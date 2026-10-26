// Count down the reminder text
if (message_timer > 0) message_timer -= 1

// Once someone has won: win = click to continue, lose = "Retry this stop" or "Menu"
if (global.Winner != 0)
{
	global.PlayerTurn = false

	// Work out the coins once, as soon as you win, so the win screen can show them
	if (global.Winner == 1 && win_reward == -1) win_reward = fight_reward()

	if (mouse_check_button_pressed(mb_left))
	{
		if (global.Winner == 1)
		{
			// Won: this stop is done
			if (!variable_global_exists("FightsWon")) global.FightsWon = 0
			global.FightsWon += 1

			// Earn coins for the shops (see fight_reward in Items_scr)
			items_init()
			global.Money += win_reward

			// Go to this stop's shop if it has one (it goes on to the map after), otherwise the map
			var shop = shop_after_fight(global.FightsWon)
			if (shop != "") go_to_shop(shop, false)
			else go_to_map()
		}
		else if (mouse_on_lose_button("retry"))
		{
			// Retry this stop: items go back to how they were when the fight started
			global.Items = items_copy(global.FightStartItems)
			global.LastLostCard = global.FightStartLostCard
			global.PepperTurns = global.FightStartPepper
			room_restart()
		}
		else if (mouse_on_lose_button("menu"))
		{
			room_goto(Menu_Room)
		}
	}
	exit
}

// "How to play" panel: any click closes it. The game unpauses one frame later,
// so that click doesn't also pick a card or place a figure.
// Story screens close with a click or Space.
// Either way it asks "Are you sure?" first: Yes (or Space) closes it, No goes back.
if (help_unpause)
{
	help_unpause = false
	global.paused = false
}
if (global.HelpOpen)
{
	var gmx = device_mouse_x_to_gui(0)
	var gmy = device_mouse_y_to_gui(0)
	if (confirming)
	{
		var pick = ""
		if (mouse_check_button_pressed(mb_left)) pick = confirm_hit(0, 0, display_get_gui_width(), display_get_gui_height(), 1, gmx, gmy)
		if (keyboard_check_pressed(vk_space)) pick = "yes"
		if (pick == "yes")
		{
			confirming = false
			close_help()
		}
		else if (pick == "no") confirming = false
	}
	else if (mouse_check_button_pressed(mb_left) || (story_open && keyboard_check_pressed(vk_space))) confirming = true
	exit
}
// The "?" button (top-right) opens it again, any time you're not paused
if (!global.paused && mouse_check_button_pressed(mb_left) && help_button_hit())
{
	open_help()
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
		else if (hand_count() >= max_hand)
		{
			// Hand is full: no card, but this still counts as your draw so you can play
			show_reminder("Your hand is full (" + string(max_hand) + " cards)")
			global.HasDrawn = true
		}
		else if (draw_card() != noone)
		{
			// Extra cards for every 4 units you have (stops early if the deck runs out)
			repeat (cards_per_draw() - 1) draw_card()
			global.HasDrawn = true
		}
	}
}
