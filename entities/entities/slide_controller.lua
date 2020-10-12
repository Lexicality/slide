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

	if name == "healplayer" then
		local healAmount = tonumber(value)
		if not healAmount then
			print("ERROR: " .. caller .. " has invalid heal amount " .. value .. "!")
			return true
		end

		if IsValid(activator) and activator:IsPlayer() then
			gamemode.Call("MapHealPlayer", activator, healAmount, caller)
		end
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
