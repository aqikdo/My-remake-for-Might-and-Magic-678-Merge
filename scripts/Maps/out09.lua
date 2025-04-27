-- Evenmorn Island

-- Show obelisk treasure
local Treasure
for i,v in Map.Sprites do
	if v.Event == 170 then
		Treasure = v
		break
	end
end

local Av = true
for i = 676, 689 do
	Av = Av and Party.QBits[i]
end

if Av and Treasure then

	local function SetTrViz()
		Treasure.Invisible = Game.Hour ~= 0
	end

	Timer(SetTrViz, const.Hour/2, true)

end

-- Dimension door

evt.map[6] = TownPortalControls.DimDoorEvent

function events.AfterLoadMap()
	Party.QBits[824] = true	-- DDMapBuff

	local function DimDoor()
		if 1500 > math.sqrt((-5121-Party.X)^2 + (98-Party.Y)^2) then
			TownPortalControls.DimDoorEvent()
		end
	end
	Timer(DimDoor, false, const.Minute*3)

end

evt.hint[503] = evt.str[55]  -- "Erathia Portal"
evt.map[503] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then         -- "Erathia Portal"
		evt.MoveToMap{X = -9853, Y = 8656, Z = -1024, Direction = 2047, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out03.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ °£ À­ Î÷ ÑÇ µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Erathia."
	end
end