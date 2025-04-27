-- Race HP/SP modifiers
local LogId = "RaceHPSP"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MT = Merge.Functions, Merge.Tables

local max = math.max
local asmpatch, autohook, hook = mem.asmpatch, mem.autohook, mem.hook
local strsplit = string.split

local function ProcessRaceHPSPTxt()
	local RaceHPSP = {}

	local TxtTable = io.open("Data/Tables/RaceHPSP.txt", "r")

	if not TxtTable then
		Log(Merge.Log.Warning, "No RaceHPSP.txt found, creating one.")
		TxtTable = io.open("Data/Tables/RaceHPSP.txt", "w")
		TxtTable:write("#\9Note\9HPBase\9HPFactor\9SPBase\9SPFactor\n")
	else
		local LineIt = TxtTable:lines()
		local header = LineIt()
		if header ~= "#\9Note\9HPBase\9HPFactor\9SPBase\9SPFactor" then
			Log(Merge.Log.Error, "RaceHPSP.txt header differs from expected one, table is ignored. Regenerate or fix it.")
		else
			local linenum = 1
			for line in LineIt do
				linenum = linenum + 1
				if line == "\9Class specific values:" then
					break
				end
				local Words = strsplit(line, "\9")
				if string.len(Words[1]) == 0 then
					Log(Merge.Log.Warning, "RaceHPSP.txt line %d first field is empty. Skipping following lines.", linenum)
					break
				end
				-- Ignore lines that don't start with number
				if Words[1] and tonumber(Words[1]) then
					local hp_sp_mods = {}
					local race_id = tonumber(Words[1])
					-- Skip Words[2] since it contains Race StringId
					hp_sp_mods.HPBase = tonumber(Words[3])
					-- Skip divisor if HPFactor is written in A/4 form
					local res = strsplit(Words[4], "/")[1]
					if not res or res == "" then
						res = Words[4]
					end
					hp_sp_mods.HPFactor = tonumber(res)
					hp_sp_mods.SPBase = tonumber(Words[5])
					-- Skip divisor if SPFactor is written in A/4 form
					res = strsplit(Words[6], "/")[1]
					if not res or res == "" then
						res = Words[6]
					end
					hp_sp_mods.SPFactor = tonumber(res)
					RaceHPSP[race_id] = {}
					RaceHPSP[race_id][-1] = hp_sp_mods
				else
					Log(Merge.Log.Warning, "RaceHPSP.txt line %d first field is not a number. Ignoring line.", linenum)
				end
			end
			LineIt() -- skip secondary header
			for line in LineIt do
				linenum = linenum + 1
				local Words = strsplit(line, "\9")
				if string.len(Words[1]) == 0 then
					Log(Merge.Log.Warning, "RaceHPSP.txt line %d first field is empty. Skipping following lines.", linenum)
					break
				end
				if tonumber(Words[1]) then
					local race = tonumber(Words[1])
					local race_family = tonumber(Words[2])
					local race_kind = tonumber(Words[3])
					local class = tonumber(Words[4])
					local class_kind = tonumber(Words[5])
					local class_step = tonumber(Words[6])
					local hp_base = tonumber(Words[7])
					-- Skip divisor if HPFactor is written in A/4 form
					local res = strsplit(Words[8], "/")[1]
					if not res or res == "" then
						res = Words[8]
					end
					local hp_factor = tonumber(res)
					local sp_base = tonumber(Words[9])
					-- Skip divisor if SPFactor is written in A/4 form
					local res = strsplit(Words[10], "/")[1]
					if not res or res == "" then
						res = Words[10]
					end
					local sp_factor = tonumber(res)
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
					for race, _ in pairs(races) do
						for class, __ in pairs(classes) do
							RaceHPSP[race] = RaceHPSP[race] or {}
							RaceHPSP[race][class] = RaceHPSP[race][class] or {}
							RaceHPSP[race][class].HPBase = hp_base
							RaceHPSP[race][class].HPFactor = hp_factor
							RaceHPSP[race][class].SPBase = sp_base
							RaceHPSP[race][class].SPFactor = sp_factor
						end
					end
				else
					Log(Merge.Log.Warning, "RaceHPSP.txt line %d first field is not a number. Ignoring line.", linenum)
				end
			end
		end
	end

	io.close(TxtTable)
	MT.RaceHPSP = RaceHPSP

	local function get_race_hpsp_tbl(t)
		if not (t.Race and t.Class) then
			Log(Merge.Log.Error,
				"%s: calling GetRaceHPSPTbl without Race or Class",
				LogId)
			return
		end
		local res = MT.RaceHPSP[t.Race] and (MT.RaceHPSP[t.Race][t.Class]
			or MT.RaceHPSP[t.Race][-1])
		return res
	end
	MF.GetRaceHPSPTbl = get_race_hpsp_tbl
end

local function SetRaceHPSPHooks()
	-- GetFullHP HPBase
	autohook(0x48D9C9, function(d)
		local player = MF.GetPlayerFromPtr(d.esi)
		if not player then
			Log(Merge.Log.Error, "%s: invalid player in GetRaceHPBase", LogId)
			return
		end
		local race = GetCharRace(player)
		local res = MF.GetRaceHPSPTbl({Race = race, Class = player.Class})
		if res and res.HPBase then
			d.edi = max(d.edi + res.HPBase, 1)
		end
	end)

	-- GetFullHP HPFactor
	--  Race HPFactor modifier contains amount of 0.25s so other factors are
	--  multiplied by 4 first and final multiplication is divided by 4 later
	local NewCode = asmpatch(0x48DA05, [[
	sal eax, 2
	nop
	nop
	nop
	nop
	nop
	imul ebx, eax
	sar ebx, 2
	add edi, ebx
	]])

	hook(NewCode + 3, function(d)
		local player = MF.GetPlayerFromPtr(d.esi)
		if not player then
			Log(Merge.Log.Error, "%s: invalid player in GetRaceHPFactor", LogId)
			return
		end
		local race = GetCharRace(player)
		local res = MF.GetRaceHPSPTbl({Race = race, Class = player.Class})
		if res and res.HPFactor then
			d.eax = max(d.eax + res.HPFactor, 0)
		end
	end)

	-- GetFullSP SPFactor
	--  Race SPFactor modifier contains amount of 0.25s so other factors are
	--  multiplied by 4 first and final multiplication is divided by 4 later
	NewCode = asmpatch(0x48DA67, [[
	sal eax, 2
	nop
	nop
	nop
	nop
	nop
	mov ecx, edi
	imul esi, eax
	sar esi, 2
	]])

	hook(NewCode + 3, function(d)
		local player = MF.GetPlayerFromPtr(d.edi)
		if not player then
			Log(Merge.Log.Error, "%s: invalid player in GetRaceSPFactor", LogId)
			return
		end
		local race = GetCharRace(player)
		local res = MF.GetRaceHPSPTbl({Race = race, Class = player.Class})
		if res and res.SPFactor then
			d.eax = max(d.eax + res.SPFactor, 0)
		end
	end)

	-- GetFullSP SPBase
	autohook(0x48DA6C, function(d)
		local player = MF.GetPlayerFromPtr(d.edi)
		if not player then
			Log(Merge.Log.Error, "%s: invalid player in GetRaceSPBase", LogId)
			return
		end
		local race = GetCharRace(player)
		local res = MF.GetRaceHPSPTbl({Race = race, Class = player.Class})
		if res and res.SPBase then
			d.esi = max(d.esi + res.SPBase, 0)
		end
	end)
end

function events.GameInitialized2()
	ProcessRaceHPSPTxt()
	SetRaceHPSPHooks()
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
