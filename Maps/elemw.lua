-- Plane of Water

local function CalcFatigue()
	if Party.Flying then
		vars.ElemwFatigue = vars.ElemwFatigue + 100
	else
		vars.ElemwFatigue = vars.ElemwFatigue + 10
	end
end

local function KillingTimer()
	if vars.ElemwFatigue >= 10000 and vars.ElemwFatigue < 30000 then
		for i,v in Party do
			if v.Dead == 0 then
				v.HP = v.HP - v:GetFullHP() * ((vars.ElemwFatigue - 10000) / 400000 + 0.01)
			end
		end
	elseif vars.ElemwFatigue >= 30000 then
		for i,v in Party do
			if v.Dead == 0 then
				v.HP = v.HP - v:GetFullHP() * 1 
			end
		end
	end
end

local function GetStone()
	if evt.CheckItemsCount(607,607,1) == true then
		vars.ElemwFatigue = 0
	end
end

function events.AfterLoadMap()
	Party.QBits[812] = true	-- DDMapBuff
	Timer(CalcFatigue, const.Minute / 8, false)
	Timer(KillingTimer, const.Minute / 8, false)
	Timer(GetStone, 1, false)
end

function events.AfterLoadMap()
	if vars.ElemwFatigue == nil then
		vars.ElemwFatigue = 0
		Timer(CalcFatigue, const.Minute / 8, false)
		Timer(KillingTimer, const.Minute / 8, false)
		Timer(GetStone, 1, false)
		Sleep(1)
		Message("Swimming under the water consumes a lot of energy, especially floating up. Try to get the heart of the water as quickly as possible without using too much energy, or you will be buried deep beneath the sea.")
	end
end
