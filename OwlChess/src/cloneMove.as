package
{
	public class cloneMove extends MOVETYPE
	{
		// generates new move, also sets same values
		public function cloneMove(m:MOVETYPE)
			{
			nw1 = m.nw1; old = m.old; spe = m.spe;
			movpiece = m.movpiece; content = m.content;
			}
	}

}