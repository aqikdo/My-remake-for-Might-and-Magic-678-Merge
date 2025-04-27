local LogId = "ExtraArtifacts"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF = Merge.Functions

local min, max, floor, ceil, random, sqrt = math.min, math.max, math.floor, math.ceil, math.random, math.sqrt
PlayerEffects		= {}
local ArtifactBonuses	= {}
local SpecialBonuses	= {}
local StoreEffects
local AdvInnScreen = const.Screens.AdventurersInn

local GetRace = GetCharRace
local GetSlotByIndex = MF.GetSlotByIndex

local spell_distance = 50

------------------------------------------------
----			Base events					----
------------------------------------------------

------------------------------------------------
-- Make artifacts unique

vars.GotArtifact = vars.GotArtifact or {}

vars.PlacedArtifacts = vars.PlacedArtifacts or {
	-- MM8
	[272] = -1, [273] = -1, [274] = -1, [275] = -1, [276] = -1, [277] = -1, [278] = -1, 
	[284] = -1, [285] = -1, [286] = -1, [287] = -1, [288] = -1, [289] = -1, [290] = -1, 
	[501] = -1, [502] = -1, [503] = -1, [504] = -1, [508] = -1,
	[509] = -1, [516] = -1, [519] = -1, [523] = -1, [539] = -1,
	[540] = -1, [541] = -1, [569] = -1,
	-- MM7
	[1333] = -1, [1334] = -1, [1335] = -1, [1336] = -1,
	[1337] = -1, [1338] = -1, [1372] = -1, [1362] = -1,
	-- MM6
	[2020] = -1, [2023] = -1, [2032] = -1, [2033] = -1, [2034] = -1
}

local GItems = Game.ItemsTxt
local ArtifactsList = {}
for i,v in GItems do
	if v.Material > 0 and v.Value > 0 and v.ChanceByLevel[6] > 0 then
		table.insert(ArtifactsList, i)
	end
end

function events.GotItem(i)
	local v = GItems[i]
	if v.Material > 0 and v.Value > 0 and v.ChanceByLevel[6] > 0 then
		vars.GotArtifact[i] = true
		if vars.PlacedArtifacts[i] and vars.PlacedArtifacts[i] > 0 then
			vars.PlacedArtifacts[i] = nil
		end
	end
end

local function GetNotFoundArts()
	local t = {}
	for k,v in pairs(ArtifactsList) do
		if not vars.GotArtifact[v] and not vars.PlacedArtifacts[v] then
			table.insert(t, v)
		end
	end
	return t
end

local function RosterHaveItem(ItemId)
	for i = 0, Party.PlayersArray.count - 1 do
		local Pl = Party.PlayersArray[i]
		for _, Item in Pl.Items do
			if Item.Number == ItemId then
				return true
			end
		end
	end
end

local function RecountFoundArtifacts()
	for ItemId,v in pairs(vars.GotArtifact) do
		vars.GotArtifact[ItemId] = RosterHaveItem(ItemId)
	end
end
Game.RecountFoundArtifacts = RecountFoundArtifacts

