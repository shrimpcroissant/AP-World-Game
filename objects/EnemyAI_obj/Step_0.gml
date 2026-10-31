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
		// Same rule as the player: 1 card, plus 1 extra for every 4 units it gets this turn
		repeat (1 + units_max div 4) draw_card()
		state = "play"
		timer = think_delay
		break

	case "play":
		// Keep playing cards until it can't afford any or runs out of room.
		// On a holding-back turn it stops after one card.
		var card = choose_card()
		var tiles = open_tiles()
		if (holding_back && cards_played >= 1) card = noone
		if (blocked_this_turn) card = noone   // Calicut Stone Tablet item
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
		// The Zebra's lane block counts down once per enemy turn
		if (blocked_lane_turns > 0) blocked_lane_turns -= 1

		// Battle phase: one side acts, then the other. Who goes first flips every round.
		var t_move = get_timer()
		with (Deck_obj) move_side(global.FirstSide)
		dbg_time("battle, first side", t_move, 2)
		dbg("Battle: side " + string(global.FirstSide) + " moved, figures left " + string(instance_number(FigureParent_obj)))
		state = "move_second"
		timer = think_delay
		break

	case "move_second":
		var t_move2 = get_timer()
		with (Deck_obj) move_side(-global.FirstSide)
		dbg_time("battle, second side", t_move2, 2)
		dbg("Battle: side " + string(-global.FirstSide) + " moved, figures left " + string(instance_number(FigureParent_obj)))
		global.FirstSide *= -1
		state = "end"
		timer = think_delay
		break

	case "end":
		// Out of cards: you still get your turn and can play your hand, you just can't draw.
		// Your hand doesn't age on those turns.
		var no_draw = Deck_obj.check_skip()
		Deck_obj.draw_skipped = no_draw

		// Cards that have been in your hand too long are discarded
		var discarded = no_draw ? 0 : Deck_obj.age_hand()
		dbg("Your turn: no_draw " + string(no_draw) + ", discarded " + string(discarded) + ", deck " + string(array_length(Deck_obj.deck)))

		// Hand the turn back to the player
		state = "waiting"
		global.PlayerTurn = true
		global.HasDrawn = no_draw   // nothing to draw on an out-of-cards turn
		Deck_obj.player_turn += 1
		global.UnitsMax = Deck_obj.units_per_turn + Deck_obj.unit_ramp(Deck_obj.player_turn) + Deck_obj.lanes_won(1)
		global.Units = global.UnitsMax
		if (!no_draw) with (Deck_obj) show_reminder("Your turn")
		with (Deck_obj) show_discarded(discarded)

		// Sack of Black Pepper item: +1 unit at the start of your turn while it lasts
		if (variable_global_exists("PepperTurns") && global.PepperTurns > 0)
		{
			global.PepperTurns -= 1
			global.Units += 1
			with (Deck_obj) add_popup(x, y - 90, "Pepper: +1 unit", c_orange)
		}
		break

	case "player_skipped":
		// The player's skipped turn is over (the skip message has been up), so the AI starts its next turn
		start_turn()
		break
}
