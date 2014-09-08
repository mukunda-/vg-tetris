/******************************************************************************
 * Tetris for SMES
 * Copyright (C) 2014 Mukunda Johnson
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 ******************************************************************************/

#include <sourcemod>
#include <sdktools>
#include <videogames>

#pragma semicolon 1

// 1.0.2
//  shorten title screen time between swaps
// 1.0.1
// fixed duel lines incoming bug!!

//----------------------------------------------------------------------------------------------------------------------
public Plugin:myinfo = {
	name = "Videogames -> Tetris",
	author = "mukunda",
	description = "Tetris!!",
	version = "1.0.2",
	url = "www.mukunda.com"
};

// TODO NOTES
// MAKE SURE *EVERYTHING* IS INITIALIZED ON GAME STARTUP
//        lines_cleared etc
//       scrub through ALL variables
// TODO start pieces a little lower at hte top so they dont go past boundaries
// check the top if its obstructed first though, and do not start it lower if it is
// also: the plaeyr loses if the top row is occupied when a piece spawns (possible in 2player mode)
//----------------------------------------------------------------------------------------------------------------------
// assets

#define MODEL_BLOCKCELL 	"models/videogames/tetris/blockcell.mdl"
#define MODEL_CARTRIDGE 	"models/videogames/tetris/cartridge.mdl"
#define MODEL_32_32 	"models/videogames/tetris/gfx_32_32.mdl"
#define MODEL_128_8		"models/videogames/tetris/gfx_128_8.mdl"
#define MODEL_BG1		"models/videogames/tetris/gfx_bg1.mdl"
#define MODEL_BG2		"models/videogames/tetris/gfx_bg2.mdl"
 
#define GFX_32_TETRIMINOES			1
#define GFX_32_GHOST				29
#define GFX_32_TETRIMINOES_SMALL	57
#define GFX_32_FONT					64
#define GFX_32_NUMBERS				64
#define GFX_32_LETTERS				74
#define GFX_32_QM					100 // question mark
#define GFX_32_COLON				101
#define GFX_32_SPLASH				104
#define GFX_32_CLEAR				107
#define GFX_32_FAIL					110
#define GFX_32_WINNER				113
#define GFX_32_LOSER				116
#define GFX_32_COUNTDOWN			119
#define GFX_32_COUNTDOWN2			122
#define GFX_32_TRYAGAIN				125
#define GFX_32_NEWRECORD			128

#define GFX_32_PRESSE				131
#define GFX_32_SPRINT				134
#define GFX_32_DUEL					137
 

#define GFX_LINES 0

//#define MUSIC_TITLE "*videogames/tetris/title.mp3"

new fontmap[96] = {
	 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,39, 0, 0, 
	 1, 2, 3, 4, 5, 6, 7, 8, 9,10,38, 0, 0, 0, 0,37,
	 0,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,
	26,27,28,29,30,31,32,33,34,35,36, 0, 0, 0, 0, 0,
	 0,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,
	26,27,28,29,30,31,32,33,34,35,36, 0, 0, 0, 0, 0
};

new fontwidth[40] = {
	10,10,10,10,10,10,10,10,10,10,
	12,12,12,12,10,10,12,12, 4,12,
	12,10,20,12,12,12,12,12,12,12,
	12,12,16,12,12,12,12, 4,12, 0
};

//----------------------------------------------------------------------------------------------------------------------
new String:model_list[][] = {
	MODEL_BLOCKCELL,
	MODEL_CARTRIDGE,
	MODEL_32_32,
	MODEL_128_8,
	MODEL_BG1,
	MODEL_BG2
	
	
};

//----------------------------------------------------------------------------------------------------------------------
new String:downloads[][] = {

	"models/videogames/tetris/blockcell.dx90.vtx",
	"models/videogames/tetris/blockcell.mdl",
	"models/videogames/tetris/blockcell.vvd",
	"models/videogames/tetris/cartridge.dx90.vtx",
	"models/videogames/tetris/cartridge.mdl",
	"models/videogames/tetris/cartridge.phy",
	"models/videogames/tetris/cartridge.vvd",
	"models/videogames/tetris/gfx_32_32.dx90.vtx",
	"models/videogames/tetris/gfx_32_32.mdl",
	"models/videogames/tetris/gfx_32_32.vvd",
	"models/videogames/tetris/gfx_128_8.dx90.vtx",
	"models/videogames/tetris/gfx_128_8.mdl",
	"models/videogames/tetris/gfx_128_8.vvd",
	"models/videogames/tetris/gfx_bg1.dx90.vtx",
	"models/videogames/tetris/gfx_bg1.mdl",
	"models/videogames/tetris/gfx_bg1.vvd",
	"models/videogames/tetris/gfx_bg2.dx90.vtx",
	"models/videogames/tetris/gfx_bg2.mdl",
	"models/videogames/tetris/gfx_bg2.vvd",
	
	"materials/videogames/tetris/blockcell.vmt",
	"materials/videogames/tetris/blockcell.vtf",
	"materials/videogames/tetris/cart_tetris.vmt",
	"materials/videogames/tetris/cart_tetris.vtf",
	"materials/videogames/tetris/gfx_32_32.vmt",
	"materials/videogames/tetris/gfx_32_32.vtf",
	"materials/videogames/tetris/gfx_128_8.vmt",
	"materials/videogames/tetris/gfx_128_8.vtf",
	"materials/videogames/tetris/gfx_bg1.vmt",
	"materials/videogames/tetris/gfx_bg1.vtf",
	"materials/videogames/tetris/gfx_bg2.vmt",
	"materials/videogames/tetris/gfx_bg2.vtf",
	
	"sound/videogames/tetris/title.mp3",
	"sound/videogames/tetris/sprint.mp3",
	"sound/videogames/tetris/duel.mp3", 
	"sound/videogames/tetris/select.mp3",
	"sound/videogames/tetris/countdown.mp3",
	"sound/videogames/tetris/flip.mp3",
	"sound/videogames/tetris/wall3.mp3",
	"sound/videogames/tetris/lock.mp3",
	"sound/videogames/tetris/clear3.mp3", 
	"sound/videogames/tetris/highscore.mp3"
}; 

new field_position[2][2]; // position of play fields in pixels on screen

new tetris_field[2][12*32]; // data for tetris fields (1=filled,0=cleared)	
							// includes extra space to fill with play border (to ease collision testing!)
							// actual on-screen field is X 1-10 and Y 11-30
					
// lets say the player uses 60 pieces / minute
// 10 minute game would be 600 pieces
// 2 minute game would be 120 pieces
// 5 minute game would be 300 pieces
// okay lets have 4096 pieces

// according to tetris guideline, random generator should deal hands containing all pieces before repeating
// so every 7 pieces will contain one of each ordered randomly

#define SEQUENCE_SIZE 2000
new String:piece_sequence[SEQUENCE_SIZE*7];
new piece_sequence_write;

// next piece the player will draw (also look ahead 3 spaces for next pieces)
new player_piece_draw[2];



//----------------------------------------------------------------------------------------------------------------------							
#define FIELD_BASEY			10
#define FIELD_DATAWIDTH		12
#define FIELD_BASEX			1
#define FIELD_DATAHEIGHT	32

#define FIELD_WIDTH			10
#define FIELD_HEIGHT		20
  
//----------------------------------------------------------------------------------------------------------------------
new String:piece_forms[][] = {

	"      #      #  ",
	"####  #      #  ", // I
	"      # #### #  ",
	"      #      #  ",
	
	"#    ##      #  ",
	"###  #  ###  #  ", // J
	"     #    # ##  ",
	"                ",
	
	"  #  #      ##  ",
	"###  #  ###  #  ", // L
	"     ## #    #  ",
	"                ",
	
	" ##  ##  ##  ## ",
	" ##  ##  ##  ## ", // O
	"                ",
	"                ",
	
	"##    #      #  ",
	" ##  ## ##  ##  ", // Z
	"     #   ## #   ",
	"                ",
	
	" ##  #      #   ",
	"##   ##  ## ##  ", // S
	"      # ##   #  ",
	"                ",
	
	" #   #       #  ",
	"###  ## ### ##  ", // T
	"     #   #   #  ",
	"                "
	
};

// vertical bounding boxes of pieces, used to determine ghost piece visibility
new piece_vmin[7*4] = { 
	1,0,2,0,  // I
	0,0,1,0,  // J
	0,0,1,0,  // L
	0,0,0,0,  // O
	0,0,1,0,  // Z
	0,0,1,0,  // S
	0,0,1,0  // T
};
new piece_vmax[7*4] = {
	1,3,2,3, // I
	1,2,2,2, // J
	1,2,2,2, // L
	1,1,1,1, // O
	1,2,2,2, // 
	1,2,2,2, // Z
	1,2,2,2 // S
}; 

#define FORM_EMPTY ' '
#define FORM_FILLED '#'

//----------------------------------------------------------------------------------------------------------------------
enum {
	PIECE_I,
	PIECE_J,
	PIECE_L,
	PIECE_O,
	PIECE_Z,
	PIECE_S,
	PIECE_T,
	PIECE_TOTAL
};

//----------------------------------------------------------------------------------------------------------------------
// ingame text map
enum {
	IG_TEXT_PLAYFIELDS=0,						// playfield display  25 x 2 players
	IG_TEXT_NEXTPIECE=IG_TEXT_PLAYFIELDS+50,	// next pieces3 x 2 players, 1player uses 4 (leaving 2 unused)
	IG_TEXT_HOLD=IG_TEXT_NEXTPIECE+6,			// held piece 1 x 2 players
	IG_TEXT_TIME=IG_TEXT_HOLD+2,				// 1p time counter "xxx.xx" (6 ents)
	IG_TEXT_LINES=IG_TEXT_TIME+6,				// 1p line counter "xx" (2 ents)
	IG_TEXT_PIECE=IG_TEXT_LINES+2,				// active piece being controlled on field (x2 players)
	IG_TEXT_GHOST=IG_TEXT_PIECE+2,				// ghost pieces
	IG_TEXT_CENTERTEXT=IG_TEXT_GHOST+2,			// countdown number, WINNER,LOSER,CLEAR,FAIL,etc
	IG_TEXT_LINEEFFECTS=IG_TEXT_CENTERTEXT+6,	// line effect overlays
	
	IG_TEXT_TOTAL=IG_TEXT_LINEEFFECTS+20*2
};

enum {
	TS_TEXT_PRESSE,
	//TS_TEXT_SELECTOR=TS_TEXT_PRESSE+3,
	TS_TEXT_SPRINT=TS_TEXT_PRESSE+3,
	TS_TEXT_DUEL=TS_TEXT_SPRINT+3,
	TS_TEXT_SCORES=TS_TEXT_DUEL*3,
	TS_TEXT_NAMES=TS_TEXT_SCORES+3*6,
	TS_TEXT_TOTAL=TS_TEXT_NAMES+60
};

