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
	draw_text_transformed((b.x1 + b.x2) / 2, (b.y1 + b.y2) / 2, names[i], 0.5, 0.5, 0)
}
draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
