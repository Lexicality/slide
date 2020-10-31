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

function ENT:Initialize()
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
		gamemode.Call("PlayerStartRun", ply)
		return true
	elseif name == "completerun" then
		-- Ideally called by a trigger_hurt in the complete area (or a
		--  teleporter) but can be called by `OnEndTouch` of the last
		--  trigger_push in dire circumstances
		if ply:Alive() then
			gamemode.Call("PlayerCompleteRun", ply)
		end
		return true
	elseif name == "restartrun" then
		-- Called when a player teleports into a spawn point (theirs or enemies)
		--  from the completion area
		-- NOTE: If the restart teleporter puts the player straight into the
		--  first trigger_push, don't bother calling this!
		gamemode.Call("PlayerRestartRun", ply)
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

function ENT:TriggerOutput(name, ...)
	name = string.lower(name)
	return BaseClass.TriggerOutput(self, name, ...)
end
