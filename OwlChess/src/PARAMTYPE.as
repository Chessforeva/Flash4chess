package
{
	public class PARAMTYPE
	{
		public var alpha:int = 0;
		public var beta:int = 0;
		public var ply:int = 0;
		public var inf:INFTYPE; 
		public var bestline: MLINE;
		public var S:SEARCHTYPE;
		
		public function PARAMTYPE( len:int )	/*MAXPLY + 2*/
		{
			S = new SEARCHTYPE(len);
			inf = new INFTYPE();
		}
	}
}