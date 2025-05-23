
-- Script simply replaces text fields of tables with ones from "LocalizeTables.txt".
-- Sacrificing a bit of perfomance for a lot of conviniency of work with localizations.

local function _RelocalizeTables(PathMask)

	for FilePath in path.find(PathMask) do

		local TxtTable = io.open(FilePath, "r")

		if TxtTable then

			local Words
			local LineIt = TxtTable:lines()
			LineIt() -- skip header

			if string.find(FilePath, "ItemsTxt") then
				-- special behaivor for ItemsTxt
				local Items = Game.ItemsTxt
				for line in LineIt do
					Words = string.split(line, "\9")
					local Num = tonumber(Words[1])
					if Num and Num < 2200 then
						local Item = Items[Num]
						Item.Name 				= Words[2]
						Item.NotIdentifiedName	= Words[3]
						Item.Notes				= Words[4]
					end
				end
			elseif string.find(FilePath, "Race") then
				local Race = Game.Races
				for line in LineIt do
					Words = string.split(line, "\9")
					local Num = tonumber(Words[1])
					if Num then
						Race[Num].StringId = Words[2]
						Race[Num].Name = Words[3]
						Race[Num].Plural = Words[4]
						Race[Num].Adj = Words[5]
					end
				end
			elseif string.find(FilePath, "2DEvents") then
				-- special behaivor for 2DEvents
				local Houses = Game.Houses
				for line in LineIt do
					Words = string.split(line, "\9")
					local Num = tonumber(Words[1])
					if Num then
						local House = Houses[Num]
						House.Name = Words[2]
						House.OwnerName	= Words[3]
						House.OwnerTitle = Words[4]
						House.EnterText = Words[5]
					end
				end
			elseif string.find(FilePath, "NPCNames") then
				-- special behaivor for NPCNames
				local NPCNames = Game.NPCNames
				NPCNames.M = {}
				NPCNames.F = {}
				for line in LineIt do
					Words = string.split(line, "\9")
					if Words[1] and string.len(Words[1]) > 0 then
						table.insert(NPCNames["M"], Words[1])
					end
					if Words[2] and string.len(Words[2]) > 0 then
						table.insert(NPCNames["F"], Words[2])
					end
				end
			else
				local len = string.len
				local LastTable = ""
				for line in LineIt do
					Words = string.split(line, "\9")
					if Words[1] then
						local cTable	= Words[1] or ""
						local cId		= tonumber(Words[2])
						local cField	= Words[3] or ""
						local cText		= tonumber(Words[4]) or Words[4] or ""

						if len(cTable) > 0 and Game[cTable] then
							LastTable = cTable
						else
							cTable = LastTable
						end

						if len(cTable) > 0 and cId then
							if len(cField) > 0 then
								Game[cTable][cId][cField] = cText
							else
								Game[cTable][cId] = cText
							end
						end
					end
				end
			end

			io.close(TxtTable)
		end
	end

end

local function CheckLocalization()
	local ErrorStr = {}
	local tinsert = table.insert
	if Game.PlaceMonTxt.count < 161 then
		tinsert(ErrorStr, "Placemon.txt: target lines count - 161, actual lines count - " .. Game.PlaceMonTxt.count)
	end

	if #ErrorStr > 0 then
		tinsert(ErrorStr, 1, "Localization files are out of date and may cause errors.")
		tinsert(ErrorStr, 2, "Download new files from https://www.celestialheavens.com/forum/10/16657 .")
		debug.ErrorMessage(table.concat(ErrorStr, "\n"))
	end
end

function RelocalizeTables()
	_RelocalizeTables("Data/*LocalizeTables.*txt")
	_RelocalizeTables("Data/Text localization/*.txt")
end

function events.ScriptsLoaded() -- declare localization event last
	events.GameInitialized2 = RelocalizeTables
	events.GameInitialized2 = CheckLocalization
end
