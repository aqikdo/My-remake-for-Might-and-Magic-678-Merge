
vars.PotionBuffs = vars.PotionBuffs or {}
local PSet	= vars.PotionBuffs
PSet.UsedPotions = PSet.UsedPotions or {}

local function GetPlayerId(Player)
	for i,v in Party.PlayersArray do
		if v["?ptr"] == Player["?ptr"] then
			return i
		end
	end
end

-- Awaken
evt.PotionEffects[7] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if vars.LastDrink == nil or Game.Time >= vars.LastDrink then
			vars.LastDrink = Game.Time + const.Minute * 20
		else
			return -1
		end
	end
end

-- Remove Fear
evt.PotionEffects[17] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if vars.LastDrink == nil or Game.Time >= vars.LastDrink then
			vars.LastDrink = Game.Time + const.Minute * 20
		else
			return -1
		end
	end
end

-- Remove Curse
evt.PotionEffects[18] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if vars.LastDrink == nil or Game.Time >= vars.LastDrink then
			vars.LastDrink = Game.Time + const.Minute * 20
		else
			return -1
		end
	end
end

-- Cure Insanity
evt.PotionEffects[19] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if vars.LastDrink == nil or Game.Time >= vars.LastDrink then
			vars.LastDrink = Game.Time + const.Minute * 20
		else
			return -1
		end
	end
end

-- Rejuvenation potion
evt.PotionEffects[51] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if Target.AgeBonus <= 0 then
			Target.AgeBonus = Target.AgeBonus - math.ceil(Power/10)
			return true
		end
	end
end

-- Swift potion
evt.PotionEffects[30] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if vars.LastDrinkSwift == nil or Game.Time >= vars.LastDrinkSwift then
			vars.SwiftPotionBuffTime = Game.Time + 1000
			vars.LastDrinkSwift = Game.Time + const.Minute * 20
			vars.SlowExpireTime = 0
			return true
		else
			return -1
		end
	end
end

-- Magic Potion 
evt.PotionEffects[3] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local PlayerId = GetPlayerId(Target)
		PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}
		local t = PSet.UsedPotions[PlayerId]
		if t[0] == nil or Game.Time >= t[0] then
--			Target.SP = math.min(Target.SP + Power + 5, Target:GetFullSP())
			t[0] = Game.Time + const.Minute * 10
		else
			return -1
		end
	end
end

-- Cure Wound
evt.PotionEffects[2] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local PlayerId = GetPlayerId(Target)
		PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}
		local t = PSet.UsedPotions[PlayerId]
		if t[1] == nil or Game.Time >= t[1] then
--			Target.HP = math.min(Target.HP + Power + 5, Target:GetFullHP())
			t[1] = Game.Time + const.Minute * 10
		else
			return -1
		end
	end
end

-- strengthed magic
evt.PotionEffects[34] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local PlayerId = GetPlayerId(Target)
		PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}
		local t = PSet.UsedPotions[PlayerId]
		if t[0] == nil or Game.Time >= t[0] then
--			Target.SP = math.min(Target.SP + Power * 5, Target:GetFullSP())
			t[0] = Game.Time + const.Minute * 30
		else
			return -1
		end
	end
end

-- strengthed cure
evt.PotionEffects[33] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local PlayerId = GetPlayerId(Target)
		PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}
		local t = PSet.UsedPotions[PlayerId]
		if t[1] == nil or Game.Time >= t[1] then
--			Target.HP = math.min(Target.HP + Power * 5, Target:GetFullHP())
			t[1] = Game.Time + const.Minute * 30
		else
			return -1
		end
	end
end

-- Divine Restoration
evt.PotionEffects[32] = function(IsDrunk, Target, Power)
	if IsDrunk then
		if vars.LastDrink == nil or Game.Time >= vars.LastDrink then
			vars.LloydEffectTime = 0
			vars.DarkGraspExpireTime = 0
			vars.StunExpireTime = 0
			vars.SlowExpireTime = 0
			vars.BurningExpireTime = 0
			vars.LastDrink = Game.Time + const.Minute * 20
		else
			return -1
		end
	end
end

-- Divine boost
evt.PotionEffects[60] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local Buffs = Target.SpellBuffs
		local ExpireTime = Game.Time + Power*const.Minute*30
		local Effect = Power*3

		for k,v in pairs({"TempLuck", "TempIntellect", "TempPersonality", "TempAccuracy", "TempEndurance", "TempSpeed", "TempMight"}) do
			Buff = Buffs[const.PlayerBuff[v]]
			Buff.ExpireTime = ExpireTime
			Buff.Power = Effect
		end
	end
end

-- Divine protection
evt.PotionEffects[61] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local Buffs = Target.SpellBuffs
		local ExpireTime = Game.Time + Power*const.Minute*30
		local Effect = Power*3

		for k,v in pairs({"AirResistance", "BodyResistance", "EarthResistance", "FireResistance", "MindResistance", "WaterResistance"}) do
			Buff = Buffs[const.PlayerBuff[v]]
			Buff.ExpireTime = ExpireTime
			Buff.Power = Effect
		end
	end
end

-- Divine Transcendence
evt.PotionEffects[62] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local PlayerId = GetPlayerId(Target)
		Target.LevelBonus = math.max(Target.LevelBonus , Power)
	end
end

-- Essences
local function EssenseOf(Target, Stat, cStat, ItemId)
	local PlayerId = GetPlayerId(Target)
	PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}

	local t = PSet.UsedPotions[PlayerId]
--	if t[ItemId] then
		return -1
--	else
--		t[ItemId] = true
--		Target[Stat]  = Target[Stat] + 15
--		Target[cStat] = Target[cStat] - 5
--		return true
--	end
end

