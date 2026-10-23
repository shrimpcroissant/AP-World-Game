// Slides smoothly to its spot on the board instead of jumping there
draw_x = lerp(draw_x, x, 0.25)
draw_y = lerp(draw_y, y, 0.25)

var sx = 0
var sy = 0
if (shake > 0)
{
	sx = random_range(-shake, shake)
	sy = random_range(-shake, shake)
	shake -= 1
}

// Smaller toward the enemy side for perspective (keeps the sign, so AI figures stay flipped)
var ps = perspective_scale()
var xs = image_xscale * ps
var ys = image_yscale * ps

draw_sprite_ext(sprite_index, image_index, draw_x + sx, draw_y + sy, xs, ys, image_angle, image_blend, image_alpha)

// White flash when hit
if (flash > 0)
{
	gpu_set_fog(true, c_white, 0, 0)
	draw_sprite_ext(sprite_index, image_index, draw_x + sx, draw_y + sy, xs, ys, image_angle, c_white, flash / 10)
	gpu_set_fog(false, c_white, 0, 0)
	flash -= 1
}
