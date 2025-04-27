-- Murmurwoods

function events.AfterLoadMap()
	Party.QBits[807] = true	-- DDMapBuff
	if Party.QBits[1750] then
		evt.SetSprite{-1701, 1, "Dec49"}
	elseif Party.QBits[1751] then
		evt.SetSprite{-1699, 1, "Dec46"}
	elseif Party.QBits[1752] then
		evt.SetSprite{-1700, 1, "Dec48"}
	elseif Party.QBits[1753] then
		evt.SetSprite{-1698, 1, "Dec45"}
	elseif Party.QBits[1754] then
		evt.SetSprite{-1697, 1, "Dec47"}
	else
		evt.SetSprite{-1698, 1, "0"}
		evt.SetSprite{-1699, 1, "0"}
		evt.SetSprite{-1697, 1, "0"}
		evt.SetSprite{-1700, 1, "0"}
		evt.SetSprite{-1701, 1, "0"}
	end
end

-- Dimension door
evt.map[500] = TownPortalControls.DimDoorEvent

function events.TileSound(t)
	if t.X == 43 and t.Y == 98 then
		TownPortalControls.DimDoorEvent()
	end
end

-- Let statues be dispelled without scroll if player have stone-to-flesh spell.

local function SpeakStatueNPC(i)
	local HaveSpell = Party[math.max(Game.CurrentPlayer, 0)].Spells[40]

	evt.ForPlayer("All")
	if evt.Cmp{"Inventory", 339} or HaveSpell then
		if not HaveSpell then
			evt.Subtract{"Inventory", 339}
		end
		evt.SetSprite{i-132+20, 0, "0"}
		evt.SpeakNPC{46}
	end
end

for i = 133, 136 do
	Game.MapEvtLines:RemoveEvent(i)
	evt.Hint[i] = evt.Str[13]
	evt.Map[i] = SpeakStatueNPC
end

Game.MapEvtLines:RemoveEvent(132)
evt.Hint[132] = evt.Str[13]
evt.Map[132] = function()
	local HaveSpell = Party[math.max(Game.CurrentPlayer, 0)].Spells[40]

	evt.ForPlayer("All")
	if evt.Cmp("Inventory", 339) or HaveSpell then
		if not HaveSpell then
			evt.Subtract("Inventory", 339)
		end
		evt.SetSprite(20, 0, "0")
		Party.QBits[39] = false	-- "Find Cauri Blackthorne then return to Dantillion in Murmurwoods with information of her location."
		Party.QBits[40] = true	-- Found and Rescued Cauri Blackthorne
		Party.QBits[430] = true	-- Roster Character In Party 31
		--Game.NPC[42].EventB = 25	-- Cauri Blackthorne : Promotion to Patriarch
		--Game.NPC[42].EventC = 1799	-- Cauri Blackthorne : Promotion to Honorary Patriarch
		--Game.NPC[39].EventD = 1799	-- Relburn Jeebes : Promotion to Honorary Patriarch
		evt.ForPlayer("All")
		evt.Add("Experience", 25000)
		evt.Add("Awards", 20)	-- "Rescued Cauri Blackthorne."
		evt.SpeakNPC(42)
	end
end

-- Gems-exchange tree

local GemsItemTypes = {20,21,22,40,43}

local GemsExchangeTable = {
-- Amber
[180]	= 250,
[2102]	= 250,
-- Amethyst
[181]	= 183,
[2060]	= 183,
-- Citrine
[179]	= 181,
-- Diamond
[997]	= 656,
[994]	= 656,
[186]	= 656,
[2056]	= 656,
-- Emerald
[2064]	= 655,
[990]	= 655,
[183]	= 655,
[2061]	= 655,
-- Lolite
[178]	= 132,
-- Ruby
[998]	= 271,
[2059]	= 271,
[185]	= 271,
-- Sapphire
[2065]	= -2000, -- Gold
[991]	= -2000, -- Gold
[184]	= -2000, -- Gold
-- Topaz
[2058]	= 0, -- Random item
[989]	= 0, -- Random item
[182]	= 0, -- Random item
-- Zircon
[177]	= 179
}

