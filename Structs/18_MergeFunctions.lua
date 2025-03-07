local LogId = "MergeFunctions"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM = Merge.Functions, Merge.ModSettings
local memcall, u4 = mem.call, mem.u4
local floor, max = math.floor, math.max

-- Create null-terminated string from given lua string
function mem_cstring(str)
	local ptr = mem.StaticAlloc(#str + 1)
	mem.copy(ptr, str, #str + 1)
	return ptr
end
MF.cstring = mem_cstring

-- Filter table records that satisfy all the conditions.
--   Conditions are given in triplets: field name, comparison operator, value.
local function table_filter(t, preserve_indexes, ...)
	local function cmp(op, value1, value2)
		if op == "=" then return value1 == value2 end
		if op == "!=" then return value1 ~= value2 end
		if op == ">" then return value1 > value2 end
		if op == ">=" then return value1 >= value2 end
		if op == "<" then return value1 < value2 end
		if op == "<=" then return value1 <= value2 end
		return false
	end

	if t == nil then return nil end
	local args = { ... }
	local n = #args
	if math.floor(n / 3) * 3 ~= n then
		Log(Merge.Log.Warning, "table.filter: invalid number of arguments")
		return nil
	end
	local res = {}
	for k, v in pairs(t) do
		local add = true
		for i = 1, n / 3 do
			if not cmp(args[i * 3 - 1], v[args[i * 3 - 2]], args[i * 3]) then
				add = false
			end
		end
		if add then
			if preserve_indexes == 1 or preserve_indexes == true then
				table.insert(res, k, v)
			else
				table.insert(res, v)
			end
		end
	end
	return res
end

table.filter = table_filter

-- Check if table is empty.
local function table_isempty(t)
	return next(t) == nil
end

table.isempty = table_isempty

local slots = {0, 1, 2, 3, 4}
local function get_current_player()
	local slot = Game.CurrentPlayer
	if not table.find(slots, slot) then
		local slot2 = u4[0x519350]
		Log(Merge.Log.Warning, "GetCurrentPlayer: current player - %d, current slot - %d", slot, slot2)
		if table.find(slots, slot2 - 1) then
			return slot2 - 1
		else
			return nil
		end
	else
		return slot
	end
end
MF.GetCurrentPlayer = get_current_player

local function get_player_from_ptr(ptr)
	if ptr < 0xB2187C or ptr > 0xB7AD24 then
		Log(Merge.Log.Error, "%s: invalid player pointer in GetPlayerFromPtr - 0x%X", LogId, ptr)
		return nil, -1
	end
	local player_id = (ptr - Party.PlayersArray["?ptr"])/Party.PlayersArray[0]["?size"]
	return Party.PlayersArray[player_id], player_id
end
MF.GetPlayerFromPtr = get_player_from_ptr

local function get_slot_by_index(player_index)
	if not player_index or player_index < 0 or player_index > 49 then
		return
	end
	for i = 0, Party.count - 1 do
		if Party.PlayersIndexes[i] == player_index then
			return i
		end
	end
end
MF.GetSlotByIndex = get_slot_by_index

local function get_slot_by_ptr(ptr)
	if ptr < 0xB2187C or ptr > 0xB7AD24 then
		Log(Merge.Log.Error, "%s: invalid player pointer in GetSlotByPtr - 0x%X", LogId, ptr)
		return
	end
	for i = 0, Party.count - 1 do
		if Party[i]["?ptr"] == ptr then
			return i
		end
	end
end
MF.GetSlotByPtr = get_slot_by_ptr

local function get_npc_map_monster(npc_id)
	if not npc_id or npc_id == 0 then
		return
	end
	for k, v in Map.Monsters do
		if v.NPC_ID == npc_id then
			return k
		end
	end
end
MF.GetNPCMapMonster = get_npc_map_monster

function CheckClassInParty(class)
	local result = false
	for _, pl in Party do
		if pl.Class == class then
			result = true
			break
		end
	end
	return result
end
MF.CheckClassInParty = CheckClassInParty

function RosterHasAward(award)
	for idx = 0, Party.PlayersArray.count - 1 do
		local player = Party.PlayersArray[idx]
		if player.Awards[award] then
			return true
		end
	end
	return false
end
MF.RosterHasAward = RosterHasAward

local function show_award_animation(anim)
	local slot = get_current_player() or 0
	local player = Party[slot]
	player:ShowFaceAnimation(anim or 96)
	memcall(0x4A6FCE, 1, u4[u4[0x75CE00]+0xE50], 0x97, slot)
	Game.PlaySound(0xCD, 0x190 + slot * 8 + 4)
end
MF.ShowAwardAnimation = show_award_animation

local function qbit_add(qbit)
	if not Party.QBits[qbit] then
		Party.QBits[qbit] = true
		show_award_animation(93)
	end
end
MF.QBitAdd = qbit_add

local function get_continent(map_id)
	return TownPortalControls.MapOfContinent(map_id or Map.MapStatsIndex)
		or not map_id and TownPortalControls.GetCurrentSwitch()
end
MF.GetContinent = get_continent

local function get_day_of_game(t)
	return t.GameYear * 336 + t.Month * 28 + t.Day
end
MF.GetGameDay = get_day_of_game

local function gt_setting_num(s, val)
	local num = tonumber(s)
	if num and num > val then
		return true
	end
end
MF.GtSettingNum = gt_setting_num

local function ne_setting_num(s, val)
	local num = tonumber(s)
	if num and num ~= val then
		return true
	end
end
MF.NeSettingNum = ne_setting_num

local function get_skill_level_skillpoints(rank)
	return rank * (rank + 1) / 2 - 1
end
MF.GetSkillLevelSkillpoints = get_skill_level_skillpoints

local mastery_spell_level = {
	[0] = 0,
	[1] = 4,
	[2] = 7,
	[3] = 10,
	[4] = 11
}

local function can_player_learn_spell(t)
	local req_level, skill_id, level
	if t.SpellId < 100 then
		req_level = (t.SpellId - 1) % 11 + 1
		skill_id = floor((t.SpellId - 1) / 11) + 12
		_, level = SplitSkill(t.Player.Skills[skill_id])
		level = mastery_spell_level[level]
	elseif t.SpellId < 133 then
		req_level = (t.SpellId - 1) % 11 + 1
		if req_level < 5 then
			req_level = mastery_spell_level[req_level - 1] + 1
			skill_id = floor((t.SpellId - 1) / 11) + 12
			_, level = SplitSkill(t.Player.Skills[skill_id])
			level = mastery_spell_level[level]
		else
			-- 7 unused spells per ability
			return false
		end
	else
		-- ranged attacks, shouldn't be learnable
		return false
	end
	t.ReqLevel = req_level
	t.Level = level
	events.call("CanPlayerLearnSpell", t)
	return t.Level >= t.ReqLevel
end
MF.CanPlayerLearnSpell = can_player_learn_spell

local mastery_rank = {
	--[0] = 0,
	[1] = 1,
	[2] = 4,
	[3] = 7,
	[4] = 10
}

local function convert_character(t)
	if not t.Player then
		Log(Merge.Log.Error,
			"%s: calling ConvertCharacter without player specified", LogId)
		return
	end
	local from_class, from_race = t.Player.Class, t.Player.Attrs.Race
	local from_maturity = t.Player.Attrs.Maturity or 0
	local class, race, maturity = t.ToClass or from_class,
		t.ToRace or from_race, t.ToMaturity or from_maturity
	if MM.Races and MM.Races.MaxMaturity then
		if MM.Races.MaxMaturity == 1 then
			if maturity == 1 then
				maturity = from_maturity
			elseif maturity > 1 then
				maturity = 1
			end
		elseif maturity > MM.Races.MaxMaturity then
			maturity = MM.Races.MaxMaturity
		end
	end
	if class == from_class and race == form_race and maturity == from_maturity then
		Log(Merge.Log.Warning,
			"%s: calling ConvertCharacter with the same target parameters", LogId)
		return
	end
	for skill = 0, 38 do
		if t.Player.Skills[skill] > 0 then
			local rank, mastery = SplitSkill(t.Player.Skills[skill])
			local new_mastery = GetMaxAvailableSkill(race, class, skill, maturity)
			if new_mastery == 0 then
				local skillpoints1 = get_skill_level_skillpoints(rank)
				t.Player.Skills[skill] = 0
				t.Player.SkillPoints = t.Player.SkillPoints + skillpoints1
			elseif new_mastery < mastery then
				local skillpoints1 = get_skill_level_skillpoints(rank)
				local new_rank = mastery_rank[new_mastery]
				local skillpoints2 = get_skill_level_skillpoints(new_rank)
				t.Player.Skills[skill] = JoinSkill(new_rank, new_mastery)
				t.Player.SkillPoints = t.Player.SkillPoints + skillpoints1
					- skillpoints2
			end
		end
	end
	t.Player.Class = class
	t.Player.Attrs.Race = race
	t.Player.Attrs.Maturity = maturity
	for spell = 1, 99 do
		if t.Player.Spells[spell] then
			if not can_player_learn_spell({Player = t.Player, SpellId = spell}) then
				t.Player.Spells[spell] = false
			end
		end
	end
	for spell = 100, 132 do
		if can_player_learn_spell({Player = t.Player, SpellId = spell}) then
			t.Player.Spells[spell] = true
		else
			t.Player.Spells[spell] = false
		end
	end
end
MF.ConvertCharacter = convert_character

-- Copy fields of NPC1 onto NPC2
local function npc_copy(src_npc_id, dst_npc_id)
	local npc1 = Game.NPC[src_npc_id]
	local npc2 = Game.NPC[dst_npc_id]
	if not npc1 or not npc2 then
		return false
	end
	npc2.Bits = npc1.Bits
	npc2.EventA = npc1.EventA
	npc2.EventB = npc1.EventB
	npc2.EventC = npc1.EventC
	npc2.EventD = npc1.EventD
	npc2.EventE = npc1.EventE
	npc2.EventF = npc1.EventF
	npc2.Fame = npc1.Fame
	npc2.Greet = npc1.Greet
	npc2.Hired = npc1.Hired
	npc2.House = npc1.House
	npc2.Joins = npc1.Joins
	npc2.NewsTopic = npc1.NewsTopic
	npc2.Pic = npc1.Pic
	npc2.Profession = npc1.Profession
	npc2.Rep = npc1.Rep
	npc2.Sex = npc1.Sex
	npc2.TellsNews = npc1.TellsNews
	npc2.UsedSpells = npc1.UsedSpells
	return true
end
MF.NPCCopy = npc_copy

-- Restore NPC fields from NPCData.txt
function npc_restore(npc_id)
	local npc = Game.NPC[npc_id]
	local npcdata = Game.NPCDataTxt[npc_id]
	if not npc or not npcdata then
		return false
	end
	npc.Bits = npcdata.Bits
	npc.EventA = npcdata.EventA
	npc.EventB = npcdata.EventB
	npc.EventC = npcdata.EventC
	npc.EventD = npcdata.EventD
	npc.EventE = npcdata.EventE
	npc.EventF = npcdata.EventF
	npc.Fame = npcdata.Fame
	npc.Greet = npcdata.Greet
	npc.Hired = npcdata.Hired
	npc.House = npcdata.House
	npc.Joins = npcdata.Joins
	npc.Name = npcdata.Name
	npc.NewsTopic = npcdata.NewsTopic
	npc.Pic = npcdata.Pic
	npc.Profession = npcdata.Profession
	npc.Rep = npcdata.Rep
	npc.Sex = npcdata.Sex
	npc.TellsNews = npcdata.TellsNews
	npc.UsedSpells = npcdata.UsedSpells
	return true
end
MF.NPCRestore = npc_restore

Log(Merge.Log.Info, "Init finished: %s", LogId)
