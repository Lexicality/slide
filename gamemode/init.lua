--[[
	Slide - gamemode/init.lua

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

AddCSLuaFile("cl_init.lua")

include("shared.lua")

include("meta_ply.lua")

include("mapfixes/entities.lua")
include("mapfixes/triggers.lua")

function GM:FixMap()
	self:CreateMapController()
	self:RemoveMapBlockers()
	self:ReplaceTriggerOnces()
	self:ModifyHealTriggers()
	self:MakeExplosionsRepeatable()
	self:TryParentSpawnpoints()
end

GM.ServerSettings = GM.ServerSettings or {}
GM.CSSSettings = {
	sv_accelerate = 10,
	sv_airaccelerate = 800,
	sv_gravity = 800,
	sv_sticktoground = 0,
}

function GM:InitPostEntity()
	for cvar, value in pairs(self.CSSSettings) do
		self.ServerSettings[cvar] = cvars.String(cvar)
		RunConsoleCommand(cvar, value)
	end
	self:FixMap()
end

function GM:ShutDown()
	-- Reset the convars
	for cvar, value in pairs(self.ServerSettings) do
		RunConsoleCommand(cvar, value)
	end
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

	local inflictor = dmginfo:GetInflictor()
	if IsValid(inflictor) and inflictor:GetClass() == "trigger_hurt" and
		inflictor._IS_HEAL then
		-- TODO: Should this clamp?
		ply:SetHealth(ply:Health() + dmginfo:GetDamage())
		dmginfo:SetDamage(0)
	end

	if dmginfo:IsExplosionDamage() and dmginfo:GetDamage() < 100 then
		-- Player just missed a mine. Play the explosion noise but don't actually damage them
		dmginfo:SetDamage(1)
		ply:SetHealth(ply:Health() + 1)
	end
end
