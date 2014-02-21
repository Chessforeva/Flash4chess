package
{
	public class material_info_t extends Object
	{
	    public var lock:int = 0;	         // uint32
	    public var recog:int = 0;            // uint8
	    public var flags:int = 0;            // uint8
	    public var cflags :Array = [ 0, 0 ]; // uint8[ColourNb]
	    public var mul :Array = [ 0, 0 ];    // uint8[ColourNb]
	    public var phase:int = 0;         // sint16
	    public var opening:int = 0;       // sint16
	    public var endgame:int = 0;       // sint16
	}
}