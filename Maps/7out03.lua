-- Erathia

-- Travel to Emerald Isle if Player was not there before.

if Party.QBits[519] then
	Game.TransportIndex[34][4] = 44
else
	Game.TransportIndex[34][4] = 101
end

-- Give "Scavenger hunt" advertisment

local CCTimers = {}

function events.AfterLoadMap()
	Party.QBits[720] = true	-- TP Buff Erathia
	Party.QBits[818] = true	-- DDMapBuff
	if not (mapvars.GotAdvertisment or Party.QBits[519]) then

		CCTimers.Catch = function()
			if not (Party.Flying or Party.EnemyDetectorRed or Party.EnemyDetectorYellow)
				and 4000 > math.sqrt((-10511-Party.X)^2 + (6119-Party.Y)^2) then

				mapvars.GotAdvertisment = true
				RemoveTimer(CCTimers.Catch)
				evt.ForPlayer(0).Add{"Inventory", 774}
				evt.SetNPCGreeting(649, 332)
				evt.SpeakNPC{649}

			end
		end
		Timer(CCTimers.Catch, false, const.Minute*3)

	end
end


evt.hint[511] = evt.str[55]  -- "Erathia Portal"
evt.map[511] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then         -- "Erathia Portal"
		evt.MoveToMap{X = -6731, Y = 14045, Z = -512, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out02.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ ¹þ ÃÉ ´ú ¶û µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Harmondale."
	end
end

Game.MapEvtLines:RemoveEvent(204)  -- remove original event
evt.hint[204] = evt.str[4]
evt.map[204] = function()
	if evt.Cmp("BodyResBonus", 20) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 10) then         -- "20 points of temporary Body Resistance from the well south of the Steadwick Town Hall."
		evt.Add("AutonotesBits", 10)         -- "20 points of temporary Body Resistance from the well south of the Steadwick Town Hall."
	end
	evt.Add("BodyResBonus", 20)
	evt.StatusText(72)         -- "+20 Body Resistance (Temporary)"
end

Game.MapEvtLines:RemoveEvent(208)  -- remove original event
evt.hint[208] = evt.str[6]
evt.map[208] = function()
	if evt.Cmp("MightBonus", 50) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 11) then         -- "50 points of temporary Might from the central fountain in Steadwick."
		evt.Add("AutonotesBits", 11)         -- "50 points of temporary Might from the central fountain in Steadwick."
	end
	evt.Add("MightBonus", 50)
	evt.StatusText(74)         -- "+50 Might (Temporary)"
end

Game.MapEvtLines:RemoveEvent(209)  -- remove original event
evt.hint[209] = evt.str[4] 
evt.map[209] = function()
	if evt.Cmp("AccuracyBonus", 10) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 7) then         -- "10 points of temporary Accuracy from the well in the village northeast of Steadwick."
		evt.Add("AutonotesBits", 7)         -- "10 points of temporary Accuracy from the well in the village northeast of Steadwick."
	end
	evt.Add("AccuracyBonus", 10)
	evt.StatusText(70)         -- "+10 Accuracy (Temporary)"
end

Game.MapEvtLines:RemoveEvent(210)  -- remove original event
evt.hint[210] = evt.str[6]
evt.map[210] = function()
	if evt.Cmp("PersonalityBonus", 5) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 12) then         -- "5 points of temporary Personality from the trough in front of the Steadwick Town Hall."
		evt.Add("AutonotesBits", 12)         -- "5 points of temporary Personality from the trough in front of the Steadwick Town Hall."
	end
	evt.Add("PersonalityBonus", 5)
	evt.StatusText(75)         -- "+5 Personality (Temporary)"
end

Game.MapEvtLines:RemoveEvent(203)  -- remove original event
evt.hint[203] = evt.str[4]
evt.map[203] = function()
	evt.StatusText(11)         -- "Refreshing!"
	return
end
