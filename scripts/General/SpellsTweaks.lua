local LogId = "SpellTweaks"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)

local ceil = math.ceil
local asmpatch = mem.asmpatch

local function GetPlayer(ptr)
	local PLId = (ptr - Party.PlayersArray[0]["?ptr"]) / Party.PlayersArray[0]["?size"]
	local PL = Party.PlayersArray[PLId]
	return PL, PlId
end

local function GetMonster(ptr)
	local MonId = (ptr - Map.Monsters[0]["?ptr"]) / Map.Monsters[0]["?size"]
	local Mon = Map.Monsters[MonId]
	return Mon, MonId
end

-- Change chance calculation for "slow" and "mass distortion" spells to be applied.
local function CanApplySpell(Skill, Mastery, Resistance)
	if Resistance == const.MonsterImmune then
		return false
	else
--		return (math.random(5, 100) + Skill + Mastery*2.5) > Resistance
		return true
	end
end

local function CanApplySlowMassDistort(d)
	local PL = GetPlayer(mem.u4[d.ebp-0x1c])
	local Skill, Mastery = SplitSkill(PL:GetSkill(const.Skills.Earth))

	local Mon = GetMonster(d.eax)
	local Res = Mon.Resistances[const.Damage.Earth]

	if CanApplySpell(Skill, Mastery, Res) then
		d.eax = 1
	else
		d.eax = 0
	end
end

mem.nop(0x426f97, 3)
mem.hook(0x426fa2, CanApplySlowMassDistort)
mem.nop(0x426910, 2)
mem.nop(0x426918, 1)
mem.hook(0x42691e, CanApplySlowMassDistort)

-- Make Stun paralyze target for small duration
mem.autohook2(0x437751, function(d)
	local Player = GetPlayer(d.ebx)
	local Skill, Mas = SplitSkill(Player:GetSkill(const.Skills.Earth))
	local mon = GetMonster(d.ecx)
	local Buff = mon.SpellBuffs[const.MonsterBuff.Paralyze]
	Buff.ExpireTime = math.max(Game.Time + math.floor(const.Minute / 60 * (25 + Mas * 5)), Buff.ExpireTime)
	Buff.Power = 1
end)

-- Make Town Portal be always sccessfull for GM and always successfull for M if there are no hostile enemies.
function events.CanCastTownPortal(t)
	t.Handled = true
	if t.Mastery == 4 or not (Party.EnemyDetectorRed or Party.EnemyDetectorYellow) then
		t.CanCast = true
	else
		t.CanCast = false
		Game.ShowStatusText(Game.GlobalTxt[480])
	end
end

-- Change chance of monster being stunned
mem.autohook2(0x437713, function(d)
	local Player = GetPlayer(d.ebx)
	local Mon = GetMonster(d.esi)
	local Skill, Mastery = SplitSkill(Player:GetSkill(const.Skills.Earth))
	
	if CanApplySpell(Skill, Mastery, Mon.Resistances[const.Damage.Earth]) then
		d.eax = 1
	else
		d.eax = 0
	end
end)

-- Change chance calculation for Control Undead
mem.nop(0x42c3aa, 6)
mem.nop(0x42c413, 6)
mem.nop(0x42c41c, 2)
mem.nop(0x42c424, 1)
mem.hook(0x42c42a, function(d)
	local mon = GetMonster(d.eax)

	if mon.DarkResistance == const.MonsterImmune or Game.IsMonsterOfKind(mon.Id, const.MonsterKind.Undead) == 0 then
		d.eax = 0
		return
	else
--		if Mas > 3 then
			mon.Group = 0
			mon.Ally = 9999 -- Same as reanimated monster's ally.
--		end
		mon.Hostile = false
		mon.ShowAsHostile = false
		d.eax = 1
		return
	end
	--[[
	local Player = GetPlayer(mem.u4[d.ebp-0x1c])
	local Skill, Mas = SplitSkill(Player:GetSkill(const.Skills.Dark))

	if mon.DarkResistance > Skill*Mas then
		d.eax = 0
		return
	end
	]]--
	
end)

-- Fix Fire Spikes counting (no extra spike)
asmpatch(0x4266D7, "jge absolute 0x42735B")

-- Fix Shield party spell buff
asmpatch(0x43800A, [[
cmp dword ptr [0xB21818 + 0x4], 0
jl @std
jg @half
cmp dword ptr [0xB21818], 0
jbe @std
@half:
sar dword ptr [ebp - 0x4], 1
@std:
cmp dword ptr [ebx + 0x1B08], 0
]])

