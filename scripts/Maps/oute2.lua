-- Misty Islands

function events.AfterLoadMap()
	LocalHostileTxt()
	Game.HostileTxt[211][0] = 0
	Game.HostileTxt[204][0] = 0

	Game.HostileTxt[211][205] = 2
	Game.HostileTxt[205][211] = 1

	Game.HostileTxt[211][201] = 2
	Game.HostileTxt[201][211] = 1

	Game.HostileTxt[211][202] = 2
	Game.HostileTxt[202][211] = 1

	Party.QBits[184] = true -- Town portal
	Party.QBits[312] = true	-- TP Buff Misty Islands
	Party.QBits[844] = true	-- DDMapBuff
end

----------------------------------------
-- Dragon tower

--[[
Game.MapEvtLines:RemoveEvent(210)
if not Party.QBits[1181] then

	local function DragonTower()
		StdQuestsFunctions.DragonTower(3039, -9201, 2818, 1181)
	end
	Timer(DragonTower, 5*const.Minute)

	function events.LeaveMap()
		RemoveTimer(DragonTower)
	end

end
]]

Game.MapEvtLines:RemoveEvent(211)
evt.map[211] = function()
	if not Party.QBits[1181] and evt.ForPlayer("All").Cmp{"Inventory", 2106} then
		evt.Set{"QBits", 1181}
		StdQuestsFunctions.SetTextureOutdoors(53, 42, "t1swbu")
	end
end

evt.map[213] = function()
	if Party.QBits[1181] then
		StdQuestsFunctions.SetTextureOutdoors(53, 42, "t1swbu")
	end
end
