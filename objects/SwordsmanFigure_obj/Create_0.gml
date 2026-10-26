// Runs FigureParent_obj's Create first. Keep this line at the top.
event_inherited()

// This figure's own variables go below

attack = 2
hp = 1

// Moves like the Sailor. When an enemy is right in front of it, it strikes BOTH spaces
// in front: enemies take its full attack, your own figures take half. See advance in FigureParent_obj.
cleaves = true
