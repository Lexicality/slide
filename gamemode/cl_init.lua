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
