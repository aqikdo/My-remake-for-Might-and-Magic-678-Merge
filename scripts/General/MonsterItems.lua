local random, floor, ceil = math.random, math.floor, math.ceil
local MonsterItems = {
[20] = 1004,
[21] = 1004,
[24] = 1006,
[64] = 1006,
[74] = 1016,
[75] = 1006,
[81] = 207,
[92] = 202,
[95] = 1009,
[150] = 1004,
[167] = 1016,
[168] = 1016,
[172] = 1006,
[186] = 1009

}

function events.MonsterKilled(mon)
	--[[
	if mon.Ally == 9999 then -- no drop from reanimated monsters
		return
	end
	]]--
	local monKind = ceil(mon.Id/3)
	local Mul = mon.Id - monKind*3 + 3
	local ItemId = MonsterItems[monKind]
	if ItemId and random(20) + Mul*2 > 13 then
		evt.SummonObject(ItemId, mon.X, mon.Y, mon.Z + 100, 100)
	end
end

local ItemProb = {0,1,1,1,1,3,3,3,3,4,4,
				  4,4,5,5,5,5,6,6,6,6,
				  6,6,6,6,6,7,7,7,7,7,
				  7,7,7,7,8,8,8,8,8,8,
				  8,8,8,9,9,9,9,9,9,9,
				  9,9,10,10,10,10,10,10,10,10,
				  11,11,11,11,11,11,11,11,11,11,
				  11,11,11,11,11,11,11,11,11,11,
				  11,11,11,11,11,11,11,11,11,11,
				  11,11,12,12,12,12,12,12,12,12}

local function GetOverallPartyLevel()
	local Ov, Cnt = 0, 1
	for i,v in Party do
		Ov = Ov + v.LevelBase
		Cnt = i + 1
	end
	return ceil(Ov/Cnt)
end

function events.PickCorpse(t)
	local mon = t.Monster
	if mon.Ally == 9999 then -- no drop from reanimated monsters
		return
	end
--	evt.GiveItem{Id=281}
	local mval = 0
	local lv = GetOverallPartyLevel()
	for i,v in Party do
		local sk, mas=SplitSkill(v.Skills[const.Skills.IdentifyItem])
		mval = math.max(mval, sk * 4 + mas * 2)
	end
	mval = math.min(mval, 48)
	if mon.TreasureItemPercent ~= 0 then
	if (mon.TreasureItemLevel >= 4 and lv <= 30) or (mon.TreasureItemLevel >= 5 and lv <= 50) or (mon.TreasureItemLevel >= 6) then
		while math.random(1,96) <= mval do
			evt.GiveItem(mon.TreasureItemLevel, ItemProb[math.random(1,100)])
		end
	end
	end
	if mon.TreasureItemLevel >= 4 and mon.TreasureItemLevel <= 5 then
		evt.GiveItem(mon.TreasureItemLevel, 14)
	end
	if mon.Elite ~= 0 then
		for i = 1, math.random(1,2) do 
			evt.GiveItem(mon.TreasureItemLevel, 14)
		end
		Party.AddGold(math.random(mon.Level , mon.Level * 2) * 10, 0)
	--	evt.Add("Gold",math.random(mon.Level , mon.Level * 2) * 10)
	--	evt.Add("Exp",math.random(mon.Level , mon.Level * 2) * 100)
	--	evt.Add(math.random(32,38),1)
	end
	if Game.UseMonsterBolster == true then
		mon.AIState = const.AIState.Removed
	end
end

-- Make monsters in indoor maps active once party sees them.
-- Make active monster nearby monster active

local function GetDist(t,x,y,z)
	local px, py, pz  = XYZ(t)
	return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
end
	
function MergeSort(arr, StartIndex, EndIndex)
	if StartIndex == EndIndex then
		return
	end
	local mid = math.floor((StartIndex + EndIndex) / 2)
--	print(StartIndex,mid,mid+1,EndIndex,"\n")
	MergeSort(arr, StartIndex, mid)
	MergeSort(arr, mid+1, EndIndex)
	local tarr = {}
	local p = StartIndex
	local q = mid+1
	for i = 0, EndIndex - StartIndex do
		if p == mid + 1 then
			tarr[i] = arr[q]
			q = q + 1
		elseif q == EndIndex + 1 then
			tarr[i] = arr[p]
			p = p + 1
		else
			if arr[p].SpellBuffs[const.MonsterBuff.Summoned].ExpireTime < arr[q].SpellBuffs[const.MonsterBuff.Summoned].ExpireTime then
				tarr[i] = arr[p]
				p = p + 1
			else
				tarr[i] = arr[q]
				q = q + 1
			end
		end
	end
	for i = StartIndex, EndIndex do
		arr[i] = tarr[i-StartIndex]
	end
end

function MergeSort2(arr, StartIndex, EndIndex)
	if StartIndex == EndIndex then
		return
	end
	local mid = math.floor((StartIndex + EndIndex) / 2)
--	print(StartIndex,mid,mid+1,EndIndex,"\n")
	MergeSort2(arr, StartIndex, mid)
	MergeSort2(arr, mid+1, EndIndex)
	local tarr = {}
	local p = StartIndex
	local q = mid+1
	for i = 0, EndIndex - StartIndex do
		if p == mid + 1 then
			tarr[i] = arr[q]
			q = q + 1
		elseif q == EndIndex + 1 then
			tarr[i] = arr[p]
			p = p + 1
		else
			if arr[p].ReanimateTime < arr[q].ReanimateTime then
				tarr[i] = arr[p]
				p = p + 1
			else
				tarr[i] = arr[q]
				q = q + 1
			end
		end
	end
	for i = StartIndex, EndIndex do
		arr[i] = tarr[i-StartIndex]
	end
end

function MergeSort3(arr, StartIndex, EndIndex)
	if StartIndex == EndIndex then
		return
	end
	local mid = math.floor((StartIndex + EndIndex) / 2)
--	print(StartIndex,mid,mid+1,EndIndex,"\n")
	MergeSort3(arr, StartIndex, mid)
	MergeSort3(arr, mid+1, EndIndex)
	local tarr = {}
	local p = StartIndex
	local q = mid+1
	for i = 0, EndIndex - StartIndex do
		if p == mid + 1 then
			tarr[i] = arr[q]
			q = q + 1
		elseif q == EndIndex + 1 then
			tarr[i] = arr[p]
			p = p + 1
		else
			if arr[p].Age < arr[q].Age then
				tarr[i] = arr[p]
				p = p + 1
			else
				tarr[i] = arr[q]
				q = q + 1
			end
		end
	end
	for i = StartIndex, EndIndex do
		arr[i] = tarr[i-StartIndex]
	end
end

function UpperBound(arr,StartIndex,EndIndex,val)
	local l = StartIndex
	local r = EndIndex
	local mid = math.floor((l+r)/2)
	local res = EndIndex + 1
	while l <= r do
		mid = math.floor((l+r)/2)
		if val < arr[mid] then
			if mid < res then
				res = mid
			end
			r = mid - 1
		else
			l = mid + 1
		end
	end
	return res
