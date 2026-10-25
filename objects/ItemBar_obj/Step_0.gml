// Clicking items, and aiming the ones that need a target
items_init()
if (variable_global_exists("paused") && global.paused) exit

// One frame after aiming ends, let clicks through again
if (finishing)
{
	finishing = false
	global.DaggerAiming = false
	exit
}

if (global.ItemAiming != "")
{
	if (!global.PlayerTurn || global.Winner != 0 || mouse_check_button_pressed(mb_right) || aim_slot >= array_length(global.Items))
	{
		stop_aiming()
		exit
	}

	if (mouse_check_button_pressed(mb_left))
	{
		var target = item_info(global.ItemAiming).target
		if (target == "own" || target == "enemy")
		{
			// Click a figure: your own ("own") or the enemy's ("enemy")
			var want_team = (target == "own") ? 1 : -1
			var fig = instance_position(mouse_x, mouse_y, FigureParent_obj)
			if (fig != noone && fig.team == want_team)
			{
				if (use_on_figure(global.ItemAiming, fig)) consume(aim_slot)
				stop_aiming()
			}
			else if (fig != noone)
			{
				remind((want_team == 1) ? "Only your own figures" : "Only enemy figures")
			}
			else
			{
				stop_aiming()   // clicked empty space: cancel
			}
		}
		else if (target == "lane")
		{
			var lane = lane_under_mouse()
			if (lane != -1 && use_on_lane(global.ItemAiming, lane)) consume(aim_slot)
			stop_aiming()   // a click off the board cancels
		}
		else if (global.ItemAiming == "storage")
		{
			// Put the clicked card from your hand into the chest
			var picked = noone
			with (CardParent_obj) if (in_hand && hovered) picked = id
			if (picked != noone)
			{
				global.Items[aim_slot].card = picked.object_index
				instance_destroy(picked)
				with (Deck_obj) show_reminder("Card stored in the chest")
			}
			stop_aiming()
		}
	}
	exit
}

// Click an item to use it, on your turn
if (mouse_check_button_pressed(mb_left) && global.PlayerTurn && global.Winner == 0 && !global.DaggerAiming)
{
	var slot = slot_under_mouse()
	if (slot != -1 && slot < array_length(global.Items)) use_item(slot)
}
