#include user_scripts\mp\m203\utility;
#include user_scripts\mp\m203\menu_index;

add_menu( title, shader ) {
    if( isdefined( title ) )
        self set_title( title );
    
    if( isdefined( shader ) )
        self.shader_option[ self get_menu() ] = true;
    
    self.structure = [];
}

add_option( text, summary, function, argument_1, argument_2, argument_3 ) {
    option            = spawnstruct();
    option.text       = text;
    option.summary    = summary;
    option.function   = function;
    option.argument_1 = argument_1;
    option.argument_2 = argument_2;
    option.argument_3 = argument_3;

    self.structure[ self.structure.size ] = option;
}

add_toggle( text, summary, function, toggle, array, argument_1, argument_2, argument_3 ) {
    option          = spawnstruct();
    option.text     = text;
    option.summary  = summary;
    option.function = function;
    option.toggle   = return_toggle( toggle );
    if( isdefined( array ) ) {
        option.slider = true;
        option.array  = array;
    }

    option.argument_1 = argument_1;
    option.argument_2 = argument_2;
    option.argument_3 = argument_3;

    self.structure[ self.structure.size ] = option;
}

add_array( text, summary, function, array, argument_1, argument_2, argument_3 ) {
    option            = spawnstruct();
    option.text       = text;
    option.summary    = summary;
    option.function   = function;
    option.slider     = true;
    option.array      = array;
    option.argument_1 = argument_1;
    option.argument_2 = argument_2;
    option.argument_3 = argument_3;

    self.structure[ self.structure.size ] = option;
}

add_increment( text, summary, function, start, minimum, maximum, increment, argument_1, argument_2, argument_3 ) {
    option            = spawnstruct();
    option.text       = text;
    option.summary    = summary;
    option.function   = function;
    option.slider     = true;
    option.start      = start;
    option.minimum    = minimum;
    option.maximum    = maximum;
    option.increment  = increment;
    option.argument_1 = argument_1;
    option.argument_2 = argument_2;
    option.argument_3 = argument_3;

    self.structure[ self.structure.size ] = option;
}

add_category( text ) {
    option          = spawnstruct();
    option.text     = text;
    option.category = true;

    self.structure[ self.structure.size ] = option;
}

new_menu( menu ) {
    if( self get_menu() == "All Players" ) {
        player             = level.players[ ( self get_cursor() + 1 ) ];
        self.select_player = player;
    }

    if( !isdefined( menu ) ) {
        menu                                        = self.previous[ ( self.previous.size - 1 ) ];
        self.previous[ ( self.previous.size - 1 ) ] = undefined;
    }
    else
        self.previous[ self.previous.size ] = self get_menu();

    self set_menu( menu );
    self clear_option();
    self create_option();
}

