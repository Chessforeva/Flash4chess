package
{
	public class EVALUATE
	{
		
	public const pV:int = 100;
    public const nV:int = 400;
    public const bV:int = 400;
    public const rV:int = 600;
    public const qV:int = 1200;
    public const kV:int = 9900; // Used by SEE algorithm, but not included in board material sums

	private var LL:INT64 = Main.LL;
	private var Piece:PIECE = Main.Piece;
	private var BitBoard:BITBOARD = Main.BitBoard;
	private var Position:POSITION = Main.Position;
	private var Kpk:KPK = Main.Kpk;
		
    public var /*int[]*/ pieceValue:Array = new Array();

	private const o_x1:i64 = LL.v(1);
	private const o_x06:i64 = LL.v(0x06);
	private const o_x03:i64 = LL.v(0x03);
	private const o_x60:i64 = LL.v(0x60);
	private const o_xC0:i64 = LL.v(0xC0);
	private const o_x0E:i64 = LL.v(0x0E);
	private const o_xFF:i64 = LL.v(0xFF);
	private const o_x81x:i64 = LL.ax(0x00810000, 0x8100);
	private const o_xFF1:i64 = LL.ax(0x00ff0000,0);
	private const o_xFF2:i64 = LL.ax(0xff000000,0);
	private const o_xFF3:i64 = LL.ax(0,0xff00);
	private const o_xFF4:i64 = LL.ax(0,0xff);
	private const o_xLC:i64 = LL.ax(0xC0000000,0);
	private const o_xL6:i64 = LL.ax(0x60000000,0);
	private const o_xLv6:i64 =LL.ax(0x6000000,0);
	private const o_xLv3:i64 =LL.ax(0x3000000,0);
	private const o_xE7:i64 = LL.v(0xe7);
	private const o_x18:i64 = LL.v(0x18);
	private const o_x0303:i64 = LL.ax(0x03030000,0);
	private const o_xC0C0:i64 = LL.ax(0xC0C00000,0);
	private const o_xLv0303:i64 = LL.v(0x0303);
	private const o_xLvC0C0:i64 = LL.v(0xC0C0);
	private const o_xFFFF:i64 = LL.v(0xFFFF);
	private const o_xKxZ1:i64 = LL.ax(0x0F,0x1F1F1F1F);
	private const o_xKxZ2:i64 = LL.ax(0,0x071F1F1F);
	private const o_xKxZ3:i64 = LL.ax(0,0xE0F8F8F8);
	private const o_xKxZ4:i64 = LL.ax(0xF0,0xF8F8F8F8); 

    /** Piece/square table for king during middle game. */
    private var /*int[]*/ kt1b:Array = [ -22,-35,-40,-40,-40,-40,-35,-22,
                                -22,-35,-40,-40,-40,-40,-35,-22,
                                -25,-35,-40,-45,-45,-40,-35,-25,
                                -15,-30,-35,-40,-40,-35,-30,-15,
                                -10,-15,-20,-25,-25,-20,-15,-10,
                                  4, -2, -5,-15,-15, -5, -2,  4,
                                 16, 14,  7, -3, -3,  7, 14, 16,
                                 24, 24,  9,  0,  0,  9, 24, 24 ];

    /** Piece/square table for king during end game. */
    private var /*int[]*/ kt2b:Array = [  0,  8, 16, 24, 24, 16,  8,  0,
                                 8, 16, 24, 32, 32, 24, 16,  8,
                                16, 24, 32, 40, 40, 32, 24, 16,
                                24, 32, 40, 48, 48, 40, 32, 24,
                                24, 32, 40, 48, 48, 40, 32, 24,
                                16, 24, 32, 40, 40, 32, 24, 16,
                                 8, 16, 24, 32, 32, 24, 16,  8,
                                 0,  8, 16, 24, 24, 16,  8,  0 ];

    /** Piece/square table for pawns during middle game. */
    private var /*int[]*/ pt1b:Array = [  0,  0,  0,  0,  0,  0,  0,  0,
                                 8, 16, 24, 32, 32, 24, 16,  8,
                                 3, 12, 20, 28, 28, 20, 12,  3,
                                -5,  4, 10, 20, 20, 10,  4, -5,
                                -6,  4,  5, 16, 16,  5,  4, -6,
                                -6,  4,  2,  5,  5,  2,  4, -6,
                                -6,  4,  4,-15,-15,  4,  4, -6,
                                 0,  0,  0,  0,  0,  0,  0,  0 ];

    /** Piece/square table for pawns during end game. */
    private var /*int[]*/ pt2b:Array = [  0,  0,  0,  0,  0,  0,  0,  0,
                                 25, 40, 45, 45, 45, 45, 40, 25,
                                 17, 32, 35, 35, 35, 35, 32, 17,
                                  5, 24, 24, 24, 24, 24, 24,  5,
                                 -9, 11, 11, 11, 11, 11, 11, -9,
                                -17,  3,  3,  3,  3,  3,  3,-17,
                                -20,  0,  0,  0,  0,  0,  0,-20,
                                  0,  0,  0,  0,  0,  0,  0,  0 ];

    /** Piece/square table for knights during middle game. */
    private var /*int[]*/ nt1b:Array = [ -53,-42,-32,-21,-21,-32,-42,-53,
                                -42,-32,-10,  0,  0,-10,-32,-42,
                                -21,  5, 10, 16, 16, 10,  5,-21,
                                -18,  0, 10, 21, 21, 10,  0,-18,
                                -18,  0,  3, 21, 21,  3,  0,-18,
                                -21,-10,  0,  0,  0,  0,-10,-21,
                                -42,-32,-10,  0,  0,-10,-32,-42,
                                -53, -42, -32, -21, -21, -32, -42, -53 ];

    /** Piece/square table for knights during end game. */
    private var /*int[]*/ nt2b:Array = [ -56,-44,-34,-22,-22,-34,-44,-56,
                                -44,-34,-10,  0,  0,-10,-34,-44,
                                -22,  5, 10, 17, 17, 10,  5,-22,
                                -19,  0, 10, 22, 22, 10,  0,-19,
                                -19,  0,  3, 22, 22,  3,  0,-19,
                                -22,-10,  0,  0,  0,  0,-10,-22,
                                -44,-34,-10,  0,  0,-10,-34,-44,
                                -56, -44, -34, -22, -22, -34, -44, -56 ];

    /** Piece/square table for bishops during middle game. */
    private var /*int[]*/ bt1b:Array = [  0,  0,  0,  0,  0,  0,  0,  0,
                                 0,  4,  2,  2,  2,  2,  4,  0,
                                 0,  2,  4,  4,  4,  4,  2,  0,
                                 0,  2,  4,  4,  4,  4,  2,  0,
                                 0,  2,  4,  4,  4,  4,  2,  0,
                                 0,  3,  4,  4,  4,  4,  3,  0,
                                 0,  4,  2,  2,  2,  2,  4,  0,
                                 0,  0, -2,  0,  0, -2,  0,  0 ];

    /** Piece/square table for queens during middle game. */
    private var /*int[]*/ qt1b:Array = [ -10, -5,  0,  0,  0,  0, -5,-10,
                                 -5,  0,  5,  5,  5,  5,  0, -5,
                                  0,  5,  5,  6,  6,  5,  5,  0,
                                  0,  5,  6,  6,  6,  6,  5,  0,
                                  0,  5,  6,  6,  6,  6,  5,  0,
                                  0,  5,  5,  6,  6,  5,  5,  0,
                                 -5,  0,  5,  5,  5,  5,  0, -5,
                                -10, -5,  0,  0,  0,  0, -5, -10 ];

    /** Piece/square table for rooks during middle game. */
    private var /*int[]*/ rt1b:Array = [  0,  3,  5,  5,  5,  5,  3,  0,
                                15, 20, 20, 20, 20, 20, 20, 15,
                                 0,  0,  0,  0,  0,  0,  0,  0,
                                 0,  0,  0,  0,  0,  0,  0,  0,
                                -2,  0,  0,  0,  0,  0,  0, -2,
                                -2,  0,  0,  2,  2,  0,  0, -2,
                                -3,  2,  5,  5,  5,  5,  2, -3,
                                 0,  3,  5,  5,  5,  5,  3,  0 ];

    private var /*int[]*/ kt1w:Array = [];
	private var /*int[]*/ qt1w:Array = [];
	private var /*int[]*/ rt1w:Array = [];
	private var /*int[]*/ bt1w:Array = [];
	private var /*int[]*/ nt1w:Array = [];
	private var /*int[]*/ pt1w:Array = [];
	private var /*int[]*/ kt2w:Array = [];
	private var /*int[]*/ nt2w:Array = [];
	private var /*int[]*/ pt2w:Array = [];
    public var /*int[]*/ e0:Array = [];

    public function initAll():void
        {
		for (var i:int = 0; i < 64; i++) this.e0.push(0);
		
        this.pieceValue = [ 0, this.kV, this.qV, this.rV, this.bV, this.nV, this.pV,
                 this.kV, this.qV, this.rV, this.bV, this.nV, this.pV ];
     
        this.kt1w = this.kt1b.slice().reverse();
        this.qt1w = this.qt1b.slice().reverse();
        this.rt1w = this.rt1b.slice().reverse();
        this.bt1w = this.bt1b.slice().reverse();
        this.nt1w = this.nt1b.slice().reverse();
        this.pt1w = this.pt1b.slice().reverse();
        this.kt2w = this.kt2b.slice().reverse();
        this.nt2w = this.nt2b.slice().reverse();
        this.pt2w = this.pt2b.slice().reverse();

        this.psTab1 = [ this.e0, this.kt1w, this.qt1w, this.rt1w, this.bt1w, this.nt1w, this.pt1w,
                            this.kt1b, this.qt1b, this.rt1b, this.bt1b, this.nt1b, this.pt1b ];
        this.psTab2 = [ this.e0, this.kt2w, this.qt1w, this.rt1w, this.bt1w, this.nt2w, this.pt2w,
                            this.kt2b, this.qt1b, this.rt1b, this.bt1b, this.nt2b, this.pt2b ];
        this.GenCastleFactor(256);
        }
    
	public var /*int[]*/ psTab1:Array = [];
    public var /*int[]*/ psTab2:Array = [];

    private const /*int[]*/ distToH1A8:Array =
      [ [ 0, 1, 2, 3, 4, 5, 6, 7 ],
        [ 1, 2, 3, 4, 5, 6, 7, 6 ],
        [ 2, 3, 4, 5, 6, 7, 6, 5 ],
        [ 3, 4, 5, 6, 7, 6, 5, 4 ],
        [ 4, 5, 6, 7, 6, 5, 4, 3 ],
        [ 5, 6, 7, 6, 5, 4, 3, 2 ],
        [ 6, 7, 6, 5, 4, 3, 2, 1 ],
        [ 7, 6, 5, 4, 3, 2, 1, 0 ] ];

    private var /*int[]*/ rookMobScore:Array = [ -10, -7, -4, -1, 2, 5, 7, 9, 11, 12, 13, 14, 14, 14, 14];
    private var /*int[]*/ bishMobScore:Array = [ -15, -10, -6, -2, 2, 6, 10, 13, 16, 18, 20, 22, 23, 24];
    private var /*int[]*/ queenMobScore:Array = [ -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 9, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
    
    private var /*PawnHashData[]*/ pawnHash:Array = [];
    private var /*KingSafetyHashData[]*/ kingSafetyHash:Array = [];
	public function ClearHash():void { pawnHash = []; kingSafetyHash = []; }
	
    private var ppBonus:Array = [ -1, 24, 26, 30, 36, 47, 64, -1];

    // King safety variables
    private var /*long*/ wKingZone:i64 = new i64();
	private var /*long*/ bKingZone:i64 = new i64();		// Squares close to king that are worth attacking
    private var /*int*/ wKingAttacks:int = 0;
	private var /*int*/ bKingAttacks:int = 0;				// Number of attacks close to white/black king
    private var /*long*/ wAttacksBB:i64 = new i64();
	private var /*long*/ bAttacksBB:i64 = new i64();

    private var castleFactor:Array = new Array();

		
    /**
     * evaluation of a position.
     * param pos The position to evaluate.
     * return The evaluation score, measured in centipawns.
     * Positive values are good for the side to make the next move.
     */
    public function evalPos(pos:POSITION):int {
        var score:int = pos.wMtrl - pos.bMtrl;

        this.wKingAttacks = 0;
        this.bKingAttacks = 0;
        this.wKingZone = BitBoard.kingAttacks[pos.getKingSq(true)];
        this.wKingZone = LL.or( this.wKingZone, LL.lshift(this.wKingZone,8) );
        this.bKingZone = BitBoard.kingAttacks[pos.getKingSq(false)];
        this.bKingZone = LL.or( this.bKingZone, LL.rshift(this.bKingZone,8) );
        this.wAttacksBB = new i64();
        this.bAttacksBB = new i64();

        score += this.pieceSquareEval(pos);
        score += this.pawnBonus(pos);
        score += this.tradeBonus(pos);
        score += this.castleBonus(pos);

        score += this.rookBonus(pos);
        score += this.bishopEval(pos, score);
        score += this.threatBonus(pos);
        score += this.kingSafety(pos);
        score = this.endGameEval(pos, score);

        if (!pos.whiteMove) score = -score;
        return score;
    }

    /** Compute white_material - black_material. */
    private function material(pos:POSITION):int {
        return pos.wMtrl - pos.bMtrl;
    }
    
    /** Compute score based on piece square tables. Positive values are good for white. */
    private function pieceSquareEval(pos:POSITION):int {
        var score:int = 0;
        var wMtrl:int = pos.wMtrl;
        var bMtrl:int = pos.bMtrl;
        var wMtrlPawns:int = pos.wMtrlPawns;
        var bMtrlPawns:int = pos.bMtrlPawns;
        var k1:int, k2:int, t1:int, t2:int, t:int, tw:int, tb:int, n1:int, n2:int;
		var wp1:int, wp2:int, bp1:int, bp2:int, r1:int, nP:int, s:int;
        
        // Kings
        {
            t1 = this.qV + (this.rV<<1) + (this.bV<<1);
            t2 = this.rV;
            {
                k1 = pos.psScore1[Piece.WKING];
                k2 = pos.psScore2[Piece.WKING];
                t = bMtrl - bMtrlPawns;
                score += this.interpolate(t, t2, k2, t1, k1);
            }
            {
                k1 = pos.psScore1[Piece.BKING];
                k2 = pos.psScore2[Piece.BKING];
                t = wMtrl - wMtrlPawns;
                score -= this.interpolate(t, t2, k2, t1, k1);
            }
        }

        // Pawns
        {
            t1 = this.qV + (this.rV<<1) + (this.bV<<1);
            t2 = this.rV;
            wp1 = pos.psScore1[Piece.WPAWN];
            wp2 = pos.psScore2[Piece.WPAWN];
            if ((wp1 != 0) || (wp2 != 0)) {
                tw = bMtrl - bMtrlPawns;
                score += this.interpolate(tw, t2, wp2, t1, wp1);
            }
            bp1 = pos.psScore1[Piece.BPAWN];
            bp2 = pos.psScore2[Piece.BPAWN];
            if ((bp1 != 0) || (bp2 != 0)) {
                /*int*/ tb = wMtrl - wMtrlPawns;
                score -= this.interpolate(tb, t2, bp2, t1, bp1);
            }
        }

        // Knights
        {
            t1 = this.qV + (this.rV<<1) + this.bV + this.nV + (6*this.pV);
            t2 = this.nV + (this.pV<<3);
            n1 = pos.psScore1[Piece.WKNIGHT];
            n2 = pos.psScore2[Piece.WKNIGHT];
            if ((n1 != 0) || (n2 != 0)) {
                score += this.interpolate(bMtrl, t2, n2, t1, n1);
            }
            n1 = pos.psScore1[Piece.BKNIGHT];
            n2 = pos.psScore2[Piece.BKNIGHT];
            if ((n1 != 0) || (n2 != 0)) {
                score -= this.interpolate(wMtrl, t2, n2, t1, n1);
            }
        }

        // Bishops
        {
            score += pos.psScore1[Piece.WBISHOP];
            score -= pos.psScore1[Piece.BBISHOP];
        }

        // Queens
        {
            var m:i64, atk:i64;
			var sq:int;
            var /*long*/ occupied:i64 = LL.or( pos.whiteBB, pos.blackBB );
            var NwhiteBB:i64 = LL.not( pos.whiteBB );
            var NblackBB:i64 = LL.not( pos.blackBB );
            
            score += pos.psScore1[Piece.WQUEEN];
            /*long*/ m = LL.c( pos.pieceTypeBB[Piece.WQUEEN] );
            while (LL.not0(m)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
                /*long*/ atk = LL.or( BitBoard.rookAttacks(sq, occupied), BitBoard.bishopAttacks(sq, occupied) );
                LL.or_( this.wAttacksBB, atk );
                score += this.queenMobScore[ LL.bitcount( LL.and( atk, NwhiteBB ) ) ];
                this.bKingAttacks += (LL.bitcount( LL.and( atk, this.bKingZone) ) << 1);
                LL.and_( m, LL.sub(m,o_x1) );
            }
            score -= pos.psScore1[Piece.BQUEEN];
            m = LL.c( pos.pieceTypeBB[Piece.BQUEEN] );
            while (LL.not0(m)) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
                /*long*/ atk = LL.or( BitBoard.rookAttacks(sq, occupied), BitBoard.bishopAttacks(sq, occupied) );
                LL.or_( this.bAttacksBB, atk );
                score -= this.queenMobScore[ LL.bitcount( LL.and( atk, NblackBB ) ) ];
                this.wKingAttacks += (LL.bitcount( LL.and( atk, this.wKingZone) ) << 1);
                LL.and_( m, LL.sub(m,o_x1) );
            }
        }

        // Rooks
        {
            r1 = pos.psScore1[Piece.WROOK];
            if (r1 != 0) {
                nP = bMtrlPawns / this.pV;
                s = r1 * Math.min(nP, 6) / 6;
                score += s;
            }
            r1 = pos.psScore1[Piece.BROOK];
            if (r1 != 0) {
                nP = wMtrlPawns / this.pV;
                s = r1 * Math.min(nP, 6) / 6;
                score -= s;
            }
        }

        return score;
    }

    /** Implement the "when ahead trade pieces, when behind trade pawns" rule. */
    private function tradeBonus(pos:POSITION):int {
        var wM:int = pos.wMtrl;
        var bM:int = pos.bMtrl;
        var wPawn:int = pos.wMtrlPawns;
        var bPawn:int = pos.bMtrlPawns;
        var deltaScore:int = wM - bM;

        var pBonus:int = 0;
        pBonus += this.interpolate((deltaScore > 0) ? wPawn : bPawn,
                 0, (-30) * deltaScore / 100, 6 * this.pV, 0);
        pBonus += this.interpolate((deltaScore > 0) ? bM : wM,
                 0, 30 * deltaScore / 100, this.qV + (this.rV<<1) + (this.bV<<1) + (this.nV<<1), 0);

        return pBonus;
    }

    private function /*int[]*/ GenCastleFactor(sz:int):void {
		
        for (var i:int = 0; i < sz; i++) {
            var h1Dist:int = 100;
            var h1Castle:Boolean = ( (i & (1<<7)) != 0 );
            if (h1Castle)
                h1Dist = 2 + LL.bitcount( LL.and( LL.v(i), o_x60 ) ); // f1,g1
            var a1Dist:int = 100;
            var a1Castle:Boolean = ( (i & 1) != 0 );
            if (a1Castle)
                a1Dist = 2 + LL.bitcount( LL.and( LL.v(i), o_x0E ) ); // b1,c1,d1
            this.castleFactor[i] = int( 1024 / Math.min(a1Dist, h1Dist) );
        }
    }
    

    /** Score castling ability. */
    private function castleBonus(pos:POSITION):int {
        if (pos.getCastleMask() == 0) return 0;
        var q:int = (7<<3);
        var k1:int = this.kt1b[q+6] - this.kt1b[q+4];
        var k2:int = this.kt2b[q+6] - this.kt2b[q+4];
        var t1:int = this.qV + (this.rV<<1) + (this.bV<<1);
        var t2:int = this.rV;
        var t:int = pos.bMtrl - pos.bMtrlPawns;
        var ks:int = this.interpolate(t, t2, k2, t1, k1);

        var castleValue:int = ks + this.rt1b[q+5] - this.rt1b[q+7];
        if (castleValue <= 0) return 0;

        var /*long*/ occupied:i64 = LL.or( pos.whiteBB, pos.blackBB );
        var tw:uint = /*(int)*/ (occupied.l) & 0x6E;
        if (pos.a1Castle()) tw |= 1;
        if (pos.h1Castle()) tw |= (1 << 7);
        var wBonus:int = (castleValue * this.castleFactor[tw]) >> 10;

        var tb:uint = /*(int)*/ ( LL.rshift(occupied, 56).l ) & 0x6E;
        if (pos.a8Castle()) tb |= 1;
        if (pos.h8Castle()) tb |= (1 << 7);
        var bBonus:int = (castleValue * this.castleFactor[tb]) >> 10;

        return wBonus - bBonus;
    }

    private function pawnBonus(pos:POSITION):int {
        var /*long*/ key:uint = pos.pawnZobristHash();
        var phk:uint = key & 0xFFFFFF;
        if(typeof(pawnHash[phk]) == "undefined") pawnHash[phk] = new PawnHashData();
        var phd:PawnHashData = pawnHash[phk];
        if (phd.key != key) this.computePawnHashData(pos, phd);
        var score:int = phd.score;

        var hiMtrl:int = this.qV + this.rV;
        score += this.interpolate(pos.bMtrl - pos.bMtrlPawns, 0, phd.passedBonusW, hiMtrl, phd.passedBonusW << 1);
        score -= this.interpolate(pos.wMtrl - pos.wMtrlPawns, 0, phd.passedBonusB, hiMtrl, phd.passedBonusB << 1);

        // Passed pawns are more dangerous if enemy king is far away
        var mtrlNoPawns:int, kingPos:int, kingX:int, kingY:int, sq:int, x:int, y:int;
		var pawnDist:int, kingDistX:int, kingDistY:int, kingDist:int, kScore:int;
		
        var highMtrl:int = this.qV + this.rV;
        var /*long*/ m:i64;
        if ( LL.not0(phd.passedPawnsW) ) {
			m = LL.c(phd.passedPawnsW);
            mtrlNoPawns = pos.bMtrl - pos.bMtrlPawns;
            if (mtrlNoPawns < highMtrl) {
                /*int*/ kingPos = pos.getKingSq(false);
                /*int*/ kingX = Position.getX(kingPos);
                /*int*/ kingY = Position.getY(kingPos);
                while ( LL.not0(m) ) {
                    /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
                    /*int*/ x = Position.getX(sq);
                    /*int*/ y = Position.getY(sq);
                    /*int*/ pawnDist = Math.min(5, 7 - y);
                    /*int*/ kingDistX = Math.abs(kingX - x);
                    /*int*/ kingDistY = Math.abs(kingY - 7);
                    /*int*/ kingDist = Math.max(kingDistX, kingDistY);
                    /*int*/ kScore = kingDist << 2;
                    if (kingDist > pawnDist) kScore += (kingDist - pawnDist) * (kingDist - pawnDist);
                    score += this.interpolate(mtrlNoPawns, 0, kScore, highMtrl, 0);
                    if (!pos.whiteMove)
                        kingDist--;
                    if ((pawnDist < kingDist) && (mtrlNoPawns == 0))
                        score += 500; // King can't stop pawn
                    LL.and_( m, LL.sub( m, o_x1 ));
                }
            }
        }

        if ( LL.not0(phd.passedPawnsB) ) {
			m = LL.c(phd.passedPawnsB);
            mtrlNoPawns = pos.wMtrl - pos.wMtrlPawns;
            if (mtrlNoPawns < highMtrl) {
                /*int*/ kingPos = pos.getKingSq(true);
                /*int*/ kingX = Position.getX(kingPos);
                /*int*/ kingY = Position.getY(kingPos);
                while ( LL.not0(m) ) {
                    /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
                    /*int*/ x = Position.getX(sq);
                    /*int*/ y = Position.getY(sq);
                    /*int*/ pawnDist = Math.min(5, y);
                    /*int*/ kingDistX = Math.abs(kingX - x);
                    /*int*/ kingDistY = Math.abs(kingY - 0);
                    /*int*/ kingDist = Math.max(kingDistX, kingDistY);
                    /*int*/ kScore = kingDist << 2;
                    if (kingDist > pawnDist) kScore += (kingDist - pawnDist) * (kingDist - pawnDist);
                    score -= this.interpolate(mtrlNoPawns, 0, kScore, highMtrl, 0);
                    if (pos.whiteMove)
                        kingDist--;
                    if ((pawnDist < kingDist) && (mtrlNoPawns == 0))
                        score -= 500; // King can't stop pawn
                    LL.and_( m, LL.sub( m, o_x1 ));
                }
            }
        }

        return score;
    }

    /** Compute pawn hash data for pos. */
    private function computePawnHashData(pos:POSITION, ph:PawnHashData):void {
        var score:int = 0;

        // Evaluate double pawns and pawn islands
        var /*long*/ wPawns:i64 = pos.pieceTypeBB[Piece.WPAWN];
        var /*long*/ wPawnFiles:i64 = LL.and( southFill(wPawns) , o_xFF );
        var NwPawnFiles:i64 = LL.not(wPawnFiles);
        var NrwPawnFiles:i64 = LL.rshift(wPawnFiles,1);
        var N1wPawnFiles:i64 = LL.not( LL.lshift(wPawnFiles,1) );
        var N2wPawnFiles:i64 = LL.not( NrwPawnFiles );
        var /*int*/ wDouble:int = LL.bitcount(wPawns) - LL.bitcount(wPawnFiles);
        var /*int*/ wIslands:int = LL.bitcount( LL.and( NrwPawnFiles , wPawnFiles) );
        var /*int*/ wIsolated:int = LL.bitcount( LL.and(N1wPawnFiles , LL.and(wPawnFiles,N2wPawnFiles) ) );
       
        var /*long*/ bPawns:i64 = pos.pieceTypeBB[Piece.BPAWN];
        var /*long*/ bPawnFiles:i64 = LL.and( southFill(bPawns), o_xFF );
        var NbPawnFiles:i64 = LL.not(bPawnFiles);
        var NrbPawnFiles:i64 = LL.rshift(bPawnFiles,1);
        var N1bPawnFiles:i64 = LL.not( LL.lshift(bPawnFiles,1) );
        var N2bPawnFiles:i64 = LL.not( NrbPawnFiles );
        var /*int*/ bDouble:int = LL.bitcount(bPawns) - LL.bitcount(bPawnFiles);
        var /*int*/ bIslands:int = LL.bitcount( LL.and( NrbPawnFiles , bPawnFiles) );
        var /*int*/ bIsolated:int = LL.bitcount( LL.and(N1bPawnFiles , LL.and(bPawnFiles,N2bPawnFiles) ) );

        score -= (wDouble - bDouble) * 25;
        score -= (wIslands - bIslands) * 15;
        score -= (wIsolated - bIsolated) * 15;


        // Evaluate backward pawns, defined as a pawn that guards a friendly pawn,
        // can't be guarded by friendly pawns, can advance, but can't advance without 
        // being captured by an enemy pawn.
        var wP_AG:i64 = LL.and(wPawns, BitBoard.maskAToGFiles);
        var wP_BH:i64 = LL.and(wPawns, BitBoard.maskBToHFiles);

        var wP_r7_AG:i64 = LL.rshift(wP_AG,7);
        var wP_l9_AG:i64 = LL.lshift(wP_AG,9);
        var wP_r9_BH:i64 = LL.rshift(wP_BH,9);
        var wP_l7_BH:i64 = LL.lshift(wP_BH,7);


        var bP_AG:i64 = LL.and(bPawns, BitBoard.maskAToGFiles);
        var bP_BH:i64 = LL.and(bPawns, BitBoard.maskBToHFiles);

        var bP_r7_AG:i64 = LL.rshift(bP_AG,7);
        var bP_l9_AG:i64 = LL.lshift(bP_AG,9);
        var bP_r9_BH:i64 = LL.rshift(bP_BH,9);
        var bP_l7_BH:i64 = LL.lshift(bP_BH,7);

        var wbPor:i64 = LL.or(wPawns, bPawns);
        var wb_l8:i64 = LL.lshift(wbPor,8);
        var wb_r8:i64 = LL.rshift(wbPor,8);
        
        var /*long*/ wPawnAttacks:i64 = LL.or(wP_l7_BH, wP_l9_AG);
                             
        var /*long*/ bPawnAttacks:i64 = LL.or(bP_r9_BH, bP_r7_AG);

        var /*long*/ wBackward:i64 = LL.and( LL.and( wPawns, LL.not(wb_r8) ), LL.rshift(bPawnAttacks,8) );
        LL.and_( wBackward, LL.not( northFill(wPawnAttacks) ) );
        LL.and_( wBackward, LL.or( wP_r9_BH, wP_r7_AG ) );
        LL.and_( wBackward, LL.not( northFill(bPawnFiles) ) );
        
        var /*long*/ bBackward:i64 = LL.and( LL.and( bPawns, LL.not(wb_l8) ), LL.lshift(wPawnAttacks,8) );
        LL.and_( bBackward, LL.not( southFill(bPawnAttacks) ) );
        LL.and_( bBackward, LL.or( bP_l7_BH, bP_l9_AG ) );
        LL.and_( bBackward, LL.not( northFill(wPawnFiles) ) );

        score -= (LL.bitcount(wBackward) - LL.bitcount(bBackward)) * 15;

        // Evaluate passed pawn bonus, white
        var y:int, sq:int;
		var /*long*/ m:i64;
		
        var ppW:i64 = LL.or( bPawns, LL.or( bPawnAttacks, LL.rshift(wPawns, 8) ) );
		BitBoard.southFill(ppW);
        var /*long*/ passedPawnsW:i64 = LL.and( wPawns, LL.not( ppW ) );
        var /*int*/ passedBonusW:int = 0;
        if (LL.not0(passedPawnsW)) {
            var /*long*/ guardedPassedW:i64 = LL.and( passedPawnsW, LL.or( wP_l7_BH,  wP_l9_AG ) );
            passedBonusW += 15 * LL.bitcount(guardedPassedW);
            /*long*/ m = LL.c( passedPawnsW );
            while ( LL.not0(m) ) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
                /*int*/ y = Position.getY(sq);
                passedBonusW += this.ppBonus[y];
                LL.and_( m, LL.sub( m, o_x1 ));
            }
        }

        // Evaluate passed pawn bonus, black
        var ppB:i64 = LL.or( wPawns, LL.or( wPawnAttacks, LL.lshift(bPawns, 8) ) );
		BitBoard.northFill(ppB);
        var /*long*/ passedPawnsB:i64  = LL.and( bPawns, LL.not( ppB ) );
        var /*int*/ passedBonusB:int = 0;
        if (LL.not0(passedPawnsB)) {
            var /*long*/ guardedPassedB:i64 = LL.and( passedPawnsB, LL.or( bP_r9_BH,  bP_r7_AG ) );
            passedBonusB += 15 * LL.bitcount(guardedPassedB);
            /*long*/ m = LL.c( passedPawnsB );
            while ( LL.not0(m) ) {
                /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
                /*int*/ y = Position.getY(sq);
                passedBonusB += this.ppBonus[7-y];
                LL.and_( m, LL.sub( m, o_x1 ));
            }
        }

        ph.key = pos.pawnZobristHash();
        ph.score = score;
        ph.passedBonusW = passedBonusW;
        ph.passedBonusB = passedBonusB;
        ph.passedPawnsW = passedPawnsW;
        ph.passedPawnsB = passedPawnsB;
    }

    /** Compute rook bonus. Rook on open/half-open file. */
    private function rookBonus(pos:POSITION):int {
        var score:int = 0;
        var /*long*/ wPawns:i64 = pos.pieceTypeBB[Piece.WPAWN];
        var /*long*/ bPawns:i64 = pos.pieceTypeBB[Piece.BPAWN];
        var sq:int, x:int;
		var m:i64, atk:i64, r7:i64;
        var /*long*/ occupied:i64 = LL.or(pos.whiteBB, pos.blackBB);
        var Noccupied:i64 = LL.not(occupied);
        var NwhiteBB:i64 = LL.not(pos.whiteBB);
        var NblackBB:i64 = LL.not(pos.blackBB);
        /*long*/ m = LL.c( pos.pieceTypeBB[Piece.WROOK] );
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            /*int*/ x = Position.getX(sq);
            if ( LL.is0( LL.and(wPawns,BitBoard.maskFile[x]) ) ) { // At least half-open file
                score += ( LL.is0( LL.and(bPawns, BitBoard.maskFile[x]) ) ? 25 : 12 );
            }
            /*long*/ atk = BitBoard.rookAttacks(sq, occupied);
            LL.or_( this.wAttacksBB, atk );
            score += this.rookMobScore[ LL.bitcount( LL.and(atk, NwhiteBB) ) ];
            if ( LL.not0( LL.and(atk, this.bKingZone) ) )
                this.bKingAttacks += LL.bitcount( LL.and(atk, this.bKingZone) );
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        /*long*/ r7 = LL.and( pos.pieceTypeBB[Piece.WROOK], o_xFF1 );
        if (  LL.not0( LL.and(r7, LL.sub(r7,o_x1)) ) &&
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BKING], o_xFF2) )  )
            score += 20; // Two rooks on 7:th row
        m = LL.c( pos.pieceTypeBB[Piece.BROOK] );
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            /*int*/ x = Position.getX(sq);
            if ( LL.is0( LL.and(bPawns, BitBoard.maskFile[x]) ) ) {
                score -= ( LL.is0( LL.and(wPawns, BitBoard.maskFile[x]) ) ? 25 : 12 );
            }
            /*long*/ atk = BitBoard.rookAttacks(sq, occupied);
            this.bAttacksBB = LL.or( this.bAttacksBB, atk );
            score -= this.rookMobScore[ LL.bitcount( LL.and(atk, NblackBB) ) ];
            if ( LL.not0( LL.and(atk, this.wKingZone) ) )
                this.wKingAttacks += LL.bitcount( LL.and(atk, this.wKingZone) );
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        r7 = LL.and( pos.pieceTypeBB[Piece.BROOK], o_xFF3 );
        if (  LL.not0( LL.and(r7, LL.sub(r7,o_x1)) ) &&
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WKING], o_xFF4) )  )
          score -= 20; // Two rooks on 2:nd row
        return score;
    }

    /** Compute bishop evaluation. */
    private function bishopEval(pos:POSITION, oldScore:int):int {
        var score:int = 0;
        var /*long*/ occupied:i64 = LL.or(pos.whiteBB, pos.blackBB);
        var Noccupied:i64 = LL.not(occupied);
        var NwhiteBB:i64 = LL.not(pos.whiteBB);
        var NblackBB:i64 = LL.not(pos.blackBB);
        var /*long*/ wBishops:i64 = pos.pieceTypeBB[Piece.WBISHOP];
        var /*long*/ bBishops:i64 = pos.pieceTypeBB[Piece.BBISHOP];
        if ( LL.is0( LL.or(wBishops, bBishops) ) ) return 0;
		var sq:int;
        var atk:i64, m:i64;       
        /*long*/ m = LL.c( wBishops );
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            /*long*/ atk = BitBoard.bishopAttacks(sq, occupied);
            LL.or_( this.wAttacksBB, atk );
            score += this.bishMobScore[ LL.bitcount( LL.and(atk, NwhiteBB) ) ];
            if ( LL.not0( LL.and(atk, this.bKingZone) ) )
                this.bKingAttacks += LL.bitcount( LL.and(atk, this.bKingZone) );
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        m = LL.c( bBishops );
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            /*long*/ atk = BitBoard.bishopAttacks(sq, occupied);
            LL.or_( this.bAttacksBB, atk );
            score -= this.bishMobScore[ LL.bitcount( LL.and(atk, NblackBB) ) ];
            if ( LL.not0( LL.and(atk, this.wKingZone) ) )
                this.wKingAttacks += LL.bitcount( LL.and(atk, this.wKingZone) );
            LL.and_( m, LL.sub( m, o_x1 ));
        }

        var /*boolean*/  whiteDark:Boolean  = LL.not0( LL.and(pos.pieceTypeBB[Piece.WBISHOP], BitBoard.maskDarkSq ));
        var /*boolean*/  whiteLight:Boolean = LL.not0( LL.and(pos.pieceTypeBB[Piece.WBISHOP], BitBoard.maskLightSq));
        var /*boolean*/  blackDark:Boolean  = LL.not0( LL.and(pos.pieceTypeBB[Piece.BBISHOP], BitBoard.maskDarkSq ));
        var /*boolean*/  blackLight:Boolean = LL.not0( LL.and(pos.pieceTypeBB[Piece.BBISHOP], BitBoard.maskLightSq));
        var /*int*/ numWhite:int = (whiteDark ? 1 : 0) + (whiteLight ? 1 : 0);
        var /*int*/ numBlack:int = (blackDark ? 1 : 0) + (blackLight ? 1 : 0);
        var /*int*/ numPawns:int = 0;
    
        // Bishop pair bonus
        if (numWhite == 2) {
            /*int*/ numPawns = pos.wMtrlPawns / this.pV;
            score += 20 + (8 - numPawns) * 3;
        }
        if (numBlack == 2) {
            /*int*/ numPawns = pos.bMtrlPawns / this.pV;
            score -= 20 + (8 - numPawns) * 3;
        }

        // bad bishop       
        if ((numWhite == 1) && (numBlack == 1) && (whiteDark != blackDark) &&
            (pos.wMtrl - pos.wMtrlPawns == pos.bMtrl - pos.bMtrlPawns)) {
            var penalty:int = (oldScore + score) / 2;
            var loMtrl:int = this.bV << 1;
            var hiMtrl:int = (this.qV + this.rV + this.bV) << 1;
            var mtrl:int = pos.wMtrl + pos.bMtrl - pos.wMtrlPawns - pos.bMtrlPawns;
            score -= this.interpolate(mtrl, loMtrl, penalty, hiMtrl, 0);
        }

        // Penalty for bishop trapped behind pawn at a2/h2/a7/h7
        if ( LL.not0( LL.and( LL.or(wBishops, bBishops) , o_x81x ) ) ) {
            if ((pos.squares[48] == Piece.WBISHOP) && // a7
                (pos.squares[41] == Piece.BPAWN) &&
                (pos.squares[50] == Piece.BPAWN))
                score -= ((this.pV * 3)>>>1);
            if ((pos.squares[55] == Piece.WBISHOP) && // h7
                (pos.squares[46] == Piece.BPAWN) &&
                (pos.squares[53] == Piece.BPAWN))
                score -= LL.not0(pos.pieceTypeBB[Piece.WQUEEN]) ? this.pV : ((this.pV * 3)>>>1) ;
            if ((pos.squares[8] == Piece.BBISHOP) &&  // a2
                (pos.squares[17] == Piece.WPAWN) &&
                (pos.squares[10] == Piece.WPAWN))
                score += this.pV * 3 / 2;
            if ((pos.squares[15] == Piece.BBISHOP) && // h2
                (pos.squares[22] == Piece.WPAWN) &&
                (pos.squares[13] == Piece.WPAWN))
                score += LL.not0(pos.pieceTypeBB[Piece.BQUEEN]) ? this.pV : ((this.pV * 3)>>>1);
        }

        return score;
    }

    private function threatBonus(pos:POSITION):int {
        var score:int = 0;
		var sq:int, tmp:int;
        var m:i64, pawns:i64;
        // Sum values for all black pieces under attack
        /*long*/ m = LL.c( pos.pieceTypeBB[Piece.WKNIGHT] );
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            LL.or_( this.wAttacksBB, BitBoard.knightAttacks[sq] );
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        var bOr1:i64 = LL.or( pos.pieceTypeBB[Piece.BKNIGHT], pos.pieceTypeBB[Piece.BBISHOP] );
        LL.or_( bOr1, LL.or( pos.pieceTypeBB[Piece.BROOK], pos.pieceTypeBB[Piece.BQUEEN] ) );
        LL.and_( this.wAttacksBB, bOr1 );
        /*long*/ pawns = pos.pieceTypeBB[Piece.WPAWN];
        LL.or_( this.wAttacksBB, LL.lshift( LL.and(pawns, BitBoard.maskBToHFiles), 7 ) );
        LL.or_( this.wAttacksBB, LL.lshift( LL.and(pawns, BitBoard.maskAToGFiles), 9 ) );
        m = LL.and( this.wAttacksBB, LL.and( pos.blackBB, LL.not(pos.pieceTypeBB[Piece.BKING]) ) );
        /*int*/ tmp = 0;
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            tmp += this.pieceValue[pos.squares[sq]];
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        score += tmp + (tmp * tmp / this.qV);

        // Sum values for all white pieces under attack
        m = LL.c( pos.pieceTypeBB[Piece.BKNIGHT] );
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            LL.or_( this.bAttacksBB, BitBoard.knightAttacks[sq] );
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        var wOr1:i64 = LL.or( pos.pieceTypeBB[Piece.WKNIGHT], pos.pieceTypeBB[Piece.WBISHOP] );
        LL.or_( wOr1, LL.or( pos.pieceTypeBB[Piece.WROOK], pos.pieceTypeBB[Piece.WQUEEN] ) );
        LL.and_( this.bAttacksBB, wOr1 );
        pawns = pos.pieceTypeBB[Piece.BPAWN];
        LL.or_( this.bAttacksBB, LL.rshift( LL.and(pawns, BitBoard.maskBToHFiles), 9 ) );
        LL.or_( this.bAttacksBB, LL.rshift( LL.and(pawns, BitBoard.maskAToGFiles), 7 ) );
        m = LL.and( this.bAttacksBB, LL.and( pos.whiteBB, LL.not(pos.pieceTypeBB[Piece.WKING]) ) );
        tmp = 0;
        while ( LL.not0(m) ) {
            /*int*/ sq = BitBoard.numberOfTrailingZeros(m);
            tmp += this.pieceValue[pos.squares[sq]];
            LL.and_( m, LL.sub( m, o_x1 ));
        }
        score -= tmp + (tmp * tmp / this.qV);
        return (score / 64);
    }


    /** Compute king safety for both kings. */
    private function kingSafety(pos:POSITION):int {
        var minM:int = this.rV + this.bV;
        var m:int = (pos.wMtrl - pos.wMtrlPawns + pos.bMtrl - pos.bMtrlPawns) / 2;
        if (m <= minM) return 0;
        var maxM:int = this.qV + (this.rV<<1) + (this.bV<<1) + (this.nV<<1);
        var score:int = this.kingSafetyKPPart(pos);
        if (Position.getY(pos.wKingSq) == 0) {
            if ( LL.not0( LL.and(pos.pieceTypeBB[Piece.WKING], o_x60) ) && // King on f1 or g1
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WROOK], o_xC0) ) && // Rook on g1 or h1
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WPAWN], BitBoard.maskFile[6]) ) &&
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WPAWN], BitBoard.maskFile[7]) ) ) {
                score -= 90;
            } else
            if ( LL.not0( LL.and(pos.pieceTypeBB[Piece.WKING], o_x06) ) && // King on b1 or c1
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WROOK], o_x03) ) && // Rook on a1 or b1
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WPAWN], BitBoard.maskFile[0]) ) &&
                LL.not0( LL.and(pos.pieceTypeBB[Piece.WPAWN], BitBoard.maskFile[1]) ) ) {
                score -= 90;
            }
        }
        if (Position.getY(pos.bKingSq) == 7) {
            if ( LL.not0( LL.and(pos.pieceTypeBB[Piece.BKING], o_xL6)) && // King on f8 or g8
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BROOK], o_xLC)) && // Rook on g8 or h8
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BPAWN], BitBoard.maskFile[6])) &&
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BPAWN], BitBoard.maskFile[7]))) {
                score += 90;
            } else
            if ( LL.not0( LL.and(pos.pieceTypeBB[Piece.BKING], o_xLv6)) && // King on b8 or c8
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BROOK], o_xLv3)) && // Rook on a8 or b8
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BPAWN], BitBoard.maskFile[0])) &&
                LL.not0( LL.and(pos.pieceTypeBB[Piece.BPAWN], BitBoard.maskFile[1]))) {
                score += 90;
            }
        }
        score += ((this.bKingAttacks - this.wKingAttacks)<<2);
        return /*int*/ this.interpolate(m, minM, 0, maxM, score);
    }

    private function kingSafetyKPPart(pos:POSITION):int {
        var /*long*/ key:uint = pos.pawnZobristHash() ^ pos.kingZobristHash();
        var phk:uint = key & 0xFFFFFF;
        if(typeof(kingSafetyHash[phk]) == "undefined")
             kingSafetyHash[phk] = new KingSafetyHashData();
        var ksh:KingSafetyHashData = kingSafetyHash[phk];
        if (ksh.key != key) {
			var kSafety:int, safety:int, halfOpenFiles:int;
			var wOpen:i64, bOpen:i64, shelter:i64;
            var score:int = 0;
            var /*long*/ wPawns:i64 = pos.pieceTypeBB[Piece.WPAWN];
            var /*long*/ bPawns:i64 = pos.pieceTypeBB[Piece.BPAWN];
            {
                /*int*/ safety = 0;
                /*int*/ halfOpenFiles = 0;
                if (Position.getY(pos.wKingSq) < 2) {
                    /*long*/ shelter = LL.bitObj( Position.getX(pos.wKingSq) );
                    var sh1:i64 = LL.or( LL.rshift( LL.and(shelter, BitBoard.maskBToHFiles), 1) ,
                               LL.lshift( LL.and(shelter, BitBoard.maskAToGFiles), 1) );
                    shelter = LL.lshift( LL.or( shelter, sh1 ), 8 );
                    safety += 3 * LL.bitcount( LL.and( wPawns, shelter ) );
                    safety -= ( LL.bitcount( LL.and(bPawns, LL.or(shelter,LL.lshift(shelter,8)))) << 1);
                    shelter = LL.lshift( shelter, 8 );
                    safety += ( LL.bitcount( LL.and( wPawns, shelter ) ) << 1);
                    shelter = LL.lshift( shelter, 8 );
                    safety -= LL.bitcount( LL.and( bPawns, shelter ) );
                    
                    /*long*/ wOpen = LL.and( southFill(shelter),
                        LL.and( LL.not(southFill(wPawns)), o_xFF ) );
                    if ( LL.not0(wOpen) ) {
                        halfOpenFiles += 25 * LL.bitcount( LL.and(wOpen, o_xE7) );
                        halfOpenFiles += 10 * LL.bitcount( LL.and(wOpen, o_x18) );
                    }
                    /*long*/ bOpen = LL.and( southFill(shelter),
                        LL.and( LL.not(southFill(bPawns)), o_xFF ) );
                    if ( LL.not0(bOpen) ) {
                        halfOpenFiles += 25 * LL.bitcount( LL.and(bOpen, o_xE7) );
                        halfOpenFiles += 10 * LL.bitcount( LL.and(bOpen, o_x18) );
                    }
                    safety = Math.min(safety, 8);
                }
                /*int*/ kSafety = ((safety - 9) * 15) - halfOpenFiles;
                score += kSafety;
            }
            {
                /*int*/ safety = 0;
                /*int*/ halfOpenFiles = 0;
                if (Position.getY(pos.bKingSq) >= 6) {
                    /*long*/ shelter = LL.bitObj( 56 + Position.getX(pos.bKingSq) );
                    var sh2:i64 = LL.or( LL.rshift( LL.and(shelter, BitBoard.maskBToHFiles), 1) ,
                               LL.lshift( LL.and(shelter, BitBoard.maskAToGFiles), 1) );
                    shelter = LL.rshift( LL.or( shelter, sh2 ), 8 );
                    safety += 3 * LL.bitcount( LL.and(bPawns, shelter) );
                    safety -= ( LL.bitcount( LL.and(wPawns, LL.or(shelter,LL.rshift(shelter,8)))) << 1);
                    shelter = LL.rshift( shelter, 8 );
                    safety += 2 * LL.bitcount( LL.and(bPawns, shelter) );
                    shelter = LL.rshift( shelter, 8 );
                    safety -= LL.bitcount( LL.and(wPawns, shelter) );

                    /*long*/ wOpen = LL.and( southFill(shelter),
                        LL.and( LL.not(southFill(wPawns)), o_xFF ) );
                    if ( LL.not0(wOpen) ) {
                        halfOpenFiles += 25 * LL.bitcount( LL.and(wOpen, o_xE7) );
                        halfOpenFiles += 10 * LL.bitcount( LL.and(wOpen, o_x18) );
                    }
                    /*long*/ bOpen = LL.and( southFill(shelter),
                        LL.and( LL.not(southFill(bPawns)), o_xFF ) );
                    if ( LL.not0(bOpen) ) {
                        halfOpenFiles += 25 * LL.bitcount( LL.and(bOpen, o_xE7) );
                        halfOpenFiles += 10 * LL.bitcount( LL.and(bOpen, o_x18) );
                    }
                    safety = Math.min(safety, 8);
                }
                /*int*/ kSafety = ((safety - 9) * 15) - halfOpenFiles;
                score -= kSafety;
            }
            ksh.key = key;
            ksh.score = score;
        }
        return ksh.score;
    }

    /** Implements special knowledge for some endgame situations. */
    private function endGameEval(pos:POSITION, oldScore:int):int {
        var score:int = oldScore;
        if (pos.wMtrl + pos.bMtrl > 6 * this.rV) return score;
        var wMtrlPawns:int = pos.wMtrlPawns;
        var bMtrlPawns:int = pos.bMtrlPawns;
        var wMtrlNoPawns:int = pos.wMtrl - wMtrlPawns;
        var bMtrlNoPawns:int = pos.bMtrl - bMtrlPawns;
		var kSq:int, x:int, y:int;
		
        var handled:Boolean = false;
        if ((wMtrlPawns + bMtrlPawns == 0) && (wMtrlNoPawns < this.rV) && (bMtrlNoPawns < this.rV)) {
            // King + minor piece vs king + minor piece is a draw
            return 0;
        }
		var wk:int, wq:int, bk:int, bq:int, wp:int, bp:int;
		
        if (!handled && (pos.wMtrl == this.qV) && (pos.bMtrl == this.pV) &&
            (LL.bitcount(pos.pieceTypeBB[Piece.WQUEEN]) == 1)) {
            wk = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.WKING]);
            wq = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.WQUEEN]);
            bk = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.BKING]);
            bp = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.BPAWN]);
            score = this.evalKQKP(wk, wq, bk, bp);
            handled = true;
        }
        if (!handled && (pos.bMtrl == this.qV) && (pos.wMtrl == this.pV) && 
            (LL.bitcount(pos.pieceTypeBB[Piece.BQUEEN]) == 1)) {
            bk = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.BKING]);
            bq = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.BQUEEN]);
            wk = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.WKING]);
            wp = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.WPAWN]);
            score = -this.evalKQKP(63-bk, 63-bq, 63-wk, 63-wp);
            handled = true;
        }
        if (!handled && (score > 0)) {
            if ((wMtrlPawns == 0) && (wMtrlNoPawns <= bMtrlNoPawns + this.bV)) {
                if (wMtrlNoPawns < this.rV) {
                    return -pos.bMtrl / 50;
                } else {
                    score /= 8;         // Too little excess material, probably draw
                    handled = true;
                }
            } else if ( LL.not0( LL.or(pos.pieceTypeBB[Piece.WROOK], LL.or( pos.pieceTypeBB[Piece.WKNIGHT],
                        pos.pieceTypeBB[Piece.WQUEEN])) ) ) {
                // Check for rook pawn + wrong color bishop
                if ( LL.is0( LL.and(pos.pieceTypeBB[Piece.WPAWN], BitBoard.maskBToHFiles)) &&
                    LL.is0( LL.and(pos.pieceTypeBB[Piece.WBISHOP], BitBoard.maskLightSq)) &&
                    LL.not0( LL.and(pos.pieceTypeBB[Piece.BKING], o_x0303 )) ) {
                    return 0;
                } else
                if ( LL.is0( LL.and(pos.pieceTypeBB[Piece.WPAWN], BitBoard.maskAToGFiles)) &&
                    LL.is0( LL.and(pos.pieceTypeBB[Piece.WBISHOP], BitBoard.maskDarkSq)) &&
                    LL.not0( LL.and(pos.pieceTypeBB[Piece.BKING], o_xC0C0 )) ) {
                    return 0;
                }
            }
        }
        if (!handled) {
            if (bMtrlPawns == 0) {
                if (wMtrlNoPawns - bMtrlNoPawns > this.bV) {
                    var wKnights:int = LL.bitcount(pos.pieceTypeBB[Piece.WKNIGHT]);
                    var wBishops:int = LL.bitcount(pos.pieceTypeBB[Piece.WBISHOP]);
                    if ((wKnights == 2) && (wMtrlNoPawns == 2 * this.nV) && (bMtrlNoPawns == 0)) {
                        score /= 50;    // KNNK is a draw
                    } else if ((wKnights == 1) && (wBishops == 1) &&
                             (wMtrlNoPawns == this.nV + this.bV) && (bMtrlNoPawns == 0)) {
                        score /= 10;
                        score += this.nV + this.bV + 300;
                        kSq = pos.getKingSq(false);
                        x = Position.getX(kSq);
                        y = Position.getY(kSq);
                        if ( LL.not0( LL.and(pos.pieceTypeBB[Piece.WBISHOP], BitBoard.maskDarkSq))) {
                            score += (7 - this.distToH1A8[7-y][7-x]) * 10;
                        } else {
                            score += (7 - this.distToH1A8[7-y][x]) * 10;
                        }
                    } else {
                        score += 300;       // Enough excess material, should win
                    }
                    handled = true;
                } else if ((wMtrlNoPawns + bMtrlNoPawns == 0) && (wMtrlPawns == this.pV)) { // KPK
                    var wp_:int = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.WPAWN]);
                    score = this.kpkEval(pos.getKingSq(true), pos.getKingSq(false),
                                    wp_, pos.whiteMove);
                    handled = true;
                }
            }
        }
        if (!handled && (score < 0)) {
            if ((bMtrlPawns == 0) && (bMtrlNoPawns <= wMtrlNoPawns + this.bV)) {
                if (bMtrlNoPawns < this.rV) {
                    return pos.wMtrl / 50;
                } else {
                    score /= 8;         // Too little excess material, probably draw
                    handled = true;
                }
            } else if ( LL.not0( LL.or(pos.pieceTypeBB[Piece.BROOK], LL.or( pos.pieceTypeBB[Piece.BKNIGHT],
                        pos.pieceTypeBB[Piece.BQUEEN])) ) ) {     
                // Check for rook pawn + wrong color bishop
                if ( LL.is0( LL.and(pos.pieceTypeBB[Piece.BPAWN], BitBoard.maskBToHFiles)) &&
                    LL.is0( LL.and(pos.pieceTypeBB[Piece.BBISHOP], BitBoard.maskDarkSq)) &&
                    LL.not0( LL.and(pos.pieceTypeBB[Piece.WKING], o_xLv0303 )) ) {
                    return 0;
                } else
                if ( LL.is0( LL.and(pos.pieceTypeBB[Piece.BPAWN], BitBoard.maskAToGFiles)) &&
                    LL.is0( LL.and(pos.pieceTypeBB[Piece.BBISHOP], BitBoard.maskLightSq)) &&
                    LL.not0( LL.and(pos.pieceTypeBB[Piece.WKING], o_xLvC0C0 )) ) {
                    return 0;
                }
            }
        }
        if (!handled) {
            if (wMtrlPawns == 0) {
                if (bMtrlNoPawns - wMtrlNoPawns > this.bV) {
                    var bKnights:int = LL.bitcount(pos.pieceTypeBB[Piece.BKNIGHT]);
                    var bBishops:int = LL.bitcount(pos.pieceTypeBB[Piece.BBISHOP]);
                    if ((bKnights == 2) && (bMtrlNoPawns == 2 * this.nV) && (wMtrlNoPawns == 0)) {
                        score /= 50;    // KNNK is a draw
                    } else if ((bKnights == 1) && (bBishops == 1) &&
                             (bMtrlNoPawns == this.nV + this.bV) && (wMtrlNoPawns == 0)) {
                        score /= 10;
                        score -= this.nV + this.bV + 300;
                        kSq = pos.getKingSq(true);
                        x = Position.getX(kSq);
                        y = Position.getY(kSq);
                        if ( LL.not0( LL.and(pos.pieceTypeBB[Piece.BBISHOP], BitBoard.maskDarkSq))) {
                            score -= (7 - this.distToH1A8[7-y][7-x]) * 10;
                        } else {
                            score -= (7 - this.distToH1A8[7-y][x]) * 10;
                        }
                    } else {
                        score -= 300;       // Enough excess material, should win
                    }
                    handled = true;
                } else if ((wMtrlNoPawns + bMtrlNoPawns == 0) && (bMtrlPawns == this.pV)) { // KPK
                    var bp_:int = BitBoard.numberOfTrailingZeros(pos.pieceTypeBB[Piece.BPAWN]);
                    score = -this.kpkEval(63-pos.getKingSq(false), 63-pos.getKingSq(true),
                                     63-bp_, !pos.whiteMove);
                    handled = true;
                }
            }
        }
        return score;
    }

    private function evalKQKP( wKing:int, wQueen:int, bKing:int, bPawn:int ):int {
        var canWin:Boolean = false;
        
        if ( LL.is0( LL.and( LL.bitObj(bKing), o_xFFFF) ) ) {
            canWin = true; // King doesn't support pawn
        } else if (Math.abs(Position.getX(bPawn) - Position.getX(bKing)) > 2) {
            canWin = true; // King doesn't support pawn
        } else {
            var bi1:i64 = LL.bitObj(wKing);
            switch (bPawn) {
            case 8:  // a2
                canWin = LL.not0( LL.and(bi1,o_xKxZ1) );
                break;
            case 10: // c2
                canWin = LL.not0( LL.and(bi1,o_xKxZ2) );
                break;
            case 13: // f2
                canWin = LL.not0( LL.and(bi1,o_xKxZ3) );
                break;
            case 15: // h2
                canWin = LL.not0( LL.and(bi1,o_xKxZ4) );
                break;
            default:
                canWin = true;
                break;
            }
        }

        var dist:int = Math.max(Math.abs(Position.getX(wKing)-Position.getX(bPawn)),
                                  Math.abs(Position.getY(wKing)-Position.getY(bPawn)));
        var score:int = this.qV - this.pV - (20 * dist);
        if (!canWin)
            score /= 50;
        return score;
    }

    private function kpkEval( wKing:int, bKing:int, wPawn:int, whiteMove:Boolean ):int {
        if (Position.getX(wKing) >= 4) { // Mirror X
            wKing ^= 7;
            bKing ^= 7;
            wPawn ^= 7;
        }
        var ix:int = (whiteMove ? 0 : 1);
        ix = (ix<<5) + (Position.getY(wKing)<<2)+Position.getX(wKing);
        ix = (ix<<6) + bKing;
        ix = (ix*48) + wPawn - 8;

        var bytePos:int = ix>>>3;
        var bitPos:int = ix % 8;
		var KpkIs:Boolean = bytePos < this.Kpk.BitBase.length;
        var draw:Boolean = false;
		if( KpkIs ) draw = ((this.Kpk.BitBase[bytePos] & (1 << bitPos)) == 0);
        if (draw) return 0;
        return (this.qV - ((this.pV>>2) * (7-Position.getY(wPawn))));
    }

    /**
     * Interpolate between (x1,y1) and (x2,y2).
     * If x < x1, return y1, if x > x2 return y2. Otherwise, use linear interpolation.
     */
    private function interpolate( x:int, x1:int, y1:int, x2:int, y2:int ):int {
        if (x > x2) return y2;
        else if (x < x1) return y1;
        else return (x - x1) * (y2 - y1) / (x2 - x1) + y1;
    }

	private function southFill(a:i64):i64
	{ var a2:i64 = LL.c(a); BitBoard.southFill(a2); return a2; }
		
	private function northFill(a:i64):i64
	{ var a2:i64 = LL.c(a);	BitBoard.northFill(a2);	return a2; }
	
	}
}