//----------------------------------------------------------------------------------------------------------------------
// global game state switcher
new game_state;
new game_timer;

enum {
	GS_STARTUP,
	GS_TITLE,
	GS_INGAME,
	GS_LOADGAME
};

#define SPRINT_LINES_TO_WIN 20

//----------------------------------------------------------------------------------------------------------------------
// ingame variables
new game_players;

new game_gravity; // todo; split for two player

#define FORCE_GRAVITY 180

//----------------------------------------------------------------------------------------------------------------------
new piece_type[2];	// current type of piece a player is using 

new piece_position[2][2]; // internal position of piece on field
// Y is x.8 fixed point in FIELD units

// actual position of piece on screen, this shifts towards internal position quickly
// x.8 fixed point in PIXEL units
new actual_piece_position[2][2]; 
new piece_rotation[2];
new piece_lock_time[2];
 
new player_ghost_position[2]; // X position of ghost piece, in field units
new player_ghost_rotation[2];
new player_ghost_top[2];
  
new line_clear_timers[2][20]; // lines 
new bool:lines_cleared[2][20]; // lines that should be cleared
//new line_clear_bottom[2]; // position on field of the lowest line being cleared (above portion gets shifted to here.)
//new bool:lines_cleared[2][4]; // lines that have been cleared relative to player's locking position 
new lines_cleared_count[2]; // number of lines last cleared

new piece_held[2]; // piece a player has in their hold box
new bool:player_held_use[2]; // was held used for the current piece? (cannot hold again until locked)

new lines_incoming[2]; // lines given by the enemy in duel mode, appear when the next piece locks
new lines_incoming_index[2]; // controls where the slot appears in the lines filling the field

//  sprint mode
new sprint_timer;
new sprint_lines_remaining;
new sprint_record;

new ingame_fade;

//----------------------------------------------------------------------------------------------------------------------
new player_throw_dir[2];		// variables for "throwing" logic
new player_throw_time[2];		// throwing is when the player holds a direction and wants it to quickly slide that way
#define THROW_TIME 13			// time player has to hold the direction before throw starts

//----------------------------------------------------------------------------------------------------------------------
#define LOCK_TIME 30			// time a piece has to sit before it locks
#define LOCK_TIME_HELD 12		// time when the piece is forced with DOWN held

//----------------------------------------------------------------------------------------------------------------------
new player_state[2];
new player_timer[2]; // generic timer for state stuff

new bool:ingame_ending;
new ingame_music_fade;
new priority_hack;

//----------------------------------------------------------------------------------------------------------------------
#define LOCK_DELAY_NEXT 10		// delay before next piece comes out when a piece locks
#define DROP_DELAY_NEXT 7		// delay after hard drop is used

#define PIECE_Y_POSITION ((piece_position[player][1]+255)>>8) // conversion from fixed point Y value to position on field

//----------------------------------------------------------------------------------------------------------------------
enum {
	PS_STARTING, // game start countdown
	PS_CONTROL,	 // controlling a piece
	PS_LOCKED,	 // a piece was just locked - mainly for a brief delay before next piece
	PS_CLEARING, // a piece was locked and lines are being cleared - slightly more delay than a normal piece locking
	PS_READY,	 // ready signal state - maybe have a countdown?
	PS_DROPPING, // player is dropping a piece
	PS_LOSE,	 // the player has topped out 
	PS_WINNING,	 // the player has won a duel or cleared a sprint
	PS_NULL		// game has ended
};

new game_time;

#define SP_TIMER_X 11
#define SP_TIMER_LETTERSPACING 12
#define SP_TIMER_MIDDLESPACE 6
#define SP_TIMER_Y 65
#define SP_TIMER_DIVIDERPOS 36

#define SP_LINESREMAINING_X 32
#define SP_LINESREMAINING_Y 107

new piece_center_offset[] = {0, 4, 4, 0, 4, 4, 4}; // offset to center tetrimino graphics
new piece_center_vert[] = {4, 8, 8, 8, 8, 8, 8}; // offset to center tetrimino graphics

// CONTROLS:
// A/D - left shift/right shift
//   holding will "throw" the piece
// S : non-locking soft-drop
// W : hard drop
// Shift : Rotate left/CCW
// Space : Rotate right/CW
// E  : Hold piece

//----------------------------------------------------------------------------------------------------------------------

#define SCORE_ENTRIES 3

new score_times[SCORE_ENTRIES];
new String:score_names[SCORE_ENTRIES][128];
//----------------------------------------------------------------------------------------------------------------------

new title_switchtimer;
new title_switchpos;
new title_desiredscroll;
new Float:title_scroll;
new title_texttimer;
new title_state; // 0 = autoscroll, 1 = selecting gamemode
new title_select;

 

new String:soundlist[][] = {
	"*videogames/tetris/title.mp3",
	"*videogames/tetris/sprint.mp3",
	"*videogames/tetris/duel.mp3", 
	"*videogames/tetris/select.mp3",
	"*videogames/tetris/countdown.mp3",
	"*videogames/tetris/flip.mp3",
	"*videogames/tetris/wall3.mp3",
	"*videogames/tetris/lock.mp3",
	"*videogames/tetris/clear3.mp3", 
	"*videogames/tetris/highscore.mp3"
};

enum {
	SOUND_BGM_TITLE,
	SOUND_BGM_SPRINT,
	SOUND_BGM_DUEL, 
	SOUND_SELECT,
	SOUND_COUNTDOWN,
	SOUND_FLIP,
	SOUND_WALL,
	SOUND_LOCK,
	SOUND_CLEAR, 
	SOUND_HIGHSCORE
};

new sound_bgm;

//----------------------------------------------------------------------------------------------------------------------
CheckDataPath() {
	decl String:path[256];
	BuildPath( Path_SM, path, sizeof path, "data/videogames/tetris" );
	if( !DirExists( path ) ) {
		SetFailState( "missing data files" );
	}
}

//----------------------------------------------------------------------------------------------------------------------
LoadData() {
	decl String:path[256];
	BuildPath( Path_SM, path, sizeof path, "data/videogames/tetris/data.txt" );
	
	for( new i = 0; i < 3; i++ ) {
		score_times[i] = 99999;
		score_names[i] = "---";
	}
	
	new Handle:kv = CreateKeyValues( "TetrisData" );
	for(;;) {
		if( !FileExists( path ) ) break;
		if( !FileToKeyValues( kv, path ) ) break;

		for( new i = 0; i < 3; i++ ) {
			decl String:keyname[128];
			FormatEx( keyname, sizeof keyname, "scores/%d/time", i );
			score_times[i] = KvGetNum( kv, keyname, 59999 );
			FormatEx( keyname, sizeof keyname, "scores/%d/name", i );
			KvGetString( kv, keyname, score_names[i], sizeof score_names[], "---" );
		}
		break;
	}
	CloseHandle(kv);
	return;
}

//----------------------------------------------------------------------------------------------------------------------
SaveData() {
	decl String:path[256];
	BuildPath( Path_SM, path, sizeof path, "data/videogames/tetris/data.txt" );
	
	new Handle:kv = CreateKeyValues( "TetrisData" );
	for( new i = 0; i < 3; i++ ) {
		decl String:keyname[128];
		FormatEx( keyname, sizeof keyname, "scores/%d/time", i );
		KvSetNum( kv, keyname, score_times[i] );
		FormatEx( keyname, sizeof keyname, "scores/%d/name", i );
		KvSetString( kv, keyname, score_names[i] );
	}
	KeyValuesToFile( kv, path );
	CloseHandle(kv);
}

//----------------------------------------------------------------------------------------------------------------------
RecordScore( const String:name[], time ) {
	new pos = -1;
	for( new i = 0; i < SCORE_ENTRIES; i++ ) {
		if( time < score_times[i] ) {
			pos = i;
			break;
		}
	}
	
	if( pos == -1 ) {
		return 0;
	}
	for( new i = 2; i > pos; i-- ) {
		score_times[i] = score_times[i-1];
		strcopy( score_names[i], sizeof score_names[], score_names[i-1] );
	}
	score_times[pos] = time;
	strcopy( score_names[pos], sizeof score_names[], name );
	SaveData();
	return pos+1;
}

//----------------------------------------------------------------------------------------------------------------------
Abs( a ) {
	return a < 0 ? -a : a;
}

//----------------------------------------------------------------------------------------------------------------------
public OnAllPluginsLoaded() {
	VG_Register( "tetris", "Tetris" );
}

//----------------------------------------------------------------------------------------------------------------------
public OnPluginStart() {
	CheckDataPath();
	LoadData();
	
}


//----------------------------------------------------------------------------------------------------------------------
public OnMapStart() {
	for( new i = 0; i < sizeof(model_list); i++ ) {
		PrecacheModel( model_list[i] );
	}
	
	for( new i = 0; i < sizeof(downloads); i++ ) {
		AddFileToDownloadsTable( downloads[i] );
	}
	
	PrecacheSound( "ui/beep07.wav" );
	
	for( new i = 0; i < sizeof soundlist; i++ ) {
		PrecacheSound( soundlist[i] );
	}
	
	
}

//----------------------------------------------------------------------------------------------------------------------
public VG_OnEntry() {
	game_time = 0;
	
	VG_SetFramerate( 60.0 );
	VG_SetUpdateTime( 100 );
	VG_SetBlanking( false );
	VG_SetBackdrop( 111,77, 15 );
	
	
	SwitchGameState( GS_STARTUP );
	//StartGame(1);
	
	
}

//----------------------------------------------------------------------------------------------------------------------
public VG_OnFrame() {
	game_time++;
	switch( game_state ) {
		case GS_STARTUP: GameLoop_Startup();
		case GS_INGAME:  GameLoop_Ingame();
		case GS_TITLE:   GameLoop_Title();
		case GS_LOADGAME: GameLoop_LoadGame();
	}
}

//----------------------------------------------------------------------------------------------------------------------
SwitchGameState( newstate ) {
	game_state = newstate;
	game_timer = 0;
	if( newstate == GS_STARTUP ) 
		InitState_Startup();
	else if( newstate == GS_TITLE ) 
		InitState_Title();
	else if( newstate == GS_LOADGAME )
		InitState_LoadGame();
	else if( newstate == GS_INGAME ) {
		InitState_Ingame();
	}
	VG_Joypad_Flush();
}

