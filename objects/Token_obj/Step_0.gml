if place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1)
{
	if global.turn == noone
	{
		global.turn = 1;
	}
	
	global.turn *= -1;
	
	// Move every figure forward one space, front figures first,
	// so the space ahead is already cleared for the ones behind
	var figs = [];
	with (Figure_obj) array_push(figs, id);
	array_sort(figs, function(a, b) { return a.y - b.y; });
	
	for (var i = 0; i < array_length(figs); i++)
	{
		with (figs[i])
		{
			if (y > 206 && !instance_position(x, y - 64, Figure_obj))
			{
				y -= 64;
			}
		}
	}
}
