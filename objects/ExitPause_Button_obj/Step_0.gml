// Draw above the board, figures and item slots (the pause frame is at -1000)
depth = -1001

if global.paused = false
{
	image_alpha = 0
	exit   // hidden: not clickable either (it sits over the top of the board)
} else {
	image_alpha = 1
}

if place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1)
{
	room_goto(Menu_Room)
}
