local LogId = "StdQuestsFollowers"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM = Merge.Functions, Merge.ModSettings

local TXT = {
	npc_follow = Game.NPCText[2793],	-- "Follow"
	npc_goodbye = Game.NPCText[2794],	-- "Good bye!"
	sharry_home = Game.NPCText[2795]	-- "It's good to be back home again. Thank you for rescuing me from these horrible ruffians!"
}

-----------------------------------------
-- Witness to the lake of fire's formation (MM8)
Quest{
	Name = "OverduneFollow1",
	NPC = 7,
	Slot = 1,
	Branch = "",
	CanShow = function()
		return Party.QBits[63] and not Party.QBits[59] and not MF.NPCInGroup(7)
	end,
	Ungive = function()
		MF.NPCFollowerAdd(7)
		ExitCurrentScreen(true)
	end,
	Texts = {
		Topic = TXT.npc_follow
	}
}
Quest{
	Name = "OverduneFollow2",
	NPC = 7,
	Slot = 1,
	Branch = "",
	CanShow = function()
		return Party.QBits[59] and MF.NPCInGroup(7)
	end,
	Ungive = function()
		MF.NPCFollowerRemove(7)
		Game.NPC[7].House = 752
		ExitCurrentScreen()
	end,
	Texts = {
		Topic = TXT.npc_goodbye
	}
}

-----------------------------------------
-- Dyson Le[y]land's revenge (MM8)
Quest{
	Name = "DysonFollow1",
	NPC = 11,
	Slot = 2,
	Branch = "",
	CanShow = function()
		return Party.QBits[89] and Party.QBits[90]
			and (Party.QBits[26] or Party.QBits[28]) and not MF.NPCInGroup(11)
	end,
	Ungive = function()
		MF.NPCFollowerAdd(11)
		ExitCurrentScreen(true)
	end,
	Texts = {
		Topic = TXT.npc_follow
	}
}
Quest{
	Name = "DysonFollow2",
	NPC = 11,
	Slot = 2,
	Branch = "",
	CanShow = function()
		return (Party.QBits[19] or Party.QBits[20]) and MF.NPCInGroup(11)
	end,
	Ungive = function()
		MF.NPCFollowerRemove(11)
		Party.QBits[433] = true
		ExitCurrentScreen()
	end,
	Texts = {
		Topic = TXT.npc_goodbye
	}
}

-----------------------------------------
-- Rescue dwarfs quest (mm7)

evt.Global[858] = function()
	if Party.QBits[610] then
		for i = 399, 405 do
			NPCFollowers.Remove(i)
		end
		NPCFollowers.Rebuild()
	end
end

for i = 0, 6 do
	evt.Global[859+i] = function()
		NPCFollowers.Add(399+i)
	end
end

-----------------------------------------
-- Rescue Loren Steel quest (mm7)

local RemoveLoren = function()
	if not Party.QBits[1695] then
		NPCFollowers.Remove(410) -- Loren
	end
	if not Party.QBits[1696] then
		NPCFollowers.Remove(411) -- fake Loren
	end
end
evt.Global[875] = RemoveLoren
evt.Global[876] = RemoveLoren
evt.Global[885] = RemoveLoren
evt.Global[886] = RemoveLoren

evt.Global[884] = function()
	if Party.QBits[1696] then
		NPCFollowers.Add(411)
	end
end -- Loren rescue part is in 7d08.lua

-----------------------------------------
-- Choose Judge quest (mm7)

evt.Global[891] = function()
	NPCFollowers.Remove(416)
	NPCFollowers.Add(417)
end

evt.Global[893] = function()
	NPCFollowers.Remove(417)
	NPCFollowers.Add(416)
end

-----------------------------------------
-- Rescue Angela Dowson quest (mm6)

evt.Global[1642] = function()
	NPCFollowers.Remove(980)
end

-----------------------------------------
-- Rescue Melody Silver quest (paladin promotion) (mm6)

evt.Global[1344] = function()
	NPCFollowers.Add(796)
end

