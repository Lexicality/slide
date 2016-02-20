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
