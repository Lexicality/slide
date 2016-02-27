include("shared.lua");

print("RD_cl")

ENT.UpdateSpeed = 0.1;
ENT.MaxLength = 50;
ENT.BeamWidth = 20;

function ENT:Initialize()
	self.positions = {};
	self.lastSave = 0;
end

local color_red, color_green = Color(255, 0, 0), Color(0, 255, 0);
function ENT:GetNewRenderBounds()
	local epos = self:GetPos();
	local min = self:OBBMins() + epos;
	local max = self:OBBMaxs() + epos;
	local pos;
	for _, data in ipairs(self.positions) do
		pos = data.pos;
		if pos.x > max.x then
			max.x = pos.x;
		end
		if pos.y > max.y then
			max.y = pos.y;
		end
		if pos.z > max.z then
			max.z = pos.z;
		end
		if pos.x < min.x then
			min.x = pos.x;
		end
		if pos.y < min.y then
			min.y = pos.y;
		end
		if pos.z < min.z then
			min.z = pos.z;
		end
	end
	return min, max;
end

ENT.plyLastPos = vector_origin;
function ENT:Think()
	local ply = self:GetPlayer();
	local plypos = IsValid(ply) and ply:GetPos();
	if not self:GetIsTracking() then
		return;
	elseif plypos == self.plyLastPos then
		return;
	elseif CurTime() < self.lastSave + self.UpdateSpeed then
		return
	end
	self.plyLastPos = plypos;
	self.lastSave = CurTime();
	-- DebugInfo(1, "Ping! - " .. self.lastSave);

	local npos = #self.positions + 1;
	if npos > self.MaxLength then
		table.remove(self.positions, 1);
		npos = self.MaxLength;
	end


	-- DebugInfo(2, "Pong! - " .. tostring(self:GetPos()));
	-- DebugInfo(3, "Pling! - " .. tostring(plypos));

	-- debugoverlay.Cross( self:GetPos(), 100, 1, color_white, true)

	self.positions[npos] = {
		-- ctime = CurTime();
		-- rtime = RealTime();
		pos   = plypos;
		-- ang   = ply:GetAngles();
		-- vel   = ply:GetVelocity();
	};

	self:SetRenderBoundsWS(self:GetNewRenderBounds());
end

function ENT:Draw() end

function ENT:IsTranslucent()
	return true;
end

local beam = Material("trails/laser");
function ENT:DrawTranslucent()
	local npos = #self.positions;

	local deathduties = self:GetFinalRestingPlace();
	local plyPossible = self:GetIsTracking();
	local plypos;
	if plyPossible then
		local ply = self:GetPlayer();
		if IsValid(ply) then
			plypos = ply:GetPos();
		end
	elseif deathduties then
		plypos = deathduties;
		plyPossible = true;
	end


	render.SetMaterial(beam);
	render.StartBeam(npos + (plyPossible and 1 or 0));
	local pos, last, dist;
	dist = 0;
	for i = 1, npos do
		pos = self.positions[i].pos;
		if last then
			dist = dist + last:Distance(pos)
		end
		render.AddBeam(pos + vector_up * 4, self.BeamWidth, dist);
		last = pos;
	end
	if plyPossible then
		render.AddBeam(plypos + vector_up * 4, self.BeamWidth, dist);
	end
	render.EndBeam()
end
