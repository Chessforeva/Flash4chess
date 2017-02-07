package
{
	public class SEARCHTYPE
	{
        public var line:MLINE;					/*  best line at next ply  */
        public var capturesearch:Boolean = false;		/*  indicates capture search  */
        public var maxval:int = 0;				/*  maximal evaluation returned in search */
        public var nextply:int = 0;				/*  Depth of search at next ply  */
        public var next:INFTYPE;				/* information at Next ply  */
        public var zerowindow:Boolean = false;			/*  Zero-width alpha-beta-window  */
        public var movgentype:int = 0;
		
		public function SEARCHTYPE( len:int )	/*MAXPLY + 2*/
		{
			line = new MLINE(len);
			next = new INFTYPE();
		}
				
	}
}