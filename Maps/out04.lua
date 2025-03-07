-- Ironsand Desert

local TileSounds = {
[0] = {[0] = 91, 	[1] = 52},
[5] = {[0] = 101, 	[1] = 62},
[6] = {[0] = 90, 	[1] = 51}
}

function events.TileSound(t)
	local Grp = TileSounds[Game.CurrentTileBin[Map.TileMap[t.X][t.Y]].TileSet]
	if Grp then
		t.Sound = Grp[t.Run]
	end
end

function events.AfterLoadMap()
	Party.QBits[804] = true	-- DDMapBuff
end

evt.house[185] = 303  -- "Mystic Medicine"
evt.map[185] = function()
	evt.EnterHouse{Id = 303}         -- "Mystic Medicine"
end

evt.house[186] = 303  -- "Mystic Medicine"
evt.map[186] = function()
end
