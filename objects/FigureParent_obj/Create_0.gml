// Shared setup for every figure on the board.
// Child figures: put event_inherited() at the top of your Create event.

if (variable_global_exists("FigureAmount"))
{	
	global.FigureAmount += 1
} else {
	global.FigureAmount = 1
}

// Which side this figure is on: 1 = player (moves up), -1 = AI (moves down).
// The AI sets this to -1 on the figures it plays.
team = 1

// Fighting stats. Set them in each figure's own Create event, under event_inherited().
// (Named hp, not health, because GameMaker already has a built-in "health".)
attack = 1
hp = 1

// Figures that don't move (like Artillery) set moves = false.
// fire_every > 0 makes the figure blast its whole lane every that many turns,
// hitting every enemy figure in the lane (never its own side).
moves = true
fire_every = 0
turns_waited = 0

// Figures with jumps = true (like the Jumper) move diagonally: one row forward and
// one lane sideways, bouncing off the side walls. dir_x is 1 for right, -1 for left.
jumps = false
dir_x = 1

// Game feel: the figure slides to its new spot, and flashes and shakes when hit
draw_x = x
draw_y = y
flash = 0
shake = 0

// Item effects on this figure (see ItemBar_obj):
gallop = false   // Arabian Horse: moves 2 spaces every turn
sail_moves = 0   // Calicut Cotton Cloth: extra spaces to move in the next battle only
stunned = 0      // Zebra: skips this many of its next actions

// Special abilities (set in each figure's own Create event):
speed_moves = 0         // extra spaces moved every turn (Runner = 1)
finishes_lane = false   // Runner: blocked on the row before the enemy's back row = lane finished
cleaves = false         // Swordsman: strikes both spaces in front, half damage to your own figures

// Takes damage, shows the hit, and removes the figure if it runs out of HP
// The +1 HP row boost counts toward total HP, so a figure dies when total_hp() runs out.
take_damage = function(amount)
{
	hp -= amount
	flash = 10
	shake = 6
	var fx = x
	var fy = y
	with (Deck_obj) add_popup(fx, fy - 20, "-" + string(amount), c_red)

	if (total_hp() <= 0 && !saved_by_myrrh()) die()
}

// The Myrrh item: the first time one of your figures would die, it survives with 1 HP instead
saved_by_myrrh = function()
{
	if (team != 1 || !item_has("myrrh")) return false
	item_remove("myrrh")
	hp = 1 - hp_bonus()   // total HP of exactly 1
	var fx = x
	var fy = y
	with (Deck_obj) add_popup(fx, fy - 40, "Saved by myrrh!", c_lime)
	return true
}

// Removes the figure with a fade-out
die = function()
{
	// Remember your last lost figure's card, for the Rhinoceros Horn item
	if (team == 1) global.LastLostCard = card_for_figure(object_index)

	var spr = sprite_index
	var ys = image_yscale
	var col = image_blend
	var gx = draw_x
	var gy = draw_y
	var ps = perspective_scale()
	with (Deck_obj) add_ghost(spr, gx, gy, ys, col, ps)
	instance_destroy()
}

// Filled in by Deck_obj's predict_battle: what the next battle phase will do to this figure
predicted_damage = 0
predicted_death = false

// Board limits: the top and bottom rows figures can move between,
// and the leftmost and rightmost lanes
top_row_y = 196
bottom_row_y = 452
left_lane_x = x
right_lane_x = x
with (Tile_obj)
{
	other.left_lane_x = min(other.left_lane_x, x)
	other.right_lane_x = max(other.right_lane_x, x)
}

// Perspective: figures look smaller the further up the ship they are, to match the
// thinner rows in the ship art. Only changes how they're drawn, not their collision or rules.
// Top row (196) draws at far_scale, bottom row (452) at full size.
far_scale = 0.75
perspective_scale = function()
{
	var t = clamp((draw_y - top_row_y) / (bottom_row_y - top_row_y), 0, 1)
	return lerp(far_scale, 1, t)
}

// Row boosts on the 5-row board, counted from this figure's own side:
// rows 0-1 (your side) give +1 HP, row 2 (middle) gives nothing, rows 3-4 (enemy side) give +1 attack.
// It's relative, so the AI's side is flipped.
rows_from_home = function(py)
{
	if (team == 1) return (bottom_row_y - py) div 64
	return (py - top_row_y) div 64
}
hp_bonus = function() { return (rows_from_home(y) <= 1) ? 1 : 0 }
atk_bonus = function() { return (rows_from_home(y) >= 3) ? 1 : 0 }

