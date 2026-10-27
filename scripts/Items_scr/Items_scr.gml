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

// ---- The ending ----
// Shown on the map after you win the Iraq fight: ted's closing narrative, then the credits,
// then back to the menu. Replace the placeholder text with the real text.
function ending_text()
{
	return "[ENDING TEXT GOES HERE: what happens after you reach the coast of Iraq.]"
}

function credits_text()
{
	return "MONSOON ROUTE\n\n[CREDITS GO HERE]\n\nArt and design: ted\n\nThanks for playing!"
}

// ---- Difficulty ----
// global.Difficulty: 0 = Easy, 1 = Normal, 2 = Hard. Picked on the start screen (Start_Button).
// The enemy's settings for each are in EnemyAI_obj's Create event.
function difficulty_names()
{
	return ["Easy", "Normal", "Hard"]
}

function difficulty()
{
	if (!variable_global_exists("Difficulty")) global.Difficulty = 1
	return global.Difficulty
}

// The Easy / Normal / Hard buttons on the start screen (the menu art is 341 x 192)
function difficulty_button(i)
{
	var w = 46
	var h = 16
	var gap = 6
	var x1 = 170 - (3 * w + 2 * gap) / 2 + i * (w + gap)
	return { x1: x1, y1: 132, x2: x1 + w, y2: 132 + h }
}

// ---- The route ----
// Stops in order. The fight at stop i is the (i+1)th fight, so after it global.FightsWon = i + 1.
function route_stops()
{
	return ["China", "Malacca", "Mogadishu", "India", "Arabia", "Iraq"]
}

