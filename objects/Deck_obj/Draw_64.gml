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
if (global.Winner == 1)
{
	// Coins earned, then continue
	draw_set_color(c_yellow)
	if (win_reward >= 0) draw_text_transformed(cx, cy + 30, "+" + string(win_reward) + " coins", 2, 2, 0)
	draw_set_color(c_white)
	draw_text_transformed(cx, cy + 80, "Click to continue", 1.5, 1.5, 0)
}
else
{
	// Two buttons: retry this stop, or go back to the menu
	var labels = ["retry", "menu"]
	for (var i = 0; i < 2; i++)
	{
		var b = lose_button(labels[i])
		var over = mouse_on_lose_button(labels[i])
		draw_set_color(over ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
		if (i == 1) draw_set_color(over ? make_color_rgb(130, 60, 60) : make_color_rgb(90, 40, 40))
		draw_rectangle(b.x1, b.y1, b.x2, b.y2, false)
		draw_set_color(c_white)
		draw_rectangle(b.x1, b.y1, b.x2, b.y2, true)
		var label = (i == 0) ? "Retry this stop" : "Back to menu"
		draw_text_transformed((b.x1 + b.x2) / 2, (b.y1 + b.y2) / 2, label, 1.5, 1.5, 0)
	}
	draw_text(cx, cy + 120, "Retrying keeps your coins and the items you had when this fight started")
}
draw_set_halign(fa_left)
draw_set_valign(fa_top)