end

local function ActiveMonTimer()
	--local room = Map.Rooms[Map.RoomFromPoint(Party.X,Party.Y,Party.Z)]
	--Message(tostring(room.MinX).." "..tostring(room.MinY).." "..tostring(room.MaxX).." "..tostring(room.MaxY))
	Party.SpellBuffs[const.PartyBuff.Invisibility].ExpireTime = 0
	local MonList = Game.GetMonstersInSight()
	local mon, mon1
	local lim = Map.Monsters.count
	for k,v in pairs(MonList) do
		if v < lim then
			mon = Map.Monsters[v]
			mon.Active = true
			mon.ShowOnMap = true
			if mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime < Game.Time then
				mon.ShowAsHostile = true
			end
--			for tv, ti in Map.Monsters do
--				if tv < lim and GetDist(Map.Monsters[tv], mon.X, mon.Y, mon.Z) < 1000 then
--					mon1 = Map.Monsters[tv]
--					mon1.Active = true
--					mon1.ShowOnMap = true
--				end
--			end
		end
	end
	for v,i in Map.Monsters do
		if v < lim then
			mon = Map.Monsters[v]
			
			if mon.ShowAsHostile == true and mon.Hostile == true and mon.HP > 0 and GetDist(mon,Party.X,Party.Y,Party.Z) <= 512 then
				if vars.LastCastSpell then 
					vars.LastCastSpell = math.max(Game.Time - const.Minute * 4, vars.LastCastSpell)
				else
					vars.LastCastSpell = Game.Time - const.Minute * 4
				end
				vars.MonsterGetCloseTime = Game.Time
			end
			
			if mon.Level > 20 and mon.Active and GetDist(Map.Monsters[v],Party.X,Party.Y,Party.Z) < 5000 and mapvars.expand[v] == nil then
				mapvars.expand[v] = true
				for tv, ti in Map.Monsters do
					if tv < lim and GetDist(Map.Monsters[tv], mon.X, mon.Y, mon.Z) < 2000 and Map.RoomFromPoint(mon.X,mon.Y,mon.Z) == Map.RoomFromPoint(Map.Monsters[tv].X,Map.Monsters[tv].Y,Map.Monsters[tv].Z) then
						mon1 = Map.Monsters[tv]
						mon1.Active = true
						mon1.ShowOnMap = true
						if mon1.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime < Game.Time then
							mon1.ShowAsHostile = true
						end
					end
				end
			end
		end
	end
--[[
	local ActiveMonList = {}
	local xCoordinate = {}
	local yCoordinate = {}
	local zCoordinate = {}
	local cnt = 0
	for i,v in Map.Monsters do
		if v.Active == true then
			cnt = cnt + 1
			ActiveMonList[cnt] = v
			xCoordinate[cnt] = v.X
			yCoordinate[cnt] = v.Y
			zCoordinate[cnt] = v.Z
		end
	end
	MergeSort(xCoordinate,1,cnt)
	MergeSort(yCoordinate,1,cnt)
	MergeSort(zCoordinate,1,cnt)
]]--
-- �ظ���������ʹ�������ܵĹ������, ���㹻��ʱ�Ῠ 
end

local function SummonMonsterAdjust()
	local cnt = 0
	local WispList = {}
	local cnt2 = 0
	local AnimateList = {}
	local nomon = 1
	local MinSpeedReduce = 1
	local one_Monsters_prevent_save = false
	for i,mon in Map.Monsters do
		if Map:IsOutdoor() and mon.ShowAsHostile == true and mon.HP > 0 and GetDist(mon,Party.X,Party.Y,Party.Z) <= 25000 * ((mon.Level / GetOverallPartyLevel()) ^ 2) and Game.UseMonsterBolster == true and (Party.EnemyDetectorRed or Party.EnemyDetectorYellow) then
			Party.SpellBuffs[const.PartyBuff.Invisibility].ExpireTime = 0
			Party.SpellBuffs[const.PartyBuff.Fly].ExpireTime = 0
			Party.SpellBuffs[const.PartyBuff.WaterWalk].ExpireTime = 0
			one_Monsters_prevent_save = true
			--mon.SpellBuffs[const.MonsterBuff.Haste].ExpireTime = Game.Time + const.Minute / 4
			--MinSpeedReduce = math.max(math.min(math.max(GetOverallPartyLevel() / mon.Level, GetDist(mon,Party.X,Party.Y,Party.Z) / 5000), MinSpeedReduce), 0.5)
		end
		if vars.LastCastSpell == nil or Game.Time - vars.LastCastSpell >= const.Minute * 5 and Game.UseMonsterBolster == true and mon.HP ~= 0 and mon.ShowAsHostile == true then
			mon.HP = mon.FullHP
		end
		local TxtMon = Game.MonstersTxt[mon.Id]
		if mon.ShowAsHostile == true and mon.Active == true and GetDist(mon,Party.X,Party.Y,Party.Z) < 5000 then
			nomon = 0
		end
		if mon.ShowAsHostile == true and mon.Active == true and mon.HP > 0 and mon.HostileType ~= 4 then
			mon.HostileType = 4
		end
		
		if mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime >= Game.Time then
			if mon.Id == 97 or mon.Id == 98 or mon.Id == 99 then
				cnt = cnt + 1
				WispList[cnt] = mon
				--[[
				if mon.ShowAsHostile == true then
					mon.HP = 0
				end
				]]--
				if vars.PlayerAttackTime > vars.MonsterAttackTime + const.Minute * 4 and vars.MonsterGetCloseTime > vars.MonsterAttackTime + const.Minute * 4 then
					if mon.AttackRecovery < 50 then
						mon.AttackRecovery = 50
					end
				end
			end
			local HPrate = mon.HP / mon.FullHP
			local splv = (mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime - Game.Time) / const.Minute / 5
			if mon.SpellBuffs[const.MonsterBuff.Summoned].Skill >= 3 then
				splv = splv / 3
			end
			mon.FullHP = math.min(math.max(1, 50 * splv),30000)
			mon.HP = math.max(0,math.ceil(mon.FullHP * HPrate))
			if mon.FullHP == 1 then
				mon.HP = 0
			end
			mon.Attack1.DamageAdd 		= Game.BolsterAmount * 0.6
			mon.Attack1.DamageDiceSides = math.sqrt(splv * 20)
			mon.Attack1.DamageDiceCount = math.sqrt(splv * 20)
			mon.Attack2Chance = 0
			mon.Spell =  0
			mon.Spell2 =  0
			mon.MoveSpeed = 0
			mon.Velocity = mon.MoveSpeed
		--	mon.SpellChance = 100
		--	mon.SpellSkill = JoinSkill(600,const.GM)
		end
		
		if mon.Ally == 9999 and mon.HP > 0 and (mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime == nil or mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime < Game.Time) then
			if mon.Id == 97 or mon.Id == 98 or mon.Id == 99 then -- When a wisp is dispelled, it becomes reanimated, kill it
				mon.HP = 0
			else
				local min, ceil = math.min, math.ceil
				mon.FullHP = ceil(min(TxtMon.FullHP * (1 + mon.Elite / 2), 30000) * ReanimateHP[1])
				if mon.HP > mon.FullHP then
					mon.HP = mon.FullHP
				end
				SetAttackMaxDamage2(mon, mon.Attack1, math.ceil(TxtMon.Attack1.DamageDiceSides) * TxtMon.Attack1.DamageDiceCount * (1 + mon.Elite) * (MonsterEliteDamage[mon.NameId] or 1) * ReanimateDmg[1] * DamageMulByBoost[mon.BoostType])
				SetAttackMaxDamage2(mon, mon.Attack2, math.ceil(TxtMon.Attack2.DamageDiceSides) * TxtMon.Attack2.DamageDiceCount * (1 + mon.Elite) * (MonsterEliteDamage[mon.NameId] or 1) * ReanimateDmg[1] * DamageMulByBoost[mon.BoostType])
				local sk,mas = SplitSkill(TxtMon.SpellSkill)
				mon.SpellSkill = JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]) * ReanimateDmg[1], 1000), mas)
				sk,mas = SplitSkill(TxtMon.Spell2Skill)
				mon.Spell2Skill = JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell2] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]) * ReanimateDmg[1], 1000), mas)
				if vars.LastCastSpell == nil or Game.Time - vars.LastCastSpell >= const.Minute * 5 then
					mon.HP = mon.FullHP
				end
				if mon.ReanimateTime == 0 or mon.ReanimateTime == nil then
					mon.ReanimateTime = Game.Time
				end
				mon.MoveSpeed = TxtMon.MoveSpeed * ReanimateSpeed[1]
				mon.Velocity = mon.MoveSpeed
				cnt2 = cnt2 + 1
				AnimateList[cnt2] = mon
				mon.Experience = 0
				if vars.PlayerAttackTime > vars.MonsterAttackTime + const.Minute * 4 and vars.MonsterGetCloseTime > vars.MonsterAttackTime + const.Minute * 4 then
					if mon.AttackRecovery < 50 then
						mon.AttackRecovery = 50
					end
				end
			end
		end
		if mon.HP <= 0 then
			mon.ReanimateTime = 0
		end
	end
	if cnt >= 5 then
		MergeSort(WispList,1,cnt)
		for i = 1, cnt-4 do
			WispList[i].HP = 0
		end
	end
	if cnt2 >= 3 then
		MergeSort2(AnimateList,1,cnt2)
		for i = 1, cnt2-2 do
			AnimateList[i].HP = 0
		end
	end
	if nomon == 1 then
		vars.LastCastSpell = Game.Time - const.Minute * 5
	end
	vars.PartySpeedReduceByMonster = MinSpeedReduce
	Monsters_prevent_save = one_Monsters_prevent_save
