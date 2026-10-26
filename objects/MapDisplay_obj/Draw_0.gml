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
	confirming = false   // the "Are you sure?" box over the story screen
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
var text = ""
if (done) text = "You reached " + global.Stops[array_length(global.Stops) - 1] + "! Journey complete.\nClick to return to the menu"
else if (detour && !pushed_off_course) text = "Malacca done!  Next stop: India\nClick to set sail"
else if (detour) text = "Oops! You left Malacca at the wrong time!\nDetour to Mogadishu. Click to continue"
else if (global.Stops[global.FightsWon] == "Iraq") text = global.Stops[global.FightsWon - 1] + " done!  Next stop: the coast of Iraq\nClick to set sail"
else if (shop_before_fight(global.FightsWon) != "") text = global.Stops[global.FightsWon - 1] + " done!  Next stop: " + global.Stops[global.FightsWon] + ", by way of Hormuz\nClick to set sail"
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

// The detour story screen, over the map
if (story_showing) draw_story_panel(ax, ay, aw, ah, k, story_text("detour"))
if (story_showing && confirming) draw_confirm(ax, ay, aw, ah, k, mouse_x, mouse_y)

// Click anywhere to sail to the next fight, or back to the menu after Arabia
if (click_delay > 0)
{
	click_delay -= 1
}
else if (story_showing)
{
	// Click or Space asks "Are you sure?". Yes (or Space) closes the story screen,
	// then the map's own message shows. No goes back to the story.
	if (confirming)
	{
		var pick = ""
		if (mouse_check_button_pressed(mb_left)) pick = confirm_hit(ax, ay, aw, ah, k, mouse_x, mouse_y)
		if (keyboard_check_pressed(vk_space)) pick = "yes"
		if (pick == "yes")
		{
			confirming = false
			story_showing = false
			click_delay = 20
		}
		else if (pick == "no") confirming = false
	}
	else if (mouse_check_button_pressed(mb_left) || keyboard_check_pressed(vk_space)) confirming = true
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
