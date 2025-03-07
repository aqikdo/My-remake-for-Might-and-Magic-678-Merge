-- Shadow Guild

local function TellPassword(Text, QText, An1, An2, Door)
	local Answer = string.lower(Question(evt.str[Text] .. "\n" .. evt.str[QText]))
	if Answer == string.lower(evt.str[An1]) or Answer == string.lower(evt.str[An2]) then
		evt.SetDoorState{Door, 1}
	else
		Game.ShowStatusText(evt.str[22])
	end
end

Game.MapEvtLines:RemoveEvent(61)
evt.hint[61] = evt.str[16]
evt.Map[61] = function() TellPassword(18, 21, 19, 20, 61) end

Game.MapEvtLines:RemoveEvent(62)
evt.hint[62] = evt.str[16]
evt.Map[62] = function() TellPassword(23, 21, 24, 25, 62) end

Game.MapEvtLines:RemoveEvent(63)
evt.hint[63] = evt.str[16]
evt.Map[63] = function() TellPassword(26, 21, 27, 27, 63) end

Game.MapEvtLines:RemoveEvent(64)
evt.hint[64] = evt.str[16]
evt.Map[64] = function() TellPassword(28, 21, 29, 30, 64) end

Game.MapEvtLines:RemoveEvent(65)
evt.map[65] = function()
	evt.MoveToMap{X = 22285, Y = 20508, Z = 346, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "outc3.odm"}
end

Game.MapEvtLines:RemoveEvent(66)
evt.map[66] = function()
	evt.MoveToMap{X = 50, Y = -480, Z = 2, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "zddb04.blv"}
end

Game.MapEvtLines:RemoveEvent(67)
evt.map[67] = function()
	evt.MoveToMap{X = -14583, Y = 11920, Z = 860, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "outa3.odm"}
end

Game.MapEvtLines:RemoveEvent(68)
evt.map[68] = function()
	evt.MoveToMap{X = 1408, Y = -1664, Z = 1, Direction = 0, LookAngle = 0, SpeedZ = 0, HouseId = 0, Icon = 0, Name = "0"}
end

-- Fix spike trap
Map.Facets[373].PolygonType = 5

local function Invisibility()
	for i,v in Map.Monsters do
		if v.HP > 0 then
			v.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = Game.Time + const.Year
			v.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power = 1000
		end
	end
end 

function events.LoadMap()
	Log(Merge.Log.Info, "6d08: LoadMap")
	Timer(Invisibility, const.Minute, false)
	--Map.Monsters[0].NameId = 127	-- Rogue Leader
	--Map.Monsters[1].NameId = 128	-- Lesser Genie
end
