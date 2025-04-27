--local timelist = {}
--cnt = 0
--function internal.OnTimer()
--	if timelist[math.floor(Game.Time / 128)]~=true then -- 1 real time second
--		Party[0].HP = Party[0].HP - 10
--		timelist[math.floor(Game.Time / 128)] = true
--	end
--end

local MonsterSpellDamage=  {[0] = 0,0.0, 4.5, 0.0, 0.0, 0.0, 3.5, 5.5, 0.0, 2.0, 5.0,10.5, 
									0.0, 0.0, 0.0, 2.0, 0.0, 0.0, 4.5, 0.0, 5.5, 0.0, 2.0,
									0.0, 2.5, 0.0, 5.5, 0.0, 0.0, 8.0, 0.0, 0.0, 3.5,10.0,
									0.0, 0.0, 0.0,23.0, 0.0,12.0, 0.0, 5.5, 0.0,40.0, 0.0,
									0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 0.0, 0.0,
									0.0, 0.0, 0.0, 6.0, 0.0, 0.0, 4.0, 0.0, 0.0,12.5, 0.0,
									0.0, 0.0, 0.0, 2.5, 0.0, 0.0, 0.0, 0.0, 0.0, 5.5, 0.0,
									5.5, 9.5, 0.0, 0.0, 0.0, 0.0, 5.0, 0.0, 0.0,10.5, 0.0,
									0.0, 5.5, 0.0, 0.0, 3.5, 0.0, 0.0, 0.0,13.0, 0.0,10.0}
									
local LichIncreaseConstant = 1.3

local function BolsterAdjust(x)
	return (1 + 5.5 * x) / 6 * 0.99 ^ ((2 - x) * 40)
end

local function LogBolsterAdjust()
	local BolsterMul = Game.BolsterAmount / 100
	return math.log(BolsterAdjust(BolsterMul))/math.log(0.99)
end

local function GetDist(x,y)
	return ((x.X-y.X) * (x.X-y.X) + (x.Y-y.Y) * (x.Y-y.Y) + (x.Z-y.Z) * (x.Z-y.Z)) ^ 0.5
end

local function GetPlayerId(Player)
	local tpl = 0
	for i,pl in Party do
		if pl == Player then
			tpl = i
		end
	end
	return tpl
end

local function PrintDamageAdd(dmg)
	dmg = math.floor(dmg)
	if dmg ~= 0 then
		Sleep(1)
		if Game.StatusMessage ~= nil then
			local fl = 0
			local str = ""
			local val = 0
			for i = 1, #Game.StatusMessage do
				local ch = string.sub(Game.StatusMessage,i,i)
				if ch >= '0' and ch <= '9' then
					val = val * 10 + ch - '0'
					if fl ~= 1 then
						fl = fl + 1
					end
				elseif fl == 1 then
					str = str..tostring(math.max(val + dmg,0))
					fl = 2
					str = str..ch 
				else
					str = str..ch 
				end
			end
			if fl == 2 then
				Game.StatusMessage = str
			end
		end
	end
end

local function PrintDamageAdd2(dmg, Lastdeal)
	dmg = math.floor(dmg)
	if dmg ~= 0 then
		Sleep(1)
		if Game.StatusMessage ~= nil then
			local fl = 0
			local str = ""
			local val = 0
			for i = 1, #Game.StatusMessage do
				local ch = string.sub(Game.StatusMessage,i,i)
				if ch >= '0' and ch <= '9' then
					val = val * 10 + ch - '0'
					if fl ~= 1 then
						fl = fl + 1
					end
				elseif fl == 1 then
					if val > dmg then
						return
					end
					str = str..tostring(val + dmg)
					fl = 2
					str = str..ch 
				else
					str = str..ch 
				end
			end
			if fl == 2 then
				Game.StatusMessage = str
			end
		end
	end
end

local function DamageMonster(mon, dmg, hit_animation)
	if mon.HP > 0 then
		Sleep(1)
	end
	if mon.HP > 0 then
		mon.HP = math.max(0, mon.HP - dmg)
		if mon.HP == 0 then
			local cnt = 0
			for i,v in Party do
				if v:IsConscious() then
					cnt = cnt + 1
				end
			end
			local exp = mon.Experience / cnt
			for i,v in Party do
				if v:IsConscious() then
					v.Experience = v.Experience + exp * (1 + v:GetLearningTotalSkill() / 100)
				end
			end
		else
			if hit_animation then
				mon:GotHit(4)
			end
		end
	end
end

---------------------------------
--function events.CalcSpellDamage(dmg, spell, skill, mastery, HP)
--	vars.LastCastSpell = Game.Time
--end

---------------------------------

function CalcBowDmgAdd(Player)
	local it = Player:GetActiveItem(const.ItemSlot.Bow)
	if not it then
		return 0
	end
	local sk, mas = SplitSkill(Player:GetSkill(const.Skills.Bow))
	if it and it:T().Skill == const.Skills.Bow and mas >= const.Expert then
		local mi= Player:GetMight()
		if mas == const.GM then
			return mi * 0.4 + sk + sk * sk * 0.15
		else
			return mi * 0.4 + sk * 2 + sk * sk * 0.15
		end
	else
		return 0
	end
end

---------------------------------

function CalcBowDmgPhysAdd(Player)
	local it = Player:GetActiveItem(const.ItemSlot.MainHand)
	if not it then
		return 0
	end
	local sk, mas = SplitSkill(Player:GetSkill(it:T().Skill))
	if it then
		return sk * 10
	else
		return 0
	end
end

---------------------------------

function CalcBowDmgMagicAdd(Player, Magic)
	local it = Player:GetActiveItem(const.ItemSlot.MainHand)
	if not it then
		return 0
	end
	local sk, mas = SplitSkill(Player:GetSkill(Magic))
	if it then
		return sk * 1.5
	else
		return 0
	end
end

