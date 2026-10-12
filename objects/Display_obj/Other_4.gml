// Room Start: set up a view the same shape as the screen.
// The whole room always stays visible. On a screen that's wider or taller than
// the room, the extra space shows around the edges instead of stretching anything.

var room_aspect = room_width / room_height
var view_w = room_width
var view_h = room_height

if (screen_aspect > room_aspect)
{
	view_w = round(room_height * screen_aspect)   // wider screen, show extra on the sides
}
else
{
	view_h = round(room_width / screen_aspect)    // taller screen, show extra on top and bottom
}

camera_set_view_size(camera, view_w, view_h)
camera_set_view_pos(camera, (room_width - view_w) / 2, (room_height - view_h) / 2)

view_enabled = true
view_visible[0] = true
view_camera[0] = camera
view_xport[0] = 0
view_yport[0] = 0
view_wport[0] = view_w
view_hport[0] = view_h

surface_resize(application_surface, view_w, view_h)
