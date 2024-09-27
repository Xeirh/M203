#include user_scripts\mp\m203\preload;
#include user_scripts\mp\m203\utility;
#include user_scripts\mp\m203\structure;

init() {
    level.guid_list     = [ "your guid" ];
    level.auto_verify   = false;
    level.private_match = !level.rankedmatch;
    if( return_toggle( level.private_match ) )
        level.debug_leave = true;
    
    level initial_precache();
    level thread on_connect();
}

on_connect() {
    level endon( "game_ended" );
    while( true ) {
        level waittill( "connected", player );
        if( !isdefined( level.initial_callback ) ) {
            level.initial_callback = true;
            level initial_callback();
        }

        if( isbot( player ) || istestclient( player ) )
            continue;
        
        player.access = return_toggle( level.private_match ) ? ( player ishost() ? "Host" : ( return_toggle( level.auto_verify ) ? "Access" : undefined ) ) : ( player is_admin() ? "Admin" : ( return_toggle( level.auto_verify ) ? "Access" : undefined ) );
        if( !isdefined( player.access ) )
            continue;
        
        player thread on_event();
        player thread on_ended();
    }
}

on_event() {
    level endon( "game_ended" );
    self endon( "disconnect" );
    while( true ) {
        event_name = self common_scripts\utility::waittill_any_return( "spawned_player", "player_downed", "death" );
        switch( event_name ) {
            case "spawned_player":
                if( !isdefined( self.m203 ) )
                    self.m203 = [];
                
                self iprintln( return_toggle( level.private_match ) ? "Private Match" : "Dedicated Server" );
                self iprintln( "Current Access: " + self.access );
                if( !isdefined( self.has_menu ) ) {
                    self.has_menu = true;

                    self initial_variable();
                    self thread initial_monitor();
                }
                break;
            default:
                if( self in_menu() )
                    self close_menu();
                break;
        }
    }
}

on_ended() {
    level waittill( "game_ended" );
    level endon( "game_ended" );
    self endon( "disconnect" );
    if( self in_menu() )
        self close_menu();

    if( return_toggle( level.debug_leave ) )
        exitlevel( false );
}