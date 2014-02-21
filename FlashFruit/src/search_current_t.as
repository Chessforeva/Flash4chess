package
{
	public class search_current_t extends Object
	{
	    public var board:board_t = new board_t();       // board_t[1]
	    public var timer:my_timer_t = new my_timer_t();    // my_timer_t[1]
	    public var mate:int = 0;         // int
	    public var depth:int = 0;        // int
	    public var max_depth:int = 0;    // int
	    public var node_nb:int = 0;      // sint64
	    public var time:Number = 0.0;       // double
	    public var speed:Number = 0.0;      // double
	}
}