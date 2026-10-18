draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, image_blend, image_alpha)

draw_set_color(c_white)
draw_set_halign(fa_center)
draw_set_valign(fa_top)
if (state == "idle")
{
	draw_text(home_x, home_y + sprite_height / 2 + 6, "Dagger")
}
else if (state == "aiming")
{
	draw_text(x, y + sprite_height / 2 + 6, "Click your figure")
}
draw_set_halign(fa_left)
