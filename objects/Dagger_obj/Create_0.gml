// The dagger. It sits next to your deck. Click it to aim (frame 1), then click one of
// your own figures on your first two rows to get rid of it once it's done its job.
// The dagger flies to the figure, then back into place. No limit on uses.

image_speed = 0
image_index = 0      // frame 0 = resting by the deck, frame 1 = aiming
scale = 2            // same size as the cards
image_xscale = scale
image_yscale = scale

home_x = x
home_y = y
home_depth = depth

state = "idle"       // idle, aiming, cancel, flying, returning
target = noone

// True while you're aiming, so clicks don't also pick cards, draw, or place figures
global.DaggerAiming = false

// True if the mouse is over the dagger in its resting spot
mouse_on_dagger = function()
{
	var hw = sprite_width / 2 + 6
	var hh = sprite_height / 2 + 6
	return point_in_rectangle(mouse_x, mouse_y, home_x - hw, home_y - hh, home_x + hw, home_y + hh)
}
