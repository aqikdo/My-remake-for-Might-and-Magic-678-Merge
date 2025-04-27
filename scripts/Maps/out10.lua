-- Mount Nighon

function events.AfterLoadMap()
	Party.QBits[721] = true	-- TP Buff Nighon
	Party.QBits[825] = true	-- DDMapBuff
end

Game.MapEvtLines:RemoveEvent(204)
evt.hint[204] = evt.str[4]  -- "Drink from the Well"
evt.map[204] = function()
	if evt.Cmp("FireResBonus", 20) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 23) then         -- "20 points of temporary Air, Earth, Fire, Water, Body, and Mind resistances from the well near the Fire Guild in Damocles in Mount Nighon."
		evt.Add("AutonotesBits", 23)         -- "20 points of temporary Air, Earth, Fire, Water, Body, and Mind resistances from the well near the Fire Guild in Damocles in Mount Nighon."
	end
	evt.Add("FireResBonus", 20)
	evt.Add("WaterResBonus", 20)
	evt.Add("BodyResBonus", 20)
	evt.Add("AirResBonus", 20)
	evt.Add("EarthResBonus", 20)
	evt.Add("MindResBonus", 20)
	evt.StatusText(73)         -- "+20 All Resistances (Temporary)"
end

Game.MapEvtLines:RemoveEvent(206)
evt.hint[206] = evt.str[6]
evt.map[206] = function()
	if evt.Cmp("PersonalityBonus", 50) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 20) then         -- "50 points of temporary Intellect and Personality from the central fountain in Damocles in Mount Nighon."
		evt.Add("AutonotesBits", 20)         -- "50 points of temporary Intellect and Personality from the central fountain in Damocles in Mount Nighon."
	end
	evt.Add("PersonalityBonus", 50)
	evt.Add("IntellectBonus", 50)
	evt.StatusText(70)         -- "+50 Intellect and Personality (Temporary)"
end

