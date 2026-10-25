// Items you buy in the shops and use during fights.
//
// global.Items is your item bag: up to item_capacity() items, kept between fights.
// Each entry is a struct: { kind: "tin", card: -1 }  (card is only used by Storage)
// global.Money is your coins for the shops.

// How many items you can carry at once
function item_capacity()
{
	return 4
}

// Makes sure the item and money globals exist (safe to call any time)
function items_init()
{
	if (!variable_global_exists("Items")) global.Items = []
	if (!variable_global_exists("Money")) global.Money = 0
	if (!variable_global_exists("ItemAiming")) global.ItemAiming = ""
	if (!variable_global_exists("LastLostCard")) global.LastLostCard = -1   // for the Rhinoceros Horn
	if (!variable_global_exists("PepperTurns")) global.PepperTurns = 0      // turns of +1 unit left from the Pepper
}

// Everything about one kind of item: its sprite, name, price, what it does, and how you use it.
// target: "none" = works as soon as you click it, "own" = then click one of your figures,
//         "enemy" = then click an enemy figure, "lane" = then click a lane,
//         "passive" = works by itself, "storage" = the chest.
// To add an item: add a case here, then make it work in ItemBar_obj (use_item / use_on_figure).
function item_info(kind)
{
	var info = item_info_base(kind)
	if (!variable_struct_exists(info, "target")) info.target = "none"
	return info
}

function item_info_base(kind)
{
	switch (kind)
	{
		// ---- Malacca ----
		case "tin":
			return { sprite: TinIngot_spr, name: "Tin Ingot", price: 2,
				desc: "Malacca's money was cast from tin.\n+2 units this turn." }
		case "cloves":
			return { sprite: NutmegandCloves_spr, name: "Nutmeg & Cloves", price: 2,
				desc: "Spices from the Spice Islands, used as medicine.\nClick, then click your figure: +1 HP.", target: "own" }
		case "compass":
			return { sprite: MagneticCompass_spr, name: "Magnetic Compass", price: 4,
				desc: "Chinese sailors steered by compass.\nAutomatic: when your deck runs out,\nit refills right away (no skipped turns). One use.", target: "passive" }
		case "storage":
			return { sprite: Storage_spr, name: "Storage Chest", price: 3,
				desc: "The fleet stored goods in Malacca's warehouse.\nClick, then click a card to store it.\nClick again later to take it back for 0 units.", target: "storage" }

		// ---- Mogadishu ----
		case "zebra":
			return { sprite: Zebra_spr, name: "Zebra", price: 3,
				desc: "Mogadishu sent zebras to the Ming court as tribute.\nClick, then click a lane: the enemy can't place\nfigures in that lane for its next 3 turns.", target: "lane" }
		case "ivory":
			return { sprite: IvoryTusks, name: "Ivory Tusks", price: 4,
				desc: "East African ivory was prized in China.\nClick, then click your figure:\n+1 attack for the rest of the fight.", target: "own" }
		case "rhino":
			return { sprite: RhinoHorn_spr, name: "Rhinoceros Horn", price: 4,
				desc: "Valued in Chinese medicine.\nRevive: the card of the last figure\nyou lost comes back to your hand." }
		case "ambergris":
			return { sprite: Ambergris_spr, name: "Ambergris", price: 2,
				desc: "Rare whale ambergris, worth a fortune.\nSell it: 5 cards are added back to your deck." }

		// ---- Calicut (India) ----
		case "pepper":
			return { sprite: PepperCornSack_spr, name: "Sack of Black Pepper", price: 3,
				desc: "Calicut's pepper was the biggest thing\nChinese ships bought.\n+1 unit at the start of your next 3 turns." }
		case "cloth":
			return { sprite: ClothBolt_spr, name: "Calicut Cotton Cloth", price: 2,
				desc: "Indian cotton (calico) made fine new sails.\nClick, then click your figure:\nit moves 2 spaces in the next battle." , target: "own" }
		case "wootz":
			return { sprite: WootzSteelBlade_spr, name: "Wootz Steel Blade", price: 3,
				desc: "South Indian crucible steel, the best blades of the age.\nClick, then click an enemy figure: 2 damage.", target: "enemy" }
		case "tablet":
			return { sprite: CalicutStoneTablet_spr, name: "Calicut Stone Tablet", price: 4,
				desc: "Zheng He set up a stone tablet in Calicut in 1407\nto honor peace and trade with China.\nThe enemy can't play cards on its next turn." }

		// ---- Hormuz (Arabia) ----
		case "frankincense":
			return { sprite: Frankincense_spr, name: "Frankincense", price: 3,
				desc: "Arabian incense, burned in Chinese temples.\nHeal all your figures +1 HP." }
		case "horse":
			return { sprite: ArabianHorse_spr, name: "Arabian Horse", price: 4,
				desc: "Arabian horses were traded across the ocean.\nClick, then click your figure:\nit gallops 2 spaces every turn from now on.", target: "own" }
		case "pearl":
			return { sprite: HormuzPearl_spr, name: "Hormuz Pearls", price: 2,
				desc: "Hormuz was famous for Persian Gulf pearls.\nSell them: +3 units this turn." }
		case "myrrh":
			return { sprite: Myrrh_spr, name: "Myrrh", price: 3,
				desc: "A healing resin from Arabia and Somalia.\nAutomatic: the next time one of your figures\nwould die, it survives with 1 HP. One use.", target: "passive" }
	}
	return { sprite: -1, name: kind, price: 0, desc: "" }
}

