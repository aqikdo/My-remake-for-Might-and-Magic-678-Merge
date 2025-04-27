-- Kriegspire
local MF, MM = Merge.Functions, Merge.ModSettings

local TileSounds = {
[6] = {[0] = 90, 	[1] = 51}
}

function events.TileSound(t)
	local Grp = TileSounds[Game.CurrentTileBin[Map.TileMap[t.X][t.Y]].TileSet]
	if Grp then
		t.Sound = Grp[t.Run]
	end
end

function events.AfterLoadMap()
	Party.QBits[834] = true	-- DDMapBuff
end

----------------------------------------
-- Loretta Fleise's fix prices quest

Game.MapEvtLines:RemoveEvent(8)
evt.house[8] = 477
evt.map[8] = function() StdQuestsFunctions.CheckPrices(477, 1515) end

Game.MapEvtLines:RemoveEvent(9)
evt.house[9] = 477
evt.map[9] = function() StdQuestsFunctions.CheckPrices(477, 1515) end

-- Fix linked fountains
if MF.GtSettingNum(MM.MM6FixLinkedFountains, 0) then
	Game.MapEvtLines:RemoveEvent(103)
	evt.hint[103] = evt.str[6]	-- "Drink from Fountain"
	evt.map[103] = function()
		evt.ForPlayer("Current")
		if evt.Cmp("PlayerBits", 68) then
			evt.Set("Eradicated", 0)
		else
			evt.Set("PlayerBits", 68)
			evt.Add("SpiritResistance", 10)
			evt.Add("MindResistance", 10)
			evt.Set("Eradicated", 0)
			evt.StatusText(7)	-- "+10 Magic resistance permanent."
			evt.Set("AutonotesBits", 436)	-- "10 Points of permanent magic resistance from the fountain north of the Dragon Tower in the town of Kriegspire."
		end
	end
end