end

local function MonsterBuffsAdjust()
	for i,mon in Map.Monsters do
	
		if mon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime >= Game.Time then
			mon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime = Game.Time + const.Hour
		end

		if mon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime >= Game.Time then
			mon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = Game.Time + const.Hour
		end
		
		if mon.SpellBuffs[const.MonsterBuff.Fear].ExpireTime >= Game.Time then
			local sk = mon.SpellBuffs[const.MonsterBuff.Fear].Skill
			if mon.SpellBuffs[const.MonsterBuff.Fear].Power == 0 then
				mon.SpellBuffs[const.MonsterBuff.Fear].Power = 1
				mon.SpellBuffs[const.MonsterBuff.Fear].ExpireTime = Game.Time + sk * const.Minute / 2
			end
		end
		--[[
		if mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime >= Game.Time + const.Minute * 11 then
			local sk = math.round((mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime - Game.Time) / (100000 * const.Minute))
			local mas = mon.SpellBuffs[const.MonsterBuff.Charm].Skill
			Message(tostring(sk).." "..tostring(mas))
		end
		]]--
		if mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime >= Game.Time + const.Minute * 11 then -- const.Day * 10 ?
			local sk = math.round((mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime - Game.Time) / (100000 * const.Minute))
			local mas = mon.SpellBuffs[const.MonsterBuff.Charm].Skill
			mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime = 0
			if (mas == 3 and sk <= 6) or (mas == 4 and sk <= 9) then
				mon.SpellBuffs[const.MonsterBuff.DamageHalved].ExpireTime = Game.Time + const.Minute * 10
				mon.SpellBuffs[const.MonsterBuff.DamageHalved].Skill = 5
				if mas == 3 then
					mon.SpellBuffs[const.MonsterBuff.DamageHalved].Power = 80
				elseif mas == 4 then
					mon.SpellBuffs[const.MonsterBuff.DamageHalved].Power = 100
				end
			else
				if mon.HP / mon.FullHP <= sk * 0.001 * mas then
					mon.Group = 0
					mon.Ally = 9999 -- Same as reanimated monster's ally.
					mon.Hostile = false
					mon.ShowAsHostile = false
					local cnt = 0
					for i,v in Party do
						if v:IsConscious() then
							cnt = cnt + 1
						end
					end
					for i,v in Party do
						if v:IsConscious() then
							evt[i].Add("Exp",mon.Experience/cnt)
						end
					end
				end
			end
		end
