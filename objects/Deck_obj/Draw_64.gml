// Draw GUI: the "?" help button, the story and "How to play" panels, and the win or lose
// message, all drawn over everything. The cursor is drawn last so it's on top of all of them.

// "?" button, top right
var gw = display_get_gui_width()
var gh = display_get_gui_height()
var gmx = gui_mouse_x()
var gmy = gui_mouse_y()
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
	draw_text_transformed_s(qx + help_btn_size / 2, qy + help_btn_size / 2, "?", 2.5, 2.5, 0)
}

if (global.HelpOpen && story_open)
{
	// Story screen (uses the same pause as the "How to play" panel)
	draw_story_panel(0, 0, gw, gh, 1, story_shown, hold / hold_needed)
}
else if (global.HelpOpen)
{
	// "How to play" panel: text wrapped to fit, shrunk if the screen is short (see help_layout)
	draw_set_alpha(0.6)
	draw_set_color(c_black)
	draw_rectangle(0, 0, gw, gh, false)
	draw_set_alpha(1)

	var lay = help_layout()
	var px = lay.px
	var py = lay.py
	var pw = lay.pw
	var ph = lay.ph
	draw_set_color(make_color_rgb(60, 40, 20))
	draw_rectangle(px, py, px + pw, py + ph, false)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_rectangle(px, py, px + pw, py + ph, true)
	draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text_ext_transformed_s(px + 30, py + 25, help_text, -1, lay.wrap, lay.ts, lay.ts, 0)

	// Rulebook link (opens the website's illustrated rulebook in a new tab)
	var lnk = lay.link
	var over_link = help_link_hit()
	draw_set_color(over_link ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
	draw_rectangle(lnk.x1, lnk.y1, lnk.x2, lnk.y2, false)
	draw_set_color(c_white)
	draw_rectangle(lnk.x1, lnk.y1, lnk.x2, lnk.y2, true)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed_s((lnk.x1 + lnk.x2) / 2, (lnk.y1 + lnk.y2) / 2, "Open the full illustrated rulebook (new tab)", 1.1, 1.1, 0)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	if (needs_hold) draw_hold_bar(gw / 2, py + ph - 70, 300, 1, hold / hold_needed)
	else
	{
		draw_set_halign(fa_center)
		draw_set_alpha(0.65 + 0.35 * sin(current_time / 200))
		draw_text_transformed_s(gw / 2, py + ph - 45, "Click anywhere to close", 1.2, 1.2, 0)
		draw_set_alpha(1)
	}
}
else if (tutorial_step >= 0 && global.Winner == 0)
{
	// China tutorial: dim everything except the highlighted area, outline it, then the prompt box
	var spot = tutorial_spot()
	draw_set_alpha(0.6)
	draw_set_color(c_black)
	if (spot == undefined) draw_rectangle(0, 0, gw, gh, false)
	else
	{
		// Four dark bands around the highlight
		draw_rectangle(0, 0, gw, spot.y1, false)
		draw_rectangle(0, spot.y2, gw, gh, false)
		draw_rectangle(0, spot.y1, spot.x1, spot.y2, false)
		draw_rectangle(spot.x2, spot.y1, gw, spot.y2, false)
	}
	draw_set_alpha(1)
	if (spot != undefined)
	{
		var glow = 0.5 + 0.5 * sin(current_time / 150)
		draw_set_alpha(0.5 + 0.5 * glow)
		draw_set_color(c_yellow)
		draw_rectangle(spot.x1, spot.y1, spot.x2, spot.y2, true)
		draw_rectangle(spot.x1 - 1, spot.y1 - 1, spot.x2 + 1, spot.y2 + 1, true)
		draw_rectangle(spot.x1 - 2, spot.y1 - 2, spot.x2 + 2, spot.y2 + 2, true)
		draw_set_alpha(1)
	}

	// Prompt box: the text wraps to the box width, and the box is as tall as the text needs
	var b = tutorial_box()
	draw_set_alpha(0.95)
	draw_set_color(make_color_rgb(60, 40, 20))
	draw_rectangle(b.x1, b.y1, b.x2, b.y2, false)
	draw_set_alpha(1)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_rectangle(b.x1, b.y1, b.x2, b.y2, true)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_set_color(c_yellow)
	draw_text_s(b.x1 + 14, b.y1 + 8, "TUTORIAL  " + string(tutorial_step + 1) + " / " + string(array_length(tutorial_steps)))
	draw_set_color(c_white)
	draw_text_ext_transformed_s(b.x1 + 14, b.y1 + 30, tutorial_steps[tutorial_step].text, -1, b.wrap, tutorial_text_scale, tutorial_text_scale, 0)

	// Buttons: Skip (not on the last step), Next on steps that wait for it (greyed out during the
	// battle until it's over), and on the battle step a play button with what the next phase does
	var over = tutorial_hit(gmx, gmy)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	var names = []
	if (tutorial_has_next()) array_push(names, "next")
	if (tutorial_has_skip()) array_push(names, "skip")
	for (var i = 0; i < array_length(names); i++)
	{
		var r = tutorial_button(names[i])
		if (names[i] == "next")
		{
			if (!tutorial_next_enabled()) draw_set_color(make_color_rgb(55, 55, 55))
			else draw_set_color(over == "next" ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
		}
		else draw_set_color(over == "skip" ? make_color_rgb(110, 80, 40) : make_color_rgb(70, 50, 30))
		draw_rectangle(r.x1, r.y1, r.x2, r.y2, false)
		draw_set_color((names[i] == "next" && !tutorial_next_enabled()) ? c_gray : c_white)
		draw_rectangle(r.x1, r.y1, r.x2, r.y2, true)
		draw_text_s((r.x1 + r.x2) / 2, (r.y1 + r.y2) / 2, (names[i] == "next") ? "Next" : "Skip tutorial")
	}
	if (tutorial_has_play())
	{
		var pb = tutorial_button("play")
		var can_play = tutorial_play_enabled()
		if (!can_play) draw_set_color(make_color_rgb(55, 55, 55))
		else draw_set_color(over == "play" ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
		draw_rectangle(pb.x1, pb.y1, pb.x2, pb.y2, false)
		draw_set_color(can_play ? c_white : c_gray)
		draw_rectangle(pb.x1, pb.y1, pb.x2, pb.y2, true)
		// Right-facing triangle
		var cx = (pb.x1 + pb.x2) / 2
		var cy = (pb.y1 + pb.y2) / 2
		draw_triangle(cx - 6, cy - 9, cx - 6, cy + 9, cx + 9, cy, false)

		// What happens next (or what's happening now)
		var label = ""
		if (global.PlayerTurn) label = "Battle over! Press Next."
		else if (can_play) label = tutorial_phase_label(EnemyAI_obj.state)
		else label = "Playing..."
		draw_set_halign(fa_left)
		draw_set_valign(fa_middle)
		draw_set_color(can_play ? c_yellow : c_white)
		var label_w = tutorial_button("skip").x1 - pb.x2 - 20
		draw_text_ext_s(pb.x2 + 10, cy, label, -1, label_w)
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
		draw_text_transformed_s(cx, cy - 30, "You win!", 4, 4, 0)
		// Coins earned, then continue
		draw_set_color(c_yellow)
		if (win_reward >= 0) draw_text_transformed_s(cx, cy + 30, "+" + string(win_reward) + " coins", 2, 2, 0)
		draw_set_color(c_white)
		draw_text_transformed_s(cx, cy + 80, "Click to continue", 1.5, 1.5, 0)
	}
	else if (is_boss_fight())
	{
		// Final fight: always lost (it's scripted), then on to the ending. No Retry.
		draw_set_color(c_red)
		draw_text_transformed_s(cx, cy - 60, global.BossOpe ? "Ope!" : "Defeated!", 4, 4, 0)
		draw_set_color(c_white)
		var why = global.BossOpe ? "It looked like you were going to win, but... you did not." : "The enemy fleet overwhelms you."
		draw_text_transformed_s(cx, cy + 10, why, 1.6, 1.6, 0)
		draw_text_transformed_s(cx, cy + 80, "Click to continue", 1.5, 1.5, 0)
	}
	else
	{
		draw_set_color(c_red)
		draw_text_transformed_s(cx, cy - 30, "You lose!", 4, 4, 0)
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
			draw_text_transformed_s((b.x1 + b.x2) / 2, (b.y1 + b.y2) / 2, label, 1.5, 1.5, 0)
		}
		draw_text_s(cx, cy + 120, "Retrying keeps your coins and the items you had when this fight started")
	}
}

draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// The cursor, on top of everything (Mouse_obj hides itself in fights, see its Step event)
draw_cursor_gui()
