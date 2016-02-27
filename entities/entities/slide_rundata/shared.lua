ENT.Base        = "base_anim";
ENT.Type        = "anim";
ENT.Spawnable   = false;
ENT.PrintName   = "Tombstone";
ENT.Purpose     = "Celebrating and marking a player's clumsy death";
ENT.Author      = "Lexi"
ENT.RenderGroup = RENDERGROUP_BOTH

print("RD Shard");

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player");
	self:NetworkVar("Bool", 0, "IsTracking");
	self:NetworkVar("Vector", 0, "FinalRestingPlace");
end
