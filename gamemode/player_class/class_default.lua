--[[
	Slide - gamemode/player_class/class_default.lua

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
DEFINE_BASECLASS "player_default"
AddCSLuaFile()

RUN_NOT_STARTED = 0
RUN_RUNNING = 1
RUN_COMPLETE = 2
RUN_FAILED = 3
RUN_ABORTED = 4

--- @type GPlayerClass
local PLAYER = {}

--
-- See gamemodes/base/player_class/player_default.lua for all overridable variables
--
PLAYER.DisplayName = "Player"
PLAYER.WalkSpeed = 250
PLAYER.RunSpeed = 250
PLAYER.CrouchedWalkSpeed = 0.34 -- Multiply move speed by this when crouching
PLAYER.DuckSpeed = 0.3 -- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed = 0.3 -- How fast to go from ducking, to not ducking
PLAYER.TeammateNoCollide = false

function PLAYER:SetupDataTables()
	self.Player:NetworkVar("Int", 0, "RunState")
	self.Player:NetworkVar("Int", 1, "NumLoops")
end

-- This will never happen but it's good housekeeping
function PLAYER:ClassChanged()
	self.Player:SetRunState(0)
	self.Player:SetNumLoops(0)
end

function PLAYER:Init()
	-- Make it so we can target the player with hammer I/O
	self.Player:SetKeyValue("targetname", self.Player:SteamID())
end

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()

	self.Player:GiveAmmo(256, "Pistol", true)
	self.Player:Give("weapon_pistol")
end

function PLAYER:Spawn()
	local ply = self.Player
	ply:SetRunState(RUN_NOT_STARTED)
	ply:SetNumLoops(0)
	-- TODO: (not) Rundata
	ply:CreateRunData()
end

--- @param inflictor GEntity
--- @param attacker GEntity
function PLAYER:Death(inflictor, attacker)
	local ply = self.Player

	local ts = ply:GetTombstone()
	if IsValid(ts) then
		ts:HandlePlayerDeath()
	end

	local state = ply:GetRunState()
	if state == RUN_RUNNING then
		ply:SetRunState(RUN_FAILED)
		-- TODO: Rundata
		gamemode.Call("PlayerFailRun", ply, inflictor, attacker)
	end

	-- local rd = ply:GetRunData()
	-- if IsValid(rd) then
	-- 	rd:HandlePlayerDeath()
	-- 	-- TEMP
	-- 	rd:Remove()
	-- end
end

function PLAYER:DeathSilent()
	local ply = self.Player

	local rd = ply:GetRunData()
	if IsValid(rd) then
		rd:HandlePlayerDeath()
		-- TODO: Do we want to keep rundata that results in a Lua based death? Presumably not
		-- rd:Remove()
	end

	local state = ply:GetRunState()
	if state == RUN_RUNNING then
		ply:SetRunState(RUN_ABORTED)
		-- TODO: Rundata
		gamemode.Call("PlayerAbortRun", ply)
	end
end

--- @param amount integer
--- @param healer GEntity
function PLAYER:MapHeal(amount, healer)
	local ply = self.Player
	if gamemode.Call("PlayerCanMapHeal", ply, amount, healer) == false then
		return
	end
	ply:SetHealth(math.min(ply:GetMaxHealth(), ply:Health() + amount))
	gamemode.Call("MapHealPlayer", ply, amount, healer)
end

function PLAYER:StartRun()
	local ply = self.Player
	if not ply:Alive() then
		return
	end
	local state = ply:GetRunState()
	local numLoops = ply:GetNumLoops() + 1
	ply:SetNumLoops(numLoops)
	if state == RUN_RUNNING then
		-- TODO: Rundata
		gamemode.Call("PlayerLoopRun", ply, numLoops)
	else
		ply:SetRunState(RUN_RUNNING)
		-- TODO: Rundata
		gamemode.Call("PlayerStartRun", ply, numLoops)
	end
end

function PLAYER:CompleteRun()
	local ply = self.Player
	if not ply:Alive() then
		return
	end
	local state = ply:GetRunState()
	if state ~= RUN_RUNNING then
		return
	end
	ply:SetRunState(RUN_COMPLETE)
	-- TODO: Rundata
	gamemode.Call("PlayerCompleteRun", ply, ply:GetNumLoops())
end

--- @param targetTeam number|nil
function PLAYER:TeleSpawn(targetTeam)
	local ply = self.Player
	if not ply:Alive() then
		return
	end
	local state = ply:GetRunState()
	if state == RUN_NOT_STARTED then
		return
	end
	-- If the player has an active run, abort it before we continue
	if state == RUN_RUNNING then
		ply:SetRunState(RUN_ABORTED)
		-- This loop didn't count
		ply:SetNumLoops(math.max(ply:GetNumLoops() - 1, 0))
		-- TODO: Rundata
		gamemode.Call("PlayerAbortRun", ply)
	end
	ply:SetRunState(RUN_NOT_STARTED)
	-- TODO: Rundata
	gamemode.Call("PlayerTeleSpawn", ply, targetTeam)
end

player_manager.RegisterClass("class_default", PLAYER, "player_default")
