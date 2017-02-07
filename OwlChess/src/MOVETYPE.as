package
{
	public class MOVETYPE
	{
        public var nw1:int = 0;		/*  new square  */
        public var old:int = 0;		/*  old square  */
        public var spe:int = 0;		/*  Indicates special move:
                                 case movepiece of
                                  king: castling
                                  pawn: e.p. capture
                                  else : pawn promotion  */

        public var movpiece:int = 0;	/* moving piece */
        public var content:int = 0;	/* evt. captured piece  */

		// sets values same
		public function copyMove(m:MOVETYPE):void
			{
			nw1 = m.nw1; old = m.old; spe = m.spe;
			movpiece = m.movpiece; content = m.content;
			}
	}

}