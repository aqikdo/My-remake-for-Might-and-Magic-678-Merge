function events.MonsterKilled(mon)
	if mon.NameId == 187 then
		evt.Set("MapVar1", 1)
	end
end

evt.map[201] = function()
	if not evt.Cmp("MapVar1", 1) then
		ExitScreen()
		Sleep(1)
		Message(" µØ Ö® ÊØ ÎÀ ÔÚ Äã ÊÔ Í¼ ¿ª ÃÅ Ê± Ï® »÷ ÁË Äã")
		Sleep(1)
		for i,pl in Party do 
			pl.HP = -10000
		end
	end
end

