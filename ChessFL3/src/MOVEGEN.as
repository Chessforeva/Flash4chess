package
{
	public class MOVEGEN
	{
	private var LL:INT64 = Main.LL;
	private var Piece:PIECE = Main.Piece;
	private var BitBoard:BITBOARD = Main.BitBoard;
	private var Position:POSITION = Main.Position;

	private const o_x1:i64 = LL.v(1);
	private const o_x60:i64 = LL.v(0x60);
	private const o_x0E:i64 = LL.v(0x0E);
	private const o_xL6:i64 = LL.ax(0x60000000, 0);
	private const o_xLE:i64 = LL.ax(0xE000000,0); 
	
    // Code to handle the Move cache.
    private var moveListCache:Array = new Array(); /* new Object[200] */
    private var moveListsInCache:int = 0;
	
    /**
     * Generate and return a list of pseudo-legal moves.
     * Pseudo-legal means that the moves doesn't necessarily defend from check threats.
     */
    public function pseudoLegalMoves( pos:POSITION ):MoveList {
        var sq:int, k0:int;
		var squares:i64, m:i64, knights:i64, pawns:i64, epM2:i64;
		var OO_SQ:i64, OOO_SQ:i64;
        var moveList:MoveList = this.getMoveListObj();
        var occupied:i64 = LL.or(pos.whiteBB, pos.blackBB);
        var Noccupied:i64 = LL.not(occupied);
        var NwhiteBB:i64 = LL.not(pos.whiteBB);
        var NblackBB:i64 = LL.not(pos.blackBB);
        var epSquare:int = pos.getEpSquare();
        var epMask:i64 = ((epSquare >= 0) ? LL.bitObj(epSquare) : new i64() );
           
        if (pos.whiteMove) {
            // Queen moves
            /*long*/ squares = LL.c(pos.pieceTypeBB[Piece.WQUEEN]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.or(BitBoard.rookAttacks(sq, occupied),
                     BitBoard.bishopAttacks(sq, occupied)), NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c(pos.pieceTypeBB[Piece.WROOK]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.rookAttacks(sq, occupied), NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c(pos.pieceTypeBB[Piece.WBISHOP]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.bishopAttacks(sq, occupied), NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // King moves
            {
                /*int*/ sq = pos.getKingSq(true);
                /*long*/ m = LL.and( BitBoard.kingAttacks[sq], NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                /*int*/ k0 = 4;
                if (sq == k0) {
                    /*long*/ OO_SQ = o_x60;
                    /*long*/ OOO_SQ = o_x0E;
                    if (((pos.getCastleMask() & (Position.H1_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 + 3) == Piece.WROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 + 1)) {
                        this.setMove(moveList, k0, k0 + 2, Piece.EMPTY);
                    }
                    if (((pos.getCastleMask() & (Position.A1_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OOO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 - 4) == Piece.WROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 - 1)) {
                        this.setMove(moveList, k0, k0 - 2, Piece.EMPTY);
                    }
                }
            }

            // Knight moves
            /*long*/ knights = LL.c(pos.pieceTypeBB[Piece.WKNIGHT]);
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and( BitBoard.knightAttacks[sq], NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // Pawn moves
            /*long*/ pawns = LL.c(pos.pieceTypeBB[Piece.WPAWN]);
            /*long*/ m = LL.and( LL.lshift(pawns, 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos, m, -8, true)) return moveList;
            m = LL.and(  LL.lshift( LL.and(m,BitBoard.maskRow3), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos, m, -16);

            epM2 = LL.or(pos.blackBB,epMask);
            m = LL.and( LL.and( LL.lshift(pawns,7), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -7, true)) return moveList;

            m = LL.and( LL.and( LL.lshift(pawns,9), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -9, true)) return moveList;
        } else {
            // Queen moves
            /*long*/ squares = LL.c(pos.pieceTypeBB[Piece.BQUEEN]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.or(BitBoard.rookAttacks(sq, occupied),
                     BitBoard.bishopAttacks(sq, occupied)), NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c(pos.pieceTypeBB[Piece.BROOK]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.rookAttacks(sq, occupied), NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c(pos.pieceTypeBB[Piece.BBISHOP]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.bishopAttacks(sq, occupied), NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }
            
            // King moves
            {
                /*int*/ sq = pos.getKingSq(false);
                /*long*/ m = LL.and( BitBoard.kingAttacks[sq], NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                /*int*/ k0 = 60;
                if (sq == k0) {
                    /*long*/ OO_SQ = o_xL6;
                    /*long*/ OOO_SQ = o_xLE;
                    if (((pos.getCastleMask() & (Position.H8_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 + 3) == Piece.BROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 + 1)) {
                        this.setMove(moveList, k0, k0 + 2, Piece.EMPTY);
                    }
                    if (((pos.getCastleMask() & (Position.A8_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OOO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 - 4) == Piece.BROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 - 1)) {
                        this.setMove(moveList, k0, k0 - 2, Piece.EMPTY);
                    }
                }
            }

            // Knight moves
            /*long*/ knights = LL.c(pos.pieceTypeBB[Piece.BKNIGHT]);
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and( BitBoard.knightAttacks[sq], NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // Pawn moves
            /*long*/ pawns = LL.c(pos.pieceTypeBB[Piece.BPAWN]);
            /*long*/ m = LL.and( LL.rshift(pawns, 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos, m, 8, true)) return moveList;
            m = LL.and(  LL.rshift( LL.and(m,BitBoard.maskRow6), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos, m, 16);

            epM2 = LL.or(pos.whiteBB,epMask);
            m = LL.and( LL.and( LL.rshift(pawns,9), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 9, true)) return moveList;

            m = LL.and( LL.and( LL.rshift(pawns,7), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 7, true)) return moveList;
        }
        return moveList;
    }

    /**
     * Generate and return a list of pseudo-legal check evasion moves.
     * Pseudo-legal means that the moves doesn't necessarily defend from check threats.
     */
    public function checkEvasions( pos:POSITION ):MoveList {
        var sq:int, threatSq:int;
		var squares:i64, m:i64, knights:i64, pawns:i64;
        var kingThreats:i64, rookPieces:i64, bishPieces:i64, validTargets:i64, epM2:i64;
        
        var moveList:MoveList = this.getMoveListObj();
        var occupied:i64 = LL.or(pos.whiteBB, pos.blackBB);
        var Noccupied:i64 = LL.not(occupied);
        var NwhiteBB:i64 = LL.not(pos.whiteBB);
        var NblackBB:i64 = LL.not(pos.blackBB);
        var epSquare:int = pos.getEpSquare();
        var epMask:i64 = ((epSquare >= 0) ? LL.bitObj(epSquare) : new i64() );

        if (pos.whiteMove) {
            /*long*/ kingThreats = LL.and( pos.pieceTypeBB[Piece.BKNIGHT], BitBoard.knightAttacks[pos.wKingSq] );
            /*long*/ rookPieces = LL.or( pos.pieceTypeBB[Piece.BROOK], pos.pieceTypeBB[Piece.BQUEEN] );
            if (LL.not0(rookPieces))
                kingThreats = LL.or( kingThreats, LL.and( rookPieces, BitBoard.rookAttacks(pos.wKingSq, occupied) ) );
            /*long*/ bishPieces = LL.or( pos.pieceTypeBB[Piece.BBISHOP], pos.pieceTypeBB[Piece.BQUEEN] );
            if (LL.not0(bishPieces))
                kingThreats = LL.or( kingThreats, LL.and( bishPieces, BitBoard.bishopAttacks(pos.wKingSq, occupied) ) );
            kingThreats = LL.or( kingThreats, LL.and( pos.pieceTypeBB[Piece.BPAWN], BitBoard.wPawnAttacks[pos.wKingSq] ) );
            /*long*/ validTargets = new i64();
            if (LL.not0(kingThreats) &&
                 LL.is0( LL.and(kingThreats, LL.sub(kingThreats,o_x1))) ) { // Exactly one attacking piece
                /*int*/ threatSq = BitBoard.numberOfTrailingZeros(kingThreats);
                validTargets = LL.or( kingThreats, BitBoard.squaresBetween[pos.wKingSq][threatSq] );
            }
            LL.or_( validTargets, pos.pieceTypeBB[Piece.BKING] );

            // Queen moves
            /*long*/ squares = LL.c(pos.pieceTypeBB[Piece.WQUEEN]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.and( LL.or(BitBoard.rookAttacks(sq, occupied),
                     BitBoard.bishopAttacks(sq, occupied)), NwhiteBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c(pos.pieceTypeBB[Piece.WROOK]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.and( BitBoard.rookAttacks(sq, occupied), NwhiteBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c(pos.pieceTypeBB[Piece.WBISHOP]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.and( BitBoard.bishopAttacks(sq, occupied), NwhiteBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // King moves
            {
                /*int*/ sq = pos.getKingSq(true);
                /*long*/ m = LL.and( BitBoard.kingAttacks[sq], NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
            }

            // Knight moves
            /*long*/ knights = LL.c(pos.pieceTypeBB[Piece.WKNIGHT]);
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and( LL.and( BitBoard.knightAttacks[sq], NwhiteBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // Pawn moves
            /*long*/ pawns = LL.c(pos.pieceTypeBB[Piece.WPAWN]);
            /*long*/ m = LL.and( LL.lshift(pawns, 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos, LL.and( m, validTargets), -8, true)) return moveList;
            m = LL.and(  LL.lshift( LL.and(m,BitBoard.maskRow3), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos, LL.and( m, validTargets), -16);

            epM2 = LL.or( LL.and( pos.blackBB, validTargets ),epMask);
            m = LL.and( LL.and( LL.lshift(pawns,7), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -7, true)) return moveList;

            m = LL.and( LL.and( LL.lshift(pawns,9), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -9, true)) return moveList;

        } else {
            /*long*/ kingThreats = LL.and( pos.pieceTypeBB[Piece.WKNIGHT], BitBoard.knightAttacks[pos.bKingSq] );
            /*long*/ rookPieces = LL.or( pos.pieceTypeBB[Piece.WROOK], pos.pieceTypeBB[Piece.WQUEEN] );
            if (LL.not0(rookPieces))
                kingThreats = LL.or( kingThreats, LL.and( rookPieces, BitBoard.rookAttacks(pos.bKingSq, occupied) ) );
            /*long*/ bishPieces = LL.or( pos.pieceTypeBB[Piece.WBISHOP], pos.pieceTypeBB[Piece.WQUEEN] );
            if (LL.not0(bishPieces))
                kingThreats = LL.or( kingThreats, LL.and( bishPieces, BitBoard.bishopAttacks(pos.bKingSq, occupied) ) );
            kingThreats = LL.or( kingThreats, LL.and( pos.pieceTypeBB[Piece.BPAWN], BitBoard.wPawnAttacks[pos.bKingSq] ) );
            /*long*/ validTargets = new i64();
            if (LL.not0(kingThreats) &&
                 LL.is0( LL.and(kingThreats, LL.sub(kingThreats,o_x1))) ) { // Exactly one attacking piece
                /*int*/ threatSq = BitBoard.numberOfTrailingZeros(kingThreats);
                validTargets = LL.or( kingThreats, BitBoard.squaresBetween[pos.bKingSq][threatSq] );
            }
            LL.or_( validTargets, pos.pieceTypeBB[Piece.WKING] );

            // Queen moves
            /*long*/ squares = LL.c(pos.pieceTypeBB[Piece.BQUEEN]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.and( LL.or(BitBoard.rookAttacks(sq, occupied),
                     BitBoard.bishopAttacks(sq, occupied)), NblackBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c(pos.pieceTypeBB[Piece.BROOK]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.and( BitBoard.rookAttacks(sq, occupied), NblackBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c(pos.pieceTypeBB[Piece.BBISHOP]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.and( BitBoard.bishopAttacks(sq, occupied), NblackBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // King moves
            {
                /*int*/ sq = pos.getKingSq(false);
                /*long*/ m = LL.and( BitBoard.kingAttacks[sq], NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
            }

            // Knight moves
            /*long*/ knights = LL.c(pos.pieceTypeBB[Piece.BKNIGHT]);
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and( LL.and( BitBoard.knightAttacks[sq], NblackBB ), validTargets);
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // Pawn moves
            /*long*/ pawns = LL.c(pos.pieceTypeBB[Piece.BPAWN]);
            /*long*/ m = LL.and( LL.rshift(pawns, 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos, LL.and( m, validTargets), 8, true)) return moveList;
            m = LL.and(  LL.rshift( LL.and(m,BitBoard.maskRow6), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos, LL.and( m, validTargets), 16);

            epM2 = LL.and( LL.or(pos.whiteBB,epMask), validTargets);
            m = LL.and( LL.and( LL.rshift(pawns,9), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 9, true)) return moveList;

            m = LL.and( LL.and( LL.rshift(pawns,7), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 7, true)) return moveList;

        }

        return moveList;
    }

    /** Generate captures, checks, and possibly some other moves that are too hard to filter out. */
    public function pseudoLegalCapturesAndChecks( pos:POSITION ):MoveList {
    
        var sq:int, k0:int;
		var squares:i64, m:i64, knights:i64, pawns:i64, epM2:i64;
		var wKingSq:int, bKingSq:int;
        var discovered:i64, kRookAtk:i64, NkRookAtk:i64, kBishAtk:i64, NkBishAtk:i64, kKnightAtk:i64;
        var OrRookBishAtk:i64, pawnAll:i64, NpawnAll:i64;
		var OO_SQ:i64, OOO_SQ:i64;
        
        var moveList:MoveList = this.getMoveListObj();
        var occupied:i64 = LL.or(pos.whiteBB, pos.blackBB);
        var Noccupied:i64 = LL.not(occupied);
        var NwhiteBB:i64 = LL.not(pos.whiteBB);
        var NblackBB:i64 = LL.not(pos.blackBB);
        var epSquare:int = pos.getEpSquare();
        var epMask:i64 = ((epSquare >= 0) ? LL.bitObj(epSquare) : new i64() );
        
        if (pos.whiteMove) {
            bKingSq = pos.getKingSq(false);
            /*long*/ discovered = new i64(); // Squares that could generate discovered checks
            /*long*/ kRookAtk = BitBoard.rookAttacks(bKingSq, occupied);
            NkRookAtk = LL.not(kRookAtk);
            if (  LL.not0( LL.and(BitBoard.rookAttacks(bKingSq, LL.or(occupied, NkRookAtk)) ,
                    LL.or(pos.pieceTypeBB[Piece.WQUEEN] , pos.pieceTypeBB[Piece.WROOK])) ) )
                LL.or_( discovered, kRookAtk );
            /*long*/ kBishAtk = BitBoard.bishopAttacks(bKingSq, occupied);
            NkBishAtk = LL.not(kBishAtk);
            if (  LL.not0( LL.and(BitBoard.bishopAttacks(bKingSq, LL.and(occupied, NkBishAtk)) ,
                    LL.or(pos.pieceTypeBB[Piece.WQUEEN] , pos.pieceTypeBB[Piece.WBISHOP])) ) )
                LL.or_( discovered, kBishAtk );
            OrRookBishAtk = LL.or(kRookAtk , kBishAtk);    

            // Queen moves
            /*long*/ squares = LL.c( pos.pieceTypeBB[Piece.WQUEEN] );
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.or(BitBoard.rookAttacks(sq, occupied) , BitBoard.bishopAttacks(sq, occupied));
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.blackBB , OrRookBishAtk ) );
                LL.and_( m, NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c( pos.pieceTypeBB[Piece.WROOK] );
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.c( BitBoard.rookAttacks(sq, occupied) );
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.blackBB , kRookAtk ) );
                LL.and_( m, NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c( pos.pieceTypeBB[Piece.WBISHOP] );
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.c( BitBoard.bishopAttacks(sq, occupied) );
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.blackBB , kBishAtk ) );
                LL.and_( m, NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // King moves
            {
                /*int*/ sq = pos.getKingSq(true);
                /*long*/ m = LL.c( BitBoard.kingAttacks[sq] );
                LL.and_( m, ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )  ? pos.blackBB : NwhiteBB );

                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                /*int*/ k0 = 4;
                if (sq == k0) {
                    OO_SQ = o_x60;
                    OOO_SQ = o_x0E;
                    if (((pos.getCastleMask() & (Position.H1_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 + 3) == Piece.WROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 + 1)) {
                        this.setMove(moveList, k0, k0 + 2, Piece.EMPTY);
                    }
                    if (((pos.getCastleMask() & (Position.A1_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OOO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 - 4) == Piece.WROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 - 1)) {
                        this.setMove(moveList, k0, k0 - 2, Piece.EMPTY);
                    }
                }
            }

            // Knight moves
            /*long*/ knights = LL.c( pos.pieceTypeBB[Piece.WKNIGHT] );
            /*long*/ kKnightAtk = BitBoard.knightAttacks[bKingSq];
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and(BitBoard.knightAttacks[sq], NwhiteBB);
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    m = LL.and( m, LL.or(pos.blackBB , kKnightAtk ) );
                m = LL.and( m, NwhiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // Pawn moves
            // Captures
            /*long*/ pawns = pos.pieceTypeBB[Piece.WPAWN];

            epM2 = LL.or(pos.blackBB,epMask);
            m = LL.and( LL.and( LL.lshift(pawns,7), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -7, false)) return moveList;

            m = LL.and( LL.and( LL.lshift(pawns,9), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -9, false)) return moveList;


            // Discovered checks and promotions
            /*long*/ pawnAll = LL.or( discovered , BitBoard.maskRow7 );
            NpawnAll = LL.not(pawnAll);

            /*long*/ m = LL.and( LL.lshift( LL.and(pawns,pawnAll), 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos, m, -8, false)) return moveList;
            m = LL.and(  LL.lshift( LL.and(m,BitBoard.maskRow3), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos, m, -16);

            // Normal checks
            /*long*/ m = LL.and( LL.lshift( LL.and(pawns,NpawnAll), 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos,
                LL.and( m, BitBoard.bPawnAttacks[bKingSq] ), -8, false)) return moveList;
            m = LL.and(  LL.lshift( LL.and(m,BitBoard.maskRow3), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos,
                LL.and( m, BitBoard.bPawnAttacks[bKingSq]), -16);
        } else {
            wKingSq = pos.getKingSq(true);
            /*long*/ discovered = new i64(); // Squares that could generate discovered checks
            /*long*/ kRookAtk = BitBoard.rookAttacks(wKingSq, occupied);
            NkRookAtk = LL.not(kRookAtk);
            if (  LL.not0( LL.and(BitBoard.rookAttacks(wKingSq, LL.or(occupied, NkRookAtk)) ,
                    LL.or(pos.pieceTypeBB[Piece.BQUEEN] , pos.pieceTypeBB[Piece.BROOK])) ) )
                LL.or_( discovered, kRookAtk );
            /*long*/ kBishAtk = BitBoard.bishopAttacks(wKingSq, occupied);
            NkBishAtk = LL.not(kBishAtk);
            if (  LL.not0( LL.and(BitBoard.bishopAttacks(wKingSq, LL.and(occupied, NkBishAtk)) ,
                    LL.or(pos.pieceTypeBB[Piece.BQUEEN] , pos.pieceTypeBB[Piece.BBISHOP])) ) )
                LL.or_( discovered, kBishAtk );
            OrRookBishAtk = LL.or(kRookAtk , kBishAtk);    

            // Queen moves
            /*long*/ squares = LL.c( pos.pieceTypeBB[Piece.BQUEEN] );
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.or(BitBoard.rookAttacks(sq, occupied) , BitBoard.bishopAttacks(sq, occupied));
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.whiteBB , OrRookBishAtk ) );
                LL.and_( m, NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c( pos.pieceTypeBB[Piece.BROOK] );
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.c( BitBoard.rookAttacks(sq, occupied) );
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.whiteBB , kRookAtk ) );
                LL.and_( m, NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c( pos.pieceTypeBB[Piece.BBISHOP] );
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.c( BitBoard.bishopAttacks(sq, occupied) );
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.whiteBB , kBishAtk ) );
                LL.and_( m, NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }
            
            // King moves
            {
                /*int*/ sq = pos.getKingSq(false);
                /*long*/ m = LL.c( BitBoard.kingAttacks[sq] );
                LL.and_( m, ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )  ? pos.whiteBB : NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                /*int*/ k0 = 60;
                if (sq == k0) {
                    OO_SQ = o_xL6;
                    OOO_SQ = o_xLE;
                    if (((pos.getCastleMask() & (Position.H8_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 + 3) == Piece.BROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 + 1)) {
                        this.setMove(moveList, k0, k0 + 2, Piece.EMPTY);
                    }
                    if (((pos.getCastleMask() & (Position.A8_CASTLE)) != 0) &&
                        ( LL.is0( LL.and(OOO_SQ,occupied) ) ) &&
                        (pos.getPiece(k0 - 4) == Piece.BROOK) &&
                        !this.sqAttacked(pos, k0) &&
                        !this.sqAttacked(pos, k0 - 1)) {
                        this.setMove(moveList, k0, k0 - 2, Piece.EMPTY);
                    }
                }
            }

            // Knight moves
            /*long*/ knights = LL.c( pos.pieceTypeBB[Piece.BKNIGHT] );
            /*long*/ kKnightAtk = BitBoard.knightAttacks[wKingSq];
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and(BitBoard.knightAttacks[sq], NblackBB);
                if ( LL.is0( LL.and(discovered, LL.bitObj(sq)) ) )
                    LL.and_( m, LL.or(pos.whiteBB , kKnightAtk ) );
                LL.and_( m, NblackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // Pawn moves
            // Captures
            /*long*/ pawns = pos.pieceTypeBB[Piece.BPAWN];

            epM2 = LL.or(pos.whiteBB,epMask);
            m = LL.and( LL.and( LL.rshift(pawns,9), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 9, false)) return moveList;

            m = LL.and( LL.and( LL.rshift(pawns,7), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 7, false)) return moveList;

            // Discovered checks and promotions
            /*long*/ pawnAll = LL.or( discovered , BitBoard.maskRow2 );
            NpawnAll = LL.not(pawnAll);

            /*long*/ m = LL.and( LL.rshift( LL.and(pawns,pawnAll), 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos, m, 8, false)) return moveList;
            m = LL.and(  LL.rshift( LL.and(m,BitBoard.maskRow6), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos, m, 16);

            // Normal checks
            /*long*/ m = LL.and( LL.rshift( LL.and(pawns,NpawnAll), 8), Noccupied );
            if (this.addPawnMovesByMask(moveList, pos,
                LL.and( m, BitBoard.wPawnAttacks[wKingSq] ), 8, false)) return moveList;
            m = LL.and(  LL.rshift( LL.and(m,BitBoard.maskRow6), 8 ), Noccupied );
            this.addPawnDoubleMovesByMask(moveList, pos,
                LL.and( m, BitBoard.wPawnAttacks[wKingSq]), 16);
        }

        return moveList;
    }

    public function pseudoLegalCaptures( pos:POSITION ):MoveList {
    
        var sq:int;
		var squares:i64, m:i64, knights:i64, pawns:i64, epM2:i64;
        var moveList:MoveList = this.getMoveListObj();
        var occupied:i64 = LL.or(pos.whiteBB, pos.blackBB);
        var Noccupied:i64 = LL.not(occupied);
        var NwhiteBB:i64 = LL.not(pos.whiteBB);
        var NblackBB:i64 = LL.not(pos.blackBB);
        var epSquare:int = pos.getEpSquare();
        var epMask:i64 = ((epSquare >= 0) ? LL.bitObj(epSquare) : new i64() );

        if (pos.whiteMove) {

            // Queen moves
            /*long*/ squares = LL.c(pos.pieceTypeBB[Piece.WQUEEN]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.or(BitBoard.rookAttacks(sq, occupied),
                     BitBoard.bishopAttacks(sq, occupied)), pos.blackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c(pos.pieceTypeBB[Piece.WROOK]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.rookAttacks(sq, occupied), pos.blackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c(pos.pieceTypeBB[Piece.WBISHOP]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.bishopAttacks(sq, occupied), pos.blackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Knight moves
            /*long*/ knights = LL.c(pos.pieceTypeBB[Piece.WKNIGHT]);
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and( BitBoard.knightAttacks[sq], pos.blackBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // King moves
            /*int*/ sq = pos.getKingSq(true);
            /*long*/ m = LL.and( BitBoard.kingAttacks[sq], pos.blackBB );
            if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;


            // Pawn moves
            /*long*/ pawns = LL.c(pos.pieceTypeBB[Piece.WPAWN]);
            /*long*/ m = LL.and( LL.and( LL.lshift(pawns, 8), Noccupied ), BitBoard.maskRow8 );
            if (this.addPawnMovesByMask(moveList, pos, m, -8, false)) return moveList;


            epM2 = LL.or(pos.blackBB,epMask);
            m = LL.and( LL.and( LL.lshift(pawns,7), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -7, false)) return moveList;

            m = LL.and( LL.and( LL.lshift(pawns,9), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, -9, false)) return moveList;

        } else {

            // Queen moves
            /*long*/ squares = LL.c(pos.pieceTypeBB[Piece.BQUEEN]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( LL.or(BitBoard.rookAttacks(sq, occupied),
                     BitBoard.bishopAttacks(sq, occupied)), pos.whiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Rook moves
            squares = LL.c(pos.pieceTypeBB[Piece.BROOK]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.rookAttacks(sq, occupied), pos.whiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Bishop moves
            squares = LL.c(pos.pieceTypeBB[Piece.BBISHOP]);
            while (LL.not0(squares)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(squares);
                /*long*/ m = LL.and( BitBoard.bishopAttacks(sq, occupied), pos.whiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( squares, LL.sub(squares,o_x1) );
            }

            // Knight moves
            /*long*/ knights = LL.c(pos.pieceTypeBB[Piece.BKNIGHT]);
            while (LL.not0(knights)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(knights);
                /*long*/ m = LL.and( BitBoard.knightAttacks[sq], pos.whiteBB );
                if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;
                LL.and_( knights,LL.sub(knights,o_x1) );
            }

            // King moves
            /*int*/ sq = pos.getKingSq(false);
            /*long*/ m = LL.and( BitBoard.kingAttacks[sq], pos.whiteBB );
            if (this.addMovesByMask(moveList, pos, sq, m)) return moveList;


            // Pawn moves
            /*long*/ pawns = LL.c(pos.pieceTypeBB[Piece.BPAWN]);
            /*long*/ m = LL.and( LL.and( LL.rshift(pawns, 8), Noccupied ), BitBoard.maskRow1 );
            if (this.addPawnMovesByMask(moveList, pos, m, 8, false)) return moveList;

            epM2 = LL.or(pos.whiteBB,epMask);

            m = LL.and( LL.and( LL.rshift(pawns,9), BitBoard.maskBToHFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 9, false)) return moveList;

            m = LL.and( LL.and( LL.rshift(pawns,7), BitBoard.maskAToGFiles ), epM2 );
            if (this.addPawnMovesByMask(moveList, pos, m, 7, false)) return moveList;
        }
        return moveList;
    }

    /**
     * Return true if the side to move is in check.
     */
    public function inCheck( pos:POSITION ):Boolean {
        var kingSq:int = pos.getKingSq(pos.whiteMove);
        return this.sqAttacked(pos, kingSq);
    }

    /**
     * Return the next piece in a given direction, starting from sq.
     */
    private function nextPiece( pos:POSITION, sq:int, delta:int ):int {
		var p:int;
        while (delta!=0) {
            sq += delta;
            p = pos.getPiece(sq);
            if (p != Piece.EMPTY) return p;
        }
        return Piece.EMPTY;
    }

    /** Like nextPiece(), but handles board edges. */
    private function nextPieceSafe( pos:POSITION, sq:int, delta:int):int {
        var dx:int = 0, dy:int = 0;
        switch (delta) {
        case 1: dx=1; dy=0; break;
        case 9: dx=1; dy=1; break;
        case 8: dx=0; dy=1; break;
        case 7: dx=-1; dy=1; break;
        case -1: dx=-1; dy=0; break;
        case -9: dx=-1; dy=-1; break;
        case -8: dx=0; dy=-1; break;
        case -7: dx=1; dy=-1; break;
        default: return Piece.EMPTY;
        }
        var x:int = Position.getX(sq);
        var y:int = Position.getY(sq);
		var p:int;
        while (true) {
            x += dx; y += dy;
            if ((x < 0) || (x > 7) || (y < 0) || (y > 7)) return Piece.EMPTY;
            p = pos.getPiece(Position.getSquare(x, y));
            if (p != Piece.EMPTY) return p;
        }
		return Piece.EMPTY;
    }
    
    /**
     * Return true if making a move delivers check to the opponent
     */
    public function givesCheck( pos:POSITION,m:MOVE ):Boolean {
        var wtm:Boolean = pos.whiteMove;
        var oKingSq:int = pos.getKingSq(!wtm);
        var oKing:int = (wtm ? Piece.BKING : Piece.WKING);
        var p:int = Piece.makeWhite(m.promoteTo == Piece.EMPTY ? pos.getPiece(m.from) : m.promoteTo);
        var d1:int = BitBoard.getDirection(m.to, oKingSq);
        var d2:int, p2:int, dx:int, d3:int, epSq:int;
        switch (d1) {
        case 8: case -8: case 1: case -1: // Rook direction
            if ((p == Piece.WQUEEN) || (p == Piece.WROOK))
                if ((d1 != 0) && (this.nextPiece(pos, m.to, d1) == oKing))
                    return true;
            break;
        case 9: case 7: case -9: case -7: // Bishop direction
            if ((p == Piece.WQUEEN) || (p == Piece.WBISHOP)) {
                if ((d1 != 0) && (this.nextPiece(pos, m.to, d1) == oKing))
                    return true;
            } else if (p == Piece.WPAWN) {
                if (((d1 > 0) == wtm) && (pos.getPiece(m.to + d1) == oKing))
                    return true;
            }
            break;
        default:
            if (d1 != 0) { // Knight direction
                if (p == Piece.WKNIGHT)
                    return true;
            }
        }
        d2 = BitBoard.getDirection(m.from, oKingSq);
        if ((d2 != 0) && (d2 != d1) && (this.nextPiece(pos, m.from, d2) == oKing)) {
            p2 = this.nextPieceSafe(pos, m.from, -d2);
            switch (d2) {
            case 8: case -8: case 1: case -1: // Rook direction
                if ((p2 == (wtm ? Piece.WQUEEN : Piece.BQUEEN)) ||
                    (p2 == (wtm ? Piece.WROOK : Piece.BROOK)))
                    return true;
                break;
            case 9: case 7: case -9: case -7: // Bishop direction
                if ((p2 == (wtm ? Piece.WQUEEN : Piece.BQUEEN)) ||
                    (p2 == (wtm ? Piece.WBISHOP : Piece.BBISHOP)))
                    return true;
                break;
            }
        }
        if ((m.promoteTo != Piece.EMPTY) && (d1 != 0) && (d1 == d2)) {
            switch (d1) {
            case 8: case -8: case 1: case -1: // Rook direction
                if ((p == Piece.WQUEEN) || (p == Piece.WROOK))
                    if ((d1 != 0) && (this.nextPiece(pos, m.from, d1) == oKing))
                        return true;
                break;
            case 9: case 7: case -9: case -7: // Bishop direction
                if ((p == Piece.WQUEEN) || (p == Piece.WBISHOP)) {
                    if ((d1 != 0) && (this.nextPiece(pos, m.from, d1) == oKing))
                        return true;
                }
                break;
            }
        }
        if (p == Piece.WKING) {
            if (m.to - m.from == 2) { // O-O
                if (this.nextPieceSafe(pos, m.from, -1) == oKing)
                    return true;
                if (this.nextPieceSafe(pos, m.from + 1, wtm ? 8 : -8) == oKing)
                    return true;
            } else if (m.to - m.from == -2) { // O-O-O
                if (this.nextPieceSafe(pos, m.from, 1) == oKing)
                    return true;
                if (this.nextPieceSafe(pos, m.from - 1, wtm ? 8 : -8) == oKing)
                    return true;
            }
        } else if (p == Piece.WPAWN) {
            if (pos.getPiece(m.to) == Piece.EMPTY) {
                dx = Position.getX(m.to) - Position.getX(m.from);
                if (dx != 0) { // en passant
                    epSq = m.from + dx;
                    d3 = BitBoard.getDirection(epSq, oKingSq);
                    switch (d3) {
                    case 9: case 7: case -9: case -7:
                        if (this.nextPiece(pos, epSq, d3) == oKing) {
                            p2 = this.nextPieceSafe(pos, epSq, -d3);
                            if ((p2 == (wtm ? Piece.WQUEEN : Piece.BQUEEN)) ||
                                (p2 == (wtm ? Piece.WBISHOP : Piece.BBISHOP)))
                                return true;
                        }
                        break;
                    case 1:
                        if (this.nextPiece(pos, Math.max(epSq, m.from), d3) == oKing) {
                            p2 = this.nextPieceSafe(pos, Math.min(epSq, m.from), -d3);
                            if ((p2 == (wtm ? Piece.WQUEEN : Piece.BQUEEN)) ||
                                (p2 == (wtm ? Piece.WROOK : Piece.BROOK)))
                                return true;
                        }
                        break;
                    case -1:
                        if (this.nextPiece(pos, Math.min(epSq, m.from), d3) == oKing) {
                            p2 = this.nextPieceSafe(pos, Math.max(epSq, m.from), -d3);
                            if ((p2 == (wtm ? Piece.WQUEEN : Piece.BQUEEN)) ||
                                (p2 == (wtm ? Piece.WROOK : Piece.BROOK)))
                                return true;
                        }
                        break;
                    }
                }
            }
        }
        return false;
    }

    /**
     * Return true if the side to move can take the opponents king.
     */
    public function canTakeKing( pos:POSITION ):Boolean {
        pos.setWhiteMove(!pos.whiteMove);
        var ret:Boolean = this.inCheck(pos);
        pos.setWhiteMove(!pos.whiteMove);
        return ret;
    }

    /**
     * Return true if a square is attacked by the opposite side.
     */
    public function sqAttacked( pos:POSITION, sq:int ):Boolean {
		var occupied:i64, bbQueen:i64;
		
        if (pos.whiteMove) {
            if (LL.not0( LL.and(BitBoard.knightAttacks[sq], pos.pieceTypeBB[Piece.BKNIGHT]) ))
                return true;
            if (LL.not0( LL.and(BitBoard.kingAttacks[sq], pos.pieceTypeBB[Piece.BKING]) ))
                return true;
            if (LL.not0( LL.and(BitBoard.wPawnAttacks[sq], pos.pieceTypeBB[Piece.BPAWN]) ))
                return true;
            occupied = LL.or( pos.whiteBB, pos.blackBB );
            bbQueen = pos.pieceTypeBB[Piece.BQUEEN];
            if ( LL.not0( LL.and(BitBoard.bishopAttacks(sq, occupied),
                 LL.or(pos.pieceTypeBB[Piece.BBISHOP], bbQueen)) ))
                return true;
            if ( LL.not0( LL.and(BitBoard.rookAttacks(sq, occupied),
                 LL.or(pos.pieceTypeBB[Piece.BROOK], bbQueen)) ))
                return true;
        } else {
            if (LL.not0( LL.and(BitBoard.knightAttacks[sq], pos.pieceTypeBB[Piece.WKNIGHT]) ))
                return true;
            if (LL.not0( LL.and(BitBoard.kingAttacks[sq], pos.pieceTypeBB[Piece.WKING]) ))
                return true;
            if (LL.not0( LL.and(BitBoard.bPawnAttacks[sq], pos.pieceTypeBB[Piece.WPAWN]) ))
                return true;
            occupied = LL.or( pos.whiteBB, pos.blackBB );
            bbQueen = pos.pieceTypeBB[Piece.WQUEEN];
            if ( LL.not0( LL.and(BitBoard.bishopAttacks(sq, occupied),
                 LL.or(pos.pieceTypeBB[Piece.WBISHOP], bbQueen)) ))
                return true;
            if ( LL.not0( LL.and(BitBoard.rookAttacks(sq, occupied),
                 LL.or(pos.pieceTypeBB[Piece.WROOK], bbQueen)) ))
                return true;
        }
        return false;
    }

    /**
     * Remove all illegal moves from moveList.
     * "moveList" is assumed to be a list of pseudo-legal moves.
     * This function removes the moves that don't defend from check threats.
     */
    public function removeIllegal( pos:POSITION, moveList:MoveList ):void {
        var l:int = 0;
        var ui:UNDOINFO = new UNDOINFO();
		var m:MOVE;
        for (var mi:int = 0; mi < moveList.size; mi++) {
            m = moveList.m[mi];
            pos.makeMove(m, ui);
            pos.setWhiteMove(!pos.whiteMove);
            if (!this.inCheck(pos))
                moveList.m[ l++ ] = new MOVE( m.from, m.to, m.promoteTo, 0);
            pos.setWhiteMove(!pos.whiteMove);
            pos.unMakeMove(m, ui);
        }
        moveList.size = l;
    }

    private function addPawnMovesByMask( moveList:MoveList, pos:POSITION, mask_:i64,
                            delta:int , allPromotions:Boolean ):Boolean {
        if (LL.is0(mask_)) return false;
		var mask:i64 = LL.c(mask_);
        var sq:int, sq0:int;
        var oKingMask:i64 = LL.c( pos.pieceTypeBB[pos.whiteMove ? Piece.BKING : Piece.WKING] );
        var kingmask:i64 = LL.and(mask,oKingMask);
        if (  LL.not0( kingmask ) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(kingmask);
            moveList.size = 0;
            this.setMove(moveList, sq + delta, sq, Piece.EMPTY);
            return true;
        }
        var promMask:i64 = LL.and( mask, BitBoard.maskRow1Row8 );
        LL.and_( mask, LL.not(promMask) );
        while (LL.not0(promMask)) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(promMask);
            /*int*/ sq0 = sq + delta;
            if (sq >= 56) { // White promotion
                this.setMove(moveList, sq0, sq, Piece.WQUEEN);
                this.setMove(moveList, sq0, sq, Piece.WKNIGHT);
                if (allPromotions) {
                    this.setMove(moveList, sq0, sq, Piece.WROOK);
                    this.setMove(moveList, sq0, sq, Piece.WBISHOP);
                }
            } else { // Black promotion
                this.setMove(moveList, sq0, sq, Piece.BQUEEN);
                this.setMove(moveList, sq0, sq, Piece.BKNIGHT);
                if (allPromotions) {
                    this.setMove(moveList, sq0, sq, Piece.BROOK);
                    this.setMove(moveList, sq0, sq, Piece.BBISHOP);
                }
            }
            LL.and_( promMask, LL.sub(promMask,o_x1) )
        }
        while (LL.not0(mask)) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(mask);
            this.setMove(moveList, sq + delta, sq, Piece.EMPTY);
            LL.and_( mask, LL.sub(mask,o_x1) )
        }
        return false;
    }

    private function addPawnDoubleMovesByMask( moveList:MoveList, pos:POSITION,
                                 mask_:i64, delta:int):void {
		var mask:i64 = LL.c(mask_);
		var sq:int;
        while (LL.not0(mask)) {
            sq = BitBoard.numberOfTrailingZeros(mask);
            this.setMove(moveList, sq + delta, sq, Piece.EMPTY);
            LL.and_( mask, LL.sub(mask,o_x1) )
        }
    }
    
    private function addMovesByMask( moveList:MoveList, pos:POSITION,
					sq0:int, mask_:i64 ):Boolean {
		var mask:i64 = LL.c(mask_);
		var sq:int;
        var oKingMask:i64 = LL.c( pos.pieceTypeBB[pos.whiteMove ? Piece.BKING : Piece.WKING] );
        var kingmask:i64 = LL.and(mask,oKingMask);
        if (  LL.not0( kingmask ) ) {
            sq = BitBoard.numberOfTrailingZeros(kingmask);
            moveList.size = 0;
            this.setMove(moveList, sq0, sq, Piece.EMPTY);
            return true;
        }
        while (LL.not0(mask)) {
            sq = BitBoard.numberOfTrailingZeros(mask);
            this.setMove(moveList, sq0, sq, Piece.EMPTY);
            LL.and_( mask, LL.sub(mask,o_x1) )
        }
        return false;
    }

    private function setMove( moveList:MoveList, from:int, to:int, promoteTo:int):void {
        moveList.m[moveList.size++] = new MOVE( from, to, promoteTo, 0);
    }

 
    private function getMoveListObj():MoveList {
        var ml:MoveList;
        if (this.moveListsInCache > 0) {
            this.moveListCache.length = --this.moveListsInCache;
            ml = /*(MoveList)*/ this.moveListCache[this.moveListsInCache];
            ml.m = []; ml.size = 0;
        } else {
            ml = new MoveList();
        }
        return ml;
    }

    /** Return(restore) all move objects in moveList to the move cache. */
    public function returnMoveList( moveList:MoveList):void {
        if (this.moveListsInCache < this.moveListCache.length) {
            this.moveListCache[this.moveListsInCache++] = moveList;
        }
    }

	}
}