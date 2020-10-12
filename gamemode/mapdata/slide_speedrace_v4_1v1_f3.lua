GM.MapData["slide_speedrace_v4_1v1_f3"] =
	{
		ToRemove = {
			-- Small wall across spawns
			"gumpprotect",
			-- Kill zone immediately after the wall
			"gumkiller",
			-- Invisible wall afterwards
			"gumblocker",
			-- Second invisible wall after the first one
			"noobweg",
			-- trigger_kill in spawn, only activates once one player has finished
			"afk_killer",
			"afk_killer2",
		},
		FirstPush = {1700},
		LastBrush = {1750},
		LastType = "heal",
		RestartTriggers = {},
	}
