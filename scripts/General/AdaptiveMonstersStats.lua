local max, min, ceil, floor, random, sqrt = math.max, math.min, math.ceil, math.floor, math.random, math.sqrt
local ReadyMons = {}
local MonBolStep = {}

---- Additional mon properties and bolster tables

const.Bolster = {}

const.Bolster.Types = {
	NoBolster 		= 0,
	OriginalStats	= 1,
	LowerToEqual	= 2,
	AllToEqual		= 3
}

-- Fix const.MonsterKind
const.MonsterKind = {
	Undead = 1,
	Dragon = 2,
	Swimmer = 3,
	Immobile = 4,
	Peasant = 5,
	NoArena = 6,
	Ogre = 7,
	Elemental = 8,
	Demon = 9,
	Titan = 10,
	Elf = 11,
	Goblin = 12,
	Dwarf = 13,
	Human = 14
}

const.Bolster.MonsterType = {
	Unknown		= 0,
	Undead 		= 1,
	Dragon 		= 2,
	Swimmer		= 3,
	Immobile	= 4,
	Peasant		= 5,
	NoArena		= 6,
	Ogre		= 7,
	Elemental	= 8,
	Demon 		= 9,
	Titan 		= 10,
	Elf 		= 11,
	Goblin		= 12,
	Dwarf		= 13,
	Human		= 14,
	DarkElf		= 15,
	Lizardman	= 16,
	Minotaur	= 17,
	Troll		= 18,
	Creature	= 19,
	Construct	= 20
	}

const.Bolster.Creed = {
	Neutral	= 0,
	Light 	= 1,
	Dark 	= 2,
	Peasant = 3	-- for hireable creatures
	}

const.Bolster.Magic = {
	Any		= 0,
	Fire	= 1,
	Air		= 2,
	Water	= 3,
	Earth	= 4,
	Spirit	= 5,
	Mind	= 6,
	Body	= 7,
	Light	= 8,
	Dark	= 9,
	Self	= 10,
	Elemental = 11
	}

const.Bolster.Style = {
	Strength	= 0,
	Endurance 	= 1,
	Speed 		= 2,
	Magic		= 3,
	Wimpy		= 4
	}

local function ProcessBolsterTxt()

	local Warning = ""

	local function GetProp(Val, Type, i)
		local result = tonumber(Val) or const.Bolster[Type][Val] or 0
		if not result then
			result = 0
			Warning = Warning .. "Undefined property, line: " .. i .. ", type: " .. Type .. "\n"
		end
		return result
	end

	---- Monsters:

	Game.Bolster = {}
	Game.Bolster.Monsters = {}

	local Bolster = Game.Bolster.Monsters
	local BolsterTxt = io.open("Data/Tables/Bolster - monsters.txt", "r")

	if not BolsterTxt then
		BolsterTxt = io.open("Data/Tables/Bolster - monsters.txt", "w")
		BolsterTxt:write("#	Note	Type	ExtraType	Creed	Style	Pref magic	NoArena	Allow ranged attacks	Allow spells	HP by size	Allow replicate	Allow summons	Summon Id	Extra points	Max HP Boost (%)\n")
		for i,v in Game.MonstersTxt do
			BolsterTxt:write(i .. "\9" .. v.Name .. "\9\9\9\9\9\9-\9-\9-\9-\9-\9-\9\9\n")
			Bolster[i] = {Type = 0, Creed = 0, Style = 0, PrefMagic = 0, Ranged = false, Spells = false, HPBySize = false, Summons = false, SummonId = 0, LevelShift = 0}
		end
	else
		local LineIt = BolsterTxt:lines()
		LineIt() -- skip header

		for line in LineIt do
			local Words = string.split(line, "\9")
			local CurId = tonumber(Words[1]) or 0
			Bolster[CurId] = {
				Type 		= GetProp(Words[3], "MonsterType", CurId),
				ExtraType 	= {},
				Creed 		= GetProp(Words[5], "Creed", CurId),
				Gender 		= Words[6] == "F" and "F" or "M",
				Style	 	= GetProp(Words[7], "Style", CurId),
				Magic 		= GetProp(Words[8], "Magic", CurId),
				NoArena 	= Words[9]  == "x",
				Ranged 		= Words[10] == "x",
				Spells 		= Words[11] == "x",
				HPBySize	= Words[12] == "x",
				Replicate	= Words[13] == "x",
				Summons 	= Words[14] == "x",
				SummonId 	= tonumber(Words[15]) or 0,
				LevelShift 	= tonumber(Words[16]) or 0,
				MaxHPBoost	= (tonumber(Words[17]) or 300)/100}
			local types = string.split(Words[4], ",")
			for _, v in pairs(types) do
				local mon_type = GetProp(v, "MonsterType", CurId)
				if mon_type and mon_type > 0 then
					table.insert(Bolster[CurId].ExtraType, mon_type)
				end
			end
		end

		if string.len(Warning) > 0 then
			Warning = 'Errors in "Bolster - monsters.txt":\n'
			debug.Message(Warning)
		end
	end

	BolsterTxt:close()

	---- Per-map restrictions:

	Game.Bolster.Maps = {}
	Game.Bolster.MapsSource = {}

	Bolster = Game.Bolster.Maps
	BolsterTxt = io.open("Data/Tables/Bolster - maps.txt", "r")

	if not BolsterTxt then
		BolsterTxt = io.open("Data/Tables/Bolster - maps.txt", "w")
		BolsterTxt:write("#	Note	Continent	Bolster kind	Spells	Summons	Level shift\n")
		for i,v in Game.MapStats do
			BolsterTxt:write(i .. "\9" .. v.Name .. "\9\9NoBolster\9-\9-\9-\9\9\n")
			Bolster[i] = {Continent = 1, Type = 0, Spells = false, Summons = false, Weather = false, LevelShift = 0, CustomSky = false}
		end
	else
		local LineIt = BolsterTxt:lines()
		LineIt() -- skip header

		for line in LineIt do
			local Words = string.split(line, "\9")
			local CurId = tonumber(Words[1]) or 0
			Bolster[CurId] = {
				Continent	= tonumber(Words[3]) or 1,
				Type 		= GetProp(Words[4], "Types", CurId),
				Spells 		= Words[5] == "x",
				Summons	 	= Words[6] == "x",
				Weather	 	= Words[7] == "x",
				LevelShift	= tonumber(Words[8]) or 0,
				CustomSky 	= string.len(Words[10]) > 0 and Words[10] or false,
				ProfsMaxRarity = tonumber(Words[9]) or 0}

			Game.Bolster.MapsSource[CurId] = table.copy(Bolster[CurId])
		end

		if string.len(Warning) > 0 then
			Warning = 'Errors in "Bolster - monsters.txt":\n'
			debug.Message(Warning)
		end
	end

	BolsterTxt:close()

	----

	Game.Bolster.MonstersSource = Game.Bolster.Monsters

	---- Formulas:

	Game.Bolster.Formulas = {}
	Bolster = Game.Bolster.Formulas
	BolsterTxt = io.open("Data/Tables/Bolster - formulas.txt", "r")

	if BolsterTxt then
		local LineIt = BolsterTxt:lines()
		LineIt() -- skip header

		for line in LineIt do
			local Words = string.split(line, "\9")
			if Words[1] and Words[2] and Words[3] and string.len(Words[1]) > 0 and string.len(Words[2]) > 0 then
				local CurId = tonumber(Words[1]) or Words[1]
				local str
				Bolster[CurId] = Bolster[CurId] or {}

				if string.len(Words[3]) == 0 then
					str = "return false"
				elseif string.find(Words[3], "return") then
					str = Words[3]
				else
					str = "return " .. Words[3]
				end

				Bolster[CurId][Words[2]] = str
			end
		end
	end

end

