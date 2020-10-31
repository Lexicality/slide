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

include("utils.lua")

include("meta_entity.lua")
include("meta_ply.lua")

GM.MapData = {}

for _, filename in ipairs(file.Find("slide/gamemode/mapdata/*.lua", "LUA")) do
	include("slide/gamemode/mapdata/" .. filename)
end

include("mapfixes/entities.lua")
include("mapfixes/triggers.lua")

function GM:FixMap()
	self:CreateMapController()
	self:RemoveMapBlockers()
	self:ReplaceTriggerOnces()
	self:ModifyHealTriggers()
	self:MakeExplosionsRepeatable()
	self:TryParentSpawnpoints()
	self:AttachMapTriggers()
	self:SetupTriggerDebugs()
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

	if dmginfo:IsExplosionDamage() and dmginfo:GetDamage() < 100 then
		-- Either a) the player just missed a mine or b) this map uses multiple weak mines
		-- We want the player to be either alive or dead, not wounded so negate
		-- the mine damage but keep a record of it in case there are multiple
		-- blasts
		local damage = dmginfo:GetDamage()
		local exstingDamage = ply._tempDamage or 0
		local totalDamage = damage + exstingDamage
		if totalDamage < ply:Health() then
			ply._tempDamage = totalDamage
			dmginfo:SetDamage(1)
			ply:SetHealth(ply:Health() + 1)
		else
			dmginfo:SetDamage(totalDamage)
		end
	end
end

--- @param ply GPlayer
function GM:PlayerPostThink(ply)
	ply._tempDamage = 0
end

--- @param ply GPlayer
--- @param amount number
--- @param healer GEntity
function GM:PlayerCanMapHeal(ply, amount, healer)
	return true
end

--- @param ply GPlayer
--- @param amount number
--- @param healer GEntity
function GM:MapHealPlayer(ply, amount, healer)
end

--- @param ply GPlayer
function GM:PlayerStartRun(ply)
	PrintMessage(HUD_PRINTTALK, ply:Name() .. " Just started a run!")
end

--- @param ply GPlayer
function GM:PlayerCompleteRun(ply)
	PrintMessage(HUD_PRINTTALK, ply:Name() .. " Just finished!")
end

--- @param ply GPlayer
--- @param targetTeam number|nil
function GM:PlayerTeleSpawn(ply, targetTeam)
	if targetTeam == TEAM_RED then
		PrintMessage(HUD_PRINTTALK, ply:Name() .. " Teleported to red spawn!")
	elseif targetTeam == TEAM_BLUE then
		PrintMessage(HUD_PRINTTALK, ply:Name() .. " Teleported to blue spawn!")
	else
		PrintMessage(HUD_PRINTTALK, ply:Name() .. " Teleported to spawn!")
	end
end
