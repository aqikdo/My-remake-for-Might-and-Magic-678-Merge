-- Plane of Air

local function Haste()
	for i,v in Map.Monsters do
		if v.HP > 0 and v.NameId == 192 then
			v.X = v.X + v.VelocityX * 0.02
			v.Y = v.Y + v.VelocityY * 0.02 
			v.Z = v.Z + v.VelocityZ * 0.02 
		end
	end
end 

function events.AfterLoadMap()
	Party.QBits[809] = true	-- DDMapBuff
	Timer(Haste, 1, false)
end
