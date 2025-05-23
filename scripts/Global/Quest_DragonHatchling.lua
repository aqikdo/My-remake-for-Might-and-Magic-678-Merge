
-- New NPC texts used: 1685, 1686, 1687, 1688

vars.Quest_DragonHatchling = vars.Quest_DragonHatchling or {}

local QSet = vars.Quest_DragonHatchling
local DragonNPC = 396

-- Refresh NPC's name.
function events.LoadMap(WasInGame)
	if not WasInGame and QSet.NameChosen then
		Game.NPC[DragonNPC].Name = QSet.DragonName
	end
end

-- Override dismiss behaivor for hatchling - put him into NPCFollowers, don't send to Adventurer's Inn.
function AfterDismissDragon(PlayerId)
	local CharId = Party.PlayersIndexes[PlayerId]
	if CharId == QSet.DragonRosterId then
		Party.QBits[CharId + 400] = false
		while not Party.QBits[CharId + 400] do -- let original function to set flags.
			Sleep(10)
		end
		NPCFollowers.Add(DragonNPC)
		Party.QBits[CharId + 400] = false
		vars.MercenariesProps[CharId].CurContinent = -1
	end
end

function events.DismissCharacter(t)
	coroutine.resume(coroutine.create(AfterDismissDragon), t.PlayerId)
end

-- Create Dragon player upon first hiring.
local function MakeDragonChar()
	local cHave, cNPC, cRosterId = NPCFollowers.HaveFreeMerc()
	if cHave then
		local Char = Party.PlayersArray[cRosterId]
		QSet.DragonRosterId = cRosterId
		GenerateMercenary{RosterId = cRosterId, Class = const.Class.Dragon,
				Level = 1, Items = {}, Face = 71,
				Skills = {[const.Skills.DragonAbility] = 1, [const.Skills.Learning] = 1}}
		Char.Name = Game.NPC[DragonNPC].Name
		Char.Attrs.Race = const.Race.Dragon
		Char.BirthYear = Game.Year - 1
		GenerateBiography(Char)

		vars.MercenariesProps[cRosterId] = {LastRefill = 0, CurContinent = -1, Hired = true}
	end
	return cHave
end

-- Feed Dragon
NPCTopic{
	NPC = DragonNPC,
	Branch = "",
	Slot = 0,
	Topic = Game.NPCText[1692], -- "Feed dragon"
	CanShow = function()
		return not QSet.DragonGrown
	end,
	Ungive = function()
		if QSet.DragonGrown then
			Message(Game.NPCText[1684])
			return
		end

		QSet.FirstFeed = QSet.FirstFeed or Game.Time
		QSet.FoodEaten = QSet.FoodEaten or 0
		if QSet.FoodEaten >= 100 then
			if Game.Time - QSet.FirstFeed > const.Month then
				QSet.DragonGrown = true
				Game.NPC[DragonNPC].Pic = Game.CharacterPortraits[71].NPCPic
				Message(Game.NPCText[1689]) -- "Dragon grown"
			else
				Message(Game.NPCText[1684]) -- "Dragon ate enough"
			end
		elseif Party.Food >= 5 then
			Party.Food = Party.Food - 5
			QSet.FoodEaten = QSet.FoodEaten + 5
			evt.PlaySound{205} -- error sound
		else
			evt.PlaySound{27} -- error sound
		end
	end}

-- Choose Dragon's name.
NPCTopic{
	NPC = DragonNPC,
	Branch = "",
	Slot = 0,
	Topic = Game.NPCTopic[789],
	CanShow = function()
		return QSet.DragonGrown and not QSet.NameChosen
	end,
	Ungive = function()
		local Name = Question(Game.NPCText[1685])
		if Name and string.len(Name) > 0 then
			local Answer = Question(string.format(Game.NPCText[1686], Name))
			if string.lower(Answer) == "y" then
				Game.NPC[DragonNPC].Name = Name
				QSet.DragonName = Name
				QSet.NameChosen = true
			end
		end
	end}

-- Move Dragon to Party.
NPCTopic{
	NPC = DragonNPC,
	Branch = "",
	Slot = 0,
	Topic =  Game.NPCTopic[616],
	CanShow = function()
		return QSet.DragonGrown and QSet.NameChosen
	end,
	Ungive = function()
		if not QSet.DragonRosterId and not MakeDragonChar() then
			Message(Game.NPCText[1687])
			return
		end
		if Party.count >= 5 then
			Message(Game.NPCText[1688])
			return
		end
		HireCharacter(QSet.DragonRosterId)
		NPCFollowers.Remove(DragonNPC)
		Sleep(100, 100)
		if Game.CurrentScreen == 4 then
			ExitCurrentScreen()
		end
	end}

-- Restore the original functionality of the dragon familiar as long as
-- he's sitting in the hireling slot.

function events.GetSkill(t)
    if  Game.NPC[DragonNPC].Hired
		and Game.ClassesExtra[t.Player.Class].Kind == 5 -- Druid class line
        and const.Skills.Fire <= t.Skill
        and t.Skill < const.Skills.Light
    then
        local s, m = SplitSkill(t.Result)
        t.Result = JoinSkill(s + 3, m)
    end
end

function events.RegenTick(Player)
    if Game.NPC[DragonNPC].Hired
		and Game.ClassesExtra[Player.Class].Kind == 5 -- Druid class line
    then
        Player.SP = math.min(Player:GetFullSP(), Player.SP + 1)
    end
end

