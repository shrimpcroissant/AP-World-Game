draw_self()

// Glows once you've drawn, as a hint that ending your turn is next
var cx = x + sprite_width / 2
var ready = global.PlayerTurn && global.HasDrawn && global.Winner == 0
if (ready)
{
	var pulse = 0.5 + 0.5 * sin(current_time / 150)
	draw_set_alpha(0.3 + 0.5 * pulse)
	draw_set_color(c_yellow)
	draw_rectangle(bbox_left - 3, bbox_top - 3, bbox_right + 3, bbox_bottom + 3, true)
	draw_rectangle(bbox_left - 4, bbox_top - 4, bbox_right + 4, bbox_bottom + 4, true)
	draw_set_alpha(1)
}

draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
draw_text(cx, bbox_bottom + 6, "End turn")
draw_text(cx, bbox_bottom + 22, "(Space)")
draw_set_halign(fa_left)