// ---- The route ----
// Stops in order. The fight at stop i is the (i+1)th fight, so after it global.FightsWon = i + 1.
function route_stops()
{
	return ["China", "Malacca", "Mogadishu", "India", "Arabia", "Iraq"]
}

// The room each fight happens in, by how many fights you've won before it.
// The Iraq coast fight (the last one) has its own room; the rest use Prototype_Room for now.
function fight_room_for(fights_won)
{
	if (fights_won == 5)
	{
		var iraq = asset_get_index("IraqCoast_Room")
		if (iraq != -1) return iraq
	}
	return Prototype_Room
}

// The shop you visit right AFTER winning a fight ("" = none).
// China is fight 1, so 2 = after Malacca, 3 = after Mogadishu, 4 = after India,
// 5 = after Arabia (you sail back into Hormuz before heading for Iraq).
function shop_after_fight(fights_won)
{
	switch (fights_won)
	{
		case 2: return "malacca"
		case 3: return "mogadishu"
		case 4: return "calicut"
		case 5: return "hormuz"
	}
	return ""
}

// The shop you visit right BEFORE a fight, after the map ("" = none).
// 4 = before the Arabia fight, you stop at Hormuz first.
function shop_before_fight(fights_won)
{
	switch (fights_won)
	{
		case 4: return "hormuz"
	}
	return ""
}

// What each shop sells
function shop_items(shop)
{
	switch (shop)
	{
		case "malacca":   return ["tin", "cloves", "compass", "storage"]
		case "mogadishu": return ["zebra", "ivory", "rhino", "ambergris"]
		case "calicut":   return ["pepper", "cloth", "wootz", "tablet"]
		case "hormuz":    return ["frankincense", "horse", "pearl", "myrrh"]
	}
	return []
}

// The merchant picture for each shop
function shop_merchant(shop)
{
	switch (shop)
	{
		case "mogadishu": return ShopMerchantMogadishu_spr
		case "calicut":   return ShopMerchantCalicut_spr
		case "hormuz":    return ShopMerchantHormuz_spr
	}
	return ShopMerchantMalacca_spr
}

// Opens a shop. pre_fight = true means the fight comes next; false means the map comes next.
function go_to_shop(shop, pre_fight)
{
	global.CurrentShop = shop
	global.ShopBeforeFight = pre_fight
	room_goto(Shop_Room)
}