function events.ItemGenerated(Item)
	local Num = Item.Number
	local ItemTxt = GItems[Num]
	if ItemTxt.Material > 0 and ItemTxt.Value > 0 and ItemTxt.ChanceByLevel[6] > 0
			and (vars.GotArtifact[Num] or vars.PlacedArtifacts[Num]) then
		local cArts = GetNotFoundArts()
		if #cArts == 0 then
			Item:Randomize(5, ItemTxt.EquipStat+1)
		else
			Item.Number = cArts[random(#cArts)]
			vars.PlacedArtifacts[Item.Number] = Map.LastRefillDay
				+ Game.MapStats[Map.MapStatsIndex].RefillDays
		end
		Log(Merge.Log.Info, "ItemGenerated: replace item %d with %d", Num, Item.Number)
	else
		Log(Merge.Log.Info, "ItemGenerated: item %d", Num)
	end
end

function events.ArtifactGenerated(t)
	local cArts = GetNotFoundArts()
	local orig_id = t.ItemId
	if #cArts == 0 then
		t.ItemId = random(177, 186)
	else
		t.ItemId = cArts[random(#cArts)]
		vars.PlacedArtifacts[t.ItemId] = Map.LastRefillDay
			+ Game.MapStats[Map.MapStatsIndex].RefillDays
	end
	Log(Merge.Log.Info, "ArtifactGenerated: replace item %d with %d", orig_id, t.ItemId)
end

vars.NextArtifactsRefill = vars.NextArtifactsRefill or Game.Time + const.Year*2
function events.AfterLoadMap()

	-- Reset flags
	if Game.Time > vars.NextArtifactsRefill then
		RecountFoundArtifacts()
		vars.NextArtifactsRefill = Game.Time + const.Year*2
	end

end

-- Check chests
function events.OpenChest(i)
	local ItemId, TxtItem, cArts
	local Chest = Map.Chests[i]
	for i,v in Chest.Items do
		ItemId = v.Number
		if v.Number >= 272 and v.Number <= 278 then
			v:Randomize(5,0)
		end
		if v.Number >= 284 and v.Number <= 290 then
			v:Randomize(5,0)
		end
		--[[
		if ItemId > 0 then
			TxtItem = GItems[ItemId]
			if TxtItem.Material > 0 and TxtItem.Value > 0 and TxtItem.ChanceByLevel[6] > 0
				and vars.GotArtifact[ItemId] and RosterHaveItem(ItemId) then

				cArts = cArts or GetNotFoundArts()
				v.ItemsPlaced = false
				v.Identified = false
				for spot,num in Chest.Inventory do
					Chest.Inventory[spot] = 0
				end
				if #cArts == 0 then
					v:Randomize(5, GItems[ItemId].EquipStat+1)
				else
					ArtPos = random(#cArts)
					v.Number = cArts[ArtPos]
					table.remove(cArts, ArtPos)
				end
				vars.GotArtifact[ItemId] = true
				Log(Merge.Log.Info, "OpenChest: replace item %d with %d", ItemId, v.Number)
			end
		end
		]]--
	end
end

function events.NewDay(t)
	local DayOfGame = t.DayOfMonth + 28 * t.Month + 336 * t.GameYear
	for k, v in pairs(vars.PlacedArtifacts) do
		if v > 0 and v <= DayOfGame then
			vars.PlacedArtifacts[k] = nil
			Log(Merge.Log.Info, "NewDay: artifact recalled: %d", k)
		end
	end
end

------------------------------------------------
-- Can wear conditions

local WearItemConditions = {}

function events.CanWearItem(t)
	local itm = Game.ItemsTxt[t.ItemId]
	local isWeapon = (itm.EquipStat == 0) or (itm.EquipStat == 1) or (itm.EquipStat == 2) or (itm.EquipStat == 12)
	local Cond = WearItemConditions[t.ItemId]
	if Cond then
		t.Available = Cond(t.PlayerId, t.Available)
	end
	if vars.LastCastSpell ~= nil and Game.Time - vars.LastCastSpell < const.Minute * 5 and (not isWeapon) then
		t.Available = false
	end
end

-- Stat bonuses

function events.CalcStatBonusByItems(t)
	local PLT = PlayerEffects[t.Player]
	if PLT then
		t.Result = t.Result + (PLT.Stats[t.Stat] or 0)
	elseif Game.CurrentScreen == AdvInnScreen or GetSlotByIndex(t.PlayerIndex) then
		Log(Merge.Log.Info, "%s: CalcStatBonusByItems (%d) StoreEffects", LogId, t.Stat)
		StoreEffects(t.Player)
	end
end

-- Skill bonuses

function events.GetSkill(t)
	local PLT = PlayerEffects[t.Player]
	if PLT then
		local Skill, Mas = SplitSkill(t.Result)
		Skill = Skill + (PLT.Skills[t.Skill] or 0)
		if Mas > 0 then
			if PLT.SpcBonuses[t.Skill + 100] then
				Mas = min(Mas + 1, 4)
			end
		end
		t.Result = JoinSkill(Skill, Mas)
	elseif Game.CurrentScreen == AdvInnScreen or GetSlotByIndex(t.PlayerIndex) then
		Log(Merge.Log.Info, "%s: GetSkill (%d) StoreEffects", LogId, t.Skill)
		StoreEffects(t.Player)
	end
end

function events.GetPlayerSkillMastery(t)
	local PLT = PlayerEffects[t.Player]
	if PLT then
		local Skill, Mas = SplitSkill(t.Result)
		if Mas > 0 then
			if PLT.SpcBonuses[t.Skill + 100] then
				Mas = min(Mas + 1, 4)
			end
		end
		t.Result = JoinSkill(Skill, Mas)
	elseif Game.CurrentScreen == AdvInnScreen or GetSlotByIndex(t.PlayerIndex) then
		Log(Merge.Log.Info, "%s: GetPlayerSkillMastery (%d) StoreEffects", LogId, t.Skill)
		StoreEffects(t.Player)
	end
end

-- Buffs and extra effects

local TimerPeriod = 2*const.Minute
local MiscItemsEffects = {}

-- Checks if player has an item in Inventory
local function PlayerHasItem(player, item_num)
	-- FIXME: check for item status?
	if mem.call(0x43C0DA, 2, item_num, player["?ptr"], 0) % 256 == 1 then
		return true
	else
		return false
	end
end

local function PartyHasItem(item_num)
	for _, pl in Party do
		if PlayerHasItem(pl, item_num) then
			return true
		end
	end
	return false
end

local function SetBuffs()

	for iR, Player in Party do
		local PLT = PlayerEffects[Player]
		if PLT then
			for k,b in pairs(PLT.Buffs) do
				local Buff = Player.SpellBuffs[k]
				Buff.ExpireTime = Game.Time + TimerPeriod + const.Minute
				Buff.Power = b
				Buff.Skill = b
				Buff.OverlayId = 0
			end
			for k, b in pairs(PLT.PartyBuffs) do
				local Buff = Party.SpellBuffs[k]
				local skill, mas = SplitSkill(b)
				Buff.ExpireTime = Game.Time + TimerPeriod + const.Minute
				Buff.Bits = 0
				Buff.Caster = 50
				-- FIXME: true for Resistances only
				Buff.Power = skill * mas
				Buff.Skill = mas
				Buff.OverlayId = 0
			end
		else
			Log(Merge.Log.Info, "%s: SetBuff StoreEffects", LogId)
			StoreEffects(Player)
		end
	end

	for k,v in pairs(MiscItemsEffects) do
		if PartyHasItem(k) then
			v()
		end
	end

end

function events.AfterLoadMap()
	Timer(SetBuffs, TimerPeriod, true)
end

-- Base effects

local function HPSPoverTime(Player, HPSP, Amount, PlayerId)
	local Cond = Player:GetMainCondition()
	if Cond >= 17 or Cond < 14 then
		Player[HPSP] = min(Player[HPSP] + Amount, Player["GetFull" .. HPSP](Player))
	end
end

local function SharedLife(Char, PlayerId)

	local Mid = Char:GetMainCondition()
	if Party.count == 1 or Mid == 14 or Mid == 16 or Char.HP >= Char:GetFullHP() then
		return
	end

	local Players = {}
	local Pool = Char.HP
	local Need = 1
	for i,v in Party do
		local res = v.HP - Char.HP
		if res > 0 then
			Pool = Pool + v.HP
			Need = Need + 1
			Players[i] = res
		end
	end

	Mid = floor(Pool/Need)
	Need = Mid - Char.HP
	Pool = Need
	for k, v in pairs(Players) do
		local p = Party[k]
		local res = min(max(p.HP - Mid, 0), Need)

		Players[k] = v - res
		p.HP = p.HP - floor(res/2)
		Pool = Pool - floor(res/2)
	end
	Char.HP = Char.HP + ceil(Need - Pool)

	if Char.HP > 0 and Char.Conditions[13] > 0 then
		Char.Conditions[13] = 0
	end

	Char:ShowFaceAnimation(const.FaceAnimation.Smile)

end

-- Over time effects
--[[
function events.RegenTick(Player)
	Message("Hello")
	local sk,mas = SplitSkill(Player.Skills[const.Skills.Regeneration])
	if Player.HP ~= Player:GetFullHP() then
		Player.HP = Player.HP - math.ceil((0.005 + sk * mas * 0.001) * Player:GetFullHP() + mas)
--	else
--		Player.HP = vars.LastHP[Player:GetIndex()]
	end
end
]]--

local function RegenTimer()
	for i,Player in Party do
		local PLT = PlayerEffects[Player]
		if PLT then
			for k,v in pairs(PLT.OverTimeEffects) do
				v(Player)
			end
			PLT = PLT.HPSPRegen
			if PLT.SP ~= 0 then
				HPSPoverTime(Player, "SP", PLT.SP)
			end
			if PLT.HP ~= 0 then
				HPSPoverTime(Player, "HP", PLT.HP)
			end
		else
			Log(Merge.Log.Info, "%s: RegenTick StoreEffects", LogId)
			StoreEffects(Player)
		end
		if Player.HP > 0 then
			Player.Unconscious = 0
		end
	end
end
function events.AfterLoadMap()
	Timer(RegenTimer, 64, false)
end

-- Attack delay mods

local MinimalMeleeAttackDelay = 5
local MinimalRangedAttackDelay = Merge and Merge.Settings and Merge.Settings.Attack
		and Merge.Settings.Attack.MinimalRangedAttackDelay or 5
local MinimalBlasterAttackDelay = Merge and Merge.Settings and Merge.Settings.Attack
		and Merge.Settings.Attack.MinimalBlasterAttackDelay or 5
 
--[[
function events.GetAttackDelay(t)
	local Pl = t.Player
	local PLT = PlayerEffects[Pl]
	if PLT then
		t.Result = t.Result + (PLT.AttackDelay[t.Ranged and 1 or 2] or 0)

		local MHItem = Pl.ItemMainHand > 0 and Pl.Items[Pl.ItemMainHand] or false
		if MHItem and not MHItem.Broken and Game.ItemsTxt[MHItem.Number].Skill == 7 then
			t.Result = max(t.Result, 5)
		else
			t.Result = max(t.Result, 5)
		end
	elseif Game.CurrentScreen == AdvInnScreen or PlayerInParty(t.PlayerIndex) then
		StoreEffects(Pl)
	end
end
]]--

function events.CalcStatBonusBySkills(t)
if t.Stat == const.Stats.MeleeAttack then -- ��ս����

local ac= t.Player:GetAccuracy()
local acadj=0
if ac <= 2 then
	acadj = -6
elseif ac <= 21 then
	acadj = math.floor(ac / 2) - 6 
elseif ac <= 40 then
	acadj = math.floor(ac / 5)
elseif ac <= 300 then
	acadj = math.floor(ac / 25) + 7
elseif ac <= 399 then
	acadj = math.floor(ac / 50) + 13
elseif ac <= 499 then
	acadj = 25
else
	acadj = 30
end
t.Result = 1000 - acadj

local Pl = t.Player
local PLT = PlayerEffects[Pl]
if PLT then
	t.Result = t.Result + (PLT.AttackDelay[2] or 0)
elseif Game.CurrentScreen == AdvInnScreen or PlayerInParty(t.PlayerIndex) then
	StoreEffects(Pl)
end

for i,v in Pl.EquippedItems do
	if v > Pl.Items.limit then
		Log(Merge.Log.Error, "%s: StoreEffects: incorrect item id (%d - %d) in inventory of player #0x%X", LogId, i, v, Player["?ptr"])
		Pl.EquippedItems[i] = 0
	elseif v > 0 then
		local Item = Pl.Items[v]
		if Item.Bonus2 == 41 and (Item.BodyLocation == const.ItemSlot.MainHand + 1 or Item.BodyLocation == const.ItemSlot.ExtraHand + 1) then
			t.Result = t.Result + 5
		end
	end
end
if Pl.SpellBuffs[const.PlayerBuff.Haste].ExpireTime > Game.Time or Party.SpellBuffs[const.PartyBuff.Haste].ExpireTime > Game.Time then
	t.Result = t.Result + 5
end
local sp= t.Player:GetSpeed()
sp = sp - sp * sp * 0.0005
local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
local armor = t.Player:GetActiveItem(const.ItemSlot.Armor)
local shield = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
if armor and armor:T().Skill == const.Skills.Leather then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Leather))
	if mas2 < const.Expert then
		t.Result = t.Result - 5
	end
elseif armor and armor:T().Skill == const.Skills.Chain then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Chain))
	if mas2 < const.Expert then
		t.Result = t.Result - 7.5
	end
	if mas2 < const.Master then
		t.Result = t.Result - 7.5
	end
elseif armor and armor:T().Skill == const.Skills.Plate then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Plate))
	if mas2 < const.Expert then
		t.Result = t.Result - 10
	end
	if mas2 < const.Master then
		t.Result = t.Result - 5
	end
	if mas2 < const.GM then
		t.Result = t.Result - 5
	end
end
if shield and shield:T().Skill == const.Skills.Shield then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Shield))
	if mas2 < const.Expert then
		t.Result = t.Result - 5
	end
	if mas2 < const.GM then
		t.Result = t.Result - 5
	end
