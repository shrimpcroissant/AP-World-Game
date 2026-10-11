// No drawing cards while the game is paused
if (variable_global_exists("paused") && global.paused) exit

// Click the deck to draw a card
if (mouse_check_button_pressed(mb_left))
{
	if (point_in_rectangle(mouse_x, mouse_y, x - pile_width / 2, y - pile_height / 2, x + pile_width / 2, y + pile_height / 2))
	{
		draw_card()
	}
}
