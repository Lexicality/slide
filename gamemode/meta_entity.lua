--- @type GEntity
local ENT = FindMetaTable("Entity")

--- @param output string
--- @param target string
--- @param input string
--- @param argument string|nil
--- @param delay integer|nil
--- @param repititions integer|nil
function ENT:AddOutput(output, target, input, argument, delay, repititions)
	if argument == nil then
		argument = ""
	end
	if delay == nil then
		delay = 0
	end
	if repititions == nil then
		repititions = -1
	end

	self:Fire(
		"AddOutput",
		output .. " " .. target .. ":" .. input .. ":" .. argument .. ":" .. delay ..
			":" .. repititions
	)
end
