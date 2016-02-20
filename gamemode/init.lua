
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")


function GM:InitPostEntity()
	game.ConsoleCommand("sv_accelerate 100\n");
	game.ConsoleCommand("sv_airaccelerate 100\n");
end

function GM:PlayerSpawn(ply)
	player_manager.SetPlayerClass(ply, "class_default")
	self.BaseClass.PlayerSpawn(self, ply)

	-- ply:SetTeam(TEAM_RED);
	ply:SetTeam(TEAM_BLUE);
	print("Hi!", ply)
end
