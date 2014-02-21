package
{
	public class material_t extends Object
	{
	    public var table :Array = [];        // entry_t*
	    public var size:int = 0;             // uint32
	    public var mask:int = 0;             // uint32
	    public var used:int = 0;             // uint32

	    public var read_nb:int = 0;          // sint64
	    public var read_hit:int = 0;         // sint64
	    public var write_nb:int = 0;         // sint64
	    public var write_collision:int = 0;  // sint64
	}
}