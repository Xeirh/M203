#include scripts\mp\m203\utility;
#include scripts\mp\m203\structure;

initial_callback() {
    level.callback_player_damage_stub    = level.callbackplayerdamage;
    level.callbackplayerdamage           = ::callback_player_damage_stub;
    level.callback_player_killed_stub    = level.callbackplayerkilled;
    level.callbackplayerkilled           = ::callback_player_killed_stub;
    level.callback_player_laststand_stub = level.callbackplayerlaststand;
    level.callbackplayerlaststand        = ::callback_player_laststand_stub;
}

initial_precache() {
    foreach( index, shader in [ "ui_arrow_right", "ui_scrollbar_arrow_right", "ui_scrollbar_arrow_left" ] )
        precacheshader( shader );
}

initial_variable() {
    self.font            = "objective";
    self.font_scale      = 0.7;
    self.option_limit    = 7;
    self.option_spacing  = 16;
    self.option_summary  = true;
    self.option_interact = true;
    self.x_offset        = -360;
    self.y_offset        = 180;
    self.random_color    = true;
    self.color_list      = [ ( 0, 0.278431, 1 ), ( 0.54902, 0.168627, 0.929412 ), ( 0.768627, 0, 0.823529 ), ( 0.886275, 0, 0.682353 ), ( 0.976471, 0, 0.560784 ), ( 1, 0, 0.443137 ), ( 1, 0.231373, 0.337255 ), ( 1, 0.352941, 0.207843 ), ( 1, 0.478431, 0 ) ];
    self.element_count   = 0;
    self.element_list    = [ "text", "submenu", "toggle", "category", "slider" ];

    random = self.color_list[ randomint( self.color_list.size ) ];
    choice = return_toggle( self.random_color ) ? ( random[ 0 ], random[ 1 ], random[ 2 ] ) : ( self.color_list[ ( self.color_list.size - 1 ) ] );

    self.color[ 0 ] = choice;
    self.color[ 1 ] = ( 0.109803, 0.129411, 0.156862 );
    self.color[ 2 ] = ( 0.133333, 0.152941, 0.180392 );
    self.color[ 3 ] = ( 0.160784, 0.180392, 0.211764 );
    self.color[ 4 ] = ( 0.223529, 0.250980, 0.286274 );

    self.cursor   = [];
    self.previous = [];

    self set_menu( "M203" );
    self set_title( self get_menu() );
}

initial_monitor() {
    level endon( "game_ended" );
    self endon( "disconnect" );
    while( true ) {
        if( self is_alive() ) {
            if( !self in_menu() ) {
                if( self adsbuttonpressed() && self meleebuttonpressed() ) {
                    if( return_toggle( self.option_interact ) )
                        self playsoundtoplayer( "h1_ui_menu_warning_box_appear", self );
                
                    self open_menu();
                    wait 0.15;
                }
            }
            else {
                menu   = self get_menu();
                cursor = self get_cursor();
                if( self meleebuttonpressed() ) {
                    if( return_toggle( self.option_interact ) )
                        self playsoundtoplayer( isdefined( self.previous[ ( self.previous.size - 1 ) ] ) ? "h1_ui_pause_menu_resume" : "h1_ui_box_text_disappear", self );
                
                    if( isdefined( self.previous[ ( self.previous.size - 1 ) ] ) )
                        self new_menu( self.previous[ menu ] );
                    else
                        self close_menu();
                
                    wait 0.15;
                }
                else if( self adsbuttonpressed() && !self attackbuttonpressed() || self attackbuttonpressed() && !self adsbuttonpressed() ) {
                    if( isdefined( self.structure ) && self.structure.size >= 2 ) {
                        if( return_toggle( self.option_interact ) )
                            self playsoundtoplayer( "h1_ui_menu_scroll", self );
                    
                        scrolling = self attackbuttonpressed() ? 1 : -1;
                        self set_cursor( ( cursor + scrolling ) );
                        self update_scrolling( scrolling );
                    }
                    wait 0.07;
                }
                else if( self fragbuttonpressed() && !self secondaryoffhandbuttonpressed() || self secondaryoffhandbuttonpressed() && !self fragbuttonpressed() ) {
                    if( return_toggle( self.structure[ cursor ].slider ) ) {
                        if( return_toggle( self.option_interact ) )
                            self playsoundtoplayer( "h1_ui_menu_scroll", self );
                        
                        scrolling = self secondaryoffhandbuttonpressed() ? 1 : -1;
                        self set_slider( scrolling );
                    }
                    wait 0.07;
                }
                else if( self usebuttonpressed() ) {
                    if( isdefined( self.structure[ cursor ].function ) ) {
                        if( return_toggle( self.option_interact ) )
                            self playsoundtoplayer( isdefined( self.structure[ cursor ].toggle ) ? return_toggle( self.structure[ cursor ].toggle ) ? "mp_ui_decline" : "mp_ui_accept" : "h1_ui_menu_accept", self );
                    
                        if( return_toggle( self.structure[ cursor ].slider ) )
                            self thread execute_function( self.structure[ cursor ].function, isdefined( self.structure[ cursor ].array ) ? self.structure[ cursor ].array[ self.slider[ menu + "_"  + cursor ] ] : self.slider[ menu + "_" + cursor ], self.structure[ cursor ].argument_1, self.structure[ cursor ].argument_2, self.structure[ cursor ].argument_3 );
                        else
                            self thread execute_function( self.structure[ cursor ].function, self.structure[ cursor ].argument_1, self.structure[ cursor ].argument_2, self.structure[ cursor ].argument_3 );
                    
                        if( isdefined( self.structure[ cursor ].toggle ) )
                            self update_menu( menu, cursor );
                    }
                    wait 0.18;
                }
            }
        }
        wait 0.05;
    }
}

callback_player_damage_stub( inflictor, attacker, damage, flag, death_cause, weapon, point, direction, hit_location, time_offset ) {
    if( return_toggle( self.god_mode ) )
        return;
    
    [[ level.callback_player_damage_stub ]]( inflictor, attacker, damage, flag, death_cause, weapon, point, direction, hit_location, time_offset );
}

callback_player_killed_stub( inflictor, attacker, damage, death_cause, weapon, direction, hit_location, time_offset, death_duration ) {
    [[ level.callback_player_killed_stub ]]( inflictor, attacker, damage, death_cause, weapon, direction, hit_location, time_offset, death_duration );
}

callback_player_laststand_stub( inflictor, attacker, damage, death_cause, weapon, direction, hit_location, time_offset, death_duration ) {
    self notify( "player_downed" );
    [[ level.callback_player_laststand_stub ]]( inflictor, attacker, damage, death_cause, weapon, direction, hit_location, time_offset, death_duration );
}