package
{
	public class MLINE
	{
		public var a:Array = [];
		
		public function MLINE( len:int )	/*MAXPLY + 2*/
		{
			var i:int = 0;
			while ((i++) < len)
				a.push( new MOVETYPE() );
		}
	}
}