-- Celeste

function events.AfterLoadMap()
	Party.QBits[722] = true	-- TP Buff Celeste
	if Party.QBits[612] then
		evt.SetMonGroupBit{57, const.MonsterBits.Hostile, true}
		evt.SetMonGroupBit{56, const.MonsterBits.Hostile, true}
		evt.SetMonGroupBit{55, const.MonsterBits.Hostile, true}
	end
end

Game.MapEvtLines:RemoveEvent(452)
evt.hint[452] = evt.str[16]
evt.map[452] = function()
	if not evt.Cmp("MightBonus", 25) then
		evt.Add("MightBonus", 25)
		evt.Add("IntellectBonus", 25)
		evt.Add("PersonalityBonus", 25)
		evt.Add("EnduranceBonus", 25)
		evt.Add("AccuracyBonus", 25)
		evt.Add("SpeedBonus", 25)
		evt.Add("LuckBonus", 25)
		evt.StatusText(70)         -- "+25 to all Stats(Temporary)"
	end
end

