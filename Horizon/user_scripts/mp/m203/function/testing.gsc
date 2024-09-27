#include user_scripts\mp\m203\utility;

print_test( test ) {
    self iprintln( test );
}

toggle_test( test ) {
    self.toggle_test[ test ] = !return_toggle( self.toggle_test[ test ] );
}