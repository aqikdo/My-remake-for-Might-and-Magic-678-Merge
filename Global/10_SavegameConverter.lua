-- Converter from old savegames
local LogId = "SavegameConverter"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MV = Merge.Functions, Merge.ModSettings, Merge.Vars
local floor = math.floor

local function abits_shift_l(to_bit, delta)
	for i = to_bit, delta + 1, -1 do
		Party.AutonotesBits[i] = Party.AutonotesBits[i - delta]
	end
end

local function convert_0_20040100()
	if vars.SaveGameFormatVersion == nil or (tonumber(vars.SaveGameFormatVersion)
			and tonumber(vars.SaveGameFormatVersion) < 20040100) then
		-- Note: do not use const.Class, const.Race, const.Alignment here
		local class_table = {
			[0] = 0, -- Archer
			[1] = 1, -- WarriorMage
			[2] = 4, -- MasterArcher
			[3] = 6, -- Sniper
			[4] = 8, -- Cleric
			[5] = 9, -- Priest
			[6] = 16, -- PriestLight
			[7] = 18, -- PriestDark
			[8] = 21, -- DarkElf
			[9] = 22, -- Patriach
			[10] = 29, -- Dragon
			[11] = 30, -- GreatWyrm
			[12] = 36, -- Druid
			[13] = 37, -- GreatDruid
			[14] = 42, -- Warlock
			[15] = 40, -- ArchDruid
			[16] = 44, -- Knight
			[17] = 45, -- Cavalier
			[18] = 50, -- BlackKnight
			[19] = 48, -- Champion
			[20] = 53, -- Minotaur
			[21] = 54, -- MinotaurLord
			[22] = 60, -- Monk
			[23] = 61, -- Initiate
			[24] = 64, -- Master
			[25] = 66, -- Ninja
			[26] = 68, -- Paladin
			[27] = 69, -- Crusader
			[28] = 72, -- Hero
			[29] = 74, -- Villain
			[30] = 76, -- Ranger
			[31] = 77, -- Hunter
			[32] = 82, -- BountyHunter
			[33] = 80, -- RangerLord
			[34] = 84, -- Thief
			[35] = 85, -- Rogue
			[36] = 90, -- Assassin
			[37] = 88, -- Spy
			[38] = 93, -- Troll/Berserker
			[39] = 94, -- WarTroll/Warmonger
			[40] = 101, -- Vampire
			[41] = 102, -- Nosferatu
			[42] = 108, -- Sorcerer
			[43] = 109, -- Wizard
			[44] = 113, -- Necromancer
			[45] = 118, -- Lich
			[46] = 116, -- ArchMage
			[47] = 118, -- nuAM/MasterNecromancer - Lich
			[48] = 120, -- Peasant
			[49] = 121, -- nuPeas, shouldn't appear
			[50] = 14, -- HighPriest
			[51] = 114 -- MasterWizard
		}

		local neutral, good, evil = 4, 0, 8

		local class_alignments = {
			[0] = neutral,
			[1] = neutral,
			[2] = good,
			[3] = evil,
			[4] = neutral,
			[5] = neutral,
			[6] = good,
			[7] = evil,
			[8] = neutral,
			[9] = neutral,
			[10] = neutral,
			[11] = neutral,
			[12] = neutral,
			[13] = neutral,
			[14] = evil,
			[15] = good,
			[16] = neutral,
			[17] = neutral,
			[18] = evil,
			[19] = good,
			[20] = neutral,
			[21] = neutral,
			[22] = neutral,
			[23] = neutral,
			[24] = good,
			[25] = evil,
			[26] = neutral,
			[27] = neutral,
			[28] = good,
			[29] = evil,
			[30] = neutral,
			[31] = neutral,
			[32] = evil,
			[33] = good,
			[34] = neutral,
			[35] = neutral,
			[36] = evil,
			[37] = good,
			[38] = neutral,
			[39] = neutral,
			[40] = neutral,
			[41] = neutral,
			[42] = neutral,
			[43] = neutral,
			[44] = evil,
			[45] = evil,
			[46] = good,
			[47] = evil,
			[48] = neutral,
			[49] = neutral,
			[50] = neutral,
			[51] = neutral
		}

		local face_races = {
			[0] = 0, -- Human
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0,
			[8] = 0,
			[9] = 0,
			[10] = 0,
			[11] = 0,
			[12] = 4, -- VampireHuman
			[13] = 4, -- VampireHuman
			[14] = 4, -- VampireHuman
			[15] = 4, -- VampireHuman
			[16] = 10, -- DarkElf
			[17] = 10, -- DarkElf
			[18] = 10, -- DarkElf
			[19] = 10, -- DarkElf
			[20] = 20, -- Minotaur
			[21] = 20, -- Minotaur
			[22] = 30, -- Troll
			[23] = 30, -- Troll
			[24] = 40, -- Dragon
			[25] = 40, -- Dragon
			[26] = 2, -- UndeadHuman
			[27] = 2, -- UndeadHuman
			[31] = 50, -- Elf
			[32] = 50, -- Elf
			[33] = 50, -- Elf
			[34] = 50, -- Elf
			[35] = 0, -- Human
			[36] = 0,
			[37] = 0,
			[38] = 0,
			[39] = 0,
			[40] = 0,
			[41] = 0,
			[42] = 0,
			[43] = 0,
			[44] = 0,
			[45] = 0,
			[46] = 0,
			[47] = 0,
			[48] = 0,
			[49] = 0,
			[50] = 0,
			[51] = 0,
			[52] = 0,
			[53] = 0,
			[54] = 0,
			[55] = 60, -- Goblin
			[56] = 60, -- Goblin
			[57] = 60, -- Goblin
			[58] = 60, -- Goblin
			[59] = 6, -- ZombieHuman
			[60] = 6, -- ZombieHuman
			[61] = 70, -- Dwarf
			[62] = 70, -- Dwarf
			[63] = 70, -- Dwarf
			[64] = 70, -- Dwarf
			[65] = 72, -- UndeadDwarf
			[66] = 72, -- UndeadDwarf
			[67] = 42, -- UndeadDragon
			[68] = 48, -- GhostDragon
			[69] = 22, -- UndeadMinotaur
			[70] = 26, -- ZombieMinotaur
			[71] = 40, -- Dragon
			[72] = 76, -- ZombieDwarf
			[73] = 76 -- ZombieDwarf
		}

		MV.PlayersAttrs = MV.PlayersAttrs or {}

		for idx = 0, Party.PlayersArray.count - 1 do
			local pl = Party.PlayersArray[idx]
			MV.PlayersAttrs[idx] = MV.PlayersAttrs[idx] or {}
			--pl.Attrs = MV.PlayersAttrs[idx]
			if pl.Class < 0 or pl.Class > 51 then
				Log(Merge.Log.Error, "Invalid player character %d class: %d", idx, pl.Class)
			else
				-- set alignment
				MV.PlayersAttrs[idx].Alignment = class_alignments[pl.Class]

				-- convert class
				pl.Class = class_table[pl.Class]

				-- convert/set race
				-- check for original face of zombified character
				if (face_races[pl.Face] % 10 == 6) and vars.PlayerFaces
						and vars.PlayerFaces[idx] then
					MV.PlayersAttrs[idx].Race = face_races[vars.PlayerFaces[idx].Face]
				else
					MV.PlayersAttrs[idx].Race = face_races[pl.Face]
				end
			end
		end

		vars.SaveGameFormatVersion = 20040100
		Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
			LogId, vars.SaveGameFormatVersion)
	end
