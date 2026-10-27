x = mouse_x
y = mouse_y
depth = -2000   // the cursor draws on top of everything, including the pause menu

// Ted's custom cursor art (Cursor_spr) if it exists
sprite_index = custom_cursor_sprite()

// In fights the pop-ups are drawn in Draw GUI, above the room, so Deck_obj draws the
// cursor there instead (see draw_cursor_gui in Items_scr). Still collides while hidden.
visible = !instance_exists(Deck_obj)
