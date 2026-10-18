// The AI opponent. It plays by the same rules as the player:
// it starts with 3 cards, draws 1 card each turn, gets 3 units each turn,
// and pays the same card costs.
//
// Each bot along the route (China to Baghdad) can be a child of this object
// that replaces choose_card and choose_tile with its own strategy.

randomize()

// Same deck as the player: 15 sailors, 3 jumpers, 2 artillery (artillery is 10% of the deck)
deck = [
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardJumper_obj, CardJumper_obj, CardJumper_obj,
	CardArtillery_obj, CardArtillery_obj,
]
deck = array_shuffle(deck)

starting_hand = 3
units_per_turn = 3
units_max = units_per_turn
units = units_max

// The AI's hand. These are real card instances, just hidden and kept out of the player's hand.
hand = []

front_row_y = 196    // the row of tiles the AI places figures on
move_limit_y = 452   // AI figures stop moving forward at this row

// How the AI's turn plays out, one step at a time so the player can follow it
think_delay = 20     // frames between each action (60 = 1 second)
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
	with (Tile_obj)
	{
		if (y == row_y && !instance_position(x, y, FigureParent_obj)) array_push(tiles, id)
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
}

repeat (starting_hand) draw_card()
