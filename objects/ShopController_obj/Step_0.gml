// Buying items and leaving the shop
if (message_timer > 0) message_timer -= 1
if (click_delay > 0)
{
	click_delay -= 1
	exit
}

// Playtest key (only while Deck_obj's debug_tools is on): F3 = +5 coins
if (variable_global_exists("DebugTools") && global.DebugTools && keyboard_check_pressed(vk_f3))
{
	global.Money += 5
	say("+5 coins (playtest)")
}

// Leave: click "Set sail" or press Space
var on_button = point_in_rectangle(mouse_x, mouse_y, btn_x, btn_y, btn_x + btn_w, btn_y + btn_h)
if (keyboard_check_pressed(vk_space) || (mouse_check_button_pressed(mb_left) && on_button))
{
	leave_shop()
	exit
}

// Buy: click an item on the shop board
if (mouse_check_button_pressed(mb_left))
{
	var i = cell_under_mouse()
	if (i != -1)
	{
		var item = stock[i]
		var info = item_info(item.kind)
		if (item.sold)
		{
			say("Already sold")
		}
		else if (array_length(global.Items) >= item_capacity())
		{
			say("Your bag is full (" + string(item_capacity()) + " items)")
		}
		else if (global.Money < info.price)
		{
			say("Not enough coins")
		}
		else
		{
			global.Money -= info.price
			array_push(global.Items, { kind: item.kind, card: -1 })
			item.sold = true
			say("Bought the " + info.name + "!")
			dbg("Bought " + item.kind + ", coins left " + string(global.Money))
		}
	}
}
