-- Racial skills
local LogId = "RacialSkills"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MS = Merge.Functions, Merge.ModSettings, Merge.Settings

local function ProcessTxt()

	if not const.Race then
		return
	end

	local header = "#\9Note\9ClassKind"
	for i = 0, Game.SkillNames.count - 1 do
		header = header .. "\9" .. Game.SkillNames[i] .. " (" .. tostring(i) .. ")"
	end

	local TxtTable = io.open("Data/Tables/Race Skills.txt", "r")
	if not TxtTable then
		Log(Merge.Log.Warning, "No Race Skills.txt found, creating one.")
		TxtTable = io.open("Data/Tables/Race Skills.txt", "w")

		TxtTable:write(header .. "\n")

		for race = 0, Game.RacesCount - 1 do
			local line = tostring(race) .. "\9" .. Game.Races[race].StringId .. "\9" .. "0"
			for i = 0, Game.SkillNames.count - 1 do
				line = line .. "\9-"
			end
			TxtTable:write(line .. "\n")
		end

		io.close(TxtTable)
		TxtTable = io.open("Data/Tables/Race Skills.txt", "r")
	end

	local LineIt = TxtTable:lines()
	LineIt() -- skip header

	local SkillConns = {B = 1, E = 2, M = 3, G = 4}
	local def_skill = {Min = 0, Add = 0, Max = 4, Bonus = 0, Auto = 0}
	local null_skill = {Min = 0, Add = 0, Max = 0, Bonus = 0, Auto = 0}
	local RaceSkills = {}

	local function GetPool(line)
		local pool
		if line == "-" or line == "" then
			pool = def_skill
		elseif line == "0" then
			pool = null_skill
		else
			pool = {}
			pool.Min, pool.Add, pool.Max, pool.Bonus, pool.Auto = line:match("^([0-4BEMG]?)/?([-%d]*)/?([0-4BEMG]*)/?([-%d]*)/?([01]?)")

			for k,v in pairs(pool) do
				pool[k] = tonumber(v) or SkillConns[v] or 0
			end
		end
		return pool
	end

	local linenum = 1

	local tmp_races = {}
	for k, v in pairs(Game.Races) do
		table.insert(tmp_races, k, {Family = v.Family, Kind = v.Kind})
	end

	for line in LineIt do
		linenum = linenum + 1
		if line == "\9Class specific skills:" then
			break
		end
		local Words = string.split(line, "\9")
		if string.len(Words[1]) == 0 then
			Log(Merge.Log.Warning, "Race Skills.txt line %d first field is empty. Ignoring line.", linenum)
		else
			-- default race skills
			if tonumber(Words[1]) then
				local race = tonumber(Words[1])
				for skill = 0, #Words - 3 do
					RaceSkills[race] = RaceSkills[race] or {}
					RaceSkills[race][-1] = RaceSkills[race][-1] or {}
					RaceSkills[race][-1][-1] = RaceSkills[race][-1][-1] or {}
					RaceSkills[race][-1][-1][skill] = GetPool(Words[skill + 3])
				end
			else
				Log(Merge.Log.Warning, "Race Skills.txt line %d first field is not a number. Ignoring line.", linenum)
			end
		end
	end

	-- Check for absent default skills
	for race = 0, Game.RacesCount - 1 do
		if not RaceSkills[race] then
			Log(Merge.Log.Warning, "Race Skills.txt contains no skills for race %d", race)
			RaceSkills[race] = {}
		end
		if not RaceSkills[race][-1] then
			Log(Merge.Log.Warning, "Race Skills.txt contains no default skills for race %d", race)
			RaceSkills[race][-1] = {}
		end
		if not RaceSkills[race][-1][-1] then
			Log(Merge.Log.Warning,
				"Race Skills.txt contains no default maturity skills for race %d",
				race)
			RaceSkills[race][-1][-1] = {}
		end
		for skill = 0, Game.SkillNames.count - 1 do
			if not RaceSkills[race][-1][-1][skill] then
				Log(Merge.Log.Warning, "Race Skills.txt contains no default skill %d for race %d",
					skill, race)
				RaceSkills[race][-1][-1][skill] = def_skill
			end
		end
	end

	-- Specific settings
	LineIt() -- skip secondary header
	for line in LineIt do
		linenum = linenum + 1
		local Words = string.split(line, "\9")
		if string.len(Words[1]) == 0 then
			Log(Merge.Log.Warning, "Race Skills.txt line %d first field is empty. Skipping following lines.", linenum)
			break
		else
			local races
			local classes
			local maturities = {}
			if tonumber(Words[1]) then
				local race = tonumber(Words[1])
				local maturity = tonumber(Words[2])
				local race_family = tonumber(Words[3])
				local race_kind = tonumber(Words[4])
				local class = tonumber(Words[5])
				local class_kind = tonumber(Words[6])
				local class_step = tonumber(Words[7])
				local skill = tonumber(Words[8])
				local value = GetPool(Words[9])
				if race > -1 then
					races = {[race] = true}
				else
					local tmp_races2
					if race_family > -1 then
						tmp_races2 = table.filter(tmp_races, 1, "Family", "=", race_family)
					else
						tmp_races2 = table.copy(tmp_races)
					end
					if race_kind > -1 then
						races = table.filter(tmp_races2, 1, "Kind", "=", race_kind)
					else
						races = tmp_races2
					end
				end
				if class > -1 then
					classes = {[class] = true}
				elseif class_kind == -1 and class_step == -1 then
					classes = {[-1] = true}
				else
					local tmp_classes
					if class_kind > -1 then
						tmp_classes = table.filter(Game.ClassesExtra, 1, "Kind", "=", class_kind)
					else
						tmp_classes = table.copy(Game.ClassesExtra)
					end
					if class_step > -1 then
						classes = table.filter(tmp_classes, 1, "Step", "=", class_step)
					else
						classes = tmp_classes
					end
				end
				if maturity > -1 then
					maturities[maturity] = true
				elseif race == -1 and race_family == -1 and race_kind == -1 then
					maturities[-1] = true
				else
					for i = 0, MS.Races.MaxMaturity - 1 do
						maturities[i] = true
					end
				end
				for race1, _ in pairs(races) do
					RaceSkills[race1] = RaceSkills[race1] or {}
					for mat1, _ in pairs(maturities) do
						RaceSkills[race1][mat1] = RaceSkills[race1][mat1] or {}
						for class1, __ in pairs(classes) do
							RaceSkills[race1][mat1][class1] = RaceSkills[race1][mat1][class1] or {}
							RaceSkills[race1][mat1][class1][skill] = value
						end
					end
				end
			else
				Log(Merge.Log.Warning, "Race Skills.txt line %d first field is not a number. Ignoring line.", linenum)
			end
		end
	end

	io.close(TxtTable)

	Game.RaceSkills = RaceSkills

	local function get_race_skill_tbl(t)
		if not (t.Race and t.Maturity and t.Class and t.Skill) then
			Log(Merge.Log.Error,
				"%s: calling GetRaceSkillTbl without Race, Class or Skill",
				LogId)
			return
		end
		local rs0 = Game.RaceSkills[t.Race]
		if not rs0 then
			Log(Merge.Log.Error, "%s: no racial skills for race %d",
				LogId, t.Race)
			return def_skill
		end
		local res = rs0[t.Maturity] and (
			rs0[t.Maturity][t.Class] and rs0[t.Maturity][t.Class][t.Skill]
			or (rs0[t.Maturity][-1] and rs0[t.Maturity][-1][t.Skill]))
			or rs0[-1] and (rs0[-1][t.Class] and rs0[-1][t.Class][t.Skill]
			or (rs0[-1][-1] and rs0[-1][-1][t.Skill]))
		if not res then
			Log(Merge.Log.Error, "%s: no default racial skill for race %d skill %d",
				LogId, t.Race, t.Skill)
			res = def_skill
		end
		return res
	end
	MF.GetRaceSkillTbl = get_race_skill_tbl

	return true