-- Make monsters' power cure heal nearby monsters

local function GetDist(t,x,y,z)
	local px, py, pz  = XYZ(t)
	return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
end

local function MonCanBeHealed(Mon, ByMon)
	if Mon.Active and Mon.HP > 0 and Mon.HP < Mon.FullHP then
		if (Mon.Ally == ByMon.Ally) and GetDist(Mon, XYZ(ByMon)) < 2000 then
			return true
		end
	end
	return false
end

local function MonDebuffStrength(Mon)
	local strength = 0
	if Mon.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time and Mon.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power <= 10 then
		strength = strength + 1
	end
	if Mon.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime > Game.Time then
		strength = strength + 1
	end
	if Mon.SpellBuffs[const.MonsterBuff.Stoned].ExpireTime > Game.Time then
		strength = strength + 10
	end
	if Mon.SpellBuffs[const.MonsterBuff.Slow].ExpireTime > Game.Time then
		strength = strength + 2
	end
	if Mon.SpellBuffs[const.MonsterBuff.MeleeOnly].ExpireTime > Game.Time then
		strength = strength + 5
	end
	if Mon.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime > Game.Time then
		strength = strength + 1
	end
	if Mon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime > Game.Time then
		strength = strength + 1
	end
	if Mon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime > Game.Time then
		strength = strength + 1
	end
	if Mon.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime > Game.Time then
		strength = strength + 1
	end
	if Mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime > Game.Time then
		strength = strength + 8
	end
	strength = strength + math.floor((1 - Mon.HP / Mon.FullHP) * 5)
	return strength
end

local function MonCanBeAffected(Mon, ByMon)
	if (Mon.Active or Mon.SpellBuffs[const.MonsterBuff.Stoned].ExpireTime > Game.Time) and Mon.HP > 0 then
		if (Mon.Ally == ByMon.Ally) and GetDist(Mon, XYZ(ByMon)) < 2000 then
			return true
		end
	end
	return false
end

local function MonCanBeReanimated(Mon, ByMon)
	if Mon.HP == 0 then
		--if (Mon.Group == ByMon.Group or Mon.Ally == ByMon.Ally or Game.HostileTxt[ceil(Mon.Id/3)][ceil(ByMon.Id/3)] == 0) and GetDist(Mon, XYZ(ByMon)) < 2000 then
		--if (Mon.Ally == ByMon.Ally) and GetDist(Mon, XYZ(ByMon)) < 2000 then
		if GetDist(Mon, XYZ(ByMon)) < 2000 then
			return true
		end
	end
	return false
end
--local IsOff = {}
--for i = 0,200 do
--	IsOff[i] = 0
--end
--local Off = {2,6,11,15,18,24,26,29,32,39,41,65,70,76,78,87,90,93,95,97}
--for i = 1,20 do
--	IsOff[Off[i]] = 1
--end

function events.MonsterCastSpellM(t)
	if t.Spell == 69 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local Heal = 6 * Skill
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local maxdebuff = 10
		local maxstrength = 0
		local HealMon = Mon
		local HealMonId = -1
		if Mas == 4 then
			maxdebuff = 9999
		end
		for i,v in Map.Monsters do
			if v == Mon and HealMonId == -1 then
				HealMonId = i
			end
			if MonCanBeAffected(v, Mon) then
				local tmpstrength = MonDebuffStrength(v)
				if tmpstrength <= maxdebuff and tmpstrength > maxstrength then
					maxstrength = tmpstrength
					HealMon = v
					HealMonId = i
				end
			end
		end
		--Message(tostring(maxstrength) .. " " .. tostring(maxdebuff) .. " " .. tostring(HealMonId))
		HealMon.HP = math.min(HealMon.HP + Heal, HealMon.FullHP)

		HealMon.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.Stoned].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.Slow].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.MeleeOnly].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime = 0
		HealMon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime = 0

		if HealMonId ~= -1 then
			Game.ShowMonsterBuffAnim(HealMonId)
		end

	end
	if t.Spell == 67 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local Heal = 4 * Skill * math.max(1, Mas / 2 - 0.5)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local count = 0
		for i,v in Map.Monsters do
			if MonCanBeHealed(v, Mon) then
				v.HP = math.min(v.HP + Heal, v.FullHP)
				Game.ShowMonsterBuffAnim(i)
				count = count + 1
				if Mas <= 3 and count >= 5 then
					break
				end
			end
		end
	end
