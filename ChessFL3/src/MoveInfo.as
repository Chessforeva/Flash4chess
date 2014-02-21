package
{
	public class MoveInfo
	{
	    public var move:MOVE;
	    public var nodes:int;
		
		public function MoveInfo( m:MOVE, n:int ):void {
          this.move = m;
          this.nodes = n;
		}
	}
}