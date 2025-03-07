-- Temple of the Moon
local MF, MM = Merge.Functions, Merge.ModSettings

Game.MapEvtLines:RemoveEvent(27)
evt.hint[27] = evt.str[10]	-- "Altar of the Moon"
evt.map[27] = function()
	if Party.QBits[1143]	-- "Visit the Altar of the Moon in the Temple of the Moon at midnight of a full moon."
			or Party.QBits[1278] then
		if (Game.DayOfMonth == 14 or MF.GtSettingNum(MM.MM6MasterDruidPromoMondayMidnight, 0)
				and Game.DayOfMonth % 7 == 0) and Game.Hour == 0 then
			evt.SpeakNPC(1091)	-- "Loretta Fleise"
		end
	end
end
