if (lit) exit

// Did an opposing figure reach this end of the lane?
var fig = instance_position(lane_x, watch_row_y, FigureParent_obj)
if (fig != noone && fig.team == watch_team)
{
	lit = true
	image_index = 1

	// Turning green wipes out every figure in this lane, on both sides
	var lx = lane_x
	var in_lane = []
	with (FigureParent_obj)
	{
		if (x == lx) array_push(in_lane, id)
	}
	for (var i = 0; i < array_length(in_lane); i++)
	{
		if (instance_exists(in_lane[i])) in_lane[i].take_damage(in_lane[i].total_hp())
	}

	// The player wins by lighting all but one of the enemy's lights (3 of 4).
	// The AI has to light all of yours.
	var side = watch_team
	var total = 0
	var green = 0
	with (LaneEndLight_obj)
	{
		if (watch_team == side)
		{
			total += 1
			if (lit) green += 1
		}
	}
	var needed = total
	if (side == 1) needed = total - 1
	if (green >= needed && global.Winner == 0) global.Winner = side
}
