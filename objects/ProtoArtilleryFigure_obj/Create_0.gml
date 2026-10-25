// Runs FigureParent_obj's Create first. Keep this line at the top.
event_inherited()

// This figure's own variables go below

attack = 1
hp = 5

// Doesn't walk like other figures. Every 5 turns it fires down its whole lane,
// doing 1 damage to every other figure there (friendly ones too, except other artillery),
// then moves up one row. See blast_lane in FigureParent_obj.
moves = false
fire_every = 5
blast_damage = 1
