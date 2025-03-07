-- The Land of the Giants

-- Correct load map event.
Game.MapEvtLines:RemoveEvent(1)
local function event1()
	Sleep(1000, 1000)

	local QB = Party.QBits
	local need_speak = not QB[775] and (QB[616] or QB[635])

	if need_speak then
		QB[775] = true

		if QB[616] then
			evt.SetNPCGreeting{462, 316}
		elseif QB[635] then
			evt.SetNPCGreeting{462, 317}
		end

		if Mouse.Item.Number ~= 0 then
			Mouse:ReleaseItem()
		end

		Mouse.Item.Number = 866
		Mouse.Item.Identified = true

		evt.SpeakNPC{462}
	end
end

function events.AfterLoadMap()
	coroutine.resume(coroutine.create(event1))
	Party.QBits[827] = true	-- DDMapBuff
end

Game.MapEvtLines:RemoveEvent(205)
evt.hint[205] = evt.str[3]  -- "Well"
evt.map[205] = function()
	local i
	if evt.Cmp("Gold", 5000) then
		evt.Subtract("Gold", 5000)
		i = Game.Rand() % 3
		if i == 1 then
			evt.Set("AgeBonus", 0)
			evt.Add("Food", 10)
		elseif i == 2 then
			if not evt.Cmp("FireResBonus", 50) then
				evt.Add("FireResBonus", 50)
			end
			if not evt.Cmp("AirResBonus", 50) then
				evt.Add("AirResBonus", 50)
			end
			if not evt.Cmp("WaterResBonus", 50) then
				evt.Add("WaterResBonus", 50)
			end
			if not evt.Cmp("EarthResBonus", 50) then
				evt.Add("EarthResBonus", 50)
			end
			if not evt.Cmp("MindResBonus", 50) then
				evt.Add("MindResBonus", 50)
			end
			if not evt.Cmp("BodyResBonus", 50) then
				evt.Add("BodyResBonus", 50)
			end
			if not evt.Cmp("ACBonus", 50) then
				evt.Add("ACBonus", 50)
			end
		else
			if not evt.Cmp("MightBonus", 50) then
				evt.Add("MightBonus", 50)
			end
			if not evt.Cmp("IntellectBonus", 50) then
				evt.Add("IntellectBonus", 50)
			end
			if not evt.Cmp("PersonalityBonus", 50) then
				evt.Add("PersonalityBonus", 50)
			end
			if not evt.Cmp("EnduranceBonus", 50) then
				evt.Add("EnduranceBonus", 50)
			end
			if not evt.Cmp("SpeedBonus", 50) then
				evt.Add("SpeedBonus", 50)
			end
			if not evt.Cmp("AccuracyBonus", 50) then
				evt.Add("AccuracyBonus", 50)
			end
			if not evt.Cmp("LuckBonus", 50) then
				evt.Add("LuckBonus", 50)
			end
		end
	else
		evt.Subtract("Gold", 4999)
	end
	evt.StatusText(65)         -- "You make a wish"
end

