// The deck. Click it to draw a card into your hand.

// GameMaker uses the same random seed every run unless you call this,
// so without it the shuffle would come out the same every time
randomize()

// Every card in the deck: 20 cards. Good cards get rarer each fight along the route,
// and Slaves only show up after India. The rest of the 20 are Sailors.
// One number per fight: China, Malacca, Mogadishu, India, Arabia, Iraq.
deck_size = 20
jumpers_per_fight   = [5, 4, 4, 3, 3, 2]
artillery_per_fight = [3, 3, 2, 2, 2, 1]
runners_per_fight   = [2, 2, 2, 2, 1, 1]
swordsmen_per_fight = [2, 2, 2, 2, 1, 1]
slaves_per_fight    = [0, 0, 0, 0, 4, 6]
//            Sailors: 8, 9,10,11, 9, 9  (whatever's left of the 20)

var fight = 0
if (variable_global_exists("FightsWon")) fight = clamp(global.FightsWon, 0, array_length(jumpers_per_fight) - 1)
full_deck = []
repeat (jumpers_per_fight[fight]) array_push(full_deck, CardJumper_obj)
repeat (artillery_per_fight[fight]) array_push(full_deck, CardArtillery_obj)
repeat (runners_per_fight[fight]) array_push(full_deck, CardRunner_obj)
repeat (swordsmen_per_fight[fight]) array_push(full_deck, CardSwordsman_obj)
repeat (slaves_per_fight[fight]) array_push(full_deck, CardSlave_obj)
while (array_length(full_deck) < deck_size) array_push(full_deck, CardSailor_obj)

// Shuffles the deck but spreads the good cards evenly through it, so you don't draw
// them all early and then get nothing but Sailors for the rest of the fight.
// The deck is cut into equal chunks, one per good card, and each good card lands
// at a random spot inside its own chunk.
spread_shuffle = function(cards)
{
	var good = []
	var plain = []
	for (var i = 0; i < array_length(cards); i++)
	{
		if (cards[i] == CardSailor_obj) array_push(plain, cards[i])
		else array_push(good, cards[i])
	}
	var g = array_length(good)
	if (g == 0) return array_shuffle(cards)
	good = array_shuffle(good)
	plain = array_shuffle(plain)

	var n = array_length(cards)
	var result = []
	var p = 0
	for (var k = 0; k < g; k++)
	{
		var size = floor((k + 1) * n / g) - floor(k * n / g)
		var spot = irandom(size - 1)
		for (var j = 0; j < size; j++)
		{
			if (j == spot) array_push(result, good[k])
			else if (p < array_length(plain)) { array_push(result, plain[p]); p += 1 }
		}
	}
	while (p < array_length(plain)) { array_push(result, plain[p]); p += 1 }
	return result
}
deck = spread_shuffle(full_deck)

// Extra draws: for every 4 units you get per turn (your units max), you draw 1 extra card.
// So the normal 3 units = 1 card, 4-7 units = 2 cards, 8+ units = 3 cards. The AI has the same rule.
cards_per_draw = function()
{
	return 1 + global.UnitsMax div 4
}

// Running out of cards: when your deck is empty at the start of your turn,
// you skip that turn and the next ones, skip_turns in total (no drawing, no playing,
// but the battle still happens). After the last skipped turn your deck is reshuffled
// back to full. The AI has the same rule in EnemyAI_obj.
skip_turns = 3
skips_left = 0

// Called when your turn is about to start. Returns true if you skip this turn.
check_skip = function()
{
	// The Magnetic Compass item refills an empty deck right away instead, then it's used up
	if (skips_left == 0 && array_length(deck) == 0 && item_has("compass"))
	{
		item_remove("compass")
		deck = spread_shuffle(full_deck)
		show_reminder("Your compass found the way! Deck refilled")
		return false
	}

	if (skips_left == 0 && array_length(deck) == 0) skips_left = skip_turns
	if (skips_left == 0) return false

	skips_left -= 1
	if (skips_left > 0)
	{
		show_reminder("Out of cards! Turn skipped (" + string(skips_left) + " more)")
	}
	else
	{
		show_reminder("Out of cards! Last skipped turn, deck reshuffled")
		deck = spread_shuffle(full_deck)
	}
	return true
}

