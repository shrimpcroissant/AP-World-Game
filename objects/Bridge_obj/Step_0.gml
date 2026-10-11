if place_meeting(x, y, Figure_obj)
{
	if spawned = 0
	{
		SpawnedID = instance_create_layer(x, y + 64, "SpawnChecker", TileFillerShower_obj)
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

if y = 452
{
	if place_meeting(x, y, Mouse_obj) and mouse_check_button(1)
	{
		instance_create_layer(x, y, "SpawnChecker", Figure_obj)
	}
}