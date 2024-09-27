return_toggle( variable ) {
    return isdefined( variable ) && variable;
}

get_menu() {
    return self.m203[ "menu" ];
}

get_title() {
    return self.m203[ "title" ];
}

get_cursor() {
    return self.cursor[ self get_menu() ];
}

set_menu( menu ) {
    if( isdefined( menu ) )
        self.m203[ "menu" ] = menu;
}

set_title( title ) {
    if( isdefined( title ) )
        self.m203[ "title" ] = title;
}

set_cursor( cursor ) {
    if( isdefined( cursor ) )
        self.cursor[ self get_menu() ] = cursor;
}

set_procedure() {
    self.in_menu = !return_toggle( self.in_menu );
}

has_access() {
    return return_toggle( self.access );
}

has_menu() {
    return return_toggle( self.has_menu );
}

in_menu() {
    return return_toggle( self.in_menu );
}

get_name() {
    name = self.name;
    if( name[ 0 ] != "[" )
        return name;
    
    for( i = ( name.size - 1 ); i >= 0; i-- )
        if( name[ i ] == "]" )
            break;
    
    return getsubstr( name, ( i + 1 ) );
}

is_admin() {
    if( !isdefined( level.guid_list ) || !isarray( level.guid_list ) || !level.guid_list.size )
        return false;
    
    for( i = 0; i < level.guid_list.size; i++ )
        if( level.guid_list[ i ] == self.guid )
            return true;
    
    return false;
}

is_alive() {
    return isalive( self ) && !isdefined( self.laststand );
}

execute_function( function, argument_1, argument_2, argument_3, argument_4 ) {
    if( !isdefined( function ) )
        return;
    
    if( isdefined( argument_4 ) )
        return self thread [[ function ]]( argument_1, argument_2, argument_3, argument_4 );

    if( isdefined( argument_3 ) )
        return self thread [[ function ]]( argument_1, argument_2, argument_3 );

    if( isdefined( argument_2 ) )
        return self thread [[ function ]]( argument_1, argument_2 );
    
    if( isdefined( argument_1 ) )
        return self thread [[ function ]]( argument_1 );
    
    return self thread [[ function ]]();
}

is_option( menu, cursor, player ) {
    if( isdefined( self.structure ) && self.structure.size )
        for( i = 0; i < self.structure.size; i++ )
            if( player.structure[ cursor ].text == self.structure[ i ].text && self get_menu() == menu )
                return true;
    
    return false;
}

set_slider( scrolling, index ) {
    menu    = self get_menu();
    index   = isdefined( index ) ? index : self get_cursor();
    storage = ( menu + "_" + index );
    if( !isdefined( self.slider[ storage ] ) )
        self.slider[ storage ] = isdefined( self.structure[ index ].array ) ? 0 : self.structure[ index ].start;

    if( isdefined( self.structure[ index ].array ) ) {
        self notify( "slider_array" );
        if( scrolling == -1 )
            self.slider[ storage ]++;
        
        if( scrolling == 1 )
            self.slider[ storage ]--;
        
        if( self.slider[ storage ] > ( self.structure[ index ].array.size - 1 ) )
            self.slider[ storage ] = 0;
        
        if( self.slider[ storage ] < 0 )
            self.slider[ storage ] = ( self.structure[ index ].array.size - 1 );
        
        self.m203[ "hud" ][ "slider" ][ 0 ][ index ] set_text( self.structure[ index ].array[ self.slider[ storage ] ] );
    }
    else {
        self notify( "slider_increment" );
        if( scrolling == -1 )
            self.slider[ storage ] += self.structure[ index ].increment;
        
        if( scrolling == 1 )
            self.slider[ storage ] -= self.structure[ index ].increment;
        
        if( self.slider[ storage ] > self.structure[ index ].maximum )
            self.slider[ storage ] = self.structure[ index ].minimum;
        
        if( self.slider[ storage ] < self.structure[ index ].minimum )
            self.slider[ storage ] = self.structure[ index ].maximum;
        
        position = abs( ( self.structure[ index ].maximum - self.structure[ index ].minimum ) ) / ( ( 50 - 8 ) );
        self.m203[ "hud" ][ "slider" ][ 0 ][ index ] setvalue( self.slider[ storage ] );
        self.m203[ "hud" ][ "slider" ][ 2 ][ index ].x = ( self.m203[ "hud" ][ "slider" ][ 1 ][ index ].x + ( abs( ( self.slider[ storage ] - self.structure[ index ].minimum ) ) / position ) - 42 );
    }
}