end

local function convert_8_20040100()
	if vars == nil or vars.SaveGameFormatVersion == nil then
		-- Note: do not use const.Class, const.Race, const.Alignment here
		local class_table = {
			[0] = 113, -- Necromancer
			[1] = 118, -- Lich
			[2] = 11, -- ClericLight
			[3] = 16, -- PriestLight
			[4] = 44, -- Knight
			[5] = 48, -- Champion
			[6] = 93, -- Troll/Berserker
			[7] = 94, -- WarTroll/Warmonger
			[8] = 53, -- Minotaur
			[9] = 54, -- MinotaurLord
			[10] = 21, -- DarkElf
			[11] = 22, -- Patriach
			[12] = 101, -- Vampire
			[13] = 102, -- Nosferatu
			[14] = 29, -- Dragon
			[15] = 30 -- GreatWyrm
		}

		local neutral, good, evil = 4, 0, 8

		local class_alignments = {
			[0] = evil,
			[1] = evil,
			[2] = good,
			[3] = good,
			[4] = neutral,
			[5] = neutral,
			[6] = neutral,
			[7] = neutral,
			[8] = neutral,
			[9] = neutral,
			[10] = neutral,
			[11] = neutral,
			[12] = neutral,
			[13] = neutral,
			[14] = neutral,
			[15] = neutral
		}

		local face_races = {
			[0] = 0, -- Human
			[1] = 0,
			[2] = 0,
			[3] = 0,
			[4] = 0,
			[5] = 0,
			[6] = 0,
			[7] = 0,
			[8] = 0,
			[9] = 0,
			[10] = 0,
			[11] = 0,
			[12] = 4, -- VampireHuman
			[13] = 4, -- VampireHuman
			[14] = 4, -- VampireHuman
			[15] = 4, -- VampireHuman
			[16] = 10, -- DarkElf
			[17] = 10, -- DarkElf
			[18] = 10, -- DarkElf
			[19] = 10, -- DarkElf
			[20] = 20, -- Minotaur
			[21] = 20, -- Minotaur
			[22] = 30, -- Troll
			[23] = 30, -- Troll
			[24] = 40, -- Dragon
			[25] = 40, -- Dragon
			[26] = 2, -- UndeadHuman
			[27] = 2, -- UndeadHuman
		}

		MV.PlayersAttrs = MV.PlayersAttrs or {}

		for idx = 0, Party.PlayersArray.count - 1 do
			local pl = Party.PlayersArray[idx]
			MV.PlayersAttrs[idx] = MV.PlayersAttrs[idx] or {}
			--pl.Attrs = MV.PlayersAttrs[idx]
			if pl.Class < 0 or pl.Class > 15 then
				Log(Merge.Log.Error, "Invalid player character %d class: %d", idx, pl.Class)
			else
				-- set alignment
				MV.PlayersAttrs[idx].Alignment = class_alignments[pl.Class]

				-- convert class
				pl.Class = class_table[pl.Class]

				-- convert/set race
				MV.PlayersAttrs[idx].Race = face_races[pl.Face]
			end
		end

		vars.SaveGameFormatVersion = 20040100
		Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
			LogId, vars.SaveGameFormatVersion)
	end
end

