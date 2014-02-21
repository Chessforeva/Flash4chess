package
{
	public class pawn_info_t extends Object
	{
	    public var lock:int = 0;                // uint32
	    public var opening:int = 0;             // sint16
	    public var endgame:int = 0;             // sint16
	    public var flags :Array = [ 0, 0 ];        // uint8[ColourNb]
	    public var passed_bits :Array = [ 0, 0 ];  // uint8[ColourNb]
	    public var single_file :Array = [ 0, 0 ];  // uint8[ColourNb]
	    public var pad:int = 0;                 // uint16
	}
}