// Where each stop is on the map art (Map_spr is 341 x 192), in route order
function route_stop_points()
{
	return [[238, 66], [211, 112], [90, 104], [157, 93], [108, 62], [92, 44]]
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
// China is fight 1, so 1 = after China (a small starter shop), 2 = after Malacca, 3 = after Mogadishu, 4 = after India,
// 5 = after Arabia (you sail back into Hormuz before heading for Iraq).
function shop_after_fight(fights_won)
{
	switch (fights_won)
	{
		case 1: return "china"
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
		case "china":     return ["compass", "cloves"]   // small starter shop after the tutorial fight
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
	// China has no merchant art yet: it uses ShopMerchantChina_spr once that sprite exists
	if (shop == "china")
	{
		var china = asset_get_index("ShopMerchantChina_spr")
		if (china != -1) return china
	}
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

// ---- Story screens ----
// Full-screen story text shown once per game (not again when you retry a fight).
// "china", "malacca" and "arabia" show at the start of that fight (Deck_obj),
// "detour" shows on the map after Malacca, when the ship ends up heading for Mogadishu (MapDisplay_obj).
function story_text(key)
{
	switch (key)
	{
		case "china":
			return "In 1410, you were appointed captain of a massive trade deal between the Ming dynasty, the Kingdom of Calicut, and the Jalayirid Sultanate. You were to sail to India, pay for 1,000 slaves, and carry them to the coast of Iraq, where a series of small dhows would pick them up and take them the rest of the way, since your massive ship could not sail in the shallower waters. The deal was a ploy to show off the economic might of the Ming and convince more states to join the tributary system. Because of this, you were given a much bigger budget than most voyages, and even extra gold to sell or trade for new supplies in case anything went wrong. You will need it: pirates infest the whole route, so expect to fight your way from port to port."
		case "malacca":
			return "In 1405, the Sultanate of Malacca joined the Chinese tributary system. Because of this, Zheng He helped it grow into the country it is today. A big project during this time was ridding Malacca of its criminal underworld."
		case "detour":
			return "Because of your Ming connections, former criminals misled you and let your ship leave the harbor at the wrong time, forcing you to detour to the city-state of Mogadishu."
		case "arabia":
			return "Your deal was with the Jalayirids, but the Kara Koyunlu, a Turkoman dynasty, have just taken Baghdad from them. Because of this, the Kara Koyunlu attack you on your way into the coast. You must attempt an escape while fighting off attackers on all sides in the dead of night."	}
	return ""
}

// Which story screen comes before a fight, by how many fights you've won before it ("" = none)
function story_before_fight(fights_won)
{
	switch (fights_won)
	{
		case 0: return "china"
		case 1: return "malacca"
		case 4: return "arabia"
	}
	return ""
}

// True the first time it's asked about a story this game, then false (so each one shows once).
// Start_Button clears global.StorySeen when you start a new game.
function story_first_time(key)
{
	if (key == "" || story_text(key) == "") return false
	if (!variable_global_exists("StorySeen")) global.StorySeen = {}
	if (variable_struct_exists(global.StorySeen, key)) return false
	global.StorySeen[$ key] = true
	return true
}

// Draws a story screen: dims the whole area, then a framed box with the text wrapped to fit,
// and the hold-to-continue bar (hold_frac 0 to 1).
// (ax, ay, aw, ah) is the area to cover, k scales the text (1 = normal size).
function draw_story_panel(ax, ay, aw, ah, k, text, hold_frac)
{
	draw_set_alpha(0.75)
	draw_set_color(c_black)
	draw_rectangle(ax, ay, ax + aw, ay + ah, false)
	draw_set_alpha(1)

	var ts = 1.6 * k          // text size
	var wrap = 560            // wrap width before scaling
	var tw = string_width_ext(text, -1, wrap) * ts
	var th = string_height_ext(text, -1, wrap) * ts
	var pw = max(tw, 320 * k) + 80 * k
	var ph = th + 130 * k
	var px = ax + aw / 2 - pw / 2
	var py = ay + ah / 2 - ph / 2
	draw_set_color(make_color_rgb(60, 40, 20))
	draw_rectangle(px, py, px + pw, py + ph, false)
	draw_set_color(make_color_rgb(220, 190, 120))
	draw_rectangle(px, py, px + pw, py + ph, true)
	draw_rectangle(px + 3, py + 3, px + pw - 3, py + ph - 3, true)

	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_text_ext_transformed(px + pw / 2, py + 40 * k, text, -1, wrap, ts, ts, 0)
	draw_hold_bar(px + pw / 2, py + ph - 70 * k, 300 * k, k, hold_frac)
	draw_set_color(c_white)
	draw_set_halign(fa_left)
	draw_set_valign(fa_top)
}

// ---- Pop-ups and input ----
// True while a pop-up or the pause menu is open, and for a moment after one closes,
// so the click (or Space) that closes it doesn't also play a card, place a figure, etc.
// Everything you click during a fight checks this first.
function input_blocked()
{
	if (variable_global_exists("paused") && global.paused) return true
	if (variable_global_exists("InputBlockUntil") && current_time < global.InputBlockUntil) return true
	return false
}

// Call this when a pop-up closes
function block_input_briefly()
{
	global.InputBlockUntil = current_time + 150
}

// ---- Cursor ----
// The cursor art: Cursor_spr if it exists (ted's custom cursor), otherwise Mouse_spr
function custom_cursor_sprite()
{
	var spr = asset_get_index("Cursor_spr")
	if (spr != -1 && sprite_exists(spr)) return spr
	return Mouse_spr
}

// Draws the cursor in a Draw GUI event, so it shows on top of every pop-up
function draw_cursor_gui()
{
	draw_sprite(Mouse_spr, 0, device_mouse_x_to_gui(0), device_mouse_y_to_gui(0))
}

// ---- Hold to continue ----
// The bar on first-time screens: fills while you hold the mouse button or Space.
// frac is 0 to 1. Drawn centered on cx, with its top at y, w wide (k scales it).
function draw_hold_bar(cx, y, w, k, frac)
{
	var h = 14 * k
	draw_set_color(make_color_rgb(30, 20, 10))
	draw_rectangle(cx - w / 2, y, cx + w / 2, y + h, false)
	draw_set_color(make_color_rgb(220, 190, 120))
	if (frac > 0) draw_rectangle(cx - w / 2, y, cx - w / 2 + w * clamp(frac, 0, 1), y + h, false)
	draw_rectangle(cx - w / 2, y, cx + w / 2, y + h, true)
	draw_set_halign(fa_center)
	draw_set_valign(fa_top)
	draw_set_color(c_white)
	draw_set_alpha(0.65 + 0.35 * sin(current_time / 200))
	draw_text_transformed(cx, y + h + 8 * k, "Hold click or Space to continue", 1.2 * k, 1.2 * k, 0)
	draw_set_alpha(1)
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
		text = "Moves: 1 row forward each battle.\nAttacks: an enemy right in front of it\n(instead of moving). Waits behind your own figures."
	}
	else if (card_obj == CardJumper_obj)
	{
		name = "Jumper"
		stats = "ATK 1   HP 3"
		text = "Moves: diagonally, 1 row forward and 1 lane over,\nbouncing off the sides of the ship.\nAttacks: an enemy on the diagonal space it\nwould move to."
	}
	else if (card_obj == CardArtillery_obj)
	{
		name = "Artillery"
		stats = "HP 5   Fires every 5 turns"
		text = "Moves: doesn't walk.\nAttacks: every 5 turns it fires its whole lane,\n1 damage to every enemy there (never your\nown figures), then moves up a row."
	}
	else if (card_obj == CardRunner_obj)
	{
		name = "Runner"
		stats = "ATK 2   HP 2"
		text = "Moves: 2 spaces each battle (the 2nd step only\ngoes into an empty space). Attacks: like a Sailor.\nSpecial: blocked on the row before the enemy's\nback row, it finishes the lane anyway."
	}
	else if (card_obj == CardSwordsman_obj)
	{
		name = "Swordsman"
		stats = "ATK 2   HP 1"
		text = "Moves: like a Sailor.\nAttacks: with an enemy in front, it hits BOTH\nspaces ahead. Enemies take full damage,\nyour own figures take half."
	}
	else if (card_obj == CardSlave_obj)
	{
		name = "Slave"
		stats = "ATK 0   HP 1"
		text = "Enslaved people were forced into labor and traded\nacross the Indian Ocean world.\nMoves: like a Sailor. Never attacks:\nit can only block and fill lanes."
	}
	return name + "   (Cost: " + string(cost) + " units)\n" + stats + "\n" + text
}

// The card that places a figure, so the Rhinoceros Horn can give a lost figure's card back
function card_for_figure(fig_obj)
{
	if (fig_obj == ProtoSailorFigure_obj) return CardSailor_obj
	if (fig_obj == ProtoJumperFigure_obj) return CardJumper_obj
	if (fig_obj == ProtoArtilleryFigure_obj) return CardArtillery_obj
	if (fig_obj == RunnerFigure_obj) return CardRunner_obj
	if (fig_obj == SwordsmanFigure_obj) return CardSwordsman_obj
	if (fig_obj == SlaveFigure_obj) return CardSlave_obj
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
