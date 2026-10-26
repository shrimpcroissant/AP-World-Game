// Draw GUI: the "?" help button, the "How to play" panel, and the win or lose message,
// all drawn over everything

// "?" button, top right
var gw = display_get_gui_width()
var gh = display_get_gui_height()
if (global.Winner == 0)
{
	var qx = gw - help_btn_size - 20
	var qy = 20
	draw_set_color(help_button_hit() ? make_color_rgb(110, 80, 40) : make_color_rgb(50, 35, 20))
	draw_rectangle(qx, qy, qx + help_btn_size, qy + help_btn_size, false)
	draw_set_color(c_white)
	draw_rectangle(qx, qy, qx + help_btn_size, qy + help_btn_size, true)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed(qx + help_btn_size / 2, qy + help_btn_size / 2, "?", 2.5, 2.5, 0)
}

// "How to play" panel
if (global.HelpOpen)
{
	draw_set_alpha(0.6)
	draw_set_color(c_black)
	draw_rectangle(0, 0, gw, gh, false)
	draw_set_alpha(1)

	var ts = 1.4   // text size
	var pw = string_width(help_text) * ts + 60
	var ph = string_height(help_text) * ts + 50
	var px = gw / 2 - pw / 2
	var py = gh / 2 - ph / 2
	draw_set_color(make_color_rgb(60, 40, 20))
	draw_rectangle(px, py, px + pw, py + ph, false)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_rectangle(px, py, px + pw, py + ph, true)
	draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text_transformed(px + 30, py + 25, help_text, ts, ts, 0)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	exit
}

if (global.Winner == 0)
{
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	exit
}

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
