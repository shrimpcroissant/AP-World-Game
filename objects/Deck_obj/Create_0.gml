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
runners_per_fight   = [2, 2, 2, 2, 2, 2]
swordsmen_per_fight = [2, 2, 2, 2, 2, 2]
slaves_per_fight    = [0, 0, 0, 0, 0, 0]   // the Slave card is out of the game
//            Sailors: 8, 9,10,11,11,13  (whatever's left of the 20)

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

// Running out of cards: when your deck is empty at the start of your turn, you can't draw
// for skip_turns turns (you still play the cards in your hand, and they don't age meanwhile).
// On the last of those turns your deck is reshuffled back to full for the turn after.
// The AI skips whole turns instead (see EnemyAI_obj).
skip_turns = 3
skips_left = 0

// Called when your turn is about to start. Returns true if you can't draw this turn.
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
		show_reminder("Out of cards! No draw this turn (" + string(skips_left) + " more)")
	}
	else
	{
		show_reminder("Out of cards! No draw this turn, deck reshuffled for next turn")
		deck = spread_shuffle(full_deck)
	}
	return true
}

// True on a turn where you can't draw because you ran out of cards (set by EnemyAI_obj
// when your turn starts). You still get the turn and can play the cards in your hand.
draw_skipped = false

starting_hand = 3  // cards drawn at the start

// Testing tools: an "Auto win" button in the top-left corner (F2 does the same).
// Set this to false before you hand the game in.
debug_tools = true
global.DebugTools = debug_tools   // the shop also has a testing key: F3 = +5 coins
debug_btn_x = 20
debug_btn_y = 20
debug_btn_w = 150
debug_btn_h = 40

// Size of the deck pile, matches the cards in hand (54 x 74 art at 2x)
pile_width = 108
pile_height = 148
back_sprite = noone  // set this to a card back sprite when you make one

// You can draw once per turn (1 card + extras, see cards_per_draw). Drawing is optional:
// you can play cards and end your turn without drawing.
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
if (difficulty() == 0 && !is_boss_fight()) units_per_turn = 5   // Easy: 1 extra unit a turn
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

// Cards only stay in your hand for hand_turns of your turns: a card drawn on turn 1 can be
// played on turns 1, 2 and 3, then it leaves your hand when turn 4 starts.
// Called by EnemyAI_obj each time your turn comes around (skipped turns count too).
hand_turns = 3
age_hand = function()
{
	var gone = 0
	var limit = hand_turns
	with (CardParent_obj)
	{
		if (!in_hand) continue
		turns_in_hand += 1
		if (turns_in_hand >= limit)
		{
			if (global.SelectedCard == id) global.SelectedCard = noone
			var cx = rest_x
			var cy = rest_y - 160
			with (other) add_popup(cx, cy, "Discarded", c_orange)
			instance_destroy()
			gone += 1
		}
	}
	return gone
}