local function convert_20040100_20050900()
	local function OldSplitSkill(val)
		local n = val % 0x40
		local mast
		if val >= 0x100 then
			mast = 4
		elseif val >= 0x80 then
			mast = 3
		elseif val >= 0x40 then
			mast = 2
		elseif val >= 1 then
			mast = 1
		else
			mast = 0
		end
		return n, mast
	end

	for idx = 0, Party.PlayersArray.count - 1 do
		local pl = Party.PlayersArray[idx]
		for k, v in pl.Skills do
			if v > 63 then
				pl.Skills[k] = JoinSkill(OldSplitSkill(v))
			end
		end
	end
	vars.SaveGameFormatVersion = 20050900
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

local function convert_20050900_20090100()
	-- Set up QBits
	-- Minotaur
	Party.QBits[77] = Party.QBits[87]
	-- Knight
	Party.QBits[71] = Party.QBits[1540] or Party.QBits[1541]
	-- Dragon
	Party.QBits[86] = Party.QBits[1543] or Party.QBits[1544]
	-- Berserker
	Party.QBits[87] = Party.QBits[1538] or Party.QBits[1539]
	-- Cleric
	Party.QBits[79] = Party.QBits[1546]
	if not Party.QBits[79] then
		Party.QBits[79] = MF.RosterHasAward(31)
	end
	-- Necromancer
	Party.QBits[83] = Party.QBits[1548]
	if not Party.QBits[83] then
		Party.QBits[83] = MF.RosterHasAward(35)
	end
	-- Vampire
	Party.QBits[88] = Party.QBits[1547]
	if not Party.QBits[88] then
		Party.QBits[88] = MF.RosterHasAward(33)
	end

	-- Set up NPC Topics
	-- Cleric
	if Party.QBits[79] then
		Game.NPC[59].EventA = 737	-- Stephen : Promote Clerics
		Game.NPC[59].EventB = 1798	-- Stephen : Promotion to Honorary Priest of the Light
		Game.NPC[59].EventC = 0	-- remove "Quest" topic
		Game.NPC[59].EventD = 0	-- remove "Prophecies of the Sun" topic
		Game.NPC[59].EventE = 0	-- remove "Clues" topic
	end
	-- Dark Elf
	if Party.QBits[40] then
		Game.NPC[42].EventA = 38	-- Cauri Blackthorne : Thanks for your help!
		Game.NPC[42].EventB = 25	-- Cauri Blackthorne : Promotion to Patriarch
		Game.NPC[42].EventC = 1799	-- Cauri Blackthorne : Promotion to Honorary Patriarch
		Game.NPC[39].EventD = 1799	-- Relburn Jeebes : Promotion to Honorary Patriarch
	end
	-- Dragon
	if Party.QBits[86] then
		Game.NPC[17].EventD = 1800	-- Deftclaw Redreaver : Promotion to Honorary Great Wyrm
		Game.NPC[53].EventD = 1800	-- Deftclaw Redreaver : Promotion to Honorary Great Wyrm
	end
	-- Knight
	if Party.QBits[71] then
		Game.NPC[15].EventD = 1801	-- Sir Charles Quixote : Promotion to Honorary Champion
		Game.NPC[52].EventD = 1801	-- Sir Charles Quixote : Promotion to Honorary Champion
	end
	-- Minotaur
	if Party.QBits[77] then
		Game.NPC[58].EventB = 1802	-- Tessalar : Promotion to Honorary Minotaur Lord
		Game.NPC[58].EventC = 70	-- Tessalar : Dark Dwarves
	end
	-- Berserker
	if Party.QBits[87] then
		Game.NPC[43].EventA = 612	-- Volog Sandwind : Roster Join Event
		Game.NPC[43].EventB = 1803	-- Volog Sandwind : Promotion to Warmonger
		Game.NPC[43].EventC = 1804	-- Volog Sandwind : Promotion to Honorary Warmonger
		Game.NPC[67].EventB = 1804	-- Hobb Sandwind : Promotion to Honorary Warmonger
	end
	-- Vampire
	if Party.QBits[88] then
		Game.NPC[62].EventA = 739	-- Lathean : Promote Vampires
		Game.NPC[62].EventB = 1805	-- Lathean : Promotion to Honorary Nosferatu
	end
	-- Necromancer
	if Party.QBits[83] then
		Game.NPC[61].EventB = 89	-- Vetrinus Taleshire : Promotion to Lich
		Game.NPC[61].EventC = 1796	-- Vetrinus Taleshire : Promotion to Master Necromancer
		Game.NPC[61].EventD = 1797	-- Vetrinus Taleshire : Promotion to Honorary Lich
	elseif Party.QBits[82] then
		Game.NPC[61].EventA = 1795	-- Vetrinus Taleshire : The Lost Book of Khel
	end

	vars.SaveGameFormatVersion = 20090100
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

