-- Shadowspire

function events.AfterLoadMap()
	Party.QBits[806] = true	-- DDMapBuff
	if Party.QBits[294] then
		evt.SetSprite(12, 1, "OrMatt1")
	end
end

GroundTex = "gdtyl"
GroundTex = Game.BitmapsLod:LoadBitmap(GroundTex)
Game.BitmapsLod.Bitmaps[GroundTex]:LoadBitmapPalette()

LocalFile(Game.TileBin)
for i = 1, 12 do
	if string.sub(Game.TileBin[i].Name, 1, 4) == "dirt" then
		Game.TileBin[i].Bitmap = GroundTex
	end
end

local TileSounds = {
[5] = {[0] = 101, 	[1] = 62}
}

function events.TileSound(t)
	local Grp = TileSounds[Game.CurrentTileBin[Map.TileMap[t.X][t.Y]].TileSet]
	if Grp then
		t.Sound = Grp[t.Run]
	end
end

evt.map[104] = function()
	Party.QBits[305] = true	-- TP Buff Shadowspire
end

evt.map[410] = function()
	if Party.QBits[293] and not Party.QBits[294] and evt.All.Cmp("Inventory", 668) then
		Party.QBits[294] = true
		evt.SetSprite(12, 1, "OrMatt1")
	end
end
