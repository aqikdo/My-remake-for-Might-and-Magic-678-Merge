-- The Barrow Downs

function events.AfterLoadMap()
	Party.QBits[826] = true	-- DDMapBuff
end

Game.MapEvtLines:RemoveEvent(501)
evt.hint[501] = evt.str[30]
evt.map[501] = function()
	evt.MoveToMap {179, -5386, 33, 240, 0, 0, 408, 2, "7d24.blv"}
	--evt.MoveToMap {245, -5362, 34, 512, 0, 0, 408, 2, "7d24.blv"}
end

evt.hint[506] = evt.str[55]  -- "Erathia Portal"
evt.map[506] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then         -- "Erathia Portal"
		evt.MoveToMap{X = -9853, Y = 8656, Z = -1024, Direction = 2047, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "Out03.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ °£ À­ Î÷ ÑÇ µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Erathia."
	end
end

Game.MapEvtLines:RemoveEvent(321)
evt.hint[321] = evt.str[4]
evt.map[321] = function()
	if evt.Cmp("FireResBonus", 25) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 26) then         -- "25 points of temporary Fire resistance from the well in the southwestern village in the Barrow Downs."
		evt.Add("AutonotesBits", 26)         -- "25 points of temporary Fire resistance from the well in the southwestern village in the Barrow Downs."
	end
	evt.Add("FireResBonus", 25)
	evt.StatusText(70)         -- "+25 Fire Resistance (Temporary)"
end