//----------------------------------------------------------------------------------------------------------------------
InitState_LoadGame() {
	VG_SetBlanking( true );
	VG_BG_SetModel( MODEL_BG2 ); 
	VG_BG_LoadFile( "bg_ingame.dat", -1, 0, 0 );
	VG_BG_SetScroll( 0 );
	VG_BG_SetScreenRefresh();
	
	VG_Text_SetOnBatch( 0, VG_TEXT_COUNT, false );
}

//----------------------------------------------------------------------------------------------------------------------
GameLoop_LoadGame() {
	// this is just a delay to ease transition between title and ingame
	if( game_timer == 10 ) {
		SwitchGameState( GS_INGAME );
		return;
	}
	game_timer++;
}

//----------------------------------------------------------------------------------------------------------------------
InitState_Startup() {
	VG_SetBlanking( true );
	VG_SetBackdrop( 0, 0, 0 );
	VG_Sleep( 30 );
	 
	VG_Text_SetOffsetParam( 0, 0, 0, 1 );  
	
	VG_Text_SetModelBatch( 0, 3, MODEL_32_32 );
	VG_Text_SetColorBatch( 0, 3, 0x00808080 );
	VG_Text_SetOnBatch( 0, 3, true );
	VG_Text_SetPositionGrid( 0, 3, 128-95/2, 80-20/2-6, 3, 32, 32 );
	VG_Text_SetOffsetBatch( 0, 3, 0 );
	for( new i = 0; i < 3; i++ ) {
		 VG_Text_SetFrame( i, GFX_32_SPLASH+i );
	}
	
	for( new x = 0; x < 17; x++ ) {
		for( new y = 0; y < 10; y++ ) {
			VG_BG_SetTile( x, y, 0 );
		}
	}
}

PrintScoreName( text_start, y, const String:text[] ) {
	new x = 6; 
	new max = 20;
	new printed = 0;
	const spacewidth = 3;
	for( new c = 0; text[c]; c++ ) {
		if( x >= 156 ) break;
		new ch = _:text[c];
		if( ch <= 32 || ch >= 192 ) {
			// control character, space, or utf-8 character starter
			x += spacewidth;
			continue;
		}
		if( ch >= 128 ) {	
			// utf-8 continuation byte
			continue;
		}
		ch = fontmap[ch-32];
		if( ch == 0 ) {
			x += spacewidth;
			continue;
		}
		new index = TS_TEXT_NAMES+text_start;
		VG_Text_SetPosition( index, x, y );
		VG_Text_SetFrame( index, GFX_32_FONT+ch-1);
		VG_Text_SetOn( index, true );
		
		text_start++;
		printed++;
		x += fontwidth[ch-1]+2;
		max--;
		if( max == 0 ) break;
		
	}
	return printed;
}

//----------------------------------------------------------------------------------------------------------------------
InitState_Title() {
	VG_BG_SetModel( MODEL_BG1 );
	VG_BG_LoadFile( "bg1.dat", -1, 0, 0 );
	VG_SetBlanking( true );
	VG_Sleep(60);
	title_desiredscroll = 0;
	title_scroll = 0.0;
	title_switchpos = 0;
	title_switchtimer = 0;
	title_texttimer=0;
	title_state = 2;
	title_select = 0;
	
	// OFFSET 0: "PRESS E"
	// OFFSET 1: "SPRINT","DUEL",SELECTOR
	// OFFSET 2: LEADERBOARD
	VG_Text_SetOffsetParam( 0, 0, 0, 0 ); 
	VG_Text_SetOffsetParam( 1, 0, 0, 0 );
	VG_Text_SetOffsetParam( 2, 0, 0, 0 );
	
	VG_Text_SetModelBatch( 0, TS_TEXT_TOTAL, MODEL_32_32 );
	VG_Text_SetColorBatch( 0, TS_TEXT_TOTAL, 0x80808080 );
	VG_Text_SetOnBatch( 0, TS_TEXT_TOTAL, false );
	VG_Text_SetPositionGrid( TS_TEXT_PRESSE, 3, 80, 96, 3, 32, 32 );
	VG_Text_SetPositionGrid( TS_TEXT_SPRINT, 3, 80, 90, 3, 32, 32 );
	VG_Text_SetPositionGrid( TS_TEXT_DUEL, 3, 80, 114, 3, 32, 32 );
	VG_Text_SetOffsetBatch( TS_TEXT_PRESSE, 3, 0 );
	VG_Text_SetOffsetBatch( TS_TEXT_SPRINT, 6, 1 ); 
	//VG_Text_SetOffsetBatch( TS_TEXT_SELECTOR, 7, 1 );
	VG_Text_SetOffsetBatch( TS_TEXT_SCORES, 75, 2 );
	VG_Text_SetOnBatch( TS_TEXT_PRESSE, 9, true );
	
	for( new i = 0; i < 3; i++ ) {
		VG_Text_SetFrame( TS_TEXT_PRESSE+i, GFX_32_PRESSE+i );
		VG_Text_SetFrame( TS_TEXT_SPRINT+i, GFX_32_SPRINT+i );
		VG_Text_SetFrame( TS_TEXT_DUEL+i, GFX_32_DUEL+i );
	}
	//VG_Text_SetFrame( TS_TEXT_SELECTOR, GFX_32_SELECTOR );
	
	Title_UpdateSelectorPos();
	
	// draw scoreboard
	
	new name_char;
	
	for( new i = 0; i < 3; i++ ) {
		new score = score_times[i];
		if( score > 59999 ) score = 59999;
		
		new values[5];

		values[0] = (score/(60*100))%10;
		values[1] = (score/(60*10))%10;
		values[2] = (score/(60))%10;
		values[3] = (score/(10))%6;
		values[4] = score%10;
		
		VG_Text_SetPosition( TS_TEXT_SCORES+i*6+0, 184, 44 + i * 32 );
		VG_Text_SetPosition( TS_TEXT_SCORES+i*6+1, 196, 44 + i * 32 );
		VG_Text_SetPosition( TS_TEXT_SCORES+i*6+2, 208, 44 + i * 32 );
		VG_Text_SetPosition( TS_TEXT_SCORES+i*6+3, 226, 44 + i * 32 );
		VG_Text_SetPosition( TS_TEXT_SCORES+i*6+4, 238, 44 + i * 32 );
		VG_Text_SetPosition( TS_TEXT_SCORES+i*6+5, 220, 44 + i * 32 );
		
		for( new digit = 0; digit < 5; digit++ ) {
			if( digit == 0 && values[digit] == 0 ) {
				VG_Text_SetFrame( TS_TEXT_SCORES+i*6+digit, 0 );
			} else {
				VG_Text_SetFrame( TS_TEXT_SCORES+i*6+digit,   GFX_32_NUMBERS+values[digit] );
			}
		}
		VG_Text_SetFrame( TS_TEXT_SCORES+i*6+5,  GFX_32_COLON );
		
		// print names
		{
			
			
			new printed = PrintScoreName( name_char, 44+i*32, score_names[i] );
			if( printed == 0 ) {
				printed = PrintScoreName( name_char, 44+i*32, "???" );
			}
			name_char += printed;
			 
		}
	}
	VG_Text_SetOnBatch( TS_TEXT_SCORES, 6*3, true );
}

//----------------------------------------------------------------------------------------------------------------------
GameLoop_Startup() {
	
	if( game_timer == 60 ) {
		VG_SetBlanking(false);
		// setup graphics
		

	}
	if( game_timer >= 60 && game_timer <= 190 ) {
		
		new a = 128 *(game_timer-60) / 30;
		if( a > 128 ) a = 128;
		a = a | (a<<8) | (a<<16);
		VG_Text_SetColorBatch( 0, 3, 0x80000000|a );
		
	} else if( game_timer >= 250 && game_timer <= 280 ) {
		new a = 128-128 *(game_timer-250) / 30;
		if( a < 0 ) a = 0;
		a = a | (a<<8) | (a<<16);
		VG_Text_SetColorBatch( 0, 3, 0x80000000|a );
	}
	
	if( game_timer >= 90 && game_timer < 249 && VG_Joypad_Clicks( 1, VG_INPUT_E_INDEX ) ) {
		game_timer = 249;
	}
	
	//if( game_timer == 30 ) {// DEBUG
	if( game_timer == 281 ) {
		VG_Text_SetOnBatch( 0, 3, false );
		SwitchGameState( GS_TITLE );
		return;
	}
	
	
	VG_Joypad_Flush();
	game_timer++;
}

//----------------------------------------------------------------------------------------------------------------------
Title_UpdateSelectorPos() {
	//VG_Text_SetPosition( TS_TEXT_SELECTOR, 74+title_select*12,97+title_select*24 ); 
	if( title_select == 1 ) {
		VG_Text_SetColorBatch( TS_TEXT_SPRINT, 3, 0x80404040 );
		VG_Text_SetColorBatch( TS_TEXT_DUEL, 3, 0x80808080 );
	} else {
		VG_Text_SetColorBatch( TS_TEXT_SPRINT, 3, 0x80808080 );
		VG_Text_SetColorBatch( TS_TEXT_DUEL, 3, 0x80404040 );
	}
}

CopyBGOffset( index, offset ) {
	new x = index%16;
	new y = index/16;
	if( y >= 10 ) {
		return;
	}
	VG_BG_SetTile( x, y, VG_BG_GetTile( offset+x, y ) );
	if( x == 15 ) {
		VG_BG_SetTile( x+1, y, VG_BG_GetTile( offset+x+1, y ) );
	}
}

Title_CopyBG( index ) {
	CopyBGOffset( index, 53 );
}

