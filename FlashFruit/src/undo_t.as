package
{
	public class undo_t extends Object
	{
	    public var capture:Boolean = false;   // bool

	    public var capture_square:int = 0;  // int
	    public var capture_piece:int = 0;   // int
	    public var capture_pos:int = 0;     // int

	    public var pawn_pos:int = 0;        // int

	    public var turn:int = 0;      // int
	    public var flags:int = 0;     // int
	    public var ep_square:int = 0; // int
	    public var ply_nb:int = 0;    // int

	    public var cap_sq:int = 0;    // int

	    public var opening:int = 0;   // int
	    public var endgame:int = 0;   // int

	    public var key:int = 0;           // uint64
	    public var pawn_key:int = 0;      // uint64
	    public var material_key:int = 0;  // uint64
	}
}