local function convert_20090100_20113000()
	-- Set Dimension Door Map Buffs
	--   Check map AutonotesBits
	Party.QBits[801] = Party.AutonotesBits[206] or Party.AutonotesBits[207]
		or Party.AutonotesBits[208] or Party.AutonotesBits[209]
	Party.QBits[802] = Party.AutonotesBits[210] or Party.AutonotesBits[211]
	Party.QBits[803] = Party.AutonotesBits[212] or Party.AutonotesBits[213]
		or Party.AutonotesBits[214]
	Party.QBits[804] = Party.AutonotesBits[215] or Party.AutonotesBits[216]
	Party.QBits[805] = Party.AutonotesBits[217] or Party.AutonotesBits[218]
		or Party.AutonotesBits[219]
	Party.QBits[806] = Party.AutonotesBits[220] or Party.AutonotesBits[221]
		or Party.AutonotesBits[222]
	--   Note: AutonotesBits[226] should be set in out08 but was set in out07
	Party.QBits[807] = Party.AutonotesBits[224] --or Party.AutonotesBits[226]
	Party.QBits[809] = Party.AutonotesBits[229]
	Party.QBits[810] = Party.AutonotesBits[228]
	Party.QBits[811] = Party.AutonotesBits[231]
	Party.QBits[812] = Party.AutonotesBits[230]
	Party.QBits[813] = Party.AutonotesBits[232]

	Party.QBits[816] = Party.AutonotesBits[258] or Party.AutonotesBits[259]
		or Party.AutonotesBits[260]
	Party.QBits[817] = Party.AutonotesBits[262]
	Party.QBits[818] = Party.AutonotesBits[263] or Party.AutonotesBits[264]
		or Party.AutonotesBits[265] or Party.AutonotesBits[266]
		or Party.AutonotesBits[267] or Party.AutonotesBits[268]
	Party.QBits[819] = Party.AutonotesBits[269]
	Party.QBits[820] = Party.AutonotesBits[270] or Party.AutonotesBits[271]

	Party.QBits[831] = Party.AutonotesBits[441]
	Party.QBits[832] = Party.AutonotesBits[440]
	Party.QBits[833] = Party.AutonotesBits[439]
	Party.QBits[834] = Party.AutonotesBits[434] or Party.AutonotesBits[435]
		or Party.AutonotesBits[436] or Party.AutonotesBits[437]
		or Party.AutonotesBits[438]
	Party.QBits[835] = Party.AutonotesBits[429] or Party.AutonotesBits[430]
		or Party.AutonotesBits[431] or Party.AutonotesBits[432]
		or Party.AutonotesBits[433]
	Party.QBits[836] = Party.AutonotesBits[426] or Party.AutonotesBits[427]
		or Party.AutonotesBits[428]
	Party.QBits[837] = Party.AutonotesBits[420] or Party.AutonotesBits[421]
		or Party.AutonotesBits[422] or Party.AutonotesBits[423]
		or Party.AutonotesBits[424] or Party.AutonotesBits[425]
	Party.QBits[838] = Party.AutonotesBits[418] or Party.AutonotesBits[419]
	Party.QBits[839] = Party.AutonotesBits[417]
	Party.QBits[840] = Party.AutonotesBits[413] or Party.AutonotesBits[414]
		or Party.AutonotesBits[415] or Party.AutonotesBits[416]
	Party.QBits[841] = Party.AutonotesBits[400] or Party.AutonotesBits[410]
		or Party.AutonotesBits[411] or Party.AutonotesBits[412]
	Party.QBits[842] = Party.AutonotesBits[407] or Party.AutonotesBits[408]
		or Party.AutonotesBits[409]
	Party.QBits[843] = Party.AutonotesBits[405] or Party.AutonotesBits[406]
	Party.QBits[844] = Party.AutonotesBits[401] or Party.AutonotesBits[402]
		or Party.AutonotesBits[403] or Party.AutonotesBits[404]
	Party.QBits[845] = Party.AutonotesBits[391] or Party.AutonotesBits[392]
		or Party.AutonotesBits[393]

	--   Check map QBits
	Party.QBits[801] = Party.QBits[801] or Party.QBits[1] or Party.QBits[2]
		or Party.QBits[186] or Party.QBits[226] or Party.QBits[227]
		or Party.QBits[268] or Party.QBits[269] or Party.QBits[270]
		or Party.QBits[271]
	Party.QBits[802] = Party.QBits[802] or Party.QBits[45] or Party.QBits[46]
		or Party.QBits[57] or Party.QBits[58] or Party.QBits[93]
		or Party.QBits[187] or Party.QBits[209] or Party.QBits[228]
		or Party.QBits[272] or Party.QBits[273] or Party.QBits[274]
		or Party.QBits[286]
	Party.QBits[803] = Party.QBits[803] or Party.QBits[13] or Party.QBits[14]
		or Party.QBits[15] or Party.QBits[16] or Party.QBits[17]
		or Party.QBits[18] or Party.QBits[59] or Party.QBits[188]
		or Party.QBits[275] or Party.QBits[276]
	Party.QBits[804] = Party.QBits[804] or Party.QBits[60] or Party.QBits[189]
		or Party.QBits[277] or Party.QBits[278]
	Party.QBits[805] = Party.QBits[805] or Party.QBits[75] or Party.QBits[190]
		or Party.QBits[200]
	Party.QBits[806] = Party.QBits[806] or Party.QBits[191] or Party.QBits[279]
		or Party.QBits[280] or Party.QBits[281]
	Party.QBits[807] = Party.QBits[807] or Party.QBits[40] or Party.QBits[192]
	Party.QBits[808] = Party.QBits[808] or Party.QBits[168] or Party.QBits[193]
	Party.QBits[809] = Party.QBits[809] or Party.QBits[207] or Party.QBits[243]
	Party.QBits[810] = Party.QBits[810] or Party.QBits[208] or Party.QBits[244]
	Party.QBits[811] = Party.QBits[811] or Party.QBits[205] or Party.QBits[242]
	Party.QBits[812] = Party.QBits[812] or Party.QBits[206] or Party.QBits[241]
	Party.QBits[813] = Party.QBits[813] or Party.QBits[37] or Party.QBits[194]
		or Party.QBits[285]
	Party.QBits[814] = Party.QBits[814] or Party.QBits[94] or Party.QBits[95]
		or Party.QBits[96] or Party.QBits[97]

	Party.QBits[816] = Party.QBits[816] or Party.QBits[513] or Party.QBits[514]
		or Party.QBits[515] or Party.QBits[516] or Party.QBits[517]
		or Party.QBits[518]
	Party.QBits[817] = Party.QBits[817] or Party.QBits[587] or Party.QBits[611]
		or Party.QBits[612] or Party.QBits[644] or Party.QBits[645]
		or Party.QBits[646] or Party.QBits[648] or Party.QBits[663]
		or Party.QBits[664] or Party.QBits[665] or Party.QBits[676]
		or Party.QBits[693] or Party.QBits[697] or Party.QBits[760]
		or Party.QBits[774] or Party.QBits[779] or Party.QBits[780]
		or Party.QBits[781]
	Party.QBits[818] = Party.QBits[818] or Party.QBits[569] or Party.QBits[677]
		or Party.QBits[700]
	Party.QBits[819] = Party.QBits[819] or Party.QBits[591] or Party.QBits[649]
		or Party.QBits[678]
	Party.QBits[820] = Party.QBits[820] or Party.QBits[679] or Party.QBits[708]
		or Party.QBits[735] or Party.QBits[736]
	Party.QBits[821] = Party.QBits[821] or Party.QBits[680] or Party.QBits[701]
		or Party.QBits[715]
	Party.QBits[824] = Party.QBits[824] or Party.QBits[563] or Party.QBits[683]
		or Party.QBits[690]
	Party.QBits[825] = Party.QBits[825] or Party.QBits[684]
	Party.QBits[826] = Party.QBits[826] or Party.QBits[685] or Party.QBits[737]
	Party.QBits[827] = Party.QBits[827] or Party.QBits[686] or Party.QBits[758]
		or Party.QBits[775]
	Party.QBits[828] = Party.QBits[828] or Party.QBits[564] or Party.QBits[687]
		or Party.QBits[714] or Party.QBits[733]
	Party.QBits[829] = Party.QBits[829] or Party.QBits[565] or Party.QBits[688]
		or Party.QBits[713] or Party.QBits[734]

	Party.QBits[831] = Party.QBits[831] or Party.QBits[1246] or Party.QBits[1384]
	Party.QBits[832] = Party.QBits[832] or Party.QBits[1385]
	Party.QBits[833] = Party.QBits[833] or Party.QBits[1386]
	Party.QBits[834] = Party.QBits[834] or Party.QBits[1238] or Party.QBits[1240]
		or Party.QBits[1247] or Party.QBits[1387]
	Party.QBits[835] = Party.QBits[835] or Party.QBits[1184] or Party.QBits[1206]
		or Party.QBits[1242] or Party.QBits[1251] or Party.QBits[1328]
		or Party.QBits[1388]
	Party.QBits[836] = Party.QBits[836] or Party.QBits[1248] or Party.QBits[1389]
		or Party.QBits[1399]
	Party.QBits[837] = Party.QBits[837] or Party.QBits[1185] or Party.QBits[1234]
		or Party.QBits[1390]
	Party.QBits[838] = Party.QBits[838] or Party.QBits[1130] or Party.QBits[1132]
		or Party.QBits[1183] or Party.QBits[1202] or Party.QBits[1235]
		or Party.QBits[1391]
	Party.QBits[839] = Party.QBits[839] or Party.QBits[1236] or Party.QBits[1249]
		or Party.QBits[1392]
	Party.QBits[840] = Party.QBits[840] or Party.QBits[1182] or Party.QBits[1203]
		or Party.QBits[1233] or Party.QBits[1334] or Party.QBits[1335]
		or Party.QBits[1336] or Party.QBits[1393]
	Party.QBits[841] = Party.QBits[841] or Party.QBits[1231] or Party.QBits[1250]
		or Party.QBits[1260] or Party.QBits[1394]
	Party.QBits[842] = Party.QBits[842] or Party.QBits[1220] or Party.QBits[1239]
		or Party.QBits[1327] or Party.QBits[1329] or Party.QBits[1395]
	Party.QBits[843] = Party.QBits[843] or Party.QBits[1241] or Party.QBits[1396]
	Party.QBits[844] = Party.QBits[844] or Party.QBits[1181] or Party.QBits[1232]
		or Party.QBits[1397]
	Party.QBits[845] = Party.QBits[845] or Party.QBits[1104] or Party.QBits[1105]
		or Party.QBits[1180] or Party.QBits[1237] or Party.QBits[1324]
		or Party.QBits[1326] or Party.QBits[1337] or Party.QBits[1398]

	-- Remove vars.ObeliskBits if present
	if vars.ObeliskBits then
		vars.ObeliskBits = nil
	end

	-- Set Escaton's Riddles Autonotes
	Party.AutonotesBits[1] = false
	Party.AutonotesBits[2] = false
	Party.AutonotesBits[3] = false
	Party.AutonotesBits[4] = false
	Party.AutonotesBits[5] = false
	Party.AutonotesBits[6] = false
	Party.AutonotesBits[7] = false
	if Party.QBits[97] then
		Party.AutonotesBits[4] = true
	elseif Party.QBits[94] then
		if Party.QBits[95] then
			Party.AutonotesBits[2] = true
		elseif Party.QBits[96] then
			Party.AutonotesBits[3] = true
		else
			Party.AutonotesBits[1] = true
		end
	elseif Party.QBits[95] then
		if Party.QBits[96] then
			Party.AutonotesBits[6] = true
		else
			Party.AutonotesBits[5] = true
		end
	elseif Party.QBits[96] then
		Party.AutonotesBits[7] = true
	end

	vars.SaveGameFormatVersion = 20113000
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

