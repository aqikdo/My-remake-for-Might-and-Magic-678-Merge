local function GetDist(t,x,y,z)
	local px, py, pz  = XYZ(t)
	return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
end

function Kill()
	for i,v in Map.Monsters do
		v.HP = 0
	end
end

function KillAura()
	for i,v in Map.Monsters do
		if GetDist(v,Party.X,Party.Y,Party.Z)<4000 then
			v.HP = 0
		end
	end
end

function TP(x,y,z)
	Party.X = x
	Party.Y = y
	Party.Z = z
end

function SeeMon()
	for _, pl in Party do
		for i, val in pl.Skills do
			if i==const.Skills.IdentifyMonster then
				local skill, mastery = SplitSkill(val)
				pl.Skills[i] = JoinSkill(60,  const.GM)
			end
		end
	end
end

function Invin()
	for _, pl in Party do
		for i, val in pl.Skills do
			local skill, mastery = SplitSkill(val)
			pl.Skills[i] = JoinSkill(60,  const.GM)
		end
	end
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end
end

function SetExpert()
	for _, pl in Party do
		for i, val in pl.Skills do
			local skill, mastery = SplitSkill(val)
			pl.Skills[i] = JoinSkill(math.max(skill,1),  const.Expert)
		end
		pl.SkillPoints = 99999
	end
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end
end

function SetMaster()
	for _, pl in Party do
		for i, val in pl.Skills do
			local skill, mastery = SplitSkill(val)
			pl.Skills[i] = JoinSkill(math.max(skill,1),  const.Master)
		end
		pl.SkillPoints = 99999
	end
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end
end

function SetGM()
	for _, pl in Party do
		for i, val in pl.Skills do
			local skill, mastery = SplitSkill(val)
			pl.Skills[i] = JoinSkill(math.max(skill,1),  const.GM)
		end
		pl.SkillPoints = 99999
	end
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end
end

function SetAttr(mi,nt,pe,en,ac,sp,lu)
	for _, pl in Party do
		pl.MightBase = mi
		pl.IntellectBase = nt
		pl.PersonalityBase = pe
		pl.EnduranceBase = en
		pl.SpeedBase = sp
		pl.AccuracyBase = ac
		pl.LuckBase = lu
	end
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end
end

function SetAttr1(plnum,mi,nt,pe,en,ac,sp,lu)
	local pl = Party[plnum]
	pl.MightBase = mi
	pl.IntellectBase = nt
	pl.PersonalityBase = pe
	pl.EnduranceBase = en
	pl.SpeedBase = sp
	pl.AccuracyBase = ac
	pl.LuckBase = lu
end

function PrintAttr()
	for _, pl in Party do
		print("Might:", pl.MightBase, "Intellect:", pl.IntellectBase, "Personality:", pl.PersonalityBase, "Endurance:", pl.EnduranceBase, "Speed:", pl.SpeedBase, "Accuracy:", pl.AccuracyBase, "Luck:", pl.LuckBase)
	end
end

function PrintRes()
	for _, pl in Party do
		print("Fire:", pl.FireResistanceBase, "Air:", pl.AirResistanceBase, "Water:", pl.WaterResistanceBase, "Earth:", pl.EarthResistanceBase, "Mind:", pl.MindResistanceBase, "Body:", pl.BodyResistanceBase)
	end
end


function GetSpell()
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end	
end

function SetMagiLevel(lv)
	for _,pl in Party do
		pl.LevelBase = lv
		for j = 0,6 do
			pl.Stats[j].Base = math.floor(lv/2+math.sqrt(lv)) * 7
		end
		pl.ArmorClassBonus=lv * 2
		for j = 0,8 do
			pl.Resistances[j].Base = math.floor(lv/2+math.sqrt(lv)) * 3
		end
		for j = 12,20 do
			pl.Skills[j] = JoinSkill(math.floor(lv/2+math.sqrt(lv)),const.GM)
		end
		pl.Skills[const.Skills.Meditation]=JoinSkill(math.floor(3*math.sqrt(lv)),const.GM)
		pl.Skills[const.Skills.Bodybuilding]=JoinSkill(math.sqrt(lv),const.GM)
		pl.Skills[const.Skills.Perception]=JoinSkill(4,1)
	end
	for _, pl in Party do
		for i in pl.Spells do
			pl.Spells[i] = true
		end
	end
	for _, pl in Party do
		for i, val in pl.Skills do
			if i==const.Skills.IdentifyMonster then
				local skill, mastery = SplitSkill(val)
				pl.Skills[i] = JoinSkill(60,  const.GM)
			end
		end
	end
end

function PrintPos()
	print(Party.X,Party.Y,Party.Z)
end

function GotoMap(name)
	evt.MoveToMap(0,0,0,0,0,0,0,0,name)
end

