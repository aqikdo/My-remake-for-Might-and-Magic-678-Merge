-- Avlee

function events.AfterLoadMap()
	Party.QBits[829] = true	-- DDMapBuff
end

function events.WalkToMap(t)

	if t.LeaveSide == "left" then

		for i,v in Party do
			if v.ItemArmor == 0 or v.Items[v.ItemArmor].Number ~= 1406 then
				if not evt[i].Cmp{"Inventory", 1406} then
					if Party.QBits[642] or Party.QBits[643] or Party.QBits[783] then
						Game.ShowStatusText("You must all be wearing your wetsuits!")
					end
					return
				end
			end
		end

		evt.MoveToMap{20096,-16448,2404,1008,0,0,0,8,"7out15.odm"}
	end

end

evt.hint[504] = evt.str[55]  -- "Erathia Portal"
evt.map[504] = function()
	evt.ForPlayer(0)
	if evt.Cmp("Inventory", 1472) then  -- "Erathia Portal"
		evt.MoveToMap{X = -9853, Y = 8656, Z = -1024, Direction = 2047, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "7Out03.Odm"}
	else
		Game.ShowStatusText(" Äã Ðè Òª Ò» °Ñ Ô¿ ³× À´ ¿ª Æô È¥ °£ À­ Î÷ ÑÇ µÄ ´« ËÍ ÃÅ ¡£")  -- "You need a key to teleport to Erathia."
	end
end

Game.MapEvtLines:RemoveEvent(204)
evt.hint[204] = evt.str[4]
evt.map[204] = function()
	if evt.Cmp("WaterResBonus", 20) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 31) then         -- "20 points of temporary Water resistance from the well in the northwest section of Spaward in Avlee."
		evt.Add("AutonotesBits", 31)         -- "20 points of temporary Water resistance from the well in the northwest section of Spaward in Avlee."
	end
	evt.Add("WaterResBonus", 20)
	evt.StatusText(71)         -- "+20 Water Resistance (Temporary)"
end