local function convert_20113000_21040400()
	for idx = 0, Party.PlayersArray.count - 1 do
		local pl = Party.PlayersArray[idx]
		MV.PlayersAttrs[idx] = MV.PlayersAttrs[idx] or {}

		-- set alignment
		if MV.PlayersAttrs[idx].Alignment then
			if MV.PlayersAttrs[idx].Alignment == 4 then
				MV.PlayersAttrs[idx].Alignment = 5
			elseif MV.PlayersAttrs[idx].Alignment == 8 then
				MV.PlayersAttrs[idx].Alignment = 10
			end
		else
			--MV.PlayersAttrs[idx].Alignment = class_alignments[pl.Class]
		end

		-- convert race
		if MV.PlayersAttrs[idx].Race then
			local race = floor(MV.PlayersAttrs[idx].Race / 2)
			local maturity = MV.PlayersAttrs[idx].Race % 2
			MV.PlayersAttrs[idx].Race = race
			MV.PlayersAttrs[idx].Maturity = maturity
		end
	end

	if vars.GlobalReputation then
		local r1, r2, r3 = vars.GlobalReputation[1], vars.GlobalReputation[2], vars.GlobalReputation[3]
		vars.GlobalReputation = {
			Worlds = {[1] = 0},
			Continents = {[1] = r1, [2] = r2, [3] = r3}
		}
	end

	-- Allow to clear pilgrimage qbit if pilgrimage was taken not in this month
	if Party.QBits[1230] then
		if not vars.LastPiligrimage then
			vars.CanClearPilgrimage = not Party.QBits[1231 + Game.Month]
		elseif (vars.LastPiligrimage.Year
				and vars.LastPiligrimage.Year ~= Game.Year
				or vars.LastPiligrimage.MonthlyQuestTaken
				and not vars.LastPiligrimage.MonthlyQuestTaken[Game.Month]) then
			vars.CanClearPilgrimage = true
		end
	end
	vars.LastPiligrimage = nil

	-- MM6 Crusader Promotion Quest
	Party.QBits[1269] = Party.QBits[1635] or Party.QBits[1636]
	-- MM6 Hero Promotion Quest
	Party.QBits[1270] = Party.QBits[1637] or Party.QBits[1638]
	-- MM6 Wizard Promotion Quest
	Party.QBits[1271] = Party.QBits[1639] or Party.QBits[1640]
	-- MM6 Master Wizard Promotion Quest
	Party.QBits[1272] = Party.QBits[1641] or Party.QBits[1642]
	-- MM6 Cavalier Promotion Quest
	Party.QBits[1273] = Party.QBits[1643] or Party.QBits[1644]
	-- MM6 Champion Promotion Quest
	Party.QBits[1274] = Party.QBits[1645] or Party.QBits[1646]
	-- MM6 Priest Promotion Quest
	Party.QBits[1275] = Party.QBits[1647] or Party.QBits[1648]
	-- MM6 High Priest Promotion Quest
	Party.QBits[1276] = Party.QBits[1649] or Party.QBits[1650]
	-- MM6 Great Druid Promotion Quest
	Party.QBits[1277] = Party.QBits[1651] or Party.QBits[1652]
	-- MM6 Arch Druid Promotion Quest
	Party.QBits[1278] = Party.QBits[1653] or Party.QBits[1654]
	-- MM6 Warrior Mage Promotion Quest
	Party.QBits[1279] = Party.QBits[1655] or Party.QBits[1656]
	-- MM6 Battle Mage Promotion Quest
	Party.QBits[1280] = Party.QBits[1657] or Party.QBits[1658]

	-- Ankh
	Party.QBits[1281] = Game.NPC[801].EventC == 1676
	Party.QBits[1282] = Game.NPC[801].EventC == 1677
	Game.NPC[799].EventC = 0
	Game.NPC[801].EventC = 0
	-- Pearl of Purity
	Game.NPC[789].EventC = 0
	-- Nomination
	Party.QBits[1283] = Game.NPC[791].EventB == 1382 or Party.QBits[1273]
	-- Resqued Sharry
	Party.QBits[1284] = MF.RosterHasAward(90)
	if Party.QBits[1284] and MM.MM6SettleSharry and MM.MM6SettleSharry == 1 then
		evt.MoveNPC(978, 1339)
	end

	vars.SaveGameFormatVersion = 21040400
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