//----------------------------------------------------------------------------------------------------------------------
GameLoop_Title() {
	if( title_state == 2 ) {
		if( game_timer == 0 ) {
			sound_bgm = VG_Audio_Play( soundlist[SOUND_BGM_TITLE], 99, _, _, 89.736 );
			VG_SetBlanking( false ); 
		}
		Title_CopyBG(game_timer*3);
		Title_CopyBG(game_timer*3+1);
		Title_CopyBG(game_timer*3+2);
		if( game_timer >= 16*10/3+3) {
			game_timer = 0;
			title_state = 0;
			title_texttimer = 25;
		}
	/*
		new divider = 4;
		if( game_timer < 10*divider ) {
			
			if( (game_timer%divider)==0) {
				new time = game_timer/divider;
				PrintToServer( "%d", time );
				for( new x = 0; x < 17; x++ ) {
					VG_BG_SetTile( x, time, VG_BG_GetTile( 53+x, time ) );
				}
			}
			if( game_timer == 0 ) {
				
				VG_SetBlanking( false );
			}
			
		} else {
			game_timer = 0;
			title_state = 0;
		}*/
	} else {
		if( title_state == 0 ) {
			title_switchtimer++;
			if( title_switchtimer == 300 ) {
				title_switchtimer = 0;
				title_texttimer = 0;
				if( title_switchpos == 0 ) {			
					VG_Text_SetOffsetParam( 0, 0, 0, 0 ); 
					VG_Text_SetOffsetParam( 1, 0, 0, 0 );
				} else if( title_switchpos == 1 || title_switchpos == 3 ) {
					
					VG_Text_SetOffsetParam( 2, 0, 0, 0 );
				}
				title_switchpos = (title_switchpos+1)%4;
				switch( title_switchpos ) {
					case 0: {
						title_desiredscroll = 0;
					} case 1, 3: {
						title_desiredscroll = 18*16;
					} case 2: {
						title_desiredscroll = 36*16;
					}
				}
			}
		
			if( title_switchpos == 0 ) {
				if( title_switchtimer >= 30 ) {
					title_texttimer++;
					if( title_texttimer == 30 ) {
						VG_Text_SetOffsetParam( 0, 0, 0, 2 ); 
					} else if( title_texttimer == 60 ) {
						VG_Text_SetOffsetParam( 0, 0, 0, 0 ); 
						
						title_texttimer = 0;
					}
				}
			} else if( title_switchpos == 1 || title_switchpos == 3 ) {
				if( title_switchtimer == 50 ) {
					VG_Text_SetOffsetParam( 2, 0, 0, 2 );
					
				}
			}
			if( VG_Joypad_Clicks( 1, VG_INPUT_E_INDEX ) ) {
				title_state = 1;
				VG_Text_SetOffsetParam( 0, 0, 0, 0 );
				VG_Text_SetOffsetParam( 1, 0, 0, 2 );
				VG_Text_SetOffsetParam( 2, 0, 0, 0 );
				title_desiredscroll = 0;
				
				VG_Audio_Play( soundlist[SOUND_SELECT] );
			}
		} else if( title_state == 1 ) {
			if( VG_Joypad_Clicks( 1, VG_INPUT_DOWN_INDEX ) && title_select == 0 ) {
				title_select = 1;
				Title_UpdateSelectorPos();
				VG_Audio_Play( soundlist[SOUND_SELECT] );
			} else if( VG_Joypad_Clicks( 1, VG_INPUT_UP_INDEX ) && title_select == 1 ) {
				title_select = 0;
				Title_UpdateSelectorPos();
				VG_Audio_Play( soundlist[SOUND_SELECT] );
			} else if( VG_Joypad_Clicks( 1, VG_INPUT_F_INDEX )  ) {
				title_select = 1-title_select;
				Title_UpdateSelectorPos();
				VG_Audio_Play( soundlist[SOUND_SELECT] );
			}
			if( VG_Joypad_Clicks( 1, VG_INPUT_E_INDEX ) || VG_Joypad_Clicks( 1, VG_INPUT_JUMP_INDEX ) ) {
				game_players = 1+title_select;
				
				
				new chan = VG_Audio_GetChannelFromSoundID( sound_bgm );
				if( chan != 0 ) VG_Audio_StopChannel( chan );
				sound_bgm = 0;
				VG_Audio_Play( soundlist[SOUND_SELECT] );
				SwitchGameState( GS_LOADGAME );
				return;
			} 
		} 
		if( RoundToNearest(title_scroll) != title_desiredscroll ) {
			new Float:movement = (title_desiredscroll-title_scroll)*0.1;
			if( movement < 0.0 ) {
				if( movement > -1.0 ) movement = -1.0;
				title_scroll += movement;
				if( RoundToNearest(title_scroll) <= title_desiredscroll ) title_scroll = float(title_desiredscroll);
			} else {
				if( movement < 1.0 ) movement = 1.0;
				title_scroll += movement;
				if( RoundToNearest(title_scroll) >= title_desiredscroll ) title_scroll = float(title_desiredscroll);
			}
			
			VG_BG_SetScroll( RoundToNearest( title_scroll ) );
		}
		/* DEVELOPMENT VERSION
		if( VG_Joypad_Clicks( 1, VG_INPUT_E_INDEX ) ) {
			game_players = 1;
			SwitchGameState( GS_LOADGAME );
		} else if( VG_Joypad_Clicks( 1, VG_INPUT_F_INDEX ) ) {
			game_players = 2;
			SwitchGameState( GS_LOADGAME );
		}*/
	}
	VG_Joypad_Flush();
	
	game_timer++;
}

//----------------------------------------------------------------------------------------------------------------------
InitState_Ingame() {
	game_gravity = 4;
	
	ingame_fade = 0;
	ingame_ending = false;
	ingame_music_fade = 0;
	priority_hack = 99;
	VG_SetBlanking( true );  
	VG_Sleep( 60 );
	VG_SetBackdrop( 0,0,0 );
	
	
	VG_Text_SetOffsetParam( 0, 0, 0, 1 );  
	VG_Text_SetOffsetParam( 1, 0, 0, 2 ); // 0 = background level, 1 = sprite level
	VG_Text_SetOffsetParam( 2, 0, 0, 3 ); // 2 = clip level
	VG_Text_SetOffsetParam( 3, 0, 0, 0 ); // 3 = disabled
	
	piece_sequence_write = 0;
	for( new player = 0; player < 2; player++ ) {
		player_piece_draw[player] = 0;
		player_state[player] = PS_STARTING; 
		player_timer[player] = 0;
		piece_held[player] = -1;
		player_held_use[player] = false;
		piece_lock_time[player] = 0;
		lines_incoming[player] = 0;
		lines_incoming_index[player] = 0;
		player_throw_time[player] = 0;
	}
		
	piece_sequence_write = 0; 
	sprint_timer = 0;
	sprint_lines_remaining = SPRINT_LINES_TO_WIN;
	
	// erase playfield
	for( new i = 0; i < FIELD_DATAWIDTH*FIELD_DATAHEIGHT; i++ ) {
		tetris_field[0][i] = 0;
		tetris_field[1][i] = 0;
	}
	
	// add border around playfield
	for( new i = 0; i < FIELD_DATAHEIGHT; i++ ) {
		for( new p = 0; p < 2; p++ ) {
			tetris_field[p][FIELD_BASEX-1+i*FIELD_DATAWIDTH] = 1;
			tetris_field[p][FIELD_BASEX+FIELD_WIDTH+i*FIELD_DATAWIDTH] = 1;
		}
	}
	for( new i = 0; i < FIELD_DATAWIDTH; i++ ) {
		for( new p = 0; p < 2; p++ ) {
			tetris_field[p][(FIELD_BASEY+FIELD_HEIGHT)*FIELD_DATAWIDTH+i] = 1;
		}
		
	}
	
	
	//VG_Text_SetOnBatch( IG_TEXT_NEXTPIECE,6, false );
	if( game_players == 1 ) {
		
		field_position[0][0] = 88;
		field_position[0][1] = 0;
		VG_Text_SetPositionGrid( IG_TEXT_PLAYFIELDS, 25, 88, 0, 5, 16, 32 );
		
		// NEXT PIECE POSITION SETUP
//		VG_Text_SetPosition( IG_TEXT_NEXTPIECE, 3, SP_NEXTPIECE_POSITION_X, SP_NEXTPIECE_POSITION_Y, 1, 8, SP_NEXTPIECE_POSITION_VSPACE );
		VG_Text_SetOnBatch( IG_TEXT_PLAYFIELDS, 25, true );
		VG_Text_SetOnBatch( IG_TEXT_PLAYFIELDS+25,25, false );
	//	VG_Text_SetOnBatch( IG_TEXT_NEXTPIECE+0,3, true );
//		VG_Text_SetOnBatch( IG_TEXT_NEXTPIECE+3,3, false );
		VG_Text_SetPositionGrid( IG_TEXT_NEXTPIECE +1, 3,
					178-10 , 
					50,
					1,0,15  );
		VG_Text_SetModelBatch( IG_TEXT_NEXTPIECE, 3, MODEL_32_32 );
		
		VG_Text_SetPosition( IG_TEXT_HOLD, 44, 25-8 );
		VG_Text_SetModel( IG_TEXT_HOLD, MODEL_32_32 );
		
		for( new i = 0; i < 5; i++ ) {
			new pos = (i < 3) ? (i * SP_TIMER_LETTERSPACING) : (i * SP_TIMER_LETTERSPACING + SP_TIMER_MIDDLESPACE);
			VG_Text_SetPosition( IG_TEXT_TIME+i, SP_TIMER_X + pos, SP_TIMER_Y );
		}
		VG_Text_SetPosition( IG_TEXT_TIME+5, SP_TIMER_X+SP_TIMER_DIVIDERPOS, SP_TIMER_Y );
		VG_Text_SetModelBatch( IG_TEXT_TIME, 6, MODEL_32_32 );
		VG_Text_SetOnBatch( IG_TEXT_TIME, 6, true );
		VG_Text_SetFrame( IG_TEXT_TIME+5, GFX_32_COLON );
		
		VG_Text_SetPositionGrid( IG_TEXT_LINES, 2, SP_LINESREMAINING_X, SP_LINESREMAINING_Y, 2, SP_TIMER_LETTERSPACING, 0 );
		VG_Text_SetModelBatch( IG_TEXT_LINES, 2, MODEL_32_32 );
		VG_Text_SetOnBatch( IG_TEXT_LINES, 6, true );
		
		VG_Text_SetPositionGrid( IG_TEXT_CENTERTEXT, 3,
			field_position[0][0] + 40 - 96/2, 
			field_position[0][1] + 32,
			3, 32, 32 );
		
		VG_Text_SetPositionGrid( IG_TEXT_CENTERTEXT+3, 2,
			field_position[0][0] + 40 - 64/2, 
			field_position[0][1] + 72,
			3, 32, 32 );
		
	} else {
		field_position[0][0] = 16;
		field_position[0][1] = 0;
		field_position[1][0] = 160;
		field_position[1][1] = 0;
		VG_Text_SetPositionGrid( IG_TEXT_PLAYFIELDS, 25,   16 ,0,  5, 16, 32 );
		VG_Text_SetPositionGrid( IG_TEXT_PLAYFIELDS+25,25, 160,0, 5, 16, 32 );
		VG_Text_SetPositionGrid( IG_TEXT_NEXTPIECE, 3, 106-10, 21, 1, 0, 15 );
		VG_Text_SetPositionGrid( IG_TEXT_NEXTPIECE+3, 3, 138-10, 21, 1, 0, 15 );
	//	VG_Text_SetPositionGrid( IG_TEXT_NEXTPIECE+3, 3, 160, 20, 1, 8, 16 );
		VG_Text_SetOnBatch( IG_TEXT_PLAYFIELDS, 50, true );
	//	VG_Text_SetOnBatch( IG_TEXT_NEXTPIECE+0,6, true ); 
		VG_Text_SetModelBatch( IG_TEXT_NEXTPIECE, 6, MODEL_32_32 );
		
		VG_Text_SetPosition( IG_TEXT_HOLD, 106-10, 81 ); // todo
		VG_Text_SetPosition( IG_TEXT_HOLD+1, 138-10, 81 );
		VG_Text_SetModelBatch( IG_TEXT_HOLD, 2, MODEL_32_32 );
		
		for( new i = 0; i < 2; i++ ) {
			VG_Text_SetPositionGrid( IG_TEXT_CENTERTEXT+i*3, 3,
				field_position[i][0] + 40 - 96/2, 
				field_position[i][1] + 32,
				3, 32, 32 );
		}
		
	}
	VG_Text_SetOnBatch( IG_TEXT_PIECE, 2, false );
	VG_Text_SetOnBatch( IG_TEXT_GHOST, 2, false );
	VG_Text_SetOnBatch( IG_TEXT_HOLD, 2, false );  
	VG_Text_SetModelBatch( IG_TEXT_PLAYFIELDS, 50, MODEL_BLOCKCELL );
	VG_Text_SetFrameBatch( IG_TEXT_PLAYFIELDS, 50, 0 );   
	 
	
	VG_Text_SetModelBatch( IG_TEXT_LINEEFFECTS, 20*2, MODEL_128_8 );
	VG_Text_SetOnBatch( IG_TEXT_LINEEFFECTS, 20*2, false ); 
	
	VG_Text_SetOffsetBatch( IG_TEXT_LINEEFFECTS, IG_TEXT_TOTAL-IG_TEXT_LINEEFFECTS, 2 );
	VG_Text_SetOffsetBatch( 0, IG_TEXT_LINEEFFECTS, 1 ); 
	
	VG_Text_SetOnBatch( IG_TEXT_CENTERTEXT, 6, false );
	VG_Text_SetModelBatch( IG_TEXT_CENTERTEXT, 6, MODEL_32_32 ); 
	VG_Text_SetOffsetBatch( IG_TEXT_CENTERTEXT, 6, 1 ); 
	
	VG_Text_SetSizeBatch( 0, IG_TEXT_TOTAL, 1 );
	VG_Text_SetColorBatch( 0, IG_TEXT_TOTAL, 0x80808080 );
	if( game_players == 2 ) {
		VG_Text_SetColor( IG_TEXT_NEXTPIECE+1, 0x80505050 );
		VG_Text_SetColor( IG_TEXT_NEXTPIECE+2, 0x80505050 );
		VG_Text_SetColor( IG_TEXT_NEXTPIECE+4, 0x80505050 );
		VG_Text_SetColor( IG_TEXT_NEXTPIECE+5, 0x80505050 );
	}
	//VG_Text_SetSizeBatch( IG_TEXT_LINEEFFECTS, 20*2, 1 );
	
	VG_Text_SetModelBatch( IG_TEXT_PIECE, 2, MODEL_32_32 );
	VG_Text_SetModelBatch( IG_TEXT_GHOST, 2, MODEL_32_32 );
	
	
	
	if( game_players == 1 ) {
		VG_Text_SetPositionGrid( IG_TEXT_LINEEFFECTS, 20 , field_position[0][0],field_position[0][1], 1, 80, 8 );
	} else {
		VG_Text_SetPositionGrid( IG_TEXT_LINEEFFECTS, 20 , field_position[0][0], field_position[0][1], 1, 80, 8 );
		VG_Text_SetPositionGrid( IG_TEXT_LINEEFFECTS+20 , 20 , field_position[1][0], field_position[1][1], 1, 80, 8 );
	}
	 
	for( new i = 0; i < game_players; i++ ) {
		UpdatePlayfield(i);
		UpdateNextPieces(i);
	}
	if( game_players == 1 ) {
		DrawLinesRemaining();
	}
}

