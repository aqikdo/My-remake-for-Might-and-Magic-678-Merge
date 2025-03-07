local LogId = "Reputation"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MO, MT, MV = Merge.Functions, Merge.ModSettings, Merge.Offsets, Merge.Tables, Merge.Vars

local abs, ceil, floor, max, min = math.abs, math.ceil, math.floor, math.max, math.min
local asmpatch, asmproc, autohook, autohook2 = mem.asmpatch, mem.asmproc, mem.autohook, mem.autohook2
local hook, nop2, u4 = mem.hook, mem.nop2, mem.u4
local strlen, strsplit = string.len, string.split

local ContSet
local rep_set
local NewCode

local function ProcessReputationTxt()
	local table_file = "Data/Tables/Reputation.txt"
	local header1 = "# World\9Note\9WorldLimUp\9WorldLimBot\9WorldDecMult"
		.. "\9WorldDecFlat\9WorldDecMin\9WorldDec2Mult\9WorldDec2Flat"
		.. "\9WorldDec2Min\9WorldDecLimUp\9WorldDecLimBot"
		.. "\9DonateWorldLim\9DonateWorldNegLim"
	local header2 = "# Cont\9Note\9WorldRep\9ContRep\9MapRep\9WorldGain"
		.. "\9ContGain\9MapGain\9RepGuards\9RepShops\9RepNPC\9LimUp"
		.."\9LimBot\9ContLimUp\9ContLimBot\9MapLimUp\9MapLimBot"
		.. "\9ContDecMult\9ContDecFlat\9ContDecMin\9ContDec2Mult"
		.. "\9ContDec2Flat\9ContDec2Min\9ContDecLimUp\9ContDecLimBot"
		.. "\9MapDecMult\9MapDecFlat\9MapDecMin\9MapDec2Mult"
		.. "\9MapDec2Flat\9MapDec2Min\9MapDecLimUp\9MapDecLimBot"
		.. "\9TradeMult\9DonateCostMult\9DonateMod\9DonateNegMod"
		.. "\9DonateLim\9DonateNegLim\9DonateNegLim2\9DonateMapLim"
		.. "\9DonateMapNegLim\9DonateMapNegLim2\9DonateContLim"
		.. "\9DonateContNegLim\9DonateContNegLim2\9DonateWorldGain"
		.. "\9DonateContGain\9DonateMapGain\9DonateSpells\9Ranks"
		.. "\9BHWorldGain\9BHContGain\9BHMapGain\9PenKillPeas"
		.. "\9PenKillGuard\9FineKillPeasFlat\9FineKillGuardFlat"
		.. "\9FineKillPeasLvlMult\9FineKillGuardLvlMult"
		.. "\9FineKillPeasRepMult\9FineKillGuardRepMult\9PenStealSShop"
		.. "\9PenStealSPeas\9PenStealSGuard\9PenStealUShop"
		.. "\9PenStealUPeas\9PenStealUGuard\9PenStealCShop"
		.. "\9PenStealCPeas\9PenStealCGuard\9FineStealCShop"
		.. "\9FineStealCPeas\9FineStealCGuard\9BegPen\9BribePen"
		.. "\9ThreatPen\9BegFailPen\9BribeFailPen\9ThreatFailPen"
	local header3 = "# Map\9Note\9WorldRep\9ContRep\9MapRep\9WorldGain"
		.. "\9ContGain\9MapGain\9RepGuards\9RepShops\9RepNPC\9LimUp"
		.. "\9LimBot\9MapLimUp\9MapLimBot\9MapDecMult\9MapDecFlat"
		.. "\9MapDecMin\9MapDec2Mult\9MapDec2Flat\9MapDec2Min"
		.. "\9MapDecLimUp\9MapDecLimBot\9TradeMult\9DonateCostMult"
		.. "\9DonateMod\9DonateNegMod\9DonateLim\9DonateNegLim"
		.. "\9DonateNegLim2\9DonateMapLim\9DonateMapNegLim"
		.. "\9DonateMapNegLim2\9DonateWorldGain\9DonateContGain"
		.. "\9DonateMapGain\9DonateSpells\9Ranks\9BHWorldGain"
		.. "\9BHContGain\9BHMapGain\9PenKillPeas\9PenKillGuard"
		.. "\9FineKillPeasFlat\9FineKillGuardFlat\9FineKillPeasLvlMult"
		.. "\9FineKillGuardLvlMult\9FineKillPeasRepMult"
		.. "\9FineKillGuardRepMult\9PenStealSShop\9PenStealSPeas"
		.. "\9PenStealSGuard\9PenStealUShop\9PenStealUPeas"
		.. "\9PenStealUGuard\9PenStealCShop\9PenStealCPeas"
		.. "\9PenStealCGuard\9FineStealCShop\9FineStealCPeas"
		.. "\9FineStealCGuard\9BegPen\9BribePen\9ThreatPen\9BegFailPen"
		.. "\9BribeFailPen\9ThreatFailPen"

	MT.Reputation = MT.Reputation or {}
	MT.Reputation.Worlds = MT.Reputation.Worlds or {}
	MT.Reputation.Continents = MT.Reputation.Continents or {}
	MT.Reputation.Maps = MT.Reputation.Maps or {}
	local rep_txt = io.open(table_file, "r")
	if not rep_txt then
		Log(Merge.Log.Warning, "No Reputation.txt found, creating one.")
		rep_txt = io.open(table_file, "w")
		rep_txt:write(header1 .. "\n")
		rep_txt:write("1\9Enroth\9\9\9\n\n")
		rep_txt:write(header2 .. "\n")
		rep_txt:write("1\9Jadame\n")
		rep_txt:write("2\9Antagarich\n")
		rep_txt:write("3\9Enroth\n")
		rep_txt:write("4\9Between Time\n\n")
		rep_txt:write(header3 .. "\n")
		MT.Reputation.Worlds[1] = {}
		MT.Reputation.Continents[1] = {}
		MT.Reputation.Continents[2] = {}
		MT.Reputation.Continents[3] = {}
		MT.Reputation.Continents[4] = {}
	else
		local iter = rep_txt:lines()
		if iter() ~= header1 then
			Log(Merge.Log.Error, "Reputation.txt first header differs from expected one, table is ignored. Regenerate or fix it.")
			io.close(rep_txt)
			return false
		end
		local line_num = 1
		local eff_lines_w = 0
		local eff_lines_c = 0
		local eff_lines_m = 0
		for line in iter do
			line_num = line_num + 1
			local words = strsplit(line, "\9")
			if not words[1] or strlen(words[1]) == 0 then
				Log(Merge.Log.Info, "Reputation.txt line %d first field is empty, end worlds reputation block",
					line_num)
				break
			end
			local world = tonumber(words[1])
			if not world then
				Log(Merge.Log.Warning,
					"Reputation.txt line %d first field is not a number. Ignoring line.",
					line_num)
			else
				MT.Reputation.Worlds[world] = {
					WorldLimUp = tonumber(words[3]),
					WorldLimBot = tonumber(words[4]),
					WorldDecMult = tonumber(words[5]),
					WorldDecFlat = tonumber(words[6]),
					WorldDecMin = tonumber(words[7]),
					WorldDec2Mult = tonumber(words[8]),
					WorldDec2Flat = tonumber(words[9]),
					WorldDec2Min = tonumber(words[10]),
					WorldDecLimUp = tonumber(words[11]),
					WorldDecLimBot = tonumber(words[12]),
					DonateWorldLim = tonumber(words[13]),
					DonateWorldNegLim = tonumber(words[14]),
				}
				eff_lines_w = eff_lines_w + 1
			end
		end
		if iter() ~= header2 then
			Log(Merge.Log.Error, "Reputation.txt second header differs from expected one, table is ignored. Regenerate or fix it.")
			io.close(rep_txt)
			return false
		end
		line_num = line_num + 1
		for line in iter do
			line_num = line_num + 1
			local words = strsplit(line, "\9")
			if not words[1] or strlen(words[1]) == 0 then
				Log(Merge.Log.Info, "Reputation.txt line %d first field is empty, end continents reputation block",
					line_num)
				break
			end
			local cont = tonumber(words[1])
			if not cont then
				Log(Merge.Log.Warning,
					"Reputation.txt line %d first field is not a number. Ignoring line.",
					line_num)
			else
				MT.Reputation.Continents[cont] = {
					UseRep = (MF.NeSettingNum(words[3], 0) or MF.NeSettingNum(words[4], 0)
						or MF.NeSettingNum(words[5], 0)) and true,
					RepWorld = tonumber(words[3]),
					RepCont = tonumber(words[4]),
					RepMap = tonumber(words[5]),
					WorldGain = tonumber(words[6]),
					ContGain = tonumber(words[7]),
					MapGain = tonumber(words[8]),
					RepGuards = tonumber(words[9]),
					RepShops = tonumber(words[10]),
					RepNPC = words[11] == "x",
					LimUp = tonumber(words[12]),
					LimBot = tonumber(words[13]),
					ContLimUp = tonumber(words[14]),
					ContLimBot = tonumber(words[15]),
					MapLimUp = tonumber(words[16]),
					MapLimBot = tonumber(words[17]),
					ContDecMult = tonumber(words[18]),
					ContDecFlat = tonumber(words[19]),
					ContDecMin = tonumber(words[20]),
					ContDec2Mult = tonumber(words[21]),
					ContDec2Flat = tonumber(words[22]),
					ContDec2Min = tonumber(words[23]),
					ContDecLimUp = tonumber(words[24]),
					ContDecLimBot = tonumber(words[25]),
					MapDecMult = tonumber(words[26]),
					MapDecFlat = tonumber(words[27]),
					MapDecMin = tonumber(words[28]),
					MapDec2Mult = tonumber(words[29]),
					MapDec2Flat = tonumber(words[30]),
					MapDec2Min = tonumber(words[31]),
					MapDecLimUp = tonumber(words[32]),
					MapDecLimBot = tonumber(words[33]),
					TradeMult = tonumber(words[34]),
					DonateCMult = tonumber(words[35]),
					DonateMod = tonumber(words[36]),
					DonateNegMod = tonumber(words[37]),
					DonateLim = tonumber(words[38]),
					DonateNegLim = tonumber(words[39]),
					DonateNegLim2 = tonumber(words[40]),
					DonateMapLim = tonumber(words[41]),
					DonateMapNegLim = tonumber(words[42]),
					DonateMapNegLim2 = tonumber(words[43]),
					DonateContLim = tonumber(words[44]),
					DonateContNegLim = tonumber(words[45]),
					DonateContNegLim2 = tonumber(words[46]),
					DonateWorldGain = tonumber(words[47]),
					DonateContGain = tonumber(words[48]),
					DonateMapGain = tonumber(words[49]),
					DonateSpells = tonumber(words[50]),
					RepRanks = tonumber(words[51]),
					BHWorldGain = tonumber(words[52]),
					BHContGain = tonumber(words[53]),
					BHMapGain = tonumber(words[54]),
					PenKillPeas = tonumber(words[55]),
					PenKillGuard = tonumber(words[56]),
					FineKillPeasFlat = tonumber(words[57]),
					FineKillGuardFlat = tonumber(words[58]),
					FineKillPeasLvlMult = tonumber(words[59]),
					FineKillGuardLvlMult = tonumber(words[60]),
					FineKillPeasRepMult = tonumber(words[61]),
					FineKillGuardRepMult = tonumber(words[62]),
					PenStealSShop = tonumber(words[63]),
					PenStealSPeas = tonumber(words[64]),
					PenStealSGuard = tonumber(words[65]),
					PenStealUShop = tonumber(words[66]),
					PenStealUPeas = tonumber(words[67]),
					PenStealUGuard = tonumber(words[68]),
					PenStealCShop = tonumber(words[69]),
					PenStealCPeas = tonumber(words[70]),
					PenStealCGuard = tonumber(words[71]),
					FineStealCShop = tonumber(words[72]),
					FineStealCPeas = tonumber(words[73]),
					FineStealCGuard = tonumber(words[74]),
					BegPen = tonumber(words[75]),
					BribePen = tonumber(words[76]),
					ThreatPen = tonumber(words[77]),
					BegFailPen = tonumber(words[78]),
					BribeFailPen = tonumber(words[79]),
					ThreatFailPen = tonumber(words[80])
				}
				eff_lines_c = eff_lines_c + 1
			end
		end
		if iter() ~= header3 then
			Log(Merge.Log.Error, "Reputation.txt third header differs from expected one, table is ignored. Regenerate or fix it.")
			io.close(rep_txt)
			return false
		end
		line_num = line_num + 1
		for line in iter do
			line_num = line_num + 1
			local words = strsplit(line, "\9")
			if not words[1] or strlen(words[1]) == 0 then
				Log(Merge.Log.Info, "Reputation.txt line %d first field is empty, end maps reputation block",
					line_num)
				break
			end
			local map1 = tonumber(words[1])
			if not map1 then
				Log(Merge.Log.Warning,
					"Reputation.txt line %d first field is not a number. Ignoring line.",
					line_num)
			else
				MT.Reputation.Maps[map1] = {
					UseRep = (MF.NeSettingNum(words[3], 0) or MF.NeSettingNum(words[4], 0)
						or MF.NeSettingNum(words[5], 0)) and true,
					RepWorld = tonumber(words[3]),
					RepCont = tonumber(words[4]),
					RepMap = tonumber(words[5]),
					WorldGain = tonumber(words[6]),
					ContGain = tonumber(words[7]),
					MapGain = tonumber(words[8]),
					RepGuards = tonumber(words[9]),
					RepShops = tonumber(words[10]),
					RepNPC = words[11] == "x",
					LimUp = tonumber(words[12]),
					LimBot = tonumber(words[13]),
					MapLimUp = tonumber(words[14]),
					MapLimBot = tonumber(words[15]),
					MapDecMult = tonumber(words[16]),
					MapDecFlat = tonumber(words[17]),
					MapDecMin = tonumber(words[18]),
					MapDec2Mult = tonumber(words[19]),
					MapDec2Flat = tonumber(words[20]),
					MapDec2Min = tonumber(words[21]),
					MapDecLimUp = tonumber(words[22]),
					MapDecLimBot = tonumber(words[23]),
					TradeMult = tonumber(words[24]),
					DonateCMult = tonumber(words[25]),
					DonateMod = tonumber(words[26]),
					DonateNegMod = tonumber(words[27]),
					DonateLim = tonumber(words[28]),
					DonateNegLim = tonumber(words[29]),
					DonateNegLim2 = tonumber(words[30]),
					DonateMapLim = tonumber(words[31]),
					DonateMapNegLim = tonumber(words[32]),
					DonateMapNegLim2 = tonumber(words[33]),
					DonateWorldGain = tonumber(words[34]),
					DonateContGain = tonumber(words[35]),
					DonateMapGain = tonumber(words[36]),
					DonateSpells = tonumber(words[37]),
					RepRanks = tonumber(words[38]),
					BHWorldGain = tonumber(words[39]),
					BHContGain = tonumber(words[40]),
					BHMapGain = tonumber(words[41]),
					PenKillPeas = tonumber(words[42]),
					PenKillGuard = tonumber(words[43]),
					FineKillPeasFlat = tonumber(words[44]),
					FineKillGuardFlat = tonumber(words[45]),
					FineKillPeasLvlMult = tonumber(words[46]),
					FineKillGuardLvlMult = tonumber(words[47]),
					FineKillPeasRepMult = tonumber(words[48]),
					FineKillGuardRepMult = tonumber(words[49]),
					PenStealSShop = tonumber(words[50]),
					PenStealSPeas = tonumber(words[51]),
					PenStealSGuard = tonumber(words[52]),
					PenStealUShop = tonumber(words[53]),
					PenStealUPeas = tonumber(words[54]),
					PenStealUGuard = tonumber(words[55]),
					PenStealCShop = tonumber(words[56]),
					PenStealCPeas = tonumber(words[57]),
					PenStealCGuard = tonumber(words[58]),
					FineStealCShop = tonumber(words[59]),
					FineStealCPeas = tonumber(words[60]),
					FineStealCGuard = tonumber(words[61]),
					BegPen = tonumber(words[62]),
					BribePen = tonumber(words[63]),
					ThreatPen = tonumber(words[64]),
					BegFailPen = tonumber(words[65]),
					BribeFailPen = tonumber(words[66]),
					ThreatFailPen = tonumber(words[67])
				}
				eff_lines_m = eff_lines_m + 1
			end
		end
	end
	io.close(rep_txt)
