package
{
  import flash.events.*;
  import flash.display.*;
  import mx.core.UIComponent;
  import flash.external.*;
  import flash.utils.Timer;

   
 public class FlexView extends UIComponent
  {
	 [Embed(source='jestlogo.png')]
	 private static var jestlogo_image:Class;
	 private var jestlogo0:Bitmap = new jestlogo_image();
 	
	 private var pageURL:String = "";
	 private var swf_loadflag:Boolean = false;
	 
	 
	 private var timer:Timer = new Timer(1000);
	 private var autogame2:Boolean = false;

	  
	 private var Js_maxDepth:int = 15			// Search Depth setting for flash (no timeout option)

	 private var Js_searchTimeout:Number = 9 * 1000;		// 9 seconds for search allowed

	 private var Js_startTime:Number = 0;
	 private var Js_nMovesMade:int = 0;
	 private var Js_computer:int = 0;
	 private var Js_player:int = 0;
	 private var Js_enemy:int = 0;

	 private var Js_fUserWin_kc:Boolean = false;
	 private var Js_fInGame:Boolean = false;


	 private var Js_fGameOver:Boolean = false;

	 private var Js_fCheck_kc:Boolean = false;
	 private var Js_fMate_kc:Boolean = false;
	 private var Js_bDraw:int = 0;
	 private var Js_fStalemate:Boolean = false;
	 private var Js_fSoonMate_kc:Boolean = false;		// Algo detects soon checkmate
	 private var Js_fAbandon:Boolean = false;			// Algo resigns, if game lost
	
	 private var Js_working:int = 0;
	 private var Js_working2:int = 0;
	 private var Js_advX_pawn:int = 10;
	 private var Js_isoX_pawn:int = 7;
	 private var Js_pawnPlus:int = 0;
	 private var Js_castle_pawn:int = 0;
	 private var Js_bishopPlus:int = 0;
	 private var Js_adv_knight:int = 0;
	 private var Js_far_knight:int = 0;
	 private var Js_far_bishop:int = 0;
	 private var Js_king_agress:int = 0;

	 private var Js_junk_pawn:int = -15;
	 private var Js_stopped_pawn:int = -4;
	 private var Js_doubled_pawn:int = -14;
	 private var Js_bad_pawn:int = -4;
	 private var Js_semiOpen_rook:int = 10;
	 private var Js_semiOpen_rookOther:int = 4;
	 private var Js_rookPlus:int = 0;
	 private var Js_crossArrow:int = 8;
	 private var Js_pinnedVal:int = 10;
	 private var Js_semiOpen_king:int = 0;
	 private var Js_semiOpen_kingOther:int = 0;
	 private var Js_castle_K:int = 0;
	 private var Js_moveAcross_K:int = 0;
	 private var Js_safe_King:int = 0;

	 private var Js_agress_across:int = -6;
	 private var Js_pinned_p:int = -8;
	 private var Js_pinned_other:int = -12;

	 private var Js_nGameMoves:int = 0;
	 private var Js_depth_Seek:int = 0;
	 private var Js_c1:int = 0;
	 private var Js_c2:int = 0;
	 private var Js_agress2:Array = [];	//int[]
	 private var Js_agress1:Array = [];	//int[]
	 private var Js_ptValue:int = 0;
	 private var Js_flip:Boolean = false;
	 private var Js_fEat:Boolean = false;
	 private var Js_myPiece:String = "";

	 private var Js_fiftyMoves:int = 0;
	 private var Js_indenSqr:int = 0;
	 private var Js_realBestDepth:int = 0;
	 private var Js_realBestScore:int = 0;
	 private var Js_realBestMove:int = 0;
	 private var Js_lastDepth:int = 0;
	 private var Js_lastScore:int = 0;
	 private var Js_fKO:Boolean = false;


	 private var Js_fromMySquare:int = 0;
	 private var Js_toMySquare:int = 0;
	 private var Js_cNodes:int = 0;
	 private var Js_scoreDither:int = 0;
	 private var Js__alpha:int = 0;
	 private var Js__beta:int = 0;
	 private var Js_dxAlphaBeta:int = 0;
	 private var Js_maxDepthSeek:int = 0;
	 private var Js_specialScore:int = 0;
	 private var Js_hint:int = 0;

	 private var Js_currentScore:int = 0;

	 private var Js_proPiece:int = 0;
	 private var Js_pawc1:Array = [];
	 private var Js_pawc2:Array = [];
	 private var Js_origSquare:int = 0;
	 private var Js_destSquare:int = 0;

	 private var Js_cCompNodes:int = 0;
	 private var Js_dxDither:int = 0;
	 private var Js_scoreWin0:int = 0;
	 private var Js_scoreWin1:int = 0;
	 private var Js_scoreWin2:int = 0;
	 private var Js_scoreWin3:int = 0;
	 private var Js_scoreWin4:int = 0;

	 private var Js_USER_TOPLAY:int = 0;
	 private var Js_JESTER_TOPLAY:int = 1;

	 private const Js_hollow:int = 2;
	 private const Js_empty:int = 0;
	 private const Js_pawn:int = 1;
	 private const Js_knight:int = 2;
	 private const Js_bishop:int = 3;
	 private const Js_rook:int = 4;
	 private const Js_queen:int = 5;
	 private const Js_king:int = 6;

	 private const Js_white:int = 0;
	 private const Js_black:int = 1;

	 private const Js_N9:int = 90;

	 private const Js_szIdMvt:String = "ABCDEFGH" + "IJKLMNOP" + "QRSTUVWX" + "abcdefgh" + "ijklmnop" + "qrstuvwx" + "01234567" + "89YZyz*+";
	 private const Js_szAlgMvt:Array = [ "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1", "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2", "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3", "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4", "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5", "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6", "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7", "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8" ];

	 private const Js_color_sq:Array = [ 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0 ];

	 private const Js_bkPawn:int = 7;
	 private const Js_pawn_msk:int = 7;
	 private const Js_promote:int = 8;
	 private const Js_castle_msk:int = 16;
	 private const Js_enpassant_msk:int = 32;
	 private const Js__idem:int = 64;
	 private const Js_menace_pawn:int = 128;
	 private const Js_check:int = 256;
	 private const Js_capture:int = 512;
	 private const Js_draw:int = 1024;
	 private const Js_pawnVal:int = 100;
	 private const Js_knightVal:int = 350;
	 private const Js_bishopVal:int = 355;
	 private const Js_rookVal:int = 550;
	 private const Js_queenVal:int = 1050;
	 private const Js_kingVal:int = 1200;
	 private const Js_xltP:int = 16384;
	 private const Js_xltN:int = 10240;
	 private const Js_xltB:int = 6144;
	 private const Js_xltR:int = 1024;
	 private const Js_xltQ:int = 512;
	 private const Js_xltK:int = 256;
	 private const Js_xltBQ:int = 4608;
	 private const Js_xltBN:int = 2048;
	 private const Js_xltRQ:int = 1536;
	 private const Js_xltNN:int = 8192;

	 private var Js_movesList:Array = [];			//new _MOVES[512];
	 private var Js_flag:GAMESTATS = new GAMESTATS;		//new _GAMESTATS();
	 private var Js_Tree:Array = [];				//new _BTREE[2000];
	 private var Js_root:BTREE = new BTREE;
	 private var Js_tmpTree:BTREE = new BTREE;		//new _BTREE();
	 private var Js_treePoint:Array = [];			//new int[Js_maxDepth];
	 private var Js_board:Array = [];				//new int[64];
	 private var Js_color:Array = [];				//new int[64];
	 private var Js_pieceMap:Array = [[]];			//new int[2][16];
	 private var Js_pawnMap:Array = [[]];			//new int[2][8];
	 private var Js_roquer:Array = [ 0, 0 ];
	 private var Js_nMvtOnBoard:Array = [];			//new int[64];
	 private var Js_scoreOnBoard:Array = [];			//new int[64];
	 private var Js_gainScore:INT = new INT;

	 private const Js_otherTroop:Array = [ 1, 0, 2 ];
	 private var Js_variants:Array = [];			//new int[Js_maxDepth];
	 private var Js_pieceIndex:Array = [];			//new int[64];
	 private var Js_piecesCount:Array = [ 0, 0 ];
	 private var Js_arrowData:Array = [];			//new int[4200];
	 private var Js_crossData:Array = [];			//new int[4200];
	 private var Js_agress:Array = [[]];			//new int[2][64];
	 private var Js_matrl:Array = [ 0, 0 ];
	 private var Js_pmatrl:Array = [ 0, 0 ];
	 private var Js_ematrl:Array = [ 0, 0 ];
	 private var Js_pinned:Array = [ 0, 0 ];
	 private var Js_withPawn:Array = [ 0, 0 ];
	 private var Js_withKnight:Array = [ 0, 0 ];
	 private var Js_withBishop:Array = [ 0, 0 ];
	 private var Js_withRook:Array = [ 0, 0 ];
	 private var Js_withQueen:Array = [ 0, 0 ];
	 private var Js_flagCheck:Array = [];			//new int[Js_maxDepth];
	 private var Js_flagEat:Array = [];			//new int[Js_maxDepth];
	 private var Js_menacePawn:Array = [];			//new int[Js_maxDepth];
	 private var Js_scorePP:Array = [];			//new int[Js_maxDepth];
	 private var Js_scoreTP:Array = [];			//new int[Js_maxDepth];
	 private var Js_eliminate0:Array = [];			//new int[Js_maxDepth]; 
	 private var Js_eliminate1:Array = [];			//new int[Js_maxDepth];
	 private var Js_eliminate2:Array = [];			//new int[Js_maxDepth];
	 private var Js_eliminate3:Array = [];			//new int[Js_maxDepth];
	 private var Js_storage:Array = [];			//new short[10000];
	 private var Js_wPawnMvt:Array = [];			//new int[64];
	 private var Js_bPawnMvt:Array = [];			//new int[64];
	 private var Js_knightMvt:Array = [[]];			//new int[2][64];
	 private var Js_bishopMvt:Array = [[]];			//new int[2][64];
	 private var Js_kingMvt:Array = [[]];			//new int[2][64];
	 private var Js_killArea:Array = [[]];			//new int[2][64];
	 private var Js_fDevl:Array = [ 0, 0 ];
	 private var Js_nextCross:Array = [];			//new char[40000];
	 private var Js_nextArrow:Array = [];			//new char[40000];
	 private var Js_tmpCh:Array = [];				//new char[20];
	 private var Js_movCh:Array = [];				//new char[8];
	 private var Js_b_r:Array = [];				//new int[64];

	 private const Js_upperNot:Array = [ " ", "P", "N", "B", "R", "Q", "K" ];
	 private const Js_lowerNot:Array = [ ' ', 'p', 'n', 'b', 'r', 'q', 'k' ];
	 private const Js_rgszPiece:Array = [ "", "", "N", "B", "R", "Q", "K" ];
	 private var Js_asciiMove:Array = [ [ ' ', ' ', ' ', ' ', ' ', ' ' ], [ ' ', ' ', ' ', ' ', ' ', ' ' ], [ ' ', ' ', ' ', ' ', ' ', ' ' ], [ ' ', ' ', ' ', ' ', ' ', ' ' ] ];
	 private const Js_reguBoard:Array = [ Js_rook, Js_knight, Js_bishop, Js_queen, Js_king, Js_bishop, Js_knight, Js_rook, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_pawn, Js_rook, Js_knight, Js_bishop, Js_queen, Js_king, Js_bishop, Js_knight, Js_rook ];
	 private const Js_reguColor:Array = [ Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, Js_white, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black, Js_black ];
	 private const Js_pieceTyp:Array = [ [ Js_empty, Js_pawn, Js_knight, Js_bishop, Js_rook, Js_queen, Js_king, Js_empty ], [ Js_empty, Js_bkPawn, Js_knight, Js_bishop, Js_rook, Js_queen, Js_king, Js_empty ] ];
	 private const Js_direction:Array = [ [ 0, 0, 0, 0, 0, 0, 0, 0 ], [ 10, 9, 11, 0, 0, 0, 0, 0 ], [ 8, -8, 12, -12, 19, -19, 21, -21 ], [ 9, 11, -9, -11, 0, 0, 0, 0 ], [ 1, 10, -1, -10, 0, 0, 0, 0 ], [ 1, 10, -1, -10, 9, 11, -9, -11 ], [ 1, 10, -1, -10, 9, 11, -9, -11 ], [ -10, -9, -11, 0, 0, 0, 0, 0 ] ];
	 private const Js_maxJobs:Array = [ 0, 2, 1, 7, 7, 7, 1, 2 ];
	 private const Js_virtualBoard:Array = [ -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 0, 1, 2, 3, 4, 5, 6, 7, -1, -1, 8, 9, 10, 11, 12, 13, 14, 15, -1, -1, 16, 17, 18, 19, 20, 21, 22, 23, -1, -1, 24, 25, 26, 27, 28, 29, 30, 31, -1, -1, 32, 33, 34, 35, 36, 37, 38, 39, -1, -1, 40, 41, 42, 43, 44, 45, 46, 47, -1, -1, 48, 49, 50, 51, 52, 53, 54, 55, -1, -1, 56, 57, 58, 59, 60, 61, 62, 63, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1 ];
	 private const Js_start_K:Array = [ 0, 0, -4, -10, -10, -4, 0, 0, -4, -4, -8, -12, -12, -8, -4, -4, -12, -16, -20, -20, -20, -20, -16, -12, -16, -20, -24, -24, -24, -24, -20, -16, -16, -20, -24, -24, -24, -24, -20, -16, -12, -16, -20, -20, -20, -20, -16, -12, -4, -4, -8, -12, -12, -8, -4, -4, 0, 0, -4, -10, -10, -4, 0, 0 ];
	 private const Js_end_K:Array = [ 0, 6, 12, 18, 18, 12, 6, 0, 6, 12, 18, 24, 24, 18, 12, 6, 12, 18, 24, 30, 30, 24, 18, 12, 18, 24, 30, 36, 36, 30, 24, 18, 18, 24, 30, 36, 36, 30, 24, 18, 12, 18, 24, 30, 30, 24, 18, 12, 6, 12, 18, 24, 24, 18, 12, 6, 0, 6, 12, 18, 18, 12, 6, 0 ];
	 private const Js_vanish_K:Array = [ 0, 8, 16, 24, 24, 16, 8, 0, 8, 32, 40, 48, 48, 40, 32, 8, 16, 40, 56, 64, 64, 56, 40, 16, 24, 48, 64, 72, 72, 64, 48, 24, 24, 48, 64, 72, 72, 64, 48, 24, 16, 40, 56, 64, 64, 56, 40, 16, 8, 32, 40, 48, 48, 40, 32, 8, 0, 8, 16, 24, 24, 16, 8, 0 ];
	 private const Js_end_KBNK:Array = [ 99, 90, 80, 70, 60, 50, 40, 40, 90, 80, 60, 50, 40, 30, 20, 40, 80, 60, 40, 30, 20, 10, 30, 50, 70, 50, 30, 10, 0, 20, 40, 60, 60, 40, 20, 0, 10, 30, 50, 70, 50, 30, 10, 20, 30, 40, 60, 80, 40, 20, 30, 40, 50, 60, 80, 90, 40, 40, 50, 60, 70, 80, 90, 99 ];
	 private const Js_knight_pos:Array = [ 0, 4, 8, 10, 10, 8, 4, 0, 4, 8, 16, 20, 20, 16, 8, 4, 8, 16, 24, 28, 28, 24, 16, 8, 10, 20, 28, 32, 32, 28, 20, 10, 10, 20, 28, 32, 32, 28, 20, 10, 8, 16, 24, 28, 28, 24, 16, 8, 4, 8, 16, 20, 20, 16, 8, 4, 0, 4, 8, 10, 10, 8, 4, 0 ];
	 private const Js_bishop_pos:Array = [ 14, 14, 14, 14, 14, 14, 14, 14, 14, 22, 18, 18, 18, 18, 22, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 18, 22, 22, 22, 22, 18, 14, 14, 22, 18, 18, 18, 18, 22, 14, 14, 14, 14, 14, 14, 14, 14, 14 ];
	 private const Js_pawn_pos:Array = [ 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, 4, 0, 0, 4, 4, 4, 6, 8, 2, 10, 10, 2, 8, 6, 6, 8, 12, 16, 16, 12, 8, 6, 8, 12, 16, 24, 24, 16, 12, 8, 12, 16, 24, 32, 32, 24, 16, 12, 12, 16, 24, 32, 32, 24, 16, 12, 0, 0, 0, 0, 0, 0, 0, 0 ];
	 private const Js_valueMap:Array = [ 0, Js_pawnVal, Js_knightVal, Js_bishopVal, Js_rookVal, Js_queenVal, Js_kingVal ];
	 private const Js_xlat:Array = [ 0, Js_xltP, Js_xltN, Js_xltB, Js_xltR, Js_xltQ, Js_xltK ];
	 private const Js_pss_pawn0:Array = [ 0, 60, 80, 120, 200, 360, 600, 800 ];
	 private const Js_pss_pawn1:Array = [ 0, 30, 40, 60, 100, 180, 300, 800 ];
	 private const Js_pss_pawn2:Array = [ 0, 15, 25, 35, 50, 90, 140, 800 ];
	 private const Js_pss_pawn3:Array = [ 0, 5, 10, 15, 20, 30, 140, 800 ];
	 private const Js_isol_pawn:Array = [ -12, -16, -20, -24, -24, -20, -16, -12 ];
	 private const Js_takeBack:Array = [ -6, -10, -15, -21, -28, -28, -28, -28, -28, -28, -28, -28, -28, -28, -28, -28 ];
	 private const Js_mobBishop:Array = [ -2, 0, 2, 4, 6, 8, 10, 12, 13, 14, 15, 16, 16, 16 ];
	 private const Js_mobRook:Array = [ 0, 2, 4, 6, 8, 10, 11, 12, 13, 14, 14, 14, 14, 14, 14 ];
	 private const Js_menaceKing:Array = [ 0, -8, -20, -36, -52, -68, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80, -80 ];
	 private const Js_queenRook:Array = [ 0, 56, 0 ];
	 private const Js_kingRook:Array = [ 7, 63, 0 ];
	 private const Js_kingPawn:Array = [ 4, 60, 0 ];
	 private const Js_raw7:Array = [ 6, 1, 0 ];
	 private const Js_heavy:Array = [ false, false, false, true, true, true, false, false ];

	 private const Js_AUTHOR:String = "Copyright © 1998-2002 - Stephane N.B. Nguyen - Vaureal, FRANCE";
	 private const Js_WEBSITE:String = "http://www.ludochess.com/";
	 private const Js_STR_COPY:String = "JESTER 1.10e by " + Js_AUTHOR + Js_WEBSITE;


	private function BoardCpy(a:Array, b:Array):void
	{
	  var sq:int = 0;
	  do b[sq] = a[sq]; while (++sq < 64);
	}
	 
	private function WatchPosit():void
	{
	  var PawnStorm:Boolean = false;
	  var i:int=0; 
	  Agression(this.Js_white, this.Js_agress[this.Js_white]);
	  Agression(this.Js_black, this.Js_agress[this.Js_black]);
	 
	  ChangeForce();
	  this.Js_withKnight[this.Js_white] = 0;
	  this.Js_withKnight[this.Js_black] = 0;
	  this.Js_withBishop[this.Js_white] = 0;
	  this.Js_withBishop[this.Js_black] = 0;
	  this.Js_withRook[this.Js_white] = 0;
	  this.Js_withRook[this.Js_black] = 0;
	  this.Js_withQueen[this.Js_white] = 0;
	  this.Js_withQueen[this.Js_black] = 0;
	  this.Js_withPawn[this.Js_white] = 0;
	  this.Js_withPawn[this.Js_black] = 0;
	  for (var side:int = this.Js_white; side <= this.Js_black; ++side) {
	    for (i = this.Js_piecesCount[side]; i >= 0; --i)
	    {
	      var b:int = this.Js_board[this.Js_pieceMap[side][i]];
	      if (b == this.Js_knight)
	        this.Js_withKnight[side] += 1;
	      else if (b == this.Js_bishop)
	        this.Js_withBishop[side] += 1;
	      else if (b == this.Js_rook)
	        this.Js_withRook[side] += 1;
	      else if (b == this.Js_queen)
	        this.Js_withQueen[side] += 1;
	      else if (b == this.Js_pawn) {
	        this.Js_withPawn[side] += 1;
	      }
	    }
	  }
	 
	  if (this.Js_fDevl[this.Js_white] == 0)
	  {
	    this.Js_fDevl[this.Js_white] = (((this.Js_board[1] == this.Js_knight) || (this.Js_board[2] == this.Js_bishop) || (this.Js_board[5] == this.Js_bishop) || (this.Js_board[6] == this.Js_knight)) ? 0 : 1);
	  }
	 
	  if (this.Js_fDevl[this.Js_black] == 0)
	  {
	    this.Js_fDevl[this.Js_black] = (((this.Js_board[57] == this.Js_knight) || (this.Js_board[58] == this.Js_bishop) || (this.Js_board[61] == this.Js_bishop) || (this.Js_board[62] == this.Js_knight)) ? 0 : 1);
	  }
	 
	  if ((!(PawnStorm)) && (this.Js_working < 5))
	  {
	    PawnStorm = ((IColmn(this.Js_pieceMap[this.Js_white][0]) < 3) && (IColmn(this.Js_pieceMap[this.Js_black][0]) > 4)) || (
	      (IColmn(this.Js_pieceMap[this.Js_white][0]) > 4) && (IColmn(this.Js_pieceMap[this.Js_black][0]) < 3));
	  }
	 
	  //BoardCpy(this.Js_knight_pos, this.Js_knightMvt[this.Js_white]);
	  //BoardCpy(this.Js_knight_pos, this.Js_knightMvt[this.Js_black]);
	  //BoardCpy(this.Js_bishop_pos, this.Js_bishopMvt[this.Js_white]);
	  //BoardCpy(this.Js_bishop_pos, this.Js_bishopMvt[this.Js_black]);

	  //slice is faster
	  this.Js_knightMvt[this.Js_white] = this.Js_knight_pos.slice();
	  this.Js_knightMvt[this.Js_black] = this.Js_knight_pos.slice();
	  this.Js_bishopMvt[this.Js_white] = this.Js_bishop_pos.slice();
	  this.Js_bishopMvt[this.Js_black] = this.Js_bishop_pos.slice();

	  MixBoard(this.Js_start_K, this.Js_end_K, this.Js_kingMvt[this.Js_white]);
	  MixBoard(this.Js_start_K, this.Js_end_K, this.Js_kingMvt[this.Js_black]);
	 
	  var sq:int = 0;
	  do {
	    var fyle:int = IColmn(sq);
	    var rank:int = IRaw(sq);
	    var bstrong:int = 1;
	    var wstrong:int = 1;
	    for (i = sq; i < 64; i += 8) {
	      if (!(Pagress(this.Js_black, i)))
	        continue;
	      wstrong = 0;
	      break;
	    }
	    for (i = sq; i >= 0; i -= 8) {
	      if (!(Pagress(this.Js_white, i)))
	        continue;
	      bstrong = 0;
	      break;
	    }
	    var bpadv:int = this.Js_advX_pawn;
	    var wpadv:int = this.Js_advX_pawn;
	    if ((((fyle == 0) || (this.Js_pawnMap[this.Js_white][(fyle - 1)] == 0))) && ((
	      (fyle == 7) || (this.Js_pawnMap[this.Js_white][(fyle + 1)] == 0))))
	      wpadv = this.Js_isoX_pawn;
	    if ((((fyle == 0) || (this.Js_pawnMap[this.Js_black][(fyle - 1)] == 0))) && ((
	      (fyle == 7) || (this.Js_pawnMap[this.Js_black][(fyle + 1)] == 0))))
	      bpadv = this.Js_isoX_pawn;
	    this.Js_wPawnMvt[sq] = (wpadv * this.Js_pawn_pos[sq] / 10);
	    this.Js_bPawnMvt[sq] = (bpadv * this.Js_pawn_pos[(63 - sq)] / 10);
	    this.Js_wPawnMvt[sq] += this.Js_pawnPlus;
	    this.Js_bPawnMvt[sq] += this.Js_pawnPlus;
	    if (this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_white]] != 0)
	    {
	      if ((((fyle < 3) || (fyle > 4))) && (IArrow(sq, this.Js_pieceMap[this.Js_white][0]) < 3))
	        this.Js_wPawnMvt[sq] += this.Js_castle_pawn;
	    }
	    else if ((rank < 3) && (((fyle < 2) || (fyle > 5))))
	      this.Js_wPawnMvt[sq] += this.Js_castle_pawn / 2;
	    if (this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_black]] != 0)
	    {
	      if ((((fyle < 3) || (fyle > 4))) && (IArrow(sq, this.Js_pieceMap[this.Js_black][0]) < 3))
	        this.Js_bPawnMvt[sq] += this.Js_castle_pawn;
	    }
	    else if ((rank > 4) && (((fyle < 2) || (fyle > 5))))
	      this.Js_bPawnMvt[sq] += this.Js_castle_pawn / 2;
	    if (PawnStorm)
	    {
	      if (((IColmn(this.Js_pieceMap[this.Js_white][0]) < 4) && (fyle > 4)) || (
	        (IColmn(this.Js_pieceMap[this.Js_white][0]) > 3) && (fyle < 3)))
	        this.Js_wPawnMvt[sq] += 3 * rank - 21;
	      if (((IColmn(this.Js_pieceMap[this.Js_black][0]) < 4) && (fyle > 4)) || (
	        (IColmn(this.Js_pieceMap[this.Js_black][0]) > 3) && (fyle < 3)))
	        this.Js_bPawnMvt[sq] -= 3 * rank;
	    }
	    this.Js_knightMvt[this.Js_white][sq] += 5 - IArrow(sq, this.Js_pieceMap[this.Js_black][0]);
	    this.Js_knightMvt[this.Js_white][sq] += 5 - IArrow(sq, this.Js_pieceMap[this.Js_white][0]);
	    this.Js_knightMvt[this.Js_black][sq] += 5 - IArrow(sq, this.Js_pieceMap[this.Js_white][0]);
	    this.Js_knightMvt[this.Js_black][sq] += 5 - IArrow(sq, this.Js_pieceMap[this.Js_black][0]);
	    this.Js_bishopMvt[this.Js_white][sq] += this.Js_bishopPlus;
	    this.Js_bishopMvt[this.Js_black][sq] += this.Js_bishopPlus;
	
	    for (i = this.Js_piecesCount[this.Js_black]; i >= 0; --i)
	    {
	      var pMap2:int = this.Js_pieceMap[this.Js_black][i];
	      if (IArrow(sq, pMap2) < 3)
	        this.Js_knightMvt[this.Js_white][sq] += this.Js_adv_knight;
	    }
	    for (i = this.Js_piecesCount[this.Js_white]; i >= 0; --i)
	    {
	      pMap2 = this.Js_pieceMap[this.Js_white][i];
	      if (IArrow(sq, pMap2) < 3) {
	        this.Js_knightMvt[this.Js_black][sq] += this.Js_adv_knight;
	      }
	    }
	 
	    if (wstrong != 0)
	      this.Js_knightMvt[this.Js_white][sq] += this.Js_far_knight;
	    if (bstrong != 0) {
	      this.Js_knightMvt[this.Js_black][sq] += this.Js_far_knight;
	    }
	    if (wstrong != 0)
	      this.Js_bishopMvt[this.Js_white][sq] += this.Js_far_bishop;
	    if (bstrong != 0) {
	      this.Js_bishopMvt[this.Js_black][sq] += this.Js_far_bishop;
	    }
	 
	    if (this.Js_withBishop[this.Js_white] == 2)
	      this.Js_bishopMvt[this.Js_white][sq] += 8;
	    if (this.Js_withBishop[this.Js_black] == 2)
	      this.Js_bishopMvt[this.Js_black][sq] += 8;
	    if (this.Js_withKnight[this.Js_white] == 2)
	      this.Js_knightMvt[this.Js_white][sq] += 5;
	    if (this.Js_withKnight[this.Js_black] == 2) {
	      this.Js_knightMvt[this.Js_black][sq] += 5;
	    }
	    this.Js_killArea[this.Js_white][sq] = 0;
	    this.Js_killArea[this.Js_black][sq] = 0;
	    if (IArrow(sq, this.Js_pieceMap[this.Js_white][0]) == 1)
	      this.Js_killArea[this.Js_black][sq] = this.Js_king_agress;
	    if (IArrow(sq, this.Js_pieceMap[this.Js_black][0]) == 1) {
	      this.Js_killArea[this.Js_white][sq] = this.Js_king_agress;
	    }
	    var Pd:int = 0;
	    var pp:int;
	    var z:int;
	    var j:int;
	    for (var k:int = 0; k <= this.Js_piecesCount[this.Js_white]; ++k)
	    {
	      i = this.Js_pieceMap[this.Js_white][k];
	      if (this.Js_board[i] != this.Js_pawn)
	        continue;
	      pp = 1;
	      if (IRaw(i) == 6)
	        z = i + 8;
	      else
	        z = i + 16;
	      for (j = i + 8; j < 64; j += 8) {
	        if ((!(Pagress(this.Js_black, j))) && (this.Js_board[j] != this.Js_pawn))
	          continue;
	        pp = 0;
	        break;
	      }
	      if (pp != 0)
	        Pd += 5 * this.Js_crossData[(sq * 64 + z)];
	      else {
	        Pd += this.Js_crossData[(sq * 64 + z)];
	      }
	    }
	    for (k = 0; k <= this.Js_piecesCount[this.Js_black]; ++k)
	    {
	      i = this.Js_pieceMap[this.Js_black][k];
	      if (this.Js_board[i] != this.Js_pawn)
	        continue;
	      pp = 1;
	      if (IRaw(i) == 1)
	        z = i - 8;
	      else
	        z = i - 16;
	      for (j = i - 8; j >= 0; j -= 8) {
	        if ((!(Pagress(this.Js_white, j))) && (this.Js_board[j] != this.Js_pawn))
	          continue;
	        pp = 0;
	        break;
	      }
	      if (pp != 0)
	        Pd += 5 * this.Js_crossData[(sq * 64 + z)];
	      else {
	        Pd += this.Js_crossData[(sq * 64 + z)];
	      }
	    }
	    if (Pd == 0)
	      continue;
	    var val:int = Pd * this.Js_working2 / 10;
	    this.Js_kingMvt[this.Js_white][sq] -= val;
	    this.Js_kingMvt[this.Js_black][sq] -= val;
	  }
	  while (++sq < 64);
	}
	 
	 
	private function CalcKBNK(winner:int, king1:int, king2:int):int
	{
	  var end_KBNKsq:int = 0;
	 
	  var sq:int = 0;
	  do
	    if (this.Js_board[sq] == this.Js_bishop)
	      if (IRaw(sq) % 2 == IColmn(sq) % 2)
	        end_KBNKsq = 0;
	      else
	        end_KBNKsq = 7;
	  while (++sq < 64);
	 
	  var s:int = this.Js_ematrl[winner] - 300;
	  if (end_KBNKsq == 0)
	    s += this.Js_end_KBNK[king2];
	  else
	    s += this.Js_end_KBNK[Iwxy(IRaw(king2), 7 - IColmn(king2))];
	  s -= this.Js_crossData[(king1 * 64 + king2)];
	  s -= IArrow(this.Js_pieceMap[winner][1], king2);
	  s -= IArrow(this.Js_pieceMap[winner][2], king2);
	  return s;
	}
	 
	 
	private function ChangeForce():void
	{
	  this.Js_ematrl[this.Js_white] = (this.Js_matrl[this.Js_white] - this.Js_pmatrl[this.Js_white] - this.Js_kingVal);
	  this.Js_ematrl[this.Js_black] = (this.Js_matrl[this.Js_black] - this.Js_pmatrl[this.Js_black] - this.Js_kingVal);
	  var tmatrl:int = this.Js_ematrl[this.Js_white] + this.Js_ematrl[this.Js_black];
	  var s1:int = (tmatrl < 1400) ? 10 : (tmatrl > 6600) ? 0 : (6600 - tmatrl) / 520;
	  if (s1 == this.Js_working)
	    return;
	  this.Js_working = s1;
	  this.Js_working2 = ((tmatrl < 1400) ? 10 : (tmatrl > 3600) ? 0 : (3600 - tmatrl) / 220);
	  
	  this.Js_castle_pawn = (10 - this.Js_working);

	  this.Js_pawnPlus = this.Js_working;
	 
	  this.Js_adv_knight = ((this.Js_working + 2) / 3);
	  this.Js_far_knight = ((this.Js_working + 6) / 2);
	 
	  this.Js_far_bishop = ((this.Js_working + 6) / 2);
	  this.Js_bishopPlus = (2 * this.Js_working);
	 
	  this.Js_rookPlus = (6 * this.Js_working);
	 
	  this.Js_semiOpen_king = ((3 * this.Js_working - 30) / 2);
	  this.Js_semiOpen_kingOther = (this.Js_semiOpen_king / 2);
	  this.Js_castle_K = (10 - this.Js_working);
	  this.Js_moveAcross_K = (-40 / (this.Js_working + 1));
	  this.Js_king_agress = ((10 - this.Js_working) / 2);
	  if (this.Js_working < 8)
	    this.Js_safe_King = (16 - (2 * this.Js_working));
	  else {
	    this.Js_safe_King = 0;
	  }

	}
	 
	 
	private function Undo():void
	{
	  var f:int = this.Js_movesList[this.Js_nGameMoves].gamMv >> 8;
	  var t:int = this.Js_movesList[this.Js_nGameMoves].gamMv & 0xFF;
	  if ((this.Js_board[t] == this.Js_king) && (IArrow(t, f) > 1))
	  {
	    DoCastle(this.Js_movesList[this.Js_nGameMoves].color, f, t, 2);
	  }
	  else
	  {
	    if (((this.Js_color[t] == this.Js_white) && (IRaw(f) == 6) && (IRaw(t) == 7)) || (
	      (this.Js_color[t] == this.Js_black) && (IRaw(f) == 1) && (IRaw(t) == 0)))
	    {
	      var from:int = f;
	      for (var g:int = this.Js_nGameMoves - 1; g > 0; --g)
	      {
	        if ((this.Js_movesList[g].gamMv & 0xFF) != from)
	          continue;
	        from = this.Js_movesList[g].gamMv >> 8;
	      }
	 
	      if (((this.Js_color[t] == this.Js_white) && (IRaw(from) == 1)) || ((this.Js_color[t] == this.Js_black) && (IRaw(from) == 6)))
	      {
	        this.Js_board[t] = this.Js_pawn;
	      }
	    }
	    this.Js_board[f] = this.Js_board[t];
	    this.Js_color[f] = this.Js_color[t];
	    this.Js_board[t] = this.Js_movesList[this.Js_nGameMoves].piece;
	    this.Js_color[t] = this.Js_movesList[this.Js_nGameMoves].color;
	    if (this.Js_color[t] != this.Js_hollow) this.Js_nMvtOnBoard[t] += -1;
	    this.Js_nMvtOnBoard[f] += -1;
	  }
	 
	  this.Js_nGameMoves += -1;
	  if( this.Js_fiftyMoves < this.Js_nGameMoves ) this.Js_fiftyMoves = this.Js_nGameMoves;

	  this.Js_computer = this.Js_otherTroop[this.Js_computer];
	  this.Js_enemy = this.Js_otherTroop[this.Js_enemy];
	  this.Js_flag.mate = false;
	  this.Js_depth_Seek = 0;

	  UpdateDisplay();

	  InitStatus();
			
	}
	 
	private function ISqAgrs(sq:int,side:int):int
	{
	  var xside:int = this.Js_otherTroop[side];
	 
	  var idir:int = this.Js_pieceTyp[xside][this.Js_pawn] * 64 * 64 + sq * 64;
	 
	  var u:int = this.Js_nextArrow[(idir + sq)];
	  if (u != sq)
	  {
	    if ((this.Js_board[u] == this.Js_pawn) && (this.Js_color[u] == side)) {
	      return 1;
	    }
	    u = this.Js_nextArrow[(idir + u)];
	    if ((u != sq) && (this.Js_board[u] == this.Js_pawn) && (this.Js_color[u] == side)) {
	      return 1;
	    }
	  }
	  if (IArrow(sq, this.Js_pieceMap[side][0]) == 1) {
	    return 1;
	  }
	 
	  var ipos:int = this.Js_bishop * 64 * 64 + sq * 64;
	  idir = ipos;
	 
	  u = this.Js_nextCross[(ipos + sq)];
	  do if (this.Js_color[u] == this.Js_hollow)
	    {
	      u = this.Js_nextCross[(ipos + u)];
	    }
	    else {
	      if ((this.Js_color[u] == side) && (((this.Js_board[u] == this.Js_queen) || (this.Js_board[u] == this.Js_bishop)))) {
	        return 1;
	      }
	      u = this.Js_nextArrow[(idir + u)];
	    }
	 
	  while (u != sq);
	 
	  ipos = this.Js_rook * 64 * 64 + sq * 64;
	  idir = ipos;
	 
	  u = this.Js_nextCross[(ipos + sq)];
	  do if (this.Js_color[u] == this.Js_hollow)
	    {
	      u = this.Js_nextCross[(ipos + u)];
	    }
	    else {
	      if ((this.Js_color[u] == side) && (((this.Js_board[u] == this.Js_queen) || (this.Js_board[u] == this.Js_rook)))) {
	        return 1;
	      }
	      u = this.Js_nextArrow[(idir + u)];
	    }
	 
	  while (u != sq);
	 
	  idir = this.Js_knight * 64 * 64 + sq * 64;
	 
	  u = this.Js_nextArrow[(idir + sq)];
	  do { if ((this.Js_color[u] == side) && (this.Js_board[u] == this.Js_knight))
	    {
	      return 1;
	    }
	    u = this.Js_nextArrow[(idir + u)];
	  }
	  while (u != sq);
	  return 0;
	}
	 
	private function Iwxy(a:int,b:int):int
	{
	  return (a << 3 | b);
	}
	 
	private function XRayBR(sq:int, s:INT, mob:INT):void
	{
	  var Kf:Array = this.Js_killArea[this.Js_c1];
	  mob.i = 0;
	  var piece:int = this.Js_board[sq];
	 
	  var ipos:int = piece * 64 * 64 + sq * 64;
	  var idir:int = ipos;
	 
	  var u:int = this.Js_nextCross[(ipos + sq)];
	  var pin:int = -1;
	  do { s.i += Kf[u];
	 
	    if (this.Js_color[u] == this.Js_hollow)
	    {
	      mob.i += 1;
	 
	      if (this.Js_nextCross[(ipos + u)] == this.Js_nextArrow[(idir + u)])
	        pin = -1;
	      u = this.Js_nextCross[(ipos + u)];
	    }
	    else if (pin < 0)
	    {
	      if ((this.Js_board[u] == this.Js_pawn) || (this.Js_board[u] == this.Js_king)) {
	        u = this.Js_nextArrow[(idir + u)];
	      }
	      else {
	        if (this.Js_nextCross[(ipos + u)] != this.Js_nextArrow[(idir + u)])
	          pin = u;
	        u = this.Js_nextCross[(ipos + u)];
	      }
	    }
	    else
	    {
	      if ((this.Js_color[u] == this.Js_c2) && (((this.Js_board[u] > piece) || (this.Js_agress2[u] == 0))))
	      {
	        if (this.Js_color[pin] == this.Js_c2)
	        {
	          s.i += this.Js_pinnedVal;
	          if ((this.Js_agress2[pin] == 0) || (this.Js_agress1[pin] > this.Js_xlat[this.Js_board[pin]] + 1))
	            this.Js_pinned[this.Js_c2] += 1;
	        }
	        else {
	          s.i += this.Js_crossArrow; }
	      }
	      pin = -1;
	      u = this.Js_nextArrow[(idir + u)];
	    }
	  }
	  while (u != sq);
	}
	 
	private function ComputerMvt():void
	{
	  if (this.Js_flag.mate) {
	    return;
	  }
	  this.Js_startTime = (new Date()).getTime();

	  ChoiceMov(this.Js_computer, 1)
	  IfCheck();
	  if (!(this.Js_fUserWin_kc)) ShowMov(this.Js_asciiMove[0]);
	  if (!(CheckMatrl())) this.Js_bDraw = 1;
	  ShowStat();

	}
	 
	private function InitMoves():void {
	  var dest:Array = [[]];
	  var steps:Array = [];
	  var sorted:Array = [];
	 
	  var ptyp:int = 0;
	  var po:int;
	  var p0:int;
	  do { po = 0;
	    do { p0 = 0;
	      do {
	        var i:int = ptyp * 64 * 64 + po * 64 + p0;
	        this.Js_nextCross[i] = po;	//(char)
	        this.Js_nextArrow[i] = po;	//(char)
	      }
	      while (++p0 < 64);
	    }
	    while (++po < 64);
	  }
	  while (++ptyp < 8);
	 
	  ptyp = 1;
	  do { po = 21;
	    do { if (this.Js_virtualBoard[po] < 0) {
	        continue;
	      }
	 
	      var ipos:int = ptyp * 64 * 64 + this.Js_virtualBoard[po] * 64;
	 
	      var idir:int = ipos;
	 
	      var d:int = 0;
	      var di:int = 0;
	        
	      var s:int;
	      do
	      {
	        dest[d] = [];				// creates object
	        dest[d][0] = this.Js_virtualBoard[po];
	        var delta:int = this.Js_direction[ptyp][d];
	        if (delta != 0)
	        {
	          p0 = po;
	          for (s = 0; s < this.Js_maxJobs[ptyp]; ++s)
	          {
	            p0 += delta;
	 
	            if ((this.Js_virtualBoard[p0] < 0) || (
	              (((ptyp == this.Js_pawn) || (ptyp == this.Js_bkPawn))) && (s > 0) && (((d > 0) || (this.Js_reguBoard[this.Js_virtualBoard[po]] != this.Js_pawn))))) {
	              break;
	            }
	            dest[d][s] = this.Js_virtualBoard[p0];
	          }
	        }
	        else {
	          s = 0;
	        }
	 
	        steps[d] = s;
		     for (di = d; (s > 0) && (di > 0); --di)
	          if (steps[sorted[(di - 1)]] == 0)
	            sorted[di] = sorted[(di - 1)];
	          else
	            break;
	        sorted[di] = d;
	      }
	      while (++d < 8);
	 
	      p0 = this.Js_virtualBoard[po];
	      if ((ptyp == this.Js_pawn) || (ptyp == this.Js_bkPawn))
	      {
	        for (s = 0; s < steps[0]; ++s)
	        {
	          this.Js_nextCross[(ipos + p0)] = dest[0][s];			//(char)
	          p0 = dest[0][s];
	        }
	        p0 = this.Js_virtualBoard[po];
	        d = 1;
	        do
	        {
	          this.Js_nextArrow[(idir + p0)] = dest[d][0];			//(char)
	          p0 = dest[d][0];
	        }
	        while (++d < 3);
	      }
	      else
	      {
	        this.Js_nextArrow[(idir + p0)] = dest[sorted[0]][0];			//(char)
	        d = 0;
	        do for (s = 0; s < steps[sorted[d]]; ++s)
	          {
	            this.Js_nextCross[(ipos + p0)] = dest[sorted[d]][s];		//(char)
	            p0 = dest[sorted[d]][s];
	            if (d >= 7)
	              continue;
	            this.Js_nextArrow[(idir + p0)] = dest[sorted[(d + 1)]][0];	//(char)
	          }
	        while (++d < 8);
	      }
	    }
	    while (++po < 99);
	  }
	  while (++ptyp < 8);
	}
	 
	private function ShowMov(rgchMove:Array):void
	{
	  var fKcastle:Boolean = false;
	  var fQcastle:Boolean = false;
	 
	  var i:int = 0;
	  do this.Js_movCh[i] = ' '; while (++i < 8);
	 
	  var szat:int = 0;
	  var szM:String = "";
	  if (!(this.Js_flip))
	  {
	    this.Js_nMovesMade += 1;
	    if (this.Js_nMovesMade < 10) szM = " ";
	    szM = szM + this.Js_nMovesMade + ".";
		szat = szM.length;
	  }
	 
	  this.Js_movCh[0] = rgchMove[0];
	  this.Js_movCh[1] = rgchMove[1];
	  this.Js_movCh[2] = '-';
	
	  if ((this.Js_root.flags & this.Js_capture) != 0 || this.Js_fEat) this.Js_movCh[2] = 'x';
	  
	  this.Js_movCh[3] = rgchMove[2];
	  this.Js_movCh[4] = rgchMove[3];

	  var waspromo:String = (((this.Js_root.flags & this.Js_promote) != 0) ? this.Js_upperNot[this.Js_board[this.Js_root.t]] : "" );
	  if( rgchMove[4] == "=" ) waspromo = rgchMove[5];

	  i = 5;
	  if (waspromo.length>0 )
	  {
	    this.Js_movCh[(i++)] = '=';
	    this.Js_movCh[(i++)] = waspromo;
	  }
	  if (this.Js_bDraw != 0) this.Js_movCh[i] = '=';
	  if (this.Js_fCheck_kc) this.Js_movCh[i] = '+';
	  if (this.Js_fMate_kc) this.Js_movCh[i] = '#';

	  var mv2:String = copyValueOf(this.Js_movCh);
	  if (this.Js_myPiece == 'K')
	  {
	    if ((mv2=="e1-g1") || (mv2=="e8-g8")) fKcastle = true;
	    if ((mv2=="e1-c1") || (mv2=="e8-c8")) fQcastle = true;
	  }
	 
	  if ((fKcastle) || (fQcastle))
	  {
	    if (fKcastle) szM += "O-O" + this.Js_movCh[i];
	    if (fQcastle) szM += "O-O-O" + this.Js_movCh[i];
	  }
	  else
	  {
	    szM += this.Js_myPiece + mv2;
	  }
	  szM += " ";

	  if (this.Js_fAbandon) szM = "resign";
	  this.Js_myPiece = "";
	  MessageOut(szM, this.Js_flip);
	  
	  CallingJS("MOVING", mv2);		//szM.substr(szat)

	  this.Js_flip = (!(this.Js_flip));
	}
	 
	private function CheckMov(s:Array, iop:int):int
	{
	  var tempb:INT = new INT;
	  var tempc:INT = new INT;
	  var tempsf:INT = new INT;
	  var tempst:INT = new INT;
	  var xnode:BTREE = new BTREE;
	 
	  var cnt:int = 0;
	  var pnt:int = 0;
	 

	  if (iop == 2)
	  {
	    UnValidateMov(this.Js_enemy, xnode, tempb, tempc, tempsf, tempst);
	    return 0;
	  }
	  cnt = 0;
	  AvailMov(this.Js_enemy, 2);
	  pnt = this.Js_treePoint[2];
	  var s0:String = copyValueOf(s);
	  while (pnt < this.Js_treePoint[3])
	  {
	    var node:BTREE = this.Js_Tree[(pnt++)];	// _BTREE

	    Lalgb(node.f, node.t, node.flags);
	    var s1:String = copyValueOf(this.Js_asciiMove[0]);
	    if ((((s[0] != this.Js_asciiMove[0][0]) || (s[1] != this.Js_asciiMove[0][1]) || (s[2] != this.Js_asciiMove[0][2]) || (s[3] != this.Js_asciiMove[0][3]))) && 
	      (((s[0] != this.Js_asciiMove[1][0]) || (s[1] != this.Js_asciiMove[1][1]) || (s[2] != this.Js_asciiMove[1][2]) || (s[3] != this.Js_asciiMove[1][3]))) && 
	      (((s[0] != this.Js_asciiMove[2][0]) || (s[1] != this.Js_asciiMove[2][1]) || (s[2] != this.Js_asciiMove[2][2]) || (s[3] != this.Js_asciiMove[2][3]))) && ((
	      (s[0] != this.Js_asciiMove[3][0]) || (s[1] != this.Js_asciiMove[3][1]) || (s[2] != this.Js_asciiMove[3][2]) || (s[3] != this.Js_asciiMove[3][3]))))
	      continue;
	    ++cnt;

	    xnode = node;

	    break;
	  }
	 
	  if (cnt == 1)
	  {
	    ValidateMov(this.Js_enemy, xnode, tempb, tempc, tempsf, tempst, this.Js_gainScore);
	    if (ISqAgrs(this.Js_pieceMap[this.Js_enemy][0], this.Js_computer) != 0)
	    {
	      UnValidateMov(this.Js_enemy, xnode, tempb, tempc, tempsf, tempst);
	 
	      return 0;
	    }
	 
	    if (iop == 1) return 1;
	 
	    UpdateDisplay();

	    this.Js_fEat = ((xnode.flags & this.Js_capture) != 0);
	    if ((this.Js_board[xnode.t] == this.Js_pawn) || ((xnode.flags & this.Js_capture) != 0) || ((xnode.flags & this.Js_castle_msk) != 0))
	    {
	      this.Js_fiftyMoves = this.Js_nGameMoves;
	    }
	 
	    this.Js_movesList[this.Js_nGameMoves].score = 0;
	 
	    Lalgb(xnode.f, xnode.t, 0);
	    return 1;
	  }
	 
	  return 0;
	}
	 	 
 
	private function GetRnd(iVal:int):int
	{
	  return Math.round( (Math.random() * 32000) % iVal);		// (int)	
	}
	 
	private function UnValidateMov(side:int, node:BTREE, tempb:INT, tempc:INT, tempsf:INT, tempst:INT):void
	{
	  var xside:int = this.Js_otherTroop[side];
	  var f:int = node.f;
	  var t:int = node.t;
	  this.Js_indenSqr = -1;
	  this.Js_nGameMoves += -1;
	  if ((node.flags & this.Js_castle_msk) != 0) {
	    DoCastle(side, f, t, 2);
	  }
	  else {
	    this.Js_color[f] = this.Js_color[t];
	    this.Js_board[f] = this.Js_board[t];
	    this.Js_scoreOnBoard[f] = tempsf.i;
	    this.Js_pieceIndex[f] = this.Js_pieceIndex[t];
	    this.Js_pieceMap[side][this.Js_pieceIndex[f]] = f;
	    this.Js_color[t] = tempc.i;
	    this.Js_board[t] = tempb.i;
	    this.Js_scoreOnBoard[t] = tempst.i;
	    if ((node.flags & this.Js_promote) != 0)
	    {
	      this.Js_board[f] = this.Js_pawn;
	      this.Js_pawnMap[side][IColmn(t)] += 1;
	      this.Js_matrl[side] += (this.Js_pawnVal - this.Js_valueMap[(node.flags & this.Js_pawn_msk)]);
	      this.Js_pmatrl[side] += this.Js_pawnVal;
	    }
	 
	    if (tempc.i != this.Js_hollow)
	    {
	      UpdatePiecMap(tempc.i, t, 2);
	      if (tempb.i == this.Js_pawn)
	        this.Js_pawnMap[tempc.i][IColmn(t)] += 1;
	      if (this.Js_board[f] == this.Js_pawn)
	      {
	        this.Js_pawnMap[side][IColmn(t)] += -1;
	        this.Js_pawnMap[side][IColmn(f)] += 1;
	      }
	      this.Js_matrl[xside] += this.Js_valueMap[tempb.i];
	      if (tempb.i == this.Js_pawn) {
	        this.Js_pmatrl[xside] += this.Js_pawnVal;
	      }
	 
	      this.Js_nMvtOnBoard[t] += -1;
	    }
	    if ((node.flags & this.Js_enpassant_msk) != 0) {
	      PrisePassant(xside, f, t, 2);
	    }
	 
	    this.Js_nMvtOnBoard[f] += -1;

	  }
	}
	 
	private function FJunk(sq:int):Boolean
	{
	  var piece:int = this.Js_board[sq];
	  var ipos:int = this.Js_pieceTyp[this.Js_c1][piece] * 64 * 64 + sq * 64;
	  var idir:int = ipos;
	  var u:int;
	  if (piece == this.Js_pawn)
	  {
	    u = this.Js_nextCross[(ipos + sq)];
	    if (this.Js_color[u] == this.Js_hollow)
	    {
	      if (this.Js_agress1[u] >= this.Js_agress2[u])
	        return false;
	      if (this.Js_agress2[u] < this.Js_xltP)
	      {
	        u = this.Js_nextCross[(ipos + u)];
	        if ((this.Js_color[u] == this.Js_hollow) && (this.Js_agress1[u] >= this.Js_agress2[u]))
	          return false;
	      }
	    }
	    u = this.Js_nextArrow[(idir + sq)];
	    if (this.Js_color[u] == this.Js_c2) return false;
	    u = this.Js_nextArrow[(idir + u)];
	    if (this.Js_color[u] == this.Js_c2) return false;
	  }
	  else
	  {
	    u = this.Js_nextCross[(ipos + sq)];
	    do { if ((this.Js_color[u] != this.Js_c1) && ((
	        (this.Js_agress2[u] == 0) || (this.Js_board[u] >= piece)))) {
	        return false;
	      }
	      if (this.Js_color[u] == this.Js_hollow)
	        u = this.Js_nextCross[(ipos + u)];
	      else
	        u = this.Js_nextArrow[(idir + u)];
	    }
	    while (u != sq);
	  }
	  return true;
	}
	 
	private function ShowThink(score4:int, best:Array):void
	{
	  if (this.Js_depth_Seek > this.Js_realBestDepth) this.Js_realBestScore = -20000;
	  if ((this.Js_depth_Seek >= this.Js_realBestDepth) && (score4 >= this.Js_realBestScore))
	  {
	    this.Js_realBestDepth = this.Js_depth_Seek;
	    this.Js_realBestScore = score4;
	    this.Js_realBestMove = best[1];
	  }
	 
	  if ((this.Js_depth_Seek == this.Js_lastDepth) && (score4 == this.Js_lastScore)) return;
	  this.Js_lastDepth = this.Js_depth_Seek;
	  this.Js_lastScore = score4;
	 
	  var s:String = "";
	  for (var i:int = 0; best[(++i)] > 0; )
	  {
	    Lalgb(best[i] >> 8, best[i] & 0xFF, 0);
	 
	    this.Js_tmpCh[0] = this.Js_asciiMove[0][0];
	    this.Js_tmpCh[1] = this.Js_asciiMove[0][1];
	    this.Js_tmpCh[2] = '-';
	    this.Js_tmpCh[3] = this.Js_asciiMove[0][2];
	    this.Js_tmpCh[4] = this.Js_asciiMove[0][3];
	    this.Js_tmpCh[5] = 0;
	    s = s + copyValueOf(this.Js_tmpCh) + " ";
	  }
	  //MessageOut("Thinking: " + s , true);

	  //ShowScore(score4);
	}
	 
	 
	private function ResetData():void
	{
	  this.Js_movesList=[];
	  var i:int = 0;
	  do
	    this.Js_movesList[i] = new MOVES;
	  while (++i < 512);
	 
	  this.Js_Tree=[];
	  i = 0;
	  do
	    this.Js_Tree[i] = new BTREE;
	  while (++i < 2000);
	 

	  for (i = 0; i < this.Js_maxDepth; ++i)
	  {
	    this.Js_treePoint[i] = 0;
	    this.Js_variants[i] = 0;
	    this.Js_flagCheck[i] = 0;
	    this.Js_flagEat[i] = 0;
	    this.Js_menacePawn[i] = 0;
	    this.Js_scorePP[i] = 0;
	    this.Js_scoreTP[i] = 0;
	    this.Js_eliminate0[i] = 0;
	    this.Js_eliminate1[i] = 0;
	    this.Js_eliminate3[i] = 0; }
	 
	  i = 0;
	  var j:int;
	  do { j = 0;
	       this.Js_pieceMap[i] = [];	// creates object
	    do this.Js_pieceMap[i][j] = 0;
	    while (++j < 16);
	  }
	  while (++i < 2);
	 
	  i = 0;
	  do { j = 0;
	       this.Js_pawnMap[i] = [];		// creates object
	    do this.Js_pawnMap[i][j] = 0;
	    while (++j < 8);
	  }
	  while (++i < 2);
	 
	  i = 0;
	  do {
	    this.Js_nMvtOnBoard[i] = 0;
	    this.Js_scoreOnBoard[i] = 0;
	    this.Js_pieceIndex[i] = 0;
	  }
	  while (++i < 64);
	 
	  i = 0;
	  do {
	    this.Js_arrowData[i] = 0;
	    this.Js_crossData[i] = 0;
	  }
	  while (++i < 4200);
	 
	  i = 0;
	  do { j = 0;
	       this.Js_agress[i] = [];		// creates object
	    do this.Js_agress[i][j] = 0;
	    while (++j < 64);
	  }
	  while (++i < 2);
	 
	  i = 0;
	  do this.Js_storage[i] = 0; while (++i < 10000);
	 
	  i = 0;
	  do {
	    this.Js_wPawnMvt[i] = 0;
	    this.Js_bPawnMvt[i] = 0;
	  }
	  while (++i < 64);
	 
	  i = 0;
	  do { j = 0;
	      this.Js_knightMvt[i] = [];		// creates object
	      this.Js_bishopMvt[i] = [];		// creates object
	      this.Js_kingMvt[i] = [];		// creates object
	      this.Js_killArea[i] = [];		// creates object
	    do {
	      this.Js_knightMvt[i][j] = 0;
	      this.Js_bishopMvt[i][j] = 0;
	      this.Js_kingMvt[i][j] = 0;
	      this.Js_killArea[i][j] = 0;
	    }
	    while (++j < 64);
	  }
	  while (++i < 2);
	 
	  i = 0;
	  do {
	    this.Js_nextCross[i] = 0;
	    this.Js_nextArrow[i] = 0;
	  }
	  while (++i < 40000);
	}
	 	 
	private function InChecking(side:int):Boolean
	{
	  var i:int = 0;
	  do
	    if ((this.Js_board[i] == this.Js_king) && 
	      (this.Js_color[i] == side) && 
	      (ISqAgrs(i, this.Js_otherTroop[side]) != 0)) return true;
	  while (++i < 64);
	 
	  return false;
	}
	 
	 
	private function ShowScore(score5:int):void
	{
	  var fMinus:Boolean = score5 < 0;
	  if (fMinus) score5 = -score5;
	  if (score5 != 0) ++score5;

	  var sz:String;
	  if (score5 == 0)
	    sz = "";
	  else if (fMinus)
	    sz = "-";
	  else {
	    sz = "+";
	  }
	  var sc100:int = Math.floor( score5 );
	  sz += (sc100/100).toString();
	  
	  MessageOut("(" + sz + ")",false);
	}

	 
	private function MixBoard(a:Array, b:Array, c:Array):void
	{
	  var sq:int = 0;
	  do c[sq] = ((a[sq] * (10 - this.Js_working) + b[sq] * this.Js_working) / 10);
	  while (++sq < 64);
	}
	 
	private function InitGame():void
	{
	  ResetData();

	  this.Js_flip = false;

	  this.Js_fInGame = true;
	  this.Js_fGameOver = false;

	  this.Js_fCheck_kc = false;
	  this.Js_fMate_kc = false;
	  this.Js_fSoonMate_kc = false;
	 
	  this.Js_bDraw = 0;
	  this.Js_fStalemate = false;
	  this.Js_fAbandon = false;
	  this.Js_fUserWin_kc = false;
	 
	 
	  InitArrow();
	  InitMoves();
	 
	  this.Js_working = -1;
	  this.Js_working2 = -1;
	 
	  this.Js_flag.mate = false;
	  this.Js_flag.recapture = true;

	  this.Js_cNodes = 0;
	  this.Js_indenSqr = 0;
	  this.Js_scoreDither = 0;
	  this.Js__alpha = this.Js_N9;
	  this.Js__beta = this.Js_N9;
	  this.Js_dxAlphaBeta = this.Js_N9;
	  this.Js_maxDepthSeek = Math.min(5,this.Js_maxDepth - 1);

	  this.Js_nMovesMade = 0;	 
	  this.Js_specialScore = 0;
	  this.Js_nGameMoves = 0;
	  this.Js_fiftyMoves = 1;
	  this.Js_hint = 3092;

	  this.Js_fDevl[this.Js_white] = 0;
	  this.Js_fDevl[this.Js_black] = 0;
	  this.Js_roquer[this.Js_white] = 0;
	  this.Js_roquer[this.Js_black] = 0;
	  this.Js_menacePawn[0] = 0;
	  this.Js_flagEat[0] = 0;
	  this.Js_scorePP[0] = 12000;
	  this.Js_scoreTP[0] = 12000;
	 
	  var i:int = 0;
	  do {
	    this.Js_board[i] = this.Js_reguBoard[i];
	    this.Js_color[i] = this.Js_reguColor[i];
	    this.Js_nMvtOnBoard[i] = 0;
	  }
	  while (++i < 64);
	 
	  if (this.Js_nMovesMade == 0)
	  {
	    this.Js_computer = this.Js_white;
	    this.Js_player = this.Js_black;
	    this.Js_enemy = this.Js_player;
	  }

	  this.Js_fUserWin_kc=false;

	  InitStatus();
		 
	}
	 
	 
	private function IColmn(a:int):int
	{
	  return (a & 0x7);
	}
	 

	private function ShowStat():void
	{
	  var sz:String = "";
	 
	  if ((this.Js_fMate_kc) && (!(this.Js_fCheck_kc)))
	  {
	    this.Js_fStalemate = true;
	  }
	 
	  if (this.Js_fCheck_kc)
	  {
	    sz = "Check+";
	  }
	 
	  if (this.Js_fMate_kc) sz = "Checkmate!";
	 
	  if (this.Js_bDraw != 0) sz = "Draw";
	  if (this.Js_fStalemate) sz = "Stalemate!";
	  if (this.Js_fAbandon) sz = "resign";
	  if (this.Js_bDraw == 3)
	  {
	    sz += "At least 3 times repeat-position !";
	  }
	  else if (this.Js_bDraw == 1)
	  {
	    sz += "Can't checkmate !";
	  }
	 
	  if ((!(this.Js_fMate_kc)) && (this.Js_bDraw == 0) && (!(this.Js_fStalemate)) && (!(this.Js_fAbandon)))
		 return;

		// when game is finished only, otherwise show status 
	  this.Js_fInGame = false;

	  if(sz.length>0) MessageOut(sz,true);
	}
	 
	private function IRaw(a:int):int
	{
	  return (a >> 3);
	} 
				 			 	
	 
	private function CalcKPK(side:int, winner:int, loser:int, king1:int, king2:int, sq:int):int
	{
	  var s:int;
	  if (this.Js_piecesCount[winner] == 1)
	    s = 50;
	  else
	    s = 120;
	  var r:int;
	  if (winner == this.Js_white)
	  {
	    if (side == loser)
	      r = IRaw(sq) - 1;
	    else
	      r = IRaw(sq);
	    if ((IRaw(king2) >= r) && (IArrow(sq, king2) < 8 - r))
	      s += 10 * IRaw(sq);
	    else
	      s = 500 + 50 * IRaw(sq);
	    if (IRaw(sq) < 6)
	      sq += 16;
	    else if (IRaw(sq) == 6)
	      sq += 8;
	  }
	  else
	  {
	    if (side == loser)
	      r = IRaw(sq) + 1;
	    else
	      r = IRaw(sq);
	    if ((IRaw(king2) <= r) && (IArrow(sq, king2) < r + 1))
	      s += 10 * (7 - IRaw(sq));
	    else
	      s = 500 + 50 * (7 - IRaw(sq));
	    if (IRaw(sq) > 1)
	      sq -= 16;
	    else if (IRaw(sq) == 1) {
	      sq -= 8;
	    }
	  }
	  s += 8 * this.Js_crossData[(king2 * 64 + sq)] - this.Js_crossData[(king1 * 64 + sq)];
	  return s;
	}
	 
	private function CalcKg(side:int, score:INT):void
	{
	  ChangeForce();
	  var winner:int;
	  if (this.Js_matrl[this.Js_white] > this.Js_matrl[this.Js_black])
	    winner = this.Js_white;
	  else
	    winner = this.Js_black;
	  var loser:int = this.Js_otherTroop[winner];
	  var king1:int = this.Js_pieceMap[winner][0];
	  var king2:int = this.Js_pieceMap[loser][0];
	 
	  var s:int = 0;
	 
	  if (this.Js_pmatrl[winner] > 0)
	  {
	    for (var i:int = 1; i <= this.Js_piecesCount[winner]; ++i) {
	      s += CalcKPK(side, winner, loser, king1, king2, this.Js_pieceMap[winner][i]);
	    }
	  }
	  else if (this.Js_ematrl[winner] == this.Js_bishopVal + this.Js_knightVal)
	  {
	    s = CalcKBNK(winner, king1, king2);
	  }
	  else if (this.Js_ematrl[winner] > this.Js_bishopVal)
	  {
	    s = 500 + this.Js_ematrl[winner] - this.Js_vanish_K[king2] - (2 * IArrow(king1, king2));
	  }
	 
	  if (side == winner)
	    score.i = s;
	  else
	    score.i = (s * -1);
	}
	 
	private function IArrow( a:int, b:int ):int
	{
	  return this.Js_arrowData[(a * 64 + b)];
	}
	 
	 
	private function MoveTree(to:BTREE, from:BTREE):void
	{
	  to.f = from.f;
	  to.t = from.t;
	  to.score = from.score;
	  to.replay = from.replay;
	  to.flags = from.flags;
	}
	 
	private function PrisePassant( xside:int, f:int, t:int, iop:int):void
	{
	  var l:int;
	  if (t > f)
	    l = t - 8;
	  else
	    l = t + 8;
	  if (iop == 1)
	  {
	    this.Js_board[l] = this.Js_empty;
	    this.Js_color[l] = this.Js_hollow;
	  }
	  else
	  {
	    this.Js_board[l] = this.Js_pawn;
	    this.Js_color[l] = xside;
	  }
	  InitStatus();
	}
	 
 
	private function GetAlgMvt(ch:String):String
	{
	  var i:int = 0;
	  do
	    if (ch == this.Js_szIdMvt.charAt(i))
	    {
	      return this.Js_szAlgMvt[i];
	    }
	  while (++i < 64);
	 
	  return "a1";
	}
	 

	private function copyValueOf(a:Array):String
	{
	  var str:String="";
	  var i:int = 0;
	  while(a.length>i && a[i]!=0 )
	  {
	   str+=( typeof(a[i])=="string" ? a[i] : String.fromCharCode(a[i]) );
	   i++;
	  }
	  return str;
	}
	
	 
	private function Agression(side:int, a:Array):void
	{
	  var i:int = 0;
	  do {
	    a[i] = 0;
	    this.Js_agress[side][i] = 0;
	  }
	  while (++i < 64);
	 
	  for (i = this.Js_piecesCount[side]; i >= 0; --i)
	  {
	    var sq:int = this.Js_pieceMap[side][i];
	    var piece:int = this.Js_board[sq];
	    var c:int = this.Js_xlat[piece];
	    var idir:int;
	    var u:int;
	    if (this.Js_heavy[piece] != false)
	    {
	      var ipos:int = piece * 64 * 64 + sq * 64;
	      idir = ipos;
	 
	      u = this.Js_nextCross[(ipos + sq)];
	      do {
		a[u] += 1;
		a[u] |= c;
	 
	        this.Js_agress[side][u] += 1;
	        this.Js_agress[side][u] |= c;
	 
	        if (this.Js_color[u] == this.Js_hollow)
	          u = this.Js_nextCross[(ipos + u)];
	        else
	          u = this.Js_nextArrow[(idir + u)];
	      }
	      while (u != sq);
	    }
	    else
	    {
	      idir = this.Js_pieceTyp[side][piece] * 64 * 64 + sq * 64;
	 
	      u = this.Js_nextArrow[(idir + sq)];
	      do {
		a[u] += 1;
		a[u] |= c;

	 
	        this.Js_agress[side][u] += 1;
	        this.Js_agress[side][u] |= c;
	 
	        u = this.Js_nextArrow[(idir + u)];
	      }
	      while (u != sq);
	    }
	  }
	}
	 	 
	private function InitArrow():void
	{
	  var a:int = 0;
	  do { var b:int = 0;
	    do {
	      var d:int = IColmn(a) - IColmn(b);
	      d = Math.abs(d);
	      var di:int = IRaw(a) - IRaw(b);
	      di = Math.abs(di);
	 
	      this.Js_crossData[(a * 64 + b)] = (d + di);
	      if (d > di)
	        this.Js_arrowData[(a * 64 + b)] = d;
	      else
	        this.Js_arrowData[(a * 64 + b)] = di;
	    }
	    while (++b < 64);
	  }
	  while (++a < 64);
	}
	 
	private function IfCheck():void
	{
	  var i:int = 0;
	  do {
	    if (this.Js_board[i] != this.Js_king)
	      continue;
	    if (this.Js_color[i] == this.Js_white)
	    {
	      if (ISqAgrs(i, this.Js_black) != 0)
	      {
	        this.Js_fCheck_kc = true;
	        return;
	      }
	    }
	    else
	    {
	      if (ISqAgrs(i, this.Js_white) == 0)
	        continue;
	      this.Js_fCheck_kc = true;
	      return;
	    }
	  }
	  while (++i < 64);
	 
	  this.Js_fCheck_kc = false;
	}
	 
	private function Anyagress(c:int, u:int):int
	{
	  if (this.Js_agress[c][u] > 0) {
	    return 1;
	  }
	  return 0;
	}
	 
	private function KnightPts(sq:int, side:int):int
	{
	  var s:int = this.Js_knightMvt[this.Js_c1][sq];
	  var a2:int = this.Js_agress2[sq] & 0x4FFF;
	  if (a2 > 0)
	  {
	    var a1:int = this.Js_agress1[sq] & 0x4FFF;
	    if ((a1 == 0) || (a2 > this.Js_xltBN + 1))
	    {
	      s += this.Js_pinned_p;
	      this.Js_pinned[this.Js_c1] += 1;
	      if (FJunk(sq))
	        this.Js_pinned[this.Js_c1] += 1;
	    }
	    else if ((a2 >= this.Js_xltBN) || (a1 < this.Js_xltP)) {
	      s += this.Js_agress_across; }
	  }
	  return s;
	}
	 
	private function QueenPts(sq:int, side:int):int
	{
	  var s:int = (IArrow(sq, this.Js_pieceMap[this.Js_c2][0]) < 3) ? 12 : 0;
	  if (this.Js_working > 2)
	    s += 14 - this.Js_crossData[(sq * 64 + this.Js_pieceMap[this.Js_c2][0])];
	  var a2:int = this.Js_agress2[sq] & 0x4FFF;
	  if (a2 > 0)
	  {
	    var a1:int = this.Js_agress1[sq] & 0x4FFF;
	    if ((a1 == 0) || (a2 > this.Js_xltQ + 1))
	    {
	      s += this.Js_pinned_p;
	      this.Js_pinned[this.Js_c1] += 1;
	      if (FJunk(sq)) this.Js_pinned[this.Js_c1] += 1;
	    }
	    else if ((a2 >= this.Js_xltQ) || (a1 < this.Js_xltP)) {
	      s += this.Js_agress_across; }
	  }
	  return s;
	}
	 
	private function PositPts(side:int, score:INT):void
	{
	  var pscore:Array = [ 0, 0 ];
	 
	  ChangeForce();
	  var xside:int = this.Js_otherTroop[side];
	  pscore[this.Js_black] = 0;
	  pscore[this.Js_white] = 0;
	 
	  for (this.Js_c1 = this.Js_white; this.Js_c1 <= this.Js_black; this.Js_c1 += 1)
	  {
	    this.Js_c2 = this.Js_otherTroop[this.Js_c1];
	    this.Js_agress1 = this.Js_agress[this.Js_c1];
	    this.Js_agress2 = this.Js_agress[this.Js_c2];
	    this.Js_pawc1 = this.Js_pawnMap[this.Js_c1];
	    this.Js_pawc2 = this.Js_pawnMap[this.Js_c2];
	    for (var i:int = this.Js_piecesCount[this.Js_c1]; i >= 0; --i)
	    {
	      var sq:int = this.Js_pieceMap[this.Js_c1][i];
	      var s:int;
	      if (this.Js_board[sq] == this.Js_pawn)
	        s = PawnPts(sq, side);
	      else if (this.Js_board[sq] == this.Js_knight)
	        s = KnightPts(sq, side);
	      else if (this.Js_board[sq] == this.Js_bishop)
	        s = BishopPts(sq, side);
	      else if (this.Js_board[sq] == this.Js_rook)
	        s = RookPts(sq, side);
	      else if (this.Js_board[sq] == this.Js_queen)
	        s = QueenPts(sq, side);
	      else if (this.Js_board[sq] == this.Js_king)
	        s = KingPts(sq, side);
	      else
	        s = 0;
	      pscore[this.Js_c1] += s;
	      this.Js_scoreOnBoard[sq] = s;
	    }
	  }
	  if (this.Js_pinned[side] > 1)
	    pscore[side] += this.Js_pinned_other;
	  if (this.Js_pinned[xside] > 1) {
	    pscore[xside] += this.Js_pinned_other;
	  }
	  score.i = (this.Js_matrl[side] - this.Js_matrl[xside] + pscore[side] - pscore[xside] + 10);
	 
	  if ((score.i > 0) && (this.Js_pmatrl[side] == 0))
	  {
	    if (this.Js_ematrl[side] < this.Js_rookVal)
	      score.i = 0;
	    else if (score.i < this.Js_rookVal)
	      score.i /= 2;
	  }
	  if ((score.i < 0) && (this.Js_pmatrl[xside] == 0))
	  {
	    if (this.Js_ematrl[xside] < this.Js_rookVal)
	      score.i = 0;
	    else if (-score.i < this.Js_rookVal) {
	      score.i /= 2;
	    }
	  }
	  if ((this.Js_matrl[xside] == this.Js_kingVal) && (this.Js_ematrl[side] > this.Js_bishopVal))
	    score.i += 200;
	  if ((this.Js_matrl[side] == this.Js_kingVal) && (this.Js_ematrl[xside] > this.Js_bishopVal))
	    score.i -= 200;
	}
	 
	private function PlayMov():void
	{
	  UpdateDisplay();
	 
	  this.Js_currentScore = this.Js_root.score;
	  this.Js_fSoonMate_kc = false;
	  if ((((this.Js_root.flags == 0) ? 0 : 1) & ((this.Js_draw == 0) ? 0 : 1)) != 0)
	  {
	    this.Js_fGameOver = true;
	  }
	  else if (this.Js_currentScore == -9999)
	  {
	    this.Js_fGameOver = true;
	    this.Js_fMate_kc = true;
	    this.Js_fUserWin_kc = true;
	  }
	  else if (this.Js_currentScore == 9998)
	  {
	    this.Js_fGameOver = true;
	    this.Js_fMate_kc = true;
	    this.Js_fUserWin_kc = false;
	  }
	  else if (this.Js_currentScore < -9000)
	  {
	    this.Js_fSoonMate_kc = true;
	  }
	  else if (this.Js_currentScore > 9000)
	  {
	    this.Js_fSoonMate_kc = true;
	  }
	  ShowScore(this.Js_currentScore);
	 
	}

	private function IRepeat(cnt:int):int
	{
	  var c:int = 0;
	  cnt = 0;
	  if (this.Js_nGameMoves > this.Js_fiftyMoves + 3)
	  {
	    var i:int = 0;
	    do this.Js_b_r[i] = 0; while (++i < 64);
	 
	    for (i = this.Js_nGameMoves; i > this.Js_fiftyMoves; --i)
	    {
	      var m:int = this.Js_movesList[i].gamMv;
	      var f:int = m >> 8;
	      var t:int = m & 0xFF;
	      this.Js_b_r[f] += 1;
	      if (this.Js_b_r[f] == 0) --c;
	      else ++c;
	      this.Js_b_r[t] += -1;
	      if (this.Js_b_r[t] == 0) --c;
	      else ++c;
	      if (c != 0) continue;
	      ++cnt;
	    }
	  }
	 
	  if (cnt == 3) this.Js_bDraw = 3;
	 
	  return cnt;
	}

	 
	private function ChoiceMov(side:int, iop:int):void
	{
	  var tempb:INT = new INT;
	  var tempc:INT = new INT;
	  var tempsf:INT = new INT;
	  var tempst:INT = new INT;
	  var rpt:INT = new INT;
	  var score:INT = new INT;
	 
	  var alpha:int = 0;
	  var beta:int = 0;
	 
	  this.Js_flag.timeout = false;
	  var xside:int = this.Js_otherTroop[side];
	  if (iop != 2)
	    this.Js_player = side;
	  WatchPosit();
	 
	  PositPts(side, score);
	  var i:int;
	  if (this.Js_depth_Seek == 0)
	  {
	    i = 0;
	    do this.Js_storage[i] = 0; while (++i < 10000);

	    this.Js_origSquare = -1;
	    this.Js_destSquare = -1;
	    this.Js_ptValue = 0;
	    if (iop != 2)
	      this.Js_hint = 0;
	    for (i = 0; i < this.Js_maxDepth; ++i)
	    {
	      this.Js_variants[i] = 0;
	      this.Js_eliminate0[i] = 0;
	      this.Js_eliminate1[i] = 0;
	      this.Js_eliminate2[i] = 0;
	      this.Js_eliminate3[i] = 0;
	    }
	    alpha = score.i - this.Js_N9;
	    beta = score.i + this.Js_N9;
	    rpt.i = 0;
	    this.Js_treePoint[1] = 0;
	    this.Js_root = this.Js_Tree[0];
	    AvailMov(side, 1);
	    for (i = this.Js_treePoint[1]; i < this.Js_treePoint[2]; ++i)
	    {
	      Peek(i, this.Js_treePoint[2] - 1);
	    }
	 
	    this.Js_cNodes = 0;
	    this.Js_cCompNodes = 0;
	
	    this.Js_scoreDither = 0;
	    this.Js_dxDither = 20;
	  }
	 
	  while ((!(this.Js_flag.timeout)) && (this.Js_depth_Seek < this.Js_maxDepthSeek))
	  {
	    this.Js_depth_Seek += 1;

	    score.i = Seek(side, 1, this.Js_depth_Seek, alpha, beta, this.Js_variants, rpt);
	    for (i = 1; i <= this.Js_depth_Seek; ++i)
	    {
	      this.Js_eliminate0[i] = this.Js_variants[i];
	    }
	    if (score.i < alpha)
	    {
	      score.i = Seek(side, 1, this.Js_depth_Seek, -9000, score.i, this.Js_variants, rpt);
	    }
	    if ((score.i > beta) && ((this.Js_root.flags & this.Js__idem) == 0))
	    {
	      score.i = Seek(side, 1, this.Js_depth_Seek, score.i, 9000, this.Js_variants, rpt);
	    }
	 
	    score.i = this.Js_root.score;

	    for (i = this.Js_treePoint[1] + 1; i < this.Js_treePoint[2]; ++i)
	    {
	      Peek(i, this.Js_treePoint[2] - 1);
	    }
	 

	 
	    for (i = 1; i <= this.Js_depth_Seek; ++i)
	    {
	      this.Js_eliminate0[i] = this.Js_variants[i];
	    }
	 
	    if ((this.Js_root.flags & this.Js__idem) != 0) {
	      this.Js_flag.timeout = true;
	    }
	    if (this.Js_Tree[1].score < -9000) {
	      this.Js_flag.timeout = true;
	    }

	    if (!(this.Js_flag.timeout))
	    {
	      this.Js_scoreTP[0] = score.i;
	      if (this.Js_scoreDither == 0)
	        this.Js_scoreDither = score.i;
	      else
	        this.Js_scoreDither = ((this.Js_scoreDither + score.i) / 2);
	    }
	    this.Js_dxDither = (20 + Math.abs(this.Js_scoreDither / 12));
	    beta = score.i + this.Js__beta;
	    if (this.Js_scoreDither < score.i)
	      alpha = this.Js_scoreDither - this.Js__alpha - this.Js_dxDither;
	    else {
	      alpha = score.i - this.Js__alpha - this.Js_dxDither;
	    }
	 
	  }
	 
 
	  score.i = this.Js_root.score;
	 
	  if (iop == 2) return;
	 
	  this.Js_hint = this.Js_variants[2];

	  if ((score.i == -9999) || (score.i == 9998))
	  {
	    this.Js_flag.mate = true;
	    this.Js_fMate_kc = true;
	  }
	  if ((score.i > -9999) && (rpt.i <= 2))
	  {
	    if (score.i < this.Js_realBestScore)
	    {
	      var m_f:int = this.Js_realBestMove >> 8;
	      var m_t:int = this.Js_realBestMove & 0xFF;
	      i = 0;
	      do {
	        if ((m_f != this.Js_Tree[i].f) || (m_t != this.Js_Tree[i].t) || (this.Js_realBestScore != this.Js_Tree[i].score))
	        {
	          continue;
	        }
	 
	        this.Js_root = this.Js_Tree[i];
	 
	        break;
	      }
	      while (++i < 2000);
	    }

	    this.Js_myPiece = this.Js_rgszPiece[this.Js_board[this.Js_root.f]];
	 
	    ValidateMov(side, this.Js_root, tempb, tempc, tempsf, tempst, this.Js_gainScore);
	    if (InChecking(this.Js_computer))
	    {
	      UnValidateMov(side, this.Js_root, tempb, tempc, tempsf, tempst);
	      this.Js_fAbandon = true;
	    }
	    else
	    {
	      Lalgb(this.Js_root.f, this.Js_root.t, this.Js_root.flags);
	      PlayMov();
	    }
	 
	  }
	  else if (this.Js_bDraw == 0)
	  {
	    Lalgb(0, 0, 0);
	    if (!(this.Js_flag.mate))
	    {
	      this.Js_fAbandon = true;

	    }
	    else
	    {
	      this.Js_fUserWin_kc = true;
	    }
	 
	  }
	 
	  if (this.Js_flag.mate)
	  {
	    this.Js_hint = 0;
	  }
	  if ((this.Js_board[this.Js_root.t] == this.Js_pawn) || ((this.Js_root.flags & this.Js_capture) != 0) || ((this.Js_root.flags & this.Js_castle_msk) != 0))
	  {
	    this.Js_fiftyMoves = this.Js_nGameMoves;
	  }
	  this.Js_movesList[this.Js_nGameMoves].score = score.i;
	 
	  if (this.Js_nGameMoves > 500)
	  {
	    this.Js_flag.mate = true;
	  }
	  this.Js_player = xside;
	  this.Js_depth_Seek = 0;
	}
	 
	private function MultiMov(ply:int, sq:int, side:int, xside:int):void
	{
	  var piece:int = this.Js_board[sq];
	 
	  var i:int = this.Js_pieceTyp[side][piece] * 64 * 64 + sq * 64;
	  var ipos:int = i;
	  var idir:int = i;
	  var u:int;
	  if (piece == this.Js_pawn)
	  {
	    u = this.Js_nextCross[(ipos + sq)];
	    if (this.Js_color[u] == this.Js_hollow)
	    {
	      AttachMov(ply, sq, u, 0, xside);
	 
	      u = this.Js_nextCross[(ipos + u)];
	      if (this.Js_color[u] == this.Js_hollow) {
	        AttachMov(ply, sq, u, 0, xside);
	      }
	    }
	    u = this.Js_nextArrow[(idir + sq)];
	    if (this.Js_color[u] == xside)
	      AttachMov(ply, sq, u, this.Js_capture, xside);
	    else if (u == this.Js_indenSqr) {
	      AttachMov(ply, sq, u, this.Js_capture | this.Js_enpassant_msk, xside);
	    }
	    u = this.Js_nextArrow[(idir + u)];
	    if (this.Js_color[u] == xside)
	      AttachMov(ply, sq, u, this.Js_capture, xside);
	    else if (u == this.Js_indenSqr) {
	      AttachMov(ply, sq, u, this.Js_capture | this.Js_enpassant_msk, xside);
	    }
	  }
	  else
	  {
	    u = this.Js_nextCross[(ipos + sq)];
	    do if (this.Js_color[u] == this.Js_hollow)
	      {
	        AttachMov(ply, sq, u, 0, xside);
	 
	        u = this.Js_nextCross[(ipos + u)];
	      }
	      else
	      {
	        if (this.Js_color[u] == xside) {
	          AttachMov(ply, sq, u, this.Js_capture, xside);
	        }
	        u = this.Js_nextArrow[(idir + u)];
	      }
	 
	    while (u != sq);
	  }
	}
	 	 
	private function XRayKg(sq:int, s:INT):void
	{
	  var cnt:int = 0;
	  var u:int = 0;
	  var ipos:int;
	  var idir:int;
	  if ((this.Js_withBishop[this.Js_c2] != 0) || (this.Js_withQueen[this.Js_c2] != 0))
	  {
	    ipos = this.Js_bishop * 64 * 64 + sq * 64;
	    idir = ipos;
	 
	    u = this.Js_nextCross[(ipos + sq)];
	    do { if (((this.Js_agress2[u] & this.Js_xltBQ) != 0) && 
	        (this.Js_color[u] != this.Js_c2)) {
	        if ((this.Js_agress1[u] == 0) || ((this.Js_agress2[u] & 0xFF) > 1))
	          ++cnt;
	        else {
	          s.i -= 3;
	        }
	      }
	      if (this.Js_color[u] == this.Js_hollow)
	        u = this.Js_nextCross[(ipos + u)];
	      else
	        u = this.Js_nextArrow[(idir + u)];
	    }
	    while (u != sq);
	  }
	 
	  if ((this.Js_withRook[this.Js_c2] != 0) || (this.Js_withQueen[this.Js_c2] != 0))
	  {
	    ipos = this.Js_rook * 64 * 64 + sq * 64;
	    idir = ipos;
	 
	    u = this.Js_nextCross[(ipos + sq)];
	    do { if (((this.Js_agress2[u] & this.Js_xltRQ) != 0) && 
	        (this.Js_color[u] != this.Js_c2)) {
	        if ((this.Js_agress1[u] == 0) || ((this.Js_agress2[u] & 0xFF) > 1))
	          ++cnt;
	        else {
	          s.i -= 3;
	        }
	      }
	      if (this.Js_color[u] == this.Js_hollow)
	        u = this.Js_nextCross[(ipos + u)];
	      else
	        u = this.Js_nextArrow[(idir + u)];
	    }
	    while (u != sq);
	  }
	 
	  if (this.Js_withKnight[this.Js_c2] != 0)
	  {
	    idir = this.Js_knight * 64 * 64 + sq * 64;
	 
	    u = this.Js_nextArrow[(idir + sq)];
	    do { if (((this.Js_agress2[u] & this.Js_xltNN) != 0) && 
	        (this.Js_color[u] != this.Js_c2)) {
	        if ((this.Js_agress1[u] == 0) || ((this.Js_agress2[u] & 0xFF) > 1))
	          ++cnt;
	        else
	          s.i -= 3;
	      }
	      u = this.Js_nextArrow[(idir + u)];
	    }
	    while (u != sq);
	  }
	  s.i += this.Js_safe_King * this.Js_menaceKing[cnt] / 16;
	 
	  cnt = 0;
	  var ok:Boolean = false;
	  idir = this.Js_king * 64 * 64 + sq * 64;
	 
	  u = this.Js_nextCross[(idir + sq)];
	  do { if (this.Js_board[u] == this.Js_pawn)
	    {
	      ok = true; }
	    if (this.Js_agress2[u] > this.Js_agress1[u])
	    {
	      ++cnt;
	      if (((this.Js_agress2[u] & this.Js_xltQ) != 0) && 
	        (this.Js_agress2[u] > this.Js_xltQ + 1) && (this.Js_agress1[u] < this.Js_xltQ)) {
	        s.i -= 4 * this.Js_safe_King;
	      }
	    }
	    u = this.Js_nextCross[(idir + u)];
	  }
	  while (u != sq);
	 
	  if (!(ok))
	    s.i -= this.Js_safe_King;
	  if (cnt > 1)
	    s.i -= this.Js_safe_King;
	}
	  
	private function DoCastle( side:int, kf:int, kt:int, iop:int ):int
	{
	  var xside:int = this.Js_otherTroop[side];
	  var rf:int;
	  var rt:int;
	  if (kt > kf)
	  {
	    rf = kf + 3;
	    rt = kt - 1;
	  }
	  else
	  {
	    rf = kf - 4;
	    rt = kt + 1;
	  }
	  if (iop == 0)
	  {
	    if ((kf != this.Js_kingPawn[side]) || (this.Js_board[kf] != this.Js_king) || (this.Js_board[rf] != this.Js_rook) || (this.Js_nMvtOnBoard[kf] != 0) || (this.Js_nMvtOnBoard[rf] != 0) || (this.Js_color[kt] != this.Js_hollow) || (this.Js_color[rt] != this.Js_hollow) || (this.Js_color[(kt - 1)] != this.Js_hollow) || (ISqAgrs(kf, xside) != 0) || (ISqAgrs(kt, xside) != 0) || (ISqAgrs(rt, xside) != 0))
	    {
	      return 0;
	    }
	  }
	  else {
	    if (iop == 1)
	    {
	      this.Js_roquer[side] = 1;
	      this.Js_nMvtOnBoard[kf] += 1;
	      this.Js_nMvtOnBoard[rf] += 1;
	    }
	    else
	    {
	      this.Js_roquer[side] = 0;
	      this.Js_nMvtOnBoard[kf] += -1;
	      this.Js_nMvtOnBoard[rf] += -1;
	      var t0:int = kt;
	      kt = kf;
	      kf = t0;
	      t0 = rt;
	      rt = rf;
	      rf = t0;
	    }
	    this.Js_board[kt] = this.Js_king;
	    this.Js_color[kt] = side;
	    this.Js_pieceIndex[kt] = 0;
	    this.Js_board[kf] = this.Js_empty;
	    this.Js_color[kf] = this.Js_hollow;
	    this.Js_board[rt] = this.Js_rook;
	    this.Js_color[rt] = side;
	    this.Js_pieceIndex[rt] = this.Js_pieceIndex[rf];
	    this.Js_board[rf] = this.Js_empty;
	    this.Js_color[rf] = this.Js_hollow;
	    this.Js_pieceMap[side][this.Js_pieceIndex[kt]] = kt;
	    this.Js_pieceMap[side][this.Js_pieceIndex[rt]] = rt;
	  }
	 
	  return 1;
	}
	 
	private function DoCalc(side:int, ply:int, alpha:int, beta:int, gainScore:int, slk:INT, InChk:INT):int
	{
	  var s:INT = new INT;
	 
	  var xside:int = this.Js_otherTroop[side];
	  s.i = (-this.Js_scorePP[(ply - 1)] + this.Js_matrl[side] - this.Js_matrl[xside] - gainScore);
	  this.Js_pinned[this.Js_black] = 0;
	  this.Js_pinned[this.Js_white] = 0;
	  if (((this.Js_matrl[this.Js_white] == this.Js_kingVal) && (((this.Js_pmatrl[this.Js_black] == 0) || (this.Js_ematrl[this.Js_black] == 0)))) || (
	    (this.Js_matrl[this.Js_black] == this.Js_kingVal) && (((this.Js_pmatrl[this.Js_white] == 0) || (this.Js_ematrl[this.Js_white] == 0)))))
	    slk.i = 1;
	  else
	    slk.i = 0;
	  var evflag:Boolean;
	  if (slk.i != 0) {
	    evflag = false;
	  }
	  else
	  {
	    evflag = (ply == 1) || (ply < this.Js_depth_Seek) || (
	      (((ply == this.Js_depth_Seek + 1) || (ply == this.Js_depth_Seek + 2))) && ((
	      ((s.i > alpha - this.Js_dxAlphaBeta) && (s.i < beta + this.Js_dxAlphaBeta)) || (
	      (ply > this.Js_depth_Seek + 2) && (s.i >= alpha - 25) && (s.i <= beta + 25)))));
	  }
	  if (evflag)
	  {
	    this.Js_cCompNodes += 1;
	    Agression(side, this.Js_agress[side]);
	 
	    if (Anyagress(side, this.Js_pieceMap[xside][0]) == 1) return (10001 - ply);
	    Agression(xside, this.Js_agress[xside]);
	 
	    InChk.i = Anyagress(xside, this.Js_pieceMap[side][0]);
	    PositPts(side, s);
	  }
	  else
	  {
	    if (ISqAgrs(this.Js_pieceMap[xside][0], side) != 0)
	      return (10001 - ply);
	    InChk.i = ISqAgrs(this.Js_pieceMap[side][0], xside);
	 
	    if (slk.i != 0)
	    {
	      CalcKg(side, s);
	    }
	  }
	  this.Js_scorePP[ply] = (s.i - this.Js_matrl[side] + this.Js_matrl[xside]);
	  if (InChk.i != 0)
	  {
	    if (this.Js_destSquare == -1) this.Js_destSquare = this.Js_root.t;
	    this.Js_flagCheck[(ply - 1)] = this.Js_pieceIndex[this.Js_destSquare];
	  }
	  else {
	    this.Js_flagCheck[(ply - 1)] = 0; }
	  return s.i;
	}
	 
 
	private function Lalgb( f:int, t:int, flag:int):void
	{
	  var i:int;
	  var y:int;
	  if (f != t)
	  {
	    this.Js_asciiMove[0][0] = (97 + IColmn(f));		//(char)
	    this.Js_asciiMove[0][1] = (49 + IRaw(f));		//(char)
	    this.Js_asciiMove[0][2] = (97 + IColmn(t));		//(char)
	    this.Js_asciiMove[0][3] = (49 + IRaw(t));		//(char)
	    this.Js_asciiMove[0][4] = 0;
	    this.Js_asciiMove[3][0] = 0;
	    this.Js_asciiMove[1][0] = this.Js_upperNot[this.Js_board[f]];

	    if (this.Js_asciiMove[1][0] == 'P')
	    {
	      var m3p:int;
	      if (this.Js_asciiMove[0][0] == this.Js_asciiMove[0][2])
	      {
	        this.Js_asciiMove[1][0] = this.Js_asciiMove[0][2];
	        this.Js_asciiMove[2][0] = this.Js_asciiMove[1][0];
		this.Js_asciiMove[1][1] = this.Js_asciiMove[0][3];
	        this.Js_asciiMove[2][1] = this.Js_asciiMove[1][1];
	        m3p = 2;
	      }
	      else
	      {
		this.Js_asciiMove[1][0] = this.Js_asciiMove[0][0];
	        this.Js_asciiMove[2][0] = this.Js_asciiMove[1][0];
		this.Js_asciiMove[1][1] = this.Js_asciiMove[0][2];
	        this.Js_asciiMove[2][1] = this.Js_asciiMove[1][1];
	        this.Js_asciiMove[2][2] = this.Js_asciiMove[0][3];
	        m3p = 3;
	      }
	      this.Js_asciiMove[1][2] = 0;
	      this.Js_asciiMove[2][m3p] = 0;
	      if ((flag & this.Js_promote) != 0)
	      {
		this.Js_asciiMove[1][2] = this.Js_lowerNot[(flag & this.Js_pawn_msk)];
		this.Js_asciiMove[2][m3p] = this.Js_asciiMove[1][2];
	        this.Js_asciiMove[0][4] = this.Js_asciiMove[1][2];
		this.Js_asciiMove[0][5] = 0;
		this.Js_asciiMove[2][(m3p + 1)] = 0;
	        this.Js_asciiMove[1][3] = 0;
	      }
	 
	    }
	    else
	    {
	      this.Js_asciiMove[2][0] = this.Js_asciiMove[1][0];
	      this.Js_asciiMove[2][1] = this.Js_asciiMove[0][1];
	      this.Js_asciiMove[1][1] = this.Js_asciiMove[0][2];
	      this.Js_asciiMove[2][2] = this.Js_asciiMove[1][1];
	      this.Js_asciiMove[1][2] = this.Js_asciiMove[0][3];
	      this.Js_asciiMove[2][3] = this.Js_asciiMove[1][2];
	      this.Js_asciiMove[1][3] = 0;
	      this.Js_asciiMove[2][4] = 0;
	      i = 0;
	      do
	        this.Js_asciiMove[3][i] = this.Js_asciiMove[2][i];
	      while (++i < 6);
	 
	      this.Js_asciiMove[3][1] = this.Js_asciiMove[0][0];
	      if ((flag & this.Js_castle_msk) != 0)
	      {
	        if (t > f)
	        {
	          this.Js_asciiMove[1][0] = 111;
	          this.Js_asciiMove[1][1] = 45;
	          this.Js_asciiMove[1][2] = 111;
	          this.Js_asciiMove[1][3] = 0;
	 
	          this.Js_asciiMove[2][0] = 111;
	          this.Js_asciiMove[2][1] = 45;
	          this.Js_asciiMove[2][2] = 111;
	          this.Js_asciiMove[2][3] = 0;
	        }
	        else
	        {
	          this.Js_asciiMove[1][0] = 111;
	          this.Js_asciiMove[1][1] = 45;
	          this.Js_asciiMove[1][2] = 111;
	          this.Js_asciiMove[1][3] = 45;
	          this.Js_asciiMove[1][4] = 111;
	          this.Js_asciiMove[1][5] = 0;
	 
	          this.Js_asciiMove[2][0] = 111;
	          this.Js_asciiMove[2][1] = 45;
	          this.Js_asciiMove[2][2] = 111;
	          this.Js_asciiMove[2][3] = 45;
	          this.Js_asciiMove[2][4] = 111;
	          this.Js_asciiMove[2][5] = 0;
	        }
	      }
	    }
	  }
	  else
	  {
	    i = 0;
	    do this.Js_asciiMove[i][0] = 0; while (++i < 4);
	  }
	}
	 
	private function UpdatePiecMap(side:int, sq:int, iop:int):void
	{
	  if (iop == 1)
	  {
	    this.Js_piecesCount[side] += -1;
	    for (var i:int = this.Js_pieceIndex[sq]; i <= this.Js_piecesCount[side]; ++i)
	    {
	      this.Js_pieceMap[side][i] = this.Js_pieceMap[side][(i + 1)];
	      this.Js_pieceIndex[this.Js_pieceMap[side][i]] = i;
	    }
	  }
	  else
	  {
	    this.Js_piecesCount[side] += 1;
	    this.Js_pieceMap[side][this.Js_piecesCount[side]] = sq;
	    this.Js_pieceIndex[sq] = this.Js_piecesCount[side];
	  }
	}
	 




	private function UpdateDisplay():void
	{
				   
	  var BB:Array = [[]];	// 8x8
	  var iCol:int = 0;
	  var iLine:int = 0;

	  var i:int = 0;
	  do { BB[i]=[]; } while (++i<8);		// create object

	  i = 0;
	  do {

	    iCol = i % 8;
	    iLine = (i-iCol) / 8;
	    BB[iLine][iCol] = (this.Js_color[i]==this.Js_black ? this.Js_lowerNot[ this.Js_board[i] ] : this.Js_upperNot[ this.Js_board[i] ] );
	
	  }
	  while (++i < 64);
	
	  var PP:String="<div><table>";
	  iLine = 7;
	  do {
	    PP+="<tr>";
	    iCol = 0;
	    do {
	        PP+="<td>."+BB[iLine][iCol]+".</td>";
	    }
	    while (++iCol < 8);
	    PP+="</tr>";
	  }
	  while (--iLine >= 0);
	  PP+="</table></div>";
	  CallingJS("UPDATEDISPLAY", PP);
	}
	  
	private function AvailCaptur(side:int, ply:int):void
	{
	  var xside:int = this.Js_otherTroop[side];
	  this.Js_treePoint[(ply + 1)] = this.Js_treePoint[ply];
	  var node:BTREE = this.Js_Tree[this.Js_treePoint[ply]];		//_BTREE

	  var inext:int = this.Js_treePoint[ply] + 1;
	  var r7:int = this.Js_raw7[side];
	 
	  var ipl:int = side;
	  for (var i:int = 0; i <= this.Js_piecesCount[side]; ++i)
	  {
	    var sq:int = this.Js_pieceMap[side][i];
	    var piece:int = this.Js_board[sq];
	    var ipos:int;
	    var idir:int;
	    var u:int;
	    if (this.Js_heavy[piece] != false)
	    {
	      ipos = piece * 64 * 64 + sq * 64;
	      idir = ipos;
	 
	      u = this.Js_nextCross[(ipos + sq)];
	      do if (this.Js_color[u] == this.Js_hollow)
	        {
	          u = this.Js_nextCross[(ipos + u)];
	        }
	        else {
	          if (this.Js_color[u] == xside)
	          {
	            node.f = sq;
	            node.t = u;
	            node.replay = 0;
	            node.flags = this.Js_capture;
	            node.score = (this.Js_valueMap[this.Js_board[u]] + this.Js_scoreOnBoard[this.Js_board[u]] - piece);
	            node = this.Js_Tree[(inext++)];
	            this.Js_treePoint[(ply + 1)] += 1;
	          }
	 
	          u = this.Js_nextArrow[(idir + u)];
	        }
	 
	      while (u != sq);
	    }
	    else
	    {
	      idir = this.Js_pieceTyp[side][piece] * 64 * 64 + sq * 64;
	      if ((piece == this.Js_pawn) && (IRaw(sq) == r7))
	      {
	        u = this.Js_nextArrow[(idir + sq)];
	        if (this.Js_color[u] == xside)
	        {
	          node.f = sq;
	          node.t = u;
	          node.replay = 0;
	          node.flags = (this.Js_capture | this.Js_promote | this.Js_queen);
	          node.score = this.Js_queenVal;
	          node = this.Js_Tree[(inext++)];
	          this.Js_treePoint[(ply + 1)] += 1;
	        }
	 
	        u = this.Js_nextArrow[(idir + u)];
	        if (this.Js_color[u] == xside)
	        {
	          node.f = sq;
	          node.t = u;
	          node.replay = 0;
	          node.flags = (this.Js_capture | this.Js_promote | this.Js_queen);
	          node.score = this.Js_queenVal;
	          node = this.Js_Tree[(inext++)];
	          this.Js_treePoint[(ply + 1)] += 1;
	        }
	 
	        ipos = this.Js_pieceTyp[side][piece] * 64 * 64 + sq * 64;
	 
	        u = this.Js_nextCross[(ipos + sq)];
	        if (this.Js_color[u] == this.Js_hollow)
	        {
	          node.f = sq;
	          node.t = u;
	          node.replay = 0;
	          node.flags = (this.Js_promote | this.Js_queen);
	          node.score = this.Js_queenVal;
	          node = this.Js_Tree[(inext++)];
	          this.Js_treePoint[(ply + 1)] += 1;
	        }
	 
	      }
	      else
	      {
	        u = this.Js_nextArrow[(idir + sq)];
	        do { if (this.Js_color[u] == xside)
	          {
	            node.f = sq;
	            node.t = u;
	            node.replay = 0;
	            node.flags = this.Js_capture;
	            node.score = (this.Js_valueMap[this.Js_board[u]] + this.Js_scoreOnBoard[this.Js_board[u]] - piece);
	            node = this.Js_Tree[(inext++)];
	            this.Js_treePoint[(ply + 1)] += 1;
	          }
	 
	          u = this.Js_nextArrow[(idir + u)];
	        }
	        while (u != sq);
	      }
	    }
	  }
	}
	 
	private function InitStatus():void
	{
	  this.Js_indenSqr = -1;
	  var i:int = 0;
	  do {
	    this.Js_pawnMap[this.Js_white][i] = 0;
	    this.Js_pawnMap[this.Js_black][i] = 0;
	  }
	  while (++i < 8);

	  this.Js_pmatrl[this.Js_black] = 0;
	  this.Js_pmatrl[this.Js_white] = 0;
	  this.Js_matrl[this.Js_black] = 0;
	  this.Js_matrl[this.Js_white] = 0;
	  this.Js_piecesCount[this.Js_black] = 0;
	  this.Js_piecesCount[this.Js_white] = 0;
	 
	 
	  var sq:int = 0;
	  do {
	    if (this.Js_color[sq] == this.Js_hollow)
	      continue;
	    this.Js_matrl[this.Js_color[sq]] += this.Js_valueMap[this.Js_board[sq]];
	    if (this.Js_board[sq] == this.Js_pawn)
	    {
	      this.Js_pmatrl[this.Js_color[sq]] += this.Js_pawnVal;
	      this.Js_pawnMap[this.Js_color[sq]][IColmn(sq)] += 1;
	    }
	    if (this.Js_board[sq] == this.Js_king)
	      this.Js_pieceIndex[sq] = 0;
	    else
	      {
	      this.Js_piecesCount[this.Js_color[sq]] += 1;
	      this.Js_pieceIndex[sq] = this.Js_piecesCount[this.Js_color[sq]];
	      }
	    this.Js_pieceMap[this.Js_color[sq]][this.Js_pieceIndex[sq]] = sq;
	 
	  }
	  while (++sq < 64);
	}
	 
	private function MessageOut(msg:String, fNL:Boolean):void
	{
	 trace(msg);
	 CallingJS("MESSAGEOUT", msg+((fNL) ? "<br>" : ""));
	}
	 
	private function Pagress(c:int, u:int):Boolean
	{
	  return (this.Js_agress[c][u] > this.Js_xltP);
	}
	 
	private function CheckMatrl():Boolean
	{
	  var flag:Boolean = true;
	  
	  var nP:int=0;
	  var nK:int=0;
	  var nB:int=0;
	  var nR:int=0;
	  var nQ:int=0;
	
	  
	  var nK1:int=0;
	  var nK2:int=0;
	  var nB1:int=0;
	  var nB2:int=0;
				   
	  var i:int = 0;
	  do
	    if (this.Js_board[i] == this.Js_pawn) {
	      ++nP;
	    } else if (this.Js_board[i] == this.Js_queen) {
	      ++nQ;
	    } else if (this.Js_board[i] == this.Js_rook) {
	      ++nR;
	    } else if (this.Js_board[i] == this.Js_bishop)
	    {
	      if (this.Js_color[i] == this.Js_white)
	        ++nB1;
	      else
	        ++nB2;
	    } else {
	      if (this.Js_board[i] != this.Js_knight)
	        continue;
	      if (this.Js_color[i] == this.Js_white)
	        ++nK1;
	      else
	        ++nK2;
	    }
	  while (++i < 64);
	 
	  if (nP != 0) return true;
	  if ((nQ != 0) || (nR != 0)) return true;
	 
	  nK = nK1 + nK2;
	  nB = nB1 + nB2;
	 
	  if ((nK == 0) && (nB == 0)) return false;
	  if ((nK == 1) && (nB == 0)) return false;
	  return ((nK != 0) || (nB != 1));
	}
	 
	private function AttachMov(ply:int, f:int, t:int, flag:int, xside:int):void
	{
	  var node:BTREE = this.Js_Tree[this.Js_treePoint[(ply + 1)]];	//_BTREE

	  var inext:int = this.Js_treePoint[(ply + 1)] + 1;
	 
	  var mv:int = f << 8 | t;
	  var s:int = 0;
	  if (mv == this.Js_scoreWin0)
	    s = 2000;
	  else if (mv == this.Js_scoreWin1)
	    s = 60;
	  else if (mv == this.Js_scoreWin2)
	    s = 50;
	  else if (mv == this.Js_scoreWin3)
	    s = 40;
	  else if (mv == this.Js_scoreWin4)
	    s = 30;
	  var z:int = f << 6 | t;
	  if (xside == this.Js_white)
	    z |= 4096;

	  s += this.Js_storage[z];

	  if (this.Js_color[t] != this.Js_hollow)
	  {
	    if (t == this.Js_destSquare)
	      s += 500;
	    s += this.Js_valueMap[this.Js_board[t]] - this.Js_board[f];
	  }
	  if (this.Js_board[f] == this.Js_pawn)
	  {
	    if ((IRaw(t) == 0) || (IRaw(t) == 7))
	    {
	      flag |= this.Js_promote;
	      s += 800;
	 
	      node.f = f;
	      node.t = t;
	      node.replay = 0;
	      node.flags = (flag | this.Js_queen);
	      node.score = (s - 20000);
	      node = this.Js_Tree[(inext++)];
	      this.Js_treePoint[(ply + 1)] += 1;
	 
	      s -= 200;
	 
	      node.f = f;
	      node.t = t;
	      node.replay = 0;
	      node.flags = (flag | this.Js_knight);
	      node.score = (s - 20000);
	      node = this.Js_Tree[(inext++)];
	      this.Js_treePoint[(ply + 1)] += 1;
	 
	      s -= 50;
	 
	      node.f = f;
	      node.t = t;
	      node.replay = 0;
	      node.flags = (flag | this.Js_rook);
	      node.score = (s - 20000);
	      node = this.Js_Tree[(inext++)];
	      this.Js_treePoint[(ply + 1)] += 1;
	 
	      flag |= this.Js_bishop;
	      s -= 50;
	    }
	    else if ((IRaw(t) == 1) || (IRaw(t) == 6))
	    {
	      flag |= this.Js_menace_pawn;
	      s += 600;
	    }
	  }
	 
	  node.f = f;
	  node.t = t;
	  node.replay = 0;
	  node.flags = flag;
	  node.score = (s - 20000);
	  node = this.Js_Tree[(inext++)];
	  this.Js_treePoint[(ply + 1)] += 1;
	}
	 
	 
	private function PawnPts(sq:int, side:int):int
	{
	  var a1:int = this.Js_agress1[sq] & 0x4FFF;
	  var a2:int = this.Js_agress2[sq] & 0x4FFF;
	  var rank:int = IRaw(sq);
	  var fyle:int = IColmn(sq);
	  var s:int = 0;
	  var r:int;
	  var in_square:Boolean;
	  var e:int;
	  var j:int;
	  if (this.Js_c1 == this.Js_white)
	  {
	    s = this.Js_wPawnMvt[sq];
	    if (((sq == 11) && (this.Js_color[19] != this.Js_hollow)) || (
	      (sq == 12) && (this.Js_color[20] != this.Js_hollow)))
	      s += this.Js_junk_pawn;
	    if ((((fyle == 0) || (this.Js_pawc1[(fyle - 1)] == 0))) && ((
	      (fyle == 7) || (this.Js_pawc1[(fyle + 1)] == 0))))
	      s += this.Js_isol_pawn[fyle];
	    else if (this.Js_pawc1[fyle] > 1)
	      s += this.Js_doubled_pawn;
	    if ((a1 < this.Js_xltP) && (this.Js_agress1[(sq + 8)] < this.Js_xltP))
	    {
	      s += this.Js_takeBack[(a2 & 0xFF)];
	      if (this.Js_pawc2[fyle] == 0)
	        s += this.Js_bad_pawn;
	      if (this.Js_color[(sq + 8)] != this.Js_hollow) {
	        s += this.Js_stopped_pawn;
	      }
	    }
	    if (this.Js_pawc2[fyle] == 0)
	    {
	      if (side == this.Js_black)
	        r = rank - 1;
	      else
	        r = rank;
	      in_square = (IRaw(this.Js_pieceMap[this.Js_black][0]) >= r) && (IArrow(sq, this.Js_pieceMap[this.Js_black][0]) < 8 - r);
	 
	      if ((a2 == 0) || (side == this.Js_white))
	        e = 0;
	      else
	        e = 1;
	      for (j = sq + 8; j < 64; j += 8) {
	        if (this.Js_agress2[j] >= this.Js_xltP)
	        {
	          e = 2;
	          break;
	        }
	        if ((this.Js_agress2[j] > 0) || (this.Js_color[j] != this.Js_hollow))
	          e = 1;
	      }
	      if (e == 2)
	        s += this.Js_working * this.Js_pss_pawn3[rank] / 10;
	      else if ((in_square) || (e == 1))
	        s += this.Js_working * this.Js_pss_pawn2[rank] / 10;
	      else if (this.Js_ematrl[this.Js_black] > 0)
	        s += this.Js_working * this.Js_pss_pawn1[rank] / 10;
	      else
	        s += this.Js_pss_pawn0[rank];
	    }
	  }
	  else if (this.Js_c1 == this.Js_black)
	  {
	    s = this.Js_bPawnMvt[sq];
	    if (((sq == 51) && (this.Js_color[43] != this.Js_hollow)) || (
	      (sq == 52) && (this.Js_color[44] != this.Js_hollow))) {
	      s += this.Js_junk_pawn;
	    }
	    if ((((fyle == 0) || (this.Js_pawc1[(fyle - 1)] == 0))) && ((
	      (fyle == 7) || (this.Js_pawc1[(fyle + 1)] == 0))))
	      s += this.Js_isol_pawn[fyle];
	    else if (this.Js_pawc1[fyle] > 1) {
	      s += this.Js_doubled_pawn;
	    }
	    if ((a1 < this.Js_xltP) && (this.Js_agress1[(sq - 8)] < this.Js_xltP))
	    {
	      s += this.Js_takeBack[(a2 & 0xFF)];
	      if (this.Js_pawc2[fyle] == 0)
	        s += this.Js_bad_pawn;
	      if (this.Js_color[(sq - 8)] != this.Js_hollow)
	        s += this.Js_stopped_pawn;
	    }
	    if (this.Js_pawc2[fyle] == 0)
	    {
	      if (side == this.Js_white)
	        r = rank + 1;
	      else
	        r = rank;
	      in_square = (IRaw(this.Js_pieceMap[this.Js_white][0]) <= r) && (IArrow(sq, this.Js_pieceMap[this.Js_white][0]) < r + 1);
	 
	      if ((a2 == 0) || (side == this.Js_black))
	        e = 0;
	      else
	        e = 1;
	      for (j = sq - 8; j >= 0; j -= 8) {
	        if (this.Js_agress2[j] >= this.Js_xltP)
	        {
	          e = 2;
	          break;
	        }
	        if ((this.Js_agress2[j] <= 0) && (this.Js_color[j] == this.Js_hollow))
	          continue;
	        e = 1;
	      }
	 
	      if (e == 2)
	        s += this.Js_working * this.Js_pss_pawn3[(7 - rank)] / 10;
	      else if ((in_square) || (e == 1))
	        s += this.Js_working * this.Js_pss_pawn2[(7 - rank)] / 10;
	      else if (this.Js_ematrl[this.Js_white] > 0)
	        s += this.Js_working * this.Js_pss_pawn1[(7 - rank)] / 10;
	      else
	        s += this.Js_pss_pawn0[(7 - rank)];
	    }
	  }
	  if (a2 > 0)
	  {
	    if ((a1 == 0) || (a2 > this.Js_xltP + 1))
	    {
	      s += this.Js_pinned_p;
	      this.Js_pinned[this.Js_c1] += 1;
	      if (FJunk(sq)) this.Js_pinned[this.Js_c1] += 1;
	    }
	    else if (a2 > a1) {
	      s += this.Js_agress_across; }
	  }
	  return s;
	}
	 
	private function RookPts(sq:int, side:int):int
	{
	  var s:INT = new INT;
	  var mob:INT = new INT;
	 
	  s.i = this.Js_rookPlus;
	  XRayBR(sq, s, mob);
	  s.i += this.Js_mobRook[mob.i];
	  var fyle:int = IColmn(sq);
	  if (this.Js_pawc1[fyle] == 0)
	    s.i += this.Js_semiOpen_rook;
	  if (this.Js_pawc2[fyle] == 0)
	    s.i += this.Js_semiOpen_rookOther;
	  if ((this.Js_pmatrl[this.Js_c2] > 100) && (IRaw(sq) == this.Js_raw7[this.Js_c1]))
	    s.i += 10;
	  if (this.Js_working > 2)
	    s.i += 14 - this.Js_crossData[(sq * 64 + this.Js_pieceMap[this.Js_c2][0])];
	  var a2:int = this.Js_agress2[sq] & 0x4FFF;
	  if (a2 > 0)
	  {
	    var a1:int = this.Js_agress1[sq] & 0x4FFF;
	    if ((a1 == 0) || (a2 > this.Js_xltR + 1))
	    {
	      s.i += this.Js_pinned_p;
	      this.Js_pinned[this.Js_c1] += 1;
	      if (FJunk(sq)) this.Js_pinned[this.Js_c1] += 1;
	    }
	    else if ((a2 >= this.Js_xltR) || (a1 < this.Js_xltP)) {
	      s.i += this.Js_agress_across; }
	  }
	  return s.i;
	}
	 
	private function KingPts(sq:int, side:int):int
	{
	  var s:INT = new INT;
	 
	  s.i = this.Js_kingMvt[this.Js_c1][sq];
	  if ((this.Js_safe_King > 0) && ((
	    (this.Js_fDevl[this.Js_c2] != 0) || (this.Js_working > 0))))
	  {
	    XRayKg(sq, s);
	  }
	  if (this.Js_roquer[this.Js_c1] != 0)
	    s.i += this.Js_castle_K;
	  else if (this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_c1]] != 0) {
	    s.i += this.Js_moveAcross_K;
	  }
	  var fyle:int = IColmn(sq);
	  if (this.Js_pawc1[fyle] == 0)
	    s.i += this.Js_semiOpen_king;
	  if (this.Js_pawc2[fyle] == 0) {
	    s.i += this.Js_semiOpen_kingOther;
	  }
	  switch (fyle)
	  {
	  case 5:
	    if (this.Js_pawc1[7] == 0)
	    {
	      s.i += this.Js_semiOpen_king; }
	    if (this.Js_pawc2[7] == 0)
	      s.i += this.Js_semiOpen_kingOther;
	  case 0:
	  case 4:
	  case 6:
	    if (this.Js_pawc1[(fyle + 1)] == 0)
	    {
	      s.i += this.Js_semiOpen_king; }
	    if (this.Js_pawc2[(fyle + 1)] == 0)
	      s.i += this.Js_semiOpen_kingOther;
	    break;
	  case 2:
	    if (this.Js_pawc1[0] == 0)
	    {
	      s.i += this.Js_semiOpen_king; }
	    if (this.Js_pawc2[0] == 0)
	      s.i += this.Js_semiOpen_kingOther;
	  case 1:
	  case 3:
	  case 7:
	    if (this.Js_pawc1[(fyle - 1)] == 0)
	    {
	      s.i += this.Js_semiOpen_king; }
	    if (this.Js_pawc2[(fyle - 1)] == 0)
	      s.i += this.Js_semiOpen_kingOther;
	    break;
	  }
	 
	  var a2:int = this.Js_agress2[sq] & 0x4FFF;
	  if (a2 > 0)
	  {
	    var a1:int = this.Js_agress1[sq] & 0x4FFF;
	    if ((a1 == 0) || (a2 > this.Js_xltK + 1))
	    {
	      s.i += this.Js_pinned_p;
	      this.Js_pinned[this.Js_c1] += 1;
	    }
	    else {
	      s.i += this.Js_agress_across; }
	  }
	  return s.i;
	}
	 
	private function AvailMov(side:int, ply:int):void
	{
	  var xside:int = this.Js_otherTroop[side];
	  this.Js_treePoint[(ply + 1)] = this.Js_treePoint[ply];
	  if (this.Js_ptValue == 0)
	    this.Js_scoreWin0 = this.Js_eliminate0[ply];
	  else
	    this.Js_scoreWin0 = this.Js_ptValue;
	  this.Js_scoreWin1 = this.Js_eliminate1[ply];
	  this.Js_scoreWin2 = this.Js_eliminate2[ply];
	  this.Js_scoreWin3 = this.Js_eliminate3[ply];
	  if (ply > 2)
	    this.Js_scoreWin4 = this.Js_eliminate1[(ply - 2)];
	  else
	    this.Js_scoreWin4 = 0;
	  for (var i:int = this.Js_piecesCount[side]; i >= 0; --i)
	  {
	    var square:int = this.Js_pieceMap[side][i];
	    MultiMov(ply, square, side, xside);
	  }
	  if (this.Js_roquer[side] != 0)
	    return;
	  var f:int = this.Js_pieceMap[side][0];
	  if (DoCastle(side, f, f + 2, 0) != 0)
	  {
	    AttachMov(ply, f, f + 2, this.Js_castle_msk, xside);
	  }
	  if (DoCastle(side, f, f - 2, 0) == 0)
	    return;
	  AttachMov(ply, f, f - 2, this.Js_castle_msk, xside);
	}
	 
	private function BishopPts(sq:int, side:int):int
	{
	  var s:INT = new INT;
	  var mob:INT = new INT;
	 
	  s.i = this.Js_bishopMvt[this.Js_c1][sq];
	  XRayBR(sq, s, mob);
	  s.i += this.Js_mobBishop[mob.i];
	  var a2:int = this.Js_agress2[sq] & 0x4FFF;
	  if (a2 > 0)
	  {
	    var a1:int = this.Js_agress1[sq] & 0x4FFF;
	    if ((a1 == 0) || (a2 > this.Js_xltBN + 1))
	    {
	      s.i += this.Js_pinned_p;
	      this.Js_pinned[this.Js_c1] += 1;
	      if (FJunk(sq)) this.Js_pinned[this.Js_c1] += 1;
	    }
	    else if ((a2 >= this.Js_xltBN) || (a1 < this.Js_xltP)) {
	      s.i += this.Js_agress_across; }
	  }
	  return s.i;
	}
	 
	private function ValidateMov(side:int, node:BTREE, tempb:INT, tempc:INT, tempsf:INT, tempst:INT, gainScore:INT):void
	{
	  var xside:int = this.Js_otherTroop[side];
	  this.Js_nGameMoves += 1;
	  var f:int = node.f;
	  var t:int = node.t;
	  this.Js_indenSqr = -1;
	  this.Js_origSquare = f;
	  this.Js_destSquare = t;
	  gainScore.i = 0;
	  this.Js_movesList[this.Js_nGameMoves].gamMv = (f << 8 | t);
	  if ((node.flags & this.Js_castle_msk) != 0)
	  {
	    this.Js_movesList[this.Js_nGameMoves].piece = this.Js_empty;
	    this.Js_movesList[this.Js_nGameMoves].color = side;
	    DoCastle(side, f, t, 1);
	  }
	  else
	  {

	    tempc.i = this.Js_color[t];
	    tempb.i = this.Js_board[t];
	    tempsf.i = this.Js_scoreOnBoard[f];
	    tempst.i = this.Js_scoreOnBoard[t];
	    this.Js_movesList[this.Js_nGameMoves].piece = tempb.i;
	    this.Js_movesList[this.Js_nGameMoves].color = tempc.i;
	    if (tempc.i != this.Js_hollow)
	    {
	      UpdatePiecMap(tempc.i, t, 1);
	      if (tempb.i == this.Js_pawn)
	        this.Js_pawnMap[tempc.i][IColmn(t)] += -1;
	      if (this.Js_board[f] == this.Js_pawn)
	      {
	        this.Js_pawnMap[side][IColmn(f)] += -1;
	        this.Js_pawnMap[side][IColmn(t)] += 1;
	        var cf:int = IColmn(f);
	        var ct:int = IColmn(t);
	        if (this.Js_pawnMap[side][ct] > 1 + this.Js_pawnMap[side][cf])
	          gainScore.i -= 15;
	        else if (this.Js_pawnMap[side][ct] < 1 + this.Js_pawnMap[side][cf])
	          gainScore.i += 15;
	        else if ((ct == 0) || (ct == 7) || (this.Js_pawnMap[side][(ct + ct - cf)] == 0))
	          gainScore.i -= 15;
	      }
	      this.Js_matrl[xside] -= this.Js_valueMap[tempb.i];
	      if (tempb.i == this.Js_pawn) {
	        this.Js_pmatrl[xside] -= this.Js_pawnVal;
	      }
	 
	      gainScore.i += tempst.i;
	      this.Js_nMvtOnBoard[t] += 1;
	    }
	    this.Js_color[t] = this.Js_color[f];
	    this.Js_board[t] = this.Js_board[f];
	    this.Js_scoreOnBoard[t] = this.Js_scoreOnBoard[f];
	    this.Js_pieceIndex[t] = this.Js_pieceIndex[f];
	    this.Js_pieceMap[side][this.Js_pieceIndex[t]] = t;
	    this.Js_color[f] = this.Js_hollow;
	    this.Js_board[f] = this.Js_empty;
	    if (this.Js_board[t] == this.Js_pawn)
	      if (t - f == 16)
	        this.Js_indenSqr = (f + 8);
	      else if (f - t == 16)
	        this.Js_indenSqr = (f - 8);
	    if ((node.flags & this.Js_promote) != 0)
	    {
	      if (this.Js_proPiece != 0)
	        this.Js_board[t] = this.Js_proPiece;
	      else
	        this.Js_board[t] = (node.flags & this.Js_pawn_msk);
	      if (this.Js_board[t] == this.Js_queen)
	        this.Js_withQueen[side] += 1;
	      else if (this.Js_board[t] == this.Js_rook)
	        this.Js_withRook[side] += 1;
	      else if (this.Js_board[t] == this.Js_bishop)
	        this.Js_withBishop[side] += 1;
	      else if (this.Js_board[t] == this.Js_knight)
	        this.Js_withKnight[side] += 1;
	      this.Js_pawnMap[side][IColmn(t)] += -1;
	      this.Js_matrl[side] += this.Js_valueMap[this.Js_board[t]] - this.Js_pawnVal;
	      this.Js_pmatrl[side] -= this.Js_pawnVal;
	 
	      gainScore.i -= tempsf.i;
	    }
	    if ((node.flags & this.Js_enpassant_msk) != 0) {
	      PrisePassant(xside, f, t, 1);
	    }
	 
	    this.Js_nMvtOnBoard[f] += 1;
	  }
	}
	 
	private function Peek(p1:int, p2:int):void
	{
	  var s0:int = this.Js_Tree[p1].score;
	  var p0:int = p1;
	  for (var p:int = p1 + 1; p <= p2; ++p)
	  {
	    var s:int = this.Js_Tree[p].score;
	    if (s <= s0)
	      continue;
	    s0 = s;
	    p0 = p;
	  }
	 
	  if (p0 == p1)
	  {
	    return;
	  }
	 
	  MoveTree(this.Js_tmpTree, this.Js_Tree[p1]);
	  MoveTree(this.Js_Tree[p1], this.Js_Tree[p0]);
	  MoveTree(this.Js_Tree[p0], this.Js_tmpTree);
	}
	 
	private function Seek(side:int, ply:int, depth:int, alpha:int, beta:int, bstline:Array, rpt:INT):int
	{
	  var tempb:INT = new INT;
	  var tempc:INT = new INT;
	  var tempsf:INT = new INT;
	  var tempst:INT = new INT;
	  var rcnt:INT = new INT;

	  var slk:INT = new INT;
	  var InChk:INT = new INT;
	  var nxtline:Array = [];		// new int[this.Js_maxDepth];

	  var node:BTREE = new BTREE;
	 
	  this.Js_cNodes += 1;
	  var xside:int = this.Js_otherTroop[side];

	  if (ply <= this.Js_depth_Seek + 3)
		{
		rpt.i = IRepeat(rpt.i);
		}
	  else
		{
		rpt.i = 0;
		}
	 
	  if ((rpt.i == 1) && (ply > 1))
	  {
	    if (this.Js_nMovesMade <= 11) {
	      return 100;
	    }
	    return 0;
	  }
	 
	  var score3:int = DoCalc(side, ply, alpha, beta, this.Js_gainScore.i, slk, InChk);
	  if (score3 > 9000)
	  {
	    bstline[ply] = 0;
	 
	    return score3;
	  }
	 
	  if (depth > 0)
	  {
	    if (InChk.i != 0)
	    {
	      depth = (depth < 2) ? 2 : depth;
	    }
	    else if ((this.Js_menacePawn[(ply - 1)] != 0) || (
	      (this.Js_flag.recapture) && (score3 > alpha) && (score3 < beta) && (ply > 2) && (this.Js_flagEat[(ply - 1)] != 0) && (this.Js_flagEat[(ply - 2)] != 0)))
	    {
	      ++depth;
	    }
	 
	  }
	  else if ((score3 >= alpha) && ((
	    (InChk.i != 0) || (this.Js_menacePawn[(ply - 1)] != 0) || (
	    (this.Js_pinned[side] > 1) && (ply == this.Js_depth_Seek + 1)))))
	  {
	    ++depth;
	  }
	  else if ((score3 <= beta) && 
	    (ply < this.Js_depth_Seek + 4) && (ply > 4) && (this.Js_flagCheck[(ply - 2)] != 0) && (this.Js_flagCheck[(ply - 4)] != 0) && (this.Js_flagCheck[(ply - 2)] != this.Js_flagCheck[(ply - 4)]))
	  {
	    ++depth;
	  }
	  var d:int;
	  if (this.Js_depth_Seek == 1)
	    d = 7;
	  else
	    d = 11;
	  if ((ply > this.Js_depth_Seek + d) || ((depth < 1) && (score3 > beta)))
	  {
	    return score3;
	  }
	 
	  if (ply > 1) {
	    if (depth > 0)
	      AvailMov(side, ply);
	    else
	      AvailCaptur(side, ply);
	  }
	  if (this.Js_treePoint[ply] == this.Js_treePoint[(ply + 1)])
	  {
	    return score3;
	  }
	  var cf:int;
	  if ((depth < 1) && (ply > this.Js_depth_Seek + 1) && (this.Js_flagCheck[(ply - 2)] == 0) && (slk.i == 0))
	  {
	    cf = 1;
	  }
	  else cf = 0;
	  var best:int;
	  if (depth > 0)
	    best = -12000;
	  else {
	    best = score3;
	  }
	  if (best > alpha)
	    alpha = best;
	  var pbst:int = this.Js_treePoint[ply];
	  var pnt:int = pbst;
	  var j:int;
	  var mv:int;
	  while ((pnt < this.Js_treePoint[(ply + 1)]) && (best <= beta))
	  {
	    if (ply > 1) Peek(pnt, this.Js_treePoint[(ply + 1)] - 1);
	 

	    node = this.Js_Tree[pnt];		//_BTREE

	    mv = node.f << 8 | node.t;
	    nxtline[(ply + 1)] = 0;
	 
	    if ((cf != 0) && (score3 + node.score < alpha))
	    {
	      break;
	    }
	 
	    if ((node.flags & this.Js__idem) == 0)
	    {
	      ValidateMov(side, node, tempb, tempc, tempsf, tempst, this.Js_gainScore);
	      this.Js_flagEat[ply] = (node.flags & this.Js_capture);
	      this.Js_menacePawn[ply] = (node.flags & this.Js_menace_pawn);
	      this.Js_scoreTP[ply] = node.score;
	      this.Js_ptValue = node.replay;
	 
	      node.score = (-Seek(xside, ply + 1, (depth > 0) ? depth - 1 : 0, -beta, -alpha, nxtline, rcnt));
	 
	      if (Math.abs(node.score) > 9000)
	        node.flags |= this.Js__idem;
	      else if (rcnt.i == 1) {
	        node.score /= 2;
	      }
	 
	      if ((rcnt.i >= 2) || (this.Js_nGameMoves - this.Js_fiftyMoves > 99) || (
	        (node.score == 9999 - ply) && (this.Js_flagCheck[ply] == 0)))
	      {
	        node.flags |= this.Js__idem;
	        if (side == this.Js_computer)
	          node.score = this.Js_specialScore;
	        else
	          node.score = (-this.Js_specialScore);
	      }
	      node.replay = nxtline[(ply + 1)];

	      UnValidateMov(side, node, tempb, tempc, tempsf, tempst);

	    }
	 
	    if ((node.score > best) && (!(this.Js_flag.timeout)))
	    {
	      if ((depth > 0) && 
	        (node.score > alpha) && ((node.flags & this.Js__idem) == 0)) {
	        node.score += depth;
	      }
	      best = node.score;
	      pbst = pnt;
	      if (best > alpha) alpha = best;
	      for (j = ply + 1; nxtline[(++j)] > 0; )
	      {
	        bstline[j] = nxtline[j]; 
	      }
	      bstline[j] = 0;
	      bstline[ply] = mv;
	      if (ply == 1)
	      {
	        if (best > this.Js_root.score)
	        {
	          MoveTree(this.Js_tmpTree, this.Js_Tree[pnt]);
	          for (j = pnt - 1; j >= 0; --j)
	          {
	            MoveTree(this.Js_Tree[(j + 1)], this.Js_Tree[j]);
	          }
	          MoveTree(this.Js_Tree[0], this.Js_tmpTree);
	          pbst = 0;
	        }
	 
	        if (this.Js_depth_Seek > 2) ShowThink(best, bstline);

	      }
	    }
	    if (this.Js_flag.timeout)
	    {
	      return (-this.Js_scoreTP[(ply - 1)]);
	    }
	    ++pnt;
	  }
	 

	  node = this.Js_Tree[pbst];		//_BTREE

	  mv = node.f << 8 | node.t;
	 
	  if (depth > 0)
	  {
	    j = node.f << 6 | node.t;
	    if (side == this.Js_black)
	      j |= 4096;

	    if (this.Js_storage[j] < 150)
	      this.Js_storage[j] = (this.Js_storage[j] + depth * 2);	//(short)

	    if (node.t != (this.Js_movesList[this.Js_nGameMoves].gamMv & 0xFF)) {
	      if (best <= beta) {
	        this.Js_eliminate3[ply] = mv;
	      } else if (mv != this.Js_eliminate1[ply])
	      {
	        this.Js_eliminate2[ply] = this.Js_eliminate1[ply];
	        this.Js_eliminate1[ply] = mv;
	      }
	    }
	    if (best > 9000)
	      this.Js_eliminate0[ply] = mv;
	    else {
	      this.Js_eliminate0[ply] = 0;
	    }
	  }
	  if ((new Date()).getTime() - this.Js_startTime > this.Js_searchTimeout) {
	      this.Js_flag.timeout = true;
	  }

	  return best;
	}
	
	// This sets active side
	private function SwitchSides( oposit:Boolean ):void
	{
	 var whitemove:Boolean = (this.Js_nGameMoves % 2 == 0);
	 var whitecomp:Boolean = (this.Js_computer == this.Js_white);
	 if( oposit == ( whitemove == whitecomp) )
	 {

	 this.Js_player = this.Js_otherTroop[this.Js_player];
	 this.Js_computer = this.Js_otherTroop[this.Js_computer];
	 this.Js_enemy = this.Js_otherTroop[this.Js_enemy];

	 this.Js_JESTER_TOPLAY = this.Js_otherTroop[this.Js_JESTER_TOPLAY];

	 }
	 this.Js_fUserWin_kc=false;
	}


	private function GetFen():String
	{
	  var fen:String = "";
	  var i:int = 64-8;
	  var pt:int = 0;
	  do
	    {

	    var piece:String = (this.Js_color[i]==this.Js_white ? this.Js_upperNot[this.Js_board[i]] : this.Js_lowerNot[this.Js_board[i]]);
	    if(piece==" ") pt+=1;
	    else
		{
		 if(pt>0) { fen += pt.toString(); pt = 0; }
		 fen += piece;
		}
	    i++;
	    if(i % 8 == 0) i -= 16;
	    if( (i>=0) && (i % 8 == 0))
		{
		 if(pt>0) { fen += pt.toString(); pt = 0; }
		 fen += "/";
		}
	    }
	  while (i>=0);
 	  if(pt>0) { fen += pt.toString(); pt = 0; }	

	  fen += " " + ( (this.Js_nGameMoves % 2 == 0) ? "w" : "b" ) + " ";


	  var wKm:Boolean = ( (this.Js_roquer[ this.Js_white ]>0) || (this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_white]]>0) );
	  var wLRm:Boolean = ( this.Js_nMvtOnBoard[this.Js_queenRook[this.Js_white]]>0 );
	  var wRRm:Boolean = ( this.Js_nMvtOnBoard[this.Js_kingRook[this.Js_white]]>0 );

	  var bKm:Boolean = ( (this.Js_roquer[ this.Js_black ]>0) || (this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_black]]>0) );
	  var bLRm:Boolean = ( this.Js_nMvtOnBoard[this.Js_queenRook[this.Js_black]]>0 );
	  var bRRm:Boolean = ( this.Js_nMvtOnBoard[this.Js_kingRook[this.Js_black]]>0 );

	  if( (wKm || wLRm || wRRm) && (bKm || bLRm || bRRm) )
		{
		 fen += "-";
		}
	  else
		{
		if( (!wKm) && (!wRRm) ) fen += "K";
		if( (!wKm) && (!wLRm) ) fen += "Q";
		if( (!bKm) && (!bRRm) ) fen += "k";
		if( (!bKm) && (!bLRm) ) fen += "q";
		}
	  fen += " ";

	  if ((this.Js_root.flags & this.Js_enpassant_msk) != 0)
		{
		fen += this.Js_szAlgMvt[ this.Js_root.t - (this.Js_color[this.Js_root.t]==this.Js_white ? 8 : -8 ) ] + " ";
	    	}
	  else fen += "- ";

	  var mv50:int = this.Js_nGameMoves - this.Js_fiftyMoves;
	  fen += (mv50>0 ? mv50.toString() : "0" ) + " ";

	  fen += (this.Js_nMovesMade + ((this.Js_nGameMoves % 2 == 0) ? 1 : 0)).toString();

	  return fen;

	}

		// for this.Js_enemy move only
		// use SwitchSides before if oposit movement required
		// ignores checkmate status flag

	private function EnterMove( from_sq:String, to_sq:String, promo:String ):void
	{
	  var mvt:int = 0;
	  var fsq_mvt:int = 0;
	  var tsq_mvt:int = 0;

	  SwitchSides( true );

	  var i:int = 0;
	  do {
	    if(this.Js_szAlgMvt[i]==from_sq) fsq_mvt = i;
	    if(this.Js_szAlgMvt[i]==to_sq) tsq_mvt = i;
	  }
	  while (++i < 64);

	  this.Js_proPiece = 0;
	  i = 2;
	  do {
	     if( this.Js_upperNot[i]==promo ) this.Js_proPiece = i;
	  }
	  while (++i < 6);

	  this.Js_root.f = 0;
	  this.Js_root.t = 0;
	  this.Js_root.flags = 0;
	 
	  var rgch:Array = [];		//new char[8];
	 
	  this.Js_myPiece = this.Js_rgszPiece[this.Js_board[fsq_mvt]];
	 
	  if (this.Js_board[fsq_mvt] == this.Js_pawn)
	  {
	    var iflag:int = 0;
	    if ( (tsq_mvt < 8) || (tsq_mvt > 55) )
	    {
	      iflag = this.Js_promote | this.Js_proPiece;
	    }
	    Lalgb(fsq_mvt, tsq_mvt, iflag);
	  }
	 
	  i=0;
	  rgch[i++] = from_sq.charCodeAt(0);	//(char)
	  rgch[i++] = from_sq.charCodeAt(1);
	  rgch[i++] = to_sq.charCodeAt(0);	//(char)
	  rgch[i++] = to_sq.charCodeAt(1);
	  if( promo.length>0 )
		{
		rgch[i++] = "=";
		rgch[i++] = promo;
		}
	  rgch[i++] = 0;
	 
	  this.Js_flag.timeout = true;
	 
	  var iMvt:int = CheckMov(rgch, 0);
	 
	  if (iMvt != 0)
	  {
	    WatchPosit();
	    UpdateDisplay();
	    IfCheck();
	    if (!(CheckMatrl())) this.Js_bDraw = 1;
	    ShowStat();
	 
	    ShowMov(rgch);
	 
	    this.Js_depth_Seek = 0;
	  }
							
	}

	// ignores flags...
	// use after InitGame

	private function SetFen(fen:String):void
	{
	  var fen2:String = "";
	  var i:int = 0;
	  do
	    {
	    var ch:String = fen.charAt(i);
	    var pt:int = parseInt(ch);
	    if(pt>0)
		{
	    	while((pt--)>0) fen2 += " ";
		}
	    else
		{
		if(ch == " ") break;
		if(!(ch=="/")) fen2 += ch;
		}
	    }
	  while ((i++)<fen.length);

	  i = 64-8;
	  var i2:int = 0;
	  do
	    {
	    this.Js_board[i] = this.Js_empty;
	    this.Js_color[i] = this.Js_hollow;
	    var piece:String = fen2.charAt(i2++);
	    var j:int = 1;
	    do {
		if( (this.Js_upperNot[j]==piece) || (this.Js_lowerNot[j]==piece) )
			{
			this.Js_board[i] = j;
			this.Js_color[i] = ( (this.Js_upperNot[j]==piece) ? this.Js_white : this.Js_black );
			}
	       }
	    while (++j <= 6);

	    this.Js_nMvtOnBoard[i] = 1;

	    i++;
	    if(i % 8 == 0) i -= 16;
	    }
	  while (i>=0);

	  this.Js_roquer[ this.Js_white ] = 1;
	  this.Js_roquer[ this.Js_black ] = 1;

	  this.Js_root.f = 0;
	  this.Js_root.t = 0;
	  this.Js_root.flags = 0;

	  var side:String = "";
	  var enp:String = "";
	  var mcnt:String = "";
	  var mv50s:String = "";

	  var st:int = 0;
	  i = 0;
	  do
	    {
	    ch = fen.charAt(i);
	    if(ch == " ") st++;
	    else if(st == 1)
		{
		side = ch;
		}
	    else if(st == 2)
		{		
		if(ch=="k" || ch=="q")
			{
			this.Js_roquer[ this.Js_black ] = 0;
			this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_black]] = 0;

			if(ch=="q") this.Js_nMvtOnBoard[this.Js_queenRook[this.Js_black]] = 0;
			if(ch=="k") this.Js_nMvtOnBoard[this.Js_kingRook[this.Js_black]] = 0;
			}
		if(ch=="K" || ch=="Q")
			{
			this.Js_roquer[ this.Js_white ] = 0;
			this.Js_nMvtOnBoard[this.Js_kingPawn[this.Js_white]] = 0;

			if(ch=="Q") this.Js_nMvtOnBoard[this.Js_queenRook[this.Js_white]] = 0;
			if(ch=="K") this.Js_nMvtOnBoard[this.Js_kingRook[this.Js_white]] = 0;
			}
		}
	    else if(st == 3)
		{
		enp += ch;
		}
	    else if(st == 4)
		{
		mv50s += ch;
		}
	    else if(st == 5)
		{
		mcnt += ch;
		}		
	    }
	  while ((i++)<fen.length);

	  if(enp.length>0)
	  {
	   i = 0;
	   do
	    {
	    if(this.Js_szAlgMvt[i]==enp)
		{
		this.Js_root.f = ((i<32) ? i-8: i+8 );
		this.Js_root.t = ((i<32) ? i+8: i-8 );
		this.Js_root.flags |= this.Js_enpassant_msk;
		}
	    }
	   while (++i < 64);
	  }

	  this.Js_nGameMoves = (parseInt(mcnt) * 2) - (side=="w" ? 2 : 1);
	  this.Js_nMovesMade = parseInt(mcnt) - ((this.Js_nGameMoves % 2==0) ? 1 : 0 );
	  this.Js_fiftyMoves = this.Js_nGameMoves - parseInt( mv50s );

	  this.Js_flip = (this.Js_nGameMoves % 2 > 0);

	  MessageOut("(FEN)", true);
	  UpdateDisplay();
	  InitStatus();

	  ResetFlags();

	  this.Js_flag.mate = false;
	  this.Js_flag.recapture = true;

	  IfCheck();
	  if (!(CheckMatrl())) this.Js_bDraw = 1;
	  ShowStat();

	}

	private function ResetFlags():void
	{
	  this.Js_fInGame = true;
	  this.Js_fCheck_kc = false;
	  this.Js_fMate_kc = false;
	  this.Js_fAbandon = false;
	  this.Js_bDraw = 0;
	  this.Js_fStalemate = false;
	  this.Js_fUserWin_kc = false;
	}

	private function Jst_Play():void
	{
	  SwitchSides( false );

	  this.Js_fEat = false;
	  ResetFlags();

	  this.Js_realBestScore = -20000;
	  this.Js_realBestDepth = 0;
	  this.Js_realBestMove = 0;
	 
	  ComputerMvt();

	  UpdateDisplay();
	 
	}


	private function UndoMov():void
	{
	if (this.Js_nGameMoves > 0)
	  {
	  SwitchSides( false );

	  Undo();

	  UpdateDisplay();

	  ResetFlags();

	  ShowStat();
	  MessageOut("(undo)", true);

	  this.Js_flip = false;
	  if(this.Js_nGameMoves % 2 == 0)
		{
		 this.Js_nMovesMade -= 1;
		}
	  else
		{
		this.Js_flip = true;
		}  
	  }
	}


	//-----------------------------------------
	// SAMPLES...
	//-----------------------------------------

	// moves entering
	private function autosample1():void
	{
	EnterMove("e2","e4","");
	EnterMove("c7","c5","");
	EnterMove("f1","e2","");
	EnterMove("c5","c4","");
	EnterMove("b2","b4","");
	EnterMove("c4","b3","");
	EnterMove("g1","f3","");
	EnterMove("b3","b2","");
	EnterMove("e1","g1","");
	EnterMove("b2","a1","R");		// promote rook
	MessageOut("FEN:"+GetFen(),true);
	}
	
	// automatic game
	private function autosample2():void
	{
	 MessageOut("Autogame started...",true);
	 autogame2 = true;		// For timer...
	}

	// undo cases
	private function autosample3():void
	{
	EnterMove("e2","e4","");
	UndoMov();
	EnterMove("a2","a4","");
	EnterMove("c7","c5","");
	UndoMov();
	Jst_Play();
	UndoMov()
	MessageOut(GetFen(),true);
	}

	// set FEN case
	private function autosample4():void
	{
	SetFen("7k/Q7/2P2K2/8/8/8/8/8 w - - 0 40");	// set given FEN
	Jst_Play();
	MessageOut(GetFen(),true);
	}

	private function onTimer(evt:TimerEvent):void
	{
	if (autogame2) Jst_Play();	// next move
	}
	
	public function FlexView():void
    {
	
	InitGame();		// Also to start a new game again
	
	timer.addEventListener(TimerEvent.TIMER, onTimer);
	timer.start();
	
	//autosample1();
	//autosample2();
	//autosample3();
	//autosample4();

	//setTimeout('autosample3();',1000);

    super();
    this.addEventListener(Event.ENTER_FRAME, onFrameEnter);
	this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);

	//this.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
	
	if (stage) init();
	else addEventListener(Event.ADDED_TO_STAGE, init);
		 
    }
    
	public function CallingMe(p:String):String
	{
	var res:String = "";
	if (p.substr(0, 3) == "sd ") Js_maxDepthSeek = parseInt( p.substr(3) );
	if (p.substr(0, 3) == "st ") Js_searchTimeout = parseInt( p.substr(3) ) * 1000;
	if (p.substr(0, 2) == "go") Jst_Play();
	if (p.substr(0, 6) == "getfen") res = GetFen();
	if (p.substr(0, 7) == "setfen ") SetFen( p.substr(7) );
	if (p.substr(0, 4) == "undo") UndoMov();
	if (p.substr(0, 3) == "new") { InitGame(); UpdateDisplay(); }
	if (p.substr(0, 5) == "move ") EnterMove(p.substr(5,2), p.substr(7,2), (p.length>9? p.substr(9,1) : ""));
	if (p.substr(0, 10) == "autosample") autosample2();
	return res
	}
	
	private function CallingJS(ch:String, p:String):String
	{
	var reqstr:String = "CallingJS(" + '"' + ch + '"' + "," + '"' + p + '"' +")";
	var ret:String = "";
	if (swf_loadflag) ret = ExternalInterface.call(reqstr);
	return ret;
	}
	
	private function onMouseDown(event:MouseEvent):void
    {
	 CallingJS("MOUSEPRESS", "");
	}
	
	private function onFrameEnter(event:Event):void
    {
	 if (!swf_loadflag && ExternalInterface.available)
		{
		ExternalInterface.addCallback("CallingMe", CallingMe );  
			
		pageURL = ExternalInterface.call('window.location.href.toString');
		if (pageURL == null) { pageURL = ExternalInterface.call('document.location.href.toString'); }
		if (pageURL == null) { pageURL = ""; }

		ExternalInterface.call('swf_loaded');
		swf_loadflag = true;
		UpdateDisplay();
		}
	}
	private function init(e:Event = null):void 
	{
	 removeEventListener(Event.ADDED_TO_STAGE, init);
	 addChild(jestlogo0);			
	}

	

  }
	
}