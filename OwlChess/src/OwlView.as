/*
main() for OwlChess project ,
(flash inits, mouse events,...)

see GUI.as, all the graphics and chess routes
*/

package
{
	// AS3 only, no Flex RIA that makes large swf
	import flash.events.*;
	import flash.ui.Mouse;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;
	import flash.utils.Timer;

 	[SWF(backgroundColor="0x669966")]

    /**
     * Sample class to draw squares and arrows between them.
     */
    public class OwlView extends Sprite
    {
        /**
         * Initialize the scene as soon as we can.
         */
		
		public var gui:GUI;				// object of GUI (everything is here)
		public var chess:OwlChess;		// object of OwlChess
		public var book:OwlBook;		// object of OwlBook
		
		public var bitmap:Bitmap		// screen picture
		public var smcons:TextField;	// small console on screen
		public var smpgn:TextField;		// small pgn-console on screen
		
		public var Tsd:TextField;		// text for depth on screen
		public var Tst:TextField;		// text for time.sec. on screen
		
		public var timer:Timer = new Timer(1000);
		
	public function OwlView()
		{
		if (stage) init();
		else addEventListener(Event.ADDED_TO_STAGE, init);
		}

	private function init(e:Event=null):void
		{
		if(hasEventListener(Event.ADDED_TO_STAGE))
		 removeEventListener(Event.ADDED_TO_STAGE, init);
		
		chess = new OwlChess();
		//chess.printboard();
		//trace(chess.GenMovesStr());
		//trace(chess.Comment());
		//trace(chess.FindOpeningMove());
		//trace(chess.FindMove());

		gui = new GUI();
		gui.chess = chess;
		
		book = new OwlBook();
		while (book.Openings.length < book.total)
			book.Openings.push(0);			// add 0s
		chess.Openings = book.Openings;
		
		defScreen();
						
		stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		stage.addEventListener(Event.RESIZE, onResize);
		
		timer.addEventListener(TimerEvent.TIMER, onTimer);
		timer.start();
		timer.delay = 10; 
		}
		
	private function onResize(e:Event):void
	{
		removeChild(bitmap);
		removeChild(smcons);
		removeChild(smpgn);
		removeChild(Tsd);
		removeChild(Tst);
		defScreen();		// redefine
	}

	// On first load and resizing, the new scaling takes place
	private function defScreen():void
		{
		gui.Height = stage.stageHeight;
		gui.Width = stage.stageWidth;
		gui.resize();

		//create a new Bitmap instance using the BitmapData
		bitmap = new Bitmap(gui.bmpData);
		addChild(bitmap);
		gui.redraw();		// and repaint pixels
		
		smcons = new TextField();
		smpgn = new TextField();	
		Tsd = new TextField();
		Tst = new TextField();
		gui.create_all_consoles(smcons, smpgn, Tsd, Tst);
		addChild(smcons);
		addChild(smpgn);
		addChild(Tsd);
		addChild(Tst);
		smcons.text = "OWL chess in Borland Turbo C (1992-95), " + 
				"ported to flash by Chessforeva (2017), " +
				gui.ConsTextOnResize(); 
		}

	private function onMouseDown(e:MouseEvent):void
		{
		gui.mouseclick( this.mouseX, this.mouseY );
		}
	
	private function onTimer(e:TimerEvent):void
		{
		gui.timertick();
		}
	
	}
}