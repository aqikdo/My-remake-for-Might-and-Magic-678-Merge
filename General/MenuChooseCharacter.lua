local LogId = "MenuChooseCharacter"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MO, MV = Merge.Functions, Merge.ModSettings, Merge.Offsets, Merge.Vars

local CreateButton, UnloadIcons = CustomUI.CreateButton, CustomUI.UnloadIcons
local min, max = math.min, math.max

local PartySize  = 1
local ActiveChar = 1
local CharButtons = {}
--local RosterIdSpots = {37,38,39,40,41}
local RosterIdSpots = {nil, 36, 37, 38, 39}
local AddChar, RemChar, LClass, RClass

MO.TmpChar = mem.StaticAlloc(Party.PlayersArray[0]["?size"])
local tmp_race

-- additional buttons by majaczek
local InfoBtn

local Size, BasePtr
local OverAction = false

local PortraitsExceptions, ClassesByContinent, RaceByContinent, ClassByRace
local function ProcessChooseCharSettings()

	local SettingsTxt = io.open("Data/Tables/Character selection.txt", "r")

	local ClassInv = {}
	for k,v in pairs(const.Class) do
		ClassInv[v] = k
	end

	local RaceInv = {}
	for k,v in pairs(const.Race) do
		RaceInv[v] = k
	end

	if not SettingsTxt then

		-- Default values

		PortraitsExceptions = {
			-- Jadame
		{28, 29, 30},
			-- Antagarich
		{28, 29, 30},
			-- Enroth
		{28, 29, 30}

		}

		ClassesByContinent = {
			-- Jadame
		{const.Class.ClericLight, const.Class.Deerslayer, const.Class.Knight, const.Class.Minotaur,
			const.Class.Berserker, const.Class.Vampire, const.Class.Necromancer},
			-- Antagarich
		{const.Class.Archer, const.Class.Cleric, const.Class.Deerslayer, const.Class.Druid,
			const.Class.Knight, const.Class.Minotaur, const.Class.Monk, const.Class.Paladin,
			const.Class.Ranger, const.Class.Thief, const.Class.Sorcerer},
			-- Enroth
		{const.Class.Archer, const.Class.Cleric, const.Class.Deerslayer, const.Class.Druid,
			const.Class.Knight, const.Class.Minotaur, const.Class.Paladin, const.Class.Sorcerer}

		}

		RaceByContinent = {
			-- Jadame
		{const.Race.Human, const.Race.VampireHuman, const.Race.DarkElf, const.Race.Minotaur,
			const.Race.Troll},
			-- Antagarich
		{const.Race.Human, const.Race.DarkElf, const.Race.Minotaur},
			-- Enroth
		{const.Race.Human, const.Race.DarkElf, const.Race.Minotaur}

		}

		ClassByRace = {
			-- Human
			[const.Race.Human] = {
				[const.Class.Archer] = true, [const.Class.Cleric] = true,
				[const.Class.ClericLight] = true, [const.Class.Druid] = true,
				[const.Class.Knight] = true, [const.Class.Monk] = true,
				[const.Class.Paladin] = true, [const.Class.Ranger] = true,
				[const.Class.Thief] = true, [const.Class.Sorcerer] = true,
				[const.Class.Necromancer] = true
			},
			-- Vampire
			[const.Race.VampireHuman] = {
				[const.Class.Vampire] = true
			},
			-- Dark elf
			[const.Race.DarkElf] = {
				[const.Class.Archer] = true, [const.Class.Deerslayer] = true,
				[const.Class.Druid] = true, [const.Class.Ranger] = true,
				[const.Class.Thief] = true, [const.Class.Sorcerer] = true
			},
			-- Minotaur
			[const.Race.Minotaur] = {
				[const.Class.Cleric] = true, [const.Class.ClericLight] = true,
				[const.Class.Druid] = true, [const.Class.Knight] = true,
				[const.Class.Minotaur] = true
			},
			-- Troll
			[const.Race.Troll] = {
				[const.Class.Berserker] = true
			},
			-- Dragon
			[const.Race.Dragon] = {
				[const.Class.Dragon] = true
			}

		}

		SettingsTxt = io.open("Data/Tables/Character selection.txt", "w")

		local ContinentNames = {"Jadame", "Antagarich", "Enroth"}

		SettingsTxt:write("Race/Class\9" .. ClassInv[0] .. "\9" .. table.concat(ClassInv, "\9") .. "\n")
		for iR = 0, #ClassByRace do
			local str = RaceInv[iR]
			for iC = 0, #ClassInv do
				str = str .. "\9" .. (ClassByRace[iR][iC] and "x" or "-")
			end
			SettingsTxt:write(str .. "\n")
		end

		SettingsTxt:write("\9Continents:\n")
		local ContinentHeader = "%s\9Portraits exceptions:\9%s\n\9Available classes:\9%s\n\9Available races:\9%s\n"
		for i,v in ipairs(RaceByContinent) do
			SettingsTxt:write(string.format(ContinentHeader,
								ContinentNames[i],
								table.concat(PortraitsExceptions[i], 	"\9"),
								table.concat(ClassesByContinent[i], 	"\9"),
								table.concat(RaceByContinent[i], 		"\9")))
		end

		SettingsTxt:close()

	else

		PortraitsExceptions, ClassesByContinent, RaceByContinent, ClassByRace = {}, {}, {}, {}

		local Counter = 0
		local LineIt = SettingsTxt:lines()
		LineIt() -- skip header

		for line in LineIt do
			if line == "\9Continents:" then
				break
			end

			local Words = string.split(line, "\9")
			local CurRace = tonumber(Words[1]) or const.Race[Words[1]] or Counter

			ClassByRace[CurRace] = {}

			for i = 2, #Words do
				ClassByRace[CurRace][i-2] = Words[i] == "x"
			end
			Counter = Counter + 1
		end

		local Cont = 1
		local TableOrder = {PortraitsExceptions, ClassesByContinent, RaceByContinent}
		Counter = 1
		for line in LineIt do
			local Words = string.split(line, "\9")
			local CurTab = TableOrder[Counter]
			CurTab[Cont] = CurTab[Cont] or {}
			CurTab = CurTab[Cont]

			Counter = Counter + 1

			for i = 3, #Words do
				local CurI = tonumber(Words[i])
				if CurI then
					table.insert(CurTab, CurI)
				end
			end

			if Counter > 3 then
				Counter = 1
				Cont = Cont + 1
			end
		end

		SettingsTxt:close()

	end

