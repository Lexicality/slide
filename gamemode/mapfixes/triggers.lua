--[[
	Slide - gamemode/mapfixes/triggers.lua

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

local function replaceTrigger(ent)
	if not ent.kvs then
		ErrorNoHalt(string.format("Entity %s doesn't have its .kvs?", ent))
		return
	end

	-- Take the ent out of the game but don't remove it (Just in case [?])
	ent:Fire("Disable")

	local replacement = ents.Create("trigger_multiple")
	for _, kv in ipairs(ent.kvs) do
		if kv[1] ~= "classname" then
			replacement:SetKeyValue(kv[1], kv[2])
		end
	end
	replacement:SetKeyValue("wait", 0)
	replacement:Spawn()
	replacement:Activate()
end

function GM:ReplaceTriggerOnces()
	for _, ent in pairs(ents.FindByClass("trigger_once")) do
		replaceTrigger(ent)
	end
end

function GM:ModifyHealTriggers()
	for _, trigger in ipairs(ents.FindByClass("trigger_hurt")) do
		local damage = trigger:GetInternalVariable("damage")

		if (damage < 0) then
			-- Prevent anything weird happening in the future
			trigger:SetKeyValue("damage", 0)
			-- The damage keyvalue is per second, but `trigger_hurt` fires twice
			-- a second so we need to divide it by 2
			damage = math.abs(damage) / 2
			trigger:Fire(
				"AddOutput",
				"OnHurtPlayer slide_map_controller:HealPlayer:" .. damage .. ":0:-1"
			)
		end
	end
end

function GM:AttachMapTriggers()
	local mapdata = self.MapData[game.GetMap()]

	if not mapdata then
		return
	end

	for _, ent in ipairs(ents.FindByMagicTarget(mapdata.FirstPush)) do
		ent:AddOutput("OnStartTouch", "slide_map_controller", "StartRun")
	end

	for _, ent in ipairs(ents.FindByMagicTarget(mapdata.LastBrush)) do
		if mapdata.LastType == "push" then
			ent:AddOutput("OnEndTouch", "slide_map_controller", "CompleteRun")
		else
			ent:AddOutput("OnStartTouch", "slide_map_controller", "CompleteRun")
		end
	end

	for _, ent in ipairs(ents.FindByMagicTarget(mapdata.RestartTriggers)) do
		ent:AddOutput("OnStartTouch", "slide_map_controller", "RestartRun")
	end
end

function GM:SetupTriggerDebugs()
	for _, ent in ipairs(ents.FindByClass("trigger_push")) do
		ent:AddOutput("OnStartTouch", "slide_map_controller", "DebugStartPush")
	end
	for _, ent in ipairs(ents.FindByClass("trigger_multiple")) do
		ent:AddOutput("OnTrigger", "slide_map_controller", "DebugTrigger")
	end
	for _, ent in ipairs(ents.FindByClass("trigger_teleport")) do
		ent:AddOutput("OnStartTouch", "slide_map_controller", "DebugTele")
	end
end
