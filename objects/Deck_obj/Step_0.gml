// Count down the reminder text
if (message_timer > 0) message_timer -= 1

// Once someone has won, a click goes back to the menu
if (global.Winner != 0)
{
	global.PlayerTurn = false
	if (mouse_check_button_pressed(mb_left)) room_goto(Menu_Room)
	exit
}

// Keep the next-battle prediction up to date while it's your turn
if (global.PlayerTurn) predict_battle()

// No drawing cards while the game is paused
if (variable_global_exists("paused") && global.paused) exit

// Right-click puts a chosen card back
if (mouse_check_button_pressed(mb_right)) global.SelectedCard = noone

// No drawing during the AI's turn
if (!global.PlayerTurn) exit

// Click the deck to draw a card, once per turn
if (mouse_check_button_pressed(mb_left))
{
	if (point_in_rectangle(mouse_x, mouse_y, x - pile_width / 2, y - pile_height / 2, x + pile_width / 2, y + pile_height / 2))
	{
		if (global.HasDrawn)
		{
			show_reminder("You already drew this turn")
		}
		else if (draw_card() != noone)
		{
			global.HasDrawn = true
		}
	}
}
