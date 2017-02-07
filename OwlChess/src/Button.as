package
{
	public class Button
	{
		public var I:int = 0;		// picture index to know which action
		public var x1:int = 0;		// left top corner (x,y)
		public var y1:int = 0;
		public var x2:int = 0;		// right bottom (x,y)
		public var y2:int = 0;
		
		public function Button(i:int, x:int, y:int, dx:int, dy:int):void
			{
				I = i;
				x1 = x;
				y1 = y;
				x2 = x + dx - 1;
				y2 = y + dy - 1;
			}
		
	}
}