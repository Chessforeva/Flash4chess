package
{
	public class search_input_t extends Object
	{
	    public var board:board_t = new board_t();          // board_t[1]
	    public var list:list_t = new list_t();            // list_t[1]
	    public var infinite:Boolean = false;           // bool
	    public var depth_is_limited:Boolean = false;   // bool
	    public var depth_limit:int = 0;            // int
	    public var time_is_limited:Boolean = false;    // bool
	    public var time_limit_1:Number = 0.0;         // double
	    public var time_limit_2:Number = 0.0;         // double
	}
}