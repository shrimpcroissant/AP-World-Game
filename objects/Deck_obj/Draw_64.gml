// Draw GUI: the win or lose message, drawn over everything in the middle of the screen
if (global.Winner == 0) exit

var cx = display_get_gui_width() / 2
var cy = display_get_gui_height() / 2

draw_set_alpha(0.6)
draw_set_color(c_black)
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false)
draw_set_alpha(1)

draw_set_halign(fa_center)
draw_set_valign(fa_middle)
if (global.Winner == 1)
{
	draw_set_color(c_lime)
	draw_text_transformed(cx, cy - 30, "You win!", 4, 4, 0)
}
else
{
	draw_set_color(c_red)
	draw_text_transformed(cx, cy - 30, "You lose!", 4, 4, 0)
}
draw_set_color(c_white)
draw_text_transformed(cx, cy + 40, "Click to return to the menu", 1.5, 1.5, 0)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