starting_hand = 3  // cards drawn at the start

// Playtest tools: an "Auto win" button in the top-left corner (F2 does the same).
// Set this to false before you hand the game in.
debug_tools = true
global.DebugTools = debug_tools   // the shop also has a playtest key: F3 = +5 coins
debug_btn_x = 20
debug_btn_y = 20
debug_btn_w = 150
debug_btn_h = 40

// Size of the deck pile, matches the cards in hand (54 x 74 art at 2x)
pile_width = 108
pile_height = 148
back_sprite = noone  // set this to a card back sprite when you make one

// You draw once per turn (1 card + extras, see cards_per_draw), and must draw before playing a card.
// Clicking the turn token sets this back to false.
global.HasDrawn = false

// False while the AI is taking its turn
global.PlayerTurn = true

// 0 while the game is going, 1 when you win, -1 when the AI wins (set by the lane lights)
global.Winner = 0

// True while the dagger is being aimed (Dagger_obj sets this)
global.DaggerAiming = false

// Units pay for cards. You refill every turn and unused units don't carry over.
units_per_turn = 4
global.Units = units_per_turn

// Units refilled at the start of your turn: units_per_turn, plus 1 more on each of the
// first turns (turn 1 = +0, turn 2 = +1, turn 3 and after = +2, up to unit_ramp_max),
// plus 1 for each lane you hold on top. The AI has the same ramp.
global.UnitsMax = units_per_turn
unit_ramp_max = 2
player_turn = 1

// Extra units from the ramp on a given turn number (1 = first turn)
unit_ramp = function(turn)
{
	return min(turn - 1, unit_ramp_max)
}

// Hand limit: you can't hold more than this many cards. Extra draws stay in the deck.
max_hand = 7
hand_count = function()
{
	var n = 0
	with (CardParent_obj) if (in_hand) n += 1
	return n
}

// Which side acts first in the battle phase. Flips every round.
global.FirstSide = 1

// Moves every figure on one side forward (1 = player, -1 = AI), front figures first,
// so the space ahead is already cleared for the ones behind.
// Figures attack an enemy in front of them instead of moving.
move_side = function(side)
{
	var figs = []
	with (FigureParent_obj)
	{
		if (team == side) array_push(figs, id)
	}
	array_sort(figs, function(a, b) { return a.y - b.y })
	if (side == -1) figs = array_reverse(figs)

	for (var i = 0; i < array_length(figs); i++)
	{
		// A figure can be destroyed earlier in the loop, so check it's still there
		if (instance_exists(figs[i])) with (figs[i]) take_action()
	}
}

