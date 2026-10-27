// Draw above the board, figures and item slots (the pause frame is at -1000)
depth = -1001

// Hidden while unpaused, or while the "How to play" panel is open
if (global.paused = false || (variable_global_exists("HelpOpen") && global.HelpOpen))
{
	image_alpha = 0
	exit   // hidden: not clickable either
} else {
	image_alpha = 1
}

// Lights up while the mouse is over it
var over = place_meeting(x, y, Mouse_obj)
image_blend = over ? make_color_rgb(255, 225, 140) : c_white

if (over && mouse_check_button_pressed(1))
{
	global.paused = false
	block_input_briefly()   // so this click doesn't also click the board underneath
}
