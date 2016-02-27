
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
	local rd = ply:CreateRunData();
	print("Player Spawned", ply, rd, "!")
end

function GM:DoPlayerDeath(ply, ...)
	self.BaseClass.DoPlayerDeath(self, ply, ...);

	local ts = ply:GetTombstone();
	if IsValid(ts) then
		ts:HandlePlayerDeath()
	end

	-- local rd = ply:GetRunData();
	-- if IsValid(rd) then
	-- 	rd:HandlePlayerDeath()
	-- 	-- TEMP
	-- 	rd:Remove();
	-- end
end

function GM:Think()
	self.BaseClass.Think(self)

	for _, ply in pairs(player.GetAll()) do
		ply:SetDTVector(0, ply:GetVelocity());
		ply:SetDTVector(1, ply:GetAbsVelocity());
	end
end