local function convert_21040400_21072000()
	-- Elgar Fellmoon
	if Party.QBits[59] and Game.NPC[40].House > 0 then
		MF.NPCCopy(40, 3)
		Game.NPC[40].House = 0
	end
	-- Sir Charles Quixote
	if Party.QBits[21] and Game.NPC[52].House > 0 then
		MF.NPCCopy(52, 15)
		Game.NPC[52].House = 0
		if Game.NPC[15].EventA == 0 then
			Game.NPC[15].EventA = 116
		end
	end
	Game.NPC[15].EventB = 0
	Game.NPC[15].EventC = 0
	Game.NPC[15].EventD = 0
	-- Deftclaw Redreaver
	if Party.QBits[22] and Game.NPC[53].House > 0 then
		MF.NPCCopy(53, 17)
		Game.NPC[53].House = 0
	end
	Game.NPC[17].EventB = 0
	Game.NPC[17].EventC = 0
	Game.NPC[17].EventD = 0
	-- Oskar Tyre
	if Party.QBits[20] and Game.NPC[54].House > 0 then
		MF.NPCCopy(54, 33)
		Game.NPC[54].House = 0
	end
	-- Masul
	if Party.QBits[23] and Game.NPC[55].House > 0 then
		MF.NPCCopy(55, 13)
		Game.NPC[55].House = 0
	end
	-- Sandro
	if Party.QBits[19] and Game.NPC[56].House > 0 then
		MF.NPCCopy(56, 9)
		Game.NPC[56].House = 0
	end
	-- Relburn Jeebes
	Game.NPC[39].EventD = 0
	-- Dartin Dunewalker
	MF.NPCRestore(40)
	-- Cauri Blackthorne
	Game.NPC[42].EventB = 0
	Game.NPC[42].EventC = 0
	-- Volog Sandwind
	if not Party.QBits[87] then
		Game.NPC[43].EventA = 34
	end
	Game.NPC[43].EventB = 0
	Game.NPC[43].EventC = 0
	-- Tessalar
	Game.NPC[58].EventB = 70
	Game.NPC[58].EventC = 0
	-- Stephen
	Game.NPC[59].EventA = 76
	Game.NPC[59].EventC = 0
	Game.NPC[59].EventD = 0
	Game.NPC[59].EventE = 0
	-- Vetrinus Taleshire
	if not Party.QBits[83] then
		Game.NPC[61].EventA = 0
	end
	Game.NPC[61].EventB = 0
	Game.NPC[61].EventC = 0
	Game.NPC[61].EventD = 0
	-- Lathean
	Game.NPC[62].EventA = 82
	Game.NPC[62].EventC = 738
	-- Hobb Sandwind
	Game.NPC[67].EventB = 0

	vars.SaveGameFormatVersion = 21072000
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

