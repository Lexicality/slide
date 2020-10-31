GM.MapData["slide_bounce_f1"] = {
	ToRemove = {
		-- Big wall across spawn
		"gumpprotect",
		-- Invisible wall afterwards
		"gumblocker",
		-- Second invisible wall after the first one
		"noobweg",
		-- trigger_kill in spawn, only activates once one player has finished
		"afkkiller",
	},
	FirstPush = {1326},
	LastBrush = {2258},
	LastType = "heal",
	SpawnTeleTriggers = {},
}
