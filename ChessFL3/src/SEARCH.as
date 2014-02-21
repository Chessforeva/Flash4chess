package
{
	public class SEARCH
	{
	private var LL:INT64 = Main.LL;
	private var Piece:PIECE = Main.Piece;
	private var BitBoard:BITBOARD = Main.BitBoard;
	private var Position:POSITION = Main.Position;
	private var KillerTable:KILLERTABLE = Main.KillerTable;
	private var History:HISTORY = Main.History;
	private var TranspositionTable:TRANSP_TABLE = Main.TranspositionTable;
	private var TextIO:TEXTIO = Main.TextIO;
	private var Evaluate:EVALUATE = Main.Evaluate;
	private var MoveGen:MOVEGEN = Main.MoveGen;
	private var ComputerPlayer:COMP_PLAYER = Main.ComputerPlayer;
	
	public var plyScale:int = 2 // Fractional ply resolution (def.8)

    private var pos:POSITION = null;
    private var kt:KILLERTABLE = KillerTable.clone();
	private var ht:HISTORY = History.clone();
    private var tt:TRANSP_TABLE = null;
	
    private var posHashList:Array = [];		// List of hashes for previous positions up to the last "zeroing" move.
    private var posHashListSize:uint = 0;	// Number of used entries in posHashList
    private var posHashFirstNew:uint = 0;	// First entry in posHashList that has not been played OTB.

    private var /*SearchTreeInfo[]*/ searchTreeInfo:Array = [];
	
    private function SetAtt2AllowNullMove():void {
        for (var i:int = 0; i < this.searchTreeInfo.length; i++) {
            this.searchTreeInfo[i].allowNullMove = true;
        }
    }

    // Time management
    private var tStart:Number;					// Time when search started
    private var minTimeMillis:Number = -1;		// Minimum recommended thinking time
    private var maxTimeMillis:Number = -1;		// Maximum allowed thinking time
    private var searchNeedMoreTime:Boolean =  false; // True if negaScout should use up to maxTimeMillis time.
    private var maxNodes:int = -1;		// Maximum number of nodes to search (approximately)
    private var nodesToGo:int = 0;		// Number of nodes until next time check
    private var nodesBetweenTimeCheck:Number = 5000; // How often to check remaining time

	public function rtime():Number { return (new Date()).getTime(); }
	
    // Search statistics stuff
	private var nodes:int = 0;
    private var qNodes:int = 0;
    private var /*int[]*/ nodesPlyVec:Array = [];
    private var /*int[]*/ nodesDepthVec:Array = [];
    private var totalNodes:int = 0;
    private var tLastStats:Number = 0;        // Time when notifyStats was last called
    private var verbose:Boolean = false;
    private var StopSearch:Boolean = false;
    
    public const MATE0:int = 32000;

    private var /*int[]*/ captures:Array = [];  /* new int[64] */   // Value of captured pieces
    private var seeUi:UNDOINFO = new UNDOINFO();

    public const UNKNOWN_SCORE:int = -32767; // Represents unknown eval score
    private var q0Eval:int = 0;		        // eval score at first level of quiescence search 
	private var TTentry:TTEntry = new TTEntry();
    private var emptyMove:MOVE = new MOVE(0, 0, Piece.EMPTY, 0);

    private function initNodeStats():void {
        this.nodes = 0;
        this.qNodes = 0;
		for (var i:int = 0; i < 20; i++)
			{
			this.nodesPlyVec[i] = 0;
			this.nodesDepthVec[i] = 0;
			}
    }
    
    public function Search( pos:POSITION, /*long[]*/ posHashList:Array,  posHashListSize:uint,
                            tt:TRANSP_TABLE ):void {
        this.pos = pos.clone();
        this.posHashList = posHashList;
        this.posHashListSize = posHashListSize;
        this.tt = tt;
        this.posHashFirstNew = posHashListSize;
        this.initNodeStats();
        for (var i:int = 0; i<200; i++) this.searchTreeInfo[i] = new SearchTreeInfo();
        for (i=0; i<64; i++) this.captures[i] = 0;
        this.StopSearch = false;
    }
                 
    /* implements Comparator<MoveInfo> */
    private function SortByScore ( mi1:MoveInfo, mi2:MoveInfo ):int {
                if ((mi1 == null) && (mi2 == null))
                    return 0;
                if (mi1 == null)
                    return 1;
                if (mi2 == null)
                    return -1;
                return mi2.move.score - mi1.move.score;
    }
		
    /* implements Comparator<MoveInfo> */
    private function SortByNodes ( mi1:MoveInfo, mi2:MoveInfo ):int {
                if ((mi1 == null) && (mi2 == null))
                    return 0;
                if (mi1 == null)
                    return 1;
                if (mi2 == null)
                    return -1;
                return mi2.nodes - mi1.nodes;
    }

    public function timeLimit ( minTimeLimit:Number, maxTimeLimit:Number ):void {
        this.minTimeMillis = minTimeLimit;
        this.maxTimeMillis = maxTimeLimit;
    }

    public function iterativeDeepening( scMovesIn:MoveList,
                        maxDepth:int, initialMaxNodes:int, verbose:Boolean ):MOVE {
        this.tStart = rtime();
        this.tLastStats = rtime();
        this.totalNodes = 0;
        var /*MoveInfo[]*/ scMoves:Array = [];    /*new MoveInfo[scMovesIn.size]*/
        var len:int = 0;
		var i:int = 0;
		var tNow:Number;
		var m:MOVE;
        for (var mi:int = 0; mi < scMovesIn.size; mi++) {
            m = scMovesIn.m[mi];
            scMoves[len++] = new MoveInfo(m, 0);
        }
        this.maxNodes = initialMaxNodes;
        this.nodesToGo = 0;
        var origPos:POSITION = this.pos.clone();
        var aspirationDelta:int = 20;
        var bestScoreLastIter:int = 0;
        var bestMove:MOVE = scMoves[0].move;
        this.verbose = verbose;
        this.SetAtt2AllowNullMove();

        for (var depth:int = 1; !this.StopSearch; depth++) {
            this.initNodeStats();
            
            trace("Depth:" + depth.toString());
            
            var alpha:int = ( depth > 1 ? Math.max(bestScoreLastIter - aspirationDelta,
                             -this.MATE0) : -this.MATE0 );
            var bestScore:int = -this.MATE0;
            var ui:UNDOINFO = new UNDOINFO();
            var needMoreTime:Boolean = false;
            for (mi = 0; mi < scMoves.length; mi++) {
                this.searchNeedMoreTime = (mi > 0);
                m = scMoves[mi].move;
                // trace( "Current move" + TextIO.moveToString(origPos,m,true) )
                this.nodes = 0;
                this.qNodes = 0;
                this.posHashList[this.posHashListSize++] = this.pos.zobristHash();
                var givesCheck:Boolean = MoveGen.givesCheck(this.pos, m);
                var beta:int = 0;
                if (depth > 1) {
                    beta = (mi == 0) ? Math.min(bestScoreLastIter + aspirationDelta, this.MATE0) : alpha + 1;
                } else {
                    beta = this.MATE0;
                }

                var lmr:int = 0;
                var isCapture:Boolean = (this.pos.getPiece(m.to) != Piece.EMPTY);
                var isPromotion:Boolean = (m.promoteTo != Piece.EMPTY);
                if ((depth >= 3) && !isCapture && !isPromotion) {
                    if (!givesCheck && !this.passedPawnPush(this.pos, m)) {
                        if (mi >= 3) lmr = 1;
                    }
                }
                this.pos.makeMove(m, ui);
                var sti:SearchTreeInfo = this.searchTreeInfo[0];
                sti.currentMove = m;
                sti.lmr = lmr * this.plyScale;
                sti.nodeIdx = -1;
                var score:int = -this.negaScout(-beta, -alpha, 1,
                         (depth - lmr - 1) * this.plyScale, -1, givesCheck);
                if ((lmr > 0) && (score > alpha)) {
                    sti.lmr = 0;
                    score = -this.negaScout(-beta, -alpha, 1, (depth - 1) * this.plyScale, -1, givesCheck);
                }
                var nodesThisMove:int = this.nodes + this.qNodes;
                this.posHashListSize--;
                this.pos.unMakeMove(m, ui);
                {
                    var Stype:int = TTentry.T_EXACT;
                    if (score <= alpha) {
                        Stype = TTentry.T_LE;
                    } else if (score >= beta) {
                        Stype = TTentry.T_GE;
                    }
                    m.score = score;
                    this.tt.insert(this.pos.historyHash(), m, Stype, 0, depth, this.UNKNOWN_SCORE);
                }
				var retryDelta:int = 0;
                if (score >= beta) {
                    retryDelta = (aspirationDelta<<1);
                    while ((score >= beta) && (!this.StopSearch)) {
                        beta = Math.min(score + retryDelta, this.MATE0);
                        retryDelta = (this.MATE0<<1);
                        if (mi != 0) needMoreTime = true;
                        bestMove = m;
                        if (verbose)
                        {
                            //trace    TextIO.moveToString(this.pos, m, false),
                            //   score, this.nodes, this.qNodes;
                            this.notifyPV(depth, score, false, true, m);
                        }
                        this.nodes = 0;
                        this.qNodes = 0;
                        this.posHashList[this.posHashListSize++] = this.pos.zobristHash();
                        this.pos.makeMove(m, ui);
                        score = -this.negaScout(-beta, -score, 1, (depth - 1) * this.plyScale, -1, givesCheck);
                        nodesThisMove += this.nodes + this.qNodes;
                        this.posHashListSize--;
                        this.pos.unMakeMove(m, ui);
                    }
                } else if ((mi == 0) && (score <= alpha)) {
                    retryDelta = (this.MATE0<<1);
                    while ((score <= alpha) && (!this.StopSearch)) {
                        alpha = Math.max(score - retryDelta, -this.MATE0);
                        retryDelta = (this.MATE0<<1);
                        needMoreTime = true;
                        this.searchNeedMoreTime = true;
                        if (verbose)
                        {
                            //trace     TextIO.moveToString(this.pos, m, false),
                            //   score, this.nodes, this.qNodes;
                            this.notifyPV(depth, score, true, false, m);
                        }    
                        this.nodes = 0;
                        this.qNodes = 0;
                        this.posHashList[this.posHashListSize++] = this.pos.zobristHash();
                        this.pos.makeMove(m, ui);
                        score = -this.negaScout(-score, -alpha, 1, (depth - 1) * this.plyScale, -1, givesCheck);
                        nodesThisMove += this.nodes + this.qNodes;
                        this.posHashListSize--;
                        this.pos.unMakeMove(m, ui);
                    }
                }
                if (verbose) {
                    var havePV:Boolean = false;
                    var PV:String = "";
                    if ((score > alpha) || (mi == 0)) {
                        havePV = true;
                        if (verbose) {
                            PV = TextIO.moveToString(this.pos, m, false) + " ";
                            this.pos.makeMove(m, ui);
                            PV += this.tt.extractPV(this.pos);
                            this.pos.unMakeMove(m, ui);
                        }
                    }
                    //if (verbose) {
                        // trace     TextIO.moveToString(this.pos, m, false), score,
                        //    this.nodes, this.qNodes, (score > alpha ? " *" : ""), PV
                    //}
                    if (verbose && havePV && (depth > 1)) {
                        this.notifyPV(depth, score, false, false, m);
                    }
                }
                scMoves[mi].move.score = score;
                scMoves[mi].nodes = nodesThisMove;
                bestScore = Math.max(bestScore, score);
                if (depth > 1) {
                    if ((score > alpha) || (mi == 0)) {
                        alpha = score;
                        var tmp:MoveInfo = scMoves[mi];
                        for (i = mi - 1; i >= 0;  i--) {
                            scMoves[i + 1] = scMoves[i];
                        }
                        scMoves[0] = tmp;
                        bestMove = scMoves[0].move;
                    }
                }

            if (depth == 1) {
                scMoves.sort(this.SortByScore);
                bestMove = scMoves[0].move;
                if(verbose) this.notifyPV(depth, bestMove.score, false, false, bestMove);
            }
            
            if (this.maxTimeMillis >= 0) {
                tNow = rtime();

                if (tNow - this.tStart >= this.maxTimeMillis)
                    {
                    if( ComputerPlayer.maxDepth > 2 ) ComputerPlayer.maxDepth--;    // self adjusting depth
                    trace("timeout");
                    this.StopSearch = true;
                    break;
                    }
				if(depth > 1 )
				{
				var timeLimit:Number = (needMoreTime ? this.maxTimeMillis : this.minTimeMillis);
				if (tNow - this.tStart >= timeLimit)
					{
					this.StopSearch = true;
					break;
					}
				}
            }
            
            if (this.maxNodes >= 0)
             {
             if (this.totalNodes >= this.maxNodes) this.StopSearch = true;
             }

            if (depth > maxDepth)
                {
				 // self adjusting depth
                 ComputerPlayer.maxDepth++;
                 this.StopSearch = true;
                } 
                    
            var plyToMate:int = this.MATE0 - Math.abs(bestScore);
            if (depth >= plyToMate) break;
            bestScoreLastIter = bestScore;

            if (depth > 1) {
                // Moves that were hard to search should be searched early in the next iteration
                // Originally java .sort(1,len,sortfunc) from the position 1
                scMoves = scMoves.slice(0, 1).concat( scMoves.slice(1).sort(this.SortByNodes) );
            }
            
        }
        
        }
        this.notifyStats();
        
        return bestMove;
    }

    private function notifyPV( depth:int, score:int,
                     uBound:Boolean, lBound:Boolean, m:MOVE):void {
            var isMate:Boolean = false;
            if (score > this.MATE0 / 2) {
                isMate = true;
                score = (this.MATE0 - score) / 2;
            } else if (score < -this.MATE0 / 2) {
                isMate = true;
                score = -((this.MATE0 + score - 1) / 2);
            }
            var tNow:Number = rtime();
            var time:Number = tNow - this.tStart;
            var nps:int = (time > 0) ? /*(int)*/(this.totalNodes / (time / 1000)) : 0;
            var /*ArrayList<Move>*/ pv:Array = this.tt.extractPVMoves(this.pos, m);
            var pvS:String = "";
            for(var j:int=0;j<pv.length;j++)
             {
              pvS+= TextIO.moveToString(this.pos, pv[j], false) + "(" + parseInt(pv[j].score).toString() + ") ";
             }
            
            var s:String = "depth:" + depth.toString();
            s+= " score:" + score.toString();
            s+= " time:" + int(time / 1000).toString();
            s+= " nodes:" + this.totalNodes.toString();
            s+= " nps:" + nps.toString();
            s+= " mate:" + (isMate?"1":"0");
            //s+= " ub:" + (uBound?"1":"0");
            //s+= " lb:" + (lBound?"1":"0");
            s+= " " + pvS;
            trace(s);
    }

    private function notifyStats():void {
        var tNow:Number = rtime();
        var time:Number = tNow - this.tStart;
        var nps:int = (time > 0) ? (this.totalNodes / (time / 1000)) : 0;
        var s:String = "nodes:" + this.totalNodes.toString();
        s+= " nps:" + nps.toString();
        s+= " time:" + int(time / 1000).toString();
        trace(s);
        this.tLastStats = tNow;
    }

    /** 
     * Main recursive search algorithm.
     * return Score for the side to make a move, in position given by "pos".
     */
    private function negaScout( alpha:int, beta:int, ply:int,
                     depth:int, recaptureSquare:int, inCheck:Boolean ):int {
        var pos:POSITION = this.pos;
		var moves:MoveList;
		var score:int = 0;
		var newDepth:int;
        if (--this.nodesToGo <= 0) {
            this.nodesToGo = this.nodesBetweenTimeCheck;
            var tNow:Number = rtime();
            var timeLimit:Number = this.searchNeedMoreTime ? this.maxTimeMillis : this.minTimeMillis;
            if ( ((timeLimit >= 0) && (tNow - this.tStart >= timeLimit)) ||
                    ((this.maxNodes >= 0) && (this.totalNodes >= this.maxNodes))) {
                this.StopSearch = true;
            }
            if (tNow - this.tLastStats >= 5000) {
                this.notifyStats();
            }
        }
        
        // Collect statistics
        if (this.verbose) {
            if (ply < 20) this.nodesPlyVec[ply]++;
            if (depth < 20*this.plyScale) this.nodesDepthVec[depth/this.plyScale]++;
        }
        this.nodes++;
        this.totalNodes++;
        var hKey:uint = pos.historyHash();

        // Draw tests
        if (this.canClaimDraw50(pos)) {
            if (MoveGen.canTakeKing(pos)) {
                score = this.MATE0 - ply;
                return score;
            }
            if (inCheck) {
            
                moves = MoveGen.pseudoLegalMoves(pos);
                MoveGen.removeIllegal(pos, moves)
            
                if (moves.size == 0) {            // Can't claim draw if already check mated.
                    score = -(this.MATE0-(ply+1));
                    MoveGen.returnMoveList(moves);
                    return score;
                }
                MoveGen.returnMoveList(moves);
            }
          return 0;
        }
        if (this.canClaimDrawRep(pos, this.posHashList, this.posHashListSize, this.posHashFirstNew)) {
            return 0;            // No need to test for mate here, since it would have been
                                 // discovered the first time the position came up.
        }

        var evalScore:int = this.UNKNOWN_SCORE;
        // Check transposition table
        var ent:TTEntry = this.tt.probe(hKey);
        var hashMove:MOVE = null;
        var sti:SearchTreeInfo = this.searchTreeInfo[ply];
        if (ent.Stype != TTentry.T_EMPTY) {
            score = ent.getScore(ply);
            evalScore = ent.evalScore;
            var plyToMate:int = this.MATE0 - Math.abs(score);
            var eDepth:int = ent.getDepth();
            if ((beta == alpha + 1) && ((eDepth >= depth) || (eDepth >= plyToMate*this.plyScale))) {
                if (    (ent.Stype == TTentry.T_EXACT) ||
                        (ent.Stype == TTentry.T_GE) && (score >= beta) ||
                        (ent.Stype == TTentry.T_LE) && (score <= alpha)) {
                 return score;
                }
            }
            hashMove = sti.hashMove;
            ent.getMove(hashMove);
        }
        
        var posExtend:int = (inCheck ? this.plyScale : 0); // Check extension

        // If out of depth, perform quiescence search
        if (depth + posExtend <= 0) {
            this.qNodes--;
            this.totalNodes--;
            this.q0Eval = evalScore;
            score = this.quiesce(alpha, beta, ply, 0, inCheck);
            var Ztype:int = TTentry.T_EXACT;
            if (score <= alpha) {
                Ztype = TTentry.T_LE;
            } else if (score >= beta) {
                Ztype = TTentry.T_GE;
            }
            this.emptyMove.score = score;
            this.tt.insert(hKey, this.emptyMove, Ztype, ply, depth, this.q0Eval);
            return score;
        }

        // Try null-move pruning
        sti.currentMove = this.emptyMove;
        if (    (depth >= 3*this.plyScale) && !inCheck && sti.allowNullMove &&
                (Math.abs(beta) <= this.MATE0 / 2)) {
            if (MoveGen.canTakeKing(pos)) {
              score = this.MATE0 - ply;
              return score;
            }
            var nullOk:Boolean = false;
            if (pos.whiteMove) {
                nullOk = (pos.wMtrl > pos.wMtrlPawns) && (pos.wMtrlPawns > 0);
            } else {
                nullOk = (pos.bMtrl > pos.bMtrlPawns) && (pos.bMtrlPawns > 0);
            }
            if (nullOk) {
                var R:int = (depth > 6*this.plyScale) ? (this.plyScale<<2) : 3*this.plyScale;
                pos.setWhiteMove(!pos.whiteMove);
                var epSquare:int = pos.getEpSquare();
                pos.setEpSquare(-1);
                this.searchTreeInfo[ply+1].allowNullMove = false;
                score = -this.negaScout(-beta, -(beta - 1), ply + 1, depth - R, -1, false);
                this.searchTreeInfo[ply+1].allowNullMove = true;
                pos.setEpSquare(epSquare);
                pos.setWhiteMove(!pos.whiteMove);
                if (score >= beta) {
                    if (score > this.MATE0 / 2)
                        score = beta;
                    this.emptyMove.score = score;
                    this.tt.insert(hKey, this.emptyMove, TTentry.T_GE, ply, depth, evalScore);
                    return score;
                } else {
                    if ((this.searchTreeInfo[ply-1].lmr > 0) && (depth < 5*this.plyScale)) {
                        var m1:MOVE = this.searchTreeInfo[ply-1].currentMove;
                        var m2:MOVE = this.searchTreeInfo[ply+1].bestMove; // threat move
                        if (m1.from != m1.to) {
                            if ((m1.to == m2.from) || (m1.from == m2.to) ||
                                LL.not0( LL.and(BitBoard.squaresBetween[m2.from][m2.to], LL.bitObj(m1.from))) ) {
                                // if the threat move was made possible by a reduced
                                // move on the previous ply, the reduction was unsafe.
                                // Return alpha to trigger a non-reduced re-this.
                              return alpha;
                            }
                        }
                    }
                }
            }
        }

        // Razoring
        if ((Math.abs(alpha) <= this.MATE0 / 2) && (depth < (this.plyScale<<2)) && (beta == alpha + 1)) {
            if (evalScore == this.UNKNOWN_SCORE) {
                evalScore = Evaluate.evalPos(pos);
            }
            var razorMargin:int = 250;
            if (evalScore < beta - razorMargin) {
                this.qNodes--;
                this.totalNodes--;
                this.q0Eval = evalScore;
                score = this.quiesce(alpha-razorMargin, beta-razorMargin, ply, 0, inCheck);
                if (score <= alpha-razorMargin) {
                  return score;
                }
            }
        }

        var futilityPrune:Boolean = false;
        var futilityScore:int = alpha;
        if (!inCheck && (depth < 5*this.plyScale) && (posExtend == 0)) {
            if ((Math.abs(alpha) <= this.MATE0 / 2) && (Math.abs(beta) <= this.MATE0 / 2)) {
                var margn:int = 0;
                if (depth <= this.plyScale) {
                    margn = 125;
                } else if (depth <= (this.plyScale<<1)) {
                    margn = 250;
                } else if (depth <= 3*this.plyScale) {
                    margn = 375;
                } else {
                    margn = 500;
                }
                if (evalScore == this.UNKNOWN_SCORE) {
                    evalScore = Evaluate.evalPos(pos);
                }
                futilityScore = evalScore + margn;
                if (futilityScore <= alpha) {
                    futilityPrune = true;
                }
            }
        }

        if ((depth > (this.plyScale<<2)) && ((hashMove == null) || (hashMove.from == hashMove.to))) {
            var isPv:Boolean = beta > alpha + 1;
            if (isPv || (depth > (this.plyScale<<3))) {
                // No hash move. Try internal iterative deepening.
                var savedNodeIdx:int = sti.nodeIdx;
                newDepth = ( isPv ? depth  - (this.plyScale<<1) : (depth * 3 )>>>3 );
                this.negaScout(alpha, beta, ply, newDepth, -1, inCheck);
                sti.nodeIdx = savedNodeIdx;
                ent = this.tt.probe(hKey);
                if (ent.Stype != TTentry.T_EMPTY) {
                    hashMove = sti.hashMove;
                    ent.getMove(hashMove);
                }
            }
        }

        // Start searching move alternatives
        
        if (inCheck)
            moves = MoveGen.checkEvasions(pos);
        else 
            moves = MoveGen.pseudoLegalMoves(pos);
        var seeDone:Boolean = false;
        var hashMoveSelected:Boolean = true;
        if (!this.selectHashMove(moves, hashMove)) {
            this.scoreMoveList(moves, ply,0);
            seeDone = true;
            hashMoveSelected = false;
        }

        var ui:UNDOINFO = sti.undoInfo;
        var haveLegalMoves:Boolean = false;
        var illegalScore:int = -(this.MATE0-(ply+1));
        var b:int = beta;
        var bestScore:int = illegalScore;
        var bestMove:int = -1;
        var lmrCount:int = 0;
		
        for (var  mi:int = 0; mi < moves.size; mi++) {
            if ((mi == 1) && !seeDone) {
                this.scoreMoveList(moves, ply, 1);
                seeDone = true;
            }
            if ((mi > 0) || !hashMoveSelected) {
                this.selectBest(moves, mi);
            }
            var m:MOVE = moves.m[mi];
            if (pos.getPiece(m.to) == (pos.whiteMove ? Piece.BKING : Piece.WKING)) {
                MoveGen.returnMoveList(moves);
                score = this.MATE0-ply;
                return score;       // King capture
            }
            var newCaptureSquare:int = -1;
            var isCapture:Boolean = false;
            var isPromotion:Boolean = (m.promoteTo != Piece.EMPTY);
            var sVal:int = int.MIN_VALUE;
			var pV:int = Evaluate.pV;
			var fVal:int = 0;
			var tVal:int = 0;
            if (pos.getPiece(m.to) != Piece.EMPTY) {
                isCapture = true;
                fVal = Evaluate.pieceValue[pos.getPiece(m.from)];
                tVal = Evaluate.pieceValue[pos.getPiece(m.to)];
                if (Math.abs(tVal - fVal) < (pV>>>1)) {    // "Equal" capture
                    sVal = this.SEE(m);
                    if (Math.abs(sVal) < (pV>>>1))
                        newCaptureSquare = m.to;
                }
            }
            var moveExtend:int = 0;
            if (posExtend == 0) {
                if ((m.to == recaptureSquare)) {
                    if (sVal == int.MIN_VALUE) sVal = this.SEE(m);
                    tVal = Evaluate.pieceValue[pos.getPiece(m.to)];
                    if (sVal > tVal - (pV>>>1))
                        moveExtend = this.plyScale;
                }
                if ((moveExtend == 0) && isCapture && (pos.wMtrlPawns + pos.bMtrlPawns > pV)) {
                    // Extend if going into pawn endgame
                    var capVal:int = Evaluate.pieceValue[pos.getPiece(m.to)];
                    if (pos.whiteMove) {
                        if ((pos.wMtrl == pos.wMtrlPawns) && (pos.bMtrl - pos.bMtrlPawns == capVal))
                            moveExtend = this.plyScale;
                    } else {
                        if ((pos.bMtrl == pos.bMtrlPawns) && (pos.wMtrl - pos.wMtrlPawns == capVal))
                            moveExtend = this.plyScale;
                    }
                }
            }
            var mayReduce:Boolean = (m.score < 53) && (!isCapture || m.score < 0) && (!isPromotion);
            
            var givesCheck:Boolean = MoveGen.givesCheck(pos, m); 
            var doFutility:Boolean = false;
            if (futilityPrune && mayReduce && haveLegalMoves) {
                if ((!givesCheck) && (!this.passedPawnPush(pos, m)))
                    doFutility = true;
            }

            if (doFutility) {
                score = futilityScore;
            } else {
                var extend1:int = Math.max(posExtend, moveExtend);
                var lmr:int = 0;
                if ((depth >= 3*this.plyScale) && mayReduce && (extend1 == 0)) {
                    if (!givesCheck && !this.passedPawnPush(pos, m)) {
                        lmrCount++;
                        if ((lmrCount > 3) && (depth > 3*this.plyScale)) {
                            lmr = (this.plyScale<<1);
                        } else {
                            lmr = this.plyScale;
                        }
                    }
                }
                this.posHashList[this.posHashListSize++] = pos.zobristHash();
                pos.makeMove(m, ui);
                sti.currentMove = m;
                newDepth = depth - this.plyScale + extend1 - lmr;
                sti.lmr = lmr;
                score = -this.negaScout(-b, -alpha, ply + 1, newDepth, newCaptureSquare, givesCheck);
                if (((lmr > 0) && (score > alpha)) ||
                    ((score > alpha) && (score < beta) && (b != beta) && (score != illegalScore))) {
                    sti.lmr = 0;
                    newDepth += lmr;
                    score = -this.negaScout(-beta, -alpha, ply + 1, newDepth, newCaptureSquare, givesCheck);
                }
                this.posHashListSize--;
                pos.unMakeMove(m, ui);
            }
            m.score = score;

            if (score != illegalScore) {
                haveLegalMoves = true;
            }
            bestScore = Math.max(bestScore, score);
            if (score > alpha) {
                alpha = score;
                bestMove = mi;
                sti.bestMove.from      = m.from;
                sti.bestMove.to        = m.to;
                sti.bestMove.promoteTo = m.promoteTo;
            }
            if (alpha >= beta) {
                if (pos.getPiece(m.to) == Piece.EMPTY) {
                    this.kt.addKiller(ply, m);
                    this.ht.addSuccess(pos, m, depth/this.plyScale);
                    for (var mi2:int = mi - 1; mi2 >= 0; mi2--) {
                        var m6:MOVE = moves.m[mi2];
                        if (pos.getPiece(m6.to) == Piece.EMPTY)
                            this.ht.addFail(pos, m6, depth/this.plyScale);
                    }
                }
                this.tt.insert(hKey, m, TTentry.T_GE, ply, depth, evalScore);
                MoveGen.returnMoveList(moves);
              return alpha;
            }
            b = alpha + 1;
        }
        if (!haveLegalMoves && !inCheck) {
            MoveGen.returnMoveList(moves);
           return 0;       // Stale-mate
        }
        if (bestMove >= 0) {
            this.tt.insert(hKey, moves.m[bestMove], TTentry.T_EXACT, ply, depth, evalScore);
      } else {
            this.emptyMove.score = bestScore;
            this.tt.insert(hKey, this.emptyMove, TTentry.T_LE, ply, depth, evalScore);
      }
        MoveGen.returnMoveList(moves);
        return bestScore;
    }

    private function passedPawnPush( pos:POSITION, m:MOVE ):Boolean {
        var p:int = pos.getPiece(m.from);
        if (pos.whiteMove) {
            if (p != Piece.WPAWN)
                return false;
            if ( LL.not0( LL.and(BitBoard.wPawnBlockerMask[m.to], pos.pieceTypeBB[Piece.BPAWN]) ) )
                return false;
            return (m.to >= 40);
        } else {
            if (p != Piece.BPAWN)
                return false;
            if ( LL.not0( LL.and(BitBoard.bPawnBlockerMask[m.to], pos.pieceTypeBB[Piece.WPAWN]) ) )
                return false;
            return (m.to <= 23);
        }
    }

    /**
     * Quiescence this. Only non-losing captures are searched.
     */
    private function quiesce( alpha:int, beta:int, ply:int,
                 depth:int, inCheck:Boolean ):int {
        var pos:POSITION = this.pos;
        this.qNodes++;
        this.totalNodes++;
        var score:int = 0;
        if (inCheck) {
            score = -(this.MATE0 - (ply+1));
        } else {
            if ((depth == 0) && (this.q0Eval != this.UNKNOWN_SCORE)) {
                score = this.q0Eval;
            } else {
                score = Evaluate.evalPos(pos);
                if (depth == 0)
                    this.q0Eval = score;
            }
        }
        if (score >= beta) {
            if ((depth == 0) && (score < this.MATE0 - ply)) {
                if (MoveGen.canTakeKing(pos)) {
                    // To make stale-mate detection work
                    score = this.MATE0 - ply;
                }
            }
            return score;
        }
        var evalScore:int = score;
        if (score > alpha)
            alpha = score;
        var bestScore:int = score;
        var tryChecks:Boolean = (depth > -3);
        var moves:MoveList;
        if (inCheck) {
            moves = MoveGen.checkEvasions(pos);
        } else if (tryChecks) {
            moves = MoveGen.pseudoLegalCapturesAndChecks(pos);
        } else {
            moves = MoveGen.pseudoLegalCaptures(pos);
        }
        this.scoreMoveListMvvLva(moves);
        var ui:UNDOINFO = this.searchTreeInfo[ply].undoInfo;
        for (var mi:int = 0; mi < moves.size; mi++) {
            if (mi < 8) {
                // If the first 8 moves didn't fail high, this is probably an ALL-node,
                // so spending more effort on move ordering is probably wasted time.
                this.selectBest(moves, mi);
            }
            var m:MOVE = moves.m[mi];
            if (pos.getPiece(m.to) == (pos.whiteMove ? Piece.BKING : Piece.WKING)) {
                MoveGen.returnMoveList(moves);
                return this.MATE0-ply;       // King capture
            }
            var givesCheck:Boolean = false;
            var givesCheckComputed:Boolean = false;
            if (inCheck) {
                // Allow all moves
            } else {
                if ((pos.getPiece(m.to) == Piece.EMPTY) && (m.promoteTo == Piece.EMPTY)) {
                    // Non-capture
                    if (!tryChecks)
                        continue;
                    givesCheck = MoveGen.givesCheck(pos, m);
                    givesCheckComputed = true;
                    if (!givesCheck)
                        continue;
                    if (this.negSEE(m)) // Needed because m.score is not computed for non-captures
                        continue;
                } else {
                    if (this.negSEE(m))
                        continue;
                    var capt:int = Evaluate.pieceValue[pos.getPiece(m.to)];
                    var prom:int = Evaluate.pieceValue[m.promoteTo];
                    var optimisticScore:int = evalScore + capt + prom + 200;
                    if (optimisticScore < alpha) { // Delta pruning
                        if ((pos.wMtrlPawns > 0) && (pos.wMtrl > capt + pos.wMtrlPawns) &&
                            (pos.bMtrlPawns > 0) && (pos.bMtrl > capt + pos.bMtrlPawns)) {
                            if (depth -1 > -4) {
                                givesCheck = MoveGen.givesCheck(pos, m);
                                givesCheckComputed = true;
                            }
                            if (!givesCheck) {
                                if (optimisticScore > bestScore)
                                    bestScore = optimisticScore;
                                continue;
                            }
                        }
                    }
                }
            }

            if (!givesCheckComputed) {
                if (depth - 1 > -4) {
                    givesCheck = MoveGen.givesCheck(pos, m);
                }
            }
            var nextInCheck:Boolean = ((depth - 1) > -4 ? givesCheck : false );

            pos.makeMove(m, ui);
            score = -this.quiesce(-beta, -alpha, ply + 1, depth - 1, nextInCheck);
            pos.unMakeMove(m, ui);
            if (score > bestScore) {
                bestScore = score;
                if (score > alpha) {
                    alpha = score;
                    if (alpha >= beta) {
                        MoveGen.returnMoveList(moves);
                        return alpha;
                    }
                }
            }
        }
        MoveGen.returnMoveList(moves);
        return bestScore;
    }

    private function  negSEE( m:MOVE ):Boolean {
        var p0:int = Evaluate.pieceValue[this.pos.getPiece(m.from)];
        var p1:int = Evaluate.pieceValue[this.pos.getPiece(m.to)];
        if (p1 >= p0) return false;
        return (this.SEE(m) < 0);
    }

    /**
     * exchange evaluation function.
     * return SEE score for m. Positive value is good for the side that makes the first move.
     */
    private function SEE( m:MOVE ):int {
        var kV:int = Evaluate.kV;
        var pos:POSITION = this.pos;
        var square:int = m.to;
        if (square == pos.getEpSquare()) {
            this.captures[0] = Evaluate.pV;
        } else {
            this.captures[0] = Evaluate.pieceValue[pos.getPiece(square)];
            if (this.captures[0] == kV) return kV;
        }
        var nCapt:int = 1;                  // Number of entries in captures[]

        pos.makeSEEMove(m, this.seeUi);
        var white:Boolean = pos.whiteMove;
        var valOnSquare:int = Evaluate.pieceValue[pos.getPiece(square)];
        var occupied:i64 = LL.or( pos.whiteBB, pos.blackBB );
        var /*long*/ atk:i64;
        var /*long*/ bAtk:i64;
        var /*long*/ rAtk:i64;
        while (true) {
            var bestValue:int = int.MAX_VALUE;
            if (white) {
                atk = LL.and( BitBoard.bPawnAttacks[square], LL.and( pos.pieceTypeBB[Piece.WPAWN], occupied ));
                if ( LL.not0(atk) ) {
                    bestValue = Evaluate.pV;
                } else {
                    atk = LL.and( BitBoard.knightAttacks[square],
                         LL.and( pos.pieceTypeBB[Piece.WKNIGHT], occupied ));
                    if ( LL.not0(atk) ) {
                        bestValue = Evaluate.nV;
                    } else {
                        bAtk = LL.and( BitBoard.bishopAttacks(square, occupied), occupied );
                        atk = LL.and( bAtk, pos.pieceTypeBB[Piece.WBISHOP] );
                        if ( LL.not0(atk) ) {
                            bestValue = Evaluate.bV;
                        } else {
                            rAtk = LL.and( BitBoard.rookAttacks(square, occupied), occupied );
                            atk = LL.and( rAtk, pos.pieceTypeBB[Piece.WROOK] );
                            if ( LL.not0(atk) ) {
                                bestValue = Evaluate.rV;
                            } else {
                                atk = LL.and( LL.or(bAtk,rAtk), pos.pieceTypeBB[Piece.WQUEEN] );
                                if ( LL.not0(atk) ) {
                                    bestValue = Evaluate.qV;
                                } else {
                                    atk = LL.and( BitBoard.kingAttacks[square],
                                        LL.and(  pos.pieceTypeBB[Piece.WKING], occupied ));
                                    if ( LL.not0(atk) ) {
                                        bestValue = kV;
                                    } else {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                atk = LL.and( BitBoard.wPawnAttacks[square],
                        LL.and( pos.pieceTypeBB[Piece.BPAWN], occupied ));
                if ( LL.not0(atk) ) {
                    bestValue = Evaluate.pV;
                } else {
                    atk = LL.and( BitBoard.knightAttacks[square],
                        LL.and( pos.pieceTypeBB[Piece.BKNIGHT], occupied ));
                    if ( LL.not0(atk) ) {
                        bestValue = Evaluate.nV;
                    } else {
                        bAtk = LL.and( BitBoard.bishopAttacks(square, occupied), occupied );
                        atk = LL.and( bAtk, pos.pieceTypeBB[Piece.BBISHOP] );
                        if ( LL.not0(atk) ) {
                            bestValue = Evaluate.bV;
                        } else {
                            rAtk = LL.and( BitBoard.rookAttacks(square, occupied), occupied );
                            atk = LL.and( rAtk, pos.pieceTypeBB[Piece.BROOK] );
                            if ( LL.not0(atk) ) {
                                bestValue = Evaluate.rV;
                            } else {
                                atk = LL.and( LL.or(bAtk,rAtk), pos.pieceTypeBB[Piece.BQUEEN] );
                                if ( LL.not0(atk) ) {
                                    bestValue = Evaluate.qV;
                                } else {
                                    atk = LL.and( BitBoard.kingAttacks[square],
                                        LL.and( pos.pieceTypeBB[Piece.BKING], occupied ));
                                    if ( LL.not0(atk) ) {
                                        bestValue = kV;
                                    } else {
                                        break;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            this.captures[nCapt++] = valOnSquare;
            if (valOnSquare == kV)
                break;
            valOnSquare = bestValue;
            LL.and_( occupied,  LL.not( LL.and( atk, LL.neg(atk) ) ) );
            white = !white;
        }
        pos.unMakeSEEMove(m, this.seeUi);
        
        var score:int = 0;
        for (var q:int = nCapt - 1; q > 0; q--) {
            score = Math.max(0, this.captures[q] - score);
        }
        return (this.captures[0] - score);
    }

    /**
     * Compute scores for each move in a move list, using SEE, killer and history information.
     * param moves  List of moves to score.
     */
    
    public function scoreMoveList( moves:MoveList, ply:int, startIdx:int ):void {
        for (var i:int = startIdx; i < moves.size; i++) {
            var m:MOVE = moves.m[i];
            var isCapture:Boolean = (this.pos.getPiece(m.to) != Piece.EMPTY) || (m.promoteTo != Piece.EMPTY);
            var score:int = (isCapture ? this.SEE(m) : 0);
            var ks:int = this.kt.getKillerScore(ply, m);
            if (ks > 0) {
                score += ks + 50;
            } else {
                var hs:int = this.ht.getHistScore(this.pos, m);
                score += hs;
            }
            m.score = score;
        }
    }
    
    private function scoreMoveListMvvLva( moves:MoveList ):void {
        for (var i:int = 0; i < moves.size; i++) {
            var m:MOVE = moves.m[i];
            var v:int = this.pos.getPiece(m.to);
            var a:int = this.pos.getPiece(m.from);
            m.score = ((Evaluate.pieceValue[v]<<4) * 625) - Evaluate.pieceValue[a];
        }
    }

    /**
     * Find move with highest score and move it to the front of the list.
     */
    private function selectBest ( moves:MoveList, startIdx:int ):void {
        var bestIdx:int = startIdx;
        var bestScore:int = moves.m[bestIdx].score;
        for (var i:int = startIdx + 1; i < moves.size; i++) {
            var sc:int = moves.m[i].score;
            if (sc > bestScore) {
                bestIdx = i;
                bestScore = sc;
            }
        }
        if (bestIdx != startIdx) {
            var m:MOVE = moves.m[startIdx];
            moves.m[startIdx] = moves.m[bestIdx];
            moves.m[bestIdx] = m;
        }
    }

    /** If hashMove exists in the move list, move the hash move to the front of the list. */
    private function selectHashMove( moves:MoveList, hashMove:MOVE ):Boolean {
        if (hashMove == null) return false;
        for (var i:int = 0; i < moves.size; i++) {
            var m:MOVE = moves.m[i];
            if ((m!=null) && m.equalsMove(hashMove)) {
                moves.m[i] = moves.m[0];
                moves.m[0] = m;
                m.score = 10000;
                return true;
            }
        }
        return false;
    }

    public function canClaimDraw50( pos:POSITION ):Boolean {
        return (pos.halfMoveClock >= 100);
    }
    
    public function canClaimDrawRep( pos:POSITION, /*long[]*/ posHashList:Array,
             posHashListSize:int, posHashFirstNew:int ):Boolean {
        var reps:int = 0;
        for (var i:int = posHashListSize - 4; i >= 0; i -= 2) {
            if (pos.zobristHash() == posHashList[i]) {
                reps++;
                if (i >= posHashFirstNew) {
                    reps++;
                    break;
                }
            }
        }
        return (reps >= 2);
    }
	
	}
}