local OffensiveSpells = {
{2,6,11,62},	-- fire
{15,18},		-- air
{24,26,29,32},	-- water
{37,39,41},		-- earth
{52},			-- spirit
{59,65},		-- mind
{70,76},		-- body
{78,84,87},		-- light
{90,93,97}		-- dark
}

local DefensiveSpells = {
{5},			-- fire
{17,19},		-- air
{33},	     	-- water
{34,35,38},		-- earth
{46,64,51,54},	-- spirit
{66},			-- mind
{68,67},		-- body
{80,85,86},		-- light
{89,95,96}		-- dark
}

SpellDamageMul = 	   {[0] = 0,5.0, 3.4, 3.0, 3.0, 5.0, 1.5, 1.8, 1.8, 0.8, 1.5, 1.8, 
								5.0, 5.0, 3.0, 3.0, 1.2, 2.0, 3.6, 1.8, 1.5, 1.5, 1.0,
								5.0, 2.5, 3.0, 2.8, 2.0, 2.0, 2.2, 1.8, 1.5, 2.5, 1.5,
								5.0, 5.0, 3.0, 1.6, 2.0, 1.3, 1.8, 1.0, 1.5, 1.5, 1.0,
								5.0, 5.0, 3.0, 3.0, 2.0, 2.0, 1.8, 1.1, 1.5, 3.5, 1.0,
								5.0, 5.0, 3.0, 2.4, 2.0, 2.0, 1.6, 1.8, 1.5, 1.4, 1.0,
								2.0, 3.0, 3.0, 2.9, 2.0, 2.0, 1.8, 1.8, 1.5, 3.0, 2.0,
								3.0, 1.8, 1.8, 1.5, 2.0, 1.2, 1.8, 1.0, 1.0, 1.2, 0.8,
								4.0, 3.2, 1.8, 1.5, 1.6, 1.2, 1.0, 0.4, 0.5, 0.8, 0.8}

local MonsterSpecialSpell = {
	[16]  = {18, 50},   	-- Regnan Sorcerer: Lightning bolt 50%
	[17]  = {24, 50},   	-- Regnan Battlemage: Poison spray 50%
	[18]  = {6 , 50},   	-- Regnan Archmage: Fireball 50%
	[46]  = {78, 50},   	-- Acolyte of the Sun: Light Bolt 50%
	[47]  = {87, 50},   	-- Cleric of the Sun: Sunray 50%
	[48]  = {87, 75},  	 	-- Priest of the Sun: Sunray 75%
	[52]  = {78, 50},   	-- Vampire Minion: Mind Blast 50%
	[53]  = {70, 50},   	-- Vampire: Harm 50%
	[54]  = {52, 50},  	 	-- Greater Vampire: Spirit Lash 50%
	[55]  = {90, 50},   	-- Dark Path Journeymann: Toxic Cloud 50%
	[56]  = {93, 50},   	-- Necromancer: Sharpmetal 50%
	[57]  = {97, 50},  	 	-- Master Necromancer: Dragon Breath 50%
	[70]  = {2 , 50},   	-- Dragon: Firebolt 50%
	[71]  = {26, 50},   	-- Dragon Flightleader: Ice Bolt 50%
	[72]  = {18, 50},  	 	-- Great Wyrm: Lightning Bolt 50%
	[73]  = {5 , 30},   	-- Lesser Fire Elemental: Haste 30%
	[74]  = {6 , 50},   	-- Fire Elemental: Fireball 50%
	[75]  = {11, 50},  	 	-- Greater Fire Elemental: Incinerate 50%
	[76]  = {26, 30},   	-- Lesser Water Elemental: Ice Bolt 30%
	[77]  = {29, 50},   	-- Water Elemental: Acid Burst 50%
	[78]  = {32, 50},  	 	-- Greater Water Elemental: Ice Blast 50%
	[79]  = {37, 50},   	-- Lesser Earth Elemental: Deadly Swarm 50%
	[80]  = {39, 50},   	-- Earth Elemental: Blade 50%
	[81]  = {34, 30},  	 	-- Greater Earth Elemental: Stun 30%
}

local MonsterSpecialSpell2 = {
	[25]  = {51, 25},   	-- Dark Elven Warrior: Heroism 25%
	[26]  = {17, 25},   	-- Dark Elven Defenser: Shield 25%
	[27]  = {86, 25},  	 	-- Dark Elven Crusader: Hour of Power 25%
	[46]  = {78, 13},   	-- Acolyte of the Sun: Heal 13%
	[47]  = {68, 25},   	-- Cleric of the Sun: Heal 25%
	[48]  = {77, 25},  	 	-- Priest of the Sun: Power Cure 25%
	[52]  = {38, 25},   	-- Vampire Minion: Stone Skin 25%
	[53]  = {51, 25},   	-- Vampire: Heroism 25%
	[54]  = {95, 25},  	 	-- Greater Vampire: Pain Reflection 25%
	[57]  = {97, 25},  	 	-- Master Necromancer: Pain Reflection 25%
	[64]  = {46, 25},   	-- Minotaur Guard: Bless 25%
	[65]  = {51, 25},   	-- Minotaur Warrior: Heroism 25%
	[66]  = {86, 25},  	 	-- Minotaur Battleleader: Hour of Power 25%
	[72]  = {80, 25},  	 	-- Great Wyrm: Dispel Magic 25%
}

								
local HPMulByStyle 		= {[0] = 1.10, 1.20, 1.10, 0.90, 1.0}
local DamageMulByStyle 	= {[0] = 0.63, 0.42, 0.56, 0.51, 1.0}
local MagicMulByStyle   = {[0] = 0.40, 0.40, 0.52, 0.66, 1.0}
local SpRateMulByStyle  = {[0] = 1.20, 1.20, 1.60, 2.00, 1.0}
local SpeedMulByStyle   = {[0] = 1.00, 0.90, 1.35, 0.90, 1.0}
local SpMasMulByStyle   = {[0] = 2   , 2   , 3   , 4   , 1  }
local ArmorResAddbyStyle= {[0] = 0   , 30  , 0   , 0   , 0  }

MagicMulByBoost   		= {[0] = 1.00, 1.00, 1.00, 3.00, 1.0}
local SpRateMulByBoost  = {[0] = 0.50, 1.00, 1.00, 3.00, 1.0}
DamageMulByBoost 		= {[0] = 3.00, 1.00, 1.00, 1.00, 1.0}
local ArmorResAddbyBoost= {[0] = 0   , 70  , 0   , 0   , 0  }

--ReanimateHP			= {[0] = 1.00, 0.25}
--ReanimateDmg			= {[0] = 1.00, 0.80}
ReanimateHP				= {[0] = 1.00, 0.50}
ReanimateDmg			= {[0] = 1.00, 0.50}
ReanimateSpeed			= {[0] = 1.00, 0}

local MonsterBodyRadius = {[388] =  90, [389] = 100, [390] = 110,
						   [502] =  45, [503] =  45, [504] =  45,
						   [409] = 150, [410] = 150, [411] = 150}
						   
local MonsterEliteLevel = {[115] =  3, [131] =  5, [132] =  5, [134] =  2, [137] =  -0.5, 
						   [164] =  4, [165] =  2, [166] =  2, [167] =  2, [168] =  2, 
						   [169] =  1, [170] =  3, [171] = 12, [172] = 12, [173] = 12, 
						   [174] =  5, [175] =  2, [176] =  2, [177] =  2, [178] =  2,
						   [179] = 10, [180] =  2, [111] =  3, [112] =  6, [127] = 	8,
						   [181] =  5, [182] =  5, [183] =  5, [128] =  2, [184] = 12,
						   [185] =  3, [186] =  3, [187] =  3, [188] =  3, [190] = 10, [191] = 5,
						   [192] =  1, [193] =  6, [197] =  2, [198] =  10, [199] =  8, [200] =  12}

