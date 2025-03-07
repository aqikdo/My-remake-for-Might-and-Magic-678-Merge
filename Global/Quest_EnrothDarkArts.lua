-- Allow some classes to swap their alligment at Enroth:
-- Priest of Light to Priest of Dark; Archmage to Master Necromancer; Hero to Villain, Master Archer to Sniper.
local LogId = "EnrothDarkArts"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM = Merge.Functions, Merge.ModSettings

----------------------
---- LOCALIZATION ----

local TXT = {

PathOfLight = Game.NPCText[2102], --"Path of Light",
PathOfDark  = Game.NPCText[2103], --"Path of Dark",

WarningLight = Game.NPCText[2104], --"Are you sure, you want to change your path? Dark spells will be vanished from your spellbook and dark magic will be erased from your mind. (Yes/No)",
WarningDark  = Game.NPCText[2105], --"Are you sure, you want to change your path? Light spells will be vanished from your spellbook and light magic will be erased from your mind. (Yes/No)",

AdvertLight = Game.NPCText[2106], --"It is never late to turn back to light, child. Choose light side.",
AdvertDark  = Game.NPCText[2107], --"Darkness wait and it's patience is eternal. Choose dark side.",

Yes = Game.NPCText[2108], --"yes",

Std = Game.NPCText[2109], --"Either you've already choosen your path, or you are not ready to do it."

path_neutral = Game.NPCText[2780],	-- "Path of Neutrality"
warning_neutral = Game.NPCText[2781]	-- "Are you sure you want to follow the Path of Neutrality? All Dark and Light spells unavailable for Neutral Path will disappear from your spellbook."
}
---- LOCALIZATION ----
----------------------

local LastClick = 0

local CC = const.Class

local DarkPromTable = {
	[CC.BattleMage] = CC.Sniper,
	[CC.MasterArcher] = CC.Sniper,
	[CC.HighPriest] = CC.PriestDark,
	[CC.PriestLight] = CC.PriestDark,
	[CC.MasterDruid] = CC.Warlock,
	[CC.ArchDruid] = CC.Warlock,
	[CC.Champion] = CC.BlackKnight,
	[CC.Templar] = CC.BlackKnight,
	[CC.Justiciar] = CC.Villain,
	[CC.Hero] = CC.Villain,
	[CC.MasterWizard] = CC.MasterNecromancer,
	[CC.ArchMage] = CC.MasterNecromancer
}

local LightPromTable = {
	[CC.BattleMage] = CC.MasterArcher,
	[CC.Sniper] = CC.MasterArcher,
	[CC.HighPriest] = CC.PriestLight,
	[CC.PriestDark] = CC.PriestLight,
	[CC.MasterDruid] = CC.ArchDruid,
	[CC.Warlock] = CC.ArchDruid,
	[CC.Champion] = CC.Templar,
	[CC.BlackKnight] = CC.Templar,
	[CC.Justiciar] = CC.Hero,
	[CC.Villain] = CC.Hero,
	[CC.MasterWizard] = CC.ArchMage,
	[CC.MasterNecromancer] = CC.ArchMage
}

local neutral_promo_table = {
	[CC.MasterArcher] = CC.BattleMage,
	[CC.Sniper] = CC.BattleMage,
	[CC.PriestLight] = CC.HighPriest,
	[CC.PriestDark] = CC.HighPriest,
	[CC.ArchDruid] = CC.MasterDruid,
	[CC.Warlock] = CC.MasterDruid,
	[CC.Templar] = CC.Champion,
	[CC.BlackKnight] = CC.Champion,
	[CC.Hero] = CC.Justiciar,
	[CC.Villain] = CC.Justiciar,
	[CC.ArchMage] = CC.MasterWizard,
	[CC.MasterNecromancer] = CC.MasterWizard
}
if MM.MM6ConvertCleric and MM.MM6ConvertCleric == 1 then
	neutral_promo_table[CC.AcolyteLight] = CC.Cleric
	neutral_promo_table[CC.AcolyteDark] = CC.Cleric
	LightPromTable[CC.Cleric] = CC.AcolyteLight
	LightPromTable[CC.AcolyteDark] = CC.AcolyteLight
	DarkPromTable[CC.Cleric] = CC.AcolyteDark
	DarkPromTable[CC.AcolyteLight] = CC.AcolyteDark
end
if MM.MM6ConvertPriest and MM.MM6ConvertPriest == 1 then
	neutral_promo_table[CC.ClericLight] = CC.Priest
	neutral_promo_table[CC.ClericDark] = CC.Priest
	LightPromTable[CC.Priest] = CC.ClericLight
	LightPromTable[CC.ClericDark] = CC.ClericLight
	DarkPromTable[CC.Priest] = CC.ClericDark
	DarkPromTable[CC.ClericLight] = CC.ClericDark