local function convert_21072000_21101000()
	abits_shift_l(696, 4)
	-- Garret Deverro
	Game.NPC[51].EventA = 0
	Game.NPC[51].EventB = 735
	if Game.NPC[51].House ~= 753 then
		Game.NPC[51].House = 562
	end
	-- Bazalath
	Game.NPC[255].House = 572
	-- William Lasker
	Game.NPC[354].EventC = 0
	Game.NPC[354].EventD = 0

	-- MM7 Rogue Promo
	Party.QBits[785] = Party.QBits[1560] or Party.QBits[1561]
	-- MM7 Spy Promo
	Party.QBits[786] = Party.QBits[1562] or Party.QBits[1563]
	-- MM7 Assassin Promo
	Party.QBits[787] = Party.QBits[1564] or Party.QBits[1565]
	-- MM7 Crusader Promo
	Party.QBits[788] = Party.QBits[1590] or Party.QBits[1591]
	-- MM7 Hero Promo
	Party.QBits[789] = Party.QBits[1592] or Party.QBits[1593]
	-- MM7 Villain Promo
	Party.QBits[790] = Party.QBits[1594] or Party.QBits[1595]
	-- MM7 Initiate Monk Promo
	Party.QBits[791] = Party.QBits[1572] or Party.QBits[1573]
	-- MM7 Master Monk Promo
	Party.QBits[792] = Party.QBits[1574] or Party.QBits[1575]
	-- MM7 Ninja Promo
	Party.QBits[793] = Party.QBits[1576] or Party.QBits[1577]
	-- MM7 Warrior Mage Promo
	Party.QBits[794] = Party.QBits[1584] or Party.QBits[1585]
	-- MM7 Master Archer Promo
	Party.QBits[795] = Party.QBits[1586] or Party.QBits[1587]
	-- MM7 Sniper Promo
	Party.QBits[796] = Party.QBits[1588] or Party.QBits[1589]
	-- MM7 Cavalier Promo
	Party.QBits[797] = Party.QBits[1566] or Party.QBits[1567]
	-- MM7 Templar Promo
	Party.QBits[798] = Party.QBits[1568] or Party.QBits[1569]
	-- MM7 Black Knight Promo
	Party.QBits[799] = Party.QBits[1570] or Party.QBits[1571]
	-- MM7 Hunter Promo
	Party.QBits[1001] = Party.QBits[1578] or Party.QBits[1579]
	-- MM7 Ranger Lord Promo
	Party.QBits[1002] = Party.QBits[1580] or Party.QBits[1581]
	-- MM7 Bounty Hunter Promo
	Party.QBits[1003] = Party.QBits[1582] or Party.QBits[1583]
	-- MM7 Priest Promo
	Party.QBits[1004] = Party.QBits[1607] or Party.QBits[1608]
	-- MM7 Priest of the Light Promo
	Party.QBits[1005] = Party.QBits[1609] or Party.QBits[1610]
	-- MM7 Priest of the Dark Promo
	Party.QBits[1006] = Party.QBits[1611] or Party.QBits[1612]
	-- MM7 Wizard Promo
	Party.QBits[1007] = Party.QBits[1619] or Party.QBits[1620]
	-- MM7 Arch Mage Promo
	Party.QBits[1008] = Party.QBits[1621] or Party.QBits[1622]
	-- MM7 Master Necromancer Promo
	Party.QBits[1009] = Party.QBits[1623] or Party.QBits[1624]
	-- MM7 Great Druid Promo
	Party.QBits[1010] = Party.QBits[1613] or Party.QBits[1614]
	-- MM7 Arch Druid Promo
	Party.QBits[1011] = Party.QBits[1615] or Party.QBits[1616]
	-- MM7 Warlock Promo
	Party.QBits[1012] = Party.QBits[1617] or Party.QBits[1618]

	vars.SaveGameFormatVersion = 21101000
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

