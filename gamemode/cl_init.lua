--[[
	Slide - gamemode/cl_init.lua

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

include('shared.lua')

-- hook.Remove("HUDPaint", "paintsprites")

-- local pos, material, white = Vector( -13917.575195, -13495.070313, 157.625534 ), Material( "sprites/splodesprite" ), Color( 255, 255, 255, 255 ) --Define this sort of stuff outside of loops to make more efficient code.
-- hook.Add( "HUDPaint", "paintsprites", function()
-- 	cam.Start3D() -- Start the 3D function so we can draw onto the screen.
-- 		render.SetMaterial( material ) -- Tell render what material we want, in this case the flash from the gravgun
-- 		-- render.SetBlend(0.5);
-- 		render.DrawSprite( pos, 16, 16, white ) -- Draw the sprite in the middle of the map, at 16x16 in it's original colour with full alpha.
-- 	cam.End3D()
-- end )

function GM:Think()
	self.BaseClass.Think(self)

	local lpl = LocalPlayer();

	DebugInfo(5, "GetAbsVelocity: " .. tostring(lpl:GetAbsVelocity()));
	DebugInfo(6, "GetVelocity: " .. tostring(lpl:GetVelocity()));
	DebugInfo(7, "SS GetVelocity: " .. tostring(lpl:GetDTVector(0)))
	DebugInfo(8, "SS GetAbsVelocity: " .. tostring(lpl:GetDTVector(1)))
	DebugInfo(9, "SS GetGroundSpeedVelocity: " .. tostring(lpl:GetDTVector(2)))
	-- SetAbsVelocity
	-- SetLocalVelocity
	-- SetVelocity
end
