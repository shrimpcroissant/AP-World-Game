// Draws the ship under the (invisible) tiles. It's only a picture:
// all the game logic uses Tile_obj / Bridge_obj positions, never these colors.
//
// The ship's 4x5 grid of cells sits inside the 128x128 sprite at about
// x 43-81, y 64-100, so the sprite is scaled and moved until those cells
// line up with the tiles (lanes x 576-768, rows y 196-452, 64px apart).
// The cells in the picture aren't all the same height, so a few rows sit a few pixels off.
// If you redraw the ship, change these numbers to match.
var sx = 6.4    // 10 sprite pixels per lane -> 64 room pixels
var sy = 8.64   // about 7.4 sprite pixels per row -> 64 room pixels
var ox = 576 - 47 * sx     // sprite pixel x 47 = middle of the left lane
var oy = 324 - 80.9 * sy   // sprite pixel y 80.9 = middle of the bridge row

draw_sprite_ext(Ship_APWORLD_spr, 0, ox, oy, sx, sy, 0, c_white, 1)
