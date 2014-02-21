package
{
	public class sort_t extends Object
	{
	    public var depth:int = 0;         // int
	    public var height:int = 0;        // int
	    public var trans_killer:int = 0;  // int
	    public var killer_1:int = 0;      // int
	    public var killer_2:int = 0;      // int
	    public var gen:int = 0;           // int
	    public var test:int = 0;          // int
	    public var pos:int = 0;           // int
	    public var value:int = 0;         // int
	    public var board :board_t = new board_t();        // board_t *
	    public var attack:attack_t = new attack_t();      // const attack_t *
	    public var list:list_t = new list_t();   // list_t[1]
	    public var bad:list_t = new list_t();    // list_t[1]
	}
}