package
{
	public class board_t extends Object
	{

	    public var square :Array = [ 0, 0 ];  // int[SquareNb]
	    public var pos :Array = [ 0, 0 ];     // int[SquareNb]

	    public var piece :Array = [[0],[0]];   // int[ColourNb][32] only 17 are needed

	    public var piece_size :Array = [ 0, 0 ];  // int[ColourNb]

	    public var pawn :Array = [[0],[0]];       // int[ColourNb][16] only 9 are needed

	    public var pawn_size :Array = [ 0, 0 ];  // int[ColourNb]

	    public var piece_nb:int = 0;   // int
	    public var number :Array = [];    // int[16] only 12 are needed

	    public var pawn_file :Array = [[0],[0]]; // int[ColourNb][FileNb];

	    public var turn:int = 0;       // int
	    public var flags:int = 0;      // int
	    public var ep_square:int = 0;  // int
	    public var ply_nb:int = 0;     // int
	    public var sp:int = 0;         // int  TODO: MOVE ME?

	    public var cap_sq:int = 0;     // int

	    public var opening:int = 0;    // int
	    public var endgame:int = 0;    // int

	    public var key:int = 0;           // uint64
	    public var pawn_key:int = 0;      // uint64
	    public var material_key:int = 0;  // uint64

	    public var stack :Array = [];        // uint64[StackSize];
	    public var movenumb:int = 0;     // int

	}
}