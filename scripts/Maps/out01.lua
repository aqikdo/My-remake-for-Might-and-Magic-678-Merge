-- Dagger Wound Island
local MF = Merge.Functions

-- Dimension door
function events.TileSound(t)
	if t.X == 63 and t.Y == 59 then
		TownPortalControls.DimDoorEvent()
	end
end

-- Move [MM8] area one init stuff into AfterLoadMap
Game.MapEvtLines:RemoveEvent(3)

function events.AfterLoadMap()
	if not Party.QBits[226] then	-- game Init stuff in area one
		Party.QBits[226] = true	-- game Init stuff in area one
		Party.QBits[185] = true	-- Blood Drop Town Portal
		Party.QBits[306] = true -- TP Buff Daggerwound Islands
		Party.QBits[401] = true	-- Roster Character In Party 2
		Party.QBits[407] = true	-- Roster Character In Party 8
		MF.QBitAdd(85)	--[[
			"Find Dadeross, the Minotaur in charge of your merchant caravan.
			When you saw him last, he was going to talk to the village clan leader."
			]]
	end
	Party.QBits[801] = true	-- DDMapBuff
end

evt.map[410] = function()
	if Party.QBits[296] and not Party.QBits[297] then
		evt.SetMonGroupBit(15, const.MonsterBits.Invisible, false)
		Party.QBits[297] = true
		Party.QBits[298] = true
		local mon_id = MF.GetNPCMapMonster(53)
		if mon_id then
			Map.Monsters[mon_id].HP = 0
			Map.Monsters[mon_id].AIState = 5
			Map.Monsters[mon_id].AIType = 2
			Map.Monsters[mon_id].GraphicState = 6
		end
	end
end

function events.PickCorpse(t)
	local mon_id = MF.GetNPCMapMonster(53)
	if mon_id and t.MonsterIndex == mon_id then
		t.Allow = false -- bypass default behaivor (do not remove corpse)
	end
end