// Goes to the travel map (or the old Map_Room if MapTravel_Room is missing)
function go_to_map()
{
	var map_room = asset_get_index("MapTravel_Room")
	if (map_room == -1) map_room = Map_Room
	room_goto(map_room)
}

// The bio shown when you hover a card in your hand. cost is passed in because it can change
// (a card from the Storage chest costs 0). Keep the stats here in sync with the figure objects.
function card_bio(card_obj, cost)
{
	var name = "Card"
	var stats = ""
	var text = ""
	if (card_obj == CardSailor_obj)
	{
		name = "Sailor"
		stats = "ATK 1   HP 1"
		text = "The backbone of the fleet. Moves one row\nforward each battle and attacks the enemy\nfigure in front of it."
	}
	else if (card_obj == CardJumper_obj)
	{
		name = "Jumper"
		stats = "ATK 1   HP 3"
		text = "Moves diagonally: one row forward and one\nlane sideways each battle, bouncing off the\nsides of the ship."
	}
	else if (card_obj == CardArtillery_obj)
	{
		name = "Artillery"
		stats = "HP 5   Fires every 5 turns"
		text = "Doesn't walk. Every 5 turns it fires down its\nlane: 1 damage to every other figure there\n(not your other artillery), then moves up a row.\nStack them in one lane!"
	}
	return name + "   (Cost: " + string(cost) + " units)\n" + stats + "\n" + text
}

// The card that places a figure, so the Rhinoceros Horn can give a lost figure's card back
function card_for_figure(fig_obj)
{
	if (fig_obj == ProtoSailorFigure_obj) return CardSailor_obj
	if (fig_obj == ProtoJumperFigure_obj) return CardJumper_obj
	if (fig_obj == ProtoArtilleryFigure_obj) return CardArtillery_obj
	return -1
}

// True if you're carrying an item of this kind
function item_has(kind)
{
	items_init()
	for (var i = 0; i < array_length(global.Items); i++)
	{
		if (global.Items[i].kind == kind) return true
	}
	return false
}

// Removes the first item of this kind from your bag
function item_remove(kind)
{
	for (var i = 0; i < array_length(global.Items); i++)
	{
		if (global.Items[i].kind == kind)
		{
			array_delete(global.Items, i, 1)
			return
		}
	}
}

// Coins earned for winning a fight: 4, plus 1 for each enemy lane light you turned green
function fight_reward()
{
	var lit_lanes = 0
	with (LaneEndLight_obj) if (watch_team == 1 && lit) lit_lanes += 1
	return 4 + lit_lanes
}

// Copies your item bag (each item is a struct, so they're copied one by one).
// Used to put your items back the way they were when you retry a fight.
function items_copy(list)
{
	var result = []
	for (var i = 0; i < array_length(list); i++)
	{
		array_push(result, { kind: list[i].kind, card: list[i].card })
	}
	return result
}

// Draws a sprite centered on (cx, cy), scaled to fit inside a size x size box
function draw_sprite_fit(spr, cx, cy, size, alpha)
{
	var w = sprite_get_width(spr)
	var h = sprite_get_height(spr)
	var s = min(size / w, size / h)
	var ox = sprite_get_xoffset(spr)
	var oy = sprite_get_yoffset(spr)
	draw_sprite_ext(spr, 0, cx - (w / 2 - ox) * s, cy - (h / 2 - oy) * s, s, s, 0, c_white, alpha)
}

// Dark box with white text, used for item descriptions
function draw_info_box(px, py, text)
{
	var w = string_width(text) + 16
	var h = string_height(text) + 12
	// Keep it on screen
	px = clamp(px, 4, room_width - w - 4)
	py = clamp(py, 4, room_height - h - 4)
	draw_set_alpha(0.85)
	draw_set_color(c_black)
	draw_rectangle(px, py, px + w, py + h, false)
	draw_set_alpha(1)
	draw_set_color(c_white)
	draw_rectangle(px, py, px + w, py + h, true)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
	draw_text(px + 8, py + 6, text)
}
