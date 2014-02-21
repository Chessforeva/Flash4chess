package
{
import flash.events.*;
import flash.display.*;
import flash.sampler.NewObjectSample;
import flash.text.*;
import mx.controls.Image;
import mx.controls.Button;
import mx.controls.CheckBox;
import mx.core.UIComponent;
import flash.utils.Timer;
import flash.ui.Mouse;

//=================================================
//
// EMULATED 64bit chess engine
// port by chessforeva.appspot.com
// for fun and chess lovers...
// apr.2012

/*
    CuckooChess - A java chess program http://web.comhem.se/petero2home/javachess/
    Copyright (C) 2011  Peter Österlund, peterosterlund2@gmail.com

 */

public class Main extends UIComponent
{

[Embed(source='logoFL3.jpg')]
private static var logo_image:Class;
private var logo0:Bitmap = new logo_image();

[Embed(source='cursor.png')]
private static var cursor_image:Class;
private var curs0:Bitmap = new cursor_image();
private var cursAt:String = "";
private var mess_:Boolean = false;

[Embed(source='baltais.jpg')]
private static var wsq_image:Class;
[Embed(source='svitras.jpg')]
private static var bsq_image:Class;

[Embed(source='Ch_plt45.png')]
private static var wp_image:Class;
[Embed(source='Ch_nlt45.png')]
private static var wn_image:Class;
[Embed(source='Ch_blt45.png')]
private static var wb_image:Class;
[Embed(source='Ch_rlt45.png')]
private static var wr_image:Class;
[Embed(source='Ch_qlt45.png')]
private static var wq_image:Class;
[Embed(source='Ch_klt45.png')]
private static var wk_image:Class;
[Embed(source='Ch_pdt45.png')]
private static var bp_image:Class;
[Embed(source='Ch_ndt45.png')]
private static var bn_image:Class;
[Embed(source='Ch_bdt45.png')]
private static var bb_image:Class;
[Embed(source='Ch_rdt45.png')]
private static var br_image:Class;
[Embed(source='Ch_qdt45.png')]
private static var bq_image:Class;
[Embed(source='Ch_kdt45.png')]
private static var bk_image:Class;

private var Cons:TextField = new TextField();
private var bsq0:Array = [];
private var pc0:Array = [];
private var Brect:TextField = new TextField();	// just rectangle
private var BtN:Button = new Button();
private var BtA:Button = new CheckBox();
private var BtU:Button = new Button();

public static var LL:INT64;
public static var Piece:PIECE;
public static var Hash:HASH;
public static var Position:POSITION;
public static var BitBoard:BITBOARD;
public static var Evaluate:EVALUATE;
public static var MoveGen:MOVEGEN;
public static var TextIO:TEXTIO;
public static var KillerTable:KILLERTABLE;
public static var History:HISTORY;
public static var TranspositionTable:TRANSP_TABLE;
public static var Search:SEARCH;
public static var HumanPlayer:HUMAN_PLAYER;
public static var ComputerPlayer:COMP_PLAYER;
public static var Book:BOOK;
public static var Kpk:KPK;
public static var GameState:GAMESTATE;
public static var Game:GAME;

public static var moveTo:String;

private var Timer2:Timer = new Timer(1000);

private var Pause:int = 0;
private var Act:Boolean = false;

private var rev:Boolean = false;


public function Main():void
 {

	moveTo = "";
	  
    Timer2.addEventListener(TimerEvent.TIMER, onTimer);
    Timer2.start();
    Timer2.delay = 20;
	
	// So, create objects and init....
	LL = new INT64();
	Kpk = new KPK();
	Piece = new PIECE();
	Hash = new HASH();
	Position = new POSITION();
	BitBoard = new BITBOARD();
	Evaluate = new EVALUATE();
	MoveGen = new MOVEGEN();
	TextIO = new TEXTIO();
	KillerTable = new KILLERTABLE();
	History = new HISTORY();
	TranspositionTable = new TRANSP_TABLE();
	HumanPlayer = new HUMAN_PLAYER();
	ComputerPlayer = new COMP_PLAYER();
	Book = new BOOK();
	GameState = new GAMESTATE;

	
    this.addEventListener(Event.ENTER_FRAME, onFrameEnter);
    this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	
    if (stage) init();
    else addEventListener(Event.ADDED_TO_STAGE, init);
	
    super();
 
 }
 
 private function addConsole():void
	{
 	var tfStyle:TextFormat = new TextFormat();
	tfStyle.font = "Arial";
	tfStyle.bold = true;
	tfStyle.size = 12;
	
	Cons.defaultTextFormat = tfStyle;
	Cons.text = "Sorry, wait for inits in 3 stages\n(processing 1/3...)";
	Cons.selectable = true;
	Cons.multiline = true;
	
	Cons.x = 390;
	Cons.y = 20;
	Cons.width = 200;
	Cons.height = 330;
	Cons.textColor =  0x000000;
	Cons.border = true;
	Cons.wordWrap = true;
	addChild(Cons);
	}
	
private function addAllButtons():void
	{
	BtN.x = 390;
	BtN.y = 360;
	BtN.width = 60;
	BtN.height = 20;
	BtN.label = "New";
	addChild(BtN);
	BtN.addEventListener(MouseEvent.MOUSE_DOWN, onNewGame);
	
	BtA.x = 460;
	BtA.y = 360;
	BtA.width = 60;
	BtA.height = 20;
	BtA.label = "Self";
	addChild(BtA);
	
	BtU.x = 530;
	BtU.y = 360;
	BtU.width = 60;
	BtU.height = 20;
	BtU.label = "Undo";
	addChild(BtU);
	BtU.addEventListener(MouseEvent.MOUSE_DOWN, onUndo);
	}
 		
 private function DispPosAll():void
	{
	SetUpBoard(Game.pos);
	TextIO.dispBoard(Game.pos);
	trace( "FEN: " + TextIO.toFEN( Game.pos ) );
	trace( "Possible: " + TextIO.dispMoves(Game.pos) );				
	trace( "Book moves: " + Book.getAllBookMoves(Game.pos) );
	trace( "Eval: " + int(Evaluate.evalPos( Game.pos )).toString() );
	var gs:String = Game.getGameStateString(); if(gs.length>0) trace(gs);
	}
 
 // Event on screen redraw
private function onFrameEnter(event:Event):void { /* do nothing */}

// Routine once on loading 
private function init(e:Event = null):void 
	{
	Mouse.cursor = "arrow";
	DrawBoard();
	
	this.rev = (Math.random() > 0.4);
	
	this.logo0.x = 20 + ((45*8) - this.logo0.width)/2;
	this.logo0.y = 20 + ((45*8) - this.logo0.height)/2;

	addChild(this.logo0);
	
	addConsole();
	
	
	removeEventListener(Event.ADDED_TO_STAGE, init);
	
	this.Pause = 10;
	}

private function onTimer(evt:TimerEvent):void
	{

	if (this.Pause > 0) { this.Pause--; return; }	// pause
	if (this.bsq0.length == 0) return;
	if(!BitBoard.InitWas1 )
		{
		Position.Init1();
		Hash.initHash();
		BitBoard.Init1();	// first part
		Cons.text = "First part of inits done\n(processing 2/3...)";
		this.Pause = 10;
		}
	else if(!BitBoard.InitWas2 )
		{
		BitBoard.Init2();	// second part
		Evaluate.initAll();
		KillerTable.Init1();
		History.creaHistory();
		Search = new SEARCH();	// just after all inits
		ComputerPlayer.Init1();
		Cons.text = "Second part of inits done\n(processing 3/3...)";
		this.Pause = 10;
		}
	else if (Book.numBookMoves < 0)
		{
		Book.initBook(true);
		removeChild(this.logo0);
		addAllButtons();
		Cons.text = "Got all book moves";
		this.Pause = 10;
		}
	else
		{
		if (!Act)		// first time action
			{
			SetNewGame();
			Act = true;
			}
		else
			{
			MoveController();		// every loop
			}
		}
	}

private function DrawBoard():void 
	{
	if (this.bsq0.length==0)
	 {
		Brect.text = "";		// Just draw a fake rectangle :)
		Brect.x = 19;
		Brect.y = 19;
		Brect.width = (8*45)+2;
		Brect.height = (8*45)+2;
		Brect.border = true;
		addChild(Brect);
	
		var sq:int = 0;
		for (var x:int = 0; x < 8; x++)
		 for (var y:int = 0; y < 8; y++)
			{
			this.bsq0[sq] = ( ((x + y) % 2 > 0) ? new bsq_image() : new wsq_image() );
			this.bsq0[sq].x = 20 + (x * 45);
			this.bsq0[sq].y = 20 + (y * 45);
			this.bsq0[sq].width = 45;
			this.bsq0[sq].height = 45;
			addChild(this.bsq0[sq]);
			sq++;
			}
	 }
	 
	}

			//This draws pieces...
private function SetUpBoard( pos:POSITION ):void 
	{	
	for (var n:int = 0; n < pc0.length; n++)
		{
		removeChild(this.pc0[n]);
		}
	this.pc0 = [];
	
	// piece placement

    for (var y:int = 7; y >= 0; y--) {
		for (var x:int = 0; x < 8; x++) {
			var p:int = pos.getPiece(Position.getSquare(x, y));
			if(p != Piece.EMPTY) {
					var pieceName:String = (" kqrbnp").charAt( (p > 6 ? p - 6 : p) );
					var p3:String = (Piece.isWhite(p) ? 'w' : 'b') + pieceName;
					var at2:String = String.fromCharCode(97 + x) +
									String.fromCharCode(49 + y);
					addPiece(p3, at2);
                }
            }
        }
	}  

private function addPiece(p:String,at:String):void 
	{
	var n:int = this.pc0.length;
	this.pc0[n] = ((p == "wp") ? new wp_image(): (p == "wn") ? new wn_image():
	 (p == "wb") ? new wb_image(): (p == "wr") ? new wr_image():
	 (p == "wq") ? new wq_image(): (p == "wk") ? new wk_image():
	 (p == "bp") ? new bp_image(): (p == "bn") ? new bn_image():
	 (p == "bb") ? new bb_image(): (p == "br") ? new br_image():
	 (p == "bq") ? new bq_image(): (p == "bk") ? new bk_image(): null );
	 
	var x:int = at.charCodeAt(0) - 97;
	var y:int = 8 - parseInt(at.charAt(1));
	
	if (this.rev) { x = 7 - x; y = 7 - y; }
	
	this.pc0[n].x = 20 + (x * 45);
	this.pc0[n].y = 20 + (y * 45);
	
	this.pc0[n].width = 45;
	this.pc0[n].height = 45;
	addChild(this.pc0[n]);
	}
	

// place cursor at (empty to clear)
private function ShowCursor(at:String):void
	{
	if (this.cursAt.length > 0) removeChild(this.curs0);
	this.cursAt = "";
	if (at.length == 0) return;
	
	var x:int = at.charCodeAt(0) - 97;
	var y:int = 8 - parseInt(at.charAt(1));
	if (x < 0 || x > 7 || y < 0 || y > 7) return;
	
	if (this.rev) { x = 7 - x; y = 7 - y; }
	this.cursAt = at;
	this.curs0.x = 20 + (x * 45);
	this.curs0.y = 20 + (y * 45);
	this.curs0.width = 45;
	this.curs0.height = 45;
	addChild(this.curs0);
	}

private function onMouseDown(event:MouseEvent):void
	{
	var mx:int = this.mouseX;
	var my:int = this.mouseY;
	
	var x1:int = Math.floor((mx - 20)/45);
	var y1:int = Math.floor((my - 20)/45);
	if (x1 >= 0 && x1 < 8 && y1 >= 0 && y1 < 8)
		{
		var atsq:String = String.fromCharCode(97 + (this.rev ? 7 - x1 : x1)) +
				(1 + (this.rev ? y1 : 7 - y1)).toString();
		var  moves:MoveList = MoveGen.pseudoLegalMoves(Game.pos);
		MoveGen.removeIllegal(Game.pos, moves);
		moveTo = "";
        for (var i:int = 0; i < moves.size; i++)
			{
			var mstr:String = TextIO.moveToUCIString(moves.m[i]);
			if ( this.cursAt.length > 0 && 
				mstr == this.cursAt + atsq + (mstr.length>4?"q":"") )
				{
				 moveTo = mstr; break;
				}
			if ( mstr.substr(0, 2) == atsq )
				{
				ShowCursor(	atsq ); break;
				}
			}
		}
	}
	
private function onNewGame(event:MouseEvent):void
 	{
	this.rev = !this.rev;
	BtA.selected = false;
	SetNewGame();
	}

private function onUndo(event:MouseEvent):void
 	{
	if (!BtA.selected && Game.currentMove > 1)
		{
		Game.processString("undo");
		Game.processString("undo");
		DispPosAll();
		ShowCursor("");
		Cons.text = Game.GetPGN();
		mess_ = false;
		}
	}
	
private function SetNewGame():void
	{
		Game = new GAME();
		Game.CreaGame( HumanPlayer.clone(), ComputerPlayer.clone() );
		if (this.rev) Game.processString("swap");
		
		DispPosAll();
		ShowCursor("");
		Cons.text = "Ready for new game";
	}
	
private function MoveController():void
	{
	if (Game.getGameStateString().length == 0)
			{
			var wtm:Boolean = Game.pos.whiteMove;
			var player:PLAYER = ( wtm ? Game.whitePlayer : Game.blackPlayer );
				// set automatic
			if ( BtA.selected && player.isHumanPlayer() ) Game.processString("swap");
			if ( !BtA.selected && player.isHumanPlayer()
				&& (this.rev == wtm) ) Game.processString("swap");

			if (!mess_)	// show some info about what's going on
				{
				mess_ = true;
				if ( player.isHumanPlayer() && (!BtA.selected))
					{
					Cons.appendText("\nYour move!");
					}
				else
					{
					Cons.appendText("\nThinking...");
					return;	//show and process on next loop
					}
				}
			
				// get move or search
			var cmd:String = player.getCommand( Game.pos, false );
			if (cmd.length > 0)
				{
				trace(cmd);
				Game.processString(cmd);
				DispPosAll();
				if (cmd.length > 2) ShowCursor(cmd.substr(2, 2));
				Cons.text = Game.GetPGN();
				mess_ = false;
				}
			}
	}
	
}

}
