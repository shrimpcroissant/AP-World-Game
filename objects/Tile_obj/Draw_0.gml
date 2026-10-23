// The tile itself isn't drawn any more: ShipBoard_obj draws the ship underneath.
// The tile only draws the glow below.

// While you have a card chosen, glow on the empty tiles you can play it on
if (y != 452 || !global.PlayerTurn) exit
if (!instance_exists(global.SelectedCard)) exit
if (instance_position(x, y, FigureParent_obj)) exit

var hover = place_meeting(x, y, Mouse_obj)
var pulse = 0.5 + 0.5 * sin(current_time / 150)
var a = hover ? 0.55 : 0.2 + 0.15 * pulse

draw_set_alpha(a)
draw_set_color(c_lime)
draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, false)
draw_set_alpha(1)
draw_set_color(c_white)
