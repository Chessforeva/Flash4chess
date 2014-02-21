package
{
	public class MOVE
	{
		public var from:int = 0;
		public var to:int = 0;
		public var promoteTo:int = 0;
		public var score:int = 0;
		
		//public var movestr:String = "";
		//private var TextIO:TEXTIO = Main.TextIO;
		
		public function MOVE(from:int, to:int, promoteTo:int, score:int):void {
			this.from = from;
			this.to = to;
			this.promoteTo = promoteTo;
			this.score = score;
			
			// good for debugs but slow
			//this.movestr = TextIO.moveToUCIString(this);
		}
  
    /*public*/ /*class*/ /*SortByScore implements Comparator<Move> */
		public function MoveCompare( withmove:MOVE ):int {
            return withmove.score - this.score;
		}
    
    /** Note that score is not included in the comparison. */
    /*@Override*/
		public function equalsMove(other:MOVE):Boolean {
        if (this.from != other.from)
            return false;
        if (this.to != other.to)
            return false;
        if (this.promoteTo != other.promoteTo)
            return false;
        return true;
		}
	
	}
}