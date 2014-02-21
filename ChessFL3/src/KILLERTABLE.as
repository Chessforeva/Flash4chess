package
{
	public class KILLERTABLE
	{
	private var /*KTEntry[]*/ ktList:Array = [];

    /** Create an empty killer table. */
    public function Init1():void {
        for (var i:int = 0; i < 200; i++) this.ktList.push( new KTEntry() );
    }
	
    public function clone():KILLERTABLE {
		var KT:KILLERTABLE = new KILLERTABLE();
		KT.ktList = this.ktList.slice();
		return KT;
    }
            
    /** Add a killer move to the table. Moves are replaced on an LRU basis. */
    public function addKiller(ply:int, m:MOVE):void {
        if (ply >= this.ktList.length) return;
        var move:uint = (m.from + (m.to << 6) + (m.promoteTo << 12));
        var ent:KTEntry = this.ktList[ply];
        if (move != ent.move0) {
            ent.move1 = ent.move0;
            ent.move0 = move;
        }
    }

    /**
     * Get a score for move m based on hits in the killer table.
     * The score is 4 for primary   hit at ply.
     * The score is 3 for secondary hit at ply.
     * The score is 2 for primary   hit at ply - 2.
     * The score is 1 for secondary hit at ply - 2.
     * The score is 0 otherwise.
     */
    public function getKillerScore(ply:int,m:MOVE):int {
        var move:uint = (m.from + (m.to << 6) + (m.promoteTo << 12));
        var ent:KTEntry;
        if (ply < this.ktList.length) {
            ent = this.ktList[ply];
            if (move == ent.move0) return 4;
            else if (move == ent.move1) return 3;
        }
        if ((ply - 2 >= 0) && (ply - 2 < this.ktList.length)) {
            ent = this.ktList[ply - 2];
            if (move == ent.move0) return 2;
            else if (move == ent.move1) return 1;
        }
        return 0;
    }

	}
}