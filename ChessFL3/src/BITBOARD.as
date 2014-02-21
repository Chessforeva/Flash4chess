package
{
	public class BITBOARD
	{
	// creates new object 
	private var LL:INT64 = Main.LL;
	private var Position:POSITION = Main.Position;

    public var InitWas1:Boolean = false;
	public var InitWas2:Boolean = false;
		
	public function Init1():void
		{
		trace("InitKNpAttacks");
		InitKNpAttacks();
		trace("InitRookRays 1.part of 2");
		InitRookRays(1);
		this.InitWas1 = true;
		}
	public function Init2():void
		{
		trace("InitRookRays 2.part of 2");
		InitRookRays(2);
		trace("InitBishopRays");
		InitBishopRays();
		trace("Init_squaresBetween");
		Init_squaresBetween();
		trace("Init OK");
		this.InitWas2 = true;
		}
	
    /** Squares attacked by a king on a given square. */
    public var /*long[]*/ kingAttacks:Array = [];
    public var /*long[]*/ knightAttacks:Array = [];
    public var /*long[]*/ wPawnAttacks:Array = [];
    public var /*long[]*/ bPawnAttacks:Array = [];

    /* Squares preventing a pawn from being a passed pawn, if occupied by enemy pawn */
    public var /*long[]*/ wPawnBlockerMask:Array = [];
	public var /*long[]*/ bPawnBlockerMask:Array = [];

	public var /*long*/ maskAToGFiles:i64 = LL.s("0x7F7F7F7F7F7F7F7FL");
	public var /*long*/ maskBToHFiles:i64 = LL.s("0xFEFEFEFEFEFEFEFEL");
	public var /*long*/ maskAToFFiles:i64 = LL.s("0x3F3F3F3F3F3F3F3FL");
	public var /*long*/ maskCToHFiles:i64 = LL.s("0xFCFCFCFCFCFCFCFCL");

	public var /*long[]*/ maskFile:Array = [
        LL.s("0x0101010101010101L"),
        LL.s("0x0202020202020202L"),
        LL.s("0x0404040404040404L"),
        LL.s("0x0808080808080808L"),
        LL.s("0x1010101010101010L"),
        LL.s("0x2020202020202020L"),
        LL.s("0x4040404040404040L"),
        LL.s("0x8080808080808080L")
    ];

    public var /*long*/ maskRow1:i64 = LL.s("0x00000000000000FFL");
    public var /*long*/ maskRow2:i64 = LL.s("0x000000000000FF00L");
    public var /*long*/ maskRow3:i64 = LL.s("0x0000000000FF0000L");
    public var /*long*/ maskRow4:i64 = LL.s("0x00000000FF000000L");
    public var /*long*/ maskRow5:i64 = LL.s("0x000000FF00000000L");
	public var /*long*/ maskRow6:i64 = LL.s("0x0000FF0000000000L");
    public var /*long*/ maskRow7:i64 = LL.s("0x00FF000000000000L");
    public var /*long*/ maskRow8:i64 = LL.s("0xFF00000000000000L");
	public var /*long*/ maskRow1Row8:i64 = LL.s("0xFF000000000000FFL");

    public var /*long*/ maskDarkSq:i64 = LL.s("0xAA55AA55AA55AA55L");
    public var /*long*/ maskLightSq:i64 = LL.s("0x55AA55AA55AA55AAL");

    public var /*long*/ maskCorners:i64 = LL.s("0x8100000000000081L");

    public var /*long[]*/ rTables:Array = [];
    public var /*long[]*/ rMasks:Array = [];
    public var /*int[]*/ rBits:Array = [ 12, 11, 11, 11, 11, 11, 11, 12,
                                         11, 10, 10, 10, 10, 10, 10, 11,
                                         11, 10, 10, 10, 10, 10, 10, 11,
                                         11, 10, 10, 10, 10, 10, 10, 11,
                                         11, 10, 10, 10, 10, 10, 10, 11,
                                         11, 10, 10, 10, 10, 10, 10, 11,
                                         10,  9,  9,  9,  9,  9, 10, 10,
                                         11, 10, 10, 10, 10, 11, 11, 11 ];
    public var /*long[]*/ rMagics:Array = [
        LL.s("0x0080011084624000L"), LL.s("0x1440031000200141L"), LL.s("0x2080082004801000L"), LL.s("0x0100040900100020L"),
        LL.s("0x0200020010200408L"), LL.s("0x0300010008040002L"), LL.s("0x040024081000a102L"), LL.s("0x0080003100054680L"),
        LL.s("0x1100800040008024L"), LL.s("0x8440401000200040L"), LL.s("0x0432001022008044L"), LL.s("0x0402002200100840L"),
        LL.s("0x4024808008000400L"), LL.s("0x100a000410820008L"), LL.s("0x8042001144020028L"), LL.s("0x2451000041002082L"),
        LL.s("0x1080004000200056L"), LL.s("0xd41010c020004000L"), LL.s("0x0004410020001104L"), LL.s("0x0000818050000800L"),
        LL.s("0x0000050008010010L"), LL.s("0x0230808002000400L"), LL.s("0x2000440090022108L"), LL.s("0x0488020000811044L"),
        LL.s("0x8000410100208006L"), LL.s("0x2000a00240100140L"), LL.s("0x2088802200401600L"), LL.s("0x0a10100180080082L"),
        LL.s("0x0000080100110004L"), LL.s("0x0021002300080400L"), LL.s("0x8400880400010230L"), LL.s("0x2001008200004401L"),
        LL.s("0x0000400022800480L"), LL.s("0x00200040e2401000L"), LL.s("0x4004100084802000L"), LL.s("0x0218800800801002L"),
        LL.s("0x0420800800800400L"), LL.s("0x002a000402001008L"), LL.s("0x0e0b000401008200L"), LL.s("0x0815908072000401L"),
        LL.s("0x1840008002498021L"), LL.s("0x1070122002424000L"), LL.s("0x1040200100410010L"), LL.s("0x0600080010008080L"),
        LL.s("0x0215001008010004L"), LL.s("0x0000020004008080L"), LL.s("0x1300021051040018L"), LL.s("0x0004040040820001L"),
        LL.s("0x48fffe99fecfaa00L"), LL.s("0x48fffe99fecfaa00L"), LL.s("0x497fffadff9c2e00L"), LL.s("0x613fffddffce9200L"),
        LL.s("0xffffffe9ffe7ce00L"), LL.s("0xfffffff5fff3e600L"), LL.s("0x2000080281100400L"), LL.s("0x510ffff5f63c96a0L"),
        LL.s("0xebffffb9ff9fc526L"), LL.s("0x61fffeddfeedaeaeL"), LL.s("0x53bfffedffdeb1a2L"), LL.s("0x127fffb9ffdfb5f6L"),
        LL.s("0x411fffddffdbf4d6L"), LL.s("0x0005000208040001L"), LL.s("0x264038060100d004L"), LL.s("0x7645fffecbfea79eL"),
    ];

    public var /*long[]*/ bTables:Array = [];
    public var /*long[]*/ bMasks:Array = [];
    public var /*int[]*/ bBits:Array = [ 5, 4, 5, 5, 5, 5, 4, 5,
                                         4, 4, 5, 5, 5, 5, 4, 4,
                                         4, 4, 7, 7, 7, 7, 4, 4,
                                         5, 5, 7, 9, 9, 7, 5, 5,
                                         5, 5, 7, 9, 9, 7, 5, 5,
                                         4, 4, 7, 7, 7, 7, 4, 4,
                                         4, 4, 5, 5, 5, 5, 4, 4,
                                         5, 4, 5, 5, 5, 5, 4, 5 ];
    public var /*long[]*/ bMagics:Array = [
        LL.s("0xffedf9fd7cfcffffL"), LL.s("0xfc0962854a77f576L"), LL.s("0x9010210041047000L"), LL.s("0x52242420800c0000L"),
        LL.s("0x884404220480004aL"), LL.s("0x0002080248000802L"), LL.s("0xfc0a66c64a7ef576L"), LL.s("0x7ffdfdfcbd79ffffL"),
        LL.s("0xfc0846a64a34fff6L"), LL.s("0xfc087a874a3cf7f6L"), LL.s("0x02000888010a2211L"), LL.s("0x0040044040801808L"),
        LL.s("0x0880040420000000L"), LL.s("0x0000084110109000L"), LL.s("0xfc0864ae59b4ff76L"), LL.s("0x3c0860af4b35ff76L"),
        LL.s("0x73c01af56cf4cffbL"), LL.s("0x41a01cfad64aaffcL"), LL.s("0x1010000200841104L"), LL.s("0x802802142a006000L"),
        LL.s("0x0a02000412020020L"), LL.s("0x0000800040504030L"), LL.s("0x7c0c028f5b34ff76L"), LL.s("0xfc0a028e5ab4df76L"),
        LL.s("0x0020082044905488L"), LL.s("0xa572211102080220L"), LL.s("0x0014020001280300L"), LL.s("0x0220208058008042L"),
        LL.s("0x0001010000104016L"), LL.s("0x0005114028080800L"), LL.s("0x0202640000848800L"), LL.s("0x040040900a008421L"),
        LL.s("0x400e094000600208L"), LL.s("0x800a100400120890L"), LL.s("0x0041229001480020L"), LL.s("0x0000020080880082L"),
        LL.s("0x0040002020060080L"), LL.s("0x1819100100c02400L"), LL.s("0x04112a4082c40400L"), LL.s("0x0001240130210500L"),
        LL.s("0xdcefd9b54bfcc09fL"), LL.s("0xf95ffa765afd602bL"), LL.s("0x008200222800a410L"), LL.s("0x0100020102406400L"),
        LL.s("0x80a8040094000200L"), LL.s("0x002002006200a041L"), LL.s("0x43ff9a5cf4ca0c01L"), LL.s("0x4bffcd8e7c587601L"),
        LL.s("0xfc0ff2865334f576L"), LL.s("0xfc0bf6ce5924f576L"), LL.s("0x0900420442088104L"), LL.s("0x0062042084040010L"),
        LL.s("0x01380810220a0240L"), LL.s("0x0000101002082800L"), LL.s("0xc3ffb7dc36ca8c89L"), LL.s("0xc3ff8a54f4ca2c89L"),
        LL.s("0xfffffcfcfd79edffL"), LL.s("0xfc0863fccb147576L"), LL.s("0x0050009040441000L"), LL.s("0x00139a0000840400L"),
        LL.s("0x9080000412220a00L"), LL.s("0x0000002020010a42L"), LL.s("0xfc087e8e4bb2f736L"), LL.s("0x43ff9e4ef4ca2c89L"),
    ];

    public var /*byte*/ dirTable:Array =
     [ -9,   0,   0,   0,   0,   0,   0,  -8,   0,   0,   0,   0,   0,   0,  -7,
        0,   0,  -9,   0,   0,   0,   0,   0,  -8,   0,   0,   0,   0,   0,  -7,   0,
        0,   0,   0,  -9,   0,   0,   0,   0,  -8,   0,   0,   0,   0,  -7,   0,   0,
        0,   0,   0,   0,  -9,   0,   0,   0,  -8,   0,   0,   0,  -7,   0,   0,   0,
        0,   0,   0,   0,   0,  -9,   0,   0,  -8,   0,   0,  -7,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,  -9, -17,  -8, -15,  -7,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0, -10,  -9,  -8,  -7,  -6,   0,   0,   0,   0,   0,
        0,  -1,  -1,  -1,  -1,  -1,  -1,  -1,   0,   1,   1,   1,   1,   1,   1,   1,
        0,   0,   0,   0,   0,   0,   6,   7,   8,   9,  10,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   0,   7,  15,   8,  17,   9,   0,   0,   0,   0,   0,
        0,   0,   0,   0,   0,   7,   0,   0,   8,   0,   0,   9,   0,   0,   0,   0,
        0,   0,   0,   0,   7,   0,   0,   0,   8,   0,   0,   0,   9,   0,   0,   0,
        0,   0,   0,   7,   0,   0,   0,   0,   8,   0,   0,   0,   0,   9,   0,   0,
        0,   0,   7,   0,   0,   0,   0,   0,   8,   0,   0,   0,   0,   0,   9,   0,
        0,   7,   0,   0,   0,   0,   0,   0,   8,   0,   0,   0,   0,   0,   0,   9  ];

 
    public var /*int*/ trailingZ:Array = 
      [ 63,  0, 58,  1, 59, 47, 53,  2,
        60, 39, 48, 27, 54, 33, 42,  3,
        61, 51, 37, 40, 49, 18, 28, 20,
        55, 30, 34, 11, 43, 14, 22,  4,
        62, 57, 46, 52, 38, 26, 32, 41,
        50, 36, 17, 19, 29, 10, 13, 21,
        56, 45, 25, 31, 35, 16,  9, 12,
        44, 24, 15,  8, 23,  7,  6,  5 ];

    public var /*long[]*/ squaresBetween:Array = []; 

	// BitBoard functions

	public function numberOfTrailingZeros (mask:i64):int {

	return LL.bitlowestat(mask);

	/* original */
        return trailingZ[ LL.rshift(  LL.mul( LL.and(mask, LL.neg(mask)) ,
         LL.ax(0x07EDD5E5,0x9A4E28C2) ) , 58).l ];
    }

	public function getDirection (from:int, to:int):int {
        var offs:int = to + (to|7) - from - (from|7) + 0x77;
        return dirTable[offs];
    }

	public function southFill (mask:i64):void {
        LL.or_(mask, LL.rshift(mask,8));
        LL.or_(mask, LL.rshift(mask,16));
        LL.or_(mask, LL.rshift(mask,32));
    }
    
	public function northFill (mask:i64):void {
        LL.or_(mask, LL.lshift(mask,8));
        LL.or_(mask, LL.lshift(mask,16));
        LL.or_(mask, LL.lshift(mask,32));
    }

	private function InitRookRays(ch:int):void
    {
     // Rook magics
       for (var sq:int = ((ch-1)*32) /* from 0 or 32 */; sq < (ch*32); sq++) {
			var x:int = Position.getX(sq);
            var y:int = Position.getY(sq);
            rMasks[sq] = addRookRays(x, y, new i64(), true);
            var tableSize:int = 1 << rBits[sq];
            rTables[sq] = new Array();		
            var /*long[]*/ table:Array = rTables[sq];	/*new long[tableSize]*/
            for (var i:int = 0; i < tableSize; i++) table[i] = LL.ax( 0xFFFFFFFF, 0xFFFFFFFF );
            var nPatterns:int = 1 << LL.bitcount(rMasks[sq]) /*Long.bitCount()*/;
            for (i = 0; i < nPatterns; i++) {
                var p:i64 = createPattern(i, rMasks[sq]);
                var entry:uint = LL.rshift( LL.mul(p,rMagics[sq]), (64 - rBits[sq])).l;
                if ( table[entry].h == 0xFFFFFFFF ) table[entry] = addRookRays(x, y, p, false);
            }
        }
    }

	private function InitBishopRays():void
    {
     // Bishop magics     
       for (var sq:int = 0; sq < 64; sq++) {
            var x:int = Position.getX(sq);
            var y:int = Position.getY(sq);
            bMasks[sq] = addBishopRays(x, y, new i64(), true);
            var tableSize:int = 1 << bBits[sq];
            bTables[sq] = new Array();
            var /*long[]*/ table:Array = bTables[sq];	/*new long[tableSize]*/
            for (var i:int = 0; i < tableSize; i++) table[i] = LL.ax( 0xFFFFFFFF, 0xFFFFFFFF );
            var nPatterns:int = 1 << LL.bitcount(bMasks[sq]) /*Long.bitCount()*/;
            for (i = 0; i < nPatterns; i++) {
                var p:i64 = createPattern(i, bMasks[sq]);
                var entry:uint = LL.rshift( LL.mul(p,bMagics[sq]), (64 - bBits[sq])).l;
                if ( table[entry].h == 0xFFFFFFFF ) table[entry] = addBishopRays(x, y, p, false);
            }
        }       
    }

	public function bishopAttacks(sq:int, occupied:i64):i64 {
        return bTables[sq][ LL.rshift(LL.mul( LL.and(occupied,bMasks[sq]) ,
             bMagics[sq]), (64 - bBits[sq])).l ];
    }


	public function rookAttacks (sq:int, occupied:i64):i64 {
        return rTables[sq][ LL.rshift(LL.mul( LL.and(occupied,rMasks[sq]) ,
             rMagics[sq]), (64 - rBits[sq])).l ];
    }

	private function InitKNpAttacks():void
    {
		var m:i64, m1:i64, m2:i64, m3:i64, m4:i64;
     
        // Compute king attacks
        for (var sq:int = 0; sq < 64; sq++) {
            m = LL.bitObj(sq);
            m1 = LL.or( LL.rshift(m,1), LL.lshift(m,7) );
            m1 = LL.and( LL.or( m1, LL.rshift(m,9) ), maskAToGFiles );
            m2 = LL.or( LL.lshift(m,1), LL.lshift(m,9) );
            m2 = LL.and( LL.or( m2, LL.rshift(m,7) ), maskBToHFiles );
            m3 = LL.or( LL.lshift(m,8), LL.rshift(m,8) );                 
            kingAttacks[sq] = LL.or( m1, LL.or( m2, m3 ) );
        }

        // Compute knight attacks
        for (sq = 0; sq < 64; sq++) {
            m = LL.bitObj(sq);
            m1 = LL.and( LL.or( LL.lshift(m,6), LL.rshift(m,10) ), maskAToFFiles );
            m2 = LL.and( LL.or( LL.lshift(m,15), LL.rshift(m,17) ), maskAToGFiles );
            m3 = LL.and( LL.or( LL.lshift(m,17), LL.rshift(m,15) ), maskBToHFiles );
            m4 = LL.and( LL.or( LL.lshift(m,10), LL.rshift(m,6) ), maskCToHFiles );           
            knightAttacks[sq] = LL.or( m1, LL.or( m2, LL.or( m3, m4 ) ) );
        }

        // Compute pawn attacks       
        for (sq = 0; sq < 64; sq++) {
            m = LL.bitObj(sq);
            m1 = LL.and( LL.lshift(m,7), maskAToGFiles );
            m2 = LL.and( LL.lshift(m,9), maskBToHFiles );
            wPawnAttacks[sq] = LL.or( m1, m2 );
            m1 = LL.and( LL.rshift(m,9), maskAToGFiles );
            m2 = LL.and( LL.rshift(m,7), maskBToHFiles );            
            bPawnAttacks[sq] =  LL.or( m1, m2 );
            
            var x:int = Position.getX(sq);
            var y:int = Position.getY(sq);
            m = new i64();
            for (var y2:int = y+1; y2 < 8; y2++) {
                if (x > 0) LL.or_( m, LL.bitObj( Position.getSquare(x-1, y2) ) );
                           LL.or_( m, LL.bitObj( Position.getSquare(x  , y2) ) );
                if (x < 7) LL.or_( m, LL.bitObj( Position.getSquare(x+1, y2) ) );
            }
            wPawnBlockerMask[sq] = LL.c(m);
            m = new i64();
            for (y2 = y-1; y2 >= 0; y2--) {
                if (x > 0) LL.or_( m, LL.bitObj( Position.getSquare(x-1, y2) ) );
                           LL.or_( m, LL.bitObj( Position.getSquare(x  , y2) ) );
                if (x < 7) LL.or_( m, LL.bitObj( Position.getSquare(x+1, y2) ) );
            }
            bPawnBlockerMask[sq] = LL.c(m);
        }
    }

	private function Init_squaresBetween():void
    {
        for (var sq1:int = 0; sq1 < 64; sq1++) {
            squaresBetween[sq1] = new Array(); /*new long[64]*/
            for (var j:int = 0; j < 64; j++)
                squaresBetween[sq1][j] = new i64();
            for (var dx:int = -1; dx <= 1; dx++) {
                for (var dy:int = -1; dy <= 1; dy++) {
                    if ((dx != 0) || (dy != 0))
                    {
                        var m:i64 = new i64();
                        var x:int = Position.getX(sq1);
                        var y:int = Position.getY(sq1);
                        while (true) {
                            x += dx; y += dy;
                            if ((x < 0) || (x > 7) || (y < 0) || (y > 7)) break;
                            var sq2:int = Position.getSquare(x, y);
                            squaresBetween[sq1][sq2] = LL.c(m);
                            LL.or_( m, LL.bitObj(sq2) );
                        }
                    }
                }
            }
        }
    }

	private function createPattern ( i:int, mask:i64 ):i64 {
        var ret:i64 = new i64();
        for (var j:int = 0; ;j++) {
            var nextMask:i64 = LL.and( mask , LL.sub(mask,LL.one));
            var bit:i64 = LL.xor( mask , nextMask);
            if ((i & (1 << j)) != 0) LL.or_( ret, bit );
            mask = nextMask;
            if (mask.l == 0 && mask.h == 0) break;
        }
        return ret;
    }
    
	private function addRookRays (x:int, y:int, occupied:i64, inner:Boolean):i64 {
        var mask:i64 = new i64();
        addRay(mask, x, y,  1,  0, occupied, inner);
        addRay(mask, x, y, -1,  0, occupied, inner);
        addRay(mask, x, y,  0,  1, occupied, inner);
        addRay(mask, x, y,  0, -1, occupied, inner);
        return mask;
    }

	private function addBishopRays (x:int, y:int, occupied:i64, inner:Boolean):i64 {
        var mask:i64 = new i64();
        addRay(mask, x, y,  1,  1, occupied, inner);
        addRay(mask, x, y, -1, -1, occupied, inner);
        addRay(mask, x, y,  1, -1, occupied, inner);
        addRay(mask, x, y, -1,  1, occupied, inner);
        return mask;
    }

	private function addRay ( mask:i64, x:int, y:int, dx:int, dy:int, 
                                     occupied:i64, inner:Boolean):void {
        var lo:int = (inner ? 1 : 0 );
        var hi:int = (inner ? 6 : 7 );
        while (true) {
            if (dx != 0) {
                x += dx; if ((x < lo) || (x > hi)) break;
            }
            if (dy != 0) {
                y += dy; if ((y < lo) || (y > hi)) break;
            }
            var sq:int = Position.getSquare(x, y);
            var sq2:i64 = LL.bitObj(sq);
            LL.or_( mask, sq2 );
            var q:i64 = LL.and(occupied ,sq2);
            if (q.l!=0 || q.h!=0) break;
        }

    }


	}
}
 
