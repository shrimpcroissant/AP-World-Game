// Draws the card rotated around its bottom-center, like a card held in a hand.
// x, y is the bottom-center of the card, whatever the sprite's origin is,
// so a new card sprite works without changing its origin.

// Bottom-center of the card art, measured from the sprite's origin
var px = (sprite_get_bbox_left(sprite_index) + sprite_get_bbox_right(sprite_index) + 1) / 2 - sprite_get_xoffset(sprite_index)
var py = sprite_get_bbox_bottom(sprite_index) + 1 - sprite_get_yoffset(sprite_index)
px *= image_xscale
py *= image_yscale

// Rotate that point by the card's angle
var rx = px * dcos(image_angle) + py * dsin(image_angle)
var ry = -px * dsin(image_angle) + py * dcos(image_angle)

draw_sprite_ext(sprite_index, image_index, x - rx, y - ry, image_xscale, image_yscale, image_angle, image_blend, image_alpha)
