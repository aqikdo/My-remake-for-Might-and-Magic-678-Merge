-- Tatalia

function events.AfterLoadMap()
	Party.QBits[828] = true	-- DDMapBuff
end

----------------------------------------
-- Adventurer's Inn

evt.house[82] = 1607
evt.map[82] = function() evt.EnterHouse{1607} end


evt.house[82] = 1607
evt.map[82] = function() evt.EnterHouse{1607} end

evt.hint[506] = evt.str[55]  -- "Erathia Portal"
evt.map[506] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then         -- "Erathia Portal"
		evt.MoveToMap{X = -6731, Y = 14045, Z = -512, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out02.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ ¹þ ÃÉ ´ú ¶û µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Harmondale."
	end
end

Game.MapEvtLines:RemoveEvent(202)
evt.hint[202] = evt.str[4]
evt.map[202] = function()
	if evt.Cmp("ArmorClassBonus", 20) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 29) then         -- "20 points of temporary Armor Class from the well in the northern village in Tatalia."
		evt.Add("AutonotesBits", 29)         -- "20 points of temporary Armor Class from the well in the northern village in Tatalia."
	end
	evt.Add("ArmorClassBonus", 20)
	evt.StatusText(73)         -- "+20 AC (Temporary)"
end


Game.MapEvtLines:RemoveEvent(203)
evt.hint[203] = evt.str[4]
evt.map[203] = function()
	if evt.Cmp("AirResBonus", 20) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 28) then         -- "20 points of temporary Air resistance from the well in the eastern section of Tidewater in Tatalia."
		evt.Add("AutonotesBits", 28)         -- "20 points of temporary Air resistance from the well in the eastern section of Tidewater in Tatalia."
	end
	evt.Add("AirResBonus", 20)
	evt.StatusText(72)         -- "+20 Air Resistance (Temporary)"
end

