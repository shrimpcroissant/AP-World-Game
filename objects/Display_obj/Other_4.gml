// Room Start: set up a view the same shape as the screen.
// The whole room always stays visible. On a screen that's wider or taller than
// the room, the extra space shows around the edges instead of stretching anything.

// The start screen is drawn in its top-left 341 x 192 (the menu art's size), so show just that
var area_w = (room == Menu_Room) ? 341 : room_width
var area_h = (room == Menu_Room) ? 192 : room_height

var room_aspect = area_w / area_h
var view_w = area_w
var view_h = area_h

if (screen_aspect > room_aspect)
{
	view_w = round(area_h * screen_aspect)   // wider screen, show extra on the sides
}
else
{
	view_h = round(area_w / screen_aspect)    // taller screen, show extra on top and bottom
}

camera_set_view_size(camera, view_w, view_h)
camera_set_view_pos(camera, (area_w - view_w) / 2, (area_h - view_h) / 2)

view_enabled = true
view_visible[0] = true
view_camera[0] = camera
view_xport[0] = 0
view_yport[0] = 0
view_wport[0] = view_w
view_hport[0] = view_h

surface_resize(application_surface, view_w, view_h)
