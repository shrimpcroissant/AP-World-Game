if global.paused = false
{
	image_alpha = 0
} else {
	image_alpha = 1
}

if place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1)
{
	room_goto(Menu_Room)
}