local LogId = "NPCFollowers"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MT, MV = Merge.Functions, Merge.ModSettings, Merge.Tables, Merge.Vars

local strformat, strgsub = string.format, string.gsub

NPCFollowers = {}

local OpenFlwPnlBtn, FollowersBG, ShiftFollowersUp, ShiftFollowersDw
local FollowerBtns = {}
local NPCPanelOpen = false
local Width, Height = 640, 480
local FolowersScreenShift = 0
local InGame = 0x71ef8d
local OpenPanelIconUp, OpenPanelIconDown = 	"NPCOpenUp", "NPCOpenDw"
local LayoutActive = false

local MaxHirelings = tonumber(MM.MaxHirelings) or 4

-- Service functions for NPC panel.

local function get_follower(idx)
	if idx < 1 then
		return
	elseif idx <= #vars.HiredNPC then
		return vars.HiredNPC[idx]
	elseif idx <= #vars.HiredNPC + #vars.NPCFollowers then
		return vars.NPCFollowers[idx - #vars.HiredNPC]
	end
end
MF.GetFollower = get_follower

local function SpeakWithFollower(ButtonPos)
	local CurNPC = get_follower(ButtonPos+FolowersScreenShift)
	if CurNPC then
		evt.SpeakNPC{CurNPC}
	end
end

local function ShowFollowerName(ButtonPos)
	local CurNPC = get_follower(ButtonPos+FolowersScreenShift)
	if CurNPC then
		Game.ShowStatusText(Game.NPC[CurNPC].Name)
	end
end

local function StdCond()
	return NPCPanelOpen and mem.u4[InGame] == 1
end

local function followers_count()
	return vars and ((vars.HiredNPC and #vars.HiredNPC or 0)
		+ (vars.NPCFollowers and #vars.NPCFollowers or 0)) or 0
end
MF.FollowersCount = followers_count

function BtnCond()
	return NPCPanelOpen or (mem.u4[InGame] == 1 and followers_count() > 0)
end

local function UpdatePos()
	local layout = Game.PatchOptions.UILayoutActive()
	if layout ~= LayoutActive then
		LayoutActive = layout
		local dy = layout and -30 or 30
		local dx = dy*3
		for i, t in ipairs({FollowersBG, ShiftFollowersUp, ShiftFollowersDw, OpenFlwPnlBtn}) do
			t.X = t.X + dx
			t.Y = t.Y + dy
		end
		for i, t in ipairs(FollowerBtns) do
			t.X = t.X + dx
			t.Y = t.Y + dy
		end
	end
end

local function ToggleNPCPanel(State)
	if type(State) == "boolean" then
		NPCPanelOpen = State
	else
		NPCPanelOpen = not NPCPanelOpen
	end

	if NPCPanelOpen then
		OpenFlwPnlBtn.IUpSrc = OpenPanelIconDown
		OpenFlwPnlBtn.IDwSrc = OpenPanelIconUp
	else
		OpenFlwPnlBtn.IUpSrc = OpenPanelIconUp
		OpenFlwPnlBtn.IDwSrc = OpenPanelIconDown
	end

	Game.NeedRedraw = true
end
MF.ToggleNPCPanel = ToggleNPCPanel

local function RebuildFollowersTable()

	local NewT = {}
	for k,v in pairs(vars.NPCFollowers) do
		if v then
			table.insert(NewT, v)
		end
	end
	vars.NPCFollowers = NewT

	Log(Merge.Log.Info, "%s: gc", LogId)
	collectgarbage("collect")
	Log(Merge.Log.Info, "%s: gc finished", LogId)
end
NPCFollowers.Rebuild = RebuildFollowersTable

local function RemoveNPCFollower(i)
	local NPCf = table.find(vars.NPCFollowers, i)
	if NPCf then
		table.remove(vars.NPCFollowers, NPCf)
		Game.NPC[i].Hired = false
		return true
	end
	return false
end
NPCFollowers.Remove = RemoveNPCFollower
MF.NPCFollowerRemove = RemoveNPCFollower

local function AddNPCFollower(i)
	local NPCf = table.find(vars.NPCFollowers, i)
	if not NPCf then
		table.insert(vars.NPCFollowers, i)
		Game.NPC[i].Hired = true
		return true
	end
	return false
end
NPCFollowers.Add = AddNPCFollower
MF.NPCFollowerAdd = AddNPCFollower

local function NPCInGroup(id)
	if not vars then return end
	if vars.HiredNPC then
		local slot = table.find(vars.HiredNPC, id)
		if slot then return slot end
	end
	if vars.NPCFollowers then
		local slot = table.find(vars.NPCFollowers, id)
		if slot then return slot end
	end
end
NPCFollowers.NPCInGroup = NPCInGroup
MF.NPCInGroup = NPCInGroup

-- Service functions for NPC topics.

NPCFollowers.DismissNPCTopic = 1511
NPCFollowers.HireNPCTopic = 1512
NPCFollowers.HireState = false

function events.ExitNPC()
	NPCFollowers.HireState = false
end

local function FindFreeEvent(NPC, Replace)
	if type(Replace) == "table" then
		for i = 0, 5 do
			local Event = NPC.Events[i]
			if Event == 0 or table.find(Replace, Event) then
				return i
			end
		end
	else
		for i = 0, 5 do
			local Event = NPC.Events[i]
			if Event == 0 or Event == Replace then
				return i
			end
		end
	end
	return nil
end
NPCFollowers.FindFreeEvent = FindFreeEvent

local function ClearEvents(NPC, Events)
	if Events then
		for k,v in NPC.Events do
			if table.find(Events, v) then
				NPC.Events[k] = 0
			end
		end
	else
		for k,v in NPC.Events do
			NPC.Events[k] = 0
		end
	end
end
NPCFollowers.ClearEvents = ClearEvents

local function dismiss_npc(NPCId, NoExit)
	local slot = table.find(vars.HiredNPC, NPCId)
	if slot then
		table.remove(vars.HiredNPC, slot)
		Game.NPC[NPCId].Hired = false
		for i = 0, 5 do
			if Game.NPC[NPCId].Events[i] == NPCFollowers.HireNPCTopic then
				Game.NPC[NPCId].Events[i] = HireNPCTopic
			end
		end
		evt.MoveNPC(NPCId, Game.NPCDataTxt[NPCId].House)
		if not NoExit then
			ExitCurrentScreen(Game.CurrentScreen == 13)
		end

		local CurNPC = Game.NPC[NPCId]

		ClearEvents(CurNPC, {NPCFollowers.HirePeasantEvent, NPCFollowers.HireNPCTopic, NPCFollowers.ShowNPCDescrEvent, NPCFollowers.DismissNPCTopic})
		local ProfSet = Game.NPCProf[CurNPC.Profession]
		if ProfSet and ProfSet.Topic > 0 then
			ClearEvents(CurNPC, {ProfSet.Topic})
		end
	end
end
MF.NPCDismiss = dismiss_npc

local function DismissNPC(NPCId, NoExit)
	NPCId = NPCId or GetCurrentNPC()
	if not NPCId then return end

	if NPCFollowers.HireState then
		dismiss_npc(NPCId, NoExit)
		NPCFollowers.HireState = false
	else
		Message(Game.NPCText[1674] .. Game.NPC[NPCId].Name .. ".")
		NPCFollowers.HireState = true
	end
end
NPCFollowers.DismissNPC = DismissNPC

local function DismissNPCEvt()
	DismissNPC()
end

local function HaveProfession(Prof)
	for k, v in pairs(vars.HiredNPC) do
		if Game.NPC[v].Profession == Prof then
			return v
		end
	end
	return nil
end
NPCFollowers.HaveProfession = HaveProfession
MF.HasNPCProfession = HaveProfession

local function RemoveProfession(Prof)
	for k, v in pairs(vars.HiredNPC) do
		if Game.NPC[v].Profession == Prof then
			dismiss_npc(v, true)
			return v
		end
	end
end
MF.RemoveNPCProfession = RemoveProfession

local function GetTotalFee(Amount)
	local Total = 0
	for k, v in pairs(vars.HiredNPC) do
		local ProfSet = Game.NPCProf[Game.NPC[v].Profession]
		if ProfSet then
			Total = Total + ProfSet.Percent
		end
	end
	return Amount and math.floor(Amount*Total/100) or Total
end
NPCFollowers.GetTotalFee = GetTotalFee

local function HireNPC(NPCId, NoExit)
	NPCId = NPCId or GetCurrentNPC()
	if not NPCId then return end

	local cProf = Game.NPC[NPCId].Profession
	local ProfSet = Game.NPCProf and Game.NPCProf[cProf]

	if NPCFollowers.HireState then

		NPCFollowers.HireState = false

		if #vars.HiredNPC >= MaxHirelings or GetTotalFee() + ProfSet.Percent > 100 then
			Message(Game.GlobalTxt[533])
			return
		end

		if ProfSet and ProfSet.Cost > 0 then
			if Party.Gold < ProfSet.Cost then
				Message(Game.GlobalTxt[155])
				return
			else
				evt.ForPlayer("Current").Subtract{"Gold", ProfSet.Cost}
			end
		end

		local slot = table.find(vars.HiredNPC, NPCId)
		if not slot then
			table.insert(vars.HiredNPC, NPCId)
			Game.NPC[NPCId].Hired = true
			evt.MoveNPC(NPCId, 0)

			if mapvars.MapNPCNews and mapvars.MapNPCNews[NPCId] then
				Map.Monsters[mapvars.MapNPCNews[NPCId].Mid].AIState = 19
			else
				for i,v in Map.Monsters do
					if v.NPC_ID == NPCId then
						v.AIState = 19
					end
				end
			end
			for i = 0, 5 do
				if Game.NPC[NPCId].Events[i] == NPCFollowers.HireNPCTopic then
					Game.NPC[NPCId].Events[i] = DismissNPCTopic
				end
			end
			if not NoExit then
				ExitCurrentScreen(Game.CurrentScreen == 13)
			end
		end

	else
		if ProfSet then
			local NPCName = Game.NPC[NPCId].Name
			local cText = ProfSet.Text .. "\n" .. "(" .. ProfSet.Description .. " " .. Game.NPCText[1675] .. NPCName .. ".)"
			cText = string.replace(cText, "%17", tostring(ProfSet.Percent))
			cText = string.replace(cText, "%01", NPCName)
			Message(cText)
		else
			Message(Game.NPCText[1675] .. Game.NPC[NPCId].Name .. ".")
		end
		NPCFollowers.HireState = true
	end
end
NPCFollowers.HireNPC = HireNPC
MF.NPCHire = HireNPC

local function HireNPCEvt()
	HireNPC()
end

local function HireRecruit()
	local npcId = GetCurrentNPC()
	local npcInfo = mapvars.MapNPCNews[npcId]

	if npcInfo and Party.count < 5 then
		if NPCFollowers.HireState then
			local Pl = Party.PlayersArray[npcInfo.RecruitId]
			GenerateMercenary{RosterId = npcInfo.RecruitId, Class = const.Class.Peasant, Level = 1, Face = npcInfo.Face}
			Pl.Name = Game.NPC[npcId].Name
			Pl.Attrs.Race = Game.CharacterPortraits[Pl.Face].Race
			GenerateBiography(Pl)
			ExitCurrentScreen()
			Map.Monsters[npcInfo.Mid].AIState = 19
			HireCharacter(npcInfo.RecruitId)
		else
			NPCFollowers.HireState = true
			local ProfSet = Game.NPCProf[npcInfo.Profession]
			local cText = ProfSet.Text
			cText = string.replace(cText, "%17", tostring(ProfSet.Percent))
			cText = string.replace(cText, "%01", Game.NPC[npcId].Name)
			Message(cText)
		end
	else
		Message(Game.GlobalTxt[533])
	end
end
NPCFollowers.HireRecruit = HireRecruit

---- Initialization ----

function events.GameInitialized2()

	-- Interface

	FollowersBG = CustomUI.CreateIcon{
							Icon = "NPCPnl",
							X = Width - 120,
							Y = Height - 379,
							Condition = StdCond,
							Layer = 1,
							Screen = 0,
							DynLoad = true}

	FollowerBtns[1] = CustomUI.CreateButton{
							IconUp = "evtnpc-b",
							X = FollowersBG.X + 10,
							Y = FollowersBG.Y + 20,
							Action = function() SpeakWithFollower(1) end,
							MouseOverAction = function() ShowFollowerName(1) end,
							Condition = StdCond,
							Layer = 0,
							Screen = 0,
							DynLoad = true}

	FollowerBtns[2] = CustomUI.CreateButton{
							IconUp = "evtnpc-b",
							X = FollowersBG.X + 10,
							Y = FollowersBG.Y + 105,
							Action = function() SpeakWithFollower(2) end,
							MouseOverAction = function() ShowFollowerName(2) end,
							Condition = StdCond,
							Layer = 0,
							Screen = 0,
							DynLoad = true}

	FollowerBtns[3] = CustomUI.CreateButton{
							IconUp = "evtnpc-b",
							X = FollowersBG.X + 10,
							Y = FollowersBG.Y + 190,
							Action = function() SpeakWithFollower(3) end,
							MouseOverAction = function() ShowFollowerName(3) end,
							Condition = StdCond,
							Layer = 0,
							Screen = 0,
							DynLoad = true}

	ShiftFollowersUp = CustomUI.CreateButton{
							IconUp = "NPCUpA",
							IconDown = "NPCUpB",
							X = FollowersBG.X + 7,
							Y = FollowersBG.Y + 5,
							Action = function() 	if FolowersScreenShift > 0 then
														FolowersScreenShift = FolowersScreenShift - 1
													end
												end,
							Condition = StdCond,
							Layer = 0,
							Screen = 0,
							DynLoad = true}

	ShiftFollowersDw = CustomUI.CreateButton{
							IconUp = "NPCDwA",
							IconDown = "NPCDwB",
							X = FollowersBG.X + 7,
							Y = FollowersBG.Y + 275,
							Action = function()
								if FolowersScreenShift + 3 < followers_count() then
									FolowersScreenShift = FolowersScreenShift + 1
								end
							end,
							Condition = StdCond,
							Layer = 0,
							Screen = 0,
							DynLoad = true}

	OpenFlwPnlBtn = CustomUI.CreateButton{
							IconUp = OpenPanelIconUp,
							IconDown = OpenPanelIconDw,
							X = Width - 26,
							Y = Height - 139,
							Action = ToggleNPCPanel,
							Condition = BtnCond,
							Layer = 1,
							Screen = 0,
							DynLoad = true}

	function events.FGInterfaceUpd()
		UpdatePos()
		if StdCond() and Game.CurrentScreen == 0 and not Game.LoadingScreen then
			for i = 1, 3 do
				CurNPC = get_follower(i+FolowersScreenShift)
				if CurNPC then
					CurPic = tostring(Game.NPC[CurNPC].Pic)
					CurPic = "npc" .. string.sub("0000", string.len(CurPic)+1) .. CurPic
					CustomUI.ShowIcon(CurPic, FollowerBtns[i].X + 4, FollowerBtns[i].Y + 4)
				end
			end
		end
	end

	-- NPC won't follow party underwater.
	function events.AfterLoadMap()
		local IsUnderwater = Game.MapStats[Map.MapStatsIndex].EaxEnvironments == 22
		OpenFlwPnlBtn.Active = not IsUnderwater
	end

	function events.Action(t)
		if Game.CurrentScreen == 0 and not Game.LoadingScreen
			and (StdCond() and CustomUI.MouseInBox(FollowersBG.X, FollowersBG.Y, FollowersBG.Wt, FollowersBG.Ht)
				or BtnCond() and CustomUI.MouseInBox(OpenFlwPnlBtn.X, OpenFlwPnlBtn.Y, OpenFlwPnlBtn.Wt, OpenFlwPnlBtn.Ht)) then

			t.Handled = true
			if t.Action == 107 then
				ToggleNPCPanel()
			end
		end
	end

	-- Topics

	function events.LoadMap(WasInGame)

		local LastTopic

		if not WasInGame then

			function events.EvtGlobal(i)
				NPCFollowers.HireState = LastTopic == i
				LastTopic = i
			end

			vars.HiredNPC = vars.HiredNPC or {}
			vars.NPCFollowers = vars.NPCFollowers or {}

			Game.GlobalEvtLines:RemoveEvent(NPCFollowers.DismissNPCTopic)
			Game.GlobalEvtLines:RemoveEvent(NPCFollowers.HireNPCTopic)
			Game.GlobalEvtLines:RemoveEvent(NPCFollowers.HirePeasantEvent)

			evt.Global[NPCFollowers.DismissNPCTopic]	= DismissNPCEvt
			evt.Global[NPCFollowers.HireNPCTopic]		= HireNPCEvt
			evt.Global[NPCFollowers.HirePeasantEvent]	= HireRecruit

			Game.NPCTopic[NPCFollowers.DismissNPCTopic]	 = Game.NPCTopic[38]
			Game.NPCTopic[NPCFollowers.HireNPCTopic]	 = Game.NPCTopic[100]
			Game.NPCTopic[NPCFollowers.HirePeasantEvent] = Game.NPCTopic[100]

			evt.Global[NPCFollowers.ShowNPCDescrEvent] = function()
				local cNPC = Game.NPC[GetCurrentNPC()]
				local ProfSet = Game.NPCProf[cNPC.Profession]
				if ProfSet then
					local cText = ProfSet.Description
					cText = string.replace(cText, "%17", tostring(ProfSet.Percent))
					cText = string.replace(cText, "%01", cNPC.Name)
					Message(cText)
				end
			end

			Game.NPCTopic[NPCFollowers.ShowNPCDescrEvent] = Game.GlobalTxt[407]

		end
		ToggleNPCPanel(false)
	end

	function events.LeaveGame()
		ToggleNPCPanel(false)
	end

end

--------------------------------
----	NPC Prof hireligs	----
--------------------------------

NPCFollowers.BegTopic		= 1766
NPCFollowers.ThreatTopic	= 1767
NPCFollowers.BribeTopic		= 1768

local function NPCWillSpeak(npc)

	if Game.CurrentScreen == 13 or NPCInGroup(npc) or not NPCFollowers.IsRandomNPC(npc) then
		return true
	end

	local NPCExtra = mapvars.MapNPCNews[npc]
	if not NPCExtra then
		return
	end

	if NPCExtra.ThreatSuccess then
		return true
	end

	local rep_set = MT.Reputation.Maps[MV.Map] or MT.Reputation.Continents[MV.Continent]
	--local ContSet = Game.ContinentSettings[TownPortalControls.MapOfContinent(Map.MapStatsIndex)]
	if not rep_set.RepNPC then
		return true
	end

	local PersSet = Game.NPCPersonalities[Game.NPCProf[Game.NPC[npc].Profession].Personality]
	local cRep = MF.ReputationRead()
	local rep_rank = MF.GetReputationRank(cRep)
	local rep_rank_shift = rep_set.RepRanks == 4 and 1 or 0
	local cFame	= NPCFollowers.GetPartyFame()
	NPCExtra.Alignment = NPCExtra.Alignment or (math.random(1,2) == 1 and "G" or "E")

	-- FIXME
	if (NPCExtra.Alignment == "G" and rep_rank > 0 + rep_rank_shift)
			or (NPCExtra.Alignment == "E" and rep_rank < -1) then
		return false, "Rep"
	end

	-- FIXME
	if math.abs(cRep) * (rep_set.TradeMult or 1) < PersSet.ReqRep then
		return false, "LowRep"
	end

	if PersSet.ReqFame > cFame then
		return false, "NoFame"
	end

	return true

end
NPCFollowers.NPCWillSpeak = NPCWillSpeak

local function SetHireTopic(npc)

	local CurNPC = Game.NPC[npc]
	local ProfSet = Game.NPCProf[CurNPC.Profession]

	-- all outdoor npcs can join if profession allows. Only signed indoor npc can join.
	if ProfSet and (CurNPC.Joins > 0 or ProfSet.Joins and Game.CurrentScreen ~= 13) then

		local RndNPCInfo = mapvars.MapNPCNews and mapvars.MapNPCNews[npc]

		NPCFollowers.HireState = false
		ClearEvents(CurNPC, {NPCFollowers.HirePeasantEvent, NPCFollowers.HireNPCTopic, NPCFollowers.ShowNPCDescrEvent, NPCFollowers.DismissNPCTopic, ProfSet.Topic})

		if ProfSet.Recruit and RndNPCInfo and RndNPCInfo.Race ~= -1 then

			local cHave, cNPC, cRosterId = NPCFollowers.HaveFreeMerc()
			if cHave then
				local FreeEvent = FindFreeEvent(CurNPC)
				if FreeEvent then
					mapvars.MapNPCNews[npc].RecruitId = cRosterId
					CurNPC.Events[FreeEvent] = NPCFollowers.HirePeasantEvent
				end
			else
				ClearEvents(CurNPC, {NPCFollowers.HirePeasantEvent})
			end

		else

			local FreeEvent
			if NPCInGroup(npc) then
				ClearEvents(CurNPC, {1031, 1032, 1033}) -- Remove extra news topics.

				if ProfSet.Topic > 0 then
					FreeEvent = FindFreeEvent(CurNPC)
					if FreeEvent then
						CurNPC.Events[FreeEvent] = ProfSet.Topic
					end
				end

				if string.len(ProfSet.Description) > 0 then
					FreeEvent = FindFreeEvent(CurNPC, NPCFollowers.ShowNPCDescrEvent)
					if FreeEvent then
						CurNPC.Events[FreeEvent] = NPCFollowers.ShowNPCDescrEvent
					end
				end

				FreeEvent = FindFreeEvent(CurNPC, NPCFollowers.DismissNPCTopic)
				if FreeEvent then
					CurNPC.Events[FreeEvent] = NPCFollowers.DismissNPCTopic
				end
			else
				FreeEvent = FindFreeEvent(CurNPC, NPCFollowers.HireNPCTopic)
				if FreeEvent then
					CurNPC.Events[FreeEvent] = NPCFollowers.HireNPCTopic
				end
			end

		end

	end

end
NPCFollowers.SetHireTopic = SetHireTopic

local function SetBTBTopics(npc)

	local cNPC = Game.NPC[npc]

	ClearEvents(cNPC)
	cNPC.EventA = NPCFollowers.BegTopic
	cNPC.EventB = NPCFollowers.ThreatTopic
	cNPC.EventC = NPCFollowers.BribeTopic

end
NPCFollowers.SetBTBTopics = SetBTBTopics

-- Make NPCProf table

NPCFollowers.HirePeasantEvent = 1510
NPCFollowers.ShowNPCDescrEvent = 1509

local function prof_text(t, key)
	local val = t.TextFields[key]
	if val then
		return (type(val) == 'number') and Game.NPCText[val] or val
	end
	return rawget(t, key)
end

local function ProcessNPCProf()

	local function SetProfNamesHook()
		local function SetProfName(d)
			d.eax = mem.topointer(Game.NPCProfessions[d.eax])
		end

		for i,v in pairs({0x41dfc1, 0x442198, 0x4426a7, 0x4b1328}) do
			mem.asmpatch(v, "push eax")
			mem.autohook(v, SetProfName)
		end
	end

	local function NPCTextId(str)
		local num = tonumber(str)
		if num then
			return num
		end
		return nil
	end

	local TxtTable = io.open("Data/Tables/NPC professions.txt", "r")
	if not TxtTable then
		if Game.NPCProfessions then
			SetProfNamesHook()
		end
		return false
	end

	Game.NPCProfessions = Game.NPCProfessions or {}
	SetProfNamesHook()

	local NPCProf = {}

	const.NPCPersonality = {
		Peasant	= 1,
		Monster = 2,
		Thief	= 3,
		Merchant = 4,
		Sorcerer = 5,
		Scholar	 = 6,
		Adventurer = 7,
		Priest	= 8,
		Official = 9,
		Guard	= 10,
		Fanatic	= 11,
		Paladin	= 12,
		Noble	= 13
	}

	local LineIt = TxtTable:lines()
	LineIt() -- skip header

	local TextFields = {
		Text = true,
		Description = true}

	local prof_metatable = {__index = prof_text}

	local cnt = 0
	for line in LineIt do

		local Words = string.split(line, "\9")
		local ProfName = tonumber(Words[3])

		Game.NPCProfessions[cnt] = ProfName and Game.GlobalTxt[ProfName] or Words[2]

		NPCProf[cnt] = {
			TextFields = TextFields,
			Rarity	= tonumber(Words[4]) or 10,
			Cost	= tonumber(Words[5]) or 100,
			Percent = tonumber(Words[6]) or 1,
			Personality	= const.NPCPersonality[Words[7]] or tonumber(Words[7]) or 1,
			Topic	= tonumber(Words[8]) or 0,
			Joins	= Words[9] == "x",
			Recruit	= Words[10] == "x",
			TextFields = {
				Text	= NPCTextId(Words[11]) or Words[11],
				Description = NPCTextId(Words[12]) or Words[12]
				}
			}

		setmetatable(NPCProf[cnt], prof_metatable)

		cnt = cnt + 1
	end

	io.close(TxtTable)
	Game.NPCProf = NPCProf

	return true

end

local function ProcessBTBTxt()

	local TxtTable = io.open("Data/Tables/NPC BTB.txt", "r")
	if not TxtTable then
		return
	end

	local T = {}
	local LineIt = TxtTable:lines()
	LineIt() -- skip header

	local function GetBTBText(str)
		local num = tonumber(str)
		return num or str
	end

	local prof_metatable = {__index = prof_text}

	for line in LineIt do

		local Words = string.split(line, "\9")
		local Num = const.NPCPersonality[Words[1]] or tonumber(Words[1])

		if Num then

			T[Num] = {
				AcceptBeg	 = Words[2] == "x",
				AcceptBribe	 = Words[3] == "x",
				AcceptThreat = Words[4] == "x",
				Creed		 = const.Bolster.Creed[Words[5]] or tonumber(Words[5]) or 0,
				ReqFame		 = tonumber(Words[6]) or 0,
				ReqRep		 = tonumber(Words[7]) or 0,

				TextFields = {
					RepOk1 = GetBTBText(Words[8]),
					RepOk2 = GetBTBText(Words[9]),

					BegRet		= GetBTBText(Words[10]),
					BribeRet	= GetBTBText(Words[11]),
					ThreatRet	= GetBTBText(Words[12]),

					NoFame = GetBTBText(Words[13]),

					RepNotoriousG = GetBTBText(Words[14]),
					RepNotoriousE = GetBTBText(Words[15]),

					RepSaintlyG = GetBTBText(Words[16]),
					RepSaintlyE = GetBTBText(Words[17]),

					Rep1E = GetBTBText(Words[19]),
					Rep2E = GetBTBText(Words[23]),
					Rep1G = GetBTBText(Words[18]),
					Rep2G = GetBTBText(Words[22]),

					LowRep1G = GetBTBText(Words[20]),
					LowRep2G = GetBTBText(Words[24]),

					LowRep1E = GetBTBText(Words[21]),
					LowRep2E = GetBTBText(Words[25]),

					BegSuccess	= GetBTBText(Words[26]),
					BegFail		= GetBTBText(Words[27]),

					BribeSuccess = GetBTBText(Words[28]),
					BribeFail	 = GetBTBText(Words[29]),

					ThreatSuccess	= GetBTBText(Words[30]),
					ThreatFail		= GetBTBText(Words[31])
					}

			}

			setmetatable(T[Num], prof_metatable)

		end
	end

	io.close(TxtTable)
	Game.NPCPersonalities = T

end

local function GenerateFace(Gender, Race)

	Gender = (Gender == "M" and 0 or Gender == "F" and 1) or 0

	local tmpT = {}

	for i,v in Game.CharacterPortraits do
		if v.DefSex == Gender and v.Race == Race then
			table.insert(tmpT, i)
		end
	end

	if #tmpT > 0 then
		return tmpT[math.random(1, #tmpT)]
	end

	return nil

end

function events.GameInitialized2()

	if not ProcessNPCProf() then
		return
	end

	ProcessBTBTxt()

	-- process outdoor NPCs

	function events.AfterLoadMap()

		local ContSet = Game.ContinentSettings[MV.Continent]

		if not ContSet.NPCFollowers then
			return
		end

		if not mapvars.MapNPCNews then
			return
		end

		if not NPCFollowers.HaveFreeMerc() then
			return
		end

		for k,v in pairs(mapvars.MapNPCNews) do
			local ProfSet = Game.NPCProf[v.Profession]
			if not NPCInGroup(k) and ProfSet and ProfSet.Joins and ProfSet.Recruit then
				local CurNPC = Game.NPC[k]
				if v.Race == nil then
					local cMonApp = NPCFollowers.GetMonAppearance(Map.Monsters[v.Mid].Id)
					v.Race = cMonApp.Race
				end

				if v.Race and v.Race > -1 then
					v.Face = v.Face or GenerateFace(v.Gender, v.Race)
					if v.Face then
						Game.NPC[k].Pic = Game.CharacterPortraits[v.Face].NPCPic
					end
				end
			end
			Game.NPC[k].EventB = 0
		end

	end

	-- set "Hire" topic
	function events.EnterNPC(npc)

		if NPCWillSpeak(npc) then
			SetHireTopic(npc)
		end

	end

	-- Disable original "Join" topic
	mem.asmpatch(0x4b2e83, "jmp absolute 0x4b2eaf")
	mem.asmpatch(0x41bd27, "jmp absolute 0x41bd57")

	-- Show amount of gold taken by followers
	local GoldTakenLine = Game.GlobalTxt[467]
	local gold_taken_followers_str =
		strgsub(strgsub(Game.GlobalTxt[466], "%%lu", "%%%%lu", 1), "([^%%])%%lu", "%1%%d")
	local NewCode = mem.asmproc([[
	nop
	nop
	nop
	nop
	nop
	push esi
	push eax
	jmp absolute 0x42015a]])

	mem.asmpatch(0x420153, "jmp absolute " .. NewCode)

	NPCFollowers.LastGoldTaken = 0
	mem.hook(NewCode, function(d)
		local Fee = NPCFollowers.LastGoldTaken
		if Fee > 0 then
			GoldTakenLine = strformat(gold_taken_followers_str, Fee)
		else
			GoldTakenLine = Game.GlobalTxt[467]
		end
		d.eax = mem.topointer(GoldTakenLine)
	end)

end

Log(Merge.Log.Info, "Init finished: %s", LogId)

