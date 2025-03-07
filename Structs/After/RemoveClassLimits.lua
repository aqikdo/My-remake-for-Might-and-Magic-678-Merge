local LogId = "RemoveClassLimits"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MT = Merge.Functions, Merge.ModSettings, Merge.Tables

local function SimpleReplacePtrs(t, CmdSize, OldOrigin, NewOrigin)
	local OldAddr
	for i, v in ipairs(t) do
		OldAddr = mem.u4[v + CmdSize]
		mem.u4[v + CmdSize] = NewOrigin + OldAddr - OldOrigin
	end
end

local StartingStatsStd = DataTables.StartingStats
local StartingSkillsStd = DataTables.StartingSkills
local SkillsStd = DataTables.Skills
local HPSPStd = DataTables.HPSP

function DataTables.StartingStats(str)

	if str then

		local OldCount = Game.Classes.StartingStats.count
		local NewCount = table.maxn(string.split(string.split(str, "\n")[1], "\9")) - 1

		if NewCount > OldCount then

			local NewPtr = mem.StaticAlloc(NewCount*4*7)
			local OldPtr = Game.Classes.StartingStats["?ptr"]


			mem.IgnoreProtection(true)

			SimpleReplacePtrs({
				0x4903d7, 0x4903ee, 0x490405, 0x49041c, 0x490433, 0x49044a, 0x490465, 0x4c6a22,
				0x4c6a65
				},
				4, OldPtr, NewPtr)

			SimpleReplacePtrs({
				0x48f6f9, 0x48f700, 0x48f70d, 0x48f88b, 0x48f892, 0x48f899, 0x48f8a0, 0x48faf6,
				0x48fb01, 0x48fb08, 0x48fb11, 0x48fb18, 0x4c6abe, 0x4c6afc
				},
				3, OldPtr, NewPtr)

			SimpleReplacePtrs({
				0x4c5a90, 0x4c5aa8, 0x4c5b04, 0x4c5b1c, 0x4c5b45, 0x4c5b5d, 0x4c5b89, 0x4c5ba1,
				0x4c5bcd, 0x4c5be5, 0x4c5c11, 0x4c5c25, 0x4c5c51, 0x4c5cab
				},
				2, OldPtr, NewPtr)

			mem.IgnoreProtection(false)

			internal.SetArrayUpval(Game.Classes.StartingStats, "count", NewCount)
			internal.SetArrayUpval(Game.Classes.StartingStats, "o", NewPtr)

		end

	end

	StartingStatsStd(str)

end

function DataTables.StartingSkills(str)

	if str then

		local OldCount = Game.ClassKinds.StartingSkills.count
		local NewCount = table.maxn(string.split(string.split(str, "\n")[1], "\9")) - 1

		if NewCount > OldCount then

			local NewPtr = mem.StaticAlloc(NewCount*Game.ClassKinds.StartingSkills[0].count)
			local OldPtr = Game.ClassKinds.StartingSkills["?ptr"]

			mem.IgnoreProtection(true)
			SimpleReplacePtrs({0x48f65c, 0x48f697, 0x48f6c4, 0x4904c8}, 3, OldPtr, NewPtr)
			mem.IgnoreProtection(false)

			internal.SetArrayUpval(Game.ClassKinds.StartingSkills, "count", NewCount)
			internal.SetArrayUpval(Game.ClassKinds.StartingSkills, "o", NewPtr)

		end

	end

	StartingSkillsStd(str)

end

