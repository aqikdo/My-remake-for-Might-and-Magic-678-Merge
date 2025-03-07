
	local MO = Merge.Offsets
	local asmpatch, asmproc = mem.asmpatch, mem.asmproc
	--0x4608c0
	local NewCode

	-- Change main menu soundtrack.
	mem.IgnoreProtection(true)
	mem.u1[0x46103c] = 16
	mem.u1[0x4bd38d] = 16
	mem.IgnoreProtection(false)

	-- Override water settings from mm8.ini
	Game.PatchOptions.HDWTRCount = 14
	Game.PatchOptions.HDWTRDelay = 15

	-- 0x4b067b - increase amount of house sound sets
	mem.asmpatch(0x4b067d, "add eax, 0xbb8")
	mem.asmpatch(0x4b0683, "imul eax, eax, 0xa")

	-- Other kinds of sounds:
	mem.asmpatch(0x4a9b23, "movzx eax, word [ds:edi+0x4c]")

	-- Disable standart lich-transformation by evt.Set{"ClassIs", X}
	-- Use Party[Y].Face = Z, and SetCharFace(Y, Z) instead.
	-- Y - char id in party, Z - portrait id form "Character portraits.txt".

	mem.asmpatch(0x447dba, "jmp 0x447def - 0x447dba")

	-- Disable mind and soul immunity setting after lich-transformation, use
	--		Party[X].Resistances[7].Base = 65000
	--		Party[X].Resistances[8].Base = 65000

	mem.asmpatch(0x447d9b, "jmp absolute 0x447dad")
	mem.asmpatch(0x447d43, "jmp absolute 0x4482eb")

	-- Fix crown of final dominion (Remove unstackable "Of Dark" bonus)
	mem.asmpatch(0x48e7b7, "jmp absolute 0x48ec2d")
	-- Eclipse
	mem.asmpatch(0x48e73f, "jmp absolute 0x48ec2d")
	-- Staff of elements
	mem.asmpatch(0x48e86c, "jmp absolute 0x48e890")
	-- Ring of fusion
	mem.asmpatch(0x48e8f3, "jmp absolute 0x48e8fc")

	-- Serendine's Preservation (remove non-stackable SP regen bonus)
	mem.nop(0x491FC5, 8)

	-- Remove some duplicated GetFullHP/GetFullSP calls
	mem.nop(0x492010, 7)
	mem.nop(0x492082, 7)
	mem.nop(0x492116, 7)
	mem.nop(0x49215B, 7)
	-- Remove duplicated GetSkill call
	mem.nop(0x4920BF, 9)

	-- Workaround for crash caused by exceed amount of loaded icons (>1000)
	-- Draw pending icon for items, which's icons could not be loaded.
	-- Need to find proper solution for this case.
	mem.asmpatch(0x410e06, "jmp absolute 0x410ec8")
	mem.asmpatch(0x410d76, [[
	xor eax, eax
	cmp dword [ds:ecx+0x11B7C], 0x3e7
	jge absolute 0x410ed1
	xor edi, edi
	cmp dword [ss:ebp+8], edi]])

	-- Reduce traveling cost from arena to four days and zero food.
	mem.asmpatch(0x446ee6, "push 0x0")
	mem.asmpatch(0x446f3c, "push 0x0")
	mem.nop(0x446f07, 3)

	-- Fix jumping on nonflat structures in outdoor maps.
	mem.asmpatch(0x47312d, [[
	cmp dword [ss:ebp-0x5c], ecx
	je @end

	mov eax, dword [ds:0xb7ca88]
	bt eax, 3
	jc @bad

	cmp dword [0xB21588], 100  ; max upward speed
	jg @bad
	cmp dword [0xB21588], -100  ; max downward speed
	jnl @end

	@bad:
	jmp absolute 0x47316c

	@end:
	]])

	-- fix flickering during crossing portals in indoor maps
	-- Use party Z instead of camera Z, when checking portals:
	mem.asmpatch(0x4af29c, "mov edx, dword [ds:0xB2155C]")
	-- Increase offset for MinX, MaxX, MinY, MaxY, MinZ
	mem.asmpatch(0x4af257, "push 0x7f")
	-- Increase offset for MaxZ
	mem.asmpatch(0x4af2ae, "add edi, 0x7f")

	-- Fix monsters flickering in indoor maps.
	function events.LoadMap()

		if not Map.IsIndoor() then
			return
		end

		local function fix(strData, strRoomData)
			local tData = mapvars[strData]
			if tData and type(tData) == "table" then
				for RoomId,Room in pairs(tData) do
					local RoomData = Map.Rooms[RoomId][strRoomData]
					for i,v in RoomData do
						RoomData[i] = -1
					end
					local count = 0
					for i,DataId in pairs(Room) do
						RoomData[i] = DataId
						count = count + 1
					end
					RoomData.count = count
				end
			else
				local cRoomId
				mapvars[strData] = {}
				for RoomId,Room in Map.Rooms do
					for i,DataId in Room[strRoomData] do
						cRoomId = Map.RoomFromPoint(Map[strRoomData][DataId])
						if cRoomId ~= RoomId and cRoomId ~= 0 then
							Room[strRoomData][i] = -1
						end
					end

					mapvars[strData][RoomId] = {}
					local RoomFix = mapvars[strData][RoomId]
					local pos = 0
					for i,v in Room[strRoomData] do
						if v >= 0 then
							RoomFix[pos] = v
							Room[strRoomData][pos] = v
							pos = pos + 1
						end
					end
					Room[strRoomData].count = pos
				end
			end
		end

		fix("RoomSpritesFix", "Sprites")
		fix("RoomLightsFix", "Lights")

		-- fix portals Z bounds
		local F
		for RoomId, Room in Map.Rooms do
			for _, FId in Room.Portals do
				F = Map.Facets[FId]
				F.MinZ = Room.MinZ
				F.MaxZ = Room.MaxZ
			end
		end

	end

	-- Fix evt.Question (was not supposed to be called outside houses in mm8, now it should)
	mem.asmpatch(0x4d9e95, [[
	test ecx, ecx
	je absolute 0x4d9f08
	test ecx, 3]])

	mem.asmpatch(0x44203a, [[
	mov dword [ds:ebp-0x8], eax
	cmp dword [ds:0x4f37d8], 0xd
	je absolute 0x44210a
	jmp absolute 0x44204a]])

	-- Don't show final cutscene, don't change map, just print image (cutscene can be shown by evt.ShowMovie)
	mem.asmpatch(0x4bd454, "push 4")
	mem.asmpatch(0x4bd88b, "jmp 0x4bd8c4 - 0x4bd88b")
	Game.PrintEndCard = function(Text, BackImg)
		if Text then
			Game.GlobalTxt[676] = Text
		end
		if BackImg then
			mem.copy(0x5014e0, BackImg, 11)
		end
		mem.call(0x4bd3e1)
	end

	-- fixed in MMPatch 2.5
	-- Fix Ice Bolt spell selection for monsters.
	--local IceBlast = "IceBlast"
	--mem.hook(0x4522e0, function(d) d.ebx = mem.topointer(IceBlast) end)
	--
	--local IceBolt = "IceBolt"
	--mem.autohook2(0x4522e9, function(d) d.ebx = mem.topointer(IceBolt) end)
	--
	--mem.asmpatch(0x4522F6, "jmp absolute 0x4520EB")
	--mem.asmpatch(0x452387, "jmp absolute 0x4520EB")

	-- Fix Day of the Gods, Deadly Swarm and Flying Fist spell selection for monsters.
	-- Note: if string variables are declared as local, only the last one will contain
	--   proper characters.
	DayGods, DeadlySwarm, FlyingFist = "Day-o-Gods", "Deadly", "Flying"
	mem.asmpatch(0x4524B3, [[
	jnz short @daygods
	push 0x44
	jmp absolute 0x4520EB
	@daygods:
	push ]] .. mem.topointer(DayGods) .. [[;
	push dword ptr [edi+4]
	call absolute 0x4DA920
	test eax, eax
	pop ecx
	pop ecx
	jnz @swarm
	push 0x53
	jmp absolute 0x4520EB
	@swarm:
	push ]] .. mem.topointer(DeadlySwarm) .. [[;
	push dword ptr [edi+4]
	call absolute 0x4DA920
	test eax, eax
	pop ecx
	pop ecx
	jnz @fist
	push 0x25
	jmp absolute 0x452485
	@fist:
	push ]] .. mem.topointer(FlyingFist) .. [[;
	push dword ptr [edi+4]
	call absolute 0x4DA920
	test eax, eax
	pop ecx
	pop ecx
	jnz absolute 0x4524BC
	push 0x4C
	jmp absolute 0x452485
	]])

	-- Show correct transition texts for mm6/7 maps.
	local TransTexts = {
	["7d18.blv"] = 9,
	["7d14.blv"] = 398,
	["d01.blv"] = 392,
	["7d16.blv"] = 412,
	["zddb01.blv"] = 22,
	["oracle.blv"] = 166,
	["sci-fi.blv"] = 451,
	["7d15.blv"] = 397,
	["d43.blv"] = 806,
	["d44.blv"] = 815,
	["d45.blv"] = 825,
	["d46.blv"] = 835,
	["d48.blv"] = 845,
	["d49.blv"] = 854,
	["mdt09.blv"] = 8,
	["mdt10.blv"] = 15,

	-- The Bandit Caves
	["mdt14.blv"] = 10,

	-- The Haunted Mansion
	["7d37.blv"] = 11,

	-- barrows
	["mdk01.blv"] = 12,
	["mdk02.blv"] = 12,
	["mdk03.blv"] = 12,
	["mdk04.blv"] = 12,
	["mdk05.blv"] = 12,
	["mdt01.blv"] = 12,
	["mdt02.blv"] = 12,
	["mdt03.blv"] = 12,
	["mdt04.blv"] = 12,
	["mdt05.blv"] = 12,
	["mdr01.blv"] = 12,
	["mdr02.blv"] = 12,
	["mdr03.blv"] = 12,
	["mdr04.blv"] = 12,
	["mdr05.blv"] = 12,

	}

	function events.GetTransitionText(t)
		local TextId = TransTexts[t.EnterMap]
		if TextId then
			t.TransId = TextId
		end
	end

	-- Roster.txt processing
	mem.nop(0x494a67, 3)
	mem.hook(0x494a6a, function(d)

		local ClassConns = {

			necromancer0  = const.Class.DarkAdept,
			necromancer  = const.Class.Necromancer,
			necromancer2 = const.Class.MasterNecromancer,
			cleric0 = const.Class.AcolyteLight,
			cleric 		 = const.Class.ClericLight,
			cleric2		 = const.Class.PriestLight,
			knight 		 = const.Class.Knight,
			knight1		 = const.Class.Cavalier,
			knight2		 = const.Class.Champion,
			troll 		 = const.Class.Barbarian,
			troll1 		 = const.Class.Berserker,
			troll2 		 = const.Class.Warmonger,
			minotaur 	 = const.Class.Minotaur,
			minotaur1	 = const.Class.MinotaurHeadsman,
			minotaur2 	 = const.Class.MinotaurLord,
			darkelf 	 = const.Class.Deerslayer,
			darkelf1 	 = const.Class.Pioneer,
			darkelf2 	 = const.Class.Pathfinder,
			vampire 	 = const.Class.Vampire,
			vampire1 	 = const.Class.ElderVampire,
			vampire2 	 = const.Class.Nosferatu,
			dragon 		 = const.Class.Dragon,
			dragon1		 = const.Class.FlightLeader,
			dragon2		 = const.Class.GreatWyrm
		} -- Use class indexes for rest.

		d.ecx = mem.u4[d.eax+8]
		local CurClassName = mem.string(d.ecx)
		d.eax = tonumber(CurClassName) or ClassConns[CurClassName]
			or const.Class[CurClassName] or const.Class.Knight

	end)

	-- Use Game.NPCNames during player selection to avoid screwing with names by gender.
	mem.hook(0x48e0f0, function(d)
		local NamesTable = Game.NPCNames[Game.CharacterPortraits[Party[0].Face].DefSex == 0 and "M" or "F"]
		Party[0].Name = NamesTable[math.random(1, #NamesTable)]
	end)

	-- negative value of FacetId leads to use facet itself instead of facet group.
	-- evt.SetFacetBit correction.
	mem.autohook(0x445d05, function(d)
		if Map.IsOutdoor() or d.ecx >= 0 or -d.ecx > Map.Facets.count -1 then return end
		d.ecx = math.abs(d.ecx)
		for k, v in pairs(const.FacetBits) do
			if v == d.edx then
				Map.Facets[d.ecx][k] = mem.u4[d.esp+4] == 1
				d.ecx = 0
			end
		end
	end)

	-- evt.SetTexture correction.
	mem.autohook(0x44597e, function(d)
		if d.ecx >= 0 then return end
		d.ecx = math.abs(d.ecx)
		local CurBitmap = mem.string(d.edx)
		local Facet = Map.Facets[d.ecx]
		if Facet.AnimatedTFT then
			for i,v in Game.TFTBin do
				if v.Name == CurBitmap then
					for a = i, i+255 do
						local TFT = Game.TFTBin[a]
						CurBitmap = TFT.Name
						CurBitmap = Game.BitmapsLod:LoadBitmap(CurBitmap)
						Game.BitmapsLod.Bitmaps[CurBitmap]:LoadBitmapPalette()
						TFT.Index = CurBitmap
						if not TFT.NotGroupEnd then
							break
						end
					end
					Facet.BitmapId = i
					break
				end
			end
		else
			CurBitmap = Game.BitmapsLod:LoadBitmap(CurBitmap)
			Game.BitmapsLod.Bitmaps[CurBitmap]:LoadBitmapPalette()
			Facet.BitmapId = CurBitmap
		end
		d.ecx = 0
	end)

	-- evt.SetSprite correction.
	mem.autohook(0x445bd2, function(d) --0x445bd2, 0x445bee
		if d.ecx >= 0  then return end
		d.ecx = math.abs(d.ecx)
		local DecName = mem.string(mem.u4[d.esp+4])
		Map.Sprites[d.ecx].Invisible = d.edx == 0
		if DecName ~= "0" then
			Map.Sprites[d.ecx].DecName = DecName
		end
	end)

	-- evt.SetLight correction.
	mem.autohook(0x445c9a, function(d)
		if d.ecx >= 0 then
			return
		end
		d.ecx = math.abs(d.ecx)
		Map.Lights[d.ecx].Off = d.edx == 0
		d.ecx = -1
	end)

	-- fixed in MMPatch 2.5
	-- Trigger "LeaveMap" event during traveling by boats/stables.
	--mem.autohook2(0x4b516b, function(d) -- 0x4bab72
	--	if Party.Gold >= d.ecx then
	--		internal.OnLeaveMap()
	--	end
	--end)

	-- Need to inspect this, sometimes gives crahes at spacebar action:
	mem.asmpatch(0x4685d9, [[
	movsx ecx, word [ds:ecx+0x6b1458]
	cmp ecx, 0x7fff
	jnz @end
	xor ecx, ecx
	@end:
	]])

	-- Need to inspect this, fix for ghost items in Party[*].Inventory array.
	mem.asmpatch(0x43c0f7, [[
	je absolute 0x43c105
	cmp eax, 138; limit of items in player's inventory
	jle @end
	mov dword [ds:esi], 0; erase wrong index
	jmp absolute 0x43c105
	@end:
	lea eax, [eax*8+eax];]])

	--mem.asmpatch(0x41a38a, [[
	--je absolute 0x41a4f1
	--cmp eax, dword [ds:0x454085];
	--jg absolute 0x41a4f1]])

	-- Prevent looting of items too far away from party.
	local function GetDist(x,y,z)
		local px, py, pz  = XYZ(Party)
		return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
	end

	mem.autohook2(0x468514, function(d)
		local obj = Mouse:GetTarget()
		if d.edx ~= obj.Index or (obj.Kind == 2 and GetDist(XYZ(Map.Objects[obj.Index])) > 500) then
			d:push(0x4686a5)
			return true
		end
	end)

	-- Remove artifacts found limit
	function events.LoadMap(WasInGame)
		if not WasInGame then
			for i,v in Party.ArtifactsFound do
				Party.ArtifactsFound[i] = false
				break
			end
		end
	end
	mem.nop(0x44dd82, 7)
	mem.nop(0x4541b4, 7)

	-- Fix GM staff usage with Unarmed skill (Damage bonus).
	local UNARMED = const.Skills.Unarmed
	function events.CalcStatBonusBySkills(t)
		if (t.Stat ~= const.Stats.MeleeDamageBase
			and t.Stat ~= const.Stats.MeleeDamageMin
			and t.Stat ~= const.Stats.MeleeDamageMax
			or t.Player.ItemMainHand == 0
			or t.Player.Skills[UNARMED] == 0)
		then
			return
		end

		local Item = t.Player.Items[t.Player.ItemMainHand]
		local ItemSkill = Game.ItemsTxt[Item.Number].Skill
		if Item.Broken or ItemSkill ~= 0 then return end

		local US, UM = SplitSkill(t.Player:GetSkill(UNARMED))
		local SS, SM = SplitSkill(t.Player:GetSkill(const.Skills.Staff))
		if UM < 2 or SM < 3 then return end

		local u_bonus = US
		if UM > 2 then
			u_bonus = US * 2
		end
		if u_bonus > SS then
			t.Result = t.Result + u_bonus - SS
		end
	end

	-- Repair unarmed skill dodge chance
	function events.GetArmorClass(t)
		local Skill, Mas = SplitSkill(t.Player:GetSkill(UNARMED))
		if Mas == 4 and math.random(1,100) < Skill then
			t.AC = 10000
		end
	end

	-- Fix Dragon's AC and Dmg bonuses by skill
	--
	local function GetPlayerFromPtr(ptr)
		local PlayerId = (ptr - Party.PlayersArray["?ptr"])/Party.PlayersArray[0]["?size"]
		return Party.PlayersArray[PlayerId], PlayerId
	end

	local function CheckDragonRace(d)
		local player = GetPlayerFromPtr(d.ecx)
		local race = player.Attrs and player.Attrs.Race
		if race and (Game.Races[race]
				and Game.Races[race].BaseRace == const.Race.Dragon) then
			d.eax = 1
		else
			d.eax = 0
		end
	end

	-- GetMeleeDamageRangeText
	NewCode = mem.asmpatch(0x48CC07, [[
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	jnz absolute 0x48CC1D
	]])
	mem.hook(NewCode, CheckDragonRace)

	-- GetRangedDamageRangeText
	NewCode = mem.asmpatch(0x48CCA4, [[
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	jnz absolute 0x48CC1D
	]])
	mem.hook(NewCode, CheckDragonRace)

	-- CalcStatBonusByItems
	NewCode = mem.asmpatch(0x48E2E5, [[
	mov ecx, edi
	nop
	nop
	nop
	nop
	nop
	cmp eax, 1
	]])
	mem.hook(NewCode + 2, CheckDragonRace)

	function events.CalcStatBonusBySkills(t)
		if t.Stat == const.Stats.MeleeAttack
			or t.Stat == const.Stats.MeleeDamageBase then

			local mas, skill = SplitSkill(t.Player:GetSkill(const.Skills.DragonAbility))
			t.Result = t.Result + skill*mas
		end
	end

	-- Make Dragon Attack to be of Fire damage type
	--   Undead/Ghost dragons produce Dark damage type
	mem.asmpatch(0x43710C, [[
	mov ax, word ptr [edi]
	cmp ax, 0x1F40
	mov dword ptr [ebp-0xC], 0
	jne @std
	mov dword ptr [ebp-0xC], 0xA
	@std:
	]])

	-- Make zombie/lich dragon breath white projectile
	function events.DragonBreathProjectile(t)
		local race = Party.PlayersArray[t.PlayerIndex].Attrs.Race
		if Game.Races[race].BaseRace == const.Race.Dragon
				and (Game.Races[race].Kind == const.RaceKind.Undead
				or Game.Races[race].Kind == const.RaceKind.Ghost) then
			t.ObjId = 8000
		end
	end

	-- Make regeneration skill and spell mm7-alike
	function events.RegenTick(Player)
		local Cond = Player:GetMainCondition()
		if Cond == 18 or Cond < 14 then
			local RegS, RegM = SplitSkill(Player:GetSkill(const.Skills.Regeneration))
			local RegP = RegS > 0 and 0.5 or 0
			RegP = RegP + RegS/10*RegM

			local Buff = Player.SpellBuffs[const.PlayerBuff.Regeneration]
			if Buff.ExpireTime > Game.Time then
				RegS, RegM = SplitSkill(Buff.Skill)
				RegP = RegP + RegS/10*RegM + 0.5
			end

			if RegP > 0 then
				local FHP = Player:GetFullHP()
				Player.HP = math.min(Player.HP + math.ceil(FHP*RegP/100), FHP)
			end
		end
	end

	-- Add a bit of sp regeneration by meditation skill
	function events.RegenTick(Player)
		local Cond = Player:GetMainCondition()
		if Cond == 18 or Cond == 17 or Cond < 14 then
			local RegS, RegM = SplitSkill(Player:GetSkill(const.Skills.Meditation))
			if RegM > 0 then
				local FSP	= Player:GetFullSP()
				--local RegP	= 0.25*(2^(RegM-1))/100
				--Player.SP	= math.min(FSP, Player.SP + math.ceil(FSP*RegP))
				local Add = RegM + math.floor(RegS/10)
				Player.SP = math.min(FSP, Player.SP + Add)
			end
		end
	end

	local function PartyCanLearn(skill)
		for _,pl in Party do
			if pl.Skills[skill] == 0 and GetMaxAvailableSkill(pl, skill) > 0 then
				return true
			end
		end
		return false
	end

	local function PlayerCanLearn(skill)
		local pl = Party[math.max(Game.CurrentPlayer,0)]
		return pl.Skills[skill] == 0 and GetMaxAvailableSkill(pl, skill) > 0
	end

	-- Correct learn skills in single-school guilds.
	function events.DrawLearnTopics(t)
		if (t.HouseType >= 5 and t.HouseType <= 8) then
			t.Handled = true
			t.NewTopics[1] = 0x2b + t.HouseType
			t.NewTopics[2] = const.LearnTopics.Learning
		elseif (t.HouseType >= 9 and t.HouseType <= 11) then
			t.Handled = true
			t.NewTopics[1] = 0x2b + t.HouseType
			t.NewTopics[2] = const.LearnTopics.Meditation
		end
	end

	-- For characters without SP factor, but with Meditation skill - add linear amount of SP
	local gameSPStats = Game.Classes.SPStats
	local statSP = const.Stats.SP
	function events.CalcStatBonusBySkills(t)
		if t.Stat == statSP and gameSPStats[t.Player.Class] == 0 then
			local Skill, Mas = SplitSkill(t.Player:GetSkill(const.Skills.Meditation))
			t.Result = Skill * Mas
		end
	end
	--   Add SP bonus from items if character without SP factor has Meditation
	NewCode = asmproc([[
	mov ecx, edi
	mov edx, 28
	call absolute ]] .. MO.GetPlayerSkillMastery .. [[;
	test eax, eax
	jz absolute 0x48DA98
	push 0
	push 8
	mov ecx, edi
	jmp absolute 0x48DA80
	]])

	mem.IgnoreProtection(true)
	mem.u4[0x48da9d] = NewCode
	mem.IgnoreProtection(false)

	-- Correct learn skills in temples and taverns
	function events.DrawLearnTopics(t)
		if t.HouseType == const.HouseType.Temple then
			t.Handled = true
			t.NewTopics[1] = const.LearnTopics.Unarmed
			t.NewTopics[2] = const.LearnTopics.Dodging
			t.NewTopics[3] = const.LearnTopics.Regeneration
			t.NewTopics[4] = const.LearnTopics.Merchant
		elseif t.HouseType == const.HouseType.Tavern then
			t.Handled = true
			t.NewTopics[1] = const.LearnTopics.DisarmTraps
			t.NewTopics[2] = const.LearnTopics.Perception
			t.NewTopics[3] = const.LearnTopics.Stealing
		end
	end

	-- Clean out map of removed corpses and summons by shrinking Map.Monsters table.
	function events.LoadMap(WasInGame)
		local lim = Map.Monsters.limit
		if WasInGame and Map.Monsters.count >= lim then
			local MonsToKeep = {}
			local size = Map.Monsters[0]["?size"]

			for i,v in Map.Monsters do
				if v.AIState ~= const.AIState.Removed and not (v.Summoner ~= 0 and v.HP <= 0) then
					table.insert(MonsToKeep, i)
				end
			end

			for i,v in ipairs(MonsToKeep) do
				if i ~= v + 1 then
					mem.copy(Map.Monsters[i-1]["?ptr"], Map.Monsters[v]["?ptr"], size)
				end
			end

			Map.Monsters.count = math.min(#MonsToKeep, lim)
		end
	end

	-- Repair Town hall's bounty hunt topic:
	BountyHuntFunctions = {}
	local BountyText = ""

	--[[
	local function CheckMon(MonId, MaxLevel)
		MaxLevel = MaxLevel or Party[0].LevelBase + 20
		return not Game.Bolster.MonstersSource[MonId].NoArena and Game.MonstersTxt[MonId].Level <= MaxLevel and not evt.CheckMonstersKilled{2, MonId - 1, 1}
	end
	BountyHuntFunctions.CheckMon = CheckMon

	local function old_MonstersForBountyHunt(MaxLevel)
		local MonId = random(1, Game.MonstersTxt.count - 1)
		local lim = 30
		local MaxLevel = Party[0].LevelBase + 20
		while not CheckMon(MonId, MaxLevel) and lim > 0 do
			MonId = random(1, Game.MonstersTxt.count - 1)
			lim = lim - 1
		end
		return MonId
	end
	BountyHuntFunctions.old_MonstersForBountyHunt = old_MonstersForBountyHunt
	]]

	local function MonstersForBountyHunt(MaxLevel)
		local list = {}
		local append = table.insert
		local MExtra = Game.Bolster.MonstersSource
		MaxLevel = MaxLevel or Party[0].LevelBase + 20
		for i, v in Game.MonstersTxt do
			if v.Level > MaxLevel or MExtra[i].NoArena or evt.CheckMonstersKilled{2, i - 1, 1} then
				-- skip
			else
				append(list, i)
			end
		end
		return list
	end
	BountyHuntFunctions.MonstersForBountyHunt = MonstersForBountyHunt

	local function NewBHSpawnPoint()
		local random = math.random
		local FacetIds, X, Y, Z
		local append = table.insert
		if Map.IsIndoor() and Map.Facets.count > 0 then
			local Facet, RoomsWFloors, RoomsWWalls = nil, {}, {}
			for i, Room in Map.Rooms do
				if Room.Floors.count > 0 then
					append(RoomsWFloors, Room)
				end
				if Room.Walls.count > 0 then
					append(RoomsWWalls, Room)
				end
			end

			if #RoomsWFloors > 0 then
				FacetIds = RoomsWFloors[random(1, #RoomsWFloors)].Floors
			elseif #RoomsWWalls > 0 then
				FacetIds = RoomsWWalls[random(1, #RoomsWFloors)].Walls
			else
				return random(-15000, 15000), random(-15000, 15000), 1000
			end

			Facet = Map.Facets[FacetIds[random(FacetIds.count-1)]]
			return Facet.MinX + (Facet.MaxX - Facet.MinX)/2, Facet.MinY + (Facet.MaxY - Facet.MinY)/2, Facet.MaxZ

		elseif Map.IsOutdoor() then
			X, Y, Z = random(-15000, 15000), random(-15000, 15000), 1000

			local Tile = Game.CurrentTileBin[Map.TileMap[(64 - Y / 0x200):floor()][(64 + X / 0x200):floor()]]
			local Cnt = 5
			while Cnt > 0 do
				if not Tile.Water then
					break
				end
				X, Y, Z = random(-15000, 15000), random(-15000, 15000), 1000
				Tile = Game.CurrentTileBin[Map.TileMap[(64 - Y / 0x200):floor()][(64 + X / 0x200):floor()]]
				Cnt = Cnt - 1
			end
		else
			X, Y, Z = random(-15000, 15000), random(-15000, 15000), 1000
		end
		return X, Y, Z
	end
	BountyHuntFunctions.NewBHSpawnPoint = NewBHSpawnPoint

	local function SetCurrentHunt()
		vars.BountyHunt = vars.BountyHunt or {}

		local MonId, BountyText, BountyHunt
		local random = math.random

		if vars.BountyHunt[Map.Name] and Game.Month == vars.BountyHunt[Map.Name].Month then
			-- If bounty hunt quest have laready been chosen for this month.
			MonId = vars.BountyHunt[Map.Name].MonId
			if not MonId then
				vars.BountyHunt[Map.Name] = nil
				BountyHuntFunctions.SetCurrentHunt()
			end

			if vars.BountyHunt[Map.Name].Done or evt.CheckMonstersKilled{2, MonId - 1, 1} then
				if vars.BountyHunt[Map.Name].Claimed then
					BountyText = Game.NPCText[135]
				else
					local Reward = Game.MonstersTxt[MonId].Level * 100
					BountyText = string.replace(Game.NPCText[134], "%lu", tostring(Reward))
					BountyText = string.format(BountyText, Game.MonstersTxt[MonId].Name, tostring(Reward))

					for i,v in Party do
						v.Awards[43] = true
					end

					evt.ForPlayer("Current")

					evt.Add{"Gold", Reward}
					evt.Add{"MontersHunted", Reward}
					evt.Subtract{"Reputation", math.ceil(Reward/2000)}

					vars.BountyHunt[Map.Name].Claimed = true
				end
			else
				BountyText = string.replace(Game.NPCText[133], "%lu", tostring(Game.MonstersTxt[MonId].Level * 100))
				BountyText = string.format(BountyText, Game.MonstersTxt[MonId].Name)
			end

		else
			-- Choose monster for new hunt.
			local Mons = BountyHuntFunctions.MonstersForBountyHunt()
			MonId = Mons[random(1, #Mons)]

			-- Create entry in list of bounty hunts.
			BountyText = string.replace(Game.NPCText[133], "%lu", tostring(Game.MonstersTxt[MonId].Level * 100))
			BountyText = string.format(BountyText, Game.MonstersTxt[MonId].Name)
			vars.BountyHunt[Map.Name] = {MonId = MonId, Month = Game.Month, Claimed = false, Done = false}

			-- Summon monster
			local X, Y, Z = BountyHuntFunctions.NewBHSpawnPoint()
			local mon = SummonMonster(MonId, X, Y, Z)
			mon.Group = 39
			mon.Hostile = true
			mon.HostileType = 4

			-- Make monster berserk to encourage it to fight everything around (peasants, guards, player)
			local MonBuff = mon.SpellBuffs[const.MonsterBuff.Berserk]
			MonBuff.ExpireTime = Game.Time + const.Month
			MonBuff.Power = 4
			MonBuff.Skill = 4
			MonBuff.Caster = -1
		end

		return BountyText
	end
	BountyHuntFunctions.SetCurrentHunt = SetCurrentHunt

	function events.LeaveMap()
		if not vars.BountyHunt then return end
		for k,v in pairs(vars.BountyHunt) do
			if v.MonId then
				v.Done = v.Claimed or v.Done or evt.CheckMonstersKilled{2, v.MonId - 1, 1}
			else
				vars.BountyHunt[k] = nil
			end
		end
	end

	NewCode = mem.asmproc([[
	nop
	nop
	nop
	nop
	nop
	jmp absolute 0x4bb3f0]])
	mem.asmpatch(0x4bae73, "jmp absolute " .. NewCode)
	mem.hook(NewCode, function(d)
		BountyText = BountyHuntFunctions.SetCurrentHunt()
		mem.u4[0xffd410] = mem.topointer(BountyText)
	end)

	-- Allow to switch between Party members in NPC screen
	mem.asmpatch(0x420D01, [[
	jz absolute 0x420E40
	cmp ecx, 4
	jnz absolute 0x420D07
	cmp dword ptr [0x519350], esi
	jz absolute 0x420F27
	xor ebx, ebx
	inc ebx
	mov dword ptr [0x587ADC], ebx
	jmp absolute 0x420F21
	]])

	-- Restrict Fly vertical movement in turn-base mode
	local tb_fly_abuse = Merge and Merge.Settings and Merge.Settings.Abuse
		and Merge.Settings.Abuse.TurnBasedFly or false
	if not tb_fly_abuse then
		--   Fly: Up
		mem.asmpatch(0x42EB89, [[
		jnz absolute 0x42EC44
		cmp dword ptr [0xB21728], edi
		jnz @end
		cmp dword ptr [0x509C9C], 3
		jnz absolute 0x42EC44
		cmp dword ptr [0x509CAC], ebx
		jle absolute 0x42EC44
		sub dword ptr [0x509CAC], 0x1A
		@end:
		]])

		--   Fly: Land
		mem.asmpatch(0x42EC1A, [[
		cmp dword ptr [0x51D33C], ebx
		jnz absolute 0x42EC44
		cmp dword ptr [0xB21728], edi
		jnz @end
		cmp dword ptr [0x509C9C], 3
		jnz absolute 0x42EC44
		cmp dword ptr [0x509CAC], 0x82
		jl absolute 0x42EC44
		sub dword ptr [0x509CAC], 0x82
		@end:
		]])
		mem.nop(0x42EC20, 2)

		--   Fly: Down
		mem.asmpatch(0x42EC2E, [[
		cmp dword ptr [0x51D33C], ebx
		jnz absolute 0x42EC44
		cmp dword ptr [0xB21728], edi
		jnz @end
		cmp dword ptr [0x509C9C], 3
		jnz absolute 0x42EC44
		cmp dword ptr [0x509CAC], ebx
		jle absolute 0x42EC44
		sub dword ptr [0x509CAC], 0x1A
		@end:
		]])
		mem.nop(0x42EC34, 2)
	end

	-- Add experience to party if monster was killed by reanimated monster
	function events.MonsterKilled(mon, monIndex, defaultHandler, killer)
		if not Merge.ModSettings.ExpFromKillByReanimated
				or Merge.ModSettings.ExpFromKillByReanimated == 0 then
			return
		end
		if killer.Type == 3 and killer.Monster.Ally == 9999 and mon.Ally ~= 9999 then
			mem.call(0x424D5B, 1, mon.Experience)
		end
	end

	-- Shrink skills table in Player Skills Panel
	local interskill = 5
	--   skills
	asmpatch(0x418DA4, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x418EAC, [[
	sub eax, ]] .. interskill)
	asmpatch(0x419006, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x419091, [[
	sub eax, ]] .. interskill)
	asmpatch(0x419102, [[
	lea ecx, [ecx + edx + 1]
	]])
	asmpatch(0x419151, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x419259, [[
	sub eax, ]] .. interskill)
	asmpatch(0x41931E, [[
	sub eax, ]] .. interskill)
	asmpatch(0x4193B3, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x41943E, [[
	sub eax, ]] .. interskill)
	asmpatch(0x4194F1, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x4195F9, [[
	sub eax, ]] .. interskill)
	asmpatch(0x4196BE, [[
	sub eax, ]] .. interskill)
	asmpatch(0x419753, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x4197DE, [[
	sub eax, ]] .. interskill)
	asmpatch(0x41984F, [[
	lea ecx, [ecx + edx + 1]
	]])
	asmpatch(0x419894, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x41999C, [[
	sub eax, ]] .. interskill)
	asmpatch(0x419A61, [[
	sub eax, ]] .. interskill)
	asmpatch(0x419AF6, [[
	lea eax, [ecx + eax - ]] .. interskill .. "]")
	asmpatch(0x419B81, [[
	sub eax, ]] .. interskill)
	--   headers
	asmpatch(0x419E6B, [[
	lea ebx, [ebx + ecx - ]] .. interskill .. "]")
	asmpatch(0x419E88, [[
	lea ebx, [ebx + ecx - ]] .. interskill .. "]")
	asmpatch(0x419E9C, [[
	lea ebx, [ebx + eax - 1]
	]])
	asmpatch(0x419F37, [[
	lea ebx, [ebx + ecx - ]] .. interskill .. "]")
	asmpatch(0x419F54, [[
	lea ebx, [ebx + ecx - ]] .. interskill .. "]")
	asmpatch(0x419F68, [[
	lea ebx, [ebx + eax - 1]
	]])

