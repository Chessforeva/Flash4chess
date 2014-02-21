package
{
	public class GAMESTATE
	{
        public const ALIVE:int = 0;
        public const WHITE_MATE:int = 1;         // White mates
        public const BLACK_MATE:int = 2;         // Black mates
        public const WHITE_STALEMATE:int = 3;    // White is stalemated
        public const BLACK_STALEMATE:int = 4;    // Black is stalemated
        public const DRAW_REP:int = 5;           // Draw by 3-fold repetition
        public const DRAW_50:int = 6;            // Draw by 50 move rule
        public const DRAW_NO_MATE:int = 7;       // Draw by impossibility of check mate
        public const DRAW_AGREE:int = 8;         // Draw by agreement
        public const RESIGN_WHITE:int = 9;       // White resigns
        public const RESIGN_BLACK:int = 10;      // Black resigns
	}
}