end
if it and it:T().Skill == const.Skills.Sword then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Sword))
	local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
	t.Result = t.Result + sp * 0.25 + sk + sk1 * mas1 * 0.25 + 23
	if mas >= 2 then
		t.Result = t.Result + 5
	end
elseif it and it:T().Skill == const.Skills.Dagger then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Dagger))
	local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
	t.Result = t.Result + sp * 0.25 + sk + sk1 * mas1 * 0.25 + 54
elseif it and it:T().Skill == const.Skills.Axe then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Axe))
	local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
	t.Result = t.Result + sp * 0.25 + sk + sk1 * mas1 * 0.25 - 18
elseif it and it:T().Skill == const.Skills.Staff then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Staff))
	local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
	t.Result = t.Result + sp * 0.25 + sk + sk1 * mas1 * 0.25 + 18
elseif it and it:T().Skill == const.Skills.Mace then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Mace))
	local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
	t.Result = t.Result + sp * 0.25 + sk + sk1 * mas1 * 0.25 + 18
elseif it and it:T().Skill == const.Skills.Spear then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Spear))
	local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
	t.Result = t.Result + sp * 0.25 + sk + sk1 * mas1 * 0.25 + 23
elseif it and it:T().Skill == const.Skills.Blaster then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Blaster))
	t.Result = t.Result + sk + mas * 5 + 194
	if it.Number == 962 then
		t.Result = t.Result + 5
	end
else
	if t.Player.Class == 28 then
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.DragonAbility))
		t.Result = t.Result + sp * 0.25 + sk * 2 + 22
	else
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Unarmed))
		t.Result = t.Result + sp * 0.25 + sk * 2 + math.min(mas, 3) * 25
	end
end
end
end

function events.CalcStatBonusBySkills(t)
if t.Stat == const.Stats.RangedAttack then -- ��ս����

local ac= t.Player:GetAccuracy()
local acadj=0
if ac <= 2 then
	acadj = -6
elseif ac <= 21 then
	acadj = math.floor(ac / 2) - 6 
elseif ac <= 40 then
	acadj = math.floor(ac / 5)
elseif ac <= 300 then
	acadj = math.floor(ac / 25) + 7
elseif ac <= 399 then
	acadj = math.floor(ac / 50) + 13
elseif ac <= 499 then
	acadj = 25
else
	acadj = 30
end
t.Result = 1000 - acadj

local Pl = t.Player
local PLT = PlayerEffects[Pl]
if PLT then
	t.Result = t.Result + (PLT.AttackDelay[1] or 0)
elseif Game.CurrentScreen == AdvInnScreen or PlayerInParty(t.PlayerIndex) then
	StoreEffects(Pl)
end

for i,v in Pl.EquippedItems do
	if v > Pl.Items.limit then
		Log(Merge.Log.Error, "%s: StoreEffects: incorrect item id (%d - %d) in inventory of player #0x%X", LogId, i, v, Player["?ptr"])
		Pl.EquippedItems[i] = 0
	elseif v > 0 then
		local Item = Pl.Items[v]
		if Item.Bonus2 == 41 and Item.BodyLocation == const.ItemSlot.Bow + 1 then
			spaddrange = 5
		end
	end
end
if Pl.SpellBuffs[const.PlayerBuff.Haste].ExpireTime > Game.Time or Party.SpellBuffs[const.PartyBuff.Haste].ExpireTime > Game.Time then
	t.Result = t.Result + 5
end
local sp= t.Player:GetSpeed()
sp = sp - sp * sp * 0.0005
local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
local armor = t.Player:GetActiveItem(const.ItemSlot.Armor)
local shield = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
if armor and armor:T().Skill == const.Skills.Leather then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Leather))
	if mas2 < const.Expert then
		t.Result = t.Result - 5
	end
elseif armor and armor:T().Skill == const.Skills.Chain then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Chain))
	if mas2 < const.Expert then
		t.Result = t.Result - 7.5
	end
	if mas2 < const.Master then
		t.Result = t.Result - 7.5
	end
elseif armor and armor:T().Skill == const.Skills.Plate then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Plate))
	if mas2 < const.Expert then
		t.Result = t.Result - 10
	end
	if mas2 < const.Master then
		t.Result = t.Result - 5
	end
	if mas2 < const.GM then
		t.Result = t.Result - 5
	end
end
if shield and shield:T().Skill == const.Skills.Shield then
	local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Shield))
	if mas2 < const.Expert then
		t.Result = t.Result - 5
	end
	if mas2 < const.GM then
		t.Result = t.Result - 5
	end
end
it = t.Player:GetActiveItem(const.ItemSlot.Bow)
if it then
	local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Bow))
	t.Result = t.Result + sp * 0.25 + sk * 2 + math.min(mas - 1, 1) * 10 + 22
else
	if t.Player.Class == 28 then
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.DragonAbility))
		t.Result = t.Result + sp * 0.25 + sk * 2 + 22
	end
end
end
end

function events.GetAttackDelay(t) --����
	if t.Ranged then
		t.Result = 120 * (0.99 ^ (t.Player:GetRangedAttack() - 1000))
	else
		t.Result = 120 * (0.99 ^ (t.Player:GetMeleeAttack() - 1000))
	end
end

-- On-hit effects

local OnHitEffects = {}

function events.ItemAdditionalDamage(t)

	if t.Item.Broken then return end

	local Effect = OnHitEffects[t.Item.Number]

	if not Effect then return end

	t.DamageKind = Effect.DamageKind or t.DamageKind
	if Effect.Add then
		t.Result = t.Result + Effect.Add
	end
	if Effect.Special then
		Effect.Special(t)
	end
end

-- Effect immunities
function events.DoBadThingToPlayer(t)
	local PLT = PlayerEffects[t.Player]
	if PLT then
		if PLT.EffectImmunities[t.Thing] then
			t.Allow = false
		end
	elseif Game.CurrentScreen == AdvInnScreen or GetSlotByIndex(t.PlayerIndex) then
		Log(Merge.Log.Info, "%s: DoBadThingToPlayer StoreEffects", LogId)
		StoreEffects(t.Player)
	end
end

-- Additional item Special Bonuses
-- Scope: item
local ItemSpcBonuses = {}

function events.ItemHasBonus2(t)
	local Bonuses = ItemSpcBonuses[t.ItemId]
	if Bonuses and table.find(Bonuses, t.Bonus2) then
		t.Result = 1
	end
end

-- Scope: player
function events.OnHasItemBonus(t)
	local PLT = PlayerEffects[t.Player]
	if PLT then
		if PLT.SpcBonuses[t.Bonus2] then
			t.Result = 1
		end
	else
		Log(Merge.Log.Info, "%s: OnHasItemBonus StoreEffects", LogId)
		StoreEffects(t.Player)
	end
end

-- Groups of mutually exclusive bonuses
local Bonus2Group = {
	-- Additional damage
	[1] = {4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 46, 67, 68,
		80, 81, 82, 83, 84, 85, 86, 87, 88},
	-- Vampiric
	[2] = {16, 41}
}

-- Check if item has one of the bonuses from the specific group
function events.ItemHasBonus2OfGroup(t)
	-- Check enchanted Bonus2 first
	if t.Bonus2 and t.Bonus2 > 0 then
		if table.find(Bonus2Group[t.Group], t.Bonus2) then
			t.Result = t.Bonus2
			return
		end
	end
	local Bonuses = ItemSpcBonuses[t.ItemId]
	if not Bonuses then
		return
	end
	for _, bonus in pairs(Bonuses) do
		if table.find(Bonus2Group[t.Group], bonus) then
			t.Result = bonus
			return
		end
	end
end

-- Arrow projectiles

local ArrowProjectiles = {}
function events.ArrowProjectile(t)
	if t.ObjId == 0x221 then
		local Pl = Party.PlayersArray[t.PlayerIndex]
		local Bow = Pl.Items[Pl.ItemBow].Number

		t.ObjId = ArrowProjectiles[Bow] or 0x221
	end
end

------------------------------------------------
----			Bake effects				----
------------------------------------------------

local function SpellPowerByItemSkill(Player, Item)
	local Skill, Mas = 7, 3
	local SkillNum = Game.ItemsTxt[Item.Number].Skill
	if SkillNum < 39 then
		Skill, Mas = SplitSkill(Player:GetSkill(SkillNum))
	end
	return Skill, Mas
end

