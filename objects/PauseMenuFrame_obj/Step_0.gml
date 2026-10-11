if keyboard_check_pressed(vk_escape)
{
	global.paused = true
}

if global.paused = false
{
	image_alpha = 0
} else {
	image_alpha = 1
}

show_debug_message(global.paused)