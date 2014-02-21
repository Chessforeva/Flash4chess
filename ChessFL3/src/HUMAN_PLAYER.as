package
{
	public class HUMAN_PLAYER extends PLAYER
	{
	
	public override function clone ():PLAYER { return new HUMAN_PLAYER(); }

    /*@Override*/
    public override function getCommand ( pos:POSITION, drawOffer:Boolean ):String
    {
		var mv:String = Main.moveTo;	// get, clear and execute
		if(mv.length>0) Main.moveTo = "";
		return mv;
	}
    
    /*@Override*/
    public override function isHumanPlayer():Boolean { return true; }
    
    /*@Override*/
	public override function useBook( bookOn:Boolean ):void {}

    /*@Override*/
    public override function timeLimit( minTimeLimit:Number, maxTimeLimit:Number, randomMode:Boolean ):void {}
		
    /*@Override*/
    public override function clearTT():void {}
	}
}