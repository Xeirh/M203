#include scripts\mp\m203\utility;
#include scripts\mp\m203\structure;
#include scripts\mp\m203\function\basic;
#include scripts\mp\m203\function\testing;

menu_index() {
    menu = self get_menu();
    if( !isdefined( menu ) )
        menu = "Unassigned Menu";
    
    switch( menu ) {
        case "M203":
            self add_menu( ( "Welcome " + self get_name() ) );
            self add_toggle( "God Mode", "Immune To Any And All Damage", ::god_mode, self.god_mode );

            self add_category( "Testing" );

            self add_option( "Option Testing", undefined, ::new_menu, "Option Testing" );
            self add_option( "Toggle Testing", undefined, ::new_menu, "Toggle Testing" );
            self add_option( "Shader Testing", undefined, ::new_menu, "Shader Testing" );
            break;
        case "Option Testing":
            self add_menu( menu );
            for( i = 0; i < 15; i++ ) {
                option = ( "Option " + ( i + 1 ) );
                self add_option( option, undefined, ::print_test, option );
            }
            break;
        case "Toggle Testing":
            self add_menu( menu );
            for( i = 0; i < 15; i++ ) {
                toggle = ( "Toggle " + ( i + 1 ) );
                self add_toggle( toggle, undefined, ::toggle_test, self.toggle_test[ toggle ], undefined, toggle );
            }
            break;
        case "Shader Testing":
            self add_menu( menu, true );
            foreach( index, color in self.color_list )
                self add_option( "white", undefined, ::change_color, color );
            break;
        case "All Players":
            self add_menu( menu );
            foreach( index, player in level.players ) {
                if( player == self )
                    continue;
                
                self add_option( player get_name(), undefined, ::new_menu, "Player Option" );
            }
            break;
        default:
            if( !isdefined( self.select_player ) )
                self.select_player = self;
            
            self player_index( menu, self.select_player );
            break;
    }
}

player_index( menu, player ) {
    if( !isdefined( player ) || !isplayer( player ) )
        menu = "Unassigned Menu";
    
    switch( menu ) {
        case "Player Option":
            self add_menu( player get_name() );
            break;
        case "Unassigned Menu":
            self add_menu( menu );
            self add_option( "This Menu Is Unassigned" );
            break;
        default:
            is_error = true;
            if( is_error ) {
                self add_menu( "Error" );
                self add_option( ( "Error With " + menu ) );
            }
            break;
    }
}