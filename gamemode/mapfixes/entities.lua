--[[
	Slide - gamemode/mapfixes/entities.lua

    Copyright 2017-2020 Lex Robinson

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]] --
DEFINE_BASECLASS "gamemode_base"

function GM:EntityKeyValue(ent, key, value)
	BaseClass.EntityKeyValue(self, ent, key, value)
	-- Sometimes we need to replace entities, so store everything we can about them.
	ent.kvs = ent.kvs or {} -- TODO: Drop this on EntityCreated?
	table.insert(ent.kvs, {key, value})
end

function GM:MakeExplosionsRepeatable()
	for _, ent in pairs(ents.FindByClass("env_explosion")) do
		local spawnflags = tonumber(ent:GetKeyValues().spawnflags) or 0
		spawnflags = bit.bor(spawnflags, 2)
		ent:SetKeyValue("spawnflags", spawnflags)
	end
end

GM.BadMapEnts = {
	slide_bounce_f1 = {
		-- Big wall across spawn
		"gumpprotect",
		-- Invisible wall afterwards
		"gumblocker",
		-- Second invisible wall after the first one
		"noobweg",
		-- trigger_kill in spawn, only activates once one player has finished
		"afkkiller",
	},
	slide_shoxx_vs_nitro_f2 = {
		-- Big wall across spawn
		"gumpprotect",
		-- Invisible wall afterwards
		"gumblocker",
		-- Second invisible wall after the first one
		"noobweg",
		-- trigger_kill in spawn, only activates once one player has finished
		"afkkiller",
	},
	slide_speedrace_v4_1v1_f3 = {
		-- Small wall across spawns
		"gumpprotect",
		-- Kill zone immediately after the wall
		"gumkiller",
		-- Invisible wall afterwards
		"gumblocker",
		-- Second invisible wall after the first one
		"noobweg",
		-- trigger_kill in spawn, only activates once one player has finished
		"afk_killer",
		"afk_killer2",
	},
}

function GM:RemoveMapBlockers()
	local badEnts = self.BadMapEnts[game.GetMap()]
	if not badEnts then
		return
	end

	for _, name in ipairs(badEnts) do
		for _, ent in ipairs(ents.FindByName(name)) do
			ent:Remove()
		end
	end
end

local function findMoveLinearBeneath(entity)
	local tr = util.TraceLine(
		{
			start = entity:GetPos(),
			endpos = entity:GetPos() - Vector(0, 0, 512),
			filter = function(ent)
				if (ent:GetClass() == "func_movelinear") then
					return true
				end
			end,
		}
	)

	return tr.Entity
end

function GM:TryParentSpawnpoints()
	for _, ent in pairs(ents.FindByClass("info_player_*")) do
		local moveLinear = findMoveLinearBeneath(ent)

		if (not IsValid(moveLinear)) then
			-- Don't waste time checking every spawnpoint, if the first one doesn't have a move linear beneath it, none do.
			return
		end

		ent:SetParent(moveLinear)
	end
end

function GM:CreateMapController()
	local ent = ents.FindByName("slide_map_controller")
	if IsValid(ent) then
		self.mapController = ent;
		return
	end
	ent = ents.Create("slide_controller")
	ent:SetName("slide_map_controller")
	ent:Spawn()
	ent:Activate()
	self.mapController = ent;
end