// Works out what the next battle phase will do, without changing anything on the board.
// It plays the battle out on copies of every figure using the same rules as move_side,
// then stores predicted_damage and predicted_death on each real figure.
// It only knows the board as it is now, so cards the AI plays before the battle aren't counted.
predict_battle = function()
{
	var sims = []
	with (FigureParent_obj)
	{
		array_push(sims, {
			inst: id, x: x, y: y, team: team, attack: attack, hp: hp,
			moves: moves, fire_every: fire_every, turns_waited: turns_waited,
			top_row_y: top_row_y, bottom_row_y: bottom_row_y,
			jumps: jumps, dir_x: dir_x, left_lane_x: left_lane_x, right_lane_x: right_lane_x,
			stunned: stunned, extra: (gallop ? 1 : 0) + sail_moves + speed_moves, blast_damage: blast_damage,
			finishes_lane: finishes_lane, cleaves: cleaves,
			dmg: 0, dead: false
		})
	}

	// Row boosts, same as FigureParent_obj's rows_from_home / hp_bonus / atk_bonus
	var rows = function(s)
	{
		if (s.team == 1) return (s.bottom_row_y - s.y) div 64
		return (s.y - s.top_row_y) div 64
	}
	var s_hp = function(s, rows) { return s.hp + ((rows(s) <= 1) ? 1 : 0) }
	var s_atk = function(s, rows) { return s.attack + ((rows(s) >= 3) ? 1 : 0) }

	var hurt = function(s, amount, s_hp, rows)
	{
		s.hp -= amount
		s.dmg += amount
		if (s_hp(s, rows) <= 0) s.dead = true
	}

	var find_at = function(list, px, py)
	{
		for (var i = 0; i < array_length(list); i++)
		{
			var s = list[i]
			if (!s.dead && s.x == px && s.y == py) return s
		}
		return undefined
	}

	// Runner finishing its lane early: lights the enemy's light there and wipes the lane
	var finish = function(f, lights, sims, s_hp, rows, hurt)
	{
		for (var l = 0; l < array_length(lights); l++)
		{
			var lt = lights[l]
			if (!lt.lit && lt.lane_x == f.x && lt.watch_team == f.team)
			{
				lt.lit = true
				for (var j = 0; j < array_length(sims); j++)
				{
					var t = sims[j]
					if (!t.dead && t.x == lt.lane_x) hurt(t, s_hp(t, rows), s_hp, rows)
				}
			}
		}
	}

	// Unlit lane lights: a figure reaching one clears its whole lane
	var lights = []
	with (LaneEndLight_obj)
	{
		if (!lit) array_push(lights, { lane_x: lane_x, watch_team: watch_team, watch_row_y: watch_row_y, lit: false })
	}

	var order = [global.FirstSide, -global.FirstSide]
	for (var o = 0; o < 2; o++)
	{
		var side = order[o]

		// Same order as move_side: front figures first
		var group = []
		for (var i = 0; i < array_length(sims); i++)
		{
			if (sims[i].team == side) array_push(group, sims[i])
		}
		array_sort(group, function(a, b) { return a.y - b.y })
		if (side == -1) group = array_reverse(group)

		for (var i = 0; i < array_length(group); i++)
		{
			var f = group[i]
			if (f.dead) continue

			// Dazzled figures (Zebra item) skip their action
			if (f.stunned > 0)
			{
				f.stunned -= 1
				continue
			}

			// Move or attack
			if (f.moves)
			{
				var moved = false
				var next_y = f.y - 64 * f.team
				var nx = f.x
				if (f.jumps)
				{
					nx = f.x + 64 * f.dir_x
					if (nx < f.left_lane_x || nx > f.right_lane_x)
					{
						f.dir_x *= -1
						nx = f.x + 64 * f.dir_x
					}
				}
				var ahead = find_at(sims, nx, next_y)
				var far_row = (f.team == 1) ? f.top_row_y : f.bottom_row_y
				if (ahead != undefined && f.finishes_lane && next_y == far_row)
				{
					finish(f, lights, sims, s_hp, rows, hurt)
				}
				else if (ahead == undefined)
				{
					if (next_y >= f.top_row_y && next_y <= f.bottom_row_y)
					{
						f.x = nx
						f.y = next_y
						// Leaving the home rows loses the +1 HP boost
						if (s_hp(f, rows) <= 0) f.dead = true
						moved = true
					}
				}
				else if (ahead.team != f.team && f.attack > 0)
				{
					var dmg = s_atk(f, rows)
					var behind = f.cleaves ? find_at(sims, nx, next_y - 64 * f.team) : undefined
					hurt(ahead, dmg, s_hp, rows)
					// Swordsman: also hits the figure behind, half damage if it's friendly
					if (behind != undefined)
					{
						if (behind.team != f.team) hurt(behind, dmg, s_hp, rows)
						else if (dmg div 2 > 0) hurt(behind, dmg div 2, s_hp, rows)
					}
				}

				// Extra spaces from the Horse or Cotton Cloth items: only after a move, never attacking
				if (moved) repeat (f.extra)
				{
					if (f.dead) break
					var ey = f.y - 64 * f.team
					var ex = f.x
					if (f.jumps)
					{
						ex = f.x + 64 * f.dir_x
						if (ex < f.left_lane_x || ex > f.right_lane_x)
						{
							f.dir_x *= -1
							ex = f.x + 64 * f.dir_x
						}
					}
					if (find_at(sims, ex, ey) != undefined)
					{
						if (f.finishes_lane && ey == far_row) finish(f, lights, sims, s_hp, rows, hurt)
						break
					}
					if (ey < f.top_row_y || ey > f.bottom_row_y) break
					f.x = ex
					f.y = ey
					if (s_hp(f, rows) <= 0) f.dead = true
				}
				f.extra = (f.extra > 0 && f.inst.gallop) ? 1 : 0
			}

			// Artillery countdown and lane blast (same rules as FigureParent_obj's blast_lane):
			// blast_damage to every other figure in the lane except friendly artillery,
			// then it moves up one row if that space is empty
			if (f.fire_every > 0)
			{
				f.turns_waited += 1
				if (f.turns_waited >= f.fire_every)
				{
					for (var j = 0; j < array_length(sims); j++)
					{
						var t = sims[j]
						if (t != f && !t.dead && t.x == f.x && !(t.team == f.team && t.fire_every > 0)) hurt(t, f.blast_damage, s_hp, rows)
					}
					f.turns_waited = 0

					if (!f.moves && !f.dead)
					{
						var ay = f.y - 64 * f.team
						if (find_at(sims, f.x, ay) == undefined && ay >= f.top_row_y && ay <= f.bottom_row_y)
						{
							f.y = ay
							if (s_hp(f, rows) <= 0) f.dead = true
						}
					}
				}
			}
		}

		// Lights are checked between the two sides' actions, like in the real battle
		for (var l = 0; l < array_length(lights); l++)
		{
			var lt = lights[l]
			if (lt.lit) continue
			var at_end = find_at(sims, lt.lane_x, lt.watch_row_y)
			if (at_end != undefined && at_end.team == lt.watch_team)
			{
				lt.lit = true
				for (var j = 0; j < array_length(sims); j++)
				{
					var t = sims[j]
					if (!t.dead && t.x == lt.lane_x) hurt(t, s_hp(t, rows), s_hp, rows)
				}
			}
		}
	}

	for (var i = 0; i < array_length(sims); i++)
	{
		var s = sims[i]
		s.inst.predicted_damage = s.dmg
		s.inst.predicted_death = s.dead
	}
}

