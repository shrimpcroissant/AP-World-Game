// Count down the reminder text
if (message_timer > 0) message_timer -= 1

// Once someone has won, a click goes back to the menu
if (global.Winner != 0)
{
	global.PlayerTurn = false
	if (mouse_check_button_pressed(mb_left))
	{
		if (global.Winner == 1)
		{
			// Won: show the map with this stop done
			if (!variable_global_exists("FightsWon")) global.FightsWon = 0
			global.FightsWon += 1
			// Use the map room if the project has it, otherwise Map_Room
			var map_room = asset_get_index("MapTravel_Room")
			if (map_room == -1) map_room = Map_Room
			room_goto(map_room)
		}
		else
		{
			room_goto(Menu_Room)
		}
	}
	exit
}

// Keep the next-battle prediction up to date while it's your turn
if (global.PlayerTurn) predict_battle()

// No drawing cards while the game is paused
if (variable_global_exists("paused") && global.paused) exit

// Playtest shortcut: the "Auto win" button (or F2) wins the fight instantly.
// Turn it off for the real game with debug_tools = false in Deck_obj's Create event.
if (debug_tools)
{
	var auto_win = keyboard_check_pressed(vk_f2)
	if (mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, debug_btn_x, debug_btn_y, debug_btn_x + debug_btn_w, debug_btn_y + debug_btn_h)) auto_win = true
	if (auto_win)
	{
		global.Winner = 1
		exit
	}
}

// Right-click puts a chosen card back
if (mouse_check_button_pressed(mb_right)) global.SelectedCard = noone

// No drawing during the AI's turn or while aiming the dagger
if (!global.PlayerTurn || global.DaggerAiming) exit

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
