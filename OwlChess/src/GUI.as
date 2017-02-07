package
{
	import flash.events.*;
	import flash.utils.ByteArray;
	import flash.ui.Mouse;
	import flash.display.*;
	import flash.geom.*;
	import flash.text.*;

	/*
	* Graphics drawing code with chess calls
	* 
	* Screen is a bitmap object with direct memory access via pixels.
	* So, no embedded images, lua scripts prepare bmp-datas.
	*/
	
	public class GUI
	{
		public static var Pictures:Pics;		// object of bitmap data
		
		public var chess:OwlChess;				// object of chess
		public var anim:Animation;				// animation object
		public var book:OwlBook;					// opening book object

		public var Scale:int;		// 1 or 2=default
		public var maxScale:int;	// 2 if fits in the stage size
		
		public var Height:int;		// scene bitmap
		public var Width:int;
		
		public const Sc2top:int = 24;	// top margin of board for Scale=2
		
		// bitmap information, drawing in memory, not image
		public var bitmap:Bitmap;
		public var bmpData:BitmapData;
		public var bmpRect:Rectangle;
		public var pixels:Vector.<uint>;
		public var PxCnt:int;
		
		public var Cons:TextField;		// console on screen
		public var Pgncons:TextField;	// pgn-console on screen
		public var depthT:TextField;
		public var timesecT:TextField;
		
		public var Buttons:Array;
		
		public const liteSqColor:int = 0xffffff;
		public const darkSqColor:int = 0x008000;
		
		public var BoInv:Boolean = false;	// is board inverted
		public var GameOver:Boolean = false;
		
		public var DragSq:int = -1;
		public var MoveSq:int = -1;
		
		// a few additional chess notations
		public var PGN:Array = [];

		public var Ai:int = 0;			// ticks to start AI, or 0
		public var AIself:Boolean;		// is AI vs AI game
		public var AIpause:int = 0;		// delay ticker to give user access to buttons

		public var bookmv:Boolean = false;
		public var AItxt:String = "";
		public const cr:String = String.fromCharCode(13);

		public function GUI()
			{
						// some inits
			Pictures = new Pics();
			anim = new Animation();
			}

	// the bitmap size changes on resizing, scaling
	public function resize():void
        {
		Scale = 2;
		if ((Height < 390) || (Width < 404)) Scale = 1;
		maxScale = Scale;
		defwinparts(false);
		}

	public function ConsTextOnResize():String
		{
		return "scale=" + Scale + cr +
				(!GameOver && !AIself && !Ai && BoInv == chess.Player ? "Your move." : ""); 
		}
		
	public function defwinparts( redrawonly:Boolean ):void
        {
		PxCnt = Width * Height;

		//create a fixed length Vector to store the pixel
		pixels = new Vector.<uint>(PxCnt, true);
		
		clsBg();

		if(!redrawonly) create_bitmap();

		drawBgBoard();
		drawLabels();
		drawPosition();
		draw_buttons();
		}
	
	private function clsBg():void
		{
		clearDragSq();
		clearMoveSq();
			// set background color
			// RGB color = ((R << 16) | (G << 8) | B);
		for (var i:int = 0; i < PxCnt; i++) pixels[i] = 0x669966;
		}
		
	private function setScale( n:int ):void
		{
		Scale = n;
		clsBg();
		defwinparts(true);
		ConsolesResize();
		redraw();
		Cons.text = "scale=" + n;
		}
		
	private function setDepth( add:int ):void
		{
		var d:int = chess.MAXPLY;
		var n:int = d + add;
		if (n > 1 && n <= 8)
			{
			chess.MAXPLY = n;
			depthT.text = n.toString();
			Cons.text = "AI depth= " + n;
			}
		}
	private function setTmSec( add:int ):void
		{
		var d:int = chess.MAXSECS;
		var n:int = d + add;
		if (n > 1 && n <= 16)
			{
			chess.MAXSECS = n;
			timesecT.text = n.toString();
			Cons.text = "AI seconds= " + n;
			}
		}
		
	private function create_bitmap():void
		{		
		//create a Rectangle with width / height of Bitmap
		bmpRect = new Rectangle(0, 0, Width, Height);

		//create the BitmapData object to hold hold the BMP data.
		bmpData = new BitmapData( Width, Height, false, 0x000000);
		}
	
	public function redraw():void
		{
		//copy the BMP pixel data into the BitmapData
		// This redraws on screen after also.
		bmpData.setVector(bmpRect, pixels);
		}
		
	public function create_all_consoles(
				smcons:TextField, smpgn:TextField,
				sdT:TextField, stT:TextField):void
		{
		Cons = smcons;
		Cons.textColor = 0x000000;	// black
		Cons.borderColor = 0xffffff;	// white
		Cons.selectable = true;
		Cons.border = true;
		Cons.wordWrap = true;
		Cons.multiline = true;
		
		Pgncons = smpgn;
		Pgncons.textColor = 0x000000;	// black
		Pgncons.borderColor = 0xffffff;	// white
		Pgncons.selectable = true;
		Pgncons.border = true;
		Pgncons.wordWrap = true;
		Pgncons.multiline = true;
		
		depthT = sdT;
		depthT.textColor = 0x000000;	// black
		depthT.text = chess.MAXPLY.toString();
		
		timesecT = stT;
		timesecT.textColor = 0x000000;	// black
		timesecT.text = chess.MAXSECS.toString();
		
		ConsolesResize();
		}
	
	private function ConsolesResize():void
		{
		Cons.x = 340 * Scale;
		var y:int = 180;
		if (Scale == 1) y += Sc2top;
		Cons.y = (180 + (Scale == 2?0:Sc2top)) * Scale;
		Cons.width = 64 * Scale;
		Cons.height = 70 * Scale;
		
		Pgncons.y = Cons.y + Cons.height + (5 * Scale);
		Pgncons.x = Cons.x;
		Pgncons.width = Cons.width;
		Pgncons.height = 40 * Scale;
		
		depthT.y = (118 + (Scale == 2?0:Sc2top)) * Scale;
		depthT.x = 384 * Scale;
		depthT.width = 32 * Scale;
		depthT.height = 20 * Scale;
		depthT.textColor = 0x004400;
		
		timesecT.y = depthT.y + (28 * Scale);
		timesecT.x = depthT.x;
		timesecT.width = depthT.width;
		timesecT.height = depthT.height;
		timesecT.textColor = depthT.textColor;
		
		var T:TextFormat = new TextFormat();
		T.font = "Times New Roman";
		T.bold = (Scale == 2);
		T.size = (Scale == 2 ? 16 : 10);
		font(Cons, T);
		font(Pgncons, T);
		T.bold = true;
		T.size = (Scale == 2 ? 26 : 14);
		font(depthT, T);
		font(timesecT, T);
		}
	public function font(t:TextField, T:TextFormat):void
		{
		t.defaultTextFormat = T;
		t.setTextFormat(T, -1, -1);
		}
		
	public function defpushbutt(I:int, x:int, y:int):void
		{
			var i:int = I & 0xff;
			var datas:Array = Pictures.List[i];
			var W:int = datas[2];
			var H:int = datas[3]
			
			Buttons.push( new Button( I, x, y, W, H ) );
			DrawPicture( i, x, y, 2 );
		}

	public function draw_buttons():void
		{
		Buttons = [];
		if (maxScale == 2)
			{
			defpushbutt( 47, 344, 30);	// Scale
			defpushbutt( 48, 342, 42);	// x1
			defpushbutt( 49, 366, 42);	// x2
			}
		
		defpushbutt( 50, 338, 62);	// New Game
		defpushbutt( 51, 338, 82);	// Take Back
		defpushbutt( 52, 338, 102);	// Selfgame
		
		defpushbutt( 55, 352, 128);	// brain
		defpushbutt( 54, 340, 126);	// AI
			
		defpushbutt( 57, 344, 146);	// depth
		defpushbutt( 0x100 + 60, 354, 156);	// -
		defpushbutt( 0x100 + 59, 370, 156);	// +
		
		
		defpushbutt( 58, 339, 174);	// time.seconds
		defpushbutt( 0x200 + 60, 354, 184);	// -
		defpushbutt( 0x200 + 59, 370, 184);	// +
		}

	private function drawBrain( on:int ):void
		{
		DrawPicture( 55 + on, 352, 128, 2);	// brain
		redraw();
		}
	private function drawSelfGame():void
		{
		DrawPicture( 52, 338, 102, 2 );	// brain
		if (AIself) DrawPicture( 53, 338 + 55, 102 + 11, 2 );
		redraw();
		}

	// draws an empty chess board with frame
	private function drawBgBoard():void
		{
		var S:int = 84;	
		for (var h:int = 0; h < S; h++)
			{
			var h4:int = h * 4;
			var hb:int = ((h - 6) / 9);
			for (var v:int = 0; v < S; v++)
			{
			var i:int = 0;
			var v4:int = v * 4;
			var vb:int = ((v - 6) / 9);

			if (h == 0 && v == 0 ) i = 29; //LU0
			if (h == 0 && v == S - 1 ) i = 34; //LD0
			if (h == S - 1 && v == 0 ) i = 30; //RU0
			if (h == S - 1 && v == S - 1 ) i = 35; //RD0
			if (!i)
				{
				if (h == 0) i = 32; //L0
				if (h == S - 1) i = 33; //R0
				if (v == 0) i = 31; //U0
				if (v == S - 1) i = 36; //D0
				}

			if (h == 5 && v == 5 ) i = 37; //LU1
			if (h == 5 && v == S - 6 ) i = 42; //LD1
			if (h == S - 6 && v == 5 ) i = 38; //RU1
			if (h == S - 6 && v == S - 6 ) i = 43; //RD1
			if (!i)
				{
				if (v > 5 && v < S - 6)
					{
					if (h == 5) i = 40; //L1
					if (h == S - 6) i = 41; //R1
					}
				if (h > 5 && h < S - 6)
					{
					if (v == 5) i = 39; //U1
					if (v == S - 6) i = 44; //D1
					}
				}
			if (!i && (h < 5 || v < 5 || h > S - 6 || v > S - 6)) i = 28; // BG
			
			if (!i) i = ((hb + vb) & 1 ?  46 /*Dark_Square*/ : 45 /*Lite_Square*/ );
			
			if (i) DrawPicture(i, h4 , v4, 0);
			}
			}
		}
	
	// draws A-H,1-8
	private function drawLabels():void
		{
		var I:int;
		var i:int;
		
		// A-H
		for (i = 0; i < 8; i++)
			{
			I = 12 + (BoInv ? 7 - i : i);
			var x:int = 36 + (36 * i);
			DrawPicture(I, x, 315, 0);
			DrawPicture(I, x, 4, 0);
			}
			
		//1-8
		for (i = 0; i < 8; i++)
			{
			I = 20 + (BoInv ? i: (7 - i));
			var y:int = (32 + (36 * i));
			DrawPicture(I, 6, y, 0);
			DrawPicture(I, 318, y, 0);
			}
		}
	private function xOfh(h:int):int { return 24 + (36 * (BoInv ? 7 - h : h)); }
	private function yOfv(v:int):int { return 24 + (36 * (BoInv ? v :7 - v)); }
	
	
	// draws pieces on board
	private function drawPosition():void
		{
		for(var v:int=8;(--v)>=0;)
			for(var h:int=0;h<8;h++)
			{
			var sq: int = (v << 4) | h;
			var o:BOARDTYPE = chess.Board[sq];
			if (o.piece) drawSq(sq);
			}
		}

	public function drawSq( sq:int ):void
			{
			var o:BOARDTYPE = chess.Board[sq];
			var i:int = (o.piece ? ((o.color == chess.white) ? 0 : 6) + (o.piece-1) : 0);
			DrawPicture(i,  xOfh( sq & 7 ), yOfv(sq >>> 4), 0);
			}
	
		/* -1, if not a square on board */
	private function SqByXY(X:int, Y:int, scale:int): int
		{
			var i:int = -1;
			var x:int = X / scale;
			var y:int = Y / scale;
			if (x >= 24 && x < 312 && y >= 24 && y < 312)
				{
				var v:int = ((y - 24) / 36);
				var h:int = ((x - 24) / 36);
				if (BoInv) h = 7 - h; else v = 7 - v;
				i = (v << 4) | h;
				}
			return i;
		}

	// I-picture nr, x,y to place
	//  op=0  -normal draw, otherwise
	//	bits:
	// 		1-clear all square
	//		2-do not draw transparent pixels
	//		4-save pixels to animation array
	//		8-restore pixels from animation array
	
	private function DrawPicture(I:int,x:int,y:int, op:int):void
		{
			var datas:Array = Pictures.List[I];
			var W:int = datas[2];
			var H:int = datas[3];
			
			if (op&1) { W = 36; H = 36; }
			else
				{
				x += datas[0];
				y += datas[1];
				}
				
			var j:int = 4;
			var transpCol:int = 0x000000;	// color for square or background
			
			var sq:int = SqByXY(x, y, 1);
			if (sq >= 0)
				transpCol = ( ((sq >> 4) + (sq & 7)) & 1 ? liteSqColor : darkSqColor );
			
			if (Scale == 2) y -= Sc2top;
								
			for(var h:int = 0; h < H; h++)
			{
				var p:int = Scale * (((y + h) * Width) + x);
				var s:String = datas[j++];
				for(var w:int = 0; w < W; w++)
					{
					var f:int = transpCol;
					var z:int = 1;
					if (!(op&1))
						{
						z = s.charCodeAt(w);
						z = (z >= 97 ? z - 97 : z - 65 + 26);
						if (z) f = Pictures.ColPalette[z - 1];
						}
					if (!op && sq >= 0 && (h == 0 || w == 0 || h == H - 1 || w == W - 1))
						{
						if (sq == DragSq) { z = 1; f = 0xff0000; }	// red
						if (sq == MoveSq) { z = 1; f = 0x0000ff; }	// blue
						}
									
					for (var l:int = 0; l < Scale; l++,p++)
					  for (var q:int = 0; q < Scale; q++) 
						{
						var i:int = p + (q * Width);
						if (i >= 0 && i < PxCnt)
							{
							if (op&4) anim.bgpixels.push(pixels[i]);
							else
							if (op&8) pixels[i] = anim.bgpixels.shift();
							else
								{		
								if(z || !(op&2)) pixels[i] = f;
								}
							}
						}
					}
			}
			
		}

 	public function mouseclick(x:int, y:int):void
		{
		if (anim.active || anim.delay || Ai) return;
			
		if (Scale == 2) y += Sc2top * Scale;
			
		var sq:int = SqByXY(x, y, Scale);
		var i:int = 0;
		if (!GameOver && !AIself && sq >= 0)
		{
		chess.InitMovGen();
		for(;i<chess.BufCount;i++)
			{
			chess.MovGen();
			if (!chess.IllegalMove(chess.Next))
				{
				if (sq == chess.Next.old)
					{
						clearDragSq();
						DragSq = sq;
						drawSq(sq);
						redraw();
						break;
					}
				
				if (DragSq >= 0 && sq == chess.Next.nw1 && DragSq == chess.Next.old)
					{
						clearMoveSq();
						var movestr:String = chess.sq2str(DragSq) + chess.sq2str(sq)
						clearDragSq();
						DoMove(movestr);
						redraw();
						break;
					}
	 
				}
			}
		}
		else
		{
		var X:int = x / Scale;
		var Y:int = y / Scale;
		
			// look for button pressed
		for (; i < Buttons.length; i++)
			{
			var b:Button = Buttons[i];
			
			if (b.x1 <= X && b.y1 <= Y && b.x2 >= X && b.y2 >= Y)
				{
				switch(b.I)
				{
				case 48:
					setScale(1);
					break;
				case 49:
					setScale(2);
					break;
				case 50:
					newgame();
					break;
				case 51:
					takeback();
					break;
				case 52:
					selfgame();
					break;
				case (0x100 + 59):
					setDepth(1);
					break;
				case (0x100 + 60):
					setDepth(-1);
					break;
				case (0x200 + 59):
					setTmSec(1);
					break;
				case (0x200 + 60):
					setTmSec(-1);
					break;
				};
			
			}
		}
		}
		}
		
		public function clearMoveSq():void
		{ var sq: int =  MoveSq; MoveSq = -1; if (sq >= 0) drawSq(sq); }
		public function clearDragSq():void
		{ var sq: int =  DragSq; DragSq = -1; if (sq >= 0) drawSq(sq); }
		
		public function DoMove(movestr:String):void
		{
			var move_notated:String = chess.DoMoveByStr(movestr);
			
			var s:String = chess.Comment();
			if(s.indexOf("Mate!")>=0) GameOver=true;

			var CkMt:Boolean = (s.indexOf("CheckMate!")>=0);
			var Ck:Boolean = (s.indexOf("Check+!")>=0);
			move_notated += (CkMt ? "#" : (Ck ? "+" : ""));
			if (!PGN.length) PGN = ["", ""];
			PGN[chess.mc - 1] = move_notated;
			
			trace("moved " + move_notated + " " + s);
			MoveSq = chess.Mpre.nw1;
			startAnimation(chess.Mpre);
			dispToConsoles(move_notated +
					(bookmv ? " (opn.)" : "" ) + 
					(s.length ? cr : "") + 
					(AItxt.length ? cr + AItxt : "") + 
					(s.length ? cr : "") + s);
			AItxt = "";
		}
		
		public function dispToConsoles(s:String):void
			{
				Pgncons.text = wholePGN(s);
				if (s.length) s += cr;
				if (!AIself && !GameOver && BoInv == chess.Player) s+= "Your move.";
				Cons.text = s;
				if (AIself && GameOver) selfGameOff();
			}
		
		public function wholePGN(s:String):String
			{
			var S:String = "";
			for (var i:int = 1; i < chess.mc; i++)
				{
				var movenumb: int = (i + 1) >> 1;
				S += ((i & 1) ? movenumb + "." : "") + PGN[i] + " " + ((i & 1) ? "" :cr);
				}
			if (GameOver) S += " {" + chess.Comment() + "}";
			return S;
			}

		
		// starts an animation on board
		public function startAnimation( move:MOVETYPE ):void
			{
			var x:int = xOfh(move.old & 7);
			var y:int = yOfv(move.old >>> 4);
			var x2:int = xOfh(move.nw1 & 7);
			var y2:int = yOfv(move.nw1 >>> 4);
			var I:int = (chess.Player == chess.white ? 6 : 0) + (move.movpiece-1);
			anim.start(move, I, x, y, x2, y2);
			DrawPicture(anim.I, anim.x, anim.y, 1);	// clear
			redraw();
			}
		
		public function timertick():void
			{
				if (AIpause) AIpause--;
				if (Ai)
					{ Ai--;
					if (!Ai)
					{
						// if need start engine
						var mv:String = chess.FindOpeningMove();
						bookmv = (mv.length > 0);
						if(!bookmv) mv = chess.FindMove();
						if (mv.length)
							{
								if (chess.Nodes)
										AItxt = "Ev = " + chess.EvValStr() +
										"," + cr + chess.Nodes + " nodes" +
										"," + cr + "realdepth = " + chess.MaxDepth;
								clearDragSq();
								clearMoveSq();
								DoMove(mv);
								if (AIself) AIpause = 30;								
							}
						drawBrain(0);
					}
					}
				else if (anim.active)
					{
					if(anim.tick) DrawPicture(anim.I, anim.x, anim.y, 8);	// restore pixels
					anim.step();
					var f:Boolean = anim.active;	// is animation over
					if (!f) DrawPicture(anim.I, anim.x, anim.y, 1); // clear, if last tick
					if (f) DrawPicture(anim.I, anim.x, anim.y, 4);	// save pixels
					DrawPicture(anim.I, anim.x, anim.y, (f?2:0));	// draw piece only
					if (!f)
						{
						if (anim.move.spe)
							{
								var p:int = anim.move.movpiece;
								if (p == chess.pawn)
									{
									// clear, en-passant pawn
									DrawPicture(anim.I, anim.x_to, anim.y_from, 1);
									}
								if (p == chess.king)
									{
									// start moving castling rook
									var Cast:CASTTYPE = new CASTTYPE();
									chess.GenCastSquare(anim.move.nw1, Cast);
									
									var move:MOVETYPE = new MOVETYPE();
									move.old = Cast.cornersquare;
									move.nw1 = Cast.castsquare;
									move.movpiece = chess.rook;
									startAnimation(move);
									}
							}
						else anim.delay = 10;	// do a small pause before starting calc.
						}
					redraw();
					}
				else
					{
						if (anim.delay) anim.delay--;
						else if (!AIpause && !GameOver && (AIself || chess.Opponent == BoInv))
							{
							Ai = 5;	// Set AI to start
							drawBrain(1);
							Cons.text = "Thinking...";
							}
					}
			}

		public function newgame():void
			{
			selfGameOff();
			chess.ResetGame();
			GameOver = false;
			MoveSq = -1; DragSq = -1;
			PGN.length = 0;
			BoInv = !BoInv;
			drawBgBoard();
			drawLabels();
			drawPosition()
			redraw();
			dispToConsoles("newgame");
			}

		public function takeback():void
			{
			selfGameOff();
			MoveSq = -1; DragSq = -1;
			for(;chess.mc>1;)
				{
				GameOver = false;
				chess.UndoMove();
				if (chess.Player == BoInv) break;
				}
			drawBgBoard();
			drawPosition();
			MoveSq = (chess.mc > 1 ? chess.Mpre.nw1 : -1);
			if(MoveSq>=0) drawSq(MoveSq);
			redraw();
			var s:String = chess.Comment();
			dispToConsoles("takeback" + (s.length ? cr : "") + s);
			}

		// start or stop a self playing AI
		public function selfgame():void
			{
			AIself = !AIself;
			dispToConsoles( AIself ? "AI vs AI game" : "selfgame=off" );
			drawSelfGame();
			}
		
		// turns off AI vs AI
		public function selfGameOff():void
			{
			AIself = false;
			drawSelfGame();
			}
	}
}

