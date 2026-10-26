// Draws the 4 item slots, your coins, and the description of the item under the mouse
items_init()
var half = slot_size / 2
var hover = slot_under_mouse()

// Zebra: show the blocked lane with black and white stripes and how many enemy turns are left
if (instance_exists(EnemyAI_obj) && EnemyAI_obj.blocked_lane_turns > 0)
{
	var lx = EnemyAI_obj.blocked_lane_x
	draw_set_alpha(0.25)
	for (var s = 0; s < 10; s++)
	{
		draw_set_color((s mod 2 == 0) ? c_white : c_black)
		draw_rectangle(lx - 32, 164 + s * 32, lx + 32, 164 + s * 32 + 31, false)
	}
	draw_set_alpha(1)
	draw_set_halign(fa_center)
	draw_set_valign(fa_bottom)
	draw_set_color(c_white)
	draw_text(lx, 160, "Blocked: " + string(EnemyAI_obj.blocked_lane_turns))
}

// While aiming the Zebra, light up the lane under the mouse
if (item_info(global.ItemAiming).target == "lane" && global.ItemAiming != "")
{
	var hl = lane_under_mouse()
	if (hl != -1)
	{
		draw_set_alpha(0.3)
		draw_set_color(c_white)
		draw_rectangle(hl - 32, 164, hl + 32, 484, false)
		draw_set_alpha(1)
	}
}

for (var i = 0; i < 4; i++)
{
	var sx = slot_x[i]
	var sy = slot_y[i]

	// Slot box (highlighted while its item is being aimed or hovered)
	var lit = (i == aim_slot) || (i == hover && i < array_length(global.Items))
	draw_set_alpha(0.7)
	draw_set_color(lit ? make_color_rgb(110, 80, 40) : make_color_rgb(50, 35, 20))
	draw_rectangle(sx - half, sy - half, sx + half, sy + half, false)
	draw_set_alpha(1)
	draw_set_color(lit ? c_yellow : make_color_rgb(200, 170, 110))
	draw_rectangle(sx - half, sy - half, sx + half, sy + half, true)

	if (i < array_length(global.Items))
	{
		var item = global.Items[i]
		var info = item_info(item.kind)
		if (info.sprite != -1) draw_sprite_fit(info.sprite, sx, sy, slot_size - 20, 1)

		// The storage chest shows when it's holding a card
		if (item.kind == "storage" && item.card != -1)
		{
			draw_set_halign(fa_center)
			draw_set_valign(fa_bottom)
			draw_set_color(c_lime)
			draw_text(sx, sy + half - 2, "1 card")
		}
	}
}

// Labels and coins
draw_set_halign(fa_center)
draw_set_valign(fa_bottom)
draw_set_color(c_white)
draw_text(slot_x[0], slot_y[0] - half - 4, "Items")
draw_text(slot_x[2], slot_y[2] - half - 4, "Items")
draw_set_valign(fa_top)
draw_set_color(c_yellow)
draw_text_transformed(slot_x[0], slot_y[1] + half + 8, "Coins: " + string(global.Money), 1.5, 1.5, 0)
if (global.PepperTurns > 0)
{
	draw_set_color(c_orange)
	draw_text(slot_x[0], slot_y[1] + half + 34, "Pepper: +1 unit for " + string(global.PepperTurns) + " more turns")
}

// Aiming hint by the mouse
if (global.ItemAiming != "")
{
	var aim_target = item_info(global.ItemAiming).target
	var hint = ""
	if (global.ItemAiming == "storage") hint = "Click a card in your hand to store it"
	else if (aim_target == "own") hint = "Click one of your figures"
	else if (aim_target == "enemy") hint = "Click an enemy figure"
	else if (aim_target == "lane") hint = "Click a lane to block"
	draw_set_color(c_lime)
	draw_text(mouse_x, mouse_y + 20, hint + " (right-click to cancel)")
}

// Description of the hovered item
if (hover != -1 && hover < array_length(global.Items) && global.ItemAiming == "")
{
	var hinfo = item_info(global.Items[hover].kind)
	var text = hinfo.name + "\n" + hinfo.desc
	if (global.Items[hover].kind == "storage" && global.Items[hover].card != -1) text += "\n(Holding a card, click to take it back)"
	var bx = slot_x[hover] + half + 8
	if (hover >= 2) bx = slot_x[hover] - half - 8 - (string_width(text) + 16)
	draw_info_box(bx, slot_y[hover] - half, text)
}

// Bio of the card you're hovering in your hand (name, cost, stats, what it does)
var hovered_card = noone
with (CardParent_obj) if (in_hand && hovered) hovered_card = id
if (hovered_card != noone && global.ItemAiming == "")
{
	var bio = card_bio(hovered_card.object_index, hovered_card.cost)
	if (instance_exists(Deck_obj))
	{
		var turns_left = Deck_obj.hand_turns - hovered_card.turns_in_hand
		if (turns_left <= 1) bio += "\nLAST TURN: discarded if you don't play it now"
		else bio += "\nLeaves your hand in " + string(turns_left) + " turns"
	}
	var bw = string_width(bio) + 16
	var bh = string_height(bio) + 12
	// Above the card, centered on it
	draw_info_box(hovered_card.rest_x - bw / 2, hovered_card.rest_y - 148 - 40 - bh, bio)
}

draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
