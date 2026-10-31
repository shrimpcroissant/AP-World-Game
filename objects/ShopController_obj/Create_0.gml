// A shop: the merchant, the 2x2 shop board with 4 items, your coins,
// and a "Set sail" button. Which shop it is comes from global.CurrentShop (see go_to_shop in Items_scr).
// After a fight's shop, "Set sail" goes to the map. Before a fight's shop, it goes straight to the fight.
items_init()
if (!variable_global_exists("FightsWon")) global.FightsWon = 2

// The game hides the normal cursor, so this room needs the custom cursor object
if (!instance_exists(Mouse_obj)) instance_create_depth(mouse_x, mouse_y, -2000, Mouse_obj)
if (!variable_global_exists("CurrentShop")) global.CurrentShop = "malacca"
if (!variable_global_exists("ShopBeforeFight")) global.ShopBeforeFight = false

merchant = shop_merchant(global.CurrentShop)
dbg("Shop opened: " + global.CurrentShop + ", coins " + string(global.Money) + ", before fight " + string(global.ShopBeforeFight))

// What's for sale: one per square of the shop board (a revisited shop is fully restocked)
stock = []
var kinds = shop_items(global.CurrentShop)
for (var i = 0; i < array_length(kinds); i++) array_push(stock, { kind: kinds[i], sold: false })

// Shop board: ShopBoard_spr drawn at 2x, centered on the merchant's counter
board_scale = 2
board_w = sprite_get_width(ShopBoard_spr) * board_scale
board_h = sprite_get_height(ShopBoard_spr) * board_scale
board_x = room_width / 2 - board_w / 2
board_y = 470
cell = board_w / 2

// "Set sail" button, bottom right
btn_w = 220
btn_h = 60
btn_x = room_width - btn_w - 30
btn_y = room_height - btn_h - 30

// Message under the coins (like "Not enough coins")
message = ""
message_timer = 0

click_delay = 20   // so the click that left the fight doesn't buy something

// Center of the shop board square for item i (0 top-left, 1 top-right, 2 bottom-left, 3 bottom-right)
cell_x = function(i) { return board_x + cell / 2 + (i mod 2) * cell }
cell_y = function(i) { return board_y + cell / 2 + (i div 2) * cell }

// Which item square the mouse is over, or -1
cell_under_mouse = function()
{
	for (var i = 0; i < array_length(stock); i++)
	{
		var cx = cell_x(i)
		var cy = cell_y(i)
		if (point_in_rectangle(mouse_x, mouse_y, cx - cell / 2, cy - cell / 2, cx + cell / 2, cy + cell / 2)) return i
	}
	return -1
}

say = function(text)
{
	message = text
	message_timer = 120
}

leave_shop = function()
{
	dbg("Leaving shop")
	if (global.ShopBeforeFight) room_goto(fight_room_for(global.FightsWon))
	else go_to_map()
}
