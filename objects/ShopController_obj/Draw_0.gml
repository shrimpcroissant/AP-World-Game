// Merchant in the background (its 2 frames swap slowly), stretched to fill the room
var frame = (current_time div 600) mod sprite_get_number(merchant)
draw_sprite_stretched(merchant, frame, 0, 0, room_width, room_height)

// Shop board with the items on it
draw_sprite_ext(ShopBoard_spr, 0, board_x, board_y, board_scale, board_scale, 0, c_white, 1)

var hover = cell_under_mouse()
draw_set_halign(fa_center)
for (var i = 0; i < array_length(stock); i++)
{
	var item = stock[i]
	var info = item_info(item.kind)
	var cx = cell_x(i)
	var cy = cell_y(i)

	if (item.sold)
	{
		draw_sprite_fit(info.sprite, cx, cy - 8, cell - 50, 0.3)
		draw_set_valign(fa_middle)
		draw_set_color(c_white)
		draw_text_transformed(cx, cy, "SOLD", 2, 2, 0)
		continue
	}

	// Lift the hovered item a little
	var lift = (i == hover) ? 4 : 0
	draw_sprite_fit(info.sprite, cx, cy - 10 - lift, cell - 50, 1)

	// Price tag
	var can_buy = global.Money >= info.price && array_length(global.Items) < item_capacity()
	draw_set_valign(fa_bottom)
	draw_set_color(c_black)
	draw_text_transformed(cx + 1, cy + cell / 2 - 5, string(info.price) + " coins", 1.5, 1.5, 0)
	draw_set_color(can_buy ? c_yellow : make_color_rgb(150, 150, 150))
	draw_text_transformed(cx, cy + cell / 2 - 6, string(info.price) + " coins", 1.5, 1.5, 0)
}

// Coins and message, top left
draw_set_halign(fa_left)
draw_set_valign(fa_top)
draw_set_color(c_black)
draw_rectangle(20, 20, 330, 110, false)
draw_set_color(c_yellow)
draw_text_transformed(32, 28, "Coins: " + string(global.Money), 2, 2, 0)
draw_set_color(c_white)
draw_text_transformed(32, 68, "Items: " + string(array_length(global.Items)) + " / " + string(item_capacity()), 1.5, 1.5, 0)

// Your bag, under the coins
for (var b = 0; b < item_capacity(); b++)
{
	var bx = 32 + b * 74 + 32
	var by = 150
	draw_set_alpha(0.7)
	draw_set_color(make_color_rgb(50, 35, 20))
	draw_rectangle(bx - 32, by - 32, bx + 32, by + 32, false)
	draw_set_alpha(1)
	draw_set_color(make_color_rgb(200, 170, 110))
	draw_rectangle(bx - 32, by - 32, bx + 32, by + 32, true)
	if (b < array_length(global.Items)) draw_sprite_fit(item_info(global.Items[b].kind).sprite, bx, by, 52, 1)
}

if (message_timer > 0)
{
	draw_set_alpha(min(1, message_timer / 30))
	draw_set_color(c_white)
	draw_text_transformed(32, 196, message, 1.5, 1.5, 0)
	draw_set_alpha(1)
}

// Set sail button
var on_button = point_in_rectangle(mouse_x, mouse_y, btn_x, btn_y, btn_x + btn_w, btn_y + btn_h)
draw_set_color(on_button ? make_color_rgb(60, 130, 60) : make_color_rgb(40, 90, 40))
draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, false)
draw_set_color(c_white)
draw_rectangle(btn_x, btn_y, btn_x + btn_w, btn_y + btn_h, true)
draw_set_halign(fa_center)
draw_set_valign(fa_middle)
draw_text_transformed(btn_x + btn_w / 2, btn_y + btn_h / 2, "Set sail (Space)", 1.5, 1.5, 0)

// Description of the hovered item
if (hover != -1 && !stock[hover].sold)
{
	var hinfo = item_info(stock[hover].kind)
	draw_info_box(cell_x(hover) + cell / 2 + 10, cell_y(hover) - cell / 2, hinfo.name + "  (" + string(hinfo.price) + " coins)\n" + hinfo.desc)
}

draw_set_color(c_white)
draw_set_halign(fa_left)
draw_set_valign(fa_top)