--	t.Monster.Velocity = t.Monster.Velocity * 2
--	t.Monster.X = Party.X + math.cos(math.random() * 6.28) * 200
--	t.Monster.Y = Party.Y + math.sin(math.random() * 6.28) * 200
--	t.Monster.Z = Party.Z
	-- if t.Spell == 5 or t.Spell == 17 or t.Spell == 17 or t.Spell == 38 or t.Spell == 46 or t.Spell == 51 or t.Spell == 85 or t.Spell == 86 then
	--if t.Spell == 66 then
		--Party[0].HP = -100000
		--local pl = Party[math.random(0, Party.length - 1)]
		--local lst = {}
		--local cnt = -1
		--for i in pl.Spells do
		--	if pl.Spells[i] == true and IsOff[i] then
		--		cnt = cnt + 1
		--		lst[cnt] = i
		--	end
		--end
		--t.CallDefault(15, JoinSkill(60, const.GM))
		--evt.CastSpell(6, const.GM, 60, Party.X,Party.Y,Party.Z+50, Party.X,Party.Y,Party.Z)
		--local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		--local pl = Party[math.random(0, Party.length - 1)]
		--local dmg = math.min(pl.SP, Skill * math.random(4,6))
		--pl.HP = pl.HP - dmg
		--pl.SP = pl.SP - dmg
	--end
end

