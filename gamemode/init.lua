--[[
	Slide - gamemode/init.lua

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
]] --
DEFINE_BASECLASS "gamemode_base"

AddCSLuaFile("cl_init.lua")

include("shared.lua")

include("meta_ply.lua")

include("mapfixes/entities.lua")
include("mapfixes/triggers.lua")

function GM:FixMap()
	self:RemoveMapBlockers()
	self:ReplaceTriggerOnces()
	self:ModifyHealTriggers()
	self:MakeExplosionsRepeatable()
	self:TryParentSpawnpoints()
end

GM.CSSSettings = {
	sv_accelerate = 10,
	sv_airaccelerate = 800,
	sv_gravity = 800,
	sv_sticktoground = 0,
}

function GM:InitPostEntity()
	for key, value in pairs(self.CSSSettings) do
		game.ConsoleCommand(key .. " " .. value .. "\n")
	end
	self:FixMap()
end

function GM:PostCleanupMap()
	self:FixMap()
end

function GM:PlayerInitialSpawn(ply)
	BaseClass.PlayerInitialSpawn(self, ply)

	player_manager.SetPlayerClass(ply, "class_default")
end

function GM:PlayerSpawn(ply)
	BaseClass.PlayerSpawn(self, ply)

	ply:CreateRunData()
end

function GM:DoPlayerDeath(ply, ...)
	BaseClass.DoPlayerDeath(self, ply, ...)

	local ts = ply:GetTombstone()
	if IsValid(ts) then
		ts:HandlePlayerDeath()
	end

	-- local rd = ply:GetRunData()
	-- if IsValid(rd) then
	-- 	rd:HandlePlayerDeath()
	-- 	-- TEMP
	-- 	rd:Remove()
	-- end
end

function GM:PlayerSilentDeath(ply)
	BaseClass.PlayerSilentDeath(self, ply)

	local rd = ply:GetRunData()
	if IsValid(rd) then
		rd:HandlePlayerDeath()
		-- TODO: Do we want to keep rundata that results in a Lua based death? Presumably not
		-- rd:Remove()
	end
end

function GM:Think()
	BaseClass.Think(self)

	for _, ply in pairs(player.GetAll()) do
		ply:SetDTVector(0, ply:GetVelocity())
		ply:SetDTVector(1, ply:GetAbsVelocity())
	end
end

function GM:GetFallDamage()
	return 0
end

---
--- @param ply GPlayer
--- @param dmginfo GCTakeDamageInfo
function GM:EntityTakeDamage(ply, dmginfo)
	if not (IsValid(ply) and ply:IsPlayer() and ply:Alive()) then
		return
	end

	self:CheckMapEnd(ply, dmginfo)

	if dmginfo:IsExplosionDamage() and dmginfo:GetDamage() < 100 then
		-- Player just missed a mine. Play the explosion noise but don't actually damage them
		dmginfo:SetDamage(1)
		ply:SetHealth(ply:Health() + 1)
	end
end

--- Called when a player finishes the map
--- @param ply GPlayer
--- @param finishedAt number The time (recorded CurTime) at which the player crossed the finishline (This hook is called several moments after it)
function GM:SlidePlayerFinished(ply, finishedAt)
	PrintMessage(HUD_PRINTTALK, ply:Nick() .. " has finished!")
end