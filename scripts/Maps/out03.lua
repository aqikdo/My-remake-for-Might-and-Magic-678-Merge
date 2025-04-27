-- Alvar

function events.AfterLoadMap()
	Party.QBits[803] = true	-- DDMapBuff
end

evt.map[104] = function()
	Party.QBits[301] = true	-- TP Buff Alvar
end
