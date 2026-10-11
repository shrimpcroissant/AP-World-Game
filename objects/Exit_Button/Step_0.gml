// game_end() does nothing in a web browser, so hide this button there
if (os_browser != browser_not_a_browser)
{
	visible = false
	exit
}

if place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1)
{
	game_end()
}