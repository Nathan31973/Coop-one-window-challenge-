#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\custom\shootable;
#using scripts\zm\_zm_score;


// easter egg song
#using scripts\zm\_zm_easteregg_song;

//arnie fix
#using scripts\zm\TempArnieFix;

// NSZ Buyable Ending
#using scripts\_NSZ\nsz_buyable_ending;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_vulture_aid;
#using scripts\zm\_zm_perk_whoswho;
#using scripts\zm\_zm_perk_tombstone;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_wunderfizz;


//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

// NSZ Zombie Blood Powerup
#using scripts\_NSZ\nsz_powerup_zombie_blood;



//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{

	zm_usermap::main();

	callback::on_spawned( &bo2_deathhands );

	level thread intro_credits();

	
	level thread set_perk_limit(5);  
	// This sets the perk limit to 10

	callback::on_spawned( &cinematic_downs ); //intermission
	

	thread zm_easteregg_song::init();

	thread soundEasterEggInit();

	taf::init();


	// NSZ Temp Wall Buys
	level thread buyable_ending::init(); 


	level._zombie_custom_add_weapons =&custom_add_weapons;
	level.pack_a_punch_camo_index = 75;
    level.pack_a_punch_camo_index_number_variants = 5;

	thread buyable_powerup();

	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;
	init_zones[0] = "start_zone";
	level thread zm_zonemgr::manage_zones( init_zones );

	level.pathdist_type = PATHDIST_ORIGINAL;

	//Bottom of the Main() function
   level.musicplay = false;
   thread musicplaying();


	//staring Points
	level.player_starting_points = 500000;
	//level.player_starting_point = enter number of points;


	//Wallrunning
	SetDvar( "wallrun_enabled", 1 );
	//Enable segments
	level thread setup_wallrun();
	
	thread shootable::init();

	player_teleporter_init();


}

