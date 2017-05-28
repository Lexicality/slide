--[[
	Slide - entities/slide_tombstone.lua

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
--]]

AddCSLuaFile()

ENT.Base        = "base_anim"
ENT.Type        = "anim"
ENT.Spawnable   = false
ENT.PrintName   = "Tombstone"
ENT.Purpose     = "Celebrating and marking a player's clumsy death"
ENT.Author      = "Lexi"
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.SpriteSize = 70

DEFINE_BASECLASS "base_entity"

function ENT:Initialize()
	self:SetModel("models/gibs/hgibs.mdl")
	self:SetMoveType(MOVETYPE_NONE)
	self:SetSolid(SOLID_NONE)
end

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "Player")
	self:NetworkVar("Bool", 0, "GrizzlyWarning")
end

function ENT:HandlePlayerDeath()
	local ply = self:GetPlayer()
	if not IsValid(ply) then
		error("Player is invalid!", 2)
	end
	local pos = ply:GetPos()
	local obb = self:OBBMaxs()
	pos.z = pos.z + obb.z
	self:SetPos(pos)
	local ang = ply:GetAngles()
	self:SetAngles(Angle(0, -ang.yaw, 0))

	local runData = ply:GetRunData()
	if IsValid(runData) then
		runData:HandlePlayerDeath()
		runData:SetFinalRestingPlace(self:GetPos())
		if IsValid(self.lastRunData) then
			self.lastRunData:Remove()
		end
		self.lastRunData = runData
	end
end

-- function ENT:UpdateTransmitState()
-- 	return TRANSMIT_ALWAYS
-- end

--[[
  _                     _                _
 | |                   | |              | |
 | |__   ___ _ __ ___  | |__   ___    __| |_ __ __ _  __ _  ___  _ __  ___
 | '_ \ / _ \ '__/ _ \ | '_ \ / _ \  / _` | '__/ _` |/ _` |/ _ \| '_ \/ __|
 | | | |  __/ | |  __/ | |_) |  __/ | (_| | | | (_| | (_| | (_) | | | \__ \
 |_| |_|\___|_|  \___| |_.__/ \___|  \__,_|_|  \__,_|\__, |\___/|_| |_|___/
                                                      __/ |
                                                     |___/
--]]

if SERVER then
	return
end


local i = 0
function aa(wut)
	DebugInfo(i, tostring(wut))
	i = i + 1
end

ENT.NextParticle = 0
ENT.ParticleDelay = 0.1
function ENT:HandleParticles()
	local testParticleMaterial = getSaneMaterial("sprites/yelflare1")
	local ct = CurTime()
	if ct < self.NextParticle then
		return
	end
	self.NextParticle = ct + self.ParticleDelay

	local p = self.PortalEmitter:Add(testParticleMaterial, self.BeamTop)
	if not p then
		return
	end
	p:SetVelocity((self.PortalNormal + VectorRand()) * 10)
	p:SetDieTime(3)
	p:SetStartSize(3)
	p:SetEndSize(0)
	local ea = LocalPlayer():EyeAngles()
	p:SetAngles(ea)
	p:SetGravity(-vector_up * 5)
end

ENT.BeamTop = vector_origin
ENT.ExitPortal = false
ENT.PortalNormal = vector_up
ENT.PortalEmitter = nil
function ENT:Think()
	-- Debugging
	i = 0
	-- Particles
	if self.PortalEmitter then
		self:HandleParticles()
	end
	-- Top
	local here = self:GetPos()
	local tr = util.TraceLine({
		start  = here,
		endpos = here + vector_up * 20000,
		mask   = MASK_SOLID_BRUSHONLY,
	})
	if tr.HitPos == self.BeamTop then
		return
	end
	self.BeamTop = tr.HitPos
	if tr.Hit and not tr.HitSky then
		self.ExitPortal = true
		self.PortalNormal = tr.HitNormal
		if self.PortalEmitter then
			self.PortalEmitter:SetPos(self.BeamTop)
		else
			self.PortalEmitter = ParticleEmitter(self.BeamTop, true)
		end
	elseif self.ExitPortal then
		self.ExitPortal = false
		if self.PortalEmitter then
			self.PortalEmitter:Finish()
			self.PortalEmitter = nil
		end
	end
	local ss = self.SpriteSize
	local mins = Vector(-ss, -ss, -ss)
	local maxs = Vector(ss, ss, (self.BeamTop - here).z)
	self:SetRenderBounds(mins, maxs)
end

function ENT:ShouldDraw()
	if self.dt.GrizzlyWarning then

		return true
	end
	return self:GetPlayer() == LocalPlayer()
end

local debugNo = Color(255, 0, 0)
local debugYes = Color(0, 255, 0)

function ENT:IsTranslucent()
	return true
end

function ENT:Draw()
	if not self:ShouldDraw() then
		return
	end

	self:DrawModel()
end

local matCache = {}
function getSaneMaterial(str)
	local mat
	mat = matCache[str]
	if mat then
		return mat
	end
	mat = Material(str)
	matCache[str] = mat
	if mat:IsError() then
		return mat
	end

	-- Fun with rendermodes ¬_¬
	if mat:GetInt("$spriterendermode") == 0 then
		mat:SetInt("$spriterendermode", 5)
	end
	mat:Recompute()
	return mat
end

local color_orange = Color(255, 0, 200)
function ENT:DrawTranslucent()
	if not self:ShouldDraw() then
		return
	end
	-- These have to be cached here due to sprit bullshit
	local behindGlow = getSaneMaterial("sprites/flare1")
	local beam = getSaneMaterial("sprites/laserbeam")
	local portal = getSaneMaterial("sprites/glow02")


	-- self.BaseClass.DrawTranslucent(self, true)

	local here = self:GetPos()
	local norm = here - EyePos()
	norm:Normalize()

	local size = self.SpriteSize

	local top = self.BeamTop
	local dist = top - here

	local ct = CurTime()

	local n = ((ct * 10) % 100) / 100

	-- local

	local beamsize = size / 2
	local target = size / 10
	if not self.ExitPortal then
		target = 0
	end
	local steps = 10
	local sizeStep = (beamsize - target) / steps
	local distStep = dist / steps

	render.SetMaterial(beam)
	-- render.OverrideColorWriteEnable(true, true)
	-- render.SetColorModulation(1, 0, 1)
	render.SetBlend(0.2)
	render.StartBeam(steps + 1)
	render.AddBeam(here, beamsize, n)
	for i = 1, steps do
		render.AddBeam(here + distStep * i, beamsize - i * sizeStep, n - i / 4)
	end
	-- render.AddBeam(here + (top - here) / 2, 50, 1)
	-- render.AddBeam(top, 10, 0)
	render.EndBeam()
	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)

	local spin = (ct * 5) % 360

	render.SetMaterial(behindGlow)
	render.DrawQuadEasy(
		here,
		norm,
		size + (math.random() * 2 - 1),
		size + (math.random() * 2 - 1),
		color_white,
		spin
		-- math.random(360)
	)
	size = size * 0.7
	render.DrawQuadEasy(
		here,
		norm,
		size + (math.random() * 2 - 1),
		size + (math.random() * 2 - 1),
		color_white,
		360 - spin
		-- math.random(360)
	)
	-- render.DrawSprite(self:GetPos(), size, size)

	if (self.ExitPortal) then
		-- render.SetMaterial(portal)
		render.DrawQuadEasy(
			self.BeamTop - vector_up,
			self.PortalNormal,
			target * 2.2,
			target * 2.2,
			color_white,
			spin
		)
	end

	-- TODO: Sparkles n shit
end
