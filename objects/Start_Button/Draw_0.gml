// The button itself
draw_self()

// On the start screen: the Easy / Normal / Hard buttons under Start (clicks are in the Step event)
if (room != Menu_Room) exit

var names = difficulty_names()
var picked = difficulty()
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
for (var i = 0; i < 3; i++)
{
	var b = difficulty_button(i)
	var over = point_in_rectangle(mouse_x, mouse_y, b.x1, b.y1, b.x2, b.y2)
	var col = make_color_rgb(70, 50, 30)
	if (i == picked) col = make_color_rgb(40, 110, 60)
	if (over) col = merge_color(col, c_white, 0.3)
	draw_set_color(col)
	draw_rectangle(b.x1, b.y1, b.x2, b.y2, false)
	draw_set_color(c_white)
	draw_rectangle(b.x1, b.y1, b.x2, b.y2, true)
	draw_text_transformed_s((b.x1 + b.x2) / 2, (b.y1 + b.y2) / 2, names[i], 0.5, 0.5, 0)
}

// How to Play button
var hb = menu_help_button()
var over_help = point_in_rectangle(mouse_x, mouse_y, hb.x1, hb.y1, hb.x2, hb.y2) && !global.MenuHelpOpen
draw_set_color(over_help ? make_color_rgb(110, 80, 40) : make_color_rgb(70, 50, 30))
draw_rectangle(hb.x1, hb.y1, hb.x2, hb.y2, false)
draw_set_color(c_white)
draw_rectangle(hb.x1, hb.y1, hb.x2, hb.y2, true)
draw_text_transformed_s((hb.x1 + hb.x2) / 2, (hb.y1 + hb.y2) / 2, "How to Play", 0.5, 0.5, 0)

// How to Play overlay: the same text as in fights, plus the rulebook link
if (variable_global_exists("MenuHelpOpen") && global.MenuHelpOpen)
{
	var lay = menu_help_layout()
	draw_set_alpha(0.6)
	draw_set_color(c_black)
	draw_rectangle(0, 0, 341, 192, false)
	draw_set_alpha(1)
	draw_set_color(make_color_rgb(60, 40, 20))
	draw_rectangle(lay.px, lay.py, lay.px + lay.pw, lay.py + lay.ph, false)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_rectangle(lay.px, lay.py, lay.px + lay.pw, lay.py + lay.ph, true)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text_ext_transformed_s(lay.px + 8, lay.py + 6, lay.text, -1, lay.wrap, lay.ts, lay.ts, 0)

	var lk = lay.link
	var over_link = point_in_rectangle(mouse_x, mouse_y, lk.x1, lk.y1, lk.x2, lk.y2)
	draw_set_color(over_link ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
	draw_rectangle(lk.x1, lk.y1, lk.x2, lk.y2, false)
	draw_set_color(c_white)
	draw_rectangle(lk.x1, lk.y1, lk.x2, lk.y2, true)
	draw_set_halign(fa_center)
	draw_set_valign(fa_middle)
	draw_text_transformed_s((lk.x1 + lk.x2) / 2, (lk.y1 + lk.y2) / 2, "Open the full illustrated rulebook (new tab)", 0.38, 0.38, 0)
	draw_set_valign(fa_bottom)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_text_transformed_s(170, lay.py + lay.ph - 3, "Click anywhere to close", 0.45, 0.45, 0)
}
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
