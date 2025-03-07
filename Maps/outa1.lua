-- Sweet Water

function events.AfterLoadMap()
	Party.QBits[831] = true	-- DDMapBuff
end

evt.hint[213] = evt.str[0]
evt.map[213] = function()
	local fl = 1
	for i = 1355, 1361 do
		if evt.CheckItemsCount(i,i,1) == false then
			fl = 0
		end
	end
	if fl == 1 and vars.FindTreasure == nil then
		vars.FindTreasure = true
		Sleep(10)
		Message("Digging under the tree, you found something.")
		evt.GiveItem(1,1,1362)
		evt.GiveItem(1,1,1363)
	end
end
