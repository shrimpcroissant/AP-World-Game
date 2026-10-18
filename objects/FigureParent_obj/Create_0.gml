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
// hitting every other figure in the lane for its attack, friendly ones too.
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

// Takes damage, shows the hit, and removes the figure if it runs out of HP
// The +1 HP row boost works like a shield: it soaks up the first point of damage.
// Once used it's gone, and leaving your rows never kills a figure.
take_damage = function(amount)
{
	var dmg_to_hp = amount
	if (hp_bonus() > 0)
	{
		shield_used = true
		dmg_to_hp -= 1
	}
	hp -= dmg_to_hp
	flash = 10
	shake = 6
	var fx = x
	var fy = y
	with (Deck_obj) add_popup(fx, fy - 20, "-" + string(amount), c_red)

	if (hp <= 0) die()
}

// Removes the figure with a fade-out
die = function()
{
	var spr = sprite_index
	var ys = image_yscale
	var col = image_blend
	var gx = draw_x
	var gy = draw_y
	with (Deck_obj) add_ghost(spr, gx, gy, ys, col)
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

// Row boosts on the 5-row board, counted from this figure's own side:
// rows 0-1 (your side) give +1 HP (a one-time shield), row 2 (middle) gives nothing, rows 3-4 (enemy side) give +1 attack.
// It's relative, so the AI's side is flipped.
rows_from_home = function(py)
{
	if (team == 1) return (bottom_row_y - py) div 64
	return (py - top_row_y) div 64
}
shield_used = false
hp_bonus = function() { return (rows_from_home(y) <= 1 && !shield_used) ? 1 : 0 }
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
advance = function()
{
	if (!moves) return

	var next_y = y - 64 * team   // player (team 1) goes up, AI (team -1) goes down
	var nx = next_x()
	var ahead = instance_position(nx, next_y, FigureParent_obj)

	if (ahead == noone)
	{
		if (next_y >= top_row_y && next_y <= bottom_row_y)
		{
			x = nx
			y = next_y
		}
	}
	else if (ahead.team != team)
	{
		ahead.take_damage(total_attack())
		shake = 4   // little lunge so you can see who attacked
	}
}

// Hits every other figure in this lane (same column) for this figure's attack,
// friend or enemy
blast_lane = function()
{
	var lane_x = x
	var damage = total_attack()
	var me = id
	var hit = []
	with (FigureParent_obj)
	{
		if (x == lane_x && id != me) array_push(hit, id)
	}
	for (var i = 0; i < array_length(hit); i++)
	{
		hit[i].take_damage(damage)
	}
}

// What this figure does in the battle phase: move/attack, or count down and fire
take_action = function()
{
	if (moves) advance()

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
		}
	}
}