local MonsterEliteSpell = {[115] = 11, [119] = 33, [120] = 33, [131] = 97, [132] = 89, [134] = 89, 
						   [164] = 90, [165] =  6, [166] = 32, [167] = 16, [168] = 41, 
						   [169] = 90, [170] =  6, [173] = 82, [174] = 97, [175] = 16, [176] = 5,
						   [179] = 11, [180] = 85, [137] = 11, [117] = 32, [184] = 70, [128] = 32,
						   [185] = 32, [186] = 18, [187] = 34, [188] = 84, [192] = 18, [193] = 82,
						   [190] = 97, [191] = 64, [196] = 90}
					
local MonsterEliteSpell2= {[115] =  6, [119] = 35, [120] = 35, [131] = 97, [132] = 97, [134] = 89, 
						   [164] = 93, [165] =  6, [166] = 32, [167] = 16, [168] = 41, 
						   [169] = 90, [170] =  6, [173] = 82, [174] = 96, [175] = 16, [176] = 95,
						   [179] = 11, [180] = 86, [137] = 11, [117] = 32, [184] = 70, [128] = 32,
						   [185] = 32, [186] = 19, [187] = 35, [188] = 64, [192] = 18, [193] = 82,
						   [190] = 93, [191] = 64, [196] = 93}
						   
MonsterEliteDamage		= {[170] =  2, [185] =  2, [186] =  2, [187] =  2, [128] =  3, [184] =  6, [192] = 3, 
						   [176] =  1.5}
						   			   
local MapLevel 			= {["sewer.blv"] 	= 2.2, -- Free Haven Sewer
						   ["zdwj02.blv"] 	= 0.6, -- Devil Outpost
						   ["6t7.blv"] 		= 2.8, -- Superior Temple of Baa
						   ["6t6.blv"] 		= 3.3, -- Supereme Temple of Baa
						   ["cd1.blv"] 		= 2.3, -- Castle Alamos
						   ["cd2.blv"] 		= 1.7, -- Castle Darkmoor
						   ["cd3.blv"] 		= 2.0, -- Castle Kerigspire
						   ["pyramid.blv"] 	= 2.2, -- Tomb of Varn
						   ["sci-fi.blv"] 	= 2.2, -- Control Center
						   ["hive.blv"] 	= 2.4, -- Hive
						   ["6d12.blv"] 	= 2.0, -- Silver Helm Castle
						   ["7d10.blv"] 	= 2.6, -- Breeding Zone
						   ["t01.blv"] 		= 2.4, -- Temple of Light
						   ["t02.blv"] 		= 2.4, -- Temple of Dark
						   ["t03.blv"] 		= 1.9, -- Grand Temple of the Sun
						   ["7d19.blv"] 	= 1.9, -- Grand Temple of the Moon
						   ["7d16.blv"] 	= 3.0, -- Wine Cellar
						   ["7d12.blv"] 	= 2.4, -- Clanker's Laboratory
						   ["7d27.blv"] 	= 3.0, -- Land of Constellation (Star)
						   ["7d23.blv"] 	= 3.0, -- Lincoin
						   ["d10.blv"] 		= 1.0, -- Crystal of Escaton
						   ["d35.blv"] 		= 2.5, -- Palace of Escaton
						   ["d36.blv"] 		= 1.8, -- Prison of the Air Lord
						   ["d37.blv"] 		= 2.4, -- Prison of the Fire Lord
						   ["d38.blv"] 		= 2.4, -- Prison of the Water Lord
						   ["d39.blv"] 		= 2.4} -- Prison of the Earth Lord

local BolsterTypes = const.Bolster.Types

local function GetOverallPartyLevel()
	local Ov, Cnt = 0, 1
	for i,v in Party do
		Ov = Ov + v.LevelBase
		Cnt = i + 1
	end
	return ceil(Ov/Cnt)
end

local function GetOverallItemBonus() -- approximate equipped items costs as their power
	local result = 0
	for ip,player in Party do
		for i,v in player.EquippedItems do
			if v > 0 then
				result = result + player.Items[v]:GetValue()
			end
		end
	end
	return result
end

local function SetAttackMaxDamage(Attack, MaxDamage)
	MaxDamage = ceil(MaxDamage)

	local Dices, Sides
	local FixDamage = 0

	MaxDamage = MaxDamage - FixDamage
	Dices = sqrt(MaxDamage)
	Sides = Dices

	Attack.DamageAdd 		= FixDamage
	Attack.DamageDiceSides 	= Sides
	Attack.DamageDiceCount 	= Dices
end

local function FixRandom(mon, p1, p2, p3, mod)
	return (math.floor(mon.StartX * p1 * p2 / p3) + math.floor(mon.StartY * p2 * p3 / p1) + mon.StartZ * p3 + vars.RandomSeed) % mod + 1
end

function SetAttackMaxDamage2(mon, Attack, MaxDamage)
	MaxDamage = ceil(MaxDamage)
	
	local Dices, Sides
	
	if MaxDamage <= 8100 then
		Dices = sqrt(MaxDamage)
		Sides = Dices + FixRandom(mon,17,41,31,floor(sqrt(Dices)))
	elseif MaxDamage <= 21000 then
		MaxDamage = MaxDamage + FixRandom(mon,13,101,19,floor(MaxDamage / 10))
		Dices = 100 - FixRandom(mon,17,97,37,10)
		Sides = math.min(255, floor(MaxDamage / Dices))
	else
		Dices = math.min(255, floor(sqrt(MaxDamage)))
		Sides = math.min(255, Dices + FixRandom(mon,17,41,31,floor(sqrt(Dices))))
	end
	
	Attack.DamageDiceSides 	= Sides
	Attack.DamageDiceCount 	= Dices
end

local function GenMonSpell1(mon, MonSettings, BolStep)

	local Magic, Creed, Style, Ranged = MonSettings.Magic, MonSettings.Creed, MonSettings.Style, MonSettings.Ranged
	if Style == 4 then
		return 0
	end

	local School, Spell
	local Schl, Schr
	if Magic == 0 then
--		School = random(1,9)
--		School = FixRandom(mon, 13, 17, 59, 9)
		Schl = 1
		Schr = 9
	elseif Magic < 10 then
		School = Magic
		Schl = Magic
		Schr = Magic
	elseif Magic == 10 then
--		School = random(5,9)
--		School = FixRandom(mon, 23, 29, 79, 5) + 4
		Schl = 5
		Schr = 9
	elseif Magic == 11 then
--		School = random(1,4)
--		School = FixRandom(mon, 37, 41, 97, 4)
		Schl = 1
		Schr = 4
	end
	
	local IsOffensive = true
	if Style == 0 or Style == 1 then
		IsOffensive = (FixRandom(mon, 233, 239, 241, 3) <= 2)
	end

	local SpellSet = {}
	if IsOffensive then
--		SpellSet = OffensiveSpells[School]
		for i = Schl,Schr do
			for j = 1 , #OffensiveSpells[i] do
				table.insert(SpellSet, OffensiveSpells[i][j])
			end
		end
	else
--		SpellSet = DefensiveSpells[School]
		for i = Schl,Schr do
			for j = 1 , #DefensiveSpells[i] do
				table.insert(SpellSet, DefensiveSpells[i][j])
			end
		end
	end