//----------------------------------------------------------------------------------------------------------------------
UpdatePlayfield( player, count=25 ) {
	// TODO/optimization: adjust count to update only upper portions of the playfield
	for( new i = 0; i < count; i++ ) {
		new y = i / 5;
		new x = i - y*5;
		new offset = FIELD_BASEX + x * 2 + (FIELD_BASEY+y*4)*FIELD_DATAWIDTH;
		
		new index = 
			(tetris_field[player][offset+0])+
			(tetris_field[player][offset+1]<<1)+
			(tetris_field[player][offset+FIELD_DATAWIDTH]<<2)+
			(tetris_field[player][offset+FIELD_DATAWIDTH+1]<<3)+
			(tetris_field[player][offset+FIELD_DATAWIDTH*2]<<4)+
			(tetris_field[player][offset+FIELD_DATAWIDTH*2+1]<<5)+
			(tetris_field[player][offset+FIELD_DATAWIDTH*3]<<6)+
			(tetris_field[player][offset+FIELD_DATAWIDTH*3+1]<<7);
			
		VG_Text_SetFrame( IG_TEXT_PLAYFIELDS + player*25 + i, index );
	}
}

//----------------------------------------------------------------------------------------------------------------------
DrawGhostPiece( player ) {	
	new piece_form = piece_type[player] * 4 + piece_rotation[player];
	if( player_ghost_position[player] != piece_position[player][0] || player_ghost_rotation[player] != piece_rotation[player] ) {
		player_ghost_position[player] = piece_position[player][0];
		player_ghost_rotation[player] = piece_rotation[player];
		
		new dd = GetDropDistance( player );
		
		player_ghost_top[player] = (PIECE_Y_POSITION + dd);
		VG_Text_SetPosition( 
			IG_TEXT_GHOST+player, 
			field_position[player][0] + (piece_position[player][0])*8, 
			field_position[player][1] + player_ghost_top[player]*8 );
		VG_Text_SetOn( IG_TEXT_GHOST+player, true );
		VG_Text_SetFrame( IG_TEXT_GHOST+player, GFX_32_GHOST + piece_form );
	}
	
	{
		new gy = (player_ghost_top[player] + piece_vmin[piece_form]) * 8; // top of ghost
		new py = (actual_piece_position[player][1]>>8) + piece_vmax[piece_form]*8+8; // bottom of piece
		new distance = gy - py;
		new alpha;
		if( distance <= 0 ) {
			alpha = 0;
		} else if( distance < 24 ) {
			// 1-24
			alpha = ((128* distance) / 24);
		} else {
			alpha = 128;
		}
		VG_Text_SetColor( IG_TEXT_GHOST+player, 0x808080 | (alpha<<24) );
	}
}

//----------------------------------------------------------------------------------------------------------------------
DrawPiece( player ) {
	
	if( player_state[player] == PS_CONTROL || player_state[player] == PS_DROPPING ) {
		new index = IG_TEXT_PIECE+player;
		VG_Text_SetPosition( index, field_position[player][0] + ((actual_piece_position[player][0]+128)>>8), field_position[player][1] + ((actual_piece_position[player][1]+128)>>8) );
		VG_Text_SetFrame( index,GFX_32_TETRIMINOES+  piece_type[player] * 4 + piece_rotation[player] );
		VG_Text_SetOn( index, true );
		
		DrawGhostPiece( player );
		
	} else {
		VG_Text_SetOn( IG_TEXT_PIECE+player, false );
		VG_Text_SetOn( IG_TEXT_GHOST+player, false );
	}
}

//----------------------------------------------------------------------------------------------------------------------
UpdateNextPieces(player) {
	if( game_players == 1 ) {
		for( new i = 0; i < 4; i++ )  {
			new piece = GetNextPiece(player,i,true);
			if( i == 0 ) {
				VG_Text_SetPosition( IG_TEXT_NEXTPIECE +i, 
					180 + piece_center_offset[piece], 
					25-8  + piece_center_vert[piece] );
				VG_Text_SetFrame( IG_TEXT_NEXTPIECE+ i, GFX_32_TETRIMINOES+piece*4 );
			} else {
				
				VG_Text_SetFrame( IG_TEXT_NEXTPIECE+ i, GFX_32_TETRIMINOES_SMALL+piece  );
			}	
			
		}
		VG_Text_SetOnBatch( IG_TEXT_NEXTPIECE, 4, true );
	} else {
		for( new i = 0; i < 3; i++ )  {
			VG_Text_SetFrame( IG_TEXT_NEXTPIECE + player*3+i, 
				GFX_32_TETRIMINOES_SMALL+GetNextPiece(player,i,true) ); 
		}
		VG_Text_SetOnBatch( IG_TEXT_NEXTPIECE+player*3, 3, true );
	}
}

//----------------------------------------------------------------------------------------------------------------------
SpawnNextPiece( player ) {
	SpawnPiece( player, GetNextPiece( player ) );
	UpdateNextPieces(player);
}

//----------------------------------------------------------------------------------------------------------------------
SpawnPiece( player, type ) {
	player_ghost_position[player] = -1;
	piece_type[player] = type;
	piece_rotation[player] = 0;
	piece_position[player][0] = 3;
	piece_position[player][1] = -1*256+50;
	actual_piece_position[player][0] = piece_position[player][0] * 8*256;
	actual_piece_position[player][1] = piece_position[player][1] * 8;
	
	// if player is holding a key, throw the piece immediately!
	if( VG_Joypad_Held( player+1, VG_INPUT_LEFT ) ) {
		player_throw_time[player] = game_time - THROW_TIME;
		player_throw_dir[player] = -1;
	} else if( VG_Joypad_Held( player+1, VG_INPUT_RIGHT ) ) {
		player_throw_time[player] = game_time - THROW_TIME;
		player_throw_dir[player] = 1;
	}
	
}

//----------------------------------------------------------------------------------------------------------------------
bool:PieceCollision( player, offsetx=0,offsety=0 ) {
	return PieceCollisionEx( player, piece_type[player], piece_rotation[player], piece_position[player][0]+offsetx, ((piece_position[player][1]+255+offsety)>>8) );
}

//----------------------------------------------------------------------------------------------------------------------
bool:PieceCollisionEx( player, type, rot, px, py ) {
	new field_offset = FIELD_BASEX + px + (FIELD_BASEY + py)*FIELD_DATAWIDTH;
	new form_offset = rot*4;
	new form_slice = type*(4);
	
	for( new y = 0; y < 4; y++ ) {
		for( new x = 0; x < 4; x++ ) {
			if( piece_forms[form_slice+y][form_offset+x] == FORM_EMPTY ) continue;
			if( tetris_field[player][field_offset+x+y*FIELD_DATAWIDTH ] ) {
				// a collision occurred.
				
				// <user feedback>
				
				return true;
			}
		}
	}
	return false;
}

//----------------------------------------------------------------------------------------------------------------------
SlidePiece( player, direction ) {
	if( direction == 0 ) return;
	// direction must be -1 or +1
	  
	if( PieceCollision( player, direction ) ) {
	
		// <user feedback>
		//VG_Audio_Play( soundlist[SOUND_WALL] );
		
		return;
	} 
	
	piece_position[player][0] += direction;
}

