-- Paradise Valley

local TileSounds = {[0] = {[0] = 91, 	[1] = 52}}

function events.TileSound(t)
	local Grp = TileSounds[Game.CurrentTileBin[Map.TileMap[t.X][t.Y]].TileSet]
	if Grp then
		t.Sound = Grp[t.Run]
	end
end

function events.AfterLoadMap()
	Party.QBits[832] = true	-- DDMapBuff
end

evt.hint[217] = evt.str[0]
evt.map[217] = function()
	GotoMap("zdtl02.blv")
end

