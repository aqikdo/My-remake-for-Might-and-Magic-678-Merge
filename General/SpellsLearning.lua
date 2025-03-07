local LogId = "SpellsLearning"
Log(Merge.Log.Info, "Init started: %s", LogId)
local MT = Merge.Tables

local floor = math.floor
local max_spell = 99

local function ProcessSpellsLearningTxt()
	local spells_learning_tbl = {}
	local TableFile = "Data/Tables/SpellsLearning.txt"
	local null_tbl = {Mastery = 0, Level = 0}
	local masteries = {B = 1, E = 2, M = 3, G = 4}

	local TxtTable = io.open(TableFile, "r")
	if not TxtTable then
		TxtTable = io.open(TableFile, "w")
		TxtTable:write("#\9Note")
		for i = 1, max_spell do
			TxtTable:write("\9" .. i .. " " .. Game.SpellsTxt[i].ShortName)
		end
		TxtTable:write("\n")
		for k = 0, Game.ClassNames.count - 1 do
			TxtTable:write(k .. "\9" .. Game.ClassNames[k])
			for i = 1, max_spell do
				local skill = floor((i - 1) / 11) + 12
				local spell_mastery = (i - 1) % 11
				if spell_mastery == 10 then
					spell_mastery = 4
				elseif spell_mastery > 6 then
					spell_mastery = 3
				elseif spell_mastery > 3 then
					spell_mastery = 2
				else
					spell_mastery = 1
				end
				local class_mastery = Game.Classes.Skills[k][skill]
				spells_learning_tbl[k] = spells_learning_tbl[k] or {}
				if class_mastery > 0 and class_mastery >= spell_mastery - 1 then
					TxtTable:write("\9" .. select(spell_mastery, "B1", "E1", "M4", "G7"))
					spells_learning_tbl[k][i] = {
						Mastery = spell_mastery,
						Level = select(spell_mastery, 1, 4, 7, 10)
					}
				else
					TxtTable:write("\9-")
					spells_learning_tbl[k][i] = null_tbl
				end
			end
			TxtTable:write("\n")
		end
	else
		local iter = TxtTable:lines()
		iter()	-- skip header
		for line in iter do
			local words = string.split(line, "\9")
			if string.len(words[1]) == 0 then
				break
			end
			if (#words >= max_spell + 2) and tonumber(words[1]) then
				local cur_class = tonumber(words[1])
				spells_learning_tbl[cur_class] = spells_learning_tbl[cur_class] or {}
				for i = 1, max_spell do
					if words[i+2] == "-" or words[i+2] == "0" then
						spells_learning_tbl[cur_class][i] = null_tbl
					else
						local mastery, level = words[i+2]:match("^([BEMG])(%d+)")
						mastery = masteries[mastery]
						level = tonumber(level)
						spells_learning_tbl[cur_class][i] = {
							Mastery = mastery, Level = level
						}
					end
				end
			end
		end
	end
	io.close(TxtTable)
	MT.SpellsLearning = spells_learning_tbl
end

function events.GameInitialized2()
	ProcessSpellsLearningTxt()
end

function events.CanPlayerLearnSpell(t)
	if t.SpellId > max_spell then
		return
	end
	local cur_class = t.Player.Class
	if MT.SpellsLearning[cur_class] and MT.SpellsLearning[cur_class][t.SpellId] then
		local plevel, pmastery = SplitSkill(t.Player:GetSkill(floor((t.SpellId - 1) / 11) + 12))
		local level = MT.SpellsLearning[cur_class][t.SpellId].Level
		local mastery = MT.SpellsLearning[cur_class][t.SpellId].Mastery
		if level == 0 or mastery == 0 then
			t.Level = 0
		else
			if plevel >= level and pmastery >= mastery then
				t.Level = 11
			else
				t.Level = 0
			end
		end
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)

