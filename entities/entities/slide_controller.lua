--[[
	Slide - entities/slide_controller.lua

    Copyright 2020 Lex Robinson

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
DEFINE_BASECLASS "base_point"

ENT.Type = "point"
ENT.Spawnable = false
ENT.PrintName = "Slide Controller"
ENT.Purpose = "Manages things that happen in a slide game"
ENT.Author = "Lexi"

-- This should not ever end up on the client but just in case
if CLIENT then
	return
end

local ENT_OUTPUT_HOOKS = {
	"PlayerSpawn",
	"PlayerStartRun",
	"PlayerAbortRun",
	"PlayerLoopRun",
	"PlayerCompleteRun",
	"PlayerTeleSpawn",
}
function ENT:Initialize()
	BaseClass.Initialize(self)

	for _, hookName in ipairs(ENT_OUTPUT_HOOKS) do
		hook.Add(
			hookName, self, function(self, ply, param)
				self:TriggerOutput("On" .. hookName, ply, param)
			end
		)
	end
	hook.Add("PlayerFailRun", self, self.OnPlayerFailRun)

end

--- @param ply GPlayer
--- @param inflictor GEntity
--- @param attacker GEntity
function ENT:OnPlayerFailRun(ply, inflictor, attacker)
	local cause = attacker
	if cause == ply then
		cause = inflictor
	end
	local param = nil
	if IsValid(cause) then
		if cause:IsPlayer() then
			param = cause:SteamID()
		else
			param = cause:GetName()
		end
	end
	if param == "" then
		param = nil
	end
	self:TriggerOutput("OnPlayerFailRun", ply, nil)
end

--- @param key string
--- @param value string
function ENT:KeyValue(key, value)
	if BaseClass.KeyValue then
		BaseClass.KeyValue(self, key, value)
	end

	if self:AddOutputFromKeyValue(key, value) then
		return
	end
end

--- @param name string
--- @param activator GEntity
--- @param caller GEntity
--- @param value string
function ENT:AcceptInput(name, activator, caller, value)
	if BaseClass.AcceptInput and
		BaseClass.AcceptInput(self, name, activator, caller, value) then
		return true
	end

	name = string.lower(name)
	if name == "addoutput" then
		-- The game will automatically turn this into a keyvalue if we don't handle it
		return false
	end

	-- All our remaining events are player driven
	if not IsValid(activator) and activator:IsPlayer() then
		return false
	end
	--- @type GPlayer
	local ply = activator

	if name == "healplayer" then
		local healAmount = tonumber(value)
		if not healAmount then
			print("ERROR: " .. caller .. " has invalid heal amount " .. value .. "!")
			return false
		end
		print("Healed!", ply, caller, caller:MapCreationID())

		player_manager.RunClass(ply, "MapHeal", healAmount, caller)
		return true
	elseif name == "startrun" then
		-- Ideally called by the first trigger_push
		player_manager.RunClass(ply, "StartRun")
		return true
	elseif name == "completerun" then
		-- Ideally called by a trigger_hurt in the complete area (or a
		--  teleporter) but can be called by `OnEndTouch` of the last
		--  trigger_push in dire circumstances
		player_manager.RunClass(ply, "CompleteRun")
		return true
	elseif name == "telespawn" then
		-- Called when a player teleports into a spawn point (theirs or enemies)
		--  from the completion area.
		local team = tonumber(value)
		if team ~= TEAM_RED and team ~= TEAM_BLUE then
			team = nil
		end
		player_manager.RunClass(ply, "TeleSpawn", team)
		return true
	elseif name == "debugstartpush" then
		print("PUSH!", ply, caller, caller:MapCreationID())
		return true
	elseif name == "debugtrigger" then
		print("Trigger!", ply, caller, caller:MapCreationID())
		return true
	elseif name == "debugtele" then
		print("Teleported!", ply, caller, caller:MapCreationID())
		return true
	end

	return false
end

--- @param key string
--- @param value string
function ENT:AddOutputFromKeyValue(key, value)
	if key:lower():sub(1, 2) == "on" then
		self:StoreOutput(key, value)
		return true
	end

	return false
end

function ENT:StoreOutput(name, ...)
	name = string.lower(name)
	return BaseClass.StoreOutput(self, name, ...)
end

--- @param name string
--- @param activator GEntity
--- @param data string|nil
function ENT:TriggerOutput(name, activator, data)
	name = string.lower(name)
	return BaseClass.TriggerOutput(self, name, activator, data)
end