StoreEffects = function(Player, postpone_gc)
	Log(Merge.Log.Info, "%s: StoreEffects", LogId)
	local Mod, T
	local PLT = PlayerEffects[Player] or {}
	PlayerEffects[Player] = PLT

	PLT.EffectImmunities = {}
	PLT.OverTimeEffects = {}
	PLT.AttackDelay = {}
	PLT.HPSPRegen = {}
	PLT.Buffs  = {}
	PLT.PartyBuffs = {}
	PLT.Stats  = {}
	PLT.Skills = {}
	PLT.SpcBonuses = {}

	PLT.HPSPRegen.HP = 0
	PLT.HPSPRegen.SP = 0

	for i,v in Player.EquippedItems do
		if v > Player.Items.limit then
			Log(Merge.Log.Error, "%s: StoreEffects: incorrect item id (%d - %d) in inventory of player #0x%X", LogId, i, v, Player["?ptr"])
			Player.EquippedItems[i] = 0
		elseif v > 0 then
			local Item = Player.Items[v]
			if not Item.Broken then

				Mod = ArtifactBonuses[Item.Number]
				if Mod then
					-- Stats
					if Mod.Stats then
						T = PLT.Stats
						for k,v in pairs(Mod.Stats) do
							T[k] = (T[k] or 0) + v
						end
					end
					-- Skills
					if Mod.Skills then
						T = PLT.Skills
						for k,v in pairs(Mod.Skills) do
							T[k] = (T[k] or 0) + v
						end
					end
					-- Spell muls
					if Mod.SpellBonus then
						T = PLT.Skills
						for k,v in pairs(Mod.SpellBonus) do
							local base = SplitSkill(Player.Skills[k])
							T[k] = (T[k] or 0) + base*0.5
						end
					end
					-- Buffs
					if Mod.Buffs then
						T = PLT.Buffs
						local Skill, Mas = SpellPowerByItemSkill(Player, Item)
						for k,v in pairs(Mod.Buffs) do
							T[k] = math.max((T[k] or 0), v, Skill*Mas/2)
						end
					end
					-- Party Buffs
					if Mod.PartyBuffs then
						T = PLT.PartyBuffs
						local skill, mas = SpellPowerByItemSkill(Player, Item)
						if Mod.PartyBuffs.ReqMastery <= mas then
							for k, v in pairs(Mod.PartyBuffs.Buff) do
								v = (v == -1) and JoinSkill(skill, mas) or v
								T[k] = max((T[k] or 0), v)
							end
						end
					end
					-- Effect immunities
					if Mod.EffectImmunities then
						T = PLT.EffectImmunities
						for k,v in pairs(Mod.EffectImmunities) do
							T[k] = true
						end
					end
					-- Attack recovery
					if Mod.ModAttackDelay then
						--local IsRangedItem = Game.ItemsTxt[Item.Number].EquipStat == const.ItemType.Missile - 1
						T = PLT.AttackDelay
						if Game.ItemsTxt[Item.Number].EquipStat == const.ItemType.Missile - 1 then
							T[1] = (T[1] or 0) + Mod.ModAttackDelay
						elseif Game.ItemsTxt[Item.Number].EquipStat == const.ItemType.Weapon - 1 or Game.ItemsTxt[Item.Number].EquipStat == const.ItemType.Weapon2H - 1 then
							T[2] = (T[2] or 0) + Mod.ModAttackDelay
						else
							T[1] = (T[1] or 0) + Mod.ModAttackDelay
							T[2] = (T[2] or 0) + Mod.ModAttackDelay
						end 
					end
					-- HP/SP regen
					if Mod.HPSPRegen then
						T = PLT.HPSPRegen
						for k, v in pairs(Mod.HPSPRegen) do
							T[k] = (T[k] or 0) + v
						end
					end
					-- Over time effects
					if Mod.OverTimeEffect then
						table.insert(PLT.OverTimeEffects, Mod.OverTimeEffect)
					end
				end

				-- Bonus2
				if ItemSpcBonuses[Item.Number] then
					T = PLT.SpcBonuses
					for _, bonus in pairs(ItemSpcBonuses[Item.Number]) do
						T[bonus] = true
					end
				end
				if Item.Bonus2 > 99 and Item.Bonus2 < 139 then
					PLT.SpcBonuses[Item.Bonus2] = true
				end

				Mod = SpecialBonuses[Item.Bonus2]
				if Mod then
					-- HP/SP regen
					if Mod.HPSPRegen then
						T = PLT.HPSPRegen
						for k, v in pairs(Mod.HPSPRegen) do
							T[k] = (T[k] or 0) + v
						end
					end
					-- Effect immunities
					if Mod.EffectImmunities then
						T = PLT.EffectImmunities
						for k,v in pairs(Mod.EffectImmunities) do
							T[k] = true
						end
					end
					if Mod.Stats then
						T = PLT.Stats
						for k,v in pairs(Mod.Stats) do
							T[k] = (T[k] or 0) + v
						end
					end
				end

			end
		end
	end

	if not postpone_gc then
		--Log(Merge.Log.Info, "%s: StoreEffects gc", LogId)
		--collectgarbage("collect")
	end
	Log(Merge.Log.Info, "%s: StoreEffects finished", LogId)
end
Game.CountItemBonuses = StoreEffects

function events.LoadMap(WasInGame)
	if not WasInGame then
		for i,v in Party do
			Log(Merge.Log.Info, "%s: LoadMap StoreEffects", LogId)
			StoreEffects(v, true)
		end
	end
end

local NeedRecount = false

function events.Action(t)
	if t.Action == 121 or t.Action == 133 and Game.CurrentScreen == 7 then
		NeedRecount = true
	end
end

function events.Tick()
	if NeedRecount then
		local Pl = max(Game.CurrentPlayer, 0)
		Log(Merge.Log.Info, "%s: Tick StoreEffects", LogId)
		StoreEffects(Party[Pl])
		NeedRecount = false
	end
end

------------------------------------------------
----			Item settings				----
------------------------------------------------

local function GetBonusList(ItemId)
	local t = ArtifactBonuses[ItemId]
	if not t then
		t = {}
		ArtifactBonuses[ItemId] = t
	end
	return t
end

local function GetSpcBonusList(BonusId)
	local t = SpecialBonuses[BonusId]
	if not t then
		t = {}
		SpecialBonuses[BonusId] = t
	end
	return t
end

--------------------------------
-- Special effects of unequipable items

-- Horn of Ros
MiscItemsEffects[2055] = function()
	local Buff = Party.SpellBuffs[const.PartyBuff.DetectLife]
	Buff.ExpireTime = Game.Time + TimerPeriod + const.Minute
	Buff.Power = 3
	Buff.Skill = 7
	Buff.OverlayId = 0
end

--------------------------------
---- Can wear conditions
--[[
-- Elderaxe
WearItemConditions[504] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Kind == const.RaceKind.Minotaur
end

-- Foulfang
WearItemConditions[508] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Family == const.RaceFamily.Vampire
end

-- Glomenmail
WearItemConditions[514] = function(PlayerId, Available)
	local Race = GetRace(Party[PlayerId])
	return Available and Game.Races[Race].BaseRace == const.Race.DarkElf
			and Game.Races[Race].Family == const.RaceFamily.None
end

-- Supreme plate
WearItemConditions[515] = function(PlayerId, Available)
	return Available and
		Game.ClassesExtra[Party[PlayerId].Class].Kind == const.ClassKind.Knight
end

-- Eclipse
WearItemConditions[516] = function(PlayerId, Available)
	return Available
		and Game.ClassesExtra[Party[PlayerId].Class].Kind == const.ClassKind.Cleric
end

-- Crown of final Dominion
WearItemConditions[521] = function(PlayerId, Available)
	return Available and Party[PlayerId].Class == const.Class.MasterNecromancer
			and Game.Races[GetRace(Party[PlayerId])].Family == const.RaceFamily.Undead
end

-- Blade of Mercy
WearItemConditions[529] = function(PlayerId, Available)
	return Available and (Party[PlayerId].Class == const.Class.Necromancer
			or Party[PlayerId].Class == const.Class.MasterNecromancer)
	-- return Game.ClassesExtra[Party[PlayerId].Class].Kind == const.ClassKind.Sorcerer
	--		and Game.ClassesExtra[Party[PlayerId].Class].Alignment == const.Alignment.Evil
end

-- Lightning crossbow
WearItemConditions[532] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Kind == const.RaceKind.Elf
end
-- Ethric's Staff
WearItemConditions[1317] = function(PlayerId, Available)
	return Available and
		Game.ClassesExtra[Party[PlayerId].Class].Alignment == const.Alignment.Evil
end
-- Old Nick
WearItemConditions[1319] = function(PlayerId, Available)
	return Available and
		Game.ClassesExtra[Party[PlayerId].Class].Alignment == const.Alignment.Evil
end
-- Taledon's Helm
WearItemConditions[1323] = function(PlayerId, Available)
	return Available and
		Game.ClassesExtra[Party[PlayerId].Class].Alignment == const.Alignment.Good
end
-- Twilight
WearItemConditions[1327] = function(PlayerId, Available)
	return Available and
		Game.ClassesExtra[Party[PlayerId].Class].Alignment == const.Alignment.Evil
end
-- Justice
WearItemConditions[1329] = function(PlayerId, Available)
	return Available and
		Game.ClassesExtra[Party[PlayerId].Class].Alignment == const.Alignment.Good
end
-- Elfbane
WearItemConditions[1333] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Kind == const.RaceKind.Goblin
end

-- Mind's Eye
WearItemConditions[1334] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Kind == const.RaceKind.Human
end

-- Elven chainmail
WearItemConditions[1335] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Kind == const.RaceKind.Elf
end

-- Forge Gauntlets
WearItemConditions[1336] = function(PlayerId, Available)
	return Available and
		Game.Races[GetRace(Party[PlayerId])].Kind == const.RaceKind.Dwarf
end

-- Hero's belt
WearItemConditions[1337] = function(PlayerId, Available)
	local Gender = Game.CharacterPortraits[Party[PlayerId].Face].DefSex
	return Available and Gender == 0 -- only male can wear it.
end

-- Lady's Escort ring
WearItemConditions[1338] = function(PlayerId, Available)
	local Gender = Game.CharacterPortraits[Party[PlayerId].Face].DefSex
	return Available and Gender == 1 -- only female can wear it.
end
]]--
-- Wetsuit
local WetsuitSlots = {0,2,4,5,6,8}
WearItemConditions[1406] = function(PlayerId)

	local Pl = Party[PlayerId]

	if not Game.CharacterDollTypes[Game.CharacterPortraits[Pl.Face].DollType].Armor then
		return false
	end

	local EqItems = Pl.EquippedItems

	-- Armors, except body (this one will be replaced).
	for _,v in pairs(WetsuitSlots) do
		if EqItems[v] > 0 then
			return false
		end
	end

	-- Main hand allow only blasters and one-handed weapons
	local MIt = EqItems[1]
	if MIt > 0 then
		local Item = Game.ItemsTxt[Pl.Items[MIt].Number]
		if Item.EquipStat == 1 then
			return false
		end
	end

	return true
