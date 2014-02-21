package
{
	public class PawnHashData
	{
        public var /*long*/ key:uint = 0;
        public var /*int*/ score:int = 0;         // Positive score means good for white
        public var /*short*/ passedBonusW:int = 0;
        public var /*short*/ passedBonusB:int = 0;
        public var /*long*/ passedPawnsW:i64 = new i64();     // The most advanced passed pawns for each file
        public var /*long*/ passedPawnsB:i64 = new i64();
	}
}