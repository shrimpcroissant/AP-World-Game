// Draw above the board, figures and item slots
depth = -1000

// The "How to play" panel also pauses the game; the pause menu stays hidden while it's open
var help_open = variable_global_exists("HelpOpen") && global.HelpOpen

// Escape opens the pause menu, and closes it again
if (keyboard_check_pressed(vk_escape) && !help_open)
{
	global.paused = !global.paused
}

if (global.paused = false || help_open)
{
	image_alpha = 0
} else {
	image_alpha = 1
}
