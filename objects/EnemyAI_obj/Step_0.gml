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
		// Keep playing cards until it can't afford any or runs out of room.
		// On a holding-back turn it stops after one card.
		var card = choose_card()
		var tiles = open_tiles()
		if (holding_back && cards_played >= 1) card = noone
		if (card != noone && array_length(tiles) > 0)
		{
			play_card(card, choose_tile(tiles))
			cards_played += 1
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

	case "skipped":
		// The AI was out of cards, so it skipped drawing and playing. Straight to the battle.
		state = "move"
		var skip_first_text = "Enemy attacks first"
		if (global.FirstSide == 1) skip_first_text = "You attack first"
		with (Deck_obj) show_reminder(skip_first_text)
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
		// If the player is out of cards, their turn is skipped and the AI goes again
		if (Deck_obj.check_skip())
		{
			state = "player_skipped"
			timer = skip_delay
			break
		}

		// Hand the turn back to the player
		state = "waiting"
		global.PlayerTurn = true
		global.HasDrawn = false
		global.UnitsMax = Deck_obj.units_per_turn + Deck_obj.lanes_won(1)
		global.Units = global.UnitsMax
		with (Deck_obj) show_reminder("Your turn, draw a card")
		break

	case "player_skipped":
		// The player's skipped turn is over (the skip message has been up), so the AI starts its next turn
		start_turn()
		break
}
