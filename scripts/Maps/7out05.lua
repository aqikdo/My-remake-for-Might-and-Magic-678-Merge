-- Deyja

function events.AfterLoadMap()
	Party.QBits[820] = true	-- DDMapBuff

	LocalHostileTxt()
	Game.HostileTxt[91][0] = 0

	evt.SetMonGroupBit {56,  const.MonsterBits.Hostile,  true}
	evt.SetMonGroupBit {55,  const.MonsterBits.Hostile,  Party.QBits[611]}
end

function events.ExitNPC(i)
	if i == 461 and not Party.QBits[761] then
		evt.SummonMonsters{3, 3, 5, Party.X, Party.Y, Party.Z + 400, 59}
		evt.SetMonGroupBit{59, const.MonsterBits.Hostile, true}
	end
end

evt.hint[505] = evt.str[55]  -- "Erathia Portal"
evt.map[505] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then         -- "Erathia Portal"
		evt.MoveToMap{X = -9853, Y = 8656, Z = -1024, Direction = 2047, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out03.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ °£ À­ Î÷ ÑÇ µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Erathia."
	end
end

Game.MapEvtLines:RemoveEvent(204)
evt.hint[204] = evt.str[4]
evt.map[204] = function()
	if evt.Cmp("PersonalityBonus", 10) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 16) then         -- "10 points of temporary Personality from the well near the Temple of the Dark in Moulder in Deyja."
		evt.Add("AutonotesBits", 16)         -- "10 points of temporary Personality from the well near the Temple of the Dark in Moulder in Deyja."
	end
	evt.Add("PersonalityBonus", 10)
	evt.StatusText(72)         -- "+10 Personality (Temporary)"
end

Game.MapEvtLines:RemoveEvent(205)
evt.hint[205] = evt.str[4]
evt.map[205] = function()
	if evt.Cmp("FireResBonus", 10) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 17) then         -- "10 points of temporary Fire resistance from the well in the south side of Moulder in Deyja."
		evt.Add("AutonotesBits", 17)         -- "10 points of temporary Fire resistance from the well in the south side of Moulder in Deyja."
	end
	evt.Add("FireResBonus", 10)
	evt.StatusText(74)         -- "+10 Fire Resistance (Temporary)"
end