end

function events.CanWearItem(t)
	local Pl = Party[t.PlayerId]
	if Pl.ItemArmor > 0 and Pl.Items[Pl.ItemArmor].Number == 1406 then
		local EqSt = Game.ItemsTxt[t.ItemId].EquipStat
		t.Available = EqSt == 0 or EqSt == 3 or EqSt == 8 or EqSt == 10 or EqSt == 11
	end
end

--------------------------------
---- Stat bonuses
-- Staff of the Swamp
GetBonusList(511).Stats = {	[const.Stats.Luck] = 25,
                            [const.Stats.ArmorClass] = 25}

-- Crown of final Dominion
GetBonusList(521).Stats = {	[const.Stats.Intellect] = 50}

-- Cycle of life
GetBonusList(543).Stats = {	[const.Stats.Endurance] = 20}

-- Puck
GetBonusList(1302).Stats = {[const.Stats.Speed]	= 40}
-- Iron Feather
GetBonusList(1303).Stats = {[const.Stats.Might]	= 40,
							[const.Stats.Speed]	= 40}
-- Wallace
GetBonusList(1304).Stats = {[const.Stats.Personality] = 40}
-- Corsair
GetBonusList(1305).Stats = {[const.Stats.Luck] = 40,
							[const.Stats.Might] = 40}
-- Governor's Armor
GetBonusList(1306).Stats = {[const.Stats.Might] 		= 15,
							[const.Stats.Intellect] 	= 15,
							[const.Stats.Personality] 	= 15,
							[const.Stats.Speed] 		= 15,
							[const.Stats.Accuracy]		= 15,
							[const.Stats.Endurance] 	= 15,
							[const.Stats.Luck]			= 15}					
-- Ring of Gods
GetBonusList(1362).Stats = {[const.Stats.Might] 		= 30,
							[const.Stats.Intellect] 	= 30,
							[const.Stats.Personality] 	= 30,
							[const.Stats.Speed] 		= 30,
							[const.Stats.Accuracy]		= 30,
							[const.Stats.Endurance] 	= 30,
							[const.Stats.Luck]			= 30}
-- Charlet
GetBonusList(1311).Stats = {[const.Stats.Might] 		= 15,
							[const.Stats.Intellect] 	= 15,
							[const.Stats.Personality] 	= 15,
							[const.Stats.Speed] 		= 15,
							[const.Stats.Accuracy]		= 15,
							[const.Stats.Endurance] 	= 15,
							[const.Stats.Luck]			= 15}
-- Yoruba
GetBonusList(1307).Stats = {[const.Stats.Endurance] 	= 40,
							[const.Stats.ArmorClass] 	= 10}
-- Splitter
GetBonusList(1308).Stats = {[const.Stats.FireResistance] = 65000}
-- Ullyses
GetBonusList(1312).Stats = {[const.Stats.Accuracy] = 50}
-- Seven League Boots
GetBonusList(1314).Stats = {[const.Stats.WaterResistance] = 20}
-- Mash
GetBonusList(1316).Stats = {[const.Stats.Might] 		= 250,
							[const.Stats.Intellect] 	= -40,
							[const.Stats.Personality] 	= -40,
							[const.Stats.Speed] 		= -40}
-- Hareck's Leather
GetBonusList(1318).Stats = {[const.Stats.Luck]				= 50}
-- Amuck
GetBonusList(1320).Stats = {[const.Stats.Endurance] 	= 100}
-- Glory shield
GetBonusList(1321).Stats = {[const.Stats.Luck]				= 20,
							[const.Stats.BodyResistance]	= -20,
							[const.Stats.MindResistance]	= -20}
-- Kelebrim
GetBonusList(1322).Stats = {[const.Stats.Endurance] = 50,
							[const.Stats.EarthResistance] = -10}
-- Taledon's Helm
GetBonusList(1323).Stats = {
	[const.Stats.Might] = 15,
	[const.Stats.Personality] = 15,
	[const.Stats.Luck] = 20
}
-- Scholar's Cap
GetBonusList(1324).Stats = {[const.Stats.Endurance] = -50}
-- Phynaxian Crown
GetBonusList(1325).Stats = {
	[const.Stats.Personality] = 30,
	[const.Stats.ArmorClass] = -20,
	[const.Stats.WaterResistance] = 50
}
-- Titan's Belt
GetBonusList(1326).Stats = {
	[const.Stats.Might] = 125,
	[const.Stats.Speed] = -15
}
-- Twilight
GetBonusList(1327).Stats = {
	[const.Stats.Speed] = 30,
	[const.Stats.Luck] = 50,
	[const.Stats.FireResistance] = -10,
	[const.Stats.AirResistance] = -10,
	[const.Stats.WaterResistance] = -10,
	[const.Stats.EarthResistance] = -10,
	[const.Stats.MindResistance] = -10,
	[const.Stats.BodyResistance] = -10,
	[const.Stats.SpiritResistance] = -10
}
-- Ania Selving
GetBonusList(1328).Stats = {[const.Stats.Speed] = -25,
							[const.Stats.Accuracy] = 100}
-- Justice
GetBonusList(1329).Stats = {[const.Stats.Speed] = -40}
-- Mekorig's hammer
GetBonusList(1330).Stats = {[const.Stats.Intellect] = 30,
							[const.Stats.Personality] = 30}
-- Hermes's Sandals
GetBonusList(1331).Stats = { [const.Stats.Speed] = 40,
							[const.Stats.Accuracy] = 25,
							[const.Stats.AirResistance] = 50}
-- Cloak of the sheep
GetBonusList(1332).Stats = { [const.Stats.Intellect] 	= 30,
							[const.Stats.Personality] 	= 30}
-- Mind's Eye
GetBonusList(1334).Stats = {
	[const.Stats.Intellect] = 30,
	[const.Stats.Personality] = 30
}
-- Elven Chainmail
GetBonusList(1335).Stats = {[const.Stats.Speed] = 20,
							[const.Stats.Accuracy] = 20}
-- Forge Gauntlets
GetBonusList(1336).Stats = {
	[const.Stats.Might] = 20,
	[const.Stats.Endurance] = 20,
	[const.Stats.FireResistance] = 30
}
-- Hero's belt
GetBonusList(1337).Stats = {[const.Stats.Might] = 10}
-- Lady's Escort ring
GetBonusList(1338).Stats = {[const.Stats.FireResistance]	= 10,
							[const.Stats.AirResistance]		= 10,
							[const.Stats.WaterResistance]	= 10,
							[const.Stats.EarthResistance]	= 10,
							[const.Stats.MindResistance]	= 10,
							[const.Stats.BodyResistance]	= 10,
							[const.Stats.Luck]	= 25}