--[[
		if mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime >= Game.Time + const.Minute * 60 then
			local sk = mon.SpellBuffs[const.MonsterBuff.Charm].Skill
			mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime = Game.Time + sk * const.Minute / 2
		end
]]--
		if mon.SpellBuffs[const.MonsterBuff.Enslave].ExpireTime >= Game.Time and mon.SpellBuffs[const.MonsterBuff.Enslave].Power == 0 then
			if mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime >= Game.Time then
				mon.HP = 0
			else
				local Effect = 0
				local Time = 0 
				if mon.SpellBuffs[const.MonsterBuff.Enslave].Skill == 3 then
					Time = const.Minute / 6
				elseif mon.SpellBuffs[const.MonsterBuff.Enslave].Skill == 4 then
					Time = const.Minute / 3
				end
				for i,v in mon.SpellBuffs do
					v.ExpireTime = 0
					v.Power = 0
					v.Skill = 0
				end
				mon.SpellBuffs[const.MonsterBuff.Slow].ExpireTime = Game.Time + Time
				mon.SpellBuffs[const.MonsterBuff.Slow].Power = 20
			end
		end
		
		--[[
		if mon.SpellBuffs[const.MonsterBuff.Enslave].ExpireTime >= Game.Time then
			mon.AIType = 3 
			mon.Hostile = false
			mon.ShowAsHostile = false
		end
		]]--
		
		if mon.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime >= Game.Time and mon.SpellBuffs[const.MonsterBuff.Paralyze].Power == 0 then
			mon.SpellBuffs[const.MonsterBuff.Stoned].ExpireTime = mon.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime
			mon.SpellBuffs[const.MonsterBuff.Paralyze].ExpireTime = 0
		end
		
		if mon.SpellBuffs[const.MonsterBuff.Berserk].ExpireTime >= Game.Time then
			local ExpTime = mon.SpellBuffs[const.MonsterBuff.Berserk].ExpireTime
			local Effect = 0
			if mon.SpellBuffs[const.MonsterBuff.Berserk].Skill == 2 then
				Effect = 400
			elseif mon.SpellBuffs[const.MonsterBuff.Berserk].Skill == 3 then
				Effect = 450
			elseif mon.SpellBuffs[const.MonsterBuff.Berserk].Skill == 4 then
				Effect = 500
			end
			
			mon.SpellBuffs[const.MonsterBuff.Berserk].ExpireTime = 0
			mon.SpellBuffs[const.MonsterBuff.Haste].ExpireTime = math.max(ExpTime + const.Day, mon.SpellBuffs[const.MonsterBuff.Haste].ExpireTime)
			
			mon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime = math.max(ExpTime, mon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime)
			if mon.SpellBuffs[const.MonsterBuff.Fate].Power then
				mon.SpellBuffs[const.MonsterBuff.Fate].Power = math.max(mon.SpellBuffs[const.MonsterBuff.Fate].Power, Effect) 
			else
				mon.SpellBuffs[const.MonsterBuff.Fate].Power = Effect
			end
			
			mon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = math.max(ExpTime, mon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime)
			if mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power then
				mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power = math.max(mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power, Effect)
			else
				mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power = Effect
			end
		end

		if mon.SpellBuffs[const.MonsterBuff.Wander].ExpireTime >= Game.Time and mon.SpellBuffs[const.MonsterBuff.Wander].Power == 0 then
			mon.SpellBuffs[const.MonsterBuff.Wander].ExpireTime = Game.Time + const.Minute * 10
			mon.SpellBuffs[const.MonsterBuff.MeleeOnly].ExpireTime = 0
			mon.SpellBuffs[const.MonsterBuff.Wander].Power = 5
		end

		if mon.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime >= Game.Time and mon.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power > 10 then
			if Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime >= Game.Time and Party.SpellBuffs[const.PartyBuff.TorchLight].Power >= 11 and GetDist(mon,Party.X,Party.Y,Party.Z) <= Party.SpellBuffs[const.PartyBuff.TorchLight].Power * 20 then
				mon.SpellBuffs[const.MonsterBuff.ShrinkingRay].ExpireTime = 0
				mon.SpellBuffs[const.MonsterBuff.ShrinkingRay].Power = 0
				Game.ShowMonsterBuffAnim(i)
			end
		end
	end
end

local function MonsterRandomWalk()
	for i,mon in Map.Monsters do
		if mon.Active == true and mon.VelocityX == 0 and mon.VelocityY == 0 and mon.VelocityZ == 0 and math.random(1,50) == 1 and mon.Ally ~= 9999 and mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime < Game.Time then
			mon.SpellBuffs[const.MonsterBuff.Charm].ExpireTime = Game.Time + const.Minute * 2
		end
	end
end

SpellMissleSpeed={0,4000,0,0,0,4000,0,0,0,0,4000,
				  0,0,0,0,0,0,10000,0,0,0,0,
				  0,1500,0,6000,0,0,4000,0,0,4000,4000,
				  6000,0,0,1000,0,4000,0,4000,0,0,0,
				  0,0,0,0,0,0,0,0,0,0,0,
				  0,0,0,4000,0,0,0,0,0,6000,0,
				  0,0,0,8000,0,0,0,0,0,4000,0,
				  4000,0,0,0,0,0,0,0,0,32000,0,
				  0,2000,0,0,4000,0,0,0,4000,0,0,0,0,0,0,0,0,0,0,0,0,0,16000,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}
				  
local function DragonMissileTimer()
	for i,v in Map.Objects do
		if v.Spell == const.Spells.ShootDragon then
			if vars.HammerhandDamageType == const.Damage.Fire then
				v.Type = 510
			elseif vars.HammerhandDamageType == const.Damage.Air then
				v.Type = 500
			elseif vars.HammerhandDamageType == const.Damage.Water then
				v.Type = 515
			elseif vars.HammerhandDamageType == const.Damage.Earth then
				v.Type = 505
			elseif vars.HammerhandDamageType == const.Damage.Body then
				v.Type = 520
			elseif vars.HammerhandDamageType == const.Damage.Mind then
				v.Type = 525
			elseif vars.HammerhandDamageType == nil then
				vars.HammerhandDamageType = const.Damage.Fire
			end
		end
	end
end

local function SpeedUpMissileTimer()
--	aergv = Party.SpeedZ
--	if aergv~=0 then
--		Message(tostring(aergv))
--	end
--	Party[0].RecoveryDelay = 10000
	local FireSpikeList = {}
	local cnt = {}
	local OwnerList = {}
	local OwnerListCount = 0
	local SpellMas = {}
	for i,v in Map.Objects do
		if v.Spell then
			local velo = math.sqrt(v.VelocityX ^ 2 + v.VelocityY ^ 2 + v.VelocityZ ^ 2)
			local acvelo = SpellMissleSpeed[v.Spell]
			local distx = Party.X - v.X
			local disty = Party.Y - v.Y
			local distz = Party.Z + 50 - v.Z
			local dist = math.sqrt(distx ^ 2 + disty ^ 2 + distz ^ 2)
			if acvelo and acvelo~=0 then
				if velo > 1000 or v.age == nil or v.age <= 2 then
					v.VelocityX = v.VelocityX * (acvelo / velo)
					v.VelocityY = v.VelocityY * (acvelo / velo)
					v.VelocityZ = v.VelocityZ * (acvelo / velo)
				else
					v.VelocityX = acvelo * (distx / dist)
					v.VelocityY = acvelo * (disty / dist)
					v.VelocityZ = acvelo * (distz / dist)
				end
			end
			--if velo < 1000 then
			--	v.VelocityX = v.VelocityX * (3000 / velo)
			--	v.VelocityY = v.VelocityY * (3000 / velo)
			--	v.VelocityZ = v.VelocityZ * (3000 / velo)
			--end
			--if v.Spell==const.Spells.ShrinkingRay then
			--	Message(tostring(velo))
			--end
			if v.Type == 10020 and v.Spell == 33 then
				v.VelocityX = 0
				v.VelocityY = 0
				v.VelocityZ = 0
				v.X = vars.LloydX
				v.Y = vars.LloydY
				v.Z = vars.LloydZ + 100
				if v.Age > 700 and v.MaxAge == 0 then
					v.Age = 500
					v.MaxAge = 1
				end
