if (variable_global_exists("paused") && global.paused) exit

switch (state)
{
	case "idle":
		image_index = 0
		depth = home_depth
		x = home_x
		y = home_y
		image_angle = 0
		if (global.PlayerTurn && global.Winner == 0 && mouse_check_button_pressed(mb_left) && mouse_on_dagger())
		{
			state = "aiming"
			global.DaggerAiming = true
			global.SelectedCard = noone
		}
		break

	case "aiming":
		// Follows the mouse
		image_index = 1
		depth = -1000
		x = lerp(x, mouse_x, 0.5)
		y = lerp(y, mouse_y, 0.5)

		if (!global.PlayerTurn || mouse_check_button_pressed(mb_right))
		{
			state = "cancel"
		}
		else if (mouse_check_button_pressed(mb_left))
		{
			var fig = instance_position(mouse_x, mouse_y, FigureParent_obj)
			// Only your own figures, and only on your 2 rows (bottom two)
			if (fig != noone && fig.team == 1 && fig.rows_from_home(fig.y) <= 1)
			{
				target = fig
				state = "flying"
			}
			else if (fig != noone && fig.team == 1)
			{
				with (Deck_obj) show_reminder("Only on your first two rows")
			}
			else if (fig != noone)
			{
				with (Deck_obj) show_reminder("Only your own figures")
			}
			else
			{
				state = "cancel"   // clicked empty space or the dagger's spot
			}
		}
		break

	case "cancel":
		// Wait one frame before letting clicks through again, so the cancelling
		// click doesn't also draw a card or pick one
		global.DaggerAiming = false
		state = "returning"
		break

	case "flying":
		if (!instance_exists(target))
		{
			state = "cancel"
			break
		}
		x = lerp(x, target.x, 0.35)
		y = lerp(y, target.y, 0.35)
		image_angle = point_direction(x, y, target.x, target.y) - 90
		if (point_distance(x, y, target.x, target.y) < 6)
		{
			var tx = target.x
			var ty = target.y
			with (Deck_obj) add_popup(tx, ty - 20, "DESTROYED", c_red)
			with (target) die()
			target = noone
			state = "cancel"
		}
		break

	case "returning":
		image_index = 0
		x = lerp(x, home_x, 0.25)
		y = lerp(y, home_y, 0.25)
		image_angle = lerp(image_angle, 0, 0.25)
		if (point_distance(x, y, home_x, home_y) < 1) state = "idle"
		break
}
