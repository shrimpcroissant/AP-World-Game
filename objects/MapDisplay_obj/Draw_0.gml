// The route map, shown after every fight you win.
// Stops in order: China (tutorial), Malacca, Mogadishu, India, Arabia, Iraq (see route_stops in Items_scr).
// Everything is in this Draw event on purpose, so it works even if the object only has a Draw event.

// One-time setup
if (!variable_instance_exists(id, "click_delay"))
{
	// You only get here after winning a fight, so FightsWon is at least 1
	if (!variable_global_exists("FightsWon") || global.FightsWon < 1) global.FightsWon = 1
	global.Stops = route_stops()
	click_delay = 20   // short wait so the click that won the fight doesn't also skip the map

	// The game hides the normal cursor, so this room needs the custom cursor object
	if (!instance_exists(Mouse_obj)) instance_create_depth(mouse_x, mouse_y, -2000, Mouse_obj)

	// The detour: after Malacca you set sail for India, but former criminals in Malacca make
	// you leave at the wrong time and you detour to Mogadishu. pushed_off_course turns true after you click "set sail",
	// and the "detour" story screen shows then (once per game, see story_text in Items_scr).
	detour = (global.FightsWon == 2)
	pushed_off_course = false
	story_showing = false
	hold = 0   // seconds the mouse button or Space has been held on the story screen
	ending_stage = 0   // after Iraq: 1 = ending text, 2 = credits, then the menu
	dbg("Map: fights won " + string(global.FightsWon) + ", coins " + string(global.Money) + ", items " + string(array_length(global.Items)))
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
// During the detour the map stays on the old frame until you click "set sail".
// Map_spr only has 2 frames now, so later stops keep showing the last one until you add more.
var frame_step = global.FightsWon - 1
if (detour && !pushed_off_course) frame_step -= 1
var frame = clamp(frame_step, 0, sprite_get_number(Map_spr) - 1)
draw_sprite_stretched(Map_spr, frame, ax, ay, aw, ah)

var done = global.FightsWon >= array_length(global.Stops)

// ---- Stop markers ----
// Past stops: green with a tick. Where you are: yellow, pulsing. Next stop: orange ring.
// Later stops: white rings. The final destination (Iraq) is a big red ring.
var cur = global.FightsWon - 1     // the stop you just finished
var nxt = global.FightsWon         // where you're sailing next
if (detour && !pushed_off_course) nxt = 3   // you plan to sail for India, before the detour
if (done) { cur = array_length(global.Stops); nxt = -1 }
var pts = route_stop_points()
var sx = aw / sprite_get_width(Map_spr)
var sy = ah / sprite_get_height(Map_spr)
var r = 9 * k
var pulse_r = r + 4 * k * (0.5 + 0.5 * sin(current_time / 150))
draw_set_halign(fa_center)
draw_set_valign(fa_top)
for (var i = 0; i < array_length(global.Stops); i++)
{
	var mx = ax + pts[i][0] * sx
	var my = ay + pts[i][1] * sy
	var last = (i == array_length(global.Stops) - 1)
	var label = global.Stops[i]
	if (i < cur || (done && i == cur - 1))
	{
		draw_set_color(c_black)
		draw_circle(mx, my, r + 2 * k, false)
		draw_set_color(make_color_rgb(60, 170, 70))
		draw_circle(mx, my, r, false)
		draw_set_color(c_white)
		draw_line_width(mx - 4 * k, my, mx - 1 * k, my + 4 * k, 2 * k)
		draw_line_width(mx - 1 * k, my + 4 * k, mx + 5 * k, my - 4 * k, 2 * k)
	}
	else if (i == cur)
	{
		draw_set_color(c_yellow)
		draw_circle(mx, my, pulse_r + 2 * k, true)
		draw_set_color(c_black)
		draw_circle(mx, my, r + 2 * k, false)
		draw_set_color(c_yellow)
		draw_circle(mx, my, r, false)
		label += " (you are here)"
	}
	else
	{
		var ring = (i == nxt) ? make_color_rgb(255, 150, 30) : c_white
		if (last) ring = make_color_rgb(220, 30, 30)
		var rr = last ? r + 4 * k : r
		if (i == nxt) rr = pulse_r
		draw_set_color(c_black)
		draw_circle(mx, my, rr + 2 * k, true)
		draw_set_color(ring)
		draw_circle(mx, my, rr, true)
		draw_circle(mx, my, rr - 1, true)
		draw_circle(mx, my, rr - 2, true)
		if (i == nxt) label += " (next stop)"
		if (last) label += " (final destination)"
	}
	// Name under the marker, with a dark shadow so it reads on land and sea
	draw_set_color(c_black)
	draw_text_transformed(mx + 1, my + r + 4 * k + 1, label, 1.2 * k, 1.2 * k, 0)
	draw_set_color(c_white)
	draw_text_transformed(mx, my + r + 4 * k, label, 1.2 * k, 1.2 * k, 0)
}

// ---- Message at the bottom ----
var text = ""
if (done) text = "You reached the coast of Iraq!\nJourney complete."
else if (detour && !pushed_off_course) text = "Malacca: done!\nNext stop: India.  Click to set sail"
else if (detour) text = "Oops! You left Malacca at the wrong time!\nDetour to Mogadishu.  Click to continue"
else if (global.Stops[global.FightsWon] == "Iraq") text = global.Stops[global.FightsWon - 1] + ": done!\nNext stop: the coast of Iraq, your final destination.  Click to set sail"
else if (shop_before_fight(global.FightsWon) != "") text = global.Stops[global.FightsWon - 1] + ": done!\nNext stop: " + global.Stops[global.FightsWon] + ", by way of the port of Hormuz.  Click to set sail"
else text = global.Stops[global.FightsWon - 1] + ": done!\nNext stop: " + global.Stops[global.FightsWon] + ".  Click to set sail"

// Pulsing text near the bottom, with a dark box behind it so it reads on the map
var pulse = 0.65 + 0.35 * sin(current_time / 200)
draw_set_halign(fa_center)
draw_set_valign(fa_bottom)
var tx = ax + aw / 2
var ty = ay + ah - 30 * k
var w = (string_width(text) * 2 + 30) * k
var h = (string_height(text) * 2 + 16) * k
draw_set_alpha(0.75)
draw_set_color(c_black)
draw_rectangle(tx - w / 2, ty - h, tx + w / 2, ty + 8 * k, false)
draw_set_alpha(pulse)
draw_set_color(c_white)
draw_text_transformed(tx, ty, text, 2 * k, 2 * k, 0)
draw_set_alpha(1)
draw_set_halign(fa_left)
draw_set_valign(fa_top)

// ---- The ending: ted's closing text, then the credits, then the menu ----
if (done && ending_stage == 0) ending_stage = 1
if (ending_stage == 1) draw_story_panel(ax, ay, aw, ah, k, ending_text(), hold)
if (ending_stage == 2) draw_story_panel(ax, ay, aw, ah, k, credits_text(), hold)
// The detour story screen, over the map
if (story_showing) draw_story_panel(ax, ay, aw, ah, k, story_text("detour"), hold)

// Click anywhere to sail to the next fight
if (click_delay > 0)
{
	click_delay -= 1
}
else if (ending_stage > 0)
{
	// Hold to move on: ending text, then credits, then back to the menu
	if (mouse_check_button(mb_left) || keyboard_check(vk_space)) hold += delta_time / 1000000
	else hold = 0
	if (hold >= 1)
	{
		hold = 0
		click_delay = 20
		ending_stage += 1
		if (ending_stage > 2) room_goto(Menu_Room)
	}
}
else if (story_showing)
{
	// Hold the mouse button or Space for 1 second (the bar fills) to close the story screen,
	// then the map's own message shows
	if (mouse_check_button(mb_left) || keyboard_check(vk_space)) hold += delta_time / 1000000
	else hold = 0
	if (hold >= 1)
	{
		story_showing = false
		hold = 0
		click_delay = 20
	}
}
else if (mouse_check_button_pressed(mb_left))
{
	if (done) room_goto(Menu_Room)
	else if (detour && !pushed_off_course)
	{
		// "Set sail" for India: switch the map, then show the detour story screen
		pushed_off_course = true
		story_showing = story_first_time("detour")
		click_delay = 20
	}
	else
	{
		// Some stops have a shop before the fight (Hormuz before Arabia), otherwise straight to the fight
		var pre_shop = shop_before_fight(global.FightsWon)
		if (pre_shop != "") go_to_shop(pre_shop, true)
		else room_goto(fight_room_for(global.FightsWon))
	}
}