--				Message(tostring(v.Age))
			elseif v.Type == 1060 then
				if FireSpikeList[v.Owner] == nil then
					cnt[v.Owner] = 1
					FireSpikeList[v.Owner] = {}
					FireSpikeList[v.Owner][cnt[v.Owner]] = v
					OwnerListCount = OwnerListCount + 1
					OwnerList[OwnerListCount] = v.Owner
					SpellMas[v.Owner] = v.SpellMastery
				else
					cnt[v.Owner] = cnt[v.Owner] + 1
					FireSpikeList[v.Owner][cnt[v.Owner]] = v
				end
			elseif v.Type == 12014 and v.Spell == 16 and v.Age < 30000 then
				v.VelocityX = 4000 * (distx / dist)
				v.VelocityY = 4000 * (disty / dist)
				v.VelocityZ = 4000 * (distz / dist)
				if math.sqrt(distx ^ 2 + disty ^ 2 + distz ^ 2) < 200 then
					v.Age = 30000
					Map:RemoveObject(i)
					vars.MonsterAttackTime = Game.Time
					evt.DamagePlayer(evt.Players.Random,const.Damage.Air,v.SpellSkill * math.random(7,9))
					evt.DamagePlayer(evt.Players.All,const.Damage.Air,v.SpellSkill * 2)
				end
			end
		end
		if v.Missile then
			local velo = math.sqrt(v.VelocityX ^ 2 + v.VelocityY ^ 2 + v.VelocityZ ^ 2)
			local acvelo = 4000
			--Message(tostring(v.Target))
			v.VelocityX = v.VelocityX * (acvelo / velo)
			v.VelocityY = v.VelocityY * (acvelo / velo)
			v.VelocityZ = v.VelocityZ * (acvelo / velo)
		end
	end
	for j = 1, OwnerListCount do
		local owner = OwnerList[j]
		if cnt[owner] > SpellMas[owner] * 2 + 1 then
--			Message(tostring(FireSpikeList[owner][1]).." "..tostring(FireSpikeList[owner][2]).." "..tostring(FireSpikeList[owner][3]).." "..tostring(FireSpikeList[owner][4]).." "..tostring(FireSpikeList[owner][5]).." "..tostring(cnt[owner]))
			MergeSort3(FireSpikeList[owner],1,cnt[owner])
			for i = SpellMas[owner] * 2 + 2, cnt[owner] do
				FireSpikeList[owner][i].Age = 31000
			end
		end
	end
end

