// Draws the deck pile centered on x, y, with how many cards are left
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

draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text(x, y, string(array_length(deck)))
draw_set_halign(fa_left)
draw_set_valign(fa_top)
