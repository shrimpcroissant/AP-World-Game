if place_meeting(x, y, FigureParent_obj)
{
	if spawned = 0
	{
		// Show it behind the figure: below player figures, above enemy figures
		var fig = instance_place(x, y, FigureParent_obj)
		SpawnedID = instance_create_layer(x, y + 64 * fig.team, "SpawnChecker", TileFillerShower_obj)
		spawned = 1
	}	
} else {
	if instance_exists(SpawnedID)
	{
		instance_destroy(SpawnedID)
		spawned = 0
		SpawnedID = noone
	}
}

// Clicking a tile in the front row plays the chosen card's figure here.
// With no card chosen, nothing happens.
var paused = input_blocked()
if y = 452 and !paused and !global.DaggerAiming
{
	if place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1) and filled = false
	{
		var card = global.SelectedCard
		if (instance_exists(card) && card.figure != noone && card.cost <= global.Units)
		{
			global.Units -= card.cost
			dbg("Player placed " + object_get_name(card.figure) + " in lane x=" + string(x) + " (units left " + string(global.Units) + ")")
			instance_create_layer(x, y, "SpawnChecker", card.figure)
			instance_destroy(card)
			global.SelectedCard = noone
		}
	}
}

if place_meeting(x, y, FigureParent_obj)
{
	filled = true
} else {
	filled = false
}