// The reminder for cards age_hand discarded (shown after "Your turn" so it isn't covered up)
show_discarded = function(gone)
{
	if (gone == 1) show_reminder("Your turn. 1 old card was discarded")
	else if (gone > 1) show_reminder("Your turn. " + string(gone) + " old cards were discarded")
}
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
			// blast_damage to every enemy figure in the lane, then it moves up one row if that space is empty
			if (f.fire_every > 0)
			{
				f.turns_waited += 1
				if (f.turns_waited >= f.fire_every)
				{
					for (var j = 0; j < array_length(sims); j++)
					{
						var t = sims[j]
						if (!t.dead && t.x == f.x && t.team != f.team) hurt(t, f.blast_damage, s_hp, rows)
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

// Testing "Auto win": counts up while it lights the enemy's lanes one by one (-1 = off)
auto_win_timer = -1

// ---- Story screens, the "How to play" panel and the China tutorial ----
// The panel pauses the game while it's open. It shows either a story screen (story_open)
// or the "How to play" text. "?" (top right) opens "How to play" any time.
global.HelpOpen = false
help_unpause = false   // closing waits one frame so the closing click doesn't also play a card
help_text = how_to_play_text()   // the text lives in Items_scr so the main menu can show it too

// Where everything in the "How to play" panel goes (used by Draw GUI and by the click check):
// the text wrapped to fit and shrunk if the screen is short, then the rulebook link button
help_layout = function()
{
	var gw = display_get_gui_width()
	var gh = display_get_gui_height()
	var wrap = 780
	var th = string_height_ext(help_text, -1, wrap)
	var ts = min(1.3, (gh - 220) / th)
	var pw = string_width_ext(help_text, -1, wrap) * ts + 60
	var ph = th * ts + 50 + 60 + 54
	var px = gw / 2 - pw / 2
	var py = gh / 2 - ph / 2
	var lw = 440
	var ly = py + 25 + th * ts + 16
	return { px: px, py: py, pw: pw, ph: ph, ts: ts, wrap: wrap,
		link: { x1: gw / 2 - lw / 2, y1: ly, x2: gw / 2 + lw / 2, y2: ly + 38 } }
}
help_link_hit = function()
{
	var l = help_layout().link
	return point_in_rectangle(gui_mouse_x(), gui_mouse_y(), l.x1, l.y1, l.x2, l.y2)
}

help_btn_size = 50
help_button_hit = function()
{
	var bx = display_get_gui_width() - help_btn_size - 20
	var by = 20
	return point_in_rectangle(gui_mouse_x(), gui_mouse_y(), bx, by, bx + help_btn_size, by + help_btn_size)
}

// story_open = true means the panel is showing story_shown instead of help_text
story_open = false
story_shown = ""

// First-time screens (stories, and "How to play" at the end of the tutorial) close by holding
// the mouse button or Space for hold_needed seconds while a bar fills, so a stray click can't
// skip them. "How to play" opened from the "?" button closes with one click.
hold_needed = 1
hold = 0
needs_hold = false

open_help = function(first_time = false)
{
	global.HelpOpen = true
	global.paused = true
	global.SelectedCard = noone
	needs_hold = first_time
	hold = 0
}

// China, first time: the story screen is followed by How to Play (also hold to continue),
// then the tutorial starts
help_after_story = false
hold_release = false   // true = wait for the button/Space to be let go before the hold bar can fill

close_help = function()
{
	if (story_open && help_after_story)
	{
		story_open = false
		help_after_story = false
		needs_hold = true
		hold = 0
		hold_release = true
		return
	}
	story_open = false
	global.HelpOpen = false
	hold = 0
	dbg("Panel closed (story or How to play)")
	help_unpause = true   // unpause next frame
	block_input_briefly() // and ignore that click/Space for a moment
}

var fights_before = variable_global_exists("FightsWon") ? global.FightsWon : 0
if (!variable_global_exists("TutorialShown")) global.TutorialShown = false

// ---- China tutorial (scripted) ----
// The first fight walks you through your first turn one step at a time. Each step:
//   wait  = what moves it on ("draw", "place", "end", "battle" happen by themselves; "next" = the Next button)
//   spot  = what gets highlighted ("deck", "hand", "tiles", "token", "board", "lights", "dagger")
//   allow = the only actions that work during the step (see tutorial_allows in Items_scr)
// Everything outside the highlight is dimmed. "Skip tutorial" ends it. The last step points out the
// ? button for How to Play (it isn't opened automatically).
tutorial_steps = [
	{ wait: "draw",   spot: "deck",   allow: "draw",       text: "Welcome aboard! Your crew is at the bottom, the enemy crew at the top. Click your deck to draw cards. Drawing is free, once per turn." },
	{ wait: "next",   spot: "units",  allow: "",           text: "These are your UNITS, what you spend to place cards. Each card costs units. You get 4 a turn, 1 more on turn 2 and 2 more from turn 3 on, plus 1 for each lane where you have more figures than the enemy. Unused units don't carry over." },
	{ wait: "next",   spot: "bios",   allow: "",           text: "Hover over a card to read its bio: its cost, attack and health, how it moves and how it attacks. Try it now, then press Next." },
	{ wait: "place",  spot: "hand",   allow: "place",      text: "Now place one. Click a card in your hand, then a glowing tile on your front row." },
	{ wait: "end",    spot: "token+hand+tiles", allow: "place,end",  text: "You can place more figures if you have units left. When you're done, click the token to end your turn (or press Space)." },
	{ wait: "battle", spot: "board",  allow: "",           text: "Battle! First the enemy draws and places its figures. Then each side's figures act one at a time: each one moves forward, or attacks an enemy right in front of it. Click the play button to watch it unfold." },
	{ wait: "next",   spot: "lights", allow: "",           text: "Get a figure to the far end of a lane to turn that lane's light green. Turn 3 of these 4 green to win. The enemy needs all 4 of yours." },
	{ wait: "next",   spot: "dagger", allow: "",           text: "The Dagger removes one of your own figures on your first two rows, to free up a spot. Hover anything to see what it does." },
	{ wait: "next",   spot: "help",   allow: "",           text: "Cards only stay in your hand for 3 turns, so use them. If you ever forget a rule, click the ? button up here to open How to Play. It also links to the full illustrated rulebook. Good luck, captain!" }
]
tutorial_step = (fights_before == 0 && !global.TutorialShown) ? 0 : -1
tutorial_figs = 0   // your figures on the board when the current step started
global.TutorialAllow = "all"
global.TutorialPhaseMode = false
global.TutorialReleased = []
global.TutorialLanesOpen = false

// How many of your figures are on the board
player_figure_count = function()
{
	var n = 0
	with (FigureParent_obj) if (team == 1) n += 1
	return n
}

// Room position -> GUI position (the pop-up layer can be scaled and shifted from the room)
room_to_gui_x = function(rx)
{
	if (view_enabled && view_visible[0]) return (rx - camera_get_view_x(view_camera[0])) * display_get_gui_width() / camera_get_view_width(view_camera[0])
	return rx * display_get_gui_width() / room_width
}
room_to_gui_y = function(ry)
{
	if (view_enabled && view_visible[0]) return (ry - camera_get_view_y(view_camera[0])) * display_get_gui_height() / camera_get_view_height(view_camera[0])
	return ry * display_get_gui_height() / room_height
}

// The highlighted area for the current step, in GUI coordinates, or undefined for none
tutorial_spot = function()
{
	if (tutorial_step < 0) return undefined
	var what = tutorial_steps[tutorial_step].spot
	// While placing, once a card is picked the highlight moves to the tiles you can place it on
	if (what == "hand" && tutorial_steps[tutorial_step].wait == "place" && instance_exists(global.SelectedCard)) what = "tiles"
	var x1 = infinity
	var y1 = infinity
	var x2 = -infinity
	var y2 = -infinity
	// A spot can name several areas joined by + (like "token+hand+tiles"): it covers all of them
	var parts = string_split(what, "+")
	for (var part_i = 0; part_i < array_length(parts); part_i++) switch (parts[part_i])
	{
		case "deck":
			var half = max(pile_width / 2, 85)   // wide enough for the units text under the deck
			x1 = x - half; y1 = y - pile_height / 2
			x2 = x + half; y2 = y + pile_height / 2 + 30
			break
		case "hand":
			with (CardParent_obj)
			{
				if (!in_hand) continue
				var cw = (sprite_get_bbox_right(sprite_index) - sprite_get_bbox_left(sprite_index) + 1) * card_scale
				var ch = (sprite_get_bbox_bottom(sprite_index) - sprite_get_bbox_top(sprite_index) + 1) * card_scale
				x1 = min(x1, rest_x - cw / 2); x2 = max(x2, rest_x + cw / 2)
				y1 = min(y1, rest_y - ch - 30); y2 = max(y2, rest_y)
			}
			break
		case "tiles":
			with (Tile_obj)
			{
				if (y != 452) continue
				x1 = min(x1, bbox_left); x2 = max(x2, bbox_right)
				y1 = min(y1, bbox_top); y2 = max(y2, bbox_bottom)
			}
			break
		case "board":
			with (Tile_obj) { x1 = min(x1, bbox_left); x2 = max(x2, bbox_right); y1 = min(y1, bbox_top); y2 = max(y2, bbox_bottom) }
			with (LaneEndLight_obj) { x1 = min(x1, bbox_left); x2 = max(x2, bbox_right); y1 = min(y1, bbox_top); y2 = max(y2, bbox_bottom) }
			break
		case "units":
			// The units text under the deck
			x1 = x - 85; x2 = x + 85
			y1 = y + pile_height / 2; y2 = y + pile_height / 2 + 34
			break
		case "bios":
			// The hand, plus the space above it where a card's bio pops up
			with (CardParent_obj)
			{
				if (!in_hand) continue
				var bw2 = (sprite_get_bbox_right(sprite_index) - sprite_get_bbox_left(sprite_index) + 1) * card_scale
				var bh2 = (sprite_get_bbox_bottom(sprite_index) - sprite_get_bbox_top(sprite_index) + 1) * card_scale
				x1 = min(x1, rest_x - bw2 / 2 - 140); x2 = max(x2, rest_x + bw2 / 2 + 140)
				y1 = min(y1, rest_y - bh2 - 260); y2 = max(y2, rest_y)
			}
			break
		case "lights":
			with (LaneEndLight_obj)
			{
				if (watch_team != 1) continue
				x1 = min(x1, bbox_left); x2 = max(x2, bbox_right)
				y1 = min(y1, bbox_top); y2 = max(y2, bbox_bottom)
			}
			break
		case "token":
			with (Token_obj) { x1 = min(x1, bbox_left); x2 = max(x2, bbox_right); y1 = min(y1, bbox_top); y2 = max(y2, bbox_bottom + 36) }   // includes "End turn (Space)"
			break
		case "dagger":
			with (Dagger_obj)
			{
				x1 = min(x1, home_x - abs(sprite_width) / 2); x2 = max(x2, home_x + abs(sprite_width) / 2)
				y1 = min(y1, home_y - abs(sprite_height) / 2); y2 = max(y2, home_y + abs(sprite_height) / 2 + 20)
			}
			break
	}
	// The ? button is on the pop-up layer already (top right), so it's returned as it is
	if (what == "help")
	{
		var hx = display_get_gui_width() - help_btn_size - 20
		return { x1: hx - 8, y1: 12, x2: hx + help_btn_size + 8, y2: 20 + help_btn_size + 8 }
	}
	if (x1 == infinity) return undefined
	var pad = 8
	return { x1: room_to_gui_x(x1) - pad, y1: room_to_gui_y(y1) - pad, x2: room_to_gui_x(x2) + pad, y2: room_to_gui_y(y2) + pad }
}

// The prompt box, in GUI coordinates. Its height fits the wrapped text, and it sits at the top
// of the screen unless that would cover the highlight, then just below the highlight instead.
tutorial_text_scale = 1.2
tutorial_box = function()
{
	var w = min(780, display_get_gui_width() - 40)
	var wrap = (w - 28) / tutorial_text_scale
	var th = string_height_ext(tutorial_steps[tutorial_step].text, -1, wrap) * tutorial_text_scale
	var h = 30 + th + 54
	var x1 = display_get_gui_width() / 2 - w / 2
	var y1 = 16
	var spot = tutorial_spot()
	if (spot != undefined && spot.y1 < y1 + h + 8 && spot.y2 > y1)
	{
		y1 = spot.y2 + 16
		if (y1 + h > display_get_gui_height() - 8) y1 = max(8, spot.y1 - h - 16)   // no room below: go above
	}
	return { x1: x1, y1: y1, x2: x1 + w, y2: y1 + h, wrap: wrap }
}
// Next only shows on steps that wait for it; the action steps move on when you do the action
// The battle step also has Next, but it stays disabled until the battle is over
tutorial_has_next = function()
{
	var w = tutorial_steps[tutorial_step].wait
	return w == "next" || w == "battle"
}
tutorial_next_enabled = function()
{
	return tutorial_steps[tutorial_step].wait != "battle" || global.PlayerTurn
}
// No Skip on the last step
tutorial_has_skip = function()
{
	return tutorial_step < array_length(tutorial_steps) - 1
}
// The play button only exists on the battle step, and only works while the enemy waits at a phase
tutorial_has_play = function()
{
	return tutorial_steps[tutorial_step].wait == "battle"
}
tutorial_play_enabled = function()
{
	return tutorial_has_play() && instance_exists(EnemyAI_obj) && EnemyAI_obj.timer <= 0 && tutorial_phase_waiting(EnemyAI_obj.state)
}
tutorial_button = function(which)
{
	var b = tutorial_box()
	if (which == "next") return { x1: b.x2 - 130, y1: b.y2 - 44, x2: b.x2 - 12, y2: b.y2 - 10 }
	if (which == "play") return { x1: b.x1 + 14, y1: b.y2 - 44, x2: b.x1 + 48, y2: b.y2 - 10 }
	return { x1: b.x2 - 290, y1: b.y2 - 44, x2: b.x2 - 142, y2: b.y2 - 10 }
}
tutorial_hit = function(mx, my)
{
	if (tutorial_has_next())
	{
		var r = tutorial_button("next")
		if (point_in_rectangle(mx, my, r.x1, r.y1, r.x2, r.y2)) return "next"
	}
	if (tutorial_has_skip())
	{
		var s = tutorial_button("skip")
		if (point_in_rectangle(mx, my, s.x1, s.y1, s.x2, s.y2)) return "skip"
	}
	if (tutorial_has_play())
	{
		var p = tutorial_button("play")
		if (point_in_rectangle(mx, my, p.x1, p.y1, p.x2, p.y2)) return "play"
	}
	var b = tutorial_box()
	if (point_in_rectangle(mx, my, b.x1, b.y1, b.x2, b.y2)) return "box"
	return ""
}

tutorial_advance = function()
{
	tutorial_step += 1
	dbg("Tutorial step " + string(tutorial_step + 1))
	tutorial_figs = player_figure_count()
	if (tutorial_step >= array_length(tutorial_steps))
	{
		tutorial_step = -1
		global.TutorialShown = true
		global.TutorialAllow = "all"   // How to Play isn't forced open; the last step points to the ? button
	}
}
// Story screen before this fight, once per game (so not again on "Retry this stop")
var story_key = story_before_fight(fights_before)
if (story_first_time(story_key))
{
	story_open = true
	story_shown = story_text(story_key)
	open_help(true)
	help_after_story = (tutorial_step == 0)
}
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
	return point_in_rectangle(gui_mouse_x(), gui_mouse_y(), b.x1, b.y1, b.x2, b.y2)
}

// Debug prints (see dbg in Items_scr)
dbg_last_fps = current_time
dbg_winner_said = false
global.BossOpe = false   // final fight: true when you were "about to win" (see LaneEndLight_obj)
dbg("Fight start: stop " + string(fights_before) + " in " + room_get_name(room) + ", difficulty " + string(difficulty()) + ", deck " + string(array_length(deck)) + ", items " + string(array_length(global.Items)))

// Final fight: the boss warning is a story pop-up (see story_before_fight)
