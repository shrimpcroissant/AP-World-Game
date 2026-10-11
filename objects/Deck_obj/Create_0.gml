// The deck. Click it to draw a card into your hand.

// GameMaker uses the same random seed every run unless you call this,
// so without it the shuffle would come out the same every time
randomize()

// Every card in the deck. To add a card, put its object in this list.
// Any object whose parent is CardParent_obj works.
deck = [Card_obj, Card_obj, Card_obj, CardSailor_obj]
deck = array_shuffle(deck)

starting_hand = 3  // cards drawn at the start

// Size of the deck pile, matches the cards in hand (54 x 74 art at 2x)
pile_width = 108
pile_height = 148
back_sprite = noone  // set this to a card back sprite when you make one

// Takes the top card off the deck and puts it in the hand
draw_card = function()
{
	if (array_length(deck) == 0) return noone
	var card_type = array_pop(deck)
	return instance_create_layer(x, y, layer, card_type)
}

repeat (starting_hand) draw_card()
