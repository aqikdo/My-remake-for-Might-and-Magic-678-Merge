local LogId = "ExtraEvents"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MO, MV = Merge.Functions, Merge.Offsets, Merge.Vars

local u1, u2, u4, mstr, mcopy, mptr = mem.u1, mem.u2, mem.u4, mem.string, mem.copy, mem.topointer
local asmpatch, autohook, autohook2, hook = mem.asmpatch, mem.autohook, mem.autohook2, mem.hook
local nop, nop2 = mem.nop, mem.nop2
local floor, max, min = math.floor, math.max, math.min
local NewCode

local GetPlayer = MF.GetPlayerFromPtr

local function GetMonster(p)
	if p < Map.Monsters["?ptr"] then
		return
	end
	local i = (p - Map.Monsters["?ptr"]) / Map.Monsters[0]["?size"]
	return Map.Monsters[i], i
end

---------------------------------------
-- Set outdoor light event

mem.autohook2(0x4886e5, function(d)
	local t = {Minute = Game.Minute, Hour = d.eax}
	events.call("SetOutdoorLight", t)
	d.eax = t.Hour
end)

mem.autohook2(0x4886f4, function(d)
	local t = {Minute = d.ecx, Hour = Game.Hour}
	events.call("SetOutdoorLight", t)
	d.ecx = t.Minute
end)

mem.autohook2(0x488731, function(d)
	local t = {Minute = d.ecx, Hour = Game.Hour}
	events.call("SetOutdoorLight", t)
	d.ecx = t.Minute
end)

mem.autohook2(0x488be7, function(d)
	local t = {Minute = Game.Minute, Hour = d.eax}
	events.call("SetOutdoorLight", t)
	d.eax = t.Hour
end)

mem.autohook2(0x488CAE, function(d)
	local t = {Minute = d.eax, Hour = Game.Hour}
	events.call("SetOutdoorLight", t)
	d.eax = t.Minute
end)

mem.autohook2(0x488C0E, function(d)
	local t = {Minute = d.edi, Hour = Game.Hour}
	events.call("SetOutdoorLight", t)
	d.edi = t.Minute
end)

---------------------------------------
-- Sounds for extra tilesets
-- allows to change sounds of step or execute event based on tile coordinates;
-- only outdoors.

local TileSoundData = {}
mem.autohook2(0x473cf0, function(d) TileSoundData = {Y = d.eax, X = mem.u4[d.esp], Run = mem.u4[d.esp+4]} end)
mem.autohook2(0x473cf8, function(d)
	TileSoundData.Sound = d.eax
	events.call("TileSound", TileSoundData)
	d.eax = TileSoundData.Sound
end)

---------------------------------------
-- Step sounds
-- allows to change sound of step
-- indoors and outdoors.

mem.autohook(0x4724f4, function(d)
	if d.edx >= 0 then
		local t = {Sound = u4[d.esp], Run = u4[d.ebp - 0x34] == 0 and 1 or 0, Facet = Map.Facets[d.edx]}
		events.call("StepSound", t)
		u4[d.esp] = t.Sound
	end
end)
mem.autohook(0x473d02, function(d)
	if d.ecx > 0xffff then
		local t = {Sound = u4[d.esp], Run = u4[d.esp] == 0x40 and 1 or 0, Facet = structs.ModelFacet:new(d.ecx + d.eax)}
		events.call("StepSound", t)
		u4[d.esp] = t.Sound
	end
end)


---------------------------------------
-- Got item

mem.autohook2(0x421244, function(d)
	events.call("GotItem", Mouse.Item.Number)
end)
mem.autohook2(0x491a4b, function(d)
	events.call("GotItem", Mouse.Item.Number)
end)


---------------------------------------
-- Regen tick event
-- Standart regen ticks, - unlike timers, continues to tick during party rest.

mem.autohook2(0x491f58, function(d)
	events.cocall("RegenTick", GetPlayer(d.eax))
end)


---------------------------------------
-- Party rest events

local function CalcRestFoodCost()
	local t = {Amount = mem.u1[0x518570]}
	events.call("CalcRestFoodCost", t)
	mem.u1[0x518570] = t.Amount
