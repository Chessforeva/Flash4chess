package
{
	public class trans_t extends Object
	{
	    public var table :Array = [];        // entry_t*
	    public var size:int = 0;             // uint32
	    public var mask:int = 0;             // uint32
	    public var date:int = 0;             // int
	    public var age :Array = [];          // int[DateSize]
	    public var used:int = 0;             // uint32
	    public var read_nb:int = 0;          // sint64
	    public var read_hit:int = 0;         // sint64
	    public var write_nb:int = 0;         // sint64
	    public var write_hit:int = 0;        // sint64
	    public var write_collision:int = 0;  // sint64
	}
}