---------------------------------
function events.PlayerAttacked(t,attacker) --���﹥������ �����˺�����
	local BolsterMul = Game.BolsterAmount / 100
	vars.LastCastSpell = Game.Time
	if attacker.Monster then
		if attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time and attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power > 10 and GetDist(attacker.Monster,Party) <= 500 then
			vars.InvisibleStrike = Game.Time + 1
			vars.InvisibleStrikeMul = (attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power - 999) * 2
			attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = 0
		end
		--Message(tostring(attacker.MonsterAction))
		local mattack = attacker.Monster.Attack1
		if attacker.MonsterAction == const.MonsterAction.Attack2 then
			mattack = attacker.Monster.Attack2
		end
		vars.MonsterAttackTime = Game.Time
		vars.StuckDetected = 0 
		if attacker.Monster.SpellBuffs[const.MonsterBuff.Haste].ExpireTime > Game.Time then
			--Message(tostring(attacker.Monster.AttackRecovery))
			attacker.Monster.AttackRecovery = 0
		elseif attacker.Monster.SpellBuffs[const.MonsterBuff.HourOfPower].ExpireTime > Game.Time then
			attacker.Monster.AttackRecovery = math.max(0, attacker.Monster.AttackRecovery * 0.75)
		end
		if attacker.Monster.SpellBuffs[const.MonsterBuff.Slow].ExpireTime > Game.Time then
			--Message(tostring(attacker.Monster.AttackRecovery))
			attacker.Monster.AttackRecovery = math.max(0, attacker.Monster.AttackRecovery / 3)
		end
		if attacker.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime > Game.Time then
			--[[
			if attacker.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Skill == 5 then
				attacker.Monster.AttackRecovery = math.max(0, attacker.Monster.AttackRecovery * 1.2)
			elseif attacker.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Skill == 6 then
				attacker.Monster.AttackRecovery = math.max(0, attacker.Monster.AttackRecovery * 1.4)
			end
			]]--
			if attacker.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Skill >= 5 then
				local reduce_pow = attacker.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Power * 0.01
				attacker.Monster.AttackRecovery = math.max(0, attacker.Monster.AttackRecovery * (1 + reduce_pow))
			end
		end
		if attacker.Monster.SpellBuffs[const.MonsterBuff.Wander].ExpireTime > Game.Time then
			if math.random(1,100) <= attacker.Monster.SpellBuffs[const.MonsterBuff.Wander].Skill * 5 then
				t.Handled = true
				return
			end
		end
		--Message(tostring(attacker.Monster.AttackRecovery))
		--Message(tostring(attacker.Spell))
		--Message(tostring(attacker.Object.Spell))
		if (not attacker.Object) then
			if t.Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime >= Game.Time then
				t.Player.SpellBuffs[const.PlayerBuff.Misform].Power = t.Player.SpellBuffs[const.PlayerBuff.Misform].Power + 1
				if t.Player.SpellBuffs[const.PlayerBuff.Misform].Power == 2 then
					t.Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime = Game.Time
				end
				t.Handled = true
				return
			end

			if Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime >= Game.Time and vars.PlayerCastImmolation then
				attacker.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].Power = math.max(attacker.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].Power, Party.SpellBuffs[const.PartyBuff.Immolation].Power)
				attacker.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = Game.Time + const.Minute * 10
				local dmg = CalcRealDamageM(Party.SpellBuffs[const.PartyBuff.Immolation].Power, const.Damage.Fire, true, Party[vars.PlayerCastImmolation], attacker.Monster)
				attacker.Monster.HP = math.max(0, attacker.Monster.HP - dmg)
				attacker.Monster:GotHit(4)
			end

			local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
			if it and it:T().Skill == const.Skills.Staff then
				local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Staff))
				if mas == 4 and (100 + sk * 2) >= math.random(1000) then
					local dmg = CalcRealDamageM(math.random(t.Player:GetMeleeDamageMin(),t.Player:GetMeleeDamageMax()), const.Damage.Phys, true, t.Player, attacker.Monster)
					attacker.Monster.HP = math.max(0, attacker.Monster.HP - dmg)
					attacker.Monster:GotHit(4)
					t.Handled = true
					return
				end
			end

			local dmg = mattack.DamageDiceCount * mattack.DamageDiceSides / 2
			if attacker.Monster.SpellBuffs[const.MonsterBuff.Heroism].ExpireTime > Game.Time then
				dmg = dmg * 1.5
			end
			if attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time and attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power <= 10 then
				dmg = dmg * (1 - (attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power) * 0.1)
			end
			local magicmul = 1
			if mattack.Type ~= const.Damage.Phys then
				magicmul = 0.99 ^ (125 - LogBolsterAdjust() - BolsterMul * 60)
			end
			if attacker.Monster.SpellBuffs[const.MonsterBuff.Bless].ExpireTime > Game.Time then
				dmg = math.ceil(dmg * 1.5 * magicmul)
				evt.DamagePlayer(t.PlayerSlot,mattack.Type, dmg)
			else
				dmg = math.random(math.ceil(dmg * 0.75 * magicmul), math.ceil(dmg * 1.25 * magicmul))
				evt.DamagePlayer(t.PlayerSlot,mattack.Type, dmg)
			end
			
			t.Handled = true
		elseif attacker.Object.Spell == 0 then
			if t.Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime >= Game.Time then
				t.Player.SpellBuffs[const.PlayerBuff.Misform].Power = t.Player.SpellBuffs[const.PlayerBuff.Misform].Power + 1
				if t.Player.SpellBuffs[const.PlayerBuff.Misform].Power == 2 then
					t.Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime = Game.Time
				end
				t.Handled = true
				return
			end
			local dmg = mattack.DamageDiceCount * mattack.DamageDiceSides / 2
			--Message(tostring(dmg).." "..tostring(t.PlayerSlot))
			if attacker.Monster.SpellBuffs[const.MonsterBuff.Heroism].ExpireTime > Game.Time then
				dmg = dmg * 1.5
			end
			if t.Player.SpellBuffs[const.PlayerBuff.Shield].ExpireTime > Game.Time or Party.SpellBuffs[const.PartyBuff.Shield].ExpireTime > Game.Time then
				dmg = dmg * 0.85
			end
			if attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time then
				dmg = dmg * (1 - (attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power) * 0.1)
			elseif attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time and attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power > 10 and GetDist(attacker.Monster,Party) <= 500 then
				dmg = dmg * 2
				attacker.Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = 0
			end
			local magicmul = 1
			if mattack.Type ~= const.Damage.Phys then
				magicmul = 0.99 ^ (125 - LogBolsterAdjust() - BolsterMul * 60)
			end
			if attacker.Monster.SpellBuffs[const.MonsterBuff.Bless].ExpireTime > Game.Time then
				evt.DamagePlayer(t.PlayerSlot,mattack.Type,math.ceil(dmg * 1.5 * magicmul))
			else
				evt.DamagePlayer(t.PlayerSlot,mattack.Type,math.random(math.ceil(dmg * 0.75 * magicmul), math.ceil(dmg * 1.25 * magicmul)))
			end
			t.Handled = true
		else
			if attacker.Object.Type == Game.SpellObjId[34] then
				vars.StunExpireTime = Game.Time + 250
			end
			if attacker.Object.Type == 1010 and attacker.Object.Spell == 62 then
				evt.DamagePlayer(t.PlayerSlot,const.Damage.Fire,attacker.Object.SpellSkill * math.random(3,5))
			end
			--Message(tostring(attacker.Object.Type).." "..tostring(attacker.Object.SpellSkill))
			if attacker.Object.Type == 3091 and attacker.Object.Spell == 33 then
				evt.DamagePlayer(t.PlayerSlot,const.Damage.Water,attacker.Object.SpellSkill * math.random(5,15))
			end
			if attacker.Object.Spell == 70 then
				if vars.PartyArmorDecrease.ExpireTime < Game.Time then
					vars.PartyArmorDecrease.ExpireTime = Game.Time + 2500
					vars.PartyArmorDecrease.Power = 20
				else
					vars.PartyArmorDecrease.ExpireTime = Game.Time + 2500
					vars.PartyArmorDecrease.Power = vars.PartyArmorDecrease.Power + 20
				end
			end
			if attacker.Object.Spell == 26 then
				vars.SlowExpireTime = math.max((vars.SlowExpireTime or 0), Game.Time + 250)
			end
			if attacker.Object.Spell == 41 then
				
				local sk,mas = SplitSkill(attacker.Object.SpellSkill) --BUG????
				--Message(tostring(sk).." "..tostring(mas))
				for i,pl in Party do
					evt.DamagePlayer(i,const.Damage.Earth,sk * math.random(4,7))
				end
				--evt.DamagePlayer(0,const.Damage.Earth,sk * math.random(4,7))
				attacker.Object.SpellSkill = 0
				t.Handled = true
			end
		end
		if (not attacker.Object) or attacker.Object.Spell == 0 then
			if attacker.Monster.Bonus > 0 then
				local DoBadThing = false
				if math.random(1,100) <= attacker.Monster.BonusMul * 5 or attacker.Monster.Bonus == const.MonsterBonus.Drainsp then
					DoBadThing = true
				end
				--[[
				if Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime > Game.Time then
					if Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].Power >= attacker.Monster.BonusMul then
						DoBadThing = false
					end
					Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].Power = math.max(0, Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].Power - attacker.Monster.BonusMul)
					if Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].Power == 0 then
						Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime = Game.Time
					end
				end
				]]--
				if DoBadThing == true then
					--t.Player:DoBadThing(attacker.Monster.Bonus, Monster)
					if attacker.Monster.Bonus == const.MonsterBonus.Poison1 then
						evt[t.PlayerSlot].Set("Poison1",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Poison2 then
						evt[t.PlayerSlot].Set("Poison2",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Poison3 then
						evt[t.PlayerSlot].Set("Poison3",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Disease1 then
						evt[t.PlayerSlot].Set("Disease1",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Disease2 then
						evt[t.PlayerSlot].Set("Disease2",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Disease3 then
						evt[t.PlayerSlot].Set("Disease3",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Paralyze then
						evt[t.PlayerSlot].Set("Paralyzed",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Stone then
						evt[t.PlayerSlot].Set("Stoned",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Drainsp then
						t.Player.SP = math.max(0, t.Player.SP - t.Player:GetFullSP() * 0.01 * attacker.Monster.BonusMul)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Afraid then
						evt[t.PlayerSlot].Set("Afraid",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Insane then
						evt[t.PlayerSlot].Set("Insane",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Curse then
						evt[t.PlayerSlot].Set("Cursed",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Weak then
						evt[t.PlayerSlot].Set("Weak",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Dead then
						evt[t.PlayerSlot].Set("Dead",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Errad then
						evt[t.PlayerSlot].Set("Eradicated",1)
					elseif attacker.Monster.Bonus == const.MonsterBonus.Uncon then
						evt[t.PlayerSlot].Set("Unconscious",1)
					end
				end
			end
		end
	elseif (not attacker.Player) and attacker.Object and attacker.Object.Spell ~= 0 then
		if attacker.Object.SpellSkill > 0 then
			attacker.Object.SpellSkill = JoinSkill(999,4)
		end
	end
	
end

---------------------------------

function events.ExitMapAction(t) --��ֹ�ڸ����й�ʱ������ 
	--Stp = false
	--Spd = 1
	if (Party.EnemyDetectorRed or Party.EnemyDetectorYellow) then
		for i = 0, Party.length - 1 do
			Party[i].HP = -1000
		end
	end
end
---------------------------------

function events.GetResistance(t) --���� 

if t.Resistance == const.Damage.Fire then
	t.Result = t.Result - math.min(t.Player.SpellBuffs[const.PlayerBuff.FireResistance].Power, Party.SpellBuffs[const.PartyBuff.FireResistance].Power)
elseif t.Resistance == const.Damage.Water then
	t.Result = t.Result - math.min(t.Player.SpellBuffs[const.PlayerBuff.WaterResistance].Power, Party.SpellBuffs[const.PartyBuff.WaterResistance].Power)
elseif t.Resistance == const.Damage.Air then
	t.Result = t.Result - math.min(t.Player.SpellBuffs[const.PlayerBuff.AirResistance].Power, Party.SpellBuffs[const.PartyBuff.AirResistance].Power)
elseif t.Resistance == const.Damage.Earth then
	t.Result = t.Result - math.min(t.Player.SpellBuffs[const.PlayerBuff.EarthResistance].Power, Party.SpellBuffs[const.PartyBuff.EarthResistance].Power)
elseif t.Resistance == const.Damage.Body then
	t.Result = t.Result - math.min(t.Player.SpellBuffs[const.PlayerBuff.BodyResistance].Power, Party.SpellBuffs[const.PartyBuff.BodyResistance].Power) 
elseif t.Resistance == const.Damage.Mind then
	t.Result = t.Result - math.min(t.Player.SpellBuffs[const.PlayerBuff.MindResistance].Power, Party.SpellBuffs[const.PartyBuff.MindResistance].Power) 
end
local tpl = GetPlayerId(t.Player)
if vars.PlayerResistances == nil then
	vars.PlayerResistances = {}
end
if vars.PlayerResistances[tpl] == nil then
	vars.PlayerResistances[tpl] = {}
end
vars.PlayerResistances[tpl][t.Resistance] = t.Result
--t.Player.Resistances[t.Resistance].Custom = t.Result
--Message(tostring(t.Result) .. " " .. tostring(t.Resistance))
end


---------------------------------

function CalcRealDamageM(Damage,DamageKind,ByPlayer,Player,Monster)
--Message(tostring(Damage).." "..tostring(DamageKind))
local ac= 0
local mac= 0
local nt= 0
local mnt= 0
local pe= 0
local mpe= 0
local BolsterMul = Game.BolsterAmount / 100
local Result = 0
local BlessTweak = 0 
local invisadd = 0
local MinotaurPhysMul = 1
local mnpIncrease = 1
if ByPlayer then
	ac = Player:GetAccuracy()
	nt = Player:GetIntellect()
	pe = Player:GetPersonality()
	if Player.SpellBuffs[const.PlayerBuff.Bless].ExpireTime > Game.Time then
		BlessTweak = 5
	end
	if Player.Afraid ~= 0 then
		BlessTweak = BlessTweak - 51
	end
	if Player.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime > Game.Time then
		BlessTweak = BlessTweak + Player.SpellBuffs[const.PlayerBuff.Glamour].Power / 10
	end
	if Player.Class >= 108 and Player.Class <= 119 then
		local sk,mas = SplitSkill(Player:GetSkill(const.Skills.Stealing))
		invisadd = invisadd - (mas * 5 + sk)
	end
	if Player.Face == 20 or Player.Face == 21 then
		MinotaurPhysMul = 1.3
	end
	if Player.Face == 26 or Player.Face == 27 then
		mnpIncrease = LichIncreaseConstant
	end
end
mnp = math.max(nt, pe)
local acpenalty = ac * 0.25 - 0.000125 * ac * ac
local nppenalty = (mnp * 0.18 - 0.00009 * mnp * mnp) * mnpIncrease
local dayofprotectionad = 0
if Monster.SpellBuffs[const.MonsterBuff.DayOfProtection].ExpireTime >= Game.Time then
	dayofprotectionad = 70
end
local PrimAdd = 0
if Monster.SpellBuffs[const.MonsterBuff.Fate].ExpireTime > Game.Time then
	PrimAdd = math.min(Monster.SpellBuffs[const.MonsterBuff.Fate].Power * 0.002, 1)
end
local hourofpowerad = 0
if Monster.SpellBuffs[const.MonsterBuff.StoneSkin].ExpireTime >= Game.Time then
	hourofpowerad = 70
end
if Monster.SpellBuffs[const.MonsterBuff.HourOfPower].ExpireTime >= Game.Time then
	hourofpowerad = hourofpowerad + 28.6
	dayofprotectionad = dayofprotectionad + 28.6
end
if Monster.SpellBuffs[const.MonsterBuff.Shield].ExpireTime >= Game.Time then
	dayofprotectionad = dayofprotectionad + 10.5
	hourofpowerad = hourofpowerad + 10.5
end
if Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime > Game.Time and Monster.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power > 10 then
	invisadd = invisadd + 137.9
end
local InfeAdd = 0
if Monster.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime > Game.Time then
	InfeAdd = math.min(Monster.SpellBuffs[const.MonsterBuff.Hammerhands].Power * 0.002, 1)
end


if DamageKind == const.Damage.Phys then
	local ar= math.max(0,Monster.ArmorClass + hourofpowerad) - acpenalty * 0.6 - BlessTweak
	if Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime > Game.Time then
		if Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].Skill >= 5 then 
			ar = ar - Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].Skill
		else
			ar = ar - 15
		end
	end
	ar = ar + Monster.PhysResistance
	
	Result = math.ceil(Damage * (0.99 ^ (ar))) * (1 + InfeAdd) * MinotaurPhysMul
	if Monster.PhysResistance > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Fire then
	local firer= Monster.FireResistance - acpenalty - nppenalty + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (firer))) * (1 + PrimAdd)
	if firer > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Air then
	local airr= Monster.AirResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (airr))) * (1 + PrimAdd)
	if airr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Water then
	local waterr= Monster.WaterResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (waterr))) * (1 + PrimAdd)
	if waterr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Earth then
	local earthr= Monster.EarthResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (earthr))) * (1 + PrimAdd)
	if earthr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Mind then
	local mindr= Monster.MindResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (mindr))) * (1 + PrimAdd)
	if mindr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Body then
	local bodyr= Monster.BodyResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (bodyr))) * (1 + PrimAdd)
	if bodyr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Spirit then
	local spiritr= Monster.SpiritResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (spiritr))) * (1 + PrimAdd)
	if spiritr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Light then
	local lightr= Monster.LightResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (lightr))) * (1 + PrimAdd)
	if lightr > 10000 then
		Result = 0
	end
