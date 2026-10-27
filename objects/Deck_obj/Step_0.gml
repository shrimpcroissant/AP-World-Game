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

// The panel (story screen or "How to play"). The game unpauses one frame after it closes,
// so the closing click doesn't also pick a card or place a figure.
// First-time screens: hold the mouse button or Space until the bar fills.
// "How to play" from the "?" button: any click closes it.
if (help_unpause)
{
	help_unpause = false
	global.paused = false
}
if (global.HelpOpen)
{
	if (needs_hold)
	{
		if (mouse_check_button(mb_left) || keyboard_check(vk_space)) hold += delta_time / 1000000
		else hold = 0
		if (hold >= hold_needed) close_help()
	}
	else if (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_space)) close_help()
	exit
}

// China tutorial prompts: each step moves on when you do what it says, or with Next
if (tutorial_step >= 0 && global.Winner == 0)
{
	// Slower enemy turn and battle while learning, so you can follow what happens
	with (EnemyAI_obj) think_delay = 36

	var step = tutorial_steps[tutorial_step]
	var done = false
	switch (step.wait)
	{
		case "draw":   done = global.HasDrawn; break
		case "place":  done = player_figure_count() > tutorial_figs; break
		case "end":    done = !global.PlayerTurn; break
		case "battle": done = global.PlayerTurn; break
	}
	if (!input_blocked() && mouse_check_button_pressed(mb_left))
	{
		var hit = tutorial_hit(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0))
		if (hit != "") block_input_briefly()   // clicks on the prompt box don't reach the board
		if (hit == "next") done = true
		else if (hit == "skip")
		{
			tutorial_step = -1
			global.TutorialShown = true
			done = false
		}
	}
	if (done) tutorial_advance()
}
else with (EnemyAI_obj) think_delay = 12
// Playtest "Auto win": lights the enemy's lanes one after another (a quick, sure win)
if (auto_win_timer >= 0)
{
	auto_win_timer += 1
	if (auto_win_timer mod 20 == 0)
	{
		var lit_one = false
		with (LaneEndLight_obj)
		{
			if (!lit_one && watch_team == 1 && !lit)
			{
				light_up()
				lit_one = true
			}
		}
	}
	exit
}

// The "?" button (top-right) opens it again, any time you're not paused
if (!input_blocked() && mouse_check_button_pressed(mb_left) && help_button_hit())
{
	open_help()
	exit
}

// Keep the next-battle prediction up to date while it's your turn
if (global.PlayerTurn) predict_battle()

// No drawing cards while the game is paused or a pop-up just closed
if (input_blocked()) exit

// Playtest shortcut: the "Auto win" button (or F2) plays out a quick win.
// Turn it off for the real game with debug_tools = false in Deck_obj's Create event.
if (debug_tools)
{
	var auto_win = keyboard_check_pressed(vk_f2)
	if (mouse_check_button_pressed(mb_left) && point_in_rectangle(mouse_x, mouse_y, debug_btn_x, debug_btn_y, debug_btn_x + debug_btn_w, debug_btn_y + debug_btn_h)) auto_win = true
	if (auto_win)
	{
		auto_win_timer = 0
		global.SelectedCard = noone
		global.PlayerTurn = false   // no more moves while it plays out
		show_reminder("Auto win (playtest)")
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
		if (draw_skipped)
		{
			show_reminder("Out of cards: no draw this turn")
		}
		else if (global.HasDrawn)
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