local function SpellBuffExtraTimer()

	if vars.LloydEffectTime and math.abs(vars.LloydEffectTime - Game.Time) < 10 then
		Party.X = vars.LloydX
		Party.Y = vars.LloydY
		Party.Z = vars.LloydZ
		vars.LloydEffectTime = 0
	end

	if (not vars.MagicRes) or vars.MagicRes < Game.Time then
		if (vars.DarkGraspExpireTime and vars.DarkGraspExpireTime >= Game.Time) or (vars.StunExpireTime and vars.StunExpireTime >= Game.Time) then
			Stp = true
		else
			Stp = false
		end
		
		Spd = 1
		SpdZ = 1
		if vars.SlowExpireTime and vars.SlowExpireTime >= Game.Time then
			Spd = Spd * 0.4
		end
		if vars.PartySpeedReduceByMonster then
			Spd = Spd * vars.PartySpeedReduceByMonster
		end
		if vars.SwiftPotionBuffTime and vars.SwiftPotionBuffTime >= Game.Time then
			Spd = Spd * 1.2
		end
		if vars.DispelSlowExpireTime and vars.DispelSlowExpireTime >= Game.Time then
			Spd = Spd * 0.1
		end
		if vars.AirShotBuffTime and vars.AirShotBuffTime >= Game.Time then
			Spd = Spd * (1 + vars.AirShotBuffPower / 100)
		end
		
		if Game.Map.Name == "elemw.odm" then
			Spd = Spd * math.max(0.25, (0.99985 ^ (vars.ElemwFatigue or 0)))
			SpdZ = SpdZ * math.max(0.25, (0.99985 ^ (vars.ElemwFatigue or 0)))
		end
		
		if vars.StunExpireTime and vars.StunExpireTime >= Game.Time then
			for _, pl in Party do
				pl.RecoveryDelay = math.max(pl.RecoveryDelay, 10)
			end
		end
	end
	
	if Game.TurnBased == true then
		Game.TurnBased = false
	end
	
	if Party.SpellBuffs[const.PartyBuff.Haste].ExpireTime > Game.Time then
		Party.SpellBuffs[const.PartyBuff.Haste].ExpireTime = Game.Time + const.Day
	end

	if Party.SpellBuffs[const.PartyBuff.WizardEye].ExpireTime > Game.Time and (Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime < Game.Time + const.Minute / 30 or Party.SpellBuffs[const.PartyBuff.TorchLight].Power <= 10)  then
		Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime = math.max(Party.SpellBuffs[const.PartyBuff.WizardEye].ExpireTime, Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime)
		Party.SpellBuffs[const.PartyBuff.TorchLight].Power = 10
	end

	if Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime > Game.Time + const.Day * 80 then
		local sk = math.round((Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime - Game.Time) / (7257600 * const.Minute / 60))
		Party.SpellBuffs[const.PartyBuff.TorchLight].ExpireTime = Game.Time + const.Minute
		Party.SpellBuffs[const.PartyBuff.TorchLight].Power = math.round(20 - 200 / (sk + 19)) + 1
	end

	for _,pl in Party do
		if pl.Dead ~= 0 or pl.Eradicated ~= 0 then
			pl.HP = math.min(pl.HP, 0)
			pl.SP = 0
		end
		if pl.SpellBuffs[const.PlayerBuff.Hammerhands].ExpireTime > Game.Time then
			pl.SpellBuffs[const.PlayerBuff.Hammerhands].ExpireTime = 0
			--pl.SpellBuffs[const.PlayerBuff.Hammerhands].Power = pl.SpellBuffs[const.PlayerBuff.Hammerhands].Skill
		end
		if pl.SpellBuffs[const.PlayerBuff.Fate].ExpireTime > Game.Time and pl.SpellBuffs[const.PlayerBuff.Fate].Skill ~= 0 then
			--Message(tostring(pl.SpellBuffs[const.PlayerBuff.Fate].Skill).." "..tostring(pl.SpellBuffs[const.PlayerBuff.Fate].Power))
			local curHP = math.max(pl.HP, 0)
			local curSP = math.max(pl.SP, 0)
			local FullHP = pl:GetFullHP()
			local FullSP = pl:GetFullSP()
			if pl.Dead ~= 0 or pl.Eradicated ~= 0 then
				curHP = 0
				curSP = 0
				FullHP = 0
				FullSP = 0
			end
			vars.Invincible = Game.Time + pl.SpellBuffs[const.PlayerBuff.Fate].Power * 0.2 * const.Minute / 60
			local RecHP = curHP * 2 + FullHP * (pl.SpellBuffs[const.PlayerBuff.Fate].Power * 0.002)
			local RecSP = curSP * 2 + FullSP * (pl.SpellBuffs[const.PlayerBuff.Fate].Power * 0.002)
			pl.Eradicated = Game.Time
			for i,v in pl.SpellBuffs do
				v.ExpireTime = 0
			end
			pl.HP = 0
			pl.SP = 0
			local cnt=0
			for i,v in Party do
				if v.Dead == 0 and v.Eradicated == 0 then
					cnt = cnt + 1
				end
			end
			for i,v in Party do
				if v.Dead == 0 and v.Eradicated == 0 then
					v.HP = math.min(v.HP + RecHP / cnt, v:GetFullHP())
					v.SP = math.min(v.SP + RecSP / cnt, v:GetFullSP())
				end
			end
			--pl.SpellBuffs[const.PlayerBuff.Hammerhands].Power = pl.SpellBuffs[const.PlayerBuff.Hammerhands].Skill
		end
		if pl.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime > Game.Time then
			pl.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime = Game.Time + const.Minute
		end
		if pl.SpellBuffs[const.PlayerBuff.Hammerhands].Skill >= 1 then
			pl.SpellBuffs[const.PlayerBuff.TempEndurance].ExpireTime = Game.Time + const.Minute * 10
		else
			pl.SpellBuffs[const.PlayerBuff.TempEndurance].ExpireTime = 0
		end
		for i,pl in Party do
			if vars.HammerhandDamageType == const.Damage.Fire then
				pl.SpellBuffs[const.PlayerBuff.FireResistance].ExpireTime = Game.Time + const.Minute * 10
			else
				pl.SpellBuffs[const.PlayerBuff.FireResistance].ExpireTime = 0
			end
			if vars.HammerhandDamageType == const.Damage.Air then
				pl.SpellBuffs[const.PlayerBuff.AirResistance].ExpireTime = Game.Time + const.Minute * 10
			else
				pl.SpellBuffs[const.PlayerBuff.AirResistance].ExpireTime = 0
			end
			if vars.HammerhandDamageType == const.Damage.Water then
				pl.SpellBuffs[const.PlayerBuff.WaterResistance].ExpireTime = Game.Time + const.Minute * 10
			else
				pl.SpellBuffs[const.PlayerBuff.WaterResistance].ExpireTime = 0
			end
			if vars.HammerhandDamageType == const.Damage.Earth then
				pl.SpellBuffs[const.PlayerBuff.EarthResistance].ExpireTime = Game.Time + const.Minute * 10
			else
				pl.SpellBuffs[const.PlayerBuff.EarthResistance].ExpireTime = 0
			end
			if vars.HammerhandDamageType == const.Damage.Body then
				pl.SpellBuffs[const.PlayerBuff.BodyResistance].ExpireTime = Game.Time + const.Minute * 10
			else
				pl.SpellBuffs[const.PlayerBuff.BodyResistance].ExpireTime = 0
			end
			if vars.HammerhandDamageType == const.Damage.Mind then
				pl.SpellBuffs[const.PlayerBuff.MindResistance].ExpireTime = Game.Time + const.Minute * 10
			else
				pl.SpellBuffs[const.PlayerBuff.MindResistance].ExpireTime = 0
			end
		end
	end
	
	for _,pl in Party do
		if pl.SpellBuffs[const.PlayerBuff.Regeneration].ExpireTime > Game.Time and pl.SpellBuffs[const.PlayerBuff.Regeneration].Power == 0 then
			sk = math.round(pl.SpellBuffs[const.PlayerBuff.Regeneration].ExpireTime - Game.Time) / 60 / const.Minute
			mas = pl.SpellBuffs[const.PlayerBuff.Regeneration].Skill
			pl.SpellBuffs[const.PlayerBuff.Regeneration].Power = math.round(sk * (mas + 1) / 5)
			pl.SpellBuffs[const.PlayerBuff.Regeneration].ExpireTime = Game.Time + const.Minute * 10
		end
	end
	
	if Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime > Game.Time + const.Minute * 10 then
		--[[
		Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime = Game.Time + const.Minute * 5
		local Player = Party[vars.PlayerCastImmolation]
		local BlessTweak = 0
		local ac = Player:GetAccuracy()
		local nt = Player:GetIntellect()
		local pe = Player:GetPersonality()
		if Player.SpellBuffs[const.PlayerBuff.Bless].ExpireTime > Game.Time then
			BlessTweak = 5
		end
		local acpenalty = ac * 0.25 - 0.000125 * ac * ac
		local nppenalty = mnp * 0.18 - 0.00009 * mnp * mnp
		local totalpenalty = 0.99 ^ (-BlessTweak - acpenalty - nppenalty)
		if Player.Afraid ~= 0 then
			BlessTweak = BlessTweak - 69
		end
		if Party.SpellBuffs[const.PartyBuff.Immolation].Skill <= 3 then
			Party.SpellBuffs[const.PartyBuff.Immolation].Power = math.ceil(Party.SpellBuffs[const.PartyBuff.Immolation].Power * totalpenalty * 0.8)
		else
			Party.SpellBuffs[const.PartyBuff.Immolation].Power = math.ceil(Party.SpellBuffs[const.PartyBuff.Immolation].Power * totalpenalty)
		end
		]]--
		if vars.ImmolationOn then
			vars.ImmolationOn = nil
			Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime = Game.Time
		else
			vars.ImmolationOn = true
			Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime = Game.Time + const.Minute * 5
			if Party.SpellBuffs[const.PartyBuff.Immolation].Skill <= 2 then
				Party.SpellBuffs[const.PartyBuff.Immolation].Power = math.ceil(Party.SpellBuffs[const.PartyBuff.Immolation].Power * 4)
			elseif Party.SpellBuffs[const.PartyBuff.Immolation].Skill <= 3 then
				Party.SpellBuffs[const.PartyBuff.Immolation].Power = math.ceil(Party.SpellBuffs[const.PartyBuff.Immolation].Power * 5)
			else
				Party.SpellBuffs[const.PartyBuff.Immolation].Power = math.ceil(Party.SpellBuffs[const.PartyBuff.Immolation].Power * 6)
			end
		end
	elseif Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime > Game.Time then
		Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime = Game.Time + const.Minute * 5
	end

	for _,pl in Party do
		if pl.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime > Game.Time and pl.SpellBuffs[const.PlayerBuff.Glamour].Skill ~= 0 then
			sk = (pl.SpellBuffs[const.PlayerBuff.Glamour].Power - 2) * 2
			mas = pl.SpellBuffs[const.PlayerBuff.Glamour].Skill
			power = mas * 5 + sk * 0.5
			for i,Player in Party do
				Player.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime = math.max(Player.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime, pl.SpellBuffs[const.PlayerBuff.Glamour].ExpireTime)
				Player.SpellBuffs[const.PlayerBuff.Glamour].Power = math.max(Player.SpellBuffs[const.PlayerBuff.Glamour].Power, power)
				Player.SpellBuffs[const.PlayerBuff.Glamour].Skill = 0
			end
		end
		if pl.Disease3 ~= 0 and Game.Time - pl.Disease3 > const.Minute * 10 then
			if pl.RecoveryDelay < 50 then
				pl.RecoveryDelay = 50
			end 
		end
		if pl.Disease2 ~= 0 and pl.Disease3 == 0 and Game.Time - pl.Disease2 > const.Minute * 10 then
			pl.Disease3 = Game.Time
		end
		if pl.Disease1 ~= 0 and pl.Disease2 == 0 and Game.Time - pl.Disease1 > const.Minute * 10 then
			pl.Disease2 = Game.Time
		end
	end
	
	if vars.LastCastSpell == nil or Game.Time - vars.LastCastSpell >= const.Minute * 5 then
		vars.EnterCombatTime = Game.Time
		for _,pl in Party do
			pl.SpellBuffs[const.PlayerBuff.PainReflection].ExpireTime = math.min(pl.SpellBuffs[const.PlayerBuff.PainReflection].ExpireTime, Game.Time + const.Minute * 10)
			pl.Weak = 0
		end
		for i,v in Party do
			if v.SpellBuffs[const.PlayerBuff.TempLuck] and v.SpellBuffs[const.PlayerBuff.TempLuck].ExpireTime > Game.Time then
				v.SpellBuffs[const.PlayerBuff.TempLuck].ExpireTime = v.SpellBuffs[const.PlayerBuff.TempLuck].ExpireTime - 7
			end
		end
	else
		Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic].ExpireTime = 0
	end

	if vars.SouldrinkerAttackCount ~= nil and vars.SouldrinkerAttackCount > 0 then
		local RecoveryAmount = (vars.SouldrinkerAttackCount * 10 + 25) * vars.SouldrinkerAttackCount / 5
		local OriginalRecoveryAmount = (vars.SouldrinkerAttackCount * 7 + 25) * vars.SouldrinkerAttackCount / 5
		vars.SouldrinkerAttackCount = 0
		for i,pl in Party do
			if pl.Dead == 0 and pl.Eradicated == 0 then
				if pl:IsConscious() then
					pl.HP = math.min(pl.HP + RecoveryAmount - OriginalRecoveryAmount,pl:GetFullHP())
				else
					pl.HP = math.min(pl.HP + RecoveryAmount,pl:GetFullHP())
				end
			end
		end
	end

	

