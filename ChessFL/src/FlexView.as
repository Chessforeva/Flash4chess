package
{
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
	  
	 [Embed(source='jestlogo.png')]
	 private static var jestlogo_image:Class;
	 private var jestlogo0:Bitmap = new jestlogo_image();
	 [Embed(source='flashlogo.jpg')]
	 private static var flashlogo_image:Class;
	 private var flashlogo0:Bitmap = new flashlogo_image();
	 [Embed(source='buttons.png')]
	 private static var buttons_image:Class;
	 
	 [Embed(source='w_sq.png')]
	 private static var wsq_image:Class;
	 [Embed(source='b_sq.png')]
	 private static var bsq_image:Class;
	 [Embed(source='cursor.png')]
	 private static var cursor_image:Class;
	 private var cursor0:Bitmap = new cursor_image();
	 	 
	 [Embed(source='Chess_wp.png')]
	 private static var wp_image:Class;
	 [Embed(source='Chess_wn.png')]
	 private static var wn_image:Class;
	 [Embed(source='Chess_wb.png')]
	 private static var wb_image:Class;
	 [Embed(source='Chess_wr.png')]
	 private static var wr_image:Class;
	 [Embed(source='Chess_wq.png')]
	 private static var wq_image:Class;
	 [Embed(source='Chess_wk.png')]
	 private static var wk_image:Class;
	 [Embed(source='Chess_bp.png')]
	 private static var bp_image:Class;
	 [Embed(source='Chess_bn.png')]
	 private static var bn_image:Class;
	 [Embed(source='Chess_bb.png')]
	 private static var bb_image:Class;
	 [Embed(source='Chess_br.png')]
	 private static var br_image:Class;
	 [Embed(source='Chess_bq.png')]
	 private static var bq_image:Class;
	 [Embed(source='Chess_bk.png')]
	 private static var bk_image:Class;
	 
	 [Embed(source='expl1.png')]
	 private static var expl1_image:Class;
	 [Embed(source='expl2.png')]
	 private static var expl2_image:Class;
	 [Embed(source='expl3.png')]
	 private static var expl3_image:Class;
	 [Embed(source='expl4.png')]
	 private static var expl4_image:Class;
	 private var expl0:Bitmap = new Bitmap();
	 
	 // Variables for chess displaying, and related to it
	 
	 private var External:Boolean = false;			// set true for external version -
													// javascript interface with flash
													// chess engine
	 private var pageURL:String = "";
	 private var swf_loadflag:Boolean = false;
	 
	 private var bsq0:Array = [];
	 private var bh0:Array = [];
	 private var BS:int = 0;		// Board size 

	 private var bt0:Array = [];
	 private var bt1:Array = [];
	 
	 private var logoshow:int = 0;
	 private var anims:int = 0;
	 private var apc2:int = 0;
	 private var apcE:int = 0;
	 private var moved:String = "";
	 private var st0:TextField = new TextField();
	 
	 private var prom0:Bitmap = new Bitmap();
	 private var plys0:TextField = new TextField();
	 private var secs0:TextField = new TextField();	
	 private var plys:int = 0;
	 private var secs:int = 0;	 
	 
	 private var pc0:Array = [];
	 private var rev:Boolean = false;
	 
	 private var PromoPiece:String = "";
	 
	 private var dragat:String = "";
	 private var GameOver:Boolean = false;
	 
	 private var timer:Timer = new Timer(1000);
	 private var autogame2:Boolean = false;

	 private var c0_opn:Array = [""];
	 private var opnmv:String = "";
	 
	 // Jester chess engine of www.ludochess.com
	 // ported code part (originally java, then javascript, then actionscript)
	  
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
	  if (!External) moved = mv2;

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
	  this.Js_maxDepthSeek = (this.Js_maxDepth - 1);

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
	if (logoshow > 0)
		{
		logoshow--;
		if (logoshow <= 0)
			{
			removeChild(jestlogo0);
			StatusMess("Hello!\nYour move");
			}
		}
	if (anims > 0 )
		{
		if (anims == 20)
			{
			apc2 = atPcI(moved.substr(0,2));	// Saves piece to apc2...
			apcE = atPcI(moved.substr(3, 2));	// Saves piece to explode to apcE...
			if (apc2 < 0) anims = 6;
			}
		anims--;
		
		if (anims == 16) ExplShow(1);
		if (anims == 12) ExplShow(2);
		if (anims == 10) ExplShow(3);
		if (anims == 7) ExplShow(4);		
		if (anims > 5)
			{
			pc0[apc2].x += (BS/8) * (moved.charCodeAt(3) - moved.charCodeAt(0)) * (1/(20-5))* (rev? -1:1);
			pc0[apc2].y += (BS/8) *	(moved.charCodeAt(4) - moved.charCodeAt(1)) * (1/(20-5))* (rev? 1:-1);
			}
		if (anims == 5) {  ExplShow(5); SetUpBoard(); }
		if (anims == 0)
			{
			if (rev == ( this.Js_nGameMoves % 2 == 0 ) ) DoMove();
			}
		}
	}
	
	// The main program function - all it starts here
		
	public function FlexView():void
    {
	
	InitGame();		// Also to start a new game again
	
	timer.addEventListener(TimerEvent.TIMER, onTimer);
	timer.start();
	timer.delay = 10;
	
	//autosample1();
	//autosample2();
	//autosample3();
	//autosample4();

	//setTimeout('autosample2();',1000);

    super();
    this.addEventListener(Event.ENTER_FRAME, onFrameEnter);
	this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
	
	if (stage) init();
	else addEventListener(Event.ADDED_TO_STAGE, init);
		 
    }
	
    //Interface with javascript
	public function CallingMe(p:String):String
	{
	var res:String = "";
	if (p.substr(0, 3) == "sd ") Js_maxDepth = parseInt( p.substr(3) );
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
	
	// Mousepress events
	private function onMouseDown(event:MouseEvent):void
    {
				// if only flash version without interface...
	if (External) CallingJS("MOUSEPRESS", "");
	else
	 {
	  if (anims == 0 && logoshow == 0)
	  {
		var mx:int = this.mouseX;
		var my:int = this.mouseY;
		
		var x1:int = Math.floor((mx - ((this.width - BS) / 2)) / (BS / 8));
		var y1:int = Math.floor((my - ((this.height - BS) / 2)) / (BS / 8));
		if (x1 >= 0 && x1 < 8 && y1 >= 0 && y1 < 8)
		 {
		 var atsq:String = String.fromCharCode(97 + (rev ? 7 - x1 : x1)) +
				(1 + (rev ? y1 : 7 - y1)).toString();
				
		 var pc:String = atPiece(atsq);
		 var wm:Boolean = (this.Js_nGameMoves % 2 == 0);
		 var wp:Boolean = (pc.charAt(0) == "w");
		 
		 if (pc.length > 0 && wm == wp )
			{
			dragat = atsq;
		 	cursor0.x = ((this.width - BS) / 2) + (x1 * (BS / 8));
		 	cursor0.y = ((this.height - BS) / 2) + (y1 * (BS / 8));
		 	cursor0.width = (BS / 8);
		 	cursor0.height = cursor0.width;
		 	addChild(cursor0);
		 	}
		 if( dragat.length>0 && (pc.length == 0 || wm != wp ))
			{
			var mc1:int = this.Js_nGameMoves;
			var v2:int = parseInt( atsq.charAt(1) );
			var pr2:String = ((atPiece(dragat).charAt(1) == "p" &&
				(v2 == 1 || v2 == 8)) ? PromoPiece : "" );
			
			if (!(opnmv == "**")) opnmv += dragat + atsq;
			
			EnterMove(dragat, atsq, pr2);
			if (mc1 != this.Js_nGameMoves)
				{
				RemoveCursor();
				StatusMess(moved+"\nThinking...");
				anims = 20;
				}
			}
		 }
		else
		 {
			var butt:int = atButtI(mx, my);
			if (butt == 0)		// New game...
				{
				RemoveCursor();
				GameOver = false;
				InitGame();
				opnmv = "";
				rev = !rev;
				DrawBoard();
				SetUpBoard();
				ShowPromoPiece();
				anims = 2;
				}
			if (butt == 1)		// Takeback...
				{
				if (!GameOver)
					{
					RemoveCursor();
					UndoMov();
					if (rev == ( this.Js_nGameMoves % 2 == 0 )) UndoMov();
					SetUpBoard();
					StatusMess("(undo)\nYour move!");
					if (this.Js_nGameMoves == 0) opnmv = "";
					anims = 2;
					}
				}
			if (butt == 2)		// Change promo piece...
				{
				PromoPiece = (PromoPiece == "Q"?"R":PromoPiece == "R"?"B":
					PromoPiece == "B"?"N":PromoPiece == "N"?"Q":"");
				ShowPromoPiece();
				}
			if (butt == 3 || butt == 13)		// Change plys...
				{
				trace(butt);
				if (butt == 13) { plys++; if (plys >= 10) plys = 1; }
				else { plys--; if (plys < 1) plys = 9; }
				ShowPlys();
				}
			if (butt == 4 || butt == 14)		// Change secs...
				{
				if (butt == 14) { secs++; if (secs > 15) secs = 1; }
				else { secs--; if (secs < 1) secs = 15; }
				ShowSecs();
				}
		 }
	  }
	 }
	
	}

	// Hide drag-cursor...
	private function RemoveCursor():void
	{
	if (dragat.length > 0)
		{
		dragat = "";
		removeChild(cursor0);
		}
	}
	
	private function ShowPromoPiece():void
	{
	if (PromoPiece.length == 0) PromoPiece = "Q";	
	else removeChild(prom0);
	
	prom0 = (PromoPiece == "Q" ? (rev? new bq_image():new wq_image()) :
		PromoPiece == "R" ? (rev? new br_image():new wr_image()) :
		PromoPiece == "B" ? (rev? new bb_image():new wb_image()) :
		PromoPiece == "N" ? (rev? new bn_image():new wn_image()) : null );
	prom0.x = bt1[2].x + (bt1[2].width * 0.3);
	prom0.y = bt1[2].y + (bt1[2].height * 0.45);
	prom0.width = bt1[2].width / 2;
	prom0.height = prom0.width;
	addChild(prom0);
	}

	private function ShowPlys():void
	{
	if (plys == 0) plys = 5;	
	else removeChild(plys0);
	
	Js_maxDepthSeek = plys;
	
	var tfStyle:TextFormat = new TextFormat();
	tfStyle.font = "Arial";
	tfStyle.bold = true;
	tfStyle.size = BS/24;
	
	plys0.defaultTextFormat = tfStyle;
	plys0.text = plys.toString();
	plys0.selectable = false;
	
	plys0.x = bt1[3].x + (bt1[3].width * 0.3);
	plys0.y = bt1[3].y + (bt1[3].height * 0.45);
	plys0.textColor =  0x000000;
	addChild(plys0);
	}
	
	private function ShowSecs():void
	{
	if (secs == 0) secs = 5;	
	else removeChild(secs0);
	
	Js_searchTimeout = secs * 1000;
	
	var tfStyle:TextFormat = new TextFormat();
	tfStyle.font = "Arial";
	tfStyle.bold = true;
	tfStyle.size = BS/24;
	
	secs0.defaultTextFormat = tfStyle;
	secs0.text = secs.toString();
	secs0.selectable = false;
	
	secs0.x = bt1[4].x + (bt1[4].width * 0.36);
	secs0.y = bt1[4].y + (bt1[4].height * 0.45);
	secs0.textColor =  0x000000;
	addChild(secs0);
	}
	
	// Computer should move...
	private function DoMove():void
    {
	var mc1:int = this.Js_nGameMoves;		
	var opns:String = (opnmv == "**" ? "" : c0_Opening(opnmv));
	var o2:String = "abcdefgh";
	if(opns.length>0)
		{
		var j:int=0;
		var mv:String=opns.substr(j,4);
		for(var t:int=1+Math.floor(Math.random()*3); t>0; t--)
		{
		for(;t>=0;)
		{
		if (o2.indexOf( opns.charAt(j) ) >= 0 && o2.indexOf( opns.charAt(j+2) ) >= 0 )
			{
			mv = opns.substr(j, 4);
			t--;
			}
		j++;
		if(j>opns.length-3)
			{
			j=0; t--;
			if(t<0) mv=opns.substr(j,4);
			}
		}
		}
		opnmv += mv;
		EnterMove(mv.substr(0,2), mv.substr(2,2), "");
		}
	if (this.Js_nGameMoves == mc1)
		{
		Jst_Play();
		opnmv = "**";
		}
	anims = 20;
	StatusMess(moved + (this.Js_fCheck_kc?"\nCheck!":"") + "\nYour move!");
	}
	
	// Event on screen redraw
	private function onFrameEnter(event:Event):void
    {
	if (External)
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
	}
	
	// Routine once on loading 
	private function init(e:Event = null):void 
	{
	Mouse.cursor = "arrow";
	removeEventListener(Event.ADDED_TO_STAGE, init);
	if (!External)
	  {

	  flashlogo0.width = (this.width/16);
	  flashlogo0.height = flashlogo0.width;
	  flashlogo0.x = this.width - (1.4*flashlogo0.width);
	  flashlogo0.y = this.height - (1.4*flashlogo0.height);
	  addChild(flashlogo0);
	  
	  InitOpen();
 	  DrawBoard();
	  DrawButtons();
	  SetUpBoard();
	  ShowPromoPiece();
	  ShowPlys();
	  ShowSecs();

	  jestlogo0.x = (this.width - jestlogo0.width)/2;
	  jestlogo0.y = (this.height - jestlogo0.height) / 2;
	  logoshow = 160;
	  }
	addChild(jestlogo0);
	}

	private function ExplShow(t:int):void 
	{
	if (apcE >= 0)
	 {
	 if (t == 1) pc0[apcE].visible = false;
	 if (t > 1) removeChild(expl0);
	 if (t < 5)
	  {
	  expl0 = (t == 1 ? new expl1_image() : t == 2 ? new expl2_image() :
			t == 3 ? new expl3_image() : t == 4 ? new expl4_image() : null);
	  expl0.width *= BS/500;
	  expl0.height *= BS/500;
	  expl0.x = pc0[apcE].x - ((expl0.width - pc0[apcE].width) / 2);
	  expl0.y = pc0[apcE].y - ((expl0.height - pc0[apcE].height) / 2);
	  addChild(expl0);
	  }
	 }
	}
	
	private function DrawBoard():void 
	{
	if (BS==0)
	 {
		BS = Math.min(this.height, this.height) * 0.8;
		var sq:int = 0;
		for (var x:int = 0; x < 8; x++)
		 for (var y:int = 0; y < 8; y++)
			{
			bsq0[sq] = ( ((x + y) % 2 > 0) ? new bsq_image() : new wsq_image() );
			bsq0[sq].x = ((this.width - BS) / 2) + (x * (BS / 8));
			bsq0[sq].y = ((this.height - BS) / 2) + (y * (BS / 8));
			bsq0[sq].width = (BS / 8);
			bsq0[sq].height = bsq0[sq].width;
			addChild(bsq0[sq]);
			sq++;
			}
	 }
	 
	 for (var w:int = 0; w < bh0.length; w++)
	 {
	  removeChild(bh0[w]);
	 }
		
	 for (var q:int = 0; q < 32; q++)
			{
			var tfStyle:TextFormat = new TextFormat();
			tfStyle.font = "Arial";
			tfStyle.bold = false;
			tfStyle.size = BS/24;
			bh0[q] = new TextField();
			bh0[q].defaultTextFormat = tfStyle;
			bh0[q].text = String.fromCharCode((q < 16 ? 65:49) +
			((!rev && q>=16) || (rev && q<16) ? 7 - (q % 8):(q % 8)));
			bh0[q].selectable = false;
			bh0[q].x = (q < 16 ? ((this.width - BS) / 2) + ( (q % 8) * (BS / 8) ) + (BS / 24) :
					((this.width + ((q < 24? -1.12:1.05) * BS))) / 2);
					
			bh0[q].y = (q >= 16 ? ((this.height - BS) / 2) + ( (q % 8) * (BS / 8)) + (BS / 32) :
					((this.height - ((q < 8? -1.03:1.14) * BS))) / 2);
			
			bh0[q].textColor =  0x99ccff;
			addChild(bh0[q]);
			}
	}

	private function DrawButtons():void 
	{
	for (var q:int = 0; q < 5; q++)
		{
		var tfStyle:TextFormat = new TextFormat();
		tfStyle.font = "Arial";
		tfStyle.bold = false;
		tfStyle.size = BS / 32;
		bt0[q] = new TextField();
		bt0[q].defaultTextFormat = tfStyle;
		bt0[q].text = (q == 0 ? "New\nGame": q == 1 ? "Take\nBack": q == 2 ? "Prom.\n:" :
				q == 3 ? "Plies\n-     +": q == 4 ? "Sec/m\n-      +": "" );
		bt0[q].selectable = false;
		bt0[q].x = ((this.width + ((q > 2?0.85: -1) * BS * 1.4)) / 2);
		bt0[q].y = ((this.height - BS) / 2) + ((q % 3) *  (BS/32) * 8);
			
		bt0[q].textColor =  0xffffff;
		addChild(bt0[q]);
		
		bt1[q] = new buttons_image();
		bt1[q].x = bt0[q].x-(bt0[q].width*0.08);
		bt1[q].y = bt0[q].y-(bt0[q].height*0.08);
		bt1[q].width = bt0[q].width * 0.5;
		bt1[q].height = bt0[q].height * 0.5;
		bt1[q].blendMode = BlendMode.SCREEN;
		addChild(bt1[q]);
		}
	}

	// Status message
	private function StatusMess(Mess:String):void 
	{
	if (Mess.length == 0) removeChild(st0);
	else
	{
	 var tfStyle:TextFormat = new TextFormat();
	 tfStyle.font = "Arial";
	 tfStyle.bold = false;
	 tfStyle.size = BS / 32;

	 st0.defaultTextFormat = tfStyle;
	 st0.textColor =  (Mess.indexOf("Thinking") >= 0 ? 0x00ff00 : 0xccff33 );
	 
	 if (this.Js_fGameOver)
		{
		if (this.Js_fMate_kc)
			{
			Mess = "Checkmate\n" + (this.Js_nGameMoves % 2 == 0 ? "0-1":"1-0") ;
			GameOver = true;
			}
		if (this.Js_fAbandon)
			{
			Mess = "Resigned!\n" + (rev?"0-1":"1-0");
			GameOver = true;
			}
		if (this.Js_fStalemate)
			{
			Mess = "Stalemate\n1/2-1/2";
			GameOver = true;
			}
		}
	 st0.text = Mess;
		 
	 st0.selectable = false;
	 st0.x = ((this.width + (0.8 * BS * 1.4)) / 2);
	 st0.y = ((this.height - BS) / 2) + (2 *  (BS/32) * 8);

	 addChild(st0);
	 }
	}
	
	//This draws pieces...
	private function SetUpBoard():void 
	{
	for (var n:int = 0; n < pc0.length; n++)
		{
		removeChild(pc0[n]);
		}
	pc0 = [];
	
	var i:int = 0;
	do {
		var pc:int = this.Js_board[i];
		if (pc > 0)
			{
			var p2:String = (this.Js_color[i] == Js_white ? "w": "b") +
				(  (pc == Js_pawn) ? "p": (pc == Js_knight) ? "n": (pc == Js_bishop) ? "b":
				(pc == Js_rook) ? "r": (pc == Js_queen) ? "q": (pc == Js_king) ? "k": "" );
			var at2:String = String.fromCharCode(97 + (i % 8)) + (1 + Math.floor(i / 8)).toString();
			addPiece(p2, at2);
			}
	  }
	while (++i < 64);
	}  
	  
	private function addPiece(p:String,at:String):void 
	{
	var n:int = pc0.length;
	pc0[n] = ((p == "wp") ? new wp_image(): (p == "wn") ? new wn_image():
	 (p == "wb") ? new wb_image(): (p == "wr") ? new wr_image():
	 (p == "wq") ? new wq_image(): (p == "wk") ? new wk_image():
	 (p == "bp") ? new bp_image(): (p == "bn") ? new bn_image():
	 (p == "bb") ? new bb_image(): (p == "br") ? new br_image():
	 (p == "bq") ? new bq_image(): (p == "bk") ? new bk_image(): null );
	 
	var x:int = at.charCodeAt(0) - 97;
	var y:int = 8 - parseInt(at.charAt(1));
	
	if (rev) { x = 7 - x; y = 7 - y; }
	
	pc0[n].x = ((this.width - BS) / 2) + (x * (BS / 8)) - (BS / 380);
	pc0[n].y = ((this.height - BS) / 2) + (y * (BS / 8)) - (BS / 380);
	
	if (p.charAt(1) == "p") pc0[n].y -= (BS / 160);
	
	pc0[n].width = (BS / 8);
	pc0[n].height = pc0[n].width;
	addChild(pc0[n]);
	}

	private function atPcI(at:String):int
	{
	var atI:int = -1;
	for (var n:int = 0; n < pc0.length; n++)
		{
		var x:int = at.charCodeAt(0) - 97;
		var y:int = 8 - parseInt(at.charAt(1));
		
		if (rev) { x = 7 - x; y = 7 - y; }
			
		var x1:int = ((this.width - BS) / 2) + (x * (BS / 8)) - (BS / 380);
		var y1:int = ((this.height - BS) / 2) + (y * (BS / 8)) - (BS / 380);

		if (Math.abs( pc0[n].x-x1 )<5 && Math.abs( pc0[n].y - y1)<5 )
			{
			atI = n;
			break;
			}
		}
	return atI;
	}
	private function atButtI(x:int, y:int):int
	{
	var atI:int = -1;
	for (var n:int = 0; n < bt1.length; n++)
		{
		if ( x > bt1[n].x && x < bt1[n].x + bt1[n].width && 
				y > bt1[n].y && y < bt1[n].y + bt1[n].height )
			{
			atI = n;
			if ((atI == 3 || atI == 4) && x > bt1[n].x + (bt1[n].width / 2))
				{
				 atI += 10;
				}
			break;
			}
		}
	return atI;
	}
	
	
	private function atPiece(atsq:String):String
	{
	var rt:String = "";
  	var i:int = 0;
	do {
		var at2:String = String.fromCharCode(97 + (i % 8)) + (1 + Math.floor(i / 8)).toString();
		if (at2 == atsq)
			{
			var pc:int = this.Js_board[i];
			if (pc > 0)
			 {
			 rt = (this.Js_color[i] == Js_white ? "w": "b") +
				(  (pc == Js_pawn) ? "p": (pc == Js_knight) ? "n": (pc == Js_bishop) ? "b":
				(pc == Js_rook) ? "r": (pc == Js_queen) ? "q": (pc == Js_king) ? "k": "" );
			 }
			break;
			}
	  }
	while (++i < 64);
	return rt;
	}

	private function InitOpen():void
	{
	// universal 15Kb code of most played chess openings
	// parameter moves:e2e4
	// returns next variants, strength, ECO code
	// chessforeva.blogspot.com

	c0_opn[1]="A00.b1c31c7c54-1d7d55e2e49.A01.b2b31d7d52c1b29-2e7e55c1b29b8c67e2e39g8f69-3d7d62-3g8f61c1b29.A00.b2b41e7e59c1b29.A10.c2c41A40.b7b61b1c39c8b79-3A30.c7c51A34.b1c34A35.b8c65g1f32-1A36.g2g37g7g69f1g29f8g79A37.g1f39-6A34.g7g61g2g39f8g79f1g29b8c69-5g8f62g2g39-3A30.g1f33b8c63b1c35-1d2d44c5d49f3d49-4g7g61-1g8f64b1c39-3g2g31b8c64f1g29g7g69-3g7g65f1g29f8g79b1c39b8c69-7A11.c7c61b1c31d7d59-2d2d42d7d59-2e2e43d7d59e4d59c6d59d2d49g8f69b1c39-7A12.g1f33d7d59b2b34-1e2e35g8f69-5A10.d7d61-1A20.e7e52A21.b1c37A25.b8c63A27.g1f33-1A25.g2g36g7g69f1g29f8g79-5A21.d7d61g2g39-2f8b41-1A22.g8f64g1f35b8c69e2e33-1g2g36d7d59c4d59f6d59-6g2g34A23.d7d56c4d59f6d59f1g29d5b69g1f39b8c69-7A22.f8b44f1g29-5A20.g2g32b8c64f1g29g7g69b1c39f8g79-5g8f65f1g29c7c63-1d7d56c4d59f6d59-7A13.e7e61b1c33d7d59d2d49c7c64-1g8f65-4d2d41d7d59b1c39-3g1f33d7d57b2b32-1d2d43g8f69-2g2g33g8f69-3g8f62g2g39-3g2g32d7d59f1g29g8f69g1f39f8e79-7A10.f7f51b1c34g8f69g2g39-3g1f32g8f69-2g2g33g8f69f1g29-4g7g61b1c34f8g79d2d42-1g2g37e7e59f1g29-5d2d41f8g79-2e2e41-1g1f31f8g79-2g2g32f8g79f1g29d7d64-1e7e55b1c39-6A15.g8f63A16.b1c36c7c51g1f35-1g2g34-2d7d51c4d59f6d59A17.g2g39g7g69f1g29-6A16.e7e51g1f36b8c69g2g39-3g2g33-2A17.e7e62d2d42-1A18.e2e43d7d59e4e59-3A17.g1f33d7d59d2d49-4A16.g7g63d2d41f8g79-2e2e43d7d69d2d49f8g79-4g2g35f8g79f1g29e8g89e2e44-1g1f35d7d69-8A15.d2d41e7e69-2g1f31c7c51-1e7e63g2g39-2g7g64b1c34-1g2g35f8g79f1g29e8g89-6g2g31c7c62-1e7e62f1g29d7d59-3g7g65f1g29f8g79b1c39e8g89.A40.d2d43b7b61-1b8c61g1f39-2A43.c7c51d4d58d7d61-1A44.e7e54e2e49d7d69b1c39-4A43.e7e61-1g8f63A56.c2c49-3A43.e2e31-2A41.c7c61c2c49-2A84.d7d52D00.b1c31g8f69D01.c1g59-3D00.c1f41g8f69-2c1g51c7c64-1h7h65g5h49c7c69-4D01.c2c47D06.b8c61b1c33-1D07.c4d53d8d59e2e39e7e59b1c39f8b49c1d29b4c39-8D06.g1f33c8g49-3D10.c7c64b1c32d5c41-1e7e61-1g8f68c4d51c6d59c1f49-3e2e34a7a63d1c29-2e7e65g1f39b8d79d1c24f8d69-2f1d35d5c49d3c49b7b59c4d39-8g7g61g1f39f8g79-4g1f34a7a61-1d5c43a2a49c8f59-3e7e64c1g55-1e2e34b8d79-6c4d51c6d59b1c37b8c63g1f39g8f69c1f49-4g8f66c1f43b8c69e2e39-3g1f36b8c69c1f49c8f59e2e39e7e69f1d39-9g1f32";
	c0_opn[2]="g8f69b1c39b8c69c1f49-7e2e31g8f69b1c39-3D11.g1f35e7e61-1g8f69D15.b1c36a7a61c4c59-2d5c43D16.a2a49D17.c8f59D18.e2e35D19.e7e69f1c49f8b49e1g19b8d74-1e8g85d1e29-7D17.f3e54b8d75e5c49-2e7e64-5D15.e7e64c1g55d5c43-1h7h66g5f69d8f69-4e2e34b8d79d1c25f8d69-2f1d34d5c49d3c49b7b59-8D13.c4d51D14.c6d59b1c39b8c69c1f49c8f59e2e39e7e69-8D11.d1c21-1e2e32a7a62-1D12.c8f54b1c39e7e69f3h49-4D11.e7e63-5D06.c8f51-1D20.d5c41b1c31-1e2e32g8f69f1c49e7e69g1f39c7c59e1g19a7a69-8e2e41e7e54g1f39e5d49-3g8f65e4e59f6d59f1c49d5b69-6D21.g1f35a7a61D22.e2e39-2D21.e7e61-1D23.g8f67D24.b1c31-1D25.e2e38D26.e7e69f1c49c7c59e1g19D27.a7a69-9D08.e7e51d4e59d5d49g1f39b8c69-5D30.e7e63D31.b1c36D32.c7c51c4d59e6d59g1f39b8c69D33.g2g39g8f69f1g29D34.f8e79e1g19e8g89c1g59-12D31.c7c62c4d51e6d59-2e2e34g8f69g1f39b8d79d1c25f8d69-2f1d34-5e2e41-1g1f33d5c44-1g8f65-3f8e71c4d52e6d59c1f49-3g1f37g8f69c1f42-1c1g57e8g84e2e39-2h7h65g5h49e8g89-7D35.g8f64D50.c1g54D51.b8d73e2e39-2D50.f8e76D53.e2e37D54.e8g89D55.g1f39-3D50.g1f32-3D35.c4d53e6d59D36.c1g59c7c63e2e39-2f8e76e2e39c7c64-1e8g85f1d39-7D37.g1f32f8e79-4D30.c4d51e6d59b1c39-3g1f32c7c51c4d59e6d59g2g39-4c7c62d1c25-1e2e34-2g8f66b1c35c7c63-1f8e76c1g59-3c1g51-1g2g33f8e79f1g29e8g89e1g19-8D06.g8f61-2D00.e2e31g8f69-2D02.g1f32b8c61c1f49-2c7c51-1c7c61c2c49e7e64-1g8f65-3c8f51-1e7e61c2c49-2g8f66c1f41c7c54-1e7e65e2e39-3D03.c1g51e7e65-1f6e44-2D02.c2c45c7c64b1c35d5c45a2a49c8f59-3e7e64-2c4d51c6d59b1c39b8c69-4e2e32-2D25.d5c41e2e39e7e69f1c49c7c59-5D02.e7e63b1c37c7c63-1f8e76c1g59-3g2g32-3D04.e2e31D05.e7e69f1d39-3D02.g2g31-4A41.d7d61A42.c2c42e7e57g1f39e5e49-3g7g62b1c39f8g79-4A41.e2e43g7g62-1g8f67b1c39g7g69-4g1f33c8g43c2c49-2g7g64c2c49f8g79b1c39-4g8f62c2c49-3g2g31-2A40.e7e61c2c46b7b61a2a33-1b1c33-1e2e43c8b79-3A43.c7c51d4d59-2A40.d7d51b1c36-1g1f33-2A84.f7f52b1c32g8f69-2g1f32g8f69-2g2g35g8f69f1g29f8e79-5A40.f8b41c1d29-2g8f62b1c35f8b49d1c24-1e2e35-3g1f34b7b69-4e2e41d7d59b1c39-3g1f32c7c51-1d7d51-1f7f52g2g39g8f69f1g29-4g8f63c2c49-3g2g31-2A80.f7f51b1c31d7d54-1g8f65c1g59d7d59-4c1g51g7g69-2A84.c2c41g8f69b1c36A85.g7g69-2A86.g2g33";
	c0_opn[3]="-3A80.e2e41A82.f5e49b1c39A83.g8f69c1g59-5A80.g1f31g8f69g2g39g7g69f1g29f8g79e1g19e8g89-8A81.g2g33g7g61-1g8f68f1g29e7e62-1g7g67c2c42f8g79-2g1f35f8g79e1g19e8g89c2c49d7d69b1c39-7g1h31-6A40.g7g61c2c45f8g79b1c35c7c52d4d59-2d7d67e2e49b8c69-4e2e42d7d69b1c39-3g1f31d7d69-4e2e43f8g79b1c35d7d69-2c2c42-1g1f32d7d69-4g1f31f8g79c2c49-4A45.g8f65b1c31d7d59c1g59b8d79-4c1f41-1c1g51c7c51g5f69g7f69-3d7d51g5f69e7f69e2e39-4e7e62e2e49h7h69g5f69d8f69b1c39-6f6e43g5f48c7c56f2f39d8a59c2c39e4f69b1d29c5d49d2b39-8d7d53-2g5h41-2g7g61g5f69e7f69-4c2c31-1A50.c2c46b8c61g1f39e7e69-3A56.c7c51d4d58A57.b7b55c4b58a7a69b1c31-1b5a64A58.c8a64A59.b1c39d7d65-1g7g64-3A57.g7g65b1c39c8a69e2e49a6f19e1f19d7d69-8b5b62d7d63b1c39-2d8b62b1c39-2e7e63b1c39-3e2e31-1f2f31-3g1f31g7g69-3A56.d7d61b1c39g7g69e2e49f8g79-5e7e51b1c39d7d69e2e49f8e79-5A60.e7e62b1c39A61.e6d59c4d59d7d69A65.e2e47A66.g7g69f2f46A67.f8g79f1b59f6d79-4A70.g1f33-3A61.g1f32A62.g7g69-7A56.g7g61b1c39f8g79e2e49d7d69-6e2e31g7g69-2g1f31c5d49f3d49e7e59-5A50.c7c61b1c39d7d59g1f39-4A53.d7d61b1c37b8d74e2e46e7e59g1f39-3g1f33-2e7e52A54.g1f39-2A53.g7g62e2e49f8g79-4g1f32b8d75-1g7g64-3A51.e7e51d4e59f6e41-1A52.f6g48c1f44b8c69g1f39f8b49-4g1f35f8c59e2e39b8c69-7E00.e7e64E20.b1c34c7c51d4d59e6d59c4d59d7d69e2e49g7g69-7d7d51c1g54f8e79e2e39-3c4d53e6d59c1g59f8e79e2e39-5g1f32-2f8b48E24.a2a31b4c39b2c39-3E30.c1g51h7h69E31.g5h49-3E32.d1c23E38.c7c53d4c59b4c52-1b8a62a2a39-2E39.e8g85a2a39b4c59g1f39b7b69-7E34.d7d51E35.c4d59d8d59-3E33.e8g85a2a39b4c39c2c39b7b68c1g59c8a62-1c8b77f2f39-4f6e41c3c29-7E40.e2e34E43.b7b62f1d33c8b79-2E44.g1e26-2E41.c7c53f1d36b8c69g1f39-3E42.g1e23c5d49e3d49-4E46.e8g84E47.f1d37c7c52g1f39-2E48.d7d57g1f39c7c59e1g19-5E46.g1e22d7d59a2a39b4e79c4d59-7E20.f2f31d7d59a2a39b4c39b2c39-5g1f31b7b64-1c7c55g2g39-3g2g31-3E10.g1f34E12.b7b65a2a32c8a63d1c29a6b79b1c39c7c59e2e49c5d49f3d49-8c8b76b1c39d7d59c4d59f6d59-6b1c31c8b75a2a39d7d59-3f8b44c1g59-3E14.e2e31c8b79f1d39-3E15.g2g35c8a66b1d21-1b2b36f8b49c1d29b4e79f1g29c7c69d2c39d7d59-8d1a41-2c8b73E16.f1g29E17.f8e79b1c32-1e1g17e8g89E18.b1c39E19.f6e49";
	c0_opn[4]="c3e49b7e49f3e19-12E10.c7c51d4d59e6d59c4d59d7d69b1c39g7g69-7d7d52b1c38b8d71-1c7c61-1d5c41-1f8b41-1f8e74c1f43e8g89e2e39-3c1g56e8g85e2e39-2h7h64-4g2g31-2E11.f8b41b1d23b7b69a2a39-3c1d26a7a52-1d8e77g2g39b8c69-6E00.g2g31c7c52d4d55e6d59c4d59-3g1f34-2E01.d7d55E02.f1g26E03.d5c44-1E06.f8e75E07.g1f39e8g89E08.e1g19-5E01.g1f33-2E00.f8b42c1d29-4D70.g7g63b1c38d7d52D82.c1f41D83.f8g79e2e39c7c59-4D80.c1g51f6e49-2D85.c4d55f6d59c1d21f8g79e2e49-3e2e49d5c39D86.b2c39f8g79c1e31c7c59d1d29-3f1b51-1f1c44c7c56g1e29b8c65c1e39e8g89e1g19-4e8g84e1g19-4e8g83g1e29-3g1f33c7c59a1b19e8g89f1e29c5d49c3d49-13D90.g1f33f8g79D92.c1f41D93.e8g89-2D91.c1g52f6e49c4d59e4g59f3g59e7e69-6D90.c4d51f6d59e2e49d5c39b2c39-5D96.d1b33D97.d5c49b3c49e8g89e2e49a7a69-6D94.e2e31e8g89-5E61.f8g77c1g51-1E70.e2e48d7d69f1d31e8g89g1e29-3E73.f1e22e8g89c1g54b8a63-1E74.c7c53E75.d4d59-2E73.h7h62g5e39-3g1f35e7e59e1g19b8c69d4d59c6e79-8E80.f2f32E81.e8g89c1e37E83.b8c62g1e29-2E81.b8d71-1c7c51-1E85.e7e54E87.d4d56-1E86.g1e23-3E81.c1g51-1g1e21-3E76.f2f41e8g89g1f39b8a62-1c7c57d4d59e7e69f1e29e6d59c4d59-9E70.g1e21e8g89e2g39-3E90.g1f33e8g89E91.f1e29b8a61-1b8d71-1E92.e7e58c1e31-1d4d51a7a59-2d4e51d6e59d1d89f8d89c1g59-5E94.e1g16b8a61-1E97.b8c68d4d59c6e79b2b46a7a54-1f6h55f1e19-3E98.f3e13f6d79-8E90.h2h31-3E71.h2h31e8g89c1g59-4E70.e8g81g1f39d7d69f1e29e7e59-6E61.g1f31E62.d7d62-1E61.e8g87c1g55-1g2g34-3g2g31e8g89f1g29d7d69-6D70.f2f31-1g1f31E60.f8g79b1c31-1g2g38e8g89f1g29d7d69e1g19b8d79-8D70.g2g31E60.f8g79f1g29d7d52c4d59f6d59e2e49-4e8g87b1c37d7d69g1f39b8c64-1b8d75e1g19-5g1f32d7d69-8A45.e2e31g7g69-2A46.g1f32A47.b7b61-1A46.c7c51c2c31-1d4d55b7b53c1g59-2d7d61-1e7e62-1g7g62b1c39-3e2e32g7g69-3d7d51c1f41-1c2c47c7c63b1c39-2e7e66b1c39f8e79-4e2e31-2d7d61c2c49-2e7e63c1f41c7c59-2c1g51c7c54e2e39-2d7d51-1f8e71-1h7h62g5h49-3c2c44b7b64a2a32-1b1c32-1g2g35c8a66b2b39-2c8b73f1g29-4c7c51d4d59-2d7d51b1c39-2f8b42c1d29d8e79g2g39-5e2e31b7b66f1d39c8b79e1g19-4c7c53f1d39-3g2g31b7b51-1b7b63f1g29c8b79e1g19-4c7c52f1g29-2d7d52f1g29-4A48.g7g64D02.b1c31d7d59c1f49f8g79e2e39e8g89f1e29-7A48.c1f41";
	c0_opn[5]="f8g79e2e39d7d63-1e8g86-4c1g51f8g79b1d29d7d54e2e39e8g89-3e8g85-4c2c31f8g79-2c2c44c7c51-1f8g79b1c37d7d52c4d59f6d59e2e49d5c39b2c39c7c59-7d7d61e2e49e8g89f1e29e7e59-5e8g85c1g51-1e2e48d7d69f1e29e7e59e1g19b8c69d4d59c6e79-10g2g32e8g89f1g29d7d69e1g19-7e2e31f8g79-2A49.g2g32f8g79f1g29e8g89c2c41-1e1g18d7d52-1d7d67c2c49b8d79-10A45.g2g31g7g69f1g29f8g79.A40.e2e45B00.b7b61d2d49c8b79f1d39-4b8c61d2d44d7d56-1e7e53-2g1f35d7d66d2d49g8f69b1c39c8g49-5e7e53-3B20.c7c54B23.b1c31a7a61-1b8c66f1b51c6d47b5c49e7e69-3g7g62-2f2f42d7d61g1f39-2e7e62g1f39d7d59-3g7g66g1f39f8g79f1b55c6d49e1g19-3f1c44e7e69-6g1e21-1g1f31d7d64-1g7g65-2B24.g2g34B25.g7g69f1g29f8g79B26.d2d39d7d67c1e35a8b84-1e7e65d1d29-3f2f44e7e69g1f39g8e79e1g19e8g89c1e39c6d49-9e7e62c1e39d7d69-4B25.g1e21-6B23.d7d61f2f45b8c65g1f39g7g69-3g7g64g1f39f8g79-4g2g34b8c69f1g29g7g69d2d39-6e7e61f2f42d7d59-2g1e21-1g1f33a7a65-1b8c64-2g2g33b8c63f1g29-2d7d56-3g7g61-2B20.b2b31b8c69c1b29-3B22.c2c31d7d53e4d59d8d59d2d49b8c61g1f39c8g49f1e29-4c5d41c3d49-2e7e61g1f39g8f69-3g7g61-1g8f65g1f39c8g46f1e29e7e69e1g14b8c69-2h2h35g4h59e1g19-6e7e63-7d7d61d2d49g8f69f1d39-4e7e61d2d49d7d59e4d56e6d59g1f39b8c69-4e4e53-4g7g61d2d49c5d49c3d49d7d59-5g8f63e4e59f6d59d2d47c5d49c3d42d7d69-2d1d41e7e69-2g1f36b8c65c3d43d7d69f1c49-3f1c46d5b69c4b39d7d59e5d69d8d69-7e7e64c3d49b7b64-1d7d65-6g1f32b8c65f1c49-2e7e64-6B20.c2c41b8c69b1c39g7g69-4d2d31b8c69g2g39g7g69f1g29f8g79f2f49-7d2d41c5d49c2c39d4c37b1c39b8c69g1f39-4g8f62e4e59f6d59-6B21.f2f41b8c64g1f39-2d7d55-2B20.g1e21b8c69-2B27.g1f37B28.a7a61c2c33-1c2c43-1d2d43c5d49f3d49g8f69-5B30.b8c63b1c31d7d61d2d49c5d49f3d49g8f69-5e7e51f1c49f8e79d2d39-4e7e62d2d49c5d49f3d49-4g7g62d2d49c5d49f3d49f8g79c1e39g8f69f1c49-8g8f61-2c2c31d7d55e4d59d8d59d2d49-4g8f64e4e59f6d59d2d49c5d49-6d2d31g7g69g2g39f8g79f1g29-5B32.d2d46c5d49f3d49d7d61-1d8b61d4b39g8f69b1c39e7e69-5d8c71b1c39e7e69c1e34a7a69-2f1e25a7a69e1g19g8f69-7e7e51d4b59a7a61b5d69f8d69d1d69d8f69-5d7d68b1c34a7a69b5a39b7b59c3d59-5c2c45f8e79b1c39a7a69b5a39-8e7e61b1c39d8c79-3B34.g7g61B35.b1c34f8g79c1e39g8f69f1c47d8a52-1e8g87c4b39";
	c0_opn[6]="d7d69-4f1e22-5B34.c1e31-1B36.c2c44B37.f8g76B38.c1e39B39.g8f69b1c39e8g86f1e29d7d69e1g19c8d79-5f6g43d1g49c6d49g4d19-8B36.g8f63b1c39d7d69f1e29c6d49d1d49f8g79-9B32.g8f65B33.b1c39d7d63c1g54c8d71-1e7e68d1d29a7a66e1c19c8d74f2f49-2h7h65g5e39-4f8e73e1c19e8g89-6f1c42d8b64-1e7e65c1e39-3f1e22e7e59d4b39f8e79-4f2f31-2e7e55d4b59d7d69a2a41-1c1g58a7a69b5a39b7b59c3d55d8a52g5d29a5d89d2g59d8a59g5d29a5d89-7f8e77g5f69e7f69c2c39e8g86a3c29f6g59a2a49-4f6g53a3c29-7g5f64g7f69c3d59f6f56c2c33f8g79e4f59c8f59a3c29-5f1d36c8e69e1g19e6d59e4d59-6f8g73c2c34f6f59e4f59c8f59-4f1d35c6e79d5e79d8e79-10g5f61g7f69b5a39b7b59c3d59-7c3d51f6d59e4d59c6b89c2c49-8e7e61d4b59-2g7g61-6B30.f1b51d7d61e1g19c8d79f1e19g8f69-5e7e62b5c63b7c69d2d39-3e1g16g8e79c2c34a7a69-2f1e15a7a69-5B31.g7g65b5c63b7c63e1g19f8g79-3d7c66d2d39f8g79h2h39g8f69b1c39-7e1g16f8g79c2c34g8f69f1e19e8g89d2d49-5f1e15e7e53-1g8f66-5B30.g8f61-3B50.d7d64b1c31g8f69-2c2c31g8f69f1d32b8c69-2f1e25b8c62-1b8d72-1g7g64e1g19f8g79-4h2h31-3d2d31-1B53.d2d48c5d49d1d41a7a63-1b8c66f1b59c8d79b5c69d7c69b1c39g8f69c1g59e7e69e1c19f8e79-12B54.f3d49B55.g8f69B56.b1c39B90.a7a65a2a41-1c1e32e7e54d4b39c8e67d1d22-1f2f37b8d75g2g49-2f8e74d1d29-4f8e72f2f39-4e7e63f2f36b7b59-2g2g43-2f6g41e3g59h7h69g5h49g7g59h4g39f8g79-8B94.c1g52B95.e7e69B96.f2f49b8d71d1f39d8c79e1c19-4B97.d8b63d1d27b6b29a1b19b2a39f4f59b8c69f5e69f7e69d4c69b7c69-10d4b32-2B98.f8e74d1f39B99.d8c79e1c19b8d79g2g49b7b59g5f69d7f69g4g59f6d79f4f59-15B90.f1c41e7e69c4b38b7b55e1g19f8e79-3b8d72-1f8e72-2e1g11-3B92.f1e22e7e56d4b39f8e79c1e32c8e69-2e1g17e8g89c1e33c8e69-2g1h16-6e7e63e1g19f8e79f2f49-5B90.f2f31e7e55d4b39c8e69c1e39-4e7e64c1e39b7b59-4B93.f2f41d8c72-1e7e54d4f39b8d79a2a49-4e7e62-2B91.g2g31e7e59d4e29-4B56.b8c61B60.c1g55c8d71-1B62.e7e68B63.d1d29B66.a7a66B67.e1c19B68.c8d75B69.f2f49-2B67.h7h64g5e39-4B64.f8e73B65.e1c19e8g89-6B57.f1c42d8b64d4b39e7e69-3e7e65c1e39-3B58.f1e21e7e59-2B56.f2f31-2B80.e7e61c1e32-1B83.f1e24-1B81.g2g43-2B70.g7g62B72.c1e37f8g79f1e21-1B75.f2f39b8c63d1d29e8g89e1c14-1f1c45c8d79e1c19-6B76.e8g86d1d28B77.b8c69e1c14c6d43e3d49c8e69";
	c0_opn[7]="-3d6d56e4d59f6d59d4c69b7c69-6f1c45B78.c8d79B79.e1c19a8c89c4b39c6e59-8B76.f1c41b8c69-6B70.f1c41f8g79-2f1e21f8g79c1e33-1e1g16e8g89-4B71.f2f41-3B55.f2f31e7e59-5B53.g8f61b1c39c5d49f3d49a7a65-1b8c61-1g7g62-6B51.f1b51b8c61e1g19c8d79f1e19-4b8d72d2d46g8f69b1c39-3e1g13-2B52.c8d76b5d79b8d71e1g19g8f69-3d8d78c2c44b8c69b1c39-3e1g15b8c67c2c39g8f69-3g8f62-6B50.f1c41g8f69d2d39-4B40.e7e62b1c31a7a65d2d47c5d49f3d49d8c79-4g2g32-2b8c64d2d49c5d49f3d49-5b2b31-1c2c31d7d55e4d57d8d55d2d49g8f69-3e6d54d2d49-3e4e52-2g8f64e4e59f6d59d2d49c5d49c3d49d7d69-8c2c41b8c69b1c39-3d2d31b8c67g2g39d7d54b1d29-2g7g65f1g29f8g79e1g19g8e79-7d7d52b1d29-3d2d47c5d49B41.f3d49a7a64B43.b1c33b7b53f1d39d8b69-3d8c76f1d33b8c65-1g8f64-2f1e23g8f69e1g19-3g2g32-3B41.c2c41g8f69b1c39-3B42.f1d34b8c61d4c69-2d8b61-1d8c71e1g19g8f69-3f8c52d4b39c5a73-1c5e76e1g19-4g7g61-1g8f63e1g19d7d64c2c49-2d8c75d1e29d7d69-6B41.f1e21-2B44.b8c62B45.b1c38B46.a7a62f1e29-2B45.d7d61-1B47.d8c76B48.c1e33B49.a7a69f1d39g8f69e1g19-5B47.f1e24a7a69e1g19g8f69c1e35f8b49-2g1h14-5g2g31a7a69f1g29g8f69e1g19-7B44.d4b51d7d69c1f43e6e59f4e39-3c2c46g8f69b1c39a7a69b5a39f8e79f1e29-10B41.d8b61d4b39-2g8f62b1c39B45.b8c63d4b57d7d66c1f49e6e59f4g59a7a69b5a39b7b59c3d55-1g5f64g7f69c3d59-10f8b43a2a39b4c39b5c39d7d59-6d4c62b7c69-3B41.d7d65c1e32a7a69-2f1e24a7a63-1f8e76e1g19e8g89-4g2g42h7h69-3f8b41-2f1d31b8c69-7B27.g7g61c2c31f8g79-2d2d48c5d44f3d49f8g79-3f8g75b1c39c5d49f3d49b8c69-7B29.g8f61b1c35-1e4e54f6d59-4B20.g2g31b8c69f1g29-4B10.c7c61b1c31d7d59B11.g1f39c8g47h2h39g4f39d1f39e7e69-5B12.d5e42c3e49-5B10.c2c41d7d59c4d53c6d59e4d59g8f69-4e4d56c6d59c4d59g8f69b1c39f6d59-8d2d31d7d59b1d29e7e59g1f39f8d69-6d2d48B12.d7d59B15.b1c32d5e49c3e49B17.b8d72e4g53g8f69f1d39e7e69g1f39f8d69d1e29h7h69g5e49f6e49e2e49-11f1c42g8f69e4g59e7e69d1e29-5g1f33g8f69e4f69d7f69-5B18.c8f55e4g39B19.f5g69f1c41-1g1f32b8d79h2h49h7h69h4h59g6h79-6h2h46h7h69g1f39b8d79h4h59g6h79f1d39h7d39d1d39e7e69c1f49-14B15.g8f61e4f69B16.g7f69-5B15.g7g61-2B12.b1d21d5e49d2e49b8d73e4g53g8f69f1d39e7e69-4f1c42g8f69-2g1f33g8f69-3c8f55e4g39f5g69g1f32-1h2h47";
	c0_opn[8]="h7h69g1f39b8d79h4h59g6h79f1d39h7d39d1d39e7e69-13g8f61e4f69g7f69-6B13.e4d52c6d59B14.c2c47g8f69b1c39b8c62c1g53-1g1f36c8g49c4d59f6d59d1b39g4f39g2f39-8e7e66g1f39f8b46c4d56f6d59c1d29-3f1d33-2f8e73c4d59f6d59f1d39-6g7g61-4B13.f1d32b8c69c2c39g8f69c1f49c8g49d1b39-9B12.e4e52c6c51d4c59-2c8f58b1c34e7e69g2g49f5g69g1e29c6c59-6c2c31e7e69c1e39-3g1f33e7e69f1e29b8d74e1g19-2c6c55-4h2h41-3f2f31-2B10.g7g61b1c39-3g1f31d7d59b1c39-4B01.d7d51b1c31-1e4d59d8d55b1c39d5a57d2d47c7c63f1c43-1g1f36g8f69-3g8f66f1c42-1g1f37c7c66f1c49c8f59-3c8g43-4f1c41-1g1f31g8f69-3d5d61d2d49g8f69g1f39a7a69-5d5d81d2d49-4g8f64b1c31f6d59-2c2c41c7c65-1e7e64-2d2d45c8g43-1f6d56c2c45d5b69g1f39-3g1f34g7g69-4f1b51c8d79b5e29-3g1f31f6d59d2d49-6B07.d7d61b1c31-1d2d49g7g61b1c38f8g79c1e35-1f2f44-3g1f31-2g8f68b1c39b8d71g1f39e7e59f1c49f8e79-5c7c61f2f46d8a59f1d39e7e59-4g1f33-2e7e51d4e53d6e59d1d89e8d89-4g1f36b8d79f1c49f8e79e1g19e8g89f1e19c7c69a2a49-10g7g66c1e31c7c66d1d29b7b59-3f8g73d1d29-3c1g51f8g79d1d29-3f1e21f8g79-2f2f31-1B09.f2f42f8g79g1f39c7c53f1b59c8d79e4e59f6g49-5e8g86f1d39-5B08.g1f32f8g79f1e29e8g89e1g19c7c65-1c8g44-6B07.g2g31f8g79f1g29e8g89g1e29e7e59-8f1d31e7e59-2f2f31-4C20.e7e52C23.b1c31b8c62-1C25.g8f67C27.f1c43-1C26.f2f43C29.d7d59f4e59f6e49-4C25.g2g33-3C21.d2d41e5d49C22.d1d49b8c69d4e39g8f69-6C23.f1c41b8c61-1g8f68C24.d2d39b8c64g1f39-2c7c63g1f39-2f8c52-4C30.f2f41C31.d7d51e4d59-2C33.e5f46f1c42-1C34.g1f37C37.g7g59-3C30.f8c51g1f39d7d69-4C25.g1f38C44.b8c68C46.b1c31g8f69C47.d2d44e5d49f3d49f8b49d4c69b7c69f1d39d7d59e4d59c6d59e1g19e8g89c1g59c7c69-14C48.f1b53c6d44-1C49.f8b45e1g19e8g89d2d39d7d69-6C46.g2g32f8c59f1g29d7d69-6C44.c2c31g8f69d2d49-3d2d41e5d49c2c31-1f1c41f8c52-1g8f67e1g14-1e4e55d7d59c4b59-5C45.f3d47f8c55c1e34d8f69c2c39g8e79f1c49-5d4b31-1d4c64d8f69d1d29d7c69b1c39-6g8f64b1c32f8b49d4c69b7c69f1d39d7d59e4d59-7d4c67b7c69e4e59d8e79d1e29f6d59c2c49c8a65b2b39-2d5b64-12C60.f1b56C68.a7a67C70.b5a48b7b51a4b39-2C71.d7d61C74.c2c35C75.c8d79-2C72.e1g14-2C77.g8f69d1e21b7b59a4b39-3d2d31b7b54a4b39-2d7d65c2c39-3d2d41e5d49e1g19f8e79f1e19-5C78.e1g18b7b51";
	c0_opn[9]="a4b39c8b73f1e19f8c59-3f8c53a2a49-2f8e73f1e19d7d64-1e8g85-5C80.f6e41d2d49b7b59a4b39d7d59d4e59C81.c8e69b1d24e4c59c2c39-3C82.c2c35f8c59-9C78.f8c51-1C84.f8e77C85.a4c61d7c69d2d39-3C86.d1e21b7b59a4b39-3C87.f1e19C88.b7b59a4b39d7d66C90.c2c39e8g89C91.d2d41c8g49-2C92.h2h39c6a54C96.b3c29c7c59d2d49d8c79b1d29c5d49c3d49-8C94.c6b81C95.d2d49b8d79b1d29c8b79b3c29f8e89d2f19-8C92.c8b72d2d49f8e89b1d23e7f89-2f3g56e8f89g5f39f8e89f3g59-8f6d71d2d49-2f8e81-5C88.e8g83a2a41c8b79d2d39d7d69-4C89.c2c35d7d54e4d59f6d59f3e59c6e59e1e59c7c69d2d49e7d69e5e19-10C90.d7d65h2h39c6a59b3c29c7c59d2d49-7C88.d2d41-1h2h31c8b79d2d39-11C68.b5c61d7c69b1c31-1d2d41e5d49d1d49d8d49f3d49-5e1g17c8g42h2h39h7h59d2d39-4C69.d8d62-1f7f65d2d49c8g43d4e59d8d19f1d19-4e5d46f3d49c6c59d4b39d8d19f1d19-12C61.c6d41f3d49e5d49-3C62.d7d61d2d49-2C63.f7f51b1c36f5e49c3e49-3d2d33f5e49d3e49-4C64.f8c51c2c33-1e1g16-2C60.g7g61-1g8e71-1C65.g8f61d2d31d7d69-2e1g18C67.f6e48d2d49e4d69b5c69d7c69d4e59d6f59d1d89e8d89b1c39d8e89h2h39-12C65.f8c51c2c39-5C50.f1c41f8c54C51.b2b41c5b49c2c39-3C53.c2c35g8f69d2d35a7a63-1d7d66-2d2d44e5d49C54.c3d49c5b49b1c34-1c1d25-7C50.d2d31g8f69-2e1g11g8f69-3f8e71-1C55.g8f64d2d35f8c53c2c39-2f8e75e1g19e8g89f1e19d7d69-5h7h61-2C56.d2d41e5d49e1g14-1e4e55-3C57.f3g52d7d59e4d59C58.c6a59c4b59c7c69C59.d5c69b7c69-11C41.d7d61d2d48b8d72f1c49-2e5d45f3d49g8f69b1c39f8e79-5g8f62b1c39b8d79-4f1c41-2C40.f7f51-1C42.g8f61b1c31b8c66d2d44e5d49f3d49-3f1b55-2f8b43-2C43.d2d41f6e49f1d39d7d59f3e59b8d79e5d79c8d79e1g19-9C42.f3e56d7d69e5f39f6e49b1c31e4c39d2c39f8e79-4d1e22d8e79d2d39e4f69c1g59e7e29f1e29f8e79b1c39c7c69-10d2d46d6d59f1d39b8c64e1g19f8e79c2c49c6b49d3e29e8g89b1c39-8f8d63e1g19e8g89c2c49c7c69-5f8e72e1g19b8c69c2c49-14C00.e7e61b1c31d7d59-2d1e21c7c59-2d2d31c7c52g1f39b8c69g2g39-4d7d57b1d27c7c53g1f39b8c69g2g39-4g8f66g1f39b7b63-1b8c62-1c7c53g2g39b8c69f1g29-7d1e22-3d2d48c7c51-1d7d59C01.b1c34b8c61-1C10.d5e41c3e49b8d76g1f39g8f69e4f69d7f69-5c8d73g1f39d7c69f1d39b8d79-7C15.f8b45e4d51e6d59f1d39b8c69a2a39-5C16.e4e58b7b61-1C17.c7c57C18.a2a38b4a51b2b49c5d49c3b59a5c79-5C19.b4c38";
	c0_opn[10]="b2c39d8a51c1d29-2d8c72d1g44f7f59-2g1f35-2g8e76d1g46d8c74g4g79h8g89g7h79c5d49g1e29-6e8g85f1d39-3g1f33-5C17.c1d21g8e79-3C16.d8d71-1g8e71a2a39b4c39b2c39c7c59d1g49-7C15.g1e21d5e49a2a39b4e79-5C10.g8f63C11.c1g56C13.d5e43c3e49b8d73g1f39-2f8e76g5f69e7f65g1f39-2g7f64g1f39-6C12.f8b42e4e59h7h69g5d29b4c39b2c39f6e49d1g49g7g69f1d39e4d29e1d29c7c59-13C13.f8e73e4e59C14.f6d79g5e76d8e79f2f49a7a65g1f39c7c59-3e8g84g1f39-5h2h43-5C11.e4e53f6d79c3e21c7c59c2c39-3f2f48c7c59g1f39b8c69c1e39a7a64d1d29b7b59-3c5d45f3d49f8c59d1d29e8g89e1c19-15C03.b1d23a7a61g1f39c7c59-3C04.b8c61g1f39g8f69e4e59f6d79-5C07.c7c52e4d56d8d55g1f39c5d49f1c49d5d69e1g19g8f69d2b39b8c69b3d49c6d49f3d49a7a69-13C08.e6d54f1b53-1C09.g1f36b8c69f1b59f8d69-6C07.g1f33b8c63e4d59e6d59-3c5d44e4d59d8d59f1c49d5d69-5g8f62-3C03.d5e41d2e49b8d76g1f39g8f69e4f69d7f69-5c8d73g1f39d7c69f1d39b8d79-7f8e71f1d35c7c59d4c59g8f69d1e29-5g1f34g8f69-3C05.g8f64C06.e4e59f6d79c2c32c7c59f1d39b8c69g1e29c5d49c3d49f7f69e5f69d7f69-10f1d35c7c59c2c39b8c69g1e29c5d47c3d49f7f69e5f69d7f69d2f36f8d69e1g19-3e1g13f8d69d2f39-8d8b62d2f39c5d49c3d49f7f69-10f2f41c7c59c2c39b8c69d2f39d8b69-8C05.f1d31c7c59-4C01.e4d51e6d59c2c41g8f69-2f1d34b8c63c2c39f8d69-3f8d66g1f39-3g1f34f8d64c2c49-2g8f65f1d39-5C02.e4e51c7c59c2c39b8c67g1f39c8d74a2a33-1f1e26g8e79-3d8b64a2a35c5c49-2f1d31-1f1e22-2g8e71-3d8b62g1f39b8c64a2a39-2c8d75-4g1f31-5C00.g1f31d7d59b1c35g8f69e4e59f6d79d2d49c7c59d4c59-7e4e54c7c59b2b49-6A40.g7g61b1c31f8g79-2B06.d2d49c7c61-1d7d61b1c39f8g79-3f8g78b1c36c7c63c1e31-1f1c42d7d69-2f2f42d7d59e4e59-3g1f33d7d55-1d7d64-3d7d66c1e34a7a66d1d29-2c7c63d1d29-3f2f43g8f69g1f39e8g89-4g1f31-3c2c31d7d69-2c2c41d7d69b1c39-3f2f41-1g1f31d7d69b1c35-1f1c44-6B02.g8f61b1c31d7d58e4d54f6d59f1c49-3e4e55-2e7e51-2e4e58f6d59b1c31-1c2c41d5b69c4c53b6d59-2d2d46d7d69e5d69-5B03.d2d48d7d69c2c43d5b69e5d67c7d64b1c39g7g69-3e7d65b1c39f8e79-4f2f42d6e59f4e59-5B04.g1f36c8g45B05.f1e29c7c63-1e7e66e1g19f8e79c2c49d5b69-7B04.d6e52f3e59-2g7g62f1c49d5b69c4b39f8g79.A02.f2f41A03.d7d56g1f39g7g64-1g8f65-3A02.e7e51-1g8f61g1f39.A04.g1f31b7b61-1b8c61";
	c0_opn[11]="d2d49d7d59-3c7c51b2b31-1c2c46b8c64b1c35e7e53-1g7g66-2d2d43c5d49f3d49-3g2g31-2g7g62d2d49-2g8f63b1c37e7e69g2g39-3g2g32-3e2e41-1g2g32b8c67f1g29g7g69e1g19f8g79-5g7g62f1g29f8g79-5A06.d7d52b2b31c8g44-1g8f65c1b29-3A09.c2c42c7c64b2b32-1d2d42g8f69-2e2e34g8f69b1c39-4d5c41-1d5d41-1e7e63d2d43-1g2g36g8f69f1g29-5A06.d2d43c7c61c2c49e7e64-1g8f65-3e7e61c2c49-2g8f66c2c49c7c64b1c39-2d5c41e2e39-2e7e64b1c37f8e79-2g2g32-5e2e31-1A07.g2g33b8c61-1A08.c7c51f1g29b8c69-3A07.c7c62f1g29c8g47e1g19b8d79-3g8f62-3c8g41f1g29b8d79-3g7g61f1g29f8g79-3g8f63f1g29c7c65e1g19-2e7e64e1g19f8e79-7A04.d7d61d2d49c8g45-1g8f64-3e7e61c2c45-1g2g34-2f7f51c2c41g8f69-2d2d43g8f69-2g2g35g8f69f1g29g7g69-5g7g61c2c42f8g79b1c34-1d2d45-3d2d43f8g79c2c49-3e2e41f8g79d2d49d7d69-4g2g32f8g79f1g29-4A05.g8f64b2b31g7g69c1b29f8g79g2g39-5c2c45b7b61g2g39c8b79f1g29e7e69e1g19-6c7c51b1c37b8c64g2g39-2d7d52c4d59f6d59-3e7e62g2g39-3g2g32b7b69f1g29c8b79-5c7c61b1c34-1d2d45d7d59-3d7d61d2d49-2e7e62b1c34d7d55d2d49f8e79-3f8b44d1c29e8g89-4d2d41-1g2g34b7b63f1g29c8b79e1g19f8e79-5d7d56d2d42-1f1g27f8e79e1g19e8g89-7g7g63b1c36d7d52c4d59f6d59-3f8g77d2d41e8g89-2e2e47d7d69d2d49e8g89f1e29e7e59e1g19b8c69d4d59c6e79-10g2g31e8g89f1g29-5b2b31f8g79c1b29-3d2d41f8g79g2g39-3g2g32f8g79f1g29e8g89d2d42-1e1g17d7d69b1c34-1d2d45-9d2d41d7d52c2c49-2e7e63c2c49-2g7g64c2c49f8g79b1c39-5g2g32b7b51f1g29c8b79-3b7b61f1g29c8b79e1g19e7e69-5c7c51f1g29-2d7d52f1g29c7c67e1g19c8g49-3e7e62-3g7g65b2b32f8g79c1b29e8g89f1g29d7d69d2d49-7f1g27f8g79c2c41-1e1g18e8g89c2c43d7d69-2d2d33d7d54-1d7d65-2d2d43d7d69.A00.g2g31c7c51f1g29b8c69-3d7d53f1g26c7c64-1g8f65-2g1f33-2e7e51f1g29-2g7g61f1g29f8g79c2c49-4g8f62f1g29d7d55-1g7g64";
	}

	private function c0_Opening(c0_fmoves:String):String
	{
	var c0_retdata:String="";

	var c0_mvs:String="";
	var c0_s:String="";
	var c0_c:String="";

	var c0_ECO:String="";
	var c0_kf:String="";

	var c0_i:int=0;
	var c0_j:int=0;

	var c0_pt:int=0;
	var c0_nm:int=0;


	var c0_NMoves:String="";
	var c0_OName:String="";
	var c0_op:String="";

	for(c0_i=1; c0_i<c0_opn.length; c0_i++)
	{
	c0_s=c0_opn[ c0_i ];
	for(c0_j=0; c0_j<c0_s.length;)
		{
		c0_c=c0_s.substr(c0_j, 1 );		// Looking for special symbols or type of information...
		if(c0_c=="-")				// Other variant...
			{
			c0_j++;
			for(c0_nm=0; c0_j+c0_nm<c0_s.length &&
				("0123456789").indexOf(c0_s.substr(c0_j+c0_nm,1))>=0;) c0_nm++;

							// Next value is length for moves to shorten...
			c0_mvs=c0_mvs.substr(0, c0_mvs.length- (4*parseInt( c0_s.substr(c0_j,c0_nm) )) );
			c0_j+=c0_nm;
			}
		else if(c0_c==".")			// Will be other opening or variant...
			{
			c0_j++;
			c0_mvs="";
			}
		else if(("abcdefgh").indexOf(c0_c)>=0)	// If it is a chess move...
			{
			c0_mvs+=c0_s.substr(c0_j,4);
			c0_j+=4;
			}
		else if(("0123456789").indexOf(c0_c)>=0)	// If it is a coefficient (for best move searches)...
			{
			c0_kf=c0_c;
			if((c0_mvs.length>c0_fmoves.length) && (c0_mvs.substr(0,c0_fmoves.length)==c0_fmoves))
				{
				var c0_next:String= c0_mvs.substr(c0_fmoves.length,4)

				if(c0_NMoves.indexOf(c0_next)<0) c0_NMoves+=c0_next+" ("+c0_kf+") ";
				}
			c0_j++;
			}
		else					// Opening information... ECO code and name (Main name for x00)
			{
			c0_ECO=c0_s.substr(c0_j,3)
			c0_j+=3;
			for(c0_pt=0; c0_s.substr(c0_j+c0_pt,1)!=".";) c0_pt++;

			if((c0_mvs.length<=c0_fmoves.length) && (c0_fmoves.substr(0,c0_mvs.length)==c0_mvs))
				{
				if(c0_mvs.length>c0_op.length && c0_op.length<c0_fmoves.length)
					{
					c0_op=c0_mvs;
					c0_OName="ECO "+c0_ECO;
					}
				}

			c0_j+=(c0_pt+1);
			}
		}
	}
					// Sorting by coeff. descending
	for(c0_i=1;c0_i<10;c0_i++)
	{
	for(c0_j=6;c0_j<c0_NMoves.length-9;)
		{
		c0_j+=9;
		if( c0_NMoves.substr(c0_j,1)==c0_i.toString() && c0_NMoves.substr(c0_j,1)>=c0_NMoves.substr(6,1) )
			{
			c0_NMoves=c0_NMoves.substr(c0_j-6,9)+c0_NMoves.substr(0,c0_j-6)+c0_NMoves.substr(c0_j-6+9);
			}
		}
	}

	if( c0_NMoves.length>0 ) c0_retdata=c0_NMoves + c0_OName;

	return c0_retdata;
	}
  }

}