end

---------------------------------------
-- Base functions
local function reputation_read()
	return mem.call(0x47603F)
end
NPCFollowers.GetPartyReputation = reputation_read
MF.GetReputation = reputation_read
MF.ReputationRead = reputation_read
local GetPartyReputation = reputation_read

MO.ReputationWrite = asmproc([[
cmp dword ptr [0x6F39A0], 2
mov eax, 0x6CF09C
jz @outdoor
mov eax, 0x6F3CCC
@outdoor:
add eax, 8
mov dword ptr [eax], ecx
retn]])

local function reputation_write(value)
	mem.call(MO.ReputationWrite, 1, value)
end
MF.ReputationWrite = reputation_write

-- Scope: 0 - local; 1 - map; 2 - continent; 3 - world
local function reputation_set(value, source, scope, target)
	Log(Merge.Log.Info, "%s: ReputationSet [%d:%d] %f, source %d", LogId, scope or -1, target or -1, value, source or -1)
	if not scope or scope == 0 then
		reputation_write(value)
	elseif scope == 1 then
		if not target then return end
		local src = MT.Reputation.Maps[target] or MT.Reputation.Continents[MF.GetContinent(target)]
		local lb, lu = src.MapLimBot, src.MapLimUp
		value = max(min(value, lu), lb)
		vars.GlobalReputation.Maps[target] = value
	elseif scope == 2 then
		if not target then return end
		local rep = vars.GlobalReputation.Continents[target] or 0
		local src = MT.Reputation.Continents[target]
		local lb, lu = src.ContLimBot, src.ContLimUp
		value = max(min(value, lu), lb)
		vars.GlobalReputation.Continents[target] = value
	elseif scope == 3 then
		if not target then return end
		local rep = vars.GlobalReputation.Worlds[target] or 0
		local src = MT.Reputation.Worlds[target]
		local lb, lu = src.WorldLimBot, src.WorldLimUp
		value = max(min(value, lu), lb)
		vars.GlobalReputation.Worlds[target] = value
	else
	end
