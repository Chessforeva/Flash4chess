package
{
	public class GAME
	{
	private var Piece:PIECE = Main.Piece;
	private var Position:POSITION = Main.Position;
	private var MoveGen:MOVEGEN = Main.MoveGen;
	private var GameState:GAMESTATE = Main.GameState;
	private var TextIO:TEXTIO = Main.TextIO;
	private var Search:SEARCH = Main.Search;
	private var Evaluate:EVALUATE = Main.Evaluate;
		
	public var /*List<Move>*/ moveList:Array = [];
	public var hist:Array = [];	// history of positions...
    public var /*List<UndoInfo>*/ uiInfoList:Array = [];
    public var /*List<bool>*/ drawOfferList:Array = [];
    public var currentMove:int = 0;
    public var pendingDrawOffer:Boolean = false;
    public var drawState:int = 0;
    public var drawStateMoveStr:String = "";     // Move required to claim DRAW_REP or DRAW_50
    public var resignState:int = 0;
    public var pos:POSITION = null;
    public var whitePlayer:PLAYER = null;
    public var blackPlayer:PLAYER = null;
    
    public function CreaGame( whitePlayer:PLAYER, blackPlayer:PLAYER ):void {
        this.whitePlayer = whitePlayer;
        this.blackPlayer = blackPlayer;
        this.handleCommand("new");
    }

    /**
     * Update the game state according to move/command string from a player.
     * param str The move or command to process.
     * return True if str was understood, false otherwise.
     */
    public function processString( str:String ):Boolean {
        if (this.handleCommand(str)) return true;
        if (this.getGameState() != GameState.ALIVE) return false;

        var m:MOVE = TextIO.stringToMove(this.pos, str);
        if (m == null) return false;

        var ui:UNDOINFO = new UNDOINFO();
		var pos_pre:POSITION = this.pos.clone();
        this.pos.makeMove(m, ui);
        TextIO.fixupEPSquare(this.pos);
        while (this.currentMove < this.moveList.length) {
            this.moveList.pop();
			this.hist.pop();
            this.uiInfoList.pop();
            this.drawOfferList.pop();
        }
        this.moveList.push(m);
		this.hist.push(pos_pre);
        this.uiInfoList.push(ui);
        this.drawOfferList.push(this.pendingDrawOffer);
        this.pendingDrawOffer = false;
        this.currentMove++;
        return true;
    }

    public function getGameStateString():String {
        var dst:String = this.drawStateMoveStr;
		var ret:String = "";
        switch (this.getGameState()) {
            case GameState.ALIVE:
                return "";
            case GameState.WHITE_MATE:
                return "Game over, white mates!";
            case GameState.BLACK_MATE:
                return "Game over, black mates!";
            case GameState.WHITE_STALEMATE:
            case GameState.BLACK_STALEMATE:
                return "Game over, draw by stalemate!";
            case GameState.DRAW_REP:
            {
                ret = "Game over, draw by repetition!";
                if ((dst != null) && (dst.length > 0)) {
                    ret = ret + " [" + dst + "]";
                }
                return ret;
            }
            case GameState.DRAW_50:
            {
                ret = "Game over, draw by 50 move rule!";
                if ((dst != null) && (dst.length > 0)) {
                    ret = ret + " [" + dst + "]";  
                }
                return ret;
            }
            case GameState.DRAW_NO_MATE:
                return "Game over, draw by impossibility of mate!";
            case GameState.DRAW_AGREE:
                return "Game over, draw by agreement!";
            case GameState.RESIGN_WHITE:
                return "Game over, white resigns!";
            case GameState.RESIGN_BLACK:
                return "Game over, black resigns!";
            default:
                /*throw new*/ trace("Gamestate exception");
        }
		return "";
    }

    /**
     * Get the last played move, or null if no moves played yet.
     */
    public function getLastMove():MOVE {
        var m:MOVE = null;
        if (this.currentMove > 0) {
            m = this.moveList[ this.currentMove - 1 ];
        }
        return m;
    }

    /**
     * Get the current state of the game.
     */
    public function getGameState():int {
        var moves:MoveList = MoveGen.pseudoLegalMoves(this.pos);
        MoveGen.removeIllegal(this.pos, moves);
        if (moves.size == 0) {
            if (MoveGen.inCheck(this.pos)) {
                return this.pos.whiteMove ? GameState.BLACK_MATE : GameState.WHITE_MATE;
            } else {
                return this.pos.whiteMove ? GameState.WHITE_STALEMATE : GameState.BLACK_STALEMATE;
            }
        }
        if (this.insufficientMaterial()) {
            return GameState.DRAW_NO_MATE;
        }
        if (this.resignState != GameState.ALIVE) {
            return this.resignState;
        }
        return this.drawState;
    }

    /**
     * Check if a draw offer is available.
     * return True if the current player has the option to accept a draw offer.
     */
    public function haveDrawOffer():Boolean {
        if (this.currentMove > 0) {
            return this.drawOfferList[this.currentMove - 1];
        } else {
            return false;
        }
    }
    
    /**
     * Handle a special command.
     * param moveStr  The command to handle
     * return  True if command handled, false otherwise.
     */
    public function handleCommand(moveStr:String):Boolean {
        if (moveStr == "help") {
         trace("Valid commands:\n");
         trace("new, undo, redo, swap, go, list, setpos, getpos, resign, time n, book on/off, perft n");       
         return true;
        } else if (moveStr == "new") {
            this.moveList = [];
            this.uiInfoList = [];
            this.drawOfferList = [];
            this.currentMove = 0;
            this.pendingDrawOffer = false;
            this.drawState = GameState.ALIVE;
            this.resignState = GameState.ALIVE;
            this.pos = TextIO.readFEN(TextIO.startPosFEN);
            this.whitePlayer.clearTT();
            this.blackPlayer.clearTT();
            this.activateHumanPlayer();
            
            // clear cache
            Evaluate.ClearHash();
            return true;
        } else if (moveStr=="undo") {
            if (this.currentMove > 0) {
                this.pos.unMakeMove(this.moveList[this.currentMove - 1], this.uiInfoList[this.currentMove - 1]);
                this.currentMove--;
                this.pendingDrawOffer = false;
                this.drawState = GameState.ALIVE;
                this.resignState = GameState.ALIVE;
                return this.handleCommand("swap");
            } else {
                trace("Nothing to undo");
            }
            return true;
        } else if (moveStr=="redo") {
            if (this.currentMove < this.moveList.length) {
                this.pos.makeMove(this.moveList[this.currentMove], this.uiInfoList[this.currentMove]);
                this.currentMove++;
                this.pendingDrawOffer = false;
                return this.handleCommand("swap");
            } else {
                trace("Nothing to redo");
            }
            return true;
        } else if (moveStr=="swap" || moveStr=="go") {
            var tmp:PLAYER = this.whitePlayer;
            this.whitePlayer = this.blackPlayer;
            this.blackPlayer = tmp;
            return true;
        } else if (moveStr=="list") {
            var PGN:String = this.GetPGN();
			trace(PGN);
            return true;
        } else if ( startsWith(moveStr, "setpos ")) {
            var fen:String = moveStr.substr(moveStr.indexOf(" ") + 1);
            var newPos:POSITION = null;
            try {
                newPos = TextIO.readFEN(fen);
            } catch (e:Error) {
                trace("Invalid FEN: " + fen );
            }
            if (newPos != null) {
                this.handleCommand("new");
                this.pos = newPos;
                this.activateHumanPlayer();
            }
            return true;
        } else if (moveStr=="getpos") {
            var fen0:String = TextIO.toFEN(this.pos);
            trace( fen0 );
            return true;
        } else if (startsWith(moveStr,"draw ")) {
            if (this.getGameState() == GameState.ALIVE) {
                var drawCmd:String = moveStr.substr(moveStr.indexOf(" ") + 1);
                return this.handleDrawCmd(drawCmd);
            } else {
                return true;
            }
        } else if (moveStr=="resign") {
            if (this.getGameState()== GameState.ALIVE) {
                this.resignState = this.pos.whiteMove ? GameState.RESIGN_WHITE : GameState.RESIGN_BLACK;
                return true;
            } else {
                return true;
            }
        } else if (startsWith(moveStr,"book")) {
            var bookCmd:String = moveStr.substr(moveStr.indexOf(" ") + 1);
            return this.handleBookCmd(bookCmd);
        } else if (startsWith(moveStr,"time")) {
            try {
                var timeStr:String = moveStr.substr(moveStr.indexOf(" ") + 1);
                var timeLimit:Number = parseInt(timeStr);
                this.whitePlayer.timeLimit(timeLimit, timeLimit, false);
                this.blackPlayer.timeLimit(timeLimit, timeLimit, false);
                return true;
            }
            catch (e:Error) {
                trace("Number format exception");
                return false;
            }
        } else if (startsWith(moveStr, "perft ")) {
            try {
                var depthStr:String = moveStr.substr(moveStr.indexOf(" ") + 1);
                var depth:int = parseInt(depthStr);
                var t0:Number = Search.rtime();
                var nodes:uint = this.perfT(this.pos, depth);
                var t1:Number = (Search.rtime() - t0)/1000;
                trace("perft = " + depth.toString());
                trace("nodes = " + nodes.toString());
                trace("time s= " + t1.toString() );
            }
            catch (e:Error) {
                trace("Number format exception");
                return false;
            }
            return true;
        } else {
            return false;
        }
		return false;
    }

    /** Swap players around if needed to make the human player in control of the next move. */
    private function activateHumanPlayer():void {
        if (!(this.pos.whiteMove ? this.whitePlayer : this.blackPlayer).isHumanPlayer()) {
            var tmp:PLAYER = this.whitePlayer;
            this.whitePlayer = this.blackPlayer;
            this.blackPlayer = tmp;
        }
    }

    /**
     * Print and gets a list of all moves.
     */
    public function GetPGN():String {
        var ret:String = "";

        // Undo all moves in move history.
        var pos:POSITION = this.pos.clone();
        for (var i:int = this.currentMove; i > 0; i--) {
            pos.unMakeMove(this.moveList[i - 1], this.uiInfoList[i - 1]);
        }

        // Print all moves
        var whiteMove:String = "";
        var blackMove:String = "";
        for (i = 0; i < this.currentMove; i++) {
            var move:MOVE = this.moveList[i];
            var strMove:String = TextIO.moveToString(pos, move, false);
            if (this.drawOfferList[i]) {
                strMove += " (d)";
            }
            if (pos.whiteMove) {
                whiteMove = strMove;
            } else {
                blackMove = strMove;
                if (whiteMove.length == 0) {
                    whiteMove = "...";
                }
                ret+=(pos.fullMoveCounter.toString() + ". " + whiteMove + " " + blackMove + " ");
                whiteMove = "";
                blackMove = "";
            }
            var ui:UNDOINFO = new UNDOINFO();
            pos.makeMove(move, ui);
        }
        if ((whiteMove.length > 0) || (blackMove.length > 0)) {
            if (whiteMove.length == 0) {
                whiteMove = "...";
            }
            ret+=(pos.fullMoveCounter.toString() + ". " + whiteMove + " " + blackMove + " ");
        }
        var gameResult:String = this.getPGNResultString();
        if (!(gameResult=="*")) ret+=gameResult;
        return ret;
    }
    
    private function getPGNResultString():String {
        var gameResult:String = "*";
        switch (this.getGameState()) {
            case GameState.ALIVE:
                break;
            case GameState.WHITE_MATE:
            case GameState.RESIGN_BLACK:
                gameResult = "1-0";
                break;
            case GameState.BLACK_MATE:
            case GameState.RESIGN_WHITE:
                gameResult = "0-1";
                break;
            case GameState.WHITE_STALEMATE:
            case GameState.BLACK_STALEMATE:
            case GameState.DRAW_REP:
            case GameState.DRAW_50:
            case GameState.DRAW_NO_MATE:
            case GameState.DRAW_AGREE:
                gameResult = "1/2-1/2";
                break;
        }
        return gameResult;
    }

    /** Return a list of previous positions in this game, back to the last "zeroing" move. */
    public function /*ArrayList<Position>*/ getHistory():Array {
        var /*ArrayList<Position>*/ posList:Array = [];
        var pos:POSITION = this.pos.clone();
        for (var i:int = this.currentMove; i > 0; i--) {
            if (pos.halfMoveClock == 0) break;
            pos.unMakeMove(this.moveList[i- 1], this.uiInfoList[i- 1]);
            posList.push(pos);
        }
        return posList.reverse();
    }

    private function handleDrawCmd( drawCmd:String ):Boolean {
		var tmpPos:POSITION;
		var ui:UNDOINFO;
        if ( startsWith(drawCmd,"rep") || startsWith(drawCmd, "50")) {
            var rep:Boolean = startsWith(drawCmd, "rep");
            var m:MOVE = null;
            var ms:String = drawCmd.substr(drawCmd.indexOf(" ") + 1);
			if (startsWith(ms, "50 ")) ms = ms.substr(3);
            if (ms.length > 0) {
                m = TextIO.stringToMove(this.pos, ms);
            }
            var valid:Boolean = false;
            if (rep) {
                var /*List<Position>*/ oldPositions:Array = [];
                if (m != null) {
                    ui = new UNDOINFO();
                    tmpPos = this.pos.clone();
                    tmpPos.makeMove(m, ui);
                    oldPositions.push(tmpPos);
                }
                oldPositions.push(this.pos);
                tmpPos = this.pos;
                for (var i:int = this.currentMove - 1; i >= 0; i--) {
                    tmpPos = tmpPos.clone();
                    tmpPos.unMakeMove(this.moveList[i], this.uiInfoList[i]);
                    oldPositions.push(tmpPos);
                }
                var repetitions:int = 0;
                var firstPos:POSITION = oldPositions[0];
                for (var j:int=0; j<oldPositions.length; j++) {
                    if (oldPositions[j].drawRuleEquals(firstPos))
                        repetitions++;
                }
                if (repetitions >= 3) {
                    valid = true;
                }
            } else {
                tmpPos = this.pos.clone();
                if (m != null) {
                    ui = new UNDOINFO();
                    tmpPos.makeMove(m, ui);
                }
                valid = ( tmpPos.halfMoveClock >= 100 );
            }
            if (valid) {
                this.drawState = ( rep ? GameState.DRAW_REP : GameState.DRAW_50 );
                this.drawStateMoveStr = null;
                if (m != null) {
                    this.drawStateMoveStr = TextIO.moveToString(this.pos, m, false);
                }
            } else {
                this.pendingDrawOffer = true;
                if (m != null) {
                    this.processString(ms);
                }
            }
            return true;
        } else if (startsWith(drawCmd,"offer ")) {
            this.pendingDrawOffer = true;
            var ms0:String = drawCmd.substr(drawCmd.indexOf(" ") + 1);
            if (TextIO.stringToMove(this.pos, ms0) != null) {
                processString(ms0);
            }
            return true;
        } else if (drawCmd == "accept") {
            if (this.haveDrawOffer()) {
                this.drawState = GameState.DRAW_AGREE;
            }
            return true;
        } else {
            return false;
        }
    }

    private function handleBookCmd( bookCmd:String ):Boolean {
        if (bookCmd == "off") {
            this.whitePlayer.useBook(false);
            this.blackPlayer.useBook(false);
            return true;
        } else if (bookCmd == "on") {
            this.whitePlayer.useBook(true);
            this.whitePlayer.useBook(true);
            return true;
        }
        return false;
    }

    private function insufficientMaterial():Boolean {
        if (this.pos.nPieces(Piece.WQUEEN) > 0) return false;
        if (this.pos.nPieces(Piece.WROOK)  > 0) return false;
        if (this.pos.nPieces(Piece.WPAWN)  > 0) return false;
        if (this.pos.nPieces(Piece.BQUEEN) > 0) return false;
        if (this.pos.nPieces(Piece.BROOK)  > 0) return false;
        if (this.pos.nPieces(Piece.BPAWN)  > 0) return false;
        var wb:int = this.pos.nPieces(Piece.WBISHOP);
        var wn:int = this.pos.nPieces(Piece.WKNIGHT);
        var bb:int = this.pos.nPieces(Piece.BBISHOP);
        var bn:int = this.pos.nPieces(Piece.BKNIGHT);
        if (wb + wn + bb + bn <= 1) {
            return true;    // King + bishop/knight vs king is draw
        }
        if (wn + bn == 0) {
            // Only bishops. If they are all on the same color, the position is a draw.
            var bSquare:Boolean = false;
            var wSquare:Boolean = false;
            for (var x:int = 0; x < 8; x++) {
                for (var y:int = 0; y < 8; y++) {
                    var p:int = this.pos.getPiece(Position.getSquare(x, y));
                    if ((p == Piece.BBISHOP) || (p == Piece.WBISHOP)) {
                        if (Position.darkSquare(x, y)) {
                            bSquare = true;
                        } else {
                            wSquare = true;
                        }
                    }
                }
            }
            if (!bSquare || !wSquare) {
                return true;
            }
        }

        return false;
    }

    private function perfT( pos:POSITION, depth:int ):uint {
        if (depth == 0) return 1;
        var nodes:uint = 0;
        var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
        MoveGen.removeIllegal(pos, moves);
        if (depth == 1) {
            var ret:uint = moves.size;
            MoveGen.returnMoveList(moves);
            return ret;
        }
        var ui:UNDOINFO = new UNDOINFO();
        for (var mi:int = 0; mi < moves.size; mi++) {
            var m:MOVE = moves.m[mi];
            pos.makeMove(m, ui);
            nodes += this.perfT( pos, depth - 1 );
            pos.unMakeMove(m, ui);
        }
        MoveGen.returnMoveList(moves);
        return nodes;
    }

	public function startsWith(s:String,s1:String):Boolean
		{ return ( s.length>= s1.length ? s.substr(0,s1.length)==s1 : false ); }
	}
}