end

mem.autohook2(0x41ebff, CalcRestFoodCost)
mem.autohook2(0x41ec24, CalcRestFoodCost)
mem.autohook2(0x41ec2b, CalcRestFoodCost)
mem.autohook2(0x41ec36, CalcRestFoodCost)

---------------------------------------
-- Calc jump height event

mem.autohook2(0x473164, function(d)
	local t = {Height = d.eax}
	events.call("CalcJumpHeight", t)
	d.eax = t.Height
end)

function events.CalcJumpHeight(t)
	t.Height = math.min(t.Height, 420)
end

---------------------------------------
-- Can cast town portal
NewCode = mem.asmproc([[
nop
nop
nop
nop
nop
jnz absolute 0x42735b
idiv ecx
cmp edx, dword [ss:ebp-4]
jmp absolute 0x4296a3]])
mem.asmpatch(0x42969e, "jmp absolute " .. NewCode)

mem.hook(NewCode, function(d)
	local t = {CanCast = true, Handled = false, Mastery = mem.u4[d.ebp-0xC]}
	events.call("CanCastTownPortal", t)
	d.ZF = t.CanCast
	if t.Handled then
		d.ecx = 1
	end
end)

---------------------------------------
-- Open chest
-- Supposed to be used to tweak list of items.

NewCode = mem.asmpatch(0x4451c1, [[
nop
nop
nop
nop
nop
call absolute 0x41f8b8]])

mem.hook(NewCode, function(d)
	events.call("OpenChest", d.ecx)
end)