-- Thor
GetBonusList(2021).Stats = {[const.Stats.Might] = 75}
-- Conan
GetBonusList(2022).Stats = {[const.Stats.Might] = 100}
-- Excalibur
GetBonusList(2023).Stats = {[const.Stats.Might] = 100}
-- Merlin
GetBonusList(2024).Stats = {[const.Stats.SP] = 400}
-- Percival
--GetBonusList(2025).Stats = {[const.Stats.Speed] = 40}
-- Galahad
GetBonusList(2026).Stats = {[const.Stats.HP] = 250, [const.Stats.ArmorClass] = 20}
-- Pellinore
GetBonusList(2027).Stats = {[const.Stats.Endurance] = 30}
-- Valeria
GetBonusList(2028).Stats = {[const.Stats.Accuracy] = 40}
-- Arthur
GetBonusList(2029).Stats = {
	[const.Stats.Might] = 10,
	[const.Stats.Intellect] = 10,
	[const.Stats.Personality] = 10,
	[const.Stats.Endurance] = 10,
	[const.Stats.Accuracy] = 10,
	[const.Stats.Speed] = 10,
	[const.Stats.Luck] = 10,
	[const.Stats.SP] = 300
}
-- Pendragon
GetBonusList(2030).Stats = {[const.Stats.Luck] = 30}
-- Lucius
GetBonusList(2031).Stats = {[const.Stats.Speed] = 40}
-- Guinevere
GetBonusList(2032).Stats = {[const.Stats.SP] = 30}
-- Igraine
GetBonusList(2033).Stats = {[const.Stats.SP] = 25}
-- Morgan
GetBonusList(2034).Stats = {[const.Stats.SP] = 20}
-- Hades
GetBonusList(2035).Stats = {[const.Stats.Luck] = 20}
-- Ares
GetBonusList(2036).Stats = {[const.Stats.FireResistance] = 50}
-- Poseidon
GetBonusList(2037).Stats = {[const.Stats.Might] 	 = 20,
							[const.Stats.Endurance]  = 20,
							[const.Stats.Accuracy] 	 = 20,
							[const.Stats.Speed] 	 = -10,
							[const.Stats.ArmorClass] = -10}
-- Cronos
GetBonusList(2038).Stats = {[const.Stats.Endurance] = 100}
-- Hercules
GetBonusList(2039).Stats = {[const.Stats.Might] 	= 200,
							[const.Stats.Intellect]	= -50}
-- Artemis
GetBonusList(2040).Stats = {[const.Stats.FireResistance] 	= -25,
							[const.Stats.AirResistance] 	= -25,
							[const.Stats.WaterResistance] 	= -25,
							[const.Stats.EarthResistance] 	= -25,
							[const.Stats.BodyResistance] 	= -25,
							[const.Stats.MindResistance] 	= -25}
-- Apollo
GetBonusList(2041).Stats = {[const.Stats.Endurance]			= -20,
							[const.Stats.FireResistance] 	= 20,
							[const.Stats.AirResistance] 	= 20,
							[const.Stats.WaterResistance] 	= 20,
							[const.Stats.EarthResistance] 	= 20,
							[const.Stats.MindResistance] 	= 20,
							[const.Stats.BodyResistance] 	= 20,
							[const.Stats.Luck]				= 20}
-- Zeus
GetBonusList(2042).Stats = {[const.Stats.HP] 		= 50,
							[const.Stats.SP] 		= 50,
							[const.Stats.Luck] 		= 50,
							[const.Stats.Intellect] = -50}
-- Aegis
GetBonusList(2043).Stats = {[const.Stats.Luck] 	= 20}
-- Odin
GetBonusList(2044).Stats = {
	[const.Stats.Speed] = -40,
	[const.Stats.FireResistance] = 50,
	[const.Stats.AirResistance] = 50,
	[const.Stats.WaterResistance] = 50,
	[const.Stats.EarthResistance] = 50
}
-- Atlas
GetBonusList(2045).Stats = {
	[const.Stats.Might] = 100,
	[const.Stats.Speed] = -10
}
-- Hermes
GetBonusList(2046).Stats = {
	[const.Stats.Speed] = 100,
	[const.Stats.Accuracy] = -60
}
-- Aphrodite
GetBonusList(2047).Stats = {[const.Stats.Personality] = 100,
							[const.Stats.Luck] 	= -20}
-- Athena
GetBonusList(2048).Stats = {[const.Stats.Intellect] = 100,
							[const.Stats.Might] 	= -40}
-- Hera
GetBonusList(2049).Stats = {[const.Stats.HP] = 50,
							[const.Stats.SP] = 50,
							[const.Stats.Luck] = 50,
							[const.Stats.Personality] = -50}
-- Lightning crossbow
-- GetBonusList(532).Stats = {[const.Stats.Accuracy] = 50}

-- Blade of Mercy
GetBonusList(529).Stats = {[const.Stats.Accuracy] = 60}

GetBonusList(534).Stats = {[const.Stats.Personality] = 45,
						   [const.Stats.Luck] 	= 45}
--Elfbane
GetBonusList(1333).Stats = {[const.Stats.Might] = 50,
						    [const.Stats.Speed] = 50,
							[const.Stats.Accuracy] = 50}
						    
--Berserker's Belt
GetBonusList(537).Stats = {[const.Stats.Might] = 100}

GetBonusList(520).Stats = {[const.Stats.Might] = 15,
						   [const.Stats.Endurance] = 15,
						   [const.Stats.Intellect] = -15,
						   [const.Stats.Personality] = -15}
--------------------------------
---- Skill bonuses
-- Faerie ring
GetBonusList(1348).SpellBonus =	{[const.Skills.DarkElfAbility] = true}
-- Witch's ring
GetBonusList(1363).SpellBonus =	{[const.Skills.Alchemy] = true}

-- Hero's belt
GetBonusList(1337).Skills =	{	[const.Skills.Armsmaster] = 5}
-- Wallace
GetBonusList(1304).Skills =	{	[const.Skills.Armsmaster] = 10}
-- Corsair
GetBonusList(1305).Skills =	{	[const.Skills.DisarmTraps] = 10}
-- Hands of the Master
GetBonusList(1313).Skills =	{	[const.Skills.Unarmed] = 4,
								[const.Skills.Dodging] = 4}
-- Ethric's Staff
GetBonusList(1317).Skills =	{	[const.Skills.Meditation] = 15,
								[const.Skills.Dark] = 5}
-- Hareck's Leather
GetBonusList(1318).Skills =	{	[const.Skills.DisarmTraps] = 10}
-- Old Nick
GetBonusList(1319).Skills =	{	[const.Skills.DisarmTraps] = 5, 
								[const.Skills.Armsmaster] = 5}
-- Glory shield
GetBonusList(1321).Skills =	{	[const.Skills.Shield] = 5,
								[const.Skills.Spirit] = 5}
-- Scholar's Cap
GetBonusList(1324).Skills = {	[const.Skills.Learning] = 15}
-- Ania Selving
GetBonusList(1328).Skills =	{	[const.Skills.Bow] = 6}
-- Faerie ring
GetBonusList(1348).Skills =	{   [const.Skills.Air] = 5}
-- Hades
GetBonusList(2035).Skills =	{	[const.Skills.DisarmTraps] = 10}
-- Hades
GetBonusList(2030).Skills =	{	[const.Skills.DisarmTraps] = 10}
-- Forge Gauntlets 
GetBonusList(1336).Skills =	{	[const.Skills.Earth] = 5}
-- Eclipse
GetBonusList(516).Skills =	{	[const.Skills.Spirit] = 5, [const.Skills.Body] = 5, [const.Skills.Mind] = 5}
-- Crown of final Dominion
GetBonusList(521).Skills =	{	[const.Skills.Dark] = 5}
-- Staff of Elements
GetBonusList(530).Skills =	{	[const.Skills.Fire] = 5, [const.Skills.Air] = 5, [const.Skills.Water] = 5, [const.Skills.Earth] = 5}
-- Ring of Fusion
GetBonusList(535).Skills =	{	[const.Skills.Water] = 5}
-- Seven League Boots
GetBonusList(1314).Skills =	{	[const.Skills.Water] = 5}
-- Ruler's Ring
GetBonusList(1315).Skills =	{	[const.Skills.Fire] = 5, [const.Skills.Dark] = 5, [const.Skills.DarkElfAbility] = 5}
-- Taledon's Helm
GetBonusList(1323).Skills = {	[const.Skills.Light] = 5}
-- Phynaxian Crown
GetBonusList(1325).Skills = {	[const.Skills.Fire] = 5}
-- Justice
GetBonusList(1329).Skills =	{	[const.Skills.Mind] = 5,
							 	[const.Skills.Body] = 5}
