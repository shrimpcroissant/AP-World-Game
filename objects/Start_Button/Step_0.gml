// On the start screen: center this button and the Exit button on the menu art (341 wide),
// and handle the Easy / Normal / Hard buttons under it (drawn in the Draw event)
// Also the How to Play button and its overlay (see menu_help_button in Items_scr)
if (room == Menu_Room)
{
	x = 170 - sprite_width / 2
	with (Exit_Button) { x = 170 - sprite_width / 2; y = 170 }   // below the How to Play button
	depth = -50   // draws the overlay above the other menu buttons
	if (!variable_global_exists("MenuHelpOpen")) global.MenuHelpOpen = false

	// Overlay open: the rulebook link opens the website rulebook in a new tab; any other click closes it
	if (global.MenuHelpOpen)
	{
		image_blend = c_white
		if (mouse_check_button_pressed(mb_left))
		{
			var lk = menu_help_layout().link
			if (point_in_rectangle(mouse_x, mouse_y, lk.x1, lk.y1, lk.x2, lk.y2)) url_open_ext(rulebook_url(), "_blank")
			else
			{
				global.MenuHelpOpen = false
				block_input_briefly()   // so this click doesn't also start the game or pick a difficulty
			}
		}
		exit
	}

	if (!input_blocked() && mouse_check_button_pressed(mb_left))
	{
		var hb = menu_help_button()
		if (point_in_rectangle(mouse_x, mouse_y, hb.x1, hb.y1, hb.x2, hb.y2))
		{
			global.MenuHelpOpen = true
			exit
		}
		for (var i = 0; i < 3; i++)
		{
			var b = difficulty_button(i)
			if (point_in_rectangle(mouse_x, mouse_y, b.x1, b.y1, b.x2, b.y2)) global.Difficulty = i
		}
	}
}

// Lights up while the mouse is over it
var over = place_meeting(x, y, Mouse_obj)
image_blend = over ? make_color_rgb(255, 225, 140) : c_white

if (over && mouse_check_button_pressed(1) && !input_blocked())
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
		global.StorySeen = {}          // and the story screens
	}
	room_goto(Prototype_Room)
}
