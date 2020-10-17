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

function PLAYER:Loadout()
	self.Player:RemoveAllAmmo()

	self.Player:GiveAmmo(256, "Pistol", true)
	self.Player:Give("weapon_pistol")
end

function PLAYER:Spawn()
	self.Player:CreateRunData()
end

function PLAYER:Death(inflicor, attacker)
	local ts = self.Player:GetTombstone()
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

player_manager.RegisterClass("class_default", PLAYER, "player_default")

-- local CLASS = {}

-- function CLASS:Loadout(pl)
-- 	pl:Give("weapon_knife")
-- 	if (pl:Team() == TEAM_RED) then
-- 		pl:Give("weapon_real_cs_glock18")
-- 	else
-- 		pl:Give("weapon_real_cs_usp")
-- 	end
-- end

-- function CLASS:OnSpawn(pl)

-- 	if (IsValid(pl.m_entTrail)) then
-- 		pl.m_entTrail:Remove()
-- 	end

-- 	local AttachmentID = 0

-- 	local col = team.GetColor(pl:Team())

-- 	pl.m_entTrail = util.SpriteTrail(pl, AttachmentID, col, true, 48, 4, 2, 0, "trails/plasma.vmt")
-- 	pl.m_entTrail:SetParent(pl)

-- end

-- player_class.Register("Default", CLASS)
