--[[
	Slide - entities/slide_rundata/shared.lua

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
DEFINE_BASECLASS "base_anim"
AddCSLuaFile()

ENT.Type = "anim"
ENT.Spawnable = false
ENT.PrintName = "Tombstone"
ENT.Purpose = "Celebrating and marking a player's clumsy death"
ENT.Author = "Lexi"
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
	self:NetworkVar("Bool", 0, "IsTracking")
	self:NetworkVar("Vector", 0, "TombstonePos")
end
