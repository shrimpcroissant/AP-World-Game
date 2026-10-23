// Draw End: damage numbers and dying figures, drawn on top of the board
for (var i = array_length(effects) - 1; i >= 0; i--)
{
	var e = effects[i]
	var k = e.t / e.life   // goes from 1 down to 0
	if (e.kind == "text")
	{
		draw_set_halign(fa_center)
		draw_set_valign(fa_middle)
		draw_set_alpha(k)
		draw_set_color(c_black)
		draw_text_transformed(e.x + 2, e.y - (1 - k) * 30 + 2, e.text, 2, 2, 0)
		draw_set_color(e.col)
		draw_text_transformed(e.x, e.y - (1 - k) * 30, e.text, 2, 2, 0)
		draw_set_alpha(1)
		draw_set_halign(fa_left)
		draw_set_valign(fa_top)
	}
	else
	{
		draw_sprite_ext(e.spr, 0, e.x, e.y, k * e.ps, e.ys * k * e.ps, (1 - k) * 90, e.col, k)
	}

	e.t -= 1
	if (e.t <= 0) array_delete(effects, i, 1)
}