end

local function SetHooks()

	local min, max = math.min, math.max
	local ClassSkillsPtr = Game.Classes.Skills["?ptr"]

	local GetPlayer = MF.GetPlayerFromPtr

	function events.GetSkill(t)
		if t.Result <= 0 or not t.Player.Attrs then
			return
		end
		local race, class = t.Player.Attrs.Race, t.Player.Class
		if not race then
			Log(Merge.Log.Warning, "%s: nil race in GetSkill (player %d, skill %d)",
				LogId, t.PlayerIndex, t.Skill)
			return
		end
		local maturity = t.Player.Attrs.Maturity or 0
		local ClassBonus = MF.GetRaceSkillTbl({Race = race,
			Maturity = maturity, Class = class, Skill = t.Skill})
		local bonus = ClassBonus and ClassBonus.Bonus or 0
		local rank, mastery = SplitSkill(t.Result)
		t.Result = JoinSkill(max(rank + bonus, 1), mastery)
	end

	local function GetMaxSkill(a, b, c, d) -- a - Race or Player structure, b - Class or skill id,
						-- c - skill id, d - race maturity
		local Race, Class, Skill, maturity
		local max_maturity = MM.Races and tonumber(MM.Races.MaxMaturity) or 0
		if type(a) == "number" then
			Race, Class, Skill, maturity = a, b, c, d or 0
		else
			Race, Class, Skill = GetCharRace(a), a.Class, b
			maturity = c or a.Attrs and a.Attrs.Maturity or 0
		end

		local DefSkill	= Game.Classes.Skills[Class][Skill]
		local Result	= DefSkill

		local Bonus = {Min = 0, Add = 0, Max = 4}
		if maturity == -1 then
			for i = 0, max_maturity do
				local ClassBonus = MF.GetRaceSkillTbl({Race = Race,
					Maturity = i, Class = Class, Skill = Skill})
				if ClassBonus and (DefSkill == 0 and ClassBonus.Min > Bonus.Min
						or DefSkill > 0 and ClassBonus.Add > Bonus.Add) then
					Bonus.Min, Bonus.Add, Bonus.Max = ClassBonus.Min, ClassBonus.Add, ClassBonus.Max
				end
			end
		else
			local ClassBonus = MF.GetRaceSkillTbl({Race = Race,
				Maturity = maturity, Class = Class, Skill = Skill})
			if ClassBonus then
				Bonus.Min, Bonus.Add, Bonus.Max = ClassBonus.Min, ClassBonus.Add, ClassBonus.Max
		end
		end

		Result = max(DefSkill, Bonus.Min)
		if DefSkill > 0 then
			Result = Result + Bonus.Add
		end

		Result = max(min(Result, Bonus.Max), 0)

		return Result, Result - DefSkill

	end

	GetMaxSkillLevel	 = GetMaxSkill
	GetMaxAvailableSkill = GetMaxSkill
	MF.GetMaxSkillMastery = GetMaxSkill

	-- Base functions

	local GetRaceSkill = mem.asmproc([[
	; start:
	; eax - player ptr
	; ecx - skill

	nop
	nop
	nop
	nop
	nop
	retn]])

	local function eventGetMaxSkill(Player, PlayerIndex, Skill, Class, Promotions)
		local t = {Player = Player, PlayerIndex = PlayerIndex,
			Class = Class, Skill = Skill,
			Promotions = Promotions, Result = 0, Bonus = 0}
		t.Result, t.Bonus = GetMaxSkill(Player.Attrs.Race, Class or Player.Class,
			Skill, Promotions or Player.Attrs.Maturity)
		events.call("GetMaxSkillLevel", t)
		return t.Result, t.Bonus
	end

	mem.hook(GetRaceSkill, function(d)
		local p, pid = GetPlayer(d.eax)
		d.eax = eventGetMaxSkill(p, pid, d.ecx)
	end)

	-- 0x4171a0, 0x4171ba, 0x4171c6
	function events.ShowSkillDescr(t)
		local cMax, Bonus = eventGetMaxSkill(t.Player, t.PlayerIndex, t.Skill, t.Class, t.Mastery)
		t.MaxLevel = cMax
	end

	-- Can get new tier

	-- 0x4b0e6b
	mem.asmpatch(0x4b0e6b, [[
	movzx eax, byte [ds:ecx+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ebx
	call absolute ]] .. GetRaceSkill .. [[;]])

	-- 0x4b0e99
--~ 	mem.asmpatch(0x4b0e99, [[
--~ 	lea eax, dword [ds:ecx+edx+]] .. ClassSkillsPtr .. [[]
--~ 	mov edx, eax
--~ 	mov eax, ebx
--~ 	call absolute ]] .. GetRaceSkill .. [[;
--~ 	mov ecx, eax
--~ 	mov eax, edi]])

	-- Can learn in shop

	-- 0x4b32ee
	mem.asmpatch(0x4b32ee, [[
	push eax
	push ecx
	movzx eax, byte[ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	test eax, eax
	pop ecx
	pop eax]])

	-- 0x4b33ea
	mem.asmpatch(0x4b33ea, [[
	movzx eax, byte[ds:ebx+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, esi
	mov ecx, ebx
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, esi
	test eax, eax]])

	-- 0x4b4bb0
	mem.asmpatch(0x4b4bb0, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x14]
	test eax, eax]])

	-- 0x4b4ca7
	mem.asmpatch(0x4b4ca7, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x14]
	test eax, eax]])

	-- 0x4b9382
	mem.asmpatch(0x4b9382, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x10]
	test eax, eax]])

	-- 0x4b9477
	mem.asmpatch(0x4b9477, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x10]
	test eax, eax]])

	-- 0x4b7bee
	mem.asmpatch(0x4b7bee, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x14]
	test eax, eax]])

	-- 0x4b7ce3
	mem.asmpatch(0x4b7ce3, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x14]
	test eax, eax]])

	-- 0x4b590d -- temple -- mistake
	mem.asmpatch(0x4b590d, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0xc]
	test eax, eax]])

	-- 0x4b5a07 -- temple
	mem.asmpatch(0x4b5a07, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0xc]
	test eax, eax]])

	-- 0x4b3f64 -- magic shop
	mem.asmpatch(0x4b3f64, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x14]
	test eax, eax]])

	-- 0x4b4059 -- magic shop
	mem.asmpatch(0x4b4059, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x14]
	test eax, eax]])

	-- 0x4b82b2 -- alchemist
	mem.asmpatch(0x4b82b2, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x18]
	test eax, eax]])

	-- 0x4b83a7 -- alchemist
	mem.asmpatch(0x4b83a7, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x18]
	test eax, eax]])

	-- 0x4b6948 -- tavern
	mem.asmpatch(0x4b6948, [[
	movzx eax, byte [ds:esi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, esi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x18]
	test eax, eax]])

	-- 0x4b6a43 -- tavern
	mem.asmpatch(0x4b6a43, [[
	movzx eax, byte [ds:edi+eax+]] .. ClassSkillsPtr .. [[]
	mov edx, eax
	mov eax, ecx
	mov ecx, edi
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, dword [ss:ebp-0x18]
	test eax, eax]])

	-- 0x4baf6c -- Can learn 1
	mem.asmpatch(0x4baf6c, [[
	movzx eax, byte [ds:ebp+eax+]] .. ClassSkillsPtr - 0x24 .. [[]
	mov edx, eax
	mov eax, ecx
	lea ecx, dword [ss:ebp-0x24]
	call absolute ]] .. GetRaceSkill .. [[;
	mov ecx, edi
	test eax, eax]])

	-- 0x4bbcf1, 0x4b4df5, 0x4b4f8c

end

function events.GameInitialized2()
	GetMaxSkillLevel	 = function() return 0 end
	GetMaxAvailableSkill = function() return 0 end
	if ProcessTxt() then
		SetHooks()
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
