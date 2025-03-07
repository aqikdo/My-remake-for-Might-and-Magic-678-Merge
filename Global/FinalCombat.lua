function FinalSummonMonster(MonId, x, y)
	local NewMon = SummonMonster(MonId, x, y, 51, true)
end
function PrepareBoss1(mon)
	mon.Velocity = 0
	mon.Attack1.DamageDiceSides = 99
	mon.Attack1.DamageDiceCount = 255
	mon.Attack1.DamageDiceAdd = Game.BolsterAmount / 100 * 60
	mon.Attack2.DamageDiceSides = 99
	mon.Attack2.DamageDiceCount = 255
	mon.Attack2.DamageDiceAdd = Game.BolsterAmount / 100 * 60
	mon.Spell = 11
	mon.SpellChance = 100
	mon.SpellSkill = JoinSkill(1000, const.GM)
	local rt = mon.HP / mon.FullHP
	mon.FullHP = 140 * math.min(Game.BolsterAmount, 200) + 2000
	mon.HP = mon.FullHP * rt
	mon.ArmorClass = 250 + math.min(Game.BolsterAmount, 200)
	mon.AirResistance = 200 + math.min(Game.BolsterAmount, 200)
	mon.WaterResistance = 200 + math.min(Game.BolsterAmount, 200)
	mon.BodyResistance = 200 + math.min(Game.BolsterAmount, 200)
	mon.FireResistance = const.MonsterImmune
	mon.EarthResistance = const.MonsterImmune
	mon.SpiritResistance = const.MonsterImmune
	mon.MindResistance = const.MonsterImmune
	mon.LightResistance = const.MonsterImmune
	mon.DarkResistance = const.MonsterImmune
	mon.PhysResistance = 0
end
function PrepareBoss2(mon)
	mon.Velocity = 250 * math.min(2, 1 + Game.BolsterAmount / 200)
	mon.Attack1.DamageDiceSides = 99
	mon.Attack1.DamageDiceCount = 255
	mon.Attack2.DamageDiceSides = 99
	mon.Attack2.DamageDiceCount = 255
	mon.Spell = 11
	mon.SpellChance = 100
	mon.SpellSkill = JoinSkill(1000, const.GM)
	local rt = mon.HP / mon.FullHP
	mon.FullHP = 140 * math.min(Game.BolsterAmount, 200) + 2000
	mon.HP = mon.FullHP * rt
	mon.ArmorClass = 150 + math.min(Game.BolsterAmount, 200)
	mon.AirResistance = 100 + math.min(Game.BolsterAmount, 200)
	mon.WaterResistance = 100 + math.min(Game.BolsterAmount, 200)
	mon.BodyResistance = 100 + math.min(Game.BolsterAmount, 200)
	mon.FireResistance = const.MonsterImmune
	mon.EarthResistance = const.MonsterImmune
	mon.SpiritResistance = const.MonsterImmune
	mon.MindResistance = const.MonsterImmune
	mon.LightResistance = const.MonsterImmune
	mon.DarkResistance = const.MonsterImmune
	mon.PhysResistance = 0
end
function PrepareBoss3(mon)
	mon.Velocity = 500 * math.min(2, 1 + Game.BolsterAmount / 200)
	mon.Attack1.DamageDiceSides = 99
	mon.Attack1.DamageDiceCount = 255
	mon.Attack2.DamageDiceSides = 99
	mon.Attack2.DamageDiceCount = 255
	mon.SpellChance = 100
	mon.SpellSkill = JoinSkill(1000, const.GM)
	local rt = mon.HP / mon.FullHP
	mon.FullHP = 140 * math.min(Game.BolsterAmount, 200) + 2000
	mon.HP = mon.FullHP * rt
	mon.ArmorClass = 50 + math.min(Game.BolsterAmount, 200)
	mon.AirResistance = math.min(Game.BolsterAmount, 200)
	mon.WaterResistance = math.min(Game.BolsterAmount, 200)
	mon.BodyResistance = math.min(Game.BolsterAmount, 200)
	mon.FireResistance = const.MonsterImmune
	mon.EarthResistance = const.MonsterImmune
	mon.SpiritResistance = const.MonsterImmune
	mon.MindResistance = const.MonsterImmune
	mon.LightResistance = const.MonsterImmune
	mon.DarkResistance = const.MonsterImmune
	mon.PhysResistance = 0
	mon.SpellBuffs[const.MonsterBuff.Haste].ExpireTime = Game.Time + const.Year
end
function SummonBoss(x, y)
	local Boss = SummonMonster(501, x, y, 251, true)
	Boss.NameId = 179
	return Boss
