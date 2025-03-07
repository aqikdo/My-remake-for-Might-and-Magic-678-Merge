-- The Tularean Forest

function events.AfterLoadMap()
	Party.QBits[719] = true	-- TP Buff Tularean Forest
	Party.QBits[819] = true	-- DDMapBuff
end

-- Dimension door
function events.TileSound(t)
	if t.X == 84 and t.Y == 94 then
		TownPortalControls.DimDoorEvent()
	end
end

evt.map[504] = function()
	TownPortalControls.DimDoorEvent()
end

function events.AfterLoadMap()
	local model
	for i,v in Map.Models do
		if v.Name == "ClL1_W" then
			model = v
		end
	end
	
	if model then
		for i,v in model.Facets do
			v.Event = 504
		end
	end
end

-- Clanker's Laboratory
Game.MapEvtLines:RemoveEvent(503)
evt.map[503] = function()

	if Party.QBits[710] then
		evt.MoveNPC{427, 395}
		Game.Houses[395].ExitMap = 86
		Game.Houses[395].ExitPic = 1
		evt.EnterHouse{395}
	else
		evt.MoveToMap{0,-709,1,512,0,0,395,9,"7d12.blv"}
	end

end

Game.MapEvtLines:RemoveEvent(204)
evt.hint[204] = evt.str[6]
evt.map[204] = function()
	if evt.Cmp("EarthResBonus", 50) then
		evt.StatusText(11)         -- "Refreshing!"
		return
	end
	if not evt.Cmp("AutonotesBits", 13) then         -- "50 points of temporary Earth resistance from the central fountain in Pierpont."
		evt.Add("AutonotesBits", 13)         -- "50 points of temporary Earth resistance from the central fountain in Pierpont."
	end
	evt.Add("EarthResBonus", 50)
	evt.StatusText(70)         -- "+50 Earth Resistance (Temporary)"
end