end

local function reputation_recalc(save)
	local src = MT.Reputation.Maps[MV.Map] or MT.Reputation.Continents[MV.Continent]
	if not src.UseRep then return end
	local m1 = src.RepMap or 0
	local m2 = src.RepCont or 0
	local m3 = src.RepWorld or 0
	-- FIXME
	vars.GlobalReputation.Maps = vars.GlobalReputation.Maps or {}
	local r1 = vars.GlobalReputation.Maps[MV.Map]
	local r2 = vars.GlobalReputation.Continents[MV.Continent]
	local r3 = vars.GlobalReputation.Worlds[MV.World]
	local old = reputation_read()
	if not r1 and m1 > 0.5 and src.MapGain > 0.5 then
		r1 = old
		vars.GlobalReputation.Maps[MV.Map] = r1
	end
	-- set to 0 if nil?
	local res = m1 * (r1 or 0) + m2 * (r2 or 0) + m3 * (r3 or 0)
	local lb, lu = src.LimBot, src.LimUp
	res = ceil(max(min(res, lu), lb))
	if save then
		reputation_write(res)
	end
	return res, old
end
MF.ReputationRecalc = reputation_recalc

-- Source: 1 - bounty hunt; 2 - evt; 3 - script
-- Scope: 0 - local; 1 - map; 2 - continent; 3 - world
local function reputation_add(value, source, scope, target, norecalc)
	Log(Merge.Log.Info, "%s: ReputationAdd [%d:%d] %f, source %d", LogId, scope or -1, target or -1, value, source or -1)
	if not scope or scope == 0 then
		local src = MT.Reputation.Maps[MV.Map] or MT.Reputation.Continents[MV.Continent]
		local src2 = MT.Reputation.Continents[MV.Continent]
		local src3 = MT.Reputation.Worlds[MV.World]
		local m1, m2, m3
		local lb1, lb2, lb3 = src.MapLimBot, src2.ContLimBot, src3.WorldLimBot
		local lu1, lu2, lu3 = src.MapLimUp, src2.ContLimUp, src3.WorldLimUp
		if source == 1 then
			-- Bounty Hunt
			m1 = src.BHMapGain or 0
			m2 = src.BHContGain or 0
			m3 = src.BHWorldGain or 0
		else
			m1 = src.MapGain or 0
			m2 = src.ContGain or 0
			m3 = src.WorldGain or 0
		end
		local r1 = vars.GlobalReputation.Maps[MV.Map] or 0
		local r2 = vars.GlobalReputation.Continents[MV.Continent] or 0
		local r3 = vars.GlobalReputation.Worlds[MV.World] or 0
		r1 = max(min(r1 + m1 * value, lu1), lb1)
		r2 = max(min(r2 + m2 * value, lu2), lb2)
		r3 = max(min(r3 + m3 * value, lu3), lb3)
		vars.GlobalReputation.Maps[MV.Map] = r1
		vars.GlobalReputation.Continents[MV.Continent] = r2
		vars.GlobalReputation.Worlds[MV.World] = r3
		if not norecalc then
			return reputation_recalc(true)
		end
	elseif scope == 1 then
		local src = MT.Reputation.Maps[target] or MT.Reputation.Continents[MF.GetContinent(target)]
		local r1 = vars.GlobalReputation.Maps[target] or 0
		r1 = max(min(r1 + value, src.MapLimUp), src.MapLimBot)
		vars.GlobalReputation.Maps[target] = r1
		if target == MV.Map and not norecalc then
			return reputation_recalc(true)
		end
	elseif scope == 2 then
		local src = MT.Reputation.Continents[target]
		local r1 = vars.GlobalReputation.Continents[target] or 0
		r1 = max(min(r1 + value, src.ContLimUp), src.ContLimBot)
		vars.GlobalReputation.Continents[target] = r1
		if target == MV.Continent and not norecalc then
			return reputation_recalc(true)
		end
	elseif scope == 3 then
		local src = MT.Reputation.Worlds[target]
		local r1 = vars.GlobalReputation.Worlds[target] or 0
		r1 = max(min(r1 + value, src.WorldLimUp), src.WorldLimBot)
		vars.GlobalReputation.Worlds[target] = r1
		if target == MV.World and not norecalc then
			return reputation_recalc(true)
		end
	else
	end