local function convert_21101000_21121800()
	abits_shift_l(696, 12)
	vars.GlobalReputation.Maps = vars.GlobalReputation.Maps or {}
	-- MM6 Arena Master
	MF.NPCRestore(1225)
	-- TPBuff
	if MV.Continent == 1 then
		Party.QBits[301] = Party.QBits[181]
		Party.QBits[302] = Party.QBits[180]
		Party.QBits[303] = Party.QBits[184]
		Party.QBits[304] = Party.QBits[183]
		Party.QBits[305] = Party.QBits[182]
		Party.QBits[306] = Party.QBits[185]
	elseif MV.Continent == 2 then
		Party.QBits[718] = Party.QBits[181]
		Party.QBits[719] = Party.QBits[180]
		Party.QBits[720] = Party.QBits[184]
		Party.QBits[721] = Party.QBits[183]
		Party.QBits[722] = Party.QBits[182]
		Party.QBits[723] = Party.QBits[185]
	elseif MV.Continent == 3 then
		Party.QBits[310] = Party.QBits[181]
		Party.QBits[311] = Party.QBits[180]
		Party.QBits[312] = Party.QBits[184]
		Party.QBits[313] = Party.QBits[183]
		Party.QBits[314] = Party.QBits[182]
		Party.QBits[315] = Party.QBits[185]
	end
	-- Hired NPCs
	vars.HiredNPC = {}
	for k, v in pairs(vars.NPCFollowers) do
		local npc = Game.NPC[v]
		for i = 0, 5 do
			if npc.Events[i] == 1512 or npc.Events[i] == 1511 then
				table.insert(vars.HiredNPC, v)
				vars.NPCFollowers[k] = nil
				break
			end
		end
	end
	for i = #vars.NPCFollowers, 1, -1 do
		if vars.NPCFollowers[i] == nil then
			table.remove(vars.NPCFollowers, i)
		end
	end
	-- Quest NPCs
	MF.NPCRestore(32)
	MF.NPCRestore(52)
	MF.NPCRestore(53)
	MF.NPCRestore(54)
	MF.NPCRestore(55)
	MF.NPCRestore(56)
	MF.NPCRestore(1226)

	vars.SaveGameFormatVersion = 21121800
	Log(Merge.Log.Warning, "%s: savegame converted to SaveGameFormatVersion %d.",
		LogId, vars.SaveGameFormatVersion)
end

function events.BeforeLoadMap(WasInGame)
	if not WasInGame then
		Log(Merge.Log.Info, "%s: BeforeLoadMap", LogId)
		vars.SaveGameFormatVersion = vars.SaveGameFormatVersion and tonumber(vars.SaveGameFormatVersion)
		if vars.SaveGameFormatVersion == nil then
			Log(Merge.Log.Info, "%s: vars.SaveGameFormatVersion isn't set.", LogId)
			local max_class_id = 0
			for idx = 0, Party.PlayersArray.count - 1 do
				local player = Party.PlayersArray[idx]
				if player.Class and player.Class > max_class_id then
					max_class_id = player.Class
				end
			end
			if max_class_id < 16 then
				Log(Merge.Log.Warning,
					"%s: maximum class is %d, convert vanilla savegame.",
					LogId, max_class_id)
				convert_8_20040100()
			elseif max_class_id < 52 then
				Log(Merge.Log.Warning,
					"%s: maximum class is %d, convert savegame.",
					LogId, max_class_id)
				convert_0_20040100()
			else
				-- Looks like new game start time can be bigger than 138240
				if Game.Time <= 138245 then
					Log(Merge.Log.Warning,
						"%s: New game autosave, maximum class is %d, don't convert.",
						LogId, max_class_id)
					return
				end
			end
		elseif vars.SaveGameFormatVersion == 20050900 then
			Log(Merge.Log.Warning,
				"%s: SaveGameFormatVersion is %d.",
				LogId, vars.SaveGameFormatVersion)
		elseif vars.SaveGameFormatVersion < 20040100 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_0_20040100()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 20050900 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_20040100_20050900()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 20090100 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_20050900_20090100()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 20113000 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_20090100_20113000()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 21040400 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_20113000_21040400()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 21072000 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_21040400_21072000()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 21101000 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_21072000_21101000()
		end
		if vars.SaveGameFormatVersion and vars.SaveGameFormatVersion < 21121800 then
			Log(Merge.Log.Warning,
				"%s: convert savegame from SaveGameFormatVersion %d.",
				LogId, vars.SaveGameFormatVersion)
			convert_21101000_21121800()
		end
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