evt.Global[1327] = function()
	if not Party.QBits[1699] then
		NPCFollowers.Remove(796)
	end
end

-----------------------------------------
-- Nicolai's quest (mm6)

local function KidnapNicolai()
	NPCFollowers.Remove(798)
	Party.QBits[1114] = false
	Party.QBits[1700] = false

	evt.MoveNPC{798, 1595}
	evt.Add{"QBits", 1119}
	evt.SetNPCTopic{798, 0, 1334}

	Game.ShowStatusText(Game.NPCText[1720], 5)
	RemoveTimer(KidnapNicolai)
end

function events.AfterLoadMap()
	if Party.QBits[1114] and NPCFollowers.NPCInGroup(798) then
		Timer(KidnapNicolai, 256*5, Game.Time + 256*60)
	end
end

Game.GlobalEvtLines:RemoveEvent(1331)
evt.Global[1331] = function()
	Timer(KidnapNicolai, 256*5, Game.Time + 256*60)
	NPCFollowers.Add(798)

	evt.MoveNPC{798, 0}
	evt.Add{"QBits", 1114}
	evt.Add{"QBits", 1700}
	evt.SetMessage{1718}
	evt.SetNPCTopic{798, 0, 1332}
end

evt.Global[1333] = function()
	NPCFollowers.Remove(798)
end

evt.Global[1334] = function()
	NPCFollowers.Add(798)
end -- Other part is in outd3.lua

-----------------------------------------
-- The Prince of thieves quest (mm6)

evt.Global[1346] = function()
	if not Party.QBits[1701] then
		NPCFollowers.Remove(802)
	end
end -- Other part is in sewer.lua

-----------------------------------------
-- Rescue Emmanuel quest (mm6)

evt.Global[1631] = function()
	if not Party.QBits[1702] then
		NPCFollowers.Remove(893)
	end
end

evt.Global[1634] = function()
	NPCFollowers.Add(893)
end -- Other part is in 6t8.lua

-----------------------------------------
-- Rescue Sherry Carnegie quest (mm6)

Game.GlobalEvtLines:RemoveEvent(1638)
evt.Global[1638] = function()
	if NPCFollowers.NPCInGroup(978) then
		evt.SetMessage(2038)	--[[
			"Thank you so much for saving Sharry!  I can’t tell you how much this means
			to both New Sorpigal and myself.  You have our gratitude forever."
			]]
		Party.QBits[1703] = false	-- Replacement for NPCs 193 ver. 6
		Party.QBits[1162] = false	-- "Rescue Sharry from the Shadow Guild Hideout and return with her to Frank Fairchild in New Sorpigal."
		evt.Add("Gold", 2000)
		Party.QBits[1284] = true
		evt.ForPlayer("All")
		evt.Add("Awards", 90)	-- "Rescued Sharry"
		evt.Add("Experience", 10000)
		NPCFollowers.Remove(978)
		if MM.MM6SettleSharry and MM.MM6SettleSharry == 1 then
			evt.MoveNPC(978, 1339)
		end
		evt.SetNPCTopic(788, 0, 0)	-- "Frank Fairchild"
	else
		evt.SetMessage(2037)	-- "Have you found Sharry yet?  No?  I’m sure she’s wherever the Shadow Guild is hiding out.  Find them and you’ll find her."
	end
end

Game.GlobalEvtLines:RemoveEvent(1640)
evt.Global[1640] = function()
	if Party.QBits[1284] then
		Message(TXT.sharry_home)
	else
		evt.SetMessage(2040)	-- "Thank you for rescuing me from these horrible ruffians!  I’d like to go back home to New Sorpigal now."
	end
end -- Other part is in 6d03.lua

-----------------------------------------
-- Rescue Sherell Ivanoveh quest (mm6)

evt.Global[1645] = function()
	if not Party.QBits[1705] then
		NPCFollowers.Remove(940)
	end
end

evt.Global[1646] = function()
	NPCFollowers.Add(940)
end -- Other part is in 6t3.lua

Log(Merge.Log.Info, "Init finished: %s", LogId)