//----------------------------------------------------------------------------------------------------------------------
ThrowPiece( player, direction ) {
	if( direction == 0 ) return;
	// direction must be -1 or +1
	
	// collision test:
	
	new field_offset = FIELD_BASEX + piece_position[player][0] + (FIELD_BASEY + PIECE_Y_POSITION)*FIELD_DATAWIDTH;
	new form_offset = piece_rotation[player]*4;
	new form_slice = piece_type[player]*(4);
	
	new shortest_stride = FIELD_WIDTH;
	for( new y = 0; y < 4; y++ ) {
		for( new x = 0; x < 4; x++ ) {
			if( piece_forms[form_slice+y][form_offset+x] == FORM_EMPTY ) continue;
			
			// get stride length
			new offset2 = field_offset+x+y*FIELD_DATAWIDTH;
			offset2 += direction;
			new stride = 0;
			while( !tetris_field[player][offset2] ) {
				stride++;
				offset2 += direction;
			}
			
			if( stride == 0 ) {
				// piece is touching something already
				
				// <user feedback>
				
				return;
			}
			
			if( stride < shortest_stride ) {
				shortest_stride = stride;
			}
		}
	}
	if( shortest_stride > 0 && shortest_stride <= 3 ) {
		VG_Audio_Play( soundlist[SOUND_WALL] );
	}
	if( shortest_stride > 3 ) shortest_stride = 3;
	if( direction < 0 ) {
		piece_position[player][0] -= shortest_stride;
	} else {
		piece_position[player][0] += shortest_stride;
	}
}

//----------------------------------------------------------------------------------------------------------------------
GetDropDistance( player ) {
	new field_offset = FIELD_BASEX + piece_position[player][0] + (FIELD_BASEY + PIECE_Y_POSITION)*FIELD_DATAWIDTH;
	new form_offset = piece_rotation[player]*4;
	new form_slice = piece_type[player]*(4);
	
	new shortest_stride = FIELD_HEIGHT;
	for( new x = 0; x < 4; x++ ) {
		for( new y = 3; y >= 0; y-- ) {
			if( piece_forms[form_slice+y][form_offset+x] == FORM_EMPTY ) continue;
			
			// get stride length
			new offset2 = field_offset+x+y*FIELD_DATAWIDTH;
			offset2 += FIELD_DATAWIDTH;
			new stride = 0;
			while( !tetris_field[player][offset2] ) {
				stride++;
				offset2 += FIELD_DATAWIDTH;
			}
			
			if( stride < shortest_stride ) {
				shortest_stride = stride;
				if( stride == 0 ) break;
			}
			break;
		}
	}
	return shortest_stride;
}

//----------------------------------------------------------------------------------------------------------------------
DropPiece( player ) {
	player_state[player] = PS_DROPPING;
	player_timer[player] = 0;
	
	new dd = GetDropDistance(player);
	
	piece_position[player][1] = (PIECE_Y_POSITION + dd) << 8;

}

//----------------------------------------------------------------------------------------------------------------------
RotatePiece( player, direction ) {
	new newrot = (piece_rotation[player] + direction) & 3;
	
	new piece_x = piece_position[player][0];
	new piece_y = PIECE_Y_POSITION;
	
	if( PieceCollisionEx( player, piece_type[player], newrot, piece_x, piece_y ) ) {
	
		// collision with side: try to nudge left or right
		if( !PieceCollisionEx( player, piece_type[player], newrot, piece_x-1, piece_y ) ) {
			piece_position[player][0]--;
		} else if( !PieceCollisionEx( player, piece_type[player], newrot, piece_x+1, piece_y ) ) {
			piece_position[player][0]++;
		} else {
			
			// nowhere to rotate
			return; 
		}
	}
	VG_Audio_Play( soundlist[SOUND_FLIP] );
	piece_rotation[player] = newrot;
}

//----------------------------------------------------------------------------------------------------------------------
CheckLinesCleared(player) {
	new base = FIELD_BASEX + (FIELD_BASEY + PIECE_Y_POSITION)*FIELD_DATAWIDTH;
	new basey = PIECE_Y_POSITION;
	new cleared = 0;
	
	new form_offset = piece_rotation[player]*4;
	new form_slice = piece_type[player]*(4);
 
	for( new i = 0; i < 20; i++ ) {
		lines_cleared[player][i] = false;
	}
	
	for( new y = 0; y < 4; y++,base += FIELD_DATAWIDTH ) {
		
		// skip if current piece did not add any blocks to this line
		new bool:lineused=false;
		for( new x = 0; x < 4; x++ ) {
			if( piece_forms[form_slice+y][form_offset+x] != FORM_EMPTY ) {
				lineused=true;
				break;
			}
		}
		if( !lineused ) {
			continue;
		}
		new bool:completed=true;
		for( new x = 0; x < FIELD_WIDTH; x++ ) {
			if( !tetris_field[player][base + x] ) {
				completed = false;
				break;
			}
		}
		
		lines_cleared[player][basey+y] = completed;
		if( completed ) cleared++;
	}
	if( cleared ) {
		// for each cleared line ,reset the timer
		// offset it from bottom to top so the upper lines get cleared later
		// so the animation looks like this:
		
		// >>>>>>
		//   >>>>>>
		//     >>>>>>
		//       >>>>
		new timer = 0;
		//line_clear_bottom[player] = 0;
		
		for( new i = FIELD_HEIGHT-1; i >= 0; i-- ) {
			if( lines_cleared[player][i] ) {
				line_clear_timers[player][i] = timer;
				timer -= 5;
				//if( !line_clear_bottom[player] ) line_clear_bottom[player] = i;
				
			}
		}
		lines_cleared_count[player] = cleared;
	}
	return cleared;
}

//----------------------------------------------------------------------------------------------------------------------
bool:BakePieceEx( player, type, rot, px, py ) {
	new field_offset = FIELD_BASEX + px + (FIELD_BASEY + py)*FIELD_DATAWIDTH;
	new form_offset = rot*4;
	new form_slice = type*4;
	
	new bool:toppedout = false;
	for( new y = 0; y < 4; y++ ) {
		for( new x = 0; x < 4; x++ ) {
			if( piece_forms[form_slice+y][form_offset+x] == FORM_EMPTY ) continue;
			if( py+y == 0 ) toppedout=true;
			tetris_field[player][field_offset+x+y*FIELD_DATAWIDTH ] = 1;
		}
	}
	return toppedout;
}

//----------------------------------------------------------------------------------------------------------------------
bool:BakePiece( player ) {
	return BakePieceEx( player, piece_type[player], piece_rotation[player], piece_position[player][0], PIECE_Y_POSITION );
}	

//----------------------------------------------------------------------------------------------------------------------
UpdateActualPiecePosition(player, xspeed=12, yspeed=10) {
	// function to slide actual/visible position towards internal position
	new desired_x = (piece_position[player][0]<<11);
	new diff = desired_x - actual_piece_position[player][0];
	if( diff != 0 ) {
		if( Abs( diff ) < 300  ) {
			actual_piece_position[player][0] = desired_x;
		} else {
			actual_piece_position[player][0] = (actual_piece_position[player][0]*(16-xspeed) + desired_x*xspeed) >> 4;
		}
			
	}
	new desired_y = (piece_position[player][1]<<3);
	diff = desired_y - actual_piece_position[player][1];
	if( diff != 0 ) {
		if( Abs( diff) < 300  ) {
			actual_piece_position[player][1] = desired_y;
		} else {
			actual_piece_position[player][1] = (actual_piece_position[player][1]*(16-yspeed) + desired_y*yspeed) >> 4;
		}
	}
	DrawPiece(player);
	
	
}

//----------------------------------------------------------------------------------------------------------------------
StartClearing(player) {
	new count = lines_cleared_count[player];
	lines_incoming[player] -= count;
	if( lines_incoming[player] < 0 ) {
		lines_incoming[1-player] -= lines_incoming[player];
		lines_incoming[player] = 0;
	}
	
	//lines_incoming[1-player] += lines_cleared_count[player];
	//lines_incoming[player] -= lines_cleared_count[player];
	//if( lines_incoming[player] < 0 ) lines_incoming[player] = 0;
	
	if( game_players == 1) {
		// 1p/sprint
		sprint_lines_remaining -= lines_cleared_count[player];
		if( sprint_lines_remaining <= 0 ) {
			sprint_lines_remaining = 0;
			player_state[player] = PS_WINNING;
			player_timer[player] = 0;
			//VG_Audio_Play( soundlist[SOUND_END] );
			ingame_ending = true;
			decl String:name[128];
			new client = VG_GetGameClient(player+1);
			if( client == 0 ) {
				name = "???";
			} else {
				GetClientName( client, name, sizeof name );
			}
			sprint_record = RecordScore( name, sprint_timer );
			return;
			
		}
	}
	
	player_state[player] = PS_CLEARING;
	player_timer[player] = 0;
}

//----------------------------------------------------------------------------------------------------------------------
UpdateHeldPiece( player ) {
	// this is only called after a piece is held, the held piece is initialized to OFF
	// and turned on when this function is used and is left on for the duration of the match
	new piece = piece_held[player]; 
	if( game_players == 1 ) { 
		VG_Text_SetFrame( IG_TEXT_HOLD,GFX_32_TETRIMINOES+ piece*4 ); 
		VG_Text_SetOn( IG_TEXT_HOLD, true ); 
		VG_Text_SetPosition( IG_TEXT_HOLD, 
			44 + piece_center_offset[piece], 
			25-8 + piece_center_vert[piece] );
	} else {
		VG_Text_SetFrame( IG_TEXT_HOLD + player , GFX_32_TETRIMINOES_SMALL+piece ); 
		VG_Text_SetOn( IG_TEXT_HOLD + player, true ); 

	}
	
}

//----------------------------------------------------------------------------------------------------------------------
bool:TryHoldPiece( player ) {	
	if( player_held_use[player] ) return false;
	player_held_use[player] = true;
	if( piece_held[player] != -1 ) {
		new current = piece_type[player];
		SpawnPiece( player, piece_held[player] );
		piece_held[player] = current;
	} else {
		piece_held[player] = piece_type[player];
		SpawnNextPiece(player);
	}
	UpdateHeldPiece(player);
	return true;
}