function usermap_test_zone_init()
{
	//Zone per room
	zm_zonemgr::add_adjacent_zone("start_zone","player_zone1","enter_player_zone1");
	zm_zonemgr::add_adjacent_zone("start_zone","player_zone2","enter_player_zone2");
	zm_zonemgr::add_adjacent_zone("start_zone","player_zone3","enter_player_zone3");
	zm_zonemgr::add_adjacent_zone("start_zone","player_zone4","enter_player_zone4");
	zm_zonemgr::add_adjacent_zone("player_zone1","test_zone1","enter_test_zone1");
	zm_zonemgr::add_adjacent_zone("player_zone2","test_zone2","enter_test_zone2");
	zm_zonemgr::add_adjacent_zone("player_zone3","test_zone3","enter_test_zone3");
	zm_zonemgr::add_adjacent_zone("player_zone4","test_zone4","enter_test_zone4");
	zm_zonemgr::add_adjacent_zone("test_zone1","room_zone1","enter_room_zone1");
	zm_zonemgr::add_adjacent_zone("test_zone2","room_zone2","enter_room_zone2");
	zm_zonemgr::add_adjacent_zone("test_zone3","room_zone3","enter_room_zone3");
	zm_zonemgr::add_adjacent_zone("test_zone4","room_zone4","enter_room_zone4");
	zm_zonemgr::add_adjacent_zone("room_zone1","main_zone1","enter_main_zone1");
	zm_zonemgr::add_adjacent_zone("main_zone1","wallrun_zone1","enter_wallrun_zone1");
	zm_zonemgr::add_adjacent_zone("main_zone1","cleedos_endgame_zone","enter_cleedos_endgame_zone1");
	zm_zonemgr::add_adjacent_zone("main_zone1","pack_wallrun_zone1","enter_pack_wallrun_zone1");
	zm_zonemgr::add_adjacent_zone("pack_wallrun_zone1","idontcare_zone1","enter_idontcare_zone1");
	zm_zonemgr::add_adjacent_zone("pack_wallrun_zone1","friend_zone1","enter_friend_zone1");
	zm_zonemgr::add_adjacent_zone("friend_zone1","rose_zone1","enter_rose_zone1");

	// zone e.g zm_zonemgr::add_adjacent_zone("start_zone","start_roomname_zone","enter_roomname_zone");

	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function setup_wallrun()
{
    players = GetPlayers();
    foreach(player in players)
    {
        player AllowWallRun(false);
        player.iswallrunning = false;
    }
    wallrun_trigger = GetEntArray("wallrun_trigger", "targetname");
    foreach(trig in wallrun_trigger)
    {
      trig thread wallrun_logic();
    }
}
function wallrun_logic()
{
    while(1)
    {
        self waittill("trigger", player);
        if(!player.iswallrunning)
        {
            player thread enable_wallrun(self);
        }
    }
}
function enable_wallrun(trig)
{
    self endon("death");
    self endon("disconnect");
    self.iswallrunning = true;
    while(self IsTouching(trig))
    {
        self AllowWallRun(true);
        WAIT_SERVER_FRAME;
    }
    self.iswallrunning = false;
    self AllowWallRun(false);
}

function set_perk_limit(num)
{
    wait( 30 ); 
    level.perk_purchase_limit = num;
}

function intro_credits()
{
    thread creat_simple_intro_hud( "Thank you for playing coop one window challenge: ^2Version 1.1", 50, 100, 3, 5 );
    thread creat_simple_intro_hud( "Mapping & scripting by ^2Nathan^53197^1(Stick)", 50, 75, 2, 5 );
    thread creat_simple_intro_hud( "update video @youtube ^2Nathan^53197", 50, 50, 2, 5 );
    thread creat_simple_intro_hud( "Have fun with finding the easter egg", 50, 25, 2, 5 );
}
 
function creat_simple_intro_hud( text, align_x, align_y, font_scale, fade_time )
{
    hud = NewHudElem();
    hud.foreground = true;
    hud.fontScale = font_scale;
    hud.sort = 1;
    hud.hidewheninmenu = false;
    hud.alignX = "left";
    hud.alignY = "bottom";
    hud.horzAlign = "left";
    hud.vertAlign = "bottom";
    hud.x = align_x;
    hud.y = hud.y - align_y;
    hud.alpha = 1;
    hud SetText( text );
    wait( 8 );
    hud fadeOverTime( fade_time );
    hud.alpha = 0;
    wait( fade_time );
    hud Destroy();
}

function buyable_powerup()
{
	level.buyable_powerup_cost = 5550; // Cost for powerup
	level.buyable_powerup_cooldown = 270; // Cooldown in seconds for buyable trigger
	while(1)
	{
		while(1)
		{
			buyable_powerup_trig = GetEnt("buyable_powerup_trig", "targetname");	
			buyable_powerup_trig SetHintString("Press and hold &&1 to spawn Max Ammo [Cost: " + level.buyable_powerup_cost + "]");
			buyable_powerup_trig SetCursorHint("HINT_NOICON");
			buyable_powerup_spawn = struct::get( "powerup_spawn", "targetname" );
			buyable_powerup_trig waittill("trigger", player);
 
			if(player.score >= level.buyable_powerup_cost)
			{
				player zm_score::minus_to_player_score(level.buyable_powerup_cost);
 
				break;
			}
		}
 
		/*
			If you want a specific powerup, then uncomment the buyable_powerup_spawn below and delete or comment out the one above it.
			Available Powerups: double_points, free_perk, full_ammo, nuke, fire_sale, carpenter, insta_kill, shield_charge, bonfire_sale,
		*/
 
		buyable_powerup_spawn thread zm_powerups::specific_powerup_drop("full_ammo", buyable_powerup_spawn.origin);
 
		buyable_powerup_trig SetHintString("Comeback in 5");
 
		wait(level.buyable_powerup_cooldown);
	}
}



//sewer trabsport
function sewer_transport_1()
{
	sewer_trig = struct::get("sewer_trig_1", "targetname");
	sewer_origin_start = struct::get("sewer_origin_start", "targetname");
	sewer_origin_one = struct::get("sewer_origin_1", "targetname");
	sewer_origin_two = struct::get("sewer_origin_2", "targetname");
	sewer_origin_three = struct::get("sewer_origin_3", "targetname");
	sewer_origin_four = struct::get("sewer_origin_4", "targetname");
	sewer_origin_five = struct::get("sewer_origin_5", "targetname");
	sewer_origin_end = struct::get("sewer_ending", "targetname");
	while(1)
	{
		sewer_trig SetHintString("Press and hold &&1 to go for a ride");
		sewer_trig waittill("trigger", player);
		player SetOrigin( sewer_origin_start.origin);
		wait(0.01);
		moveable = Spawn( "script_model", player.origin );
		player PlayerLinkTo( moveable );
		moveable MoveTo( sewer_origin_one.origin, 1, 0.5, 0 );
		wait(1);
		moveable MoveTo( sewer_origin_two.origin, 1, 0, 0.5);
		wait(1);
		moveable MoveTo( sewer_origin_three.origin, 1, 0.5, 0);
		wait(1);
		moveable MoveTo( sewer_origin_four.origin, 1, 0, 0);
		wait(1);
		moveable MoveTo( sewer_origin_five.origin, 1, 0, 0.5);
		wait(1);
		player Unlink();
		moveable Delete();
		wait(0.01);
		player SetOrigin( sewer_origin_end.origin );
	}
}





function player_teleporter_init()
{
	player_tp = GetEntArray( "teleport_player", "targetname" );
	for( i = 0; i < player_tp.size; i++ )
	{
		player_tp[i] thread player_teleport();
	}
}

function player_teleport()
{
	destination = GetEnt( self.target, "targetname" );
	while(1)
	{
		self waittill( "trigger", player );
		player SetOrigin( destination.origin );
		player SetPlayerAngles( destination.angles );
	}
}

function soundEasterEggInit()
{
 level.soundEasterEgg = 0;
 level.playEasterEgg = 3;
 level.playSoundLocation = GetEnt("easter_egg_sound_location", "SpookySkeletons"); // Create a script origin and set it to server, not client, then give it this targetname
 level.multipleActivations = true;

 thread shoot1();
 thread shoot2();
 thread shoot3();
}
 
function shoot1()
{
 shoot_trig1 = GetEnt("egg_shoot1", "targetname");
 shoot_trig1 waittill("trigger", player);
 shoot_model1 = GetEnt("shoot_model1", "targetname");
 shoot_model1 delete();
 level.soundEasterEgg++;
 thread finishedEasterEgg();
 shoot_trig1 delete();
}
 
function shoot2()
{
 shoot_trig2 = GetEnt("egg_shoot2", "targetname");
 shoot_trig2 waittill("trigger", player);
 shoot_model2 = GetEnt("shoot_model2", "targetname");
 shoot_model2 delete();
 level.soundEasterEgg++;
 thread finishedEasterEgg();
 shoot_trig2 delete();
}
 
function shoot3()
{
 shoot_trig3 = GetEnt("egg_shoot3", "targetname");
 shoot_trig3 waittill("trigger", player);
 shoot_model3 = GetEnt("shoot_model3", "targetname");
 shoot_model3 delete();
 level.soundEasterEgg++;
 thread finishedEasterEgg();
 shoot_trig3 delete();
}
 
function finishedEasterEgg()
{
 if(level.soundEasterEgg >= level.playEasterEgg)
 {
 IPrintLnBold("Enjoy");
 level.playSoundLocation PlaySound("song_easter_egg1"); // Change "sephiroth" to the name of your soundalias.
 
 players = GetPlayers();
 for (i = 0;i<players.size;i++)
 
 {
 players[i] PlayLocalSound( "song_easter_egg1");
 }
 
}
}

//BO2 Deathhands Animation
function bo2_deathhands()
{
	self thread giveDeathHands();
}

function giveDeathHands()
{
	level waittill( "intermission" ); 

	self thread player1_deathhands();
	self thread player2_deathhands();
	self thread player3_deathhands();
	self thread player4_deathhands();
}

function func_giveWeapon(weapon)
{
    self TakeWeapon(self GetCurrentWeapon());
    weapon = getWeapon(weapon);
    self GiveWeapon(weapon);
    self GiveMaxAmmo(weapon);
    self SwitchToWeapon(weapon);
}

function player1_deathhands() //Dempsey
{
	players = GetPlayers();
	player_1 = players[0];
	if ( self.playername == ""+player_1.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function player2_deathhands() //Nikolai
{
	players = GetPlayers();
	player_2 = players[1];
	if ( self.playername == ""+player_2.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function player3_deathhands() //Richtofen
{
	players = GetPlayers();
	player_3 = players[2];
	if ( self.playername == ""+player_3.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function player4_deathhands() //Takeo
{
	players = GetPlayers();
	player_4 = players[3];
	if ( self.playername == ""+player_4.playername+"" )
	{
	self func_giveWeapon("bo2_deathhands");
	}
}

function cinematic_downs()
{
	level endon( "intermission" ); 
	level.players_not_valid = 0; 
	
	while(1)
	{

		while( zm_utility::is_player_valid(self) )
			wait(0.05); 
		
		level.players_not_valid++; 
		self.player_not_valid = true; 
		players = GetPlayers(); 
		if( level.players_not_valid == players.size-1 )
			foreach( player in players )
				if( !isDefined(player.player_not_valid) )
				{
					player PlayLocalSound( "music4" );  // change to your song name
					player.playing_cinematic_down = true; 
				}
		
		while( !zm_utility::is_player_valid(self) )
			wait(0.05); 
		
		level.players_not_valid--; 
		self.player_not_valid = undefined; 
		
		players = getplayers(); 
		foreach( player in players )
			if( isDefined(player.playing_cinematic_down) )
			{
				player StopLocalSound( "music4" ); // change to your song name
				player.playing_cinematic_down = undefined; 
		}
		
		wait(0.05); 
	}
}

//Bottom of your Mapname.gsc
function musicplaying()
{
   //Wait till game starts
   level flag::wait_till( "initial_blackscreen_passed" );
   //IPrintLn("Herro?");
   musicmulti = GetEntArray("musicmulti","targetname");
   //IPrintLn("Found " + musicmulti.size + " Ents");
   foreach(musicpiece in musicmulti)
      musicpiece thread sound_logic();
}
 
function sound_logic()
{
   while(1)
   {
       self waittill("trigger", player);
       if(level.musicplay == false)
       {
            level.musicplay = true;
            //IPrintLn("Music Activated: "+self.script_string);
            player PlaySoundWithNotify(self.script_string, "soundcomplete");
            player waittill("soundcomplete");
            //IPrintLn("Music Over");
            level.musicplay = false;
       }
       else
       {
            IPrintLn("Music Already Playing");
       }
 
   }
}