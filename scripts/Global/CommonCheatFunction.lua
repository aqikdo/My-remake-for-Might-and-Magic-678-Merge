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