elseif  DamageKind == const.Damage.Dark then
	local darkr= Monster.DarkResistance - acpenalty - nppenalty  + dayofprotectionad - BlessTweak + invisadd
	Result = math.ceil(Damage * (0.99 ^ (darkr))) * (1 + PrimAdd)
	if darkr > 10000 then
		Result = 0
	end
else
	Result = math.ceil(Damage * (0.99 ^ (invisadd - BlessTweak)))
end

return Result
end

---------------------------------

local function CalcRealDamage(Player,Damage,DamageKind)
--Message(tostring(Damage).." "..tostring(DamageKind))
if vars.Invincible and vars.Invincible > Game.Time then
	return 0
end
if vars.InvisibleStrike and vars.InvisibleStrike >= Game.Time then
	Damage = Damage * vars.InvisibleStrikeMul
end
if Player.Insane ~= 0 then
	Damage = Damage * 3
end
if Player.Afraid ~= 0 then
	Damage = Damage * 1.5
end
local BolsterMul = Game.BolsterAmount / 100
local ar= Player:GetArmorClass()
local en= Player:GetEndurance()
if en < 1000 then
	en = en - 0.0005 * en * en
end 
--Message(tostring(ar).." "..tostring(en).." "..tostring(Damage).." "..tostring(DamageKind))
local tmp = 0
local tpl = GetPlayerId(Player)
if DamageKind <= 5 or DamageKind == 7 or DamageKind == 8 then
	if vars.PlayerResistances then
		if vars.PlayerResistances[tpl] then
			if vars.PlayerResistances[tpl][DamageKind] then
				tmp = vars.PlayerResistances[tpl][DamageKind]
			end
		end
	end
	if tmp < 1000 then
		tmp = tmp - 0.0005 * tmp * tmp
	end 
--	if Player.Resistances[DamageKind].Custom then
--		tmp = Player.Resistances[DamageKind].Custom
--	end
elseif DamageKind == 6 or DamageKind == 9 or DamageKind == 10 then
	tmp = Player:GetLuck()
	if tmp < 1000 then
		tmp = tmp - 0.0005 * tmp * tmp
	end
	tmp = tmp * 0.8 + en * 0.2
end

if ar < 1000 then
	ar = ar - 0.0005 * ar * ar
end

if Player.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime > Game.Time then
	tmp = tmp + Player.SpellBuffs[const.PlayerBuff.Glamour].Power / 10
end

local rd = en * 0.2
--Message(tostring(tmp))
if DamageKind == const.Damage.Phys then
	if Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime >= Game.Time then
		Player.SpellBuffs[const.PlayerBuff.Misform].Power = Player.SpellBuffs[const.PlayerBuff.Misform].Power + 1
		if Player.SpellBuffs[const.PlayerBuff.Misform].Power == 2 then
			Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime = Game.Time
		end
		return 0
	else
		return math.ceil(Damage * (0.99 ^ (ar + rd - 100 - BolsterMul * 60)))
	end
