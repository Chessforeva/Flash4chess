package
{
	public class HISTORY
	{
    private var /*int[]*/ countSuccess:Array = [];
    private var /*int[]*/ countFail:Array = [];
    private var /*int[]*/ score:Array = [];
	
	private var Piece:PIECE = Main.Piece;
		
    public function clone():HISTORY {
		var HS:HISTORY = new HISTORY();
		for (var p:int = 0; p < Piece.nPieceTypes; p++) {
            HS.countSuccess.push( this.countSuccess[p].slice() );
            HS.countFail.push( this.countFail[p].slice() );
            HS.score.push( this.score[p].slice() );
        }
		return HS;
    }
            
    public function creaHistory():void {
        for (var p:int = 0; p < Piece.nPieceTypes; p++) {
            this.countSuccess.push( new Array() );
            this.countFail.push( new Array() );
            this.score.push( new Array() );
            for (var sq:int = 0; sq < 64; sq++) {
                this.countSuccess[p][sq] = 0;
                this.countFail[p][sq] = 0;
                this.score[p][sq] = -1;
            }
        }
    }

    /** Record move as a success. */
    public function addSuccess( pos:POSITION, m:MOVE,  depth:int ):void {
        var p:int = pos.getPiece(m.from);
        var cnt:int = depth;
        var val:int = this.countSuccess[p][m.to] + cnt;
        if (val > 1000) { val /= 2; this.countFail[p][m.to] /= 2; }
        this.countSuccess[p][m.to] = val;
        this.score[p][m.to] = -1;
    }

    /** Record move as a failure. */
    public function addFail( pos:POSITION, m:MOVE,  depth:int ):void {
        var p:int = pos.getPiece(m.from);
        var cnt:int = depth;
        this.countFail[p][m.to] += cnt;
        this.score[p][m.to] = -1;
    }

    /** Get a score between 0 and 49, depending of the success/fail ratio of the move. */
    public function getHistScore( pos:POSITION, m:MOVE ):int {
        var p:int = pos.getPiece(m.from);
        var ret:int = this.score[p][m.to];
        if (ret >= 0) return ret;
        var succ:int = this.countSuccess[p][m.to];
        var fail:int = this.countFail[p][m.to];
        if (succ + fail > 0) {
            ret = succ * 49 / (succ + fail);
        } else {
            ret = 0;
        }
        this.score[p][m.to] = ret;
        return ret;
    }

	}
}