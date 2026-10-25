// Your item slots during a fight: 2 on the left of the ship, 2 on the right.
// Deck_obj creates this at the start of every fight. Items come from global.Items (see Items_scr).
items_init()
global.ItemAiming = ""

slot_size = 84
slot_x = [290, 290, 1070, 1070]
slot_y = [250, 380, 250, 380]

aim_slot = -1        // which slot's item is being aimed
finishing = false    // waits one frame after aiming so that click doesn't also do something else

// Which slot (0-3) the mouse is over, or -1
slot_under_mouse = function()
{
	var half = slot_size / 2
	for (var i = 0; i < 4; i++)
	{
		if (point_in_rectangle(mouse_x, mouse_y, slot_x[i] - half, slot_y[i] - half, slot_x[i] + half, slot_y[i] + half)) return i
	}
	return -1
}

// Starts aiming an item (blocks card picks, drawing and placing until it's done)
start_aiming = function(kind, slot)
{
	global.ItemAiming = kind
	global.DaggerAiming = true
	global.SelectedCard = noone
	aim_slot = slot
}

stop_aiming = function()
{
	global.ItemAiming = ""
	aim_slot = -1
	finishing = true
}

// Uses up the item in slot i
consume = function(i)
{
	array_delete(global.Items, i, 1)
}

popup = function(px, py, text, col)
{
	with (Deck_obj) add_popup(px, py, text, col)
}

remind = function(text)
{
	with (Deck_obj) show_reminder(text)
}

// True if there's a figure on this team (1 = yours, -1 = enemy)
has_figure = function(side)
{
	var found = false
	with (FigureParent_obj) if (team == side) found = true
	return found
}

// What happens when you click an item in slot i
use_item = function(i)
{
	var item = global.Items[i]
	var info = item_info(item.kind)
	var px = slot_x[i]
	var py = slot_y[i] - slot_size / 2 - 10

	// Items you aim at a figure
	if (info.target == "own")
	{
		if (has_figure(1)) start_aiming(item.kind, i)
		else remind("You need a figure on the board first")
		return
	}
	if (info.target == "enemy")
	{
		if (has_figure(-1)) start_aiming(item.kind, i)
		else remind("No enemy figures to target")
		return
	}
	if (info.target == "lane")
	{
		start_aiming(item.kind, i)
		return
	}
	if (info.target == "passive")
	{
		remind("The " + info.name + " works by itself")
		return
	}

	switch (item.kind)
	{
		case "tin":
			global.Units += 2
			popup(px, py, "+2 units", c_yellow)
			consume(i)
			break

		case "pearl":
			global.Units += 3
			popup(px, py, "+3 units", c_yellow)
			consume(i)
			break

		case "pepper":
			global.PepperTurns += 3
			remind("+1 unit at the start of your next 3 turns")
			consume(i)
			break

		case "ambergris":
			with (Deck_obj)
			{
				repeat (5) array_push(deck, full_deck[irandom(array_length(full_deck) - 1)])
				deck = array_shuffle(deck)
				skips_left = 0   // you have cards again, so no more skipped turns
			}
			popup(Deck_obj.x, Deck_obj.y - 90, "+5 cards", c_aqua)
			consume(i)
			break

		case "rhino":
			if (global.LastLostCard == -1)
			{
				remind("You haven't lost a figure yet")
				break
			}
			instance_create_layer(Deck_obj.x, Deck_obj.y, Deck_obj.layer, global.LastLostCard)
			global.LastLostCard = -1
			remind("Your lost figure's card is back in your hand")
			consume(i)
			break

		case "frankincense":
			if (!has_figure(1))
			{
				remind("You need a figure on the board first")
				break
			}
			with (FigureParent_obj)
			{
				if (team == 1)
				{
					hp += 1
					var fx = x
					var fy = y
					with (Deck_obj) add_popup(fx, fy - 20, "+1 HP", c_lime)
				}
			}
			consume(i)
			break

		case "tablet":
			EnemyAI_obj.blocked_turns += 1
			remind("The enemy honors the tablet: no cards next turn")
			consume(i)
			break

		case "storage":
			if (item.card == -1)
			{
				var have_card = false
				with (CardParent_obj) if (in_hand) have_card = true
				if (have_card) start_aiming("storage", i)
				else remind("No cards in your hand to store")
			}
			else
			{
				// Take the stored card back. It's free to play.
				var card = instance_create_layer(Deck_obj.x, Deck_obj.y, Deck_obj.layer, item.card)
				card.cost = 0
				remind("Took your stored card back, it costs 0 units")
				consume(i)
			}
			break
	}
}

// What an aimed item does to the figure you clicked. Returns true if it worked.
use_on_figure = function(kind, fig)
{
	var fx = fig.x
	var fy = fig.y - 20
	switch (kind)
	{
		case "cloves":
			fig.hp += 1
			popup(fx, fy, "+1 HP", c_lime)
			return true
		case "ivory":
			fig.attack += 1
			popup(fx, fy, "+1 ATK", c_orange)
			return true
		case "cloth":
			if (!fig.moves) { remind("That figure doesn't move"); return false }
			fig.sail_moves = 1
			popup(fx, fy, "New sails!", c_aqua)
			return true
		case "horse":
			if (!fig.moves) { remind("That figure doesn't move"); return false }
			fig.gallop = true
			popup(fx, fy, "Galloping!", c_aqua)
			return true
		case "wootz":
			fig.take_damage(2)
			return true
	}
	return false
}

// The lane (tile column x) under the mouse, or -1. Anywhere on the board in that column counts.
lane_under_mouse = function()
{
	var found = -1
	with (Tile_obj)
	{
		if (abs(mouse_x - x) <= 32 && mouse_y >= 164 && mouse_y <= 484) found = x
	}
	return found
}

// Zebra: blocks a lane so the enemy can't place figures in it for 3 of its turns
use_on_lane = function(kind, lane_x)
{
	if (kind == "zebra")
	{
		EnemyAI_obj.blocked_lane_x = lane_x
		EnemyAI_obj.blocked_lane_turns = 3
		popup(lane_x, 150, "Lane blocked!", c_white)
		return true
	}
	return false
}
