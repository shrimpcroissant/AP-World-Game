// Runs the AI's turn one step at a time, then the battle phase
if (variable_global_exists("paused") && global.paused) exit
if (state == "waiting") exit
if (global.Winner != 0) exit  // game over

if (timer > 0)
{
	timer -= 1
	exit
}

switch (state)
{
	case "draw":
		draw_card()
		state = "play"
		timer = think_delay
		break

	case "play":
		// Keep playing cards until it can't afford any or runs out of room
		var card = choose_card()
		var tiles = open_tiles()
		if (card != noone && array_length(tiles) > 0)
		{
			play_card(card, choose_tile(tiles))
		}
		else
		{
			state = "move"
			var first_text = "Enemy attacks first"
			if (global.FirstSide == 1) first_text = "You attack first"
			with (Deck_obj) show_reminder(first_text)
		}
		timer = think_delay
		break

	case "move":
		// Battle phase: one side acts, then the other. Who goes first flips every round.
		with (Deck_obj) move_side(global.FirstSide)
		state = "move_second"
		timer = think_delay
		break

	case "move_second":
		with (Deck_obj) move_side(-global.FirstSide)
		global.FirstSide *= -1
		state = "end"
		timer = think_delay
		break

	case "end":
		// Hand the turn back to the player
		state = "waiting"
		global.PlayerTurn = true
		global.HasDrawn = false
		global.UnitsMax = Deck_obj.units_per_turn + Deck_obj.lanes_won(1)
		global.Units = global.UnitsMax
		with (Deck_obj) show_reminder("Your turn, draw a card")
		break
}
