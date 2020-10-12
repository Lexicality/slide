--- @param targetlist table
function ents.FindByMagicTarget(targetlist)
	local found_ents = {}
	for _, target in ipairs(targetlist) do
		if type(target) == "number" then
			table.insert(found_ents, ents.GetMapCreatedEntity(target))
		else
			table.Add(found_ents, ents.FindByName(target))
		end
	end
	return found_ents
end