else
	return math.ceil(Damage * (0.99 ^ (tmp + rd - 225 + LogBolsterAdjust())))
end

end

---------------------------------

function events.MonsterAttacked(t,attacker) --���ﱻ���� 
	if attacker.MonsterIndex then
		vars.PlayerAttackTime = Game.Time
		--vars.LastCastSpell = Game.Time
		if t.Monster.Active == true then
			if attacker.Object and attacker.Object.Spell ~= 0 then
				local sk,mas = SplitSkill(attacker.Object.SpellSkill)
				local spell = attacker.Object.Spell
				local dmg = sk * MonsterSpellDamage[spell] * 2 * math.random(40,60) / 50
				if t.Monster.PhysResistance < 10000 then
					dmg = dmg * (0.99 ^ t.Monster.PhysResistance)
				end
				t.Monster.HP = math.max(0, t.Monster.HP - dmg)	
			else
				local dmg = attacker.Monster.Attack1.DamageDiceSides * attacker.Monster.Attack1.DamageDiceCount * 0.5 * math.random(40,60) / 50
				dmg = dmg * (0.99 ^ t.Monster.PhysResistance)
				if t.Monster.PhysResistance < 10000 then
					dmg = dmg * (0.99 ^ t.Monster.PhysResistance)
				end
				t.Monster.HP = math.max(0, t.Monster.HP - dmg)	
			end
		else
			if attacker.Monster.Id == 97 or attacker.Monster.Id == 98 or attacker.Monster.Id == 99 or attacker.Monster.Ally == 9999 or attacker.Monster.SpellBuffs[const.MonsterBuff.Enslave].ExpireTime > Game.Time or attacker.Monster.SpellBuffs[const.MonsterBuff.Berserk].ExpireTime > Game.Time then
				attacker.Monster.HP = 0
			end
		end
		if attacker.Monster.Id == 97 or attacker.Monster.Id == 98 or attacker.Monster.Id == 99 or attacker.Monster.Ally == 9999 or attacker.Monster.SpellBuffs[const.MonsterBuff.Enslave].ExpireTime > Game.Time or attacker.Monster.SpellBuffs[const.MonsterBuff.Berserk].ExpireTime > Game.Time then
			if attacker.Monster.ShowHostile ~= true and GetDist(t.Monster,Party) >= 10000 then
				attacker.Monster.HP = 0
			end
		end
		if (t.Monster.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime >= Game.Time and (t.Monster.Id == 97 or t.Monster.Id == 98 or t.Monster.Id == 99)) or (t.Monster.Ally == 9999 and t.Monster.ShowAsHostile == false) then
			vars.MonsterAttackTime = Game.Time
			vars.LastCastSpell = Game.Time
			vars.StuckDetected = 0
		end
		t.Handled = true
	else
		if attacker.PlayerIndex then
			vars.PlayerAttackTime = Game.Time
			vars.LastCastSpell = Game.Time
			if t.Monster.SpellBuffs[const.MonsterBuff.PainReflection].ExpireTime > 0 then
				local tmptime = t.Monster.SpellBuffs[const.MonsterBuff.PainReflection].ExpireTime
				t.Monster.SpellBuffs[const.MonsterBuff.PainReflection].ExpireTime = 0
				Sleep(1)
				if t.Monster.HP > 0 then
					t.Monster.SpellBuffs[const.MonsterBuff.PainReflection].ExpireTime = tmptime
				end
			end
		end
		if attacker.Object and attacker.Player then
			--Message(tostring(attacker.Object.Spell))
			vars.PlayerAttackTime = Game.Time
			vars.LastCastSpell = Game.Time
			if attacker.Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime < Game.Time then
				--Message(tostring(attacker.Object.Spell))
				if attacker.Object.Spell == 133 then
					local dmg = CalcRealDamageM(CalcBowDmgAdd(attacker.Player), const.Damage.Phys, true, attacker.Player, t.Monster)
					local itt = attacker.Player:GetActiveItem(const.ItemSlot.Bow)
					local skt, mast = SplitSkill(attacker.Player:GetSkill(const.Skills.Bow))
					if mast == const.GM then
						local dmgadd = 0
						local tmp
						tmp = CalcRealDamageM(CalcBowDmgPhysAdd(attacker.Player), const.Damage.Phys, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Fire), const.Damage.Fire, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Air), const.Damage.Air, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Water), const.Damage.Water, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Earth), const.Damage.Earth, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Spirit), const.Damage.Spirit, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Mind), const.Damage.Mind, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Body), const.Damage.Body, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Dark), const.Damage.Dark, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						tmp = CalcRealDamageM(CalcBowDmgMagicAdd(attacker.Player, const.Skills.Light), const.Damage.Light, true, attacker.Player, t.Monster)
						if tmp > dmgadd then
							dmgadd = tmp
						end
						dmg = dmg + dmgadd
					end
					DamageMonster(t.Monster, dmg, false)
					PrintDamageAdd2(dmg)
				end
			end
			if attacker.Object.Spell == 39 then
				t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime = Game.Time + const.Day
			elseif attacker.Object.Spell == 59 then
				local sk,mas = attacker.Object.SpellSkill,attacker.Object.SpellMastery
				if mas >= 4 then
					for _,mon in Map.Monsters do
						if mon ~= t.Monster and GetDist(t.Monster,mon) <= 250 and mon.HP > 0 then
							local dmg = CalcRealDamageM(sk * math.random(4,8) + 11, const.Damage.Mind, true, attacker.Player, mon)
							DamageMonster(mon, dmg, true)
						end
					end
				end
			elseif attacker.Object.Spell == 26 then
				if t.Monster.WaterResistance < 1000 then
					t.Monster.SpellBuffs[const.MonsterBuff.Slow].Power = math.max(t.Monster.SpellBuffs[const.MonsterBuff.Slow].Power, 2)
					t.Monster.SpellBuffs[const.MonsterBuff.Slow].Skill = math.max(t.Monster.SpellBuffs[const.MonsterBuff.Slow].Skill, 1)
					t.Monster.SpellBuffs[const.MonsterBuff.Slow].ExpireTime = Game.Time + const.Minute * 10
				end
			elseif attacker.Object.Spell == 70 then
				if t.Monster.BodyResistance < 1000 then
					t.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].Power = math.max(t.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].Power, attacker.Object.SpellSkill * (4 + attacker.Object.SpellMastery) * 0.5)
					t.Monster.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = Game.Time + const.Minute * attacker.Object.SpellSkill
				end
			elseif attacker.Object.Spell == 52 then
				local sk,mas = attacker.Object.SpellSkill,attacker.Object.SpellMastery
				if t.Monster.SpiritResistance < 1000 then
					local minhp = t.Monster.FullHP * (0.95 - mas * 0.05)
					if t.Monster.HP > minhp then
						local dmg = math.min(t.Monster.HP - minhp, t.Monster.FullHP * (0.02 + sk * 0.0005))
						t.Monster.HP = t.Monster.HP - dmg
						--t.Monster:GotHit(4)
						PrintDamageAdd(dmg)
					else
						t.Monster.HP = t.Monster.HP + 1
						PrintDamageAdd(-1)
					end
				end
			elseif attacker.Object.Spell == 84 then
				local sk,mas = attacker.Object.SpellSkill,attacker.Object.SpellMastery
				t.Monster.SpellBuffs[const.MonsterBuff.Fate].ExpireTime = Game.Time + const.Day
				if t.Monster.SpellBuffs[const.MonsterBuff.Fate].Power then
					t.Monster.SpellBuffs[const.MonsterBuff.Fate].Power = t.Monster.SpellBuffs[const.MonsterBuff.Fate].Power + math.floor(sk * 1.25 + 50)
				else
					t.Monster.SpellBuffs[const.MonsterBuff.Fate].Power = math.floor(sk * 1.25 + 50)
				end
				Game.ShowMonsterBuffAnim(t.MonsterIndex)
				t.Handled = true
			elseif attacker.Object.Spell == const.Spells.Souldrinker then
				if vars.SouldrinkerAttackCount == nil then
					vars.SouldrinkerAttackCount = 0
				end
				vars.SouldrinkerAttackCount =  vars.SouldrinkerAttackCount + 1
			elseif attacker.Object.Spell == const.Spells.ShootDragon then
				local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.DragonAbility))
				local dmgmin = sk+10
				local dmgmax = sk*10+10
				dmg = CalcRealDamageM(math.random(dmgmin,dmgmax), vars.HammerhandDamageType, true, attacker.Player, t.Monster)
				--Message(tostring(dmg).." Ranged")
				if dmg == 0 then
					t.Handled = true
				else
					DamageMonster(t.Monster, dmg, false)
					PrintDamageAdd(dmg)
				end
			elseif attacker.Object.Spell == 111 then --There's a bug. lifedrain is 111 instead of 113
				local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.VampireAbility))
				local oridmg = attacker.Player:GetFullHP() * 0.05 * (mas + 1)
				local dmg = CalcRealDamageM(oridmg, const.Damage.Body, true, attacker.Player, t.Monster)
				--attacker.Player.HP = math.min(attacker.Player.HP + math.min(oridmg, t.Monster.HP), attacker.Player:GetFullHP())
				DamageMonster(t.Monster, dmg, false)
				local regen = math.round(oridmg / 200)
				for _,pl in Party do
					pl.SpellBuffs[const.PlayerBuff.Regeneration].Power = regen
					pl.SpellBuffs[const.PlayerBuff.Regeneration].ExpireTime = Game.Time + const.Minute * 10
				end
				PrintDamageAdd(dmg)
			end
			
		end
		if attacker.PlayerIndex and not attacker.Object then
			if attacker.Player.SpellBuffs[const.PlayerBuff.Misform].ExpireTime < Game.Time then
				local it = attacker.Player:GetActiveItem(const.ItemSlot.MainHand)
				local dmg = 0
				if it and it:T().Skill == const.Skills.Dagger then
					local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.Dagger))
					if mas == const.GM and math.random(1,100) <= sk + 10 then
						dmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), const.Damage.Phys, true, attacker.Player, t.Monster) * 2
						if it.Number == 569 then
							dmg = dmg * 1.5
						end
						DamageMonster(t.Monster, dmg, false)
						attacker.Player.HP = math.min(attacker.Player:GetFullHP(), attacker.Player.HP + dmg * 0.25)
					end
				elseif it and it:T().Skill == const.Skills.Axe then
					local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.Axe))
					if mas == const.GM then
						if t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime < Game.Time then
							t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime = Game.Time + const.Day
							Game.ShowMonsterBuffAnim(t.MonsterIndex)
						else
							t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].ExpireTime = Game.Time + const.Day
						end
						t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].Skill = 25
						if attacker.Player.Class >= 52 and attacker.Player.Class <= 59 then -- Minotaurs
							local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.Stealing))
							t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].Skill = t.Monster.SpellBuffs[const.MonsterBuff.ArmorHalved].Skill + (mas * 5 + sk) * 0.5
						end
					end
					if it.Number == 1309 then
						dmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), const.Damage.Phys, true, attacker.Player, t.Monster) + CalcRealDamageM(math.random(3,18), const.Damage.Fire, true, attacker.Player, t.Monster)
						dmg = math.min(dmg, t.Monster.HP)
						--Message(tostring(dmg))
						attacker.Player.HP = math.min(attacker.Player:GetFullHP(), attacker.Player.HP + dmg * 0.4)
						dmg = 0
					end
				elseif it and it:T().Skill == const.Skills.Mace then
					local sk0,mas0 = SplitSkill(attacker.Player.Skills[const.Skills.Mace])
					local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.Mace)) -- A terrible way to remove automatic casted stun
					attacker.Player.Skills[const.Skills.Mace] = JoinSkill(sk0,math.min(2,mas0))
					
					if mas == 3 then
						if 10 >= math.random(1,100) then
							dmg = 100
							t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = Game.Time + const.Minute
							t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Skill = 5
							t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Power = 50
						end
					elseif mas == 4 then
						if 10 >= math.random(1,100) then
							for i,v in Map.Monsters do
								if v~=t.Monster and GetDist(t.Monster,v) <= 250 then
									local tmpdmg = CalcRealDamageM(100, const.Damage.Phys, true, attacker.Player, v)
									v.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = Game.Time + const.Minute
									v.SpellBuffs[const.MonsterBuff.DamageHalved].Skill = 5
									v.SpellBuffs[const.MonsterBuff.DamageHalved].Power = 50
									DamageMonster(v, tmpdmg, true)
								end
							end
							dmg = CalcRealDamageM(100, const.Damage.Phys, true, attacker.Player, t.Monster)
							t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = Game.Time + const.Minute
							t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Skill = 5
							t.Monster.SpellBuffs[const.MonsterBuff.DamageHalved].Power = 50
						end
					end
					if mas > 2 then
						dmg = dmg + CalcRealDamageM(sk * (mas-2), const.Damage.Phys, true, attacker.Player, t.Monster)
						DamageMonster(t.Monster, dmg, false)
					end
					
					Sleep(1)
					attacker.Player.Skills[const.Skills.Mace] = JoinSkill(sk0,mas0)
				elseif it and it:T().Skill == const.Skills.Staff then
					local sk0,mas0 = SplitSkill(attacker.Player.Skills[const.Skills.Staff])
					local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.Staff)) -- A terrible way to remove automatic casted stun
					local sk1,mas1 = SplitSkill(attacker.Player:GetSkill(const.Skills.Unarmed))
					
					attacker.Player.Skills[const.Skills.Staff] = JoinSkill(sk0,math.min(2,mas0))
					if mas >= 3 then
						if sk >= math.random(1,1000) and t.Monster.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime < Game.Time then
							t.Monster.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime = Game.Time + const.Minute
							t.Monster.SpellBuffs[const.MonsterBuff.Paralyze].Power = 1
						end
						if t.Monster.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime >= Game.Time then
							dmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), const.Damage.Phys, true, attacker.Player, t.Monster) * 0.5
						end
						local orgdmg = sk * (mas-2) * 0.5
						if mas == 4 then
							orgdmg = orgdmg + sk1 * math.max(0, mas1 - 1)
						end
						dmg = dmg + CalcRealDamageM(orgdmg, const.Damage.Phys, true, attacker.Player, t.Monster)
						DamageMonster(t.Monster, dmg, false)
					end
					Sleep(1)
					attacker.Player.Skills[const.Skills.Staff] = JoinSkill(sk0,mas0)
				elseif it and it:T().Skill == const.Skills.Spear then
					local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.Spear)) -- A terrible way to remove automatic casted stun
					local function get_line_dist(Party, mon1, mon2, min_error)
						local x1,y1,z1 = XYZ(Party)
						local x2,y2,z2 = XYZ(mon1)
						local x3,y3,z3 = XYZ(mon2)
						local disa = ((x2-x1) ^ 2 + (y2-y1) ^ 2 + (z2-z1) ^ 2) ^ 0.5
						local disb = ((x3-x1) ^ 2 + (y3-y1) ^ 2 + (z3-z1) ^ 2) ^ 0.5
						local disc = ((x3-x2) ^ 2 + (y3-y2) ^ 2 + (z3-z2) ^ 2) ^ 0.5
						local half_p = (disa + disb + disc) / 2
						local AreaS = ((half_p - disa) * (half_p - disb) * (half_p - disc) * half_p) ^ 0.5
						local dish = AreaS * 2 / disa
						if dish < min_error and (disa ^ 2 + disb ^ 2 > disc ^ 2) then
							return (disb ^ 2 - dish ^ 2) ^ 0.5
						else
							return 99999
						end
					end
					if mas >= 2 and mas <= 3 then
						local mindist = 10000
						local mindistmon = nil
						for i,v in Map.Monsters do
							if v ~= t.Monster then
								local tmpdist = get_line_dist(Party, t.Monster, v, 50) 
								if tmpdist < mindist then
									mindist = tmpdist
									mindistmon = v
								end
							end
						end
						if mindist <= 300 then
							dmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), const.Damage.Phys, true, attacker.Player, mindistmon)
							DamageMonster(mindistmon, dmg, true)
						end
					elseif mas == 4 then
						local mindist = 10000
						local secmindist = 10000
						local mindistmon = nil
						local secmindistmon = nil
						for i,v in Map.Monsters do
							if v ~= t.Monster then
								local tmpdist = get_line_dist(Party, t.Monster, v, 50) 
								if tmpdist < mindist then
									secmindist = mindist
									secmindistmon = mindistmon
									mindist = tmpdist
									mindistmon = v
								elseif tmpdist < secmindist then
									secmindist = tmpdist
									secmindistmon = v
								end
							end
						end
						if mindist <= 600 then
							dmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), const.Damage.Phys, true, attacker.Player, mindistmon)
							DamageMonster(mindistmon, dmg, true)
						end
						if secmindist <= 600 then
							local tmpdmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), const.Damage.Phys, true, attacker.Player, secmindistmon)
							DamageMonster(secmindistmon, tmpdmg, true)
						end
					end
					
				elseif (not it) then
					if attacker.Player.Class >= 28 and attacker.Player.Class <= 35 then --Dragon
						local sk,mas = SplitSkill(attacker.Player:GetSkill(const.Skills.DragonAbility))
						local dmgmin = sk+10
						local dmgmax = sk*10+10
						dmg = CalcRealDamageM(math.random(dmgmin,dmgmax), vars.HammerhandDamageType, true, attacker.Player, t.Monster)
						--Message(tostring(dmg).." Melee")
						if dmg == 0 then
							t.Handled = true
						else
							DamageMonster(t.Monster, dmg, false)
							--PrintDamageAdd(dmg)
						end
					else
						if attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill >= 1 then
							dmg = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), (vars.HammerhandDamageType or const.Damage.Body), true, attacker.Player, t.Monster) * (0.1 + attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Power * 0.0025)
							DamageMonster(t.Monster, dmg, false)
							attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill = attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill - 1
						end
					end
				end
				if it and (it:T().Skill == const.Skills.Sword or it:T().Skill == const.Skills.Dagger or it:T().Skill == const.Skills.Axe or it:T().Skill == const.Skills.Staff or it:T().Skill == const.Skills.Spear or it:T().Skill == const.Skills.Mace) then
					if attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill >= 1 then
						if it:T().Skill == const.Skills.Staff then
							local dmg1 = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), (vars.HammerhandDamageType or const.Damage.Body), true, attacker.Player, t.Monster) * (0.1 + attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Power * 0.0025)
							DamageMonster(t.Monster, dmg1, false)
							attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill = attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill - 1
							dmg = dmg + dmg1
						else
							local dmg1 = CalcRealDamageM(math.random(attacker.Player:GetMeleeDamageMin(),attacker.Player:GetMeleeDamageMax()), (vars.HammerhandDamageType or const.Damage.Body), true, attacker.Player, t.Monster) * (0.04 + attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Power * 0.001)
							DamageMonster(t.Monster, dmg1, false)
							attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill = attacker.Player.SpellBuffs[const.PlayerBuff.Hammerhands].Skill - 1
							dmg = dmg + dmg1
						end
						
					end
				end
				PrintDamageAdd(dmg)
			end
		end
	end
	--Sleep(1)
	t.Monster.SpellBuffs[const.MonsterBuff.Stoned].ExpireTime = 0
