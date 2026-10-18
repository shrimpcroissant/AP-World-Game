// Clicking the token ends your turn. The AI plays its cards, then both sides battle.
var paused = variable_global_exists("paused") && global.paused
if (paused || !global.PlayerTurn || global.Winner != 0 || global.DaggerAiming) exit

// Click the token or press Space
var clicked = place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1)
if (clicked or keyboard_check_pressed(vk_space))
{
	if global.turn == noone
	{
		global.turn = 1;
	}
	
	global.turn *= -1;
	
	// End the turn: any chosen card goes back in the hand
	global.SelectedCard = noone;
	global.PlayerTurn = false;
	
	// Now it's the AI's turn. After it plays, both sides battle.
	with (EnemyAI_obj) start_turn();
}
