local function AirPrisonTimer()
	if Party.X > -350 and Party.X < 475 and Party.Y > -285 and Party.Y < 990 and Party.Z > -3525 and Party.Z < -3330 then
		for i,v in Map.Monsters do
			if v.HP > 0 then
				v.HP = v.FullHP
			end
		end
	end
	if not evt.Cmp("MapVar2", 1) then
		if Party.X > 500 and Party.X < 1150 and Party.Y > 500 and Party.Y < 1150 and Party.Z > 1000 and Party.Z < 1550 then
			evt.Set("MapVar2", 1)
			local Boss = SummonMonster(84, 825, 825, 1250, true)
			Boss.NameId = 186
			BolsterMonsters()
		end
	end
	
end

local function TrapTimer()
	if evt.Cmp("MapVar2", 1) then
		--[[
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), 100 + math.random(-50,50),  0 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), 50 + math.random(-50,50),  50 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), 0 + math.random(-50,50),  100 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), -50 + math.random(-50,50), 50 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), -100 + math.random(-50,50), 0 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), -50 + math.random(-50,50),-50 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), 0 + math.random(-50,50), -100 + math.random(-50,50), math.random(0,100))
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), 50 + math.random(-50,50), -50 + math.random(-50,50), math.random(0,100))
		--]]
		evt.CastSpell(15, 4, 999, 0, 0, math.random(100, 500), math.random(-150,150),  math.random(-100,100), math.random(0,100))
		
	end
end

function events.MonsterKilled(mon)
	if mon.NameId == 186 then
		evt.Set("MapVar1", 1)
	end
end

evt.map[201] = function()
	if not evt.Cmp("MapVar1", 1) then
		ExitScreen()
		Sleep(1)
		Message(" ·ç Ö® ÊØ ÎÀ ÔÚ Äã ÊÔ Í¼ ¿ª ÃÅ Ê± Ï® »÷ ÁË Äã")
		Sleep(1)
		for i,pl in Party do 
			pl.HP = -10000
		end
	end
end

function events.AfterLoadMap()
	Timer(AirPrisonTimer, 4, false)
	Timer(TrapTimer, const.Minute / 32, false)
end
