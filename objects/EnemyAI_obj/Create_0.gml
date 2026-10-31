// The AI opponent. It plays by the same rules as the player: same units (4, ramping up),
// same draw rules and card costs. It starts with 4 cards (one more than you).
// The only thing still in your favor: you win with 3 of 4 lanes, it needs all 4.
//
// Each bot along the route (China to Baghdad) can be a child of this object
// that replaces choose_card and choose_tile with its own strategy.

randomize()

// The enemy's deck: 20 cards, 12 sailors, 5 jumpers, 3 artillery.
// It still runs out partway through a long fight (then it skips 3 turns, same rule as you).
full_deck = [
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardJumper_obj, CardJumper_obj, CardJumper_obj, CardJumper_obj, CardJumper_obj,
	CardArtillery_obj, CardArtillery_obj, CardArtillery_obj,
]
deck = array_shuffle(full_deck)

// Same out-of-cards rule as the player (see Deck_obj): an empty deck at the start
// of its turn makes the AI skip skip_turns turns, then its deck is reshuffled back to full
skip_turns = 3
skips_left = 0

starting_hand = 4
units_per_turn = 4   // same as you
units_max = units_per_turn
units = units_max
ai_turn = 0   // counts the AI's turns, for the early-turn unit ramp (see Deck_obj's unit_ramp)
max_hand = 7  // same hand limit as the player

// Chance each turn that the AI "saves up" and stops after playing one card
hold_back_chance = 0   // 0 = never holds back, plays every card it can afford
holding_back = false
cards_played = 0

// Calicut Stone Tablet item: the AI plays no cards for this many of its turns
blocked_turns = 0
blocked_this_turn = false

// Zebra item: the AI can't place figures in the lane at blocked_lane_x for this many of its turns
blocked_lane_x = -1
blocked_lane_turns = 0

// The AI's hand. These are real card instances, just hidden and kept out of the player's hand.
hand = []

front_row_y = 196    // the row of tiles the AI places figures on
move_limit_y = 452   // AI figures stop moving forward at this row

// How the AI's turn plays out, one step at a time so the player can follow it
think_delay = 12     // frames between each action (60 = 1 second)
skip_delay = 90      // how long a skipped turn's message stays up before moving on
state = "waiting"    // "waiting" means it's the player's turn
timer = 0

// Deck pile size, same as the player's
pile_width = 108
pile_height = 148

// Takes the top card off the AI's deck and puts it in the AI's hand
draw_card = function()
{
	if (array_length(deck) == 0) return noone
	if (array_length(hand) >= max_hand) return noone
	var card_type = array_pop(deck)
	var card = instance_create_layer(x, y, layer, card_type)
	card.in_hand = false   // keeps it out of the player's hand
	card.visible = false
	array_push(hand, card)
	return card
}

// Bot strategy: which card to play next, or noone to stop playing this turn.
// This basic bot plays the most expensive card it can afford.
choose_card = function()
{
	var best = noone
	for (var i = 0; i < array_length(hand); i++)
	{
		var card = hand[i]
		if (card.figure != noone && card.cost <= units)
		{
			if (best == noone || card.cost > best.cost) best = card
		}
	}
	return best
}

// Bot strategy: which open tile to play on. This basic bot picks one at random.
choose_tile = function(tiles)
{
	return tiles[irandom(array_length(tiles) - 1)]
}

// Every empty tile in the AI's front row
open_tiles = function()
{
	var row_y = front_row_y
	var tiles = []
	// The Zebra item can block one lane so the enemy can't place figures in it
	var blocked_x = (blocked_lane_turns > 0) ? blocked_lane_x : -1
	with (Tile_obj)
	{
		if (y == row_y && x != blocked_x && !instance_position(x, y, FigureParent_obj)) array_push(tiles, id)
	}
	return tiles
}

// Pays for a card and puts its figure on the tile
play_card = function(card, tile)
{
	var fig = instance_create_layer(tile.x, tile.y, "SpawnChecker", card.figure)
	fig.team = -1
	fig.image_yscale = -1                          // faces the player
	fig.image_blend = make_color_rgb(255, 170, 170)  // light red so you can tell it apart

	units -= card.cost
	dbg("AI placed " + object_get_name(card.figure) + " in lane x=" + string(tile.x) + " (units left " + string(units) + ")")
	array_delete(hand, array_get_index(hand, card), 1)
	instance_destroy(card)
}