--	Spell = #SpellSet
--	Spell = SpellSet[random(1,#SpellSet)]
	Spell = SpellSet[FixRandom(mon, 47, 101, 7, #SpellSet)]
	return Spell

end

local function GenMonSpell2(mon, MonSettings, BolStep)

	local Magic, Creed, Style, Ranged = MonSettings.Magic, MonSettings.Creed, MonSettings.Style, MonSettings.Ranged

	if Style == 4 then
		return 0
	end

	local School, Spell
	if Magic == 0 then
--		School = random(1,9)
		School = FixRandom(mon, 23, 29, 31, 9)
	elseif Magic < 10 then
		School = Magic
	elseif Magic == 10 then
--		School = random(5,9)
		School = FixRandom(mon, 101, 17, 7, 5) + 4
	elseif Magic == 11 then
--		School = random(1,4)
		School = FixRandom(mon, 107, 97, 17, 4)
	end
	
	local IsOffensive = (FixRandom(mon, 61, 67, 73, 2) == 1)

	local SpellSet
	if IsOffensive then
		SpellSet = OffensiveSpells[School]
	else
		SpellSet = DefensiveSpells[School]
	end

	Spell = #SpellSet
--	Spell = SpellSet[random(1,Spell)]
	Spell = SpellSet[FixRandom(mon, 17, 93, 31, Spell)]
	return Spell

end

local SpellReplace = {[81] = 87}

local function CalcResistance(res,BolsterMul)
--	return math.min(20 + 15 * math.log(res + 1), res * 3.5 - 30)
	if res > 10000 then
		return const.MonsterImmune
	else
		return math.max(0,res - 10 + (BolsterMul - 1) * 40)
	end
end

local function BolsterAdjust(x)
--	return math.min(20 + 15 * math.log(res + 1), res * 3.5 - 30)
	return (1 + 5.5 * x) / 6 * 0.99 ^ ((2 - x) * 40)
end

local function LogBolsterAdjust()
	local BolsterMul = Game.BolsterAmount / 100
	return math.log(BolsterAdjust(BolsterMul))/math.log(0.99)
end

function PrepareMapMon(mon)

	local lv = MapLevel[Map.Name] or 1
	
	if mon.Id == 457 then
		mon.NameId = 120
	elseif mon.Id == 458 then
		mon.NameId = 119
	end
	
	if mon.NameId == 179 then
		return
	end
	
	local TxtMon		= Game.MonstersTxt[mon.Id]
	local MonSettings	= Game.Bolster.Monsters[mon.Id]
	local BolStep		= MonBolStep[mon.Id]
	local Style         = MonSettings.Style
	local BolsterMul    = Game.BolsterAmount/100
	local IsSummoned    = mon.SpellBuffs[const.MonsterBuff.Summoned].ExpireTime >= Game.Time
	local IsReanimated  = 0
	if mon.Ally == 9999 then
		IsReanimated = 1
	end
	
--	mon.Level = math.floor(TxtMon.Level * lv)
	mon.Level = TxtMon.Level
	
--	mon.Elite           = (mon.StartX * 10007 + mon.StartY * 12347 + mon.StartZ * 45347) % 10
--	mon.Elite           = FixRandom(mon, 10007, 12347, 45347, math.ceil(300 / (mon.Level + 10))) - 1
	mon.Elite			= 0 
--[[
	if mon.Elite ~= 1 or mon.Level < 20 or IsSummoned then
		mon.Elite = 0
	end
]]--
	if mon.NameId >= 1 and mon.NameId ~= 163 then
		mon.Elite = 1
	end
	if mon.Id == 646 or mon.Id == 647 or mon.Id == 648 or mon.Id == 652 then
		mon.Elite = 0
	end
	if mon.Elite == 0 then
		mon.NameId = 0
	end
	if mon.NameId >= 1 and mon.NameId ~= 163 then
		if mon.NameId == 10 and Game.Map.Name == "pyramid.blv" then
			mon.Elite = 2
		else
			mon.Elite = MonsterEliteLevel[mon.NameId] or 1
		end
	end

	local num = FixRandom(mon, 97, 47, 73, 100) - 1
	
	if num < 75 then
		mon.BoostType = math.floor(num / 15)
	else
		mon.BoostType = Style
	end
	
	if mon.Elite ~= 0 then
		mon.BoostType = const.Bolster.Style.Wimpy
	end

--	if mon.Elite == 1 then
--		mon.Elite = 10
--	end
	-- Base stats
	if mon.NameId ~= 123 and not IsSummoned then -- Q
		local fhp = ceil(min(TxtMon.FullHP * (1 + mon.Elite / 2), 30000) * ReanimateHP[IsReanimated]) 
		if mon.HP > 0 then
			mon.HP = ceil(fhp * mon.HP / mon.FullHP)
		end
		mon.FullHP = fhp
	end

	--mon.HP = 30000
	--mon.FullHP = 30000

	local elite_armor_add = 99.5 * math.log(2 * (mon.Elite + 1) / (mon.Elite + 2))
	local elite_res_add = elite_armor_add
	if mon.Elite ~= 0 then
		elite_res_add = elite_res_add - 20
	end

	mon.ArmorClass = TxtMon.ArmorClass + elite_armor_add + FixRandom(mon, 131, 137, 139, 11) - 1
	
	if not IsSummoned then
		mon.MoveSpeed = TxtMon.MoveSpeed * ReanimateSpeed[IsReanimated]
	end
	
	-- Attacks
	
	if not IsSummoned then
		mon.Attack1.DamageAdd 		= BolsterMul * 60
		SetAttackMaxDamage2(mon, mon.Attack1, math.ceil(TxtMon.Attack1.DamageDiceSides) * TxtMon.Attack1.DamageDiceCount * (1 + mon.Elite) * (MonsterEliteDamage[mon.NameId] or 1) * ReanimateDmg[IsReanimated] * DamageMulByBoost[mon.BoostType])
		
		mon.Attack1.Missile 		= TxtMon.Attack1.Missile
		mon.Attack1.Type 			= TxtMon.Attack1.Type
		
		mon.Attack2.DamageAdd 		= BolsterMul * 60
		SetAttackMaxDamage2(mon, mon.Attack2, math.ceil(TxtMon.Attack2.DamageDiceSides) * TxtMon.Attack2.DamageDiceCount * (1 + mon.Elite) * (MonsterEliteDamage[mon.NameId] or 1) * ReanimateDmg[IsReanimated] * DamageMulByBoost[mon.BoostType])

	--	mon.Attack2Chance 			= 0 
		mon.Attack2Chance 			= TxtMon.Attack2Chance
		mon.Attack2.Missile 		= TxtMon.Attack2.Missile
		mon.Attack2.Type 			= TxtMon.Attack2.Type
		
		-- Spells
		-- Monsters can not cast paralyze, replace it:
		mon.Spell = SpellReplace[mon.Spell] or TxtMon.Spell
		mon.Spell2 = SpellReplace[mon.Spell2] or TxtMon.Spell2

		local NeedSpells = true

		local sk,mas = SplitSkill(TxtMon.SpellSkill)
		--mas = 4
		
		--if mon.Spell == 0 or FixRandom(mon, 3, 5, 7, 2) <= 0 then
		mon.Spell = GenMonSpell1(mon, MonSettings, BolStep, 0)
		mas = 3

		if MonsterSpecialSpell[mon.Id] then
			if FixRandom(mon, 2017, 199, 127, 100) <= MonsterSpecialSpell[mon.Id][2] then
				mon.Spell = MonsterSpecialSpell[mon.Id][1]
				mas = 4
			end	
		end
		--end

		--mas = 4
		--mon.Spell = 65
		
--		if mon.Elite~=0 then
--			mon.Spell = 19
--		end
		if Game.Map.Name == "elemw.odm" then
			mon.Spell = 26
		end

		if mon.NameId >= 1 and mon.NameId ~= 163 then
			mon.Spell = MonsterEliteSpell[mon.NameId] or mon.Spell
			mas = 4
		end

		mon.SpellChance		= min(TxtMon.SpellChance * (1 + mon.Elite) * SpRateMulByBoost[mon.BoostType], math.min(60, 15 * (SpRateMulByStyle[Style] ^ 2) * SpRateMulByBoost[mon.BoostType]))
	--	mon.SpellSkill 		= JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]), 1000) , mas)
		if IsReanimated == 1 then
			mon.SpellSkill = JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]) * ReanimateDmg[1], 1000), mas)
		else
			mon.SpellSkill = JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]), 1000) , mas)
		end
	--	mon.SpellChance     = 0

		sk,mas = SplitSkill(TxtMon.Spell2Skill)
		--mas = 4

		--if mon.Spell2 == 0 or FixRandom(mon, 173, 337, 347, 6) <= 5 then
		mon.Spell2 = GenMonSpell2(mon, MonSettings, BolStep)
		mas = 3

		if MonsterSpecialSpell2[mon.Id] then
			if FixRandom(mon, 137, 131, 139, 100) <= MonsterSpecialSpell2[mon.Id][2] then
				mon.Spell2 = MonsterSpecialSpell2[mon.Id][1]
				mas = 4
			end	
		end

		--end
	--	mon.Spell2 = GenMonSpell2(mon, MonSettings, BolStep)
	--	mon.Spell2 = 64
		if mon.NameId >= 1 and mon.NameId ~= 163 then
			mon.Spell2 = MonsterEliteSpell2[mon.NameId] or mon.Spell2
			mas = 4
		end
		
		mon.Spell2Chance	= min(TxtMon.Spell2Chance * (1 + mon.Elite) * SpRateMulByBoost[mon.BoostType], math.min(100, 25 * (SpRateMulByStyle[Style] ^ 2) * SpRateMulByBoost[mon.BoostType]))
	--	mon.Spell2Skill 	= JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell2] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]), 1000), mas)
		if IsReanimated == 1 then
			mon.Spell2Skill = JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell2] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]) * ReanimateDmg[1], 1000), mas)
		else
			mon.Spell2Skill = JoinSkill(math.min(math.max(1, sk * (1 + mon.Elite) * SpellDamageMul[mon.Spell2] * (MonsterEliteDamage[mon.NameId] or 1) * MagicMulByBoost[mon.BoostType]), 1000) , mas)
		end
	--	mon.Spell2Chance    = 0
		if mon.Spell == mon.Spell2 then
			mon.SpellChance = mon.SpellChance + mon.Spell2Chance * (100 - mon.SpellChance) / 100
			mon.Spell2 = 0
			mon.Spell2Chance = 0
			mon.Spell2Skill = 0
			if mon.NameId == 170 then
				mon.SpellChance = 100
			elseif mon.NameId == 173 then
				mon.SpellChance = 100
			end
		end
		
	end
	
	if mon.Id == 646 or mon.Id == 647 or mon.Id == 648 or mon.Id == 652 then
		mon.Spell = 0
		mon.Spell2 = 0
	end
	-- Summons

	mon.Special 	= TxtMon.Special
	mon.SpecialA 	= TxtMon.SpecialA
	mon.SpecialB 	= TxtMon.SpecialB
