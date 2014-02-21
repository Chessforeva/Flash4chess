package
{
	public class TEXTIO
	{
	public const startPosFEN:String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";
	
	private var Piece:PIECE = Main.Piece;
	private var Position:POSITION = Main.Position;
	private var MoveGen:MOVEGEN = Main.MoveGen;
	
    /** Parse a FEN string and return a chess Position object. */
    public function readFEN( fen:String ):POSITION /*throws ChessParseError*/ {
        var pos:POSITION = Position.clone();	
       	if(fen.length==0) fen=startPosFEN;
        var /*String[]*/ words:Array = fen.split(" ");
        if (words.length < 2) {
            /*throw new*/ trace("Too few spaces");
        }
        
        // Piece placement
        var row:int = 7;
        var col:int = 0;
		var i:int;
		var /*char*/ c:String;
        for (i = 0; i < words[0].length; i++) {
            c = words[0].charAt(i);
            switch (c) {
                case '1': col += 1; break;
                case '2': col += 2; break;
                case '3': col += 3; break;
                case '4': col += 4; break;
                case '5': col += 5; break;
                case '6': col += 6; break;
                case '7': col += 7; break;
                case '8': col += 8; break;
                case '/': row--; col = 0; break;
                case 'P': this.safeSetPiece(pos, col, row, Piece.WPAWN);   col++; break;
                case 'N': this.safeSetPiece(pos, col, row, Piece.WKNIGHT); col++; break;
                case 'B': this.safeSetPiece(pos, col, row, Piece.WBISHOP); col++; break;
                case 'R': this.safeSetPiece(pos, col, row, Piece.WROOK);   col++; break;
                case 'Q': this.safeSetPiece(pos, col, row, Piece.WQUEEN);  col++; break;
                case 'K': this.safeSetPiece(pos, col, row, Piece.WKING);   col++; break;
                case 'p': this.safeSetPiece(pos, col, row, Piece.BPAWN);   col++; break;
                case 'n': this.safeSetPiece(pos, col, row, Piece.BKNIGHT); col++; break;
                case 'b': this.safeSetPiece(pos, col, row, Piece.BBISHOP); col++; break;
                case 'r': this.safeSetPiece(pos, col, row, Piece.BROOK);   col++; break;
                case 'q': this.safeSetPiece(pos, col, row, Piece.BQUEEN);  col++; break;
                case 'k': this.safeSetPiece(pos, col, row, Piece.BKING);   col++; break;
                default: /*throw new*/ trace("Invalid piece");
            }
        }
        if (words[1].length == 0) {
            /*throw new*/ trace("Invalid side");
        }
        pos.setWhiteMove(words[1].charAt(0) == 'w');
 
        // Castling rights
        var castleMask:int = 0;
        if (words.length > 2) {
            for (i = 0; i < words[2].length; i++) {
                c = words[2].charAt(i);
                switch (c) {
                    case 'K':
                        castleMask |= (Position.H1_CASTLE);
                        break;
                    case 'Q':
                        castleMask |= (Position.A1_CASTLE);
                        break;
                    case 'k':
                        castleMask |= (Position.H8_CASTLE);
                        break;
                    case 'q':
                        castleMask |= (Position.A8_CASTLE);
                        break;
                    case '-':
                        break;
                    default:
                        /*throw new*/ trace("Invalid castling flags");
                }
            }
        }
        pos.setCastleMask(castleMask);

        if (words.length > 3) {
            // En passant target square
            var epString:String = words[3];
            if (!(epString=="-")) {
                if (epString.length < 2) {
                    /*throw new*/ trace("Invalid en passant square");
                }
                pos.setEpSquare(getSquare(epString));
            }
        }

        try {
            if (words.length > 4) {
                pos.halfMoveClock = parseInt(words[4]);
            }
            if (words.length > 5) {
                pos.fullMoveCounter = parseInt(words[5]);
            }
        } catch (e:Error) {
            // Ignore errors here, since the fields are optional
        }

        // Each side must have exactly one king
        var wKings:int = 0;
        var bKings:int = 0;
        for (var x:int = 0; x < 8; x++) {
            for (var y:int = 0; y < 8; y++) {
                var p:int = pos.getPiece(Position.getSquare(x, y));
                if (p == Piece.WKING) {
                    wKings++;
                } else if (p == Piece.BKING) {
                    bKings++;
                }
            }
        }
        if (wKings != 1) {
            /*throw new*/ trace("White must have exactly one king");
        }
        if (bKings != 1) {
            /*throw new*/ trace("Black must have exactly one king");
        }


        // Make sure king can not be captured
        var /*Position*/ pos2:POSITION = pos.clone();
        pos2.setWhiteMove(!pos.whiteMove);
        
        if (MoveGen.inCheck(pos2)) {
            /*throw new*/ trace("King capture possible");
        }

        this.fixupEPSquare(pos);

        return pos;
	}

    /** Remove pseudo-legal EP square if it is not legal, ie would leave king in check. */
    public function fixupEPSquare(pos:POSITION):void {
        var epSquare:int = pos.getEpSquare();
        if (epSquare >= 0) {
                var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
                MoveGen.removeIllegal(pos, moves);      
                var epValid:Boolean = false;
                for (var mi:int = 0; mi < moves.size; mi++) {
                    var m:MOVE = moves.m[mi];
                    if (m.to == epSquare) {
                        if (pos.getPiece(m.from) == (pos.whiteMove ? Piece.WPAWN : Piece.BPAWN)) {
                            epValid = true;
                            break;
                        }
                    }
                }
                if (!epValid) pos.setEpSquare(-1);
        }
    }

    private function safeSetPiece( pos:POSITION, col:int, row:int, p:int):void {
        if (row < 0) /*throw new*/ trace("Too many rows");
        if (col > 7) /*throw new*/ trace("Too many columns");
        if ((p == Piece.WPAWN) || (p == Piece.BPAWN)) {
            if ((row == 0) || (row == 7))
                /*throw new*/ trace("Pawn on first.or.last rank");
        }
        pos.setPiece(Position.getSquare(col, row), p);
    }
    
    /** Return a FEN string corresponding to a chess Position object. */
    public function toFEN( pos:POSITION ):String {
        var ret:String = "";
        // Piece placement
        for (var r:int = 7; r >=0; r--) {
            var numEmpty:int = 0;
            for (var c:int = 0; c < 8; c++) {
                var p:int = pos.getPiece(Position.getSquare(c, r));
                if (p == Piece.EMPTY) {
                    numEmpty++;
                } else {
                    if (numEmpty > 0) {
                        ret+=numEmpty.toString();
                        numEmpty = 0;
                    }
                    switch (p) {
                        case Piece.WKING:   ret+=('K'); break;
                        case Piece.WQUEEN:  ret+=('Q'); break;
                        case Piece.WROOK:   ret+=('R'); break;
                        case Piece.WBISHOP: ret+=('B'); break;
                        case Piece.WKNIGHT: ret+=('N'); break;
                        case Piece.WPAWN:   ret+=('P'); break;
                        case Piece.BKING:   ret+=('k'); break;
                        case Piece.BQUEEN:  ret+=('q'); break;
                        case Piece.BROOK:   ret+=('r'); break;
                        case Piece.BBISHOP: ret+=('b'); break;
                        case Piece.BKNIGHT: ret+=('n'); break;
                        case Piece.BPAWN:   ret+=('p'); break;
                        default: /*throw new*/ trace("toFEN exception");
                    }
                }
            }
            if (numEmpty > 0) {
                ret+=numEmpty.toString();
            }
            if (r > 0) {
                ret+=('/');
            }
        }
        ret+=(pos.whiteMove ? " w " : " b ");

        // Castling rights
        var anyCastle:Boolean = false;
        if (pos.h1Castle()) {
            ret+=('K');
            anyCastle = true;
        }
        if (pos.a1Castle()) {
            ret+=('Q');
            anyCastle = true;
        }
        if (pos.h8Castle()) {
            ret+=('k');
            anyCastle = true;
        }
        if (pos.a8Castle()) {
            ret+=('q');
            anyCastle = true;
        }
        if (!anyCastle) {
            ret+=('-');
        }
        
        // En passant target square
        {
            ret+=(' ');
            if (pos.getEpSquare() >= 0) {
                var x:int = Position.getX(pos.getEpSquare());
                var y:int = Position.getY(pos.getEpSquare());
                ret+=String.fromCharCode(97 + x);
                ret+=String.fromCharCode(49 + y);
            } else {
                ret+=('-');
            }
        }

        // Move counters
        ret+=(' ');
        ret+=pos.halfMoveClock.toString();
        ret+=(' ');
        ret+=pos.fullMoveCounter.toString();

        return ret;
    }
    
    /**
     * Convert a chess move to human readable form.
     * param pos      The chess position.
     * param move     The executed move.
     * param longForm If true, use long notation, eg Ng1-f3.
     *                 Otherwise, use short notation, eg Nf3
     */
    public function moveToString( pos:POSITION, move:MOVE, longForm:Boolean ):String {
        var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
        MoveGen.removeIllegal(pos, moves);
        return this.moveGToString(pos, move, longForm, moves);
    }
    
    private function moveGToString( pos:POSITION, move:MOVE, longForm:Boolean, moves:MoveList):String {
        var ret:String = "";
        var wKingOrigPos:int = Position.getSquare(4, 0);
        var bKingOrigPos:int = Position.getSquare(4, 7);
        if (move.from == wKingOrigPos && pos.getPiece(wKingOrigPos) == Piece.WKING) {
            // Check white castle
            if (move.to == Position.getSquare(6, 0)) {
                    ret+=("O-O");
            } else if (move.to == Position.getSquare(2, 0)) {
                ret+=("O-O-O");
            }
        } else if (move.from == bKingOrigPos && pos.getPiece(bKingOrigPos) == Piece.BKING) {
            // Check white castle
            if (move.to == Position.getSquare(6, 7)) {
                ret+=("O-O");
            } else if (move.to == Position.getSquare(2, 7)) {
                ret+=("O-O-O");
            }
        }
        if (ret.length == 0) {
            var p:int = pos.getPiece(move.from);
            ret+=this.pieceToChar(p);
            var x1:int = Position.getX(move.from);
            var y1:int = Position.getY(move.from);
            var x2:int = Position.getX(move.to);
            var y2:int = Position.getY(move.to);
            if (longForm) {
                ret+=String.fromCharCode(97 + x1);
                ret+=String.fromCharCode(49 + y1);
                ret+=(this.isCapture(pos, move) ? 'x' : '-');
            } else {
                if (p == (pos.whiteMove ? Piece.WPAWN : Piece.BPAWN)) {
                    if (this.isCapture(pos, move)) {
                        ret+=String.fromCharCode(97 + x1);
                    }
                } else {
                    var numSameTarget:int = 0;
                    var numSameFile:int = 0;
                    var numSameRow:int = 0;
                    for (var mi:int = 0; mi < moves.size; mi++) {
                        var m:MOVE = moves.m[mi];
                        if (m == null) break;
                        if ((pos.getPiece(m.from) == p) && (m.to == move.to)) {
                            numSameTarget++;
                            if (Position.getX(m.from) == x1)
                                numSameFile++;
                            if (Position.getY(m.from) == y1)
                                numSameRow++;
                        }
                    }
                    if (numSameTarget < 2) {
                        // No file/row info needed
                    } else if (numSameFile < 2) {
                        ret+=String.fromCharCode(97 + x1);   // Only file info needed
                    } else if (numSameRow < 2) {
                        ret+=String.fromCharCode(49 + y1);   // Only row info needed
                    } else {
                        ret+=String.fromCharCode(97 + x1);
                        ret+=String.fromCharCode(49 + y1);
                    }
                }
                if (this.isCapture(pos, move)) {
                    ret+='x';
                }
            }
            ret+=String.fromCharCode(97 + x2);
            ret+=String.fromCharCode(49 + y2);
            if (move.promoteTo != Piece.EMPTY) {
                ret+="="+this.pieceToChar(move.promoteTo);
            }
        }
        var ui:UNDOINFO = new UNDOINFO();

        if (MoveGen.givesCheck(pos, move)) {
            pos.makeMove(move, ui);
            var nextMoves:MoveList = MoveGen.pseudoLegalMoves(pos);
            MoveGen.removeIllegal(pos, nextMoves);
            if (nextMoves.size == 0) ret+=('#');
            else ret+=('+');
            pos.unMakeMove(move, ui);
        }

        return ret;
    }

    /** Convert a move object to UCI string format. */
    public function moveToUCIString( m:MOVE ):String {
        var ret:String = this.squareToString(m.from) + this.squareToString(m.to);
        var p:int = m.promoteTo;
		var i:int=(p>6 ? p-6 : p);
        return ret + (i<2 ? "" : ("  qrbn").charAt(i) );
    }

    public function dispMoves( pos:POSITION ):String{
        var  moves:MoveList = MoveGen.pseudoLegalMoves(pos);
        MoveGen.removeIllegal(pos, moves);
        var mstr:String = "";
        for(var i:int=0;i<moves.size;i++) mstr += (i>0?",": "") + this.moveGToString(pos, moves.m[i],
		 false /*in short format*/, moves);
        return mstr;
    }
    
    /**
     * Convert a string to a Move object.
     * return A move object, or null if move has invalid syntax
     */
    public function uciStringToMove( move:String ):MOVE {
        var m:MOVE = null;
        if ((move.length < 4) || (move.length > 5)) return m;
        var fromSq:int = this.getSquare(move.substr(0, 2));
        var toSq:int   = this.getSquare(move.substr(2, 4));
        if ((fromSq < 0) || (toSq < 0)) return m;
        var prom:String = ' ';
        var white:Boolean = true;
        if (move.length == 5) {
            prom = move.charAt(4);
            if (Position.getY(toSq) == 7) {
                white = true;
            } else if (Position.getY(toSq) == 0) {
                white = false;
            } else {
                return m;
            }
        }
        
        var promoteTo:int = 0;
        switch (prom) {
            case ' ':
                promoteTo = Piece.EMPTY;
                break;
            case 'q':
                promoteTo = white ? Piece.WQUEEN : Piece.BQUEEN;
                break;
            case 'r':
                promoteTo = white ? Piece.WROOK : Piece.BROOK;
                break;
            case 'b':
                promoteTo = white ? Piece.WBISHOP : Piece.BBISHOP;
                break;
            case 'n':
                promoteTo = white ? Piece.WKNIGHT : Piece.BKNIGHT;
                break;
            default:
                return m;
        }
        m = new MOVE(fromSq, toSq, promoteTo, 0);
        return m;
    }

    private function isCapture( pos:POSITION, move:MOVE ):Boolean {
        if (pos.getPiece(move.to) == Piece.EMPTY) {
            var p:int = pos.getPiece(move.from);
            return ((p == (pos.whiteMove ? Piece.WPAWN : Piece.BPAWN)) && (move.to == pos.getEpSquare()));
        } else {
            return true;
        }
    }

    /**
     * Convert a chess move string to a Move object.
     * Just verifies UCI move.
     */
    public function stringToMove( pos:POSITION, sMove:String ):MOVE {
        var m:MOVE = this.uciStringToMove( sMove );
        var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
        MoveGen.removeIllegal(pos, moves);
        for (var mi:int = 0; mi < moves.size; mi++)
              if( (m!=null) && (moves.m[mi]!=null) && m.equalsMove( moves.m[mi] )) return m;
        return null;
    }

    /**
     * Convert a string, such as "e4" to a square number.
     * return The square number, or -1 if not a legal square.
     */
    public function getSquare( s:String ):int {
        var x:int = s.charCodeAt(0) - 97;
        var y:int = s.charCodeAt(1) - 49;
        if ((x < 0) || (x > 7) || (y < 0) || (y > 7)) return -1;
        return Position.getSquare(x, y);
    }

    /**
     * Convert a square number to a string, such as "e4".
     */
    public function squareToString( square:int ):String {
        var ret:String = "";
        var x:int = Position.getX(square);
        var y:int = Position.getY(square);
        ret+=String.fromCharCode(97 + x);
        ret+=String.fromCharCode(49 + y);
        return ret;
    }

    /**
     * traces board
     */
    public function dispBoard( pos:POSITION ):void {
        var ln:String = "+----+----+----+----+----+----+----+----+";
		var S:String;
        trace(ln);
        for (var y:int = 7; y >= 0; y--) {
            S = "|";
            for (var x:int = 0; x < 8; x++) {
                var p:int = pos.getPiece(Position.getSquare(x, y));
                var dark:Boolean = Position.darkSquare(x, y);
                if (p == Piece.EMPTY) {
                    S+=(dark ? "::::" : "....") + "|";
                } else {
                    S+=(dark ? ":" : ".") + (Piece.isWhite(p) ? 'w' : 'b');
                    var pieceName:String = this.pieceToChar(p);
                    if (pieceName.length == 0) pieceName = "P";
                    S+=pieceName;
                    S+=(dark ? ":" : ".") + "|";
                }
            }
			trace(S); trace(ln);
        }
    }

    /**
     * Convert move String to lower case and remove special check/mate symbols.
     */
    private function normalizeMoveString( str:String ):String {
        if (str.length > 0) {
            var lastchar:String = str.charAt(str.length - 1);
            if ((lastchar == '#') || (lastchar == '+')) {
                str = str.toLowerCase().substr(0, str.length - 1);
            }
        }
        return str;
    }
    
    public function pieceToChar(p:int):String {
        var i:int=(p>6 ? p-6 : p);
        return (i==6 ? "" : (" KQRBN").charAt(i) );
    }

	}
}