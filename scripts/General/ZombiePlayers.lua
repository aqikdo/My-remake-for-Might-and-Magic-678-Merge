local LogId = "ZombiePlayers"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)

local floor, max, min, random = math.floor, math.max, math.min, math.random

function events.GameInitialized2()

	---- Reorganize priority of main conditions.
	local MainCondOrder = {
		const.Condition.Eradicated,
		const.Condition.Dead,
		const.Condition.Stoned,
		const.Condition.Unconscious,
		const.Condition.Asleep,
		const.Condition.Paralyzed,

		const.Condition.Disease3,
		const.Condition.Poison3,
		const.Condition.Disease2,
		const.Condition.Poison2,
		const.Condition.Disease1,
		const.Condition.Poison1,

		const.Condition.Zombie,
		const.Condition.Insane,
		const.Condition.Drunk,
		const.Condition.Afraid,
		const.Condition.Weak,
		const.Condition.Cursed
	}

	for i,v in ipairs(MainCondOrder) do
		mem.u4[0x4fdfa4 + i*4] = v
	end

	---- Make Zombies immune to some diseases and mental conditions.
	local ZombieImmunities = {
		const.Condition.Asleep,
		const.Condition.Disease3,
		const.Condition.Disease2,
		const.Condition.Disease1,
		const.Condition.Insane,
		const.Condition.Drunk,
		const.Condition.Afraid,
		const.Condition.Weak
	}

	function events.DoBadThingToPlayer(t)
		if t.Player.Conditions[17] > 0 and table.find(ZombieImmunities, t.Thing) then
			t.Allow = false
		end
	end

	---- Portrait switches.

	-- Keep drawing face animations if character is in zombie condition
	-- and switch portrait according to condition.
	NewCode = mem.asmpatch(0x48fb90, [[
	mov ecx, eax

	; Get face
	movzx eax, byte [ds:esi+0x353]

	; Get race
	imul eax, eax, ]] .. Game.CharacterPortraits[0]["?size"] ..[[;
	add eax, ]] .. Game.CharacterPortraits["?ptr"] .. [[;
	add eax, 0x3f; race value offset
	movzx eax, byte [ds:eax]

	; cmp eax, const.Race.Zombie ;
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	mov eax, dword [ds:esi+0x88]
	jne @Zom

	test eax, eax
	jnz @SetFace
	jmp @std

	@Zom:
	test eax, eax
	jnz @std

	@SetFace:
	nop
	nop
	nop
	nop
	nop

	@std:
	mov eax, ecx
	mov ecx, esi
	cmp eax, 0x12
	je absolute 0x48fcb4
	cmp eax, 0x11
	je absolute 0x48fcb4]])

	local function GetZombieFace(Race, Sex)
		local ZombieFaces = {
			[const.Race.Human]	= {[0] = 59, [1] = 60},
			[const.Race.DarkElf]	= {[0] = 59, [1] = 60},
			[const.Race.Minotaur]	= {[0] = 70, [1] = 70},
			[const.Race.Troll]	= {[0] = 76, [1] = 76},
			[const.Race.Dragon]	= {[0] = 68, [1] = 68},
			[const.Race.Elf]	= {[0] = 59, [1] = 60},
			[const.Race.Goblin]	= {[0] = 59, [1] = 60},
			[const.Race.Dwarf]	= {[0] = 72, [1] = 73},
		}
		if Game.Races[Race].Family == const.RaceFamily.Undead
				or Game.Races[Race].Family == const.RaceFamily.Ghost then
			return nil
		end
		--if Game.Races[Race].Family == const.RaceFamily.Vampire
		--		or Game.Races[Race].Family == const.RaceFamily.Zombie then
		--	return ZombieFaces[Game.Races[Race].BaseRace][Sex]
		--end
		return ZombieFaces[Game.Races[Race].BaseRace][Sex]
	end


	local function SetFace(PlayerId)
		local Player = Party.PlayersArray[PlayerId]
		local CurrentPlayer = 0

		for k,v in Party.PlayersIndexes do
			if v == PlayerId then
				CurrentPlayer = k
			end
		end

		vars.PlayerFaces = vars.PlayerFaces or {}

		if Player.Conditions[const.Condition.Zombie] > 0 then
			local Portrait = Game.CharacterPortraits[Player.Face]

			if Game.Races[Portrait.Race].Family ~= const.RaceFamily.Zombie then
				vars.PlayerFaces[PlayerId] = {Face = Player.Face, Voice = Player.Voice}
			end

			--local OrigPortrait = Game.CharacterPortraits[vars.PlayerFaces[PlayerId].Face]
			local OrigPortrait = vars.PlayerFaces[PlayerId]
				and Game.CharacterPortraits[vars.PlayerFaces[PlayerId].Face] or nil
			if OrigPortrait then
				local NewFace = GetZombieFace(OrigPortrait.Race, OrigPortrait.DefSex)

				if NewFace then
					Player.Face = NewFace
					SetCharFace(CurrentPlayer, NewFace)
					if Merge.Settings.Conversions.KeepVoiceOnZombification ~= 1 then
						Player.Voice = Game.CharacterPortraits[NewFace].DefVoice
					end
				else
					Player.Conditions[const.Condition.Zombie] = 0
					Player.Conditions[const.Condition.Dead] = Game.Time
				end
			end
		else
			local NewFace = vars.PlayerFaces[PlayerId]
			if NewFace then
				Player.Face = NewFace.Face
				SetCharFace(CurrentPlayer, NewFace.Face)
				Player.Voice = NewFace.Voice
			end
			--if Game.Races[Game.CharacterPortraits[Player.Face].Race].Family == const.RaceFamily.Zombie then
			--	Player.Conditions[const.Condition.Zombie] = Game.Time
			--end
		end
	end

	mem.hook(NewCode + 0x17, function(d)
		d.eax = Game.Races[d.eax] and (Game.Races[d.eax].Family == const.RaceFamily.Zombie)
	end)

	mem.hook(NewCode + 0x30, function(d)
		local PlayerId	= (d.esi - Party.PlayersArray["?ptr"])/Party.PlayersArray[0]["?size"]
		SetFace(PlayerId)
	end)

	-- Make direct heals harm zombified characters.
	mem.asmpatch(0x48d048, [[
	cmp dword [ds:esi+0x88], 0x0
	je @std
	sub dword [ds:esi+0x1bf8], ecx
	jmp @end

	@std:
	add dword [ds:esi+0x1bf8], ecx
	@end:
	]])

	-- Make Divine Intervention cure zombie condition aswell.
	mem.asmpatch(0x42be4a, [[
	push 0x20
	pop ecx
	mov esi, eax
	mov dword [ds:eax+0x88], 0
	]])

	-- Make cure of zombie condition same expensive as eradication.
	local IsDarkTemplePtr = mem.StaticAlloc(1)
	mem.asmpatch(0x4b661b, [[
	; don't increase cost in dark temples
	cmp byte [ds:]] .. IsDarkTemplePtr .. [[], 1
	je @std

	cmp eax, 0x11
	je absolute 0x4b662a

	@std:
	cmp eax, 0xe
	jl absolute 0x4b6648]])

	-- Dark temples will reanimate players instead of reviving.
	local IsDarkTemple = false
	function events.EnterHouse(i)
		local House = Game.Houses[i]
		IsDarkTemple = House.Type == const.HouseType.Temple and (House.C == 2 or House.C == 3)
		mem.u1[IsDarkTemplePtr] = IsDarkTemple
	end

	local function NeedHealDark(Player)
		local Conditions = Player.Conditions
		local Race = GetCharRace(Player)

		if (Conditions[const.Condition.Dead] > 0 or Conditions[const.Condition.Eradicated] > 0)
				and Game.Races[Race].Family ~= const.RaceFamily.Undead
				and Game.Races[Race].Family ~= const.RaceFamily.Ghost
				and not GetZombieFace(Race, Player:GetSex()) then
			return false
		end

		local NeedHeal = false
		for i = 0, 16 do
			if Conditions[i] > 0 then
				NeedHeal = true
				break
			end
		end

		local NeedHeal = NeedHeal or (Player.HP < Player:GetFullHP()) or (Player.SP < Player:GetFullSP())
		return NeedHeal
	end

	function events.ClickShopTopic(t)

		if IsDarkTemple and t.Topic == const.ShopTopics.Heal then

			local PlayerId = max(Game.CurrentPlayer, 0)
			local cPlayer  = Party[PlayerId]

			if not NeedHealDark(cPlayer) then
				t.Handled = true
				return
			end

			local Cost
			local Conditions = cPlayer.Conditions

			if Conditions[const.Condition.Dead] > 0 then
				Cost = Game.Houses[t.HouseId].Val*5
			elseif Conditions[const.Condition.Eradicated] > 0 then
				Cost = Game.Houses[t.HouseId].Val*10
			elseif Conditions[const.Condition.Zombie] > 0 then
				Cost = Game.Houses[t.HouseId].Val
			end

			if Cost and evt.Subtract{"Gold", Cost} then
				t.Handled = true
				cPlayer.HP = cPlayer:GetFullHP()
				cPlayer.SP = cPlayer:GetFullSP()
				evt.ForPlayer(PlayerId).Set{"MainCondition", 1}
				if Game.Races[GetCharRace(cPlayer)].Family ~= const.RaceFamily.Undead
						and Game.Races[GetCharRace(cPlayer)].Family ~= const.RaceFamily.Ghost then
					Conditions[const.Condition.Zombie] = Game.Time
					SetFace(Party.PlayersIndexes[PlayerId])
				end
			end
		end
	end

	function events.CanShowHealTopic(t)
		if not IsDarkTemple then
			return
		end

		t.CanShow = NeedHealDark(Party[max(Game.CurrentPlayer, 0)])
	end

	-- "Reanimate" spell will raise dead players as zombies
	local u2 = mem.u2
	function events.Action(t)

		if Game.CurrentScreen == 20 and t.Action == 110 then

			local Spell = u2[0x51d820]

			if Spell == 0x59 then -- reanimate

				local Caster = Party.PlayersArray[u2[0x51d822]]
				local Target = Party[t.Param-1]
				local Race = GetCharRace(Target)

				if Target.Conditions[const.Condition.Dead] > 0 and Caster.SP >= 10
						and (Game.Races[Race].Family == const.RaceFamily.Undead
						or Game.Races[Race].Family == const.RaceFamily.Ghost
						or GetZombieFace(Race, Target:GetSex())) then

					t.Handled = true

					local Skill, Mas = SplitSkill(Caster:GetSkill(const.Skills.Dark))
					local resultHP = Skill*(10+10*Mas)

					if resultHP + Target.HP > 0 and resultHP > Target:GetFullHP()/2 then
						-- Success
						evt.PlaySound{18000}
						Caster:ShowFaceAnimation(const.FaceAnimation.CastSpell)
						Target.HP = min(Target:GetFullHP(), resultHP + Target.HP)

						for k,v in pairs(ZombieImmunities) do
							Target.Conditions[v] = 0
						end

						Target.Conditions[const.Condition.Unconscious] = 0
						Target.Conditions[const.Condition.Paralyzed] = 0
						Target.Conditions[const.Condition.Dead] = 0

						if (Game.Races[Race].Family ~= const.RaceFamily.Undead)
								and (Game.Races[Race].Family ~= const.RaceFamily.Ghost) then
							Target.Conditions[const.Condition.Zombie] = Game.Time
							SetFace(Party.PlayersIndexes[t.Param-1])
						end
					else
						-- Not enough skill
						evt.PlaySound{136}
						Caster:ShowFaceAnimation(const.FaceAnimation.SpellFailed)
						Game.ShowStatusText(Game.GlobalTxt[750])
					end

					Caster:SetRecoveryDelay(180)
					Caster.SP = Caster.SP - 10

				else -- Not enough SP or wrong target

					evt.PlaySound{136}
					Game.ShowStatusText(Game.GlobalTxt[586])
					Caster:ShowFaceAnimation(const.FaceAnimation.SpellFailed)
					Game.NeedRedraw = true

				end

				u2[0x51d820] = 0
				ExitCurrentScreen()

			end
		end
	end

	local chance = Merge and Merge.Settings and Merge.Settings.Conversions
		and Merge.Settings.Conversions.ZombieZombificationChance or 0
	local StatEffect = Game.GetStatisticEffect
	local MindRes, DarkRes = const.Stats.MindResistance, const.Stats.DarkResistance
	function events.RegenTick(player)
		if Game.Races[player.Attrs.Race]
				and Game.Races[player.Attrs.Race].Family == const.RaceFamily.Zombie
				and player.Conditions[const.Condition.Zombie] == 0 then
			if chance == 0 then
				return
			end
			local base = StatEffect(player:GetResistance(MindRes) + 13)
				+ StatEffect(player:GetResistance(DarkRes) + 13)
			base = 10 * (base + StatEffect(player:GetLuck())) + 1000
			local rnd = random(base)
			--Log(Merge.Log.Info, "Zombie zombification: %d, %d, %d", rnd, chance, base)
			if rnd <= chance then
				player.Conditions[const.Condition.Zombie] = Game.Time
			end
		end
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