-- Mekorig's hammer
GetBonusList(1330).Skills =	{	[const.Skills.Spirit] = 5}
-- Ghost ring
GetBonusList(1347).Skills =	{	[const.Skills.Spirit] = 5}
-- Guinevere
GetBonusList(2032).Skills =	{	[const.Skills.Light] = 5, [const.Skills.Dark] = 5}
-- Igraine
GetBonusList(2033).Skills =	{	[const.Skills.Spirit] = 5, [const.Skills.Body] = 5, [const.Skills.Mind] = 5}
-- Morgan
GetBonusList(2034).Skills =	{	[const.Skills.Fire] = 5, [const.Skills.Air] = 5, [const.Skills.Water] = 5, [const.Skills.Earth] = 5}
-- Cloak of the Sun
GetBonusList(1349).Skills =	{	[const.Skills.Light] = 2}
-- Cloak of the Moon
GetBonusList(1350).Skills =	{	[const.Skills.Dark] = 2}
-- Elven Chainmail
GetBonusList(1335).Skills = {	[const.Skills.DarkElfAbility] = 5}
-- Mind's Eye
GetBonusList(1334).Skills = {	[const.Skills.Mind] = 5}


--------------------------------
---- Buffs and extra effects

-- Lady's Escort ring
--GetBonusList(1338).Buffs = {[const.PlayerBuff.WaterBreathing] = 0} -- Buff = Skill
-- Governor's Armor
--GetBonusList(1306).Buffs = {[const.PlayerBuff.Shield] = 3}
-- Hareck's Leather
--GetBonusList(1318).Buffs = {[const.PlayerBuff.WaterBreathing] = 0}
-- Kelebrim
--GetBonusList(1322).Buffs = {[const.PlayerBuff.Shield] = 3}
-- Elfbane
--GetBonusList(1333).Buffs = {[const.PlayerBuff.Shield] = 3}
-- Wetsuit
--GetBonusList(1406).Buffs = {[const.PlayerBuff.WaterBreathing] = 0}
-- Excalibur
--GetBonusList(2023).Buffs = {[const.PlayerBuff.Bless] = 3}
-- Galahad
--GetBonusList(2026).Buffs = {[const.PlayerBuff.Stoneskin] = 20}
--Pellinore
--GetBonusList(2027).Buffs = {[const.PlayerBuff.Stoneskin] = 20}
-- Valeria
--GetBonusList(2028).Buffs = {[const.PlayerBuff.Shield] = 3}
-- Aegis
--GetBonusList(2043).Buffs = {[const.PlayerBuff.Shield] = 3}

--------------------------------
---- Party Buffs

-- Aegis
GetBonusList(2043).PartyBuffs = {
	ReqMastery = 4,
	Buff = {[const.PartyBuff.Shield] = JoinSkill(7, 3)}
}

--------------------------------
---- Effect Immunities
--[[
-- Yoruba
GetBonusList(1307).EffectImmunities = {	[const.MonsterBonus.Insane] 	= true,
							[const.MonsterBonus.Disease1] 	= true,
							[const.MonsterBonus.Disease2] 	= true,
							[const.MonsterBonus.Disease3] 	= true,
							[const.MonsterBonus.Paralyze] 	= true,
							[const.MonsterBonus.Stone] 		= true,
							[const.MonsterBonus.Poison1] 	= true,
							[const.MonsterBonus.Poison2] 	= true,
							[const.MonsterBonus.Poison3] 	= true,
							[const.MonsterBonus.Asleep] 	= true}
-- Ghoulsbane
GetBonusList(1309).EffectImmunities = {[const.MonsterBonus.Paralyze] = true}
-- Kelebrim
GetBonusList(1322).EffectImmunities = {[const.MonsterBonus.Stone] = true}
-- Cloak of the sheep
GetBonusList(1332).EffectImmunities = {	[const.MonsterBonus.Insane] 	= true,
							[const.MonsterBonus.Disease1] 	= true,
							[const.MonsterBonus.Disease2] 	= true,
							[const.MonsterBonus.Disease3] 	= true,
							[const.MonsterBonus.Paralyze] 	= true,
							[const.MonsterBonus.Stone] 		= true,
							[const.MonsterBonus.Poison1] 	= true,
							[const.MonsterBonus.Poison2] 	= true,
							[const.MonsterBonus.Poison3] 	= true,
							[const.MonsterBonus.Asleep] 	= true}
-- Medusa's mirror
GetBonusList(1341).EffectImmunities = {[const.MonsterBonus.Stone] = true}
-- Pendragon
GetBonusList(2030).EffectImmunities = {
	[const.MonsterBonus.Poison1] = true,
	[const.MonsterBonus.Poison2] = true,
	[const.MonsterBonus.Poison3] = true
}
-- Aegis
GetBonusList(2043).EffectImmunities = {[const.MonsterBonus.Stone] = true}
]]--

--------------------------------
---- Attack delay mods

-- Elderaxe
GetBonusList(504).ModAttackDelay = 5
-- Wyrm Spitter
GetBonusList(506).ModAttackDelay = 10
-- Longseeker
GetBonusList(512).ModAttackDelay = 5
-- Supreme plate
GetBonusList(515).ModAttackDelay = 5
-- Herald's Boots
GetBonusList(518).ModAttackDelay = 5
-- Lightning Crossbow
GetBonusList(532).ModAttackDelay = 35
-- Percival
GetBonusList(2025).ModAttackDelay = -20
-- Puck
GetBonusList(1302).ModAttackDelay = 5
-- Merlin
GetBonusList(2024).ModAttackDelay = 15
-- Mordred
GetBonusList(2020).ModAttackDelay = 5
-- Conan
GetBonusList(2022).ModAttackDelay = 15
-- Serpent wand
GetBonusList(570).ModAttackDelay = 5

--------------------------------
---- HP/SP regen

-- Serendine's Preservation
GetBonusList(513).HPSPRegen = {SP = 8}
-- Mind's Eye
GetBonusList(1334).HPSPRegen = {SP = 3}
-- Elven Chainmail
GetBonusList(1335).HPSPRegen = {HP = 4}
-- Hero's belt
GetBonusList(1337).HPSPRegen = {HP = 6}
-- Merlin
GetBonusList(2024).HPSPRegen = {SP = 5}
-- Pellinore
GetBonusList(2027).HPSPRegen = {HP = 8}
-- Hades
GetBonusList(2035).HPSPRegen = {HP = -5}

GetBonusList(509).HPSPRegen = {HP = 6}

GetBonusList(520).HPSPRegen = {HP = 10}

GetSpcBonusList(37).HPSPRegen = {HP = 6}
GetSpcBonusList(38).HPSPRegen = {SP = 2}
GetSpcBonusList(44).HPSPRegen = {HP = 4}
GetSpcBonusList(47).HPSPRegen = {SP = 1}
GetSpcBonusList(50).HPSPRegen = {HP = 4}
GetSpcBonusList(54).HPSPRegen = {HP = 4}
GetSpcBonusList(55).HPSPRegen = {SP = 1}
GetSpcBonusList(70).HPSPRegen = {SP = 1}
GetSpcBonusList(66).HPSPRegen = {HP = 6, SP = 2}

GetSpcBonusList(73).EffectImmunities = {
	[const.MonsterBonus.Dead] 	= true,
	[const.MonsterBonus.Errad] 	= true}
	
GetSpcBonusList(2).Stats = {[const.Stats.Might] 		= -2,
							[const.Stats.Intellect] 	= -2,
							[const.Stats.Personality] 	= -2,
							[const.Stats.Speed] 		= -2,
							[const.Stats.Accuracy]		= -2,
							[const.Stats.Endurance] 	= -2,
							[const.Stats.Luck]			= -2}
							
GetSpcBonusList(51).Stats ={[const.Stats.Accuracy] 	= 10,
							[const.Stats.Speed] 	= -10}
							
GetSpcBonusList(48).Stats ={[const.Stats.Endurance] 	= -15,
							[const.Stats.ArmorClass] 	= 5,
							[const.Stats.BodyResistance]= 20,
							[const.Stats.MindResistance]= 20}

GetSpcBonusList(69).Stats ={[const.Stats.AirResistance]	= 20}			

GetSpcBonusList(70).Stats ={[const.Stats.WaterResistance]	= 20}

GetSpcBonusList(62).Stats ={[const.Stats.EarthResistance]	= 40}	

GetSpcBonusList(25).Stats ={[const.Stats.Level]	= 25}	

--------------------------------
---- Over time item effects

-- Cycle of life
GetBonusList(543).OverTimeEffect = function(Player, PlayerId)
	SharedLife(Player, PlayerId)
end