// Stats with the row boost included. Use these for fighting, not attack and hp directly.
total_attack = function() { return attack + atk_bonus() }
total_hp = function() { return hp + hp_bonus() }

// Where this figure moves next: straight ahead, or diagonally for jumpers.
// Jumpers turn around when the next lane would be off the board.
next_x = function()
{
	if (!jumps) return x
	var nx = x + 64 * dir_x
	if (nx < left_lane_x || nx > right_lane_x)
	{
		dir_x *= -1
		nx = x + 64 * dir_x
	}
	return nx
}

// Moves one space toward the other side. If an enemy figure is in the way,
// attacks it instead. If one of its own figures is in the way, waits.
// With only_move = true (extra moves from items) it never attacks, it just stops.
// Returns true if the figure moved.
// force = true lets figures that don't normally walk (Artillery) step forward anyway.
advance = function(only_move = false, force = false)
{
	if (!moves && !force) return false

	var next_y = y - 64 * team   // player (team 1) goes up, AI (team -1) goes down
	var nx = next_x()
	var ahead = instance_position(nx, next_y, FigureParent_obj)

	// Runner: blocked on the row right before the enemy's back row, it finishes the lane anyway
	var far_row = (team == 1) ? top_row_y : bottom_row_y
	if (ahead != noone && finishes_lane && next_y == far_row)
	{
		finish_lane()
		return false
	}

	if (ahead == noone)
	{
		if (next_y >= top_row_y && next_y <= bottom_row_y)
		{
			x = nx
			y = next_y

			// Leaving your home rows takes away the +1 HP boost, which can kill a hurt figure
			if (total_hp() <= 0 && !saved_by_myrrh())
			{
				var fx = x
				var fy = y
				with (Deck_obj) add_popup(fx, fy - 20, "Lost boost", c_red)
				die()
			}
			return true
		}
	}
	else if (ahead.team != team && !only_move && attack > 0)   // 0-attack figures (Slave) never attack
	{
		if (cleaves)
		{
			// Swordsman: hits the figure in front AND the one behind it.
			// Enemies take full attack, your own figures take half.
			var dmg = total_attack()
			var behind = instance_position(nx, next_y - 64 * team, FigureParent_obj)
			ahead.take_damage(dmg)
			if (behind != noone && instance_exists(behind))
			{
				if (behind.team != team) behind.take_damage(dmg)
				else if (dmg div 2 > 0) behind.take_damage(dmg div 2)
			}
		}
		else
		{
			ahead.take_damage(total_attack())
		}
		shake = 4   // little lunge so you can see who attacked
	}
	return false
}

// Runner: turns the enemy's light at the end of this lane green, like reaching the end
finish_lane = function()
{
	var lx = x
	var my_team = team
	var fx = x
	var fy = y
	with (Deck_obj) add_popup(fx, fy - 20, "Lane finished!", c_lime)
	with (LaneEndLight_obj)
	{
		if (lane_x == lx && watch_team == my_team && !lit) light_up()
	}
}

// Artillery shot: hits every enemy figure in this lane (same column) for blast_damage.
// Your own figures are never hit.
blast_damage = 1
blast_lane = function()
{
	var lane_x = x
	var damage = blast_damage
	var my_team = team
	var hit = []
	with (FigureParent_obj)
	{
		if (x == lane_x && team != my_team) array_push(hit, id)
	}
	for (var i = 0; i < array_length(hit); i++)
	{
		hit[i].take_damage(damage)
	}
}

// What this figure does in the battle phase: move/attack, or count down and fire
take_action = function()
{
	// Dazzled by the Zebra: skips this action
	if (stunned > 0)
	{
		stunned -= 1
		var sx = x
		var sy = y
		with (Deck_obj) add_popup(sx, sy - 20, "Dazzled", c_white)
		return
	}

	if (moves)
	{
		// Extra spaces from the Horse (every turn) or the Cotton Cloth (this battle only).
		// Extra spaces only happen if the first step was a move, and they never attack.
		var extra = (gallop ? 1 : 0) + sail_moves + speed_moves
		sail_moves = 0
		if (advance())
		{
			repeat (extra)
			{
				if (!instance_exists(id) || !advance(true)) break
			}
		}
		if (!instance_exists(id)) return
	}

	if (fire_every > 0)
	{
		turns_waited += 1
		if (turns_waited >= fire_every)
		{
			var fx = x
			var fy = y
			with (Deck_obj) add_popup(fx, fy - 20, "FIRE!", c_orange)
			blast_lane()
			turns_waited = 0

			// Artillery moves up one row after it fires (only into an empty space, it never attacks)
			if (instance_exists(id) && !moves) advance(true, true)
		}
	}
}