end

local function ArmageddonTimer()
	for _,pl in Party do
		if pl.ArmageddonCasts > 0 then
			Sleep(200)
			for i,v in Map.Monsters do
				v.HP = 0
			end
			for i,v in Party do
				v.HP = -1000
				v.ArmageddonCasts = 0
			end
			break
		end
	end
end

local function GetLastHP()
	if vars.LastHP == nil or vars.HP == nil then
		vars.LastHP = {0,0,0,0,0}
		vars.HP = {0,0,0,0,0}
	end
	for i,pl in Party do
		vars.LastHP[i] = vars.HP[i]
		vars.HP[i] = pl.HP
	end
end

local function NegRegen()
	Party.LastRegenerationTime = Game.Time + 100000000
end

--[[
local function MonsterHasteTimer()
	for i,v in Map.Monsters do
		if v.SpellBuffs[const.MonsterBuff.Haste].ExpireTime >  Game.Time then
			v.AttackRecovery = math.max(v.AttackRecovery - 10, 0)
		end
	end
end
]]--

function events.AfterLoadMap()
	if Map.IsIndoor() or Map.Name == "elema.odm" or Map.Name == "elemf.odm" or Map.Name == "elemw.odm" then
		Timer(ActiveMonTimer, const.Minute/2, false)
	end
--[[
	else
		local avl = 0
		local cnt = 0
		for _,v in Map.Monsters do
			if v.Level >= 20 then
				avl = avl + v.Level
				cnt = cnt + 1
			end
		end
		if cnt>=10 then
			avl = avl / cnt
		else
			avl = 10
		end
		for _,chest in Map.Chests do
			for _,itm in chest.Items do
				if itm:T().EquipStat+1 ~= const.ItemType.Gold and itm:T().Material == 0 then
					itm:Randomize(math.min(math.floor(avl/10) + 1 + math.random(0,1),6),itm:T().EquipStat+1)
					while itm:T().Material ~= 0 do
						itm:Randomize(math.min(math.floor(avl/10) + 1 + math.random(0,1),6),itm:T().EquipStat+1)
					end
				--elseif itm:T().Material == 1 or itm:T().Material == 2 then
				--	itm:Randomize(6,itm:T().EquipStat+1)
				--	while itm:T().Material ~= 1 and itm:T().Material ~= 2 do
				--		itm:Randomize(6,itm:T().EquipStat+1)
				--	end
				end
			end
		end
	]]--
end

local function ManaRegeneration()
	if vars.LastCastSpell == nil or Game.Time - vars.LastCastSpell >= const.Minute * 5 then
		for i,v in Party do
			if v.Dead == 0 and v.Eradicated == 0 then
				local maxsp = v:GetFullSP()
				local maxhp = v:GetFullHP()
				if vars.BurningExpireTime and vars.BurningExpireTime >= Game.Time then
					v.SP = math.min(v.SP + math.max(1,maxsp*0.02),maxsp)
				else
					v.SP = math.min(v.SP + math.max(1,maxsp*0.02),maxsp)
					v.HP = math.min(v.HP + math.max(1,maxhp*0.02),maxhp)
				end
			end
		end
	end
end

local function SpellOnCostMana()
	if Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime > Game.Time then
		local plid = vars.PlayerCastImmolation
		if plid then
			local pl = Party[plid]
			local maxsp = pl:GetFullSP()
			pl.SP = math.max(pl.SP - maxsp * 0.005 - 10, 0)
			if pl.SP == 0 then
				Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime = Game.Time
				vars.PlayerCastImmolation = nil
			end
		end
	end
end

local function HealthRegeneration()
	for i,v in Party do
		if v.Dead == 0 and v.Eradicated == 0 then
			local maxhp = v:GetFullHP()
			local sk, mas = SplitSkill(v:GetSkill(const.Skills.Regeneration))
			local regenHP = math.ceil(sk * mas * 0.25)
			if v.SpellBuffs[const.PlayerBuff.Regeneration].ExpireTime > Game.Time then
				regenHP = regenHP + v.SpellBuffs[const.PlayerBuff.Regeneration].Power
			end
			if vars.BurningExpireTime and vars.BurningExpireTime >= Game.Time then
				regenHP = 0
			end
			v.HP = math.min(v.HP + regenHP,maxhp)
		end
	end
end

local function InsaneTimer()
	for i,v in Party do
		if v.Dead == 0 and v.Eradicated == 0 and v.Insane ~= 0 then
			local maxhp = v:GetFullHP()
			local dmg = maxhp * 0.02
			v.HP = v.HP - dmg
		end
	end
end