--	mon.SpecialC 	= TxtMon.SpecialC
	mon.SpecialD 	= TxtMon.SpecialD
--[[	
	mon.Special = 2
	mon.SpecialA = 5 -- If monster always stands still, like Trees in The Tularean forest, he will behave like spawn point.
	mon.SpecialB = Game.MonstersTxt[633].Fly == 1 and 0 or 1 -- if summon can fly he will be summoned in air.
	mon.SpecialC = 0
	mon.SpecialD = 633
]]--		
	mon.Velocity = mon.MoveSpeed
	-- Rewards
	
	if IsReanimated == 0 then
		mon.Experience = mon.Level * mon.Level * 1.25
	else
		mon.Experience = 0
	end
	
	mon.TreasureItemPercent = TxtMon.TreasureItemPercent
--	mon.TreasureItemPercent = 100
	mon.TreasureItemLevel	= TxtMon.TreasureItem
	
	
	if mon.Elite ~= 0 then
		mon.TreasureItemPercent = 100
		if TxtMon.TreasureItemLevel ~= 0 then
			mon.TreasureItemLevel	= math.min(TxtMon.TreasureItemLevel + 3, 6)
		else
			mon.TreasureItemLevel	= math.min(math.floor(mon.Level) / 10 + 3, 6)
		end
	else 
		if TxtMon.TreasureItemLevel >= 2 then
			mon.TreasureItemLevel	= math.min(TxtMon.TreasureItemLevel + 2, 6)
			local lv2 = GetOverallPartyLevel()
			local lv3 = mon.Level
			if mon.TreasureItemLevel == 4 then
				if lv2 <= 30 then
					mon.TreasureItemPercent = math.max(TxtMon.TreasureItemPercent, 50 * (2.7 ^ (-(lv3-15)*(lv3-15)/200)))
				end
			end
			if mon.TreasureItemLevel == 5 then
				if lv2 <= 50 then
					mon.TreasureItemPercent = math.max(TxtMon.TreasureItemPercent, 75 * (2.7 ^ (-(lv3-30)*(lv3-30)/200)))
				end
			end
			if mon.TreasureItemLevel == 6 then
				mon.TreasureItemPercent = math.max(TxtMon.TreasureItemPercent, 100 * (2.7 ^ (-(lv3-50)*(lv3-50)/1000)))
			end
		end
	end
	
	if TxtMon.FireResistance < 10000 then 
		mon.FireResistance = math.max(TxtMon.FireResistance + elite_res_add + FixRandom(mon, 149, 151, 157, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
	else
		mon.FireResistance = const.MonsterImmune
	end
	if TxtMon.AirResistance < 10000 then 
		mon.AirResistance = math.max(TxtMon.AirResistance + elite_res_add + FixRandom(mon, 163, 167, 173, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
	else
		mon.AirResistance = const.MonsterImmune
	end
	if TxtMon.WaterResistance < 10000 then 
		mon.WaterResistance = math.max(TxtMon.WaterResistance + elite_res_add + FixRandom(mon, 179, 181, 191, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
	else
		mon.WaterResistance = const.MonsterImmune
	end
	if TxtMon.EarthResistance < 10000 then 
		mon.EarthResistance = math.max(TxtMon.EarthResistance + elite_res_add + FixRandom(mon, 193, 197, 199, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
		if mon.Elite ~= 0 or mon.BoostType == const.Bolster.Style.Speed then
			mon.EarthResistance = const.MonsterImmune
		end
	else
		mon.EarthResistance = const.MonsterImmune
	end
	if TxtMon.BodyResistance < 10000 then 
		mon.BodyResistance = math.max(TxtMon.BodyResistance + elite_res_add + FixRandom(mon, 211, 223, 227, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
	else
		mon.BodyResistance = const.MonsterImmune
	end
	if TxtMon.MindResistance < 10000 then 
		mon.MindResistance = math.max(TxtMon.MindResistance + elite_res_add + FixRandom(mon, 233, 239, 241, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
	else
		mon.MindResistance = const.MonsterImmune
	end
	if TxtMon.SpiritResistance < 10000 then 
		mon.SpiritResistance = math.max(TxtMon.SpiritResistance + elite_res_add + FixRandom(mon, 251, 257, 263, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
	else
		mon.SpiritResistance = const.MonsterImmune
	end
	if TxtMon.LightResistance < 10000 then 
		mon.LightResistance = math.max(TxtMon.LightResistance + elite_res_add + FixRandom(mon, 269, 271, 277, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
		if mon.Elite ~= 0 or mon.BoostType == const.Bolster.Style.Speed then
			mon.LightResistance = const.MonsterImmune
		end
	else
		mon.LightResistance = const.MonsterImmune
	end
	if TxtMon.DarkResistance < 10000 then 
		mon.DarkResistance = math.max(TxtMon.DarkResistance + elite_res_add + FixRandom(mon, 281, 283, 293, 11) + ArmorResAddbyBoost[mon.BoostType], 0)
		if mon.Elite ~= 0 or mon.BoostType == const.Bolster.Style.Speed then
			mon.DarkResistance = const.MonsterImmune
		end
	else
		mon.DarkResistance = const.MonsterImmune
	end

	mon.PhysResistance = TxtMon.PhysResistance + ArmorResAddbyBoost[mon.BoostType]
	--[[
	mon.WaterResistance = 500
	mon.PhysResistance = 500
	mon.FireResistance = 500
	mon.AirResistance = 500
	mon.EarthResistance = 500
	mon.MindResistance = 500
	mon.SpiritResistance = 500
	mon.LightResistance = 500
	mon.DarkResistance = 500
	mon.BodyResistance = 500
	mon.Velocity = 0
	]]--
	mon.BodyRadius = MonsterBodyRadius[mon.Id] or mon.BodyRadius
	mon.Bonus = TxtMon.Bonus
	mon.BonusMul = TxtMon.BonusMul
--	if mon.BodyRadius > 100 then
--		mon.BodyRadius = 100
--	end
end

local function CalcExtraDamage(Level)
	if Level <= 10 then
		return 0
	elseif Level <= 20 then
		return 10 * Level - 100
	else
		return 40 * Level - 700 
	end
end

local function PrepareTxtMon(i, PartyLevel, MapSettings, OnlyThis)

	if PartyLevel < 0 or MapSettings.Type == 0 then
		return
	end

	-- formulas variables
	local MonsterLevel,HP,BoostedHP,AC,MonsterHeight,MaxDamage,SpellSkill,SpellMastery,BolsterMul,MonsterPower,MonSettings,MoveSpeed
	--

	local BolStep, MonTable, MonKind
	local MonsSettings = Game.Bolster.Monsters
	local BolsterMul = Game.BolsterAmount/100
	local Formulas = Game.Bolster.Formulas

	local env = {
		max				= max,
		min				= min,
		ceil			= ceil,
		floor			= floor,
		sqrt			= sqrt,
		random			= random
		}

	local function ProcessFormula(Formula, Default)
		local f = Formula and assert(loadstring(Formula))

		if type(f) == "function" then
			env.PartyLevel 		= PartyLevel
			env.MonsterLevel 	= MonsterLevel
			env.HP				= HP
			env.BoostedHP 		= BoostedHP
			env.AC 				= AC
			env.MonsterHeight 	= MonsterHeight
			env.MaxDamage 		= MaxDamage
			env.SpellSkill		= SpellSkill
			env.SpellMastery 	= SpellMastery
			env.BolsterMul 		= BolsterMul
			env.MonsterPower 	= MonsterPower
			env.MonSettings 	= MonSettings
			env.MapSettings 	= MapSettings
			env.MoveSpeed		= MoveSpeed

			setfenv(f, env)
			return f()
		end
		return Default
	end
	
	local function GetMaxDamage(Attack)
		return Attack.DamageDiceCount*Attack.DamageDiceSides+Attack.DamageAdd
	end

	local function GetAvgLevel(mi)
		local mk = ceil(mi/3)
		local result = 0
		for p = 0, 2 do
			result = result + Game.MonstersTxt[mk*3-p].Level + MonsSettings[mk*3-p].LevelShift
		end
		return max(ceil(result/3), 3)
	end

	MonTable = {}

	if type(i) == "number" then
		MonKind = ceil(i/3)
		MonTable = OnlyThis and {[i] = Game.MonstersTxt[i]}
			or 	{	[MonKind*3-2] = Game.MonstersTxt[MonKind*3-2],
					[MonKind*3-1] = Game.MonstersTxt[MonKind*3-1],
					[MonKind*3  ] = Game.MonstersTxt[MonKind*3  ]}

	elseif type(i) == "table" then
		for k,v in pairs(i) do
			MonKind = ceil(v/3)
			MonTable[MonKind*3-2] = Game.MonstersTxt[MonKind*3-2]
			MonTable[MonKind*3-1] = Game.MonstersTxt[MonKind*3-1]
			MonTable[MonKind*3  ] = Game.MonstersTxt[MonKind*3  ]
		end
	else
		return
	end

	for k,v in pairs(MonTable) do
		if ReadyMons[k] then
			MonTable[k] = nil
		end
	end
	
	local function isTableNonEmpty(t)
		if t == nil or next(t) == nil then
			return false
		else
			return true
		end
	end

	local lv = MapLevel[Map.Name] or 1
	
	if mapvars.RefillCountAdded ~= true then
		if isTableNonEmpty(Map.Refilled) and Map.Refilled.RefillCount ~= nil then
			mapvars.RefillCount = Map.Refilled.RefillCount + 1
			--Map.Refilled.RefillCount = nil
		else
			if isTableNonEmpty(Map.Refilled) then
				mapvars.RefillCount = 1
			else
				mapvars.RefillCount = 0
			end
		end
	end
	mapvars.RefillCountAdded = true

	
	if vars.NoRefillAdd ~= true then
		lv = lv * (MapSettings.LevelShift + 50 * mapvars.RefillCount) / MapSettings.LevelShift
		--[[
		if mapvars.RefillCount == 0 then
			if MapSettings.LevelShift <= 30 then
				local mulrate = (-0.01622*MapSettings.LevelShift*MapSettings.LevelShift+1.38*MapSettings.LevelShift+3.198) / MapSettings.LevelShift
				lv = lv * (math.max(0, BolsterMul / 2 - 1) * (mulrate - 1) + 1)
			end
		end
		]]--
	end
	
	
	for monId, mon in pairs(MonTable) do

		MonKind 		= ceil(monId/3)
		HP 				= mon.FullHP
		BoostedHP		= mon.FullHP
		AC 				= mon.ArmorClass
		MonSettings		= MonsSettings[monId]
		MonsterHeight 	= Game.MonListBin[monId].Height
		MonsterPower	= monId - MonKind*3 + 3
		MonsterLevel	= GetAvgLevel(monId)
		BolStep 		= min(floor(PartyLevel/MonsterLevel), 4)
		local Style     = MonSettings.Style

		local Formula = Formulas[MonKind] or Formulas["def"]

		--local lvadd = math.sqrt(math.max(math.log(lv),0)) * 72
		local lvadd = 99.5 * math.log(lv * 2 / (lv + 1))

		MonBolStep[monId] = BolStep

		if MapSettings.Type ~= BolsterTypes.OriginalStats then

			-- Base hitpoints
			mon.FullHP = min(mon.FullHP * (1 + BolsterMul * 5.5) * HPMulByStyle[Style] * (lv + 1) * 0.5, 30000)
			BoostedHP  = mon.FullHP

			-- Armor class
			mon.ArmorClass = math.max(0, mon.ArmorClass + BolsterMul * 40 - 50) + lvadd
			
			-- Attacks
			MaxDamage = GetMaxDamage(mon.Attack1)
			MaxDamage = MaxDamage * BolsterAdjust(BolsterMul) * (0.99 ^ (BolsterMul * 60 - 80)) * DamageMulByStyle[Style] * lv
			SetAttackMaxDamage(mon.Attack1, MaxDamage)
			mon.Attack1.DamageAdd 		= BolsterMul * 60

			if mon.Attack2Chance > 0 then
				MaxDamage = GetMaxDamage(mon.Attack2)
				MaxDamage = MaxDamage * BolsterAdjust(BolsterMul) * (0.99 ^ (BolsterMul * 60 - 80)) * DamageMulByStyle[Style] * lv
				SetAttackMaxDamage(mon.Attack2, MaxDamage)
				mon.Attack2.DamageAdd 		= BolsterMul * 60
			end

			-- Base spells

			local Skill = mon.SpellChance + mon.Spell2Chance * 0.01
			
			mon.SpellSkill 		= JoinSkill(math.max(1,math.min(1000,Skill * MagicMulByStyle[Style] * lv)), SpMasMulByStyle[Style])
			mon.SpellChance		= min(mon.Level * 0.2 * SpRateMulByStyle[Style] ^ 3 * BolsterMul, 15 * SpRateMulByStyle[Style] ^ 2)

			mon.Spell2Skill 	= JoinSkill(math.max(1,math.min(1000,Skill * MagicMulByStyle[Style] * lv)), SpMasMulByStyle[Style])
			mon.Spell2Chance	= min(mon.Level * 0.2 * SpRateMulByStyle[Style] ^ 3 * BolsterMul, 25 * SpRateMulByStyle[Style] ^ 2)

			
		end

		-- Move speed

		MoveSpeed = mon.MoveSpeed
		mon.MoveSpeed = mon.MoveSpeed * (1 + BolsterMul * 0.1)
		if mon.Level < 20 then
			mon.MoveSpeed = mon.MoveSpeed * 1 * SpeedMulByStyle[Style]
		elseif mon.Level < 30 then
			mon.MoveSpeed = mon.MoveSpeed * math.min(1.5, 1 + BolsterMul * 0.25) * SpeedMulByStyle[Style]
		else
			mon.MoveSpeed = mon.MoveSpeed * math.min(2, 1 + BolsterMul * 0.5) * SpeedMulByStyle[Style]
		end
		
		-- Additional attacks
		--[[
		if mon.Attack2Chance == 0 and MonSettings.Ranged and BolStep > 0 then
			mon.Attack2Chance 			= min(BolStep*10, 35)
			mon.Attack2.Missile 		= BolStep > 2 and (MonSettings.Magic == 0 and 1 or 6) or 0
			mon.Attack2.Type 			= mon.Attack1.Type

			MaxDamage = GetMaxDamage(mon.Attack1)
			SetAttackMaxDamage(mon.Attack2, MaxDamage)
		end
		]]--
		-- Additional spells
		--[[
		if ProcessFormula(Formula["AllowNewSpell"], false) then

			local SkillByMas = {1,4,7,10}
			local Mas = Style == 3 and 2 or 1
			local Skill = SkillByMas[Mas]

			SpellSkill, SpellMastery = Skill, Mas
			Skill = ProcessFormula(Formula["SpellSkill"], SpellSkill)
			Mas   = ProcessFormula(Formula["SpellMastery"], SpellMastery)

			if mon.Spell == 0 and (BolStep >= 1 or MonSettings.Style == 3) then
				mon.SpellSkill = JoinSkill(Skill, Mas)
				mon.SpellChance = MonSettings.Style == 3 and 60 or 35
			end

			if mon.Spell2 == 0 and (BolStep >= 2 or (MonSettings.Style == 3 and BolStep >= 1)) then
				mon.Spell2Skill = JoinSkill(Skill, Mas)
				mon.Spell2Chance = MonSettings.Style == 3 and 35 or 20
			end

		end
		]]--
		--Resistances
		
		mon.Level = mon.Level * lv

		mon.FireResistance = CalcResistance(mon.FireResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.AirResistance = CalcResistance(mon.AirResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.WaterResistance = CalcResistance(mon.WaterResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.EarthResistance = CalcResistance(mon.EarthResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.BodyResistance = CalcResistance(mon.BodyResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.MindResistance = CalcResistance(mon.MindResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.SpiritResistance = CalcResistance(mon.SpiritResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.LightResistance = CalcResistance(mon.LightResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.DarkResistance = CalcResistance(mon.DarkResistance,BolsterMul) + lvadd + ArmorResAddbyStyle[Style]
		mon.PhysResistance = mon.PhysResistance + ArmorResAddbyStyle[Style]
		
		--Experience
		mon.Experience = mon.Level * mon.Level * 1.25

		-- Summons
		--[[
		if ProcessFormula(Formula["AllowReplicate"], false) then

			mon.Special = 4
			mon.SpecialA = 0
			mon.SpecialB = 0
			mon.SpecialC = 2
			mon.SpecialD = MonSettings.SummonId

		end

		if ProcessFormula(Formula["AllowSummons"], false) then

			mon.Special = 2
			mon.SpecialA = mon.MoveType == 5 and 0 or max((1 + BolStep),3) -- If monster always stands still, like Trees in The Tularean forest, he will behave like spawn point.
			mon.SpecialB = Game.MonstersTxt[MonSettings.SummonId].Fly == 1 and 0 or 1 -- if summon can fly he will be summoned in air.
			mon.SpecialC = 0
			mon.SpecialD = MonSettings.SummonId == 0 and monId or MonSettings.SummonId

		end
		]]--
		ReadyMons[monId] = true
		PQR = (PQR or 0) + 1
	end
	
end

function BolsterMonsters()

	vars.RandomSeed = vars.RandomSeed or math.random(1,32767)
	local MapSettings = Game.Bolster.Maps[Map.MapStatsIndex]
	if not MapSettings then
		return
	end

	local PartyLevel = GetOverallPartyLevel() + MapSettings.LevelShift
	local MapInTxt = Game.MapStats[Map.MapStatsIndex]
	local t = {}

	for i,v in Game.MonListBin do
		if 		string.find(v.Name, MapInTxt.Monster1Pic)
			or	string.find(v.Name, MapInTxt.Monster2Pic)
			or	string.find(v.Name, MapInTxt.Monster3Pic) then

			if not ReadyMons[i] then
				table.insert(t, i)
			end
		end
	end

	-- summons
	for i = 97, 99 do
		table.insert(t, i)
	end

	for i,v in Map.Monsters do
		if v.Id > 0 and v.Id < Game.MonstersTxt.Limit then
			table.insert(t, v.Id)
		else
			Log(Merge.Log.Error, "%s: Monster with incorrect Id (%s) at %s %s %s", Map.Name, v.Id, v.X, v.Y, v.Z)
			v.AIState = const.AIState.Removed
		end
	end

	PrepareTxtMon(t, PartyLevel, MapSettings, false)

	for i,v in Map.Monsters do
		if v.Id > 0 and v.Id < Game.MonstersTxt.Limit then
			PrepareMapMon(v)
		end
	end

end
Game.BolsterMonsters = BolsterMonsters

local function Init()

	ProcessBolsterTxt()
	Game.Bolster.ReloadTxt = ProcessBolsterTxt
	local StdSummonMonster = SummonMonster

	function SummonMonster(Id, ...)

		local mon, i = StdSummonMonster(Id, ...)
		if not mon then
			return
		end

		if not (Editor and Editor.WorkMode) then

			local MapSettings = Game.Bolster.Maps[Map.MapStatsIndex]
			if MapSettings then
				local PartyLevel = GetOverallPartyLevel() + MapSettings.LevelShift
				if not ReadyMons[Id] then
					PrepareTxtMon(Id, PartyLevel, MapSettings)
				end
				PrepareMapMon(mon)
			end

		end

		return mon, i
	end

	-- Set monster kind check

	function events.IsMonsterOfKind(t)
		local MonExtra = Game.Bolster.MonstersSource[t.Id]
		if t.Kind == MonExtra.Type or table.find(MonExtra.ExtraType, t.Kind) then
			t.Result = 1
		end
	end

	-- Boost summons

	mem.autohook2(0x44d4b1, function(d)
		if not ReadyMons[d.esi] then
			local MapSettings = Game.Bolster.Maps[Map.MapStatsIndex]
			if MapSettings then
				local PartyLevel = GetOverallPartyLevel() + MapSettings.LevelShift

				for i = d.esi, d.esi+2 do
					if not ReadyMons[i] then
						PrepareTxtMon(i, PartyLevel, MapSettings)
					end
				end
			end
		end
	end)

	-- Arena monsters generation
	local ArenaMonstersList, ArenaPartyLevel, ArenaMapSettings
	function events.BeforeArenaStart(ArenaLevel)
		if PartyLevelBaseSaved then
			for i,v in Party do
				v.LevelBase = PartyLevelBaseSaved[i]
			end
		end
		local PartyLevel = GetOverallPartyLevel()

		local MinLevel, MaxLevel
		if ArenaLevel == 0 then
			MinLevel = 0
			MaxLevel = max(PartyLevel/4, 10)
		elseif ArenaLevel == 1 then
			MinLevel = min(ceil(PartyLevel/5), 70)
			MaxLevel = max(ceil(PartyLevel/3), 10) + 5
		elseif ArenaLevel == 2 then
			MinLevel = min(ceil(PartyLevel/3), 70)
			MaxLevel = max(ceil(PartyLevel/2), 10) + 7
		elseif ArenaLevel == 3 then
			MinLevel = min(ceil(PartyLevel/2), 70)
			MaxLevel = max(PartyLevel, 10) + 10
		end

		local MinKind, MaxKind
		if ArenaLevel == 0 then
			MinKind, MaxKind = 1,1
		elseif ArenaLevel == 1 then
			MinKind, MaxKind = 1,2
		elseif ArenaLevel == 2 then
			MinKind, MaxKind = 2,3
		elseif ArenaLevel == 3 then
			MinKind, MaxKind = 3,3
		end

		local MonstersTxt = Game.MonstersTxt
		local List, Kind, MonLevel = {}, nil, nil
		for i = 1, Game.MonstersTxt.count-1 do
			Kind = 3 - i % 3
			if not (Kind < MinKind or Kind > MaxKind) then
				MonLevel = MonstersTxt[i].Level
				if not (MonLevel < MinLevel or MonLevel > MaxLevel) and Game.IsMonsterOfKind(i, const.MonsterKind.NoArena) == 0 then
					table.insert(List, i)
				end
			end
		end

		ArenaPartyLevel = PartyLevel
		ArenaMonstersList = List
		ArenaMapSettings = Game.Bolster.Maps[Map.MapStatsIndex]

		Sleep(1)
		for i,v in Party do
			v.HP = v:GetFullHP()
			v.SP = v:GetFullSP()
		end
	end

	function events.GenerateArenaMonster(t)
		local MonId = ArenaMonstersList[random(#ArenaMonstersList)]

		t.Handled = true
		t.MonId = MonId

		if ArenaMapSettings and not ReadyMons[MonId] then
			PrepareTxtMon(MonId, ArenaPartyLevel, ArenaMapSettings, true)
			BolsterMonsters()
		end
	end

	-- Add player's armor class penalty depending on enemy's bolster
	local NewCode = mem.asmpatch(0x48db2f, [[
	add esi, eax
	cmp dword[ds:0x4F37D8], 0; Check current screen
	jnz @std

	mov edx, dword [ds:ebp-0x4c]
	cmp edx, 0
	jl @std
	cmp edx, dword [ds:0x692FB0];
	jge @std

	nop; mem hook
	nop
	nop
	nop
	nop

	xor edx, edx
	@std:
	cmp esi, 0x1]])

	local pptr, psize = Party.PlayersArray["?ptr"], Party.PlayersArray[0]["?size"]
	local function GetPlayer(ptr)
		local PlayerId = (ptr - pptr)/psize
		return Party.PlayersArray[PlayerId], PlayerId
	end

	mem.hook(NewCode + 28, function(d)
		local monId = Map.Monsters[d.edx].Id
		d.esi = d.esi
		local t = {MapMonId = d.edx, AC = d.esi, Player = GetPlayer(d.edi)}
		events.call("GetArmorClass", t)
		d.esi = t.AC
	end)

end

function events.AfterLoadMap()
	if LoadTimes == nil then
		LoadTimes = vars.LoadTimes or 0
	end
	vars.LoadTimes = math.max(LoadTimes + 1, (vars.LoadTimes or 0) + 1)
	LoadTimes = vars.LoadTimes
	for _, pl in Party do
		for i, val in pl.Skills do
			if i==const.Skills.IdentifyMonster then
				local skill, mastery = SplitSkill(val)
				pl.Skills[i] = JoinSkill(60,  const.GM)
			end
		end
	end

	if Game.Map.Name == "zarena.blv" or Game.Map.Name == "d42.blv" or Game.Map.Name == "7d05.blv" then
		if not PartyLevelBaseSaved then
			PartyLevelBaseSaved = {}
			for i,v in Party do
				PartyLevelBaseSaved[i] = v.LevelBase
				v.LevelBase = 0
			end
		end
	else
		if PartyLevelBaseSaved then
			for i,v in Party do
				v.LevelBase = PartyLevelBaseSaved[i]
			end
		end
		PartyLevelBaseSaved = nil
	end

	--[[
	if Game.Map.Name == "cd1.blv" then
		if not vars.AlamosCreatedMonster or vars.AlamosCreatedMonster == false then
			--evt.SummonMonsters(1,3,1,-8350,3738,333)
			evt.SummonMonsters(1,3,1,-3584,2527,225)
			evt.SummonMonsters(1,3,1,-3584,2135,225)
			evt.SummonMonsters(1,3,1,-3276,1675,225)
			evt.SummonMonsters(1,3,1,-2861,1675,225)
			vars.AlamosCreatedMonster = true
		end
	end
	if Game.Map.Name == "7d23.blv" then
		if not vars.LincoinCreatedMonster or vars.LincoinCreatedMonster == false then
			evt.SummonMonsters(1,3,1,3335,-9450,1549)
			evt.SummonMonsters(1,3,1,4434,-9650,1549)
			evt.SummonMonsters(1,3,1,5410,-9450,1549)
			vars.LincoinCreatedMonster = true
		end
	end
	]]--
	if mapvars.expand == nil then
		mapvars.expand = {}
	end
	if vars.PartyResistanceDecrease == nil then
		vars.PartyResistanceDecrease = {}
		vars.PartyResistanceDecrease.Power = 0
		vars.PartyResistanceDecrease.ExpireTime = 0
	end
	if vars.PartyArmorDecrease == nil then
		vars.PartyArmorDecrease = {}
		vars.PartyArmorDecrease.Power = 0
		vars.PartyArmorDecrease.ExpireTime = 0
	end
	
	if Editor and Editor.WorkMode then
		return
	end

	LocalMonstersTxt()
	ReadyMons	= {}
	MonBolStep	= {}

	BolsterMonsters()
end

function events.MonsterKilled(mon)
	if mon.Id == 647 or mon.Id == 648 then
		if evt.ForPlayer("All").Cmp{"Inventory", 2164} then
			evt.SummonMonsters(2, 3, 1, 4352, 20096, -2256)
			evt.SummonMonsters(2, 3, 1, 6016, 21504, -2256)
			evt.SummonMonsters(2, 3, 1, 2816, 22016, -2256)
			evt.SummonMonsters(1, 3, 1, 4352, 24704, -2256)
			evt.SummonMonsters(1, 3, 1, 2944, 23552, -2256)
			evt.SummonMonsters(1, 3, 1, 6144, 23424, -2256)
			evt.SummonMonsters(2, 3, 1, 2688, 19840, -2256)
			evt.SummonMonsters(2, 3, 1, 1920, 21760, -2256)
			evt.SummonMonsters(2, 3, 1, 6144, 19840, -2256)
			evt.SummonMonsters(2, 3, 1, 7168, 21760, -2256)
			evt.SummonMonsters(2, 3, 1, 2584, 25728, -2256)
			evt.SummonMonsters(1, 3, 1, 5248, 25728, -2256)
			evt.SummonMonsters(1, 3, 1, 1792, 23168, -2256)
			evt.SummonMonsters(1, 3, 1, 2688, 25216, -2256)
			evt.SummonMonsters(1, 3, 1, 7296, 23040, -2256)
			evt.SummonMonsters(1, 3, 1, 6144, 25088, -2256)
			BolsterMonsters()
		end

	end
end

function events.GameInitialized2()
	Init()
end

Game.MinMeleeRecoveryTime = 15