function events.MonsterCastSpell(t)
	-- Enslave
	if t.Spell == 66 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		t.CallDefault(7, t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local pllist = {}
		local cnt = 0
		for i = 0, Party.length - 1 do
			local v = Party[i]
			if v.SP >= 50 and v:GetFullSP() >= v.LevelBase * 5 then
				cnt = cnt + 1
				pllist[cnt] = v
			end
		end
		vars.LastCastSpell = Game.Time
		if cnt ~= 0 then
			local pl = pllist[math.random(1,cnt)]
			local dmg = math.min(pl:GetFullSP() * 0.5, pl.SP)
			--evt.DamagePlayer(pl,const.Damage.Mind,100 * math.ceil(dmg * Skill / 10))
			pl.HP = pl.HP - dmg / 10
			pl.SP = math.max(0,pl.SP - dmg)
		else
			for i = 0, Party.length - 1 do
				local v = Party[i]
				if v.SP > 0 then
					cnt = cnt + 1
					pllist[cnt] = v
				end
			end
			if cnt ~= 0 then
				local pl = pllist[math.random(1,cnt)]
				local dmg = math.min(pl:GetFullSP(), pl.SP)
				pl.HP = pl.HP - dmg / 10
				pl.SP = math.max(0,pl.SP - dmg)
			end
		end
		
	end
	
	-- Berserk
	if t.Spell == 62 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		t.ObjectType = 1010
		--t.CallDefault(2)
		vars.LastCastSpell = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		t.CallDefault(15, JoinSkill(Skill, Mas))
		t.Monster.HP = t.Monster.HP * 0.99
		t.Monster.AttackRecovery = 0
		--local tmp = math.random(0, Party.length - 1)
		--local pl = Party[tmp]
		--local dmg = Skill * math.random(4,6)
		--evt.DamagePlayer(tmp,const.Damage.Body,dmg)
		--t.Monster.HP = math.min(t.Monster.FullHP, t.Monster.HP + dmg)
	end
	
	-- Day of protection
	if t.Spell == 85 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.SpellBuffs[const.MonsterBuff.DayOfProtection].Power = val
				v.SpellBuffs[const.MonsterBuff.DayOfProtection].ExpireTime = Game.Time + const.Day
				v.SpellBuffs[const.MonsterBuff.DayOfProtection].Skill = Skill
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
	
	-- Hour of Power
	if t.Spell == 86 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.SpellBuffs[const.MonsterBuff.HourOfPower].Power = val
				v.SpellBuffs[const.MonsterBuff.HourOfPower].ExpireTime = Game.Time + const.Day
				v.SpellBuffs[const.MonsterBuff.HourOfPower].Skill = Mas
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
	
	-- Heroism
	if t.Spell == 51 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.SpellBuffs[const.MonsterBuff.Heroism].Power = val
				v.SpellBuffs[const.MonsterBuff.Heroism].ExpireTime = Game.Time + const.Day
				v.SpellBuffs[const.MonsterBuff.Heroism].Skill = Mas
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
	
	-- Bless
	if t.Spell == 46 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.SpellBuffs[const.MonsterBuff.Bless].Power = val
				v.SpellBuffs[const.MonsterBuff.Bless].ExpireTime = Game.Time + const.Day
				v.SpellBuffs[const.MonsterBuff.Bless].Skill = Mas
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
	
	--StoneSkin
	if t.Spell == 38 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.SpellBuffs[const.MonsterBuff.Shield].Power = val
				v.SpellBuffs[const.MonsterBuff.Shield].ExpireTime = Game.Time + const.Day
				v.SpellBuffs[const.MonsterBuff.Shield].Skill = Mas
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
	
	--Shield
	if t.Spell == 17 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.SpellBuffs[const.MonsterBuff.Shield].Power = val
				v.SpellBuffs[const.MonsterBuff.Shield].ExpireTime = Game.Time + const.Day
				v.SpellBuffs[const.MonsterBuff.Shield].Skill = Mas
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
	
	--PainReflection
	if t.Spell == 95 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas * Skill
		local v = Mon
--		for i,v in Map.Monsters do
--			if MonCanBeAffected(v, Mon) then
				if v.SpellBuffs[const.MonsterBuff.PainReflection].Power and v.SpellBuffs[const.MonsterBuff.PainReflection].Power~=0 then
					v.SpellBuffs[const.MonsterBuff.PainReflection].Power = math.max(v.SpellBuffs[const.MonsterBuff.PainReflection].Power,val)
				else
					v.SpellBuffs[const.MonsterBuff.PainReflection].Power = val
					v.SpellBuffs[const.MonsterBuff.PainReflection].ExpireTime = Game.Time + const.Day
				end
--			end
--		end
	end
	
	-- Shared Life
	if t.Spell == 54 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas + Skill/10
		local HPPool = 0
		local cnt = 0
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				HPPool = HPPool + v.HP / v.FullHP
				cnt = cnt + 1
			end
		end
		for i,v in Map.Monsters do
			if MonCanBeAffected(v, Mon) then
				v.HP = v.FullHP * math.min((HPPool / cnt) + 0.02, 1)
			end
		end
	end

	-- Slash
	if t.Spell == 52 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local Mon = t.Monster
		local dmg = Skill * math.random(4,6)
		local dist = GetDist(Mon,Party.X,Party.Y,Party.Z)
		if dist < 512 then
			for i,pl in Party do
				evt.DamagePlayer(i,const.Damage.Spirit,dmg)
			end
		end
	end
	
	--Lloyd's Beacon
	if t.Spell == 33 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		if not vars.LloydEffectTime then
			vars.LloydEffectTime = 0
		end
		if vars.LloydEffectTime < Game.Time and Game.Map.Name ~= "elemw.odm" then
			t.ObjectType = 10020
			t.CallDefault(2)
			vars.LloydEffectTime = Game.Time + 1000
			vars.LloydX = Party.X
			vars.LloydY = Party.Y
			vars.LloydZ = Party.Z
		else
			t.ObjectType = 3092
			local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
			t.CallDefault(2, JoinSkill(Skill, Mas))
		end
		--[[
		local x,y,z = Party.X, Party.Y, Party.Z
		--Message("Hi")
		Sleep(1000)
		--Message("Hi")
		Party.X, Party.Y, Party.Z = x,y,z
		]]--
		
	end
	
	--Dark Grasp
	if t.Spell == 96 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		if (not vars.DarkGraspExpireTime) or vars.DarkGraspExpireTime < Game.Time then
			vars.DarkGraspExpireTime = Game.Time + 1000
		end
		--[[
		if Stp == false then
			Stp = true
			Sleep(1024)
			Stp = false
		end
		]]--
	end
	
	--Slow
	if t.Spell == 35 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		vars.SlowExpireTime = Game.Time + 2000
		vars.SwiftPotionBuffTime = 0
		--[[
		if Spd == 1 then
			Spd = 0.5
			Sleep(2048)
			Spd = 1
		end
		]]--
	end
	
	--Stun
	if t.Spell == 34 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		t.ObjectType = Game.SpellObjId[34]
		t.CallDefault(2)
		--[[
		vars.StunExpireTime = Game.Time + 200
		]]--
		--[[
		for _, pl in Party do
			pl.RecoveryDelay = math.max(pl.RecoveryDelay, 200/1.625)
		end
		if Stp == false then
			Stp = true
			Sleep(200)
			Stp = false
		end
		]]--
	end
	
	--Reanimate
	if t.Spell == 89 and t.Monster.ShowAsHostile == true and t.Monster.Ally ~= 9999 and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		local val = Mas + Skill/10
		local ReMonList = {}
		local cnt = 0
		for i,v in Map.Monsters do
			if MonCanBeReanimated(v,Mon) then
				local dist = GetDist(Mon,v.X,v.Y,v.Z)
				local num = 1
				if dist < 1000 and dist >= 500 then
					num = 3
				elseif dist < 500 then
					num = 8
				end
				for j = 1, num do
					cnt = cnt + 1
					ReMonList[cnt] = v
				end
			end
		end
		if cnt > 0 then 
			local mon = ReMonList[math.random(1,cnt)]
			local TxtMon = Game.MonstersTxt[mon.Id]
			local min, ceil = math.min, math.ceil
			mon.FullHP = ceil(min(TxtMon.FullHP * (1 + mon.Elite / 2), 30000) * ReanimateHP[0])
			SetAttackMaxDamage2(mon, mon.Attack1, math.ceil(TxtMon.Attack1.DamageDiceSides) * TxtMon.Attack1.DamageDiceCount * (1 + mon.Elite) * (MonsterEliteDamage[mon.NameId] or 1) * ReanimateDmg[0])
			SetAttackMaxDamage2(mon, mon.Attack2, math.ceil(TxtMon.Attack2.DamageDiceSides) * TxtMon.Attack2.DamageDiceCount * (1 + mon.Elite) * (MonsterEliteDamage[mon.NameId] or 1) * ReanimateDmg[0])
			mon.MoveSpeed = TxtMon.MoveSpeed * ReanimateSpeed[0]
			mon.Velocity = mon.MoveSpeed
			mon.HP = math.min(mon.FullHP, Skill * Mas * 10)
			mon.AIState = const.AIState.Active
			mon.Bits = Mon.Bits
			mon.Active = true
			mon.Group = Mon.Group
			mon.Ally = Mon.Ally
			mon.Hostile = Mon.Hostile
			mon.ShowAsHostile = Mon.ShowAsHostile
			mon.AIType = Mon.AIType
			mon.HostileType = Mon.HostileType
			mon.Experience = 0
			mon.TreasureItemPercent = 0
		end
	end
	
	--PrismaticLight
	if t.Spell == 84 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)	
		if GetDist(t.Monster,Party.X,Party.Y,Party.Z) <= 5000 then
			if vars.PartyResistanceDecrease.ExpireTime < Game.Time then
				vars.PartyResistanceDecrease.ExpireTime = Game.Time + 2500
				vars.PartyResistanceDecrease.Power = 20
			else
				vars.PartyResistanceDecrease.ExpireTime = Game.Time + 2500
				vars.PartyResistanceDecrease.Power = vars.PartyResistanceDecrease.Power + 20
			end
			vars.LastCastSpell = Game.Time
		end
		--Game.ShowMonsterBuffAnim(t.MonsterIndex)
		t.ObjectType = 8060
		t.CallDefault(2)
		if GetDist(t.Monster,Party.X,Party.Y,Party.Z) <= 5000 then
			for i,pl in Party do
				pl.SpellBuffs[const.PlayerBuff.Fate].ExpireTime = Game.Time + 2500
				pl.SpellBuffs[const.PlayerBuff.Fate].Skill = 0
				evt.DamagePlayer(i, const.Damage.Light, Skill)
			end
			vars.MonsterAttackTime = Game.Time
			vars.StuckDetected = 0
		end
	end
	
	--Dispel Magic
	if t.Spell == 80 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		for i,pl in Party do
			pl.MightBonus = 0
			pl.IntellectBonus = 0
			pl.PersonalityBonus = 0
			pl.EnduranceBonus = 0
			pl.SpeedBonus = 0
			pl.AccuracyBonus = 0
			pl.LuckBonus = 0
			pl.FireResistanceBonus = 0
			pl.AirResistanceBonus = 0
			pl.WaterResistanceBonus = 0
			pl.EarthResistanceBonus = 0
			pl.SpiritResistanceBonus = 0
			pl.MindResistanceBonus = 0
			pl.BodyResistanceBonus = 0
		end
		--[[
		evt.All.Set("MightBonus", 0)
		evt.All.Set("IntellectBonus", 0)
		evt.All.Set("PersonalityBonus", 0)
		evt.All.Set("EnduranceBonus", 0)
		evt.All.Set("SpeedBonus", 0)
		evt.All.Set("AccuracyBonus", 0)
		evt.All.Set("LuckBonus", 0)
		evt.All.Set("FireResBonus", 0)
		evt.All.Set("AirResBonus", 0)
		evt.All.Set("WaterResBonus", 0)
		evt.All.Set("EarthResBonus", 0)
		evt.All.Set("SpiritResBonus", 0)
		evt.All.Set("MindResBonus", 0)
		evt.All.Set("BodyResBonus", 0)
		evt.All.Set("LightResBonus", 0)
		evt.All.Set("DarkResBonus", 0)
		]]--
	end
	
	--SummonElemental
	if t.Spell == 82 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		if t.Monster.NameId == 193 then
			local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)	
			local summonlist = {246}
			local NewMon = SummonMonster(summonlist[1], math.random(t.Monster.X-500, t.Monster.X+500), math.random(t.Monster.Y-500, t.Monster.Y+500), t.Monster.Z + math.random(50,150), true)
			if NewMon then
				NewMon.AIState = const.AIState.Active
				NewMon.Bits = t.Monster.Bits
				NewMon.Active = true
				NewMon.Group = t.Monster.Group
				NewMon.Ally = t.Monster.Ally
				NewMon.Hostile = t.Monster.Hostile
				NewMon.ShowAsHostile = t.Monster.ShowAsHostile
				NewMon.Experience = 0
				NewMon.TreasureItemPercent = 0
				PrepareMapMon(NewMon)
				t.Monster.AttackRecovery = 350 
			end
			t.CallDefault(80)
		else
			local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
			local summonlist = {75,78,81,84,132,117,141,159}
			local NewMon = SummonMonster(summonlist[math.random(1,8)], math.random(t.Monster.X-100, t.Monster.X+100), math.random(t.Monster.Y-100, t.Monster.Y+100), t.Monster.Z + math.random(50,150), true)
			if NewMon then
				NewMon.AIState = const.AIState.Active
				NewMon.Bits = t.Monster.Bits
				NewMon.Active = true
				NewMon.Group = t.Monster.Group
				NewMon.Ally = t.Monster.Ally
				NewMon.Hostile = t.Monster.Hostile
				NewMon.ShowAsHostile = t.Monster.ShowAsHostile
				NewMon.Experience = 0
				NewMon.TreasureItemPercent = 0
				PrepareMapMon(NewMon)
				t.Monster.AttackRecovery = 1000 
			end
		end
	end
	
	--Lightning Ball
	if t.Spell == 16 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		t.ObjectType = 12014
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		t.CallDefault(2, JoinSkill(Skill, Mas))
	end
	
	--Curse
	if t.Spell == 64 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		vars.MonsterAttackTime = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas <= 3 then
			local cond = math.random(0, 3)
			if cond == 3 then
				local pl = {}
				local cnt = 0
				for i,v in Party do
					if v.Dead == 0 then
						cnt = cnt  + 1
						pl[cnt] = i
					end
				end
				local num = math.random(1, cnt)
				evt[pl[num]].Set("Insane",1)
			else
				local pl = {}
				local cnt = 0
				for i,v in Party do
					if v.Dead == 0 then
						cnt = cnt  + 1
						pl[cnt] = i
					end
				end
				local num = math.random(1, cnt)
				if cond == 0 then
					evt[pl[num]].Set("Cursed",1)
				elseif cond == 1 then
					evt[pl[num]].Set("Asleep",1)
				elseif cond == 2 then
					evt[pl[num]].Set("Afraid",1)
				end
				if cnt >= 2 then
					local num2 = math.random(1, cnt - 1)
					if num2 >= num then
						num2 = num2 + 1
					end
					if cond == 0 then
						evt[pl[num2]].Set("Cursed",1)
					elseif cond == 1 then
						evt[pl[num2]].Set("Asleep",1)
					elseif cond == 2 then
						evt[pl[num2]].Set("Afraid",1)
					end
				end
			end
		elseif Mas == 4 then
			local cond = math.random(0, 3)
			if cond == 3 then
				local pl = {}
				local cnt = 0
				for i,v in Party do
					if v.Dead == 0 then
						cnt = cnt  + 1
						pl[cnt] = i
					end
				end
				local num = math.random(1, cnt)
				evt[pl[num]].Set("Insane",1)
				if cnt >= 2 then
					local num2 = math.random(1, cnt - 1)
					if num2 >= num then
						num2 = num2 + 1
					end
					evt[pl[num2]].Set("Insane",1)
				end
			else
				local pl = {}
				local cnt = 0
				for i,v in Party do
					if v.Dead == 0 then
						if cond == 0 then
							evt[i].Set("Cursed",1)
						elseif cond == 1 then
							evt[i].Set("Asleep",1)
						elseif cond == 2 then
							evt[i].Set("Afraid",1)
						end
					end
				end
			end
		end
		if t.Monster.NameId == 191 then
			t.Monster.AttackRecovery = 0
		end
	end
	
	--Invisible
	if t.Spell == 19 and t.Monster.ShowAsHostile == true and Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime <= Game.Time then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		vars.MonsterAttackTime = Game.Time
		if t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time and t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power >= 1000 then
			t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = Game.Time + const.Year
			t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power = t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power + 1
		else
			t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = Game.Time + const.Year
			t.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power = 1000
		end
		t.Monster.SpellBuffs[const.MonsterBuff.Fate].ExpireTime = 0
		t.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = 0
		t.Monster.SpellBuffs[const.MonsterBuff.Slow].ExpireTime = 0
		t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = 0
		t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime = 0
		if Mas == const.GM then
			local cnt = 0
			for i,v in Party do
				if v:IsConscious() then
					cnt = cnt + 1
				end
			end
			local target_pl = math.random(0, cnt - 1)
			for i,v in Party do
				if v:IsConscious() then
					target_pl = target_pl - 1
					if target_pl == 0 then
						local mattack = t.Monster.Attack1
						local dmg = mattack.DamageDiceCount * mattack.DamageDiceSides / 2
						dmg = math.random(math.ceil(dmg * 0.75), math.ceil(dmg * 1.25))
						evt.DamagePlayer(math.random(0,cnt - 1), const.Phys, dmg)
						break
					end
				end
			end
		end
	end
	
	if t.Spell == 18 and t.Monster.ShowAsHostile == true and t.Monster.NameId == 192 then
		t.ObjectType = 2060
		vars.LastCastSpell = Game.Time
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		t.CallDefault(15, JoinSkill(Skill, Mas))
		--local tmp = math.random(0, Party.length - 1)
		--local pl = Party[tmp]
		--local dmg = Skill * math.random(4,6)
		--evt.DamagePlayer(tmp,const.Damage.Body,dmg)
		--t.Monster.HP = math.min(t.Monster.FullHP, t.Monster.HP + dmg)
	end

	-- GM spell boost

	-- Firebolt 2: Double damage
	-- Haste 5: Affect all monsters
	if t.Spell == 5 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas == const.GM then 
			local x,y,z = XYZ(t.Monster)
			local Mon = t.Monster
			for i,v in Map.Monsters do
				if MonCanBeAffected(v, Mon) then
					v.SpellBuffs[const.MonsterBuff.Haste].ExpireTime = math.max(v.SpellBuffs[const.MonsterBuff.Haste].ExpireTime, Game.Time + const.Minute * 5)
					v.SpellBuffs[const.MonsterBuff.Haste].Skill = const.GM
					Game.ShowMonsterBuffAnim(i)
				end
			end
		end
	end
	-- Fireball 6: Quick cast
	if t.Spell == 6 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas == const.GM then 
			t.Monster.AttackRecovery = 5
		end
	end
	--Incinerate 11: continuous burn and stop regeneration 

	--Shield 17: 80% chance to block arrow

	-- Lightning Bolt 18: Paralyze and quick cast
	if t.Spell == 18 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas == const.GM then 
			Sleep(1)
			t.Monster.AttackRecovery = t.Monster.AttackRecovery / 2
		end
	end

	-- Invisible 19: Blink Strike

	-- Ice Blast 32
	if t.Spell == 32 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas == const.GM then 
			t.ObjectType = 3090
			vars.LastCastSpell = Game.time
			t.CallDefault(15, JoinSkill(Skill, 1))

		end
	end

	-- Curse 64: Improve effect

	-- Psychic Shock 65: Control the Party for a few seconds
	if t.Spell == 65 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas == const.GM then 
			if (not vars.DarkGraspExpireTime) or vars.DarkGraspExpireTime < Game.Time + 100 then
				vars.DarkGraspExpireTime = Game.Time + 100
			end
		end
	end

	-- Power cure 67: Improve effect and no numbers limit

	-- Divine Restoration 69: No debuff strength limit

	-- Dispel Magic 80: Add Slow effect
	if t.Spell == 80 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		if Mas == const.GM then 
			vars.DispelSlowExpireTime = Game.Time + 100
		end
	end
	--Bless
	--[[
	if t.Spell == 46 then
		local Skill, Mas = SplitSkill(t.Monster.Spell == t.Spell and t.Monster.SpellSkill or t.Monster.Spell2Skill)
		local Skill1, Mas1 = SplitSkill(t.Monster.SpellSkill)
		local Skill2, Mas2 = SplitSkill(t.Monster.Spell2Skill)
		if Skill1 ~= 0 and Mas1 ~= 0 then
			Skill1 = math.ceil(Skill1 * (1 + (Skill / 10 + Mas) * 0.01))
			Mas1 = math.min(Mas1 + 1, 4)
			t.Monster.SpellSkill = math.
		end
	end
	]]--
