// Draws the AI's deck pile, its units, and how many cards it holds
var left = x - pile_width / 2
var top = y - pile_height / 2

draw_set_halign(fa_center)

if (array_length(deck) > 0)
{
	draw_set_color(make_color_rgb(110, 35, 35))
	draw_rectangle(left, top, left + pile_width, top + pile_height, false)
	draw_set_color(c_white)
	draw_rectangle(left, top, left + pile_width, top + pile_height, true)
	draw_set_valign(fa_middle)
	draw_text(x, y, string(array_length(deck)))
}
else
{
	// Empty deck: show that the AI's turns will be skipped
	draw_set_color(c_white)
	draw_set_valign(fa_middle)
	var skip_text = "Out of cards!"
	if (skips_left > 0) skip_text += "\nSkipping " + string(skips_left) + " more"
	else skip_text += "\nNext turn is skipped"
	draw_text(x, y, skip_text)
}

draw_set_color(c_white)
draw_set_valign(fa_top)
draw_text_transformed(x, y + pile_height / 2 + 8, "Enemy units: " + string(units) + " / " + string(units_max), 1.5, 1.5, 0)
draw_text_transformed(x, y + pile_height / 2 + 32, "Enemy hand: " + string(array_length(hand)), 1.5, 1.5, 0)

if (state != "waiting")
{
	draw_set_valign(fa_bottom)
	draw_text_transformed(x, top - 10, "Enemy's turn...", 1.5, 1.5, 0)
}

draw_set_halign(fa_left)
draw_set_valign(fa_top)
