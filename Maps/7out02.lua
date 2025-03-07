-- Harmondale

function events.AfterLoadMap()
	Party.QBits[817] = true	-- DDMapBuff
end

-- Choose Judge quest

evt.Map[37] = function()
	NPCFollowers.Remove(416)
	NPCFollowers.Remove(417)
end

-- Enter castle Harmondale

Game.MapEvtLines:RemoveEvent(301)
evt.Hint = evt.str[30]
evt.Map[301] = function()
	if Party.QBits[519] then
		if Party.QBits[610] or Party.QBits[644] then
			if Party.QBits[610] then
				evt.MoveToMap{-5073, -2842, 1, 512, 0, 0, 382, 9, "7d29.blv"}
			else
				evt.MoveToMap{-5073, -2842, 1, 512, 0, 0, 390, 9, "7d29.blv"}
			end
		else
			Party.QBits[644] = true
			Party.QBits[587] = true

			evt.Add{"History3", 0}
			evt.MoveNPC {397, 240}
			evt.SpeakNPC{397}
		end
	else
		evt.FaceAnimation{Game.CurrentPlayer, const.FaceAnimation.DoorLocked}
	end
end

-- Mercenary guild - invasion

Party.QBits[608] = Party.QBits[611] or Party.QBits[612]

evt.Map[50] = function()
	if (Party.QBits[693] or Party.QBits[694]) and not (Party.QBits[702] or Party.QBits[695]) then
		mapvars.InvasionTime = mapvars.InvasionTime or Game.Time + const.Week*2
		if mapvars.InvasionTime < Game.Time then
			Party.QBits[695] = true
			evt.SetMonGroupBit {60,  const.MonsterBits.Hostile,  true}
			evt.SetMonGroupBit {60,  const.MonsterBits.Invisible, false}
			evt.Set{"BankGold", 0}
			evt.SpeakNPC{437}
		end
	end
end

-- Give "Scavenger hunt" advertisment

local CCTimers = {}

function events.AfterLoadMap()
	if not (mapvars.GotAdvertisment or Party.QBits[519] or evt.All.Cmp{"Inventory", 774}) then

		CCTimers.Catch = function()
			if not (Party.Flying or Party.EnemyDetectorRed or Party.EnemyDetectorYellow)
				and 4000 > math.sqrt((-13115-Party.X)^2 + (12497-Party.Y)^2) then

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


evt.hint[303] = evt.str[100]  -- ""
evt.map[303] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1466) then         -- "Emerald Is. Teleportal Key"
		evt.MoveToMap{X = 12409, Y = 4917, Z = -64, Direction = 1040, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out01.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ ôä ´ä µº µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Emerald Island."
	end
end

evt.hint[304] = evt.str[100]  -- ""
evt.map[304] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1470) then
       evt.MoveToMap{X = 17161, Y = -10827, Z = 0, Direction = 1024, LookAngle = 0, SpeedZ = 0, HouseId = 226, Icon = 4, Name = "Out09.odm"}         -- "Harmondale Teleportal Hub"
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ °¬ ¸¥ ÃÉ µº µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Evenmorn Island."
	end
end

Game.MapEvtLines:RemoveEvent(218)  -- remove original event
evt.hint[218] = evt.str[4]
evt.map[218] = function()
	if evt.Cmp("MightBonus", 10) then
		evt.StatusText(11)         -- "Refreshing!"
	else
		evt.Add("MightBonus", 10)
		evt.StatusText(70)         -- "+ 10 Might (Temporary)"
		evt.Add("AutonotesBits", 6)         -- "10 points of temporary Might from the well in the village south of Harmondale."
	end
end