Game.MapEvtLines:RemoveEvent(455)
evt.Hint[455] = evt.Str[40]
evt.Map[455] = function()

	local PlId = Game.CurrentPlayer
	if PlId < 0 then
		return
	end

	local Player = Party[PlId]
	for i,v in Player.Items do
		local Val = GemsExchangeTable[v.Number]
		if Val then
			if Val > 0 then
				evt[PlId].Add{"Inventory", Val}
			elseif Val < 0 then
				evt[PlId].Add{"Gold", -Val}
			else
				Val = GemsItemTypes[math.random(1,#GemsItemTypes)]
				evt[PlId].GiveItem{3,Val,0}
			end
			v.Number = 0
			break
		end
	end

end

evt.Map[420] = function()
	if Party.QBits[1748] and not Party.QBits[1755] then
		evt.SpeakNPC{1233}
	else
		Game.ShowStatusText(" Õâ ÊÇ Ò» ¿Å ³Á Ë¯ µÄ ¹Å Ê÷ ¡£")
	end
end

evt.Map[421] = function()
	if evt.Cmp{"Inventory", 694} and not Party.QBits[1754] then
		Game.ShowStatusText(" Õò Ä§ Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
		evt.SetSprite{-1697, 1, "Dec47"}
		evt.Subtract("Inventory", 694)
		Party.QBits[1754] = true
	elseif Party.QBits[1754] then
		Game.ShowStatusText(" Õò Ä§ Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
	else
		Game.ShowStatusText(" Õâ ÊÇ Ò» ¸ù Õò Ä§ Ö® Öù £¬ µ« Æä Á¦ Á¿ È« Ê§ £¬ ÒÑ ¾­ Ê§ È¥ ÁË ×÷ ÓÃ ¡£")
	end
end

evt.Map[422] = function()
	if evt.Cmp{"Inventory", 698} and not Party.QBits[1753] then
		Game.ShowStatusText(" ´ó µØ Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
		evt.SetSprite{-1698, 1, "Dec45"}
		evt.Subtract("Inventory", 698)
		Party.QBits[1753] = true
	elseif Party.QBits[1753] then
		Game.ShowStatusText(" ´ó µØ Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
	else
		Game.ShowStatusText(" Õâ ÊÇ Ò» ¸ù ´ó µØ Ö® Öù £¬ µ« Æä Á¦ Á¿ È« Ê§ £¬ ÒÑ ¾­ Ê§ È¥ ÁË ×÷ ÓÃ ¡£")
	end
end

evt.Map[423] = function()
	if evt.Cmp{"Inventory", 696} and not Party.QBits[1751] then
		Game.ShowStatusText(" ´ó Æø Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
		evt.SetSprite{-1699, 1, "Dec46"}
		evt.Subtract("Inventory", 696)
		Party.QBits[1751] = true
	elseif Party.QBits[1751] then
		Game.ShowStatusText(" ´ó Æø Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
	else
		Game.ShowStatusText(" Õâ ÊÇ Ò» ¸ù ´ó Æø Ö® Öù £¬ µ« Æä Á¦ Á¿ È« Ê§ £¬ ÒÑ ¾­ Ê§ È¥ ÁË ×÷ ÓÃ ¡£")
	end	
end

evt.Map[424] = function()
	if evt.Cmp{"Inventory", 697} and not Party.QBits[1752] then
		Game.ShowStatusText(" Á÷ Ë® Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
		evt.SetSprite{-1700, 1, "Dec48"}
		evt.Subtract("Inventory", 697)
		Party.QBits[1752] = true
	elseif Party.QBits[1752] then
		Game.ShowStatusText(" Á÷ Ë® Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
	else
		Game.ShowStatusText(" Õâ ÊÇ Ò» ¸ù Á÷ Ë® Ö® Öù £¬ µ« Æä Á¦ Á¿ È« Ê§ £¬ ÒÑ ¾­ Ê§ È¥ ÁË ×÷ ÓÃ ¡£")
	end	
end

evt.Map[425] = function()
	if evt.Cmp{"Inventory", 695} and not Party.QBits[1750] then
		Game.ShowStatusText(" ÁÒ »ð Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
		evt.SetSprite{-1701, 1, "Dec49"}
		evt.Subtract("Inventory", 695)
		Party.QBits[1750] = true
	elseif Party.QBits[1750] then
		Game.ShowStatusText(" ÁÒ »ð Ö® Öù ÖÐ ³ä Ó¯ ×Å Á¦ Á¿ £¡")
	else
		Game.ShowStatusText(" Õâ ÊÇ Ò» ¸ù ÁÒ »ð Ö® Öù £¬ µ« Æä Á¦ Á¿ È« Ê§ £¬ ÒÑ ¾­ Ê§ È¥ ÁË ×÷ ÓÃ ¡£")
	end	
end