// Called by the turn token when the player ends their turn
start_turn = function()
{
	// Same rule as the player: base units, plus the early-turn ramp, plus 1 per lane it holds
	ai_turn += 1
	units_max = units_per_turn + Deck_obj.unit_ramp(ai_turn) + Deck_obj.lanes_won(-1)
	units = units_max
	state = "draw"
	timer = think_delay
	holding_back = random(1) < hold_back_chance
	dbg("AI turn " + string(ai_turn) + ": units " + string(units) + ", hand " + string(array_length(hand)) + ", deck " + string(array_length(deck)) + (holding_back ? ", holding back" : ""))
	cards_played = 0
	blocked_this_turn = blocked_turns > 0
	if (blocked_this_turn)
	{
		blocked_turns -= 1
		with (Deck_obj) show_reminder("The enemy honors the Calicut tablet and plays no cards")
	}

	// Out of cards: skip drawing and playing, go straight to the battle
	if (skips_left == 0 && array_length(deck) == 0) skips_left = skip_turns
	if (skips_left > 0)
	{
		skips_left -= 1
		if (skips_left > 0)
		{
			with (Deck_obj) show_reminder("Enemy is out of cards! Turn skipped (" + string(other.skips_left) + " more)")
		}
		else
		{
			with (Deck_obj) show_reminder("Enemy's last skipped turn, its deck is reshuffled")
			deck = array_shuffle(full_deck)
		}
		state = "skipped"
		dbg("AI out of cards, turn skipped (" + string(skips_left) + " more)")
		timer = skip_delay
	}
}

// Hard bot placement: puts figures in the lanes where your figures are furthest along,
// to block the lanes you're winning (ties are picked at random)
smart_tile = function(tiles)
{
	var best = []
	var best_score = -1
	for (var i = 0; i < array_length(tiles); i++)
	{
		var lane_x = tiles[i].x
		var lane_score = 0
		with (FigureParent_obj)
		{
			if (x == lane_x && team == 1) lane_score += 1 + rows_from_home(y)
		}
		if (lane_score > best_score)
		{
			best_score = lane_score
			best = [tiles[i]]
		}
		else if (lane_score == best_score) array_push(best, tiles[i])
	}
	return best[irandom(array_length(best) - 1)]
}

// ---- Difficulty (picked on the start screen, see difficulty() in Items_scr) ----
// Easy: 3 units a turn to start with, and 1 turn in 4 it stops after one card.
// Normal: everything above as it is.
// Hard: 5 units a turn to start with, 1 more card in its starting hand,
// and it places figures to block the lanes you're winning.
switch (difficulty())
{
	case 0:
		units_per_turn = 3
		hold_back_chance = 0.25
		break
	case 2:
		units_per_turn = 5
		starting_hand = 5
		choose_tile = smart_tile
		break
}
// ---- Final fight (coast of Iraq): the boss ----
// Whatever the difficulty: a deck with Runners and Swordsmen, at least 6 units a turn and 6 starting
// cards, it never holds back, it blocks the lanes you're winning, and it only needs 3 of your
// 4 lights (see LaneEndLight_obj). Tested in the balance sim: very hard even for strong players.
if (is_boss_fight())
{
	full_deck = [
		CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
		CardJumper_obj, CardJumper_obj, CardJumper_obj, CardJumper_obj,
		CardArtillery_obj, CardArtillery_obj,
		CardRunner_obj, CardRunner_obj, CardRunner_obj, CardRunner_obj,
		CardSwordsman_obj, CardSwordsman_obj, CardSwordsman_obj, CardSwordsman_obj
	]
	deck = array_shuffle(full_deck)
	units_per_turn = max(units_per_turn, 6)
	starting_hand = max(starting_hand, 6)
	hold_back_chance = 0
	choose_tile = smart_tile
}
units_max = units_per_turn
units = units_max

repeat (starting_hand) draw_card()
