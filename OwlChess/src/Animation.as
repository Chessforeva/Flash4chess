package
{
	public class Animation
	{
		public var active:Boolean = false;
		
		public var I:int;		// drawable piece
		public var tick:int = 0;
		public var move:MOVETYPE;
		public var x:int;		// current position (x,y)
		public var y:int;
		
		public var x_from:int;		// from (x,y)
		public var y_from:int;
		
		public var x_to:int;		// to (x,y)
		public var y_to:int;
		
		public var dx:Number;		// delta x,y for a step
		public var dy:Number;
		public var tcnt:int;		// amount to tick
		
		public var bgpixels:Array;
		
		public var delay:int = 0;	// to pause after animation
		
		public function start( m:MOVETYPE, i:int, xpos:int, ypos:int, xto:int, yto:int ):void
			{
				active = true;
				I = i;
				tick = 0;
				move = new cloneMove(m);
				
				x_from = xpos; y_from = ypos;
				x = x_from; y = y_from;
				x_to = xto; y_to = yto;
				
				dx = (x_to - x); dy = (y_to - y);
				tcnt =  Math.max(Math.abs(dx),Math.abs(dy))>>4;
				dx /= tcnt; dy /= tcnt;
				
				bgpixels = [];
			}
			
		public function step():void
			{
				tick++;
				if (tick < tcnt)
					{
					x = x_from + (dx * tick);
					y = y_from + (dy * tick);
					}
				else if (tick == tcnt)
					{
					x = x_to; y = y_to;
					active = false;			// stop animation
					}
			}
	}
}