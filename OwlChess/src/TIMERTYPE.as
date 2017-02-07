package
{
	public class TIMERTYPE
	{
		public var started:int = 0;
		public var elapsed:int = 0;
		
		public function gettime():Number
			{
			return (new Date()).getTime();
			}
	
		public function timesecs():int
			{
			return ((new Date()).getTime() / 1000 );
			}
		
		public function Tick():void
			{
			elapsed = timesecs() - started;
			}
	
		public function InitTime():void
		{
			started = timesecs();
			elapsed = 0;
		}
		
	}
}