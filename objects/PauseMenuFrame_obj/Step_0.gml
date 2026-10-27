// Draw above the board, figures and item slots
depth = -1000

// The "How to play" panel also pauses the game; the pause menu stays hidden while it's open
var help_open = variable_global_exists("HelpOpen") && global.HelpOpen

// Escape opens the pause menu, and closes it again
if (keyboard_check_pressed(vk_escape) && !help_open)
{
	global.paused = !global.paused
	if (!global.paused) block_input_briefly()   // closing it doesn't also click the board
}

// Slate blue instead of the skin-colored art
image_blend = make_color_rgb(120, 150, 200)

if (global.paused = false || help_open)
{
	image_alpha = 0
} else {
	image_alpha = 1
}
