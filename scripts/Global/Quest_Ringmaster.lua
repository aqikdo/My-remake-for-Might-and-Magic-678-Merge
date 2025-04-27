local MF = Merge.Functions

-- house: 1291
Quest{
	NPC = 1040,	-- Su Lang Manchu
	Branch = "",
	Slot = 2,
	CanShow = function() return not Party.QBits[1285] end,
	Ungive = function()
		local k = MF.GetCurrentPlayer() or 0
		local player = Party[k]
		local level, mastery = SplitSkill(player.Skills[const.Skills.Dark])
		local rank = MF.GetReputationRank(MF.GetReputation())
		local max_rank = MF.GetReputationMaxRank()
		if level >= 4 and mastery >= 2 and rank >= max_rank then
			Party.QBits[1285] = true
			evt.Add("Inventory", 1725)	-- Witch Ring
			Mouse.Item.Bonus2 = 120
		else
			Message(Game.NPCText[2749])
			--[[I can assist experts of dark magic, provided they meet my standards.
  I only offer my help to the genuinely dedicated – those so evil their reputations are as bad as they can get.  The truly notorious.
  I make no exceptions, and charge no fee in the interests of spreading darkness throughout the world.]]
		end
	end,
	Texts = {
		Topic = Game.GlobalTxt[520]
	}
}

-- house: 1226
Quest{
	NPC = 1057,	-- Ki Lo Nee
	Branch = "",
	Slot = 2,
	CanShow = function() return not Party.QBits[1286] end,
	Ungive = function()
		local k = MF.GetCurrentPlayer() or 0
		local player = Party[k]
		local level, mastery = SplitSkill(player.Skills[const.Skills.Light])
		local rank = MF.GetReputationRank(MF.GetReputation())
		local min_rank = MF.GetReputationMinRank()
		if level >= 4 and mastery >= 2 and rank <= min_rank then
			Party.QBits[1286] = true
			evt.Add("Inventory", 1725)	-- Witch Ring
			Mouse.Item.Bonus2 = 119
		else
			Message(Game.NPCText[2750])
			--[[An advanced caster of light magic is amongst the most powerful spell casters in the world.
  I can improve nearly any expert, but I do not do this lightly.  I will only help persons of the highest reputation.  Living saints.]]
		end
	end,
	Texts = {
		Topic = Game.GlobalTxt[510]
	}
}