end
---------------------------------
--[[
function events.Regeneration(t) --��Ѫ���� 
	local sk,mas = SplitSkill(t.Player.Skills[const.Skills.Regeneration])
	t.HP =  - math.ceil((0.005 + sk * mas * 0.001) * t.Player:GetFullHP() + mas)
end
]]--
---------------------------------
--[[
function CalcDamageToPlayerWithPerception(Player, Damage, DamageKind)
	local sk, mas = SplitSkill(Player:GetSkill(const.Skills.Perception))
	--Message(tostring(t.Damage))
	if mas >= const.Expert and Player.Dead == 0 and Player.Unconscious == 0 then
		local p = math.max(0.99 ^ (4 * mas * sk), 0.1)
		local cnt = 0
		local tpl
		for i,pl in Party do
			cnt = cnt + 1
			if pl == Player then
				tpl = i
			end
		end
		if tpl == nil then
			return
		end
		if cnt >= 2 then
			local num = math.random(0,cnt-2)
			if num >= tpl then
				num = num + 1
			end
			Party[num].HP = Party[num].HP - CalcRealDamage(Party[num],Damage,DamageKind) * (1 - p)
			Player.HP = Player.HP - CalcRealDamage(Player,Damage,DamageKind) * p
			--t.Result = CalcRealDamage(Player,Damage,DamageKind) * p
		else
			Player.HP = Player.HP - CalcRealDamage(Player,Damage,DamageKind) * p
		end
	else
		--local tmpppp = CalcRealDamage(Player,Damage,DamageKind)
		--Message(tostring(tmpppp).." "..tostring(Damage).." "..tostring(DamageKind))
		Player.HP = Player.HP - CalcRealDamage(Player,Damage,DamageKind)
		--Result = CalcRealDamage(Player,Damage,DamageKind)
	end
end
]]--

