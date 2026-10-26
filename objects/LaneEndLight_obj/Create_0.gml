// A light at one end of a lane. Starts red, turns green (and stays green)
// once an opposing figure reaches this end of the lane, and wipes out every figure in the lane.
// The player wins with 3 of the 4 enemy lights green; the AI needs all 4 of yours.

image_speed = 0
image_index = 0   // frame 0 = red, frame 1 = green
lit = false

// The lane this light belongs to: the tile column it sits over
lane_x = x + sprite_width / 2

// Lights above the board are the AI's end: lit by player figures reaching the top row.
// Lights below the board are your end: lit by AI figures reaching the bottom row.
if (y + sprite_height / 2 < 324)
{
	watch_team = 1
	watch_row_y = 196
}
else
{
	watch_team = -1
	watch_row_y = 452
}

// Turns this light green: wipes out every figure in the lane (both sides) and checks for a win.
// Called when a figure reaches this end (Step event), or when a Runner finishes the lane early.
light_up = function()
{
	if (lit) return
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
