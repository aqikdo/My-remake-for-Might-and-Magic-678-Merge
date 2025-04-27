local LogId = "ReputationTopics"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)

vars.GlobalReputation = vars.GlobalReputation or {}
vars.GlobalReputation.Worlds = vars.GlobalReputation.Worlds or {}
vars.GlobalReputation.Continents = vars.GlobalReputation.Continents or {}
vars.GlobalReputation.Maps = vars.GlobalReputation.Maps or {}
vars.ContinentFame = vars.ContinentFame or {} -- contains exp base for fame counting.

local function ExitBTBTopics(npc)
	NPCFollowers.ClearEvents(Game.NPC[npc])

	NPCFollowers.SetHireTopic(npc)
	NPCFollowers.SetNewsTopics(npc)
end

-- Beg topic.
Game.GlobalEvtLines:RemoveEvent(NPCFollowers.BegTopic)
evt.Global[NPCFollowers.BegTopic] = function()
	if Game.CurrentPlayer < 0 then
		return
	end

	local MerchantSkill = SplitSkill(Party[Game.CurrentPlayer]:GetSkill(const.Skills.Merchant))
	local npc = GetCurrentNPC()
	local PersSet = Game.NPCPersonalities[Game.NPCProf[Game.NPC[npc].Profession].Personality]
	local NPCExtra = mapvars.MapNPCNews[npc]

	if NPCExtra.BegSuccess == Game.DayOfMonth then
		Message(NPCFollowers.PrepareBTBString(npc, PersSet.BegRet))
		Party[Game.CurrentPlayer]:ShowFaceAnimation(const.FaceAnimation.BegFail)
	elseif PersSet.AcceptBeg then
		NPCExtra.BegSuccess = Game.DayOfMonth
		Message(NPCFollowers.PrepareBTBString(npc, PersSet.BegSuccess))
		ExitBTBTopics(npc)
		Party[Game.CurrentPlayer]:ShowFaceAnimation(const.FaceAnimation.Beg)
	else
		Message(NPCFollowers.PrepareBTBString(npc, PersSet.BegFail))
		Party[Game.CurrentPlayer]:ShowFaceAnimation(const.FaceAnimation.BegFail)
	end
end

-- Threat topic
Game.GlobalEvtLines:RemoveEvent(NPCFollowers.ThreatTopic)
evt.Global[NPCFollowers.ThreatTopic] = function()
	if Game.CurrentPlayer < 0 then
		return
	end

	local npc = GetCurrentNPC()
	local PersSet = Game.NPCPersonalities[Game.NPCProf[Game.NPC[npc].Profession].Personality]

	if PersSet.AcceptThreat then
		mapvars.MapNPCNews[npc].ThreatSuccess = Game.DayOfMonth
		Message(NPCFollowers.PrepareBTBString(npc, PersSet.ThreatSuccess))
		ExitBTBTopics(npc)
	else
		Message(NPCFollowers.PrepareBTBString(npc, PersSet.ThreatFail))
		Party[Game.CurrentPlayer]:ShowFaceAnimation(const.FaceAnimation.ThreatFail)
	end
end

-- Bribe topic.
Game.GlobalEvtLines:RemoveEvent(NPCFollowers.BribeTopic)
evt.Global[NPCFollowers.BribeTopic] = function()
	local npc = GetCurrentNPC()
	local ProfSet = Game.NPCProf[Game.NPC[npc].Profession]
	local Cost = ProfSet.Cost or 50
	local PersSet = Game.NPCPersonalities[ProfSet.Personality]

	evt.ForPlayer(0)

	if PersSet.AcceptBribe then
		if Party.Gold > Cost then
			evt.Subtract("Gold", Cost)
			mapvars.MapNPCNews[npc].BribeSuccess = Game.DayOfMonth
			Message(NPCFollowers.PrepareBTBString(npc, PersSet.BribeSuccess))
			ExitBTBTopics(npc)
		else
			Message(Game.GlobalTxt[155])
			Party[Game.CurrentPlayer]:ShowFaceAnimation(const.FaceAnimation.BribeFail)
		end
	else
		Message(NPCFollowers.PrepareBTBString(npc, PersSet.BribeFail))
		Party[Game.CurrentPlayer]:ShowFaceAnimation(const.FaceAnimation.BribeFail)
	end
end


local StdBribeTopic = Game.NPCTopic[1765]
function events.EnterNPC(i)
	local Cost = Game.NPCProf[Game.NPC[i].Profession].Cost or 50
	Game.NPCTopic[NPCFollowers.BribeTopic] = StdBribeTopic .. " " .. tostring(Cost) .. " " .. Game.GlobalTxt[97]
end

Log(Merge.Log.Info, "Init finished: %s", LogId)

