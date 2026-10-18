// The deck. Click it to draw a card into your hand.

// GameMaker uses the same random seed every run unless you call this,
// so without it the shuffle would come out the same every time
randomize()

// Every card in the deck. To add a card, put its object in this list.
// Any object whose parent is CardParent_obj works.
// 15 sailors, 3 jumpers, 2 artillery (artillery is 10% of the deck)
deck = [
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj, CardSailor_obj,
	CardJumper_obj, CardJumper_obj, CardJumper_obj,
	CardArtillery_obj, CardArtillery_obj,
]
deck = array_shuffle(deck)

starting_hand = 3  // cards drawn at the start

// Size of the deck pile, matches the cards in hand (54 x 74 art at 2x)
pile_width = 108
pile_height = 148
back_sprite = noone  // set this to a card back sprite when you make one

// You draw one card per turn, and must draw before playing a card.
// Clicking the turn token sets this back to false.
global.HasDrawn = false

// False while the AI is taking its turn
global.PlayerTurn = true

// 0 while the game is going, 1 when you win, -1 when the AI wins (set by the lane lights)
global.Winner = 0

// True while the dagger is being aimed (Dagger_obj sets this)
global.DaggerAiming = false

// Units pay for cards. You refill every turn and unused units don't carry over.
units_per_turn = 3
global.Units = units_per_turn

// Units refilled at the start of your turn: units_per_turn plus 1 for each lane you hold
global.UnitsMax = units_per_turn

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
			shield_used: shield_used, dmg: 0, dead: false
		})
	}

	// Row boosts, same as FigureParent_obj's rows_from_home / hp_bonus / atk_bonus
	var rows = function(s)
	{
		if (s.team == 1) return (s.bottom_row_y - s.y) div 64
		return (s.y - s.top_row_y) div 64
	}
	var s_hp = function(s, rows) { return s.hp + ((rows(s) <= 1 && !s.shield_used) ? 1 : 0) }
	var s_atk = function(s, rows) { return s.attack + ((rows(s) >= 3) ? 1 : 0) }

	var hurt = function(s, amount, s_hp, rows)
	{
		var to_hp = amount
		if (rows(s) <= 1 && !s.shield_used)
		{
			s.shield_used = true
			to_hp -= 1
		}
		s.hp -= to_hp
		s.dmg += amount
		if (s.hp <= 0) s.dead = true
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

			// Move or attack
			if (f.moves)
			{
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
				if (ahead == undefined)
				{
					if (next_y >= f.top_row_y && next_y <= f.bottom_row_y)
					{
						f.x = nx
						f.y = next_y
					}
				}
				else if (ahead.team != f.team)
				{
					hurt(ahead, s_atk(f, rows), s_hp, rows)
				}
			}

			// Artillery countdown and lane blast
			if (f.fire_every > 0)
			{
				f.turns_waited += 1
				if (f.turns_waited >= f.fire_every)
				{
					for (var j = 0; j < array_length(sims); j++)
					{
						var t = sims[j]
						if (t != f && !t.dead && t.x == f.x) hurt(t, s_atk(f, rows), s_hp, rows)
					}
					f.turns_waited = 0
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
add_ghost = function(spr, px, py, ys, col)
{
	array_push(effects, { kind: "ghost", spr: spr, x: px, y: py, ys: ys, col: col, t: 20, life: 20 })
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
	// If the deck is empty there's nothing to draw, so don't block playing
	return global.HasDrawn || array_length(deck) == 0
}

// Takes the top card off the deck and puts it in the hand
draw_card = function()
{
	if (array_length(deck) == 0) return noone
	var card_type = array_pop(deck)
	return instance_create_layer(x, y, layer, card_type)
}

repeat (starting_hand) draw_card()
