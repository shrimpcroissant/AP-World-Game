// Lays out every card in the hand as a fan, like cards held in real life.
// Works for any object whose parent is CardParent_obj.

// Hand settings, tweak these
var hand_center_x = room_width / 2
var hand_bottom_y = room_height - 20  // where the bottom of the middle card sits
var spacing = 80    // pixels between each card (smaller = more overlap)
var tilt = 6        // degrees each card tilts, per step away from the middle
var drop = 6        // how much the outer cards dip down
var move_speed = 0.2  // 1 = snap instantly, smaller = slide in smoother
var hover_lift = 30  // how far a card rises when the mouse is over it

if (!in_hand) exit

// Collect every card in the hand and sort by the order they were made
var cards = []
with (CardParent_obj)
{
	if (in_hand) array_push(cards, id)
}
array_sort(cards, function(a, b) { return a.hand_order - b.hand_order })

var count = array_length(cards)
var index = 0
for (var i = 0; i < count; i++)
{
	if (cards[i] == id) { index = i; break }
}

// offset is 0 for the middle card, negative on the left, positive on the right
var offset = index - (count - 1) / 2

rest_x = hand_center_x + offset * spacing
rest_y = hand_bottom_y + offset * offset * drop
rest_angle = -offset * tilt

// Only the top card under the mouse lifts (cards further right sit on top)
hovered = false
var paused = variable_global_exists("paused") && global.paused
if (!paused) for (var j = count - 1; j >= 0; j--)
{
	if (cards[j].is_mouse_over())
	{
		hovered = (cards[j] == id)
		break
	}
}

// Click a card to choose it, click it again to put it back
if (hovered && mouse_check_button_pressed(mb_left) && global.PlayerTurn && !global.DaggerAiming)
{
	if (global.SelectedCard == id)
	{
		global.SelectedCard = noone
	}
	else if (instance_exists(Deck_obj) && !Deck_obj.can_play())
	{
		// Must draw first, so remind the player above the deck
		with (Deck_obj) show_reminder("Draw a card first")
	}
	else if (cost > global.Units)
	{
		with (Deck_obj) show_reminder("Not enough units")
	}
	else
	{
		global.SelectedCard = id
	}
}

// The chosen card sits higher than a hovered one
var target_y = rest_y
if (global.SelectedCard == id) target_y -= hover_lift * 2
else if (hovered) target_y -= hover_lift

// The chosen card pulses so it's clear which one you picked
if (global.SelectedCard == id)
{
	var pulse = 1 + 0.06 * sin(current_time / 120)
	image_xscale = card_scale * pulse
	image_yscale = card_scale * pulse
}
else
{
	image_xscale = card_scale
	image_yscale = card_scale
}

x = lerp(x, rest_x, move_speed)
y = lerp(y, target_y, move_speed)
image_angle = lerp(image_angle, rest_angle, move_speed)

// Cards you can't afford right now are dimmed, and cards on their last turn in your hand are orange
var last_turn = instance_exists(Deck_obj) && turns_in_hand >= Deck_obj.hand_turns - 1
if (global.PlayerTurn && cost > global.Units) image_blend = last_turn ? make_color_rgb(150, 100, 60) : c_gray
else image_blend = last_turn ? make_color_rgb(255, 170, 90) : c_white

// Cards further right draw on top
depth = hand_depth - index