// How many lanes (columns of tiles) one side has the majority in
lanes_won = function(side)
{
	var lanes = []
	with (Tile_obj)
	{
		if (!array_contains(lanes, x)) array_push(lanes, x)
	}

	var won = 0
	for (var i = 0; i < array_length(lanes); i++)
	{
		var lane_x = lanes[i]
		var mine = 0
		var theirs = 0
		with (FigureParent_obj)
		{
			if (x == lane_x)
			{
				if (team == side) mine += 1
				else theirs += 1
			}
		}
		if (mine > theirs) won += 1
	}
	return won
}

// Short-lived effects drawn over the board: damage numbers and fading figures
effects = []

// Floating text that rises and fades, like "-1"
add_popup = function(px, py, text, col)
{
	array_push(effects, { kind: "text", x: px, y: py, text: text, col: col, t: 45, life: 45 })
}

// A figure that just died, fading and shrinking away
// ps is the figure's perspective size when it died (1 = full size)
add_ghost = function(spr, px, py, ys, col, ps = 1)
{
	array_push(effects, { kind: "ghost", spr: spr, x: px, y: py, ys: ys, ps: ps, col: col, t: 20, life: 20 })
}

// Reminder text shown above the deck
message = ""
message_timer = 0
message_time = 120  // how many frames the text stays up (60 = 1 second)

