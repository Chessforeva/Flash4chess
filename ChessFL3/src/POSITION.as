package
{
	public class POSITION
	{
		// object cloning
	public function clone():POSITION
	{
		var P:POSITION = new POSITION();
		P.copy(this);
		return P;
	}
		
	private var LL:INT64 = Main.LL;
	private var Piece:PIECE = Main.Piece;
	private var Hash:HASH = Main.Hash;
	private var BitBoard:BITBOARD = Main.BitBoard;
	private var Evaluate:EVALUATE = Main.Evaluate;
		
    /** Bit definitions for the castleMask bit mask. */
    public const A1_CASTLE:int = ( 1 << 0 ); /** White e1-c1 castle. */
    public const H1_CASTLE:int = ( 1 << 1 ); /** White e1-g1 castle. */
    public const A8_CASTLE:int = ( 1 << 2 ); /** Black e8-c8 castle. */
    public const H8_CASTLE:int = ( 1 << 3 ); /** Black e8-g8 castle. */
	
	public function Init1():void	// constructor 1time
		{
		for (var i:int = 0; i < 64; i++ ) this.squares.push(0);
		for (i = 0; i < Piece.nPieceTypes; i++)
			{
				pieceTypeBB.push( new i64() );
				psScore1.push(0);
				psScore2.push(0);
			}
		var kV:int = 9900;		// -Evaluate.kV
		wMtrl = -kV;
		bMtrl = -kV;
		}

    public var squares:Array = [];

    // Bitboards
    public var /*long[]*/ pieceTypeBB:Array = [];
    public var /*long*/ whiteBB:i64 = new i64();
	public var /*long*/ blackBB:i64 = new i64();
    
    // Piece square table scores
    public var /*short[]*/ psScore1:Array = [];
	public var /*short[]*/ psScore2:Array = [];

    public var whiteMove:Boolean = true;
    
    public var castleMask:int = 0;

    public var epSquare:int = -1;
    
    /** Number of half-moves since last 50-move reset. */
    public var halfMoveClock:int = 0;
    
    /** Game move number, starting from 1. */
    public var fullMoveCounter:int = 1;
    public var /*long*/ hashKey:uint = 0;          // Cached Zobrist hash key, init has been removed
    public var /*long*/ pHashKey:uint = 0;
    public var wKingSq:int = -1;
    public var bKingSq:int = -1;   // Cached king positions
    public var wMtrl:int = 0;      // Total value of all white pieces and pawns
    public var bMtrl:int = 0;      // Total value of all black pieces and pawns
    public var wMtrlPawns:int = 0; // Total value of all white pawns
    public var bMtrlPawns:int = 0; // Total value of all black pawns

    public function copy (other:POSITION):void {
        this.squares = other.squares.slice();
		for (var i:int = 0; i < Piece.nPieceTypes; i++)
			{
			this.pieceTypeBB[i] = LL.c(other.pieceTypeBB[i]);
			}
        this.psScore1 = other.psScore1.slice();
        this.psScore2 = other.psScore2.slice();
        this.whiteBB = LL.c( other.whiteBB );
        this.blackBB = LL.c( other.blackBB );
        this.whiteMove = other.whiteMove;
        this.castleMask = other.castleMask;
        this.epSquare = other.epSquare;
        this.halfMoveClock = other.halfMoveClock;
        this.fullMoveCounter = other.fullMoveCounter;
        this.hashKey = other.hashKey;
        this.pHashKey = other.pHashKey;
        this.wKingSq = other.wKingSq;
        this.bKingSq = other.bKingSq;
        this.wMtrl = other.wMtrl;
        this.bMtrl = other.bMtrl;
        this.wMtrlPawns = other.wMtrlPawns;
        this.bMtrlPawns = other.bMtrlPawns;
    }
    
    /*@Override*/       
    public function equals(other:POSITION):Boolean {
        if (!this.drawRuleEquals(other))
            return false;
        if (this.halfMoveClock != other.halfMoveClock)
            return false;
        if (this.fullMoveCounter != other.fullMoveCounter)
            return false;
        if (this.hashKey != other.hashKey)
            return false;
        if (this.pHashKey != other.pHashKey)
            return false;
        return true;
    }
    
    /**
     * Return Zobrist hash value for the current position.
     * Everything except the move counters are included in the hash value.
     */
    public /*long*/ function zobristHash():uint {
        return this.hashKey;
    }
	
    public /*long*/ function pawnZobristHash():uint {
        return this.pHashKey;
    }
	
    public /*long*/ function kingZobristHash():uint {
        return ( Hash.psHashKeys[Piece.WKING][this.wKingSq] ^ Hash.psHashKeys[Piece.BKING][this.bKingSq] );
    }

	
    public /*long*/ function historyHash():uint {
        return (this.halfMoveClock < 80 ?  this.hashKey :
         ( this.hashKey ^ Hash.moveCntKeys[Math.min(this.halfMoveClock, 100)] ) );
    }
    
    /**
     * Decide if two positions are equal in the sense of the draw by repetition rule.
     * return True if positions are equal, false otherwise.
     */
	
    public function drawRuleEquals(other:POSITION):Boolean  {
        if (this.whiteMove != other.whiteMove)
            return false;
        if (this.castleMask != other.castleMask)
            return false;
        if (this.epSquare != other.epSquare)
            return false;
		for (var sq:int = 0; sq < 64; sq++) if (this.squares[sq] != other.squares[sq]) return false;
        return true;
    }

    public function setWhiteMove(whiteMove:Boolean):void {
        if (whiteMove != this.whiteMove) {
            this.hashKey ^= Hash.whiteHashKey;
            this.whiteMove = whiteMove;
        }
    }
		
	/** Return index in squares[] vector corresponding to (x,y). */
	public function getSquare(x:int, y:int):int {  return (y * 8) + x; }
	
    /** Return x position (file) corresponding to a square. */
	public function getX(square:int):int { return square & 7; }
	
    /** Return y position (rank) corresponding to a square. */
	public function getY(square:int):int { return square >> 3; }

    /** Return true if (x,y) is a dark square. */
    public function darkSquare(x:int, y:int):Boolean {
        return (x & 1) == (y & 1);
    }

    /** Return piece occupying a square. */
	public function getPiece(square:int):int { return this.squares[square]; }
	
	
    /** Move a non-pawn piece to an empty square. */
    private function movePieceNotPawn(from:int, to:int):void {
        var piece:int = this.squares[from];
        this.hashKey ^= Hash.psHashKeys[piece][from];
        this.hashKey ^= Hash.psHashKeys[piece][to];
        this.hashKey ^= Hash.psHashKeys[Piece.EMPTY][from];
        this.hashKey ^= Hash.psHashKeys[Piece.EMPTY][to];
        
        this.squares[from] = Piece.EMPTY;
        this.squares[to] = piece;

        var /*long*/ sqMaskF:i64 = LL.bitObj( from );
        var /*long*/ sqMaskT:i64 = LL.bitObj( to );
        var NsqMaskF:i64 = LL.not(sqMaskF);
        var NsqMaskT:i64 = LL.not(sqMaskT);
        
        this.pieceTypeBB[piece] = LL.or( LL.and( this.pieceTypeBB[piece], NsqMaskF ), sqMaskT );
         if (Piece.isWhite(piece)) {
            this.whiteBB = LL.or( LL.and( this.whiteBB, NsqMaskF ), sqMaskT );
            if (piece == Piece.WKING)
                this.wKingSq = to;
        } else {
            this.blackBB = LL.or( LL.and( this.blackBB, NsqMaskF ), sqMaskT );
            if (piece == Piece.BKING)
                this.bKingSq = to;
        }

        this.psScore1[piece] += Evaluate.psTab1[piece][to] - Evaluate.psTab1[piece][from];
        this.psScore2[piece] += Evaluate.psTab2[piece][to] - Evaluate.psTab2[piece][from];
    }

    /** Set a square to a piece value. */
    public function setPiece(square:int,piece:int):void {
        // Update hash key
        var removedPiece:int = this.squares[square];
        this.hashKey ^= Hash.psHashKeys[removedPiece][square];
        this.hashKey ^= Hash.psHashKeys[piece][square];
        if ((removedPiece == Piece.WPAWN) || (removedPiece == Piece.BPAWN))
            this.pHashKey ^= Hash.psHashKeys[removedPiece][square];
        if ((piece == Piece.WPAWN) || (piece == Piece.BPAWN))
            this.pHashKey ^= Hash.psHashKeys[piece][square];
        
        // Update material balance
        var pVal:int = Evaluate.pieceValue[removedPiece];
        if (Piece.isWhite(removedPiece)) {
            this.wMtrl -= pVal;
            if (removedPiece == Piece.WPAWN)
                this.wMtrlPawns -= pVal;
        } else {
            this.bMtrl -= pVal;
            if (removedPiece == Piece.BPAWN)
                this.bMtrlPawns -= pVal;
        }
        pVal = Evaluate.pieceValue[piece];
        if (Piece.isWhite(piece)) {
            this.wMtrl += pVal;
            if (piece == Piece.WPAWN)
                this.wMtrlPawns += pVal;
        } else {
            this.bMtrl += pVal;
            if (piece == Piece.BPAWN)
                this.bMtrlPawns += pVal;
        }

        // Update board
        this.squares[square] = piece;

        // Update bitboards
        var /*long*/ sqMask:i64 = LL.bitObj( square );
        var NsqMask:i64 = LL.not(sqMask);
       
        LL.and_( this.pieceTypeBB[removedPiece], NsqMask );
        LL.or_( this.pieceTypeBB[piece], sqMask );
        
        if (removedPiece != Piece.EMPTY) {
            if (Piece.isWhite(removedPiece))
                LL.and_( this.whiteBB, NsqMask );
            else
                LL.and_( this.blackBB, NsqMask );
        }
        if (piece != Piece.EMPTY) {
            if (Piece.isWhite(piece))
                LL.or_( this.whiteBB, sqMask );
            else
                LL.or_( this.blackBB, sqMask );
        }

        // Update king position 
        if (piece == Piece.WKING) {
            this.wKingSq = square;
        } else if (piece == Piece.BKING) {
            this.bKingSq = square;
        }

        // Update piece/square table scores
        this.psScore1[removedPiece] -= Evaluate.psTab1[removedPiece][square];
        this.psScore2[removedPiece] -= Evaluate.psTab2[removedPiece][square];
        this.psScore1[piece]        += Evaluate.psTab1[piece][square];
        this.psScore2[piece]        += Evaluate.psTab2[piece][square];
    }

    /**
     * Set a square to a piece value.
     * Special version that only updates enough of the state for the SEE function to be happy.
     */
    public function setSEEPiece(square:int,piece:int):void {
        var removedPiece:int = this.squares[square];

        // Update board
        this.squares[square] = piece;

        // Update bitboards
        var /*long*/ sqMask:i64 = LL.bitObj( square );
        var NsqMask:i64 = LL.not(sqMask);

        LL.and_( this.pieceTypeBB[removedPiece], NsqMask );
        LL.or_( this.pieceTypeBB[piece], sqMask );

        if (removedPiece != Piece.EMPTY) {
            if (Piece.isWhite(removedPiece))
                LL.and_( this.whiteBB, NsqMask );
            else
                LL.and_( this.blackBB, NsqMask );
        }
        if (piece != Piece.EMPTY) {
            if (Piece.isWhite(piece))
                LL.or_( this.whiteBB, sqMask );
            else
                LL.or_( this.blackBB, sqMask );
        }
    }

    /** Return true if white e1c1 castling right has not been lost. */
    public function a1Castle():Boolean {
        return (this.castleMask & A1_CASTLE) != 0;
    }
    /** Return true if white e1g1 castling right has not been lost. */
    public function h1Castle():Boolean {
        return (this.castleMask & H1_CASTLE) != 0;
    }
    /** Return true if black e8c8 castling right has not been lost. */
    public function a8Castle():Boolean {
        return (this.castleMask & A8_CASTLE) != 0;
    }
    /** Return true if black e8g8 castling right has not been lost. */
    public function h8Castle():Boolean {
        return (this.castleMask & H8_CASTLE) != 0;
    }
    
    /** Bitmask describing castling rights. */
    public function getCastleMask():int { return this.castleMask; }
	
    public function setCastleMask(castleMask:int):void {
        this.hashKey ^= Hash.castleHashKeys[this.castleMask];
        this.hashKey ^= Hash.castleHashKeys[castleMask];
        this.castleMask = castleMask;
    }

    /** En passant square, or -1 if no ep possible. */
    public function getEpSquare():int { return this.epSquare; }
	
    public function setEpSquare(epSquare:int):void {
        if (this.epSquare != epSquare) {
            this.hashKey ^= Hash.epHashKeys[(this.epSquare >= 0) ? getX(this.epSquare) + 1 : 0];
            this.hashKey ^= Hash.epHashKeys[(epSquare >= 0) ? getX(epSquare) + 1 : 0];
            this.epSquare = epSquare;
        }
    }

    public function getKingSq(whiteMove:Boolean):int {
        return (whiteMove ? this.wKingSq : this.bKingSq);
    }

    /**
     * Count number of pieces of a certain type.
     */
    public function nPieces(pType:int):int {
        var ret:int = 0;
        for (var sq:int = 0; sq < 64; sq++) {
            if (this.squares[sq] == pType)
                ret++;
        }
        return ret;
    }

    /** Apply a move to the current position. */
    public function makeMove(move:MOVE, ui:UNDOINFO):void {
        ui.capturedPiece = this.squares[move.to];
        ui.castleMask = this.castleMask;
        ui.epSquare = this.epSquare;
        ui.halfMoveClock = this.halfMoveClock;
        
        var wtm:Boolean = this.whiteMove;
        
        var p:int = this.squares[move.from];
        var capP:int = this.squares[move.to];
        var /*long*/ fromMask:i64 = LL.bitObj( move.from );
		var x:int = 0;

        var prevEpSquare:int = this.epSquare;
        this.setEpSquare(-1);

        if ((capP != Piece.EMPTY) ||
             (  LL.not0( LL.and( LL.or(this.pieceTypeBB[Piece.WPAWN], this.pieceTypeBB[Piece.BPAWN]), fromMask) ) ) ) {
            this.halfMoveClock = 0;

            // Handle en passant and epSquare
            if (p == Piece.WPAWN) {
                if (move.to - move.from == 2 * 8) {
                    x = getX(move.to);
                    if (((x > 0) && (this.squares[move.to - 1] == Piece.BPAWN)) ||
                            ((x < 7) && (this.squares[move.to + 1] == Piece.BPAWN))) {
                        this.setEpSquare(move.from + 8);
                    }
                } else if (move.to == prevEpSquare) {
                    this.setPiece(move.to - 8, Piece.EMPTY);
                }
            } else if (p == Piece.BPAWN) {
                if (move.to - move.from == -2 * 8) {
                    x = getX(move.to);
                    if (((x > 0) && (this.squares[move.to - 1] == Piece.WPAWN)) ||
                            ((x < 7) && (this.squares[move.to + 1] == Piece.WPAWN))) {
                        this.setEpSquare(move.from - 8);
                    }
                } else if (move.to == prevEpSquare) {
                    this.setPiece(move.to + 8, Piece.EMPTY);
                }
            }

            if (  LL.not0( LL.and( LL.or(this.pieceTypeBB[Piece.WKING], this.pieceTypeBB[Piece.BKING]), fromMask) ) ) {
                if (wtm) {
                    this.setCastleMask(this.castleMask & (~A1_CASTLE));
                    this.setCastleMask(this.castleMask & (~H1_CASTLE));
                } else {
                    this.setCastleMask(this.castleMask & (~A8_CASTLE));
                    this.setCastleMask(this.castleMask & (~H8_CASTLE));
                }
            }

            // Perform move
            this.setPiece(move.from, Piece.EMPTY);
            // Handle promotion
            if (move.promoteTo != Piece.EMPTY) {
                this.setPiece(move.to, move.promoteTo);
            } else {
                this.setPiece(move.to, p);
            }
        } else {
            this.halfMoveClock++;

            // Handle castling
            if (  LL.not0( LL.and( LL.or(this.pieceTypeBB[Piece.WKING], this.pieceTypeBB[Piece.BKING]), fromMask) ) ) {
                var k0:int = move.from;
                if (move.to == k0 + 2) { // O-O
                    this.movePieceNotPawn(k0 + 3, k0 + 1);
                } else if (move.to == k0 - 2) { // O-O-O
                    this.movePieceNotPawn(k0 - 4, k0 - 1);
                }
                if (wtm) {
                    this.setCastleMask(this.castleMask & (~A1_CASTLE));
                    this.setCastleMask(this.castleMask & (~H1_CASTLE));
                } else {
                    this.setCastleMask(this.castleMask & (~A8_CASTLE));
                    this.setCastleMask(this.castleMask & (~H8_CASTLE));
                }
            }

            // Perform move
            this.movePieceNotPawn(move.from, move.to);
        }
        if (!wtm) {
            this.fullMoveCounter++;
        }

        // Update castling rights when rook moves
        if ( LL.not0( LL.and( BitBoard.maskCorners, fromMask ) ) ) {
            var rook:int = wtm ? Piece.WROOK : Piece.BROOK;
            if (p == rook)
                this.removeCastleRights(move.from);
        }
        if ( LL.not0( LL.and(BitBoard.maskCorners, LL.bitObj(move.to)) ) ) {
            var oRook:int = wtm ? Piece.BROOK : Piece.WROOK;
            if (capP == oRook)
                this.removeCastleRights(move.to);
        }

        this.hashKey ^= Hash.whiteHashKey;
        this.whiteMove = !wtm;
    }

    public function unMakeMove( move:MOVE, ui:UNDOINFO):void {
        this.hashKey ^= Hash.whiteHashKey;
        this.whiteMove = !this.whiteMove;
        var p:int = this.squares[move.to];
        this.setPiece(move.from, p);
        this.setPiece(move.to, ui.capturedPiece);
        this.setCastleMask(ui.castleMask);
        this.setEpSquare(ui.epSquare);
        this.halfMoveClock = ui.halfMoveClock;
        var wtm:Boolean = this.whiteMove;
        if (move.promoteTo != Piece.EMPTY) {
            p = wtm ? Piece.WPAWN : Piece.BPAWN;
            this.setPiece(move.from, p);
        }
        if (!wtm) {
            this.fullMoveCounter--;
        }
        
        // Handle castling
        var king:int = wtm ? Piece.WKING : Piece.BKING;
        if (p == king) {
            var k0:int = move.from;
            if (move.to == k0 + 2) { // O-O
                this.movePieceNotPawn(k0 + 1, k0 + 3);
            } else if (move.to == k0 - 2) { // O-O-O
                this.movePieceNotPawn(k0 - 1, k0 - 4);
            }
        }

        // Handle en passant
        if (move.to == this.epSquare) {
            if (p == Piece.WPAWN) {
                this.setPiece(move.to - 8, Piece.BPAWN);
            } else if (p == Piece.BPAWN) {
                this.setPiece(move.to + 8, Piece.WPAWN);
            }
        }
    }

    /**
     * Apply a move to the current position.
     * Special version that only updates enough of the state for the SEE function to be happy.
     */
    public function makeSEEMove( move:MOVE, ui:UNDOINFO):void {
        ui.capturedPiece = this.squares[move.to];
        var wtm:Boolean = this.whiteMove;
        
        var p:int = this.squares[move.from];
        var /*long*/ fromMask:i64 = LL.bitObj( move.from );

        // Handle castling
        if (  LL.not0( LL.and( LL.or(this.pieceTypeBB[Piece.WKING], this.pieceTypeBB[Piece.BKING]), fromMask) ) ) {
            var k0:int = move.from;
            if (move.to == k0 + 2) { // O-O
                this.setSEEPiece(k0 + 1, this.squares[k0 + 3]);
                this.setSEEPiece(k0 + 3, Piece.EMPTY);
            } else if (move.to == k0 - 2) { // O-O-O
                this.setSEEPiece(k0 - 1, this.squares[k0 - 4]);
                this.setSEEPiece(k0 - 4, Piece.EMPTY);
            }
        }

        // Handle en passant
        if (move.to == this.epSquare) {
            if (p == Piece.WPAWN) {
                this.setSEEPiece(move.to - 8, Piece.EMPTY);
            } else if (p == Piece.BPAWN) {
                this.setSEEPiece(move.to + 8, Piece.EMPTY);
            }
        }

        // Perform move
        this.setSEEPiece(move.from, Piece.EMPTY);
        this.setSEEPiece(move.to, p);
        this.whiteMove = !wtm;
    }

    public function unMakeSEEMove( move:MOVE, ui:UNDOINFO ):void {
        this.whiteMove = !this.whiteMove;
        var p:int = this.squares[move.to];
        this.setSEEPiece(move.from, p);
        this.setSEEPiece(move.to, ui.capturedPiece);
        var wtm:Boolean = this.whiteMove;

        // Handle castling
        var king:int = wtm ? Piece.WKING : Piece.BKING;
        if (p == king) {
            var k0:int = move.from;
            if (move.to == k0 + 2) { // O-O
                this.setSEEPiece(k0 + 3, this.squares[k0 + 1]);
                this.setSEEPiece(k0 + 1, Piece.EMPTY);
            } else if (move.to == k0 - 2) { // O-O-O
                this.setSEEPiece(k0 - 4, this.squares[k0 - 1]);
                this.setSEEPiece(k0 - 1, Piece.EMPTY);
            }
        }

        // Handle en passant
        if (move.to == this.epSquare) {
            if (p == Piece.WPAWN) {
                this.setSEEPiece(move.to - 8, Piece.BPAWN);
            } else if (p == Piece.BPAWN) {
                this.setSEEPiece(move.to + 8, Piece.WPAWN);
            }
        }
    }

    private function removeCastleRights(square:int):void {
        if (square == getSquare(0, 0)) {
            this.setCastleMask(this.castleMask & (~A1_CASTLE));
        } else if (square == getSquare(7, 0)) {
            this.setCastleMask(this.castleMask & (~H1_CASTLE));
        } else if (square == getSquare(0, 7)) {
            this.setCastleMask(this.castleMask & (~A8_CASTLE));
        } else if (square == getSquare(7, 7)) {
            this.setCastleMask(this.castleMask & (~H8_CASTLE));
        }
    }
	
}


	
}