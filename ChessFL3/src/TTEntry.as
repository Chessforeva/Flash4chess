package
{
	public class TTEntry
	{
        public var /*long*/ key:uint = 0;		// Zobrist hash key
        public var /*short*/ move:uint = 0;	// from + (to<<6) + (promote<<12)
        public var /*short*/ score:int = 0;	// Score from search
        public var /*short*/ depthSlot:uint = 0;  // Search depth (bit 0-14) and hash slot (bit 15).
        public var /*byte*/ generation:uint = 0;  // Increase when OTB position changes
        public var /*byte*/ Stype:int = 3;       // exact score, lower bound, upper bound (T_EMPTY)
        public var /*short*/ evalScore:int = 0; // Score from evaluation 
        
        public const T_EXACT:int = 0;   // Exact score
        public const T_GE:int = 1;      // True score >= this.score
        public const T_LE:int = 2;      // True score <= this.score
        public const T_EMPTY:int = 3;   // Empty hash slot
        
		private var Search:SEARCH = Main.Search;
			
        /** Return true if this object is more valuable than the other, false otherwise. */
        public function betterThan( other:TTEntry, currGen:int ):Boolean {
            if ((this.generation == currGen) != (other.generation == currGen)) {
                return this.generation == currGen;   // Old entries are less valuable
            }
            if ((this.Stype == this.T_EXACT) != (other.Stype == this.T_EXACT)) {
                return this.Stype == this.T_EXACT;         // Exact score more valuable than lower/upper bound
            }
            if (this.getDepth() != other.getDepth()) {
                return this.getDepth() > other.getDepth();     // Larger depth is more valuable
            }
            return false;   // Otherwise, pretty much equally valuable
        }

        /** Return true if entry is good enough to spend extra time trying to afunction overwriting it. */
        public function  valuable( currGen:int ):Boolean {
            if (this.generation != currGen)
                return false;
            return (this.Stype == this.T_EXACT) || (this.getDepth() > 3 * Search.plyScale);
        }

        public function getMove( m:MOVE ):void {
            m.from = this.move & 63;
            m.to = (this.move >>> 6) & 63;
            m.promoteTo = (this.move >>> 12) & 15;
        }
        
        public function setMove( m:MOVE ):void {
            this.move = (m.from + (m.to << 6) + (m.promoteTo << 12));
        }
        
        /** Get the score from the hash entry, and convert from "mate in x" to "mate at ply". */
        public function getScore( ply:int ):int {
            var sc:int = this.score;
            if (sc > Search.MATE0 - 1000) {
                sc -= ply;
            } else if (sc < -(Search.MATE0 - 1000)) {
                sc += ply;
            }
            return sc;
        }
        
        /** Convert score from "mate at ply" to "mate in x", and store in hash entry. */
        public function setScore( score:int, ply:int ):void {
            if (score > Search.MATE0 - 1000) {
                score += ply;
            } else if (score < -(Search.MATE0 - 1000)) {
                score -= ply;
            }
            this.score = score;
        }

        /** Get depth from the hash entry. */
        public function getDepth():int {
            return this.depthSlot & 0x7fff;
        }

        /** Set depth. */
        public function setDepth( d:int ):void {
            this.depthSlot &= 0x8000;
            this.depthSlot |= d & 0x7fff;
        }

        public function getHashSlot():int {
            return this.depthSlot >>> 15;
        }

        public function setHashSlot( s:int ):void {
            this.depthSlot &= 0x7fff;
            this.depthSlot |= (s << 15);
        }

	}
}