end
MF.ReputationAdd = reputation_add

local function reputation_sub(value, source, scope, target, norecalc)
	return reputation_add(-value, source, scope, target, norecalc)
end
MF.ReputationSub = reputation_sub
MF.ReputationSubtract = reputation_sub

---------------------------------------
-- Hooks
---------------------------------------
-- Reputation Max Rank
local function get_reputation_max_rank()
	local rep_ranks = rep_set.RepRanks
	if not rep_ranks then
		return 0
	elseif rep_ranks == 1 then
		return 5
	elseif rep_ranks == 3 then
		return 5
	elseif rep_ranks == 4 then
		return 6
	end
end
MF.GetReputationMaxRank = get_reputation_max_rank
-- Reputation Min Rank
local function get_reputation_min_rank()
	local rep_ranks = rep_set.RepRanks
	if not rep_ranks then
		return 0
	elseif rep_ranks == 1 then
		return -5
	elseif rep_ranks == 3 then
		return -5
	elseif rep_ranks == 4 then
		return -5
	end
end
MF.GetReputationMinRank = get_reputation_min_rank

-- Reputation Rank
local function get_reputation_rank(reputation)
	reputation = reputation or reputation_read()
	local t = {Reputation = reputation, Rank = 0}
	local rep_ranks = rep_set.RepRanks
	local max_rank, min_rank = get_reputation_max_rank(), get_reputation_min_rank()
	if not rep_ranks then
		t.Rank = 0
	elseif rep_ranks == 1 then
		--max_rank, min_rank = 5, -5
		if reputation <= -25 then
			t.Rank = -5
		elseif reputation <= -20 then
			t.Rank = -4
		elseif reputation <= -15 then
			t.Rank = -3
		elseif reputation <= -10 then
			t.Rank = -2
		elseif reputation < -5 then
			t.Rank = -1
		elseif reputation >= 25 then
			t.Rank = 5
		elseif reputation >= 20 then
			t.Rank = 4
		elseif reputation >= 15 then
			t.Rank = 3
		elseif reputation >= 10 then
			t.Rank = 2
		elseif reputation > 5 then
			t.Rank = 1
		end
	elseif rep_ranks == 3 then
		--max_rank, min_rank = 5, -5
		if reputation <= -1000 then
			t.Rank = -5
		elseif reputation <= -800 then
			t.Rank = -4
		elseif reputation <= -600 then
			t.Rank = -3
		elseif reputation <= -400 then
			t.Rank = -2
		elseif reputation <= -200 then
			t.Rank = -1
		elseif reputation >= 1000 then
			t.Rank = 5
		elseif reputation >= 800 then
			t.Rank = 4
		elseif reputation >= 600 then
			t.Rank = 3
		elseif reputation >= 400 then
			t.Rank = 2
		elseif reputation >= 200 then
			t.Rank = 1
		end
	elseif rep_ranks == 4 then
		--max_rank, min_rank = 6, -5
		if reputation <= -1000 then
			t.Rank = -5
		elseif reputation <= -800 then
			t.Rank = -4
		elseif reputation <= -600 then
			t.Rank = -3
		elseif reputation <= -400 then
			t.Rank = -2
		elseif reputation <= -200 then
			t.Rank = -1
		elseif reputation >= 1000 then
			t.Rank = 6
		elseif reputation >= 800 then
			t.Rank = 5
		elseif reputation >= 600 then
			t.Rank = 4
		elseif reputation >= 400 then
			t.Rank = 3
		elseif reputation >= 200 then
			t.Rank = 2
		elseif reputation > 0 then
			t.Rank = 1
		end
	end
	events.call("GetReputationRank", t)
	t.Rank = max(min(t.Rank, max_rank), min_rank)
	return t.Rank
end
MF.GetReputationRank = get_reputation_rank

---------------------------------------
-- Reputation Rank Str
NewCode = asmpatch(0x493753, [[
nop
nop
nop
nop
nop
test eax, eax
jz @std
retn
@std:
cmp ecx, 0x19
jl absolute 0x49375E
]])

hook(NewCode, function(d)
	local t = {
		Reputation = d.ecx,
		Ptr = 0
	}
	t.Rank = MF.GetReputationRank(t.Reputation)
	events.call("GetReputationRankStr", t)
	d.eax = t.Ptr
end)

---------------------------------------
-- Temple Donation events
--   Donation cost
autohook(0x4B5B3D, function(d)
	local t = {Cost = d.ecx}
	t.HouseId = MF.GetCurrentHouse()
	events.call("DonationCost", t)
	d.ecx = t.Cost
end)

