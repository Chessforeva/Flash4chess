/*
An actionscript port of
 OWL CHESS written in Borland Turbo C (year 1992-95)
done by http://chessforeva.blogspot.com (year 2017)

The original code is very well documented and 32bit chess engine is Flash appropriate.
*/

package
{
public class OwlChess
{
	public var MAXPLY:int = 6;		// max.ply
	public var MAXSECS:int = 8;		// max.seconds to search

	public function OwlChess()
	{	
		prepareBitCounts();
		initEngine();
	}
	

	/* constants and globals */
	
	/* pieces */
public const empty:int = 0;
public const king:int = 1;
public const queen:int = 2;
public const rook:int = 3;
public const bishop:int = 4;
public const knight:int = 5;
public const pawn:int = 6;

	/* colours */
public const white:int = 0;
public const black:int = 1;
	
	/* castlings */
public const zero:int = 0;
public const lng:int = 1;
public const shrt:int = 2;


public var Player:int = white;			// Side to move
public var Opponent:int = black;		// opponent
public var ProgramColor:int = white;	// AI side


public const Pieces:Array = [ rook, knight, bishop, queen, king, bishop, knight, rook ];	// [8]
public var PieceTab:Array =[[],[]];
public var Board: Array = [];	// [0x78]

public var MovTab:Array = [];
public var mc:int = 0;		// count of moves

public var OfficerNo:Array = [];
public var PawnNo:Array = [];	// 2

public function InsertPiece(p:int, c:int, sq:int):void
	{
	Board[sq].piece = p;
	Board[sq].color = c;
	}

public function ResetMoves():void
{
   mc = 1;
   MovTab = [ new MOVETYPE(), new MOVETYPE(), new MOVETYPE() ];
   Mo = MovTab[mc]; Mpre = MovTab[mc-1];
} 

public function ClearBoard():void
{
 for (var sq:int = 0; sq <= 0x77; sq++) Board[sq] = new BOARDTYPE();
}

public function ResetGame():void
{
 ClearBoard();
 for (var i:int=0;i<8;i++)
 {
  InsertPiece(Pieces[i], white, i);
  InsertPiece(pawn, white, i+0x10);
  InsertPiece(pawn, black, i+0x60);
  InsertPiece(Pieces[i], black, i+0x70);
 }
 CalcPieceTab();
 Player = white; Opponent = black;	// Side to move, opponent
 ResetMoves();
 UseLib = 200;
}

/*
 *  Clears indexes in board and piecetab
 */

public function ClearIndex():void
{
    for (var square:int = 0; square <= 0x77; square++)
        Board[square].index = 16;
    for (var col:int = white; col <= black; col++)
        for (var index:int = 0; index <= 16; index++) PieceTab[col][index] = new PIECETAB();

    OfficerNo = [ -1, -1 ]; PawnNo = [ -1, -1 ];
}


/*
 *  Calcualates Piece table from scratch
 */

public function CalcPieceTab():void
{
    ClearIndex();

    for (var piece1:int = king; piece1 <= pawn; piece1++)
     {
        if (piece1 == pawn)
        {
            OfficerNo[white] = PawnNo[white];
            OfficerNo[black] = PawnNo[black];
        }
        var square:int = 0;
        do
        {
            var o:BOARDTYPE = Board[square];
            if (o.piece == piece1)
            {
                var w:int = o.color;
                PawnNo[w]++;
                var p:int = PawnNo[w];
                var q:PIECETAB = PieceTab[w][p];
                q.ipiece = piece1; q.isquare = square;
                o.index = p;
            }
            square ^=  0x77;
            if (!(square & 4))
            {
                if (square >= 0x70)
                    square = (square + 0x11) & 0x73;
                else
                    square += 0x10;
            }
        } while (square);
    }
}


	// search current depth (originally Depth starts from 0)  1..MAXPLY
public var Depth:int = 1;
public var AttackTab:Array = [];
public const BitTab:Array = [0, 1, 2, 4, 8, 0x10, 0x20];	// [7]
public const DirTab:Array = [ 1, -1, 0x10, -0x10, 0x11, -0x11, 0x0f, -0x0f];	// [8]
public const KnightDir:Array = [0x0E, -0x0E, 0x12, -0x12, 0x1f, -0x1f, 0x21, -0x21];	// [8]
public const PawnDir:Array = [0x10, -0x10];	// [2]
public var BufCount:int = 0;
public var BufPnt:int = 0;
public var Next:MOVETYPE = new MOVETYPE();
public var Buffer:Array = [];
public const ZeroMove:MOVETYPE = new MOVETYPE();


	// [2][2] of new,old squares    
public const CastMove:Array = [ [new CSTPE(2, 4), new CSTPE(6, 4)],
	[new CSTPE(0x72, 0x74), new CSTPE(0x76, 0x74)] ];

/* === MOVEGEN === */

public function CalcAttackTab():void
{
	var o:ATTACKTABTYPE;

    for (var sq:int = -0x77; sq <= 0x77; sq++)
		AttackTab[120+sq] = new ATTACKTABTYPE(); 
    for (var dir:int = 7; dir >=0; dir--)
    {
        for (var i:int = 1; i < 8; i++)
        {
		o = AttackTab[120+(DirTab[dir]*i)];
		o.pieceset = BitTab[queen]+BitTab[(dir < 4 ? rook : bishop)];
		o.direction = DirTab[dir];
        }
        o = AttackTab[120+DirTab[dir]];
		o.pieceset += BitTab[king];
		o = AttackTab[120+KnightDir[dir]];
        o.pieceset = BitTab[knight];
        o.direction = KnightDir[dir];
    }
}


/*
 *  calculate whether apiece placed on asquare attacks the square
 */

public function PieceAttacks(apiece:int, acolor:int,
	asquare:int, square:int):Boolean
{
    var x:int = square - asquare;
    if (apiece == pawn)   /*  pawn attacks  */
        return (Math.abs(x - PawnDir[acolor]) == 1);
    /*  other attacks: can the piece move to the square?  */
    else if (AttackTab[120+x].pieceset & BitTab[apiece])
    {
        if (apiece == king || apiece == knight)
            return true;
        else
        {
        /*  are there any blocking pieces in between?  */
            var sq:int = asquare;
            do
            {
                sq += AttackTab[120+x].direction;
            } while (sq != square && Board[sq].piece == empty );
            return (sq == square);
        }
    }
    else
        return false;
}


/*
 *  calculate whether acolor attacks the square with at pawn
 */

public function PawnAttacks(acolor:int,square:int):Boolean
{
    var o:BOARDTYPE;
	var sq:int = square - PawnDir[acolor] - 1;  /*  left square  */
    if (!(sq & 0x88))
    {
        o = Board[sq];
        if (o.piece == pawn && o.color == acolor)
            return true;
    }
    sq += 2;   /*  right square  */
    if (!(sq & 0x88))
    {
        o = Board[sq];
        if (o.piece == pawn && o.color == acolor)
            return true;
    }
    return false;
}


/*
 *  Calculates whether acolor attacks the square
 */

public function Attacks(acolor:int, square:int):Boolean
{
    if (PawnAttacks(acolor, square))    /*  pawn attacks  */
        return true;
    /*  Other attacks:  try all pieces, starting with the smallest  */
    for (var i:int = OfficerNo[acolor]; i >= 0; i--)
    {
	var o:PIECETAB = PieceTab[acolor][i];
        if (o.ipiece != empty)
            if (PieceAttacks(o.ipiece, acolor, o.isquare, square))
                return true;
    }
    return false;
}


/*
 *  check whether inpiece is placed on square and has never moved
 */

public function Check(square:int, inpiece:int, incolor:int):Boolean
{
    var o:BOARDTYPE = Board[square];
    if(o.piece == inpiece && o.color == incolor)
    {
        var dep:int = mc - 1;
        while (dep>=0 && MovTab[dep].movpiece != empty)
        {
            if (MovTab[dep].nw1 == square)
                return false;
            dep--;
        }
        return true;
    }
    return false;
}


/*
 *  Calculate whether incolor can castle
 */

public function CalcCastling(incolor:int):int
{
    var square:int = 0;
	var cast:int = zero;

    if (incolor == black) square = 0x70;
    if (Check(square + 4, king, incolor))  /*  check king  */
    {
        if (Check(square, rook, incolor))
            cast += lng;  /*  check a-rook  */
        if (Check(square + 7, rook, incolor))
            cast += shrt;  /*  check h-rook  */
    }
    return cast;
}


/*
 *  check if move is a pawn move or a capture
 */

public function RepeatMove(move:MOVETYPE):Boolean
{
    return (move.movpiece != empty && move.movpiece != pawn &&
              move.content == empty && !move.spe);
}


/*
 *  Count the number of moves since last capture or pawn move
 *  The game is a draw when fiftymovecnt = 100
 */

public function FiftyMoveCnt():int
{
    var cnt:int = 0;
    while (RepeatMove(MovTab[mc - cnt]))
        cnt++;
    return cnt;
}


/*
 *  Calculate how many times the move has occurred before
 *  The game is a draw when repetition = 3
 *  MovTab contains the previous moves
 *  When immediate is set, only immediate repetition is checked
 */

public function Repetition(immediate:Boolean):int
{
    var repeatcount:int = 1;
    var lastdep:int = mc;    /*  current position  */
    var samedepth:int = lastdep;
    var compdep:int = samedepth - 4;            /*  First position to compare  */

    /*  MovTab contains previous relevant moves  */
    while (RepeatMove(MovTab[lastdep-1]) && (compdep < lastdep ||
                 !immediate))
        lastdep--;
    if (compdep < lastdep) return 1;
    var checkdep:int = samedepth;
    do
    {
        checkdep--;
        var checksq:int = MovTab[checkdep].nw1;
		var f:Boolean = true;
        for (var tracedep:int = checkdep + 2; tracedep < samedepth; tracedep += 2)
            if (MovTab[tracedep].old == checksq) { f=false; break; }
	
	if(f)
	{

        /*  Trace the move backward to see if it has been 'undone' earlier  */
        tracedep = checkdep;
        var tracesq:int = MovTab[tracedep].old;
        do
        {
            if (tracedep-2 < lastdep) return repeatcount;
            tracedep -= 2;
            /*  Check if piece has been moved before  */
			var o:MOVETYPE = MovTab[tracedep];
            if (tracesq == o.nw1) tracesq = o.old;
        } while (tracesq != checksq || tracedep > compdep + 1);
        if (tracedep < compdep)    /*  Adjust evt. compdep  */
        {
            compdep = tracedep;
            if ((samedepth - compdep) % 2 == 1)
            {
                if (compdep == lastdep) return repeatcount;
                compdep --;
            }
            checkdep = samedepth;
        }
	}
	
        /*  All moves between SAMEDEP and compdep have been checked,
            so a repetition is found  */
//TEN :
	if (checkdep <= compdep)
        {
            repeatcount++;
            if (compdep - 2 < lastdep) return repeatcount;
            checkdep = samedepth = compdep;
            compdep -= 2;
        }
    } while (1);
	return repeatcount;
}


/*
 *  Test whether a move is possible
 *
 *  On entry:
 *    Move contains a full description of a move, which
 *    has been legally generated in a different position.
 *    MovTab[mc] contains last performed move.
 *
 *  On exit:
 *    KillMovGen indicates whether the move is possible
 */

public function KillMovGen(move:MOVETYPE):Boolean
{
    var killmov:Boolean = false;
    if (move.spe && (move.movpiece == king))
    {
        var cast:int = CalcCastling(Player);     /*  Castling  */
        var castdir:int = ((move.nw1 > move.old) ? shrt : lng );

        if (cast & castdir)    /*  Has king or rook moved before  */
        {
            var castsq:int =  ((move.nw1 + move.old) / 2);
            /*  Are the squares empty ?  */
            if  (Board[move.nw1].piece == empty)
              if (Board[castsq].piece == empty)
                if ((move.nw1 > move.old) || (Board[move.nw1-1].piece == empty))
                  /*  Are the squares unattacked  */
                  if (!Attacks(Opponent, move.old))
                    if (!Attacks(Opponent, move.nw1))
                      if (!Attacks(Opponent, castsq))
                        killmov = true;
        }
    }
    else
    {
    if (move.spe && (move.movpiece == pawn))
    {
            /*  E.p. capture  */
            /*  Was the Opponent's move a 2 square move?  */
        if (Mpre.movpiece == pawn)
            if (Math.abs(Mpre.nw1 - Mpre.old) >= 0x20)
	    {
				var q:BOARDTYPE = Board[move.old];
                if ((q.piece == pawn) && (q.color == Player))
                        killmov = (move.nw1 == ((Mpre.nw1 + Mpre.old) / 2));
	    }
    }
    else
    {
		var promote:int = 0;
        if (move.spe)                  /*  Normal test  */
        {
            promote = move.movpiece;   /*  Pawnpromotion  */
            move.movpiece = pawn;
        }

        /*  Is the content of Old and nw1 squares correct?  */
		var o:BOARDTYPE = Board[move.old];

        if (o.piece == move.movpiece)
          if (o.color == Player)
			{
			var n:BOARDTYPE = Board[move.nw1];
            if (n.piece == move.content)
              if (move.content == empty || n.color == Opponent)
              {
                if (move.movpiece == pawn)   /*  Is the move possible?  */
                {
                  if (Math.abs(move.nw1 - move.old) < 0x20)
                    killmov = true;
                  else
                    killmov = Board[(move.nw1+move.old) / 2].piece == empty;
                }
                else
                  killmov = PieceAttacks(move.movpiece, Player,
                                 move.old, move.nw1);
              }
              if (move.spe)
                move.movpiece = promote;
			}
    }
    }
    return killmov;
}


/*
 *  Store a move in buffer
 */

public function Generate():void
{
Buffer[ ++BufCount] = new cloneMove(Next); /* new copied MOVETYPE() */
}


/*
 *  Generates pawn promotion
 */

public function PawnPromotionGen():void
{
    Next.spe = 1;
    for (var promote:int = queen; promote <= knight; promote++)
    {
        Next.movpiece = promote;
        Generate();
    }
    Next.spe = 0;
}


/*
 *  Generates captures of the piece on nw1 using PieceTab
 */

public function CapMovGen():void
{
    Next.spe = 0;
    Next.content = Board[Next.nw1].piece;
    Next.movpiece = pawn;
    var nextsq:int = Next.nw1 - PawnDir[Player];
    for (var sq:int = nextsq-1; sq <= nextsq+1; sq++)
        if (sq != nextsq)
          if ((sq & 0x88) == 0)
            {
			var o:BOARDTYPE = Board[sq];
            if (o.piece == pawn && o.color == Player)
             {
                Next.old = sq;
                if (Next.nw1 < 8 || Next.nw1 >= 0x70)
                    PawnPromotionGen();
                else
                    Generate();
             }
	    }
            /*  Other captures, starting with the smallest pieces  */
    for (var i:int = OfficerNo[Player]; i >= 0; i--)
    {
		var g:PIECETAB = PieceTab[Player][i];
		var p:int = g.ipiece;
        if (p != empty && p != pawn)
          if (PieceAttacks(p, Player, g.isquare, Next.nw1))
          {
              Next.old = g.isquare;
              Next.movpiece = p;
              Generate();
          }
    }
}


/*
 *  generates non captures for the piece on old
 */

public function NonCapMovGen():void
{
	var newsq:int;
	var dir:int;
	
    Next.spe = 0;
    Next.movpiece = Board[Next.old].piece;
    Next.content = empty;
    switch (Next.movpiece)
    {
        case king :
            for (dir = 7; dir >= 0; dir--)
            {
                newsq = Next.old + DirTab[dir];
                if (!(newsq & 0x88))
                  if (Board[newsq].piece == empty)
                  {
                      Next.nw1 = newsq;
                      Generate();
                  }
            }
            break;
        case knight :
            for (dir = 7; dir >= 0; dir--)
            {
                newsq = Next.old + KnightDir[dir];
                if (!(newsq & 0x88))
                  if (Board[newsq].piece == empty)
                  {
                      Next.nw1 = newsq;
                      Generate();
                  }
            }
            break;
        case queen :
        case rook  :
        case bishop:
            var first:int = 7;
            var last:int = 0;
            if (Next.movpiece == rook) first = 3;
            if (Next.movpiece == bishop) last = 4;
            for (dir = first; dir >= last; dir--)
            {
                var direction:int = DirTab[dir];
                newsq = Next.old + direction;
                /*  Generate all non captures in the direction  */
                while (!(newsq & 0x88))
                {
                    if (Board[newsq].piece != empty) break;
                    Next.nw1 = newsq;
                    Generate();
                    newsq = Next.nw1 + direction;
                }
            }
            break;
        case pawn :
            Next.nw1 = Next.old + PawnDir[Player];  /*  one square forward  */
            if (Board[Next.nw1].piece == empty)
            {
                if (Next.nw1 < 8 || Next.nw1 >= 0x70)
                    PawnPromotionGen();
                else
                {
                    Generate();
                    if (Next.old < 0x18 || Next.old >= 0x60)
                    {
                        Next.nw1 += (Next.nw1 - Next.old); /* 2 squares forward */
                        if (Board[Next.nw1].piece == empty) Generate();
                    }
                }
            }
    }  /* switch */
}


/*
 *  The move generator.
 *  InitMovGen generates all possible moves and places them in a buffer.
 *  Movgen will the generate the moves one by one and place them in next.
 *
 *  On entry:
 *    Player contains the color to move.
 *    MovTab[mc-1] the last performed move.
 *
 *  On exit:
 *    Buffer contains the generated moves.
 *
 *    The moves are generated in the order :
 *      Captures
 *      Castlings
 *      Non captures
 *      E.p. captures
 */

public function InitMovGen():void
{
    var g:PIECETAB;
	var index:int;
	
    Next = new MOVETYPE();
    Buffer = [];
    BufCount = 0; BufPnt = 0;
    /*  generate all captures starting with captures of
        largest pieces  */
    for (index = 1; index <= PawnNo[Opponent]; index++)
    {
		g = PieceTab[Opponent][index];
        if (g.ipiece != empty)
        {
            Next.nw1 = g.isquare;
            CapMovGen();
        }
    }
    Next.spe = 1;
    Next.movpiece = king;
    Next.content = empty;
    for (var castdir:int = (lng-1); castdir <= shrt-1; castdir++)
    {
        var o:CSTPE = CastMove[Player][castdir];
        Next.nw1 = o.castnew;
        Next.old = o.castold;
        if (KillMovGen(Next)) Generate();
    }

    /*  generate non captures, starting with pawns  */
    for (index = PawnNo[Player]; index >= 0; index--)
    {
		g = PieceTab[Player][index];
        if (g.ipiece != empty)
        {
            Next.old = g.isquare;
            NonCapMovGen();
        }
    }
    
    if (Mpre.movpiece == pawn)   /*  E.p. captures  */
        if (Math.abs(Mpre.nw1 - Mpre.old) >= 0x20)
        {
            Next.spe = 1;
            Next.movpiece = pawn;
            Next.content = empty;
            Next.nw1 = (Mpre.nw1 + Mpre.old) / 2;
            for (var sq:int = Mpre.nw1-1; sq <= Mpre.nw1+1;  sq++)
                if (sq != Mpre.nw1)
                    if (!(sq & 0x88))
                    {
                        Next.old = sq;
                        if (KillMovGen(Next)) Generate();
                    }
        }
}


/*
 *  place next move from the buffer in next.  Generate zeromove when there
 *  are no more moves.
 */


 
public function MovGen():void
{
    if (BufPnt >= BufCount)
        Next = ZeroMove;
    else
    {
        Next = Buffer[ ++BufPnt ];
    }
}

/*
 *  Test if the move is legal for color == player in the
 *  given position
 */

public function IllegalMove(move:MOVETYPE):Boolean
{
   Perform(move, false);
   var illegal:Boolean = Attacks(Opponent, PieceTab[Player][0].isquare);
   Perform(move, true);
   return illegal;
}

/*
 *  Prints comment to the game (check, mate, draw, resign)
 */


public function Comment():String
{
    var s:String = "";
	var possiblemove:Boolean = false;
	var checkmate:Boolean = false;

    InitMovGen();
    for(var i:int=0;i<BufCount;i++)
    {
        MovGen();
        if (!IllegalMove(Next)) { possiblemove=true; break; }
    }

    var check:Boolean = Attacks(Opponent, PieceTab[Player][0].isquare);  //calculate check
    //  No possible move means checkmate or stalemate
    if (!possiblemove)
    {
        if (check)
        {
            checkmate = true;
            s+="CheckMate! "+(Opponent==white ? "1-0" : "0-1");
        }
        else
            s+="StaleMate! 1/2-1/2";
    }
    else
        if (MainEvalu >= MATEVALUE - DEPTHFACTOR * 16)
        {
            var nummoves:int = ((MATEVALUE - MainEvalu + 0x40) / (DEPTHFACTOR * 2));
            if(nummoves>0)
             s+= "Mate in " + nummoves + " move" + ((nummoves > 1) ? "s":"") + "!";
        }
    if (check && !checkmate) s+="Check+!";
    else  //test 50 move rule and repetition of moves 
      {
      if (FiftyMoveCnt() >= 100)
         {
         s+="50 Move rule";
         }
      else
         if (Repetition(false) >= 3)
         {
            s+="3 fold Repetition";
         }
         else                //Resign if the position is hopeless
            if (Opponent==ProgramColor && (-25500 < MainEvalu && MainEvalu < -0x880))
               {
               s+=(Opponent==white ? "White" : "Black") + " resigns";
               }
      }
      return s;
}


public function CHR(n:int):String
{
	return String.fromCharCode(n)
}
public function sq2str(square:int):String
{
 return CHR(97+(square&7)) + CHR(49+(square>>>4));
}


/*
 *  convert a move to a string
 */

public function MoveStr(move:MOVETYPE):String
{
    if (move.movpiece != empty)
    {
        if (move.spe && move.movpiece == king)  /*  castling  */
        {
            return "O-O" + ((move.nw1 > move.old) ? "" : "-O");
        }
        else
        {
			var s:String = "";
            var piece:int = Board[ move.old ].piece;
			var ispawn:Boolean = (piece == pawn);
            var c:Boolean = move.content || 
			( ispawn && Math.abs( Math.abs(move.nw1 - move.old)-0x10 )==1 );
            var p:Boolean = (ispawn && move.movpiece<6);
            if(!ispawn) s += " KQRBN".charAt(move.movpiece);
            s += sq2str(move.old);
            s += (c ? 'x' : '-');
            s += sq2str(move.nw1);
            if(p) s += "=" + "QRBN".charAt(move.movpiece-2);
            return s;
        }
    }
    return "?";
}



// generates string of possible moves,
// does not include check,checkmate,stalemate flags
public function GenMovesStr():String
{
    var s:String = "";
    InitMovGen();
    for(var i:int=0;i<BufCount;i++)
    {
        MovGen();
        if (!IllegalMove(Next)) s += "," + MoveStr( Next );
    };
  return s.substr(1);
}

public function printboard():void
{
 for(var v:int=8;(--v)>=0;)
  {
  var s:String = "";
  for(var h:int=0;h<8;h++)
   {
    var o:BOARDTYPE = Board[ (v << 4) + h ];
	var p:String = ".kqrbnp".charAt(o.piece);
    if(o.color == white) p = p.toUpperCase();
    s+=p;
   }
  trace(s);
  }
}

/* === DO MOVE, UNDO MOVE === */

/*
 *  move a piece to a new location on the board
 */

public function MovePiece( nw1:int, old:int ):void
{
    var n:BOARDTYPE = Board[nw1];
	var o:BOARDTYPE = Board[old];
    Board[nw1] = o; Board[old] = n;
    PieceTab[o.color][o.index].isquare = nw1;
}

/*
 *  Calculate the squares for the rook move in castling
 */

public function GenCastSquare( nw1:int, Cast:CASTTYPE ):void
{
    if ((nw1 & 7) >= 4)          /* short castle */
    {
        Cast.castsquare = nw1 - 1;
        Cast.cornersquare = nw1 + 1;
    }
    else                           /* long castle */
    {
        Cast.castsquare = nw1 + 1;
        Cast.cornersquare = nw1 - 2;
    }
}


/*
 *  This public function used in captures.  insquare must not be empty.
 */

public function DeletePiece(insquare:int):void
{
    var o:BOARDTYPE = Board[insquare];
    o.piece = empty;
    PieceTab[o.color][o.index].ipiece = empty;
}


/*
 *  Take back captures
 */

public function InsertPTabPiece( inpiece:int, incolor:int, insquare:int ):void
{
    var o:BOARDTYPE = Board[insquare];
	var q:PIECETAB = PieceTab[incolor][o.index];
    o.piece =  inpiece; q.ipiece  = inpiece;
    o.color = incolor;
    q.isquare = insquare;
}


/*
 *  Used for pawn promotion
 */

public function ChangeType( newtype:int, insquare:int ):void
{
    var o:BOARDTYPE = Board[insquare];
    o.piece = newtype;
    PieceTab[o.color][o.index].ipiece = newtype;
    if (OfficerNo[o.color] < o.index) OfficerNo[o.color] = o.index;
}


/*
 Do move
*/
public function DoMove( move:MOVETYPE ):void
{
 Perform( move, false );
 Player ^= 1; Opponent ^= 1;
}

/*
 Undo move
*/
public function UndoMove():void
{
 Player ^= 1; Opponent ^= 1;
 unPerform();
}

/*
 *  Perform or take back move (takes back if resetmove is true),
 *  and perform the updating of Board and PieceTab.  Player must
 *  contain the color of the moving player, Opponent the color of the
 *  Opponent.
 *
 *  MovePiece, DeletePiece, InsertPTabPiece and ChangeType are used to update
 *  the Board module.
 */


public function sqByAt(square:String):int
{
	return ((square.charCodeAt(0) - 97) +
		(0x10 * (square.charCodeAt(1) - 49)));
}

public function DoMoveByStr( mstr:String ):String
{
 var ret:String = "";
 var old:int = sqByAt( mstr.substr(0, 2) );
 var nw1:int = sqByAt( mstr.substr(2, 2) );
 InitMovGen();
 for(var i:int=0;i<BufCount;i++)
 {
	MovGen();
	if(Next.old == old && Next.nw1 == nw1 &&
		(mstr.length<5 ||
		(Next.spe && ("qrbn").indexOf(mstr.charAt(4))==Next.movpiece-2 )))
	{
	ret = MoveStr( Next );
	DoMove( Next );
	break;
	}
 };
 return ret;
}


public function Perform( move:MOVETYPE, resetmove:Boolean ):void
{
    if (resetmove)
    {
        MovePiece(move.old, move.nw1);
        if (move.content != empty)
            InsertPTabPiece(move.content, Opponent, move.nw1);
    }
    else         
    {
        if (move.content != empty)
            DeletePiece(move.nw1);
        MovePiece(move.nw1, move.old);
    }

    if (move.spe)
    {
        if (move.movpiece == king)
        {
			var Cast:CASTTYPE = new CASTTYPE();
            GenCastSquare(move.nw1, Cast);
            if (resetmove)
            {
                MovePiece(Cast.cornersquare, Cast.castsquare);
            }
            else
            {
                MovePiece(Cast.castsquare, Cast.cornersquare);
            }
        }
        else
        {
            if (move.movpiece == pawn)
            {
                var epsquare:int = (move.nw1 & 7) + (move.old & 0x70); /* E.p. capture */
                if (resetmove)
                    InsertPTabPiece(pawn, Opponent, epsquare);
                else
                    DeletePiece(epsquare);
            }
            else
            {
                if (resetmove)
                    ChangeType(pawn, move.old);
                else
                    ChangeType(move.movpiece,move.nw1);
            }
        }
    }

    if(resetmove)
    {
	mc--; MovTab.pop();
    }
    else
    {
	MovTab[mc++] = new cloneMove(move);
	if( MovTab.length<=mc ) MovTab[mc] = new MOVETYPE();
    }
    Mo = MovTab[mc]; Mpre = MovTab[mc-1];
}

/* simply undo last move in searching */
public function unPerform():void { Perform( Mpre, true); }

/*
 * Compare two moves
 */

public function EqMove( a:MOVETYPE, b:MOVETYPE ):Boolean
{
 return (a.movpiece == b.movpiece && a.nw1 == b.nw1 && a.old == b.old &&
       a.content == b.content && a.spe == b.spe);
}

/* === EVALUATE === */

// creates objects for 3-dim arrays
public function arr2xN(a:Array, n:int):void
	{
	a[0] = []; a[1] = [];
	for (var i:int = 0; i < n; i++)
		{
		a[0][i] = []; a[1][i] = []
		};
	}

public const TOLERANCE:int = 8;  /*  Tolerance width  */
public const EXCHANGEVALUE:int =32;
     /*  Value for exchanging pieces when ahead (not pawns)  */
public const ISOLATEDPAWN:int = 20;
    /*  Isolated pawn.  Double isolated pawn is 3 * 20  */
public const DOUBLEPAWN:int = 8;   /*  Double pawn  */
public const SIDEPAWN:int = 6;   /*  Having a pawn on the side  */
public const CHAINPAWN:int = 3;   /*  Being covered by a pawn  */
public const COVERPAWN:int = 3;   /*  covering a pawn  */
public const NOTMOVEPAWN:int = 2;   /*  Penalty for moving pawn  */
public const BISHOPBLOCKVALUE:int = 20;
    /*  Penalty for bishop blocking d2/e2 pawn  */
public const ROOKBEHINDPASSPAWN:int = 16;   /*  Bonus for Rook behind passed pawn  */

/* constants and globals */

public const PieceValue:Array = [0, 0x1000, 0x900, 0x4c0, 0x300, 0x300, 0x100];	// [7]
public const distan:Array = [ 3, 2, 1, 0, 0, 1, 2, 3 ];	// [8]
    /*  The value of a pawn is the sum of Rank and file values.
        The file value is equal to PawnFileFactor * (Rank Number + 2) */
public const pawnrank:Array = [0, 0, 0, 2, 4, 8, 30, 0];	// [8]	
public const passpawnrank:Array = [0, 0, 10, 20, 40, 60, 70, 0];	// [8]
public const pawnfilefactor:Array = [0, 0, 2, 5, 6, 2, 0, 0];	// [8]
public const castvalue:Array = [4, 32];	// [2]  /*  Value of castling  */

public const filebittab:Array = [1, 2, 4, 8, 0x10, 0x20, 0x40, 0x80];	// [8]

public var totalmaterial:int = 0;
public var pawntotalmaterial:int = 0;
public var material:int = 0;

  /*  Material level of the game
        (early middlegame = 43 - 32, endgame = 0)  */
public var materiallevel:int = 0;
public const squarerankvalue:Array = [ 0, 0, 0, 0, 1, 2, 4, 4];	// [8]

public var mating:Boolean = false;  /*  mating evaluation public function is used  */

public var PVTable:Array = []; //[2][7][0x78]

public var RootValue:int = 0;

// generates array
public function PwBtList():Array
{
	var a:Array = [];
	for (var i:int = 0; i <= MAXPLY; i++)
		a[i] = new PAWNBITTYPE();
	return a;
}
public var pawnbit:Array = [];

public const MAXINT:int = 32767;

public var bitcount:Array = [];	// count the number of set bits in b (0..255)
public function prepareBitCounts():void
{
 for(var i:int=0; i<256; i++)
  {
   var b:int = i;
   var c:int = 0;
   while (b)
    {
    if (b & 1) c++;
    b >>>= 1;
    }
   bitcount[i] = c;
  }
}
 

/*
 *  Calculate value of the pawn structure in pawnbit[color][depth]
 */

public function pawnstrval( depth:int, color:int ):int
{
	/*  contains FILEs with isolated pawns  */

    var o:PAWNBITTYPE = pawnbit[color][depth];
	var v:int = o.one;
	var d:int = o.dob;
    var iso:int = v &  ~((v << 1) | (v >>> 1));
    return (-(bitcount[d] * DOUBLEPAWN +
            bitcount[iso] * ISOLATEDPAWN +
	    bitcount[iso & d] * ISOLATEDPAWN * 2));
}


/*
 *  calculate the value of the piece on the square
 */

public function PiecePosVal( piece:int, color:int, square:int ):int
{
    return (PieceValue[piece] + PVTable[color][piece][square]);
}

/*
 *  calculates piece-value table for the static evaluation public function
 */

public function CalcPVTable():void
{
    /*  Bit tables for static pawn structure evaluation  */
	
	// genertes 3dim arrays PVTable
    arr2xN(PVTable, 7); //[2][7][0x78]
	  
    /*  Importance of an attack of the square  */
    var attackvalue:Array = [[],[]];	//[2][0x78]
    
    var pawntab:Array = [[],[]];	// [2][8]
    
    /*  Value of squares controlled from the square  */
    var pvcontrol:Array = [];
	arr2xN(pvcontrol, 5); //[2][5][0x78]

    var losingcolor:int;     /*  the color which is being mated  */
    var posval:int;                /*  The positional value of piece  */
    var attval:int;                /*  The attack value of the square  */
    var line:int;             /*  The file of the piece  */
    var rank:int;             /*  The rank of the piece  */
    var dist:int;       /*  Distance to center */
	var kingdist:int;	/*    to opponents king */
    var cast:int;             /*  Possible castlings  */
    var direct:int;              /*  Indicates direct attack  */
    var cnt:int;                   /*  Counter for attack values  */
    var strval:int;                /*  Pawnstructure value  */
    var color:int;
	var oppcolor:int; /*  Color and opponents color  */
    var piececount:int;      /*  Piece counter  */
    var square:int;         /*  Square counter  */
    var dir:int;               /*  Direction counter  */
    var sq:int;         /*  Square counter  */
    var t:int;			/*  temporary junk  */  
	var t2:int; var t3:int;
	var o:BOARDTYPE;
	var g:PAWNBITTYPE;
	var p:int;

    /*  Calculate SAMMAT, PAWNSAMMAT and Material  */
    material = 0;
    pawntotalmaterial = 0;
    totalmaterial = 0;
    mating = false;

    for (square = 0; square < 0x78; square++)
        if (!(square & 0x88))
	{
            o = Board[square];
			p = o.piece;
            if (p != empty)
                if (p != king)
                {
                    t = PieceValue[p];
                    totalmaterial += t;
                    if (p == pawn)
                        pawntotalmaterial += PieceValue[pawn];
                    if (o.color == white) t = -t;
                    material -= t;
                }
	}
    materiallevel = Math.max(0, totalmaterial - 0x2000) / 0x100;
    /*  Set mating if weakest player has less than the equivalence
    of two bishops and the advantage is at least a rook for a bishop  */
    losingcolor = ((material < 0) ? white : black);
    var v:int = Math.abs(material);
    mating = ((totalmaterial - v) / 2 <= PieceValue[bishop] * 2)
        && (v >= PieceValue[rook] - PieceValue[bishop]);
    /*  Calculate ATTACKVAL (importance of each square)  */
    for (rank = 0; rank < 8; rank++)
        for (line = 0; line < 8; line++)
        {
            square = (rank << 4) + line;
            attval = Math.max(0, 8 - 3 * (distan[rank] + distan[line]));
                    /*  center importance */
                    /*  Rank importrance  */
            for (color = white; color <= black; color++)
            {
                attackvalue[color][square] = ((squarerankvalue[rank] * 3 *
                        (materiallevel + 8)) >> 5) + attval;
                square ^= 0x70;
            }
        }
    for (color = white; color <= black; color++)
    {
        oppcolor = (color ^ 1);
        cast = CalcCastling( oppcolor );
        if (cast != shrt && materiallevel > 0)
            /*  Importance of the 8 squares around the opponent's King  */
        for (dir = 0; dir < 8; dir++)
        {
            sq = PieceTab[oppcolor][0].isquare + DirTab[dir];
            if (!(sq & 0x88))
                attackvalue[color][sq] += ((12 * (materiallevel + 8)) >> 5);
        }
    }

    /*  Calculate PVControl  */
    for (square = 0x77; square >=0; square--)
        if(!(square & 0x88))
            for (color = white; color <= black; color++)
                for (piececount = rook; piececount <= bishop; piececount++)
                    pvcontrol[color][piececount][square] = 0;
    for (square = 0x77; square >=0; square--)
        if(!(square & 0x88))
            for (color = white; color <= black; color++)
            {
                for (dir = 7; dir >= 0; dir--)
                {
                    piececount = ((dir < 4) ? rook : bishop);
                /*  Count value of all attacs from the square in
                    the Direction.
                    The Value of attacking a Square is Found in ATTACKVAL.
                    Indirect Attacks (e.g. a Rook attacking through
                    another Rook) counts for a Normal attack,
                    Attacks through another Piece counts half  */
                    cnt = 0;
                    sq = square;
                    direct = 1;
                    do
                    {
                        sq += DirTab[dir];
                        if (sq & 0x88) break;	//goto TEN
                        t = attackvalue[color][sq];
                        if (direct)
                            cnt += t;
                        else
                            cnt += (t >> 1);
                        p = Board[sq].piece;
                        if (p != empty)
                            if ((p != piececount)
                              && (p != queen))
                                direct = 0;
                    } while (p != pawn);
/*TEN:*/            pvcontrol[color][piececount][square] += (cnt >> 2);
                }
            }

    /*  Calculate PVTable, value by value  */
    for (square = 0x77; square >= 0; square--)
      if (!(square & 0x88))
      {
         for (color = white; color <= black; color++)
         {
            oppcolor = (color ^ 1);
            line = square & 7;
            rank = square >> 4;
            if (color == black) rank = 7 - rank;
            dist = distan[rank] + distan[line];
			v = PieceTab[oppcolor][0].isquare;
            kingdist = Math.abs((square >> 4) - (v >> 4)) + ((square - v) & 7);
            for (piececount = king; piececount <= pawn; piececount++)
            {
                posval = 0;        /*  Calculate POSITIONAL Value for  */
                                   /*  The piece on the Square  */
                if (mating && (piececount != pawn))
                {
                    if (piececount == king)
                        if (color == losingcolor)  /*  Mating evaluation  */
                        {
                            posval = 128 - 16 * distan[rank] - 12 * distan[line];
                            if (distan[rank] == 3)
                                posval -= 16;
                        }
                        else
                        {
                            posval = 128 - 4 * kingdist;
                            if ((distan[rank] >= 2) || (distan[line] == 3))
                                posval -= 16;
                        }
                }
                else
                {
                    t = pvcontrol[color][rook][square];
                    t2 = pvcontrol[color][bishop][square];
                    /*  Normal evaluation public function  */
                    switch (piececount)
                    {
                        case king :
                            if (materiallevel <= 0) posval = -2 * dist;
                            break;
                        case queen :
                            posval = (t + t2) >> 2;
                            break;
                        case rook :
                            posval = t;
                            break;
                        case bishop :
                            posval = t2;
                            break;
                        case knight :
                            cnt = 0;
                            for (dir = 0; dir < 8; dir++)
                            {
                                sq = square + KnightDir[dir];
                                if (!(sq & 0x88))
                                    cnt += attackvalue[color][sq];
                            }
                            posval = (cnt >> 1) - dist * 3;
                            break;
                        case pawn :
                            if ((rank != 0) && (rank != 7))
                                posval = pawnrank[rank] +
                                  pawnfilefactor[line] * (rank + 2) - 12;
                    }
                }
                PVTable[color][piececount][square] = posval;
            }
         }
      }

    /*  Calculate pawntab (indicates which squares contain pawns)  */

    for (color = white; color <= black; color++)
        for (rank = 0; rank < 8; rank++)
            pawntab[color][rank] = 0;
    for (square = 0x77; square >= 0; square--)
        if (!(square & 0x88))
	{
            o = Board[square];
            if (o.piece == pawn)
            {
                rank = square >> 4;
                if (o.color == black) rank = 7 - rank;
                pawntab[o.color][rank] |= filebittab[square & 7];
            }
	}
    for (color = white; color <= black; color++)  /*  initialize pawnbit  */
    {
        g = pawnbit[color][0]; g.dob = 0; g.one = 0;
        for (rank = 1; rank < 7; rank++)
        {
            t = pawntab[color][rank];
            g.dob |= (g.one & t);
            g.one |= t;
        }
    }
    /*  Calculate pawnstructurevalue  */
    RootValue = pawnstrval(0, Player) - pawnstrval(0, Opponent);

    /*  Calculate static value for pawn structure  */
    for (color = white; color <= black; color++)
    {
        oppcolor = (color ^ 1);
        var pawnfiletab:int = 0;
        var leftsidetab:int = 0;
        var rightsidetab:int = 0;
        var behindoppass:int = 0;
        var oppasstab:int = 0xff;
        for (rank = 1; rank < 7; rank++)
        /*  Squares where opponents pawns are passed pawns  */
        {
            oppasstab &= (~(pawnfiletab | leftsidetab | rightsidetab));
            /*  Squares behind the opponents passed pawns  */
            behindoppass |= (oppasstab & pawntab[oppcolor][7 - rank]);
            /*  squares which are covered by a pawn  */
            var leftchaintab:int = leftsidetab;
            var rightchaintab:int = rightsidetab;
            pawnfiletab = pawntab[color][rank]; /*  squares w/ pawns  */
            /*  squares w/ a pawn beside them  */
            leftsidetab = (pawnfiletab << 1) & 0xff;
            rightsidetab = (pawnfiletab >> 1) & 0xff;
            var sidetab:int = leftsidetab | rightsidetab;
            var chaintab:int = leftchaintab | rightchaintab;
            /*  squares covering a pawn  */
            t = pawntab[color][rank+1];
            var leftcovertab:int = (t << 1) & 0xff;
            var rightcovertab:int = (t >> 1 ) & 0xff;
            sq = rank << 4;
            if (color == black) sq ^= 0x70;
            var bit:int = 1;
            while (bit)
            {
                strval = 0;
                if (bit & sidetab)
                    strval = SIDEPAWN;
                else if (bit & chaintab)
                    strval = CHAINPAWN;
                if (bit & leftcovertab)
                    strval += COVERPAWN;
                if (bit & rightcovertab)
                    strval += COVERPAWN;
                if (bit & pawnfiletab)
                    strval += NOTMOVEPAWN;
                PVTable[color][pawn][sq] += strval;
                if ((materiallevel <= 0) || (oppcolor != ProgramColor))
                {
                    if (bit & oppasstab)
                        PVTable[oppcolor][pawn][sq] += passpawnrank[7 - rank];
                    if (bit & behindoppass)
                    {
                        t = sq ^ 0x10;
                        for (t3 = black; t3 >= white ; t3--)
                        {
                            PVTable[t3][rook][sq] += ROOKBEHINDPASSPAWN;
                            if (rank == 6)
                                PVTable[t3][rook][t] += ROOKBEHINDPASSPAWN;
                        }
                    }
                }
                sq++;
                bit = (bit << 1) & 0xff;
            }
        }
    }
    /*  Calculate penalty for blocking center pawns with a bishop  */
    for (sq = 3; sq < 5; sq ++)
    {
        o = Board[sq + 0x10];
        if ((o.piece == pawn) && (o.color == white))
            PVTable[white][bishop][sq+0x20] -= BISHOPBLOCKVALUE;
        o = Board[sq + 0x60];
        if ((o.piece == pawn) && (o.color == black))
            PVTable[black][bishop][sq+0x50] -= BISHOPBLOCKVALUE;
    }
    for (square = 0x77; square >= 0; square--) /*  Calculate RootValue  */
        if (!(square & 0x88))
	{
            o = Board[square]; p = o.piece;
            if (p != empty)
                if (o.color == Player)
                    RootValue +=
                        PiecePosVal(p, Player, square);
                else
                    RootValue -=
                        PiecePosVal(p, Opponent, square);
	}
}

/*
 *  Update pawnbit and calculates value when a pawn is removed from line
 */

public function decpawnstrval(color:int, line:int):int
{
    var o:PAWNBITTYPE = pawnbit[color][Depth];
    var t:int = ~filebittab[line];
    o.one = (o.one & t) | o.dob;
    o.dob &= t;
    return (pawnstrval(Depth, color) - pawnstrval(Depth - 1, color));
}

/*
 *  Update pawnbit and calculates value when a pawn moves
 *  from old to nw1 file
 */

public function movepawnstrval(color:int, nw1:int, old:int):int
{
    var o:PAWNBITTYPE = pawnbit[color][Depth];
    var t:int = filebittab[nw1];
    var t2:int = ~filebittab[old];
    o.dob |= (o.one & t);
    o.one = ((o.one & t2) | o.dob) | t;
    o.dob &= t2;
    return (pawnstrval(Depth, color) - pawnstrval(Depth - 1, color));
}

/*
 *  Calculate STATIC evaluation of the move
 */

public function StatEvalu(move:MOVETYPE):int
{
    var value:int = 0;
    if (move.spe)
        if (move.movpiece == king)
        {
            var Cast:CASTTYPE = new CASTTYPE();
            GenCastSquare(move.nw1, Cast);
            value = PiecePosVal(rook, Player, Cast.castsquare) -
                    PiecePosVal(rook,Player, Cast.cornersquare);
            if (move.nw1 > move.old)
                value += castvalue[shrt-1];
            else
                value += castvalue[lng-1];
        }
        else if (move.movpiece == pawn)
        {
            var epsquare:int = move.nw1 - PawnDir[Player];  /*  E.p. capture  */
            value = PiecePosVal(pawn, Opponent, epsquare);
        }
        else            /*  Pawnpromotion  */
            value = PiecePosVal(move.movpiece, Player, move.old) -
                    PiecePosVal(pawn, Player, move.old) +
                    decpawnstrval(Player, move.old & 7);

    if (move.content != empty)  /*  normal moves  */
        {
            value += PiecePosVal(move.content, Opponent, move.nw1);
            /*  Penalty for exchanging pieces when behind in material  */
            if (Math.abs(MainEvalu) >= 0x100)
                if (move.content != pawn)
                    if ((ProgramColor == Opponent) == (MainEvalu >= 0))
                        value -= EXCHANGEVALUE;
        }
	/*  calculate pawnbit  */
    pawnbit[black][Depth].copyPwBt( pawnbit[black][Depth-1] );
    pawnbit[white][Depth].copyPwBt( pawnbit[white][Depth-1] );
    if ((move.movpiece == pawn) && ((move.content != empty) || move.spe))
            value += movepawnstrval(Player, move.nw1 & 7, move.old & 7);
    if ((move.content == pawn) || move.spe && (move.movpiece == pawn))
            value -= decpawnstrval(Opponent, move.nw1 & 7);
        /*  Calculate value of move  */
    return (value + PiecePosVal(move.movpiece, Player, move.nw1)-
                PiecePosVal(move.movpiece, Player, move.old));
}

/* === SEARCH with own MOVEGEN 2 === */

/*
 *  Global Variables for this module
 */

public var Mo:MOVETYPE;		// pointer to MovTab[mc] - current move
public var Mpre:MOVETYPE;	// pointer to MovTab[mc-1] - previous move by opponent

public var Analysis:int = 1;	// to display
public var MateSrch:int = 0;	// set 1 to search mate only

public var MaxDepth:int = 0;	// max.ply reached (=Depth-1)
public var LegalMoves:int = 0;
public var SkipSearch:Boolean = false;

public const rank7:Array = [0x60, 0x10];

public var timetimer:TIMERTYPE = new TIMERTYPE();

public var Nodes:int = 0;

public var killingmove:Array = [[],[]];	// [2][MAXPLY+1]
public var checktab:Array = [];	//[MAXPLY+3], start from 1, not 0
/*  Square of eventual pawn on 7th rank  */
public var passedpawn:Array = [];	// [MAXPLY+4], start from 2

public var alphawindow:int = 0;  /*  alpha window value  */
public var repeatevalu:int = 0;  /*  MainEvalu at ply one  */

public var startinf:INFTYPE = new INFTYPE();     /*  Inf at first ply  */

public const mane:int = 0;
public const specialcap:int = 1;
public const kill:int = 2;
public const norml:int = 3;	/*  move type  */

public const LOSEVALUE:int  = 0x7D00;
public const MATEVALUE:int  = 0x7C80; 
public const DEPTHFACTOR:int  = 0x80;

public var MainLine:MLINE = new MLINE(MAXPLY+2);
public var MainEvalu:int = 0;

public var preDispMv:MOVETYPE;
public var mxdpdisp:int = 0;

public function DisplayMove():void
{
   if (Analysis && Depth==1)
      {
	var move:MOVETYPE = MainLine.a[1];
	if(move.movpiece && ( mxdpdisp<MaxDepth || !EqMove(preDispMv,move)))
	{
	preDispMv = new cloneMove(move); mxdpdisp = MaxDepth;
	trace(''+ MaxDepth + " ply " +
	 	timetimer.elapsed + " sec. " + Nodes + " nodes " +
		sq2str(move.old)+sq2str(move.nw1));
	PrintBestMove();
	}
      }
}

public function PrintBestMove():void
{
   var s:String = "";
   var dep:int = 1;
   while(1)
   {
	var move:MOVETYPE = MainLine.a[dep++];
	if(move.movpiece == empty) break;
	s += sq2str(move.old) + sq2str(move.nw1) + " ";
   }
   
   trace('ev:' + EvValStr() + " " + s);
}

// evalvalue as string
public function EvValStr():String
{
 var e:Number = (MainEvalu/256);
 if(Player==black) e=-e;
 return (e>0 ? "+" : "") + e.toFixed(2);
}

/*
 *  Initialize killingmove, checktab and passedpawn
 */
 
public function clearkillmove():void
{
    for (var dep:int = 0; dep <= MAXPLY; dep++)
        for (var i:int = 0; i < 2; i++)
            killingmove[i][dep] = ZeroMove;
    checktab[0] = 0;
    passedpawn[0] = -1;  /*  No check at first ply  */
    passedpawn[1] = -1;
    /*  Place eventual pawns on 7th rank in passedpawn  */
    for (var col:int = white; col <= black; col++)
        for (var sq:int  = rank7[col]; sq <= rank7[col] + 7; sq++)
	{
            var o:BOARDTYPE = Board[sq];
            if ((o.piece == pawn) && (o.color == col))
                if (col == Player)
                    passedpawn[0] = sq;
                else
                    passedpawn[1] = sq;
	}
}

/*
 *  Update killingmove using bestmove
 */

public function updatekill(bestmove:MOVETYPE):void
{
    if (bestmove.movpiece != empty)
    {
    /*  Update killingmove unless the move is a capture of last
        piece moved  */
        if ((Mpre.movpiece == empty) || (bestmove.nw1 != Mpre.nw1))
            if ((killingmove[0][Depth].movpiece == empty) ||
                (EqMove(bestmove, killingmove[1][Depth])))
            {
                killingmove[1][Depth] = new cloneMove( killingmove[0][Depth] );
                killingmove[0][Depth] = new cloneMove( bestmove );
            }
            else if (!EqMove(bestmove, killingmove[0][Depth]))
                killingmove[1][Depth] = new cloneMove( bestmove );
    }
}  /*  Updatekill  */



/*
 *  Test if move has been generated before
 */

public function generatedbefore(P:PARAMTYPE):Boolean
{
    if (P.S.movgentype != mane)
    {
        if( EqMove(Mo, P.bestline.a[Depth]) ) return true;

        if (!P.S.capturesearch)
            if (P.S.movgentype != kill)
                for (var i:int = 0; i < 2; i++)
                    if( EqMove( Mo, killingmove[i][Depth]) )
                        return true;
    }
    return false;
}


/*
 *  Test cut-off.  Cutval cantains the maximal possible evaluation
 */

public function cut(cutval:int,P:PARAMTYPE):int
{
    var ct:int = 0;
    if (cutval <= P.alpha)
    {
        ct = 1;
        if (P.S.maxval < cutval) P.S.maxval = cutval;
    }
    return ct;
}


/*
 *  Perform move, calculate evaluation, test cut-off, etc
 */
public function tkbkmv():Boolean { unPerform(); return true; }

public function update(P:PARAMTYPE):Boolean
{
    Nodes++;
    P.S.nextply = P.ply - 1;      /*  Calculate next ply  */
    if (MateSrch)  /*  MateSrch  */
    {
        Perform( Mo, false );  /*  Perform Move on the board  */
        /*  Check if Move is legal  */
        if (Attacks(Opponent, PieceTab[Player][0].isquare))
		return tkbkmv(); //TAKEBACKMOVE
        if (Depth==1) LegalMoves++;
        checktab[Depth] = 0;
        passedpawn[1+Depth] = -1;
        var d:INFTYPE = P.S.next;
		d.value = 0; d.evaluation = 0;
        if (P.S.nextply <= 0)  /*  Calculate chech and perform evt. cut-off  */
        {
            if (!P.S.nextply)
                checktab[Depth] = Attacks(Player,
                    PieceTab[Opponent][0].isquare);
            if (!checktab[Depth])
                if (cut(P.S.next.value, P))
			return tkbkmv(); //TAKEBACKMOVE
        }

        DisplayMove();
        return false;	//ACCEPTMOVE
    }
    
    /*  Make special limited capturesearch at first iteration  */
    if (MaxDepth <= 1)
        if (P.S.capturesearch && Depth >= 3)
	{
            if (!((Mo.content < Mo.movpiece)
                || (P.S.movgentype == specialcap) || (Mo.old == MovTab[mc-2].nw1)))
		{
		DisplayMove();
                return true;	// CUTMOVE
		}
	}
            /*  Calculate nxt static incremental evaluation  */
    P.S.next.value = -P.inf.value + StatEvalu(Mo);
    /*  Calculate checktab (only checks with moved piece are calculated)
        Giving Check does not count as a ply  */
    checktab[Depth] = PieceAttacks(Mo.movpiece, Player, Mo.nw1, PieceTab[Opponent][0].isquare);
    if (checktab[Depth]) P.S.nextply = P.ply;
    /*  Calculate passedpawn.  Moving a pawn to 7th rank does not
        count as a ply  */
    passedpawn[1+Depth] = passedpawn[1+(Depth-2)];
    if (Mo.movpiece == pawn)
        if ((Mo.nw1 < 0x18) || (Mo.nw1 >= 0x60))
        {
            passedpawn[1+Depth] = Mo.nw1;
            P.S.nextply = P.ply;
        }
        /*  Perform selection at last ply and in capture search  */
    var selection:Boolean = ((P.S.nextply <= 0) && !checktab[Depth] && (Depth > 1));
    if (selection)   /*  check evaluation  */
        if (cut(P.S.next.value + 0, P)) { DisplayMove(); return true; }	// CUTMOVE
    Perform( Mo, false );  /*  perform move on the board  */
    /*  check if move is legal  */
    if (Attacks(Opponent, PieceTab[Player][0].isquare))
		return tkbkmv(); //TAKEBACKMOVE
    var p:int = passedpawn[1+Depth];
    if (p >= 0)  /*  check passedpawn  */
        {
	var b:BOARDTYPE = Board[p];
        if (b.piece != pawn || b.color != Player)
            passedpawn[1+Depth] = -1;
        }
    if (Depth==1)
    {
        LegalMoves++;
        P.S.next.value += (Math.random()*4);
    }
    P.S.next.evaluation = P.S.next.value;
//ACCEPTMOVE:
    DisplayMove();
    return false;
}


/*
 *  Calculate draw bonus/penalty, and set draw if the game is a draw
 */

public function drawgame(S:SEARCHTYPE):Boolean
{
    var o:INFTYPE = S.next;
	var searchfifty:int;
	var searchrepeat:int;
		
    if (Depth == 2)
    {
        searchfifty = FiftyMoveCnt();
        searchrepeat = Repetition(false);
        if (searchrepeat >= 3)
        {
            o.evaluation = 0;
            return true;
        }
        var drawcount:int = 0;
        if (searchfifty >= 96)  /*  48 moves without pawn moves or captures */
            drawcount = 3;
        else
        {
            if (searchrepeat >= 2)  /*  2nd repetition  */
                drawcount = 2;
            else if (searchfifty >= 20)  /*  10 moves without pawn moves or  */
               drawcount = 1;        /*  captures  */
        }
		var n:int = ((repeatevalu * drawcount) >>> 2);	// int
        o.value += n;
        o.evaluation += n;	//int
    }
    if (Depth >= 4)
    {
        searchrepeat = Repetition(true);
        if (searchrepeat >= 2)       /*  Immediate repetition counts as  */
        {                            /*  a draw                          */
            o.evaluation = 0;
            return true;
        }
    }
    return false;
}

// This is a very slow "deep objects copy" function
public function copyMLine(b:Array, a:Array):void
	{
	var i:int = 0;
	b.length = 0;
	while (i < a.length) b.push( new cloneMove(a[i++]));
	}
		
/*
 *  Update bestline and MainEvalu using line and maxval
 */

public function updatebestline(P:PARAMTYPE):void
{
    copyMLine( P.bestline.a, P.S.line.a );
    P.bestline.a[Depth] = new cloneMove( Mo );	/* copies to new MOVETYPE() */

    if (Depth==1)
    {
        MainEvalu = P.S.maxval;
        if (MateSrch) P.S.maxval = alphawindow;
		DisplayMove();
    }
}


/*
 *  The inner loop of the search procedure.  MovTab[mc] contains the move.
 */

public function loopbody(P:PARAMTYPE):Boolean
{
    if (generatedbefore(P)) return false;
    if (Depth < MAXPLY)
    {
        if (P.S.movgentype == mane)
			{
            copyMLine( P.S.line.a, P.bestline.a );
			}
        P.S.line.a[Depth+1] = ZeroMove;
    }
    /*  principv indicates principal variation search  */
    /*  Zerowindow indicates zero - width alpha - beta window  */
    P.S.next.principv = false;
    P.S.zerowindow = false;
    if (P.inf.principv)
        if (P.S.movgentype == mane)
            P.S.next.principv = (P.bestline.a[Depth+1].movpiece != empty);
        else
            P.S.zerowindow = (P.S.maxval >= P.alpha);
	    
    while(1)
    {
//REPEATSEARCH:

    if (update(P)) return false;
    var f:Boolean = true;
    if (MateSrch)  /*  stop evt. search  */
        if ((P.S.nextply <= 0) && !checktab[Depth]) f=false;
    if (f && drawgame(P.S)) f=false;
    if (f && Depth >= MAXPLY) f=false;
    if(f)
    {
    /*  Analyse nextply using a recursive call to search  */
    var oldplayer:int = Player;
    Player = Opponent;
    Opponent = oldplayer;
    Depth++;
    if (P.S.zerowindow)
        P.S.next.evaluation = -search(-P.alpha - 1, -P.alpha, P.S.nextply,
                P.S.next, P.S.line );
    else
        P.S.next.evaluation = -search(-P.beta, -P.alpha, P.S.nextply,
                P.S.next, P.S.line );
    Depth--;
    oldplayer = Opponent;
    Opponent = Player;
    Player = oldplayer;
    }
//NOTSEARCH:
    unPerform();  /*  take back move  */
    if (SkipSearch)
        return true;
    if (Analysis)
    {
     if (MainEvalu > alphawindow) SkipSearch = timeused();
     if (MaxDepth <= 1) SkipSearch = false;
    }
    P.S.maxval = Math.max(P.S.maxval, P.S.next.evaluation);  /*  Update Maxval  */
    if( EqMove(P.bestline.a[Depth], Mo ))  /*  Update evt. bestline  */
        updatebestline(P);
    if (P.alpha < P.S.maxval)      /*  update alpha and test cutoff */
    {
        updatebestline(P);
        if (P.S.maxval >= P.beta)
            return true;
        /*  Adjust maxval (tolerance search)  */
        if (P.ply >= 2  && P.inf.principv && !P.S.zerowindow)
            P.S.maxval = Math.min(P.S.maxval + TOLERANCE, P.beta - 1);
        P.alpha = P.S.maxval;
        if (P.S.zerowindow && ! SkipSearch)
        {
            /*  repeat search with full window  */
            P.S.zerowindow = false;
            continue; //goto REPEATSEARCH;
        }
    }
    break;
    }
    
    return SkipSearch;
}


/*
 *  generate  pawn promotions
 */

public function pawnpromotiongen(P:PARAMTYPE):Boolean
{
    Mo.spe = 1;
    for (var promote:int = queen; promote <= knight; promote++)
    {
        Mo.movpiece = promote;
        if (loopbody(P)) return true;
    }
    Mo.spe = 0;
    return false;
}


/*
 *  Generate captures of the piece on Newsq
 */

public function capmovgen( newsq:int, P:PARAMTYPE ):Boolean
{
    Mo.content = Board[newsq].piece;
    Mo.spe = 0;
    Mo.nw1 = newsq;
    Mo.movpiece = pawn;  /*  pawn captures  */
    var nxtsq:int = Mo.nw1 - PawnDir[Player];
    for (var sq:int = nxtsq - 1; sq <= nxtsq + 1; sq++)
        if (sq != nxtsq)
            if (!(sq & 0x88))
			{
				var b:BOARDTYPE = Board[sq];
                if (b.piece == pawn && b.color == Player)
                {
                    Mo.old = sq;
                    if (Mo.nw1 < 8 || Mo.nw1 >= 0x70)
                    {
                        if (pawnpromotiongen(P))
                            return true;
                    }
                    else if (loopbody(P))
                        return true;
                }
			}
    for (var i:int = OfficerNo[Player]; i >= 0; i--)  /*  other captures  */
	{
		var m:PIECETAB = PieceTab[Player][i];
		var p:int = m.ipiece;
		var q:int = m.isquare;

        if (p != empty && p != pawn)
            if (PieceAttacks(p, Player, q, newsq))
            {
                Mo.old = q;
                Mo.movpiece = p;
                if (loopbody(P)) return true;
            }
	}
    return false;
}
              

/*
 *  Generates non captures for the piece on oldsq
 */

public function noncapmovgen( oldsq:int, P:PARAMTYPE ):Boolean
{
	var dir:int;
    var newsq:int;
	
    Mo.spe = 0;
    Mo.old = oldsq;
    Mo.movpiece = Board[oldsq].piece;
    Mo.content = empty;

    switch (Mo.movpiece)
    {
        case king :
            for (dir = 7; dir >= 0; dir--)
            {
                newsq = Mo.old + DirTab[dir];
                if (!(newsq & 0x88))
                    if (Board[newsq].piece == empty)
                    {
                        Mo.nw1 = newsq;
                        if (loopbody(P))
                             return true;
                    }
            }
            break;
        case knight :
            for (dir = 7; dir >= 0; dir--)
            {
                newsq = Mo.old + KnightDir[dir];
                if (!(newsq & 0x88))
                    if (Board[newsq].piece == empty)
                    {
                        Mo.nw1 = newsq;
                        if (loopbody(P))
                            return true;
                    }
            }
            break;
        case queen :
        case rook  :
        case bishop :
            var first:int = 7;
            var last:int = 0;
            if (Mo.movpiece == rook) first = 3;
            else if (Mo.movpiece == bishop) last = 4;
            for (dir = first; dir >= last; dir--)
            {
                var direction:int = DirTab[dir];
                newsq = Mo.old + direction;
                while (!(newsq & 0x88))
                {
                    if (Board[newsq].piece != empty) break;	// goto TEN
                    Mo.nw1 = newsq;
                    if (loopbody(P))
                        return true;
                    newsq = Mo.nw1 + direction;
                }
//TEN:
                continue;
            }
            break;
        case pawn :
            /*  One square forward  */
            Mo.nw1 = Mo.old + PawnDir[Player];
            if (Board[Mo.nw1].piece == empty)
                if (Mo.nw1 < 8 || Mo.nw1 >= 0x70)
                {
                    if (pawnpromotiongen(P)) return true;
                }
                else
                {
                    if (loopbody(P))
                        return true;
                    if (Mo.old < 0x18 || Mo.old >= 0x60)
                    {
                        /*  two squares forward  */
                        Mo.nw1 += (Mo.nw1 - Mo.old);
                        if (Board[Mo.nw1].piece == empty)
                            if (loopbody(P))
                                return true;
                    }
               }
    } /*  switch  */
    return false;
}


/*
 *  castling moves
 */

public function castlingmovgen(P:PARAMTYPE):Boolean
{
    Mo.spe = 1;
    Mo.movpiece = king;
    Mo.content = empty;
    for (var castdir:int = (lng-1); castdir <= shrt-1; castdir++)
    {
        var m:CSTPE = CastMove[Player][castdir];
        Mo.nw1 = m.castnew;
        Mo.old = m.castold;
        if (KillMovGen(Mo))
            if (loopbody(P))
                return true;
    }
    return false;
}


/*
 *  e.p. captures
 */

public function epcapmovgen(P:PARAMTYPE):Boolean
{
    if (Mpre.movpiece == pawn)
        if (Math.abs(Mpre.nw1 - Mpre.old) >= 0x20)
        {
            Mo.spe = 1;
            Mo.movpiece = pawn;
            Mo.content = empty;
            Mo.nw1 = (Mpre.nw1 + Mpre.old) / 2;
            for (var sq:int = Mpre.nw1 - 1; sq <= Mpre.nw1 + 1; sq++)
                if (sq != Mpre.nw1)
                    if (!(sq & 0x88))
                    {
                        Mo.old = sq;
                        if (KillMovGen(Mo))
                            if (loopbody(P))
                                return true;
                    }
        }
    return false;
}


/*
 *  Generate the next move to be analysed.
 *   Controls the order of the movegeneration.
 *      The moves are generated in the order:
 *      Main variation
 *      Captures of last moved piece
 *      Killing moves
 *      Other captures
 *      Pawnpromotions
 *      Castling
 *      Normal moves
 *      E.p. captures
 */

public function searchmovgen(P:PARAMTYPE):void
{
    var w:MOVETYPE = P.bestline.a[Depth];

    Mo.copyMove(ZeroMove);
    
    /*  generate move from the main variation  */
    if (w.movpiece != empty)
    {
        Mo.copyMove( w );
        P.S.movgentype = mane;
        if (loopbody(P)) return;
    }
    if (Mpre.movpiece != empty)
        if (Mpre.movpiece != king)
        {
            P.S.movgentype = specialcap;
            if (capmovgen(Mpre.nw1, P)) return;
        }
    P.S.movgentype = kill;
    if (!P.S.capturesearch)
        for (var killno:int = 0; killno <= 1; killno++)
        {
            Mo.copyMove( killingmove[killno][Depth] );
            if (Mpre.movpiece != empty)
                if (KillMovGen(Mo))
                    if (loopbody(P)) return;
        }
    P.S.movgentype = norml;
	var u:PIECETAB;
    for (var index:int = 1; index <= PawnNo[Opponent]; index++)
        {
		u = PieceTab[Opponent][index];
        if (u.ipiece != empty)
            if (Mpre.movpiece == empty || u.isquare != Mpre.nw1)
                if (capmovgen(u.isquare, P))
                    return;
        }
    if (P.S.capturesearch)
    {
        var p:int = passedpawn[1+(Depth-2)];
        if (p >= 0)
            {
			var o:BOARDTYPE = Board[p];
            if (o.piece == pawn && o.color == Player)
                if (noncapmovgen(p, P)) return;
            }
    }
    if (!P.S.capturesearch)                /*  non-captures  */
    {
        if (castlingmovgen(P))
            return;      /*  castling  */
        for (index = PawnNo[Player]; index >= 0; index--)
            {
			u = PieceTab[Player][index];
            if (u.ipiece != empty)
                if (noncapmovgen(u.isquare, P)) return;
            }
    }
    if (epcapmovgen(P))
        return;  /*  e.p. captures  */
}


/*
 *  Perform the search
 *  On entry :
 *    Player is next to move
 *    MovTab[Depth-1] contains last move
 *    alpha, beta contains the alpha - beta window
 *    ply contains the Depth of the search
 *    inf contains various information
 *
 *  On exit :
 *    Bestline contains the principal variation
 *    search contains the evaluation for Player
 */

public function search( alpha:int, beta:int, ply:int, inf:INFTYPE, bestline:MLINE):int
{
    var S:SEARCHTYPE = new SEARCHTYPE( MAXPLY+2 );
	var P:PARAMTYPE = new PARAMTYPE( MAXPLY+2 );
    /*  Perform capturesearch if ply <= 0 and !check  */
    S.capturesearch = ((ply <= 0) && !checktab[Depth-1]);
    if (S.capturesearch)  /*  initialize maxval  */
    {
        S.maxval = -inf.evaluation;
        if (alpha < S.maxval)
        {
            alpha = S.maxval;
            if (S.maxval >= beta) return S.maxval;	//goto STOP
        }
    }
    else
    {
        S.maxval = -(LOSEVALUE - (Depth-1)*DEPTHFACTOR);
    }
    P.alpha = alpha;
    P.beta = beta;
    P.ply = ply;
    P.inf = inf;
    P.bestline = bestline;
    P.S = S;
    searchmovgen(P);   /*  The search loop  */
    if (SkipSearch) return S.maxval;	// goto STOP
    if (S.maxval == -(LOSEVALUE - (Depth-1) * DEPTHFACTOR))   /*  Test stalemate  */
        if (!Attacks(Opponent, PieceTab[Player][0].isquare))
        {
            S.maxval = 0;
            return S.maxval;	//goto STOP
        }
    updatekill(P.bestline.a[Depth]);
//STOP:
    return S.maxval;
}


/*
 *  Begin the search
 */

public function callsearch( alpha:int, beta:int ):int
{
    startinf.principv = (MainLine.a[1].movpiece != empty);
    LegalMoves = 0;
    var maxval:int = search(alpha, beta, MaxDepth, startinf, MainLine );
    if (!LegalMoves)
        MainEvalu = maxval;
    return maxval;
}


/*
 *  Checks whether the search time is used
 */

public function timeused():Boolean
{
   if (Analysis)
    {
    timetimer.Tick();
    return (timetimer.elapsed >= MAXSECS);
    }
    return false;
}


/*
 *  setup search (Player = color to play, Opponent = opposite)
 */

public function FindMove():String
{
    ProgramColor = Player;
    timetimer.InitTime();
    Nodes = 0;
    SkipSearch = false;
    clearkillmove();
    pawnbit = [ PwBtList(), PwBtList() ];
    CalcPVTable();
    startinf.value = -RootValue;
    startinf.evaluation = -RootValue;
    MaxDepth = 0;
    MainLine = new MLINE(MAXPLY + 2);
    MainEvalu = RootValue;
    alphawindow = MAXINT;

    do
    {
        /*  update various variables  */
        if (MaxDepth <= 1) repeatevalu = MainEvalu;
        alphawindow = Math.min(alphawindow, MainEvalu - 0x80);
        if (MateSrch)
        {
            alphawindow = 0x6000;
            if (MaxDepth > 0) MaxDepth++;
        }
        MaxDepth++;
        var maxval:int = callsearch(alphawindow, 0x7f00);  /*  perform the search  */
        if (maxval <= alphawindow && !SkipSearch && !MateSrch &&  LegalMoves > 0)
        {
            /*  Repeat the search if the value falls below the
                    alpha-window  */
            MainEvalu = alphawindow;
            maxval = callsearch(-0x7F00, alphawindow - TOLERANCE * 2);
            LegalMoves = 2;
        }
    } while (!SkipSearch && !timeused() && (MaxDepth < MAXPLY) &&
            (LegalMoves > 1) &&
            (Math.abs(MainEvalu) < MATEVALUE - 24 * DEPTHFACTOR));

   DisplayMove();
   PrintBestMove();
   //printboard();
   return retMvStr();
}

public function retMvStr():String
{
   var ret:String = "";
   var move:MOVETYPE = MainLine.a[1];
   var p:int = move.movpiece;
   if(p)
    {
    ret = sq2str(move.old) + sq2str(move.nw1);
    if( move.spe && (p!=pawn && p!=king)) ret+="qrbn".charAt(p-2);
    }
   return ret;
}

/* === STARTING === */


// initiate engine
public function initEngine():void
{
CalcAttackTab();
ResetGame();
}

/* === Opening book === */

public var Openings:Array;

/* Globals */
public var LibNo:int = 0;		// [0...32000]
public var OpCount:int = 0;		// current move in list
public var LibMc:int  = 0;
public var LibMTab:Array  = [];
public var UseLib:int  = 200;
public var LibFound:Boolean  = false;

public const UNPLAYMARK:int = 0x3f;
 
/*
 *  Sets libno to the previous move in the block
 */

public function PreviousLibNo():void
{
 var n:int = 0;
 do { 
	LibNo--;
	var o:int = Openings[LibNo];
        if (o>= 128) n++;
        if (o & 64) n--;
    } while (n);
}

/*
 *  Set libno to the first move in the block
 */
 
public function FirstLibNo():void
{
    while (!(Openings[LibNo-1] & 64)) 
        PreviousLibNo();
}

/*
 *  set libno to the next move in the block.  Unplayable
 *  moves are skipped if skip is set
 */

public function NextLibNo(skip:Boolean):void
{
    if (Openings[LibNo] >= 128) FirstLibNo();
    else
    {
        var n:int = 0;
        do
        {
            var o:int = Openings[LibNo];
            if (o & 64) n++;
            if (o >= 128) n--;
            LibNo++;
        } while (n);
        if (skip && (Openings[LibNo] == UNPLAYMARK))
            FirstLibNo();
    }
}

/*
 *  find the node corresponding to the correct block
 */

public function FindNode():void
{
    var o:int;
    LibNo++;
    if (mc >= LibMc)
    {
        LibFound = true;
        return;
    }
    OpCount = -1;
    InitMovGen();
    for(var i:int=0;i<BufCount;i++)
    {
        OpCount++;
        MovGen();
        if(EqMove(Next, LibMTab[mc])) break;
    }

    if (Next.movpiece != empty)
    {
        while (1)
        {
        o = Openings[LibNo];
        if (((o & 63) == OpCount) || (o >= 128)) break;
        NextLibNo(false);
        }
	    
        if ((o & 127) == (64+OpCount))
        {
            DoMove( Next );
            FindNode();
            UndoMove();
        }
    }
}



public function CalcLibNo():void
{
    LibNo = 0;
    if (mc <= UseLib)
    {
        copyMLine(LibMTab,MovTab);
        LibMc = mc;
        ResetGame();
        LibFound = false;
        FindNode();
        while(mc < LibMc)
            {
            DoMove( LibMTab[mc] );
			}
        if (!LibFound)
        {
            UseLib = mc-1;
            LibNo = 0;
        }
    }
}

/*
 *  find an opening move from the library,
 *  return move string or "", also sets LibFound
 */

public function FindOpeningMove():String
{
    Nodes = 0;
    CalcLibNo();
    if (!LibNo) return "";

	
    const weight:Array = [7, 10, 12, 13, 14, 15, 16];	// [7]
    var cnt:int = 0;
	var p:int = 0;
	var countp:int = 1;

    var r:int = (Math.random()*16);   /*  calculate weighted random number in 0..16  */
    while (r >= weight[p]) p++;
    for (; countp <= p; countp++)  /* find corresponding node */
        NextLibNo(true);
    OpCount = Openings[LibNo] & 63;  /*  generate the move  */

    InitMovGen();
    for(var i:int=0;cnt<=OpCount && i<BufCount;i++)
    {
        MovGen();
        cnt++;
    }
    
                          /* store the move in mainline  */
    MainLine = new MLINE( MAXPLY+2 );
    MainLine.a[1] = new cloneMove(Next);
    MainEvalu = 0;
    PrintBestMove();
    return retMvStr();
}


}
}