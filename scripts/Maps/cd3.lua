-- Castle Kriegspire

local MF, MM = Merge.Functions, Merge.ModSettings

-- Guardian of Kriegspire
Game.MapEvtLines:RemoveEvent(13)
evt.hint[13] = evt.str[8]
evt.Map[13] = function()
	if Party.QBits[1364] then
		evt.MoveToMap {13487, 3117, 673, 0, 0, 0, 0, 0, "0"}
	else
		local Answer = string.lower(Question(evt.str[9]))
		if (Answer == string.lower(evt.str[11]) or Answer == string.lower(evt.str[12])) and Party.Gold >= 50000 then
			evt.Subtract{"Gold", 50000}
			evt.MoveToMap {13487, 3117, 673, 0, 0, 0, 0, 0, "0"}
		else
			Game.ShowStatusText(evt.str[13])
		end
	end
end

-- Curator of Kriegspire
Game.MapEvtLines:RemoveEvent(27)
evt.hint[27] = evt.str[14]
evt.Map[27] = function()
	local Answer = string.lower(Question(evt.str[15]))
	if (Answer == string.lower(evt.str[11]) or Answer == string.lower(evt.str[12])) and Party.Gold >= 10000 then
		evt.ForPlayer(0)
		evt.Subtract("Gold", 10000)

		evt.ForPlayer("All")
		evt.Set("MainCondition", 0)
		evt.Add("HasFullHP", 0)
		evt.Add("HasFullSP", 0)
		if MM and MF.GtSettingNum(MM.MM6MultibyteReputationBug, 0) then
			evt.Subtract("ReputationIs", 500 % 256)
		else
			evt.Subtract("ReputationIs", 500)
		end
	else
		Game.ShowStatusText(evt.str[13])
	end
end

function events.LoadMap()
	Log(Merge.Log.Info, "cd3: LoadMap")
	--Map.Monsters[0].NameId = 134	-- Lurch
end