end

function events.MonsterCanCastSpell(t)
	--Message("Hello")
	--if t.Spell == 77 then
	--Message(tostring(t.Result).." "..tostring(t.Spell).." "..tostring(t.Distance))
	--end
	--[[
	t.Result = 1
	if t.Spell == 77 then
		--local x,y,z = XYZ(t.Monster)
		--local Mon = t.Monster
		t.Result = 1
		--for i,v in Map.Monsters do
		--	if MonCanBeHealed(v, Mon) then
		--		t.Result = 1
		--		break
		--	end
		--end
	end
	if t.Spell == 89 then
		local x,y,z = XYZ(t.Monster)
		local Mon = t.Monster
		t.Result = 0
		for i,v in Map.Monsters do
			if MonCanBeReanimated(v, Mon) then
				t.Result = 1
				break
			end
		end
	end
	if t.Spell == 66 then
		t.Result = 0
		for i = 0, Party.length - 1 do
			local v = Party[i]
			if v.SP ~=0 then
				t.Result = 1
				break
			end
		end
	end
	if t.Spell == 62 or t.Spell == 85 or t.Spell == 86 or t.Spell == 54 or t.Spell == 33 then
		t.Result = 1
	end
	]]--
end

-- Fix monster Day of Protection references
asmpatch(0x42595B, "cmp dword ptr [eax + 0x1A0], edx")
asmpatch(0x425965, "cmp dword ptr [eax + 0x19C], edx")
asmpatch(0x42596D, "movzx ecx, word ptr [eax + 0x1A4]")