end

function events.GameInitialized1()
	ProcessChooseCharSettings()

	Game.CharSelection = {}
	Game.CharSelection.PortraitsExceptions	= PortraitsExceptions
	Game.CharSelection.ClassesByContinent	= ClassesByContinent
	Game.CharSelection.RaceByContinent		= RaceByContinent
	Game.CharSelection.ClassByRace			= ClassByRace
end

function events.GameInitialized2()

	Size, BasePtr = Party.PlayersArray[0]["?size"], Party.PlayersArray[0]["?ptr"]

	MV.PlayersAttrs = MV.PlayersAttrs or {}
	MV.PlayersAttrs[0] = MV.PlayersAttrs[0] or {}

	local function ClassAvailable(Class, Race, Continent)
		return ClassByRace[Race][Class] and table.find(ClassesByContinent[Continent], Class)
	end

	local function SwitchClass(Step)

		local DefClass 	= Game.CharacterPortraits[Party[0].Face].DefClass
		local CurClass 	= Party[0].Class
		local CurCont	= TownPortalControls.GetCurrentSwitch()
		local CurRace	= GetCharRace(Party[0])
		local CurFace	= Party[0].Face

		-- FIXME: HACK
		-- force zombie to undead by majaczek
		if (Merge.Settings.Character.ForceZombieToUndeadRace == 1)
			and (CurRace == const.Race.Zombie) then
			CurRace = const.Race.Undead
			Game.CharacterPortraits[Party[0].Face].Race = CurRace
		end
		-- endof FIXME

		CurClass = CurClass + Step
		if Step == 0 then
			Step = 1
		end

		local cnt = Game.ClassNames.count
		while not ClassAvailable(CurClass, CurRace, CurCont) do
			if CurClass > Game.ClassNames.count then
				CurClass = 0
			elseif CurClass < 0 then
				CurClass = Game.ClassNames.count
			else
				CurClass = CurClass + Step
			end

			cnt = cnt - 1
			if cnt <= 0 then
				CurClass = DefClass
				break
			end
		end

		Party[0].Class = CurClass
		local CurStarSkills = Game.ClassKinds.StartingSkills[math.floor(CurClass/2)]
		for i = 0, Party[0].Skills.count - 1 do
			Party[0].Skills[i] = CurStarSkills[i] == 2 and 1 or 0
		end

		mem.u4[0x51e330] = 1
		OverAction = 462

	end

	function events.CharacterChosen()
		Party[0].Attrs.Race = Game.CharacterPortraits[Party[0].Face].Race
		SwitchClass(0)
	end

	local function SetActive(i, NeedRefresh, IsNew)
		if i == ActiveChar then
			return
		end

		local NameBuffPtr = mem.u4[mem.u4[mem.u4[0x100614c] + 0x128] + 0xC0]
		Party[0].Name = mem.string(NameBuffPtr)

		local char_ptr
		if RosterIdSpots[ActiveChar] then
			MV.PlayersAttrs[RosterIdSpots[ActiveChar]] = MV.PlayersAttrs[RosterIdSpots[ActiveChar]] or {}
			Party.PlayersArray[RosterIdSpots[ActiveChar]].Attrs.Race = Party[0].Attrs.Race
			char_ptr = Party.PlayersArray[RosterIdSpots[ActiveChar]]["?ptr"]
		else
			tmp_race = Party[0].Attrs.Race
			char_ptr = MO.TmpChar
		end
		mem.copy(char_ptr, BasePtr, Size)

		ActiveChar = i
		if not IsNew then
			if RosterIdSpots[ActiveChar] then
				mem.copy(BasePtr, Party.PlayersArray[RosterIdSpots[ActiveChar]]["?ptr"], Size)
				Party[0].Attrs.Race = Party.PlayersArray[RosterIdSpots[ActiveChar]].Attrs.Race
			else
				mem.copy(BasePtr, MO.TmpChar, Size)
				Party[0].Attrs.Race = tmp_race
			end
		end

		for iP = 1, string.len(Party[0].Name) + 1 do
			mem.u1[NameBuffPtr + iP - 1] = string.byte(Party[0].Name, iP) or 0
		end

		if NeedRefresh then
			for iL = 1, 5 do
				if iL ~= i then
					CharButtons[iL].IUpSrc = "SlChar" .. iL .. "U"
					CharButtons[iL].IDwSrc = "SlChar" .. iL .. "D"
				end
			end

			CharButtons[i].IUpSrc, CharButtons[i].IDwSrc = "SlChar" .. i .. "D", "SlChar" .. i .. "U"
			CharButtons[i].IUpPtr, CharButtons[i].IDwPtr = CharButtons[i].IDwPtr, CharButtons[i].IUpPtr

			mem.u4[0x51e330] = 1
			OverAction = 64
		end
	end

	local function PrepareChar(RosterId, PartyId)
		Log(Merge.Log.Info, "MenuChooseCharacter: PrepareChar: RosterId %d, PartyId %d",
			RosterId, PartyId)
		local ItemTypesBySkills	= {	[0]	= 30, 23, 24, 25, 26, 27, 28, 11, 5, 31, 32, 33}
		local ItemsBySkills		= {	[12] = 401, [13] = 412, [14] = 423, [15] = 434, [16] = 445, [17] = 456, [18] = 467, [19] = 478, [20] = 489}

		local Char = Party.PlayersArray[RosterId]
		Char.Experience = 0
		Char.LevelBase = 1

		GenerateBiography(Char)

		Char.BirthYear = math.random(1150, 1154)

		if Merge.Settings.Character.AutolearnRacialSkills == 1 then
			-- Set up Autolearned Racial Skills
			local race = GetCharRace(Char)
			for skill = 0, Char.Skills.count - 1 do
				local race_skill =
					MF.GetRaceSkillTbl({Race = race, Maturity = 0, Class = Char.Class, Skill = skill})
				if race_skill and race_skill.Auto == 1 then
					Char.Skills[skill] = 1
				end
			end
		end

		for i,v in Char.Inventory do
			Char.Inventory[i] = 0
		end

		for i,v in Char.EquippedItems do
			Char.EquippedItems[i] = 0
		end

		evt.ForPlayer(PartyId)

		Game.CurrentPlayer = PartyId
		for i,v in Char.Skills do
			if v > 0 then
				if ItemTypesBySkills[i] then
					evt.GiveItem{1,ItemTypesBySkills[i],0}
					Mouse.Item.Bonus = 0
					Mouse.Item.BonusStrength = 0
				elseif ItemsBySkills[i] then
					evt.GiveItem{1,0,ItemsBySkills[i]}
					Mouse.Item.Bonus = 0
					Mouse.Item.BonusStrength = 0
				else
					evt.GiveItem{2,11,0}
					if Mouse.Item.Bonus > 0 then
						Mouse.Item.BonusStrength = math.random(1,5)
					end
				end
			end
		end
		evt.GiveItem{1,16,0}
		evt.GiveItem{1,45,0}
		evt.GiveItem{1,0,220}
		evt.GiveItem{1,45,0}
		Mouse.Item.Number = 0
		Game.CurrentPlayer = 0

		for i = 0, 10 do
			Char.Resistances[i].Base = 0
		end

		local spellbook_page
		-- set basic spells
		for i = 0, 8 do
			local CurS, CurM = SplitSkill(Char.Skills[i+12])
			for iL = 1 + i*11, CurS + i*11 do
				spellbook_page = spellbook_page or i
				Char.Spells[iL] = true
			end
		end
		-- set basic racial "spells"
		for i = 9, 11 do
			local CurS, CurM = SplitSkill(Char.Skills[i+12])
			for iL = 1 + i*11, CurM + i*11 do
				spellbook_page = spellbook_page or i
				Char.Spells[iL] = true
			end
		end
		Char.SpellBookPage = spellbook_page or 0

		for i,v in Char.Items do
			v.Identified = true
		end

		Char.HP = Char:GetFullHP()
		Char.SP = Char:GetFullSP()

		if MF.GtSettingNum(MM.InitialSkillPoints, 0) then
			Char.SkillPoints = MM.InitialSkillPoints
		end
		if MF.GtSettingNum(MM.InitialExperience, 0) then
			Char.Experience = MM.InitialExperience
		end
	end

	LClass = CreateButton{
		IconUp	 	= "SlClassLU",
		IconDown	= "SlClassLD",
		Screen		= 21,
		Layer		= 1,
		DynLoad = true,
		X		=	65,
		Y		=	99,
		Action	= function() SwitchClass(1) end
	}

	RClass = CreateButton{
		IconUp	 	= "SlClassRU",
		IconDown	= "SlClassRD",
		Screen		= 21,
		Layer		= 1,
		DynLoad = true,
		X		=	83,
		Y		=	99,
		Action	= function() SwitchClass(-1) end
	}

	AddChar = CreateButton{
		IconUp	 	= "SlCharAddU",
		IconDown	= "SlCharAddD",
		Screen		= 21,
		Layer		= 1,
		DynLoad = true,
		X		=	51,
		Y		=	437,
		Action	=	function()
							if PartySize < 5 then
								PartySize = PartySize + 1
								SetActive(PartySize, true, true)
								OverAction = 171
							end
						end
	}

	RemChar = CreateButton{
		IconUp	 	= "SlCharRemU",
		IconDown	= "SlCharRemD",
		Screen		= 21,
		Layer		= 1,
		DynLoad = true,
		X		=	72,
		Y		=	437,
		Action	=	function() PartySize = max(PartySize - 1, 1)
							if ActiveChar > PartySize then
								SetActive(PartySize, true)
							end
						end
	}

	
	-- additional buttons by majaczek
	InfoBtn = CreateButton{
		IconUp	 	= "ib-m2d-b",
		IconDown	= "ib-m2d-c",
		Screen		= 21,
		Layer		= 1,
		DynLoad = true,
		X		=	8,
		Y		=	440,
		Action	=	function() 	-- local DefClass 	= Game.CharacterPortraits[Party[0].Face].DefClass
								local CurClass 	= Party[0].Class
								-- local CurCont	= TownPortalControls.GetCurrentSwitch()
								local CurRace	= GetCharRace(Party[0])
								local CurFace	= Party[0].Face
								local CurVoice = Party[0].Voice
								
								MessageBox("Info: Class = " .. CurClass .. ", race = " .. CurRace
									.. ", Face = " .. CurFace .. ", Voice=" .. CurVoice)
						end
	}
	
	for i = 1, 5 do
		CharButtons[i] = CreateButton{
			IconUp	 	= "SlChar" .. i .. (i == 1 and "D" or "U"),
			IconDown	= "SlChar" .. i .. (i == 1 and "U" or "D"),
			Screen		= 21,
			Layer		= 1,
			DynLoad = true,
			X		=	58 + i*40,
			Y		=	439,
			Action	=	function() SetActive(i, true) end,
			Condition 	= function() return PartySize > i - 1 end
		}
	end

	function events.MenuAction(t)
		if OverAction then
			t.Action = OverAction
			OverAction = false
			return
		end
		if t.Action == 5 then
			PartySize  = 1
			ActiveChar = 1
		elseif t.Action == 66 then
			SetActive(1, false)
		elseif t.Action == 65 then
			local CurCont = TownPortalControls.GetCurrentSwitch()
			for i,v in Game.CharacterPortraits do
				v.AvailableAtStart = (table.find(RaceByContinent[CurCont], v.Race) ~= nil and
											not table.find(PortraitsExceptions[CurCont], i)) and 1 or 0
			end
		end
	end

	events.AddFirst("NewGameMap", function()
		Log(Merge.Log.Info, "%s: NewGameMap", LogId)
		MV.NewGame = true
		--UnloadIcons(21)
		Game.CurrentScreen = 0

		if RosterIdSpots[1] then
			Party.PlayersArray[RosterIdSpots[1]].RosterBitIndex = 400 + RosterIdSpots[1]
		end
		PrepareChar(0, 0)
		for i = 1, 4 do
			local CurChar = RosterIdSpots[i+1]
			Party.PlayersArray[CurChar].RosterBitIndex = 400 + CurChar
			if PartySize > i then
				Party.PlayersIndexes[i] = CurChar
				PrepareChar(CurChar, i)
				Party.QBits[400 + CurChar] = true
			else
				Party.PlayersIndexes[i] = -1
			end
		end

		Party.count = PartySize
		PartySize  = 1
		ActiveChar = 1
		CharButtons[1].IUpSrc = "SlChar1D"
		CharButtons[1].IDWSrc = "SlChar1U"
		for iL = 2, 5 do
			CharButtons[iL].IUpSrc = "SlChar" .. iL .. "U"
			CharButtons[iL].IDWSrc = "SlChar" .. iL .. "D"
		end
	end)

end

Log(Merge.Log.Info, "Init finished: %s", LogId)

