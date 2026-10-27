// Draw GUI: the "?" help button, the story and "How to play" panels, and the win or lose
// message, all drawn over everything. The cursor is drawn last so it's on top of all of them.

// "?" button, top right
var gw = display_get_gui_width()
var gh = display_get_gui_height()
var gmx = device_mouse_x_to_gui(0)
var gmy = device_mouse_y_to_gui(0)
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

if (global.HelpOpen && story_open)
{
	// Story screen (uses the same pause as the "How to play" panel)
	draw_story_panel(0, 0, gw, gh, 1, story_shown, hold / hold_needed)
}
else if (global.HelpOpen)
{
	// "How to play" panel: text wrapped to fit, shrunk if the screen is short
	draw_set_alpha(0.6)
	draw_set_color(c_black)
	draw_rectangle(0, 0, gw, gh, false)
	draw_set_alpha(1)

	var wrap = 780
	var th = string_height_ext(help_text, -1, wrap)
	var ts = min(1.3, (gh - 170) / th)   // text size
	var pw = string_width_ext(help_text, -1, wrap) * ts + 60
	var ph = th * ts + 50 + 60
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
	draw_text_ext_transformed(px + 30, py + 25, help_text, -1, wrap, ts, ts, 0)
	if (needs_hold) draw_hold_bar(gw / 2, py + ph - 70, 300, 1, hold / hold_needed)
	else
	{
		draw_set_halign(fa_center)
		draw_set_alpha(0.65 + 0.35 * sin(current_time / 200))
		draw_text_transformed(gw / 2, py + ph - 45, "Click anywhere to close", 1.2, 1.2, 0)
		draw_set_alpha(1)
	}
}
else if (tutorial_step >= 0 && global.Winner == 0)
{
	// China tutorial prompt at the top of the screen
	var b = tutorial_box()
	draw_set_alpha(0.9)
	draw_set_color(make_color_rgb(60, 40, 20))
	draw_rectangle(b.x1, b.y1, b.x2, b.y2, false)
	draw_set_alpha(1)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_rectangle(b.x1, b.y1, b.x2, b.y2, true)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_yellow)
	draw_text(b.x1 + 14, b.y1 + 8, "TUTORIAL  " + string(tutorial_step + 1) + " / " + string(array_length(tutorial_steps)))
	draw_set_color(c_white)
	draw_text_transformed(b.x1 + 14, b.y1 + 28, tutorial_steps[tutorial_step].text, 1.2, 1.2, 0)

	var names = ["next", "skip"]
	var over = tutorial_hit(gmx, gmy)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	for (var i = 0; i < 2; i++)
	{
		var r = tutorial_button(names[i])
		if (i == 0) draw_set_color(over == "next" ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
		else draw_set_color(over == "skip" ? make_color_rgb(110, 80, 40) : make_color_rgb(70, 50, 30))
		draw_rectangle(r.x1, r.y1, r.x2, r.y2, false)
		draw_set_color(c_white)
		draw_rectangle(r.x1, r.y1, r.x2, r.y2, true)
		draw_text((r.x1 + r.x2) / 2, (r.y1 + r.y2) / 2, (i == 0) ? "Next" : "Skip tutorial")
	}
}
else if (global.Winner != 0)
{
	var cx = gw / 2
	var cy = gh / 2

	draw_set_alpha(0.6)
	draw_set_color(c_black)
	draw_rectangle(0, 0, gw, gh, false)
	draw_set_alpha(1)

	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	if (global.Winner == 1)
	{
		draw_set_color(c_lime)
		draw_text_transformed(cx, cy - 30, "You win!", 4, 4, 0)
		// Coins earned, then continue
		draw_set_color(c_yellow)
		if (win_reward >= 0) draw_text_transformed(cx, cy + 30, "+" + string(win_reward) + " coins", 2, 2, 0)
		draw_set_color(c_white)
		draw_text_transformed(cx, cy + 80, "Click to continue", 1.5, 1.5, 0)
	}
	else
	{
		draw_set_color(c_red)
		draw_text_transformed(cx, cy - 30, "You lose!", 4, 4, 0)
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
}

draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// The cursor, on top of everything (Mouse_obj hides itself in fights, see its Step event)
draw_cursor_gui()