local function donation_reputation(HouseId)
	local house = Game.Houses[HouseId]
	local src = MT.Reputation.Maps[MV.Map] or MT.Reputation.Continents[MV.Continent]
	local src2 = MT.Reputation.Continents[MV.Continent]
	local src3 = MT.Reputation.Worlds[MV.World]
	local r1 = vars.GlobalReputation.Maps[MV.Map] or 0
	local r2 = vars.GlobalReputation.Continents[MV.Continent] or 0
	local r3 = vars.GlobalReputation.Worlds[MV.World] or 0
	local m1, m2, m3 = src.DonateMapGain, src.DonateContGain, src.DonateWorldGain
	if bit.band(house.C, 1) > 0 then
		local bot1, bot2, bot3 = src.DonateMapNegLim, src2.DonateContNegLim, src3.DonateWorldNegLim
		local up1, up2, up3 = src.DonateMapNegLim2, src2.DonateContNegLim2, src3.DonateWorldLim
		local r, m, bot0, up0, value
		if src.DonateNegLim then
			-- TODO
		elseif bot1 then
			r = r1
			m = m1
			bot0 = bot1
			up0 = up1
		elseif bot2 then
			r = r2
			m = m2
			bot0 = bot2
			up0 = up2
		else
		end
		if r < bot0 then
			if r + src.DonateNegMod * m <= bot0 then
				value = src.DonateNegMod
			else
				value = (bot0 - r) / m
			end
			if not bot1 or r1 + value * m1 < bot1 then
				vars.GlobalReputation.Maps[MV.Map] = r1 + value * m1
			elseif r1 < bot1 then
				vars.GlobalReputation.Maps[MV.Map] = bot1
			end
			if not bot2 or r2 + value * m2 < bot2 then
				vars.GlobalReputation.Continents[MV.Continent] = r2 + value * m2
			elseif r2 < bot2 then
				vars.GlobalReputation.Continents[MV.Continent] = bot2
			end
			if not bot3 or r3 + value * m3 < bot3 then
				vars.GlobalReputation.Worlds[MV.World] = r3 + value * m3
			elseif r3 < bot3 then
				vars.GlobalReputation.Worlds[MV.World] = bot3
			end
			return reputation_recalc(true)
		elseif r > up0 then
			if r - src.DonateNegMod * m >= up0 then
				value = -src.DonateNegMod
			else
				value = (r - up0) / m
			end
			if not up1 or r1 + value * m1 > up1 then
				vars.GlobalReputation.Maps[MV.Map] = r1 + value * m1
			elseif r1 > up1 then
				vars.GlobalReputation.Maps[MV.Map] = up1
			end
			if not up2 or r2 + value * m2 > up2 then
				vars.GlobalReputation.Continents[MV.Continent] = r2 + value * m2
			elseif r2 > up2 then
				vars.GlobalReputation.Continents[MV.Continent] = up2
			end
			if not up3 or r3 + value * m3 > up3 then
				vars.GlobalReputation.Worlds[MV.World] = r3 + value * m3
			elseif r3 > up3 then
				vars.GlobalReputation.Worlds[MV.World] = up3
			end
			return reputation_recalc(true)
		end
	else
		local lim1, lim2, lim3 = src.DonateMapLim, src2.DonateContLim, src3.DonateWorldLim
		local r, lim, m, value
		if src.DonateLim then
			-- TODO
		elseif lim1 then
			r = r1
			m = m1
			lim = lim1
		elseif lim2 then
			r = r2
			m = m2
			lim =lim2
		else
		end
		if not lim then
			lim = -5
		end
		if r <= lim then
			return
		end
		if r + src.DonateMod * m >= lim then
			value = src.DonateMod
		else
			value = (lim - r) / m
		end
		if not lim1 or r1 + value * m1 > lim1 then
			vars.GlobalReputation.Maps[MV.Map] = r1 + value * m1
		elseif r1 > lim1 then
			vars.GlobalReputation.Maps[MV.Map] = lim1
		end
		if not lim2 or r2 + value * m2 > lim2 then
			vars.GlobalReputation.Continents[MV.Continent] = r2 + value * m2
		elseif r2 > lim2 then
			vars.GlobalReputation.Continents[MV.Continent] = lim2
		end
		if not lim3 or r3 + value * m3 > lim3 then
			vars.GlobalReputation.Worlds[MV.World] = r3 + value * m3
		elseif r3 > lim3 then
			vars.GlobalReputation.Worlds[MV.World] = lim3
		end
		return reputation_recalc(true)
	end
end

--   Donation Reputation change
NewCode = asmpatch(0x4B5B4C, [[
mov ecx, dword ptr [0x518678]
nop
nop
nop
nop
nop
]], 0x4B5B74 - 0x4B5B4C)

hook((NewCode or 0x4B5B4C) + 6, function(d)
	local t = {}
	t.CurrentValue, t.PreviousValue = donation_reputation(d.ecx)
	if t.CurrentValue ~= t.PreviousValue then
		events.call("ReputationChanged", t)
	end
end)

--[=[
NewCode = asmpatch(0x4B5B62, [[
nop
nop
nop
nop
nop
cmp ecx, edx
jg @rep
push ecx
push ecx
jmp absolute 0x4B5B74
@rep:
sub ecx, edi
mov edi, dword ptr [eax+8]
cmp ecx, edx
mov dword ptr [eax+8], ecx
jge @end
mov dword ptr [eax+8], edx
@end:
mov eax, dword ptr [eax+8]
push edi
push eax
nop
nop
nop
nop
nop
]])
nop2(0x4B5B67, 0x4B5B74)

hook(NewCode, function(d)
	local t = {Limit = -5, Subtractor = 1, Reputation = d.ecx}
	events.call("DonationReputationChange", t)
	d.edx = t.Limit
	d.edi = t.Subtractor
end)

hook(NewCode + 0x24, function(d)
	local t = {CurrentValue = d.eax, PreviousValue = d.edi}
	events.call("ReputationChanged", t)
end)
]=]

