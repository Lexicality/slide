
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

include("meta_ply.lua");


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

function GM:DoPlayerDeath(ply, ...)
	self.BaseClass.DoPlayerDeath(self, ply, ...);

	ply:GetTombstone():HandlePlayerDeath();
end

function GM:Think()
	self.BaseClass.Think(self)

	for _, ply in pairs(player.GetAll()) do
		ply:SetDTVector(0, ply:GetVelocity());
		ply:SetDTVector(1, ply:GetAbsVelocity());
	end
end