end
if MM.MM6ConvertSorcerer and MM.MM6ConvertSorcerer == 1 then
	neutral_promo_table[CC.ApprenticeMage] = CC.Sorcerer
	neutral_promo_table[CC.DarkAdept] = CC.Sorcerer
	LightPromTable[CC.Sorcerer] = CC.ApprenticeMage
	LightPromTable[CC.DarkAdept] = CC.ApprenticeMage
	DarkPromTable[CC.Sorcerer] = CC.DarkAdept
	DarkPromTable[CC.ApprenticeMage] = CC.DarkAdept
end
if MM.MM6ConvertWizard and MM.MM6ConvertWizard == 1 then
	neutral_promo_table[CC.Mage] = CC.Wizard
	neutral_promo_table[CC.Necromancer] = CC.Wizard
	LightPromTable[CC.Wizard] = CC.Mage
	LightPromTable[CC.Necromancer] = CC.Mage
	DarkPromTable[CC.Wizard] = CC.Necromancer
	DarkPromTable[CC.Mage] = CC.Necromancer
end

local function SwapAllignmentDark()

	local CurPl = math.max(Game.CurrentPlayer, 0)
	local v = Party[CurPl]
	local PromClass = DarkPromTable[v.Class]

	if PromClass and LastClick + 2 > os.time() then
		local Answer = Question(TXT.WarningDark)

		if string.lower(Answer) == TXT.Yes then
			v.Skills[const.Skills.Dark] = math.max(v.Skills[const.Skills.Dark], v.Skills[const.Skills.Light])
			v.Skills[const.Skills.Light] = 0
			for i = 78, 88 do
				v.Spells[i] = false
			end

			v.Class = PromClass
			evt[CurPl].Add{"Experience", 0}
			v:ShowFaceAnimation(71)
		else
			v:ShowFaceAnimation(67)
		end
	else
		if PromClass then
			Message(TXT.AdvertDark)
		else
			Message(TXT.Std)
		end
	end
	LastClick = os.time()

end

local function SwapAllignmentLight()

	local CurPl = math.max(Game.CurrentPlayer, 0)
	local v = Party[CurPl]
	local PromClass = LightPromTable[v.Class]

	if PromClass and LastClick + 2 > os.time() then
		local Answer = Question(TXT.WarningLight)

		if string.lower(Answer) == TXT.Yes then
			v.Skills[const.Skills.Light] = math.max(v.Skills[const.Skills.Dark], v.Skills[const.Skills.Light])
			v.Skills[const.Skills.Dark] = 0
			for i = 89, 99 do
				v.Spells[i] = false
			end

			v.Class = PromClass
			evt[CurPl].Add{"Experience", 0}
			v:ShowFaceAnimation(71)
		else
			v:ShowFaceAnimation(67)
		end
	else
		if PromClass then
			Message(TXT.AdvertLight)
		else
			Message(TXT.Std)
		end

	end
	LastClick = os.time()

end

local function change_alignment_neutral()
	local slot = MF.GetCurrentPlayer() or 0
	local player = Party[slot]
	local to_class = neutral_promo_table[player.Class]
	if to_class then
		MF.ConvertCharacter({Player = player, ToClass = to_class})
		MF.ShowAwardAnimation(71)
	else
		Message(TXT.Std)
		player:ShowFaceAnimation(67)
	end
end

-- Path of Dark topic

NPCTopic{
	Topic = TXT.PathOfDark,
	NPC = 1040,
	Slot = 4,
	Branch = "",
	Ungive = SwapAllignmentDark
}

NPCTopic{
	Topic = TXT.PathOfDark,
	NPC = 1030,
	Slot = 4,
	Branch = "",
	Ungive = SwapAllignmentDark
}

-- Path of Light topic

NPCTopic{
	Topic = TXT.PathOfLight,
	NPC = 1057,
	Slot = 4,
	Branch = "",
	Ungive = SwapAllignmentLight
}

NPCTopic{
	Topic = TXT.PathOfLight,
	NPC = 1031,
	Slot = 4,
	Branch = "",
	Ungive = SwapAllignmentLight
}

NPCTopic{
	Topic = TXT.PathOfLight,
	NPC = 795,
	Slot = 4,
	Branch = "",
	Ungive = SwapAllignmentLight
}

QuestNPC = 978	-- Sharry Carnegie
Quest{
	Name = "SharryPath",
	Branch = "",
	Slot = 2,
	CanShow = function() return Party.QBits[1284] end,
	Ungive = function() QuestBranch("path") end,
	Texts = {
		Topic = TXT.path_neutral,
		Ungive = TXT.warning_neutral
	}
}
Quest{
	Name = "SharryPathY",
	Branch = "path",
	Slot = 0,
	Ungive = function()
		change_alignment_neutral()
		QuestBranch("")
	end,
	Texts = {
		Topic = Game.GlobalTxt[704]	-- "Yes"
	}
}
Quest{
	Name = "SharryPathN",
	Branch = "path",
	Slot = 1,
	Ungive = function() QuestBranch("") end,
	Texts = {
		Topic = Game.GlobalTxt[705]	-- "No"
	}
}

Log(Merge.Log.Info, "Init finished: %s", LogId)

