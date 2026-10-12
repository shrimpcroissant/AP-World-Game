// Draws the deck pile centered on x, y, with how many cards are left,
// and any reminder text just above it

if (message_timer > 0)
{
	// Fades out over the last half second
	draw_set_alpha(min(1, message_timer / 30))
	draw_set_color(c_white)
	draw_set_halign(fa_center)
	draw_set_valign(fa_bottom)
	draw_text_transformed(x, y - pile_height / 2 - 10, message, 1.5, 1.5, 0)
	draw_set_alpha(1)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
}

// Units left this turn, just below the deck
draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_text_transformed(x, y + pile_height / 2 + 8, "Units: " + string(global.Units) + " / " + string(global.UnitsMax), 1.5, 1.5, 0)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

if (array_length(deck) == 0) exit

var left = x - pile_width / 2
var top = y - pile_height / 2

if (back_sprite != noone)
{
	draw_sprite_stretched(back_sprite, 0, left, top, pile_width, pile_height)
}
else
{
	// Placeholder card back until there's art for it
	draw_set_color(make_color_rgb(90, 60, 35))
	draw_rectangle(left, top, left + pile_width, top + pile_height, false)
	draw_set_color(c_white)
	draw_rectangle(left, top, left + pile_width, top + pile_height, true)
}

// Glows when it's your turn and you haven't drawn yet
if (global.PlayerTurn && !global.HasDrawn && global.Winner == 0)
{
	var pulse = 0.5 + 0.5 * sin(current_time / 150)
	draw_set_alpha(0.3 + 0.5 * pulse)
	draw_set_color(c_yellow)
	draw_rectangle(left - 4, top - 4, left + pile_width + 4, top + pile_height + 4, true)
	draw_rectangle(left - 5, top - 5, left + pile_width + 5, top + pile_height + 5, true)
	draw_set_alpha(1)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_text(x, y + 20, "Click to draw")
}

draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(x, y, string(array_length(deck)))
draw_set_halign(fa_left)
draw_set_valign(fa_top)
