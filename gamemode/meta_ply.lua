local PLY = FindMetaTable("Player");

function PLY:GetTombstone()
	local ts = self.tombStone;
	if IsValid(ts) then
		return ts;
	end
	ts = ents.Create("slide_tombstone");
	ts:SetPlayer(self);
	ts:Spawn();
	self.tombStone = ts;
	return ts;
end

function PLY:GetRunData()
	return self.runData or NULL;
end

function PLY:CreateRunData()
	local rd = ents.Create("slide_rundata");
	rd:SetupOwner(self);
	rd:Spawn();
	self.runData = rd;
	return rd;
end
