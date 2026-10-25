// The AI opponent. It mostly plays by the same rules as the player:
// it starts with 4 cards (one more than you), draws 1 card each turn, and pays the same card costs.
// To keep fights beginner-friendly it's a bit weaker: 2 units a turn instead of 3,
// and some turns it holds back after one card (see hold_back_chance).
//
// Each bot along the route (China to Baghdad) can be a child of this object
// that replaces choose_card and choose_tile with its own strategy.

randomize()

// A smaller deck than yours, so the enemy runs out of cards partway through a fight
// (it then skips 3 turns, same rule as you): 12 cards, 9 sailors, 2 jumpers, 1 artillery.
full_deck = [
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardJumper_obj, CardJumper_obj,
	CardArtillery_obj,
]
deck = array_shuffle(full_deck)

// Same out-of-cards rule as the player (see Deck_obj): an empty deck at the start
// of its turn makes the AI skip skip_turns turns, then its deck is reshuffled back to full
skip_turns = 3
skips_left = 0

starting_hand = 4
units_per_turn = 2
units_max = units_per_turn
units = units_max

// Chance each turn that the AI "saves up" and stops after playing one card
hold_back_chance = 1 / 5
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
	array_delete(hand, array_get_index(hand, card), 1)
	instance_destroy(card)
}

// Called by the turn token when the player ends their turn
start_turn = function()
{
	// Same rule as the player: base units plus 1 per lane it holds
	units_max = units_per_turn + Deck_obj.lanes_won(-1)
	units = units_max
	state = "draw"
	timer = think_delay
	holding_back = random(1) < hold_back_chance
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
		timer = skip_delay
	}
}

repeat (starting_hand) draw_card()
