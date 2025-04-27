-- Plane of Fire

function events.AfterLoadMap()
	Party.QBits[811] = true	-- DDMapBuff
	if Party.QBits[1720] and evt.All.Cmp("Inventory", 667) then
		Party.QBits[1721] = true
	end
end
