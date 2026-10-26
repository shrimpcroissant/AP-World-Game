// Runs FigureParent_obj's Create first. Keep this line at the top.
event_inherited()

// This figure's own variables go below

attack = 2
hp = 2

// Runs 2 spaces each turn (the 2nd step only moves into an empty space, it never attacks).
speed_moves = 1

// On the row right before the enemy's back row, if anything blocks it,
// it finishes the lane anyway (the lane light turns green). See advance in FigureParent_obj.
finishes_lane = true