-- Potion of time elapse
evt.PotionEffects[52] = function(IsDrunk, Target, Power, ItemId)
	if Map:IsIndoor() then
		return -1
	else
		Game.Time = Game.Time + const.Day * Power
	end
end

-- Potion of Raising Dead
evt.PotionEffects[53] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		if Target.Dead ~= 0 then
			Target.HP = 1
			Target.SP = 0
			Target.Dead = 0
			Target:SetRecoveryDelayRaw(const.Minute * 10)
			Target.Weak = Game.Time
		end
	end
end

-- Essence of Personality
evt.PotionEffects[54] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		return EssenseOf(Target, "PersonalityBase", "SpeedBase", ItemId)
	end
end

-- Essence of Endurance
evt.PotionEffects[55] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		return -1
--		local PlayerId = GetPlayerId(Target)
--		PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}
--		local t = PSet.UsedPotions[PlayerId]

--		if t[ItemId] then
--			return -1
--		else
--			t[ItemId] = true
--			Target.MightBase		= Target.MightBase - 1
--			Target.IntellectBase	= Target.IntellectBase - 1
--			Target.PersonalityBase	= Target.PersonalityBase - 1
--			Target.AccuracyBase		= Target.AccuracyBase - 1
--			Target.SpeedBase		= Target.SpeedBase - 1
--			Target.LuckBase			= Target.LuckBase - 1
--			Target.EnduranceBase	= Target.EnduranceBase + 15
--		end
	end
end

-- Essence of Accuracy
evt.PotionEffects[56] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		return EssenseOf(Target, "AccuracyBase", "LuckBase", ItemId)
	end
end

-- Essence of Speed
evt.PotionEffects[57] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		return EssenseOf(Target, "SpeedBase", "PersonalityBase", ItemId)
	end
end

-- Essence of Luck
evt.PotionEffects[58] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		return EssenseOf(Target, "LuckBase", "AccuracyBase", ItemId)
	end
end

-- Potion of the Gods
evt.PotionEffects[63] = function(IsDrunk, Target, Power, ItemId)
	if IsDrunk then
		local PlayerId = GetPlayerId(Target)
		PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}
		if PSet.UsedPotions[PlayerId][ItemId] then
			return -1
		else
			PSet.UsedPotions[PlayerId][ItemId] = true

			local Stats = Target.Stats
			for i = 0, 6 do
				Stats[i].Base = Stats[i].Base + 20
			end
			for i,v in Target.Resistances do
				v.Base = v.Base + 10
			end
			Target.AgeBonus = Target.AgeBonus + 10
		end
	end
end

-- Potion of Doom
evt.PotionEffects[59] = function(IsDrunk, Target, Power, ItemId)
	local PlayerId = GetPlayerId(Target)
	PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}

	local t = PSet.UsedPotions[PlayerId]
	if t[ItemId] then
		return -1
	else
		t[ItemId] = true
		Target.MightBase		= Target.MightBase + 1
		Target.IntellectBase	= Target.IntellectBase + 1
		Target.PersonalityBase	= Target.PersonalityBase + 1
		Target.EnduranceBase	= Target.EnduranceBase + 1
		Target.AccuracyBase		= Target.AccuracyBase + 1
		Target.SpeedBase		= Target.SpeedBase + 1
		Target.LuckBase			= Target.LuckBase + 1

		for i,v in Target.Resistances do
			v.Base = v.Base + 1
		end
		
		for i, val in Target.Skills do
			if val ~= 0 then
				local skill, mastery = SplitSkill(val)
				Target.Skills[i] = JoinSkill(skill + 1, mastery)
			end
		end
		Target.AgeBonus = Target.AgeBonus + 5
	end
end

-- Pure resistances
local function PureResistance(Target, Stat, ItemId)
	local PlayerId = GetPlayerId(Target)
	PSet.UsedPotions[PlayerId] = PSet.UsedPotions[PlayerId] or {}

	local t = PSet.UsedPotions[PlayerId]
--	if t[ItemId] then
		return -1
--	else
--		t[ItemId] = true
--		Target.Resistances[Stat].Base = Target.Resistances[Stat].Base + 40
--	end
end
-- Divine Strength
evt.PotionEffects[64] = function(IsDrunk, Target, Power, ItemId) 
	if IsDrunk then
		if vars.LastDrinkStrength == nil or (Game.Time - vars.LastDrinkStrength) >= const.Hour then
			for i,pl in Party do
				pl.SpellBuffs[const.PlayerBuff.Heroism].Power = Power * 5
				pl.SpellBuffs[const.PlayerBuff.Heroism].ExpireTime = Game.Time + const.Minute * 5
			end
			vars.LastDrinkStrength = Game.Time
			return true
		else
			return -1
		end
	end
	
end
evt.PotionEffects[65] = function(IsDrunk, Target, Power, ItemId) return PureResistance(Target, 1, ItemId) end
evt.PotionEffects[66] = function(IsDrunk, Target, Power, ItemId) return PureResistance(Target, 2, ItemId) end
evt.PotionEffects[67] = function(IsDrunk, Target, Power, ItemId) return PureResistance(Target, 3, ItemId) end
evt.PotionEffects[68] = function(IsDrunk, Target, Power, ItemId) return PureResistance(Target, 2, ItemId) end
evt.PotionEffects[69] = function(IsDrunk, Target, Power, ItemId) return PureResistance(Target, 3, ItemId) end


-- Protection from Magic
evt.PotionEffects[70] = function(IsDrunk, Target, Power)
	if IsDrunk then
		local Buff = Party.SpellBuffs[const.PartyBuff.ProtectionFromMagic]
		Buff.ExpireTime = Game.Time + const.Minute*30*math.max(Power, 1)
		Buff.Power = 3
		Buff.Skill = JoinSkill(10,4)
	end
end