show_reminder = function(text)
{
	message = text
	message_timer = message_time
}

// True if the player is allowed to play a card right now
can_play = function()
{
	// If the deck is empty or your hand is full there's nothing to draw, so don't block playing
	return global.HasDrawn || array_length(deck) == 0 || hand_count() >= max_hand
}

// Takes the top card off the deck and puts it in the hand
draw_card = function()
{
	if (array_length(deck) == 0) return noone
	if (hand_count() >= max_hand) return noone
	var card_type = array_pop(deck)
	return instance_create_layer(x, y, layer, card_type)
}

repeat (starting_hand) draw_card()

// Your item slots beside the ship (items bought in the shops, see Items_scr)
items_init()
instance_create_depth(0, 0, -500, ItemBar_obj)

// Snapshot of your items at the start of this fight, so "Retry this stop" can put them back
global.FightStartItems = items_copy(global.Items)
global.FightStartLostCard = global.LastLostCard
global.FightStartPepper = global.PepperTurns

// Coins for winning, worked out once when you win (shown on the win screen)
win_reward = -1

// ---- "How to play" panel ----
// Opens by itself at the start of the first fight (China) once per game,
// and any time from the "?" button in the top-right corner. It pauses the game while open.
global.HelpOpen = false
help_unpause = false   // closing waits one frame so the closing click doesn't also play a card
help_text =
	"HOW TO PLAY\n\n" +
	"GOAL: Turn 3 of the 4 lights at the TOP green.\n" +
	"A light turns green when your figure reaches the enemy's back row.\n" +
	"(The enemy wins if it turns all 4 lights at the BOTTOM green.)\n\n" +
	"YOUR TURN:\n" +
	"1. Click your deck (bottom right) to draw.\n" +
	"2. Click a card, then a glowing tile in your front row.\n" +
	"   Cards cost units (under your deck). Units refill each turn.\n" +
	"3. End your turn with the token (left of the ship) or Space.\n\n" +
	"BATTLE: every figure then moves forward by itself\n" +
	"and attacks whatever is in front of it.\n\n" +
	"TIPS:\n" +
	"- Your 2 home rows give +1 HP. The enemy's 2 rows give +1 attack.\n" +
	"- Hover cards, figures and items to see what they do.\n" +
	"  \"DEATH\" means a figure won't survive the next battle.\n" +
	"- Use items (beside the ship) on your turn. Right-click cancels.\n" +
	"- Escape pauses. The ? button (top right) shows this again.\n\n" +
	"Click anywhere to start"

help_btn_size = 50
help_button_hit = function()
{
	var bx = display_get_gui_width() - help_btn_size - 20
	var by = 20
	return point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), bx, by, bx + help_btn_size, by + help_btn_size)
}

open_help = function()
{
	global.HelpOpen = true
	global.paused = true
	global.SelectedCard = noone
}

close_help = function()
{
	global.HelpOpen = false
	global.TutorialShown = true
	help_unpause = true   // unpause next frame
}

// Show it automatically at the start of the China fight, the first time
if (!variable_global_exists("TutorialShown")) global.TutorialShown = false
var first_fight = !variable_global_exists("FightsWon") || global.FightsWon == 0
if (first_fight && !global.TutorialShown) open_help()

// Buttons on the lose screen, in GUI coordinates (centered on the screen)
lose_button = function(which)
{
	var cx = display_get_gui_width() / 2
	var cy = display_get_gui_height() / 2
	var w = 240
	var h = 60
	var bx = (which == "retry") ? cx - w - 20 : cx + 20
	return { x1: bx, y1: cy + 30, x2: bx + w, y2: cy + 30 + h }
}
mouse_on_lose_button = function(which)
{
	var b = lose_button(which)
	return point_in_rectangle(device_mouse_x_to_gui(0), device_mouse_y_to_gui(0), b.x1, b.y1, b.x2, b.y2)
}