---------------------------------------
-- Get gold
-- Triggers when party finds gold (monster's corpses or gold items)

mem.autohook2(0x42013a, function(d)
	local t = {Amount = d.esi}
	events.call("BeforeGotGold", t)
	d.esi = t.Amount
end)

---------------------------------------
-- Click shop topic
-- Triggers when player clicks topic in shop
-- (list of topics provided by RemoveHouseRulesLimits.lua in const.ShopTopics)

mem.autohook2(0x4baa76, function(d)
	local t = {Handled = false, Topic = d.ecx}
	t.HouseId = GetCurrentHouse()
	events.call("ClickShopTopic", t)

	d.ecx = t.Topic -- topic id change is allowed, but most probably will lead to game crash.

	if t.Handled then
		d.ZF = true
	end
end)

---------------------------------------
-- Calculate fame
-- Allows to change calculation base or overhaul counting.
--

NewCode = mem.asmpatch(0x4903a2, [[
call absolute 0x4026f4
nop; mem hook here
nop
nop
nop
nop

je @over

push 0
push 0xfa
push ecx
push eax
call absolute 0x4dac60

@over:
jmp absolute 0x4903bf]])

mem.hook(NewCode + 5, function(d)
	local t = {Handled = false, Result = 0, Base = Party[0].Experience}
	events.call("GetFameBase", t)

	if t.Handled then
		d.eax = t.Result
	else
		d.ecx = mem.u4[d.eax + 0xa4]
		d.eax = t.Base
	end
	d.ZF = t.Handled
end)

---------------------------------------
-- Get loading screen pic
-- Allows to change loading screen picture.
--
local strlen = string.len
mem.autohook2(0x44031d, function(d)
	local ptr = u4[d.esp]
	local t = {Pic = mstr(ptr)}
	events.call("GetLoadingPic", t)

	mcopy(ptr, t.Pic)
	u1[ptr + strlen(t.Pic)] = 0
end)

---------------------------------------
-- Can show "Heal" topic
--
local function CanShowHealTopic(d)
	local t = {CanShow = d.eax}
	events.call("CanShowHealTopic", t)
	d.eax = t.CanShow
end

mem.autohook2(0x4b5c3b, CanShowHealTopic)
mem.autohook2(0x4b5cd7, CanShowHealTopic)
mem.autohook2(0x4bacdd, CanShowHealTopic)

---------------------------------------
-- Get travel days cost
--
function events.GameInitialized2()

	NewCode = mem.asmpatch(0x4b5626, [[
	nop; mem hook
	nop
	nop
	nop
	nop
	cmp eax, 1
	jge absolute 0x4b562e]])

	mem.hook(NewCode, function(d)
		local t = {Days = d.eax, House = mem.u4[0x518678]}
		events.call("GetTravelDaysCost", t)

		d.eax = t.Days
	end)

	mem.autohook(0x4b51b8, function(d)
		local t = {Days = d.ecx, House = mem.u4[0x518678]}
		events.call("GetTravelDaysCost", t)

		d.ecx = t.Days
	end)

end

---------------------------------------
-- Can repair item
--
NewCode = mem.asmpatch(0x41cfdd, [[
mov ecx, dword [ss:esp-4];
nop; mem hook
nop
nop
nop
nop
cmp eax, 1
mov eax, dword [ss:ebp-4];]])

mem.hook(NewCode + 4, function(d)
	local t = {CanRepair = d.eax == 1, Player = Party[math.max(0, Game.CurrentPlayer)], Item = structs.Item:new(d.ecx)}
	events.call("CanRepairItem", t)

	d.ecx = 0
	d.eax = t.CanRepair and 1 or 0
end)

---------------------------------------
-- Artifact generated
--
function events.GameInitialized2()
	local function ArtifactGenerated(d)
		local t = {ItemId = d.eax}
		events.call("ArtifactGenerated", t)

		d.eax = t.ItemId
	end
	
	mem.autohook2(0x44dd8d, ArtifactGenerated)
	mem.autohook(0x4541c4, ArtifactGenerated)
end

---------------------------------------
-- Arrow projectile
--
mem.autohook(0x42636c, function(d)
	local t = {ObjId = u4[d.ebp-0xac], PlayerIndex = u2[0x51d822]}
	events.call("ArrowProjectile", t)

	u4[d.ebp-0xac] = t.ObjId
end)

---------------------------------------
-- Dragon breath projectile
--
mem.autohook(0x4264ef, function(d)
	local t = {ObjId = u4[d.ebp-0xac], PlayerIndex = u2[0x51d822]}
	events.call("DragonBreathProjectile", t)

	u4[d.ebp-0xac] = t.ObjId
end)

---------------------------------------
-- Get spell skill
-- Supposed to modify skill level for default attacks of players (for example, dragon breath)
--
function events.GetSkill(t)
	if u2[0x51d820] > 0 then
		t.Spell = u2[0x51d820]
		events.call("GetSpellSkill", t)
	end
end

---------------------------------------
-- BeforeLeaveGame
-- called before LeaveGame event, at the moment, when player click "Quit" button second time.
-- Supposed to be used, when player leaving game, but map data still necessary.
mem.autohook2(0x433b0d, function() events.call("BeforeLeaveGame") end)

---------------------------------------
-- MonsterCastSpell
--
--
function events.GameInitialized2()

	local TargetBuf = mem.StaticAlloc(Map.Monsters.limit*4)
	local LastAttackTargetBuf = mem.StaticAlloc(Map.Monsters.limit*4)

	mem.asmpatch(0x404638, [[
	mov eax, dword [ss:esp+8]
	cmp eax, dword [ds:0x40123F]
	jl @end

	push edx
	push ecx

	mov ecx, 0x3cc
	sub eax, dword [ds:0x40123F]
	cdq
	idiv ecx

	pop ecx
	pop edx

	mov word [ds:]] .. TargetBuf+2 .. [[+eax*4], 0;
	mov word [ds:]] .. TargetBuf   .. [[+eax*4], 4; -- target is party (const.ObjectRefKind)

	@end:
	mov eax, dword [ss:ebp+0xc]
	cmp eax, edi]])

	mem.asmpatch(0x404650, [[
	mov eax, dword [ss:esp+8]
	cmp eax, dword [ds:0x40123F]
	jl @end

	push edx
	push ecx

	mov ecx, 0x3cc
	sub eax, dword [ds:0x40123F]
	cdq
	idiv ecx

	pop ecx
	pop edx

	mov word [ds:]] .. TargetBuf+2 .. [[+eax*4], si;
	mov word [ds:]] .. TargetBuf   .. [[+eax*4], 3; -- target is monster (const.ObjectRefKind)

	@end:
	imul esi, esi, 0x3cc]])

	-- attack target selection

	mem.asmpatch(0x403f02, [[
	mov eax, dword [ss:ebp-0x4]
	mov word [ds:]] .. LastAttackTargetBuf+2 .. [[+eax*4], 0;
	mov word [ds:]] .. LastAttackTargetBuf   .. [[+eax*4], 4; -- target is party (const.ObjectRefKind)
	mov eax, dword [ds:0xb2155c];]])

	mem.asmpatch(0x403f25, [[
	mov ecx, dword [ss:ebp-0x4]
	mov word [ds:]] .. LastAttackTargetBuf+2 .. [[+ecx*4], ax;
	mov word [ds:]] .. LastAttackTargetBuf   .. [[+ecx*4], 3; -- target is monster (const.ObjectRefKind)
	imul eax, eax, 0x3cc;]])

	-- Fix damaging player upon death of monster being killed by other monsters.
	NewCode = mem.asmpatch(0x436a59, [[
	movzx ecx, word [ds:]] .. LastAttackTargetBuf   .. [[+eax*4]
	cmp ecx, 0x4
	jne absolute 0x436e01
	imul eax, eax, 0x3cc]])

	----

	function GetMonsterTarget(i)
		return u2[TargetBuf+i*4], u2[TargetBuf+i*4+2]
	end

	function GetLastAttackedMonsterTarget(i)
		return u2[LastAttackTargetBuf+i*4], u2[LastAttackTargetBuf+i*4+2]
	end

	local function MonsterCanCastSpellHook(d)
		local Mon, MonId = GetMonster(d.esi)
		if Mon then
			local TargetRef, TargetId = GetMonsterTarget(MonId)
			local t = {Spell = u4[d.ebp-0x8], Monster = Mon, Target = 0, Distance = u4[d.ebp-0xC], Result = d.eax, TargetRef = TargetRef}
			if TargetRef == 4 then
				t.Target = Party
			elseif TargetRef == 3 then
				t.Target = Map.Monsters[TargetId]
			end
			events.call("MonsterCanCastSpell", t)
			d.eax = t.Result
		end
	end

	NewCode = mem.asmhook(0x42543c, [[
	cmp dword [ss:ebp-0x8], 0
	je @end
	nop
	nop
	nop
	nop
	nop
	@end:]])
	mem.hook(NewCode+6, MonsterCanCastSpellHook)

	NewCode = mem.asmhook(0x42544f, [[
	cmp dword [ss:ebp-0x8], 0
	je @end
	nop
	nop
	nop
	nop
	nop
	@end:]])
	mem.hook(NewCode+6, MonsterCanCastSpellHook)

	mem.autohook(0x404d9f, function(d)
		local Mon, MonId = GetMonster(d.esi)
		if Mon then
			local TargetRef, TargetId = GetMonsterTarget(MonId)
			local t = {Spell = d.ecx, Monster = Mon, Target = 0, TargetRef = TargetRef, Handled = false}

			if TargetRef == 4 then
				t.Target = Party
			elseif TargetRef == 3 then
				t.Target = Map.Monsters[TargetId]
			end

			events.call("MonsterCastSpellM", t)
			if t.Handled then
				d.ecx = 0xffff
			else
				d.ecx = t.Spell
			end
		end
	end)

end

---------------------------------------
-- On Enter Shop
-- Allow to forbid entrance
NewCode = mem.asmpatch(0x443205, [[
mov [eax], ebx
mov [eax+4], ebx
mov eax, [ebp-0x14]
nop
nop
nop
nop
nop
test eax, eax
jnz absolute 0x4431F2
]])

mem.hook(NewCode + 8, function(d)
	local t = {HouseId = d.eax, Banned = 0}
	events.call("OnEnterShop", t)
	d.eax = t.Banned
end)

-- IsMonsterOfKind
mem.hookfunction(0x436542, 2, 0, function(d, def, id, kind)
	local t = {
		Id = id,
		-- :const.MonsterKind
		Kind = kind,
		Result = def(id, kind),
	}
	events.cocall("IsMonsterOfKind", t)
	return t.Result
end)

---------------------------------------
-- On HasItemBonus
-- Called after iterating over equipped items
NewCode = mem.asmpatch(0x48CFB3, [[
cmp esi, 0x10
jl absolute 0x48CF93
mov eax, [esp+8]
nop
nop
nop
nop
nop
test eax, eax
jnz absolute 0x48CFBE
]])

mem.hook(NewCode + 13, function(d)
	local t = {Bonus2 = d.eax, Result = 0}
	t.Player, t.PlayerIndex = GetPlayer(d.ecx)
	events.call("OnHasItemBonus", t)
	d.eax = t.Result
end)

---------------------------------------
-- CanPlayerLearnSpell
--   ReqLevel is spell level (hardcoded as Spell_Id % 11)
--   Player will be able to learn spell if Level is no less than ReqLevel
--   Player will be able to learn spell without skill learnt if Level >= 64
NewCode = asmpatch(0x466A76, [[
mov ecx, [ebp-8]
nop
nop
nop
nop
nop
cmp eax, 0x40
jge absolute 0x466AB1
cmp [ebp-8], eax
jle absolute 0x466AAC
]])

hook(NewCode + 3, function(d)
	local pl, pl_id = GetPlayer(d.esi)
	local t = { ReqLevel = d.ecx, Level = d.eax, Player = pl, PlayerIndex = pl_id, BookIndex = mem.u4[0xB7CA64] }
	t.SpellId = Game.ItemsTxt[t.BookIndex].Mod1DiceSides
	events.call("CanPlayerLearnSpell", t)
	d.eax = t.Level
end)

---------------------------------------
-- New day/week/month/year
NewCode = asmpatch(0x492344, [[
add eax, dword ptr [0x45DEBB]
cmp dword ptr [0xB215B8], ebp
jne @newday
cmp dword ptr [0xB215B0], edx
jne @newday
cmp dword ptr [0xB215AC], eax
jz @std
@newday:
nop
nop
nop
nop
nop
@std:
mov dword ptr [0xB215B8], ebp
sub eax, dword ptr [0x45DEBB]
]])
--nop(0x49234A, 5)

hook(NewCode + 30, function(d)
	-- Ignore the first call after running MM8
	if d.ebp == 0 and d.edx == 0 and d.eax == u4[0x45DEBB] then return end
	local t = {DayOfMonth = d.ebp, Month = d.edx, Year = d.eax,
		GameYear = d.eax - u4[0x45DEBB], DayOfWeek = d.ebp % 7,
		Week = floor(d.ebp / 7), Type = 1}
	t.PrevYear = Game.Year
	t.PrevMonth = Game.Month
	t.PrevDayOfMonth = Game.DayOfMonth
	t.GameDay = MF.GetGameDay({GameYear = t.GameYear, Month = t.Month, Day = t.DayOfMonth})
	t.PrevGameDay = MF.GetGameDay({GameYear = t.PrevYear + t.GameYear - t.Year,
		Month = t.PrevMonth, Day = t.PrevDayOfMonth})
	if t.Year ~= Game.Year then
		events.call("NewYear", t)
		t.NewYear = true
	end
	if t.NewYear or t.Month ~= Game.Month then
		events.call("NewMonth", t)
		t.NewMonth = true
	end
	if t.NewMonth or t.Week ~= floor(Game.DayOfMonth / 7) then
		events.call("NewWeek", t)
		t.NewWeek = true
	end
	events.call("NewDay", t)
end)

local newyear_t3, newmonth_t3, newweek_t3, newday_t3 = false, false, false, false
local newday_tbl

NewCode = asmpatch(0x4B041D,
[[
mov esi, edx
xor edx, edx
div ecx
add eax, dword ptr [0x45DEBB]
cmp dword ptr [0xB215B8], esi
jne @newday
cmp dword ptr [0xB215B0], edx
jne @newday
cmp dword ptr [0xB215AC], eax
jz @std
@newday:
nop
nop
nop
nop
nop
@std:
mov dword ptr [0xB215B8], esi
sub eax, dword ptr [0x45DEBB]
]]
)
nop(0x4B0423, 4)

hook(NewCode + 36, function(d)
	local t = {DayOfMonth = d.esi, Month = d.edx, Year = d.eax,
		GameYear = d.eax - u4[0x45DEBB], DayOfWeek = d.esi % 7,
		Week = floor(d.esi / 7), Type = 2}
	t.PrevYear = Game.Year
	t.PrevMonth = Game.Month
	t.PrevDayOfMonth = Game.DayOfMonth
	t.GameDay = MF.GetGameDay({GameYear = t.GameYear, Month = t.Month, Day = t.DayOfMonth})
	t.PrevGameDay = MF.GetGameDay({GameYear = t.PrevYear + t.GameYear - t.Year,
		Month = t.PrevMonth, Day = t.PrevDayOfMonth})
	local postpone = Game.CurrentScreen == 17
	if t.Year ~= Game.Year then
		if postpone then
			newyear_t3 = true
		else
			events.call("NewYear", t)
			t.NewYear = true
		end
	end
	if t.NewYear or t.Month ~= Game.Month then
		if postpone then
			newmonth_t3 = true
		else
			events.call("NewMonth", t)
			t.NewMonth = true
		end
	end
	if t.NewMonth or t.Week ~= floor(Game.DayOfMonth / 7) then
		if postpone then
			newweek_t3 = true
		else
			events.call("NewWeek", t)
			t.NewWeek = true
		end
	end
	if postpone then
		newday_t3, newday_tbl = true, t
		t.Type = 3
	else
		events.call("NewDay", t)
	end
end)

function events.LoadMap()
	Log(Merge.Log.Info, "%s: LoadMap", LogId)
	if MV.NewGame then
		local t = {DayOfMonth = 0, Month = 0, Year = u4[0x45DEBB],
			GameYear = 0, DayOfWeek = 0, Week = 0, Type = 4}
		events.call("NewYear", t)
		t.NewYear = true
		events.call("NewMonth", t)
		t.NewMonth = true
		events.call("NewWeek", t)
		t.NewWeek = true
		events.call("NewDay", t)
	else
		if newyear_t3 then
			newyear_t3 = false
			events.call("NewYear", newday_tbl)
			newday_tbl.NewYear = true
		end
		if newmonth_t3 then
			newmonth_t3 = false
			events.call("NewMonth", newday_tbl)
			newday_tbl.NewMonth = true
		end
		if newweek_t3 then
			newweek_t3 = false
			events.call("NewWeek", newday_tbl)
			newday_tbl.NewWeek = true
		end
		if newday_t3 then
			newday_t3 = false
			events.call("NewDay", newday_tbl)
			newday_tbl = nil
		end
	end
end

---------------------------------------
-- Spell scroll skill value
NewCode = asmpatch(0x4320D1, [[
mov eax, ]] .. JoinSkill(5, 3) .. [[;
nop
nop
nop
nop
nop
push eax
]])

hook(NewCode + 5, function(d)
	local player_id = u4[d.esp+0x2C]
	local player = Party.PlayersArray[player_id]
	local skill_level, skill_mastery = u4[MO.SpellScrollBonusStrength], u4[MO.SpellScrollBonus]
	if skill_level == 0 then skill_level = 5 end
	if skill_mastery < 26 or skill_mastery > 29 then
		skill_mastery = 3
	else
		skill_mastery = skill_mastery - 25
	end
	local t = {SpellId = u4[d.esp+0x1C], Player = player, PlayerId = player_id,
		SkillLevel = skill_level, SkillMastery = skill_mastery}
	events.call("SpellScrollSkillValue", t)
	d.eax = JoinSkill(t.SkillLevel, t.SkillMastery)
end)

-- Item sold
autohook2(0x4BBDAF, function(d)
	local t = {Item = u4[d.esi+0x4A8], Value = d.ebx}
	events.cocall("ItemSold", t)
end)

Log(Merge.Log.Info, "Init finished: %s", LogId)

