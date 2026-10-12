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