function PrintArtifact()
	for v=1,5000 do 
		if vars.GotArtifact[v] == true then 
			print(Game.ItemsTxt[v].Name) 
			--[[vars.GotArtifact[v] = nil]] 
		end 
	end
end

local function TestSummonMonster(MonId, x, y)
	local NewMon = SummonMonster(MonId, x, y, 51, true)
	NewMon.NameId = 179
	return NewMon
end
local function PrepareTestMon(mon, hp, ar, firere, watere, airre, earthre, spirre, mindre, bodyre, darkre, lightre)
	mon.Velocity = 0
	mon.Attack1.DamageDiceSides = 0
	mon.Attack1.DamageDiceCount = 0
	mon.Attack1.DamageDiceAdd = 0
	mon.Attack2.DamageDiceSides = 0
	mon.Attack2.DamageDiceCount = 0
	mon.Attack2.DamageDiceAdd = 0
	mon.Spell = 0
	mon.SpellChance = 0
	mon.SpellSkill = 0
	mon.Spell2 = 0
	mon.SpellChance2 = 0
	mon.SpellSkill2 = 0
	mon.FullHP = hp
	mon.HP = hp
	mon.ArmorClass = ar
	mon.AirResistance = airre
	mon.WaterResistance = watere
	mon.BodyResistance = bodyre
	mon.FireResistance = firere
	mon.EarthResistance = earthre
	mon.SpiritResistance = spirre
	mon.MindResistance = mindre
	mon.LightResistance = lightre
	mon.DarkResistance = darkre
	mon.PhysResistance = 0
end

local function RecoveryTimer()
	for i,v in Party do
		v.HP = v:GetFullHP()
		v.SP = v:GetFullSP()
	end
end

local Killcnt = 0
local start_test = false
local start_time = 0
local end_time = 0
local test_level = 0

function events.MonsterKilled(mon)
	if start_test == true then
		Killcnt = Killcnt + 1
		if Killcnt == 1 then
			start_time = Game.Time
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 5000, 175 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end
	
		if Killcnt == 2 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 5000, 200 + test_level, 0 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end
	
		if Killcnt == 3 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 5000, 200 + test_level, 100 + test_level, 0 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end
	
		if Killcnt == 4 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 5000, 200 + test_level, 100 + test_level, 100 + test_level, 0 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end
	
		if Killcnt == 5 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 5000, 200 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 100 + test_level, 0 + test_level, 100 + test_level, 100 + test_level, 100 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end
	
		if Killcnt == 6 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 15000, 175 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, const.MonsterImmune, 75 + test_level, 75 + test_level, 75 + test_level, const.MonsterImmune, const.MonsterImmune)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end
	
		if Killcnt == 7 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 15000, 125 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end

		if Killcnt == 8 then
			local testmon = TestSummonMonster(501, 3859, 7346)
			PrepareTestMon(testmon, 15000, 225 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level, 75 + test_level)
			testmon.Hostile = true
			testmon.ShowAsHostile = true
			testmon.HostileType = 4
		end

		if Killcnt == 9 then
			start_test = false
			end_time = Game.Time
			local time_taken_sec = (end_time - start_time) / const.Minute * 60
			Message("Test completed in " .. tostring(time_taken_sec) .. " seconds.\nDps: " ..tostring(70000/time_taken_sec/(0.99^test_level)))
		end
	end
end

function StartTest()
	GotoMap("d42.blv")
	Sleep(5)
	Killcnt = 0
	if PartyLevelBaseSaved then
		for i,v in Party do
			v.LevelBase = PartyLevelBaseSaved[i]
		end
	end
	Sleep(5)
	for i,v in Party do
		v.HP = v:GetFullHP()
		v.SP = v:GetFullSP()
	end
	local testmon = TestSummonMonster(501, 3859, 7346)
	PrepareTestMon(testmon, 30000, 500, 400, 400, 400, 400, 400, 400, 400, 400, 400)
	for i,v in Map.Monsters do
		v.Hostile = true
		v.ShowAsHostile = true
		v.HostileType = 4
	end
	Timer(RecoveryTimer, const.Minute/4, false)
	--BolsterMonsters() 
	return
end

function StartTest2(testlv)
	GotoMap("d42.blv")
	Sleep(5)
	test_level = testlv or 0
	Killcnt = 0
	start_test = true
	if PartyLevelBaseSaved then
		for i,v in Party do
			v.LevelBase = PartyLevelBaseSaved[i]
		end
	end
	Sleep(5)
	for i,v in Party do
		v.HP = v:GetFullHP()
		v.SP = v:GetFullSP()
	end
	Timer(RecoveryTimer, const.Minute/4, false)

	local testmon = TestSummonMonster(501, 3859, 7346)
	PrepareTestMon(testmon, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
	testmon.Hostile = true
	testmon.ShowAsHostile = true
	testmon.HostileType = 4
	--BolsterMonsters() 
	return
end