//----------------------------------------------------------------------------------------------------------------------
PP_Control( player ) {
	new gravity = game_gravity;
	if( VG_Joypad_Clicks( player+1, VG_INPUT_E_INDEX ) ) {
		if( TryHoldPiece( player ) ) {
			return;
		}
	}
	if( VG_Joypad_Held( player+1, VG_INPUT_DOWN ) ) {
		gravity = FORCE_GRAVITY;
	} else if( VG_Joypad_Clicks( player+1, VG_INPUT_UP_INDEX ) ) {
		
		DropPiece( player );
		return;
	}
	
	piece_position[player][1] += gravity;
	if( PieceCollision( player, 0,1 ) ) {
		piece_position[player][1] &= ~0xFF; // fixed point truncate
		piece_lock_time[player]++;
	} else {
		piece_lock_time[player] = 0;
	}
	
	if( piece_lock_time[player] >= (VG_Joypad_Held( player+1, VG_INPUT_DOWN ) ? LOCK_TIME_HELD : LOCK_TIME) ) {
		// LOCK PIECE
		piece_lock_time[player] = 0;
		StartLock( player, 0 );
		return;
	}
	
	if( VG_Joypad_Clicks( player+1, VG_INPUT_LEFT_INDEX ) ) {
		SlidePiece(player,-1);
		player_throw_dir[player] = -1;
		player_throw_time[player] = game_time; 
	} else if( VG_Joypad_Clicks( player+1, VG_INPUT_RIGHT_INDEX ) ) {
		SlidePiece(player,1);
		player_throw_dir[player] = 1;
		player_throw_time[player] = game_time;
	}
	

	
	new throw_key = player_throw_dir[player] == 1 ? VG_INPUT_RIGHT : VG_INPUT_LEFT;
	
	if( !VG_Joypad_Held( player+1, throw_key ) ) {
		player_throw_time[player] = game_time;
	} else {
		if( game_time >= player_throw_time[player] + THROW_TIME ) {
			ThrowPiece( player, player_throw_dir[player] );
		}
	}
	
	
	if( VG_Joypad_Clicks( player+1, VG_INPUT_JUMP_INDEX ) || VG_Joypad_Clicks( player+1, VG_INPUT_R_INDEX ) ) {
		RotatePiece( player, 1 );
	} else if( VG_Joypad_Clicks( player+1, VG_INPUT_F_INDEX ) || VG_Joypad_Clicks( player+1, VG_INPUT_SHIFT_INDEX ) ) {
		RotatePiece( player, -1 );
	}
	
	UpdateActualPiecePosition( player );
}

//----------------------------------------------------------------------------------------------------------------------
ShiftField( player, position ) {
	new base = (FIELD_BASEY+position) * FIELD_DATAWIDTH + FIELD_BASEX;
	for( new y = position; y >= 0; y-- ) {
		for( new x = 0; x < FIELD_WIDTH; x++ ) {
			
			tetris_field[player][base+x] = tetris_field[player][base+x-FIELD_DATAWIDTH];
		}
		base -= FIELD_DATAWIDTH;
	}
}
/*
//----------------------------------------------------------------------------------------------------------------------
ShiftField2( player, position, column ) {
	new base = (FIELD_BASEY+position) * FIELD_DATAWIDTH + FIELD_BASEX + column;
	for( new y = position; y >= 0; y-- ) {	
		tetris_field[player][base] = tetris_field[player][base-FIELD_DATAWIDTH];
		base -= FIELD_DATAWIDTH;
	}
}*/
 

//----------------------------------------------------------------------------------------------------------------------
PP_Starting(player) {
	
	new index = IG_TEXT_CENTERTEXT+player*3+1;
	const offset = -30;
	new gfx = game_players == 2 ? GFX_32_COUNTDOWN2 : GFX_32_COUNTDOWN;
	if( player_timer[player] == 60+offset ) {
	
		//VG_Text_SetPosition( index, field_position[player][0] + 10*8/2-16, field_position[player][1] + 16 );
		VG_Text_SetFrame( index, gfx );
		VG_Text_SetOn( index, true );  
		if( player == 0 ) VG_Audio_Play( soundlist[SOUND_COUNTDOWN] );
	} else if( player_timer[player] == 120+offset ) {
		
		VG_Text_SetFrame( index, gfx+1 );
		if( player == 0 ) VG_Audio_Play( soundlist[SOUND_COUNTDOWN] );
	} else if( player_timer[player] == 180+offset ) {
		VG_Text_SetFrame( index, gfx+2 );
		if( player == 0 ) VG_Audio_Play( soundlist[SOUND_COUNTDOWN] );
	} else if( player_timer[player] == 240+offset ) {
		//VG_Text_SetOffset( index, 3 );
		VG_Text_SetOn( index, false );
		
		player_state[player] = PS_CONTROL;
		player_timer[player] = 0;
		SpawnNextPiece(player);
		return;
	}
	
	player_timer[player]++;
}

//----------------------------------------------------------------------------------------------------------------------
PP_Clearing(player) {
	
	//player_timer[player]++;
	//if(( player_timer[player] % 2 ) != 0 ) return;
	//new t = player_timer[player]++;
	new lowest_timer = 99;
	new bool:changes = false;
	for( new line = 0; line < 20; line++ ) {
		if( lines_cleared[player][line] ) {
			new time = line_clear_timers[player][line];
			new base = IG_TEXT_LINEEFFECTS+player*20+line;
			if( time >= 0 && time < 20 ) {
				VG_Text_SetFrame( base, GFX_LINES+time );
				VG_Text_SetOn( base, true );
			} else {
				VG_Text_SetOn( base, false );
			}
			if( time <  lowest_timer ) lowest_timer = time;
			new clear_block = time-6;
			if( clear_block >= 0 && clear_block < 10 ) {
				tetris_field[player][FIELD_BASEX+clear_block+(FIELD_BASEY+line)*FIELD_DATAWIDTH] = 0;
				changes = true;
			}
			if( line_clear_timers[player][line] == 0 ) {
				
				VG_Audio_Play( soundlist[SOUND_CLEAR] );
			}
			line_clear_timers[player][line]++;
			
		}
	}
	
	if( lowest_timer >= 20 ) {
		new bool:finished = true;
		for( new line = 0; line < 20; line++ ) {
			
			if( lines_cleared[player][line] ) {
				ShiftField( player, line );
				lines_cleared[player][line] = false;
				finished=false;
				break;
			}
		}
		
		if( finished ) {
			player_state[player] = PS_LOCKED;
			player_timer[player] = LOCK_DELAY_NEXT;
		} else {
			changes = true;
		}
	}
	/*
	new shift_block = lowest_timer-12;
	if( shift_block >= 0 && shift_block < 10 ) {
		
		changes = true;
		// TODO: OPTIMIZE, only one column is changed, this update passes over everything
	}
	if( lowest_timer == 24 ) {
		player_state[player] = PS_LOCKED;
		player_timer[player] = LOCK_DELAY_NEXT;
	}*/
	
	if( changes ) {
		UpdatePlayfield( player ); 
	}
	/*
	if( t == 4 ) {
		
		
	} else {
		
		if( lines_cleared[player][t] ) {
			new piece_y = PIECE_Y_POSITION;
			ShiftField( player, piece_y + t );
			UpdatePlayfield(player);
		
		}
	}
	
	*/
	
}

StartLose( player ) {
	player_state[player] = PS_LOSE;
	player_timer[player] = 0;
	if( game_players == 2 ) {
		new player2 = 1-player;
		player_state[player2] = PS_WINNING;
		player_timer[player2] = 0;
		DrawPiece(player2);
	}
	ingame_ending = true;
}

StartLock( player, delay=0 ) {
	new bool:toppedout = BakePiece( player );
	UpdatePlayfield(player);
	
	if( toppedout ) {
		StartLose(player);
		
		//VG_Audio_Play( soundlist[SOUND_END] );
	} else {
		VG_Audio_Play( soundlist[SOUND_LOCK] );
		if( CheckLinesCleared(player) ) {
			StartClearing(player);
			
		} else {
			player_state[player] = PS_LOCKED;
			player_timer[player] = delay;
		}
	}
	DrawPiece(player);
}

//----------------------------------------------------------------------------------------------------------------------
PP_Dropping(player) {

	UpdateActualPiecePosition( player, _, 8 ); // slow/more animated drop
	
	player_timer[player]++;
	if( player_timer[player] >= DROP_DELAY_NEXT ) {
		
		StartLock( player, LOCK_DELAY_NEXT );
		return;
	}
}

//----------------------------------------------------------------------------------------------------------------------
AddIncomingLine(player) {
	lines_incoming[player]--;
	
	new base = FIELD_BASEX+FIELD_BASEY*FIELD_DATAWIDTH;
	for( new y = 0; y < FIELD_HEIGHT-1; y++ ) {
		for( new x = 0; x < FIELD_WIDTH; x++ ) {
			tetris_field[player][base+x] = tetris_field[player][base+x+FIELD_DATAWIDTH];
		}
		base += FIELD_DATAWIDTH;
	}
	
	for( new x = 0; x < FIELD_WIDTH; x++ ) {
		tetris_field[player][base+x] = 1;
	}
	tetris_field[player][base+lines_incoming_index[player]] = 0;
	lines_incoming_index[player]++;
	if( lines_incoming_index[player] >= FIELD_WIDTH ) lines_incoming_index[player] = 0;
	UpdatePlayfield( player );
	
	VG_Audio_Play( soundlist[SOUND_LOCK], _, 150, 0.5 );
}

//----------------------------------------------------------------------------------------------------------------------
PP_Locked(player) {
	player_timer[player]++;
	if( lines_incoming[player] ) {
		if( (player_timer[player] % 3) == 2 ) { // frame divider
			AddIncomingLine(player);
		}
		return;
	}
	
	if( player_timer[player] >= LOCK_DELAY_NEXT ) {
		player_held_use[player] = false;
		
		
		for( new i = 3; i <= 6; i++ ) {
			if( tetris_field[player][FIELD_BASEX+i+FIELD_BASEY*FIELD_DATAWIDTH] ) {
				StartLose(player);
				return;
			}
		}
	
		SpawnNextPiece( player );
		//SpawnPiece(player, GetRandomInt(0,PIECE_TOTAL-1) );
		player_state[player] = PS_CONTROL;
		
	}
}

//----------------------------------------------------------------------------------------------------------------------
DoFieldClear( player ) {
	
	if( player_timer[player] < 60 ) {
		new bool:changes = false;
		for( new line = 0; line < FIELD_HEIGHT; line++ ) {
			
			new time = player_timer[player] - (line) - (line&1)*4;
			
			new base =  IG_TEXT_LINEEFFECTS+line+player*20;
			if( time >= 0 && time < 20 ) {
				VG_Text_SetFrame(base, GFX_LINES+time );
				VG_Text_SetOn( base, true );
			} else {
				VG_Text_SetOn( base, false );
			}
			new clear_block = time-6;
			if( clear_block >= 0 && clear_block < 10 ) {
				tetris_field[player][FIELD_BASEX+clear_block+(FIELD_BASEY+line)*FIELD_DATAWIDTH] = 0;
				changes = true;
			}
		}
		if( changes ) {
			UpdatePlayfield( player ); 
		}
	}
	if( player == 0 && player_timer[player] < 40 ) {
		if( (player_timer[player] % 4) == 0 ) {
			VG_Audio_Play( soundlist[SOUND_CLEAR],_,130 );
		}
	}
}