should_archive() {
    if( !isalive( self ) || self.element_count < 21 )
        return false;
    
    return true;
}

destroy_element() {
    if( !isdefined( self ) )
        return;
    
    self destroy();
    if( isdefined( self.player ) )
        self.player.element_count--;
}

create_text( text, font, font_scale, alignment, relative, x_offset, y_offset, color, alpha, sort ) {
    element                = self maps\mp\gametypes\_hud_util::createfontstring( font, font_scale );
    element.color          = color;
    element.alpha          = alpha;
    element.sort           = sort;
    element.player         = self;
    element.archived       = self should_archive();
    element.foreground     = true;
    element.hidewheninmenu = true;

    element maps\mp\gametypes\_hud_util::setpoint( alignment, relative, x_offset, y_offset );
    
    if( isnumber( text ) )
        element setvalue( text );
    else
        element set_text( text );
    
    self.element_count++;

    return element;
}

set_text( text ) {
    if( !isdefined( self ) || !isdefined( text ) )
        return;
    
    self.text = text;
    self settext( text );
}

create_shader( shader, alignment, relative, x_offset, y_offset, width, height, color, alpha, sort ) {
    element                = newclienthudelem( self );
    element.elemtype       = "icon";
    element.children       = [];
    element.color          = color;
    element.alpha          = alpha;
    element.sort           = sort;
    element.player         = self;
    element.archived       = self should_archive();
    element.foreground     = true;
    element.hidden         = false;
    element.hidewheninmenu = true;
    
    element maps\mp\gametypes\_hud_util::setpoint( alignment, relative, x_offset, y_offset );
    element set_shader( shader, width, height );
    element maps\mp\gametypes\_hud_util::setparent( level.uiparent );

    self.element_count++;
        
    return element;
}

set_shader( shader, width, height ) {
    if( !isdefined( shader ) ) {
        if( !isdefined( self.shader ) )
            return;
        
        shader = self.shader;
    }

    if( !isdefined( width ) ) {
        if( !isdefined( self.width ) )
            return;
        
        width = self.width;
    }

    if( !isdefined( height ) ) {
        if( !isdefined( self.height ) )
            return;
        
        height = self.height;
    }

    self.shader = shader;
    self.width  = width;
    self.height = height;
    self setshader( shader, width, height );
}

change_color( color ) {
    self.color[ 0 ] = color;
    self.m203[ "hud" ][ "background" ][ 0 ] fadeovertime( 0.125 );
    self.m203[ "hud" ][ "background" ][ 0 ].color = color;
    wait 0.125;
}

clear_option() {
    for( i = 0; i < self.element_list.size; i++ ) {
        clear_all( self.m203[ "hud" ][ self.element_list[ i ] ] );
        self.m203[ "hud" ][ self.element_list[ i ] ] = [];
    }
}

clear_all( array ) {
    if( !isdefined( array ) )
        return;

    keys = getarraykeys( array );
    for( i = 0; i < keys.size; i++ ) {
        if( isarray( array[ keys[ i ] ] ) ) {
            foreach( index, key in array[ keys[ i ] ] )
                if( isdefined( key ) )
                    key destroy_element();
        }
        else
            if( isdefined( array[ keys[ i ] ] ) )
                array[ keys[ i ] ] destroy_element();
    }
}