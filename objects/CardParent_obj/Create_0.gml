// Shared setup for every card.
// Child cards: put event_inherited() at the top of your Create event.

// How big cards are drawn. Whole numbers keep pixel art sharp.
card_scale = 2
image_xscale = card_scale
image_yscale = card_scale

// The figure this card places on the board when played.
// Set it in each card's own Create event, under event_inherited().
figure = noone

// How many units it costs to play this card. Set it in each card's own Create event.
cost = 0

// The card you've clicked on, waiting to be played on the board
if (!variable_global_exists("SelectedCard")) global.SelectedCard = noone

// Cards in the hand draw just above the layer they were created on
hand_depth = depth

// Cards with in_hand = true get laid out in the hand fan
in_hand = true

// Remembers the order cards were made in, so the hand keeps a stable order
if (!variable_global_exists("CardOrder"))
{
	global.CardOrder = 0
}
hand_order = global.CardOrder
global.CardOrder += 1

// Where this card rests in the hand (set by the Step event).
// Hover checks use this spot, so a card doesn't flicker as it lifts away from the mouse.
rest_x = x
rest_y = y
rest_angle = 0
hovered = false

// True if the mouse is over this card's resting spot, tilt included
is_mouse_over = function()
{
	var w = (sprite_get_bbox_right(sprite_index) - sprite_get_bbox_left(sprite_index) + 1) * image_xscale
	var h = (sprite_get_bbox_bottom(sprite_index) - sprite_get_bbox_top(sprite_index) + 1) * image_yscale

	// Mouse position relative to the card's bottom-center, un-rotated
	var dx = mouse_x - rest_x
	var dy = mouse_y - rest_y
	var lx = dx * dcos(rest_angle) - dy * dsin(rest_angle)
	var ly = dx * dsin(rest_angle) + dy * dcos(rest_angle)

	return (abs(lx) <= w / 2 && ly <= 0 && ly >= -h)
}