//----------------------------------------------------------------------------------------------------------------------
EndGame() {
	VG_Audio_Panic();
	player_state[0] = PS_NULL;
	player_state[1] = PS_NULL;
	VG_Text_SetOnBatch( 0 , IG_TEXT_TOTAL, false );
	VG_Sprites_DeleteAll();
	SwitchGameState( GS_STARTUP );
}

//----------------------------------------------------------------------------------------------------------------------
PP_Losing(player) {
	DoFieldClear( player );
	if( player_timer[player] == 30 ) {
		new index = IG_TEXT_CENTERTEXT+player*3;
		new source = game_players == 1 ? GFX_32_FAIL : GFX_32_LOSER;
 
		for( new i = 0; i < 3; i++ )
			VG_Text_SetFrame( index+i, source+i );  
			 
		VG_Text_SetOnBatch( index, 3, true ); 
	}
	if( player_timer[player] >= 80 ) {
		if( VG_Joypad_Clicks(player+1, VG_INPUT_JUMP_INDEX) || VG_Joypad_Clicks(player+1, VG_INPUT_E_INDEX) ) {
			
			EndGame();
			return;
		}
	}
	player_timer[player]++;
}

//----------------------------------------------------------------------------------------------------------------------
PP_Winning(player) {
	DoFieldClear( player );
	 
	new labeltime = sprint_record ? 180 : 120;
	if( player_timer[player] == 30 ) {
		new index = IG_TEXT_CENTERTEXT+player*3;
		if(game_players == 1 ) {
			
		//		VG_Text_SetPosition( index, field_position[player][0] + 10*8/2-32, field_position[player][1] + 32 );
		//		VG_Text_SetPosition( index+1, field_position[player][0] + 10*8/2, field_position[player][1] + 32 );
			for( new i = 0; i < 3; i++ ) 
				VG_Text_SetFrame( index+i, GFX_32_CLEAR+i );
			VG_Text_SetOnBatch( index, 3, true ); 
			
		} else {
			
			for( new i = 0; i < 3; i++ ) 
				VG_Text_SetFrame( index+i, GFX_32_WINNER+i );
			VG_Text_SetOnBatch( index, 3, true ); 
				
		}
	} else if( player_timer[player] == labeltime ) {
		if(game_players == 1 ) {
			
			new index = IG_TEXT_CENTERTEXT+3;
		//	VG_Text_SetPosition( index, field_position[player][0] + 10*8/2-32, field_position[player][1] + 104 );
		//	VG_Text_SetPosition( index+1, field_position[player][0] + 10*8/2, field_position[player][1] + 104 );
			
			if( sprint_record ) {
				for( new i = 0; i < 2; i++ ) 
					VG_Text_SetFrame( index+i, GFX_32_NEWRECORD+i );
				VG_Audio_Play( soundlist[SOUND_HIGHSCORE] );
				
			} else {
				for( new i = 0; i < 2; i++ ) 
					VG_Text_SetFrame( index+i, GFX_32_TRYAGAIN+i );
			}
			VG_Text_SetOnBatch( index, 2, true );  
		}
	}
	if( player_timer[player] >= labeltime && game_players == 1 ) {
		
		new t = (player_timer[player] - labeltime )%60 ;
		if( t == 0 ){ 
			VG_Text_SetOnBatch( IG_TEXT_TIME, 6, false );
		} else if( t == 30 ) {
			VG_Text_SetOnBatch( IG_TEXT_TIME, 6, true );
		}
		
		if( sprint_record ) {
			// flash the text on new record
			t = (player_timer[player] - labeltime ) ;
			new a = 0x70 + RoundToNearest(Sine(float(t)/2.0)*16.0);
			a = a|(a<<8)|(a<<16)|0x80000000;
			VG_Text_SetColorBatch( IG_TEXT_CENTERTEXT+3, 2, a );
		}
		/*if( t == 0 ){ 
			VG_Text_SetColorBatch( IG_TEXT_CENTERTEXT+3, 2, 0x80808080 );
		} else if( t == 10 ) {
			VG_Text_SetColorBatch( IG_TEXT_CENTERTEXT+3, 2, 0x80606060 );
		}*/
		
		if( player_timer[player] >= labeltime + 60 && (VG_Joypad_Clicks(player+1, VG_INPUT_JUMP_INDEX) || VG_Joypad_Clicks(player+1, VG_INPUT_E_INDEX)) ) {
			EndGame();
			return;
		}
	} else if( player_timer[player] >= 80 && game_players == 2 ) {
		if( VG_Joypad_Clicks(player+1, VG_INPUT_JUMP_INDEX) || VG_Joypad_Clicks(player+1, VG_INPUT_E_INDEX) ) {
			EndGame();
			return;
		}
	}
	player_timer[player]++;
}
/*
//----------------------------------------------------------------------------------------------------------------------
PP_SprintCleared(player) {
	if( player_timer[player] == 60 ) {
		
	} else if( player_timer[player] >= 90 ) {
		
	}
	player_timer[player]++;
	
}*/
 

//----------------------------------------------------------------------------------------------------------------------
ProcessPlayer( player ) {
	
	switch( player_state[player] ) {
		case PS_STARTING: PP_Starting(player);
		case PS_CONTROL: PP_Control(player);
		case PS_DROPPING: PP_Dropping(player);
		case PS_LOCKED: PP_Locked(player);
		case PS_CLEARING: PP_Clearing(player);
		case PS_LOSE: PP_Losing(player);
		case PS_WINNING: PP_Winning(player);
		//case PS_SPRINTCLEARED: PP_SprintCleared(player);
	}
	
}

PlayIngameMusic() {
	if( game_players == 1 ) {
		sound_bgm = VG_Audio_Play( soundlist[SOUND_BGM_SPRINT], priority_hack--, _, _, 75.212 );
	} else {
		sound_bgm = VG_Audio_Play( soundlist[SOUND_BGM_DUEL], priority_hack--, _, _, 46.138 );
	}
}

CheckIngameBGMLoop() {
	new chan = VG_Audio_GetChannelFromSoundID( sound_bgm );
	if( chan == 0 ) {
		PlayIngameMusic();
		return;
	}
	if( VG_Audio_GetTimeout(chan) <= 1.0 ) {
		PlayIngameMusic();
		return;
	}
}

//----------------------------------------------------------------------------------------------------------------------
GameLoop_Ingame() {
	
	if( ingame_fade < 16*10/3+3 ) {
		if( ingame_fade == 0 ) {
			VG_SetBlanking( false );
			PlayIngameMusic();
		}
		new offset = game_players == 1 ? 17 : 34;
		CopyBGOffset( ingame_fade*3+0, offset );
		CopyBGOffset( ingame_fade*3+1, offset );
		CopyBGOffset( ingame_fade*3+2, offset );
		ingame_fade++;
	}
	
	if( ingame_ending ) {
		if( sound_bgm != 0 ) {
			new chan = VG_Audio_GetChannelFromSoundID( sound_bgm );
			if( chan != 0 ) {
				ingame_music_fade++;
				new Float:vol = 1.0 - (float(ingame_music_fade) / 120.0);
				if( vol <= 0.0 ) {
					VG_Audio_StopChannel( chan );
					sound_bgm = 0;
				} else {
					VG_Audio_SetChannelVolume( chan, vol );
				}
				
			}
		}
	} else {
		if(game_players==2)CheckIngameBGMLoop();
	}
	
	for( new i = 0; i < game_players; i++ ) 
		ProcessPlayer( i );
	
	if( game_players == 1 ) {
		if( player_state[0] == PS_CONTROL || 
			player_state[0] == PS_DROPPING || 
			player_state[0] == PS_LOCKED ||
			player_state[0] == PS_CLEARING ) {
			
			sprint_timer++;
		}
		
		
		DrawSprintTimer();
		DrawLinesRemaining();
	}
	 
	VG_Joypad_Flush();
}

//----------------------------------------------------------------------------------------------------------------------
DrawLinesRemaining() {
	VG_Text_SetFrame( IG_TEXT_LINES, GFX_32_NUMBERS + sprint_lines_remaining/10 );
	VG_Text_SetFrame( IG_TEXT_LINES+1, GFX_32_NUMBERS + sprint_lines_remaining%10 );
}

//----------------------------------------------------------------------------------------------------------------------
DrawSprintTimer() {
	new digits[5];
	new time = sprint_timer;
	if(time > 999*60+59) time = 999*60+59;
	digits[0] = time / ( 6000 );
	digits[1] = (time / ( 600 )) % 10;
	digits[2] = (time / ( 60 )) % 10;
	digits[3] = (time / ( 10 )) % 6;
	digits[4] = (time % 10);
	
	for( new i = 0; i < 5; i++ ) {
		VG_Text_SetFrame( IG_TEXT_TIME+i, GFX_32_NUMBERS + digits[i] );
	}
}

//----------------------------------------------------------------------------------------------------------------------
AddBagToSequence() {
	if( piece_sequence_write >= sizeof( piece_sequence ) ) return; // full sequence has been generated
	// fisher-yates shuffle
	new pieces[] = {0,1,2,3,4,5,6};
	
	for( new i = sizeof pieces - 1; i >= 1; i-- ) {
		new j = GetRandomInt( 0, i );
		new a = pieces[i];
		pieces[i] = pieces[j];
		pieces[j] = a;
	}
	
	// add this new bag of pieces to the sequence
	for( new i = 0; i < sizeof pieces; i++ ) {
		piece_sequence[piece_sequence_write++] = pieces[i];
		if( piece_sequence_write >= sizeof( piece_sequence ) ) {
			return;
		}
	}
}

//----------------------------------------------------------------------------------------------------------------------
GetNextPiece( player, offset=0, bool:peek=false ) {

	// get a piece from the piece sequence
	new position = player_piece_draw[player] + offset;
	if( position >= sizeof( piece_sequence ) ) position -= sizeof( piece_sequence );
	
	while( position >= piece_sequence_write ) {
		AddBagToSequence();
	}
	
	new piece = piece_sequence[position];
	if( !peek )  {
		player_piece_draw[player]++;
		if( player_piece_draw[player] >= sizeof( piece_sequence ) ) {
			player_piece_draw[player] -= sizeof( piece_sequence );
		}
	}
	return piece;
}
