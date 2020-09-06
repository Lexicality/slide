--[[
	Slide - gamemode/mapfixes/entities.lua

    Copyright 2017 Lex Robinson

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
]]--
DEFINE_BASECLASS "gamemode_base"

function GM:EntityKeyValue(ent, key, value)
    BaseClass.EntityKeyValue(self, ent, key, value)
	-- Sometimes we need to replace entities, so store everything we can about them.
	ent.kvs = ent.kvs or {} -- TODO: Drop this on EntityCreated?
	table.insert(ent.kvs, { key, value })
end

function GM:MakeExplosionsRepeatable()
	for _, ent in pairs(ents.FindByClass("env_explosion")) do
		local spawnflags = tonumber(ent:GetKeyValues().spawnflags) or 0
		spawnflags = bit.bor(spawnflags, 2)
		ent:SetKeyValue("spawnflags", spawnflags)
	end
end