local function BurningTimer()
	for i,v in Party do
		if v.Dead == 0 and v.Eradicated == 0 then
			if vars.BurningExpireTime and vars.BurningExpireTime >= Game.Time then
				evt.DamagePlayer(i, const.Damage.Fire, vars.BurningPower)
			end
		end
	end
end

local function StuckDetect()
	if vars.StuckDetected == nil then
		vars.StuckDetected = 0
	end
	if vars.MonsterGetCloseTime == nil then
		vars.MonsterGetCloseTime = 0
	end
	--vars.StuckDetected = math.max(vars.StuckDetected - 1, 0)
	if vars.PlayerAttackTime ~= nil and vars.MonsterAttackTime ~= nil and vars.MonsterGetCloseTime ~= nil then
		if vars.MonsterGetCloseTime <= Game.Time - const.Minute * 1 then
			vars.MonsterAttackTime = Game.Time
			vars.StuckDetected = 0 
		end
		if vars.PlayerAttackTime > vars.MonsterAttackTime + const.Minute * 4 and vars.MonsterGetCloseTime > vars.MonsterAttackTime + const.Minute * 4 and vars.StuckDetected == 0 then
			vars.StuckDetected = 1
			--vars.MonsterAttackTime = Game.Time - const.Minute * 5.5
			Message("Warning! It seems that you're trying to stuck the monsters. It's forbidden in this game, so your players' recovery time will be frozen for a while.")
		end
		if vars.PlayerAttackTime > vars.MonsterAttackTime + const.Minute * 4 and vars.MonsterGetCloseTime > vars.MonsterAttackTime + const.Minute * 4 then
			for i,v in Party do
				if v.RecoveryDelay < 50 then
					v.RecoveryDelay = 50
				end
			end
		end
	end
end

local function FatigueTimer()
	if vars.LastCastSpell and Game.Time - vars.LastCastSpell < const.Minute * 5 and vars.EnterCombatTime and Game.Time - vars.EnterCombatTime > const.Hour * 4 then
		for i,v in Party do
			local maxsp = v:GetFullSP()
			local maxhp = v:GetFullHP()
			if v.Dead == 0 and v.Eradicated == 0 then
				v.SP = math.max(v.SP - math.max(1, maxsp * 0.01), 0)
				v.HP = v.HP - math.max(1, maxhp * 0.01)
			end
		end
	end
end

local function PoisonTimer()
	for i,v in Party do
		if v.Dead == 0 then
			if v.Poison1 ~= 0 then
				v.HP = v.HP - 2
			end
			if v.Poison2 ~= 0 then
				v.HP = v.HP - 10
			end
			if v.Poison3 ~= 0 then
				v.HP = v.HP - 50
			end
		end
	end
end

local function ImmolationTimer()
	if Party.SpellBuffs[const.PartyBuff.Immolation].ExpireTime > Game.Time then
		for i,v in Map.Monsters do
			if v.HP > 0 and v.ShowAsHostile == true and v.Active == true and GetDist(v,Party.X,Party.Y,Party.Z) < 512 then
				v.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = Game.Time + const.Day
				local val = (Party.SpellBuffs[const.PartyBuff.Immolation].Power * 0.1 + 10)
				if v.SpellBuffs[const.MonsterBuff.Hammerhands].Power then
					v.SpellBuffs[const.MonsterBuff.Hammerhands].Power = v.SpellBuffs[const.MonsterBuff.Hammerhands].Power + math.floor(val)
				else
					v.SpellBuffs[const.MonsterBuff.Hammerhands].Power = math.floor(val)
				end
				Game.ShowMonsterBuffAnim(i)
				--v.HP = math.max(0, v.HP - CalcRealDamageM(Party.SpellBuffs[const.PartyBuff.Immolation].Power,const.Damage.Fire,false,nil,v))
				v:GotHit(4)
			end
		end
	end
end

function events.AfterLoadMap()
--	Stp = false
--	Spd = 1
	if vars.MonsterGetCloseTime == nil then
		vars.MonsterGetCloseTime = 0
	end
	if vars.MonsterAttackTime == nil then
		vars.MonsterAttackTime = Game.Time
	end
	if vars.PlayerAttackTime == nil then
		vars.PlayerAttackTime = Game.Time
	end
	Timer(SpeedUpMissileTimer, 4, false)
	Timer(SpellBuffExtraTimer, 1, false)
--	Timer(MonsterHasteTimer, 10, false)
	Timer(SummonMonsterAdjust, const.Minute/8, false)
	Timer(ManaRegeneration, const.Minute/8, false)
	Timer(SpellOnCostMana, const.Minute/4, false)
	Timer(HealthRegeneration, const.Minute/4, false)
	Timer(FatigueTimer, const.Minute/4, false)
	Timer(PoisonTimer, const.Minute/8, false)
	Timer(StuckDetect, const.Minute/8, false)
	Timer(ArmageddonTimer, const.Minute/8, false)
	Timer(MonsterBuffsAdjust, 4, false)
	--Timer(ImmolationTimer, const.Minute, false)
	Timer(NegRegen, const.Minute * 4, false)
	Timer(MonsterRandomWalk, const.Minute / 4, false)
	Timer(DragonMissileTimer, 1, false)
	Timer(InsaneTimer, const.Minute/8, false)
	Timer(BurningTimer, const.Minute/4, false)
end


-- Make additional special effect: when monster dies, spawn other monsters.
local FieldsToCopy = {"Hostile", "Ally", "NoFlee", "HostileType", "Group", "MoveType"}

local function SummonWithDelay(Count, Source, Delay, SummonId)

	local f = function()
		local StartTime = Game.Time
		while Game.Time < StartTime + Delay do
			Sleep(25,25)
		end

		for i = 1, Count do
			local NewMon = SummonMonster(SummonId, random(Source.X-100, Source.X+100), random(Source.Y-100, Source.Y+100), Source.Z + random(50,150), true)
			if NewMon then
				NewMon.Direction = random(0,2047)
				NewMon.LookAngle = random(100,400)
				NewMon.Velocity  = 10000
				NewMon.VelocityY = random(1000,2000)
				for k,v in pairs(FieldsToCopy) do
					NewMon[k] = Source[k]
				end
			end
			Source.SpecialA = Source.SpecialA + 1
		end

		Source.GraphicState = -1
		Source.AIState = const.AIState.Removed
	end

	coroutine.resume(coroutine.create(f))

end

function events.MonsterKilled(mon)

	if mon.Special == 4 then

		local SummonId = mon.SpecialD

		if SummonId == 0 then
			local WeakMonId = ceil(mon.Id/3)*3-2
			if mon.Id ~= WeakMonId then
				SummonId = mon.Id - 1
			else
				SummonId = mon.Id
			end
		end

		-- don't allow to summon same monsters as killed one.
		if SummonId == mon.Id then
			return
		end

		local count = (mon.SpecialC == 0 and 2 or mon.SpecialC) - mon.SpecialA
		SummonWithDelay(count, mon, const.Minute/6, SummonId)

	end
end

function events.DeathMap()
	vars.ElemwFatigue = nil
end
