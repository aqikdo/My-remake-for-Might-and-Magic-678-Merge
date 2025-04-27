-- Class Promotions Table
local LogId = "Promotions"
Log(Merge.Log.Info, "Init started: %s", LogId)
local MT = Merge.Tables

local strlen = string.len

local function ProcessPromotionsTxt()
	local promotions, promotions_inv = {}, {}
	local TableFile = "Data/Tables/Promotions.txt"
	local header = "# Class\9Note\9Promotions"

	local TxtTable = io.open(TableFile, "r")
	if not TxtTable then
		Log(Merge.Log.Warning, "No Promotions.txt found, creating one.")
		TxtTable = io.open(TableFile, "w")
		TxtTable:write(header .. "\n")

		promotions[const.Class.Archer] = {const.Class.WarriorMage}
		promotions[const.Class.WarriorMage] = {const.Class.MasterArcher, const.Class.Sniper}
		promotions[const.Class.Cleric] = {const.Class.Priest}
		promotions[const.Class.Priest] = {
			const.Class.HighPriest, const.Class.PriestLight, const.Class.PriestDark
		}
		promotions[const.Class.ClericLight] = {const.Class.HighPriest, const.Class.PriestLight}
		promotions[const.Class.ClericDark] = {const.Class.HighPriest, const.Class.PriestDark}
		promotions[const.Class.Deerslayer] = {const.Class.Pioneer}
		promotions[const.Class.Pioneeer] = {const.Class.Pathfinder}
		promotions[const.Class.Dragon] = {const.Class.FlightLeader}
		promotions[const.Class.FlightLeader] = {const.Class.GreatWyrm}
		promotions[const.Class.Druid] = {const.Class.GreatDruid}
		promotions[const.Class.GreatDruid] = {const.Class.ArchDruid, const.Class.Warlock}
		promotions[const.Class.Knight] = {const.Class.Cavalier}
		promotions[const.Class.Cavalier] = {const.Class.Champion, const.Class.BlackKnight}
		promotions[const.Class.Minotaur] = {const.Class.MinotaurHeadsman}
		promotions[const.Class.MinotaurHeadsman] = {const.Class.MinotaurLord}
		promotions[const.Class.Monk] = {const.Class.Initiate}
		promotions[const.Class.Initiate] = {const.Class.Master, const.Class.Ninja}
		promotions[const.Class.Paladin] = {const.Class.Crusader}
		promotions[const.Class.Crusader] = {const.Class.Hero, const.Class.Villain}
		promotions[const.Class.Ranger] = {const.Class.Hunter}
		promotions[const.Class.Hunter] = {const.Class.RangerLord, const.Class.BountyHunter}
		promotions[const.Class.Thief] = {const.Class.Rogue}
		promotions[const.Class.Rogue] = {const.Class.Spy, const.Class.Assassin}
		promotions[const.Class.Berserker] = {const.Class.Warmonger}
		promotions[const.Class.Vampire] = {const.Class.ElderVampire}
		promotions[const.Class.ElderVampire] = {const.Class.Nosferatu}
		promotions[const.Class.Sorcerer] = {const.Class.Wizard, const.Class.Necromancer}
		promotions[const.Class.Wizard] = {
			const.Class.MasterWizard, const.Class.ArchMage, const.Class.MasterNecromancer
		}
		promotions[const.Class.Necromancer] = {const.Class.MasterWizard, const.Class.MasterNecromancer}

		for class = 0, Game.ClassNames.count - 1 do
			if promotions[class] then
				TxtTable:write(class .. "\9" .. Game.ClassNames[class])
				for _, dest in pairs(promotions[class]) do
					TxtTable:write("\9" .. dest)
				end
				TxtTable:write("\n")
			end
		end
	else
		local LineIt = TxtTable:lines()
		if LineIt() ~= header then
			Log(Merge.Log.Error, "Promotions.txt header differs from expected one, table is ignored. Regenerate or fix it.")
		else
			local line_num = 1
			for line in LineIt do
				line_num = line_num + 1
				local words = string.split(line, "\9")
				if strlen(words[1]) == 0 then
					Log(Merge.Log.Warning,
						"Promotions.txt line %d first field is empty. Skipping following lines.",
						line_num)
					break
				end
				-- Ignore lines that don't start with number
				if words[1] and tonumber(words[1]) then
					-- TODO: check for already present table
					local source = tonumber(words[1])
					promotions[source] = {}
					for i = 2, #words do
						local dest = tonumber(words[i])
						if dest then
							table.insert(promotions[source], dest)
						end
						-- TODO: add a warning if field isn't a number
					end
				else
					Log(Merge.Log.Warning,
						"Promotions.txt line %d first field is not a number. Ignoring line.",
						line_num)
				end
			end
		end
	end
	io.close(TxtTable)
	for source, dest_t in pairs(promotions) do
		for _, dest in pairs(dest_t) do
			promotions_inv[dest] = promotions_inv[dest] or {}
			table.insert(promotions_inv[dest], source)
		end
	end
	MT.ClassPromotions = promotions
	MT.ClassPromotionsInv = promotions_inv
end

function events.GameInitialized2()
	ProcessPromotionsTxt()
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
