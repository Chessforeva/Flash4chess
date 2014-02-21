package
{
	public class BookEntry
	{
	    public var move:MOVE;
	    public var moveStr:String;
	    public var count:int;
		
		public function BookEntry( move:MOVE, moveStr:String ) {
            this.move = move;
            this.moveStr = moveStr;
            this.count = 1;
		}
	}
}