function DataTables.Skills(str)

	if str then

		local OldCount = Game.Classes.Skills.count
		local NewCount = table.maxn(string.split(string.split(str, "\n")[1], "\9")) - 1

		if NewCount > OldCount then

			local NewPtr = mem.StaticAlloc(NewCount*Game.Classes.Skills[0].count)
			local OldPtr = Game.Classes.Skills["?ptr"]

			mem.IgnoreProtection(true)

			SimpleReplacePtrs({0x4171a0, 0x4b0e6b}, 4, OldPtr, NewPtr)

			SimpleReplacePtrs({
				0x4171ba, 0x4171c6, 0x4b0e99, 0x4b32ee, 0x4b33ea, 0x4b3f64, 0x4b4059, 0x4b4bb0,
				0x4b4ca7, 0x4b590d, 0x4b5a07, 0x4b6948, 0x4b6a43, 0x4b7bee, 0x4b7ce3, 0x4b82b2,
				0x4b83a7, 0x4b9382, 0x4b9477, 0x4bbcf1, 0x4b4df5, 0x4b4f8c, 0x4baf6c
				},
				3, OldPtr, NewPtr)

			mem.IgnoreProtection(false)

			internal.SetArrayUpval(Game.Classes.Skills, "count", NewCount)
			internal.SetArrayUpval(Game.Classes.Skills, "o", NewPtr)

		end

	end

	SkillsStd(str)

end

function DataTables.HPSP(str)

	if str then

		local OldCount = Game.Classes.Skills.count
		local NewCount = DataTables.ComputeRowCountInPChar(mem.topointer(str), 5) - 1

		if NewCount > OldCount then

			local NewSpace = mem.StaticAlloc(NewCount*5)
			local AddrTable = {{0x48d9be}, {0x48da71}, {0x48d9fe, 0x48f532}, {0x48da60, 0x48f51b}, {0x48da28}}

			mem.IgnoreProtection(true)

			mem.u1[0x48da23 + 2] = NewCount - 1

			for i,v in ipairs({"HPBase", "SPBase", "HPFactor", "SPFactor", "SPStats"}) do

				local NewPtr = NewSpace+(i-1)*NewCount

				SimpleReplacePtrs(AddrTable[i], 3, Game.Classes[v]["?ptr"], NewPtr)

				internal.SetArrayUpval(Game.Classes[v], "count", NewCount)
				internal.SetArrayUpval(Game.Classes[v], "o", NewPtr)

			end

			mem.IgnoreProtection(false)

		end

	end

	HPSPStd(str)

end

-- Remove Class.txt limits form EnglishT.lod
mem.autohook2(0x4558cf, function(d)

	local ClassCount = DataTables.ComputeRowCountInPChar(d.eax, 2) - 1

	local ClassDescTablePtr = mem.StaticAlloc(ClassCount*4*2+4)
	local NamesTablePtr = ClassDescTablePtr + ClassCount*4 + 4

	mem.IgnoreProtection(true)

	-- Descriptions
	SimpleReplacePtrs({0x416BC8, 0x417B8F - 1, 0x4333E7, 0x4558E2}, 3, 0x5e48f0, ClassDescTablePtr)
	mem.u4[0x455959+3] = ClassDescTablePtr + ClassCount*4

	-- Class names
	SimpleReplacePtrs({
				0x416BE1, 0x41A719, 0x41CA25, 0x4304B3, 0x4325D8, 0x432759,	0x4333F7, 0x4B0EC6,
				0x4B0ED5, 0x4B348E, 0x4B40FD, 0x4B4AB9, 0x4B4E0B, 0x4B4FA2, 0x4B504D, 0x4B5AAB,
				0x4B6AED, 0x4B7D87, 0x4B844B, 0x4B951B, 0x4BD5CA, 0x4C5812, 0x4C6BD0, 0x4C8EB1
				},
				3, 0xbb2fd0, NamesTablePtr)

	mem.u4[0x417B89 + 2] = NamesTablePtr

	mem.IgnoreProtection(false)

	mem.nop(0x4558f4, 1)
	mem.asmpatch(0x4558ed, [[
	call absolute 0x4db20e
	mov edi, dword [ss:ebp-0x18]
	add edi, ]] .. ClassCount*4+4 .. [[;
	inc eax
	mov dword [ds:edi], eax
	xor edi, edi]])

	internal.SetArrayUpval(Game["ClassNames"], "o", NamesTablePtr)
 	internal.SetArrayUpval(Game["ClassNames"], "count", ClassCount)

end)

