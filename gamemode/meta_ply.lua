--[[
	Slide - gamemode/meta_ply.lua

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

--- @type GPlayer
local PLY = FindMetaTable("Player")

function PLY:GetTombstone()
	local ts = self.tombStone
	if IsValid(ts) then
		return ts
	end
	ts = ents.Create("slide_tombstone")
	ts:SetPlayer(self)
	ts:Spawn()
	self.tombStone = ts
	return ts
end

function PLY:GetRunData()
	return self.runData or NULL
end

function PLY:CreateRunData()
	local team = self:Team()
	if team == TEAM_SPECTATOR or team == TEAM_UNASSIGNED then
		-- No rundata for ghosts
		return
	end
	local rd = ents.Create("slide_rundata")
	rd:SetupOwner(self)
	rd:Spawn()
	self.runData = rd
	return rd
end
