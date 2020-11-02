--[[
	Slide - entities/slide_rundata/init.lua

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

AddCSLuaFile("cl_init.lua")
include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/gibs/hgibs.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)

	self.positions = {}
end

function ENT:Setup(ply)
	self:SetPos(ply:GetPos())
	self:SetParent(ply)
	ply:DeleteOnRemove(self)
	self:SetPlayer(ply)
	self:SetIsTracking(true)
end

function ENT:GetData()
	return self.positions
end

function ENT:Think()
	local ply = self:GetPlayer()
	if not (self:GetIsTracking() and IsValid(ply)) then
		return
	end

	self.positions[#self.positions + 1] = {
		ctime = CurTime(),
		rtime = RealTime(),
		pos = ply:GetPos(),
		ang = ply:GetAngles(),
		vel = ply:GetVelocity(),
	}
end
