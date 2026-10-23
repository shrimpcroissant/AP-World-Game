// The route map, shown after every fight you win.
// Stops in order: China (tutorial), Malacca, Mogadishu, India, Arabia.
// Everything is in this Draw event on purpose, so it works even if the object only has a Draw event.

// One-time setup
if (!variable_instance_exists(id, "click_delay"))
{
	// You only get here after winning a fight, so FightsWon is at least 1
	if (!variable_global_exists("FightsWon") || global.FightsWon < 1) global.FightsWon = 1
	global.Stops = ["China", "Malacca", "Mogadishu", "India", "Arabia"]
	click_delay = 20   // short wait so the click that won the fight doesn't also skip the map
}

// Area to fill: the camera view if the room uses one, otherwise the whole room
var ax = 0
var ay = 0
var aw = room_width
var ah = room_height
if (view_enabled && view_visible[0])
{
	var cam = view_camera[0]
	ax = camera_get_view_x(cam)
	ay = camera_get_view_y(cam)
	aw = camera_get_view_width(cam)
	ah = camera_get_view_height(cam)
}
var k = aw / 1366   // text scale, so it looks the same in a zoomed-in room

// Which Map_spr frame: frame 0 after China (heading to Malacca), frame 1 after Malacca, and so on.
// Map_spr only has 2 frames now, so later stops keep showing the last one until you add more.
var frame = clamp(global.FightsWon - 1, 0, sprite_get_number(Map_spr) - 1)
draw_sprite_stretched(Map_spr, frame, ax, ay, aw, ah)

var done = global.FightsWon >= array_length(global.Stops)
var text = ""
if (done) text = "You reached " + global.Stops[array_length(global.Stops) - 1] + "! Journey complete.\nClick to return to the menu"
else text = global.Stops[global.FightsWon - 1] + " done!  Next stop: " + global.Stops[global.FightsWon] + "\nClick to set sail"

// Pulsing text near the bottom, with a dark box behind it so it reads on the map
var pulse = 0.65 + 0.35 * sin(current_time / 200)
draw_set_halign(fa_center)
draw_set_valign(fa_bottom)
var tx = ax + aw / 2
var ty = ay + ah - 30 * k
var w = (string_width(text) * 2 + 30) * k
var h = (string_height(text) * 2 + 16) * k
draw_set_alpha(0.6)
draw_set_color(c_black)
draw_rectangle(tx - w / 2, ty - h, tx + w / 2, ty + 8 * k, false)
draw_set_alpha(pulse)
draw_set_color(c_white)
draw_text_transformed(tx, ty, text, 2 * k, 2 * k, 0)
draw_set_alpha(1)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// Click anywhere to sail to the next fight, or back to the menu after Arabia
if (click_delay > 0)
{
	click_delay -= 1
}
else if (mouse_check_button_pressed(mb_left))
{
	if (done) room_goto(Menu_Room)
	else room_goto(Prototype_Room)   // every stop uses this fight room for now
}
