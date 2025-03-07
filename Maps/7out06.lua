-- The Bracada Desert

function events.AfterLoadMap()
	Party.QBits[821] = true	-- DDMapBuff
end


evt.hint[504] = evt.str[55]  -- "Erathia Portal"
evt.map[504] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then         -- "Erathia Portal"
		evt.MoveToMap{X = -9853, Y = 8656, Z = -1024, Direction = 2047, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out03.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ °£ À­ Î÷ ÑÇ µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Erathia."
	end
end

Game.MapEvtLines:RemoveEvent(461)
evt.hint[461] = evt.str[6]
evt.map[461] = function()
	if evt.Cmp("PersonalityBonus", 25) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 18) then         -- "25 points of temporary Intellect and Personality from the fountain outside the School of Sorcery in the Bracada Desert."
		evt.Add("AutonotesBits", 18)         -- "25 points of temporary Intellect and Personality from the fountain outside the School of Sorcery in the Bracada Desert."
	end
	evt.Add("PersonalityBonus", 25)
	evt.Add("IntellectBonus", 25)
	evt.StatusText(72)         -- "+25 Intellect and Personality (Temporary)"
end

