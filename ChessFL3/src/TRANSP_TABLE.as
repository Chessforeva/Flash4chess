package
{
	public class TRANSP_TABLE
	{
	private var /*TTEntry[]*/ table:Array = [];
    private var /*TTEntry*/ emptySlot:TTEntry = new TTEntry();
    private var /*byte*/ generation:int = 0;
    private var /*long*/ stores:int = 0;
    private var /*long*/ hits:int = 0;
	
	private var MoveGen:MOVEGEN = Main.MoveGen;
	private var TextIO:TEXTIO = Main.TextIO;

	public function clone():TRANSP_TABLE { return new TRANSP_TABLE(); }
	
    public function insert( key:uint, sm:MOVE, Stype:int, ply:int,
                 depth:int, evalScore:int ):void {
        if (depth < 0) depth = 0;
        var idx0:uint = this.h0(key);
        var idx1:uint = this.h1(key);
        var ent:TTEntry = this.table[idx0];
        var hashSlot:int = 0;
        if (ent.key != key) {
            ent = this.table[idx1];
            hashSlot = 1;
            this.stores++;
        }
        if (ent.key != key) {
            if (this.table[idx1].betterThan(this.table[idx0], this.generation)) {
                ent = this.table[idx0];
                hashSlot = 0;
                this.stores++;
            }
            if (ent.valuable(this.generation)) {
                var altEntIdx:uint = (ent.getHashSlot() == 0) ? this.h1(ent.key) : this.h0(ent.key);
                if (ent.betterThan(this.table[altEntIdx], this.generation)) {
                    var altEnt:TTEntry = this.table[altEntIdx];
                    altEnt.key = ent.key;
                    altEnt.move = ent.move;
                    altEnt.score = ent.score;
                    altEnt.depthSlot = ent.depthSlot;
                    altEnt.generation = ent.generation;
                    altEnt.Stype = ent.Stype;
                    altEnt.setHashSlot(1 - ent.getHashSlot());
                    altEnt.evalScore = ent.evalScore;
                }
            }
        }
        var doStore:Boolean = true;
        if ((ent.key == key) && (ent.getDepth() > depth) && (ent.Stype == Stype)) {
            if (Stype == emptySlot.T_EXACT) {
                doStore = false;
            } else if ((Stype == emptySlot.T_GE) && (sm.score <= ent.score)) {
                doStore = false;
            } else if ((Stype == emptySlot.T_LE) && (sm.score >= ent.score)) {
                doStore = false;
            }
        }
        if (doStore) {
            if ((ent.key != key) || (sm.from != sm.to))
                ent.setMove(sm);
            ent.key = key;
            ent.setScore(sm.score, ply);
            ent.setDepth(depth);
            ent.generation = this.generation;
            ent.Stype = Stype;
            ent.setHashSlot(hashSlot);
            ent.evalScore = evalScore;
        }
    }

    /** Retrieve an entry from the hash table corresponding to "pos". */
    public function probe( key:uint ):TTEntry {
        var idx0:uint = this.h0(key);
        var ent:TTEntry = this.table[idx0];
        if (ent.key == key)
            {
             this.hits++;
             return ent;
            }
        var idx1:uint = this.h1(key);
        ent = this.table[idx1];
        if (ent.key == key)
            {
             this.hits++;
             return ent;
            }
        return this.emptySlot;
    }

    /**
     * Increase hash table generation. This means that subsequent inserts will be considered
     * more valuable than the entries currently present in the hash table.
     */
    public function nextGeneration():void {  this.generation++; }

    /** Clear the transposition table. */
    public function clearTable():void {
        //for(var i=0; i<this.table.length; i++ ) this.table[i].Stype = TTEntry.T_EMPTY;
        this.table = [];
        this.stores = 0;
        this.hits = 0;
    }

    /**
     * Extract a list of PV moves, starting from "rootPos" and first move "mv".
     */
    public function /*ArrayList<Move>*/ extractPVMoves( rootPos:POSITION, mv:MOVE ):Array {
        var pos:POSITION = rootPos.clone();
        var m:MOVE = new MOVE( mv.from, mv.to, mv.promoteTo, mv.score );
        var /*ArrayList<Move>*/ ret:Array = [];   /*new ArrayList<Move>() */
        var ui:UNDOINFO = new UNDOINFO();
        var /*List<Long>*/ hashHistory:Array = [];    /* new ArrayList<Long>() */
        while (true) {
            ret.push(m);
            pos.makeMove(m, ui);

            if (ArrContains( hashHistory, pos.zobristHash())) break;

            hashHistory.push(pos.zobristHash());
            var ent:TTEntry = this.probe(pos.historyHash());
            if (ent.Stype == emptySlot.T_EMPTY) break;
            m = new MOVE(0,0,0,0);
            ent.getMove(m);
            
            var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
            MoveGen.removeIllegal(pos, moves);      

            var containz:Boolean = false;
            for (var mi:int = 0; mi < moves.size; mi++)
                if (m.equalsMove(moves.m[mi])) {
                    containz = true;
                    break;
                }
            if (!containz) break;
        }
        return ret;
    }

    /** Extract the PV starting from pos, using hash entries, both exact scores and bounds. */
    public function extractPV( posx:POSITION ):String {
        var ret:String = "";
        var pos:POSITION = posx.clone();    // To afunction modifying the input parameter
        var first:Boolean = true;
        var ent:TTEntry = this.probe(pos.historyHash());
        var ui:UNDOINFO = new UNDOINFO();
        var /*ArrayList<Long>*/ hashHistory:Array = [];   /*new ArrayList<Long>()*/
        var repetition:Boolean = false;
        while (ent.Stype != emptySlot.T_EMPTY) {
            var Ztype:String = "";
            if (ent.Stype == emptySlot.T_LE) {
                Ztype = "<";
            } else if (ent.Stype == emptySlot.T_GE) {
                Ztype = ">";
            }
            var m:MOVE = new MOVE(0,0,0,0);
            ent.getMove(m);
            var moves:MoveList = MoveGen.pseudoLegalMoves(pos);
            MoveGen.removeIllegal(pos, moves);
            var containz:Boolean = false;
            for (var mi:int = 0; mi < moves.size; mi++)
                if (m.equalsMove(moves.m[mi])) {
                    containz = true;
                    break;
                }
            if  (!containz) break;
            var moveStr:String = TextIO.moveToString(pos, m, false);
            if (repetition) break;
            if (!first) ret+=" ";
            ret += Ztype + moveStr;
            pos.makeMove(m, ui);

            if (ArrContains( hashHistory, pos.zobristHash())) repetition = true;

            hashHistory.push(pos.zobristHash());
            ent = this.probe(pos.historyHash());
            first = false;
        }
        return ret;
    }

    /** Print hash table statistics. */
    public function printStats():void {
        var unused:int = 0;
        var thisGen:int = 0;
        var s:String="Hash stats ";
        s+="stores: " + this.stores.toString();
        s+=", hits: " + this.hits.toString();
        trace(s);
    }
    
    private function h0( key:uint ):uint {
        var tk:uint = (key >>> 0) & 0xFFFFFF;
        if(typeof(this.table[tk]) == "undefined") this.table[tk]= new TTEntry();
        return tk;
    }
    private function h1( key:uint ):uint {
        var tk:uint = (key >>> 1) & 0xFFFFFF;
        if(typeof(this.table[tk]) == "undefined") this.table[tk]= new TTEntry();
        return tk;
    }
    	
	private function ArrContains( arr:Array, val:uint ):Boolean {
		for (var i:int=0; i<arr.length; i++) if (arr[i] == val) return true;
		return false;
	}

	}
}