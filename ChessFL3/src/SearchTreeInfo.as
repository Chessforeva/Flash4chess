package
{
	public class SearchTreeInfo
	{
        public var undoInfo:UNDOINFO = new UNDOINFO();
        public var hashMove:MOVE = new MOVE(0, 0, 0, 0);	// Temporary storage for local hashMove variable
        public var allowNullMove:Boolean = true;			// Don't allow two null-moves in a row
        public var bestMove:MOVE = new MOVE(0, 0, 0, 0);	// Copy of the best found move at this ply
        public var currentMove:MOVE = new MOVE(0, 0, 0, 0);	// Move currently being searched
        public var lmr:int = 0;			// LMR reduction amount
        public var nodeIdx:int = 0; 
	}
}