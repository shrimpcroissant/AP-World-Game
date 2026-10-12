// Draw End: shows attack and health above a hovered figure, plus "DEATH"
// if it won't survive the next battle.
// Draw End runs after every normal Draw, so this sits on top of other figures.

var tx = x
var ty = bbox_top - 6
var hovered = position_meeting(mouse_x, mouse_y, id)

// The text pulses its opacity
var pulse = 0.65 + 0.35 * sin(current_time / 120)

draw_set_halign(fa_center)
draw_set_valign(fa_bottom)

if (hovered)
{
	var text = "ATK " + string(total_attack())
	if (atk_bonus() > 0) text += " (+1)"
	text += "   HP " + string(total_hp())
	if (hp_bonus() > 0) text += " (+1)"
	if (fire_every > 0) text += "   FIRES IN " + string(fire_every - turns_waited)
	if (global.PlayerTurn && predicted_damage > 0) text += "   NEXT TURN -" + string(predicted_damage)

	// Dark box behind the numbers so they're readable on any background
	var w = string_width(text) + 10
	var h = string_height(text) + 4
	draw_set_alpha(0.75 * pulse)
	draw_set_color(c_black)
	draw_rectangle(tx - w / 2, ty - h, tx + w / 2, ty + 2, false)
	draw_set_alpha(1)

	draw_set_color(c_white)
	draw_set_alpha(pulse)
	draw_text(tx, ty, text)
	draw_set_alpha(1)

	ty -= h + 4   // put DEATH above the stats box
}

// Predicted to die in the next battle
if (hovered && global.PlayerTurn && predicted_death)
{
	draw_set_alpha(pulse)
	draw_set_color(c_black)
	draw_text_transformed(tx + 1, ty + 1, "DEATH", 1.5, 1.5, 0)
	draw_set_color(c_red)
	draw_text_transformed(tx, ty, "DEATH", 1.5, 1.5, 0)
	draw_set_alpha(1)
}

draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
