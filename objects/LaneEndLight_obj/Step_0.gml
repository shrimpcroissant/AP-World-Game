if (lit) exit

// Did an opposing figure reach this end of the lane?
var fig = instance_position(lane_x, watch_row_y, FigureParent_obj)
if (fig != noone && fig.team == watch_team) light_up()
