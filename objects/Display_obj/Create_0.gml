// Fits the game to whatever screen it's running on.
// Lives in Menu_Room and stays alive for the whole game (persistent).

// Only one of these should ever exist, even after going back to the menu
if (instance_number(Display_obj) > 1)
{
	instance_destroy()
	exit
}

// The shape of this computer's screen, e.g. 16:9 = 1.78, 16:10 = 1.6, 4:3 = 1.33
screen_aspect = display_get_width() / display_get_height()

// Size the window to fill most of the screen, in the same shape as the screen
window_fill = 0.85  // how much of the screen height the window takes up (1 = all of it)
var win_h = floor(display_get_height() * window_fill)
var win_w = floor(win_h * screen_aspect)
window_set_size(win_w, win_h)
call_later(1, time_source_units_frames, function() { window_center() })

camera = camera_create()