-- Monsters cannot cast paralyze, replace this spell:
local SpellReplace = {[81] = 87, [83] = 85}
function events.MonsterCastSpellM(t)
	t.Spell = SpellReplace[t.Spell] or t.Spell
end

-- Enable several disabled monster spells
mem.IgnoreProtection(true)
mem.u1[0x40603A] = 0	-- Deadly Swarm
mem.u1[0x406061] = 0	-- Flying Fist
mem.u1[0x406072] = 4	-- Make Shrapmetal to use Sparks processing instead of broken own one
mem.IgnoreProtection(false)

-- Immolation
local function InDist(Mon)
	if Mon.Active and Mon.HP > 0 then
		if GetDist(Mon, Party.X, Party.Y, Party.Z) < 300 then
			return true
		end
	end
	return false
end

local immolation = false
local starttime = 0
local imsk, immas
function events.LoadMapScripts()
	immolation = false
end
local function Test(d)
--	Party[0].HP = Party[0].HP - 100
	immolation = true
	starttime = math.floor(Game.Time / 128)
	imsk = d.edi  -- ��ϵ�ȼ� 
	immas = d.eax + 1 -- mastery
	d.eax = d.eax - 1
end
local timelist = {}
local cnt = 0
--function internal.OnTimer()
--	if timelist[math.floor(Game.Time / 128)]~=true and immolation == true and math.floor(Game.Time / 128) < starttime + 10 * immas then -- 1 real time second
--		for i,v in Map.Monsters do
--			if InDist(v) and v.Hostile == true then
--				v.HP = math.max(v.HP - imsk * (0.99 ^ (v.FireResistance - 20)), 0)
--				-- Game.ShowMonsterBuffAnim(i)
--			end
--		end
--		timelist[math.floor(Game.Time / 128)] = true
--		timelist[math.floor(Game.Time / 128) - 1] = false
--	end
--end
--mem.hook(0x427A64, Test)

Log(Merge.Log.Info, "Init finished: %s", LogId)
