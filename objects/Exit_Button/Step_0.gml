// game_end() does nothing in a web browser, so hide this button there
if (os_browser != browser_not_a_browser)
{
	visible = false
	exit
}

// Lights up while the mouse is over it
var over = place_meeting(x, y, Mouse_obj)
image_blend = over ? make_color_rgb(255, 225, 140) : c_white

// Not while the How to Play overlay is open (or just closed)
if (over && mouse_check_button_pressed(1) && !input_blocked() && !(variable_global_exists("MenuHelpOpen") && global.MenuHelpOpen))
{
	game_end()
}