-- Class kinds table
local function ProcessClassExtra()

	local ClassExtra = Game.ClassesExtra
	local KindStepConns = {}
	for k,v in pairs(ClassExtra) do
		KindStepConns[v.Kind] = KindStepConns[v.Kind] or {}
		KindStepConns[v.Kind][v.Step] = k
	end

	mem.hook(0x4b315b, function(d) d.edx = ClassExtra[d.eax].Step end)

	local function GetFirstStep(CurStep)
		local Kind = ClassExtra[CurStep].Kind
		return KindStepConns[Kind][1] or CurStep
	end

	local function GetNextStep(CurStep)
		local Step, Kind = ClassExtra[CurStep].Step, ClassExtra[CurStep].Kind
		return KindStepConns[Kind][Step+1] or CurStep
	end

	local function GetMaxStep(CurStep)
		if GetNextStep(CurStep) == CurStep then
			return CurStep
		end

		local Kind = ClassExtra[CurStep].Kind
		return KindStepConns[Kind][#KindStepConns[Kind]]
	end

	local function get_all_promos(t, Class, inc_self)
		if inc_self and not table.find(t, Class) then
			table.insert(t, Class)
		end
		if MT.ClassPromotions[Class] then
			for _, v in pairs(MT.ClassPromotions[Class]) do
				get_all_promos(t, v, true)
			end
		end
	end
	MF.GetAllPromos = get_all_promos

	local function CanLearnSkill(Skill, Class, Mastery, Player, PlayerIndex)
		local PID = math.max(Game.CurrentPlayer, 0)
		Player = Player or Party[PID]
		PlayerIndex = PlayerIndex or Party.PlayersIndexes[PID]
		local t = {Skill = Skill, Class = Class, Player = Player, PlayerIndex = PlayerIndex,
			MaxLevel = Game.Classes.Skills[Class][Skill], Mastery = Mastery}
		events.call("ShowSkillDescr", t)
		if Mastery == -1 then
			local max_level = t.MaxLevel
			local promos = {}
			get_all_promos(promos, Class)
			for _, v in pairs(promos) do
				t.Class = v
				t.MaxLevel = Game.Classes.Skills[v][Skill]
				events.call("ShowSkillDescr", t)
				if t.MaxLevel > max_level then
					max_level = t.MaxLevel
				end
			end
			t.MaxLevel = max_level
		end
		return t.MaxLevel
	end

	mem.nop(0x41719d, 3)
	mem.hook(0x4171a0, function(d) d.eax = CanLearnSkill(d.eax, d.edi) end)
	mem.nop(0x4171b5, 5)
	mem.hook(0x4171ba, function(d) d.ecx = CanLearnSkill(d.eax, d.edi) end)
	mem.hook(0x4171c6, function(d) d.eax = CanLearnSkill(d.eax, d.edi, -1) end)

	local max = math.max
	local tSkills = Game.Classes.Skills

	mem.asmpatch(0x41718b, "jmp absolute 0x4171b2")

	---- If class have branched promotions, show few possible promotion names.
	local function get_skill_promos(t1, t2, Skill, Mastery, Race, MinMaturity, MaxMaturity)
		MinMaturity = MinMaturity or 0
		MaxMaturity = MaxMaturity or MM.Races.MaxMaturity
		local t3 = {}
		if not t2 or table.isempty(t2) then
			return
		end
		for _, v in pairs(t2) do
			local found = false
			for i = MinMaturity, MaxMaturity do
				if MF.GetMaxSkillMastery(Race, v, Skill, i) >= Mastery then
					if not table.find(t1, v) then
						table.insert(t1, v)
					end
					found = true
					break
				end
			end
			if (not found) and MT.ClassPromotions[v] then
				for __, v1 in pairs(MT.ClassPromotions[v]) do
					if not table.find(t3, v1) then
						table.insert(t3, v1)
					end
				end
			end
		end
		get_skill_promos(t1, t3, Skill, Mastery, Race, MinMaturity, MaxMaturity)
	end
	MF.GetSkillPromos = get_skill_promos

	local function get_skill_promo_names(Class, Skill, Mastery)
		local PID = math.max(Game.CurrentPlayer, 0)
		local Player = Party[PID]
		--local PlayerIndex = Party.PlayersIndexes[PID]
		local min_maturity = Player.Attrs.Maturity or 0
		local max_maturity = MM.Races.MaxMaturity
		local cur_maturity
		for i = min_maturity + 1, MM.Races.MaxMaturity do
			if MF.GetMaxSkillMastery(Player.Attrs.Race, Class, Skill, i) >= Mastery then
				cur_maturity = i
				max_maturity = i - 1
				break
			end
		end
		local t1, t2 = {}, {}
		get_skill_promos(t1, MT.ClassPromotions[Class], Skill, Mastery,
			Player.Attrs.Race, min_maturity, max_maturity)
		for _, v in pairs(t1) do
			table.insert(t2, MF.GetClassName({ClassId = v, RaceId = Player.Attrs.Race}))
		end
		if cur_maturity then
			table.insert(t2,
				string.format("%s (%d)",
					MF.GetRaceName({RaceId = Player.Attrs.Race, ClassId = Class}),
					cur_maturity))
		end
		return table.concat(t2, " " .. Game.GlobalTxt[634] .. " ")
	end
	MF.GetSkillPromoNames = get_skill_promo_names

	local NewCode = mem.asmpatch(0x4B0E86, [[
	mov esi, 0x5DF0E0
	xor eax, eax
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	jz 0x4B0ED5 - 0x4B0E86
	push eax
	jmp 0x4B0ECD - 0x4B0E86
	]], 0x4B0EC6 - 0x4B0E86)
	mem.hook((NewCode or 0x4B0E86) + 7, function(d)
		local PID = math.max(Game.CurrentPlayer, 0)
		local Player = Party[PID]
		--local PlayerIndex = Party.PlayersIndexes[PID]
		local PromotionName = get_skill_promo_names(Player.Class, d.ecx, d.edx)
		--Log(Merge.Log.Info, "GetSkillPromoNames: %d, %d, %d, %d - %s", PID, Player.Class, d.ecx, d.edx, PromotionName)
		if PromotionName == "" then
			d.eax = 0
		else
			d.eax = mem.topointer(PromotionName)
		end
	end)
end

function events.GameInitialized2()
	ProcessClassExtra()
end

function events.GameInitialized1()

	local ClassExtraTxt = io.open("Data/Tables/Class Extra.txt", "r")
	if not ClassExtraTxt then
		ClassExtraTxt = io.open("Data/Tables/Class Extra.txt", "w")

		ClassExtraTxt:write("#	Kind	Step	Note\n")
		for i,v in Game.ClassNames do
			local Kind, Step = math.ceil((i+1)/2), (i+1)%2
			ClassExtraTxt:write(i .. "\9" .. Kind .. "\9" .. Step .. "\9" .. v .. "\n")
		end

		io.close(ClassExtraTxt)
		ClassExtraTxt = io.open("Data/Tables/Class Extra.txt", "r")
	end

	local ClassExtra = {}
	local LineIt = ClassExtraTxt:lines()
	LineIt() -- skip header

	for line in LineIt do
		local Words = string.split(line, "\9")
		ClassExtra[tonumber(Words[1])] = {Kind = tonumber(Words[2]),
				Step = tonumber(Words[3]),
				Alignment = tonumber(Words[4])}
	end

	Game.ClassesExtra = ClassExtra

end

Log(Merge.Log.Info, "Init finished: %s", LogId)

