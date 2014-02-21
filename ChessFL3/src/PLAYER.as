package
{
	public class PLAYER
	{
	public function clone ():PLAYER { return new PLAYER();  }

    /*@Override*/
    public function getCommand ( pos:POSITION, drawOffer:Boolean ):String
      { return ""; /* just do nothing */ }
    
    /*@Override*/
    public function isHumanPlayer():Boolean { return true; }
    
    /*@Override*/
	public function useBook( bookOn:Boolean ):void {}

    /*@Override*/
    public function timeLimit( minTimeLimit:Number, maxTimeLimit:Number, randomMode:Boolean ):void {}
		
    /*@Override*/
    public function clearTT():void {}
	}
}