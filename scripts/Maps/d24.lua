-- Balthazar Lair

function events.LoadMap()
	if Party.QBits[23] then
		for i,v in Map.Monsters do
			if v.Group == 0 then -- All tritons have group 0.
				v.AIState = const.AIState.Invisible
			end
		end
	end
end

evt.map[451] = function()
	Party.QBits[303] = true	-- TP Buff Baltazar's Lair
end