-- Ethric's Staff
GetBonusList(1317).OverTimeEffect =	function(Player, PlayerId)
	local race_family = Game.Races[GetCharRace(Player)].Family
	--if Player.Class ~= const.Class.MasterNecromancer then
	if race_family ~= const.RaceFamily.Undead and race_family ~= const.RaceFamily.Ghost then
		HPSPoverTime(Player, "HP", -10, PlayerId)
	end
end

------------------------------------
---- Additional item Special Bonuses
-- See SPCITEMS.TXT
-- Supported bonuses:
--   Additional damage (excl): 4-15,46,67,68,80-88
--   Vampiric (excl): 16,41
--   Double damage: 39,40,63-65,74-79
--   Carnage: 3
--   Water walking: 71
--   Feather Falling: 72

-- Elderaxe (buffed to 9-12 Water damage)
ItemSpcBonuses[504] = {6} --{6, 59}
-- Guardian
ItemSpcBonuses[507] = {86}
-- Foulfang (buffed to 12 Body damage)
ItemSpcBonuses[508] = {15, 16}
-- Breaker
ItemSpcBonuses[510] = {86}
-- Spiritslayer
ItemSpcBonuses[527] = {16}
-- Iron Feather
ItemSpcBonuses[1303] = {9}
-- Hareck's Leather
ItemSpcBonuses[1318] = {71}
-- Old Nick
ItemSpcBonuses[1319] = {16}
-- Hermes' Sandals
ItemSpcBonuses[1331] = {72}
-- Elfbane
ItemSpcBonuses[1333] = {75}
-- Lady's Escort ring
ItemSpcBonuses[1338] = {71, 72}
-- Villain's Blade (Special)
ItemSpcBonuses[1354] = {75}
-- Wetsuit
ItemSpcBonuses[1406] = {71}
-- Winged Sandals
ItemSpcBonuses[1439] = {72}
-- Mordred
ItemSpcBonuses[2020] = {16}
-- Percival
ItemSpcBonuses[2025] = {59}

--------------------------------
---- Arrow projectiles

-- Ullyses
ArrowProjectiles[1312] = 3030

--------------------------------
---- On-hit item effects (only weapons)

-- FIXME: Monster positions seems to be a corner of the sprite.
--     Should be increased by half of the sprite size.
local function CastSpellTowardsMonster(Spell, Skill, Mastery, Monster)
	local dist_c = spell_distance / sqrt((Monster.X - Party.X) ^ 2 +
		(Monster.Y - Party.Y) ^ 2 + (Monster.Z - Party.Z) ^ 2)
	 evt.CastSpell(Spell, Mastery, Skill,
		Monster.X - floor((Monster.X - Party.X) * dist_c),
		Monster.Y - floor((Monster.Y - Party.Y) * dist_c),
		Monster.Z - floor((Monster.Z - Party.Z) * dist_c),
		Monster.X, Monster.Y, Monster.Z)
end

-- Splitter
OnHitEffects[1308] = {
	DamageKind 	= const.Damage.Fire,
	Add			= 10,
	Special = function(t)
		local Skill, Mas = SpellPowerByItemSkill(t.Player, t.Item)
		CastSpellDirect(125,Skill,Mas)
		--evt.CastSpell(6, Mas, Skill, t.Monster.X,t.Monster.Y,t.Monster.Z+50, t.Monster.X,t.Monster.Y,t.Monster.Z)
		CastSpellTowardsMonster(6, Skill, Mas, t.Monster)
	end}
-- Thor
OnHitEffects[2021] = {
	Add			= 10,
	Special = function(t)
		CastSpellDirect(125, 7, 3)
		if t.Monster.HP - t.Result > 0 then
			local Skill, Mas = SpellPowerByItemSkill(t.Player, t.Item)
			evt.CastSpell(18, Mas, Skill, t.Monster.X,t.Monster.Y,t.Monster.Z+50, t.Monster.X,t.Monster.Y,t.Monster.Z)
		end
	end}

-- Excalibur
OnHitEffects[2023] = {
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Dragon then
			t.Result = t.Result + 100
		end
	end}
-- Percival
OnHitEffects[2025] = {
	DamageKind 	= const.Damage.Fire,
	Special = function(t)
		local Skill, Mas = SpellPowerByItemSkill(t.Player, t.Item)
		--evt.CastSpell(6, Mas, Skill, t.Monster.X,t.Monster.Y,t.Monster.Z+50, t.Monster.X,t.Monster.Y,t.Monster.Z)
		CastSpellTowardsMonster(6, 0, 0, t.Monster)
	end}

-- Ullyses
--[[
OnHitEffects[1312] = {
	DamageKind 	= const.Damage.Water,
	Add = 10,
	Special = function(t)
		local Skill, Mas = SpellPowerByItemSkill(t.Player, t.Item)
		CastSpellTowardsMonster(32, Skill, const.GM , t.Monster)
	end}
]]--

-- Hades
OnHitEffects[2035] = {
	DamageKind 	= const.Damage.Water,
	Add = 30,
	Special = function(t)
		local Skill, Mas = SpellPowerByItemSkill(t.Player, t.Item)
		CastSpellDirect(29, Skill, Mas)
	end}
-- Ares
OnHitEffects[2036] = {
	DamageKind 	= const.Damage.Fire,
	Add = 30}
-- Artemis
OnHitEffects[2040] = {
	DamageKind 	= const.Damage.Air,
	Add			= 50,
	Special = function(t)
		local Skill, Mas = SpellPowerByItemSkill(t.Player, t.Item)
		--CastSpellDirect(125,1,1)
		evt.CastSpell(18, Mas, Skill, t.Monster.X,t.Monster.Y,t.Monster.Z+50, t.Monster.X,t.Monster.Y,t.Monster.Z)
	end}
--Ullyses
OnHitEffects[1312] = {
	DamageKind 	= const.Damage.Water,
	Add			= 30}
--Sword of the Snake
OnHitEffects[523] = {
	DamageKind 	= const.Damage.Spirit,
	Add			= 50}
--Posiden
OnHitEffects[2037] = {
	DamageKind 	= const.Damage.Water,
	Add			= 15}
	
--Gibbet
OnHitEffects[1310] = {
	DamageKind 	= const.Damage.Light,
	Add			= 30,
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Undead or montype == const.MonsterKind.Dragon or montype == const.MonsterKind.Demon then
			t.Result = t.Result + 30
		end
	end}

-- Elsenrail
OnHitEffects[500] = {
	DamageKind 	= const.Damage.Light,
	Add			= 30}

-- Glomenthal
OnHitEffects[501] = {
	DamageKind 	= const.Damage.Dark,
	Add			= 30}
	
-- Volcano
OnHitEffects[505] = {
	DamageKind 	= const.Damage.Fire,
	Add			= 30}
	
-- Finality
OnHitEffects[525] = {
	DamageKind 	= const.Damage.Fire,
	Add			= 40}
	
-- Spiritslayer
OnHitEffects[527] = {
	DamageKind 	= const.Damage.Spirit,
	Add			= 25}
	
OnHitEffects[528] = {
	DamageKind 	= const.Damage.Water,
	Add			= 20}

-- Blade of Mercy
OnHitEffects[529] = {
	DamageKind 	= const.Damage.Air,
	Add			= 10}
	
-- Serpent Wand
OnHitEffects[570] = {
	Special = function(t)
		t.Monster.HP = math.max(t.Monster.HP - 5, 0)
		t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = Game.Time + const.Minute
		t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Skill = 5
		t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Power = 20
		t.Monster.SpellBuffs[const.MonsterBuff.Slow].ExpireTime = Game.Time + const.Minute
		t.Monster.SpellBuffs[const.MonsterBuff.Slow].Power = 2
	end}

-- Judicious Measure
OnHitEffects[503] = {
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Ogre then
			t.Result = t.Result + 100
		end
	end}
	
-- Wyrm Spitter
OnHitEffects[506] = {
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Dragon then
			t.Result = t.Result + 200
		end
	end}
	
-- Justice
OnHitEffects[1329] = {
	DamageKind 	= const.Damage.Light,
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Undead then
			t.Result = t.Result + 100
		end
	end}
	
-- Old Nick
OnHitEffects[1319] = {
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Elf then
			t.Result = t.Result + 100
		end
	end}
	
-- Conan
OnHitEffects[2022] = {
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Dragon or montype == const.MonsterKind.Demon then
			t.Result = t.Result + 100
		end
	end}
	
-- Elfbane
OnHitEffects[1333] = {
	Special = function(t)
		local montype = Game.Bolster.Monsters[t.Monster.Id].Type
		if	montype == const.MonsterKind.Dragon or montype == const.MonsterKind.Elf then
			t.Result = t.Result + 100
		end
	end}
		
Log(Merge.Log.Info, "Init finished: %s", LogId)
