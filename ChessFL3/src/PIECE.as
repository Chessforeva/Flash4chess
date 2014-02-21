package
{
	public class PIECE
	{
		/* Constants for different piece types */

	    public const EMPTY:int = 0;
		public const WKING:int = 1;
		public const WQUEEN:int = 2;
		public const WROOK:int = 3;
		public const WBISHOP:int = 4;
		public const WKNIGHT:int = 5;
		public const WPAWN:int = 6;
		public const BKING:int = 7;
		public const BQUEEN:int = 8;
		public const BROOK:int = 9;
		public const BBISHOP:int = 10;
		public const BKNIGHT:int = 11;
		public const BPAWN:int = 12;

		public const nPieceTypes:int = 13;

		/**
		* Return true if p is a white piece, false otherwise.
		* Note that if p is EMPTY, an unspecified value is returned.
		*/
		
		public function isWhite(pType:int):Boolean
		{
			return pType < this.BKING;
		}
		
		public function makeWhite(pType:int):int
		{
			return pType < this.BKING ? pType : pType - (this.BKING - this.WKING);
		}
    	public function makeBlack(pType:int):int
		{
			return ((pType > this.EMPTY) && (pType < this.BKING)) ?
				pType + (this.BKING - this.WKING) : pType;
		}
	}
}