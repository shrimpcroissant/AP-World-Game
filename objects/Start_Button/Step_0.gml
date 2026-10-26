if place_meeting(x, y, Mouse_obj) and mouse_check_button_pressed(1)
{
	// On the main menu this starts a new game at the first stop (China, the tutorial fight),
	// with no coins and no items.
	// Anywhere else (like the map) it just goes to the next fight.
	if (room == Menu_Room)
	{
		global.FightsWon = 0
		global.Money = 0
		global.Items = []
		global.LastLostCard = -1
		global.PepperTurns = 0
		global.TutorialShown = false   // show "How to play" again at the start of a new game
	}
	room_goto(Prototype_Room)
}