function CalcDamageToPlayerWithPerception(Player, Damage, DamageKind)
	--Message(tostring(Player:GetIndex()).." "..tostring(Damage).." "..tostring(DamageKind))
	--if Damage > 2000 then
	--	Message(tostring(Player:GetIndex()).." "..tostring(Damage).." "..tostring(DamageKind))
	--end
	local sk, mas = SplitSkill(Player:GetSkill(const.Skills.Perception))
	--Message(tostring(t.Damage))
	if mas >= const.Expert and Player.Dead == 0 and Player.Unconscious == 0 then
		local p = math.max(1-(0.05+mas*0.01)*sk, 0.1)
		local cnt = 0
		local maxp = 1
		local prob = {}
		local plst = {}
		for i,pl in Party do
			local sk1,mas1 = SplitSkill(pl:GetSkill(const.Skills.Repair))
			if pl ~= Player and mas1 >= const.Expert and pl.Dead == 0 and pl.Unconscious == 0 then
				cnt = cnt + 1
				prob[cnt] = math.min((0.015+mas1*0.0025)*sk1, 0.25)
				plst[cnt] = pl
				maxp = maxp - prob[cnt]
			end
		end
		if cnt >= 1 then
			--Message(tostring(p).." "..tostring(maxp).." "..tostring(cnt).." ["..tostring(prob[1]).." "..tostring(prob[2]).." "..tostring(prob[3]).." "..tostring(prob[4]).."]")
			local sprob = {prob[1]}
			for i = 2,cnt do
				sprob[i] = prob[i] + sprob[i-1]
			end
			for i = 1,cnt do
				sprob[i] = sprob[i] * 30000 / sprob[cnt]
			end
			local respl = math.random(0,29999)
			for i = 1,cnt do
				if sprob[i] > respl then
					respl = plst[i]
					break
				end
			end
			--Message(tostring(p).." "..tostring(maxp).." "..tostring(cnt).." ["..tostring(sprob[1]).." "..tostring(sprob[2]).." "..tostring(sprob[3]).." "..tostring(sprob[4]).."]")
			local pres = math.max(p,maxp)
			Player.HP = Player.HP - CalcRealDamage(Player,Damage,DamageKind) * pres
			respl.HP = respl.HP - CalcRealDamage(Player,Damage,DamageKind) * (1-pres)
		else
			Player.HP = Player.HP - CalcRealDamage(Player,Damage,DamageKind)
		end
	else
		--local tmpppp = CalcRealDamage(Player,Damage,DamageKind)
		--Message(tostring(tmpppp).." "..tostring(Damage).." "..tostring(DamageKind))
		Player.HP = Player.HP - CalcRealDamage(Player,Damage,DamageKind)
		--Result = CalcRealDamage(Player,Damage,DamageKind)
	end
end

---------------------------------
function events.CalcDamageToPlayer(t) --��������
	if t.Damage == -12321 then
		t.Result = 0
		return
	end
	t.Result = 0
	if t.Player.SpellBuffs[const.PlayerBuff.PainReflection].ExpireTime >= Game.Time then
		for i,pl in Party do
			pl.SpellBuffs[const.PlayerBuff.PainReflection].Skill = math.max(pl.SpellBuffs[const.PlayerBuff.PainReflection].Skill - 1, 0)
			if pl.SpellBuffs[const.PlayerBuff.PainReflection].Skill == 0 then
				pl.SpellBuffs[const.PlayerBuff.PainReflection].ExpireTime = Game.Time
			end
		end
		local cnt = 0
		for i,pl in Party do
			cnt = cnt + 1
		end
		for _,pl in Party do
			CalcDamageToPlayerWithPerception(pl, t.Damage / cnt * (0.995 ^ (t.Player.SpellBuffs[const.PlayerBuff.PainReflection].Power - 5)), t.DamageKind)
		end
	else
		CalcDamageToPlayerWithPerception(t.Player, t.Damage, t.DamageKind)
	end
--[[
local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Perception))
--Message(tostring(t.Damage))
if mas >= const.Expert and t.Player.Dead == 0 and t.Player.Unconscious == 0 then
	local p = math.max(0.99 ^ (4 * mas * sk), 0.2)
	local cnt = 0
	local tpl
	for i,pl in Party do
		cnt = cnt + 1
		if pl == t.Player then
			tpl = i
		end
	end
	if tpl == nil then
		return
	end
	if cnt >= 2 then
		local num = math.random(0,cnt-2)
		if num >= tpl then
			num = num + 1
		end
		Party[num].HP = Party[num].HP - CalcRealDamage(Party[num],t.Damage,t.DamageKind) * (1 - p)
		t.Player.HP = t.Player.HP - CalcRealDamage(t.Player,t.Damage,t.DamageKind) * p
		--t.Result = CalcRealDamage(t.Player,t.Damage,t.DamageKind) * p
	else
		t.Player.HP = t.Player.HP - CalcRealDamage(t.Player,t.Damage,t.DamageKind) * p
	end
else
	--local tmpppp = CalcRealDamage(t.Player,t.Damage,t.DamageKind)
	--Message(tostring(tmpppp).." "..tostring(t.Damage).." "..tostring(t.DamageKind))
	t.Player.HP = t.Player.HP - CalcRealDamage(t.Player,t.Damage,t.DamageKind)
	--t.Result = CalcRealDamage(t.Player,t.Damage,t.DamageKind)
end
]]--
end

---------------------------------

