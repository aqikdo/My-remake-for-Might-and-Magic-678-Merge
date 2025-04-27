-- Race-related stuff except for const.Race
Log(Merge.Log.Info, "Init started: Races.lua")

-- Get Character's Race by his Race Attr or by his Face
function GetCharRace(Char)
	if Char == nil then
		Log(Merge.Log.Error, "GetCharRace: nil Character")
		return false
	end
	return Char.Attrs and Char.Attrs.Race or Game.CharacterPortraits[Char.Face].Race
end

local function ProcessRacesTxt()
	Game.RaceMaturityMax = 1
	local mature_variants = Game.RaceMaturityMax + 1

	local TXTMatureNames = {
		[0] = nil,
		[1] = "Mature"
	}

	local BaseRaceKinds = {
		[const.Race.Human] = const.RaceKind.Human,
		[const.Race.DarkElf] = const.RaceKind.Elf,
		[const.Race.Minotaur] = const.RaceKind.Minotaur,
		[const.Race.Troll] = const.RaceKind.Troll,
		[const.Race.Dragon] = const.RaceKind.Dragon,
		[const.Race.Elf] = const.RaceKind.Elf,
		[const.Race.Goblin] = const.RaceKind.Goblin,
		[const.Race.Dwarf] = const.RaceKind.Dwarf
	}

	-- Default Race Names*, can be overridden/localized in Data/Tables/Races.txt
	local TXTRaceNames = {
		[const.Race.Human]	= "Human",
		[const.Race.DarkElf]	= "Dark Elf",
		[const.Race.Minotaur]	= "Minotaur",
		[const.Race.Troll]	= "Troll",
		[const.Race.Dragon]	= "Dragon",
		[const.Race.Elf]	= "Elf",
		[const.Race.Goblin]	= "Goblin",
		[const.Race.Dwarf]	= "Dwarf"
	}

	local TXTFamilyNames = {
		[const.RaceFamily.None]		= nil,
		[const.RaceFamily.Undead]	= "Undead",
		[const.RaceFamily.Vampire]	= "Vampire",
		[const.RaceFamily.Zombie]	= "Zombie",
		[const.RaceFamily.Ghost]	= "Ghost"
	}

	local TXTRaceNamesPlural = {
		[const.Race.Human]	= "Humans",
		[const.Race.DarkElf]	= "Dark Elves",
		[const.Race.Minotaur]	= "Minotaurs",
		[const.Race.Troll]	= "Trolls",
		[const.Race.Dragon]	= "Dragons",
		[const.Race.Elf]	= "Elves",
		[const.Race.Goblin]	= "Goblins",
		[const.Race.Dwarf]	= "Dwarves"
	}

	local TXTFamilyNamesPlural = {
		[const.RaceFamily.None]		= nil,
		[const.RaceFamily.Undead]	= "Undead",
		[const.RaceFamily.Vampire]	= "Vampires",
		[const.RaceFamily.Zombie]	= "Zombies",
		[const.RaceFamily.Ghost]	= "Ghosts"
	}

	local TXTRaceNamesAdj = {
		[const.Race.Human]	= "Human",
		[const.Race.DarkElf]	= "Dark Elven",
		[const.Race.Minotaur]	= "Minotaur",
		[const.Race.Troll]	= "Troll",
		[const.Race.Dragon]	= "Dragon",
		[const.Race.Elf]	= "Elven",
		[const.Race.Goblin]	= "Goblin",
		[const.Race.Dwarf]	= "Dwarven"
	}

	local TXTFamilyNameAdj = {
		[const.RaceFamily.None]		= nil,
		[const.RaceFamily.Undead]	= "Undead",
		[const.RaceFamily.Vampire]	= "Vampire",
		[const.RaceFamily.Zombie]	= "Zombie",
		[const.RaceFamily.Ghost]	= "Ghost"
	}

	local race_kinds_count = 0

	for k, v in pairs(const.RaceKind) do
		race_kinds_count = race_kinds_count + 1
	end

	Game.RaceKindsCount = race_kinds_count

	local race_families_count = 0

	for k, v in pairs(const.RaceFamily) do
		race_families_count = race_families_count + 1
	end

	Game.RaceFamiliesCount = race_families_count

	-- Amount of variants per base race
	--   Should be equal to number of families
	local race_variants = Game.RaceFamiliesCount

	local Races = {}
	local races_count = 0

	-- Set Race Names to const.Race key by default
	for k, v in pairs(const.Race) do
		Races[v] = {}
		Races[v].Id = v
		Races[v].StringId = k
		Races[v].BaseRace = v - (v % race_variants)
		Races[v].Family = v % race_variants
		if v % race_variants == 0 then
			Races[v].Kind = BaseRaceKinds[Races[v].BaseRace]
		else
			-- We have only Undead race variants yet
			--   Extend when new variants will be added
			Races[v].Kind = const.RaceKind.Undead
		end
		Races[v].Name =
			TXTRaceNames[Races[v].BaseRace] and
			((TXTFamilyNames[Races[v].Family] and TXTFamilyNames[Races[v].Family] .. " " or "")
			.. TXTRaceNames[Races[v].BaseRace]) or k
		Races[v].Plural =
			TXTRaceNamesPlural[Races[v].BaseRace] and
			((TXTFamilyNames[Races[v].Family] and TXTFamilyNames[Races[v].Family] .. " " or "")
			.. TXTRaceNamesPlural[Races[v].BaseRace]) or k
		Races[v].Adj =
			TXTRaceNamesAdj[Races[v].BaseRace] and
			((TXTFamilyNames[Races[v].Family] and TXTFamilyNames[Races[v].Family] .. " " or "")
			.. TXTRaceNamesAdj[Races[v].BaseRace]) or k
		races_count = races_count + 1
	end

	Game.RacesCount = races_count

	local TxtTable = io.open("Data/Tables/Races.txt", "r")
	local header = "#\9StringId\9BaseRace\9Family\9Kind\9Name\9Plural\9Adjective"

	if not TxtTable then
		Log(Merge.Log.Warning, "No Races.txt found, creating one.")
		TxtTable = io.open("Data/Tables/Races.txt", "w")
		TxtTable:write(header .. "\n")
		for k, v in pairs(Races) do
			TxtTable:write(string.format("%d\9%s\9%d\9%d\9%d\9%s\9%s\9%s\n", k, v.StringId, v.BaseRace, v.Family, v.Kind, v.Name, v.Plural, v.Adj))
		end
	else
		local LineIt = TxtTable:lines()
		if LineIt() ~= header then
			Log(Merge.Log.Error, "Races.txt header differs from expected one, table is ignored. Regenerate or fix it.")
			return false
		end

		for line in LineIt do
			local Words = string.split(line, "\9")
			if string.len(Words[1]) == 0 then
				break
			end
			if Words[1] and tonumber(Words[1]) then
				local race = tonumber(Words[1])
				-- We won't take StringId from TxtTable so skip Words[2]
				local baserace = tonumber(Words[3])
				if baserace and baserace >= 0 and baserace <= Game.RacesCount then
					Races[race].BaseRace = baserace
				end
				local racefamily = tonumber(Words[4])
				if racefamily and racefamily >= 0 and racefamily <= Game.RaceFamiliesCount then
					Races[race].Family = racefamily
				end
				local racekind = tonumber(Words[5])
				if racekind and racekind >= 0 and racekind <= Game.RaceKindsCount then
					Races[race].Kind = racekind
				end
				Races[race].Name = Words[6] or Races[race].Name
				Races[race].Plural = Words[7] or Races[race].Name
				Races[race].Adj = Words[8] or Races[race].Adj
			end
		end
	end

	io.close(TxtTable)

	-- MM7 MMExtension has Game.Races which isn't present in
	--   MM8/Merge MMExtension, so using this name should be safe
	Game.Races = Races
end

function events.GameInitialized1()
	ProcessRacesTxt()
end

Log(Merge.Log.Info, "Init finished: Races.lua")
