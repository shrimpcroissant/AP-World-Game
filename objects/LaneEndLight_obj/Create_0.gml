// A light at one end of a lane. Starts red, turns green (and stays green)
// once an opposing figure reaches this end of the lane, and wipes out every figure in the lane.
// When all 4 lights at one end are green, the side attacking that end wins.

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
