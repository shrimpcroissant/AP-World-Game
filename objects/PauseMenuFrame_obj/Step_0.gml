// Draw above the board, figures and item slots
depth = -1000

// Escape opens the pause menu, and closes it again
if keyboard_check_pressed(vk_escape)
{
	global.paused = !global.paused
}

if global.paused = false
{
	image_alpha = 0
} else {
	image_alpha = 1
}