end
function StartCombat()
	GotoMap("d42.blv")
	Sleep(10)
	local Boss = SummonBoss(3859,7346)
	FinalSummonMonster(111, 1495, 5267)
	FinalSummonMonster(123, 3806, 5267)
	FinalSummonMonster(135, 6205, 5267)
	FinalSummonMonster(171, 2473, 6191)
	FinalSummonMonster(288, 5210, 6191)
	FinalSummonMonster(507, 1495, 5871)
	FinalSummonMonster(570, 3806, 5871)
	FinalSummonMonster(546, 6205, 5871)
	FinalSummonMonster(486, 1495, 4900)
	FinalSummonMonster(498, 3806, 4900)
	FinalSummonMonster(510, 6205, 4900)
	FinalSummonMonster(561, 2473, 7170)
	FinalSummonMonster(633, 5210, 7170)
	BolsterMonsters() 
	PrepareBoss1(Boss)
	Sleep(10000)
	FinalSummonMonster(18, 1495, 5267)
	FinalSummonMonster(18, 3806, 5267)
	FinalSummonMonster(18, 6205, 5267)
	FinalSummonMonster(213, 2473, 6191)
	FinalSummonMonster(213, 5210, 6191)
	FinalSummonMonster(486, 1495, 5871)
	FinalSummonMonster(486, 3806, 5871)
	FinalSummonMonster(486, 6205, 5871)
	FinalSummonMonster(267, 1495, 4900)
	FinalSummonMonster(267, 3806, 4900)
	FinalSummonMonster(267, 6205, 4900)
	FinalSummonMonster(570, 2473, 7170)
	FinalSummonMonster(570, 5210, 7170)
	BolsterMonsters() 
	PrepareBoss2(Boss)
	Sleep(10000)
	FinalSummonMonster(156, 1495, 5267)
	FinalSummonMonster(156, 3806, 5267)
	FinalSummonMonster(156, 6205, 5267)
	FinalSummonMonster(261, 1495, 5871)
	FinalSummonMonster(261, 3806, 5871)
	FinalSummonMonster(261, 6205, 5871)
	FinalSummonMonster(567, 1495, 4900)
	FinalSummonMonster(567, 3806, 4900)
	FinalSummonMonster(567, 6205, 4900)
	for i,v in Map.Monsters do
		v.Hostile = true
		v.ShowAsHostile = true
		v.HostileType = 4
	end
	BolsterMonsters() 
	PrepareBoss3(Boss)
	return
end

function events.MonsterKilled(mon)
	if mon.NameId == 179 then
		vars.FinalCombatStart = false
		vars.Finished = true
	end
end

--[[
function events.AfterLoadMap()
	Timer(TeleportTimer, 4, false)
	if vars.Quest_CrossContinents.AllStoriesFinished and (not Party.EnemyDetectorRed) and (not Party.EnemyDetectorYellow) then
		if not vars.FinalCombat then
			vars.FinalCombat = true
			evt.SetNPCGreeting{803, 322}
			NPCTopic{
				NPC		= 803,
				Name	= "Verdant - FinalCombat",
				Branch	= "",
				Slot	= 3,
				CanShow	= function() return true end,
				Ungive  = function(t)
					vars.FinalCombatStart = true
					vars.TeleportTime = Game.Time + 1000
				end,
				Texts	= {
					Topic	= Game.NPCTopic[1769],
					Ungive	= Game.NPCText[2217]
					}
			}
			evt.SpeakNPC{803}
			
		end
	end
end
]]--

function events.ExitMapAction(t)
	if vars.FinalCombatStart == true then
		for i,v in Map.Monsters do
			if v.NameId == 179 then
				for i = 0, Party.length - 1 do
					Party[i].HP = -1000
				end
			end
		end
	end
end

function events.DeathMap()
	if vars.FinalCombatStart == true then
		vars.Doom = vars.Doom or 1
	end
end

local function KillingTimer()
	for i,v in Map.Monsters do
		v.HP = 0
	end
	for i,pl in Party do
		pl.HP = pl.HP - pl:GetFullHP() * 0.01 * vars.Doom
	end
end

function events.AfterLoadMap()
	if vars.Doom then
		vars.Doom = vars.Doom + 1
		Timer(KillingTimer, 1, false)
		if vars.Doom == 2 then
			Message(" ÊÀ ½ç Ä© ÈÕ ½µ ÁÙ ÁË £¬ ²¢ ÇÒ ÓÉ ÓÚ Äã ·´ ¿¹ ÁË Î¬ ¶û µ¤ £¬ Äã Ò² ²» »á ÐÒ Ãâ Óö ÄÑ ¡£")
		end
	end
	if vars.Finished then
		Sleep(10)
		local timesp = (Game.Year - 1172) * 12 * 28 + Game.Month * 28 + Game.DayOfMonth
		local score = (Game.BolsterAmount / 10) + 20 * (0.8 ^ math.log(Party.Deaths + 1)) + 20 * (0.8 ^ math.log(vars.LoadTimes / 100 + 1)) + 20 * (0.994 ^ timesp)
		score = math.ceil(score)
		if vars.Quest_CrossContinents.AllStoriesFinished then
			score = score + 10
		end
		Sleep(10)
		Message("Congratulations! You defeated Verdant and save the world!")
		Sleep(10)
		local str = ""
		if score >= 90 then
			str = "My Goodness! How can you get such a high score, you are definitely a god at this game."
		elseif score >= 80 then
			str = "Excellent! You have to be a grandmaster at this game."
		elseif score >= 70 then
			str = "Wow! It's really a good score, you are a master at this game."
		elseif score >= 60 then
			str = "Pretty good! This game is very hard, I believe that you are a pro at this game."
		elseif score >= 50 then
			str = "Not bad. I know that the game is very difficult, but I think you can do better."
		elseif score >= 40 then
			str = "It's ok to get this score if you are not an expert at this game, you can try to challenge yourself and choose a higher difficulty."
		elseif score >= 30 then
			str = "You can do better. Do not be afraid of challenge."
		elseif score >= 20 then
			str = "Don't worry, it's ok for a greenhand, next time you will be better."
		elseif score >= 10 then
			str = "You can switch to the official version of this game, you may not be very suitable for this difficulty."
		else
			str = "Alright, I have no idea how can you get such a low score, you can quit this game :("
		end
		Message("Here's the score for you.\nThe time you spend: "..tostring(Game.Year - 1172).." years "..tostring(Game.Month).." months "..tostring(Game.DayOfMonth).." days ".."\nYour death times: "..tostring(Party.Deaths).."\nYour load game times: "..tostring(vars.LoadTimes).."\nAnd finally, your score: "..tostring(score).."\n"..str)
		Sleep(10)
		Message("Anyway, thank you for playing this game and hope you enjoy it.")
		vars.Finished = false
	end
end