open_menu( menu ) {
    if( !isdefined( menu ) )
        menu = isdefined( self get_menu() ) && self get_menu() != "M203" ? self get_menu() : "M203";
    
    if( !isdefined( self.m203[ "hud" ] ) )
        self.m203[ "hud" ] = [];
    
    self.m203[ "hud" ][ "title" ]           = self create_text( self get_title(), self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", ( self.x_offset + 4 ), ( self.y_offset + 3 ), self.color[ 4 ], 1, 10 );
    self.m203[ "hud" ][ "background" ][ 0 ] = self create_shader( "white", "TOP_LEFT", "TOPCENTER", self.x_offset, ( self.y_offset - 1 ), 222, 34, self.color[ 0 ], 1, 1 );
    self.m203[ "hud" ][ "background" ][ 1 ] = self create_shader( "white", "TOP_LEFT", "TOPCENTER", ( self.x_offset + 1 ), self.y_offset, 220, 32, self.color[ 1 ], 1, 2 );
    self.m203[ "hud" ][ "foreground" ][ 0 ] = self create_shader( "white", "TOP_LEFT", "TOPCENTER", ( self.x_offset + 1 ), ( self.y_offset + 16 ), 220, 16, self.color[ 2 ], 1, 3 );
    self.m203[ "hud" ][ "foreground" ][ 1 ] = self create_shader( "white", "TOP_LEFT", "TOPCENTER", ( self.x_offset + 1 ), ( self.y_offset + 16 ), 214, 16, self.color[ 3 ], 1, 4 );
    
    self set_menu( menu );
    self set_procedure();
    self create_option();
}

close_menu() {
    self set_procedure();
    self clear_option();
    self clear_all( self.m203[ "hud" ] );
}

create_title( title ) {
    self.m203[ "hud" ][ "title" ] set_text( isdefined( title ) ? title : self get_title() );
}

create_summary( summary ) {
    if( isdefined( self.m203[ "hud" ][ "summary" ] ) && !return_toggle( self.option_summary ) || !isdefined( self.structure[ self get_cursor() ].summary ) && isdefined( self.m203[ "hud" ][ "summary" ] ) )
        self.m203[ "hud" ][ "summary" ] destroy_element();
    
    if( isdefined( self.structure[ self get_cursor() ].summary ) && return_toggle( self.option_summary ) ) {
        if( !isdefined( self.m203[ "hud" ][ "summary" ] ) )
            self.m203[ "hud" ][ "summary" ] = self create_text( isdefined( summary ) ? summary : self.structure[ self get_cursor() ].summary, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", ( self.x_offset + 4 ), ( self.y_offset + 35 ), self.color[ 4 ], 1, 10 );
        else
            self.m203[ "hud" ][ "summary" ] set_text( isdefined( summary ) ? summary : self.structure[ self get_cursor() ].summary );
    }
}

create_option() {
    self clear_option();
    self menu_index();
    if( !isdefined( self.structure ) || !self.structure.size )
        self add_option( "Currently No Options To Display" );
    
    if( !isdefined( self get_cursor() ) )
        self set_cursor( 0 );
    
    start = 0;
    if( ( self get_cursor() > int( ( ( self.option_limit - 1 ) / 2 ) ) ) && ( self get_cursor() < ( self.structure.size - int( ( ( self.option_limit + 1 ) / 2 ) ) ) ) && ( self.structure.size > self.option_limit ) )
        start = ( self get_cursor() - int( ( self.option_limit - 1 ) / 2 ) );
    
    if( ( self get_cursor() > ( self.structure.size - ( int( ( ( self.option_limit + 1 ) / 2 ) ) + 1 ) ) ) && ( self.structure.size > self.option_limit ) )
        start = ( self.structure.size - self.option_limit );
    
    self create_title();
    if( return_toggle( self.option_summary ) )
        self create_summary();
    
    if( isdefined( self.structure ) && self.structure.size ) {
        limit = min( self.structure.size, self.option_limit );
        for( i = 0; i < limit; i++ ) {
            index      = ( i + start );
            cursor     = ( self get_cursor() == index );
            color[ 0 ] = cursor ? self.color[ 0 ] : self.color[ 4 ];
            color[ 1 ] = return_toggle( self.structure[ index ].toggle ) ? cursor ? self.color[ 0 ] : self.color[ 4 ] : cursor ? self.color[ 2 ] : self.color[ 1 ];
            if( isdefined( self.structure[ index ].function ) && self.structure[ index ].function == ::new_menu )
                self.m203[ "hud" ][ "submenu" ][ index ] = self create_shader( "ui_arrow_right", "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 212 ), ( self.y_offset + ( ( i * self.option_spacing ) + 22 ) ), 4, 4, color[ 0 ], 1, 10 );
            
            if( isdefined( self.structure[ index ].toggle ) )
                self.m203[ "hud" ][ "toggle" ][ index ] = self create_shader( "white", "TOP_LEFT", "TOPCENTER", ( self.x_offset + 4 ), ( self.y_offset + ( ( i * self.option_spacing ) + 20 ) ), 8, 8, color[ 1 ], 1, 10 );
            
            if( return_toggle( self.structure[ index ].slider ) ) {
                if( isdefined( self.structure[ index ].array ) )
                    self.m203[ "hud" ][ "slider" ][ 0 ][ index ] = self create_text( self.structure[ index ].array[ self.slider[ self get_menu() + "_" + index ] ], self.font, self.font_scale, "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 210 ), ( self.y_offset + ( ( i * self.option_spacing ) + 19 ) ), color[ 0 ], 1, 10 );
                else {
                    if( cursor )
                        self.m203[ "hud" ][ "slider" ][ 0 ][ index ] = self create_text( self.slider[ self get_menu() + "_" + index ], self.font, ( self.font_scale - 0.1 ), "CENTER", "TOPCENTER", ( self.x_offset + 187 ), ( self.y_offset + ( ( i * self.option_spacing ) + 24 ) ), self.color[ 4 ], 1, 10 );
                    
                    self.m203[ "hud" ][ "slider" ][ 1 ][ index ] = self create_shader( "white", "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 212 ), ( self.y_offset + ( ( i * self.option_spacing ) + 20 ) ), 50, 8, cursor ? self.color[ 2 ] : self.color[ 1 ], 1, 8 );
                    self.m203[ "hud" ][ "slider" ][ 2 ][ index ] = self create_shader( "white", "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 170 ), ( self.y_offset + ( ( i * self.option_spacing ) + 20 ) ), 8, 8, cursor ? self.color[ 0 ] : self.color[ 3 ], 1, 9 );
                }

                self set_slider( undefined, index );
            }

            if( return_toggle( self.structure[ index ].category ) ) {
                self.m203[ "hud" ][ "category" ][ 0 ][ index ] = self create_text( self.structure[ index ].text, self.font, self.font_scale, "CENTER", "TOPCENTER", ( self.x_offset + 102 ), ( self.y_offset + ( ( i * self.option_spacing ) + 24 ) ), self.color[ 0 ], 1, 10 );
                self.m203[ "hud" ][ "category" ][ 1 ][ index ] = self create_shader( "white", "TOP_LEFT", "TOPCENTER", ( self.x_offset + 4 ), ( self.y_offset + ( ( i * self.option_spacing ) + 24 ) ), 30, 1, self.color[ 0 ], 1, 10 );
                self.m203[ "hud" ][ "category" ][ 2 ][ index ] = self create_shader( "white", "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 212 ), ( self.y_offset + ( ( i * self.option_spacing ) + 24 ) ), 30, 1, self.color[ 0 ], 1, 10 );
            }
            else {
                if( return_toggle( self.shader_option[ self get_menu() ] ) ) {
                    shader = isdefined( self.structure[ index ].text ) ? self.structure[ index ].text : "white";
                    color  = isdefined( self.structure[ index ].argument_1 ) ? self.structure[ index ].argument_1 : ( 1, 1, 1 );
                    width  = isdefined( self.structure[ index ].argument_2 ) ? self.structure[ index ].argument_2 : 20;
                    height = isdefined( self.structure[ index ].argument_3 ) ? self.structure[ index ].argument_3 : 20;
                    self.m203[ "hud" ][ "text" ][ index ] = self create_shader( shader, "CENTER", "TOPCENTER", ( self.x_offset + ( ( i * 24 ) - ( ( limit * 10 ) - 109 ) ) ), ( self.y_offset + 32 ), width, height, color, 1, 10 );
                }
                else
                    self.m203[ "hud" ][ "text" ][ index ] = self create_text( return_toggle( self.structure[ index ].slider ) ? self.structure[ index ].text + ":" : self.structure[ index ].text, self.font, self.font_scale, "TOP_LEFT", "TOPCENTER", isdefined( self.structure[ index ].toggle ) ? ( self.x_offset + 15 ) : ( self.x_offset + 4 ), ( self.y_offset + ( ( i * self.option_spacing ) + 19 ) ), color[ 0 ], 1, 10 );
            }
        }

        if( !isdefined( self.m203[ "hud" ][ "text" ][ self get_cursor() ] ) )
            self set_cursor( ( self.structure.size - 1 ) );
    }
    self update_resize();
}

update_scrolling( scrolling ) {
    if( return_toggle( self.structure[ self get_cursor() ].category ) ) {
        self set_cursor( ( self get_cursor() + scrolling ) );
        return self update_scrolling( scrolling );
    }

    if( ( self.structure.size > self.option_limit ) || ( self get_cursor() >= 0 ) || ( self get_cursor() <= 0 ) ) {
        if( ( self get_cursor() >= self.structure.size ) || ( self get_cursor() < 0 ) )
            self set_cursor( ( self get_cursor() >= self.structure.size ) ? 0 : ( self.structure.size - 1 ) );
        
        self create_option();
    }

    self update_resize();
}

update_resize() {
    limit    = min( self.structure.size, self.option_limit );
    height   = int( ( limit * self.option_spacing ) );
    adjust   = ( self.structure.size > self.option_limit ) ? int( ( ( 112 / self.structure.size ) * limit ) ) : height;
    position = ( self.structure.size - 1 ) / ( height - adjust );
    if( return_toggle( self.shader_option[ self get_menu() ] ) ) {
        self.m203[ "hud" ][ "foreground" ][ 1 ].y = ( self.y_offset + 46 );
        self.m203[ "hud" ][ "foreground" ][ 1 ].x = ( self.m203[ "hud" ][ "text" ][ self get_cursor() ].x - 10 );
        if( !isdefined( self.m203[ "hud" ][ "arrow" ][ 0 ] ) )
            self.m203[ "hud" ][ "arrow" ][ 0 ] = self create_shader( "ui_scrollbar_arrow_left", "TOP_LEFT", "TOPCENTER", ( self.x_offset + 10 ), ( self.y_offset + 29 ), 6, 6, self.color[ 4 ], 1, 10 );
        
        if( !isdefined( self.m203[ "hud" ][ "arrow" ][ 1 ] ) )
            self.m203[ "hud" ][ "arrow" ][ 1 ] = self create_shader( "ui_scrollbar_arrow_right", "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 211 ), ( self.y_offset + 29 ), 6, 6, self.color[ 4 ], 1, 10 );
        
        self.m203[ "hud" ][ "foreground" ][ 2 ] destroy_element();
    }
    else {
        self.m203[ "hud" ][ "foreground" ][ 1 ].y = ( self.m203[ "hud" ][ "text" ][ self get_cursor() ].y - 3 );
        self.m203[ "hud" ][ "foreground" ][ 1 ].x = ( self.x_offset + 1 );
        if( !isdefined( self.m203[ "hud" ][ "foreground" ][ 2 ] ) )
            self.m203[ "hud" ][ "foreground" ][ 2 ] = self create_shader( "white", "TOP_RIGHT", "TOPCENTER", ( self.x_offset + 221 ), ( self.y_offset + 16 ), 4, 16, self.color[ 3 ], 1, 4 );
        
        self.m203[ "hud" ][ "arrow" ][ 0 ] destroy_element();
        self.m203[ "hud" ][ "arrow" ][ 1 ] destroy_element();
    }

    self.m203[ "hud" ][ "background" ][ 0 ] set_shader( self.m203[ "hud" ][ "background" ][ 0 ].shader, self.m203[ "hud" ][ "background" ][ 0 ].width, return_toggle( self.shader_option[ self get_menu() ] ) ? ( isdefined( self.structure[ self get_cursor() ].summary ) && return_toggle( self.option_summary ) ? 66 : 50 ) : ( isdefined( self.structure[ self get_cursor() ].summary ) && return_toggle( self.option_summary ) ? ( height + 34 ) : ( height + 18 ) ) );
    self.m203[ "hud" ][ "background" ][ 1 ] set_shader( self.m203[ "hud" ][ "background" ][ 1 ].shader, self.m203[ "hud" ][ "background" ][ 1 ].width, return_toggle( self.shader_option[ self get_menu() ] ) ? ( isdefined( self.structure[ self get_cursor() ].summary ) && return_toggle( self.option_summary ) ? 64 : 48 ) : ( isdefined( self.structure[ self get_cursor() ].summary ) && return_toggle( self.option_summary ) ? ( height + 32 ) : ( height + 16 ) ) );
    self.m203[ "hud" ][ "foreground" ][ 0 ] set_shader( self.m203[ "hud" ][ "foreground" ][ 0 ].shader, self.m203[ "hud" ][ "foreground" ][ 0 ].width, return_toggle( self.shader_option[ self get_menu() ] ) ? 32 : height );
    self.m203[ "hud" ][ "foreground" ][ 1 ] set_shader( self.m203[ "hud" ][ "foreground" ][ 1 ].shader, return_toggle( self.shader_option[ self get_menu() ] ) ? 20 : 214, return_toggle( self.shader_option[ self get_menu() ] ) ? 2 : 16 );
    self.m203[ "hud" ][ "foreground" ][ 2 ] set_shader( self.m203[ "hud" ][ "foreground" ][ 2 ].shader, self.m203[ "hud" ][ "foreground" ][ 2 ].width, adjust );
    if( isdefined( self.m203[ "hud" ][ "foreground" ][ 2 ] ) ) {
        self.m203[ "hud" ][ "foreground" ][ 2 ].y = ( self.y_offset + 16 );
        if( self.structure.size > self.option_limit )
            self.m203[ "hud" ][ "foreground" ][ 2 ].y += ( self get_cursor() / position );
    }
    
    if( isdefined( self.m203[ "hud" ][ "summary" ] ) )
        self.m203[ "hud" ][ "summary" ].y = return_toggle( self.shader_option[ self get_menu() ] ) ? ( self.y_offset + 51 ) : ( self.y_offset + ( ( limit * self.option_spacing ) + 19 ) );
}

update_menu( menu, cursor, force ) {
    if( isdefined( menu ) && !isdefined( cursor ) || !isdefined( menu ) && isdefined( cursor ) )
        return;
    
    if( isdefined( menu ) && isdefined( cursor ) ) {
        foreach( player in level.players ) {
            if( !isdefined( player ) || !player in_menu() )
                continue;
            
            if( player get_menu() == menu || self != player && player is_option( menu, cursor, self ) )
                if( isdefined( player.m203[ "hud" ][ "text" ][ cursor ] ) || player == self && player get_menu() == menu && isdefined( player.m203[ "hud" ][ "text" ][ cursor ] ) || self != player && player is_option( menu, cursor, self ) || return_toggle( force ) )
                    player create_option();
        }
    }
    else {
        if( isdefined( self ) && self in_menu() )
            self create_option();
    }
}