// Did an opposing figure reach this end of the lane?
var fig = instance_position(lane_x, watch_row_y, FigureParent_obj)
if (fig == noone || fig.team != watch_team) exit

if (!lit)
{
	light_up()
	exit
}

// Already green: the figure has finished the lane, so it leaves the board instead of
// sitting on the end forever and blocking that lane (it doesn't count as a lost figure)
with (fig)
{
	var fx = x
	var fy = y
	var spr = sprite_index
	var ys = image_yscale
	var col = image_blend
	var gx = draw_x
	var gy = draw_y
	var ps = perspective_scale()
	with (Deck_obj)
	{
		add_popup(fx, fy - 20, "Lane done", c_lime)
		add_ghost(spr, gx, gy, ys, col, ps)
	}
	instance_destroy()
}
