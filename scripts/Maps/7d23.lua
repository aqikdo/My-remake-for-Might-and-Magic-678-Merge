
evt.SetMonGroupBit {56,  const.MonsterBits.Hostile,  false}
evt.SetMonGroupBit {56,  const.MonsterBits.Invisible, true}

Game.MapEvtLines:RemoveEvent(501)
evt.hint[501] = evt.str[2]
evt.map[501] = function()

	for i,v in Party do
		if v.ItemArmor == 0 or v.Items[v.ItemArmor].Number ~= 1406 then
			if not evt[i].Cmp{"Inventory", 1406} then
				Game.ShowStatusText(evt.str[20])
				return
			end
		end
	end

	evt.MoveToMap{-7005, 7856, 225, 128, 0, 0, 0, 8, "7out15.odm"}

end

Game.MapEvtLines:RemoveEvent(51)
evt.map[51] = function()
	if evt.Cmp("MapVar2", 1) and mapvars.EnterLastRoom == nil then
		evt.SetDoorState{Id = 73, State = 0}
		evt.SetDoorState{Id = 74, State = 0}
	end
end

Game.MapEvtLines:RemoveEvent(52)
evt.map[52] = function()
	if evt.Cmp("MapVar2", 1) and mapvars.EnterLastRoom == nil then
		evt.SetDoorState{Id = 75, State = 0}
		evt.SetDoorState{Id = 76, State = 0}
		mapvars.EnterLastRoom = 1
	end
end

Game.MapEvtLines:RemoveEvent(53)
evt.map[53] = function()
	if evt.Cmp("MapVar2", 1) and mapvars.EnterLastRoom == nil then
		evt.SetDoorState{Id = 69, State = 0}
		evt.SetDoorState{Id = 70, State = 0}
	end
end

Game.MapEvtLines:RemoveEvent(54)
evt.map[54] = function()
	if evt.Cmp("MapVar2", 1) and mapvars.EnterLastRoom == nil then
		evt.SetDoorState{Id = 71, State = 0}
		evt.SetDoorState{Id = 72, State = 0}
		mapvars.EnterLastRoom = 1
	end
end

Game.MapEvtLines:RemoveEvent(56)

Game.MapEvtLines:RemoveEvent(376)
evt.map[376] = function()
	if not evt.Cmp("QBits", 633) then         -- Got the sci-fi part
		if not evt.Cmp("MapVar2", 1) then
			return
		end
		local fl = 0
		for i,v in Map.Monsters do
			if v.NameId == 180 and v.HP > 0 then
				fl = 1
				break
			end
		end
		if not evt.Cmp("Inventory", 1407) and fl == 0 then         -- "Oscillation Overthruster"
			evt.Add("Inventory", 1407)         -- "Oscillation Overthruster"
			evt.Set("QBits", 633)         -- Got the sci-fi part
			evt.Add("QBits", 748)         -- Final Part - I lost it
			evt.SetDoorState{Id = 80, State = 1}
			evt.Set("MapVar3", 1)
		end
	end
	evt.SetLight{Id = 1, On = false}
	evt.SetLight{Id = 2, On = true}
end