function events.CalcDamageToMonster(t) --�����������
--Message(tostring(t.Monster.StartX).." "..tostring(t.Monster.StartY).." "..tostring(t.Monster.StartZ))
	if t.Damage == -12321 then
		t.Result = 1
	else
		t.Result = CalcRealDamageM(t.Damage,t.DamageKind,t.ByPlayer,t.Player,t.Monster)
		if t.ByPlayer then
			if t.Monster.SpellBuffs[const.MonsterBuff.PainReflection].Power > 0 then
				t.Player.HP = t.Player.HP - t.Result
			end
			if t.Player.Class >= 100 and t.Player.Class <= 107 then
				local sk,mas = SplitSkill(t.Player:GetSkill(const.Skills.VampireAbility))
				t.Player.HP = math.min(t.Player:GetFullHP(), t.Player.HP + t.Result * 0.01 * (mas * 5 + sk))
			--elseif t.Player.Class >= 28 and t.Player.Class <= 35 then -- Dragon
			--	t.Result = math.max(t.Result, 1)
			--	if t.DamageKind == const.Damage.Phys then
			--		t.Result = 1
			--	end
			end
			--evt.DamagePlayer(GetPlayerId(t.Player),t.DamageKind,t.Result * (t.Monster.SpellBuffs[const.MonsterBuff.PainReflection].Power * 0.0005 + 0.25))
		end
	end
end
---------------------------------

function events.CalcStatBonusByMagic(t)
	if t.Stat == const.Stats.MeleeAttack then -- AttackBonus is removed (changed to attack rate)
		t.Result = 0
	end
end

function events.CalcStatBonusByItems(t)
	if t.Stat == const.Stats.MeleeAttack then -- AttackBonus is removed
		t.Result = 0
	end
end

---------------------------------
--[[
function events.CalcStatBonusByItems(t)
	if t.Stat == const.Stats.MeleeDamageMin and t.Player.Class >= 28 and t.Player.Class <= 35 then -- DragonMelee
		local sk,mas = SplitSkill(t.Player:GetSkill(const.Skills.DragonAbility))
		t.Result = sk + 10
	end
end

function events.CalcStatBonusByItems(t)
	if t.Stat == const.Stats.MeleeDamageMax and t.Player.Class >= 28 and t.Player.Class <= 35 then -- DragonMelee
		local sk,mas = SplitSkill(t.Player:GetSkill(const.Skills.DragonAbility))
		t.Result = sk * 10 + 10
	end
end
]]--
---------------------------------

function events.CalcStatBonusByMagic(t)
	if t.Stat == const.Stats.RangedAttack then  -- AttackBonus is removed
		t.Result = 0
	end
end

function events.CalcStatBonusByItems(t)
if t.Stat == const.Stats.RangedAttack then -- AttackBonus is removed
t.Result = 0
end
end

---------------------------------


function events.CalcStatBonusByMagic(t) -- ����
if t.Stat == const.Stats.Might then
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempMight].Power)) / 5 - t.Player.MightBonus)
elseif t.Stat == const.Stats.Intellect then 
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempIntellect].Power)) / 5 - t.Player.IntellectBonus)
elseif t.Stat == const.Stats.Personality then 
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempPersonality].Power)) / 5 - t.Player.PersonalityBonus)
elseif t.Stat == const.Stats.Endurance then 
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempEndurance].Power)) / 5 - t.Player.EnduranceBonus)
elseif t.Stat == const.Stats.Speed then 
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempSpeed].Power)) / 5 - t.Player.SpeedBonus)
elseif t.Stat == const.Stats.Accuracy then 
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempAccuracy].Power)) / 5 - t.Player.AccuracyBonus)
elseif t.Stat == const.Stats.Luck then 
	t.Result = math.max(0, (t.Result - math.min(Party.SpellBuffs[const.PartyBuff.DayOfGods].Power, t.Player.SpellBuffs[const.PlayerBuff.TempLuck].Power)) / 5 - t.Player.LuckBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.ArmorClass then 
	t.Result = math.max(0, t.Result - t.Player.ArmorClassBonus- math.min(Party.SpellBuffs[const.PartyBuff.Stoneskin].Power, t.Player.SpellBuffs[const.PlayerBuff.Stoneskin].Power))
	if vars.PartyArmorDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyArmorDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.FireResistance then 
	t.Result = math.max(0, t.Result / 5 - t.Player.FireResistanceBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.AirResistance then 
	t.Result = math.max(0, t.Result / 5 - t.Player.AirResistanceBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.WaterResistance then 
	t.Result = math.max(0, t.Result / 5 - t.Player.WaterResistanceBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.EarthResistance then 
	t.Result = math.max(0, t.Result / 5 - t.Player.EarthResistanceBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.BodyResistance then 
	t.Result = math.max(0, t.Result / 5 - t.Player.BodyResistanceBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
elseif t.Stat == const.Stats.MindResistance then 
	t.Result = math.max(0, t.Result / 5 - t.Player.MindResistanceBonus)
	if vars.PartyResistanceDecrease.ExpireTime >= Game.Time then
		t.Result = t.Result - math.min(vars.PartyResistanceDecrease.Power, 100)
	end
end
if t.Player.Class >= 76 and t.Player.Class <= 83 and t.Stat >= const.Stats.Might and t.Stat <= const.Stats.Luck then -- Ranger Bonus
		
	local sk,mas = SplitSkill(t.Player:GetSkill(const.Skills.Stealing))
	local incre = mas * 0.5 + sk * 0.1
	local weapon_sk, weapon_mas = SplitSkill(t.Player.Skills[const.Skills.Axe])
	local bow_sk, bow_mas = SplitSkill(t.Player.Skills[const.Skills.Bow])
	local magic_sk, magic_mas = SplitSkill(t.Player.Skills[const.Skills.Fire])
	for j=const.Skills.Air,const.Skills.Dark do
		local tmpsk,tmpmas = SplitSkill(t.Player.Skills[j])
		if tmpsk > magic_sk then
			magic_sk = tmpsk
		end
	end
	local armor_sk, armor_mas = SplitSkill(t.Player.Skills[const.Skills.Shield])
	for j=const.Skills.Leather,const.Skills.Plate do
		local tmpsk,tmpmas = SplitSkill(t.Player.Skills[j])
		if tmpsk > armor_sk then
			armor_sk = tmpsk
		end
	end
	local min_sk = math.min(weapon_sk, bow_sk, magic_sk, armor_sk)
	
	t.Result = t.Result + math.floor(min_sk * incre)
end
end


---------------------------------



function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.SP then -- ħ��ֵ
		local nt= t.Player:GetIntellect()
		local pe= t.Player:GetPersonality()
		mnp = math.max(nt,pe)
		if t.Player.Face == 26 or t.Player.Face == 27 then
			mnp = mnp * LichIncreaseConstant
		end
		t.Result = t.Result * (1 + mnp * 0.01)
	end
end

---------------------------------

function events.CalcStatBonusByItems(t)
	if t.Stat == const.Stats.SP then -- ħ��ֵ
		t.Result = t.Result * 10
	end
end

---------------------------------


function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.HP then -- Ѫ��
		local en= t.Player:GetEndurance()
		local sk,mas = SplitSkill(t.Player:GetSkill(const.Skills.Bodybuilding))
		t.Result = t.Result * (1 + en * 0.01) + Game.Classes.HPFactor[t.Player.Class] * sk * mas;
	end
end

---------------------------------

function events.CalcStatBonusByItems(t)
	if t.Stat == const.Stats.HP then -- Ѫ��
		t.Result = t.Result * 10
	end
end

---------------------------------

function events.CalcStatBonusByItems(t)
	if t.Stat >= 10 and t.Stat <= 15 then -- ����
		local lu= t.Player:GetBaseLuck()
		local it = t.Player:GetActiveItem(const.ItemSlot.Armor)
		local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
		t.Result = t.Result + math.floor(lu * 0.2)
		if it and it:T().Skill == const.Skills.Leather then
			local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Leather))
			local sk4, mas4 = SplitSkill(t.Player:GetSkill(const.Skills.Dodging))
			t.Result = t.Result + math.max(0, sk1 * 3)
			if mas4 == const.GM and not(it2 and it2:T().Skill == const.Skills.Shield) then
				t.Result = t.Result + sk4 * 4
			end
		elseif it and it:T().Skill == const.Skills.Chain then
			local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Chain))
			t.Result = t.Result + math.max(0, sk2 * 4)
		elseif it and it:T().Skill == const.Skills.Plate then
			local sk3, mas3 = SplitSkill(t.Player:GetSkill(const.Skills.Plate))
			t.Result = t.Result + math.ceil(sk3 * 4.5)
		else
			local sk4, mas4 = SplitSkill(t.Player:GetSkill(const.Skills.Dodging))
			if not(it2 and it2:T().Skill == const.Skills.Shield) then
				t.Result = t.Result + sk4 * 5
			end
		end
		if it2 and it2:T().Skill == const.Skills.Shield then
			local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Shield))
			t.Result = t.Result + math.max(0, sk * 3)
		end
	end
