AddCSLuaFile("shared.lua");
AddCSLuaFile("cl_init.lua");
include("shared.lua");

print("RD Init")

function ENT:Initialize()
	print("New RunData!");
	self:SetModel("models/gibs/hgibs.mdl");
	self:SetMoveType(MOVETYPE_NONE);
	self:SetSolid(SOLID_NONE);

	self.positions = {};
end

function ENT:SetupOwner(ply)
	print("Got a player!", ply)
	self:SetPos(ply:GetPos());
	self:SetParent(ply);
	ply:DeleteOnRemove(self);
	self:SetPlayer(ply);
	self:SetIsTracking(true);
	print(self.dt.IsTracking);
end

function ENT:HandlePlayerDeath()
	print("ply ded :(");
	self:SetIsTracking(false);
	self:SetParent(NULL);
end

function ENT:GetData()
	return self.positions;
end

function ENT:Think()
	if not self:GetIsTracking() then
		return;
	end

	local ply = self:GetPlayer();
	self.positions[#self.positions + 1] = {
		ctime = CurTime();
		rtime = RealTime();
		pos   = ply:GetPos();
		ang   = ply:GetAngles();
		vel   = ply:GetVelocity();
	};
end
