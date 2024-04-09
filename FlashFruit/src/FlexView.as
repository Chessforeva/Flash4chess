package
{

//
// Fruit 2.1 chess engine by Fabien Letouzey, 2004-2005.
// At http://www.fruitchess.com,  http://wbec-ridderkerk.nl/
//
// Port to Lua, then AS3 language by http://chessforeva.blogspot.com, 2011
//
// Actionscript is closer to scripting language, this means: not a strong chess
// But this is a smart AI anyway.
//
// There is no opening book.
//
// Samples and all the usage is obvious down at the end.
// Free usage and much thanks to Fabien!
//
// Update 28.10.11:  2D board GUI version to get standalone playable .swf


import flash.events.*;
import flash.display.*;
import flash.text.*;
import mx.controls.Image;
import mx.core.UIComponent;
import flash.external.*;
import flash.utils.Timer;
import flash.ui.Mouse;

public class FlexView extends UIComponent
{

//Embedded pictures
	  
[Embed(source='logoFL2.jpg')]
private static var logo_image:Class;
private var logo0:Bitmap = new logo_image();
[Embed(source='gameover.png')]
private static var gameover_image:Class;
private var gameover0:Bitmap = new gameover_image();

[Embed(source='w_sq.png')]
private static var wsq_image:Class;
[Embed(source='b_sq.png')]
private static var bsq_image:Class;
[Embed(source='cursor1.png')]
private static var cursor1_image:Class;
private var cursor1:Bitmap = new cursor1_image();
[Embed(source='cursor2.png')]
private static var cursor2_image:Class;
private var cursor2:Bitmap = new cursor2_image();


[Embed(source='pawn_white.png')]
private static var wp_image:Class;
[Embed(source='knight_white.png')]
private static var wn_image:Class;
[Embed(source='bishop_white.png')]
private static var wb_image:Class;
[Embed(source='rook_white.png')]
private static var wr_image:Class;
[Embed(source='queen_white.png')]
private static var wq_image:Class;
[Embed(source='king_white.png')]
private static var wk_image:Class;
[Embed(source='pawn_black.png')]
private static var bp_image:Class;
[Embed(source='knight_black.png')]
private static var bn_image:Class;
[Embed(source='bishop_black.png')]
private static var bb_image:Class;
[Embed(source='rook_black.png')]
private static var br_image:Class;
[Embed(source='queen_black.png')]
private static var bq_image:Class;
[Embed(source='king_black.png')]
private static var bk_image:Class;

private var External:Boolean = false;			// set true for external version -
												// javascript interface with flash
												// chess engine
private var BS:int = 0;		// Board size 
private var bsq0:Array = [];

private var pc0:Array = [];
private var rev:Boolean = false;
private var logoshow:int = 0;
private var gameovershow:int = 0;
private var anims:int = 0;
private var apc2:int = 0; 
private var apc3:int = 0; 

private var PromoPiece:String = "q";		// just put queen
private var dragat:String = "";
private var curs2:String = "";

private var MoveList:String = "";
private var MoveNpk:int = 0;
private var MoveMade:String = "";

private var GameOver:Boolean = false;

//Html related
private var pageURL:String = "";
private var swf_loadflag:Boolean = false;



// for AI vs AI autogame

private var Timer2:Timer = new Timer(1000);
private var autogame2:Boolean = false;
private var auto_pgn :String = "";
private var auto_mc:int = 0;
private var auto_mlist:String = "";

// colour.h

// constants

private const TRUE:int = 1;
private const FALSE:int = 0;

private const UseTable:Boolean = true;   // const bool
private const MaterialTableSize:int = 64 * 1024;         // const size of Material hashing (array elements to use)
private const PawnTableSize:int = 64 * 1024;             // const size of Pawn hashing (array elements to use)

private const UseTrans:Boolean = true;   // const bool
private const TransSize:int = 64 * 1024;                 // const size of transp-table (array elements to use)
// it is not a memory hash size, because there is no memory allocation at all

private var bestmv:String = "";      // string contains best move
private var bestmv2:String = "";     // string contains pgn-format of the move

private var ShowInfo:Boolean = false;  // set true to show thinking!

private const iDbg01:Boolean = false;  // internal for debugging

private const ColourNone:int = -1; // const int
private const White:int = 0;       // const int
private const Black:int = 1;       // const int
private const ColourNb:int = 2;    // const int

private const WhiteFlag:int = (1 << White);   // const int
private const BlackFlag:int = (1 << Black);   // const int
private const WxorB:int = (White ^ Black);
private const bnot1:int = (~1);
private const bnot3:int = (~3);
private const bnotx77:int = (~0x77);
private const bnotxF:int = (~0xF)

private const V07777:int = 4095;          // const int
private const bnotV07777:int = (~V07777);   // const int

	 
// should be true, or error otherwise

private function ASSERT(id:int,logic:Boolean):void { 
if( ! logic ) {
print2out("ASSERT FAIL on id=" + string_from_int(id));
}
}

private function string_from_int( a:int ):String {
return a.toString();
}

private function string_from_float( n:Number ):String {
var s:String = n.toString();
var i:int = s.indexOf(".");
if(i >= 0) { s = s.substr( 0, i+2 ); }
return s;
}

private function print2out( s:String ):void {

if (this.swf_loadflag) { CallingJS("TRACE_OUTPUT", s); }
else { trace(s); }
}

private function os_clock(): Number {
return (new Date()).getTime()/1000;    // in seconds
}



// my_fatal()

private function my_fatal( errmess:String ):void {  // for error case 
print2out( "my-error: "+errmess );
}

private function COLOUR_IS_OK(colour:int):Boolean { 
return ((colour & bnot1)==0);
}

private function COLOUR_IS_WHITE(colour:int):Boolean { 
return (colour==White);
}

private function COLOUR_IS_BLACK(colour:int):Boolean { 
return (colour!=White);
}

private function COLOUR_FLAG(colour:int):int { 
return (colour+1);
}

private function COLOUR_IS(piece:int,colour:int):Boolean { 
return (FLAG_IS(piece,colour+1));
}

private function FLAG_IS(piece:int,flag:int):Boolean { 
return ((piece & flag)!=0);
}

private function COLOUR_OPP(colour:int):int { 
return (colour ^ WxorB);
}

// end of colour.h


// piece.h

// constants

private const WhitePawnFlag:int = (1 << 2);   // const int
private const BlackPawnFlag:int = (1 << 3);   // const int
private const KnightFlag:int    = (1 << 4);   // const int
private const BishopFlag:int    = (1 << 5);   // const int
private const RookFlag:int      = (1 << 6);   // const int
private const KingFlag:int      = (1 << 7);   // const int

private const PawnFlags:int  = (WhitePawnFlag | BlackPawnFlag);   // const int
private const QueenFlags:int = (BishopFlag | RookFlag);          // const int

private const PieceNone64:int = 0; // const int
private const WhitePawn64:int = WhitePawnFlag;  // const int
private const BlackPawn64:int = BlackPawnFlag;  // const int
private const Knight64:int    = KnightFlag;     // const int
private const Bishop64:int    = BishopFlag;     // const int
private const Rook64:int      = RookFlag;       // const int
private const Queen64:int     = QueenFlags;     // const int
private const King64:int      = KingFlag;       // const int

private const PieceNone256:int   = 0; // const int
private const WhitePawn256:int   =  (WhitePawn64 | WhiteFlag);  // const int
private const BlackPawn256:int   =  (BlackPawn64 | BlackFlag);  // const int
private const WhiteKnight256:int =  (Knight64 | WhiteFlag);     // const int
private const BlackKnight256:int =  (Knight64 | BlackFlag);     // const int
private const WhiteBishop256:int =  (Bishop64 | WhiteFlag);     // const int
private const BlackBishop256:int =  (Bishop64 | BlackFlag);     // const int
private const WhiteRook256:int   =  (Rook64 | WhiteFlag);       // const int
private const BlackRook256:int   =  (Rook64 | BlackFlag);       // const int
private const WhiteQueen256:int  =  (Queen64 | WhiteFlag);      // const int
private const BlackQueen256:int  =  (Queen64 | BlackFlag);      // const int
private const WhiteKing256:int   =  (King64 | WhiteFlag);       // const int
private const BlackKing256:int   =  (King64 | BlackFlag);       // const int
private const PieceNb:int        = 256; // const int

private const WhitePawn12:int   =  0; // const int
private const BlackPawn12:int   =  1; // const int
private const WhiteKnight12:int =  2; // const int
private const BlackKnight12:int =  3; // const int
private const WhiteBishop12:int =  4; // const int
private const BlackBishop12:int =  5; // const int
private const WhiteRook12:int   =  6; // const int
private const BlackRook12:int   =  7; // const int
private const WhiteQueen12:int  =  8; // const int
private const BlackQueen12:int  =  9; // const int
private const WhiteKing12:int   = 10; // const int
private const BlackKing12:int   = 11; // const int

// "constants"

private const PawnMake:Array = [ WhitePawn256, BlackPawn256 ];   // const int[ColourNb]

private const PieceFrom12:Array = [  WhitePawn256, BlackPawn256, WhiteKnight256, BlackKnight256,
WhiteBishop256, BlackBishop256, WhiteRook256, BlackRook256,
WhiteQueen256,  BlackQueen256, WhiteKing256, BlackKing256 ];  // const int[12]

private const PieceString:String = "PpNnBbRrQqKk";   // const char[12+1]

private const PawnMoveInc:Array = [ 16, -16 ];  // const int[ColourNb]

private const KnightInc:Array = [ -33, -31, -18, -14, 14, 18, 31, 33, 0 ];  // const int[8+1]

private const BishopInc:Array = [ -17, -15, 15, 17, 0 ];  // const int[4+1]

private const RookInc:Array = [ -16, -1, 1, 16, 0 ];  // const int[4+1]

private const QueenInc:Array = [ -17, -16, -15, -1, 1, 15, 16, 17, 0 ];  // const[8+1]

private const KingInc:Array = [ -17, -16, -15, -1, 1, 15, 16, 17, 0 ];  // const[8+1]


// variables

private var PieceTo12:Array = [];    // int[PieceNb]
private var PieceOrder:Array = [];   // int[PieceNb]
private var PieceInc:Array = [];     // const

// macros

private function PAWN_OPP(pawn:int):int { 
return (pawn ^ (WhitePawn256 ^ BlackPawn256));
}

private function PIECE_COLOUR(piece:int):int { 
return ((piece & 3)-1);
}

private function PIECE_TYPE(piece:int):int { 
return (piece & bnot3);
}

private function PIECE_IS_PAWN(piece:int):Boolean  { 
return ((piece & PawnFlags)!=0);
}

private function PIECE_IS_KNIGHT(piece:int):Boolean  { 
return ((piece & KnightFlag)!=0);
}

private function PIECE_IS_BISHOP(piece:int):Boolean  { 
return ((piece & QueenFlags)==BishopFlag);
}

private function PIECE_IS_ROOK(piece:int):Boolean  { 
return ((piece & QueenFlags)==RookFlag);
}

private function PIECE_IS_QUEEN(piece:int):Boolean  { 
return ((piece & QueenFlags)==QueenFlags);
}

private function PIECE_IS_KING(piece:int):Boolean  { 
return ((piece & KingFlag)!=0);
}

private function PIECE_IS_SLIDER(piece:int):Boolean  { 
return ((piece & QueenFlags)!=0);
}


// end of piece.h



// square.h


// constants

private const FileNb:int = 16;   // const int
private const RankNb:int = 16;   // const int

private const SquareNb:int = FileNb*RankNb;   // const int

private const FileInc:int = 1;   // const int
private const RankInc:int = 16;  // const int

private const FileNone:int = 0;   // const int

private const FileA:int = 0x4;   // const int
private const FileB:int = 0x5;   // const int
private const FileC:int = 0x6;   // const int
private const FileD:int = 0x7;   // const int
private const FileE:int = 0x8;   // const int
private const FileF:int = 0x9;   // const int
private const FileG:int = 0xA;   // const int
private const FileH:int = 0xB;   // const int

private const RankNone:int = 0;   // const int

private const Rank1:int = 0x4;   // const int
private const Rank2:int = 0x5;   // const int
private const Rank3:int = 0x6;   // const int
private const Rank4:int = 0x7;   // const int
private const Rank5:int = 0x8;   // const int
private const Rank6:int = 0x9;   // const int
private const Rank7:int = 0xA;   // const int
private const Rank8:int = 0xB;   // const int

private const SquareNone:int = 0;   // const int

private const A1:int=0x44; private const B1:int=0x45; private const C1:int=0x46;
 private const D1:int=0x47; private const E1:int=0x48; private const F1:int=0x49;
 private const G1:int=0x4A; private const H1:int=0x4B;   // const int
private const A2:int=0x54; private const B2:int=0x55; private const C2:int=0x56;
 private const D2:int=0x57; private const E2:int=0x58; private const F2:int=0x59;
 private const G2:int=0x5A; private const H2:int=0x5B;   // const int
private const A3:int=0x64; private const B3:int=0x65; private const C3:int=0x66;
 private const D3:int=0x67; private const E3:int=0x68; private const F3:int=0x69;
 private const G3:int=0x6A; private const H3:int=0x6B;   // const int
private const A4:int=0x74; private const B4:int=0x75; private const C4:int=0x76;
 private const D4:int=0x77; private const E4:int=0x78; private const F4:int=0x79;
 private const G4:int=0x7A; private const H4:int=0x7B;   // const int
private const A5:int=0x84; private const B5:int=0x85; private const C5:int=0x86;
 private const D5:int=0x87; private const E5:int=0x88; private const F5:int=0x89;
 private const G5:int=0x8A; private const H5:int=0x8B;   // const int
private const A6:int=0x94; private const B6:int=0x95; private const C6:int=0x96;
 private const D6:int=0x97; private const E6:int=0x98; private const F6:int=0x99;
 private const G6:int=0x9A; private const H6:int=0x9B;   // const int
private const A7:int=0xA4; private const B7:int=0xA5; private const C7:int=0xA6;
 private const D7:int=0xA7; private const E7:int=0xA8; private const F7:int=0xA9;
 private const G7:int=0xAA; private const H7:int=0xAB;   // const int
private const A8:int=0xB4; private const B8:int=0xB5; private const C8:int=0xB6;
 private const D8:int=0xB7; private const E8:int=0xB8; private const F8:int=0xB9;
 private const G8:int=0xBA; private const H8:int=0xBB;   // const int


private const Dark:int = 0;   // const int
private const Light:int = 1;   // const int

// variables

private var SquareTo64:Array = [];        // int[SquareNb]
private var SquareIsPromote :Array = [];   // bool[SquareNb]


// "constants"

private const SquareFrom64:Array = [
A1, B1, C1, D1, E1, F1, G1, H1,
A2, B2, C2, D2, E2, F2, G2, H2,
A3, B3, C3, D3, E3, F3, G3, H3,
A4, B4, C4, D4, E4, F4, G4, H4,
A5, B5, C5, D5, E5, F5, G5, H5,
A6, B6, C6, D6, E6, F6, G6, H6,
A7, B7, C7, D7, E7, F7, G7, H7,
A8, B8, C8, D8, E8, F8, G8, H8,
];   // const int[64]

private const RankMask:Array  = [ 0, 0xF ];          // const int[ColourNb]
private const PromoteRank:Array  = [ 0xB0, 0x40 ];   // const int[ColourNb]

// macros

private function SQUARE_IS_OK(square:int):Boolean  { 
return ((square-0x44 & bnotx77)==0);
}

private function SQUARE_MAKE(file:int,rank:int):int { 
return ((rank << 4) | file);
}

private function SQUARE_FILE(square:int):int { 
return (square & 0xF);
}

private function SQUARE_RANK(square:int):int { 
return (square >> 4);
}

private function SQUARE_EP_DUAL(square:int):int { 
return (square ^ 16);
}

private function SQUARE_COLOUR(square:int):int { 
return ( (square ^ (square >> 4)) & 1);
}

private function SQUARE_FILE_MIRROR(square:int):int { 
return (square ^ 0x0F);
}

private function SQUARE_RANK_MIRROR(square:int):int { 
return (square ^ 0xF0);
}

private function FILE_OPP(file:int):int { 
return (file ^ 0xF);
}

private function RANK_OPP(rank:int):int { 
return (rank ^ 0xF);
}

private function PAWN_RANK(square:int,colour:int):int { 
return (SQUARE_RANK(square) ^ RankMask[colour]);
}

private function PAWN_PROMOTE(square:int,colour:int):int { 
return (PromoteRank[colour] | (square & 0xF));
}


// end of square.h


// board.h

// constants

private const Empty:int = 0;       // const int
private const Edge:int = Knight64; // const int   HACK: uncoloured knight

private const WP:int = WhitePawn256;   // const int
private const WN:int = WhiteKnight256; // const int
private const WB:int = WhiteBishop256; // const int
private const WR:int = WhiteRook256;   // const int
private const WQ:int = WhiteQueen256;  // const int
private const WK:int = WhiteKing256;   // const int

private const BP:int = BlackPawn256;   // const int
private const BN:int = BlackKnight256; // const int
private const BB:int = BlackBishop256; // const int
private const BR:int = BlackRook256;   // const int
private const BQ:int = BlackQueen256;  // const int
private const BK:int = BlackKing256;   // const int

private const FlagsNone:int = 0;   // const int
private const FlagsWhiteKingCastle:int  = (1 << 0) ;   // const int
private const FlagsWhiteQueenCastle:int = (1 << 1) ;   // const int
private const FlagsBlackKingCastle:int  = (1 << 2) ;   // const int
private const FlagsBlackQueenCastle:int = (1 << 3) ;   // const int

private const StackSize:int = 4096; // const int

// macros

private function KING_POS(board:board_t,colour:int):int { 
return board.piece[colour][0];
}


// end of board.h


// move.h

// constants

private const MoveNone:int = 0;  // const int   HACK: a1a1 cannot be a legal move
private const Movenull:int = 11; // const int   HACK: a1d2 cannot be a legal move

private const MoveNormal:int    =  (0 << 14);   // const int
private const MoveCastle:int    =  (1 << 14);   // const int
private const MovePromote:int   =  (2 << 14);   // const int
private const MoveEnPassant:int =  (3 << 14);   // const int
private const MoveFlags:int     =  (3 << 14);   // const int

private const MovePromoteKnight:int =  (MovePromote | (0 << 12));   // const int
private const MovePromoteBishop:int =  (MovePromote | (1 << 12));   // const int
private const MovePromoteRook:int   =  (MovePromote | (2 << 12));   // const int
private const MovePromoteQueen:int  =  (MovePromote | (3 << 12));   // const int

private const MoveAllFlags:int = (0xF << 12);   // const int

private var PromotePiece:Array = [ Knight64, Bishop64, Rook64, Queen64 ];   // int[4]

// macros

private function MOVE_MAKE(from:int,to:int):int { 
return ( (this.SquareTo64[from] << 6) | this.SquareTo64[to]);
}

private function MOVE_MAKE_FLAGS(from:int,to:int,flags:int):int {
   return ( (this.SquareTo64[from] << 6) | (this.SquareTo64[to] | flags));
}

private function MOVE_FROM(move:int):int { 
return SquareFrom64[ ((move >> 6) & 63)];
}

private function MOVE_TO(move:int):int { 
return SquareFrom64[ (move & 63)];
}

private function MOVE_IS_SPECIAL(move:int):Boolean { 
return ( (move & MoveFlags)!=MoveNormal );
}

private function MOVE_IS_PROMOTE(move:int):Boolean { 
return ( (move & MoveFlags)==MovePromote );
}

private function MOVE_IS_EN_PASSANT(move:int):Boolean { 
return ( (move & MoveFlags)==MoveEnPassant );
}

private function MOVE_IS_CASTLE(move:int):Boolean { 
return ( (move & MoveFlags)==MoveCastle );
}

private function MOVE_PIECE(move:int,board:board_t):int { 
return (board.square[MOVE_FROM(move)]);
}


// end of move.h



// attack.h


// variables

private var DeltaIncLine :Array = [];      // int[DeltaNb]
private var DeltaIncAll :Array = [];       // int[DeltaNb]

private var DeltaMask :Array = [];         // int[DeltaNb]
private var IncMask :Array = [];           // int[IncNb]

private var PieceCode :Array = [];         // int[PieceNb]
private var PieceDeltaSize :Array = [[]];    // int[4][256]      4kB
private var PieceDeltaDelta :Array = [[[]]];   // int[4][256][4]  16kB


// macros

private function IS_IN_CHECK(board:board_t,colour:int):Boolean { 
return is_attacked(board,KING_POS(board,colour),COLOUR_OPP(colour));
}

private function DELTA_INC_LINE(delta:int):int { 
return this.DeltaIncLine[DeltaOffset+delta];
}

private function DELTA_INC_ALL(delta:int):int { 
return this.DeltaIncAll[DeltaOffset+delta];
}

private function DELTA_MASK(delta:int):int { 
return this.DeltaMask[DeltaOffset+delta];
}

private function INC_MASK(inc:int):int { 
return this.IncMask[IncOffset+inc];
}

private function PSEUDO_ATTACK(piece:int,delta:int):Boolean { 
return ((piece & DELTA_MASK(delta))!=0);
}

private function PIECE_ATTACK(board:board_t,piece:int,from:int,to:int):Boolean { 
return PSEUDO_ATTACK(piece,to-from) && line_is_empty(board,from,to);
}


private function SLIDER_ATTACK(piece:int,inc:int):Boolean { 
return ((piece & INC_MASK(inc))!=0);
}

private function ATTACK_IN_CHECK(attack:attack_t):Boolean { 
return (attack.dn!=0);
}


// end of attack.h


// trans.h

// constants

private const UseModulo:Boolean = false;        // const bool
private const DateSize:int = 16;            // const int
private const DepthNone:int = -128;         // const int
private const ClusterSize:int = 4;          // const int, not a hash size


// variables

private var Trans:trans_t = new trans_t ();      // trans_t [1]
private var TransRv:trans_rtrv = new trans_rtrv();  // retriever

// end of trans.h




// hash.h

// macros

private function uint32(i:int):int { 
return (i & 0xFFFFFFFF);
}

private function KEY_INDEX(key:int):int { 
return uint32(key);
}

private function KEY_LOCK(key:int):int {          // no 64 bits, so, we use the original key
return key;                                       // uint32((key >> 32));
}

// constants

private const RandomPiece:int     =   0; // 12 * 64   const int
private const RandomCastle:int    = 768; // 4         const int
private const RandomEnPassant:int = 772; // 8         const int
private const RandomTurn:int      = 780; // 1         const int


// end of hash.h


// list.h

// constants

private const ListSize:int = 256;   // const int

private const UseStrict:Boolean = true;   // const bool


// macros

private function LIST_ADD(list:list_t,mv:int):void { 
list.move[list.size]=mv;
list.size = list.size + 1;
}

private function LIST_CLEAR(list:list_t):void { 
list.move = [];
list.size = 0;
}


// end of list.h


// material.h

// constants

private const MAT_NONE:int =0; private const MAT_KK:int =1; private const MAT_KBK:int =2;
private const MAT_KKB:int =3; private const MAT_KNK:int =4; private const MAT_KKN:int =5;
private const MAT_KPK:int =6; private const MAT_KKP:int =7; private const MAT_KQKQ:int =8;
private const MAT_KQKP:int =9; private const MAT_KPKQ:int =10; private const MAT_KRKR:int =11;
private const MAT_KRKP:int =12; private const MAT_KPKR:int =13; private const MAT_KBKB:int =14;
private const MAT_KBKP:int =15; private const MAT_KPKB:int =16; private const MAT_KBPK:int =17;
private const MAT_KKBP:int =18; private const MAT_KNKN:int =19; private const MAT_KNKP:int =20;
private const MAT_KPKN:int =21; private const MAT_KNPK:int =22; private const MAT_KKNP:int =23;
private const MAT_KRPKR:int =24; private const MAT_KRKRP:int =25; private const MAT_KBPKB:int =26;
private const MAT_KBKBP:int =27; private const MAT_NB:int =28;

private const DrawNodeFlag:int    =  (1 << 0);  // const int
private const DrawBishopFlag:int  =  (1 << 1);  // const int
private const MatRookPawnFlag:int =  (1 << 0);  // const int
private const MatBishopFlag:int   =  (1 << 1);  // const int
private const MatKnightFlag:int   =  (1 << 2);  // const int
private const MatKingFlag:int     =  (1 << 3);  // const int


// constants

private const PawnPhase:int   = 0;   // const int
private const KnightPhase:int = 1;   // const int
private const BishopPhase:int = 1;   // const int
private const RookPhase:int   = 2;   // const int
private const QueenPhase:int  = 4;   // const int
private const TotalPhase:int = (PawnPhase * 16) + (KnightPhase * 4) +
(BishopPhase * 4) + RookPhase * 4 + (QueenPhase * 2);   // const int

// constants and variables

private var MaterialWeight:int = 256; // 100% const int

private const PawnOpening:int   = 80;    // was 100 const int
private const PawnEndgame:int   = 90;    // was 100 const int
private const KnightOpening:int = 325;   // const int
private const KnightEndgame:int = 325;   // const int
private const BishopOpening:int = 325;   // const int
private const BishopEndgame:int = 325;   // const int
private const RookOpening:int   = 500;   // const int
private const RookEndgame:int   = 500;   // const int
private const QueenOpening:int  = 1000;  // const int
private const QueenEndgame:int  = 1000;  // const int

private const BishopPairOpening:int = 50;   // const int
private const BishopPairEndgame:int = 50;   // const int


// variables

private var Material:material_t = new material_t();   // material_t[1]

// material_info_copy ()

private function material_info_copy ( dst:material_info_t, src:material_info_t ):void { 

dst.lock = src.lock;
dst.recog = src.recog;

dst.cflags[0] = src.cflags[0];
dst.cflags[1] = src.cflags[1];

dst.mul[0] = src.mul[0];
dst.mul[1] = src.mul[1];

dst.phase = src.phase;
dst.opening = src.opening;
dst.endgame = src.endgame;

dst.flags = src.flags;

}


// end of material.h



// move_do.h

// variables

private var CastleMask :Array = [];   // int[SquareNb]

// end of move_do.h



// pawn.h


// constants

private const BackRankFlag:int =  (1 << 0);   // const int


// pawn_info_copy ()

private function pawn_info_copy ( dst:pawn_info_t, src:pawn_info_t ):void { 
dst.lock = src.lock;
dst.opening = src.opening;
dst.endgame = src.endgame;
dst.flags[0] = src.flags[0];
dst.flags[1] = src.flags[1];
dst.passed_bits[0] = src.passed_bits[0];
dst.passed_bits[1] = src.passed_bits[1];
dst.single_file[0] = src.single_file[0];
dst.single_file[1] = src.single_file[1];
dst.pad  = src.pad ;
}

// constants and variables

private var Pawn:pawn_t = new pawn_t();           // pawn_t[1]

private const doubledOpening:int = 10;       // const int
private const doubledEndgame:int = 20;       // const int

private const IsolatedOpening:int = 10;      // const int
private const IsolatedOpeningOpen:int = 20;  // const int
private const IsolatedEndgame:int = 20;      // const int

private const BackwardOpening:int = 8;       // const int
private const BackwardOpeningOpen:int = 16;  // const int
private const BackwardEndgame:int = 10;      // const int

private const CandidateOpeningMin:int = 5;   // const int
private const CandidateOpeningMax:int = 55;  // const int
private const CandidateEndgameMin:int = 10;  // const int
private const CandidateEndgameMax:int = 110; // const int

private var Bonus :Array = [];   // int[RankNb]

// variables

private var BitEQ :Array = [];   // int[16]
private var BitLT :Array = [];   // int[16]
private var BitLE :Array = [];   // int[16]
private var BitGT :Array = [];   // int[16]
private var BitGE :Array = [];   // int[16]

private var BitFirst :Array = [];  // int[0x100]
private var BitLast :Array = [];   // int[0x100]
private var BitCount :Array = [];  // int[0x100]
private var BitRev :Array = [];    // int[0x100]


private var BitRank1 :Array = [];  // int[RankNb]
private var BitRank2 :Array = [];  // int[RankNb]
private var BitRank3 :Array = [];  // int[RankNb]


// end of pawn.h


// pst.h

// constants

private const Opening:int = 0;   // const int
private const Endgame:int = 1;   // const int
private const StageNb:int = 2;   // const int

// constants

private const pA1:int=0; private const pB1:int=1; private const pC1:int=2;
 private const pD1:int=3; private const pE1:int=4; private const pF1:int=5;
 private const pG1:int=6; private const pH1:int=7;  // const int
private const pA2:int=8; private const pB2:int=9; private const pC2:int=10;
 private const pD2:int=11; private const pE2:int=12; private const pF2:int=13;
 private const pG2:int=14; private const pH2:int=15;  // const int
private const pA3:int=16; private const pB3:int=17; private const pC3:int=18;
 private const pD3:int=19; private const pE3:int=20; private const pF3:int=21;
 private const pG3:int=22; private const pH3:int=23;  // const int
private const pA4:int=24; private const pB4:int=25; private const pC4:int=26;
 private const pD4:int=27; private const pE4:int=28; private const pF4:int=29;
 private const pG4:int=30; private const pH4:int=31;  // const int
private const pA5:int=32; private const pB5:int=33; private const pC5:int=34;
 private const pD5:int=35; private const pE5:int=36; private const pF5:int=37;
 private const pG5:int=38; private const pH5:int=39;  // const int
private const pA6:int=40; private const pB6:int=41; private const pC6:int=42;
 private const pD6:int=43; private const pE6:int=44; private const pF6:int=45;
 private const pG6:int=46; private const pH6:int=47;  // const int
private const pA7:int=48; private const pB7:int=49; private const pC7:int=50;
 private const pD7:int=51; private const pE7:int=52; private const pF7:int=53;
 private const pG7:int=54; private const pH7:int=55;  // const int
private const pA8:int=56; private const pB8:int=57; private const pC8:int=58;
 private const pD8:int=59; private const pE8:int=60; private const pF8:int=61;
 private const pG8:int=62; private const pH8:int=63;  // const int

// constants and variables

private var PieceActivityWeight:int = 256; // 100%   const int
private var KingSafetyWeight:int = 256;    // 100%  const int
private var PassedPawnWeight:int = 256;    // 100%  const int
private var PawnStructureWeight:int = 256; // 100%  const int

private const PawnFileOpening:int = 5;        // const int
private const KnightCentreOpening:int = 5;    // const int
private const KnightCentreEndgame:int = 5;    // const int
private const KnightRankOpening:int = 5;      // const int
private const KnightBackRankOpening:int = 0;  // const int
private const KnightTrapped:int = 100;        // const int
private const BishopCentreOpening:int = 2;    // const int
private const BishopCentreEndgame:int = 3;    // const int
private const BishopBackRankOpening:int = 10; // const int
private const BishopDiagonalOpening:int = 4;  // const int
private const RookFileOpening:int = 3;        // const int
private const QueenCentreOpening:int = 0;     // const int
private const QueenCentreEndgame:int = 4;     // const int
private const QueenBackRankOpening:int = 5;   // const int
private const KingCentreEndgame:int = 12;     // const int
private const KingFileOpening:int = 10;       // const int
private const KingRankOpening:int = 10;       // const int

// "constants"

private const PawnFile:Array  = [ -3, -1, 0, 1, 1, 0, -1, -3 ];      // const int[8]

private const KnightLine:Array  = [ -4, -2, 0, 1, 1, 0, -2, -4 ];    // const int[8]

private const KnightRank:Array  = [ -2, -1, 0, 1, 2, 3, 2, 1 ];    // const int[8]

private const BishopLine:Array  = [ -3, -1, 0, 1, 1, 0, -1, -3 ];    // const int[8]

private const RookFile:Array  = [ -2, -1, 0, 1, 1, 0, -1, -2 ];      // const int[8]

private const QueenLine:Array  = [ -3, -1, 0, 1, 1, 0, -1, -3 ];     // const int[8]

private const KingLine:Array  = [ -3, -1, 0, 1, 1, 0, -1, -3 ];      // const int[8]

private const KingFile:Array  = [ 3, 4, 2, 0, 0, 2, 4, 3 ];      // const int[8]

private const KingRank:Array  = [ 1, 0, -2, -3, -4, -5, -6, -7 ];      // const int[8]

// variables

private var Pst :Array = [];      // sint16 [12][64][StageNb]


// end of pst.h




// random.h

// "constants"

private var Random64 :Array = [];    // uint64[RandomNb]  array of const fixed randoms
private var R64_i:int = 0;        // length
private const RandomNb:int = 781;   // max size

// end of random.h




// search.h


// variables

private var setjmp:Boolean = false;        // c++ has setjmp-longjmp feature

// constants

private const DepthMax:int = 64;     // const int
private const HeightMax:int = 256;   // const int

private const SearchNormal:int = 0;  // const int
private const SearchShort:int  = 1;  // const int

private const SearchUnknown:int = 0; // const int
private const SearchUpper:int   = 1; // const int
private const SearchLower:int   = 2; // const int
private const SearchExact:int   = 3; // const int

private const UseShortSearch:Boolean = true;    // const bool
private const ShortSearchDepth:int = 1;     // const int

private const DispBest:Boolean = true;          // const bool
private const DispDepthStart:Boolean = true;    // const bool
private const DispDepthEnd:Boolean = true;      // const bool
private const DispRoot:Boolean = true;          // const bool
private const DispStat:Boolean = true;          // const bool

private const UseEasy:Boolean = true;           // const bool  singular move
private const EasyThreshold:int = 150;      // const int
private const EasyRatio:Number = 0.20;         // const

private const UseEarly:Boolean = true;          // const bool  early iteration end
private const EarlyRatio:Number = 0.60;        // const

private const UseBad:Boolean = true;            // const bool
private const BadThreshold:int = 50;        // const int
private const UseExtension:Boolean = true;      // const bool

// variables

private var SearchInput:search_input_t = new search_input_t();      // search_input_t[1]
private var SearchInfo:search_info_t = new search_info_t();        // search_info_t[1]
private var SearchRoot:search_root_t = new search_root_t();        // search_root_t[1]
private var SearchCurrent:search_current_t = new search_current_t();  // search_current_t[1]
private var SearchBest:search_best_t = new search_best_t();        // search_best_t[1]



// constants and variables

// main search

private const UseDistancePruning:Boolean = true;   // const bool

// transposition table

private const TransDepth:int = 1;    // const int

private const UseMateValues:Boolean = true; // use mate values from shallower searches?   // const bool

// null move

private var Usenull:Boolean = true;     // const bool
private var UsenullEval:Boolean = true; // const bool
private const nullDepth:int = 2;      // const int
private var nullReduction:int = 3;  // const int

private var UseVer:Boolean = true;         // const bool
private var UseVerEndgame:Boolean = true;  // const bool
private var VerReduction:int = 5;      // const int   was 3

// move ordering

private const UseIID:Boolean = true;      // const bool
private const IIDDepth:int = 3;       // const int
private const IIDReduction:int = 2;   // const int

// extensions

private const ExtendSingleReply:Boolean = true;   // const bool

// history pruning

private var UseHistory:Boolean = true;       // const bool
private const HistoryDepth:int = 3;        // const int
private const HistoryMoveNb:int = 3;       // const int
private var HistoryValue:int = 9830;     // const int 60%
private const HistoryReSearch:Boolean = true;  // const bool

// futility pruning

private var UseFutility:Boolean = false;     // const bool
private var FutilityMargin:int = 100;    // const int

// quiescence search

private var UseDelta:Boolean = false;        // const bool
private var DeltaMargin:int = 50;        // const int

private var CheckNb:int = 1;             // const int
private var CheckDepth:int = 0;          // const int   1 - this.CheckNb

// misc

private const NodeAll:int = -1;   // const int
private const NodePV:int  =  0;   // const int
private const NodeCut:int = 1;   // const int


// end of search.h



// fen.h

// "constants"

private const StartFen:String = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";   // const char

// variables

private const Strict:Boolean = false;   // const bool

// end of fen.h



// protocol.h

// constants

private const VERSION:String = "Fruit 2.1 by Fabien Letouzey, port to AS3 by Chessforeva";
private const NormalRatio:Number = 1.0;   // const
private const PonderRatio:Number = 1.25;   // const

// variables

private var Init:Boolean = false;       // bool

// end of protocol.h



// sort.h


// constants

private const KillerNb:int = 2;   // const int

private const HistorySize:int = 12 * 64;   // const int
private const HistoryMax:int = 16384;      // const int

private const TransScore:int   = 32766;   // const int
private const GoodScore:int    =  4000;   // const int
private const KillerScore:int  =     4;   // const int
private const HistoryScore:int = -24000;   // const int
private const BadScore:int     = -28000;   // const int

private const CODE_SIZE:int = 256;         // const int


private const GEN_ERROR:int = 0;
private const GEN_LEGAL_EVASION:int = 1;
private const GEN_TRANS:int = 2;
private const GEN_GOOD_CAPTURE:int = 3;
private const GEN_BAD_CAPTURE:int = 4;
private const GEN_KILLER:int = 5;
private const GEN_QUIET:int = 6;
private const GEN_EVASION_QS:int = 7;
private const GEN_CAPTURE_QS:int = 8;
private const GEN_CHECK_QS:int = 9;
private const GEN_END:int = 10;

private const TEST_ERROR:int = 0;
private const TEST_NONE:int = 1;
private const TEST_LEGAL:int = 2;
private const TEST_TRANS_KILLER:int = 3;
private const TEST_GOOD_CAPTURE:int = 4;
private const TEST_BAD_CAPTURE:int = 5;
private const TEST_KILLER:int = 6;
private const TEST_QUIET:int = 7;
private const TEST_CAPTURE_QS:int = 8;
private const TEST_CHECK_QS:int = 9;


// variables

private var PosLegalEvasion:int = 0;   // int
private var PosSEE:int = 0;            // int

private var PosEvasionQS:int = 0;      // int
private var PosCheckQS:int = 0;        // int
private var PosCaptureQS:int = 0;      // int

private var Code :Array = [];             // int[CODE_SIZE]

private var Killer :Array = [];           // uint16[HeightMax][KillerNb]

private var History :Array = [];          // uint16[HistorySize]
private var HistHit :Array = [];          // uint16[HistorySize]
private var HistTot :Array = [];          // uint16[HistorySize]



// end of sort.h



// value.h

// variables

private var ValuePiece :Array = [ 0, 0 ];   // int[PieceNb]

// constants

private const ValuePawn:int   = 100;   // was 100   const int
private const ValueKnight:int = 325;   // was 300   const int
private const ValueBishop:int = 325;   // was 300   const int
private const ValueRook:int   = 500;   // was 500   const int
private const ValueQueen:int  = 1000;  // was 900   const int
private const ValueKing:int   = 10000; // was 10000 const int

private const ValueNone:int    = -32767;          // const int
private const ValueDraw:int    = 0;               // const int
private const ValueMate:int    = 30000;           // const int
private const ValueInf:int     = ValueMate;       // const int
private const ValueEvalInf:int = ValueMate - 256; // const int handle mates upto 255 plies


// end of value.h


// eval.h

// constants and variables

private const KnightUnit:int = 4;   // const int
private const BishopUnit:int = 6;   // const int
private const RookUnit:int = 7;     // const int
private const QueenUnit:int = 13;   // const int

private const MobMove:int = 1;      // const int
private const MobAttack:int = 1;    // const int
private const MobDefense:int = 0;   // const int

private const KnightMobOpening:int = 4; // const int
private const KnightMobEndgame:int = 4; // const int
private const BishopMobOpening:int = 5; // const int
private const BishopMobEndgame:int = 5; // const int
private const RookMobOpening:int = 2;   // const int
private const RookMobEndgame:int = 4;   // const int
private const QueenMobOpening:int = 1;  // const int
private const QueenMobEndgame:int = 2;  // const int
private const KingMobOpening:int = 0;   // const int
private const KingMobEndgame:int = 0;   // const int

private const UseOpenFile:Boolean = true;   // const bool
private const RookSemiOpenFileOpening:int = 10;  // const int
private const RookSemiOpenFileEndgame:int = 10;  // const int
private const RookOpenFileOpening:int = 20;      // const int
private const RookOpenFileEndgame:int = 20;      // const int
private const RookSemiKingFileOpening:int = 10;  // const int
private const RookKingFileOpening:int = 20;      // const int

private const UseKingAttack:Boolean = true;     // const bool
private const KingAttackOpening:int = 20;   // const int

private const UseShelter:Boolean = true;    // const bool
private const ShelterOpening:int = 256; // 100%  const int
private const UseStorm:Boolean = true;      // const bool
private const StormOpening:int = 10;    // const int

private const Rook7thOpening:int = 20;   // const int
private const Rook7thEndgame:int = 40;   // const int
private const Queen7thOpening:int = 10;  // const int
private const Queen7Endgame:int = 20;  // const int

private const TrappedBishop:int = 100;   // const int

private const BlockedBishop:int = 50;   // const int
private const BlockedRook:int = 50;     // const int

private const PassedOpeningMin:int = 10;   // const int
private const PassedOpeningMax:int = 70;   // const int
private const PassedEndgameMin:int = 20;   // const int
private const PassedEndgameMax:int = 140;  // const int

private const UnstoppablePasser:int = 800; // const int
private const FreePasser:int = 60;         // const int

private const AttackerDistance:int = 5;    // const int
private const DefenderDistance:int = 20;   // const int

// "constants"

private const KingAttackWeight:Array = [ 0, 0, 128, 192, 224, 240, 248, 252, 254, 255, 256, 256 ,256, 256, 256, 256 ];  // const int[16]

// variables

private var MobUnit :Array = [[]];        // int[ColourNb][PieceNb]
//MobUnit[0] :Array = [];
//MobUnit[1] :Array = [];

private var KingAttackUnit :Array = []  // int[PieceNb]

// macros

private function THROUGH(piece:int):Boolean { 
return (piece==Empty);
}

// end of eval.h



// hash.h

// variables

private var Castle64 :Array = [];   // int[16]

// end of hash.h




// vector.h

// "constants"

private const IncNone:int = 0;          // const int
private const IncNb:int = (2*17) + 1;   // const int
private const IncOffset:int = 17;       // const int

private const DeltaNone:int = 0;           // const int
private const DeltaNb:int = (2*119) + 1;   // const int
private const DeltaOffset:int = 119;       // const int

// variables

private var Distance :Array = [];   // int[DeltaNb]

// macros

private function DISTANCE(square_1:int,square_2:int):int { 
return this.Distance[DeltaOffset+(square_2-square_1)];
}

// end of vector.h


// option.h

// types

private function set_opt_t_def( k:int, vary:String, decl:Boolean, init:String, type:String, extra:String ):void { 
this.Option[k].vary = vary;        // string
this.Option[k].decl = decl;        // bool
this.Option[k].init = init;        // string
this.Option[k].val  = init;        // string the same as init
this.Option[k].type = type;        // string
this.Option[k].extra = extra;      // string
}



// variables

private var Option :Array = [];

// end of option.h


//
// Programs C
//


// attack.cpp

//  functions

// attack_init()

private function attack_init():void {  // void  

var delta :int = 0;   // int
var inc :int = 0;     // int
var piece :int = 0;   // int
var dir :int = 0;     // int
var dist :int = 0;    // int
var size :int = 0;    // int
var king :int = 0;    // int
var from :int = 0;    // int
var to :int = 0;      // int
var pos :int = 0;     // int
var k:int = 0;


// clear

for (delta = 0; delta<DeltaNb; delta++) {
this.DeltaIncLine[delta] = IncNone;
this.DeltaIncAll[delta] = IncNone;
this.DeltaMask[delta] = 0;
}

for (inc = 0; inc<IncNb; inc++) {
this.IncMask[inc] = 0;
}

// pawn attacks

this.DeltaMask[DeltaOffset-17] = ( this.DeltaMask[DeltaOffset-17] | BlackPawnFlag );
this.DeltaMask[DeltaOffset-15] = ( this.DeltaMask[DeltaOffset-15] | BlackPawnFlag );

this.DeltaMask[DeltaOffset+15] = ( this.DeltaMask[DeltaOffset+15] | WhitePawnFlag );
this.DeltaMask[DeltaOffset+17] = ( this.DeltaMask[DeltaOffset+17] | WhitePawnFlag );

// knight attacks

for (dir = 0; dir <8 ; dir++) {

delta = KnightInc[dir];
//ASSERT(3, delta_is_ok(delta));

//ASSERT(4, this.DeltaIncAll[DeltaOffset+delta]==IncNone);
this.DeltaIncAll[DeltaOffset+delta] = delta;
this.DeltaMask[DeltaOffset+delta] = ( this.DeltaMask[DeltaOffset+delta] | KnightFlag );
}

// bishop/queen attacks

for (dir = 0; dir<=3 ; dir++ ) {

inc = BishopInc[dir];
//ASSERT(5, inc!=IncNone);

this.IncMask[IncOffset+inc] = ( this.IncMask[IncOffset+inc] | BishopFlag );

for (dist = 1; dist<8; dist++ ) {

delta = inc*dist;
//ASSERT(6, delta_is_ok(delta));

//ASSERT(7, this.DeltaIncLine[DeltaOffset+delta]==IncNone);
this.DeltaIncLine[DeltaOffset+delta] = inc;
//ASSERT(8, this.DeltaIncAll[DeltaOffset+delta]==IncNone);
this.DeltaIncAll[DeltaOffset+delta] = inc;
this.DeltaMask[DeltaOffset+delta] = ( this.DeltaMask[DeltaOffset+delta] | BishopFlag );
}
}

// rook/queen attacks

for (dir = 0; dir<4 ; dir++ ) {

inc = RookInc[dir];
//ASSERT(9, inc!=IncNone);

this.IncMask[IncOffset+inc] = ( this.IncMask[IncOffset+inc] | RookFlag );

for (dist = 1; dist<8 ; dist++ ) {

delta = inc*dist;
//ASSERT(10, delta_is_ok(delta));

//ASSERT(11, this.DeltaIncLine[DeltaOffset+delta]==IncNone);
this.DeltaIncLine[DeltaOffset+delta] = inc;
//ASSERT(12, this.DeltaIncAll[DeltaOffset+delta]==IncNone);
this.DeltaIncAll[DeltaOffset+delta] = inc;
this.DeltaMask[DeltaOffset+delta] = ( this.DeltaMask[DeltaOffset+delta] | RookFlag );
}
}

// king attacks

for (dir = 0; dir<8 ; dir++ ) {

delta = KingInc[dir];
//ASSERT(13, delta_is_ok(delta));

this.DeltaMask[DeltaOffset+delta] = ( this.DeltaMask[DeltaOffset+delta] | KingFlag );
}

// this.PieceCode[]

for (piece = 0; piece< PieceNb; piece++ ) {
this.PieceCode[piece] = -1;
}

this.PieceCode[WN] = 0;
this.PieceCode[WB] = 1;
this.PieceCode[WR] = 2;
this.PieceCode[WQ] = 3;

this.PieceCode[BN] = 0;
this.PieceCode[BB] = 1;
this.PieceCode[BR] = 2;
this.PieceCode[BQ] = 3;

// this.PieceDeltaSize[][] & this.PieceDeltaDelta[][][]


for (piece = 0; piece <=3; piece++ ) {

this.PieceDeltaSize[piece] = [];
this.PieceDeltaDelta[piece] = [];

for (delta = 0; delta<256; delta++) {

this.PieceDeltaDelta[piece][delta] = [];
this.PieceDeltaSize[piece][delta] = 0;

}
}


for (king = 0; king<SquareNb; king++ ) {

if (SQUARE_IS_OK(king)) {

for (from = 0; from<SquareNb; from++ ) {

if (SQUARE_IS_OK(from)) {

// knight
pos = 0;
while (true) {
inc=KnightInc[pos];
if(inc == IncNone) {
break;
}
to = from + inc;
if (SQUARE_IS_OK(to)  &&  DISTANCE(to,king) == 1) {
add_attack(0,king-from,to-from);
}
pos = pos + 1;
}

// bishop
pos = 0;
while (true) {
inc=BishopInc[pos];
if(inc == IncNone) {
break;
}
to = from+inc;
while( SQUARE_IS_OK(to) ) {
if (DISTANCE(to,king) == 1) {
add_attack(1,king-from,to-from);
break;
}
to = to + inc;
}
pos = pos + 1;
}

// rook
pos = 0;
while (true) {
inc=RookInc[pos];
if(inc == IncNone) {
break;
}
to = from+inc;
while( SQUARE_IS_OK(to) ) {
if (DISTANCE(to,king) == 1) {
add_attack(2,king-from,to-from);
break;
}
to = to + inc;
}
pos = pos + 1;
}

// queen
pos = 0;
while (true) {
inc=QueenInc[pos];
if(inc == IncNone) {
break;
}
to = from+inc;
while( SQUARE_IS_OK(to) ) {
if (DISTANCE(to,king) == 1) {
add_attack(3,king-from,to-from);
break;
}
to = to + inc;
}
pos = pos + 1;
}
}
}
}


for (piece = 0; piece<4; piece++ ) {
for (delta = 0; delta< 256; delta++ ) {
size = this.PieceDeltaSize[piece][delta];
//ASSERT(14, size>=0 && size<3);
this.PieceDeltaDelta[piece][delta][size] = DeltaNone;
}
}
}

}

// add_attack()

private function add_attack(piece:int, king:int, target:int)  :void {

var size :int = 0;   // int
var i :int = 0;      // int

//ASSERT(15, piece>=0 && piece<4);
//ASSERT(16, delta_is_ok(king));
//ASSERT(17, delta_is_ok(target));

size = this.PieceDeltaSize[piece][DeltaOffset+king];
//ASSERT(18, size>=0 && size<3);

for (i = 0; i<size; i++ ) {
if (this.PieceDeltaDelta[piece][DeltaOffset+king][i] == target) {
return;    // already in the table
}
}

if (size < 2)  {
this.PieceDeltaDelta[piece][DeltaOffset+king][size] = target;
size = size + 1;
this.PieceDeltaSize[piece][DeltaOffset+king] = size;
}
}

// is_attacked()

private function is_attacked( board:board_t, to:int, colour:int):Boolean {  // bool

var inc :int = 0;    // int
var pawn :int = 0;   // int
var ptr :int = 0;    // int
var from :int = 0;   // int
var piece :int = 0;  // int
var delta :int = 0;  // int
var sq :int = 0;     // int

//ASSERT(20, SQUARE_IS_OK(to));
//ASSERT(21, COLOUR_IS_OK(colour));

// pawn attack

inc = PawnMoveInc[colour];
pawn = PawnMake[colour];

if (board.square[to-(inc-1)] == pawn) {
return true;
}
if (board.square[to-(inc+1)] == pawn) {
return true;
}

// piece attack

ptr = 0;
while(true) {
from = board.piece[colour][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];
delta = to - from;

if (PSEUDO_ATTACK(piece,delta)) {

inc = DELTA_INC_ALL(delta);
//ASSERT(22, inc!=IncNone);

sq = from;
while(true) {

sq = sq + inc;
if (sq == to) {
return true;
}
if (board.square[sq] != Empty) {
break;
}
}
}
ptr = ptr + 1;
}

return false;

}

// line_is_empty()

private function line_is_empty( board:board_t, from:int, to:int ) :Boolean {

var delta :int = 0;  // int
var inc :int = 0;    // int
var sq :int = 0;     // int

//ASSERT(24, SQUARE_IS_OK(from));
//ASSERT(25, SQUARE_IS_OK(to));

delta = to - from;
//ASSERT(26, delta_is_ok(delta));

inc = DELTA_INC_ALL(delta);
//ASSERT(27, inc!=IncNone);

sq = from;
while(true) {

sq = sq + inc;
if (sq == to) {
return true;
}
if (board.square[sq] != Empty) {
break;
}
}

return false;  // blocker
}

// is_pinned()

private function is_pinned( board:board_t, square:int, colour:int) :Boolean {

var from :int = 0;  // int
var to :int = 0;    // int
var inc :int = 0;   // int
var sq :int = 0;    // int
var piece :int = 0; // int

//ASSERT(29, SQUARE_IS_OK(square));
//ASSERT(30, COLOUR_IS_OK(colour));

from = square;
to = KING_POS(board,colour);

inc = DELTA_INC_LINE(to-from);
if (inc == IncNone) {
return false;  // not a line
}

sq = from;
while(true) {
sq = sq + inc;
if (board.square[sq] != Empty) {
break;
}
}

if (sq != to) {
return false; // blocker
}

sq = from;
while(true) {
sq = sq - inc;
piece = board.square[sq];
if ( piece!= Empty) {
break;
}
}

return COLOUR_IS(piece,COLOUR_OPP(colour)) && SLIDER_ATTACK(piece,inc);
}

// attack_is_ok()

private function attack_is_ok( attack:attack_t ) :Boolean {

var i :int = 0;   // int
var sq :int = 0;  // int
var inc :int = 0; // int

// checks

if (attack.dn < 0 || attack.dn > 2) {
return false;
}

for (i = 0; i < attack.dn; i++ ) {
sq = attack.ds[i];
if (! SQUARE_IS_OK(sq)) {
return false;
}
inc = attack.di[i];
if (inc != IncNone  &&  (! inc_is_ok(inc))) {
return false;
}
}

if (attack.ds[attack.dn] != SquareNone) {
return false;
}
if (attack.di[attack.dn] != IncNone) {
return false;
}

return true;
}

// attack_set()

private function attack_set( attack:attack_t, board:board_t )  :void {

var me :int = 0;    // int
var opp :int = 0;   // int
var ptr :int = 0;   // int
var from :int = 0;  // int
var to :int = 0;    // int
var inc :int = 0;   // int
var pawn :int = 0;  // int
var delta :int = 0; // int
var piece :int = 0; // int
var sq :int = 0;    // int
var cont :Boolean = false;


// init

attack.dn = 0;

me = board.turn;
opp = COLOUR_OPP(me);

to = KING_POS(board,me);

// pawn attacks

inc = PawnMoveInc[opp];
pawn = PawnMake[opp];

from = to - (inc-1);
if (board.square[from] == pawn) {
attack.ds[attack.dn] = from;
attack.di[attack.dn] = IncNone;
attack.dn = attack.dn + 1;
}

from = to - (inc+1);
if (board.square[from] == pawn) {
attack.ds[attack.dn] = from;
attack.di[attack.dn] = IncNone;
attack.dn = attack.dn + 1;
}

// piece attacks

ptr = 1;	// HACK: no king
while(true) {
from = board.piece[opp][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

delta = to - from;
//ASSERT(33, delta_is_ok(delta));

if (PSEUDO_ATTACK(piece,delta)) {

inc = IncNone;

if (PIECE_IS_SLIDER(piece)) {

// check for (blockers

inc = DELTA_INC_LINE(delta);
//ASSERT(34, inc!=IncNone);

sq = from;
while(true) {
sq = sq + inc;
if (board.square[sq] != Empty) {
break;
}
}

if (sq != to) {
cont = true;     // blocker => next attacker
}
}

if(cont) {
cont = false;
} else { 
attack.ds[attack.dn] = from;
attack.di[attack.dn] = -inc; // HACK
attack.dn = attack.dn + 1;
}
}
ptr = ptr + 1;
}

attack.ds[attack.dn] = SquareNone;
attack.di[attack.dn] = IncNone;

// debug

//ASSERT(35, attack_is_ok(attack));
}

// piece_attack_king()

private function piece_attack_king( board:board_t, piece:int, from:int, king:int ) :Boolean {

var code :int = 0;      // int
var delta_ptr :int = 0; // int
var delta :int = 0;     // int
var inc :int = 0;       // int
var to :int = 0;        // int
var sq :int = 0;        // int

//ASSERT(37, piece_is_ok(piece));
//ASSERT(38, SQUARE_IS_OK(from));
//ASSERT(39, SQUARE_IS_OK(king));

code = this.PieceCode[piece];
//ASSERT(40, code>=0 && code<4);

if (PIECE_IS_SLIDER(piece)) {

delta_ptr = 0;
while(true) {

delta = this.PieceDeltaDelta[code][DeltaOffset+(king-from)][delta_ptr];
if(delta==DeltaNone) {
break;
}

//ASSERT(41, delta_is_ok(delta));

inc = this.DeltaIncLine[DeltaOffset+delta];
//ASSERT(42, inc!=IncNone);

to = from + delta;

sq = from;
while(true) {
sq = sq + inc;

if (sq == to && SQUARE_IS_OK(to)) {
//ASSERT(43, DISTANCE(to,king)==1);
return true;
}

if (board.square[sq] != Empty) {
break;
}
}

delta_ptr = delta_ptr + 1;
}

} else {  // non-slider

delta_ptr = 0;
while(true) {

delta = this.PieceDeltaDelta[code][DeltaOffset+(king-from)][delta_ptr];
if(delta==DeltaNone) {
break;
}

//ASSERT(44, delta_is_ok(delta));

to = from + delta;

if (SQUARE_IS_OK(to)) {
//ASSERT(45, DISTANCE(to,king)==1);
return true;
}

delta_ptr = delta_ptr + 1;
}
}

return false;
}

// end of attack.cpp



// board.cpp

//  functions

// board_is_ok()

private function board_is_ok( board:board_t ):Boolean { 

var sq :int = 0;     // int
var piece :int = 0;  // int
var colour :int = 0; // int
var size :int = 0;   // int
var pos :int = 0;    // int


// squares

for (sq = 0; sq<SquareNb; sq++ ) {

piece = board.square[sq];
pos = board.pos[sq];

if (SQUARE_IS_OK(sq)) {

// inside square

if (piece == Empty) {

if (pos != -1) {
return false;
}
} else { 

if (! piece_is_ok(piece)) {
return false;
}

if (! PIECE_IS_PAWN(piece)) {
colour = PIECE_COLOUR(piece);
if (pos < 0  ||  pos >= board.piece_size[colour]) {
return false;
}
if (board.piece[colour][pos] != sq) {
return false;
}
} else {  // pawn
if (this.SquareIsPromote[sq]) {
return false;
}
colour = PIECE_COLOUR(piece);
if (pos < 0  ||  pos >= board.pawn_size[colour]) {
return false;
}
if (board.pawn[colour][pos] != sq) {
return false;
}
}
}

} else { 

// edge square

if (piece != Edge) {
return false;
}
if (pos != -1) {
return false;
}
}
}

// piece lists

for (colour = 0; colour<=1; colour++ ) {

// piece list

size = board.piece_size[colour];
if (size < 1  ||  size > 16) {
return false;
}

for (pos = 0; pos < size; pos++ ) {

sq = board.piece[colour][pos];
if (! SQUARE_IS_OK(sq)) {
return false;
}
if (board.pos[sq] != pos) {
return false;
}
piece = board.square[sq];
if (! COLOUR_IS(piece,colour)) {
return false;
}
if (pos == 0  &&  (! PIECE_IS_KING(piece))) {
return false;
}
if (pos != 0  &&  PIECE_IS_KING(piece)) {
return false;
}
if (pos != 0  &&  this.PieceOrder[piece] > this.PieceOrder[board.square[board.piece[colour][pos-1]]]) {
return false;
}
}

sq = board.piece[colour][size];
if (sq != SquareNone) {
return false;
}

// pawn list

size = board.pawn_size[colour];
if (size < 0  ||  size > 8) {
return false;
}

for (pos = 0; pos < size; pos++ ) {

sq = board.pawn[colour][pos];
if (! SQUARE_IS_OK(sq)) {
return false;
}
if (this.SquareIsPromote[sq]) {
return false;
}
if (board.pos[sq] != pos) {
return false;
}
piece = board.square[sq];
if (! COLOUR_IS(piece,colour)) {
return false;
}
if (! PIECE_IS_PAWN(piece)) {
return false;
}
}

sq = board.pawn[colour][size];
if (sq != SquareNone) {
return false;
}

// piece total

if (board.piece_size[colour] + board.pawn_size[colour] > 16) {
return false;
}
}

// material

if (board.piece_nb != board.piece_size[White] + board.pawn_size[White]
+ board.piece_size[Black] + board.pawn_size[Black]) {
return false;
}

if (board.number[WhitePawn12] != board.pawn_size[White]) {
return false;
}
if (board.number[BlackPawn12] != board.pawn_size[Black]) {
return false;
}
if (board.number[WhiteKing12] != 1) {
return false;
}
if (board.number[BlackKing12] != 1) {
return false;
}

// misc

if (! COLOUR_IS_OK(board.turn)) {
return false;
}

if (board.ply_nb < 0) {
return false;
}

if (board.sp < board.ply_nb) {
return false;
}

if (board.cap_sq != SquareNone  &&  (! SQUARE_IS_OK(board.cap_sq))) {
return false;
}

if (board.opening != board_opening(board)) {
return false;
}
if (board.endgame != board_endgame(board)) {
return false;
}

// we can not guarantee that the key is the same, it is just a random number
//
//if (board.key != hash_key(board)) {
//  return false;
//}
//if (board.pawn_key != hash_pawn_key(board)) {
//  return false;
//}
//if (board.material_key != hash_material_key(board)) {
//  return false;
//}

return true;
}

// board_clear()

private function board_clear( board:board_t ) :void {

var sq :int = 0;     // int
var sq_64 :int = 0;  // int

// edge squares

for (sq = 0; sq<SquareNb; sq++ ) {
board.square[sq] = Edge;
}

// empty squares

for (sq_64 = 0; sq_64<=63; sq_64++ ) {
sq = SquareFrom64[sq_64];
board.square[sq] = Empty;
}

// misc

board.turn = ColourNone;
board.flags = FlagsNone;
board.ep_square = SquareNone;
board.ply_nb = 0;
}

// board_copy()

private function board_copy( dst:board_t, src:board_t ) :void {

var i :int = 0;  // int

//ASSERT(48, board_is_ok(src));

dst.square = src.square;
dst.pos = src.pos;
dst.piece = [];
dst.piece[0] = [];
dst.piece[1] = [];

for (i = 0; i<src.piece[0].length; i++ ) {
dst.piece[0][i] = src.piece[0][i];
}
for (i = 0; i<src.piece[1].length; i++ ) {
dst.piece[1][i] = src.piece[1][i];
}

dst.piece_size = [];
for (i = 0; i<src.piece_size.length; i++ ) {
dst.piece_size[i] = src.piece_size[i];
}

dst.pawn = [];
dst.pawn[0] = [];
dst.pawn[1] = [];

for (i = 0; i<src.pawn[0].length; i++ ) {
dst.pawn[0][i] = src.pawn[0][i];
}
for (i = 0; i<src.pawn[1].length; i++ ) {
dst.pawn[1][i] = src.pawn[1][i];
}

dst.pawn_size = [];
for (i = 0; i<src.pawn_size.length; i++ ) {
dst.pawn_size[i] = src.pawn_size[i];
}

dst.piece_nb = src.piece_nb;
dst.number = [];
for (i = 0; i<src.number.length; i++ ) {
dst.number[i] = src.number[i];
}

dst.pawn_file = [];
dst.pawn_file[0] = [];
dst.pawn_file[1] = [];

for (i = 0; i<src.pawn_file[0].length; i++ ) {
dst.pawn_file[0][i] = src.pawn_file[0][i];
}

for (i = 0; i<src.pawn_file[1].length; i++ ) {
dst.pawn_file[1][i] = src.pawn_file[1][i];
}


dst.turn = src.turn;
dst.flags = src.flags;
dst.ep_square = src.ep_square
dst.ply_nb = src.ply_nb;
dst.sp = src.sp;

dst.cap_sq = src.cap_sq;

dst.opening = src.opening;
dst.endgame = src.endgame;

dst.key = src.key;
dst.pawn_key = src.pawn_key;
dst.material_key = src.material_key;

dst.stack = [];
for (i = 0; i<src.stack.length; i++ ) {
dst.stack[i] = src.stack[i];
}

}


// board_init_list()

private function board_init_list( board:board_t ) :void {

var sq_64 :int = 0;   // int
var sq :int = 0;      // int
var piece :int = 0;   // int
var colour :int = 0;  // int
var pos :int = 0;     // int
var i :int = 0;       // int
var size :int = 0;    // int
var square :int = 0;  // int
var order :int = 0;   // int
var file :int = 0;    // int

// init

for (sq = 0; sq<SquareNb; sq++ ) {
board.pos[sq] = -1;
}

board.piece_nb = 0;
for (piece = 0; piece<=11; piece++ ) {
board.number[piece] = 0;
}

// piece lists

for (colour = 0; colour<=1; colour++ ) {

// piece list

pos = 0;

for (sq_64 = 0; sq_64<=63; sq_64++ ) {

sq = SquareFrom64[sq_64];
piece = board.square[sq];
if (piece != Empty  &&  (! piece_is_ok(piece))) {
my_fatal("board_init_list(): illegal position\n");
}

if (COLOUR_IS(piece,colour)  &&  (! PIECE_IS_PAWN(piece))) {

if (pos >= 16) {
my_fatal("board_init_list(): illegal position\n");
}
//ASSERT(50, pos>=0 && pos<16);

board.pos[sq] = pos;
board.piece[colour][pos] = sq;
pos = pos + 1;

board.piece_nb = board.piece_nb + 1;
board.number[this.PieceTo12[piece]] = board.number[this.PieceTo12[piece]] + 1;
}
}

if ( board.number[ ( COLOUR_IS_WHITE(colour) ? WhiteKing12 : BlackKing12 ) ] != 1) {
my_fatal("board_init_list(): illegal position\n");
}

//ASSERT(51, pos>=1 && pos<=16);
board.piece[colour][pos] = SquareNone;
board.piece_size[colour] = pos;

// MV sort

size = board.piece_size[colour];

for (i = 1; i<size; i++ ) {

square = board.piece[colour][i];
piece = board.square[square];
order = this.PieceOrder[piece];
pos = i;
while( pos > 0 ) {
sq=board.piece[colour][pos-1];
if( order <= this.PieceOrder[board.square[sq]] ) {
break;
}
//ASSERT(52, pos>0 && pos<size);
board.piece[colour][pos] = sq;
//ASSERT(53, board.pos[sq]==pos-1);
board.pos[sq] = pos;
pos = pos - 1;
}

//ASSERT(54, pos>=0 && pos<size);
board.piece[colour][pos] = square;
//ASSERT(55, board.pos[square]==i);
board.pos[square] = pos;
}

// debug

if (iDbg01) {

for (i = 0; i<board.piece_size[colour]; i++ ) {

sq = board.piece[colour][i];
//ASSERT(56, board.pos[sq]==i);

if (i == 0) {  // king
//ASSERT(57, PIECE_IS_KING(board.square[sq]));
} else { 
//ASSERT(58, ! PIECE_IS_KING(board.square[sq]));
//ASSERT(59, this.PieceOrder[board.square[board.piece[colour][i]]] <= this.PieceOrder[board.square[board.piece[colour][i-1]]]);
}
}
}

// pawn list

for (file = 0; file< FileNb; file++ ) {
board.pawn_file[colour][file] = 0;
}

pos = 0;

for (sq_64 = 0; sq_64<=63; sq_64++ ) {

sq = SquareFrom64[sq_64];
piece = board.square[sq];

if (COLOUR_IS(piece,colour)  &&  PIECE_IS_PAWN(piece)) {

if (pos >= 8  ||  this.SquareIsPromote[sq]) {
my_fatal("board_init_list(): illegal position\n");
}
//ASSERT(60, pos>=0 && pos<8);

board.pos[sq] = pos;
board.pawn[colour][pos] = sq;
pos = pos + 1;

board.piece_nb = board.piece_nb + 1;
board.number[this.PieceTo12[piece]] = board.number[this.PieceTo12[piece]] + 1;
board.pawn_file[colour][SQUARE_FILE(sq)] =
( board.pawn_file[colour][SQUARE_FILE(sq)] | this.BitEQ[PAWN_RANK(sq,colour)]);
}
}

//ASSERT(61, pos>=0 && pos<=8);
board.pawn[colour][pos] = SquareNone;
board.pawn_size[colour] = pos;

if (board.piece_size[colour] + board.pawn_size[colour] > 16) {
my_fatal("board_init_list(): illegal position\n");
}
}

// last square

board.cap_sq = SquareNone;

// PST

board.opening = board_opening(board);
board.endgame = board_endgame(board);

// hash key

for (i = 0; i<board.ply_nb; i++ ) {
board.stack[i] = 0; // HACK
}
board.sp = board.ply_nb;

board.key = hash_key(board);
board.pawn_key = hash_pawn_key(board);
board.material_key = hash_material_key(board);

// legality

if (! board_is_legal(board)) {
my_fatal("board_init_list(): illegal position\n");
}

// debug

//ASSERT(62, board_is_ok(board));
}

// board_is_legal()

private function board_is_legal( board:board_t ) :Boolean { 

return (! IS_IN_CHECK(board,COLOUR_OPP(board.turn)));
}

// board_is_check()

private function board_is_check( board:board_t ) :Boolean { 

return IS_IN_CHECK(board,board.turn);
}

// board_is_mate()

private function board_is_mate( board:board_t ) :Boolean { 

var attack:attack_t = new attack_t();   // attack_t[1]

attack_set(attack,board);

if (! ATTACK_IN_CHECK(attack)) {
return false; // not in check => not mate
}

if (legal_evasion_exist(board,attack)) {
return false; // legal move => not mate
}

return true; // in check && no legal move => mate
}

// board_is_stalemate()

private function board_is_stalemate( board:board_t ) :Boolean {

var list:list_t = new list_t();   // list_t[1];
var i :int = 0;      // int
var move :int = 0;   // int

// init

if (IS_IN_CHECK(board,board.turn)) {
return false; // in check => not stalemate
}

// move loop

gen_moves(list,board);

for (i = 0; i<list.size; i++ ) {
move = list.move[i];
if (pseudo_is_legal(move,board)) {
return false; // legal move => not stalemate
}
}

return true; // in check && no legal move => mate
}

// board_is_repetition()

private function board_is_repetition( board:board_t ) :Boolean {

var i :int = 0;   // int

// 50-move rule

if (board.ply_nb >= 100) { // potential draw

if (board.ply_nb > 100) {
return true;
}

//ASSERT(68, board.ply_nb==100);
return (! board_is_mate(board));
}

// position repetition

//ASSERT(69, board.sp>=board.ply_nb);

for (i = 4; i< board.ply_nb-1; i+=2 ) {
if (board.stack[board.sp-i] == board.key) {
return true;
}
}

return false;
}

// board_opening()

private function board_opening( board:board_t ) :int {

var opening :int = 0;   // int
var colour :int = 0;    // int
var ptr :int = 0;       // int
var sq :int = 0;        // int
var piece :int = 0;     // int

opening = 0;
for (colour = 0;  colour<=1; colour++ ) {

ptr = 0;
while(true) {
sq = board.piece[colour][ptr];
if(sq==SquareNone) {
break;
}
piece = board.square[sq];
opening = opening + Pget( this.PieceTo12[piece], this.SquareTo64[sq], Opening );
ptr = ptr + 1;
}

ptr = 0;
while(true) {
sq = board.pawn[colour][ptr];
if(sq==SquareNone) {
break;
}
piece = board.square[sq];
opening = opening + Pget( this.PieceTo12[piece], this.SquareTo64[sq], Opening );
ptr = ptr + 1;
}

}

return opening;
}

// board_endgame()

private function board_endgame( board:board_t ) :int {

var endgame :int = 0;   // int
var colour :int = 0;    // int
var ptr :int = 0;       // int
var sq :int = 0;        // int
var piece :int = 0;     // int

endgame = 0;
for (colour = 0;  colour<=1; colour++ ) {

ptr = 0;
while(true) {
sq = board.piece[colour][ptr];
if(sq==SquareNone) {
break;
}
piece = board.square[sq];
endgame = endgame + Pget( this.PieceTo12[piece], this.SquareTo64[sq], Endgame );
ptr = ptr + 1;
}

ptr = 0;
while(true) {
sq = board.pawn[colour][ptr];
if(sq==SquareNone) {
break;
}
piece = board.square[sq];
endgame = endgame + Pget( this.PieceTo12[piece], this.SquareTo64[sq], Endgame );
ptr = ptr + 1;
}

}

return endgame;
}

// end of board.cpp




// eval.cpp

//  functions

// eval_init()

private function eval_init():void { 

var colour :int = 0;   // int
var piece :int = 0;    // int

// UCI options

this.PieceActivityWeight = (option_get_int("Piece Activity") * 256 + 50) / 100;
this.KingSafetyWeight    = (option_get_int("King Safety")    * 256 + 50) / 100;
this.PassedPawnWeight    = (option_get_int("Passed Pawns")   * 256 + 50) / 100;

// mobility table

for (colour = 0;  colour<=1; colour++ ) {
this.MobUnit[colour] = [];
for (piece = 0; piece<PieceNb; piece++ ) {
this.MobUnit[colour][piece] = 0;
}
}

this.MobUnit[White][Empty] = MobMove;

this.MobUnit[White][BP] = MobAttack;
this.MobUnit[White][BN] = MobAttack;
this.MobUnit[White][BB] = MobAttack;
this.MobUnit[White][BR] = MobAttack;
this.MobUnit[White][BQ] = MobAttack;
this.MobUnit[White][BK] = MobAttack;

this.MobUnit[White][WP] = MobDefense;
this.MobUnit[White][WN] = MobDefense;
this.MobUnit[White][WB] = MobDefense;
this.MobUnit[White][WR] = MobDefense;
this.MobUnit[White][WQ] = MobDefense;
this.MobUnit[White][WK] = MobDefense;

this.MobUnit[Black][Empty] = MobMove;

this.MobUnit[Black][WP] = MobAttack;
this.MobUnit[Black][WN] = MobAttack;
this.MobUnit[Black][WB] = MobAttack;
this.MobUnit[Black][WR] = MobAttack;
this.MobUnit[Black][WQ] = MobAttack;
this.MobUnit[Black][WK] = MobAttack;

this.MobUnit[Black][BP] = MobDefense;
this.MobUnit[Black][BN] = MobDefense;
this.MobUnit[Black][BB] = MobDefense;
this.MobUnit[Black][BR] = MobDefense;
this.MobUnit[Black][BQ] = MobDefense;
this.MobUnit[Black][BK] = MobDefense;

// KingAttackUnit[]

for (piece = 0; piece<PieceNb; piece++ ) {
this.KingAttackUnit[piece] = 0;
}

this.KingAttackUnit[WN] = 1;
this.KingAttackUnit[WB] = 1;
this.KingAttackUnit[WR] = 2;
this.KingAttackUnit[WQ] = 4;

this.KingAttackUnit[BN] = 1;
this.KingAttackUnit[BB] = 1;
this.KingAttackUnit[BR] = 2;
this.KingAttackUnit[BQ] = 4;
}

// evalpos()

private function evalpos( board:board_t ) :int {

var opening :opening_t = new opening_t();   // int
var endgame :endgame_t = new endgame_t();   // int
var mat_info:material_info_t = new material_info_t();  // material_info_t[1]
var pawn_info:pawn_info_t = new pawn_info_t();     // pawn_info_t[1]
var mul :Array = [ 0, 0 ];   // int[ColourNb]
var phase :int = 0;  // int
var eval1 :int = 0;   // int
var wb :int = 0;     // int
var bb :int = 0;     // int

//ASSERT(85, board_is_legal(board));
//ASSERT(86, ! board_is_check(board)); // exceptions are extremely rare

// material

material_get_info(mat_info,board);

opening.v = opening.v + mat_info.opening;
endgame.v = endgame.v + mat_info.endgame;

mul[White] = mat_info.mul[White];
mul[Black] = mat_info.mul[Black];

// PST

opening.v = opening.v + board.opening;
endgame.v = endgame.v + board.endgame;

// pawns

pawn_get_info(pawn_info,board);

opening.v = opening.v + pawn_info.opening;
endgame.v = endgame.v + pawn_info.endgame;

// draw

eval_draw(board,mat_info,pawn_info,mul);

if (mat_info.mul[White] < mul[White]) {
mul[White] = mat_info.mul[White];
}
if (mat_info.mul[Black] < mul[Black]) {
mul[Black] = mat_info.mul[Black];
}

if (mul[White] == 0  &&  mul[Black] == 0) {
return ValueDraw;
}

// eval

eval_piece(board,mat_info,pawn_info,opening,endgame);
eval_king(board,mat_info,opening,endgame);
eval_passer(board,pawn_info,opening,endgame);
eval_pattern(board,opening,endgame);

// phase mix

phase = mat_info.phase;
eval1 = ((opening.v * (256 - phase)) + (endgame.v * phase)) / 256;

// drawish bishop endgames

if ( ( mat_info.flags & DrawBishopFlag ) != 0) {

wb = board.piece[White][1];
//ASSERT(87, PIECE_IS_BISHOP(board.square[wb]));

bb = board.piece[Black][1];
//ASSERT(88, PIECE_IS_BISHOP(board.square[bb]));

if (SQUARE_COLOUR(wb) != SQUARE_COLOUR(bb)) {
if (mul[White] == 16) {
mul[White] = 8; // 1/2
}
if (mul[Black] == 16) {
mul[Black] = 8; // 1/2
}
}
}

// draw bound

if (eval1 > ValueDraw) {
eval1 = (eval1 * mul[White]) / 16;
} else { 
if (eval1 < ValueDraw) {
eval1 = (eval1 * mul[Black]) / 16;
}
}

// value range

if (eval1 < -ValueEvalInf) {
eval1 = -ValueEvalInf;
}
if (eval1 > ValueEvalInf) {
eval1 = ValueEvalInf;
}

//ASSERT(89, eval1>=-ValueEvalInf && eval1<=ValueEvalInf);

// turn

if (COLOUR_IS_BLACK(board.turn)) {
eval1 = -eval1;
}

//ASSERT(90, ! value_is_mate(eval1));

return eval1;
}

// eval_draw()

private function eval_draw( board:board_t, mat_info:material_info_t, pawn_info:pawn_info_t, mul:Array ) :void { 

var colour :int = 0;    // int
var me :int = 0;        // int
var opp :int = 0;       // int
var pawn :int = 0;      // int
var king :int = 0;      // int
var pawn_file :int = 0; // int
var prom :int = 0;      // int
var list :Array = [];     // int list[7+1]
var ifelse :Boolean = false;

// draw patterns

for (colour = 0;  colour<=1; colour++ ) {

me = colour;
opp = COLOUR_OPP(me);

// KB*P+K* draw

if ( ( mat_info.cflags[me] & MatRookPawnFlag ) != 0 ) {

pawn = pawn_info.single_file[me];

if (pawn != SquareNone) {   // all pawns on one file

pawn_file = SQUARE_FILE(pawn);

if (pawn_file == FileA  ||  pawn_file == FileH) {

king = KING_POS(board,opp);
prom = PAWN_PROMOTE(pawn,me);

if (DISTANCE(king,prom) <= 1  && ( ! bishop_can_attack(board,prom,me))) {
mul[me] = 0;
}
}
}
}

// K(B)P+K+ draw

if ( ( mat_info.cflags[me] & MatBishopFlag ) != 0) {

pawn = pawn_info.single_file[me];

if (pawn != SquareNone) {   // all pawns on one file

king = KING_POS(board,opp);

if (SQUARE_FILE(king)  == SQUARE_FILE(pawn)
&& PAWN_RANK(king,me) >  PAWN_RANK(pawn,me)
&& (! bishop_can_attack(board,king,me))) {
mul[me] = 1;  // 1/16
}
}
}

// KNPK* draw

if ( ( mat_info.cflags[me] & MatKnightFlag ) != 0 ) {

pawn = board.pawn[me][0];
king = KING_POS(board,opp);

if (SQUARE_FILE(king)  == SQUARE_FILE(pawn)
&& PAWN_RANK(king,me) >  PAWN_RANK(pawn,me)
&& PAWN_RANK(pawn,me) <= Rank6) {
mul[me] = 1;  // 1/16
}
}
}

// recognisers, only heuristic draws herenot

ifelse = true;

if (ifelse && mat_info.recog == MAT_KPKQ) {

// KPKQ (white)

draw_init_list(list,board,White);

if (draw_kpkq(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KQKP) {

// KPKQ (black)

draw_init_list(list,board,Black);

if (draw_kpkq(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KPKR) {

// KPKR (white)

draw_init_list(list,board,White);

if (draw_kpkr(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KRKP) {

// KPKR (black)

draw_init_list(list,board,Black);

if (draw_kpkr(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KPKB) {

// KPKB (white)

draw_init_list(list,board,White);

if (draw_kpkb(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KBKP) {

// KPKB (black)

draw_init_list(list,board,Black);

if (draw_kpkb(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KPKN) {

// KPKN (white)

draw_init_list(list,board,White);

if (draw_kpkn(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KNKP) {

// KPKN (black)

draw_init_list(list,board,Black);

if (draw_kpkn(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KNPK) {

// KNPK (white)

draw_init_list(list,board,White);

if (draw_knpk(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KKNP) {

// KNPK (black)

draw_init_list(list,board,Black);

if (draw_knpk(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KRPKR) {

// KRPKR (white)

draw_init_list(list,board,White);

if (draw_krpkr(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KRKRP) {

// KRPKR (black)

draw_init_list(list,board,Black);

if (draw_krpkr(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KBPKB) {

// KBPKB (white)

draw_init_list(list,board,White);

if (draw_kbpkb(list,board.turn)) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KBKBP) {

// KBPKB (black)

draw_init_list(list,board,Black);

if (draw_kbpkb(list,COLOUR_OPP(board.turn))) {
mul[White] = 1; // 1/16;
mul[Black] = 1; // 1/16;
}

ifelse = false;
}
}

//
private function add_line( board:board_t, me:int, from:int, dx:int ):int { 

var to:int = from + dx;
var capture:int = 0;
var mob:int = 0;

while(true) {
capture=board.square[to];
if(capture!=Empty) {
break;
}
mob = mob + MobMove;
to = to + dx;
}

mob = mob + this.MobUnit[me][capture];

return mob;
}


// eval_piece()

private function eval_piece( board:board_t, mat_info:material_info_t, pawn_info:pawn_info_t, opening:opening_t, endgame:endgame_t ) :void {

var colour :int = 0;   // int
var op :Array = [ 0, 0 ];      // int[ColourNb]
var eg :Array = [ 0, 0 ];      // int[ColourNb]
var me :int = 0;       // int
var opp :int = 0;      // int
var opp_flag :int = 0; // int
var ptr :int = 0;      // int
var from :int = 0;     // int
var to :int = 0;       // int
var piece :int = 0;    // int
var mob :int = 0;      // int
var capture :int = 0;  // int
var unit :Array = [];     // int
var rook_file :int = 0;  // int
var king_file :int = 0;  // int
var king :int = 0;     // int
var delta :int = 0;    // int
var ptype:int = 0;

// eval

for (colour = 0;  colour<=1; colour++ ) {

me = colour;
opp = COLOUR_OPP(me);

opp_flag = COLOUR_FLAG(opp);

unit = this.MobUnit[me];

// piece loop

ptr = 1;            // HACK: no king
while(true) {
from = board.piece[me][ptr];
if(from==SquareNone) {
break;
}

piece = board.square[from];

ptype = PIECE_TYPE(piece);

if(ptype == Knight64) {

// mobility

mob = -KnightUnit;

mob = mob + unit[board.square[from-33]];
mob = mob + unit[board.square[from-31]];
mob = mob + unit[board.square[from-18]];
mob = mob + unit[board.square[from-14]];
mob = mob + unit[board.square[from+14]];
mob = mob + unit[board.square[from+18]];
mob = mob + unit[board.square[from+31]];
mob = mob + unit[board.square[from+33]];

op[me] = op[me] + (mob * KnightMobOpening);
eg[me] = eg[me] + (mob * KnightMobEndgame);

}

if(ptype == Bishop64) {

// mobility

mob = -BishopUnit;

mob = mob + add_line( board, me, from, -17 );
mob = mob + add_line( board, me, from, -15 );
mob = mob + add_line( board, me, from, 15 );
mob = mob + add_line( board, me, from, 17 );

op[me] = op[me] + (mob * BishopMobOpening);
eg[me] = eg[me] + (mob * BishopMobEndgame);

}

if(ptype == Rook64) {

// mobility

mob = -RookUnit;

mob = mob + add_line( board, me, from, -16 );
mob = mob + add_line( board, me, from, -1 );
mob = mob + add_line( board, me, from, 1 );
mob = mob + add_line( board, me, from, 16 );

op[me] = op[me] + (mob * RookMobOpening);
eg[me] = eg[me] + (mob * RookMobEndgame);

// open file

if (UseOpenFile) {

op[me] = op[me] - (RookOpenFileOpening / 2);
eg[me] = eg[me] - (RookOpenFileEndgame / 2);


rook_file = SQUARE_FILE(from);

if (board.pawn_file[me][rook_file] == 0) {   // no friendly pawn

op[me] = op[me] + RookSemiOpenFileOpening;
eg[me] = eg[me] + RookSemiOpenFileEndgame;

if (board.pawn_file[opp][rook_file] == 0) {  // no enemy pawn

op[me] = op[me] + RookOpenFileOpening - RookSemiOpenFileOpening;
eg[me] = eg[me] + RookOpenFileEndgame - RookSemiOpenFileEndgame;

}

if ( ( mat_info.cflags[opp] & MatKingFlag ) != 0) {

king = KING_POS(board,opp);
king_file = SQUARE_FILE(king);

delta = Math.abs(rook_file-king_file); // file distance

if (delta <= 1) {
op[me] = op[me] + RookSemiKingFileOpening;
if (delta == 0) {
op[me] = op[me] + RookKingFileOpening - RookSemiKingFileOpening;
}
}
}
}
}

// 7th rank

if (PAWN_RANK(from,me) == Rank7) {
// if opponent pawn on 7th rank+.
if ( ( pawn_info.flags[opp] & BackRankFlag ) != 0 ||
PAWN_RANK(KING_POS(board,opp),me) == Rank8) {
op[me] = op[me] + Rook7thOpening;
eg[me] = eg[me] + Rook7thEndgame;
}
}

}

if(ptype == Queen64) {

// mobility

mob = -QueenUnit;

mob = mob + add_line( board, me, from, -17 );
mob = mob + add_line( board, me, from, -16 );
mob = mob + add_line( board, me, from, -15 );
mob = mob + add_line( board, me, from, -1 );
mob = mob + add_line( board, me, from, 1 );
mob = mob + add_line( board, me, from, 15 );
mob = mob + add_line( board, me, from, 16 );
mob = mob + add_line( board, me, from, 17 );


op[me] = op[me] + (mob * QueenMobOpening);
eg[me] = eg[me] + (mob * QueenMobEndgame);

// 7th rank

if (PAWN_RANK(from,me) == Rank7) {
// if opponent pawn on 7th rank+.
if ( ( pawn_info.flags[opp] & BackRankFlag ) != 0 ||
PAWN_RANK(KING_POS(board,opp),me) == Rank8) {
op[me] = op[me] + Queen7thOpening;
eg[me] = eg[me] + Queen7Endgame;
}
}

}

ptr = ptr + 1;
}
}

// update

opening.v = opening.v + ((op[White] - op[Black]) * this.PieceActivityWeight) / 256;
endgame.v = endgame.v + ((eg[White] - eg[Black]) * this.PieceActivityWeight) / 256;
}

// eval_king()

private function eval_king( board:board_t, mat_info:material_info_t, opening:opening_t, endgame:endgame_t) :void {

var colour :int = 0;   // int
var op :Array = [ 0, 0 ]; // int[ColourNb]
var eg :Array = [ 0, 0 ]; // int[ColourNb]
var me :int = 0;       // int
var opp :int = 0;      // int
var from :int = 0;     // int

var penalty_1 :int = 0;   // int
var penalty_2 :int = 0;   // int

var tmp :int = 0;       // int
var penalty :int = 0;   // int

var king :int = 0;       // int
var ptr :int = 0;        // int
var piece :int = 0;      // int
var attack_tot :int = 0; // int
var piece_nb :int = 0;   // int

// king attacks

if (UseKingAttack) {

for (colour = 0;  colour<=1; colour++ ) {

if ( ( mat_info.cflags[colour] & MatKingFlag ) != 0) {

me = colour;
opp = COLOUR_OPP(me);

king = KING_POS(board,me);

// piece attacks

attack_tot = 0;
piece_nb = 0;

ptr = 1;        // HACK: no king
while(true) {
from=board.piece[opp][ptr];
if(from==SquareNone) {
break;
}

piece = board.square[from];

if (piece_attack_king(board,piece,from,king)) {
piece_nb = piece_nb + 1;
attack_tot = attack_tot + this.KingAttackUnit[piece];
}
ptr = ptr + 1;
}

// scoring

//ASSERT(104, piece_nb>=0 && piece_nb<16);
op[colour] = op[colour] - (attack_tot * KingAttackOpening * KingAttackWeight[piece_nb]) / 256;
}
}
}

// white pawn shelter

if (UseShelter  &&  ( mat_info.cflags[White] & MatKingFlag ) != 0) {

me = White;

// king

penalty_1 = shelter_square(board,KING_POS(board,me),me);

// castling

penalty_2 = penalty_1;

if ( ( board.flags & FlagsWhiteKingCastle ) != 0) {
tmp = shelter_square(board,G1,me);
if (tmp < penalty_2) {
penalty_2 = tmp;
}
}

if ( ( board.flags & FlagsWhiteQueenCastle ) != 0) {
tmp = shelter_square(board,B1,me);
if (tmp < penalty_2) {
penalty_2 = tmp;
}
}

//ASSERT(105, penalty_2>=0 && penalty_2<=penalty_1);

// penalty

penalty = (penalty_1 + penalty_2) / 2;
//ASSERT(106, penalty>=0);

op[me] = op[me] - (penalty * ShelterOpening) / 256;
}

// black pawn shelter

if (UseShelter  &&  ( mat_info.cflags[Black] & MatKingFlag ) != 0) {

me = Black;

// king

penalty_1 = shelter_square(board,KING_POS(board,me),me);

// castling

penalty_2 = penalty_1;

if ( ( board.flags & FlagsBlackKingCastle ) != 0) {
tmp = shelter_square(board,G8,me);
if (tmp < penalty_2) {
penalty_2 = tmp;
}
}

if ( ( board.flags & FlagsBlackQueenCastle ) != 0) {
tmp = shelter_square(board,B8,me);
if (tmp < penalty_2) {
penalty_2 = tmp;
}
}

//ASSERT(107, penalty_2>=0 && penalty_2<=penalty_1);

// penalty

penalty = (penalty_1 + penalty_2) / 2;
//ASSERT(108, penalty>=0);

op[me] = op[me] - (penalty * ShelterOpening) / 256;
}

// update

opening.v = opening.v + ((op[White] - op[Black]) * this.KingSafetyWeight) / 256;
endgame.v = endgame.v + ((eg[White] - eg[Black]) * this.KingSafetyWeight) / 256;
}

// eval_passer()

private function eval_passer( board:board_t, pawn_info:pawn_info_t, opening:opening_t, endgame:endgame_t ) :void {


var colour :int = 0;   // int
var op :Array = [ 0, 0 ]; // int[ColourNb]
var eg :Array = [ 0, 0 ]; // int[ColourNb]
var att :int = 0;      // int
var def :int = 0;      // int
var bits :int = 0;     // int
var file :int = 0;     // int
var rank :int = 0;     // int
var sq :int = 0;       // int
var min :int = 0;      // int
var max :int = 0;      // int
var delta :int = 0     // int

// passed pawns

for (colour = 0;  colour<=1; colour++ ) {

att = colour;
def = COLOUR_OPP(att);
bits = pawn_info.passed_bits[att];
while(true) {
if(bits == 0) {
break;
}

file = this.BitFirst[bits];
//ASSERT(113, file>=FileA && file<=FileH);

rank = this.BitLast[board.pawn_file[att][file] ];
//ASSERT(114, rank>=Rank2 && rank<=Rank7);

sq = SQUARE_MAKE(file,rank);
if (COLOUR_IS_BLACK(att)) {
sq = SQUARE_RANK_MIRROR(sq);
}

//ASSERT(115, PIECE_IS_PAWN(board.square[sq]));
//ASSERT(116, COLOUR_IS(board.square[sq],att));

// opening scoring

op[att] = op[att] + quad(PassedOpeningMin,PassedOpeningMax,rank);

// endgame scoring init

min = PassedEndgameMin;
max = PassedEndgameMax;

delta = max - min;
//ASSERT(117, delta>0);

// "dangerous" bonus

// defender has no piece
if (board.piece_size[def] <= 1
&&  (unstoppable_passer(board,sq,att)  ||  king_passer(board,sq,att))) {
delta = delta + UnstoppablePasser;
} else { 
if (free_passer(board,sq,att)) {
delta = delta + FreePasser;
}
}

// king-distance bonus

delta = delta - (pawn_att_dist(sq,KING_POS(board,att),att) * AttackerDistance);
delta = delta + (pawn_def_dist(sq,KING_POS(board,def),att) * DefenderDistance);

// endgame scoring

eg[att] = eg[att] + min;
if (delta > 0) {
eg[att] = eg[att] + quad(0,delta,rank);
}

bits = (bits & bits-1);
}
}

// update

opening.v = opening.v + ((op[White] - op[Black]) * this.PassedPawnWeight) / 256;
endgame.v = endgame.v + ((eg[White] - eg[Black]) * this.PassedPawnWeight) / 256;
}

// eval_pattern()

private function eval_pattern( board:board_t, opening:opening_t, endgame:endgame_t ) :void {

// trapped bishop (7th rank)

if ((board.square[A7] == WB  &&  board.square[B6] == BP)
||  (board.square[B8] == WB  &&  board.square[C7] == BP)) {
opening.v = opening.v - TrappedBishop;
endgame.v = endgame.v - TrappedBishop;
}

if ((board.square[H7] == WB  &&  board.square[G6] == BP)
||  (board.square[G8] == WB  &&  board.square[F7] == BP)) {
opening.v = opening.v - TrappedBishop;
endgame.v = endgame.v - TrappedBishop;
}

if ((board.square[A2] == BB  &&  board.square[B3] == WP)
||  (board.square[B1] == BB  &&  board.square[C2] == WP)) {
opening.v = opening.v + TrappedBishop;
endgame.v = endgame.v + TrappedBishop;
}

if ((board.square[H2] == BB  &&  board.square[G3] == WP)
||  (board.square[G1] == BB  &&  board.square[F2] == WP)) {
opening.v = opening.v + TrappedBishop;
endgame.v = endgame.v + TrappedBishop;
}

// trapped bishop (6th rank)

if (board.square[A6] == WB  &&  board.square[B5] == BP) {
opening.v = opening.v - (TrappedBishop / 2);
endgame.v = endgame.v - (TrappedBishop / 2);
}

if (board.square[H6] == WB  &&  board.square[G5] == BP) {
opening.v = opening.v - (TrappedBishop / 2);
endgame.v = endgame.v - (TrappedBishop / 2);
}

if (board.square[A3] == BB  &&  board.square[B4] == WP) {
opening.v = opening.v + (TrappedBishop / 2);
endgame.v = endgame.v + (TrappedBishop / 2);
}

if (board.square[H3] == BB  &&  board.square[G4] == WP) {
opening.v = opening.v + (TrappedBishop / 2);
endgame.v = endgame.v + (TrappedBishop / 2);
}

// blocked bishop

if (board.square[D2] == WP  &&  board.square[D3] != Empty  &&  board.square[C1] == WB) {
opening.v = opening.v - BlockedBishop;
}

if (board.square[E2] == WP  &&  board.square[E3] != Empty  &&  board.square[F1] == WB) {
opening.v = opening.v - BlockedBishop;
}

if (board.square[D7] == BP  &&  board.square[D6] != Empty  &&  board.square[C8] == BB) {
opening.v = opening.v + BlockedBishop;
}

if (board.square[E7] == BP  &&  board.square[E6] != Empty  &&  board.square[F8] == BB) {
opening.v = opening.v + BlockedBishop;
}

// blocked rook

if ((board.square[C1] == WK  ||  board.square[B1] == WK)
&&  (board.square[A1] == WR  ||  board.square[A2] == WR  ||  board.square[B1] == WR)) {
opening.v = opening.v - BlockedRook;
}

if ((board.square[F1] == WK  ||  board.square[G1] == WK)
&&  (board.square[H1] == WR  ||  board.square[H2] == WR  ||  board.square[G1] == WR)) {
opening.v = opening.v - BlockedRook;
}

if ((board.square[C8] == BK  ||  board.square[B8] == BK)
&&  (board.square[A8] == BR  ||  board.square[A7] == BR  ||  board.square[B8] == BR)) {
opening.v = opening.v + BlockedRook;
}

if ((board.square[F8] == BK  ||  board.square[G8] == BK)
&&  (board.square[H8] == BR  ||  board.square[H7] == BR  ||  board.square[G8] == BR)) {
opening.v = opening.v + BlockedRook;
}
}

// unstoppable_passer()

private function unstoppable_passer( board:board_t, pawn:int, colour:int ) :Boolean {

var me :int = 0;     // int
var opp :int = 0;    // int
var file :int = 0;   // int
var rank :int = 0;   // int
var king :int = 0;   // int
var prom :int = 0;   // int
var ptr :int = 0;    // int
var sq :int = 0;     // int
var dist :int = 0;   // int

//ASSERT(122, SQUARE_IS_OK(pawn));
//ASSERT(123, COLOUR_IS_OK(colour));

me = colour;
opp = COLOUR_OPP(me);

file = SQUARE_FILE(pawn);
rank = PAWN_RANK(pawn,me);

king = KING_POS(board,opp);

// clear promotion path?


ptr = 0;
while(true) {
sq=board.piece[me][ptr];
if(sq==SquareNone) {
break;
}

if (SQUARE_FILE(sq) == file  &&  PAWN_RANK(sq,me) > rank) {
return false; // "friendly" blocker
}
ptr = ptr + 1;
}


// init

if (rank == Rank2) {
pawn = pawn + PawnMoveInc[me];
rank = rank + 1;
//ASSERT(124, rank==PAWN_RANK(pawn,me));
}

//ASSERT(125, rank>=Rank3 && rank<=Rank7);

prom = PAWN_PROMOTE(pawn,me);

dist = DISTANCE(pawn,prom);
//ASSERT(126, dist==Rank8-rank);
if (board.turn == opp) {
dist = dist + 1;
}

if (DISTANCE(king,prom) > dist) {
return true; // not in the square
}

return false;
}

// king_passer()

private function king_passer( board:board_t, pawn:int, colour:int ) :Boolean {

var me :int = 0;     // int
var king :int = 0;   // int
var file :int = 0;   // int
var prom :int = 0;   // int

//ASSERT(128, SQUARE_IS_OK(pawn));
//ASSERT(129, COLOUR_IS_OK(colour));

me = colour;

king = KING_POS(board,me);
file = SQUARE_FILE(pawn);
prom = PAWN_PROMOTE(pawn,me);

if (DISTANCE(king,prom) <= 1
&&  DISTANCE(king,pawn) <= 1
&&  (SQUARE_FILE(king) != file
||  (file != FileA  &&  file != FileH))) {
return true;
}

return false;
}

// free_passer()

private function free_passer( board:board_t, pawn:int, colour:int ) :Boolean {

var me :int = 0;    // int
var opp :int = 0;   // int
var inc :int = 0;   // int
var sq :int = 0;    // int
var move :int = 0;  // int

//ASSERT(131, SQUARE_IS_OK(pawn));
//ASSERT(132, COLOUR_IS_OK(colour));

me = colour;
opp = COLOUR_OPP(me);

inc = PawnMoveInc[me];
sq = pawn + inc;
//ASSERT(133, SQUARE_IS_OK(sq));

if (board.square[sq] != Empty) {
return false;
}

move = MOVE_MAKE(pawn,sq);
if (see_move(move,board) < 0) {
return false;
}

return true;
}

// pawn_att_dist()

private function pawn_att_dist( pawn:int, king:int, colour:int ) :int {

var me :int = 0;      // int
var inc :int = 0;     // int
var target :int = 0;  // int

//ASSERT(134, SQUARE_IS_OK(pawn));
//ASSERT(135, SQUARE_IS_OK(king));
//ASSERT(136, COLOUR_IS_OK(colour));

me = colour;
inc = PawnMoveInc[me];

target = pawn + inc;

return DISTANCE(king,target);
}

// pawn_def_dist()

private function pawn_def_dist( pawn:int, king:int, colour:int ) :int {

var me :int = 0;      // int
var inc :int = 0;     // int
var target :int = 0;  // int

//ASSERT(137, SQUARE_IS_OK(pawn));
//ASSERT(138, SQUARE_IS_OK(king));
//ASSERT(139, COLOUR_IS_OK(colour));

me = colour;
inc = PawnMoveInc[me];

target = pawn + inc;

return DISTANCE(king,target);
}

// draw_init_list()

private function draw_init_list( list:Array, board:board_t, pawn_colour:int ) :void {

var pos :int = 0;   // int
var att :int = 0;   // int
var def :int = 0;   // int
var ptr :int = 0;   // int
var sq :int = 0;    // int
var pawn :int = 0;  // int
var i :int = 0;     // int

//ASSERT(142, COLOUR_IS_OK(pawn_colour));

// init

pos = 0;

att = pawn_colour;
def = COLOUR_OPP(att);

//ASSERT(143, board.pawn_size[att]==1);
//ASSERT(144, board.pawn_size[def]==0);

// att

ptr = 0;
while(true) {
sq=board.piece[att][ptr];
if(sq==SquareNone) {
break;
}
list[pos] = sq;
pos = pos + 1;
ptr = ptr + 1;
}

ptr = 0;
while(true) {
sq=board.pawn[att][ptr];
if(sq==SquareNone) {
break;
}
list[pos] = sq;
pos = pos + 1;
ptr = ptr + 1;
}

// def

ptr = 0;
while(true) {
sq=board.piece[def][ptr];
if(sq==SquareNone) {
break;
}
list[pos] = sq;
pos = pos + 1;
ptr = ptr + 1;
}

ptr = 0;
while(true) {
sq=board.pawn[def][ptr];
if(sq==SquareNone) {
break;
}
list[pos] = sq;
pos = pos + 1;
ptr = ptr + 1;
}


// } marker

//ASSERT(145, pos==board.piece_nb);

list[pos] = SquareNone;

// file flip?

pawn = board.pawn[att][0];

if (SQUARE_FILE(pawn) >= FileE) {
for (i = 0; i< pos; i++ ) {
list[i] = SQUARE_FILE_MIRROR(list[i]);
}
}

// rank flip?

if (COLOUR_IS_BLACK(pawn_colour)) {
for (i = 0; i< pos; i++ ) {
list[i] = SQUARE_RANK_MIRROR(list[i]);
}
}
}

// draw_kpkq()

private function draw_kpkq( list: Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int
var bq :int = 0;       // int
var prom :int = 0;     // int
var dist :int = 0;     // int
var wp_file :int = 0;  // int
var wp_rank :int = 0;  // int
var ifelse :Boolean = false;

//ASSERT(147, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(148, SQUARE_IS_OK(wk));

wp = list[1];
//ASSERT(149, SQUARE_IS_OK(wp));
//ASSERT(150, SQUARE_FILE(wp)<=FileD);

bk =  list[2];
//ASSERT(151, SQUARE_IS_OK(bk));

bq =  list[3];
//ASSERT(152, SQUARE_IS_OK(bq));

//ASSERT(153, list[4]==SquareNone);

// test

if (wp == A7) {

prom = A8;
dist = 4;

if (wk == B7  ||  wk == B8) {  // best case
if (COLOUR_IS_WHITE(turn)) {
dist = dist - 1;
}
} else { 
if (wk == A8  || ((wk == C7  ||  wk == C8)  &&  bq != A8)) {    // white loses a tempo
if (COLOUR_IS_BLACK(turn)  &&  SQUARE_FILE(bq) != FileB) {
return false;
}
} else { 
return false;
}
}

//ASSERT(154, bq!=prom);
if (DISTANCE(bk,prom) > dist) {
return true;
}
} else { 
if (wp == C7) {

prom = C8;
dist = 4;

ifelse = true;
if (ifelse && wk == C8) {     // dist = 0

dist = dist + 1; // self-blocking penalty
if (COLOUR_IS_WHITE(turn)) {
dist = dist - 1; // right-to-move bonus
}

ifelse = false;
}
if (ifelse && (wk == B7  ||  wk == B8)) { // dist = 1, right side

dist = dist - 1; // right-side bonus
if (DELTA_INC_LINE(wp-bq) == wk-wp) {
dist = dist + 1; // pinned-pawn penalty
}
if (COLOUR_IS_WHITE(turn)) {
dist = dist - 1; // right-to-move bonus
}

ifelse = false;
}

if (ifelse && (wk == D7  ||  wk == D8)) { // dist = 1, wrong side

if (DELTA_INC_LINE(wp-bq) == wk-wp) {
dist = dist + 1; // pinned-pawn penalty
}
if (COLOUR_IS_WHITE(turn)) {
dist = dist - 1; // right-to-move bonus
}

ifelse = false;
}

if (ifelse && ((wk == A7  ||  wk == A8)  &&  bq != C8)) {  // dist = 2, right side

if (COLOUR_IS_BLACK(turn)  &&  SQUARE_FILE(bq) != FileB) {
return false;
}

dist = dist - 1; // right-side bonus

ifelse = false;
}

if (ifelse && ((wk == E7  ||  wk == E8)  &&  bq != C8)) { // dist = 2, wrong side

if (COLOUR_IS_BLACK(turn)  &&  SQUARE_FILE(bq) != FileD) {
return false;
}

ifelse = false;
}
if (ifelse) {
return false;
}

//ASSERT(155, bq!=prom);
if (DISTANCE(bk,prom) > dist) {
return true;
}
}
}

return false;
}

// draw_kpkr()

private function draw_kpkr( list:Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int
var br :int = 0;       // int
var inc :int = 0;      // int
var prom :int = 0;     // int
var dist :int = 0;     // int
var wk_file :int = 0;  // int
var wk_rank :int = 0;  // int
var wp_file :int = 0;  // int
var wp_rank :int = 0;  // int
var br_file :int = 0;  // int
var br_rank :int = 0;  // int


//ASSERT(157, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(158, SQUARE_IS_OK(wk));

wp = list[1];
//ASSERT(159, SQUARE_IS_OK(wp));
//ASSERT(160, SQUARE_FILE(wp)<=FileD);

bk = list[2];
//ASSERT(161, SQUARE_IS_OK(bk));

br = list[3];
//ASSERT(162, SQUARE_IS_OK(br));

//ASSERT(163, list[4]==SquareNone);

// init

wk_file = SQUARE_FILE(wk);
wk_rank = SQUARE_RANK(wk);

wp_file = SQUARE_FILE(wp);
wp_rank = SQUARE_RANK(wp);

br_file = SQUARE_FILE(br);
br_rank = SQUARE_RANK(br);

inc = PawnMoveInc[White];
prom = PAWN_PROMOTE(wp,White);

// conditions

if (DISTANCE(wk,wp) == 1) {

//ASSERT(164, Math.abs(wk_file-wp_file)<=1);
//ASSERT(165, Math.abs(wk_rank-wp_rank)<=1);

// no-op

} else { 
if (DISTANCE(wk,wp) == 2  &&  Math.abs(wk_rank-wp_rank) <= 1) {

//ASSERT(166, Math.abs(wk_file-wp_file)==2);
//ASSERT(167, Math.abs(wk_rank-wp_rank)<=1);

if (COLOUR_IS_BLACK(turn)  &&  br_file != (wk_file + wp_file) / 2) {
return false;
}
} else { 
return false;
}
}

// white features

dist = DISTANCE(wk,prom) + DISTANCE(wp,prom);
if (wk == prom) {
dist = dist + 1;
}

if (wk == wp+inc) {  // king on pawn's "front square"
if (wp_file == FileA) {
return false;
}
dist = dist + 1; // self-blocking penalty
}

// black features

if (br_file != wp_file  &&  br_rank != Rank8) {
dist = dist - 1; // misplaced-rook bonus
}

// test

if (COLOUR_IS_WHITE(turn)) {
dist = dist - 1; // right-to-move bonus
}

if (DISTANCE(bk,prom) > dist) {
return true;
}

return false;
}

// draw_kpkb()

private function draw_kpkb( list:Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int
var bb :int = 0;       // int
var inc :int = 0;      // int
var en2 :int = 0;      // int
var to :int = 0;       // int
var delta :int = 0;    // int
var inc_2 :int = 0;    // int
var sq :int = 0;       // int


//ASSERT(169, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(170, SQUARE_IS_OK(wk));

wp = list[1];
//ASSERT(171, SQUARE_IS_OK(wp));
//ASSERT(172, SQUARE_FILE(wp)<=FileD);

bk = list[2];
//ASSERT(173, SQUARE_IS_OK(bk));

bb = list[3];
//ASSERT(174, SQUARE_IS_OK(bb));

//ASSERT(175, list[4]==SquareNone);

// blocked pawn?

inc = PawnMoveInc[White];
en2 = PAWN_PROMOTE(wp,White) + inc;

to = wp+inc;
while(to != en2) {

//ASSERT(176, SQUARE_IS_OK(to));

if (to == bb) {
return true; // direct blockade
}

delta = to - bb;
//ASSERT(177, delta_is_ok(delta));

if (PSEUDO_ATTACK(BB,delta)) {

inc_2 = DELTA_INC_ALL(delta);
//ASSERT(178, inc_2!=IncNone);

sq = bb;
while(true) {

sq = sq + inc_2;
//ASSERT(179, SQUARE_IS_OK(sq));
//ASSERT(180, sq!=wk);
//ASSERT(181, sq!=wp);
//ASSERT(182, sq!=bb);
if (sq == to) {
return true; // indirect blockade
}
if(sq == bk) {
break;
}

}
}
to = to + inc;
}

return false;
}

// draw_kpkn()

private function draw_kpkn( list:Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int
var bn :int = 0;       // int
var inc :int = 0;      // int
var en2 :int = 0;      // int
var file :int = 0;     // int
var sq :int = 0;       // int


//ASSERT(184, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(185, SQUARE_IS_OK(wk));

wp = list[1];
//ASSERT(186, SQUARE_IS_OK(wp));
//ASSERT(187, SQUARE_FILE(wp)<=FileD);

bk = list[2];
//ASSERT(188, SQUARE_IS_OK(bk));

bn = list[3];
//ASSERT(189, SQUARE_IS_OK(bn));

//ASSERT(190, list[4]==SquareNone);

// blocked pawn?

inc = PawnMoveInc[White];
en2 = PAWN_PROMOTE(wp,White) + inc;

file = SQUARE_FILE(wp);
if (file == FileA  ||  file == FileH) {
en2 = en2 - inc;
}

sq = wp+inc;
while(sq != en2) {

//ASSERT(191, SQUARE_IS_OK(sq));

if (sq == bn  ||  PSEUDO_ATTACK(BN,sq-bn)) {
return true; // blockade
}

sq = sq + inc;
}

return false;
}

// draw_knpk()

private function draw_knpk( list:Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wn :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int


//ASSERT(193, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(194, SQUARE_IS_OK(wk));

wn = list[1];
//ASSERT(195, SQUARE_IS_OK(wn));

wp = list[2];
//ASSERT(196, SQUARE_IS_OK(wp));
//ASSERT(197, SQUARE_FILE(wp)<=FileD);

bk = list[3];
//ASSERT(198, SQUARE_IS_OK(bk));

//ASSERT(199, list[4]==SquareNone);

// test

if (wp == A7  &&  DISTANCE(bk,A8) <= 1) {
return true;
}

return false;
}

// draw_krpkr()

private function draw_krpkr( list:Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wr :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int
var br :int = 0;       // int

var wp_file :int = 0;  // int
var wp_rank :int = 0;  // int
var bk_file :int = 0;  // int
var bk_rank :int = 0;  // int
var br_file :int = 0;  // int
var br_rank :int = 0;  // int

var prom :int = 0;     // int

//ASSERT(201, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(202, SQUARE_IS_OK(wk));

wr = list[1];
//ASSERT(203, SQUARE_IS_OK(wr));

wp = list[2];
//ASSERT(204, SQUARE_IS_OK(wp));
//ASSERT(205, SQUARE_FILE(wp)<=FileD);

bk = list[3];
//ASSERT(206, SQUARE_IS_OK(bk));

br = list[4];
//ASSERT(207, SQUARE_IS_OK(br));

//ASSERT(208, list[5]==SquareNone);

// test

wp_file = SQUARE_FILE(wp);
wp_rank = SQUARE_RANK(wp);

bk_file = SQUARE_FILE(bk);
bk_rank = SQUARE_RANK(bk);

br_file = SQUARE_FILE(br);
br_rank = SQUARE_RANK(br);

prom = PAWN_PROMOTE(wp,White);

if (bk == prom) {

// TODO: rook near Rank1 if wp_rank == Rank6?

if (br_file > wp_file) {
return true;
}

} else { 
if (bk_file == wp_file  &&  bk_rank > wp_rank) {

return true;

} else { 
if (wr == prom  &&  wp_rank == Rank7  &&  (bk == G7  ||  bk == H7)  &&  br_file == wp_file) {

if (br_rank <= Rank3) {
if (DISTANCE(wk,wp) > 1) {
return true;
}
} else {  // br_rank >= Rank4
if (DISTANCE(wk,wp) > 2) {
return true;
}
}
}
}
}

return false;
}

// draw_kbpkb()

private function draw_kbpkb( list:Array, turn:int ) :Boolean {

var wk :int = 0;       // int
var wb :int = 0;       // int
var wp :int = 0;       // int
var bk :int = 0;       // int
var bb :int = 0;       // int

var inc :int = 0;      // int
var en2 :int = 0;      // int
var to :int = 0;       // int
var delta :int = 0;    // int
var inc_2 :int = 0;    // int
var sq :int = 0;       // int


//ASSERT(210, COLOUR_IS_OK(turn));

// load

wk = list[0];
//ASSERT(211, SQUARE_IS_OK(wk));

wb = list[1];
//ASSERT(212, SQUARE_IS_OK(wb));

wp = list[2];
//ASSERT(213, SQUARE_IS_OK(wp));
//ASSERT(214, SQUARE_FILE(wp)<=FileD);

bk = list[3];
//ASSERT(215, SQUARE_IS_OK(bk));

bb = list[4];
//ASSERT(216, SQUARE_IS_OK(bb));

//ASSERT(217, list[5]==SquareNone);

// opposit colour?

if (SQUARE_COLOUR(wb) == SQUARE_COLOUR(bb)) {
return false; // TODO
}

// blocked pawn?

inc = PawnMoveInc[White];
en2 = PAWN_PROMOTE(wp,White) + inc;

to = wp+inc;
while( to != en2 ) {

//ASSERT(218, SQUARE_IS_OK(to));

if (to == bb) {
return true; // direct blockade
}

delta = to - bb;
//ASSERT(219, delta_is_ok(delta));

if (PSEUDO_ATTACK(BB,delta)) {

inc_2 = DELTA_INC_ALL(delta);
//ASSERT(220, inc_2!=IncNone);

sq = bb;
while(true) {
sq = sq + inc_2;
//ASSERT(221, SQUARE_IS_OK(sq));
//ASSERT(222, sq!=wk);
//ASSERT(223, sq!=wb);
//ASSERT(224, sq!=wp);
//ASSERT(225, sq!=bb);
if (sq == to) {
return true; // indirect blockade
}
if (sq == bk) {
break;
}
}
}
to = to + inc;
}

return false;
}

// shelter_square()

private function shelter_square( board:board_t, square:int, colour:int ) :int {

var penalty :int = 0;   // int
var file :int = 0;      // int
var rank :int = 0;      // int

//ASSERT(227, SQUARE_IS_OK(square));
//ASSERT(228, COLOUR_IS_OK(colour));

penalty = 0;

file = SQUARE_FILE(square);
rank = PAWN_RANK(square,colour);

penalty = penalty + ( shelter_file(board,file,rank,colour) * 2 );
if (file != FileA) {
penalty = penalty + shelter_file(board,file-1,rank,colour);
}
if (file != FileH) {
penalty = penalty + shelter_file(board,file+1,rank,colour);
}

if (penalty == 0) {
penalty = 11; // weak back rank
}

if (UseStorm) {
penalty = penalty + storm_file(board,file,colour);
if (file != FileA) {
penalty = penalty + storm_file(board,file-1,colour);
}
if (file != FileH) {
penalty = penalty + storm_file(board,file+1,colour);
}
}

return penalty;
}

// shelter_file()

private function shelter_file( board:board_t, file:int, rank:int, colour:int ) :int {

var dist :int = 0;      // int
var penalty :int = 0;   // int

//ASSERT(230, file>=FileA && file<=FileH);
//ASSERT(231, rank>=Rank1 && rank<=Rank8);
//ASSERT(232, COLOUR_IS_OK(colour));

dist = this.BitFirst[ ( board.pawn_file[colour][file] & this.BitGE[rank]) ];
//ASSERT(233, dist>=Rank2 && dist<=Rank8);

dist = Rank8 - dist;
//ASSERT(234, dist>=0 && dist<=6);

penalty = 36 - (dist * dist);
//ASSERT(235, penalty>=0 && penalty<=36);

return penalty;
}

// storm_file()

private function storm_file( board:board_t, file:int, colour:int ) :int {

var dist :int = 0;      // int
var penalty :int = 0;   // int

//ASSERT(237, file>=FileA && file<=FileH);
//ASSERT(238, COLOUR_IS_OK(colour));

dist = this.BitLast[board.pawn_file[COLOUR_OPP(colour)][file] ];
//ASSERT(239, dist>=Rank1 && dist<=Rank7);

penalty = 0;

if(dist == Rank4) {
penalty = StormOpening * 1;
} else { 
if(dist == Rank5) {
penalty = StormOpening * 3;
} else { 
if(dist == Rank6) {
penalty = StormOpening * 6;
}
}
}

return penalty;
}

// bishop_can_attack()

private function bishop_can_attack( board:board_t, to:int, colour:int ) :Boolean {

var ptr :int = 0;    // int
var from :int = 0;   // int
var piece :int = 0;  // int

//ASSERT(241, SQUARE_IS_OK(to));
//ASSERT(242, COLOUR_IS_OK(colour));

ptr = 1;                // HACK: no king
while(true) {
from = board.piece[colour][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

if (PIECE_IS_BISHOP(piece)  &&  SQUARE_COLOUR(from) == SQUARE_COLOUR(to)) {
return true;
}
ptr = ptr + 1;
}

return false;
}

// end of eval.cpp



// fen.cpp

//  functions

private function if_fen_err( logic:Boolean, fenstr:String, pos:int ):void { 
if(logic) {
my_fatal("board_from_fen(): bad FEN " + fenstr + " at pos=" + string_from_int(pos) + " \n");
}
}

// board_from_fen()

private function board_from_fen( board:board_t, fenstr:String ) :void {

var pos :int = 0;   // int
var file :int = 0;  // int
var rank :int = 0;  // int
var sq :int = 0;    // int
var c :String = " ";   // char
var nb :String = "";   // string
var i :int = 0;     // int
var len :int = 0;   // int
var piece :int = 0; // int
var pawn :int = 0;  // int
var fen :Array = [];  // char[]
var gotoupdate :Boolean = false;

board_clear(board);

for (i = 0; i<fenstr.length; i++ ) {
fen[i] = fenstr.charAt(i);
}

pos = 0;
c = fen[pos];

// piece placement

for (rank = Rank8; rank>=Rank1; rank-- ) {

file = FileA;
while ( file <= FileH ) {

if (c >= "1"  &&  c <= "8") {            // empty square(s)

len = (c.charCodeAt(0) - ("0").charCodeAt(0));

for (i = 0; i<len; i++ ) {
if_fen_err( file > FileH, fenstr, pos );

board.square[SQUARE_MAKE(file,rank)] = Empty;
file = file + 1;
}

} else {   // piece

piece = piece_from_char(c);
if_fen_err( piece == PieceNone256, fenstr, pos );

board.square[SQUARE_MAKE(file,rank)] = piece;
file = file + 1;
}

pos = pos + 1;
c = fen[pos];
}

if (rank > Rank1) {
if_fen_err( c != "/", fenstr, pos );
pos = pos + 1;
c = fen[pos];

}
}

// active colour

if_fen_err( c != " ", fenstr, pos );

pos = pos + 1;
c = fen[pos];

if(c=="w") {
board.turn = White;
} else { 
if(c=="b") {
board.turn = Black;
} else { 
if_fen_err( true, fenstr, pos );
}
}

pos = pos + 1;
c = fen[pos];

// castling

if_fen_err( c != " ", fenstr, pos );

pos = pos + 1;
c = fen[pos];

board.flags = FlagsNone;

if (c == "-") {    // no castling rights

pos = pos + 1;
c = fen[pos];

} else { 


if (c == "K") {
if (board.square[E1] == WK  &&  board.square[H1] == WR) {
board.flags = ( board.flags | FlagsWhiteKingCastle );
}
pos = pos + 1;
c = fen[pos];
}

if (c == "Q") {
if (board.square[E1] == WK  &&  board.square[A1] == WR) {
board.flags = ( board.flags | FlagsWhiteQueenCastle );
}
pos = pos + 1;
c = fen[pos];
}

if (c == "k") {
if (board.square[E8] == BK  &&  board.square[H8] == BR) {
board.flags = ( board.flags | FlagsBlackKingCastle );
}
pos = pos + 1;
c = fen[pos];
}

if (c == "q") {
if (board.square[E8] == BK  &&  board.square[A8] == BR) {
board.flags = ( board.flags | FlagsBlackQueenCastle );
}
pos = pos + 1;
c = fen[pos];
}
}

// en-passant

if_fen_err( c != " ", fenstr, pos );

pos = pos + 1;
c = fen[pos];

if (c == "-") {   // no en-passant

sq = SquareNone;
pos = pos + 1;
c = fen[pos];

} else { 

if_fen_err( c < "a"  ||  c > "h", fenstr, pos );
file = file_from_char(c);
pos = pos + 1;
c = fen[pos];

if_fen_err( c != (COLOUR_IS_WHITE(board.turn) ? "6" : "3"), fenstr, pos );

rank = rank_from_char(c);
pos = pos + 1;
c = fen[pos];

sq = SQUARE_MAKE(file,rank);
pawn = SQUARE_EP_DUAL(sq);

if (board.square[sq] != Empty
||  board.square[pawn] != PawnMake[COLOUR_OPP(board.turn)]
||  (board.square[pawn-1] != PawnMake[board.turn]
&&  board.square[pawn+1] != PawnMake[board.turn])) {
sq = SquareNone;
}
}

board.ep_square = sq;

// halfmove clock

board.ply_nb = 0;
board.movenumb = 0;

if (c != " ") {
if (! Strict) {
gotoupdate = true;
} else { 
if_fen_err( true, fenstr, pos );
}
}

if( ! gotoupdate ) {
pos = pos + 1;
c = fen[pos];

if (c<"0" || c>"9") {
if (! Strict) {
gotoupdate = true;
} else { 
if_fen_err( true, fenstr, pos );
}
}
}

if( ! gotoupdate ) {
nb = str_after_ok( fenstr.substr( pos ), " ");  // ignore halfmove clock
board.ply_nb = parseInt( nb );
board.movenumb = board.ply_nb;  // just save it
}

// board update

// update:
board_init_list(board);
}

// board_to_fen()

private function board_to_fen( board:board_t, strfen:string_t ) :Boolean {

var file :int = 0;   // int
var rank :int = 0;   // int
var sq :int = 0;     // int
var piece :int = 0;  // int
var c :String = " ";    // string
var len :int = 0;    // int
var fen :String = "";   // string
var str1 :string_t = new string_t()

// piece placement

for (rank = Rank8; rank>=Rank1; rank-- ) {

file = FileA;
while( file <= FileH ) {

sq = SQUARE_MAKE(file,rank);
piece = board.square[sq];
//ASSERT(248, piece==Empty || piece_is_ok(piece));

if (piece == Empty) {

len = 0;
while( file <= FileH  &&  board.square[SQUARE_MAKE(file,rank)] == Empty ) {

file = file + 1;
len = len + 1;
}

//ASSERT(249, len>=1 && len<=8);
c = String.fromCharCode(  ("0").charCodeAt(0) + len );

} else { 

c = piece_to_char(piece);
file = file + 1;
}

fen = fen + c;

}

if( rank != Rank1 ) {
fen = fen + "/";
}
}

// active colour

fen = fen + " " + (COLOUR_IS_WHITE(board.turn) ? "w" : "b" ) + " ";

// castling

if (board.flags == FlagsNone) {
fen = fen + "-";
} else { 
if ( ( board.flags & FlagsWhiteKingCastle) != 0) {
fen = fen + "K";
}
if ( ( board.flags & FlagsWhiteQueenCastle) != 0) {
fen = fen + "Q";
}
if ( ( board.flags & FlagsBlackKingCastle) != 0) {
fen = fen + "k";
}
if ( ( board.flags & FlagsBlackQueenCastle) != 0) {
fen = fen + "q";
}
}

fen = fen + " ";

// en-passant

if (board.ep_square == SquareNone) {
fen = fen + "-";
} else { 
square_to_string(board.ep_square, str1 );
fen = fen + str1.v;
}

fen = fen + " ";

// ignoring halfmove clock

fen = fen + "0 " + string_from_int(board.movenumb);

strfen.v = fen;

return true;
}

// to see on screen

private function printboard() :void {

var file :int = 0;   // int
var rank :int = 0;   // int
var sq :int = 0;     // int
var piece :int = 0;  // int
var str1:string_t = new string_t()
var s :String = "";     //  string
var board:board_t = this.SearchInput.board;

// piece placement

for (rank = Rank8; rank>=Rank1; rank-- ) {

file = FileA;
while( file <= FileH ) {

sq = SQUARE_MAKE(file,rank);
piece = board.square[sq];
//ASSERT(248, piece==Empty || piece_is_ok(piece));

if(piece == Empty) {
s = s + ".";
} else { 
s = s + piece_to_char(piece);
}

file = file + 1;
}

s = s + "\n";
}

board_to_fen( board, str1 );

s = s + str1.v + "\n";

print2out(s);

}

// end of fen.cpp


// hash.cpp

// 64-bit private functions for 32-bit reality, we accept collisions for slower interpreter


//  functions

// hash_init()

private function hash_init(): void { 

var i :int = 0;   // int

for (i = 0; i<=15; i++ ) {
this.Castle64[i] = hash_castle_key(i);
}
}

// hash_key()

private function hash_key( board:board_t ):int {    // uint64 
var key :int = 0     // uint64;
var colour :int = 0; // int
var ptr :int = 0;    // int
var sq :int = 0;     // int
var piece :int = 0;  // int

// init

key = 0;

// pieces

for (colour = 0;  colour<=1; colour++ ) {

ptr = 0;
while(true) {
sq=board.piece[colour][ptr];
if(sq== SquareNone) {
break;
}

piece = board.square[sq];
key = ( key ^ hash_piece_key(piece,sq) );

ptr = ptr + 1;
}


ptr = 0;
while(true) {
sq=board.pawn[colour][ptr];
if(sq== SquareNone) {
break;
}

piece = board.square[sq];
key = ( key ^ hash_piece_key(piece,sq) );

ptr = ptr + 1;
}

}

// castle flags

key = ( key ^ hash_castle_key(board.flags) );

// en-passant square

sq = board.ep_square;
if (sq != SquareNone) {
key = ( key ^ hash_ep_key(sq) );
}

// turn

key = ( key ^ hash_turn_key(board.turn) );

return key;
}

// hash_pawn_key()

private function hash_pawn_key( board:board_t ):int { // uint64 

var key :int = 0     // uint64;
var colour :int = 0; // int
var ptr :int = 0;    // int
var sq :int = 0;     // int
var piece :int = 0;  // int


// init

key = 0;

// pawns

for (colour = 0;  colour<=1; colour++ ) {

ptr = 0;
while(true) {
sq=board.pawn[colour][ptr];
if(sq== SquareNone) {
break;
}

piece = board.square[sq];
key = ( key ^ hash_piece_key(piece,sq) );

ptr = ptr + 1;
}

}

return key;
}

// hash_material_key()

private function hash_material_key( board:board_t ):int {  // uint64 

var key :int = 0     // uint64;
var piece1:int = 0;  // int
var count :int = 0;  // int


// init

key = 0;

// counters

for (piece1 = 0; piece1<=11; piece1++ ) {
count = board.number[piece1];
key = ( key ^ hash_counter_key(piece1,count) );
}

return key;

}

// hash_piece_key()

private function hash_piece_key( piece:int, square:int ):int {  // uint64 

//ASSERT(253, piece_is_ok(piece));
//ASSERT(254, SQUARE_IS_OK(square));

return this.Random64[RandomPiece+(this.PieceTo12[piece] ^ 1)*64 + this.SquareTo64[square] ];
// HACK: xor 1 for PolyGlot book (not AS3)
}

// hash_castle_key()

private function hash_castle_key( flags:int ):int  {  // uint64 

var key :int = 0     // uint64;
var i :int = 0;      // int

//ASSERT(255, (flags & bnotxF)==0);

key = 0;

for (i = 0; i<=3; i++ ) {
if ( ( flags & (1 << i) ) != 0) {
key = ( key ^ this.Random64[RandomCastle+i] );
}
}

return key;
}

// hash_ep_key()

private function hash_ep_key( square:int ):int  {  // uint64 

//ASSERT(256, SQUARE_IS_OK(square));

return this.Random64[RandomEnPassant+SQUARE_FILE(square)-FileA ];
}

// hash_turn_key()

private function hash_turn_key( colour:int ):int  { // uint64 

//ASSERT(257, COLOUR_IS_OK(colour));

return (COLOUR_IS_WHITE(colour) ? this.Random64[RandomTurn] : 0 );
}

// hash_counter_key()

private function hash_counter_key( piece_12:int, count:int ):int  { // uint64 

var key :int = 0     // uint64;
var i :int = 0;      // int
var index :int = 0;  // int

//ASSERT(258, piece_12>=0 && piece_12<12);
//ASSERT(259, count>=0 && count<=10);

// init

key = 0;

// counter

index = piece_12 * 16;
for (i = 0; i<count; i++ ) {
key = ( key ^ this.Random64[index+i] );
}

return key;

}

// end of hash.cpp





// list.cpp

//  functions

// list_is_ok()

private function list_is_ok( list:list_t ) :Boolean {


if (list.size < 0  ||  list.size >= ListSize) {
return false;
}

return true;
}

// list_remove()

private function list_remove( list:list_t, pos:int ) :void {

var i :int = 0;   // int

//ASSERT(260, list_is_ok(list));
//ASSERT(261, pos>=0 && pos<list.size);

for (i = pos; i<= list.size-2; i++ ) {
list.move[i] = list.move[i+1];
list.value[i] = list.value[i+1];
}

list.size = list.size - 1;
}

// list_copy()

private function list_copy( dst:list_t, src:list_t )  :void {

var i :int = 0;   // int

//ASSERT(263, list_is_ok(src));

dst.size = src.size;

for (i = 0; i< src.size; i++ ) {
dst.move[i] = src.move[i];
dst.value[i] = src.value[i];
}
}

// list_sort()

private function list_sort( list:list_t )  :void {

var size :int = 0;   // int
var i :int = 0;      // int
var j :int = 0;      // int
var move :int = 0;   // int
var value :int = 0;  // int

//ASSERT(264, list_is_ok(list));

// init

size = list.size;
list.value[size] = -32768; // HACK: sentinel

// insert sort (stable)

for (i = size-2; i>=0; i-- ) {

move = list.move[i];
value = list.value[i];

j = i;
while( value < list.value[j+1] ) {
list.move[j] = list.move[j+1];
list.value[j] = list.value[j+1];
j = j + 1;
}

//ASSERT(265, j<size);

list.move[j] = move;
list.value[j] = value;
}

// debug

if (iDbg01) {
for (i = 0; i<=size-2; i++ ) {
//ASSERT(266, list.value[i]>=list.value[i+1]);
}
}
}

// list_contain()

private function list_contain( list:list_t, move:int ) :Boolean {

var i :int = 0;   // int

//ASSERT(267, list_is_ok(list));
//ASSERT(268, move_is_ok(move));

for (i = 0; i<list.size; i++ ) {
if (list.move[i] == move) {
return true;
}
}

return false;
}

// list_note()

private function list_note( list:list_t )  :void {

var i :int = 0;      // int
var move :int = 0;   // int

//ASSERT(269, list_is_ok(list));

for (i = 0; i<list.size; i++ ) {
move = list.move[i];
//ASSERT(270, move_is_ok(move));
list.value[i] = -move_order(move);
}
}

// list_filter()

private function list_filter( list:list_t, board:board_t, keep:Boolean ) :void {

var pos :int = 0;   // int
var i :int = 0;     // int
var move :int = 0;  // int
var value :int = 0; // int

pos = 0;

for (i = 0; i<list.size; i++ ) {

//ASSERT(275, pos>=0 && pos<=i);

move = list.move[i];
value = list.value[i];

if (pseudo_is_legal(move,board) == keep) {
list.move[pos] = move;
list.value[pos] = value;
pos = pos + 1;
}
}

//ASSERT(276, pos>=0 && pos<=list.size);
list.size = pos;

// debug

//ASSERT(277, list_is_ok(list));
}

// end of list.cpp




// material.cpp

//  functions

// material_init()

private function material_init(): void { 

// UCI options

this.MaterialWeight = (option_get_int("Material") * 256 + 50) / 100;

// material table

this.Material.size = 0;
this.Material.mask = 0;
}

// material_alloc()

private function material_alloc(): void { 

if (UseTable) {

this.Material.size = MaterialTableSize;
this.Material.mask = this.Material.size - 1;   // 2^x -1
// Material.table = (entry_t *) my_malloc(Material.size*sizeof(entry_t));

material_clear();
}

}

// material_clear()

private function material_clear(): void { 

var i:int = 0;

this.Material.table = [];
this.Material.used = 0;
this.Material.read_nb = 0;
this.Material.read_hit = 0;
this.Material.write_nb = 0;
this.Material.write_collision = 0;

}

// material_get_info()

private function material_get_info( info:material_info_t, board:board_t )  :void {

var key :int = 0;             // uint64
var entry:material_info_t = new material_info_t();         // *
var index:int = 0;

// probe

if (UseTable) {

this.Material.read_nb = this.Material.read_nb + 1;

key = board.material_key;
index = ( KEY_INDEX(key) & this.Material.mask );

entry = this.Material.table[index];

if(entry==null) {
this.Material.table[index] = new material_info_t();
entry = this.Material.table[index];
}

if (entry.lock == KEY_LOCK(key)) {

// found

this.Material.read_hit = this.Material.read_hit + 1;

material_info_copy( info, entry );

return;
}
}

// calculation

material_comp_info(info,board);

// store

if (UseTable) {

this.Material.write_nb = this.Material.write_nb + 1;

if (entry.lock == 0) {     // HACK: assume free entry
this.Material.used = this.Material.used + 1;
} else { 
this.Material.write_collision = this.Material.write_collision + 1;
}

material_info_copy( entry, info );

entry.lock = KEY_LOCK(key);
}

}

// material_comp_info()

private function material_comp_info( info:material_info_t,  board:board_t)  :void {

var wp :int = 0;   // int
var wn :int = 0;   // int
var wb :int = 0;   // int
var wr :int = 0;   // int
var wq :int = 0;   // int
var bp :int = 0;   // int
var bn :int = 0;   // int
var bb :int = 0;   // int
var br :int = 0;   // int
var bq :int = 0;   // int

var wt :int = 0;   // int
var bt :int = 0;   // int
var wm :int = 0;   // int
var bm :int = 0;   // int

var colour :int = 0;  // int
var recog :int = 0;   // int
var flags :int = 0;   // int
var cflags :Array = [ 0, 0 ]; // int[ColourNb]
var mul :Array = [ 16, 16 ];    // int[ColourNb]
var phase :int = 0;   // int
var opening :int = 0; // int
var endgame :int = 0; // int
var ifelse :Boolean = false;


// init

wp = board.number[WhitePawn12];
wn = board.number[WhiteKnight12];
wb = board.number[WhiteBishop12];
wr = board.number[WhiteRook12];
wq = board.number[WhiteQueen12];

bp = board.number[BlackPawn12];
bn = board.number[BlackKnight12];
bb = board.number[BlackBishop12];
br = board.number[BlackRook12];
bq = board.number[BlackQueen12];

wt = wq + wr + wb + wn + wp; // no king
bt = bq + br + bb + bn + bp; // no king

wm = wb + wn;
bm = bb + bn;

var w_maj :int = wq * 2 + wr;         // int
var w_min :int = wb + wn;             // int
var w_tot :int = w_maj * 2 + w_min;   // int

var b_maj :int = bq * 2 + br;         // int
var b_min :int = bb + bn;             // int
var b_tot :int = b_maj * 2 + b_min;   // int

// recogniser

recog = MAT_NONE;

ifelse = true;

if (ifelse && (wt == 0  &&  bt == 0)) {

recog = MAT_KK;

ifelse = false;
}

if (ifelse && (wt == 1  &&  bt == 0)) {

if (wb == 1) {
recog = MAT_KBK;
}
if (wn == 1) {
recog = MAT_KNK;
}
if (wp == 1) {
recog = MAT_KPK;
}

ifelse = false;
}

if (ifelse && (wt == 0  &&  bt == 1)) {

if (bb == 1) {
recog = MAT_KKB;
}
if (bn == 1) {
recog = MAT_KKN;
}
if (bp == 1) {
recog = MAT_KKP;
}

ifelse = false;
}

if (ifelse && (wt == 1  &&  bt == 1)) {

if (wq == 1  &&  bq == 1) {
recog = MAT_KQKQ;
}
if (wq == 1  &&  bp == 1) {
recog = MAT_KQKP;
}
if (wp == 1  &&  bq == 1) {
recog = MAT_KPKQ;
}
if (wr == 1  &&  br == 1) {
recog = MAT_KRKR;
}
if (wr == 1  &&  bp == 1) {
recog = MAT_KRKP;
}
if (wp == 1  &&  br == 1) {
recog = MAT_KPKR;
}
if (wb == 1  &&  bb == 1) {
recog = MAT_KBKB;
}
if (wb == 1  &&  bp == 1) {
recog = MAT_KBKP;
}
if (wp == 1  &&  bb == 1) {
recog = MAT_KPKB;
}
if (wn == 1  &&  bn == 1) {
recog = MAT_KNKN;
}
if (wn == 1  &&  bp == 1) {
recog = MAT_KNKP;
}
if (wp == 1  &&  bn == 1) {
recog = MAT_KPKN;
}

ifelse = false;
}

if (ifelse && (wt == 2  &&  bt == 0)) {

if (wb == 1  &&  wp == 1) {
recog = MAT_KBPK;
}
if (wn == 1  &&  wp == 1) {
recog = MAT_KNPK;
}

ifelse = false;
}

if (ifelse && (wt == 0  &&  bt == 2)) {

if (bb == 1  &&  bp == 1) {
recog = MAT_KKBP;
}
if (bn == 1  &&  bp == 1) {
recog = MAT_KKNP;
}

ifelse = false;
}

if (ifelse && (wt == 2  &&  bt == 1)) {

if (wr == 1  &&  wp == 1  &&  br == 1) {
recog = MAT_KRPKR;
}
if (wb == 1  &&  wp == 1  &&  bb == 1) {
recog = MAT_KBPKB;
}

ifelse = false;
}

if (ifelse && (wt == 1  &&  bt == 2)) {

if (wr == 1  &&  br == 1  &&  bp == 1) {
recog = MAT_KRKRP;
}
if (wb == 1  &&  bb == 1  &&  bp == 1) {
recog = MAT_KBKBP;
}

ifelse = false;
}

// draw node (exact-draw recogniser)

flags = 0; // TODO: MOVE ME

// if no major piece || pawn
if (wq+wr+wp == 0  &&  bq+br+bp == 0) {
// at most one minor => KK, KBK || KNK
if (wm + bm <= 1 ||  recog == MAT_KBKB) {
flags = ( flags | DrawNodeFlag );
}

} else { 
if (recog == MAT_KPK   ||  recog == MAT_KKP ||  recog == MAT_KBPK  ||  recog == MAT_KKBP) {
flags = ( flags | DrawNodeFlag );
}
}

// bishop endgame
// if only bishops
if (wq+wr+wn == 0  &&  bq+br+bn == 0) {
if (wb == 1  &&  bb == 1) {
if (wp-bp >= -2  &&  wp-bp <= 2) {    // pawn diff <= 2
flags = ( flags | DrawBishopFlag );
}
}
}

// white multiplier

if (wp == 0) {  // white has no pawns

ifelse = true;
if (ifelse && (w_tot == 1)) {

//ASSERT(283, w_maj==0);
//ASSERT(284, w_min==1);

// KBK* || KNK*, always insufficient

mul[White] = 0;


ifelse = false;
}

if (ifelse && (w_tot == 2  &&  wn == 2)) {

//ASSERT(285, w_maj==0);
//ASSERT(286, w_min==2);

// KNNK*, usually insufficient

if (b_tot != 0  ||  bp == 0) {
mul[White] = 0;
} else {    // KNNKP+, might not be draw
mul[White] = 1; // 1/16
}

ifelse = false;
}

if (ifelse && (w_tot == 2  &&  wb == 2  &&  b_tot == 1  &&  bn == 1)) {

//ASSERT(287, w_maj==0);
//ASSERT(288, w_min==2);
//ASSERT(289, b_maj==0);
//ASSERT(290, b_min==1);

// KBBKN*, barely drawish (not at all?)

mul[White] = 8; // 1/2

ifelse = false;
}

if (ifelse && (w_tot-b_tot <= 1  &&  w_maj <= 2)) {

// no more than 1 minor up, drawish

mul[White] = 2; // 1/8
ifelse = false;
}

} else { 

if (wp == 1) { // white has one pawn

if (b_min != 0) {

// assume black sacrifices a minor against the lone pawn

b_min = b_min - 1;
b_tot = b_tot + 1;

ifelse = true;
if (ifelse && (w_tot == 1)) {

//ASSERT(291, w_maj==0);
//ASSERT(292, w_min==1);

// KBK* || KNK*, always insufficient

mul[White] = 4; // 1/4

ifelse = false;
}

if (ifelse && (w_tot == 2  &&  wn == 2)) {

//ASSERT(293, w_maj==0);
//ASSERT(294, w_min==2);

// KNNK*, usually insufficient

mul[White] = 4; // 1/4

ifelse = false;
}

if (ifelse && (w_tot-b_tot <= 1  &&  w_maj <= 2)) {

// no more than 1 minor up, drawish

mul[White] = 8; // 1/2

ifelse = false;
}

} else { 
if (br != 0) {

// assume black sacrifices a rook against the lone pawn

b_maj = b_maj - 1;
b_tot = b_tot - 2;

ifelse = true;
if (ifelse && (w_tot == 1)) {

//ASSERT(295, w_maj==0);
//ASSERT(296, w_min==1);

// KBK* || KNK*, always insufficient

mul[White] = 4; // 1/4

ifelse = false;
}

if (ifelse && (w_tot == 2  &&  wn == 2)) {

//ASSERT(297, w_maj==0);
//ASSERT(298, w_min==2);

// KNNK*, usually insufficient

mul[White] = 4; // 1/4

ifelse = false;
}

if (ifelse && (w_tot-b_tot <= 1  &&  w_maj <= 2)) {

// no more than 1 minor up, drawish

mul[White] = 8; // 1/2

ifelse = false;
}

}
}

}
}

// black multiplier

if (bp == 0) {    // black has no pawns


ifelse = true;
if (ifelse && (b_tot == 1)) {

//ASSERT(299, b_maj==0);
//ASSERT(300, b_min==1);

// KBK* || KNK*, always insufficient

mul[Black] = 0;

ifelse = false;
}

if (ifelse && (b_tot == 2  &&  bn == 2)) {

//ASSERT(301, b_maj==0);
//ASSERT(302, b_min==2);

// KNNK*, usually insufficient

if (w_tot != 0  ||  wp == 0) {
mul[Black] = 0;
} else {   // KNNKP+, might not be draw
mul[Black] = 1; // 1/16
}

ifelse = false;
}

if (ifelse && (b_tot == 2  &&  bb == 2  &&  w_tot == 1  &&  wn == 1)) {

//ASSERT(303, b_maj==0);
//ASSERT(304, b_min==2);
//ASSERT(305, w_maj==0);
//ASSERT(306, w_min==1);

// KBBKN*, barely drawish (not at all?)

mul[Black] = 8; // 1/2

ifelse = false;
}

if (ifelse && (b_tot-w_tot <= 1  &&  b_maj <= 2)) {

// no more than 1 minor up, drawish

mul[Black] = 2; // 1/8

ifelse = false;
}

} else { 
if (bp == 1) {  // black has one pawn

if (w_min != 0) {

// assume white sacrifices a minor against the lone pawn

w_min = w_min - 1;
w_tot = w_tot - 1;

ifelse = true;
if (ifelse && (b_tot == 1)) {

//ASSERT(307, b_maj==0);
//ASSERT(308, b_min==1);

// KBK* || KNK*, always insufficient

mul[Black] = 4; // 1/4

ifelse = false;
}

if (ifelse && (b_tot == 2  &&  bn == 2)) {

//ASSERT(309, b_maj==0);
//ASSERT(310, b_min==2);

// KNNK*, usually insufficient

mul[Black] = 4; // 1/4

ifelse = false;
}

if (ifelse && (b_tot-w_tot <= 1  &&  b_maj <= 2)) {

// no more than 1 minor up, drawish

mul[Black] = 8; // 1/2

ifelse = false;
}

} else { 
if (wr != 0) {

// assume white sacrifices a rook against the lone pawn

w_maj = w_maj - 1;
w_tot = w_tot - 2;

ifelse = true;
if (ifelse && (b_tot == 1)) {

//ASSERT(311, b_maj==0);
//ASSERT(312, b_min==1);

// KBK* || KNK*, always insufficient

mul[Black] = 4; // 1/4

ifelse = false;
}

if (ifelse && (b_tot == 2  &&  bn == 2)) {

//ASSERT(313, b_maj==0);
//ASSERT(314, b_min==2);

// KNNK*, usually insufficient

mul[Black] = 4; // 1/4

ifelse = false;
}

if (ifelse && (b_tot-w_tot <= 1  &&  b_maj <= 2)) {

// no more than 1 minor up, drawish

mul[Black] = 8; // 1/2

ifelse = false;
}

}
}
}
}

// potential draw for white

if (wt == wb+wp  &&  wp >= 1) {
cflags[White] = ( cflags[White] | MatRookPawnFlag );
}
if (wt == wb+wp  &&  wb <= 1  &&  wp >= 1  &&  bt > bp) {
cflags[White] = ( cflags[White] | MatBishopFlag );
}

if (wt == 2  &&  wn == 1  &&  wp == 1  &&  bt > bp) {
cflags[White] = ( cflags[White] | MatKnightFlag );
}

// potential draw for black

if (bt == bb+bp  &&  bp >= 1) {
cflags[Black] = ( cflags[Black] | MatRookPawnFlag );
}
if (bt == bb+bp  &&  bb <= 1  &&  bp >= 1  &&  wt > wp) {
cflags[Black] = ( cflags[Black] | MatBishopFlag );
}

if (bt == 2  &&  bn == 1  &&  bp == 1  &&  wt > wp) {
cflags[Black] = ( cflags[Black] | MatKnightFlag );
}

// draw leaf (likely draw)

if (recog == MAT_KQKQ  ||  recog == MAT_KRKR) {
mul[White] = 0;
mul[Black] = 0;
}

// king safety

if (bq >= 1  &&  bq+br+bb+bn >= 2) {
cflags[White] = ( cflags[White] | MatKingFlag );
}
if (wq >= 1  &&  wq+wr+wb+wn >= 2) {
cflags[Black] = ( cflags[Black] | MatKingFlag );
}

// phase (0: opening . 256: endgame)

phase = TotalPhase;

phase = phase - (wp * PawnPhase);
phase = phase - (wn * KnightPhase);
phase = phase - (wb * BishopPhase);
phase = phase - (wr * RookPhase);
phase = phase - (wq * QueenPhase);

phase = phase - (bp * PawnPhase);
phase = phase - (bn * KnightPhase);
phase = phase - (bb * BishopPhase);
phase = phase - (br * RookPhase);
phase = phase - (bq * QueenPhase);

if (phase < 0) {
phase = 0;
}

//ASSERT(315, phase>=0 && phase<=TotalPhase);
phase = Math.min( ((phase * 256) + (TotalPhase / 2)) / TotalPhase, 256 );

//ASSERT(316, phase>=0 && phase<=256);

// material

opening = 0;
endgame = 0;

opening = opening + (wp * PawnOpening);
opening = opening + (wn * KnightOpening);
opening = opening + (wb * BishopOpening);
opening = opening + (wr * RookOpening);
opening = opening + (wq * QueenOpening);

opening = opening - (bp * PawnOpening);
opening = opening - (bn * KnightOpening);
opening = opening - (bb * BishopOpening);
opening = opening - (br * RookOpening);
opening = opening - (bq * QueenOpening);

endgame = endgame + (wp * PawnEndgame);
endgame = endgame + (wn * KnightEndgame);
endgame = endgame + (wb * BishopEndgame);
endgame = endgame + (wr * RookEndgame);
endgame = endgame + (wq * QueenEndgame);

endgame = endgame - (bp * PawnEndgame);
endgame = endgame - (bn * KnightEndgame);
endgame = endgame - (bb * BishopEndgame);
endgame = endgame - (br * RookEndgame);
endgame = endgame - (bq * QueenEndgame);

// bishop pair

if (wb >= 2) {     // HACK: assumes different colours
opening = opening + BishopPairOpening;
endgame = endgame + BishopPairEndgame;
}

if (bb >= 2) {     // HACK: assumes different colours
opening = opening - BishopPairOpening;
endgame = endgame - BishopPairEndgame;
}

// store info

info.recog = recog;
info.flags = flags;

for (colour = 0;  colour<=1; colour++ ) {
info.cflags[colour] = cflags[colour];
info.mul[colour] = mul[colour];
}

info.phase = phase;
info.opening = (opening * this.MaterialWeight) / 256;
info.endgame = (endgame * this.MaterialWeight) / 256;
}

// end of material.cpp



// move.cpp

//  functions

// move_is_ok()

private function move_is_ok( move:int ) :Boolean {

if (move < 0  ||  move >= 65536 || move == MoveNone || move == Movenull) {
return false;
}
return true;
}

// move_promote()

private function move_promote( move:int ) :int {

var code :int = 0;   // int
var piece :int = 0;  // int

//ASSERT(317, move_is_ok(move));

//ASSERT(318, MOVE_IS_PROMOTE(move));

code = ( (move >> 12) & 3 );
piece = this.PromotePiece[code];

if (SQUARE_RANK(MOVE_TO(move)) == Rank8) {
piece = ( piece | WhiteFlag );
} else { 
//ASSERT(319, SQUARE_RANK(MOVE_TO(move))==Rank1);
piece = ( piece | BlackFlag );
}

//ASSERT(320, piece_is_ok(piece));

return piece;
}

// move_order()

private function move_order( move:int ) :int {

//ASSERT(321, move_is_ok(move));

return ( ( (move & V07777) << 2 ) | ( (move >> 12) & 3 ) );
}

// move_is_capture()

private function move_is_capture( move:int, board:board_t ) :Boolean {

//ASSERT(322, move_is_ok(move));

return MOVE_IS_EN_PASSANT(move) || (board.square[MOVE_TO(move)] != Empty);
}

// move_is_under_promote()

private function move_is_under_promote( move:int ) :Boolean {

//ASSERT(324, move_is_ok(move));

return MOVE_IS_PROMOTE(move) && ( ( move & MoveAllFlags ) != MovePromoteQueen );
}

// move_is_tactical()

private function move_is_tactical( move:int, board:board_t ) :Boolean {

//ASSERT(325, move_is_ok(move));

return ( (move & (1 << 15))!= 0 )  ||  (board.square[MOVE_TO(move)] != Empty); // HACK
}

// move_capture()


private function move_capture( move:int, board:board_t ) :int {

//ASSERT(327, move_is_ok(move));

if (MOVE_IS_EN_PASSANT(move)) {
return PAWN_OPP(board.square[MOVE_FROM(move)]);
}

return board.square[MOVE_TO(move)];
}

// move_to_string()

private function move_to_string( move:int, str1:string_t ) :Boolean {

var str2:string_t = new string_t()

//ASSERT(329, move==Movenull || move_is_ok(move));

// null move

if (move == Movenull) {
return true;
}

// normal moves

str1.v = "";
square_to_string( MOVE_FROM(move), str2 );
str1.v = str1.v + str2.v;
square_to_string( MOVE_TO(move), str2 );
str1.v = str1.v + str2.v;
//ASSERT(332, (str1.v.length==4));

// promotes

if (MOVE_IS_PROMOTE(move)) {
str1.v = str1.v + ( piece_to_char(move_promote(move)) ).toLowerCase();
}

return true;
}

// move_from_string()

private function move_from_string( str1:string_t, board:board_t ) :int {

var str2:string_t = new string_t()
var c :String = " ";         // char;

var from :int = 0;        // int
var to :int = 0;          // int
var move :int = 0;        // int
var piece :int = 0;       // int
var delta :int = 0;       // int

// from

str2.v = str1.v.substr( 0, 2 );

from = square_from_string(str2);
if (from == SquareNone) {
return MoveNone;
}

// to

str2.v = str1.v.substr( 2, 2 );

to = square_from_string(str2);
if (to == SquareNone) {
return MoveNone;
}

move = MOVE_MAKE(from,to);

// promote

if( str1.v.length>4 ) {
c = str1.v.charAt( 4 );
if(c=="n") {
move = ( move | MovePromoteKnight );
}
if(c=="b") {
move = ( move | MovePromoteBishop );
}
if(c=="r") {
move = ( move | MovePromoteRook );
}
if(c=="q") {
move = ( move | MovePromoteQueen );
}
}

// flags

piece = board.square[from];

if (PIECE_IS_PAWN(piece)) {
if (to == board.ep_square) {
move = ( move | MoveEnPassant );
}
} else { 
if (PIECE_IS_KING(piece)) {
delta = to - from;
if (delta == 2  ||  delta == -2) {
move = ( move | MoveCastle );
}
}
}

return move;
}

// end of move.cpp




// move_check.cpp

//  functions

// gen_quiet_checks()

private function gen_quiet_checks( list:list_t,  board:board_t ) :void {


//ASSERT(337, ! board_is_check(board));

list.size=0;

add_quiet_checks(list,board);
add_castle_checks(list,board);

// debug

//ASSERT(338, list_is_ok(list));
}

// add_quiet_checks()

private function add_quiet_checks( list:list_t,  board:board_t ) :void {

var me :int = 0;    // int
var opp :int = 0;   // int
var king :int = 0;  // int

var ptr :int = 0;   // int
var ptr_2 :int = 0; // int

var from :int = 0;  // int
var to :int = 0;    // int
var sq :int = 0;    // int

var piece :int = 0;    // int
var inc_ptr :int = 0;  // int
var inc :int = 0;      // int
var pawn :int = 0;   // int
var rank :int = 0;   // int
var pin :Array = [];   // int[8+1]
var gotonextpiece :Boolean = false;

// init

me = board.turn;
opp = COLOUR_OPP(me);

king = KING_POS(board,opp);

find_pins(pin,board);

// indirect checks

ptr = 0;
while(true) {
from = pin[ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

//ASSERT(341, is_pinned(board,from,opp));

if (PIECE_IS_PAWN(piece)) {

inc = PawnMoveInc[me];
rank = PAWN_RANK(from,me);

if (rank != Rank7) {    // promotes are generated with captures
to = from + inc;
if (board.square[to] == Empty) {
if (DELTA_INC_LINE(to-king) != DELTA_INC_LINE(from-king)) {
//ASSERT(342, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
if (rank == Rank2) {
to = from + (2*inc);
if (board.square[to] == Empty) {
//ASSERT(343, DELTA_INC_LINE(to-king)!=DELTA_INC_LINE(from-king));
//ASSERT(344, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}
}
}

} else { 
if (PIECE_IS_SLIDER(piece)) {

inc_ptr = 0;
while(true) {
inc = this.PieceInc[piece][inc_ptr];
if( inc == IncNone ) {
break;
}

to = from+inc;
while(true) {

if( board.square[to] != Empty ) {
break;
}

//ASSERT(345, DELTA_INC_LINE(to-king)!=DELTA_INC_LINE(from-king));
LIST_ADD(list,MOVE_MAKE(from,to));

to = to + inc;
}
inc_ptr = inc_ptr + 1;
}

} else { 

inc_ptr = 0;
while(true) {
inc = this.PieceInc[piece][inc_ptr];
if( inc == IncNone ) {
break;
}

to = from + inc;
if (board.square[to] == Empty) {
if (DELTA_INC_LINE(to-king) != DELTA_INC_LINE(from-king)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}
}

inc_ptr = inc_ptr + 1;
}

}
}
ptr = ptr + 1;
}

// piece direct checks

ptr = 1;       // HACK: no king
while(true) {
from = board.piece[me][ptr];
if( from == SquareNone ) {
break;
}

ptr_2 = 0;
while(true) {
sq = pin[ptr_2];
if( sq == SquareNone ) {
break;
}

if (sq == from) {
gotonextpiece = true;
break;
}

ptr_2 = ptr_2 + 1;
}

if(gotonextpiece) {

gotonextpiece = false;

} else { 

//ASSERT(346, ! is_pinned(board,from,opp));

piece = board.square[from];

if (PIECE_IS_SLIDER(piece)) {

inc_ptr = 0;
while(true) {
inc = this.PieceInc[piece][inc_ptr];
if( inc == IncNone ) {
break;
}

to = from+inc;
while(true) {

if( board.square[to] != Empty ) {
break;
}

if (PIECE_ATTACK(board,piece,to,king)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}

to = to + inc;
}
inc_ptr = inc_ptr + 1;
}


} else { 

inc_ptr = 0;
while(true) {
inc = this.PieceInc[piece][inc_ptr];
if( inc == IncNone ) {
break;
}

to = from + inc;
if (board.square[to] == Empty) {
if (PSEUDO_ATTACK(piece,king-to)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}
}

inc_ptr = inc_ptr + 1;
}

}

}

// next_piece:

ptr = ptr + 1;
}

// pawn direct checks

inc = PawnMoveInc[me];
pawn = PawnMake[me];

to = king - (inc-1);
//ASSERT(347, PSEUDO_ATTACK(pawn,king-to));

from = to - inc;
if (board.square[from] == pawn) {
if (board.square[to] == Empty) {
//ASSERT(348, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
} else { 
from = to - (2*inc);
if (board.square[from] == pawn) {
if (PAWN_RANK(from,me) == Rank2
&&  board.square[to] == Empty
&&  board.square[from+inc] == Empty) {
//ASSERT(349, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}

to = king - (inc+1);
//ASSERT(350, PSEUDO_ATTACK(pawn,king-to));

from = to - inc;
if (board.square[from] == pawn) {
if (board.square[to] == Empty) {
//ASSERT(351, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
} else { 
from = to - (2*inc);
if (board.square[from] == pawn) {
if (PAWN_RANK(from,me) == Rank2
&&  board.square[to] == Empty
&&  board.square[from+inc] == Empty) {
//ASSERT(352, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}

}

// add_castle_checks()

private function add_castle_checks( list:list_t,  board:board_t ) :void {


//ASSERT(355, ! board_is_check(board));

if (COLOUR_IS_WHITE(board.turn)) {

if ( ( board.flags & FlagsWhiteKingCastle) != 0
&&  board.square[F1] == Empty
&&  board.square[G1] == Empty
&&  (! is_attacked(board,F1,Black))) {
add_check(list,MOVE_MAKE_FLAGS(E1,G1,MoveCastle),board);
}

if ( ( board.flags & FlagsWhiteQueenCastle) != 0
&&  board.square[D1] == Empty
&&  board.square[C1] == Empty
&&  board.square[B1] == Empty
&&  (! is_attacked(board,D1,Black))) {
add_check(list,MOVE_MAKE_FLAGS(E1,C1,MoveCastle),board);
}

} else {  // black

if ( ( board.flags & FlagsBlackKingCastle) != 0
&&  board.square[F8] == Empty
&&  board.square[G8] == Empty
&&  (! is_attacked(board,F8,White))) {
add_check(list,MOVE_MAKE_FLAGS(E8,G8,MoveCastle),board);
}

if ( ( board.flags & FlagsBlackQueenCastle) != 0
&&  board.square[D8] == Empty
&&  board.square[C8] == Empty
&&  board.square[B8] == Empty
&&  (! is_attacked(board,D8,White))) {
add_check(list,MOVE_MAKE_FLAGS(E8,C8,MoveCastle),board);
}
}
}

// add_check()

private function add_check( list:list_t, move:int, board:board_t ) : void {

var undo:undo_t = new undo_t();    // undo_t[1];

//ASSERT(357, move_is_ok(move));

if(move == 20282)
{
	var iii:int = 8;
}
move_do(board,move,undo);
if (IS_IN_CHECK(board,board.turn)) {
LIST_ADD(list,move);
}
move_undo(board,move,undo);
}

// move_is_check()

private function move_is_check( move:int, board:board_t ) :Boolean {

var undo:undo_t = new undo_t();    // undo_t[1];

var check :Boolean = false;   // bool
var me :int = 0;          // int
var opp :int = 0;         // int
var king :int = 0;        // int
var from :int = 0;        // int
var to :int = 0;          // int
var piece :int = 0;       // int

//ASSERT(359, move_is_ok(move));

// slow test for complex moves

if (MOVE_IS_SPECIAL(move)) {

move_do(board,move,undo);
check = IS_IN_CHECK(board,board.turn);
move_undo(board,move,undo);

return check;
}

// init

me = board.turn;
opp = COLOUR_OPP(me);
king = KING_POS(board,opp);

from = MOVE_FROM(move);
to = MOVE_TO(move);
piece = board.square[from];
//ASSERT(361, COLOUR_IS(piece,me));

// direct check

if (PIECE_ATTACK(board,piece,to,king)) {
return true;
}

// indirect check

if (is_pinned(board,from,opp)
&&  DELTA_INC_LINE(king-to) != DELTA_INC_LINE(king-from)) {
return true;
}

return false;
}

// find_pins()

private function find_pins( list:Array, board:board_t ) :void {

var me :int = 0;    // int
var opp :int = 0;   // int
var king :int = 0;  // int
var ptr :int = 0;   // int
var from :int = 0;  // int
var piece :int = 0; // int
var delta :int = 0; // int
var inc :int = 0;   // int
var sq :int = 0;    // int
var pin :int = 0;   // int
var capture :int = 0;   // int
var q :int = 0;         // int

// init

me = board.turn;
opp = COLOUR_OPP(me);

king = KING_POS(board,opp);

ptr = 1;            // HACK: no king
while(true) {
from = board.piece[me][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

delta = king - from;
//ASSERT(364, delta_is_ok(delta));

if (PSEUDO_ATTACK(piece,delta)) {

//ASSERT(365, PIECE_IS_SLIDER(piece));

inc = DELTA_INC_LINE(delta);
//ASSERT(366, inc!=IncNone);

//ASSERT(367, SLIDER_ATTACK(piece,inc));

sq = from;

while(true) {
sq = sq + inc;
capture = board.square[sq];
if( capture != Empty ) {
break;
}
}

//ASSERT(368, sq!=king);

if (COLOUR_IS(capture,me)) {
pin = sq;

while(true) {
sq = sq + inc;

if( board.square[sq] != Empty ) {
break;
}
}

if (sq == king) {

list[q] = pin;
q = q + 1;

}
}
}

ptr = ptr + 1;
}

list[q] = SquareNone;
}

// end of move_check.cpp



// move_do.cpp

//  functions

private function initCmsk( sq:int, flagMask:int ): void { 
this.CastleMask[sq] = ( this.CastleMask[sq] & (~ flagMask ) );
}

// move_do_init()

private function move_do_init(): void { 

var sq :int = 0;   // int

for (sq = 0; sq<SquareNb; sq++ ) {
this.CastleMask[sq] = 0xF;
}

initCmsk( E1, FlagsWhiteKingCastle );
initCmsk( H1, FlagsWhiteKingCastle );

initCmsk( E1, FlagsWhiteQueenCastle );
initCmsk( A1, FlagsWhiteQueenCastle );

initCmsk( E8, FlagsBlackKingCastle );
initCmsk( H8, FlagsBlackKingCastle );

initCmsk( E8, FlagsBlackQueenCastle );
initCmsk( A8, FlagsBlackQueenCastle );

}

// move_do()

private function move_do( board:board_t, move:int, undo:undo_t ) :void {

var me :int = 0;        // int
var opp :int = 0;       // int
var from :int = 0;      // int
var to :int = 0;        // int
var piece :int = 0;     // int
var pos :int = 0;       // int
var capture :int = 0;   // int
var old_flags :int = 0; // int
var new_flags :int = 0; // int

var delta :int = 0;  // int
var sq :int = 0;     // int
var pawn :int = 0;   // int
var rook :int = 0;   // int

//ASSERT(370, move_is_ok(move));

//ASSERT(372, board_is_legal(board));

// initialise undo

undo.capture = false;

undo.turn = board.turn;
undo.flags = board.flags;
undo.ep_square = board.ep_square;
undo.ply_nb = board.ply_nb;

undo.cap_sq = board.cap_sq;

undo.opening = board.opening;
undo.endgame = board.endgame;

undo.key = board.key;
undo.pawn_key = board.pawn_key;
undo.material_key = board.material_key;

// init

me = board.turn;
opp = COLOUR_OPP(me);

from = MOVE_FROM(move);
to = MOVE_TO(move);

piece = board.square[from];
if(!COLOUR_IS(piece, me))
 {
	 var iii:int = 3;
 }
//ASSERT(373, COLOUR_IS(piece,me));

// update key stack

//ASSERT(374, board.sp<StackSize);
board.stack[board.sp] = board.key;
board.sp = board.sp + 1;

// update turn

board.turn = opp;


// update castling rights

old_flags = board.flags;
new_flags = ( ( old_flags & this.CastleMask[from] ) & this.CastleMask[to] );

board.flags = new_flags;


// update en-passant square

sq = board.ep_square;
if (sq != SquareNone) {

board.ep_square = SquareNone;
}

if (PIECE_IS_PAWN(piece)) {

delta = to - from;

if (delta == 32  ||  delta == -32) {
pawn = PawnMake[opp];
if (board.square[to-1] == pawn  ||  board.square[to+1] == pawn) {
board.ep_square = (from + to) / 2;
}
}
}

// update move number (captures are handled later)

board.ply_nb = board.ply_nb + 1;
if (PIECE_IS_PAWN(piece)) {
board.ply_nb = 0; // conversion
}

// update last square

board.cap_sq = SquareNone;

// remove the captured piece

sq = to;
if (MOVE_IS_EN_PASSANT(move)) {
sq = SQUARE_EP_DUAL(sq);
}

capture=board.square[sq];
if (capture!= Empty) {

//ASSERT(375, COLOUR_IS(capture,opp));
//ASSERT(376, ! PIECE_IS_KING(capture));

undo.capture = true;
undo.capture_square = sq;
undo.capture_piece = capture;
undo.capture_pos = board.pos[sq];

square_clear(board,sq,capture,true);

board.ply_nb = 0; // conversion
board.cap_sq = to;
}

// move the piece

if (MOVE_IS_PROMOTE(move)) {

// promote

undo.pawn_pos = board.pos[from];

square_clear(board,from,piece,true);

piece = move_promote(move);

// insert the promote piece in MV order

pos = board.piece_size[me];
while( pos > 0  &&  piece > board.square[board.piece[me][pos-1]] ) {
pos = pos - 1;   // HACK
}

square_set(board,to,piece,pos,true);

board.cap_sq = to;

} else { 

// normal move

square_move(board,from,to,piece,true);
}

// move the rook in case of castling

if (MOVE_IS_CASTLE(move)) {

rook =  ( Rook64 | COLOUR_FLAG(me) ); // HACK

if (to == G1) {
square_move(board,H1,F1,rook,true);
} else { 
if (to == C1) {
square_move(board,A1,D1,rook,true);
} else { 
if (to == G8) {
square_move(board,H8,F8,rook,true);
} else { 
if (to == C8) {
square_move(board,A8,D8,rook,true);
} else { 
//ASSERT(377, false);
}
}
}
}
}

// debug

//ASSERT(378, board_is_ok(board));

}

// move_undo()

private function move_undo( board:board_t, move:int, undo:undo_t ) :void {

var me :int = 0;    // int
var from :int = 0;  // int
var to :int = 0;    // int
var piece :int = 0; // int
var pos :int = 0;   // int
var rook :int = 0;  // int

//ASSERT(380, move_is_ok(move));

// init

me = undo.turn;

from = MOVE_FROM(move);
to = MOVE_TO(move);

piece = board.square[to];
//ASSERT(382, COLOUR_IS(piece,me));

// castle

if (MOVE_IS_CASTLE(move)) {

rook =  ( Rook64 | COLOUR_FLAG(me) ); // HACK

if (to == G1) {
square_move(board,F1,H1,rook,false);
} else { 
if (to == C1) {
square_move(board,D1,A1,rook,false);
} else { 
if (to == G8) {
square_move(board,F8,H8,rook,false);
} else { 
if (to == C8) {
square_move(board,D8,A8,rook,false);
} else { 
//ASSERT(383, false);
}
}
}
}
}



// move the piece backward

if (MOVE_IS_PROMOTE(move)) {

// promote

//ASSERT(384, piece==move_promote(move));
square_clear(board,to,piece,false);

piece = PawnMake[me];
pos = undo.pawn_pos;

square_set(board,from,piece,pos,false);

} else { 

// normal move

square_move(board,to,from,piece,false);
}

// put the captured piece back

if (undo.capture) {
square_set(board,undo.capture_square,undo.capture_piece,undo.capture_pos,false);
}

// update board info

board.turn = undo.turn;
board.flags = undo.flags;
board.ep_square = undo.ep_square;
board.ply_nb = undo.ply_nb;

board.cap_sq = undo.cap_sq;

board.opening = undo.opening;
board.endgame = undo.endgame;

board.key = undo.key;
board.pawn_key = undo.pawn_key;
board.material_key = undo.material_key;

// update key stack

//ASSERT(385, board.sp>0);
board.sp = board.sp - 1;

// debug

//ASSERT(386, board_is_ok(board));
//ASSERT(387, board_is_legal(board));
}

// move_do_null()

private function move_do_null( board:board_t, undo:undo_t )  :void {

var sq :int = 0;   // int

//ASSERT(390, board_is_legal(board));
//ASSERT(391, ! board_is_check(board));

// initialise undo

undo.turn = board.turn;
undo.ep_square = board.ep_square;
undo.ply_nb = board.ply_nb;
undo.cap_sq = board.cap_sq;
undo.key = board.key;

// update key stack

//ASSERT(392, board.sp<StackSize);
board.stack[board.sp] = board.key;
board.sp = board.sp + 1;

// update turn

board.turn = COLOUR_OPP(board.turn);

// update en-passant square

sq = board.ep_square;
if (sq != SquareNone) {

board.ep_square = SquareNone;
}

// update move number

board.ply_nb = 0; // HACK: null move is considered as a conversion

// update last square

board.cap_sq = SquareNone;

// debug

//ASSERT(393, board_is_ok(board));
}

// move_undo_null()

private function move_undo_null( board:board_t, undo:undo_t )  :void {

//ASSERT(396, board_is_legal(board));
//ASSERT(397, ! board_is_check(board));

// update board info

board.turn = undo.turn;
board.ep_square = undo.ep_square;
board.ply_nb = undo.ply_nb;
board.cap_sq = undo.cap_sq;
board.key = undo.key;

// update key stack

//ASSERT(398, board.sp>0);
board.sp = board.sp - 1;

// debug

//ASSERT(399, board_is_ok(board));
}

// square_clear()

private function square_clear( board:board_t, square:int, piece:int, update:Boolean ) :void {

var pos :int = 0;       // int
var piece_12 :int = 0;  // int
var colour :int = 0;    // int
var sq :int = 0;        // int
var i :int = 0;         // int
var size :int = 0;      // int
var sq_64 :int = 0;     // int
var t :int = 0;         // int
var hash_xor :int = 0;  // uint64

//ASSERT(401, SQUARE_IS_OK(square));
//ASSERT(402, piece_is_ok(piece));

// init

pos = board.pos[square];
//ASSERT(404, pos>=0);

piece_12 = this.PieceTo12[piece];
colour = PIECE_COLOUR(piece);

// square

//ASSERT(405, board.square[square]==piece);
board.square[square] = Empty;

// piece list

if (! PIECE_IS_PAWN(piece)) {

// init

size = board.piece_size[colour];
//ASSERT(406, size>=1);

// stable swap

//ASSERT(407, pos>=0 && pos<size);

//ASSERT(408, board.pos[square]==pos);
board.pos[square] = -1;

for (i = pos; i<= size-2; i++ ) {

sq = board.piece[colour][i+1];

board.piece[colour][i] = sq;

//ASSERT(409, board.pos[sq]==i+1);
board.pos[sq] = i;
}

// size

size = size - 1;

board.piece[colour][size] = SquareNone;
board.piece_size[colour] = size;

} else { 

// init

size = board.pawn_size[colour];
//ASSERT(410, size>=1);

// stable swap

//ASSERT(411, pos>=0 && pos<size);

//ASSERT(412, board.pos[square]==pos);
board.pos[square] = -1;

for (i = pos; i<= size-2; i++ ) {

sq = board.pawn[colour][i+1];

board.pawn[colour][i] = sq;

//ASSERT(413, board.pos[sq]==i+1);
board.pos[sq] = i;
}

// size

size = size - 1;

board.pawn[colour][size] = SquareNone;
board.pawn_size[colour] = size;

// pawn "bitboard"

t = SQUARE_FILE(square);
board.pawn_file[colour][t] = ( board.pawn_file[colour][t] ^ 
this.BitEQ[PAWN_RANK(square,colour)] );
}

// material

//ASSERT(414, board.piece_nb>0);
board.piece_nb = board.piece_nb - 1;

//ASSERT(415, board.number[piece_12]>0);
board.number[piece_12] = board.number[piece_12] - 1;

// update

if (update) {

// init

sq_64 = this.SquareTo64[square];

// PST

board.opening = board.opening - Pget( piece_12, sq_64, Opening );
board.endgame = board.endgame - Pget( piece_12, sq_64, Endgame );

// hash key

hash_xor = this.Random64[RandomPiece+((piece_12 ^ 1)*64)+sq_64];
// HACK: xor 1 for PolyGlot book (not AS3)

board.key = ( board.key ^ hash_xor);
if (PIECE_IS_PAWN(piece)) {
board.pawn_key = ( board.pawn_key ^ hash_xor);
}

// material key

board.material_key = ( board.material_key ^ this.Random64[(piece_12*16)+board.number[piece_12]] );


}
}

// square_set()

private function square_set( board:board_t, square:int, piece:int, pos:int, update:Boolean ) :void {

var piece_12 :int = 0;  // int
var colour :int = 0;    // int
var sq :int = 0;        // int
var i :int = 0;         // int
var size :int = 0;      // int
var sq_64 :int = 0;     // int
var t :int = 0;         // int
var hash_xor :int = 0;  // uint64


//ASSERT(417, SQUARE_IS_OK(square));
//ASSERT(418, piece_is_ok(piece));
//ASSERT(419, pos>=0);


// init

piece_12 = this.PieceTo12[piece];
colour = PIECE_COLOUR(piece);

// square

//ASSERT(421, board.square[square]==Empty);
board.square[square] = piece;

// piece list

if (! PIECE_IS_PAWN(piece)) {

// init

size = board.piece_size[colour];
//ASSERT(422, size>=0);

// size

size = size + 1;

board.piece[colour][size] = SquareNone;
board.piece_size[colour] = size;

// stable swap

//ASSERT(423, pos>=0 && pos<size);

for (i = size-1; i>= pos+1; i-- ) {

sq = board.piece[colour][i-1];

board.piece[colour][i] = sq;

//ASSERT(424, board.pos[sq]==i-1);
board.pos[sq] = i;
}

board.piece[colour][pos] = square;

//ASSERT(425, board.pos[square]==-1);
board.pos[square] = pos;

} else { 

// init

size = board.pawn_size[colour];
//ASSERT(426, size>=0);

// size

size = size + 1;

board.pawn[colour][size] = SquareNone;
board.pawn_size[colour] = size;

// stable swap

//ASSERT(427, pos>=0 && pos<size);

for (i = size-1; i>= pos+1; i-- ) {

sq = board.pawn[colour][i-1];

board.pawn[colour][i] = sq;

//ASSERT(428, board.pos[sq]==i-1);
board.pos[sq] = i;
}

board.pawn[colour][pos] = square;

//ASSERT(429, board.pos[square]==-1);
board.pos[square] = pos;

// pawn "bitboard"

t = SQUARE_FILE(square);
board.pawn_file[colour][t] = ( board.pawn_file[colour][t] ^ 
this.BitEQ[PAWN_RANK(square,colour)] );


}

// material

//ASSERT(430, board.piece_nb<32);
board.piece_nb = board.piece_nb + 1;

//ASSERT(431, board.number[piece_12]<9);
board.number[piece_12] = board.number[piece_12] + 1;

// update

if (update) {

// init

sq_64 = this.SquareTo64[square];

// PST

board.opening = board.opening + Pget( piece_12, sq_64, Opening );
board.endgame = board.endgame + Pget( piece_12, sq_64, Endgame );
// hash key

hash_xor = this.Random64[RandomPiece+((piece_12 ^ 1)*64)+sq_64];
// HACK: xor 1 for PolyGlot book (not AS3)

board.key = ( board.key ^ hash_xor);
if (PIECE_IS_PAWN(piece)) {
board.pawn_key = ( board.pawn_key ^ hash_xor);
}

// material key

board.material_key = ( board.material_key ^ this.Random64[(piece_12*16)+board.number[piece_12]] );

}
}

// square_move()

private function square_move( board:board_t, from:int, to:int, piece:int, update:Boolean ) : void {

var piece_12 :int = 0;    // int
var colour :int = 0;      // int
var pos :int = 0;         // int
var from_64 :int = 0;     // int
var to_64 :int = 0;       // int
var piece_index :int = 0; // int
var t :int = 0;           // int
var hash_xor :int = 0;    // uint64



//ASSERT(433, SQUARE_IS_OK(from));
//ASSERT(434, SQUARE_IS_OK(to));
//ASSERT(435, piece_is_ok(piece));


// init

colour = PIECE_COLOUR(piece);

pos = board.pos[from];
//ASSERT(437, pos>=0);

// from

//ASSERT(438, board.square[from]==piece);
board.square[from] = Empty;

//ASSERT(439, board.pos[from]==pos);
board.pos[from] = -1; // not needed

// to

//ASSERT(440, board.square[to]==Empty);
board.square[to] = piece;

//ASSERT(441, board.pos[to]==-1);
board.pos[to] = pos;

// piece list

if (! PIECE_IS_PAWN(piece)) {

//ASSERT(442, board.piece[colour][pos]==from);
board.piece[colour][pos] = to;

} else { 

//ASSERT(443, board.pawn[colour][pos]==from);
board.pawn[colour][pos] = to;

// pawn "bitboard"

t = SQUARE_FILE(from);
board.pawn_file[colour][t] = ( board.pawn_file[colour][t] ^ 
this.BitEQ[PAWN_RANK(from,colour)] );
t = SQUARE_FILE(to);
board.pawn_file[colour][t] = ( board.pawn_file[colour][t] ^ 
this.BitEQ[PAWN_RANK(to,colour)] );

}

// update

if (update) {

// init

from_64 = this.SquareTo64[from];
to_64 = this.SquareTo64[to];
piece_12 = this.PieceTo12[piece];

// PST

board.opening = board.opening + Pget(piece_12,to_64,Opening) - Pget(piece_12,from_64,Opening);
board.endgame = board.endgame + Pget(piece_12,to_64,Endgame) - Pget(piece_12,from_64,Endgame);

// hash key

piece_index = RandomPiece + ((piece_12 ^ 1) * 64);
// HACK: xor 1 for PolyGlot book (not AS3)

hash_xor =  ( this.Random64[piece_index+to_64] ^ this.Random64[piece_index+from_64] );

board.key = ( board.key ^ hash_xor );
if (PIECE_IS_PAWN(piece)) {
board.pawn_key = ( board.pawn_key ^ hash_xor);
}

}

}

// end of move_do.cpp



// move_evasion.cpp

//  functions

// gen_legal_evasions()

private function gen_legal_evasions( list:list_t, board:board_t, attack:attack_t ) :void {

gen_evasions(list,board,attack,true,false);

// debug

//ASSERT(447, list_is_ok(list));
}

// gen_pseudo_evasions()

private function gen_pseudo_evasions( list:list_t, board:board_t, attack:attack_t ) :void {

gen_evasions(list,board,attack,false,false);

// debug

//ASSERT(451, list_is_ok(list));
}

// legal_evasion_exist()

private function legal_evasion_exist( board:board_t, attack:attack_t ) :Boolean {

var list:list_t = new list_t();  // list[1] dummy

return gen_evasions(list,board,attack,true,true);
}

// gen_evasions()

private function gen_evasions( list:list_t, board:board_t, attack:attack_t, legal:Boolean, stop:Boolean ) :Boolean {
var me :int = 0;         // int
var opp :int = 0;        // int
var opp_flag :int = 0;   // int
var king :int = 0;       // int
var inc_ptr :int = 0;    // int
var inc :int = 0;        // int
var to :int = 0;         // int
var piece :int = 0;      // int


//ASSERT(459, board_is_check(board));
//ASSERT(460, ATTACK_IN_CHECK(attack));

// init

list.size=0;

me = board.turn;
opp = COLOUR_OPP(me);

opp_flag = COLOUR_FLAG(opp);

king = KING_POS(board,me);

inc_ptr = 0;
while(true) {
inc = KingInc[inc_ptr];
if( inc == IncNone ) {
break;
}
// avoid escaping along a check line
if (inc != -attack.di[0]  &&  inc != -attack.di[1]) {
to = king + inc;
piece = board.square[to];
if (piece == Empty  ||  FLAG_IS(piece,opp_flag)) {
if ((! legal ) || (! is_attacked(board,to,opp))) {
if (stop) {
return true;
}
LIST_ADD(list,MOVE_MAKE(king,to));
}
}
}

inc_ptr = inc_ptr + 1;
}


if (attack.dn >= 2) {
return false; // double check, we are {ne
}

// single check

//ASSERT(461, attack.dn==1);

// capture the checking piece

if (add_pawn_captures(list,board,attack.ds[0],legal,stop)  &&  stop) {
return true;
}
if (add_piece_moves(list,board,attack.ds[0],legal,stop)  &&  stop) {
return true;
}

// interpose a piece

inc = attack.di[0];

if (inc != IncNone) { // line
to = king+inc;
while( to != attack.ds[0] ) {

//ASSERT(462, SQUARE_IS_OK(to));
//ASSERT(463, board.square[to]==Empty);
if (add_pawn_moves(list,board,to,legal,stop)  &&  stop) {
return true;
}
if (add_piece_moves(list,board,to,legal,stop)  &&  stop) {
return true;
}
to = to + inc;
}
}

return false;

}

// add_pawn_moves()

private function add_pawn_moves( list:list_t, board:board_t, to:int, legal:Boolean, stop:Boolean ) :Boolean {
var me :int = 0;      // int
var inc :int = 0;     // int
var pawn :int = 0;    // int
var from :int = 0;    // int
var piece :int = 0;   // int

//ASSERT(466, SQUARE_IS_OK(to));

//ASSERT(469, board.square[to]==Empty);

me = board.turn;

inc = PawnMoveInc[me];
pawn = PawnMake[me];

from = to - inc;
piece = board.square[from];

if (piece == pawn) {  // single push

if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
add_pawn_move(list,from,to);
}

} else { 
if (piece == Empty  &&  PAWN_RANK(to,me) == Rank4)  {   // double push

from = to - (2*inc);
if (board.square[from] == pawn) {
if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
//ASSERT(470, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}
}

return false;
}

// add_pawn_captures()

private function add_pawn_captures( list:list_t, board:board_t, to:int, legal:Boolean, stop:Boolean ) :Boolean { 
var me :int = 0;     // int
var inc :int = 0;    // int
var pawn :int = 0;   // int
var from :int = 0;   // int

//ASSERT(473, SQUARE_IS_OK(to));

//ASSERT(476, COLOUR_IS(board.square[to],COLOUR_OPP(board.turn)));

me = board.turn;

inc = PawnMoveInc[me];
pawn = PawnMake[me];

from = to - (inc-1);
if (board.square[from] == pawn) {
if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
add_pawn_move(list,from,to);
}
}

from = to - (inc+1);
if (board.square[from] == pawn) {
if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
add_pawn_move(list,from,to);
}
}

if (board.ep_square != SquareNone &&  to == SQUARE_EP_DUAL(board.ep_square)) {

//ASSERT(477, PAWN_RANK(to,me)==Rank5);
//ASSERT(478, PIECE_IS_PAWN(board.square[to]));

to = board.ep_square;
//ASSERT(479, PAWN_RANK(to,me)==Rank6);
//ASSERT(480, board.square[to]==Empty);

from = to - (inc-1);
if (board.square[from] == pawn) {
if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
//ASSERT(481, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE_FLAGS(from,to,MoveEnPassant));
}
}

from = to - (inc+1);
if (board.square[from] == pawn) {
if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
//ASSERT(482, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE_FLAGS(from,to,MoveEnPassant));
}
}
}

return false;
}

// add_piece_moves()

private function add_piece_moves( list:list_t, board:board_t, to:int, legal:Boolean, stop:Boolean) :Boolean {
var me :int = 0;      // int
var ptr :int = 0;     // int
var from :int = 0;    // int
var piece :int = 0;   // int

//ASSERT(485, SQUARE_IS_OK(to));

me = board.turn;

ptr = 1;            // HACK: no king
while(true) {
from = board.piece[me][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

if (PIECE_ATTACK(board,piece,from,to)) {
if ((! legal)  ||  (! is_pinned(board,from,me))) {
if (stop) {
return true;
}
LIST_ADD(list,MOVE_MAKE(from,to));
}
}

ptr = ptr + 1;
}

return false;

}

// end of move_evasion.cpp



// move_gen.cpp

//  functions

// gen_legal_moves()

private function gen_legal_moves( list:list_t, board:board_t )  :void {

var attack:attack_t = new attack_t();  // attack_t[1]

attack_set(attack,board);

if (ATTACK_IN_CHECK(attack)) {
gen_legal_evasions(list,board,attack);
} else { 
gen_moves(list,board);
list_filter(list,board, true);
}

// debug

//ASSERT(490, list_is_ok(list));
}

// gen_moves()

private function gen_moves( list:list_t, board:board_t ) :void {

//ASSERT(493, ! board_is_check(board));

list.size=0;

add_moves(list,board);

add_en_passant_captures(list,board);
add_castle_moves(list,board);

// debug

//ASSERT(494, list_is_ok(list));
}

// gen_captures()

private function gen_captures( list:list_t, board:board_t ) :void {

list.size=0;

add_captures(list,board);
add_en_passant_captures(list,board);

// debug

//ASSERT(497, list_is_ok(list));
}

// gen_quiet_moves()

private function gen_quiet_moves( list:list_t, board:board_t ) :void {

//ASSERT(500, ! board_is_check(board));

list.size=0;

add_quiet_moves(list,board);
add_castle_moves(list,board);

// debug

//ASSERT(501, list_is_ok(list));
}

// add_moves()

private function add_moves( list:list_t, board:board_t ) :void {

var me :int = 0;         // int
var opp :int = 0;        // int
var opp_flag :int = 0;   // int
var ptr :int = 0;        // int
var from :int = 0;       // int
var to :int = 0;         // int
var piece :int = 0;      // int
var capture :int = 0;    // int
var inc_ptr :int = 0;    // int
var inc :int = 0;        // int

me = board.turn;
opp = COLOUR_OPP(me);

opp_flag = COLOUR_FLAG(opp);

// piece moves

ptr = 0;
while(true) {
from = board.piece[me][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

if (PIECE_IS_SLIDER(piece)) {

inc_ptr = 0;
while(true) {
inc = this.PieceInc[piece][inc_ptr];
if( inc == IncNone ) {
break;
}

to = from+inc;
while(true) {
capture=board.square[to];
if( capture != Empty ) {
break;
}

LIST_ADD(list,MOVE_MAKE(from,to));

to = to + inc;
}

if (FLAG_IS(capture,opp_flag)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}

inc_ptr = inc_ptr + 1;
}

} else { 

inc_ptr = 0;
while(true) {
inc = this.PieceInc[piece][inc_ptr];
if( inc == IncNone ) {
break;
}

to = from + inc;
capture = board.square[to];
if (capture == Empty  ||  FLAG_IS(capture,opp_flag)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}

inc_ptr = inc_ptr + 1;
}

}

ptr = ptr + 1;
}


// pawn moves

inc = PawnMoveInc[me];

ptr = 0;
while(true) {
from = board.pawn[me][ptr];
if( from == SquareNone ) {
break;
}

to = from + (inc-1);
if (FLAG_IS(board.square[to],opp_flag)) {
add_pawn_move(list,from,to);
}

to = from + (inc+1);
if (FLAG_IS(board.square[to],opp_flag)) {
add_pawn_move(list,from,to);
}

to = from + inc;
if (board.square[to] == Empty) {
add_pawn_move(list,from,to);
if (PAWN_RANK(from,me) == Rank2) {
to = from + (2*inc);
if (board.square[to] == Empty) {
//ASSERT(504, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}

ptr = ptr + 1;
}

}

//
private function add_capt1 ( from:int, dt:int, list:list_t, board:board_t, opp_flag:int ): void { 
var to:int = from + dt;
if (FLAG_IS(board.square[to],opp_flag)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}
}


//
private function add_capt2( from:int, dt:int, list:list_t, board:board_t, opp_flag:int ): void { 
var to:int = from + dt;
var capture:int = 0;
while(true) {
capture=board.square[to];
if(capture!=Empty) {
break;
}
to = to + dt;
}
if (FLAG_IS(capture,opp_flag)) {
LIST_ADD(list,MOVE_MAKE(from,to));
}
}

//
private function add_capt3( from:int, dt:int, list:list_t, board:board_t, opp_flag:int ): void { 
var to:int = from + dt;
if (FLAG_IS(board.square[to],opp_flag)) {
add_pawn_move(list,from,to);
}
}

//
private function add_capt4( from:int, dt:int, list:list_t, board:board_t ): void { 
var to:int = from + dt;
if (board.square[to] == Empty) {
add_promote(list,MOVE_MAKE(from,to));
}
}

// add_captures()

private function add_captures( list:list_t, board:board_t ) :void {

var me :int = 0;         // int
var opp :int = 0;        // int
var opp_flag :int = 0;   // int
var ptr :int = 0;        // int
var from :int = 0;       // int
var piece :int = 0;      // int
var p:int = 0;

me = board.turn;
opp = COLOUR_OPP(me);

opp_flag = COLOUR_FLAG(opp);

// piece captures

ptr = 0;
while(true) {
from = board.piece[me][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

p = PIECE_TYPE(piece);

if(p == Knight64) {

add_capt1 ( from, -33, list, board, opp_flag );
add_capt1 ( from, -31, list, board, opp_flag );
add_capt1 ( from, -18, list, board, opp_flag );
add_capt1 ( from, -14, list, board, opp_flag );
add_capt1 ( from, 14, list, board, opp_flag );
add_capt1 ( from, 18, list, board, opp_flag );
add_capt1 ( from, 31, list, board, opp_flag );
add_capt1 ( from, 33, list, board, opp_flag );
} else { 

if(p == Bishop64) {

add_capt2 ( from, -17, list, board, opp_flag );
add_capt2 ( from, -15, list, board, opp_flag );
add_capt2 ( from, 15, list, board, opp_flag );
add_capt2 ( from, 17, list, board, opp_flag );

} else { 

if(p == Rook64) {

add_capt2 ( from, -16, list, board, opp_flag );
add_capt2 ( from, -1, list, board, opp_flag );
add_capt2 ( from, 1, list, board, opp_flag );
add_capt2 ( from, 16, list, board, opp_flag );

} else { 

if(p == Queen64) {

add_capt2 ( from, -17, list, board, opp_flag );
add_capt2 ( from, -16, list, board, opp_flag );
add_capt2 ( from, -15, list, board, opp_flag );
add_capt2 ( from, -1, list, board, opp_flag );
add_capt2 ( from, 1, list, board, opp_flag );
add_capt2 ( from, 15, list, board, opp_flag );
add_capt2 ( from, 16, list, board, opp_flag );
add_capt2 ( from, 17, list, board, opp_flag );

} else { 

if(p == King64) {

add_capt1 ( from, -17, list, board, opp_flag );
add_capt1 ( from, -16, list, board, opp_flag );
add_capt1 ( from, -15, list, board, opp_flag );
add_capt1 ( from, -1, list, board, opp_flag );
add_capt1 ( from, 1, list, board, opp_flag );
add_capt1 ( from, 15, list, board, opp_flag );
add_capt1 ( from, 16, list, board, opp_flag );
add_capt1 ( from, 17, list, board, opp_flag );

} else { 

//ASSERT(507, false);

}
}
}
}
}

ptr = ptr + 1;
}

// pawn captures

if (COLOUR_IS_WHITE(me)) {

ptr = 0;
while(true) {
from = board.pawn[me][ptr];
if( from == SquareNone ) {
break;
}

add_capt3 ( from, 15, list, board, opp_flag );
add_capt3 ( from, 17, list, board, opp_flag );

// promote

if (SQUARE_RANK(from) == Rank7) {
add_capt4 ( from, 16, list, board );
}

ptr = ptr + 1;
}

} else {  // black

ptr = 0;
while(true) {
from = board.pawn[me][ptr];
if( from == SquareNone ) {
break;
}

add_capt3 ( from, -17, list, board, opp_flag );
add_capt3 ( from, -15, list, board, opp_flag );

// promote

if (SQUARE_RANK(from) == Rank2) {
add_capt4 ( from, -16, list, board );
}

ptr = ptr + 1;
}

}

}


//
private function add_quietm1( from:int, dt:int, list:list_t, board:board_t ): void { 
var to:int = from + dt;
if (board.square[to] == Empty) {
LIST_ADD(list,MOVE_MAKE(from,to));
}
}

//
private function add_quietm2( from:int, dt:int, list:list_t, board:board_t ): void { 
var to:int = from + dt;
while(true) {
if(board.square[to]!=Empty) {
break;
}
LIST_ADD(list,MOVE_MAKE(from,to));
to = to + dt;
}
}

// add_quiet_moves()

private function add_quiet_moves( list:list_t, board:board_t ) :void {

var me :int = 0;         // int
var ptr :int = 0;        // int
var from :int = 0;       // int
var to :int = 0;         // int
var piece :int = 0;      // int
var p:int = 0;


me = board.turn;

// piece moves

ptr = 0;
while(true) {
from = board.piece[me][ptr];
if( from == SquareNone ) {
break;
}

piece = board.square[from];

p = PIECE_TYPE(piece);

if(p == Knight64) {

add_quietm1 ( from, -33, list, board );
add_quietm1 ( from, -31, list, board );
add_quietm1 ( from, -18, list, board );
add_quietm1 ( from, -14, list, board );
add_quietm1 ( from, 14, list, board );
add_quietm1 ( from, 18, list, board );
add_quietm1 ( from, 31, list, board );
add_quietm1 ( from, 33, list, board );
} else { 

if(p == Bishop64) {

add_quietm2 ( from, -17, list, board );
add_quietm2 ( from, -15, list, board );
add_quietm2 ( from, 15, list, board );
add_quietm2 ( from, 17, list, board );

} else { 

if(p == Rook64) {

add_quietm2 ( from, -16, list, board );
add_quietm2 ( from, -1, list, board );
add_quietm2 ( from, 1, list, board );
add_quietm2 ( from, 16, list, board );

} else { 

if(p == Queen64) {

add_quietm2 ( from, -17, list, board );
add_quietm2 ( from, -16, list, board );
add_quietm2 ( from, -15, list, board );
add_quietm2 ( from, -1, list, board );
add_quietm2 ( from, 1, list, board );
add_quietm2 ( from, 15, list, board );
add_quietm2 ( from, 16, list, board );
add_quietm2 ( from, 17, list, board );

} else { 

if(p == King64) {

add_quietm1 ( from, -17, list, board );
add_quietm1 ( from, -16, list, board );
add_quietm1 ( from, -15, list, board );
add_quietm1 ( from, -1, list, board );
add_quietm1 ( from, 1, list, board );
add_quietm1 ( from, 15, list, board );
add_quietm1 ( from, 16, list, board );
add_quietm1 ( from, 17, list, board );

} else { 

//ASSERT(510, false);

}
}
}
}
}

ptr = ptr + 1;
}

// pawn moves

if (COLOUR_IS_WHITE(me)) {

ptr = 0;
while(true) {
from = board.pawn[me][ptr];
if( from == SquareNone ) {
break;
}

// non promotes

if (SQUARE_RANK(from) != Rank7) {
to = from + 16;
if (board.square[to] == Empty) {
//ASSERT(511, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
if (SQUARE_RANK(from) == Rank2) {
to = from + 32;
if (board.square[to] == Empty) {
//ASSERT(512, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}
}

ptr = ptr + 1;
}

} else {  // black

ptr = 0;
while(true) {
from = board.pawn[me][ptr];
if( from == SquareNone ) {
break;
}

// non promotes

if (SQUARE_RANK(from) != Rank2) {
to = from - 16;
if (board.square[to] == Empty) {
//ASSERT(513, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
if (SQUARE_RANK(from) == Rank7) {
to = from - 32;
if (board.square[to] == Empty) {
//ASSERT(514, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE(from,to));
}
}
}
}

ptr = ptr + 1;
}

}

}

// add_promotes()

private function add_promotes( list:list_t, board:board_t ) :void {

var me :int = 0;    // int
var inc :int = 0;   // int
var ptr :int = 0;   // int
var from :int = 0;  // int
var to :int = 0;    // int

me = board.turn;

inc = PawnMoveInc[me];

ptr = 0;
while(true) {
from = board.pawn[me][ptr];
if( from == SquareNone ) {
break;
}

if (PAWN_RANK(from,me) == Rank7) {
add_capt4 ( from, inc, list, board );
to = from + inc;
}

ptr = ptr + 1;
}
}

// add_en_passant_captures()

private function add_en_passant_captures( list:list_t, board:board_t ) :void {

var from :int = 0;  // int
var to :int = 0;    // int
var me :int = 0;    // int
var inc :int = 0;   // int
var pawn :int = 0;  // int

to = board.ep_square;

if (to != SquareNone) {

me = board.turn;

inc = PawnMoveInc[me];
pawn = PawnMake[me];

from = to - (inc-1);
if (board.square[from] == pawn) {
//ASSERT(519, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE_FLAGS(from,to,MoveEnPassant));
}

from = to - (inc+1);
if (board.square[from] == pawn) {
//ASSERT(520, ! this.SquareIsPromote[to]);
LIST_ADD(list,MOVE_MAKE_FLAGS(from,to,MoveEnPassant));
}

}

}

// add_castle_moves()

private function add_castle_moves( list:list_t, board:board_t ) :void {

//ASSERT(523, ! board_is_check(board));

if (COLOUR_IS_WHITE(board.turn)) {

if ( ( board.flags & FlagsWhiteKingCastle ) != 0
&&  board.square[F1] == Empty
&&  board.square[G1] == Empty
&&  (! is_attacked(board,F1,Black))) {
LIST_ADD(list,MOVE_MAKE_FLAGS(E1,G1,MoveCastle));
}

if ( ( board.flags & FlagsWhiteQueenCastle ) != 0
&&  board.square[D1] == Empty
&&  board.square[C1] == Empty
&&  board.square[B1] == Empty
&&  (! is_attacked(board,D1,Black))) {
LIST_ADD(list,MOVE_MAKE_FLAGS(E1,C1,MoveCastle));
}

} else {   // black

if ( ( board.flags & FlagsBlackKingCastle ) != 0
&&  board.square[F8] == Empty
&&  board.square[G8] == Empty
&&  (! is_attacked(board,F8,White))) {
LIST_ADD(list,MOVE_MAKE_FLAGS(E8,G8,MoveCastle));
}

if ( ( board.flags & FlagsBlackQueenCastle ) != 0
&&  board.square[D8] == Empty
&&  board.square[C8] == Empty
&&  board.square[B8] == Empty
&&  (! is_attacked(board,D8,White))) {
LIST_ADD(list,MOVE_MAKE_FLAGS(E8,C8,MoveCastle));
}
}
}

// add_pawn_move()

private function add_pawn_move( list:list_t, from:int, to:int )  :void {

var move :int = 0;   // int

//ASSERT(525, SQUARE_IS_OK(from));
//ASSERT(526, SQUARE_IS_OK(to));

move = MOVE_MAKE(from,to);

if (this.SquareIsPromote[to]) {
LIST_ADD(list,(move | MovePromoteQueen));
LIST_ADD(list,(move | MovePromoteKnight));
LIST_ADD(list,(move | MovePromoteRook));
LIST_ADD(list,(move | MovePromoteBishop));
} else { 
LIST_ADD(list,move);
}
}

// add_promote()

private function add_promote( list:list_t, move:int )  :void {

//ASSERT(528, move_is_ok(move));

//ASSERT(529, (move & bnotV07777)==0); // HACK
//ASSERT(530, this.SquareIsPromote[MOVE_TO(move)]);

LIST_ADD(list,(move | MovePromoteQueen));
LIST_ADD(list,(move | MovePromoteKnight));
LIST_ADD(list,(move | MovePromoteRook));
LIST_ADD(list,(move | MovePromoteBishop));
}

// end of move_gen.cpp




// move_legal.cpp

//  functions

// move_is_pseudo()

private function move_is_pseudo( move:int, board:board_t ) :Boolean { 

var me :int = 0;      // int
var opp :int = 0;     // int
var from :int = 0;    // int
var to :int = 0;      // int
var piece :int = 0;   // int
var capture :int = 0; // int
var inc :int = 0;     // int
var delta :int = 0;   // int

//ASSERT(531, move_is_ok(move));

//ASSERT(533, ! board_is_check(board));

// special cases

if (MOVE_IS_SPECIAL(move)) {
return move_is_pseudo_debug(move,board);
}

//ASSERT(534, (move & bnotV07777)==0);

// init

me = board.turn;
opp = COLOUR_OPP(board.turn);

// from

from = MOVE_FROM(move);
//ASSERT(535, SQUARE_IS_OK(from));

piece = board.square[from];
if (! COLOUR_IS(piece,me)) {
return false;
}

//ASSERT(536, piece_is_ok(piece));

// to

to = MOVE_TO(move);
//ASSERT(537, SQUARE_IS_OK(to));

capture = board.square[to];
if (COLOUR_IS(capture,me)) {
return false;
}

// move

if (PIECE_IS_PAWN(piece)) {

if (this.SquareIsPromote[to]) {
return false;
}

inc = PawnMoveInc[me];
delta = to - from;
//ASSERT(538, delta_is_ok(delta));

if (capture == Empty) {

// pawn push

if (delta == inc) {
return true;
}

if (delta == (2*inc)
&&  PAWN_RANK(from,me) == Rank2
&&  board.square[from+inc] == Empty) {
return true;
}

} else { 

// pawn capture

if (delta == (inc-1)  ||  delta == (inc+1)) {
return true;
}
}

} else { 

if (PIECE_ATTACK(board,piece,from,to)) {
return true;
}
}

return false;
}

// quiet_is_pseudo()

private function quiet_is_pseudo( move:int, board:board_t ) :Boolean {

var me :int = 0;      // int
var opp :int = 0;     // int
var from :int = 0;    // int
var to :int = 0;      // int
var piece :int = 0;   // int
var inc :int = 0;     // int
var delta :int = 0;   // int

//ASSERT(539, move_is_ok(move));

//ASSERT(541, ! board_is_check(board));

// special cases

if (MOVE_IS_CASTLE(move)) {
return move_is_pseudo_debug(move,board);
} else { 
if (MOVE_IS_SPECIAL(move)) {
return false;
}
}

//ASSERT(542, (move & bnotV07777)==0);

// init

me = board.turn;
opp = COLOUR_OPP(board.turn);

// from

from = MOVE_FROM(move);
//ASSERT(543, SQUARE_IS_OK(from));

piece = board.square[from];
if (! COLOUR_IS(piece,me)) {
return false;
}

//ASSERT(544, piece_is_ok(piece));

// to

to = MOVE_TO(move);
//ASSERT(545, SQUARE_IS_OK(to));

if (board.square[to] != Empty) {
return false; // capture
}

// move

if (PIECE_IS_PAWN(piece)) {

if (this.SquareIsPromote[to]) {
return false;
}

inc = PawnMoveInc[me];
delta = to - from;
//ASSERT(546, delta_is_ok(delta));

// pawn push

if (delta == inc) {
return true;
}

if (delta == (2*inc)
&&  PAWN_RANK(from,me) == Rank2
&&  board.square[from+inc] == Empty) {
return true;
}

} else { 

if (PIECE_ATTACK(board,piece,from,to)) {
return true;
}
}

return false;
}

// pseudo_is_legal()

private function pseudo_is_legal( move:int, board:board_t ) :Boolean { 

var opp :int = 0;        // int
var me :int = 0;         // int
var from :int = 0;       // int
var to :int = 0;         // int
var piece :int = 0;      // int
var legal :Boolean = false;  // bool
var king :int = 0;       // int
var undo:undo_t = new undo_t();  //undo_t[1]

//ASSERT(547, move_is_ok(move));

// init

me = board.turn;
opp = COLOUR_OPP(me);

from = MOVE_FROM(move);
to = MOVE_TO(move);

piece = board.square[from];
//ASSERT(549, COLOUR_IS(piece,me));

// slow test for en-passant captures

if (MOVE_IS_EN_PASSANT(move)) {

move_do(board,move,undo);
legal = ! IS_IN_CHECK(board,me);
move_undo(board,move,undo);

return legal;
}

// king moves (including castle)

if (PIECE_IS_KING(piece)) {

legal = ! is_attacked(board,to,opp);

if (iDbg01) {
//ASSERT(550, board.square[from]==piece);
board.square[from] = Empty;
//ASSERT(551, legal==(! is_attacked(board,to,opp)));
board.square[from] = piece;
}

return legal;
}

// pins

if (is_pinned(board,from,me)) {
king = KING_POS(board,me);
return (DELTA_INC_LINE(king-to) == DELTA_INC_LINE(king-from)); // does not discover the line
}

return true;
}

// move_is_pseudo_debug()

private function move_is_pseudo_debug ( move:int, board:board_t ) :Boolean { 

var list:list_t = new list_t();  //list_t[1]

//ASSERT(552, move_is_ok(move));

//ASSERT(554, ! board_is_check(board));

gen_moves(list,board);

return list_contain(list,move);
}

// end of move_legal.cpp



// option.cpp

//  functions

// option_init()

private function option_init() :void {

var i:int = 0;

for(i=0;i<=20;i++) this.Option[i] = new opt_t_def();

// options are as they are for the execuatable version
set_opt_t_def( 0, "Hash",  false, "16", "spin", "min 4 max 1024" );
set_opt_t_def( 1, "Ponder",  false, "false", "check", "" );
set_opt_t_def( 2, "OwnBook",  false, "false", "check", "" );
set_opt_t_def( 3, "BookFile",   false, "book_small.bin", "string", "" );
set_opt_t_def( 4, "nullMove Pruning",  true, "Fail High", "combo", "var Always var Fail High var Never" );
set_opt_t_def( 5, "nullMove Reduction",  true, "3", "spin", "min 1 max 3" );
set_opt_t_def( 6, "Verification Search",  true, "endgame", "combo", "var Always var endgame var Never" );
set_opt_t_def( 7, "Verification Reduction",  true, "5", "spin", "min 1 max 6" );
set_opt_t_def( 8, "History Pruning", true, "true", "check", "" );
set_opt_t_def( 9, "History Threshold",  true, "60", "spin", "min 0 max 100" );
set_opt_t_def( 10, "Futility Pruning",  true, "false", "check", "" );
set_opt_t_def( 11, "Futility Margin",  true, "100", "spin",  "min 0 max 500" );
set_opt_t_def( 12, "Delta Pruning",  true, "false", "check", "" );
set_opt_t_def( 13, "Delta Margin",  true, "50", "spin",  "min 0 max 500" );
set_opt_t_def( 14, "Quiescence Check Plies", true, "1", "spin", "min 0 max 2" );
set_opt_t_def( 15, "Material",  true, "100", "spin", "min 0 max 400" );
set_opt_t_def( 16, "Piece Activity",  true, "100", "spin", "min 0 max 400" );
set_opt_t_def( 17, "King Safety",  true, "100", "spin", "min 0 max 400" );
set_opt_t_def( 18, "Pawn Structure",  true, "100", "spin", "min 0 max 400" );
set_opt_t_def( 19, "Passed Pawns",  true, "100", "spin", "min 0 max 400" );
set_opt_t_def( 20, "", false, "", "", "" );

}

// option_list()

private function option_list() :void {

var opt:opt_t_def = new opt_t_def();
var i:int = 0;

while(true) {
opt = this.Option[i];
if( opt.vary.length == 0 ) {
break;
}

if (opt.decl) {
send("option name "+ opt.vary +" type "+ opt.type +" default "+ opt.val + opt.extra);
}

i = i + 1;
}
}

// option_set()

private function option_set( vary:String, val:String ) :Boolean {

var i:int = 0;

i = option_find(vary);
if (i<0) { return false; }
this.Option[i].val = val;

return true;
}

// option_get()

private function option_get( vary:String ):String { 

var i:int = 0;

i = option_find(vary);
if (i<0) {
my_fatal("option_get(): unknown option : "+ vary + "\n");
return "";
}

return this.Option[i].val;
}

// option_get_bool()

private function option_get_bool( vary:String ):Boolean { 

var val :String = option_get(vary);   // string

if (string_equal(val,"true")  ||  string_equal(val,"yes")  ||  string_equal(val,"1")) {
return true;
} else { 
if (string_equal(val,"false")  ||  string_equal(val,"no")  ||  string_equal(val,"0")) {
return false;
}
}

//ASSERT(558, false);

return false;
}

// option_get_int()

private function option_get_int( vary:String ) :int {
return parseInt( option_get(vary) );
}

// option_get_string()

private function option_get_string( vary:String ):String { 
return option_get(vary);
}

// option_find()

private function option_find( vary:String ) :int { 

var opt:opt_t_def = new opt_t_def();
var i:int = 0;

while(true) {
opt = this.Option[i];
if( opt.vary.length == 0 ) {
break;
}

if (string_equal(opt.vary,vary)) {
return i;
}

i = i + 1;
}

return -1;
}

// end of option.cpp



// pawn.cpp

//  functions

// pawn_init_bit()

private function pawn_init_bit()  :void {

var rank :int = 0;   // int
var first :int = 0;  // int
var last :int = 0;   // int
var count :int = 0;  // int
var b :int = 0;      // int
var rev :int = 0;    // int


// rank-indexed Bit*[]

for (rank = 0; rank<RankNb; rank++ ) {

this.BitEQ[rank] = 0;
this.BitLT[rank] = 0;
this.BitLE[rank] = 0;
this.BitGT[rank] = 0;
this.BitGE[rank] = 0;

this.BitRank1[rank] = 0;
this.BitRank2[rank] = 0;
this.BitRank3[rank] = 0;
}

for (rank = Rank1; rank<=Rank8; rank++ ) {
this.BitEQ[rank] = ( 1 << rank - Rank1);
this.BitLT[rank] = this.BitEQ[rank] - 1;
this.BitLE[rank] = ( this.BitLT[rank] | this.BitEQ[rank] );
this.BitGT[rank] = ( this.BitLE[rank] ^ 0xFF );
this.BitGE[rank] = ( this.BitGT[rank] | this.BitEQ[rank]);
}

for (rank = Rank1; rank<=Rank8; rank++ ) {
this.BitRank1[rank] = this.BitEQ[rank+1];
this.BitRank2[rank] = ( this.BitEQ[rank+1] | this.BitEQ[rank+2]) ;
this.BitRank3[rank] = ( ( this.BitEQ[rank+1] | this.BitEQ[rank+2] ) | this.BitEQ[rank+3] );
}

// bit-indexed Bit*[]

for (b = 0; b<= 0x100-1; b++ ) {

first = Rank8;  // HACK for pawn shelter
last = Rank1;   // HACK
count = 0;
rev = 0;

for (rank = Rank1; rank<=Rank8; rank++ ) {
if ( ( b & this.BitEQ[rank] ) != 0) {
if (rank < first) {
first = rank;
}
if (rank > last) {
last = rank;
}
count = count + 1;
rev = ( rev | this.BitEQ[RANK_OPP(rank)] );
}
}

this.BitFirst[b] = first;
this.BitLast[b] = last;
this.BitCount[b] = count;
this.BitRev[b] = rev;
}

}

// pawn_init()

private function pawn_init() :void {

var rank :int = 0;   // int

// UCI options

this.PawnStructureWeight = (option_get_int("Pawn Structure") * 256 + 50) / 100;

// bonus

for (rank = 0; rank<RankNb; rank++ ) {

this.Bonus[rank] = 0;
}

this.Bonus[Rank4] = 26;
this.Bonus[Rank5] = 77;
this.Bonus[Rank6] = 154;
this.Bonus[Rank7] = 256;

// pawn hash-table

this.Pawn.size = 0;
this.Pawn.mask = 0;

}

// pawn_alloc()

private function pawn_alloc()  :void {


if (UseTable) {

this.Pawn.size = PawnTableSize;
this.Pawn.mask = this.Pawn.size - 1;     // 2^x -1
// Pawn.table = (entry_t *) my_malloc(Pawn.size*sizeof(entry_t));
pawn_clear();
}

}

// pawn_clear()

private function pawn_clear()  :void {

var i:int = 0;

this.Pawn.table = [];
this.Pawn.used = 0;
this.Pawn.read_nb = 0;
this.Pawn.read_hit = 0;
this.Pawn.write_nb = 0;
this.Pawn.write_collision = 0;

}

// pawn_get_info()

private function pawn_get_info( info:pawn_info_t, board:board_t ):void { 

var key :int = 0;           // uint64
var entry:pawn_info_t = new pawn_info_t()    // *;
var index:int = 0;

// probe

if (UseTable) {

this.Pawn.read_nb = this.Pawn.read_nb + 1;

key = board.pawn_key;
index = ( KEY_INDEX(key) & this.Pawn.mask );

entry = this.Pawn.table[index];
if(entry==null) {
this.Pawn.table[index] = new pawn_info_t();
entry = this.Pawn.table[index];
}

if (entry.lock == KEY_LOCK(key)) {

// found

this.Pawn.read_hit = this.Pawn.read_hit + 1;

pawn_info_copy( info, entry );

return;
}
}

// calculation

pawn_comp_info(info,board);

// store

if (UseTable) {

this.Pawn.write_nb = this.Pawn.write_nb + 1;

if (entry.lock == 0) {    // HACK: assume free entry
this.Pawn.used = this.Pawn.used + 1;
} else { 
this.Pawn.write_collision = this.Pawn.write_collision + 1;
}

pawn_info_copy( entry, info );

entry.lock = KEY_LOCK(key);
}

}

// pawn_comp_info()

private function pawn_comp_info( info:pawn_info_t, board:board_t ) :void {

var colour :int = 0;   // int
var file :int = 0;     // int
var rank :int = 0;     // int
var me :int = 0;       // int
var opp :int = 0;      // int
var ptr :int = 0;      // int
var sq :int = 0;       // int
var backward :Boolean = false;    // bool
var candidate :Boolean = false;   // bool
var doubled :Boolean = false;     // bool
var isolated :Boolean = false;    // bool
var open :Boolean = false;        // bool
var passed :Boolean = false;      // bool
var t1 :int = 0;        // int
var t2 :int = 0;        // int
var n :int = 0;         // int
var bits :int = 0;      // int
var opening :Array = [ 0, 0 ];  // int[ColourNb]
var endgame :Array = [ 0, 0 ];  // int[ColourNb]
var flags :Array = [ 0, 0 ];    // int[ColourNb]
var file_bits :Array = [ 0, 0 ];   // int[ColourNb]
var passed_bits :Array = [ 0, 0 ]; // int[ColourNb]
var single_file :Array = [ 0, 0 ]; // int[ColourNb]
var q:int = 0;
var om:int = 0;
var em:int = 0;


// pawn_file[]

// #if DEBUG
for (colour = 0;  colour<=1; colour++ ) {

var pawn_file :Array = [];   // int[FileNb]

me = colour;

for (file = 0; file<FileNb; file++ ) {
pawn_file[file] = 0;
}

ptr = 0;
while(true) {
sq=board.pawn[me][ptr];
if(sq==SquareNone) {
break;
}

file = SQUARE_FILE(sq);
rank = PAWN_RANK(sq,me);

//ASSERT(565, file>=FileA && file<=FileH);
//ASSERT(566, rank>=Rank2 && rank<=Rank7);

pawn_file[file] =  ( pawn_file[file] | this.BitEQ[rank] );

ptr = ptr + 1;
}

for (file = 0; file<FileNb; file++ ) {
if (board.pawn_file[colour][file] != pawn_file[file]) {
my_fatal("board.pawn_file[][]\n");
}
}
}
// #}if


// features && scoring

for (colour = 0;  colour<=1; colour++ ) {

me = colour;
opp = COLOUR_OPP(me);

ptr = 0;
while(true) {
sq=board.pawn[me][ptr];
if(sq==SquareNone) {
break;
}


// init

file = SQUARE_FILE(sq);
rank = PAWN_RANK(sq,me);

//ASSERT(567, file>=FileA && file<=FileH);
//ASSERT(568, rank>=Rank2 && rank<=Rank7);

// flags

file_bits[me] = ( file_bits[me] | this.BitEQ[file] );
if (rank == Rank2) {
flags[me] = ( flags[me] | BackRankFlag );
}

// features

backward = false;
candidate = false;
doubled = false;
isolated = false;
open = false;
passed = false;

t1 = ( board.pawn_file[me][file-1] | board.pawn_file[me][file+1] );
t2 = ( board.pawn_file[me][file] | this.BitRev[board.pawn_file[opp][file]] );

// doubled

if ( ( board.pawn_file[me][file] & this.BitLT[rank] ) != 0) {
doubled = true;
}

// isolated && backward

if (t1 == 0) {

isolated = true;

} else { 
if ( ( t1 & this.BitLE[rank] ) == 0) {

backward = true;

// really backward?

if ( ( t1 & this.BitRank1[rank] ) != 0) {

//ASSERT(569, rank+2<=Rank8);
q = (t2 & this.BitRank1[rank]);
q = (q | this.BitRev[board.pawn_file[opp][file-1]]);
q = (q | this.BitRev[board.pawn_file[opp][file+1]]);

if ( ( q & this.BitRank2[rank] ) == 0) {

backward = false;
}

} else { 
if (rank == Rank2  &&  ( ( t1 & this.BitEQ[rank+2] ) != 0)) {

//ASSERT(570, rank+3<=Rank8);
q = (t2 & this.BitRank2[rank]);
q = (q | this.BitRev[board.pawn_file[opp][file-1]]);
q = (q | this.BitRev[board.pawn_file[opp][file+1]]);

if ( ( q & this.BitRank3[rank] ) == 0) {

backward = false;
}
}
}
}
}

// open, candidate && passed

if ( ( t2 & this.BitGT[rank] ) == 0) {

open = true;

q = ( this.BitRev[board.pawn_file[opp][file-1]] | 
this.BitRev[board.pawn_file[opp][file+1]]);

if ( ( q & this.BitGT[rank] ) == 0) {

passed = true;
passed_bits[me] = ( passed_bits[me] | this.BitEQ[file] );

} else { 

// candidate?

n = 0;

n = n + this.BitCount[( board.pawn_file[me][file-1] & this.BitLE[rank] ) ];
n = n + this.BitCount[( board.pawn_file[me][file+1] & this.BitLE[rank] ) ];

n = n - this.BitCount[( this.BitRev[board.pawn_file[opp][file-1]] & this.BitGT[rank] ) ];
n = n - this.BitCount[( this.BitRev[board.pawn_file[opp][file+1]] & this.BitGT[rank] ) ];

if (n >= 0) {

// safe?

n = 0;

n = n + this.BitCount[( board.pawn_file[me][file-1] & this.BitEQ[rank-1] ) ];
n = n + this.BitCount[( board.pawn_file[me][file+1] & this.BitEQ[rank-1] ) ];

n = n - this.BitCount[( this.BitRev[board.pawn_file[opp][file-1]] & this.BitEQ[rank+1] ) ];
n = n - this.BitCount[( this.BitRev[board.pawn_file[opp][file+1]] & this.BitEQ[rank+1] ) ];

if (n >= 0) {
candidate = true;
}
}
}
}

// score

om = opening[me];
em = endgame[me];

if (doubled) {
om = om - doubledOpening;
em = em - doubledEndgame;
}

if (isolated) {
if (open) {
om = om - IsolatedOpeningOpen;
em = em - IsolatedEndgame;
} else { 
om = om - IsolatedOpening;
em = em - IsolatedEndgame;
}
}

if (backward) {
if (open) {
om = om - BackwardOpeningOpen;
em = em - BackwardEndgame;
} else { 
om = om - BackwardOpening;
em = em - BackwardEndgame;
}
}

if (candidate) {
om = om + quad(CandidateOpeningMin,CandidateOpeningMax,rank);
em = em + quad(CandidateEndgameMin,CandidateEndgameMax,rank);
}


opening[me] = om;
endgame[me] = em;

ptr = ptr + 1;

}
}

// store info

info.opening = ((opening[White] - opening[Black]) * this.PawnStructureWeight) / 256;
info.endgame = ((endgame[White] - endgame[Black]) * this.PawnStructureWeight) / 256;

for (colour = 0;  colour<=1; colour++ ) {

me = colour;
opp = COLOUR_OPP(me);

// draw flags

bits = file_bits[me];

if (bits != 0  &&  ( ( bits & bits-1 ) == 0) ) {  // one set bit

file = this.BitFirst[bits];
rank = this.BitFirst[board.pawn_file[me][file] ];
//ASSERT(571, rank>=Rank2);

q = ( this.BitRev[board.pawn_file[opp][file-1]] | 
this.BitRev[board.pawn_file[opp][file+1]] );

if ( ( q & this.BitGT[rank] ) == 0) {

rank = this.BitLast[board.pawn_file[me][file] ];
single_file[me] = SQUARE_MAKE(file,rank);
}
}

info.flags[colour] = flags[colour];
info.passed_bits[colour] = passed_bits[colour];
info.single_file[colour] = single_file[colour];
}

}

// quad()

private function quad( y_min:int, y_max:int, x:int ) :int {

var y :int = 0;   // int

//ASSERT(572, y_min>=0 && y_min<=y_max && y_max<=32767);
//ASSERT(573, x>=Rank2 && x<=Rank7);

y =  Math.floor( y_min + ((y_max - y_min) * this.Bonus[x] + 128) / 256 );

//ASSERT(574, y>=y_min && y<=y_max);

return y;
}

// end of pawn.cpp



// piece.cpp

//  functions

// piece_init()

private function piece_init() :void {

var piece :int = 0;      // int
var piece_12 :int = 0;   // int

// this.PieceTo12[], this.PieceOrder[], this.PieceInc[]

for (piece = 0; piece<PieceNb; piece++ ) {
this.PieceTo12[piece] = -1;
this.PieceOrder[piece] = -1;
this.PieceInc[piece] = [];
}

for (piece_12 = 0; piece_12<= 11; piece_12++ ) {
this.PieceTo12[PieceFrom12[piece_12]] = piece_12;
this.PieceOrder[PieceFrom12[piece_12]] = ( piece_12 >> 1 );
}

this.PieceInc[WhiteKnight256] = KnightInc;
this.PieceInc[WhiteBishop256] = BishopInc;
this.PieceInc[WhiteRook256]   = RookInc;
this.PieceInc[WhiteQueen256]  = QueenInc;
this.PieceInc[WhiteKing256]   = KingInc;

this.PieceInc[BlackKnight256] = KnightInc;
this.PieceInc[BlackBishop256] = BishopInc;
this.PieceInc[BlackRook256]   = RookInc;
this.PieceInc[BlackQueen256]  = QueenInc;
this.PieceInc[BlackKing256]   = KingInc;

}

// piece_is_ok()

private function piece_is_ok( piece:int ) :Boolean {

if (piece < 0  ||  piece >= PieceNb) {
return false;
}
if (this.PieceTo12[piece] < 0) {
return false;
}
return true;
}

// piece_to_char()

private function piece_to_char( piece:int ) :String {

var i:int = this.PieceTo12[piece];

//ASSERT(576, piece_is_ok(piece));

return PieceString.charAt( i );
}

// piece_from_char()

private function piece_from_char( c:String ) :int {

var ptr :int = PieceString.indexOf( c );   // int

if (ptr<0) {
return PieceNone256;
}

//ASSERT(575, ptr>=0 && ptr<12);

return PieceFrom12[ptr];
}

// end of piece.cpp




// protocol.cpp

//  functions

private function setstartpos(): void { 

// init (to help debugging)

this.Init = false;

search_clear();

board_from_fen(this.SearchInput.board,StartFen);

}

// inits()

private function inits(): void { 

if (! this.Init) {

// late initialisation

this.Init = true;

if (option_get_bool("OwnBook")) {
//   book_open(option_get_string("BookFile"));
send("Sorry, no book.");
}

trans_alloc(this.Trans);

pawn_init();
pawn_alloc();

material_init();
material_alloc();

pst_init();
eval_init();
}
}

// loop_step()

private function do_input( cmd:String ): void { 

var ifelse :Boolean = true;

// parse

if (ifelse && string_start_with(cmd,"go")) {

inits();

parse_go( cmd );

ifelse = false;
}

if (ifelse && string_equal(cmd,"isready")) {

inits();
send("readyok");

ifelse = false;
}


if (ifelse && string_start_with(cmd,"position ")) {

inits();
parse_position(cmd);

ifelse = false;
}


if (ifelse && string_start_with(cmd,"setoption ")) {

parse_setoption( cmd );

ifelse = false;
}


if (ifelse && string_equal(cmd,"help")) {


send("supports commands: setposition fen, setposition moves, go depth, go movetime ");

// can manage also options, but for AS3 is better to use the default settings

// option_list();

ifelse = false;
}

}

// parse_go()

private function parse_go( cmd:String ) :void {

var cmd1 :String = "";          // string
var cmd2 :String = "";          // string
var infinite :Boolean = false;   // bool
var depth :int = -1;         // int
var movetime :Number = -1.0;    // int
var ifelse :Boolean = false;
var save_board:string_t = new string_t()

// parse

cmd1 = str_after_ok(cmd," ");    // skip "go"
cmd2 = str_after_ok(cmd1," ");   // value
cmd1 = str_before_ok(cmd1+" "," ");

ifelse = true;
if (ifelse && string_equal(cmd1,"depth")) {

depth = parseInt(cmd2);
//ASSERT(590, depth>=0);

ifelse = false;
}

if (ifelse && string_equal(cmd1,"infinite")) {

infinite = true;

ifelse = false;
}

if (ifelse && string_equal(cmd1,"movetime")) {

movetime = parseInt(cmd2);
//ASSERT(593, movetime>=0.0);

ifelse = false;
}

if (ifelse) {

movetime = 10;   // Otherwise constantly 10 secs

ifelse = false;
}


// init

ClearAll();

// depth limit

if (depth >= 0) {
this.SearchInput.depth_is_limited = true;
this.SearchInput.depth_limit = depth;
}

// time limit

if (movetime >= 0.0) {

// fixed time

this.SearchInput.time_is_limited = true;
this.SearchInput.time_limit_1 = movetime;
this.SearchInput.time_limit_2 = movetime;

}

if (infinite) {
this.SearchInput.infinite = true;
}

// search

if( ! this.ShowInfo) {
send("Thinking (ShowInfo=false)...");
}

board_to_fen(this.SearchInput.board, save_board);   // save board for sure

search();
search_update_current();

board_from_fen(this.SearchInput.board, save_board.v); // && restore after search

send_best_move();

}

// parse_position()

private function parse_position( cmd:String ) :void {

var cmd1 :String = "";          // string
var cmd2 :String = "";          // string
var mc:int = 0;

var move_string:string_t = new string_t()   // string

var move:int = 0;             // int
var undo:undo_t = new undo_t();  // undo_t[1]
var mnext:String = "";

cmd1 = str_after_ok(cmd," ");    // skip "position"
cmd2 = str_after_ok(cmd1," ");   // value

// start position

if ( string_start_with(cmd1,"fen") ) {  // "fen" present

board_from_fen(this.SearchInput.board,cmd2);

} else { 

if ( string_start_with(cmd1,"moves") ) {  // "moves" present

board_from_fen(this.SearchInput.board,StartFen);

mc = 0;

mnext = cmd2;
while(true) {

if( mnext.length==0 ) {
break;
}

move_string.v = ( mnext.indexOf(" ")<0 ? mnext : str_before_ok(mnext," ") );

move = move_from_string(move_string,this.SearchInput.board);

move_do(this.SearchInput.board,move,undo);

mnext = str_after_ok(mnext," ");

mc = mc + 1
}

this.SearchInput.board.movenumb = 1+Math.floor(mc/2);

} else { 

// HACK: assumes startpos

board_from_fen(this.SearchInput.board,StartFen);

}
}

}

// parse_setoption()

private function parse_setoption( cmd:String ) :void {

var cmd1 :String = "";    // string
var cmd2 :String = "";    // string

var name :String = "";    // string
var value :String = "";   // string

cmd1 = str_after_ok(cmd," ");    // skip "setoption"

name = str_after_ok(cmd1,"name ");
name = str_before_ok(name+" "," ");

value = str_after_ok(cmd1,"value ");
value = str_before_ok(value+" "," ");


if ( name.length>0 && value.length>0 )  {

// update

option_set(name,value);
}

// update transposition-table size if needed

if (this.Init  &&  string_equal(name,"Hash")) {  // Init => already allocated

if (option_get_int("Hash") >= 4) {
trans_alloc(this.Trans);
}
}

}


// send_best_move()

private function send_ndtm( ch:int ): void { 

var s :String = "info";
var s2 :String = "";

if(ch>5) {
s = s + " depth " + string_from_int(this.SearchCurrent.depth );
s = s + " seldepth " + string_from_int(this.SearchCurrent.max_depth ) + " ";
}

if(ch>=20 && ch<=22) {
s2 = s2 + " score mate " + string_from_int(this.SearchCurrent.mate ) + " ";
}
if(ch==11 || ch==21) {
s2 = s2 + "lowerbound ";
}
if(ch==12 || ch==22) {
s2 = s2 + "upperbound ";
}

s = s + " " + s2 + "time "+ string_from_float( this.SearchCurrent.time ) + "s";
s = s + " nodes " + string_from_int( this.SearchCurrent.node_nb );
s = s + " nps " +   string_from_float( this.SearchCurrent.speed );

send( s );

}

private function send_best_move(): void { 

var move_string:string_t = new string_t()     // string
var ponder_string:string_t = new string_t()   // string

var move :int = 0;      // int
var pv:Array = [];

// info

send_ndtm(1);


trans_stats(this.Trans);
// pawn_stats();
// material_stats();

// best move

move = this.SearchBest.move;
pv = this.SearchBest.pv;

move_to_string(move,move_string);

if ((false) && pv[0] == move  &&  move_is_ok(pv[1])) {

// no pondering for AS3, too slow

move_to_string(pv[1],ponder_string);
send("bestmove " + move_string.v + " ponder " + ponder_string.v);
} else { 
send("bestmove " + move_string.v);
}

if (this.External) CallingJS("BESTMOVE", move_string.v);

this.bestmv = move_string.v;

format_best_mv2( move );

}

// move for pgn

private function format_best_mv2( move:int ): void { 

var piece:int = 0;
var piecech :String = "";
var mvattr :String = "";
var promos :String = "";
var ckmt :String = "";
var board:board_t = this.SearchInput.board;

if( MOVE_IS_CASTLE(move) ) {
this.bestmv2 = ( this.bestmv.charAt( 2 ) == "g" ? "0-0" : "0-0-0" );
} else { 
piece = board.square[MOVE_FROM(move)];
if( (! piece_is_ok( piece )) || piece == PieceNone64 ) {
piece = board.square[MOVE_TO(move)];
}

piecech = ( piece_to_char(piece) ).toUpperCase();
if( piecech == "P") {
piecech = "";
}

mvattr = ( move_is_capture(move,board) ? "x" : "-" );

if( this.bestmv.length>4 ) {
promos = this.bestmv.charAt( 4 );
}

if( move_is_check(move,board) ) {
ckmt = "+";
}

this.bestmv2 = piecech + this.bestmv.substr( 0,2 ) + mvattr + this.bestmv.substr( 2, 2 ) + promos + ckmt;

}
}


// send()

private function send( str1:String ) :void {

if( ! this.ShowInfo && string_start_with(str1,"info ")) {
return;
}

print2out( str1 );
}

// string_equal()

private function string_equal( s1:String, s2:String ) :Boolean { 

return (s1==s2);
}

// string_start_with()

private function string_start_with( s1:String,  s2:String ) :Boolean { 

var l1:int =(s1.length);
var l2:int =(s2.length);

return (l1>=l2) && (s1.substr( 0, l2)==s2);
}


// str_before_ok()

private function str_before_ok( str1:String, c:String ): String { 
var i :int = str1.indexOf( c );
if(i>=0) {
return str1.substr( 0, i );
}
return "";
}

// str_after_ok()

private function str_after_ok( str1:String, c:String ): String { 
var i :int = str1.indexOf( c );
if(i>=0) {
return str1.substr( i+ (c.length) );
}
return "";
}

// end of protocol.cpp



// pst.cpp



// macros

private function Pget( piece_12:int,square_64:int,stage:int ): int { 
return this.Pst[piece_12][square_64][stage];
}

private function Pset( piece_12:int,square_64:int,stage:int, value:int ): void { 
this.Pst[piece_12][square_64][stage] = value;
}

private function Padd( piece_12:int,square_64:int,stage:int, value:int ): void { 
this.Pst[piece_12][square_64][stage] += value;
}

private function Pmul( piece_12:int,square_64:int,stage:int, value:int ): void { 
this.Pst[piece_12][square_64][stage] *= value;
}

//  functions

// pst_init()

private function pst_init(): void { 

var i :int = 0;      // int
var piece :int = 0;  // int
var sq :int = 0;     // int
var stage :int = 0;  // int

// UCI options

this.PieceActivityWeight = (option_get_int("Piece Activity") * 256 + 50) / 100;
this.KingSafetyWeight    = (option_get_int("King Safety")    * 256 + 50) / 100;
this.PawnStructureWeight = (option_get_int("Pawn Structure") * 256 + 50) / 100;

// init

for (piece = 0; piece<=11; piece++ ) {
this.Pst[piece] = [];
for (sq = 0; sq<=63; sq++ ) {
this.Pst[piece][sq] = [];
for (stage = 0; stage<StageNb; stage++ ) {
Pset(piece,sq,stage, 0);
}
}
}

// pawns

piece = WhitePawn12;

// file

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, PawnFile[square_file(sq)] * PawnFileOpening );
}

// centre control

Padd(piece,pD3,Opening, 10);
Padd(piece,pE3,Opening, 10);

Padd(piece,pD4,Opening, 20);
Padd(piece,pE4,Opening, 20);

Padd(piece,pD5,Opening, 10);
Padd(piece,pE5,Opening, 10);

// weight

for (sq = 0; sq<=63; sq++ ) {
Pmul(piece,sq,Opening,  this.PawnStructureWeight / 256);
Pmul(piece,sq,Endgame,  this.PawnStructureWeight / 256);
}

// knights

piece = WhiteKnight12;

// centre

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, KnightLine[square_file(sq)] * KnightCentreOpening);
Padd(piece,sq,Opening, KnightLine[square_rank(sq)] * KnightCentreOpening);
Padd(piece,sq,Endgame, KnightLine[square_file(sq)] * KnightCentreEndgame);
Padd(piece,sq,Endgame, KnightLine[square_rank(sq)] * KnightCentreEndgame);
}

// rank

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, KnightRank[square_rank(sq)] * KnightRankOpening);
}

// back rank

for (sq = pA1; sq<=pH1; sq++ ) {    // HACK: only first rank
Padd(piece,sq,Opening, -KnightBackRankOpening);
}

// "trapped"

Padd(piece,pA8,Opening, -KnightTrapped);
Padd(piece,pH8,Opening, -KnightTrapped);

// weight

for (sq = 0; sq<=63; sq++ ) {
Pmul(piece,sq,Opening,  this.PieceActivityWeight / 256);
Pmul(piece,sq,Endgame,  this.PieceActivityWeight / 256);
}

// bishops

piece = WhiteBishop12;

// centre

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening,  BishopLine[square_file(sq)] * BishopCentreOpening);
Padd(piece,sq,Opening,  BishopLine[square_rank(sq)] * BishopCentreOpening);
Padd(piece,sq,Endgame,  BishopLine[square_file(sq)] * BishopCentreEndgame);
Padd(piece,sq,Endgame,  BishopLine[square_rank(sq)] * BishopCentreEndgame);
}

// back rank

for (sq = pA1; sq<=pH1; sq++ ) {    // HACK: only first rank
Padd(piece,sq,Opening, -BishopBackRankOpening);
}

// main diagonals

for (i = 0; i<=7; i++ ) {
sq = square_make(i,i);
Padd(piece,sq,Opening, BishopDiagonalOpening);
Padd(piece,square_opp(sq),Opening, BishopDiagonalOpening);
}

// weight

for (sq = 0; sq<=63; sq++ ) {
Pmul(piece,sq,Opening,  this.PieceActivityWeight / 256);
Pmul(piece,sq,Endgame,  this.PieceActivityWeight / 256);
}

// rooks

piece = WhiteRook12;

// file

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, RookFile[square_file(sq)] * RookFileOpening);
}

// weight

for (sq = 0; sq<=63; sq++ ) {
Pmul(piece,sq,Opening,  this.PieceActivityWeight / 256);
Pmul(piece,sq,Endgame,  this.PieceActivityWeight / 256);
}

// queens

piece = WhiteQueen12;

// centre

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, QueenLine[square_file(sq)] * QueenCentreOpening);
Padd(piece,sq,Opening, QueenLine[square_rank(sq)] * QueenCentreOpening);
Padd(piece,sq,Endgame, QueenLine[square_file(sq)] * QueenCentreEndgame);
Padd(piece,sq,Endgame, QueenLine[square_rank(sq)] * QueenCentreEndgame);
}

// back rank

for (sq = pA1; sq<=pH1; sq++ ) {    // HACK: only first rank
Padd(piece,sq,Opening, -QueenBackRankOpening);
}

// weight

for (sq = 0; sq<=63; sq++ ) {
Pmul(piece,sq,Opening, this.PieceActivityWeight / 256);
Pmul(piece,sq,Endgame, this.PieceActivityWeight / 256);
}

// kings

piece = WhiteKing12;

// centre

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Endgame, KingLine[square_file(sq)] * KingCentreEndgame);
Padd(piece,sq,Endgame, KingLine[square_rank(sq)] * KingCentreEndgame);
}

// file

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, KingFile[square_file(sq)] * KingFileOpening);
}

// rank

for (sq = 0; sq<=63; sq++ ) {
Padd(piece,sq,Opening, KingRank[square_rank(sq)] * KingRankOpening);
}

// weight

for (sq = 0; sq<=63; sq++ ) {
Pmul(piece,sq,Opening, this.KingSafetyWeight / 256);
Pmul(piece,sq,Endgame, this.PieceActivityWeight / 256);
}

// symmetry copy for black

for (piece = 0; piece<= 11; piece+=2 ) { // HACK
for (sq = 0; sq<=63; sq++ ) {
for (stage = 0; stage<StageNb; stage++ ) {
Pset(piece+1,sq,stage, -Pget(piece,square_opp(sq),stage) ); // HACK
}
}
}

}

// square_make()

private function square_make( file:int, rank:int ) :int {

//ASSERT(610, file>=0 && file<8);
//ASSERT(611, rank>=0 && rank<8);

return ( (rank << 3) | file);
}

// square_file()

private function square_file( square:int ) :int {

//ASSERT(612, square>=0 && square<64);

return ( square & 7 );
}

// square_rank()

private function square_rank( square:int ) :int {

//ASSERT(613, square>=0 && square<64);

return (square >> 3);
}

// square_opp()

private function square_opp( square:int ) :int {

//ASSERT(614, square>=0 && square<64);

return (square ^ 56);
}

// end of pst.cpp




// pv.cpp


//  functions

// pv_is_ok()

private function pv_is_ok( pv:Array ) :Boolean {

var pos :int = 0;    // int
var move :int = 0;   // int

while(true) {

if (pos >= 256) {
return false;
}
move = pv[pos];

if (move == MoveNone) {
return true;
}
if (! move_is_ok(move)) {
return false;
}

pos = pos + 1;
}

return true;
}

// pv_copy()

private function pv_copy( dst:Array , src:Array ) :void {

var i :int = 0;  // int
var m :int = 0;  // int

//ASSERT(615, pv_is_ok(src));

while(true) {
m = src[i];
dst[i] = m;
if( m == MoveNone) {
break;
}
i = i + 1;
}

}

// pv_cat()

private function pv_cat( dst:Array , src:Array , move:int ) :void {

var i :int = 0;  // int
var m :int = 0;  // int

//ASSERT(617, pv_is_ok(src));

dst[0] = move;

while(true) {
m = src[i];
dst[i+1] = m;
if( m == MoveNone) {
break;
}
i = i + 1;
}

}

// pv_to_string()


private function pv_to_string( pv:Array, str1:string_t ) :Boolean {

var i :int = 0;              // int
var move :int = 0;           // int
var str2:string_t = new string_t()  // string_t[1]

//ASSERT(619, pv_is_ok(pv));


// init

str1.v = "";

// loop

while(true) {

move = pv[i];
if(move==MoveNone) {
break;
}

if(i>0) {
str1.v = str1.v + " ";
}

move_to_string(move, str2);
str1.v = str1.v + str2.v;

i = i + 1;
}

return true;

}

// end of pv.cpp




// random.cpp

// we simply ignore 32bits of number
// so, we can't read polyglot book
// anyway, we can hash now

//  functions

private function Rn64(s64b:String): void { 
this.Random64 [this.R64_i] = parseInt( s64b.substr( 0, 10 ) );
this.R64_i = this.R64_i + 1;
}

// random_init()

private function random_init(): void { 

Rn64("0x9D39247E33776D41"); Rn64("0x2AF7398005AAA5C7"); Rn64("0x44DB015024623547"); Rn64("0x9C15F73E62A76AE2");
Rn64("0x75834465489C0C89"); Rn64("0x3290AC3A203001BF"); Rn64("0x0FBBAD1F61042279"); Rn64("0xE83A908FF2FB60CA");
Rn64("0x0D7E765D58755C10"); Rn64("0x1A083822CEAFE02D"); Rn64("0x9605D5F0E25EC3B0"); Rn64("0xD021FF5CD13A2ED5");
Rn64("0x40BDF15D4A672E32"); Rn64("0x011355146FD56395"); Rn64("0x5DB4832046F3D9E5"); Rn64("0x239F8B2D7FF719CC");
Rn64("0x05D1A1AE85B49AA1"); Rn64("0x679F848F6E8FC971"); Rn64("0x7449BBFF801FED0B"); Rn64("0x7D11CDB1C3B7ADF0");
Rn64("0x82C7709E781EB7CC"); Rn64("0xF3218F1C9510786C"); Rn64("0x331478F3AF51BBE6"); Rn64("0x4BB38DE5E7219443");
Rn64("0xAA649C6EBCFD50FC"); Rn64("0x8DBD98A352AFD40B"); Rn64("0x87D2074B81D79217"); Rn64("0x19F3C751D3E92AE1");
Rn64("0xB4AB30F062B19ABF"); Rn64("0x7B0500AC42047AC4"); Rn64("0xC9452CA81A09D85D"); Rn64("0x24AA6C514DA27500");
Rn64("0x4C9F34427501B447"); Rn64("0x14A68FD73C910841"); Rn64("0xA71B9B83461CBD93"); Rn64("0x03488B95B0F1850F");
Rn64("0x637B2B34FF93C040"); Rn64("0x09D1BC9A3DD90A94"); Rn64("0x3575668334A1DD3B"); Rn64("0x735E2B97A4C45A23");
Rn64("0x18727070F1BD400B"); Rn64("0x1FCBACD259BF02E7"); Rn64("0xD310A7C2CE9B6555"); Rn64("0xBF983FE0FE5D8244");
Rn64("0x9F74D14F7454A824"); Rn64("0x51EBDC4AB9BA3035"); Rn64("0x5C82C505DB9AB0FA"); Rn64("0xFCF7FE8A3430B241");
Rn64("0x3253A729B9BA3DDE"); Rn64("0x8C74C368081B3075"); Rn64("0xB9BC6C87167C33E7"); Rn64("0x7EF48F2B83024E20");
Rn64("0x11D505D4C351BD7F"); Rn64("0x6568FCA92C76A243"); Rn64("0x4DE0B0F40F32A7B8"); Rn64("0x96D693460CC37E5D");
Rn64("0x42E240CB63689F2F"); Rn64("0x6D2BDCDAE2919661"); Rn64("0x42880B0236E4D951"); Rn64("0x5F0F4A5898171BB6");
Rn64("0x39F890F579F92F88"); Rn64("0x93C5B5F47356388B"); Rn64("0x63DC359D8D231B78"); Rn64("0xEC16CA8AEA98AD76");
Rn64("0x5355F900C2A82DC7"); Rn64("0x07FB9F855A997142"); Rn64("0x5093417AA8A7ED5E"); Rn64("0x7BCBC38DA25A7F3C");
Rn64("0x19FC8A768CF4B6D4"); Rn64("0x637A7780DECFC0D9"); Rn64("0x8249A47AEE0E41F7"); Rn64("0x79AD695501E7D1E8");
Rn64("0x14ACBAF4777D5776"); Rn64("0xF145B6BECCDEA195"); Rn64("0xDABF2AC8201752FC"); Rn64("0x24C3C94DF9C8D3F6");
Rn64("0xBB6E2924F03912EA"); Rn64("0x0CE26C0B95C980D9"); Rn64("0xA49CD132BFBF7CC4"); Rn64("0xE99D662AF4243939");
Rn64("0x27E6AD7891165C3F"); Rn64("0x8535F040B9744FF1"); Rn64("0x54B3F4FA5F40D873"); Rn64("0x72B12C32127FED2B");
Rn64("0xEE954D3C7B411F47"); Rn64("0x9A85AC909A24EAA1"); Rn64("0x70AC4CD9F04F21F5"); Rn64("0xF9B89D3E99A075C2");
Rn64("0x87B3E2B2B5C907B1"); Rn64("0xA366E5B8C54F48B8"); Rn64("0xAE4A9346CC3F7CF2"); Rn64("0x1920C04D47267BBD");
Rn64("0x87BF02C6B49E2AE9"); Rn64("0x092237AC237F3859"); Rn64("0xFF07F64EF8ED14D0"); Rn64("0x8DE8DCA9F03CC54E");
Rn64("0x9C1633264DB49C89"); Rn64("0xB3F22C3D0B0B38ED"); Rn64("0x390E5FB44D01144B"); Rn64("0x5BFEA5B4712768E9");
Rn64("0x1E1032911FA78984"); Rn64("0x9A74ACB964E78CB3"); Rn64("0x4F80F7A035DAFB04"); Rn64("0x6304D09A0B3738C4");
Rn64("0x2171E64683023A08"); Rn64("0x5B9B63EB9CEFF80C"); Rn64("0x506AACF489889342"); Rn64("0x1881AFC9A3A701D6");
Rn64("0x6503080440750644"); Rn64("0xDFD395339CDBF4A7"); Rn64("0xEF927DBCF00C20F2"); Rn64("0x7B32F7D1E03680EC");
Rn64("0xB9FD7620E7316243"); Rn64("0x05A7E8A57DB91B77"); Rn64("0xB5889C6E15630A75"); Rn64("0x4A750A09CE9573F7");
Rn64("0xCF464CEC899A2F8A"); Rn64("0xF538639CE705B824"); Rn64("0x3C79A0FF5580EF7F"); Rn64("0xEDE6C87F8477609D");
Rn64("0x799E81F05BC93F31"); Rn64("0x86536B8CF3428A8C"); Rn64("0x97D7374C60087B73"); Rn64("0xA246637CFF328532");
Rn64("0x043FCAE60CC0EBA0"); Rn64("0x920E449535DD359E"); Rn64("0x70EB093B15B290CC"); Rn64("0x73A1921916591CBD");
Rn64("0x56436C9FE1A1AA8D"); Rn64("0xEFAC4B70633B8F81"); Rn64("0xBB215798D45DF7AF"); Rn64("0x45F20042F24F1768");
Rn64("0x930F80F4E8EB7462"); Rn64("0xFF6712FFCFD75EA1"); Rn64("0xAE623FD67468AA70"); Rn64("0xDD2C5BC84BC8D8FC");
Rn64("0x7EED120D54CF2DD9"); Rn64("0x22FE545401165F1C"); Rn64("0xC91800E98FB99929"); Rn64("0x808BD68E6AC10365");
Rn64("0xDEC468145B7605F6"); Rn64("0x1BEDE3A3AEF53302"); Rn64("0x43539603D6C55602"); Rn64("0xAA969B5C691CCB7A");
Rn64("0xA87832D392EFEE56"); Rn64("0x65942C7B3C7E11AE"); Rn64("0xDED2D633CAD004F6"); Rn64("0x21F08570F420E565");
Rn64("0xB415938D7DA94E3C"); Rn64("0x91B859E59ECB6350"); Rn64("0x10CFF333E0ED804A"); Rn64("0x28AED140BE0BB7DD");
Rn64("0xC5CC1D89724FA456"); Rn64("0x5648F680F11A2741"); Rn64("0x2D255069F0B7DAB3"); Rn64("0x9BC5A38EF729ABD4");
Rn64("0xEF2F054308F6A2BC"); Rn64("0xAF2042F5CC5C2858"); Rn64("0x480412BAB7F5BE2A"); Rn64("0xAEF3AF4A563DFE43");
Rn64("0x19AFE59AE451497F"); Rn64("0x52593803DFF1E840"); Rn64("0xF4F076E65F2CE6F0"); Rn64("0x11379625747D5AF3");
Rn64("0xBCE5D2248682C115"); Rn64("0x9DA4243DE836994F"); Rn64("0x066F70B33FE09017"); Rn64("0x4DC4DE189B671A1C");
Rn64("0x51039AB7712457C3"); Rn64("0xC07A3F80C31FB4B4"); Rn64("0xB46EE9C5E64A6E7C"); Rn64("0xB3819A42ABE61C87");
Rn64("0x21A007933A522A20"); Rn64("0x2DF16F761598AA4F"); Rn64("0x763C4A1371B368FD"); Rn64("0xF793C46702E086A0");
Rn64("0xD7288E012AEB8D31"); Rn64("0xDE336A2A4BC1C44B"); Rn64("0x0BF692B38D079F23"); Rn64("0x2C604A7A177326B3");
Rn64("0x4850E73E03EB6064"); Rn64("0xCFC447F1E53C8E1B"); Rn64("0xB05CA3F564268D99"); Rn64("0x9AE182C8BC9474E8");
Rn64("0xA4FC4BD4FC5558CA"); Rn64("0xE755178D58FC4E76"); Rn64("0x69B97DB1A4C03DFE"); Rn64("0xF9B5B7C4ACC67C96");
Rn64("0xFC6A82D64B8655FB"); Rn64("0x9C684CB6C4D24417"); Rn64("0x8EC97D2917456ED0"); Rn64("0x6703DF9D2924E97E");
Rn64("0xC547F57E42A7444E"); Rn64("0x78E37644E7CAD29E"); Rn64("0xFE9A44E9362F05FA"); Rn64("0x08BD35CC38336615");
Rn64("0x9315E5EB3A129ACE"); Rn64("0x94061B871E04DF75"); Rn64("0xDF1D9F9D784BA010"); Rn64("0x3BBA57B68871B59D");
Rn64("0xD2B7ADEEDED1F73F"); Rn64("0xF7A255D83BC373F8"); Rn64("0xD7F4F2448C0CEB81"); Rn64("0xD95BE88CD210FFA7");
Rn64("0x336F52F8FF4728E7"); Rn64("0xA74049DAC312AC71"); Rn64("0xA2F61BB6E437FDB5"); Rn64("0x4F2A5CB07F6A35B3");
Rn64("0x87D380BDA5BF7859"); Rn64("0x16B9F7E06C453A21"); Rn64("0x7BA2484C8A0FD54E"); Rn64("0xF3A678CAD9A2E38C");
Rn64("0x39B0BF7DDE437BA2"); Rn64("0xFCAF55C1BF8A4424"); Rn64("0x18FCF680573FA594"); Rn64("0x4C0563B89F495AC3");
Rn64("0x40E087931A00930D"); Rn64("0x8CFFA9412EB642C1"); Rn64("0x68CA39053261169F"); Rn64("0x7A1EE967D27579E2");
Rn64("0x9D1D60E5076F5B6F"); Rn64("0x3810E399B6F65BA2"); Rn64("0x32095B6D4AB5F9B1"); Rn64("0x35CAB62109DD038A");
Rn64("0xA90B24499FCFAFB1"); Rn64("0x77A225A07CC2C6BD"); Rn64("0x513E5E634C70E331"); Rn64("0x4361C0CA3F692F12");
Rn64("0xD941ACA44B20A45B"); Rn64("0x528F7C8602C5807B"); Rn64("0x52AB92BEB9613989"); Rn64("0x9D1DFA2EFC557F73");
Rn64("0x722FF175F572C348"); Rn64("0x1D1260A51107FE97"); Rn64("0x7A249A57EC0C9BA2"); Rn64("0x04208FE9E8F7F2D6");
Rn64("0x5A110C6058B920A0"); Rn64("0x0CD9A497658A5698"); Rn64("0x56FD23C8F9715A4C"); Rn64("0x284C847B9D887AAE");
Rn64("0x04FEABFBBDB619CB"); Rn64("0x742E1E651C60BA83"); Rn64("0x9A9632E65904AD3C"); Rn64("0x881B82A13B51B9E2");
Rn64("0x506E6744CD974924"); Rn64("0xB0183DB56FFC6A79"); Rn64("0x0ED9B915C66ED37E"); Rn64("0x5E11E86D5873D484");
Rn64("0xF678647E3519AC6E"); Rn64("0x1B85D488D0F20CC5"); Rn64("0xDAB9FE6525D89021"); Rn64("0x0D151D86ADB73615");
Rn64("0xA865A54EDCC0F019"); Rn64("0x93C42566AEF98FFB"); Rn64("0x99E7AFEABE000731"); Rn64("0x48CBFF086DDF285A");
Rn64("0x7F9B6AF1EBF78BAF"); Rn64("0x58627E1A149BBA21"); Rn64("0x2CD16E2ABD791E33"); Rn64("0xD363EFF5F0977996");
Rn64("0x0CE2A38C344A6EED"); Rn64("0x1A804AADB9CFA741"); Rn64("0x907F30421D78C5DE"); Rn64("0x501F65EDB3034D07");
Rn64("0x37624AE5A48FA6E9"); Rn64("0x957BAF61700CFF4E"); Rn64("0x3A6C27934E31188A"); Rn64("0xD49503536ABCA345");
Rn64("0x088E049589C432E0"); Rn64("0xF943AEE7FEBF21B8"); Rn64("0x6C3B8E3E336139D3"); Rn64("0x364F6FFA464EE52E");
Rn64("0xD60F6DCEDC314222"); Rn64("0x56963B0DCA418FC0"); Rn64("0x16F50EDF91E513AF"); Rn64("0xEF1955914B609F93");
Rn64("0x565601C0364E3228"); Rn64("0xECB53939887E8175"); Rn64("0xBAC7A9A18531294B"); Rn64("0xB344C470397BBA52");
Rn64("0x65D34954DAF3CEBD"); Rn64("0xB4B81B3FA97511E2"); Rn64("0xB422061193D6F6A7"); Rn64("0x071582401C38434D");
Rn64("0x7A13F18BBEDC4FF5"); Rn64("0xBC4097B116C524D2"); Rn64("0x59B97885E2F2EA28"); Rn64("0x99170A5DC3115544");
Rn64("0x6F423357E7C6A9F9"); Rn64("0x325928EE6E6F8794"); Rn64("0xD0E4366228B03343"); Rn64("0x565C31F7DE89EA27");
Rn64("0x30F5611484119414"); Rn64("0xD873DB391292ED4F"); Rn64("0x7BD94E1D8E17DEBC"); Rn64("0xC7D9F16864A76E94");
Rn64("0x947AE053EE56E63C"); Rn64("0xC8C93882F9475F5F"); Rn64("0x3A9BF55BA91F81CA"); Rn64("0xD9A11FBB3D9808E4");
Rn64("0x0FD22063EDC29FCA"); Rn64("0xB3F256D8ACA0B0B9"); Rn64("0xB03031A8B4516E84"); Rn64("0x35DD37D5871448AF");
Rn64("0xE9F6082B05542E4E"); Rn64("0xEBFAFA33D7254B59"); Rn64("0x9255ABB50D532280"); Rn64("0xB9AB4CE57F2D34F3");
Rn64("0x693501D628297551"); Rn64("0xC62C58F97DD949BF"); Rn64("0xCD454F8F19C5126A"); Rn64("0xBBE83F4ECC2BDECB");
Rn64("0xDC842B7E2819E230"); Rn64("0xBA89142E007503B8"); Rn64("0xA3BC941D0A5061CB"); Rn64("0xE9F6760E32CD8021");
Rn64("0x09C7E552BC76492F"); Rn64("0x852F54934DA55CC9"); Rn64("0x8107FCCF064FCF56"); Rn64("0x098954D51FFF6580");
Rn64("0x23B70EDB1955C4BF"); Rn64("0xC330DE426430F69D"); Rn64("0x4715ED43E8A45C0A"); Rn64("0xA8D7E4DAB780A08D");
Rn64("0x0572B974F03CE0BB"); Rn64("0xB57D2E985E1419C7"); Rn64("0xE8D9ECBE2CF3D73F"); Rn64("0x2FE4B17170E59750");
Rn64("0x11317BA87905E790"); Rn64("0x7FBF21EC8A1F45EC"); Rn64("0x1725CABFCB045B00"); Rn64("0x964E915CD5E2B207");
Rn64("0x3E2B8BCBF016D66D"); Rn64("0xBE7444E39328A0AC"); Rn64("0xF85B2B4FBCDE44B7"); Rn64("0x49353FEA39BA63B1");
Rn64("0x1DD01AAFCD53486A"); Rn64("0x1FCA8A92FD719F85"); Rn64("0xFC7C95D827357AFA"); Rn64("0x18A6A990C8B35EBD");
Rn64("0xCCCB7005C6B9C28D"); Rn64("0x3BDBB92C43B17F26"); Rn64("0xAA70B5B4F89695A2"); Rn64("0xE94C39A54A98307F");
Rn64("0xB7A0B174CFF6F36E"); Rn64("0xD4DBA84729AF48AD"); Rn64("0x2E18BC1AD9704A68"); Rn64("0x2DE0966DAF2F8B1C");
Rn64("0xB9C11D5B1E43A07E"); Rn64("0x64972D68DEE33360"); Rn64("0x94628D38D0C20584"); Rn64("0xDBC0D2B6AB90A559");
Rn64("0xD2733C4335C6A72F"); Rn64("0x7E75D99D94A70F4D"); Rn64("0x6CED1983376FA72B"); Rn64("0x97FCAACBF030BC24");
Rn64("0x7B77497B32503B12"); Rn64("0x8547EDDFB81CCB94"); Rn64("0x79999CDFF70902CB"); Rn64("0xCFFE1939438E9B24");
Rn64("0x829626E3892D95D7"); Rn64("0x92FAE24291F2B3F1"); Rn64("0x63E22C147B9C3403"); Rn64("0xC678B6D860284A1C");
Rn64("0x5873888850659AE7"); Rn64("0x0981DCD296A8736D"); Rn64("0x9F65789A6509A440"); Rn64("0x9FF38FED72E9052F");
Rn64("0xE479EE5B9930578C"); Rn64("0xE7F28ECD2D49EECD"); Rn64("0x56C074A581EA17FE"); Rn64("0x5544F7D774B14AEF");
Rn64("0x7B3F0195FC6F290F"); Rn64("0x12153635B2C0CF57"); Rn64("0x7F5126DBBA5E0CA7"); Rn64("0x7A76956C3EAFB413");
Rn64("0x3D5774A11D31AB39"); Rn64("0x8A1B083821F40CB4"); Rn64("0x7B4A38E32537DF62"); Rn64("0x950113646D1D6E03");
Rn64("0x4DA8979A0041E8A9"); Rn64("0x3BC36E078F7515D7"); Rn64("0x5D0A12F27AD310D1"); Rn64("0x7F9D1A2E1EBE1327");
Rn64("0xDA3A361B1C5157B1"); Rn64("0xDCDD7D20903D0C25"); Rn64("0x36833336D068F707"); Rn64("0xCE68341F79893389");
Rn64("0xAB9090168DD05F34"); Rn64("0x43954B3252DC25E5"); Rn64("0xB438C2B67F98E5E9"); Rn64("0x10DCD78E3851A492");
Rn64("0xDBC27AB5447822BF"); Rn64("0x9B3CDB65F82CA382"); Rn64("0xB67B7896167B4C84"); Rn64("0xBFCED1B0048EAC50");
Rn64("0xA9119B60369FFEBD"); Rn64("0x1FFF7AC80904BF45"); Rn64("0xAC12FB171817EEE7"); Rn64("0xAF08DA9177DDA93D");
Rn64("0x1B0CAB936E65C744"); Rn64("0xB559EB1D04E5E932"); Rn64("0xC37B45B3F8D6F2BA"); Rn64("0xC3A9DC228CAAC9E9");
Rn64("0xF3B8B6675A6507FF"); Rn64("0x9FC477DE4ED681DA"); Rn64("0x67378D8ECCEF96CB"); Rn64("0x6DD856D94D259236");
Rn64("0xA319CE15B0B4DB31"); Rn64("0x073973751F12DD5E"); Rn64("0x8A8E849EB32781A5"); Rn64("0xE1925C71285279F5");
Rn64("0x74C04BF1790C0EFE"); Rn64("0x4DDA48153C94938A"); Rn64("0x9D266D6A1CC0542C"); Rn64("0x7440FB816508C4FE");
Rn64("0x13328503DF48229F"); Rn64("0xD6BF7BAEE43CAC40"); Rn64("0x4838D65F6EF6748F"); Rn64("0x1E152328F3318DEA");
Rn64("0x8F8419A348F296BF"); Rn64("0x72C8834A5957B511"); Rn64("0xD7A023A73260B45C"); Rn64("0x94EBC8ABCFB56DAE");
Rn64("0x9FC10D0F989993E0"); Rn64("0xDE68A2355B93CAE6"); Rn64("0xA44CFE79AE538BBE"); Rn64("0x9D1D84FCCE371425");
Rn64("0x51D2B1AB2DDFB636"); Rn64("0x2FD7E4B9E72CD38C"); Rn64("0x65CA5B96B7552210"); Rn64("0xDD69A0D8AB3B546D");
Rn64("0x604D51B25FBF70E2"); Rn64("0x73AA8A564FB7AC9E"); Rn64("0x1A8C1E992B941148"); Rn64("0xAAC40A2703D9BEA0");
Rn64("0x764DBEAE7FA4F3A6"); Rn64("0x1E99B96E70A9BE8B"); Rn64("0x2C5E9DEB57EF4743"); Rn64("0x3A938FEE32D29981");
Rn64("0x26E6DB8FFDF5ADFE"); Rn64("0x469356C504EC9F9D"); Rn64("0xC8763C5B08D1908C"); Rn64("0x3F6C6AF859D80055");
Rn64("0x7F7CC39420A3A545"); Rn64("0x9BFB227EBDF4C5CE"); Rn64("0x89039D79D6FC5C5C"); Rn64("0x8FE88B57305E2AB6");
Rn64("0xA09E8C8C35AB96DE"); Rn64("0xFA7E393983325753"); Rn64("0xD6B6D0ECC617C699"); Rn64("0xDFEA21EA9E7557E3");
Rn64("0xB67C1FA481680AF8"); Rn64("0xCA1E3785A9E724E5"); Rn64("0x1CFC8BED0D681639"); Rn64("0xD18D8549D140CAEA");
Rn64("0x4ED0FE7E9DC91335"); Rn64("0xE4DBF0634473F5D2"); Rn64("0x1761F93A44D5AEFE"); Rn64("0x53898E4C3910DA55");
Rn64("0x734DE8181F6EC39A"); Rn64("0x2680B122BAA28D97"); Rn64("0x298AF231C85BAFAB"); Rn64("0x7983EED3740847D5");
Rn64("0x66C1A2A1A60CD889"); Rn64("0x9E17E49642A3E4C1"); Rn64("0xEDB454E7BADC0805"); Rn64("0x50B704CAB602C329");
Rn64("0x4CC317FB9CDDD023"); Rn64("0x66B4835D9EAFEA22"); Rn64("0x219B97E26FFC81BD"); Rn64("0x261E4E4C0A333A9D");
Rn64("0x1FE2CCA76517DB90"); Rn64("0xD7504DFA8816EDBB"); Rn64("0xB9571FA04DC089C8"); Rn64("0x1DDC0325259B27DE");
Rn64("0xCF3F4688801EB9AA"); Rn64("0xF4F5D05C10CAB243"); Rn64("0x38B6525C21A42B0E"); Rn64("0x36F60E2BA4FA6800");
Rn64("0xEB3593803173E0CE"); Rn64("0x9C4CD6257C5A3603"); Rn64("0xAF0C317D32ADAA8A"); Rn64("0x258E5A80C7204C4B");
Rn64("0x8B889D624D44885D"); Rn64("0xF4D14597E660F855"); Rn64("0xD4347F66EC8941C3"); Rn64("0xE699ED85B0DFB40D");
Rn64("0x2472F6207C2D0484"); Rn64("0xC2A1E7B5B459AEB5"); Rn64("0xAB4F6451CC1D45EC"); Rn64("0x63767572AE3D6174");
Rn64("0xA59E0BD101731A28"); Rn64("0x116D0016CB948F09"); Rn64("0x2CF9C8CA052F6E9F"); Rn64("0x0B090A7560A968E3");
Rn64("0xABEEDDB2DDE06FF1"); Rn64("0x58EFC10B06A2068D"); Rn64("0xC6E57A78FBD986E0"); Rn64("0x2EAB8CA63CE802D7");
Rn64("0x14A195640116F336"); Rn64("0x7C0828DD624EC390"); Rn64("0xD74BBE77E6116AC7"); Rn64("0x804456AF10F5FB53");
Rn64("0xEBE9EA2ADF4321C7"); Rn64("0x03219A39EE587A30"); Rn64("0x49787FEF17AF9924"); Rn64("0xA1E9300CD8520548");
Rn64("0x5B45E522E4B1B4EF"); Rn64("0xB49C3B3995091A36"); Rn64("0xD4490AD526F14431"); Rn64("0x12A8F216AF9418C2");
Rn64("0x001F837CC7350524"); Rn64("0x1877B51E57A764D5"); Rn64("0xA2853B80F17F58EE"); Rn64("0x993E1DE72D36D310");
Rn64("0xB3598080CE64A656"); Rn64("0x252F59CF0D9F04BB"); Rn64("0xD23C8E176D113600"); Rn64("0x1BDA0492E7E4586E");
Rn64("0x21E0BD5026C619BF"); Rn64("0x3B097ADAF088F94E"); Rn64("0x8D14DEDB30BE846E"); Rn64("0xF95CFFA23AF5F6F4");
Rn64("0x3871700761B3F743"); Rn64("0xCA672B91E9E4FA16"); Rn64("0x64C8E531BFF53B55"); Rn64("0x241260ED4AD1E87D");
Rn64("0x106C09B972D2E822"); Rn64("0x7FBA195410E5CA30"); Rn64("0x7884D9BC6CB569D8"); Rn64("0x0647DFEDCD894A29");
Rn64("0x63573FF03E224774"); Rn64("0x4FC8E9560F91B123"); Rn64("0x1DB956E450275779"); Rn64("0xB8D91274B9E9D4FB");
Rn64("0xA2EBEE47E2FBFCE1"); Rn64("0xD9F1F30CCD97FB09"); Rn64("0xEFED53D75FD64E6B"); Rn64("0x2E6D02C36017F67F");
Rn64("0xA9AA4D20DB084E9B"); Rn64("0xB64BE8D8B25396C1"); Rn64("0x70CB6AF7C2D5BCF0"); Rn64("0x98F076A4F7A2322E");
Rn64("0xBF84470805E69B5F"); Rn64("0x94C3251F06F90CF3"); Rn64("0x3E003E616A6591E9"); Rn64("0xB925A6CD0421AFF3");
Rn64("0x61BDD1307C66E300"); Rn64("0xBF8D5108E27E0D48"); Rn64("0x240AB57A8B888B20"); Rn64("0xFC87614BAF287E07");
Rn64("0xEF02CDD06FFDB432"); Rn64("0xA1082C0466DF6C0A"); Rn64("0x8215E577001332C8"); Rn64("0xD39BB9C3A48DB6CF");
Rn64("0x2738259634305C14"); Rn64("0x61CF4F94C97DF93D"); Rn64("0x1B6BACA2AE4E125B"); Rn64("0x758F450C88572E0B");
Rn64("0x959F587D507A8359"); Rn64("0xB063E962E045F54D"); Rn64("0x60E8ED72C0DFF5D1"); Rn64("0x7B64978555326F9F");
Rn64("0xFD080D236DA814BA"); Rn64("0x8C90FD9B083F4558"); Rn64("0x106F72FE81E2C590"); Rn64("0x7976033A39F7D952");
Rn64("0xA4EC0132764CA04B"); Rn64("0x733EA705FAE4FA77"); Rn64("0xB4D8F77BC3E56167"); Rn64("0x9E21F4F903B33FD9");
Rn64("0x9D765E419FB69F6D"); Rn64("0xD30C088BA61EA5EF"); Rn64("0x5D94337FBFAF7F5B"); Rn64("0x1A4E4822EB4D7A59");
Rn64("0x6FFE73E81B637FB3"); Rn64("0xDDF957BC36D8B9CA"); Rn64("0x64D0E29EEA8838B3"); Rn64("0x08DD9BDFD96B9F63");
Rn64("0x087E79E5A57D1D13"); Rn64("0xE328E230E3E2B3FB"); Rn64("0x1C2559E30F0946BE"); Rn64("0x720BF5F26F4D2EAA");
Rn64("0xB0774D261CC609DB"); Rn64("0x443F64EC5A371195"); Rn64("0x4112CF68649A260E"); Rn64("0xD813F2FAB7F5C5CA");
Rn64("0x660D3257380841EE"); Rn64("0x59AC2C7873F910A3"); Rn64("0xE846963877671A17"); Rn64("0x93B633ABFA3469F8");
Rn64("0xC0C0F5A60EF4CDCF"); Rn64("0xCAF21ECD4377B28C"); Rn64("0x57277707199B8175"); Rn64("0x506C11B9D90E8B1D");
Rn64("0xD83CC2687A19255F"); Rn64("0x4A29C6465A314CD1"); Rn64("0xED2DF21216235097"); Rn64("0xB5635C95FF7296E2");
Rn64("0x22AF003AB672E811"); Rn64("0x52E762596BF68235"); Rn64("0x9AEBA33AC6ECC6B0"); Rn64("0x944F6DE09134DFB6");
Rn64("0x6C47BEC883A7DE39"); Rn64("0x6AD047C430A12104"); Rn64("0xA5B1CFDBA0AB4067"); Rn64("0x7C45D833AFF07862");
Rn64("0x5092EF950A16DA0B"); Rn64("0x9338E69C052B8E7B"); Rn64("0x455A4B4CFE30E3F5"); Rn64("0x6B02E63195AD0CF8");
Rn64("0x6B17B224BAD6BF27"); Rn64("0xD1E0CCD25BB9C169"); Rn64("0xDE0C89A556B9AE70"); Rn64("0x50065E535A213CF6");
Rn64("0x9C1169FA2777B874"); Rn64("0x78EDEFD694AF1EED"); Rn64("0x6DC93D9526A50E68"); Rn64("0xEE97F453F06791ED");
Rn64("0x32AB0EDB696703D3"); Rn64("0x3A6853C7E70757A7"); Rn64("0x31865CED6120F37D"); Rn64("0x67FEF95D92607890");
Rn64("0x1F2B1D1F15F6DC9C"); Rn64("0xB69E38A8965C6B65"); Rn64("0xAA9119FF184CCCF4"); Rn64("0xF43C732873F24C13");
Rn64("0xFB4A3D794A9A80D2"); Rn64("0x3550C2321FD6109C"); Rn64("0x371F77E76BB8417E"); Rn64("0x6BFA9AAE5EC05779");
Rn64("0xCD04F3FF001A4778"); Rn64("0xE3273522064480CA"); Rn64("0x9F91508BFFCFC14A"); Rn64("0x049A7F41061A9E60");
Rn64("0xFCB6BE43A9F2FE9B"); Rn64("0x08DE8A1C7797DA9B"); Rn64("0x8F9887E6078735A1"); Rn64("0xB5B4071DBFC73A66");
Rn64("0x230E343DFBA08D33"); Rn64("0x43ED7F5A0FAE657D"); Rn64("0x3A88A0FBBCB05C63"); Rn64("0x21874B8B4D2DBC4F");
Rn64("0x1BDEA12E35F6A8C9"); Rn64("0x53C065C6C8E63528"); Rn64("0xE34A1D250E7A8D6B"); Rn64("0xD6B04D3B7651DD7E");
Rn64("0x5E90277E7CB39E2D"); Rn64("0x2C046F22062DC67D"); Rn64("0xB10BB459132D0A26"); Rn64("0x3FA9DDFB67E2F199");
Rn64("0x0E09B88E1914F7AF"); Rn64("0x10E8B35AF3EEAB37"); Rn64("0x9EEDECA8E272B933"); Rn64("0xD4C718BC4AE8AE5F");
Rn64("0x81536D601170FC20"); Rn64("0x91B534F885818A06"); Rn64("0xEC8177F83F900978"); Rn64("0x190E714FADA5156E");
Rn64("0xB592BF39B0364963"); Rn64("0x89C350C893AE7DC1"); Rn64("0xAC042E70F8B383F2"); Rn64("0xB49B52E587A1EE60");
Rn64("0xFB152FE3FF26DA89"); Rn64("0x3E666E6F69AE2C15"); Rn64("0x3B544EBE544C19F9"); Rn64("0xE805A1E290CF2456");
Rn64("0x24B33C9D7ED25117"); Rn64("0xE74733427B72F0C1"); Rn64("0x0A804D18B7097475"); Rn64("0x57E3306D881EDB4F");
Rn64("0x4AE7D6A36EB5DBCB"); Rn64("0x2D8D5432157064C8"); Rn64("0xD1E649DE1E7F268B"); Rn64("0x8A328A1CEDFE552C");
Rn64("0x07A3AEC79624C7DA"); Rn64("0x84547DDC3E203C94"); Rn64("0x990A98FD5071D263"); Rn64("0x1A4FF12616EEFC89");
Rn64("0xF6F7FD1431714200"); Rn64("0x30C05B1BA332F41C"); Rn64("0x8D2636B81555A786"); Rn64("0x46C9FEB55D120902");
Rn64("0xCCEC0A73B49C9921"); Rn64("0x4E9D2827355FC492"); Rn64("0x19EBB029435DCB0F"); Rn64("0x4659D2B743848A2C");
Rn64("0x963EF2C96B33BE31"); Rn64("0x74F85198B05A2E7D"); Rn64("0x5A0F544DD2B1FB18"); Rn64("0x03727073C2E134B1");
Rn64("0xC7F6AA2DE59AEA61"); Rn64("0x352787BAA0D7C22F"); Rn64("0x9853EAB63B5E0B35"); Rn64("0xABBDCDD7ED5C0860");
Rn64("0xCF05DAF5AC8D77B0"); Rn64("0x49CAD48CEBF4A71E"); Rn64("0x7A4C10EC2158C4A6"); Rn64("0xD9E92AA246BF719E");
Rn64("0x13AE978D09FE5557"); Rn64("0x730499AF921549FF"); Rn64("0x4E4B705B92903BA4"); Rn64("0xFF577222C14F0A3A");
Rn64("0x55B6344CF97AAFAE"); Rn64("0xB862225B055B6960"); Rn64("0xCAC09AFBDDD2CDB4"); Rn64("0xDAF8E9829FE96B5F");
Rn64("0xB5FDFC5D3132C498"); Rn64("0x310CB380DB6F7503"); Rn64("0xE87FBB46217A360E"); Rn64("0x2102AE466EBB1148");
Rn64("0xF8549E1A3AA5E00D"); Rn64("0x07A69AFDCC42261A"); Rn64("0xC4C118BFE78FEAAE"); Rn64("0xF9F4892ED96BD438");
Rn64("0x1AF3DBE25D8F45DA"); Rn64("0xF5B4B0B0D2DEEEB4"); Rn64("0x962ACEEFA82E1C84"); Rn64("0x046E3ECAAF453CE9");
Rn64("0xF05D129681949A4C"); Rn64("0x964781CE734B3C84"); Rn64("0x9C2ED44081CE5FBD"); Rn64("0x522E23F3925E319E");
Rn64("0x177E00F9FC32F791"); Rn64("0x2BC60A63A6F3B3F2"); Rn64("0x222BBFAE61725606"); Rn64("0x486289DDCC3D6780");
Rn64("0x7DC7785B8EFDFC80"); Rn64("0x8AF38731C02BA980"); Rn64("0x1FAB64EA29A2DDF7"); Rn64("0xE4D9429322CD065A");
Rn64("0x9DA058C67844F20C"); Rn64("0x24C0E332B70019B0"); Rn64("0x233003B5A6CFE6AD"); Rn64("0xD586BD01C5C217F6");
Rn64("0x5E5637885F29BC2B"); Rn64("0x7EBA726D8C94094B"); Rn64("0x0A56A5F0BFE39272"); Rn64("0xD79476A84EE20D06");
Rn64("0x9E4C1269BAA4BF37"); Rn64("0x17EFEE45B0DEE640"); Rn64("0x1D95B0A5FCF90BC6"); Rn64("0x93CBE0B699C2585D");
Rn64("0x65FA4F227A2B6D79"); Rn64("0xD5F9E858292504D5"); Rn64("0xC2B5A03F71471A6F"); Rn64("0x59300222B4561E00");
Rn64("0xCE2F8642CA0712DC"); Rn64("0x7CA9723FBB2E8988"); Rn64("0x2785338347F2BA08"); Rn64("0xC61BB3A141E50E8C");
Rn64("0x150F361DAB9DEC26"); Rn64("0x9F6A419D382595F4"); Rn64("0x64A53DC924FE7AC9"); Rn64("0x142DE49FFF7A7C3D");
Rn64("0x0C335248857FA9E7"); Rn64("0x0A9C32D5EAE45305"); Rn64("0xE6C42178C4BBB92E"); Rn64("0x71F1CE2490D20B07");
Rn64("0xF1BCC3D275AFE51A"); Rn64("0xE728E8C83C334074"); Rn64("0x96FBF83A12884624"); Rn64("0x81A1549FD6573DA5");
Rn64("0x5FA7867CAF35E149"); Rn64("0x56986E2EF3ED091B"); Rn64("0x917F1DD5F8886C61"); Rn64("0xD20D8C88C8FFE65F");
Rn64("0x31D71DCE64B2C310"); Rn64("0xF165B587DF898190"); Rn64("0xA57E6339DD2CF3A0"); Rn64("0x1EF6E6DBB1961EC9");
Rn64("0x70CC73D90BC26E24"); Rn64("0xE21A6B35DF0C3AD7"); Rn64("0x003A93D8B2806962"); Rn64("0x1C99DED33CB890A1");
Rn64("0xCF3145DE0ADD4289"); Rn64("0xD0E4427A5514FB72"); Rn64("0x77C621CC9FB3A483"); Rn64("0x67A34DAC4356550B");
Rn64("0xF8D626AAAF278509");


// We know it.
//   if ((Random64[RandomNb-1] ( >> ) 32) != 0xF8D626AA) { // upper half of the last element of the array
//      my_fatal("broken 64-bit types\n");
//   }

}

// end of random.cpp




// recog.cpp

//  functions

// recog_draw()

private function recog_draw( board:board_t ) :Boolean {

var mat_info:material_info_t = new material_info_t();  // material_info_t[1]
var ifelse :Boolean = false;

var me :int = 0;    // int
var opp :int = 0;   // int
var wp :int = 0;   // int
var wk :int = 0;   // int
var bk :int = 0;   // int
var wb :int = 0;   // int
var bb :int = 0;   // int


// material

if (board.piece_nb > 4) {
return false;
}

material_get_info(mat_info,board);

if ( ( mat_info.flags & DrawNodeFlag ) == 0) {
return false;
}

// recognisers


ifelse = true;
if (mat_info.recog == MAT_KK) {

// KK

return true;
}

if (mat_info.recog == MAT_KBK) {

// KBK (white)

return true;
}

if (mat_info.recog == MAT_KKB) {

// KBK (black)

return true;
}

if (mat_info.recog == MAT_KNK) {

// KNK (white)

return true;
}

if (mat_info.recog == MAT_KKN) {

// KNK (black)

return true;
}

if (mat_info.recog == MAT_KPK) {

// KPK (white)

me = White;
opp = COLOUR_OPP(me);

wp = board.pawn[me][0];
wk = KING_POS(board,me);
bk = KING_POS(board,opp);

if (SQUARE_FILE(wp) >= FileE) {
wp = SQUARE_FILE_MIRROR(wp);
wk = SQUARE_FILE_MIRROR(wk);
bk = SQUARE_FILE_MIRROR(bk);
}

if (kpk_draw(wp,wk,bk,board.turn)) {
return true;
}
ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KKP) {

// KPK (black)

me = Black;
opp = COLOUR_OPP(me);

wp = SQUARE_RANK_MIRROR(board.pawn[me][0]);
wk = SQUARE_RANK_MIRROR(KING_POS(board,me));
bk = SQUARE_RANK_MIRROR(KING_POS(board,opp));

if (SQUARE_FILE(wp) >= FileE) {
wp = SQUARE_FILE_MIRROR(wp);
wk = SQUARE_FILE_MIRROR(wk);
bk = SQUARE_FILE_MIRROR(bk);
}

if (kpk_draw(wp,wk,bk,COLOUR_OPP(board.turn))) {
return true;
}
ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KBKB) {

// KBKB

wb = board.piece[White][1];
bb = board.piece[Black][1];

if (SQUARE_COLOUR(wb) == SQUARE_COLOUR(bb)) {   // bishops on same colour
return true;
}
ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KBPK) {

// KBPK (white)

me = White;
opp = COLOUR_OPP(me);

wp = board.pawn[me][0];
wb = board.piece[me][1];
bk = KING_POS(board,opp);

if (SQUARE_FILE(wp) >= FileE) {
wp = SQUARE_FILE_MIRROR(wp);
wb = SQUARE_FILE_MIRROR(wb);
bk = SQUARE_FILE_MIRROR(bk);
}

if (kbpk_draw(wp,wb,bk)) {
return true;
}
ifelse = false;
}

if (ifelse && mat_info.recog == MAT_KKBP) {

// KBPK (black)

me = Black;
opp = COLOUR_OPP(me);

wp = SQUARE_RANK_MIRROR(board.pawn[me][0]);
wb = SQUARE_RANK_MIRROR(board.piece[me][1]);
bk = SQUARE_RANK_MIRROR(KING_POS(board,opp));

if (SQUARE_FILE(wp) >= FileE) {
wp = SQUARE_FILE_MIRROR(wp);
wb = SQUARE_FILE_MIRROR(wb);
bk = SQUARE_FILE_MIRROR(bk);
}

if (kbpk_draw(wp,wb,bk)) {
return true;
}
ifelse = false;
}

if (ifelse) {
//ASSERT(623, false);
}

return false;
}

// kpk_draw()

private function kpk_draw( wp:int, wk:int, bk:int, turn:int ) :Boolean {

var wp_file :int = 0;   // int
var wp_rank :int = 0;   // int
var wk_file :int = 0;   // int
var bk_file :int = 0;   // int
var bk_rank :int = 0;   // int
var ifelse :Boolean = false;

//ASSERT(624, SQUARE_IS_OK(wp));
//ASSERT(625, SQUARE_IS_OK(wk));
//ASSERT(626, SQUARE_IS_OK(bk));
//ASSERT(627, COLOUR_IS_OK(turn));

//ASSERT(628, SQUARE_FILE(wp)<=FileD);

wp_file = SQUARE_FILE(wp);
wp_rank = SQUARE_RANK(wp);

wk_file = SQUARE_FILE(wk);

bk_file = SQUARE_FILE(bk);
bk_rank = SQUARE_RANK(bk);

ifelse = true;
if (ifelse && (bk == wp+16)) {

if (wp_rank <= Rank6) {

return true;

} else { 

//ASSERT(629, wp_rank==Rank7);

if (COLOUR_IS_WHITE(turn)) {
if (wk == wp-15  ||  wk == wp-17) {
return true;
}
} else { 
if (wk != wp-15  &&  wk != wp-17) {
return true;
}
}
}
ifelse = false;
}

if (ifelse && (bk == wp+32)) {

if (wp_rank <= Rank5) {

return true;

} else { 

//ASSERT(630, wp_rank==Rank6);

if (COLOUR_IS_WHITE(turn)) {
if (wk != wp-1  &&  wk != wp+1) {
return true;
}
} else { 
return true;
}
}

ifelse = false;
}

if (ifelse && (wk == wp-1  ||  wk == wp+1)) {

if (bk == wk+32  &&  COLOUR_IS_WHITE(turn)) {    // opposition
return true;
}

ifelse = false;
}

if (ifelse && (wk == wp+15  ||  wk == wp+16  ||  wk == wp+17)) {

if (wp_rank <= Rank4) {
if (bk == wk+32  &&  COLOUR_IS_WHITE(turn)) {   // opposition
return true;
}
}
ifelse = false;
}

// rook pawn

if (wp_file == FileA) {

if (DISTANCE(bk,A8) <= 1) {
return true;
}

if (wk_file == FileA) {
if (wp_rank == Rank2) {
wp_rank = wp_rank + 1; // HACK
}
if (bk_file == FileC  &&  bk_rank > wp_rank) {
return true;
}
}
}

return false;

}

// kbpk_draw()

private function kbpk_draw ( wp:int, wb:int, bk:int ) :Boolean {

//ASSERT(631, SQUARE_IS_OK(wp));
//ASSERT(632, SQUARE_IS_OK(wb));
//ASSERT(633, SQUARE_IS_OK(bk));

if (SQUARE_FILE(wp) == FileA
&&  DISTANCE(bk,A8) <= 1
&&  SQUARE_COLOUR(wb) != SQUARE_COLOUR(A8)) {
return true;
}

return false;
}

// end of recog.cpp



// search.cpp

//  functions

// depth_is_ok()

private function depth_is_ok( depth:int ) :Boolean { 

return (depth > -128)  &&  (depth < DepthMax);
}

// height_is_ok()

private function height_is_ok( height:int ) :Boolean { 

return (height >= 0)  &&  (height < HeightMax);
}

// search_clear()

private function search_clear() :void {

// this.SearchInput

this.SearchInput.infinite = false;
this.SearchInput.depth_is_limited = false;
this.SearchInput.depth_limit = 0;
this.SearchInput.time_is_limited = false;
this.SearchInput.time_limit_1 = 0.0;
this.SearchInput.time_limit_2 = 0.0;

// this.SearchInfo

this.SearchInfo.can_stop = false;
this.SearchInfo.stop = false;
this.SearchInfo.check_nb = 10000;  // was 100000
this.SearchInfo.check_inc = 10000; // was 100000
this.SearchInfo.last_time = 0.0;

// this.SearchBest

this.SearchBest.move = MoveNone;
this.SearchBest.value = 0;
this.SearchBest.flags = SearchUnknown;
this.SearchBest.pv[0] = MoveNone;

// this.SearchRoot

this.SearchRoot.depth = 0;
this.SearchRoot.move = MoveNone;
this.SearchRoot.move_pos = 0;
this.SearchRoot.move_nb = 0;
this.SearchRoot.last_value = 0;
this.SearchRoot.bad_1 = false;
this.SearchRoot.bad_2 = false;
this.SearchRoot.change = false;
this.SearchRoot.easy = false;
this.SearchRoot.flag = false;

// this.SearchCurrent

this.SearchCurrent.mate = 0;
this.SearchCurrent.depth = 0;
this.SearchCurrent.max_depth = 0;
this.SearchCurrent.node_nb = 0;
this.SearchCurrent.time = 0.0;
this.SearchCurrent.speed = 0.0;
}

// search()

private function search() :void {

var move :int = MoveNone;    // int
var depth :int = 0;          // int

//ASSERT(634, board_is_ok(this.SearchInput.board));

// opening book

if (option_get_bool("OwnBook")  && (! this.SearchInput.infinite)) {

// no book here
// move = book_move(this.SearchInput.board);

if (move != MoveNone) {

// play book move

this.SearchBest.move = move;
this.SearchBest.value = 1;
this.SearchBest.flags = SearchExact;
this.SearchBest.depth = 1;
this.SearchBest.pv[0] = move;
this.SearchBest.pv[1] = MoveNone;

search_update_best();

return;
}
}

// this.SearchInput

gen_legal_moves(this.SearchInput.list,this.SearchInput.board);

if ( this.SearchInput.list.size <= 1) {
this.SearchInput.depth_is_limited = true;
this.SearchInput.depth_limit = 4;        // was 1
}

// this.SearchInfo

this.setjmp = false;
while(true) {	// setjmp loop


if (this.setjmp) {
this.setjmp = false;
//ASSERT(635, this.SearchInfo.can_stop);
//ASSERT(636, this.SearchBest.move!=MoveNone);
search_update_current();
return;
}

// this.SearchRoot

list_copy(this.SearchRoot.list,this.SearchInput.list);

// this.SearchCurrent

board_copy(this.SearchCurrent.board,this.SearchInput.board);
my_timer_reset(this.SearchCurrent.timer);
my_timer_start(this.SearchCurrent.timer);

// init

trans_inc_date(this.Trans);

sort_init1();
search_full_init(this.SearchRoot.list,this.SearchCurrent.board);

// iterative deepening

for (depth = 1; depth< DepthMax; depth++ ) {

if (DispDepthStart) {
send("info depth " + string_from_int(depth));
}

this.SearchRoot.bad_1 = false;
this.SearchRoot.change = false;

board_copy(this.SearchCurrent.board,this.SearchInput.board);

if (UseShortSearch  &&  depth <= ShortSearchDepth) {
search_full_root(this.SearchRoot.list,this.SearchCurrent.board,depth,SearchShort);
if (this.setjmp) {
break;
}
} else { 
search_full_root(this.SearchRoot.list,this.SearchCurrent.board,depth,SearchNormal);
if (this.setjmp) {
break;
}
}

search_update_current();

if (DispDepthEnd) {
send_ndtm(6);
}

// update search info

if (depth >= 1) {
this.SearchInfo.can_stop = true;
}

if (depth == 1
&&  this.SearchRoot.list.size >= 2
&&  this.SearchRoot.list.value[0] >= this.SearchRoot.list.value[1] + EasyThreshold) {
this.SearchRoot.easy = true;
}

if (UseBad  &&  depth > 1) {
this.SearchRoot.bad_2 = this.SearchRoot.bad_1;
this.SearchRoot.bad_1 = false;
//ASSERT(637, this.SearchRoot.bad_2==(this.SearchBest.value<=this.SearchRoot.last_value-BadThreshold));
}

this.SearchRoot.last_value = this.SearchBest.value;

// stop search?

if (this.SearchInput.depth_is_limited
&&  depth >= this.SearchInput.depth_limit) {
this.SearchRoot.flag = true;
}

if (this.SearchInput.time_is_limited
&&  this.SearchCurrent.time >= this.SearchInput.time_limit_1
&&  (! this.SearchRoot.bad_2)) {
this.SearchRoot.flag = true;
}

if (UseEasy
&&  this.SearchInput.time_is_limited
&&  this.SearchCurrent.time >= this.SearchInput.time_limit_1 * EasyRatio
&&  this.SearchRoot.easy) {
//ASSERT(638, ! this.SearchRoot.bad_2);
//ASSERT(639, ! this.SearchRoot.change);
this.SearchRoot.flag = true;
}

if (UseEarly
&&  this.SearchInput.time_is_limited
&&  this.SearchCurrent.time >= this.SearchInput.time_limit_1 * EarlyRatio
&&  (! this.SearchRoot.bad_2)
&&  (! this.SearchRoot.change)) {
this.SearchRoot.flag = true;
}

if (this.SearchInfo.can_stop
&&  (this.SearchInfo.stop  ||  (this.SearchRoot.flag  &&  (! this.SearchInput.infinite)))) {
return;
}
}

}	// setjmp loop

}

// search_update_best()

private function search_update_best() :void {

var move:int = 0;   // int
var value:int = 0;   // int
var flags:int = 0;   // int
var depth:int = 0;   // int
var max_depth:int = 0;   // int
var pv:Array = [];
var time:Number = 0.0;
var node_nb :int = 0;                  // sint64
var mate :int = 0;                     // int
var move_string:string_t = new string_t()     // string
var pv_string:string_t = new string_t()       // string

search_update_current();

if (DispBest) {

move = this.SearchBest.move;
value = this.SearchBest.value;
flags = this.SearchBest.flags;
depth = this.SearchBest.depth;
pv = this.SearchBest.pv;

max_depth = this.SearchCurrent.max_depth;
time = this.SearchCurrent.time;
node_nb = this.SearchCurrent.node_nb;

move_to_string(move,move_string);
pv_to_string(pv,pv_string);

mate = value_to_mate(value);
this.SearchCurrent.mate = mate;

if (mate == 0) {

// normal evaluation

if (flags == SearchExact) {
send_ndtm(10);
} else { 
if (flags == SearchLower) {
send_ndtm(11);
} else { 
if (flags == SearchUpper) {
send_ndtm(12);
}
}
}

} else { 

// mate announcement

if (flags == SearchExact) {
send_ndtm(20);
} else { 
if (flags == SearchLower) {
send_ndtm(21);
} else { 
if (flags == SearchUpper) {
send_ndtm(22);
}
}
}

}
}

// update time-management info

if (UseBad  &&  this.SearchBest.depth > 1) {
if (this.SearchBest.value <= this.SearchRoot.last_value - BadThreshold) {
this.SearchRoot.bad_1 = true;
this.SearchRoot.easy = false;
this.SearchRoot.flag = false;
} else { 
this.SearchRoot.bad_1 = false;
}
}

}

// search_update_root()

private function search_update_root() :void {

var move :int = 0;       // int
var move_pos :int = 0;   // int

var move_string:string_t = new string_t()  // string

if (DispRoot) {

search_update_current();

if (this.SearchCurrent.time >= 1.0) {

move = this.SearchRoot.move;
move_pos = this.SearchRoot.move_pos;

move_to_string(move,move_string);

send("info currmove " + move_string.v + " currmovenumber "+ string_from_int(move_pos+1));
}

}
}

// search_update_current()

private function search_update_current() :void {

var timer:my_timer_t = new my_timer_t();
var node_nb:int = 0;
var etime:Number = 0.0;
var speed:Number = 0.0;

timer = this.SearchCurrent.timer;
node_nb = this.SearchCurrent.node_nb;

etime = my_timer_elapsed_real(timer);
speed = (etime >= 1.0 ? node_nb / etime : 0.0 );

this.SearchCurrent.time = etime;
this.SearchCurrent.speed = speed;

}

// search_check()

private function search_check()  :void {

// search_send_stat();

// event();

if (this.SearchInput.depth_is_limited
&&  this.SearchRoot.depth > this.SearchInput.depth_limit) {
this.SearchRoot.flag = true;
}

if (this.SearchInput.time_is_limited
&&  this.SearchCurrent.time >= this.SearchInput.time_limit_2) {
this.SearchRoot.flag = true;
}

if (this.SearchInput.time_is_limited
&&  this.SearchCurrent.time >= this.SearchInput.time_limit_1
&&  (! this.SearchRoot.bad_1)
&&  (! this.SearchRoot.bad_2)
&&  ((! UseExtension ) ||  this.SearchRoot.move_pos == 0)) {
this.SearchRoot.flag = true;
}

if (this.SearchInfo.can_stop
&&  (this.SearchInfo.stop  ||  (this.SearchRoot.flag  &&  (! this.SearchInput.infinite)))) {
this.setjmp = true;  // the same as  longjmp(this.SearchInfo.buf,1);
}

}

// search_send_stat()

private function search_send_stat()  :void {

var node_nb:int = 0;
var time:Number = 0.0;
var speed:Number = 0.0;

search_update_current();

if (DispStat  &&  this.SearchCurrent.time >= this.SearchInfo.last_time + 1.0) {  // at least one-second gap

this.SearchInfo.last_time = this.SearchCurrent.time;

time = this.SearchCurrent.time;
speed = this.SearchCurrent.speed;
node_nb = this.SearchCurrent.node_nb;

send_ndtm(3);

trans_stats(this.Trans);
}

}

// end of search.cpp



// search_full.cpp

//  functions

// search_full_init()

private function search_full_init( list:list_t, board:board_t ): void { 

var str1 :String = "";     // string
var tmove :int = 0;     // int

//ASSERT(640, list_is_ok(list));
//ASSERT(641, board_is_ok(board));

// null-move options

str1 = option_get_string("nullMove Pruning");

if (string_equal(str1,"Always")) {
this.Usenull = true;
this.UsenullEval = false;
} else { 
if (string_equal(str1,"Fail High")) {
this.Usenull = true;
this.UsenullEval = true;
} else { 
if (string_equal(str1,"Never")) {
this.Usenull = false;
this.UsenullEval = false;
} else { 
//ASSERT(642, false);
this.Usenull = true;
this.UsenullEval = true;
}
}
}

this.nullReduction = option_get_int("nullMove Reduction");

str1 = option_get_string("Verification Search");

if (string_equal(str1,"Always")) {
this.UseVer = true;
this.UseVerEndgame = false;
} else { 
if (string_equal(str1,"endgame")) {
this.UseVer = true;
this.UseVerEndgame = true;
} else { 
if (string_equal(str1,"Never")) {
this.UseVer = false;
this.UseVerEndgame = false;
} else { 
//ASSERT(643, false);
this.UseVer = true;
this.UseVerEndgame = true;
}
}
}

this.VerReduction = option_get_int("Verification Reduction");

// history-pruning options

this.UseHistory = option_get_bool("History Pruning");
this.HistoryValue = (option_get_int("History Threshold") * 16384 + 50) / 100;

// futility-pruning options

this.UseFutility = option_get_bool("Futility Pruning");
this.FutilityMargin = option_get_int("Futility Margin");

// delta-pruning options

this.UseDelta = option_get_bool("Delta Pruning");
this.DeltaMargin = option_get_int("Delta Margin");

// quiescence-search options

this.CheckNb = option_get_int("Quiescence Check Plies");
this.CheckDepth = 1 - this.CheckNb;

// standard sort

list_note(list);
list_sort(list);

// basic sort

tmove = MoveNone;
if (UseTrans) {
trans_retrieve(this.Trans, board.key, this.TransRv);
tmove = this.TransRv.trans_move;
}

note_moves(list,board,0,tmove);
list_sort(list);
}

// search_full_root()

private function search_full_root( list:list_t, board:board_t, depth:int, search_type:int ) :int {

var value :int = 0;   // int

//ASSERT(644, list_is_ok(list));
//ASSERT(645, board_is_ok(board));
//ASSERT(646, depth_is_ok(depth));
//ASSERT(647, search_type==SearchNormal || search_type==SearchShort);

//ASSERT(648, list==this.SearchRoot.list);
//ASSERT(649, ! (list.size==0));
//ASSERT(650, board==this.SearchCurrent.board);
//ASSERT(651, board_is_legal(board));
//ASSERT(652, depth>=1);

value = full_root(list,board,-ValueInf, ValueInf,depth,0,search_type);
if( this.setjmp ) {
return 0;
}

//ASSERT(653, value_is_ok(value));
//ASSERT(654, list.value[0]==value);

return value;
}

// full_root()

private function full_root( list:list_t, board:board_t, alpha:int, beta:int, depth:int, height:int, search_type:int ) :int {

var old_alpha :int = 0;    // int
var value :int = 0;        // int
var best_value :int = 0;   // int
var i :int = 0;            // int
var move :int = 0;         // int
var new_depth:int ;        // int
var undo:undo_t = new undo_t();  // undo_t[1]
var new_pv :Array = [];      // int[HeightMax];

//ASSERT(655, list_is_ok(list));
//ASSERT(656, board_is_ok(board));
//ASSERT(657, range_is_ok(alpha,beta));
//ASSERT(658, depth_is_ok(depth));
//ASSERT(659, height_is_ok(height));
//ASSERT(660, search_type==SearchNormal || search_type==SearchShort);

//ASSERT(661, list.size==this.SearchRoot.list.size);
//ASSERT(662, ! (list.size==0));
//ASSERT(663, board.key==this.SearchCurrent.board.key);
//ASSERT(664, board_is_legal(board));
//ASSERT(665, depth>=1);

// init

this.SearchCurrent.node_nb = this.SearchCurrent.node_nb + 1;
this.SearchInfo.check_nb = this.SearchInfo.check_nb - 1;

for (i = 0; i< list.size; i++ ) {
list.value[i] = ValueNone;
}

old_alpha = alpha;
best_value = ValueNone;

// move loop

for (i = 0; i< list.size; i++ ) {

move = list.move[i];

this.SearchRoot.depth = depth;
this.SearchRoot.move = move;
this.SearchRoot.move_pos = i;
this.SearchRoot.move_nb = list.size;

search_update_root();

new_depth = full_new_depth(depth,move,board,board_is_check(board) && list.size==1,true);

move_do(board,move,undo);

if (search_type == SearchShort  ||  best_value == ValueNone) {   // first move
value = -full_search(board,-beta,-alpha,new_depth,height+1,new_pv,NodePV);
if( this.setjmp ) {
return 0;
}
} else { // other moves
value = -full_search(board,-alpha-1,-alpha,new_depth,height+1,new_pv,NodeCut);
if( this.setjmp ) {
return 0;
}
if (value > alpha) {   //  &&  value < beta
this.SearchRoot.change = true;
this.SearchRoot.easy = false;
this.SearchRoot.flag = false;
search_update_root();
value = -full_search(board,-beta,-alpha,new_depth,height+1,new_pv,NodePV);
if( this.setjmp ) {
return 0;
}
}
}

move_undo(board,move,undo);

if (value <= alpha) {    // upper bound
list.value[i] = old_alpha;
} else { 
if (value >= beta) {    // lower bound
list.value[i] = beta;
} else {      // alpha < value < beta => exact value
list.value[i] = value;
}
}

if (value > best_value  &&  (best_value == ValueNone  ||  value > alpha)) {

this.SearchBest.move = move;
this.SearchBest.value = value;
if (value <= alpha) {    // upper bound
this.SearchBest.flags = SearchUpper;
} else { 
if (value >= beta) {    // lower bound
this.SearchBest.flags = SearchLower;
} else {   // alpha < value < beta => exact value
this.SearchBest.flags = SearchExact;
}
}
this.SearchBest.depth = depth;

//unshift is faster, but not used here
pv_cat(this.SearchBest.pv, new_pv, move);

search_update_best();
}

if (value > best_value) {
best_value = value;
if (value > alpha) {
if (search_type == SearchNormal) {
alpha = value;
}
if (value >= beta) {
break;
}
}
}
}

//ASSERT(666, value_is_ok(best_value));

list_sort(list);

//ASSERT(667, this.SearchBest.move==list.move[0]);
//ASSERT(668, this.SearchBest.value==best_value);

if (UseTrans  &&  best_value > old_alpha  &&  best_value < beta) {
pv_fill(this.SearchBest.pv, 0, board);
}

return best_value;

}

// full_search()

private function full_search( board:board_t, alpha:int, beta:int, depth:int, height:int, pv:Array, node_type:int ) :int {

var in_check :Boolean = false;       // bool
var single_reply :Boolean = false;   // bool
var tmove :int = 0;       // int
var tdepth :int = 0;      // int

var min_value :int = 0;   // int
var max_value :int = 0;   // int
var old_alpha :int = 0;   // int
var value :int = 0;       // int
var best_value :int = 0;  // int

var bmove :int_t = new int_t(); // int
var move :int = 0;        // int

var best_move :int = 0;   // int
var new_depth :int = 0;   // int
var played_nb :int = 0;   // int
var i :int = 0;           // int
var opt_value :int = 0;   // int
var reduced :Boolean = false;      // bool
var attack:attack_t = new attack_t();  // attack_t[1]
var sort:sort_t = new sort_t();      // sort_t[1]
var undo:undo_t = new undo_t();      // undo_t[1]
var new_pv :Array = [];          // int[HeightMax]
var played :Array = [];          // int[256]
var gotocut :Boolean = false;
var cont :Boolean = false;

//ASSERT(670, range_is_ok(alpha,beta));
//ASSERT(671, depth_is_ok(depth));
//ASSERT(672, height_is_ok(height));

//ASSERT(674, node_type==NodePV || node_type==NodeCut || node_type==NodeAll);

//ASSERT(675, board_is_legal(board));

// horizon?

if (depth <= 0) {
return full_quiescence(board,alpha,beta,0,height,pv);
}

// init

this.SearchCurrent.node_nb = this.SearchCurrent.node_nb + 1;
this.SearchInfo.check_nb = this.SearchInfo.check_nb - 1;
pv[0] = MoveNone;

if (height > this.SearchCurrent.max_depth) {
this.SearchCurrent.max_depth = height;
}

if (this.SearchInfo.check_nb <= 0) {
this.SearchInfo.check_nb = this.SearchInfo.check_nb + this.SearchInfo.check_inc;
search_check();
if( this.setjmp ) {
return 0;
}
}

// draw?

if (board_is_repetition(board)  ||  recog_draw(board)) {
return ValueDraw;
}

// mate-distance pruning

if (UseDistancePruning) {

// lower bound

value = (height+2-ValueMate); // does not work if the current position is mate
if (value > alpha  &&  board_is_mate(board)) {
value = (height-ValueMate);
}

if (value > alpha) {
alpha = value;
if (value >= beta) {
return value;
}
}

// upper bound

value = -(height+1-ValueMate);

if (value < beta) {
beta = value;
if (value <= alpha) {
return value;
}
}
}

// transposition table

tmove = MoveNone;

if (UseTrans  &&  depth >= TransDepth) {

if( trans_retrieve(this.Trans, board.key, this.TransRv)) {

tmove = this.TransRv.trans_move;

// trans_move is now updated

if (node_type != NodePV) {

if (UseMateValues) {

if (this.TransRv.trans_min_value > ValueEvalInf  &&  this.TransRv.trans_min_depth < depth) {
this.TransRv.trans_min_depth = depth;
}

if (this.TransRv.trans_max_value < -ValueEvalInf  &&  this.TransRv.trans_max_depth < depth) {
this.TransRv.trans_max_depth = depth;
}
}

min_value = -ValueInf;

if ( this.TransRv.trans_min_depth >= depth ) {
min_value = value_from_trans(this.TransRv.trans_min_value,height);
if (min_value >= beta) {
return min_value;
}
}

max_value = ValueInf;

if ( this.TransRv.trans_max_depth >= depth ) {
max_value = value_from_trans(this.TransRv.trans_max_value,height);
if (max_value <= alpha) {
return max_value;
}
}

if (min_value == max_value) {
return min_value; // exact match
}
}
}
}

// height limit

if (height >= HeightMax-1) {
return evalpos(board);
}

// more init

old_alpha = alpha;
best_value = ValueNone;
best_move = MoveNone;
played_nb = 0;

attack_set(attack,board);
in_check = ATTACK_IN_CHECK(attack);

// null-move pruning

if (this.Usenull  &&  depth >=nullDepth  &&  node_type != NodePV) {

if ((! in_check)
&&  (! value_is_mate(beta))
&&  do_null(board)
&&  ((! this.UsenullEval ) ||  depth <=nullReduction+1  ||  evalpos(board) >= beta)) {

// null-move search

new_depth = depth - this.nullReduction - 1;

move_do_null(board,undo);
value = -full_search(board,-beta,-beta+1,new_depth,height+1,new_pv,-node_type);
if( this.setjmp ) {
return 0;
}
move_undo_null(board,undo);

// verification search

if (this.UseVer  &&  depth > this.VerReduction) {

if (value >= beta  &&  ((! this.UseVerEndgame)  ||  do_ver(board))) {

new_depth = depth - this.VerReduction;
//ASSERT(676, new_depth>0);

value = full_no_null(board,alpha,beta,new_depth,height,new_pv,NodeCut,tmove, bmove);
move = bmove.v;

if( this.setjmp ) {
return 0;
}
if (value >= beta) {
//ASSERT(677, move==new_pv[0]);
played[played_nb] = move;
played_nb = played_nb + 1;
best_move = move;
best_value = value;

// slice is faster
// pv_copy(pv,new_pv);
new_pv = pv.slice(); 


gotocut = true;
}
}
}

// pruning

if ((! gotocut) && value >= beta) {

if (value > ValueEvalInf) {
value = ValueEvalInf; // do not return unproven mates
}
//ASSERT(678, ! value_is_mate(value));

// pv_cat(pv,new_pv,Movenull);

best_move = MoveNone;
best_value = value;
gotocut = true;
}
}
}

if(! gotocut) {  // [1]

// Internal Iterative Deepening

if (UseIID  &&  depth >= IIDDepth  &&  node_type == NodePV  &&  tmove == MoveNone) {

new_depth = depth - IIDReduction;
//ASSERT(679, new_depth>0);

value = full_search(board,alpha,beta,new_depth,height,new_pv,node_type);
if( this.setjmp ) {
return 0;
}
if (value <= alpha) {
value = full_search(board,-ValueInf,beta,new_depth,height,new_pv,node_type);
if( this.setjmp ) {
return 0;
}
}

tmove = new_pv[0];
}

// move generation

sort_init2(sort,board,attack,depth,height,tmove);

single_reply = false;
if (in_check  &&  sort.list.size == 1) {
single_reply = true; // HACK
}

// move loop

opt_value = ValueInf;

while(true) {

move = sort_next(sort);
if(move == MoveNone) {
break
}

// extensions

new_depth = full_new_depth(depth,move,board,single_reply,node_type==NodePV);

// history pruning

reduced = false;

if (this.UseHistory  &&  depth >= HistoryDepth  &&  node_type != NodePV) {
if ((! in_check)  &&  played_nb >= HistoryMoveNb  &&  new_depth < depth) {
//ASSERT(680, best_value!=ValueNone);
//ASSERT(681, played_nb>0);
//ASSERT(682, sort.pos>0 && move==sort.list.move[sort.pos-1]);
value = sort.value; // history score
if (value < this.HistoryValue) {
//ASSERT(683, value>=0 && value<16384);
//ASSERT(684, move!=tmove);
//ASSERT(685, ! move_is_tactical(move,board));
//ASSERT(686, ! move_is_check(move,board));
new_depth = new_depth - 1;
reduced = true;
}
}
}

// futility pruning

if (this.UseFutility  &&  depth == 1  &&  node_type != NodePV) {

if ((! in_check)  &&  new_depth == 0  &&  (! move_is_tactical(move,board))
&&  (! move_is_dangerous(move,board))) {

//ASSERT(687, ! move_is_check(move,board));

// optimistic evaluation

if (opt_value == ValueInf) {
opt_value = evalpos(board) + this.FutilityMargin;
//ASSERT(688, opt_value<ValueInf);
}

value = opt_value;

// pruning

if (value <= alpha) {

if (value > best_value) {
best_value = value;
pv[0] = MoveNone;
}

cont = true;
}
}
}

if(cont) {  // continue [1]
cont = false;
} else { 

// recursive search

move_do(board,move,undo);

if (node_type != NodePV  ||  best_value == ValueNone) {    // first move
value = -full_search(board,-beta,-alpha,new_depth,height+1,new_pv,-node_type);
if( this.setjmp ) {
return 0;
}
} else {    // other moves
value = -full_search(board,-alpha-1,-alpha,new_depth,height+1,new_pv,NodeCut);
if( this.setjmp ) {
return 0;
}
if (value > alpha) {    //  &&  value < beta
value = -full_search(board,-beta,-alpha,new_depth,height+1,new_pv,NodePV);
if( this.setjmp ) {
return 0;
}
}
}

// history-pruning re-search

if (HistoryReSearch  &&  reduced  &&  value >= beta) {

//ASSERT(689, node_type!=NodePV);

new_depth = new_depth + 1;
//ASSERT(690, new_depth==depth-1);

value = -full_search(board,-beta,-alpha,new_depth,height+1,new_pv,-node_type);
if( this.setjmp ) {
return 0;
}
}

move_undo(board,move,undo);

played[played_nb] = move;
played_nb = played_nb + 1;

if (value > best_value) {
best_value = value;
pv_cat(pv,new_pv,move);
if (value > alpha) {
alpha = value;
best_move = move;
if (value >= beta) {
gotocut = true;
break;
}
}
}

if (node_type == NodeCut) {
node_type = NodeAll;
}

}  // continue [1]

}


if(! gotocut) {  // [2]

// ALL node

if (best_value == ValueNone) {    // no legal move
if (in_check) {
//ASSERT(691, board_is_mate(board));
return (height-ValueMate);
} else { 
//ASSERT(692, board_is_stalemate(board));
return ValueDraw;
}
}

} // goto cut [2]
} // goto cut [1]

// cut:

//ASSERT(693, value_is_ok(best_value));

// move ordering

if (best_move != MoveNone) {

good_move(best_move,board,depth,height);

if (best_value >= beta  &&  (! move_is_tactical(best_move,board))) {

//ASSERT(694, played_nb>0 && played[played_nb-1]==best_move);

for (i = 0; i<= played_nb-2; i++ ) {
move = played[i];
//ASSERT(695, move!=best_move);
history_bad(move,board);
}

history_good(best_move,board);
}
}

// transposition table

if (UseTrans  &&  depth >= TransDepth) {

tmove = best_move;
tdepth = depth;
this.TransRv.trans_min_value = ( best_value > old_alpha ?  value_to_trans(best_value,height) : -ValueInf );
this.TransRv.trans_max_value = ( best_value < beta ? value_to_trans(best_value,height) : ValueInf );

trans_store(this.Trans,board.key, tmove, tdepth, this.TransRv);
}

return best_value;

}


// full_no_null()

private function full_no_null( board:board_t, alpha:int,  beta:int, depth:int, height:int, pv:Array, node_type:int, tmove:int,  b_move:int_t ) :int {

var value :int = 0;            // int
var best_value :int = 0;       // int
var move :int = 0;             // int
var new_depth :int = 0;        // int

var attack:attack_t = new attack_t();  // attack_t[1]
var sort:sort_t = new sort_t();      // sort_t[1]
var undo:undo_t = new undo_t();      // undo_t[1]
var new_pv :Array = [];          // int[HeightMax]
var gotocut :Boolean = false;

//ASSERT(697, range_is_ok(alpha,beta));
//ASSERT(698, depth_is_ok(depth));
//ASSERT(699, height_is_ok(height));
//ASSERT(701, node_type==NodePV || node_type==NodeCut || node_type==NodeAll);
//ASSERT(702, tmove==MoveNone || move_is_ok(tmove));

//ASSERT(704, board_is_legal(board));
//ASSERT(705, ! board_is_check(board));
//ASSERT(706, depth>=1);

// init

this.SearchCurrent.node_nb = this.SearchCurrent.node_nb + 1;
this.SearchInfo.check_nb = this.SearchInfo.check_nb - 1;
pv[0] = MoveNone;

if (height > this.SearchCurrent.max_depth) {
this.SearchCurrent.max_depth = height;
}

if (this.SearchInfo.check_nb <= 0) {
this.SearchInfo.check_nb = this.SearchInfo.check_nb + this.SearchInfo.check_inc;
search_check();
if( this.setjmp ) {
return 0;
}
}

attack_set(attack,board);
//ASSERT(707, ! ATTACK_IN_CHECK(attack));

b_move.v = MoveNone;
best_value = ValueNone;

// move loop

sort_init2(sort,board,attack,depth,height,tmove);


while(true) {

move = sort_next(sort);
if(move == MoveNone) {
break
}

new_depth = full_new_depth(depth,move,board,false,false);

move_do(board,move,undo);
value = -full_search(board,-beta,-alpha,new_depth,height+1,new_pv,-node_type);
if( this.setjmp ) {
return 0;
}
move_undo(board,move,undo);

if (value > best_value) {
best_value = value;
pv_cat(pv,new_pv,move);
if (value > alpha) {
alpha = value;
b_move.v = move;
if (value >= beta) {
gotocut = true;
break;
}
}
}

}

if(! gotocut) {  // [1]

// ALL node

if (best_value == ValueNone) {     // no legal move => stalemate
//ASSERT(708, board_is_stalemate(board));
best_value = ValueDraw;
}

} // goto cut [1]

// cut:

//ASSERT(709, value_is_ok(best_value));

return best_value;

}

// full_quiescence()

private function full_quiescence( board:board_t, alpha:int, beta:int, depth:int, height:int, pv:Array ) :int { 

var in_check :Boolean = false;     // bool
var old_alpha :int = 0;        // int

var value :int = 0;            // int
var best_value :int = 0;       // int
var best_move :int = 0;       // int
var opt_value :int = 0;        // int
var move :int = 0;             // int

var to :int = 0;               // int
var capture :int = 0;          // int

var attack:attack_t = new attack_t();  // attack_t[1]
var sort:sort_t = new sort_t();      // sort_t[1]
var undo:undo_t = new undo_t();      // undo_t[1]
var new_pv:Array = [];          // int[HeightMax]

var gotocut :Boolean = false;
var cont :Boolean = false;

//ASSERT(711, range_is_ok(alpha,beta));
//ASSERT(712, depth_is_ok(depth));
//ASSERT(713, height_is_ok(height));

//ASSERT(715, board_is_legal(board));
//ASSERT(716, depth<=0);

// init

this.SearchCurrent.node_nb = this.SearchCurrent.node_nb + 1;
this.SearchInfo.check_nb = this.SearchInfo.check_nb - 1;
pv[0] = MoveNone;

if (height > this.SearchCurrent.max_depth) {
this.SearchCurrent.max_depth = height;
}

if (this.SearchInfo.check_nb <= 0) {
this.SearchInfo.check_nb = this.SearchInfo.check_nb + this.SearchInfo.check_inc;
search_check();
if( this.setjmp ) {
return 0;
}
}

// draw?

if (board_is_repetition(board)  ||  recog_draw(board)) {
return ValueDraw;
}

// mate-distance pruning

if (UseDistancePruning) {

// lower bound

value = (height+2-ValueMate); // does not work if the current position is mate
if (value > alpha  &&  board_is_mate(board)) {
value = (height-ValueMate);
}

if (value > alpha) {
alpha = value;
if (value >= beta) {
return value;
}
}

// upper bound

value = -(height+1-ValueMate);

if (value < beta) {
beta = value;
if (value <= alpha) {
return value;
}
}
}

// more init

attack_set(attack,board);
in_check = ATTACK_IN_CHECK(attack);

if (in_check) {
//ASSERT(717, depth<0);
depth = depth + 1; // in-check extension
}

// height limit

if (height >= HeightMax-1) {
return evalpos(board);
}

// more init

old_alpha = alpha;
best_value = ValueNone;
best_move = MoveNone;

// if (this.UseDelta)
opt_value = ValueInf;

if (! in_check) {

// lone-king stalemate?

if (simple_stalemate(board)) {
return ValueDraw;
}

// stand pat

value = evalpos(board);

//ASSERT(718, value>best_value);
best_value = value;
if (value > alpha) {
alpha = value;
if (value >= beta) {
gotocut = true;
}
}

if ((! gotocut) && this.UseDelta) {
opt_value = value + this.DeltaMargin;
//ASSERT(719, opt_value<ValueInf);
}
}

if(! gotocut) {  // [1]

// move loop

sort_init_qs(sort,board,attack,depth>=this.CheckDepth);


while(true) {

move = sort_next_qs(sort);
if(move == MoveNone) {
break
}


// delta pruning

if (this.UseDelta  &&  beta == old_alpha+1) {

if ((! in_check) && (! move_is_check(move,board)) && (! capture_is_dangerous(move,board))) {

//ASSERT(720, move_is_tactical(move,board));

// optimistic evaluation

value = opt_value;

to = MOVE_TO(move);
capture = board.square[to];

if (capture != Empty) {
value = value + this.ValuePiece[capture];
} else { 
if (MOVE_IS_EN_PASSANT(move)) {
value = value + ValuePawn;
}
}

if (MOVE_IS_PROMOTE(move)) {
value = value + ValueQueen - ValuePawn;
}

// pruning

if (value <= alpha) {

if (value > best_value) {
best_value = value;
pv[0] = MoveNone;
}

cont = true;
}
}
}

if(cont) {  // continue [1]
cont = false;
} else { 

move_do(board,move,undo);
value = -full_quiescence(board,-beta,-alpha,depth-1,height+1,new_pv);
if( this.setjmp ) {
return 0;
}
move_undo(board,move,undo);

if (value > best_value) {
best_value = value;
pv_cat(pv,new_pv,move);
if (value > alpha) {
alpha = value;
best_move = move;
if (value >= beta) {
gotocut = true;
break;
}
}
}

}  // continue [1]

}

if(! gotocut) {  // [2]

// ALL node

if (best_value == ValueNone) {        // no legal move
//ASSERT(721, board_is_mate(board));
return (height-ValueMate);
}

} // goto cut [2]
} // goto cut [1]

// cut:

//ASSERT(722, value_is_ok(best_value));

return best_value;

}

// full_new_depth()

private function full_new_depth( depth:int, move:int, board:board_t, single_reply:Boolean, in_pv:Boolean ) :int {
var new_depth :int = 0;   // int
var b :Boolean = false;       // bool

//ASSERT(723, depth_is_ok(depth));
//ASSERT(724, move_is_ok(move));

//ASSERT(728, depth>0);

new_depth = depth - 1;

b = b || (single_reply  &&  ExtendSingleReply);
b = b || (in_pv  &&  MOVE_TO(move) == board.cap_sq &&  see_move(move,board) > 0)  // recapture
b = b || (in_pv  &&  PIECE_IS_PAWN(MOVE_PIECE(move,board))
&&  PAWN_RANK(MOVE_TO(move),board.turn) == Rank7
&&  see_move(move,board) >= 0);
b = b || move_is_check(move,board);
if(b) {
new_depth = new_depth + 1;
}

//ASSERT(729, new_depth>=0 && new_depth<=depth);

return new_depth;
}

// do_null()

private function do_null( board:board_t ) :Boolean {


// use null move if the side-to-move has at least one piece

return (board.piece_size[board.turn] >= 2); // king + one piece
}

// do_ver()

private function do_ver( board:board_t ) :Boolean {

// use verification if the side-to-move has at most one piece

return (board.piece_size[board.turn] <= 2); // king + one piece
}

// pv_fill()

private function pv_fill( pv:Array, at:int, board:board_t ) :void {

var move :int = 0;   // int
var tmove :int = 0;  // int
var tdepth :int = 0; // int

var undo:undo_t = new undo_t();      // undo_t[1]

//ASSERT(734, UseTrans);

move = pv[at];

if (move != MoveNone  &&  move != Movenull) {

move_do(board,move,undo);
pv_fill(pv, at+1,board);
move_undo(board,move,undo);

tmove = move;
tdepth = -127; // HACK
this.TransRv.trans_min_value = -ValueInf;
this.TransRv.trans_max_value = ValueInf;

trans_store(this.Trans, board.key, tmove, tdepth, this.TransRv);
}
}

// move_is_dangerous()

private function move_is_dangerous( move:int, board:board_t ) :Boolean {

var piece :int = 0;   // int

//ASSERT(735, move_is_ok(move));

//ASSERT(737, ! move_is_tactical(move,board));

piece = MOVE_PIECE(move,board);

if (PIECE_IS_PAWN(piece) &&  PAWN_RANK(MOVE_TO(move),board.turn) >= Rank7) {
return true;
}

return false;
}

// capture_is_dangerous()

private function capture_is_dangerous( move:int, board:board_t ) :Boolean {

var piece :int = 0;     // int
var capture :int = 0;   // int

//ASSERT(738, move_is_ok(move));

//ASSERT(740, move_is_tactical(move,board));

piece = MOVE_PIECE(move,board);

if (PIECE_IS_PAWN(piece) &&  PAWN_RANK(MOVE_TO(move),board.turn) >= Rank7) {
return true;
}

capture = move_capture(move,board);

if (PIECE_IS_QUEEN(capture)) {
return true;
}

if (PIECE_IS_PAWN(capture) &&  PAWN_RANK(MOVE_TO(move),board.turn) <= Rank2) {
return true;
}

return false;
}

// simple_stalemate()

private function simple_stalemate( board:board_t ) :Boolean {

var me :int = 0          // int
var opp :int = 0;        // int
var king :int = 0;       // int
var opp_flag :int = 0;   // int
var from :int = 0;       // int
var to :int = 0;         // int
var capture :int = 0;    // int
var inc_ptr :int = 0;    // int
var inc :int = 0;        // int

//ASSERT(742, board_is_legal(board));
//ASSERT(743, ! board_is_check(board));

// lone king?

me = board.turn;
if (board.piece_size[me] != 1  ||  board.pawn_size[me] != 0) {
return false; // no
}

// king in a corner?

king = KING_POS(board,me);
if (king != A1  &&  king != H1  &&  king != A8  &&  king != H8) {
return false; // no
}

// init

opp = COLOUR_OPP(me);
opp_flag = COLOUR_FLAG(opp);

// king can move?

from = king;

inc_ptr = 0;
while(true) {
inc = KingInc[inc_ptr];
if( inc == IncNone ) {
break;
}

to = from + inc;
capture = board.square[to];
if (capture == Empty  ||  FLAG_IS(capture,opp_flag)) {
if (! is_attacked(board,to,opp)) {
return false; // legal king move
}
}

inc_ptr = inc_ptr + 1;
}


// no legal move

//ASSERT(744, board_is_stalemate( board ));

return true;
}

// end of search_full.cpp



// see.cpp

// types

//  functions

// see_move()

private function see_move( move:int, board:board_t ) :int {

var att :int = 0;              // int
var def :int = 0;              // int
var from :int = 0;             // int
var to :int = 0;               // int
var value :int = 0;            // int
var piece_value :int = 0;      // int
var piece :int = 0;            // int
var capture :int = 0;          // int
var pos :int = 0;              // int
var alists:alists_t = new alists_t();  // alists_t[1]
var alist:alist_t = new alist_t();          // alist_t *

//ASSERT(745, move_is_ok(move));

// init

from = MOVE_FROM(move);
to = MOVE_TO(move);

// move the piece

piece_value = 0;

piece = board.square[from];
//ASSERT(747, piece_is_ok(piece));

att = PIECE_COLOUR(piece);
def = COLOUR_OPP(att);

// promote

if (MOVE_IS_PROMOTE(move)) {
//ASSERT(748, PIECE_IS_PAWN(piece));
piece = move_promote(move);
//ASSERT(749, piece_is_ok(piece));
//ASSERT(750, COLOUR_IS(piece,att));
}

piece_value = piece_value + this.ValuePiece[piece];

// clear attacker lists

alist_clear(alists.alist[Black]);
alist_clear(alists.alist[White]);

// find hidden attackers

alists_hidden(alists,board,from,to);

// capture the piece

value = 0;

capture = board.square[to];

if (capture != Empty) {

//ASSERT(751, piece_is_ok(capture));
//ASSERT(752, COLOUR_IS(capture,def));

value = value + this.ValuePiece[capture];
}

// promote

if (MOVE_IS_PROMOTE(move)) {
value = value + this.ValuePiece[piece] - ValuePawn;
}

// en-passant

if (MOVE_IS_EN_PASSANT(move)) {
//ASSERT(753, value==0);
//ASSERT(754, PIECE_IS_PAWN(board.square[SQUARE_EP_DUAL(to)]));
value = value + ValuePawn;
alists_hidden(alists,board,SQUARE_EP_DUAL(to),to);
}

// build defender list

alist = alists.alist[def];

alist_build(alist,board,to,def);
if (alist.size == 0) {
return value; // no defender => stop SEE
}

// build attacker list

alist = alists.alist[att];

alist_build(alist,board,to,att);

// remove the moved piece (if it's an attacker)

pos = 0;
while( pos<alist.size  &&  alist.square[pos] != from ) {
pos = pos + 1;
}

if (pos < alist.size) {
alist_remove(alist,pos);
}

// SEE search

value = value - see_rec(alists,board,def,to,piece_value);

return value;

}

// see_square()

private function see_square( board:board_t, to:int, colour:int ) :int {

var att :int = 0;              // int
var def :int = 0;              // int
var piece_value :int = 0;      // int
var piece :int = 0;            // int
var alists:alists_t = new alists_t();  // alists_t[1]
var alist:alist_t = new alist_t();          // alist_t *

//ASSERT(756, SQUARE_IS_OK(to));
//ASSERT(757, COLOUR_IS_OK(colour));

//ASSERT(758, COLOUR_IS(board.square[to],COLOUR_OPP(colour)));

// build attacker list

att = colour;

alist = alists.alist[att];

alist_clear(alist);

alist_build(alist,board,to,att);

if (alist.size == 0) {
return 0; // no attacker => stop SEE
}

// build defender list

def = COLOUR_OPP(att);
alist = alists.alist[def];

alist_clear(alist);

alist_build(alist,board,to,def);

// captured piece

piece = board.square[to];
//ASSERT(759, piece_is_ok(piece));
//ASSERT(760, COLOUR_IS(piece,def));

piece_value = this.ValuePiece[piece];

// SEE search

return see_rec(alists,board,att,to,piece_value);

}

// see_rec()

private function see_rec( alists:alists_t, board:board_t, colour:int, to:int, piece_value:int ) :int {

var from :int = 0;    // int
var piece :int = 0;   // int
var value :int = 0;   // int

//ASSERT(763, COLOUR_IS_OK(colour));
//ASSERT(764, SQUARE_IS_OK(to));
//ASSERT(765, piece_value>0);

// find the least valuable attacker

from = alist_pop(alists.alist[colour],board);
if (from == SquareNone) {
return 0; // no more attackers
}

// find hidden attackers

alists_hidden(alists,board,from,to);

// calculate the capture value

value = piece_value; // captured piece
if (value == ValueKing) {
return value; // do not allow an answer to a king capture
}

piece = board.square[from];
//ASSERT(766, piece_is_ok(piece));
//ASSERT(767, COLOUR_IS(piece,colour));
piece_value = this.ValuePiece[piece];

// promote

if (piece_value == ValuePawn  &&  this.SquareIsPromote[to]) {    // HACK: PIECE_IS_PAWN(piece)
//ASSERT(768, PIECE_IS_PAWN(piece));
piece_value = ValueQueen;
value = value + ValueQueen - ValuePawn;
}

value = value - see_rec(alists,board,COLOUR_OPP(colour),to,piece_value);

if (value < 0) {
value = 0;
}

return value;

}

// alist_build()

private function alist_build( alist:alist_t, board:board_t, to:int, colour:int ) :void {

var ptr :int = 0;    // int
var from :int = 0;   // int
var piece :int = 0;  // int
var delta :int = 0;  // int
var inc :int = 0;    // int
var sq :int = 0;     // int
var pawn :int = 0;   // int

//ASSERT(771, SQUARE_IS_OK(to));
//ASSERT(772, COLOUR_IS_OK(colour));

// piece attacks

ptr = 0;
while(true) {

from = board.piece[colour][ptr];

if(from==SquareNone) {
break;
}

piece = board.square[from];
delta = to - from;

if (PSEUDO_ATTACK(piece,delta)) {

inc = DELTA_INC_ALL(delta);
//ASSERT(773, inc!=IncNone);

sq = from;
while(true) {

sq = sq + inc;
if (sq == to) {  // attack
alist_add(alist,from,board);
break;
}

if(board.square[sq] != Empty) {
break;
}

}
}

ptr = ptr + 1;
}

// pawn attacks

inc = PawnMoveInc[colour];
pawn = PawnMake[colour];

from = to - (inc-1);
if (board.square[from] == pawn) {
alist_add(alist,from,board);
}

from = to - (inc+1);
if (board.square[from] == pawn) {
alist_add(alist,from,board);
}

}

// alists_hidden()

private function alists_hidden( alists:alists_t, board:board_t, from:int, to:int ) :void {

var inc :int = 0;     // int
var sq :int = 0;      // int
var piece :int = 0;   // int

//ASSERT(776, SQUARE_IS_OK(from));
//ASSERT(777, SQUARE_IS_OK(to));

inc = DELTA_INC_LINE(to-from);

if (inc != IncNone)  {  // line

sq = from;

while(true) {
sq = sq - inc;
piece = board.square[sq];
if ( piece!= Empty) {
break;
}
}

if (SLIDER_ATTACK(piece,inc)) {

//ASSERT(778, piece_is_ok(piece));
//ASSERT(779, PIECE_IS_SLIDER(piece));

alist_add(alists.alist[PIECE_COLOUR(piece)],sq,board);
}
}

}

// alist_clear()

private function alist_clear( alist:alist_t ): void { 

alist.size = 0;
alist.square = [];

}


// alist_add()

private function alist_add( alist:alist_t, square:int, board:board_t ) :void {

var piece :int = 0;   // int
var size :int = 0;    // int
var pos :int = 0;     // int


//ASSERT(782, SQUARE_IS_OK(square));


// insert in MV order

piece = board.square[square];

alist.size = alist.size + 1; // HACK
size = alist.size;

//ASSERT(784, size>0 && size<16);

pos = size-1;
while( pos > 0  &&  piece > board.square[alist.square[pos-1]]) {    // HACK
//ASSERT(785, pos>0 && pos<size);
alist.square[pos] = alist.square[pos-1];
pos = pos - 1;
}

//ASSERT(786, pos>=0 && pos<size);
alist.square[pos] = square;

}

// alist_remove()

private function alist_remove( alist:alist_t, pos:int ) :void {

var size :int = 0;  // int
var i :int = 0;     // int

//ASSERT(788, pos>=0 && pos<alist.size);

size = alist.size;
alist.size = alist.size - 1;     // HACK

//ASSERT(789, size>=1);

//ASSERT(790, pos>=0 && pos<size);

for (i = pos; i<=size-2; i++ ) {
//ASSERT(791, i>=0 && i<size-1);
alist.square[i] = alist.square[i+1];
}

}

// alist_pop()

private function alist_pop( alist:alist_t, board:board_t ) :int {

var sq :int = 0;     // int
var size :int = 0;   // int


sq = SquareNone;

size = alist.size;

if (size != 0) {
size = size - 1;
//ASSERT(794, size>=0);
sq = alist.square[size];
alist.size = size;
}

return sq;

}

// end of see.cpp



// sort.cpp



//  functions

// sort_init()

private function sort_init1() :void {

var i :int = 0;        // int
var height :int = 0;   // int
var pos :int = 0;      // int

// killer

for (height = 0; height<HeightMax; height++ ) {
this.Killer[height] = [];
for (i = 0; i<=1; i++ ) {
this.Killer[height][i] = MoveNone;
}
}

// history

for (i = 0; i<HistorySize; i++ ) {
this.History[i] = 0;
this.HistHit[i] = 1;
this.HistTot[i] = 1;
}

// Code[]

for (pos = 0; pos< CODE_SIZE; pos++ ) {
this.Code[pos] = GEN_ERROR;
}

pos = 0;

// main search

this.PosLegalEvasion = pos;
this.Code[0] = GEN_LEGAL_EVASION;
this.Code[1] = GEN_END;

this.PosSEE = 2;
this.Code[2] = GEN_TRANS;
this.Code[3] = GEN_GOOD_CAPTURE;
this.Code[4] = GEN_KILLER;
this.Code[5] = GEN_QUIET;
this.Code[6] = GEN_BAD_CAPTURE;
this.Code[7] = GEN_END;

// quiescence search

this.PosEvasionQS = 8;
this.Code[8] = GEN_EVASION_QS;
this.Code[9] = GEN_END;

this.PosCheckQS = 10;
this.Code[10] = GEN_CAPTURE_QS;
this.Code[11] = GEN_CHECK_QS;
this.Code[12] = GEN_END;

this.PosCaptureQS = 13;
this.Code[13] = GEN_CAPTURE_QS;
this.Code[14] = GEN_END;

pos = 15;

//ASSERT(795, pos<CODE_SIZE);

}

// sort_init()

private function sort_init2( sort:sort_t, board:board_t, attack:attack_t, depth:int, height:int, trans_killer:int ) :void {

//ASSERT(799, depth_is_ok(depth));
//ASSERT(800, height_is_ok(height));
//ASSERT(801, trans_killer==MoveNone || move_is_ok(trans_killer));

sort.board = board;
sort.attack = attack;

sort.depth = depth;
sort.height = height;

sort.trans_killer = trans_killer;
sort.killer_1 = this.Killer[sort.height][0];
sort.killer_2 = this.Killer[sort.height][1];

if (ATTACK_IN_CHECK(sort.attack)) {

gen_legal_evasions(sort.list,sort.board,sort.attack);
note_moves(sort.list,sort.board,sort.height,sort.trans_killer);
list_sort(sort.list);

sort.gen = this.PosLegalEvasion + 1;
sort.test = TEST_NONE;

} else {  // not in check

sort.list.size = 0;
sort.gen = this.PosSEE;

}

sort.pos = 0;
}

// sort_next()

private function sort_next( sort:sort_t ) :int {

var move :int = 0;   // int
var gen :int = 0;    // int
var nocont :Boolean = false;
var ifelse :Boolean = false;

while (true) {

while (sort.pos < sort.list.size) {

nocont = true;

// next move

move = sort.list.move[sort.pos];
sort.value = 16384; // default score
sort.pos = sort.pos + 1;

//ASSERT(803, move!=MoveNone);

// test

ifelse = true;
if (ifelse && (sort.test == TEST_NONE)) {
		    ifelse = false;
}

if (ifelse && (sort.test == TEST_TRANS_KILLER)) {

if (nocont && (! move_is_pseudo(move,sort.board))) {
nocont = false;
}
if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

ifelse = false;
}

if (ifelse && (sort.test == TEST_GOOD_CAPTURE)) {

//ASSERT(804, move_is_tactical(move,sort.board));

if (nocont && move == sort.trans_killer) {
nocont = false;
}

if (nocont && (! capture_is_good(move,sort.board))) {
LIST_ADD(sort.bad,move);
nocont = false;
}

if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

ifelse = false;
}

if (ifelse && (sort.test == TEST_BAD_CAPTURE)) {

//ASSERT(805, move_is_tactical(move,sort.board));
//ASSERT(806, (! capture_is_good(move,sort.board)));

//ASSERT(807, move!=sort.trans_killer);
if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

ifelse = false;
}

if (ifelse && (sort.test == TEST_KILLER)) {

if (nocont && move == sort.trans_killer) {
nocont = false;
}
if (nocont && (! quiet_is_pseudo(move,sort.board))) {
nocont = false;
}
if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

//ASSERT(808, (! nocont) || (! move_is_tactical(move,sort.board)));

ifelse = false;
}

if (ifelse && (sort.test == TEST_QUIET)) {

//ASSERT(809, ! move_is_tactical(move,sort.board));

if (nocont && move == sort.trans_killer) {
nocont = false;
}
if (nocont && move == sort.killer_1) {
nocont = false;
}
if (nocont && move == sort.killer_2) {
nocont = false;
}
if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

if (nocont) {
sort.value = history_prob(move,sort.board);
}

ifelse = false;
}

if (ifelse) {

//ASSERT(810, false);

return MoveNone;
}

if (nocont) {

//ASSERT(811, pseudo_is_legal(move,sort.board));
return move;

} // otherwise continue

}

// next stage

gen = this.Code[sort.gen];
sort.gen = sort.gen + 1;

ifelse = true;

if (ifelse && (gen == GEN_TRANS)) {

LIST_CLEAR(sort.list);
if (sort.trans_killer != MoveNone) {
LIST_ADD(sort.list,sort.trans_killer);
}

sort.test = TEST_TRANS_KILLER;

ifelse = false;
}

if (ifelse && (gen == GEN_GOOD_CAPTURE)) {

gen_captures(sort.list,sort.board);
note_mvv_lva(sort.list,sort.board);
list_sort(sort.list);

LIST_CLEAR(sort.bad);

sort.test = TEST_GOOD_CAPTURE;

ifelse = false;
}

if (ifelse && (gen == GEN_BAD_CAPTURE)) {

list_copy(sort.list,sort.bad);

sort.test = TEST_BAD_CAPTURE;

ifelse = false;
}

if (ifelse && (gen == GEN_KILLER)) {

LIST_CLEAR(sort.list);
if (sort.killer_1 != MoveNone) {
LIST_ADD(sort.list,sort.killer_1);
}
if (sort.killer_2 != MoveNone) {
LIST_ADD(sort.list,sort.killer_2);
}

sort.test = TEST_KILLER;

ifelse = false;
}

if (ifelse && (gen == GEN_QUIET)) {

gen_quiet_moves(sort.list,sort.board);
note_quiet_moves(sort.list,sort.board);
list_sort(sort.list);

sort.test = TEST_QUIET;

ifelse = false;
}

if (ifelse) {

//ASSERT(812, gen==GEN_END);

return MoveNone;
}

sort.pos = 0;

}

return MoveNone;
}

// sort_init_qs()

private function sort_init_qs( sort:sort_t, board:board_t, attack:attack_t, check:Boolean ) :void {

sort.board = board;
sort.attack = attack;

if (ATTACK_IN_CHECK(sort.attack)) {
sort.gen = this.PosEvasionQS;
} else { 
if (check) {
sort.gen = this.PosCheckQS;
} else { 
sort.gen = this.PosCaptureQS;
}
}

LIST_CLEAR(sort.list);
sort.pos = 0;

}

// sort_next_qs()

private function sort_next_qs( sort:sort_t ) :int {

var move :int = 0;   // int
var gen :int = 0;    // int
var nocont :Boolean = false;
var ifelse :Boolean = false;

while (true) {

while (sort.pos < sort.list.size) {

nocont = true;

// next move

move = sort.list.move[sort.pos];
sort.pos = sort.pos + 1;

//ASSERT(818, move!=MoveNone);

// test

ifelse = true;

if (ifelse && (sort.test == TEST_LEGAL)) {

if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

ifelse = false;
}

if (ifelse && (sort.test == TEST_CAPTURE_QS)) {

//ASSERT(819, move_is_tactical(move,sort.board));

if (nocont && (! capture_is_good(move,sort.board))) {
nocont = false;
}
if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

ifelse = false;
}

if (ifelse && (sort.test == TEST_CHECK_QS)) {

//ASSERT(820, ! move_is_tactical(move,sort.board));
//ASSERT(821, move_is_check(move,sort.board));

if (nocont && see_move(move,sort.board) < 0) {
nocont = false;
}
if (nocont && (! pseudo_is_legal(move,sort.board))) {
nocont = false;
}

ifelse = false;
}

if (ifelse) {

//ASSERT(822, false);
return MoveNone;

}

if (nocont) {

//ASSERT(823, pseudo_is_legal(move,sort.board));
return move;

}

}

// next stage

gen = this.Code[sort.gen];
sort.gen = sort.gen + 1;

ifelse = true;

if (ifelse && (gen == GEN_EVASION_QS)) {

gen_pseudo_evasions(sort.list,sort.board,sort.attack);
note_moves_simple(sort.list,sort.board);
list_sort(sort.list);

sort.test = TEST_LEGAL;

ifelse = false;
}

if (ifelse && (gen == GEN_CAPTURE_QS)) {

gen_captures(sort.list,sort.board);
note_mvv_lva(sort.list,sort.board);
list_sort(sort.list);

sort.test = TEST_CAPTURE_QS;

ifelse = false;
}

if (ifelse && (gen == GEN_CHECK_QS)) {

gen_quiet_checks(sort.list,sort.board);

sort.test = TEST_CHECK_QS;

ifelse = false;
}

if (ifelse) {

//ASSERT(824, gen==GEN_END);

return MoveNone;
}

sort.pos = 0;
}

//ASSERT(1824, false);
return MoveNone;
}

// good_move()

private function good_move( move:int, board:board_t, depth:int, height:int ) :void {

var index :int = 0;   // int
var i :int = 0;       // int

//ASSERT(825, move_is_ok(move));
//ASSERT(827, depth_is_ok(depth));
//ASSERT(828, height_is_ok(height));

if (move_is_tactical(move,board)) {
return;
}

// killer

if (this.Killer[height][0] != move) {
this.Killer[height][1] = this.Killer[height][0];
this.Killer[height][0] = move;
}

//ASSERT(829, this.Killer[height][0]==move);
//ASSERT(830, this.Killer[height][1]!=move);

// history

index = history_index(move,board);

this.History[index] = this.History[index] + ( depth * depth );          // HISTORY_INC()

if (this.History[index] >= HistoryMax) {
for (i = 0; i<HistorySize; i++ ) {
this.History[i] = (this.History[i] + 1) / 2;
}
}

}

// history_good()

private function history_good( move:int, board:board_t )  :void {

var index :int = 0;   // int

//ASSERT(831, move_is_ok(move));

if (move_is_tactical(move,board)) {
return;
}

// history

index = history_index(move,board);

this.HistHit[index] = this.HistHit[index] + 1;
this.HistTot[index] = this.HistTot[index] + 1;

if (this.HistTot[index] >= HistoryMax) {
this.HistHit[index] = (this.HistHit[index] + 1) / 2;
this.HistTot[index] = (this.HistTot[index] + 1) / 2;
}

//ASSERT(833, this.HistHit[index]<=this.HistTot[index]);
//ASSERT(834, this.HistTot[index]<HistoryMax);
}

// history_bad()

private function history_bad( move:int, board:board_t )  :void {

var index :int = 0;   // int

//ASSERT(835, move_is_ok(move));

if (move_is_tactical(move,board)) {
return;
}

// history

index = history_index(move,board);

this.HistTot[index] = this.HistTot[index] + 1;

if (this.HistTot[index] >= HistoryMax) {
this.HistHit[index] = (this.HistHit[index] + 1) / 2;
this.HistTot[index] = (this.HistTot[index] + 1) / 2;
}

//ASSERT(837, this.HistHit[index]<=this.HistTot[index]);
//ASSERT(838, this.HistTot[index]<HistoryMax);

}

// note_moves()

private function note_moves( list:list_t, board:board_t, height:int,  trans_killer:int )  :void {

var size :int = 0;   // int
var i :int = 0;      // int
var move :int = 0;   // int

//ASSERT(839, list_is_ok(list));
//ASSERT(841, height_is_ok(height));
//ASSERT(842, trans_killer==MoveNone || move_is_ok(trans_killer));

size = list.size;

if (size >= 2) {
for (i = 0; i<size; i++ ) {
move = list.move[i];
list.value[i] = move_value(move,board,height,trans_killer);
}
}

}

// note_captures()

private function note_captures( list:list_t, board:board_t ) :void {

var size :int = 0;   // int
var i :int = 0;      // int
var move :int = 0;   // int

//ASSERT(843, list_is_ok(list));

size = list.size;

if (size >= 2) {
for (i = 0; i< size; i++ ) {
move = list.move[i];
list.value[i] = capture_value(move,board);
}
}

}

// note_quiet_moves()

private function note_quiet_moves( list:list_t, board:board_t ) :void {

var size :int = 0;   // int
var i :int = 0;      // int
var move :int = 0;   // int

//ASSERT(845, list_is_ok(list));

size = list.size;

if (size >= 2) {
for (i = 0; i< size; i++ ) {
move = list.move[i];
list.value[i] = quiet_move_value(move,board);
}
}

}

// note_moves_simple()

private function note_moves_simple( list:list_t, board:board_t ) :void {

var size :int = 0;   // int
var i :int = 0;      // int
var move :int = 0;   // int

//ASSERT(847, list_is_ok(list));

size = list.size;

if (size >= 2) {
for (i = 0; i< size; i++ ) {
move = list.move[i];
list.value[i] = move_value_simple(move,board);
}
}

}

// note_mvv_lva()

private function note_mvv_lva( list:list_t, board:board_t ) :void {

var size :int = 0;   // int
var i :int = 0;      // int
var move :int = 0;   // int

//ASSERT(849, list_is_ok(list));

size = list.size;

if (size >= 2) {
for (i = 0; i< size; i++ ) {
move = list.move[i];
list.value[i] = mvv_lva(move,board);
}
}

}

// move_value()

private function move_value( move:int, board:board_t, height:int, trans_killer:int ) :int {

var value :int = 0;   // int

//ASSERT(851, move_is_ok(move));
//ASSERT(853, height_is_ok(height));
//ASSERT(854, trans_killer==MoveNone || move_is_ok(trans_killer));

if (move == trans_killer) {    // transposition table killer
value = TransScore;
} else { 
if (move_is_tactical(move,board)) {   // capture || promote
value = capture_value(move,board);
} else { 
if (move == this.Killer[height][0]) {   // killer 1
value = KillerScore;
} else { 
if (move == this.Killer[height][1]) {  // killer 2
value = KillerScore - 1;
} else {   // quiet move
value = quiet_move_value(move,board);
}
}
}
}

return value;

}

// capture_value()

private function capture_value( move:int, board:board_t ) :int {

var value :int = 0;   // int

//ASSERT(855, move_is_ok(move));

//ASSERT(857, move_is_tactical(move,board));

value = mvv_lva(move,board);

if (capture_is_good(move,board)) {
value = value + GoodScore;
} else { 
value = value + BadScore;
}

//ASSERT(858, value>=-30000 && value<=30000);

return value;

}

// quiet_move_value()

private function quiet_move_value( move:int, board:board_t ) :int {

var value :int = 0;   // int
var index :int = 0;   // int

//ASSERT(859, move_is_ok(move));

//ASSERT(861, ! move_is_tactical(move,board));

index = history_index(move,board);

value = HistoryScore + this.History[index];
//ASSERT(862, value>=HistoryScore && value<=KillerScore-4);

return value;

}

// move_value_simple()

private function move_value_simple( move:int, board:board_t ) :int {

var value :int = 0;   // int

//ASSERT(863, move_is_ok(move));

value = HistoryScore;
if (move_is_tactical(move,board)) {
value = mvv_lva(move,board);
}

return value;

}

// history_prob()

private function history_prob( move:int, board:board_t ) :int {

var value :int = 0;   // int
var index :int = 0;   // int

//ASSERT(865, move_is_ok(move));

//ASSERT(867, ! move_is_tactical(move,board));

index = history_index(move,board);

//ASSERT(868, this.HistHit[index]<=this.HistTot[index]);
//ASSERT(869, this.HistTot[index]<HistoryMax);

value = (this.HistHit[index] * 16384) / this.HistTot[index];
//ASSERT(870, value>=0 && value<=16384);

return value;

}

// capture_is_good()

private function capture_is_good( move:int, board:board_t ) :Boolean {

var piece :int = 0;     // int
var capture :int = 0;   // int

//ASSERT(871, move_is_ok(move));

//ASSERT(873, move_is_tactical(move,board));

// special cases

if (MOVE_IS_EN_PASSANT(move)) {
return true;
}
if (move_is_under_promote(move)) {
return false; // REMOVE ME?
}

// captures && queen promotes

capture = board.square[MOVE_TO(move)];

if (capture != Empty) {

// capture

//ASSERT(874, move_is_capture(move,board));

if (MOVE_IS_PROMOTE(move)) {
return true; // promote-capture
}

piece = board.square[MOVE_FROM(move)];
if (this.ValuePiece[capture] >= this.ValuePiece[piece]) {
return true;
}
}

return (see_move(move,board) >= 0);

}

// mvv_lva()

private function mvv_lva( move:int, board:board_t ) :int {

var piece :int = 0;     // int
var capture :int = 0;   // int
var promote :int = 0;   // int
var value :int = 0;     // int

//ASSERT(875, move_is_ok(move));

//ASSERT(877, move_is_tactical(move,board));

if (MOVE_IS_EN_PASSANT(move)) {   // en-passant capture

value = 5; // PxP

} else { 

capture = board.square[MOVE_TO(move)];

if (capture!= Empty) {   // normal capture

piece = board.square[MOVE_FROM(move)];

value = (this.PieceOrder[capture] * 6) - this.PieceOrder[piece] + 5;
//ASSERT(878, value>=0 && value<30);

} else {// promote

//ASSERT(879, MOVE_IS_PROMOTE(move));

promote = move_promote(move);

value = this.PieceOrder[promote] - 5;
//ASSERT(880, value>=-4 && value<0);
}
}

//ASSERT(881, value>=-4 && value<30);

return value;

}

// history_index()

private function history_index( move:int, board:board_t ) :int {

var index :int = 0;   // int

//ASSERT(882, move_is_ok(move));

//ASSERT(884, ! move_is_tactical(move,board));

index = (this.PieceTo12[board.square[MOVE_FROM(move)]] * 64) + this.SquareTo64[MOVE_TO(move)];

//ASSERT(885, index>=0 && index<HistorySize);

return index;

}

// end of sort.cpp


// square.cpp

//  functions

// square_init()

private function square_init() :void {

var sq :int = 0;   // int

// this.SquareTo64[]

for (sq = 0; sq< SquareNb; sq++ ) {
this.SquareTo64[sq] = -1;
}

for (sq = 0; sq<=63; sq++ ) {
this.SquareTo64[SquareFrom64[sq]] = sq;
}

// this.SquareIsPromote[]

for (sq = 0; sq< SquareNb; sq++ ) {
this.SquareIsPromote[sq] = SQUARE_IS_OK(sq)  &&  (SQUARE_RANK(sq) == Rank1  ||  SQUARE_RANK(sq) == Rank8);
}

}

// file_from_char()

private function file_from_char(c:String) :int {

//ASSERT(886, c>="a" && c<="h");

return FileA + (c.charCodeAt(0) - ("a").charCodeAt(0));
}

// rank_from_char()

private function rank_from_char(c:String) :int {

//ASSERT(887, c>="1" && c<="8");

return Rank1 + (c.charCodeAt(0) - ("1").charCodeAt(0));
}

// file_to_char()

private function file_to_char( file:int ):String { 

//ASSERT(888, file>=FileA && file<=FileH);

return String.fromCharCode(  ("a").charCodeAt(0) + (file - FileA) );

}

// rank_to_char()

private function rank_to_char( rank:int ) :String {

//ASSERT(889, rank>=Rank1 && rank<=Rank8);

return String.fromCharCode(  ("1").charCodeAt(0) + (rank - Rank1) );

}

// square_to_string()

private function square_to_string( square:int, str1:string_t ) :Boolean {

//ASSERT(890, SQUARE_IS_OK(square));

str1.v = "";
str1.v = str1.v + file_to_char(SQUARE_FILE(square));
str1.v = str1.v + rank_to_char(SQUARE_RANK(square));

return true;
}

// square_from_string()

private function square_from_string( str1:string_t ) :int {

var file :int = 0;   // int
var rank :int = 0;   // int
var c1 :String = " ";   // char
var c2 :String = " ";   // char

c1 = str1.v.charAt( 0 );
if (c1 < "a"  ||  c1 > "h") {
return SquareNone;
}
c2 = str1.v.charAt( 1 );
if (c2 < "1"  ||  c2 > "8") {
return SquareNone;
}

file = file_from_char(c1);
rank = rank_from_char(c2);

return SQUARE_MAKE(file,rank);
}

// end of square.cpp


// trans.cpp

//  functions

// trans_is_ok()

private function trans_is_ok( trans:trans_t ) :Boolean {

var date :int = 0;   // int

if ( trans.size == 0 ) {
return false;
}

if ((trans.mask == 0)  ||  (trans.mask >= trans.size)) {
return false;
}

if (trans.date >= DateSize) {
return false;
}

for (date = 0; date<DateSize; date++ ) {
if (trans.age[date] != trans_age(trans,date)) {
return false;
}
}

return true;

}


// trans_alloc()

private function trans_alloc( trans:trans_t ): void { 

trans.size = TransSize;
trans.mask = trans.size - 1;   // 2^x -1

trans_clear(trans);

//ASSERT(900, trans_is_ok(trans));
}


// trans_clear()

private function trans_clear( trans:trans_t ) :void {

var clear_entry:entry_t = new entry_t();     // entry_t *

var index :int = 0;                   // uint32

trans_set_date(trans,0);
trans.table = [];            // will define objects while searching

}


// trans_cl_I()

private function trans_cl_I( trans:trans_t, index:int ) :void {

trans.table[index] = new entry_t();

var clear_entry:entry_t = trans.table[index];

clear_entry.lock = 0;
clear_entry.move = MoveNone;
clear_entry.depth = DepthNone;
clear_entry.date = trans.date;
clear_entry.move_depth = DepthNone;
clear_entry.flags = 0;
clear_entry.min_depth = DepthNone;
clear_entry.max_depth = DepthNone;
clear_entry.min_value = -ValueInf;
clear_entry.max_value = ValueInf;

//ASSERT(903, entry_is_ok(clear_entry));

}


// trans_inc_date()

private function trans_inc_date( trans:trans_t )  :void {

trans_set_date(trans,(trans.date+1)%DateSize);
}

// trans_set_date()

private function trans_set_date( trans:trans_t, date:int )  :void {

var date1:int = 0;

//ASSERT(906, date>=0 && date<DateSize);

trans.date = date;

for (date1 = 0; date1<DateSize; date1++ ) {
trans.age[date1] = trans_age(trans,date1);
}

trans.used = 0;
trans.read_nb = 0;
trans.read_hit = 0;
trans.write_nb = 0;
trans.write_hit = 0;
trans.write_collision = 0;

}

// trans_age()

private function trans_age( trans:trans_t, date:int ) :int {

var age :int = 0;   // int

//ASSERT(908, date>=0 && date<DateSize);

age = trans.date - date;
if (age < 0) {
age = age + DateSize;
}

//ASSERT(909, age>=0 && age<DateSize);

return age;

}

// trans_store()

private function trans_store( trans:trans_t, key:int, move:int, depth:int, Tset:trans_rtrv )  :void {

var entry:entry_t = new entry_t();        // entry_t *
var best_entry:entry_t = new entry_t();   // entry_t *
var ei :int = 0;             // int
var i :int = 0;              // int
var score :int = 0;          // int
var best_score :int = 0;     // int
var nw_rc :Boolean = false;

//ASSERT(910, trans_is_ok(trans));
//ASSERT(911, move>=0 && move<65536);
//ASSERT(912, depth>=-127 && depth<=127);
//ASSERT(913, Tset.trans_min_value>=-ValueInf && Tset.trans_min_value<=ValueInf);
//ASSERT(914, Tset.trans_max_value>=-ValueInf && Tset.trans_max_value<=ValueInf);
//ASSERT(915, Tset.trans_min_value<=Tset.trans_max_value);

// init

trans.write_nb = trans.write_nb + 1;

// probe

best_score = -32767;

ei = trans_entry(trans,key);

for (i = 0; i< ClusterSize; i++ ) {

entry = trans.table[ei+i];

if (entry!=null) {

if (entry.lock == KEY_LOCK(key)) {

// hash hit => update existing entry

trans.write_hit = trans.write_hit + 1;
if (entry.date != trans.date) {
trans.used = trans.used + 1;
}

entry.date = trans.date;

if (depth > entry.depth) {
entry.depth = depth; // for replacement scheme
}

if (move != MoveNone  &&  depth >= entry.move_depth) {
entry.move_depth = depth;
entry.move = move;
}

if (Tset.trans_min_value > -ValueInf  &&  depth >= entry.min_depth) {
entry.min_depth = depth;
entry.min_value = Tset.trans_min_value;
}

if (Tset.trans_max_value < ValueInf  &&  depth >= entry.max_depth) {
entry.max_depth = depth;
entry.max_value = Tset.trans_max_value;
}

//ASSERT(916, entry_is_ok(entry));

return;
}

} else { 

trans_cl_I( trans, ei+i );   // create a new entry record
nw_rc = true;

entry = trans.table[ei+i];

}

// evaluate replacement score

score = (trans.age[entry.date] * 256) - entry.depth;
//ASSERT(917, score>-32767);

if (score > best_score) {
best_entry = entry;
best_score = score;
}

if(nw_rc) {
break;
}

}

// "best" entry found

entry = best_entry;

//ASSERT(919, entry.lock!=KEY_LOCK(key));

if (entry.lock != 0) {     // originally entry.date == trans.date
trans.write_collision = trans.write_collision + 1;
} else { 
trans.used = trans.used + 1;
}

// store

entry.lock = KEY_LOCK(key);
entry.date = trans.date;

entry.depth = depth;

entry.move_depth = ( move != MoveNone ? depth : DepthNone );
entry.move = move;

entry.min_depth = (Tset.trans_min_value > -ValueInf ? depth : DepthNone );
entry.max_depth = (Tset.trans_max_value < ValueInf ? depth : DepthNone );
entry.min_value = Tset.trans_min_value;
entry.max_value = Tset.trans_max_value;

//ASSERT(921, entry_is_ok(entry));

}

// trans_retrieve()

private function trans_retrieve( trans:trans_t, key:int, Ret:trans_rtrv ) :Boolean {

var entry:entry_t = new entry_t();   // entry_t *
var ei :int = 0;        // int
var i :int = 0;         // int

//ASSERT(922, trans_is_ok(trans));

// init

trans.read_nb = trans.read_nb + 1;

// probe

ei = trans_entry(trans,key);

for (i = 0; i< ClusterSize; i++ ) {

entry = trans.table[ei+i];

if (entry!=null && entry.lock!=null) {
	  
if (entry.lock == KEY_LOCK(key)) {

// found

trans.read_hit = trans.read_hit + 1;
if (entry.date != trans.date) {
entry.date = trans.date;
}

Ret.trans_move = entry.move;

Ret.trans_min_depth = entry.min_depth;
Ret.trans_max_depth = entry.max_depth;
Ret.trans_min_value = entry.min_value;
Ret.trans_max_value = entry.max_value;

return true;
}

} else {
return false;
}
}

// not found

return false;
}

// trans_stats()

private function trans_stats( trans:trans_t ) :void {

var full:Number = 0.0;       // double
var hit:Number = 0.0;        // double
var collision:Number = 0.0;  // double
var s :String = "";

//ASSERT(928, trans_is_ok(trans));

full = (trans.size>0 ? trans.used / trans.size : 0);
hit = (trans.read_nb>0 ? trans.read_hit / trans.read_nb : 0);
collision = (trans.write_nb>0 ? trans.write_collision / trans.write_nb : 0);

s = s + "\n" + "hash trans info";
s = s +" hashfull " + string_from_int(full*100.0) + "%";
s = s +" hits " + string_from_int(hit*100.0) + "%";
s = s +" collisions " + string_from_int(collision*100.0) + "%";

full = (this.Material.size>0 ? this.Material.used / this.Material.size : 0);
hit = (this.Material.read_nb>0 ? this.Material.read_hit / this.Material.read_nb : 0);
collision = (this.Material.write_nb>0 ? this.Material.write_collision / this.Material.write_nb : 0);

s = s + "\n" + "hash material info";
s = s +" hashfull " + string_from_int(full*100.0) + "%";
s = s +" hits " + string_from_int(hit*100.0) + "%";
s = s +" collisions " + string_from_int(collision*100.0) + "%";

full = (this.Pawn.size>0 ? this.Pawn.used / this.Pawn.size : 0);
hit = (this.Pawn.read_nb>0 ? this.Pawn.read_hit /this.Pawn.read_nb : 0);
collision = (this.Pawn.write_nb>0 ? this.Pawn.write_collision / this.Pawn.write_nb : 0);

s = s + "\n" + "hash pawn info";
s = s +" hashfull " + string_from_int(full*100.0) + "%";
s = s +" hits " + string_from_int(hit*100.0) + "%";
s = s +" collisions " + string_from_int(collision*100.0) + "%";
s = s + "\n";

send( s );
}

// trans_entry()

private function trans_entry( trans:trans_t, key:int ):int {  // index to entry_t  

var index :int = 0;  // uint32

//ASSERT(929, trans_is_ok(trans));

if (UseModulo) {
index = KEY_INDEX(key) % (trans.mask + 1);
} else { 
index =  ( KEY_INDEX(key) & trans.mask);
}

//ASSERT(930, index<=trans.mask);

return index;

}

// entry_is_ok()

private function entry_is_ok( entry:entry_t ) :Boolean {

if (entry.date >= DateSize) {
return false;
}

if (entry.move == MoveNone  &&  entry.move_depth != DepthNone) {
return false;
}
if (entry.move != MoveNone  &&  entry.move_depth == DepthNone) {
return false;
}

if (entry.min_value == -ValueInf  &&  entry.min_depth != DepthNone) {
return false;
}
if (entry.min_value >  -ValueInf  &&  entry.min_depth == DepthNone) {
return false;
}

if (entry.max_value == ValueInf  &&  entry.max_depth != DepthNone) {
return false;
}
if (entry.max_value <  ValueInf  &&  entry.max_depth == DepthNone) {
return false;
}

return true;
}

// end of trans.cpp



// util.cpp

// my_timer_reset()

private function my_timer_reset( timer:my_timer_t ): void { 

timer.start_real = 0.0;
timer.elapsed_real = 0.0;
timer.running = false;

}

// my_timer_start()

private function my_timer_start( timer:my_timer_t ): void { 

//ASSERT(946, timer.start_real==0.0);
//ASSERT(948, ! timer.running);

timer.running = true;
timer.start_real = os_clock();

}

// my_timer_stop()

private function my_timer_stop( timer:my_timer_t ): void { 

//ASSERT(950, timer.running);

timer.elapsed_real = timer.elapsed_real + os_clock() - timer.start_real;
timer.start_real = 0.0;
timer.running = false;

}

// my_timer_elapsed_real()

private function my_timer_elapsed_real( timer:my_timer_t ) :int { 

if (timer.running) {
timer.elapsed_real = (os_clock() - timer.start_real);
}

return timer.elapsed_real;
}


// end of util.cpp



// value.cpp

//  functions

// value_init()

private function value_init(): void { 

var piece :int = 0;   // int

// ValuePiece[]

for (piece = 0; piece<=1; piece++) {
this.ValuePiece[piece] = -1;
}

this.ValuePiece[Empty] = 0; // needed?
this.ValuePiece[Edge]  = 0; // needed?

this.ValuePiece[WP] = ValuePawn;
this.ValuePiece[WN] = ValueKnight;
this.ValuePiece[WB] = ValueBishop;
this.ValuePiece[WR] = ValueRook;
this.ValuePiece[WQ] = ValueQueen;
this.ValuePiece[WK] = ValueKing;

this.ValuePiece[BP] = ValuePawn;
this.ValuePiece[BN] = ValueKnight;
this.ValuePiece[BB] = ValueBishop;
this.ValuePiece[BR] = ValueRook;
this.ValuePiece[BQ] = ValueQueen;
this.ValuePiece[BK] = ValueKing;
}

// value_is_ok()

private function value_is_ok( value:int ) :Boolean {

if (value < -ValueInf  ||  value > ValueInf) {
return false;
}

return true;
}

// range_is_ok()

private function range_is_ok( min:int, max:int ) :Boolean {

if (! value_is_ok(min)) {
return false;
}
if (! value_is_ok(max)) {
return false;
}

if (min >= max) {
return false; // alpha-beta-like ranges cannot be null
}

return true;
}

// value_is_mate()

private function value_is_mate( value:int ) :Boolean {

//ASSERT(954, value_is_ok(value));

if (value < -ValueEvalInf  ||  value > ValueEvalInf) {
return true;
}

return false;
}

// value_to_trans()

private function value_to_trans( value:int, height:int ) :int {

//ASSERT(955, value_is_ok(value));
//ASSERT(956, height_is_ok(height));

if (value < -ValueEvalInf) {
value = value - height;
} else { 
if (value > ValueEvalInf) {
value = value + height;
}
}

//ASSERT(957, value_is_ok(value));

return value;

}

// value_from_trans()

private function value_from_trans( value:int, height:int ) :int {

//ASSERT(958, value_is_ok(value));
//ASSERT(959, height_is_ok(height));

if (value < -ValueEvalInf) {
value = value + height;
} else { 
if (value > ValueEvalInf) {
value = value - height;
}
}

//ASSERT(960, value_is_ok(value));

return value;

}

// value_to_mate()

private function value_to_mate( value:int ) :int {

var dist :int = 0;   // int

//ASSERT(961, value_is_ok(value));

if (value < -ValueEvalInf) {

dist = (ValueMate + value) / 2;
//ASSERT(962, dist>0);

return -dist;

} else { 
if (value > ValueEvalInf) {

dist = (ValueMate - value + 1) / 2;
//ASSERT(963, dist>0);

return dist;
}
}

return 0;
}

// end of value.cpp



// vector.cpp

//  functions

private function vector_init() :void {

var delta :int = 0;   // int
var x :int = 0;       // int
var y :int = 0;       // int
var dist :int = 0;    // int
var tmp :int = 0;     // int

// Distance[]

for (delta = 0; delta<DeltaNb; delta++ ) {
this.Distance[delta] = -1;
}

for (y = -7; y<=7; y++) {

for (x = -7; x<=7; x++) {

delta = y * 16 + x;
//ASSERT(964, delta_is_ok(delta));

dist = 0;

tmp = x;
if (tmp < 0) {
tmp = -tmp;
}
if (tmp > dist) {
dist = tmp;
}

tmp = y;
if (tmp < 0) {
tmp = -tmp;
}
if (tmp > dist) {
dist = tmp;
}

this.Distance[DeltaOffset+delta] = dist;
}
}

}


// delta_is_ok()

private function delta_is_ok( delta:int ) :Boolean {

if (delta < -119  ||  delta > 119) {
return false;
}

if ( (delta & 0xF) == 8) {
return false;     // HACK: delta % 16 would be ill-defined for negative numbers
}

return true;
}


// inc_is_ok()

private function inc_is_ok( inc:int ) :Boolean {

var dir :int = 0;   // int

for (dir = 0; dir<8 ; dir++ ) {
if (KingInc[dir] == inc) {
return true;
}
}

return false;
}

// end of vector.cpp


// main.cpp

//  functions

// main()

private function main(): void { 

// init

print2out( VERSION );

option_init();

square_init();
piece_init();
pawn_init_bit();
value_init();
vector_init();
attack_init();
move_do_init();

random_init();
hash_init();

inits();
setstartpos();

}

// end of main.cpp

private function ClearAll():void {
    // just clear all to be sure that nothing left

search_clear();
trans_clear(this.Trans);
pawn_clear();
material_clear();

}

//---


// Event on screen redraw
private function onFrameEnter(event:Event):void
{
if (this.External)
{
if (!this.swf_loadflag && ExternalInterface.available)
{
ExternalInterface.addCallback("CallingMe", CallingMe );  
			
this.pageURL = ExternalInterface.call('window.location.href.toString');
if (this.pageURL == null) { this.pageURL = ExternalInterface.call('document.location.href.toString'); }
if (this.pageURL == null) { this.pageURL = ""; }

ExternalInterface.call('swf_loaded');
this.swf_loadflag = true;
}
}
}

//Interface with javascript
public function CallingMe(p:String):String
{
var res:String = "ok";
var a:int = 0;
var cmd1:String = "";
var cmd2:String = "";

if (p.substr(0, 8) == "ShowInfo") this.ShowInfo = true;

if (p.substr(0, 9) == "do_input:") {
	cmd1 = p.substr(9);
	a = cmd1.indexOf(";");
	if (a >= 0)
	{
		cmd2 = cmd1.substr(a + 1);
		cmd1 = cmd1.substr(0, a);
	}
	if (cmd1.length > 0)  { do_input( cmd1 ); }
	if (cmd2.length > 0)  { do_input( cmd2 ); }
}
	 
return res;
}

private function spchar( s: String ):String
{
	var s2:String = "";
	var i:int = 0;
	var c:int = 0;
	for (i = 0; i < s.length; i++)
	{
		c = s.charCodeAt(i);
		if (c == 10) s2 += "<br>";
		else if (c == 13) s2 += "<br>";
		else if ( !(c == 34 || c == 39) ) s2 += s.charAt(i);
	}
	return s2;
}

private function CallingJS(ch:String, p:String):String
{
var reqstr:String = "CallingJS(" + '"' + ch + '"' + "," + '"' + spchar(p) + '"' +")";
var ret:String = "";
if (this.swf_loadflag) { ret = ExternalInterface.call(reqstr); }
return ret;
}
	
// Mousepress events
private function onMouseDown(event:MouseEvent):void
{
if (this.External) CallingJS("MOUSEPRESS", "");
else
	if (this.GameOver && this.gameovershow == 0) StartNewGame(false);
	else
	{
	  if (this.anims == 0 && this.logoshow == 0 && this.gameovershow == 0)
	  {
		var mx:int = this.mouseX;
		var my:int = this.mouseY;
		
		var x1:int = Math.floor((mx - ((this.width - this.BS) / 2)) / (this.BS / 8));
		var y1:int = Math.floor((my - ((this.height - this.BS) / 2)) / (this.BS / 8));
		if (x1 >= 0 && x1 < 8 && y1 >= 0 && y1 < 8)
		 {
		 var atsq:String = String.fromCharCode(97 + (this.rev ? 7 - x1 : x1)) +
				(1 + (this.rev ? y1 : 7 - y1)).toString();
				
		 var pc:String = atPiece(atsq);
		 var wm:Boolean = (this.MoveNpk % 2 == 0);
		 var wp:Boolean = (pc.charAt(0) == "w");
		 
		 if (pc.length > 0)
			{
			if (wm == wp)
			{
			this.dragat = atsq;
		 	this.cursor1.x = ((this.width - this.BS) / 2) + (x1 * (this.BS / 8));
		 	this.cursor1.y = ((this.height - this.BS) / 2) + (y1 * (this.BS / 8));
		 	this.cursor1.width = (this.BS / 8);
		 	this.cursor1.height = this.cursor1.width;
		 	addChild(this.cursor1);
			}
			else
			{
				if (this.MoveNpk == (this.rev ? 1: 0)) StartNewGame(false);
			}
		 	}
			
		 if( this.dragat.length>0 && (pc.length == 0 || wm != wp ))
			{
			var v2:int = parseInt( atsq.charAt(1) );
			var pr2:String = ((atPiece(this.dragat).charAt(1) == "p" &&
				(v2 == 1 || v2 == 8)) ? this.PromoPiece : "" );
				
			var move_string:string_t = new string_t()   // string
			var undo:undo_t = new undo_t();    // undo_t[1];
			var move:int = 0;
			var board:board_t = this.SearchInput.board;
			
			move_string.v = dragat + atsq + pr2;
			move = move_from_string(move_string, board);
			
			gen_legal_moves(this.SearchInput.list, board);
			
			for (var j:int = 0; j < this.SearchInput.list.size; j++ )
				{
				if (this.SearchInput.list.move[j] == move)
					{
					this.MoveMade = move_string.v;
					RemoveCursor(1);
					this.anims = 12;
					break;
					}
				}

			}
		 }
	  }
	 }
}

	// Hide drag-cursor...
private function RemoveCursor(ch:int):void
	{
	if (ch == 1 && this.dragat.length > 0)
		{
		this.dragat = "";
		removeChild(this.cursor1);
		}
	if (ch == 2 && this.curs2.length > 0)
		{
		this.curs2 = "";
		removeChild(this.cursor2);
		}
	}

private function atPiece(atsq:String):String
	{
	var file :int = 0;   // int
	var rank :int = 0;   // int
	var sq :int = 0;     // int
	var piece :int = 0;  // int
	var board:board_t = this.SearchInput.board
	var p2:String = "";
	var p3:String = "";
	var at2:String = "";
	
	for (rank = Rank8; rank>=Rank1; rank-- ) {

	file = FileA;
	while( file <= FileH ) {

		at2 = file_to_char(file) + rank_to_char(rank);
		if (atsq == at2)
			{
			sq = SQUARE_MAKE(file,rank);
			piece = board.square[sq];

			if (piece == Empty) return "";
			else{
				p2 = piece_to_char(piece);
				p3 = p2.toLowerCase();
				p3 = ((p3 == p2) ? "b" : "w" ) + p3;
				return p3;
				}
			}

	file = file + 1;
	}
	}
	return "";
	}


// Routine once on loading 
private function init(e:Event = null):void 
{

if(!this.External)
{
	Mouse.cursor = "arrow";
	DrawBoard();
	this.rev = (Math.random() > 0.4);
	StartNewGame(true);
	
	this.logo0.x = (this.width - this.logo0.width)/2;
	this.logo0.y = (this.height - this.logo0.height) / 2;
	this.logoshow = 150;
}
addChild(this.logo0);
removeEventListener(Event.ADDED_TO_STAGE, init);
}

// randomized simplest opening case...
private function randomopening( mvlist:String ):Boolean {

   var tm:String = "";
   var i:int = 0;
   var j:int = 0;
   var mv_l:int = mvlist.length;

   var fmv:Array = [ ["e2-e4", "d2-d4", "Ng1-f3", "Nb1-c3", "c2-c4", "g2-g3", "e2-e4", "c2-c3", "e2-e4", "d2-d4" ],
                   [ "e7-e5", "d7-d5", "Ng8-f6", "Nb8-c6", "c7-c5", "g7-g6", "c7-c5", "c7-c6", "e7-e6", "g7-g6" ] ];
   var m:String = "";
   
   if(mv_l<6) {

     tm = string_from_int( os_clock() );

     i = ( tm.charCodeAt(tm.length-1) - ("0").charCodeAt(0));

     m = fmv[ (  mv_l == 0 ? 0 : 1 ) ] [ i ];
     j = ( m.length >5 ? 1 : 0 );
     bestmv = m.substr(j,2) + m.substr(3+j,2);
     bestmv2 = m;

     return true;
   }

   return false;

}

// automatic AI vs AI game for testing.
private function autogame(): void {

print2out("Autogame!");
this.autogame2 = true;		// For timer...
this.auto_pgn = "";
this.auto_mc = 0;
this.auto_mlist = "";
}
	
private function onTimer(evt:TimerEvent):void {

if (this.autogame2) {

if(! randomopening( this.auto_mlist ) ) {
do_input( "go");
}

if( this.auto_mc % 2 == 0) {
this.auto_pgn += string_from_int(Math.floor(this.auto_mc/2)+1 )+".";
}
this.auto_pgn += this.bestmv2 + " ";

this.auto_mlist += " " + this.bestmv;

do_input( "position moves" + this.auto_mlist );
printboard();

print2out(this.auto_pgn);

if( board_is_mate(  this.SearchInput.board ) ) {
print2out("Checkmate! " + ( this.SearchInput.board.turn == White ? "0-1" : "1-0" ));
this.autogame2 = false;
}
if( board_is_stalemate( this.SearchInput.board ) ) {
print2out("Stalemate  1/2-1/2");
this.autogame2 = false;
}

this.auto_mc++;
}

// animations and logo
	if (this.logoshow > 0)
		{
		this.logoshow--;
		if (this.logoshow <= 0)
			{
			removeChild(this.logo0);
			if (this.rev) DoMove();
			}
		}
	if (this.gameovershow > 0)
		{
		this.gameovershow--;
		if (this.gameovershow <= 0)
			{
			removeChild(this.gameover0);
			}
		}

	if (this.anims > 0 )
		{
		if (this.anims == 12)
			{
			this.apc2 = atPcI(this.MoveMade.substr(0, 2));	// Saves piece to apc2...
			this.apc3 = -1;
			var pc3:String = atPiece( this.MoveMade.substr(0, 2) );
			var q00S:String = " wke1g1h1 or wke1c1a1 or bke8g8h8 or bke8c8g8 ";
			var q00a:int = q00S.indexOf( pc3 + this.MoveMade );
			if(  q00a>= 0 ) this.apc3 = atPcI( q00S.substr(q00a + 6, 2));
			
			if (this.apc2 < 0) this.anims = 6;
			
			this.MoveList += (this.MoveList.length > 0 ? " " : "" ) + this.MoveMade;
			this.MoveNpk++;
			do_input( "position moves " + this.MoveList );
			RemoveCursor(2);
			}
		this.anims--;
		
		if (this.anims > 5)
			{
			var dx:int = (this.BS / 8) * (this.MoveMade.charCodeAt(2) - this.MoveMade.charCodeAt(0)) * (1 / (12 - 5)) * (this.rev? -1:1);
			var dy:int = (this.BS / 8) * (this.MoveMade.charCodeAt(3) - this.MoveMade.charCodeAt(1)) * (1 / (12 - 5)) * (this.rev? 1: -1);
			
			this.pc0[this.apc2].x += dx;
			this.pc0[this.apc2].y += dy;
			if (this.apc3 >= 0)
				{
				this.pc0[this.apc3].x -= dx;
				this.pc0[this.apc3].y -= dy;
				}
			}
		if (this.anims == 5) {  SetUpBoard(); }
		if (this.anims == 2)
			{
			if (this.MoveMade.length > 0) ShowCursor2();	
			}
		if (this.anims == 0)
			{
			ifGameOver();
			if (this.rev == ( this.MoveNpk % 2 == 0 ) ) DoMove();
			}
		}

}

// previous move
private function ShowCursor2():void
{
	var at:String = this.MoveMade.substr(2, 2);
	var x:int = at.charCodeAt(0) - 97;
	var y:int = 8 - parseInt(at.charAt(1));
	
	if (this.rev) { x = 7 - x; y = 7 - y; }
	this.curs2 = at;
	this.cursor2.x = ((this.width - this.BS) / 2) + (x * (this.BS / 8));
	this.cursor2.y = ((this.height - this.BS) / 2) + (y * (this.BS / 8));
	this.cursor2.width = (this.BS / 8);
	this.cursor2.height = this.cursor2.width;
	addChild(this.cursor2);
}			
			
			
// On Game Over should set flag
private function ifGameOver():void
{
var board:board_t = this.SearchInput.board;
gen_legal_moves(this.SearchInput.list, board);
if(this.SearchInput.list.size < 1)
 {
	this.gameover0.x = (this.width - this.gameover0.width)/2;
	this.gameover0.y = (this.height - this.gameover0.height) / 2;
	this.gameovershow = 200;

	addChild(this.gameover0);
	this.GameOver = true;
 }
}				
				
// MoveIt
private function DoMove():void
{
	
if(! randomopening( this.MoveList ) ) {
do_input( "go movetime 4");
}
if(this.bestmv.length > 0)
	{
	this.MoveMade = this.bestmv;
	this.anims = 12;
	}
}

private function StartNewGame( first:Boolean ):void
	{
	do_input( "position fen " + this.StartFen );
	this.MoveList = "";
	this.MoveNpk = 0;
	this.MoveMade = "";
	this.GameOver = false;
	this.rev = !this.rev;
	RemoveCursor(1);
	RemoveCursor(2);
	SetUpBoard();
	if (!first && this.rev) DoMove();
	}

private function DrawBoard():void 
	{
	if (this.BS==0)
	 {
		this.BS = Math.min(this.height, this.height) * 0.98;
		var sq:int = 0;
		for (var x:int = 0; x < 8; x++)
		 for (var y:int = 0; y < 8; y++)
			{
			this.bsq0[sq] = ( ((x + y) % 2 > 0) ? new bsq_image() : new wsq_image() );
			this.bsq0[sq].x = ((this.width - this.BS) / 2) + (x * (this.BS / 8));
			this.bsq0[sq].y = ((this.height - this.BS) / 2) + (y * (this.BS / 8));
			this.bsq0[sq].width = (this.BS / 8);
			this.bsq0[sq].height = this.bsq0[sq].width;
			addChild(this.bsq0[sq]);
			sq++;
			}
	 }
	 
	}

		//This draws pieces...
private function SetUpBoard():void 
	{	
	var file :int = 0;   // int
	var rank :int = 0;   // int
	var sq :int = 0;     // int
	var piece :int = 0;  // int
	var board:board_t = this.SearchInput.board
	var p2:String = "";
	var p3:String = "";
	var at2:String = "";
	
	for (var n:int = 0; n < pc0.length; n++)
		{
		removeChild(this.pc0[n]);
		}
	this.pc0 = [];
	
	
	// piece placement

	for (rank = Rank8; rank>=Rank1; rank-- ) {

	file = FileA;
	while( file <= FileH ) {

		sq = SQUARE_MAKE(file,rank);
		piece = board.square[sq];

		if (piece != Empty) {
			p2 = piece_to_char(piece);
			p3 = p2.toLowerCase();
			p3 = ((p3 == p2) ? "b" : "w" ) + p3;
			at2 = file_to_char(file) + rank_to_char(rank);
			addPiece(p3, at2);
		}

	file = file + 1;
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
	
	this.pc0[n].x = ((this.width - this.BS) / 2) + (x * (this.BS / 8));
	this.pc0[n].y = ((this.height - this.BS) / 2) + (y * (this.BS / 8)) - (this.BS / 360);
	
	this.pc0[n].width = (this.BS / 8);
	this.pc0[n].height = this.pc0[n].width;
	addChild(this.pc0[n]);
	}
	
private function atPcI(at:String):int
	{
	var atI:int = -1;
	for (var n:int = 0; n < this.pc0.length; n++)
		{
		var x:int = at.charCodeAt(0) - 97;
		var y:int = 8 - parseInt(at.charAt(1));
		
		if (this.rev) { x = 7 - x; y = 7 - y; }
			
		var x1:int = ((this.width - this.BS) / 2) + (x * (this.BS / 8));
		var y1:int = ((this.height - this.BS) / 2) + (y * (this.BS / 8)) - (this.BS / 360);

		if (Math.abs( this.pc0[n].x-x1 )<5 && Math.abs( this.pc0[n].y - y1)<5 )
			{
			atI = n;
			break;
			}
		}
	return atI;
	}



// The main program function - all it starts here
		
 public function FlexView():void
 {
	
    Timer2.addEventListener(TimerEvent.TIMER, onTimer);
    Timer2.start();
    Timer2.delay = 10;

    main();  // initialize and set up starting position

//  do_input( "help" );
//  do_input( "position moves e2e4 e7e5 g1f3 g8f6 f1c4 f8c5 e1g1 e8g8" );
//  do_input( "position moves h2h3 a7a5 h3h4 a5a4 b2b4" );
//  do_input( "position moves b2b4 a7a5 a2a3 a5b4 c1b2 b4a3 b1c3 a3b2 h2h3 b2a1n h3h4 a1c2" );
//  do_input( "position moves b2b4 g7g6 b4b5 c7c5 b5c6" );
//  do_input( "position fen 7k/Q7/2P2K2/8/8/8/8/8 w - - 70 1" );
//  printboard();
//  do_input( "go");
//  do_input( "go depth 5");
//  do_input( "go movetime 5");


// checkmate in 3 moves    1.Bf7+ Kxf7 2.Qxg6+ Ke7 3.Qe6#
//  this.ShowInfo = true;
//  do_input( "position fen r3kr2/pbq5/2pRB1p1/8/4QP2/2P3P1/PP6/2K5 w q - 0 36" );
//  printboard();
//  do_input( "go movetime 10");

//   autogame();

    super();
    this.addEventListener(Event.ENTER_FRAME, onFrameEnter);
    this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	
    if (stage) init();
    else addEventListener(Event.ADDED_TO_STAGE, init);

	 
 }

}
}
