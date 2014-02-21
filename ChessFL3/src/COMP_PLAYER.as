package
{
	public class COMP_PLAYER extends PLAYER
	{
	private var Game:GAME = Main.Game;
	private var History:HISTORY = Main.History;
	private var TranspositionTable:TRANSP_TABLE = Main.TranspositionTable;
	private var Search:SEARCH = Main.Search;
	private var MoveGen:MOVEGEN = Main.MoveGen;
	private var TextIO:TEXTIO = Main.TextIO;
	private var Book:BOOK = Main.Book;
	
    private var engineName:String = "CuckooChess 1.11 Javascript port";

    private var minTimeMillis:Number = 8 * 1000;	/* 8 sec */
    private var maxTimeMillis:Number = 10 * 1000;	/* 10 sec + some */

    public var maxDepth:int = 5;		// initial
    
    private var maxNodes:int = 100000;
    private var verbose:Boolean = false /*true*/;
    private var tt:TRANSP_TABLE = null;
    private var hs:Array = [];
    private var bookEnabled:Boolean = true;
    private var randomMode:Boolean = false;
    private var currentSearch:SEARCH = null;

	public override function clone():PLAYER
		{
		var CP:COMP_PLAYER = new COMP_PLAYER()
		CP.Init1();
		return CP;
		}
		
    public function Init1():void {
        this.tt = TranspositionTable.clone();
    }
   
    /*@Override*/
    public override function getCommand(pos:POSITION, drawOffer:Boolean ):String {
        // Create a search object
        var posHashList:Array = [];    /*long[200 + histo.length]*/
        var posHashListSize:uint = 0;
        for( var j:int=0; j<Game.hist.length; j++ ) {
            posHashList[posHashListSize++] = Game.hist[j].zobristHash();
        }
        this.tt.nextGeneration();
        var sc:SEARCH = new SEARCH();
        sc.Search(pos, posHashList, posHashListSize, this.tt);

        // Determine all legal moves
        var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
        MoveGen.removeIllegal(pos, moves);
        sc.scoreMoveList(moves, 0, 0);

        // Test for "game over"
        if (moves.size == 0) {
            // Switch sides so that the human can decide what to do next.
            return "swap";
        }

        if (this.bookEnabled) {
            var bookMove:MOVE = Book.getBookMove(pos);
            if (bookMove != null) {
                trace("Book moves: " + Book.getAllBookMoves(pos) );
                return TextIO.moveToUCIString(bookMove);
            }
        }
        
        // Find best move using iterative deepening
        this.currentSearch = sc;
        var bestM:MOVE = null;
        if ((moves.size == 1) && (this.canClaimDraw(pos, posHashList, posHashListSize, moves.m[0]).length == 0)) {
            bestM = moves.m[0];
            bestM.score = 0;
        } else if (this.randomMode) {
            bestM = this.findSemiRandomMove(sc, moves);
        } else {
            sc.timeLimit(this.minTimeMillis, this.maxTimeMillis);
            bestM = sc.iterativeDeepening(moves, this.maxDepth, this.maxNodes, this.verbose);
        }
        this.currentSearch = null;
        this.tt.printStats();
        var strMove:String = TextIO.moveToUCIString(bestM);

        // Claim draw if appropriate
        if (bestM.score <= 0) {
            var drawClaim:String = this.canClaimDraw(pos, posHashList, posHashListSize, bestM);
            if (drawClaim.length>0)
                {
                 strMove = drawClaim;              
                }
        }
        return strMove;
    }
    
    /** Check if a draw claim is allowed, possibly after playing "move".
     *  param move The move that may have to be made before claiming draw.
     *  return The draw string that claims the draw, or empty string if draw claim not valid.
     */
    public function canClaimDraw( pos:POSITION, posHashList:Array,
                 posHashListSize:uint, move:MOVE ):String {
        var drawStr:String = "";
        if (Search.canClaimDraw50(pos)) {
            drawStr = "draw 50";
        } else if (Search.canClaimDrawRep(pos, posHashList, posHashListSize, posHashListSize)) {
            drawStr = "draw rep";
        } else {
            var  strMove:String = TextIO.moveToString(pos, move, false);
            posHashList[posHashListSize++] = pos.zobristHash();
            var ui:UNDOINFO = new UNDOINFO();
            pos.makeMove(move, ui);
            if (Search.canClaimDraw50(pos)) {
                drawStr = "draw 50 " + strMove;
            } else if (Search.canClaimDrawRep(pos, posHashList, posHashListSize, posHashListSize)) {
                drawStr = "draw rep " + strMove;
            }
            pos.unMakeMove(move, ui);
        }
        return drawStr;
    }

    /*@Override*/
    public override function isHumanPlayer():Boolean {
        return false;
    }

    /*@Override*/
    public override function useBook( bookOn:Boolean ):void {
        this.bookEnabled = bookOn;
    }

    /*@Override*/
    public override function timeLimit( minTimeLimit:Number, maxTimeLimit:Number, randomMode:Boolean ):void {
        if (randomMode) {
            minTimeLimit = 0;
            maxTimeLimit = 0;
        }
        this.minTimeMillis = minTimeLimit;
        this.maxTimeMillis = maxTimeLimit;
        this.randomMode = randomMode;
        if (this.currentSearch != null) {
            this.currentSearch.timeLimit(minTimeLimit, maxTimeLimit);
        }
    }

    /*@Override*/
    public override function clearTT():void {
        this.tt.clearTable();
    }

    private function findSemiRandomMove( sc:SEARCH, moves:MoveList ):MOVE {
        sc.timeLimit(this.minTimeMillis, this.maxTimeMillis);
        var bestM:MOVE = sc.iterativeDeepening(moves, 1, this.maxNodes, this.verbose);
        var bestScore:int = bestM.score;

        var sum:int = 0;
        for (var mi:int = 0; mi < moves.size; mi++) {
            sum += this.moveProbWeight(moves.m[mi].score, bestScore);
        }
        var rnd:int = Math.floor(Math.random()*sum);
        for (mi = 0; mi < moves.size; mi++) {
            var weight:int = this.moveProbWeight(moves.m[mi].score, bestScore);
            if (rnd < weight) {
                return moves.m[mi];
            }
            rnd -= weight;
        }
        trace("Fail on findSemiRandomMove");
        return null;
    }

    private function moveProbWeight( moveScore:int, bestScore:int ):int {
        var d:Number = (bestScore - moveScore) / 100.0;
        var w:Number = 100 * Math.exp(-d*d/2);
        return Math.ceil(w);
    }

	}
}