--   Donation Spell
--     ecx/byte[ebp-1] - amount of donations prev. made
--     edx - day of the week (0..6) (also SkillValue-1)
--NewCode = asmpatch(0x4B5B96, [[
--;pop eax
--;pop edi
NewCode = asmpatch(0x4B5B96, [[
nop
nop
nop
nop
nop
test eax, eax
jnz @spell
mov edi, dword ptr [0x519350]
mov al, byte ptr [ebp-1]
jmp absolute 0x4B5BBD
@spell:
push ebx
push 0x30
push edx
mov edi, dword ptr [0x519350]
lea edx, [edi-1]
mov edx, dword ptr [edx*4+0xB7CA4C]
]])
nop2(0x4B5B9B, 0x4B5BAB)

--hook(NewCode + 2, function(d)
hook(NewCode, function(d)
	local t = {
		Spell = 0x56, SkillLevel = d.edx + 1, SkillMastery = 3,
		--Reputation = d.eax, PreviousReputation = d.edi,
		Reputation = reputation_read(),
		DonationsMade = d.ecx, DonationsRequired = d.edx,
		Caster = Game.CurrentPlayer, Cast = d.ecx >= d.edx
	}
	t.Rank = MF.GetReputationRank(t.Reputation)
	events.call("DonationSpell", t)
	d.eax = t.Cast and 1 or 0
	d.ecx = t.Spell
	d.edx = JoinSkill(t.SkillLevel, t.SkillMastery)
end)

---------------------------------------
-- Merchant reputation effect
autohook2(0x4902B9, function(d)
	local t = {RepTradeEffect = d.eax}
	events.call("ReputationTradeEffect", t)
	if tonumber(MM.ReputationMaxTradeEffect) then
		t.RepTradeEffect = max(t.RepTradeEffect, -tonumber(MM.ReputationMaxTradeEffect))
	end
	d.eax = t.RepTradeEffect
end)

---------------------------------------
-- Functions and events
---------------------------------------

local function ChangeGuardsState(State)
	for i,v in Map.Monsters do
		if v.Group == 38 or v.Group == 55 then -- default groups for map guards.
			v.Hostile = State
		end
	end
end

local function GetFameBase()
	local CurCont = TownPortalControls.MapOfContinent(Map.MapStatsIndex)
	if MV.Continent == 4 then
		return Party[0].Experience
	else
		local Total = 0

		for k,v in pairs(vars.ContinentFame) do
			Total = Total + v
		end

		local res = Party[0].Experience - Total + (vars.ContinentFame[MV.Continent] or 0)
		vars.ContinentFame[MV.Continent] = res

		return res
	end
end

local function GetPartyFame()
	return Party.GetFame()
end
NPCFollowers.GetPartyFame = GetPartyFame

local function StoreReputation()
--[[
	local CurCont = TownPortalControls.MapOfContinent(Map.MapStatsIndex)

	local cur_rep = vars.GlobalReputation.Continents[CurCont]
	cur_rep = (cur_rep and (cur_rep - ceil(cur_rep)) or 0) + GetPartyReputation()
	vars.GlobalReputation.Continents[CurCont] = cur_rep
]]
end

function events.GetFameBase(t)
	t.Base = GetFameBase() or 0
end

local PEASANT = const.Bolster.Creed.Peasant
function events.MonsterKilled(mon, monIndex, defaultHandler, killer)

	if not (rep_set.UseRep or rep_set.PenKillPeas or rep_set.PenKillGuard) then
		return
	end

	-- affect reputation only if monster killed by party or party ally,
	-- and monster was not reanimated.
	if (killer.Type == 4 or killer.Type == 3 and killer.Monster.Ally == 9999)
			and mon.Ally ~= 9999 then
		local CurCont = TownPortalControls.MapOfContinent(Map.MapStatsIndex)
		local MonExtra = Game.Bolster.MonstersSource[mon.Id]
		local ContRep = vars.GlobalReputation.Continents[CurCont]

		evt.ForPlayer(0)

		local rep_changed = false
		-- Subtract Reputation if peasant killed (peasants can not be bounty hunt targets or arena participants).
		if MonExtra.Creed == PEASANT and rep_set.PenKillPeas
				and mon.NameId ~= 123 then -- Q
			evt.Add("Reputation", rep_set.PenKillPeas)
			rep_changed = true
		end
		if (mon.Group == 38 or mon.Group == 55) and rep_set.PenKillGuard then
			evt.Add("Reputation", rep_set.PenKillGuard)
			rep_changed = true
		end
		if rep_changed then
			--if not evt.Cmp{"Reputation", 100} then -- Don't drop reputation below 100.
			--	evt.Add{"Reputation", 1} -- Add and Sub kind of reverted for reputation.

			--	if ContRep < 20 then
			--		vars.GlobalReputation.Continents[CurCont] = ContRep + 1
			--		evt.Add{"Reputation", 1} -- Let party get murderer reputation across continent
			--	end
			--end

			local PartyRep = GetPartyReputation()

			if rep_set.RepGuards and PartyRep >= rep_set.RepGuards then
				ChangeGuardsState(true)
			end

			return
		end

		if not rep_set.UseRep then return end
		-- Increase Reputation if monster is bounty hunt target.
		local BH = vars.BountyHunt and vars.BountyHunt[Map.Name]
		if BH and not BH.Done and BH.MonId == mon.Id then
			local Reward = math.floor(mon.Level/20)

			if evt.Cmp{"Reputation", -20} then
				evt.Subtract{"Reputation", Reward}
			end

			-- Let party adjust global reputation by BH quests.
			if ContRep > -5 then
				vars.GlobalReputation.Continents[CurCont] = ContRep - 1
			end

			return
		end

	end

end

function events.ClickShopTopic(t)

	if not rep_set.UseRep then
		return
	end

	local Rep = GetPartyReputation()
	if Rep > 0 then
		local cHouse = Game.Houses[t.HouseId]

		if t.Topic == const.ShopTopics.Donate and cHouse.C == 0 then

		--	local Amount = Game.Houses[t.HouseId].Val
		--	local cGold = Party.Gold
		--	if Party.Gold >= Amount then
		--		if Rep > 0 then
		--			Party.Gold = cGold - math.min((math.floor(Amount*Rep/5)), cGold) + Amount
		--		end

		--		if rep_set.RepGuards and Rep < rep_set.RepGuards then
		--			ChangeGuardsState(false)
		--		end
		--	end

		elseif table.find({const.HouseType.Boats, const.HouseType.Stables, const.HouseType.Temple}, cHouse.Type) then
			return

		elseif rep_set.RepShops and Rep > rep_set.RepShops then
			t.Handled = true
			ShowBanText()

		end
	end
end

function events.BeforeSaveGame()
	--StoreReputation()
end

function events.LeaveMap()
	--StoreReputation()
end

function events.LoadMap()
	reputation_recalc(true)
end

function events.AfterLoadMap()

	local CurCont = MV.Continent

	ContSet = Game.ContinentSettings[MV.Continent]
	rep_set = MT.Reputation.Maps[MV.Map] or MT.Reputation.Continents[MV.Continent]

	if not rep_set.UseRep then
		return
	end

	vars.GlobalReputation.Continents[CurCont] = vars.GlobalReputation.Continents[CurCont] or 0

	local State

	-- Separate reputation by continents
	--local CurRep = ceil(vars.GlobalReputation.Continents[CurCont])
	local CurRep = reputation_read()

	--evt.Set{"Reputation", CurRep}

	-- Make guards aggressive
	if rep_set.RepGuards then
		State = CurRep >= rep_set.RepGuards
		ChangeGuardsState(State)
	end

end

local ht = const.HouseType
-- Close shops for party with bad reputation
function events.OnEnterShop(t)
	if rep_set.RepShops then
		local house = Game.Houses[t.HouseId]
		if table.find({ht.Boats, ht.Stables, ht.Temple}, house.Type) then
			return
		end
		t.Banned = GetPartyReputation() >= rep_set.RepShops
	end
end

function events.ReputationTradeEffect(t)
	if not rep_set.UseRep then
		return
	end
	if rep_set.TradeMult then
		t.RepTradeEffect = ceil(t.RepTradeEffect * rep_set.TradeMult)
	end
end

function events.ReputationChanged(t)
	if rep_set.RepGuards then
		State = t.CurrentValue >= rep_set.RepGuards
		ChangeGuardsState(State)
	end
end

function events.DonationCost(t)
	if not rep_set.UseRep then
		return
	end
	local cur_rep = GetPartyReputation()
	if cur_rep <= 0 then
		return
	end
	local house = Game.Houses[t.HouseId]
	if bit.band(house.C, 1) == 0 then
		local amount = house.Val
		-- Default multiplier was 0.2
		if rep_set.DonateCMult then
			t.Cost = max(amount, floor(amount * cur_rep * rep_set.DonateCMult))
		end
	end
end

--[[
function events.DonationReputationChange(t)
	if rep_set.DonateMod then
		t.Subtractor = -rep_set.DonateMod
	end
	if rep_set.DonateLim then
		t.Limit = rep_set.DonateLim
	end
end
]]

function events.DonationSpell(t)
	if not rep_set.DonateSpells then
		return
	end
	if rep_set.DonateSpells == 2 then
		if t.Reputation <= -25 then
			t.Spell = 85
		elseif t.Reputation <= -20 then
			t.Spell = 86
		elseif t.Reputation <= -15 then
			t.Spell = 75
		elseif t.Reputation <= -10 then
			t.Spell = 50
		else
			t.Cast = false
		end
	elseif rep_set.DonateSpells == 3 then
		if t.Rank <= -5 then
			t.Spell = 85
		elseif t.Rank == -4 then
			t.Spell = 86
		elseif t.Rank == -3 then
			t.Spell = 83
		else
			t.Cast = false
		end
	elseif rep_set.DonateSpells == 4 then
		if t.Rank <= -5 then
			t.Spell = 85
		elseif t.Rank == -4 then
			t.Spell = 86
		elseif t.Rank == -3 then
			t.Spell = 75
		elseif t.Rank == -2 then
			t.Spell = 50
		else
			t.Cast = false
		end
	end
	Log(Merge.Log.Info, "%s: Reputation %d, Rank %d, Temple Spell %d",
		LogId, t.Reputation, t.Rank, t.Spell)
end

local function get_reputation_rank_str(t)
	if not rep_set.RepRanks then
		return
	end
	if rep_set.RepRanks == 1 then
		if t.Rank > 4 then
			t.Ptr = u4[0x601448 + 379 * 4]
		elseif t.Rank > 0 then
			t.Ptr = u4[0x601448 + 392 * 4]
		elseif t.Rank > -1 then
			t.Ptr = u4[0x601448 + 399 * 4]
		elseif t.Rank > -5 then
			t.Ptr = u4[0x601448 + 402 * 4]
		else
			t.Ptr = u4[0x601448 + 434 * 4]
		end
	elseif rep_set.RepRanks == 3 then
		if t.Rank > -6 and t.Rank < 6 then
			t.Ptr = u4[0x601448 + (515 + t.Rank) * 4]
		else
			t.Ptr = u4[0x601448 + 515 * 4]
		end
	elseif rep_set.RepRanks == 4 then
		if t.Rank == 1 then
			t.Ptr = u4[0x601448 + 392 * 4]
		elseif t.Rank > -6 and t.Rank < 1 then
			t.Ptr = u4[0x601448 + (515 + t.Rank) * 4]
		elseif t.Rank > 1 and t.Rank < 7 then
			t.Ptr = u4[0x601448 + (514 + t.Rank) * 4]
		else
			t.Ptr = u4[0x601448 + 515 * 4]
		end
	end
end

events.GetReputationRankStr = get_reputation_rank_str

MF.GetReputationRankStr = function(rep)
	rep = rep or reputation_read()
	local t = {Rank = get_reputation_rank(rep), Reputation = rep}
	get_reputation_rank_str(t)
	if t.Ptr > 0 then
		return mem.string(t.Ptr)
	end
end

local function calc_dec_reputation(rep, dec_mult, dec_flat, dec_min, lim_bot, lim_up, days)
	if not days or days < 1 then
		return rep
	end
	--Log(Merge.Log.Info, "calc_dec_rep: %f, %f, %f, %d, %d, %d", dec_mult, dec_flat, dec_min, lim_bot, lim_up, days)
	dec_mult = dec_mult or 0
	dec_flat = dec_flat or 0
	dec_min = dec_min or 0
	if lim_bot and rep < lim_bot then
		--Log(Merge.Log.Info, "calc_dec_rep: bottom; %f, %f, %f", dec_mult, dec_flat, dec_min)
		dec_flat = -dec_flat
		dec_min = -dec_min
		for i = 1, days do
			--Log(Merge.Log.Info, "calc_dec_rep: [%d] %f", i, rep)
			if rep >= lim_bot then
				rep = lim_bot
				break
			end
			local new_rep = rep
			if dec_flat ~= 0 then
				new_rep = new_rep - dec_flat
				if new_rep >= lim_bot then
					rep = lim_bot
					break
				end
			end
			--Log(Merge.Log.Info, "calc_dec_rep: [%d] flat: %f", i, new_rep)
			if dec_mult ~= 0 then
				new_rep = new_rep * (1 - dec_mult)
				if new_rep >= lim_bot then
					rep = lim_bot
					break
				end
			end
			--Log(Merge.Log.Info, "calc_dec_rep: [%d] mult: %f", i, new_rep)
			if dec_min ~= 0 then
				if rep - new_rep > dec_min then
					rep = rep - dec_min
					if rep >= lim_bot then
						rep = lim_bot
						break
					end
				else
					rep = new_rep
				end
			else
				rep = new_rep
			end
		end
	elseif lim_up and rep > lim_up then
		--Log(Merge.Log.Info, "calc_dec_rep: upper")
		for i = 1, days do
			if rep <= lim_up then
				rep = lim_up
				break
			end
			local new_rep = rep
			if dec_flat ~= 0 then
				new_rep = new_rep - dec_flat
				if new_rep <= lim_up then
					rep = lim_up
					break
				end
			end
			if dec_mult ~= 0 then
				new_rep = new_rep * (1 - dec_mult)
				if new_rep <= lim_up then
					rep = lim_up
					break
				end
			end
			if dec_min ~= 0 then
				if rep - new_rep < dec_min then
					rep = rep - dec_min
					if rep <= lim_up then
						rep = lim_up
						break
					end
				else
					rep = new_rep
				end
			else
				rep = new_rep
			end
		end
	end
	return rep
end
MF.CalcDecRep = calc_dec_reputation

function events.NewDay(t)
	if t.Type == 1 or t.Type == 2 then
		--Log(Merge.Log.Info, "%s: dec reputation", LogId)
		local days = t.GameDay - t.PrevGameDay
		for k, rep in pairs(vars.GlobalReputation.Worlds) do
			--Log(Merge.Log.Info, "%s: dec reputation: world %d - %s", LogId, k, tostring(rep) or "nil")
			v1 = MT.Reputation.Worlds[k]
			local dec1_mult, dec_flat, dec_min
			if t.Type == 1 then
				dec1_mult = v1.WorldDecMult
				dec_flat = v1.WorldDecFlat
				dec_min = v1.WorldDecMin
			elseif t.Type == 2 then
				dec1_mult = v1.WorldDec2Mult or 0
				dec_flat = v1.WorldDec2Flat or 0
				dec_min = v1.WorldDec2Min or 0
			end
			--Log(Merge.Log.Info, "dec_rep: world; %f, %f, %f", dec1_mult, dec_flat, dec_min)
			if not rep then
				-- Skip
				--Log(Merge.Log.Info, "%s: dec reputation: skip world %d: no rep", LogId, k)
			elseif dec_mult == 0 and dec_flat == 0 then
				-- Skip
				--Log(Merge.Log.Info, "%s: dec reputation: skip world %d: no dec", LogId, k)
			elseif v1.WorldDecLimUp and rep > v1.WorldDecLimUp
					or v1.WorldDecLimBot and rep < v1.WorldDecLimBot then
				local old = rep
				rep = calc_dec_reputation(rep, dec1_mult, dec_flat, dec_min,
					v1.WorldDecLimBot, v1.WorldDecLimUp, days)
				vars.GlobalReputation.Worlds[k] = rep
				--Log(Merge.Log.Info, "%s: dec reputation: world %d: %f to %f", LogId, k, old, rep)
			else
				--Log(Merge.Log.Info, "%s: dec reputation: skip world %d: no need", LogId, k)
			end
		end
		for k, rep in pairs(vars.GlobalReputation.Continents) do
			--Log(Merge.Log.Info, "%s: dec reputation: cont %d - %s", LogId, k, tostring(rep) or "nil")
			v = MT.Reputation.Continents[k]
			local dec_mult, dec_flat, dec_min
			if t.Type == 1 then
				dec_mult = v.ContDecMult or 0
				dec_flat = v.ContDecFlat or 0
				dec_min = v.ContDecMin or 0
			elseif t.Type == 2 then
				dec_mult = v.ContDec2Mult or 0
				dec_flat = v.ContDec2Flat or 0
				dec_min = v.ContDec2Min or 0
			end
			--Log(Merge.Log.Info, "dec_rep: cont; %f, %f, %f", dec_mult, dec_flat, dec_min)
			if not rep then
				-- Skip
				--Log(Merge.Log.Info, "%s: dec reputation: skip cont %d: no rep", LogId, k)
			elseif dec_mult == 0 and dec_flat == 0 then
				-- Skip
				--Log(Merge.Log.Info, "%s: dec reputation: skip cont %d: no dec", LogId, k)
			elseif v.ContDecLimUp and rep > v.ContDecLimUp
					or v.ContDecLimBot and rep < v.ContDecLimBot then
				local old = rep
				rep = calc_dec_reputation(rep, dec_mult, dec_flat, dec_min,
					v.ContDecLimBot, v.ContDecLimUp, days)
				vars.GlobalReputation.Continents[k] = rep
				--Log(Merge.Log.Info, "%s: dec reputation: cont %d: %f to %f", LogId, k, old, rep)
			else
				--Log(Merge.Log.Info, "%s: dec reputation: skip cont %d: no need", LogId, k)
			end
		end
		for k, rep in pairs(vars.GlobalReputation.Maps) do
			--Log(Merge.Log.Info, "%s: dec reputation: map %d - %s", LogId, k, tostring(rep) or "nil")
			v = MT.Reputation.Maps[k] or MT.Reputation.Continents[MF.GetContinent(k)]
			local dec_mult, dec_flat, dec_min
			if t.Type == 1 then
				dec_mult = v.MapDecMult or 0
				dec_flat = v.MapDecFlat or 0
				dec_min = v.MapDecMin or 0
			elseif t.Type == 2 then
				dec_mult = v.MapDec2Mult or 0
				dec_flat = v.MapDec2Flat or 0
				dec_min = v.MapDec2Min or 0
			end
			--Log(Merge.Log.Info, "dec_rep: map; %f, %f, %f", dec_mult, dec_flat, dec_min)
			if not rep then
				-- Skip
				--Log(Merge.Log.Info, "%s: dec reputation: skip map %d: no rep", LogId, k)
			elseif dec_mult == 0 and dec_flat == 0 then
				-- Skip
				--Log(Merge.Log.Info, "%s: dec reputation: skip map %d: no dec", LogId, k)
			elseif v.MapDecLimUp and rep > v.MapDecLimUp
					or v.MapDecLimBot and rep < v.MapDecLimBot then
				local old = rep
				rep = calc_dec_reputation(rep, dec_mult, dec_flat, dec_min,
					v.MapDecLimBot, v.MapDecLimUp, days)
				vars.GlobalReputation.Maps[k] = rep
				--Log(Merge.Log.Info, "%s: dec reputation: map %d: %f to %f", LogId, k, old, rep)
			else
				--Log(Merge.Log.Info, "%s: dec reputation: skip map %d: no need", LogId, k)
			end
		end
		--[[
		if rep_set.UseRep then
			StoreReputation()
		end
		for k, v in pairs(MT.Reputation.Continents) do
			if v.UseRep and (v.DecMult or v.DecFlat) then
				local cur_rep = vars.GlobalReputation.Continents[k]
				if cur_rep and cur_rep ~= 0 then
					for i = 1, t.GameDay - t.PrevGameDay do
						if cur_rep == 0 then
							break
						end
						local prev_rep = cur_rep
						if v.DecFlat then
							-- TODO: add skills and followers modifiers
							if cur_rep > v.DecFlat then
								cur_rep = cur_rep - v.DecFlat
							elseif cur_rep < -v.DecFlat then
								cur_rep = cur_rep - v.DecFlat
							else
								cur_rep = 0
							end
						end
						if v.DecMult and cur_rep ~= 0 then
							-- TODO: add skills and followers modifiers
							cur_rep = cur_rep * (1 - v.DecMult)
						end
						if v.DecMin and abs(prev_rep - cur_rep) < v.DecMin then
							if prev_rep > v.DecMin then
								cur_rep = prev_rep - v.DecMin
							elseif prev_rep < -v.DecMin then
								cur_rep = prev_rep + v.DecMin
							else
								cur_rep = 0
							end
						end
					end
					vars.GlobalReputation.Continents[k] = cur_rep
					evt.Set("Reputation", ceil(cur_rep))
				end
			end
		end
		]]
		reputation_recalc(true)
	end
end

function events.GameInitialized2()
	ProcessReputationTxt()
end

Log(Merge.Log.Info, "Init finished: %s", LogId)

