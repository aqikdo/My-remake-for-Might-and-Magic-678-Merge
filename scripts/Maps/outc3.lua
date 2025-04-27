-- Mire of the Damned

function events.AfterLoadMap()
	Party.QBits[839] = true	-- DDMapBuff
end

----------------------------------------
-- Loretta Fleise's fix prices quest

Game.MapEvtLines:RemoveEvent(8)
evt.house[8] = 474
evt.map[8] = function() StdQuestsFunctions.CheckPrices(474, 1520) end

Game.MapEvtLines:RemoveEvent(9)
evt.house[9] = 474
evt.map[9] = function() StdQuestsFunctions.CheckPrices(474, 1520) end
