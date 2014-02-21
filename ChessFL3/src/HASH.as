package
{
	public class HASH
	{
	public var /*long[]*/ psHashKeys:Array = new Array();		// [piece][square]
    public var /*long*/ whiteHashKey:uint = 0;
    public var /*long[]*/ castleHashKeys:Array = new Array();  // [castleMask]
    public var /*long[]*/ epHashKeys:Array = new Array();      // [epFile + 1] (epFile==-1 for no ep)
    public var /*long[]*/ moveCntKeys:Array = new Array();     // [min(halfMoveClock, 100)]
    
	private var Piece:PIECE = Main.Piece;
		
    public function initHash():void
    {
        var rndNo:int = 0;
        for (var p:int = 0; p < Piece.nPieceTypes; p++) {
            this.psHashKeys[p] = new Array();
            for (var sq:int= 0; sq < 64; sq++) {
                this.psHashKeys[p][sq] = this.getRandomHashVal(rndNo++);
            }
        }
        this.whiteHashKey = this.getRandomHashVal(rndNo++);
        for (var cm:int = 0; cm < 16; cm++)
            this.castleHashKeys[cm] = this.getRandomHashVal(rndNo++);
        for (var f:int = 0; f < 9; f++)
            this.epHashKeys[f] = this.getRandomHashVal(rndNo++);
        for (var mc:int = 0; mc < 101; mc++)
            this.moveCntKeys[mc] = this.getRandomHashVal(rndNo++);
    }

    private /*long*/ function getRandomHashVal(rndNo:int):uint {
        var rr:uint = 0;
        for(var i:int=0;i<6;i++)
            rr = (rr << 8) | (( Math.floor(Math.random()*256)+rndNo) % 256 );
        return rr;
	}
	
	}
}