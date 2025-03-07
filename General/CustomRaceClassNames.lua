-- Custom Race/Class Names

Log(Merge.Log.Info, "Init started: CustomRaceClassNames.lua")

local TXT = Localize{
	BiographyFmt0 = "%s - %s",
	BiographyFmt1 = "%s  Ò» Î» %s %s",
	BiographyFmt2 = "%s  Ò» Î» %s (%s)"
}

local MF, MV = Merge.Functions, Merge.Vars
local asmpatch, hook = mem.asmpatch, mem.hook
local strformat, strgsub, strlen = string.format, string.gsub, string.len

local function ProcessCustomRaceClassNamesTxt()
	local CustomRaceClassNames = {}

	local result = false

	local TxtTable = io.open("Data/Tables/CustomRaceClassNames.txt", "r")

	if not TxtTable then
		Log(Merge.Log.Warning, "No CustomRaceClassNames.txt found, creating one.")
		TxtTable = io.open("Data/Tables/CustomRaceClassNames.txt", "w")
		TxtTable:write("#\9Continent\9RaceKind\9RaceFamily\9Race\9Alignment\9ClassKind\9ClassStep\9Class\9RaceName\9RacePlural\9RaceAdj\9ClassName\n")
	else
		local LineIt = TxtTable:lines()
		local header = LineIt()
		if header ~= "#\9Continent\9RaceKind\9RaceFamily\9Race\9Alignment\9ClassKind\9ClassStep\9Class\9RaceName\9RacePlural\9RaceAdj\9ClassName" then
			Log(Merge.Log.Error, "CustomRaceClassNames.txt header differs from expected one, table is ignored. Regenerate or fix it.")
		else
			result = 0
			local linenum = 1
			for line in LineIt do
				linenum = linenum + 1
				local Words = string.split(line, "\9")
				if strlen(Words[1]) == 0 then
					Log(Merge.Log.Warning, "CustomRaceClassNames.txt line %d first field is empty. Skipping following lines.", linenum)
					break
				end
				-- Ignore lines that don't start with number
				if Words[1] and tonumber(Words[1]) then
					-- Also ignore lines that have either less than 11 or more than 13 columns
					if #Words > 10 and #Words < 14 then
						local CustomName = {}
						CustomName.ContinentId = tonumber(Words[2])
						CustomName.RaceKindId = tonumber(Words[3])
						CustomName.RaceFamilyId = tonumber(Words[4])
						CustomName.RaceId = tonumber(Words[5])
						CustomName.AlignmentId = tonumber(Words[6])
						CustomName.ClassKindId = tonumber(Words[7])
						CustomName.ClassStepId = tonumber(Words[8])
						CustomName.ClassId = tonumber(Words[9])
						CustomName.RaceName = Words[10]
						CustomName.RacePlural = Words[11]
						CustomName.RaceAdj = Words[12]
						CustomName.ClassName = Words[13]
						table.insert(CustomRaceClassNames, CustomName)
						result = result + 1
					else
						Log(Merge.Log.Warning, "CustomRaceClassNames.txt line %d has %d columns. Ignoring line.", linenum, #Words)
					end
				else
					Log(Merge.Log.Warning, "CustomRaceClassNames.txt line %d first field is not a number. Ignoring line.", linenum)
				end
			end
		end
	end

	io.close(TxtTable)
	Game.CustomRaceClassNames = CustomRaceClassNames
	return result
end

local function EvaluateMacros(Str, Params)
	Str = strgsub(Str, "{RN}", Params.RaceId ~= -1 and Game.Races[Params.RaceId]
			and Game.Races[Params.RaceId].Name or "")
	Str = strgsub(Str, "{RP}", Params.RaceId ~= -1 and Game.Races[Params.RaceId]
			and Game.Races[Params.RaceId].Plural or "")
	Str = strgsub(Str, "{RA}", Params.RaceId ~= -1 and Game.Races[Params.RaceId]
			and Game.Races[Params.RaceId].Adj or "")
	Str = strgsub(Str, "{BRN}", Params.RaceId ~= -1 and Game.Races[Params.RaceId].BaseRace
			and Game.Races[Game.Races[Params.RaceId].BaseRace]
			and Game.Races[Game.Races[Params.RaceId].BaseRace].Name or "")
	Str = strgsub(Str, "{BRP}", Params.RaceId ~= -1 and Game.Races[Params.RaceId].BaseRace
			and Game.Races[Game.Races[Params.RaceId].BaseRace]
			and Game.Races[Game.Races[Params.RaceId].BaseRace].Plural or "")
	Str = strgsub(Str, "{BRA}", Params.RaceId ~= -1 and Game.Races[Params.RaceId].BaseRace
			and Game.Races[Game.Races[Params.RaceId].BaseRace]
			and Game.Races[Game.Races[Params.RaceId].BaseRace].Adj or "")
	Str = strgsub(Str, "{CN}", Params.ClassId ~= -1
			and Game.ClassNames[Params.ClassId] or "")
	return Str
end

local function CheckRaceId(RaceId)
	if RaceId == nil then
		return false
	elseif not tonumber(RaceId) then
		-- Id should be a number
		return false
	elseif RaceId < 0 or RaceId >= Game.RacesCount then
		-- Assuming we don't have spaces inside Game.Races, given Id is out of bounds
		return false
	elseif Game.Races[RaceId] == nil then
		-- There is no Race structure with given Id
		return false
	else
		return true
	end
end

local function CheckClassId(ClassId)
	if ClassId == nil then
		return false
	elseif not tonumber(ClassId) then
		-- Id should be a number
		return false
	elseif ClassId < 0 or ClassId >= Game.ClassNames.count then
		-- Assuming we don't have spaces inside Game.ClassNames, given Id is out of bounds
		return false
	elseif Game.ClassesExtra[ClassId] == nil then
		-- There is no ClassExtra structure with given Class Id
		return false
	else
		return true
	end
end

local function get_race_class_name_tbl(t)
	if not CheckRaceId(t.Race) then
		return nil
	end
	if not CheckClassId(t.Class) then
		return nil
	end
	t.Continent = t.Continent or MV.Continent or -1
	t.Alignment = t.Alignment or -1
	local race_family = Game.Races[t.Race].Family or -1
	local race_kind = Game.Races[t.Race].Kind or -1
	local class_kind = Game.ClassesExtra[t.Class].Kind or -1
	local class_step = Game.ClassesExtra[t.Class].Step or -1
	for _, custom_name in pairs(Game.CustomRaceClassNames) do
		if (custom_name.RaceId == -1 or CustomName.RaceId == t.Race)
				and (custom_name.ClassId == -1 or custom_name.ClassId == t.Class)
				and (custom_name.RaceFamilyId == -1 or custom_name.RaceFamilyId == race_family)
				and (custom_name.RaceKindId == -1 or custom_name.RaceKindId == race_kind)
				and (custom_name.ClassKindId == -1 or custom_name.ClassKindId == class_kind)
				and (custom_name.ClassStepId == -1 or custom_name.ClassStepId == class_step)
				and (custom_name.ContinentId == -1 or custom_name.ContinentId == t.Continent)
				and (custom_name.AlignmentId == -1 or custom_name.AlignmentId == t.Alignment) then
			return custom_name
		end
	end
end

function GetRaceName(RaceId, ContinentId, AlignmentId, ClassId, NameType)
	if type(RaceId) == "table" then
		ClassId = RaceId.ClassId
		ContinentId = RaceId.ContinentId or -1
		AlignmentId = RaceId.AlignmentId or -1
		NameType = RaceId.NameType or 0
		RaceId = RaceId.RaceId
	else
		ContinentId = ContinentId or -1
		AlignmentId = AlignmentId or -1
		NameType = NameType or 0
	end
	if not CheckRaceId(RaceId) then
		return nil
	end
	if not CheckClassId(ClassId) then
		return nil
	end
	RaceFamilyId = Game.Races[RaceId].Family or -1
	RaceKindId = Game.Races[RaceId].Kind or -1
	ClassKindId = Game.ClassesExtra[ClassId].Kind or -1
	ClassStepId = Game.ClassesExtra[ClassId].Step or -1
	for _, CustomName in pairs(Game.CustomRaceClassNames) do
		if (CustomName.RaceId == -1 or CustomName.RaceId == RaceId)
				and (CustomName.RaceFamilyId == -1 or CustomName.RaceFamilyId == RaceFamilyId)
				and (CustomName.RaceKindId == -1 or CustomName.RaceKindId == RaceKindId)
				and (CustomName.ContinentId == -1 or CustomName.ContinentId == ContinentId)
				and (CustomName.AlignmentId == -1 or CustomName.AlignmentId == AlignmentId)
				and (CustomName.ClassKindId == -1 or CustomName.ClassKindId == ClassKindId)
				and (CustomName.ClassStepId == -1 or CustomName.ClassStepId == ClassStepId)
				and (CustomName.ClassId == -1 or CustomName.ClassId == ClassId) then
			local RaceName
			if NameType == 0 then
				RaceName = CustomName.RaceName
			elseif NameType == 1 then
				RaceName = CustomName.RacePlural
			elseif NameType == 2 then
				RaceName = CustomName.RaceAdj
			end
			if RaceName == "" or RaceName == nil then
				if NameType == 0 then
					RaceName = Game.Races[RaceId].Name
				elseif NameType == 1 then
					RaceName = Game.Races[RaceId].Plural
				elseif NameType == 2 then
					RaceName = Game.Races[RaceId].Adj
				end
			elseif RaceName == "-" then
				RaceName = ""
			else
				RaceName = EvaluateMacros(RaceName,
						{RaceId = RaceId, RaceFamilyId = RaceFamilyId,
						RaceKindId = RaceKindId, ContinentId = ContinentId,
						AlignmentId = AlignmentId, ClassId = ClassId,
						ClassKindId = ClassKindId, ClassStepId = ClassStepId})
			end
			return RaceName
		end
	end
	-- We haven't found Custom Race Name, return regular one
	if NameType == 0 then
		return Game.Races[RaceId].Name
	elseif NameType == 1 then
		return Game.Races[RaceId].Plural
	elseif NameType == 2 then
		return Game.Races[RaceId].Adj
	end
	-- Name of last resort
	return Game.Races[RaceId].Name
end
MF.GetRaceName = GetRaceName

function GetClassName(ClassId, ContinentId, RaceId, AlignmentId)
	if type(ClassId) ==  "table" then
		RaceId = ClassId.RaceId
		ContinentId = ClassId.ContinentId or -1
		AlignmentId = ClassId.AlignmentId or -1
		ClassId = ClassId.ClassId
	else
		ContinentId = ContinentId or -1
		AlignmentId = AlignmentId or -1
	end
	if not CheckClassId(ClassId) then
		return nil
	end
	if not CheckRaceId(RaceId) then
		return nil
	end
	ClassKindId = Game.ClassesExtra[ClassId].Kind or -1
	ClassStepId = Game.ClassesExtra[ClassId].Step or -1
	RaceFamilyId = Game.Races[RaceId].Family or -1
	RaceKindId = Game.Races[RaceId].Kind or -1
	for _, CustomName in pairs(Game.CustomRaceClassNames) do
		if (CustomName.ClassId == -1 or CustomName.ClassId == ClassId)
				and (CustomName.ClassKindId == -1 or CustomName.ClassKindId == ClassKindId)
				and (CustomName.ClassStepId == -1 or CustomName.ClassStepId == ClassStepId)
				and (CustomName.ContinentId == -1 or CustomName.ContinentId == ContinentId)
				and (CustomName.RaceId == -1 or CustomName.RaceId == RaceId)
				and (CustomName.RaceFamilyId == -1 or CustomName.RaceFamilyId == RaceFamilyId)
				and (CustomName.RaceKindId == -1 or CustomName.RaceKindId == RaceKindId)
				and (CustomName.AlignmentId == -1 or CustomName.AlignmentId == AlignmentId) then
			local ClassName = CustomName.ClassName
			if ClassName == "" or ClassName == nil then
				ClassName = Game.ClassNames[ClassId]
			elseif ClassName == "-" then
				ClassName = ""
			else
				ClassName = EvaluateMacros(ClassName,
						{ClassId = ClassId, ClassKindId = ClassKindId,
						ClassStepId = ClassStepId, ContinentId = ContinentId,
						RaceId = RaceId, RaceFamilyId = RaceFamilyId,
						RaceKindId = RaceKindId, AlignmentId = AlignmentId})
			end
			return ClassName
		end
	end
	-- We haven't found Custom Class Name, return regular one
	return Game.ClassNames[ClassId]
end
MF.GetClassName = GetClassName

function GenerateBiography(Char)
	-- better autobiographies by majaczek, reworked by cthscr
	-- Default MM8 text: "This is you--The Acknowledged Hero of Jadame."
	local class, race = Char.Class, GetCharRace(Char)
	if (Merge.Settings.Character.EnhancedAutobiographies == 1) then
		-- "Name the RaceAdj Class" style
		local racename = GetRaceName({ClassId = class, RaceId = race, NameType = 0})
		local classname = GetClassName({ClassId = class, RaceId = race})
		-- Omit RaceName* if it equals ClassName (space insensitively)
		if strgsub(racename, "%s+", "") == strgsub(classname, "%s+", "") then
			Char.Biography = strformat(Game.GlobalTxt[429],	-- "%s the %s"
					Char.Name, classname)
		else
			Char.Biography = strformat(TXT.BiographyFmt1,	-- "%s the %s %s"
					Char.Name,
					GetRaceName({ClassId = class, RaceId = race, NameType = 2}),
					classname)
		end
	elseif (Merge.Settings.Character.EnhancedAutobiographies == 2) then
		-- "Name the Class (Race)" style
		local racename = GetRaceName({ClassId = class, RaceId = race, NameType = 0})
		local classname = GetClassName({ClassId = class, RaceId = race})
		-- Omit RaceName* if it equals ClassName (space insensitively)
		if strgsub(racename, "%s+", "") == strgsub(classname, "%s+", "") then
			Char.Biography = strformat(Game.GlobalTxt[429],	-- "%s the %s"
					Char.Name, classname)
		else
			Char.Biography = strformat(TXT.BiographyFmt2,	-- "%s the %s (%s)"
					Char.Name, classname, racename)
		end
	else
		-- "Name - Class" style
		Char.Biography = strformat(TXT.BiographyFmt0,	-- "%s - %s"
				Char.Name, GetClassName({ClassId = class, RaceId = race}))
	end
end

local function SetCustomRaceClassNamesHooks()
	Log(Merge.Log.Info, "CustomRaceClassNames: setting up hooks.")

	local function GetPlayerFromPtr(ptr)
		local PlayerId = (ptr - Party.PlayersArray["?ptr"])/Party.PlayersArray[0]["?size"]
		return Party.PlayersArray[PlayerId], PlayerId
	end

	-- QuickRef
	mem.hook(0x41A714, function(d)
		local player = GetPlayerFromPtr(d.ecx)
		Game.TextBuffer = GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race})
		--Log(Merge.Log.Info, "GetCustomClassName1, %s", Game.TextBuffer)
		d.eax = 0x5DF0E0
	end)
	mem.asmpatch(0x41A719, [[
	push eax]])
	mem.nop(0x41A71A, 6)

	-- Right click Status
	mem.hook(0x41CA3F, function(d)
		local player = GetPlayerFromPtr(d.ebx)
		Game.TextBuffer2 = strformat(Game.GlobalTxt[429],	-- "%s the %s"
			player.Name,
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName2, %s", Game.TextBuffer)
	end)

	--[[
	-- Unknown
	mem.hook(0x4304CD, function(d)
		local player = GetPlayerFromPtr(d.esi)
		Game.TextBuffer = strformat(Game.GlobalTxt[429],	-- "%s the %s"
			player.Name,
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName3, %s", Game.TextBuffer)
	end)

	-- Unknown
	mem.hook(0x4325F1, function(d)
		local player = GetPlayerFromPtr(d.esi)
		Game.TextBuffer = strformat(Game.GlobalTxt[429],	-- "%s the %s"
			player.Name,
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName4, %s", Game.TextBuffer)
	end)
	]]

	-- MouseOver Status
	mem.hook(0x432772, function(d)
		local player = GetPlayerFromPtr(d.esi)
		Game.TextBuffer = strformat(Game.GlobalTxt[429],	-- "%s the %s"
			player.Name,
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName5, %s", Game.TextBuffer)
	end)

	-- "This skill level can not be learned by the %s class."
	mem.hook(0x4B0ED5, function(d)
		local player = Party[math.max(Game.CurrentPlayer, 0)]
		Game.TextBuffer2 = GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race})
		--Log(Merge.Log.Info, "GetCustomClassName6, %s", Game.TextBuffer2)
		d.eax = 0x5E1020
	end)
	mem.asmpatch(0x4B0EDA, [[
	push eax]])
	mem.nop(0x4B0EDB, 1)

	local function CustomNameSeekKnowledge(d)
		local player = GetPlayerFromPtr(d.ecx)
		Game.TextBuffer = strformat(Game.GlobalTxt[544],	-- "Seek knowledge elsewhere %s the %s"
			player.Name,
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName7, %s", Game.TextBuffer)
	end

	-- Instructor
	mem.hook(0x4B34A8, CustomNameSeekKnowledge)
	-- Magician
	mem.hook(0x4B4117, CustomNameSeekKnowledge)
	-- Scribe
	mem.hook(0x4B5067, CustomNameSeekKnowledge)
	-- Healer
	mem.hook(0x4B5AC5, CustomNameSeekKnowledge)
	-- Tavern
	mem.hook(0x4B6B07, CustomNameSeekKnowledge)
	-- Blacksmith
	mem.hook(0x4B7DA1, CustomNameSeekKnowledge)
	-- Alchemist
	mem.hook(0x4B8465, CustomNameSeekKnowledge)
	-- Armorsmith
	mem.hook(0x4B9535, CustomNameSeekKnowledge)

	-- Victory card
	mem.asmpatch(0x4BD5D9, [[
	mov ecx, ebx
	add ebx, 0xA8
	]])
	mem.hook(0x4BD5EC, function(d)
		local player = GetPlayerFromPtr(d.ecx)
		Game.TextBuffer = strformat(Game.GlobalTxt[129],	-- "%s the Level %u %s"
			player.Name,
			d.eax,
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName8, %s", Game.TextBuffer)
	end)

	-- Adventurer's Inn
	mem.hook(0x4C8EC4, function(d)
		local player = GetPlayerFromPtr(d.ebp)
		Game.TextBuffer2 = strformat("%s: %s",	-- 0x4F3C88
			Game.GlobalTxt[41],	-- "Class"
			GetClassName({ClassId = player.Class, RaceId = player.Attrs.Race}))
		--Log(Merge.Log.Info, "GetCustomClassName9, %s", Game.TextBuffer2)
	end)
	local new_code = asmpatch(0x4C8EED, [[
	nop
	nop
	nop
	nop
	nop
	mov edx, dword ptr [0x5DB938]
	mov ecx, dword ptr [0x519334]
	add edi, ebx
	push 0
	push 0xFA
	push esi
	push 0
	push edi
	push 0xC0
	call absolute 0x44A253
	push dword ptr [ebp + 0x1BF8]
	]])
	hook(new_code, function(d)
		local player = GetPlayerFromPtr(d.ebp)
		Game.TextBuffer2 = strformat(" ÖÖ ×å: %s (%d)",
			GetRaceName({ClassId = player.Class, RaceId = player.Attrs.Race,
				Maturity = player.Attrs.Maturity or 0}),
			player.Attrs.Maturity or 0)
	end)
end

function events.GameInitialized2()
	local result = ProcessCustomRaceClassNamesTxt()
	if not result then
		Log(Merge.Log.Warning, "Loading CustomRaceClassNames.txt has failed.")
	elseif result == 0 then
		Log(Merge.Log.Warning, "No effective lines in CustomRaceClassNames.txt were found.")
	else
		Log(Merge.Log.Info, "Loaded CustomRaceClassNames.txt: %d effective lines", result)
		SetCustomRaceClassNamesHooks()
	end
end

Log(Merge.Log.Info, "Init finished: CustomRaceClassNames.lua")