end

---------------------------------

function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.ArmorClass then -- ����

		local it = t.Player:GetActiveItem(const.ItemSlot.Armor)
		local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
		if it and it:T().Skill == const.Skills.Leather then
			local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Leather))
			local sk4, mas4 = SplitSkill(t.Player:GetSkill(const.Skills.Dodging))
			t.Result = t.Result + math.max(0, (sk1-10)*1) + math.max(0, sk1 * (mas1 - 3) * 2)
			if mas4 == const.GM and not(it2 and it2:T().Skill == const.Skills.Shield) then
				t.Result = t.Result + sk4 * 2
			end
		elseif it and it:T().Skill == const.Skills.Chain then
			local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Chain))
			t.Result = t.Result + math.max(0, (sk2-10)*4) + math.max(0, sk2 * (mas2 - 3))
		elseif it and it:T().Skill == const.Skills.Plate then
			local sk3, mas3 = SplitSkill(t.Player:GetSkill(const.Skills.Plate))
			t.Result = t.Result + math.max(0, (sk3-10)*6)
		else
			local sk4, mas4 = SplitSkill(t.Player:GetSkill(const.Skills.Dodging))
			if not(it2 and it2:T().Skill == const.Skills.Shield) then
				t.Result = t.Result + sk4
			end
		end
		if it2 and it2:T().Skill == const.Skills.Shield then
			local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Shield))
			t.Result = t.Result + math.max(0, sk * 2)
		end
	end
end

---------------------------------

function CalcDmgByAM(sk,mas)
	if mas <= 2 then
		return sk * mas 
	elseif mas >= 3 then
		return sk * 2
	else
		return 0
	end
end

---------------------------------

function events.CalcStatBonusBySkills(t)
	
	for _, pl in Party do
		local maxsk = 0
		for i, learn in EnumAvailableSkills(pl.Class) do
			local skill, mastery = SplitSkill(pl.Skills[i])
			if i == const.Skills.Sword or i == const.Skills.Dagger or i == const.Skills.Axe or i == const.Skills.Staff or i == const.Skills.Spear or i == const.Skills.Mace or i == const.Skills.Unarmed then
				maxsk = math.max(maxsk,skill)
			end
		end
		for i, learn in EnumAvailableSkills(pl.Class) do
			local skill, mastery = SplitSkill(pl.Skills[i])
			if i == const.Skills.Sword or i == const.Skills.Dagger or i == const.Skills.Axe or i == const.Skills.Staff or i == const.Skills.Spear or i == const.Skills.Mace or i == const.Skills.Unarmed then
				if mastery == 0 then
					mastery = 1
				end
				pl.Skills[i] = JoinSkill(maxsk, mastery)
			end
		end
	end
	
	if t.Stat == const.Stats.MeleeDamageBase then -- ��
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Sword))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		if it and it:T().Skill == const.Skills.Sword then
			local mi= t.Player:GetMight()
			t.Result = t.Result + mi*0.6 + sk*mas/2 + CalcDmgByAM(sk1,mas1) + sk*sk*0.2
			if mas >= const.Expert then
				t.Result = t.Result * 1.05
			end
			if it:T().EquipStat == 1 then
				t.Result = t.Result + math.max(0,mi*1.2)
			else
				local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
				if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
					local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
					t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
				end
			end
		end
	end
end
---------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.MeleeDamageBase then -- ذ��
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Dagger))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		-----const.Novice�ǻ�����const.Expert��ר�ң�const.Master�Ǵ�ʦ��const.GM����ʦ
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		if it and it:T().Skill == const.Skills.Dagger then
			local mi= t.Player:GetMight()
			t.Result = t.Result + mi*0.5 + sk*mas*0.5/1.2 + CalcDmgByAM(sk1,mas1) + sk*sk*0.2/1.2
			if mas >= const.GM then
				t.Result = t.Result - sk
			end
			if mas >= const.Master then
				t.Result = t.Result * 1.25
			end
			local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
			if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
				local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
				t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
			end
		end
	end
end
--------------------------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.MeleeDamageBase then -- ��
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Axe))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		-----const.Novice�ǻ�����const.Expert��ר�ң�const.Master�Ǵ�ʦ��const.GM����ʦ
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		if it and it:T().Skill == const.Skills.Axe then
			local mi= t.Player:GetMight()
			t.Result = t.Result + mi*0.72 + sk*mas*0.6 + CalcDmgByAM(sk1,mas1) + sk*sk*0.24
			if mas >= const.Master then
				t.Result = t.Result - sk
			end
			if mas >= const.Expert then
				t.Result = t.Result + mi*0.1
			end
			if it:T().EquipStat == 1 then
				t.Result = t.Result + mi*1.44
			else
				local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
				if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
					local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
					t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
				end
			end
			if mas >= const.Master then
				t.Result = t.Result * 1.2
			end
		end
	end
end

-------------------------------------------------------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.MeleeDamageBase then -- Staff
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Staff))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		local sk2, mas2 = SplitSkill(t.Player:GetSkill(const.Skills.Unarmed))
		-----const.Novice�ǻ�����const.Expert��ר�ң�const.Master�Ǵ�ʦ��const.GM����ʦ
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		if it and it:T().Skill == const.Skills.Staff then
			local mi= t.Player:GetMight()
			local UnAdd = 0
			if mas == const.GM and mas2 == const.GM then
				UnAdd = UnAdd + sk2 * sk2 * 0.1
			end
			t.Result = t.Result + mi*0.6 + sk*mas/2 + CalcDmgByAM(sk1,mas1) + UnAdd + sk*sk*0.2
			if it:T().EquipStat == 1 then
				t.Result = t.Result + math.max(0,mi*1.2)
			else
				local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
				if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
					local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
					t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.MeleeDamageBase then -- ì
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Spear))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		-----const.Novice�ǻ�����const.Expert��ר�ң�const.Master�Ǵ�ʦ��const.GM����ʦ
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		if it and it:T().Skill == const.Skills.Spear then
			local mi= t.Player:GetMight()
			t.Result = t.Result + mi*0.6 + sk*mas/2 + CalcDmgByAM(sk1,mas1) + sk*sk*0.2
			local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
			if not it2 then
				t.Result = t.Result + math.max(0,mi*1.2)
			else 
				if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
					local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
					t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.MeleeDamageBase then --����
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Mace))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		-----const.Novice�ǻ�����const.Expert��ר�ң�const.Master�Ǵ�ʦ��const.GM����ʦ
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		if it and it:T().Skill == const.Skills.Mace then
			local mi= t.Player:GetMight()
			t.Result = t.Result + mi*0.6 + sk*mas/2 + CalcDmgByAM(sk1,mas1) + sk*sk*0.2
			local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
			if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
				local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
				t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
			end
		end
	end
end

-------------------------------------------------------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.MeleeDamageBase then --���� 
		local it = t.Player:GetActiveItem(const.ItemSlot.MainHand)
		local sk, mas = SplitSkill(t.Player:GetSkill(const.Skills.Unarmed))
		local sk1, mas1 = SplitSkill(t.Player:GetSkill(const.Skills.Armsmaster))
		if (not it) and (t.Player.Class < 28 or t.Player.Class > 35) then --Dragon
			local mi= t.Player:GetMight()
			if mas == const.GM then
				t.Result = t.Result + sk
			end
			t.Result = t.Result + math.max(0,mi*0.6)+math.max(0,sk*mas*0.4)+sk*sk*0.16
			local it2 = t.Player:GetActiveItem(const.ItemSlot.ExtraHand)
			if not it2 then
				if mas == 4 then
					t.Result = t.Result + math.max(0,mi*0.9)
				end
			else 
				if it2 and (it2:T().Skill == const.Skills.Sword or it2:T().Skill == const.Skills.Dagger) then
					local sk2, mas2 = SplitSkill(t.Player:GetSkill(it2:T().Skill))
					t.Result = t.Result + sk2*mas2/2 + CalcDmgByAM(sk1,mas1) + sk2*sk2*0.2
				end
			end
		elseif (not it) and (t.Player.Class >= 28 or t.Player.Class <= 35) then
			t.Result = 0
		end
	end
end

-------------------------------------------------------------------------------
function events.CalcStatBonusBySkills(t)
	if t.Stat == const.Stats.RangedDamageBase then
		t.Result = t.Result + CalcBowDmgAdd(t.Player)
	end
end

-------------------------------------------------------------------------------
function events.CanSaveGame(t)
	if Game.UseMonsterBolster == true and vars.LastCastSpell ~= nil and Game.Time - vars.LastCastSpell < const.Minute * 5 then
		t.Result = false
		Game.ShowStatusText("You cannot save in combat.")
	end
end

--[[
function events.DoBadThingToPlayer(t)
	t.Allow = false
end
]]--