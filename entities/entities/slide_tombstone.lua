AddCSLuaFile();

ENT.Base        = "base_anim";
ENT.Type        = "anim";
ENT.Spawnable   = false;
ENT.PrintName   = "Tombstone";
ENT.Purpose     = "Celebrating and marking a player's clumsy death";
ENT.Author      = "Lexi"
ENT.RenderGroup = RENDERGROUP_BOTH

DEFINE_BASECLASS "base_entity";

print "Holla holla tombstone!";

function ENT:Initialize()
	self:SetModel("models/gibs/hgibs.mdl");
	self:SetMoveType(MOVETYPE_NONE);
	self:SetSolid(SOLID_NONE);
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player");
	self:NetworkVar("Bool", 0, "GrizzlyWarning")
end

function ENT:SetPlayer(ply)
	self.dt.Player = ply;
end

function ENT:GetPlayer()
	return self.dt.Player;
end

function ENT:HandlePlayerDeath()
	local ply = self:GetPlayer();
	if not IsValid(ply) then
		error("Player is invalid!", 2);
	end
	local pos = ply:GetPos();
	local obb = self:OBBMaxs();
	pos.z = pos.z + obb.z;
	self:SetPos(pos);
	local ang = ply:GetAngles();
	self:SetAngles(Angle(0, -ang.yaw, 0));
end

-- function ENT:UpdateTransmitState()
-- 	return TRANSMIT_ALWAYS;
-- end

function ENT:ShouldDraw()
	if self.dt.GrizzlyWarning then

		return true;
	end
	return self:GetPlayer() == LocalPlayer();
end

local debugNo = Color(255, 0, 0);
local debugYes = Color(0, 255, 0);

function ENT:IsTranslucent()
	return true;
end

function ENT:Draw()
	if not self:ShouldDraw() then
		-- debugoverlay.Cross(self:GetPos(), 10, 0.1, debugNo, true)
		return;
	end

	debugoverlay.Cross(self:GetPos(), 1, 0.1, debugYes, true)

	self:DrawModel();
end

local behindGlow = Material("sprites/orangecore1");
-- local beam = Material("sprites/laserbeam");
local beam = Material("sprites/physgbeamb");
local color_orange = Color(255, 0, 200);
function ENT:DrawTranslucent()
	if not self:ShouldDraw() then
		return;
	end

	local i = 0;
	function aa(wut)
		DebugInfo(i, tostring(wut))
		i = i + 1
	end

	-- self.BaseClass.DrawTranslucent(self, true)

	local here = self:GetPos();
	local tr = util.QuickTrace(here, vector_up * 20000, self);

	local obbs = self:OBBMaxs();
	local size = obbs:Length() * 10;

	local top = tr.HitPos
	local dist = top - here;
	local dist1 = dist / 10;

	local n = ((CurTime() * 5) % 100) / 100
	-- local

	local beamsize = size - 20;

	render.SetMaterial(beam);
	-- render.OverrideColorWriteEnable(true, true)
	-- render.SetColorModulation(1, 0, 1);
	render.SetBlend(0.2)
	render.StartBeam(11);
	render.AddBeam(here, beamsize, n);
	for i = 1, 10 do
		render.AddBeam(here + dist1 * i, beamsize - i * 3, n - i / 4);
	end
	-- render.AddBeam(here + (top - here) / 2, 50, 1)
	-- render.AddBeam(top, 10, 0);
	render.EndBeam()
	render.SetBlend(1)
	-- render.SetColorModulation(1, 1, 1);


	render.SetMaterial(behindGlow)
	render.DrawSprite(self:GetPos(), size, size);

	-- TODO: Sparkles n shit
end
