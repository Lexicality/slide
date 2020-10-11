--[[
	Slide - gamemode/shared.lua

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
AddCSLuaFile()

GM.Name = "Slide"
GM.Author = "Lexi"
GM.Email = "lexi@lexi.org.uk"
GM.Website = "http://lexi.org.uk"
GM.Version = "0.0.1"
GM.Help =
	"Slide from one end of the map to the other without dying horribly (Easier said than done)"
GM.TeamBased = true

DeriveGamemode("base")
include("player_class/class_default.lua")

MsgN("Slide!")

TEAM_RED = 2
TEAM_BLUE = 3

function GM:CreateTeams()
	team.SetUp(TEAM_RED, "Team Red", Color(255, 75, 67))
	team.SetUp(TEAM_BLUE, "Team Blue", Color(39, 186, 255))
	team.SetUp(TEAM_SPECTATOR, "Spectators", Color(200, 200, 200), true)

	team.SetSpawnPoint(TEAM_RED, "info_player_terrorist", true)
	team.SetSpawnPoint(TEAM_BLUE, "info_player_counterterrorist", true)
	team.SetSpawnPoint(
		TEAM_SPECTATOR, {"info_player_counterterrorist", "info_player_terrorist"}
	)
end

function GM:PlayerNoClip(ply, state)
	return true
end
