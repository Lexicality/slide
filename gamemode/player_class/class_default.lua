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
	local ply = self.Player
	ply:NetworkVar("Int", 0, "RunState")
	ply:NetworkVar("Int", 1, "NumLoops")
	ply:NetworkVar("Entity", 0, "RunData")
	ply:NetworkVar("Entity", 1, "Tombstone")
end

-- This will never happen but it's good housekeeping
function PLAYER:ClassChanged()
	local ply = self.Player
	ply:SetDTInt(0, 0)
	ply:SetDTInt(1, 0)
	ply:SetDTEntity(0, NULL)
	ply:SetDTEntity(1, NULL)
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
end

--- @param inflictor GEntity
--- @param attacker GEntity
function PLAYER:Death(inflictor, attacker)
	local ply = self.Player

	local state = ply:GetRunState()
	if state ~= RUN_RUNNING then
		return
	end

	-- Get rid of the previous tombstone
	local oldTomb = ply:GetTombstone()
	if IsValid(oldTomb) then
		oldTomb:Remove()
	end

	local runData = ply:GetRunData()
	if IsValid(runData) then
		runData:SetIsTracking(false)
		-- TODO: Extract the rundata data
		ply:SetRunData(NULL)
	end

	local tombstone = ents.Create("slide_tombstone")
	-- This will deal with removing the rundata entity
	tombstone:Spawn()
	tombstone:Activate()
	tombstone:Setup(ply, runData)
	ply:SetTombstone(tombstone)

	ply:SetRunState(RUN_FAILED)
	gamemode.Call("PlayerFailRun", ply, inflictor, attacker)
end

function PLAYER:DeathSilent()
	self:AbortRun()
end

function PLAYER:AbortRun()
	local ply = self.Player

	local state = ply:GetRunState()
	if state ~= RUN_RUNNING then
		return
	end

	-- If the run is aborted, the rundata is useless
	local runData = ply:GetRunData()
	if IsValid(runData) then
		runData:Remove()
		ply:SetRunData(NULL)
	end

	-- Leave the player's last tombstone, don't create a new one

	ply:SetRunState(RUN_ABORTED)
	gamemode.Call("PlayerAbortRun", ply)
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

	local numLoops = ply:GetNumLoops() + 1
	ply:SetNumLoops(numLoops)

	local state = ply:GetRunState()
	if state == RUN_RUNNING then
		-- TODO: Add lapping to rundata
		gamemode.Call("PlayerLoopRun", ply, numLoops)
	else
		-- Clean up any victory data we had
		local lastRunData = ply:GetRunData()
		if IsValid(lastRunData) then
			lastRunData:Remove()
		end

		local runData = ents.Create("slide_rundata")
		runData:Spawn()
		runData:Activate()
		runData:Setup(ply)
		ply:SetRunData(runData)

		ply:SetRunState(RUN_RUNNING)

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

	-- Get rid of any proof you ever failed
	local oldTomb = ply:GetTombstone()
	if IsValid(oldTomb) then
		oldTomb:Remove()
	end

	local runData = ply:GetRunData()
	if IsValid(runData) then
		runData:SetIsTracking(false)
		-- TODO: Extract the rundata data
		runData:SetParent(NULL)
		-- FIXME: Workaround for teleporters
		local data = runData:GetData()
		if #data > 0 then
			runData:SetPos(data[#data].pos)
		end
		-- Leave successful runs around until the player leaves
		ply:SetRunData(NULL)
	end

	ply:SetRunState(RUN_COMPLETE)
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
		-- This loop didn't count
		ply:SetNumLoops(math.max(ply:GetNumLoops() - 1, 0))
		self:AbortRun()
	end

	ply:SetRunState(RUN_NOT_STARTED)
	gamemode.Call("PlayerTeleSpawn", ply, targetTeam)
end

player_manager.RegisterClass("class_default", PLAYER, "player_default")
