local LogId = "SpellsExtra"
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM, MO, MT = Merge.Functions, Merge.ModSettings, Merge.Offsets, Merge.Tables

local floor, min = math.floor, math.min
local asmpatch, hook, nop2, u2, u4 = mem.asmpatch, mem.hook, mem.nop2, mem.u2, mem.u4
local max_spell = 132

local function GetMonster(ptr)
	local MonId = (ptr - Map.Monsters[0]["?ptr"]) / Map.Monsters[0]["?size"]
	local Mon = Map.Monsters[MonId]
	return Mon, MonId
end

local function ProcessSpellsExtraTxt()
	local spells_extra_tbl = {}
	local TableFile = "Data/Tables/SpellsExtra.txt"
	local null_tbl = {Mastery = 0, Level = 0}
	local masteries = {B = 1, E = 2, M = 3, G = 4}

	local TxtTable = io.open(TableFile, "r")
	if not TxtTable then
		TxtTable = io.open(TableFile, "w")
		TxtTable:write("#\9Spell\9ChanceBaseNormal\9ChanceFactorNormal\9ChanceMaxNormal\9ChanceCursedNormal")
		TxtTable:write("\9ChanceBaseExpert\9ChanceFactorExpert\9ChanceMaxExpert\9ChanceCursedExpert")
		TxtTable:write("\9ChanceBaseMaster\9ChanceFactorMaster\9ChanceMaxMaster\9ChanceCursedMaster")
		TxtTable:write("\9ChanceBaseGM\9ChanceFactorGM\9ChanceMaxGM\9ChanceCursedGM")
		TxtTable:write("\9Var1\9Var1Normal\9Var1Expert\9Var1Master\9Var1GM\9Var2\9Var2Normal")
		TxtTable:write("\9Var2Expert\9Var2Master\9Var2GM\n")
		for i = 1, max_spell do
			TxtTable:write(i .. "\9" .. Game.SpellsTxt[i].Name)
			if i < 100 then
				TxtTable:write("\009100\0090\009100\00950\009100\0090\009100\00950\009100\0090\009100\00950\009100\0090\009100\00950\n")
			else
				TxtTable:write("\009100\0090\009100\009100\009100\0090\009100\009100\009100\0090\009100\009100\009100\0090\009100\009100\n")
			end
			spells_extra_tbl[i] = {
				ChanceBase = {100, 100, 100, 100},
				ChanceFactor = {0, 0, 0, 0},
				ChanceMax = {100, 100, 100, 100},
				ChanceCursed = i < 100 and {50, 50, 50, 50} or {100, 100, 100, 100},
			}
		end
	else
		local iter = TxtTable:lines()
		iter()	-- skip header
		for line in iter do
			local words = string.split(line, "\9")
			if string.len(words[1]) == 0 then
				break
			end
			if tonumber(words[1]) then
				local spell = tonumber(words[1])
				spells_extra_tbl[spell] = {
					ChanceBase = {
						words[3] and tonumber(words[3]),
						words[7] and tonumber(words[7]),
						words[11] and tonumber(words[11]),
						words[15] and tonumber(words[15])
					},
					ChanceFactor = {
						words[4] and tonumber(words[4]),
						words[8] and tonumber(words[8]),
						words[12] and tonumber(words[12]),
						words[16] and tonumber(words[16])
					},
					ChanceMax = {
						words[5] and tonumber(words[5]),
						words[9] and tonumber(words[9]),
						words[13] and tonumber(words[13]),
						words[17] and tonumber(words[17])
					},
					ChanceCursed = {
						words[6] and tonumber(words[6]),
						words[10] and tonumber(words[10]),
						words[14] and tonumber(words[14]),
						words[18] and tonumber(words[18])
					},
					Var1Normal = words[20] and tonumber(words[20]),
					Var1Expert = words[21] and tonumber(words[21]),
					Var1Master = words[22] and tonumber(words[22]),
					Var1GM = words[23] and tonumber(words[23]),
					Var2Normal = words[25] and tonumber(words[25]),
					Var2Expert = words[26] and tonumber(words[26]),
					Var2Master = words[27] and tonumber(words[27]),
					Var2GM = words[28] and tonumber(words[28]),
					Var3Normal = words[30] and tonumber(words[30]),
					Var3Expert = words[31] and tonumber(words[31]),
					Var3Master = words[32] and tonumber(words[32]),
					Var3GM = words[33] and tonumber(words[33]),
					Var4Normal = words[35] and tonumber(words[35]),
					Var4Expert = words[36] and tonumber(words[36]),
					Var4Master = words[37] and tonumber(words[37]),
					Var4GM = words[38] and tonumber(words[38]),
				}
			end
		end
	end
	io.close(TxtTable)
	MT.SpellsExtra = spells_extra_tbl
end

local function SetSpellsExtraHooks()
	local scroll_chance, scroll_cursed = {
		MM.ScrollChanceNormal and tonumber(MM.ScrollChanceNormal) or 100,
		MM.ScrollChanceExpert and tonumber(MM.ScrollChanceExpert) or 100,
		MM.ScrollChanceMaster and tonumber(MM.ScrollChanceMaster) or 100,
		MM.ScrollChanceGM and tonumber(MM.ScrollChanceGM) or 100,
	}, {
		MM.ScrollChanceCursedNormal and tonumber(MM.ScrollChanceCursedNormal) or 50,
		MM.ScrollChanceCursedExpert and tonumber(MM.ScrollChanceCursedExpert) or 50,
		MM.ScrollChanceCursedMaster and tonumber(MM.ScrollChanceCursedMaster) or 50,
		MM.ScrollChanceCursedGM and tonumber(MM.ScrollChanceCursedGM) or 50,
	}
	-- Check abilities for sufficient SP as well
	asmpatch(0x4262C5, [[
	mov eax, dword ptr [ebp-0x1C]
	cmp cx, 0x85
	]])
	-- Spell fail check
	local new_code = asmpatch(0x4262EC, [[
	cmp cx, 0x85
	jge absolute 0x42630D
	xor ecx, ecx
	mov edx, [eax]
	or edx, [eax+4]
	setnz cl
	push ecx
	call absolute 0x4D99F2
	push 0x64
	cdq
	pop ecx
	idiv ecx
	movzx ecx, word ptr [ebx]
	pop eax
	inc edx
	push edi
	push 0x64
	pop edi
	cmp ecx, edi
	jge @one
	test eax, eax
	jz @one
	push 0x32
	pop edi
	@one:
	nop
	nop
	nop
	nop
	nop
	cmp edi, edx
	pop edi
	]], 0x426307 - 0x4262EC)
	hook((new_code or 0x4262EC) + 0x35, function(d)
		local t = {Spell = d.ecx, Roll = d.edx, Cursed = d.eax > 0,
			Mastery = u4[d.ebp - 0xC], Level = u4[d.ebp - 0x3C]}
		local flags = u2[d.ebx + 8]
		t.Type = u2[d.ebx + 0xA] > 0 and (bit.band(flags, 0x1) > 0 and 1 or (bit.band(flags, 0x20) > 0 and 2 or 3)) or 0
		t.Player, t.PlayerIndex = MF.GetPlayerFromPtr(u4[d.ebp - 0x1C])
		if t.Type == 0 then
			local SE = MT.SpellsExtra[t.Spell]
			t.Chance = SE
				and (min(SE.ChanceBase[t.Mastery]
					+ SE.ChanceFactor[t.Mastery] * t.Level,
					(t.Cursed and SE.ChanceCursed[t.Mastery] or SE.ChanceMax[t.Mastery])))
				or d.edi
		elseif t.Type == 1 then
			if t.Cursed then
				t.Chance = scroll_cursed[t.Mastery]
			else
				t.Chance = scroll_chance[t.Mastery]
			end
		else
			t.Chance = 100
		end
		events.call("SpellFailCheck", t)
		d.edi = t.Chance
	end)
	-------- Player Spell Var event --------
	local function player_spell_var(d, num, value)
		local t = {Spell = u2[d.ebx], VarNum = num, Value = value and value[1] or d.eax, Target = u4[d.ebp - 0x30]}
		local flags = u2[d.ebx + 8]
		t.Type = u2[d.ebx + 0xA] > 0 and (bit.band(flags, 0x1) > 0 and 1 or (bit.band(flags, 0x20) > 0 and 2 or 3)) or 0
		t.Player, t.PlayerIndex = MF.GetPlayerFromPtr(u4[d.ebp - 0x1C])
		events.call("PlayerSpellVar", t)
		if value then
			value[1] = t.Value
		else
			d.eax = t.Value
		end
	end
	local function player_spell_var1(d)
		player_spell_var(d, 1)
	end
	local function player_spell_var2(d)
		player_spell_var(d, 2)
	end
	local function player_spell_var3(d)
		player_spell_var(d, 3)
	end
	local function immolation_spell_var(d)
		player_spell_var(d, 1)
		local pl, plin = MF.GetPlayerFromPtr(u4[d.ebp - 0x1C])
		for i,v in Party do
			if v == pl then
				vars.PlayerCastImmolation = i
			end
		end
	end
	-------- 1: Torch Light --------
	new_code = asmpatch(0x426612, [[
	mov eax, dword ptr [ebp - 0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[1].Var1GM or 3600) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[1].Var1Master or 3600) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[1].Var1Expert or 3600) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[1].Var1Normal or 3600) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul edi
	]])
	hook(new_code + 0x26, player_spell_var1)
	-- fix buff caster
	asmpatch(0x426636, [[
	inc eax
	push eax
	]])
	asmpatch(0x42663E, "push esi")

	-------- Resistances: 3, 14, 25, 36, 58, 69 --------
	new_code = asmpatch(0x427438, [[
	mov eax, dword ptr [ebp-0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, 4
	jmp @end
	@master:
	mov eax, 3
	jmp @end
	@expert:
	mov eax, 2
	jmp @end
	@normal:
	mov eax, 1
	@end:
	nop
	nop
	nop
	nop
	nop
	imul edi
	mov dword ptr [ebp - 4], eax
	mov eax, 0xE10
	nop
	nop
	nop
	nop
	nop
	imul edi
	mov dword ptr [ebp - 0x14], eax
	mov dword ptr [ebp - 0x10], edx
	]], 0x42746D - 0x427438)
	hook((new_code or 0x427438) + 0x26, function(d)
		local spell, mastery = d.ecx, u4[d.ebp - 0xC]
		if spell == 3 then
			vars.HammerhandDamageType = const.Damage.Fire
		elseif spell == 14 then
			vars.HammerhandDamageType = const.Damage.Air
		elseif spell == 25 then
			vars.HammerhandDamageType = const.Damage.Water
		elseif spell == 36 then
			vars.HammerhandDamageType = const.Damage.Earth
		elseif spell == 58 then
			vars.HammerhandDamageType = const.Damage.Mind
		elseif spell == 69 then
			vars.HammerhandDamageType = const.Damage.Body
		end
		d.eax = MT.SpellsExtra[spell]["Var1" .. select(mastery, "Normal", "Expert", "Master", "GM")] or d.eax
		player_spell_var(d, 1)
	end)
	hook((new_code or 0x427438) + 0x35, function(d)
		local spell, mastery = d.ecx, u4[d.ebp - 0xC]
		d.eax = MT.SpellsExtra[spell]["Var2" .. select(mastery, "Normal", "Expert", "Master", "GM")] or d.eax
		player_spell_var(d, 2)
	end)
	-- do not use spells 17,38,51 code
	asmpatch(0x427525, [[
	call absolute 0x4D967C
	mov ecx, dword ptr [ebp - 0x20]
	add eax, dword ptr [0xB20EBC]
	adc edx, dword ptr [0xB20EC0]
	shl ecx, 4
	add ecx, 0xB21738
	jmp absolute 0x42665C
	]])

	-------- 4: Fire Aura --------
	new_code = asmpatch(0x42720D, [[
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[4].Var1GM or 12) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[4].Var2GM or 3600) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[4].Var1Master or 12) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[4].Var2Master or 3600) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[4].Var1Expert or 11) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[4].Var2Expert or 3600) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[4].Var1Normal or 10) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[4].Var2Normal or 3600) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	mov eax, ecx
	nop
	nop
	nop
	nop
	nop
	imul edi
	]], 0x427249 - 0x42720D)
	hook((new_code or 0x42720D) + 0x36, player_spell_var1)
	hook((new_code or 0x42720D) + 0x40, player_spell_var2)
	-- Permanent bonus if duration is 0
	asmpatch(0x4272E4, [[
	mov eax, dword ptr [ebp - 0x14]
	mov edx, dword ptr [ebp - 0x10]
	or eax, edx
	mov eax, dword ptr [ebp - 4]
	]])
	-------- 5: Haste --------
	new_code = asmpatch(0x42752D, [[
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[5].Var2GM or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[5].Var1GM or 240) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[5].Var2Master or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[5].Var1Master or 180) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[5].Var2Expert or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[5].Var1Expert or 60) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[5].Var2Normal or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[5].Var1Normal or 60) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	mov eax, ecx
	mov ecx, dword ptr [ebp - 4]
	nop
	nop
	nop
	nop
	nop
	imul edi
	add eax, ecx
	adc edx, 0
	]], 0x42755D - 0x42752D)
	hook((new_code or 0x42752D) + 0x37, player_spell_var2)
	hook((new_code or 0x42752D) + 0x44, player_spell_var1)
	-- Use player SpellBuff instead of party one
	asmpatch(0x4275BD, [[
	cmp dword ptr [ebp - 0xC], 1
	jg @party
	movzx eax, word ptr [ebx + 4]
	mov dword ptr [ebp - 0x24], eax
	mov dword ptr [ebp - 0x8], eax
	jmp @common
	@party:
	mov ecx, 0xB20E90
	call absolute 0x42D776
	mov dword ptr [ebp - 0x24], eax
	mov dword ptr [ebp - 0x8], 0
	@common:
	fild qword ptr [ebp - 0x14]
	fmul dword ptr [0x4E8568]
	call absolute 0x4D967C
	add eax, dword ptr [0xB20EBC]
	adc edx, dword ptr [0xB20EC0]
	mov dword ptr [ebp - 0x17C], eax
	mov dword ptr [ebp - 0x178], edx
	;movsx edi, word ptr [ebx + 2]
	;inc edi

	@loop:
	push esi
	;push edi
	push esi
	push esi
	push dword ptr [ebp - 0xC]
	mov eax, dword ptr [ebp - 0x17C]
	mov edx, dword ptr [ebp - 0x178]
	push edx
	push eax
	push dword ptr [ebp - 0x8]
	mov ecx, 0xB20E90
	call absolute 0x4026F4
	mov ecx, eax
	add ecx, 0x1AA4
	call absolute 0x455D97
	push dword ptr [ebp - 0x8]
	movzx eax, word ptr [ebx]
	push eax
	mov ecx, dword ptr [0x75CE00]
	call absolute 0x42D747
	mov ecx, eax
	call absolute 0x4A6FCE
	inc dword ptr [ebp - 0x8]
	mov eax, dword ptr [ebp - 0x24]
	cmp eax, dword ptr [ebp - 0x8]
	jg @loop
	]], 0x427643 - 0x4275BD)
	-------- 7: Fire Spike --------
	new_code = asmpatch(0x42666D, [[
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[7].Var1GM or 9) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[7].Var1Master or 7) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[7].Var1Expert or 5) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[7].Var1Normal or 3) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	]], 0x426697 - 0x42666D)
	hook((new_code or 0x42666D) + 0x21, player_spell_var1)

	-------- 8: Immolation --------
	
	new_code = asmpatch(0x427A65, [[
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[8].Var1GM or 600) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[8].Var1Master or 60) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[8].Var1Expert or 30) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[8].Var1Normal or 10) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul edi
	]], 0x427A7C - 0x427A65)
	hook((new_code or 0x427A65) + 0x21, immolation_spell_var)

	-------- 9: Meteor Shower --------
	new_code = asmpatch(0x427B1B, [[
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[9].Var1GM or 20) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[9].Var1Master or 16) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[9].Var1Expert or 12) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[9].Var1Normal or 8) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp-0x34], eax
	]], 0x427B36 - 0x427B1B)
	hook((new_code or 0x427B1B) + 0x22, player_spell_var1)
	
	-------- 10: Inferno
	
	local function GetDist(t,x,y,z)
		local px, py, pz  = XYZ(t)
		return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
	end
	
	local function InDist(Mon)
		if Mon.Active and Mon.HP > 0 then
			if GetDist(Mon, Party.X, Party.Y, Party.Z) < 5000 then
				return true
			end
		end
		return false
	end
	
	local function InFrontOfParty(Mon)
		local Angle = math.atan2(Mon.Y - Party.Y,Mon.X - Party.X)
		if Angle < 0 then
			Angle = Angle + math.pi * 2
		end
		local PartyAngle = Party.Direction / 1024 * math.pi
		local MaxDif = math.pi / 3
		if math.abs(Angle - PartyAngle) < MaxDif or math.abs(Angle + 2 * math.pi - PartyAngle) < MaxDif or math.abs(Angle - 2 * math.pi - PartyAngle) < MaxDif then
			return true
		else
			return false
		end
	end
	
--	mem.nop(0x427F5C, 2)
	local function Test(d)
		local pl, plin = MF.GetPlayerFromPtr(u4[d.ebp - 0x1C]) --施法者 
		local sk,mas = SplitSkill(pl.Skills[const.Skills.Fire])
		for i,mon in Map.Monsters do
		--	if v < lim then
				if InDist(mon) and InFrontOfParty(mon) and mon.FireResistance < 1000 then
					vars.PlayerAttackTime = Game.Time
				--	mon.ArmorClass = math.max(0, mon.ArmorClass - penalty)
					mon.SpellBuffs[const.MonsterBuff.Hammerhands].ExpireTime = Game.Time + const.Day
					if mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power then
						mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power = mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power + math.floor(sk * 1.25 + 50)
					else
						mon.SpellBuffs[const.MonsterBuff.Hammerhands].Power = math.floor(sk * (mas * 0.5 - 0.75) + 50)
					end
					Game.ShowMonsterBuffAnim(i)
				end
		--	end
		end
	end
--	mem.hook(0x427EA4, Test)
	
--	local function Test(d)
--		Party[0].HP = Party[0].HP - 100
--		local mon = GetMonster(d.ebp - 8)
--		mon.HP = 0
--		local sk = d.edi --火系等级 
--		for i,v in Map.Monsters do
--			v.ArmorClass = v.ArmorClass * (0.95 ^ sk)
--		end
--		d.ecx = d.ecx - d.eax
--	end
--	mem.hook(0x427F5C, Test)

	--asmpatch(0x427B3D, "je 0x427B4A")
	

	-------- 12: Wizard Eye --------
	asmpatch(0x427FEF, [[
	call absolute 0x425B1A
	test eax, eax
	jz absolute 0x42D3AB
	]], 0x427FFE - 0x427FEF)
	new_code = asmpatch(0x427FFE, [[
	mov eax, dword ptr [ebp - 0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[12].Var2GM or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[12].Var1GM or 4) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[12].Var2Master or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[12].Var1Master or 3) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[12].Var2Expert or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[12].Var1Expert or 2) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[12].Var2Normal or 3600) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[12].Var1Normal or 1) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul edi
	mov dword ptr [ebp - 0x14], eax
	mov dword ptr [ebp - 0x10], edx
	movsx eax, word ptr [ebx + 0x2]
	inc eax
	push eax
	push esi
	push esi
	push ecx
	]], 0x428016 - 0x427FFE)
	hook((new_code or 0x427FFE) + 0x3A, function(d)
		local backup = d.eax
		d.eax = d.ecx
		player_spell_var(d, 1)
		d.ecx = d.eax
		d.eax = backup
		player_spell_var(d, 2)
	end)

	-------- 13: Feather Fall --------
	new_code = asmpatch(0x42805B, [[
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[13].Var1GM or 3600) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[13].Var1Master or 3600) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[13].Var1Expert or 600) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[13].Var1Normal or 300) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul edi
	]], 0x428083 - 0x42805B)
	hook((new_code or 0x42805B) + 0x22, player_spell_var1)
	-- fix buff caster
	asmpatch(0x4280DD, [[
	inc eax
	push eax
	push esi
	push esi
	]])

	-------- 15: Sparks --------
	new_code = asmpatch(0x428120, [[
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[15].Var1GM or 9) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[15].Var1Master or 7) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[15].Var1Expert or 5) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[15].Var1Normal or 3) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	]], 0x42814D - 0x428120)
	hook((new_code or 0x428120) + 0x22, player_spell_var1)

	-------- 16: Jump --------
	new_code = asmpatch(0x4282DE, [[
	mov eax, dword ptr [ebp - 0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[16].Var1GM or 1000) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[16].Var1Master or 1000) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[16].Var1Expert or 1000) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[16].Var1Normal or 750) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [0xB21588], eax
	]])
	hook(new_code + 0x26, player_spell_var1)

	-------- 17, 38, 51: Shield, Stone Skin, Heroism --------
	new_code = asmpatch(0x42794A, [[
	test eax, eax
	jle @normal
	cmp eax, 4
	jle @hook
	mov eax, 4
	jmp @hook
	@normal:
	mov eax, 1
	@hook:
	nop
	nop
	nop
	nop
	nop
	imul edi
	add eax, ecx
	adc edx, esi
	mov dword ptr [ebp - 0x14], eax
	mov dword ptr [ebp - 0x10], edx
	movzx ecx, word ptr [ebx]

	cmp ecx, 0x11
	jz @shield
	cmp ecx, 0x26
	jz @stone
	cmp ecx, 0x33
	jnz absolute 0x42D45D
	mov eax, 8
	jmp @end
	@stone:
	mov eax, 0xE
	jmp @end
	@shield:
	mov dword ptr [ebp - 0x4], esi
	mov eax, 0xD
	@end:
	shl eax, 4
	add eax, 0x1A34
	mov dword ptr [ebp - 0x20], eax

	push dword ptr [ebp - 0x8]
	mov ecx, dword ptr [ebp - 0x1C]
	call absolute 0x425B1A
	test eax, eax
	jz absolute 0x42D3AB
	cmp dword ptr [ebp - 0xC], 1
	jg @party
	movzx eax, word ptr [ebx + 4]
	mov dword ptr [ebp - 0x24], eax
	mov dword ptr [ebp - 0x8], eax
	jmp @common
	@party:
	mov ecx, 0xB20E90
	call absolute 0x42D776
	mov dword ptr [ebp - 0x24], eax
	mov dword ptr [ebp - 0x8], esi
	@common:
	movzx edi, word ptr [ebx]
	inc edi
	fild qword ptr [ebp - 0x14]
	fmul dword ptr [0x4E8568]
	call absolute 0x4D967C
	add eax, dword ptr [0xB20EBC]
	adc edx, dword ptr [0xB20EC0]
	mov dword ptr [ebp - 0x14C], eax
	mov dword ptr [ebp - 0x148], edx

	@loop:
	push esi
	push edi
	push dword ptr [ebp - 0x4]
	push dword ptr [ebp - 0xC]
	push dword ptr [ebp - 0x148]
	push dword ptr [ebp - 0x14C]
	push dword ptr [ebp - 0x8]
	mov ecx, 0xB20E90
	call absolute 0x4026F4
	mov ecx, eax
	add ecx, dword ptr [ebp - 0x20]
	call absolute 0x455D97
	push dword ptr [ebp - 0x8]
	movzx eax, word ptr [ebx]
	push eax
	mov ecx, dword ptr [0x75CE00]
	call absolute 0x42D747
	mov ecx, eax
	call absolute 0x4A6FCE
	inc dword ptr [ebp - 0x8]
	mov eax, dword ptr [ebp - 0x24]
	cmp eax, dword ptr [ebp - 0x8]
	jg @loop
	jmp absolute 0x42C200
	]], 0x427A60 - 0x42794A)
	hook((new_code or 0x42794A) + 0x15, function(d)
		local spell, mastery = d.ecx, d.eax
		local power = {}
		if spell ~= 17 then
			power[1] = MT.SpellsExtra[spell]["Var3" .. select(mastery, "Normal", "Expert", "Master", "GM")] or 1
			player_spell_var(d, 3, power)
			d.eax = MT.SpellsExtra[spell]["Var4" .. select(mastery, "Normal", "Expert", "Master", "GM")] or 5
			player_spell_var(d, 4)
			u4[d.ebp - 0x4] = floor(power[1] * d.edi) + d.eax
		end
		d.eax = MT.SpellsExtra[spell]["Var2" .. select(mastery, "Normal", "Expert", "Master", "GM")] or 3600
		player_spell_var(d, 2)
		d.ecx = d.eax
		d.eax = MT.SpellsExtra[spell]["Var1" .. select(mastery, "Normal", "Expert", "Master", "GM")]
			or select(mastery, 300, 300, 900, 3600)
		player_spell_var(d, 1)
	end)

	-------- 19: Invisibility --------
	new_code = asmpatch(0x4282F1, [[
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[19].Var1GM or 4) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[19].Var2GM or 3600) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[19].Var1Master or 3) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[19].Var2Master or 600) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[19].Var1Expert or 2) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[19].Var2Expert or 600) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[19].Var1Normal or 1) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[19].Var2Normal or 600) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul eax, edi
	mov dword ptr [ebp - 4], eax
	mov eax, ecx
	nop
	nop
	nop
	nop
	nop
	imul edi
	]], 0x428327 - 0x4282F1)
	hook((new_code or 0x4282F1) + 0x36, player_spell_var1)
	hook((new_code or 0x4282F1) + 0x43, player_spell_var2)
	-- fix buff caster
	asmpatch(0x42838E, [[
	inc eax
	push eax
	push esi
	]])

	-------- 21, 124: Fly, Flight --------
	new_code = asmpatch(0x428406, [[
	mov dword ptr [ebp - 0x24], eax
	jnz @ok
	movzx eax, word ptr [ebx + 0x8]
	and eax, 0x21
	jz absolute 0x428A5F
	@ok:
	mov eax, dword ptr [ebp - 0xC]
	cmp eax, esi
	jg @upper
	mov eax, 1
	jmp @end
	@upper:
	cmp eax, 4
	jle @end
	mov eax, 4
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 0x4], eax
	test eax, eax
	jz @ff2
	movzx eax, word ptr [ebx + 0x8]
	and eax, 0x4000
	test eax, eax
	jnz @ff1
	mov eax, dword ptr [ebp - 0x24]
	test eax, eax
	jz absolute 0x428A5F
	jmp @ff2
	@ff1:
	mov dword ptr [ebp - 0x4], esi
	@ff2:
	mov eax, ecx
	imul edi
	mov dword ptr [ebp - 0x14], eax
	mov dword ptr [ebp - 0x10], edx
	]], 0x428432 - 0x428406)
	hook((new_code or 0x428406) + 0x2A, function(d)
		local spell, mastery = u2[d.ebx], d.eax
		d.eax = MT.SpellsExtra[spell]["Var2" .. select(mastery, "Normal", "Expert", "Master", "GM")]
			or select(mastery, 300, 600, 3600, 3600)
		player_spell_var(d, 2)
		d.ecx = d.eax
		d.eax = MT.SpellsExtra[spell]["Var1" .. select(mastery, "Normal", "Expert", "Master", "GM")]
			or select(mastery, 1, 1, 1, 0)
		player_spell_var(d, 1)
	end)
	-- Allow to fly with 0 sp if tick SP cost is 0
	asmpatch(0x472AD0, [[
	jg @end
	cmp word ptr [0xB217B0], 0
	jz @end
	jmp absolute 0x47316C
	@end:
	]])

	-------- 24: Poison Spray --------
	new_code = asmpatch(0x42889A, [[
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[24].Var1GM or 7) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[24].Var1Master or 5) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[24].Var1Expert or 3) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[24].Var1Normal or 1) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	]], 0x4288C4 - 0x42889A)
	hook((new_code or 0x42889A) + 0x21, player_spell_var1)

	-------- 33: Lloyd's Beacon --------
	--   Lloyd's Beacon slots
	new_code = asmpatch(0x4D147E, [[
	cmp ecx, ebx
	jz absolute 0x4D14A9
	mov edx, 14
	call absolute ]] .. Merge.Offsets.GetPlayerSkillMastery .. [[;
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[33].Var1GM or 5) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[33].Var1Master or 3) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[33].Var1Expert or 2) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[33].Var1Normal or 1) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp-0x14], eax
	]], 0x4D14A9 - 0x4D147E)
	hook((new_code or 0x4D147E) + 0x35, function(d)
		local t = {Spell = 33, VarNum = 1, Value = d.eax}
		t.Player, t.PlayerIndex = MF.GetPlayerFromPtr(d.ecx)
		events.call("PlayerSpellVar", t)
		d.eax = t.Value
	end)
	--   Lloyd's Beacon slots
	new_code = asmpatch(0x4D1736, [[
	mov ecx, edi
	mov edx, 14
	call absolute ]] .. Merge.Offsets.GetPlayerSkillMastery .. [[;
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[33].Var1GM or 5) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[33].Var1Master or 3) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[33].Var1Expert or 2) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[33].Var1Normal or 1) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp-0x18], eax
	]], 0x4D175D - 0x4D1736)
	hook((new_code or 0x4D1736) + 0x2F, function(d)
		local t = {Spell = 33, VarNum = 1, Value = d.eax}
		t.Player, t.PlayerIndex = MF.GetPlayerFromPtr(d.edi)
		events.call("PlayerSpellVar", t)
		d.eax = t.Value
	end)
	--   Lloyd's Beacon duration
	new_code = asmpatch(0x4296CD, [[
	mov eax, dword ptr [ebp-0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[33].Var2GM or 604800) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[33].Var2Master or 86400) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[33].Var2Expert or 21600) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[33].Var2Normal or 3600) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul eax, edi
	]])
	hook((new_code or 0x4296CD) + 0x26, player_spell_var2)
	-------- 35: Slow --------
	new_code = asmpatch(0x426F1C, [[
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[35].Var1GM or 8) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[35].Var2GM or 300) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[35].Var1Master or 4) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[35].Var2Master or 300) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[35].Var1Expert or 2) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[35].Var2Expert or 300) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[35].Var1Normal or 2) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[35].Var2Normal or 180) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	mov eax, ecx
	nop
	nop
	nop
	nop
	nop
	imul eax, edi
	]], 0x426F5E - 0x426F1C)
	hook((new_code or 0x426F1C) + 0x37, player_spell_var1)
	hook((new_code or 0x426F1C) + 0x41, player_spell_var2)
	-------- 46: Bless --------
	asmpatch(0x42764C, [[
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov ecx, ]] .. (MT.SpellsExtra[46].Var1GM or 3600) .. [[;
	mov eax, ]] .. (MT.SpellsExtra[46].Var2GM or 3600) .. [[;
	jmp @end
	@master:
	mov ecx, ]] .. (MT.SpellsExtra[46].Var1Master or 900) .. [[;
	mov eax, ]] .. (MT.SpellsExtra[46].Var2Master or 3600) .. [[;
	jmp @end
	@expert:
	mov ecx, ]] .. (MT.SpellsExtra[46].Var1Expert or 300) .. [[;
	mov eax, ]] .. (MT.SpellsExtra[46].Var2Expert or 3600) .. [[;
	jmp @end
	@normal:
	mov ecx, ]] .. (MT.SpellsExtra[46].Var1Normal or 300) .. [[;
	mov eax, ]] .. (MT.SpellsExtra[46].Var2Normal or 3600) .. [[;
	@end:
	]])
	new_code = asmpatch(0x427651, [[
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 0x14], eax
	mov eax, ecx
	mov ecx, dword ptr [ebp - 0x14]
	nop
	nop
	nop
	nop
	nop
	imul edi
	add eax, ecx
	adc edx, esi
	]], 0x427677 - 0x427651)
	nop2(0x427683, 0x427689)
	hook(new_code or 0x427651, function(d)
		local mastery, backup = u4[d.ebp - 0xC], d.eax
		local power = {}
		power[1] = MT.SpellsExtra[46]["Var3" .. select(mastery, "Normal", "Expert", "Master", "GM")] or 1
		player_spell_var(d, 3, power)
		d.eax = MT.SpellsExtra[46]["Var4" .. select(mastery, "Normal", "Expert", "Master", "GM")] or 5
		player_spell_var(d, 4)
		u4[d.ebp - 0x4] = floor(power[1] * d.edi) + d.eax
		d.eax = backup
		player_spell_var(d, 2)
	end)
	hook((new_code or 0x427651) + 0xD, player_spell_var1)
	-------- 52: Spirit Lash --------
	asmpatch(0x42788D, [[
	mov eax, edi
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[52].Var1GM or 256) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[52].Var1Master or 256) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[52].Var1Expert or 256) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[52].Var1Normal or 512) .. [[;
	@end:
	]])
	nop2(0x427892, 0x427899)
	hook(0x427892, player_spell_var1)
	-------- 60: Charm --------
	new_code = asmpatch(0x427055, [[
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[60].Var1GM or 0x1BAF800) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[60].Var1Master or 600) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[60].Var1Expert or 300) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[60].Var1Normal or 150) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	cmp eax, 0x1BAF800
	je @end2
	imul eax, edi
	@end2:
	]], 0x427086 - 0x427055)
	hook((new_code or 0x427055) + 0x23, player_spell_var1)
	-------- 71: Regeneration --------
	new_code = asmpatch(0x427385, [[
	mov eax, dword ptr [ebp - 0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[71].Var1GM or 4) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[71].Var2GM or 3600) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[71].Var1Master or 3) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[71].Var2Master or 3600) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[71].Var1Expert or 2) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[71].Var2Expert or 3600) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[71].Var1Normal or 1) .. [[;
	mov ecx, ]] .. (MT.SpellsExtra[71].Var2Normal or 3600) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	mov dword ptr [ebp - 4], eax
	mov eax, ecx
	nop
	nop
	nop
	nop
	nop
	imul edi
	mov dword ptr [ebp - 0x14], eax
	mov dword ptr [ebp - 0x10], edx
	]], 0x4273C5 - 0x427385)
	hook((new_code or 0x427385) + 0x3A, player_spell_var1)
	hook((new_code or 0x427385) + 0x44, player_spell_var2)
	-------- 81: Paralyze --------
	new_code = asmpatch(0x426EB4, [[
	mov eax, dword ptr [ebp - 0xC]
	dec eax
	dec eax
	jz @expert
	jl @normal
	dec eax
	jz @master
	mov eax, ]] .. (MT.SpellsExtra[81].Var1GM or 23040) .. [[;
	jmp @end
	@master:
	mov eax, ]] .. (MT.SpellsExtra[81].Var1Master or 23040) .. [[;
	jmp @end
	@expert:
	mov eax, ]] .. (MT.SpellsExtra[81].Var1Expert or 23040) .. [[;
	jmp @end
	@normal:
	mov eax, ]] .. (MT.SpellsExtra[81].Var1Normal or 23040) .. [[;
	@end:
	nop
	nop
	nop
	nop
	nop
	imul edi, eax
	]])
	hook((new_code or 0x426EB4) + 0x26, player_spell_var1)
local function alltrue(d)
	d.eax = 1
end
	mem.hook(0x425ae2,alltrue)
--	mem.nop(0x426e9d, 6)
	-------- Select target type --------
	asmpatch(0x425BC8, [[
	cmp ecx, 5
	jnz @shield
	mov ecx, dword ptr [ebp + 8]
	test ecx, ecx
	jnz absolute 0x425C11
	push 12
	jmp absolute ]] .. MO.SkillMasteryTarget2 .. [[;
	@shield:
	cmp ecx, 17
	jnz @stoneskin
	mov ecx, dword ptr [ebp + 8]
	test ecx, ecx
	jnz absolute 0x425C11
	push 13
	jmp absolute ]] .. MO.SkillMasteryTarget2 .. [[;
	@stoneskin:
	cmp ecx, 38
	jnz @heroism
	mov ecx, dword ptr [ebp + 8]
	test ecx, ecx
	jnz absolute 0x425C11
	push 15
	jmp absolute ]] .. MO.SkillMasteryTarget2 .. [[;
	@heroism:
	cmp ecx, 51
	jnz @std
	mov ecx, dword ptr [ebp + 8]
	test ecx, ecx
	jnz absolute 0x425C11
	push 16
	jmp absolute ]] .. MO.SkillMasteryTarget2 .. [[;
	@std:
	add ecx, 0xFFFFFFFE
	cmp ecx, 0x79
	]])
end

	-------- 84: PrismaticLight --------
	
	local function GetDist(t,x,y,z)
		local px, py, pz  = XYZ(t)
		return math.sqrt((px-x)^2 + (py-y)^2 + (pz-z)^2)
	end
	
	local function InDist(Mon)
		if Mon.Active and Mon.HP > 0 then
			if GetDist(Mon, Party.X, Party.Y, Party.Z) < 5000 then
				return true
			end
		end
		return false
	end
	
	local function InFrontOfParty(Mon)
		local Angle = math.atan2(Mon.Y - Party.Y,Mon.X - Party.X)
		if Angle < 0 then
			Angle = Angle + math.pi * 2
		end
		local PartyAngle = Party.Direction / 1024 * math.pi
		local MaxDif = math.pi / 3
		if math.abs(Angle - PartyAngle) < MaxDif or math.abs(Angle + 2 * math.pi - PartyAngle) < MaxDif or math.abs(Angle - 2 * math.pi - PartyAngle) < MaxDif then
			return true
		else
			return false
		end
	end
	
	local function PrL(d)
		--Party[0].HP = Party[0].HP - 10000
		
		local sk = d.edi --光系等级 
		
		--local MonList = Game.GetMonstersInSight()
		--local lim = Map.Monsters.count
		--for i,v in pairs(MonList) do
			--if v < lim then
		for i,mon in Map.Monsters do
			if InDist(mon) and InFrontOfParty(mon) and mon.LightResistance < 1000 then
				vars.PlayerAttackTime = Game.Time
				mon.SpellBuffs[const.MonsterBuff.Fate].ExpireTime = Game.Time + const.Day
				if mon.SpellBuffs[const.MonsterBuff.Fate].Power then
					mon.SpellBuffs[const.MonsterBuff.Fate].Power = mon.SpellBuffs[const.MonsterBuff.Fate].Power + math.floor(sk * 1.25 + 50)
				else
					mon.SpellBuffs[const.MonsterBuff.Fate].Power = math.floor(sk * 1.25 + 50)
				end
				Game.ShowMonsterBuffAnim(i)
			end
		end
		--d.ecx = 540
	end
	--mem.hook(0x42B8E7, PrL)
	
--	-------- 84: Fate --------
--	local function Die(d)
--		Party[0].HP = -10000
--	end
--	mem.hook(0x429081, Die)
--	mem.hook(0x429181, Die)
--	mem.hook(0x429281, Die)
--	mem.hook(0x429381, Die)
--	mem.hook(0x429481, Die)
--	mem.hook(0x429581, Die)
--	mem.hook(0x429681, Die)
--	mem.hook(0x429781, Die)
--	mem.hook(0x429881, Die)
--	mem.hook(0x429981, Die)
--	mem.hook(0x429A81, Die)
--	mem.hook(0x429B51, Die)
--	mem.hook(0x429C81, Die)
--	mem.hook(0x429D81, Die)
--	mem.hook(0x429E81, Die)

function events.GameInitialized1()
	ProcessSpellsExtraTxt()
	SetSpellsExtraHooks()
end

Log(Merge.Log.Info, "Init finished: %s", LogId)



-- 426c7d acid burst
Stp = false
Spd = 1
local function stpoutdoorx(d)
	if Stp == false then
--		Party.X = d.edi
		Party.X = (Party.X * (1-Spd) + d.edi * Spd)
	end
	--edi ebx edx
end
local function stpoutdoory(d)
	if Stp == false then
--		Party.Y = d.ebx
		Party.Y = (Party.Y * (1-Spd) + d.ebx * Spd)
	end
end
local function stpoutdoorz(d)
	if Stp == false then
		Party.Z = (Party.Z * (1-SpdZ) + d.edx * SpdZ)
	end
end
local function stpindoorx(d)
	if Stp == false then
--		Party.X = d.eax
		Party.X = (Party.X * (1-Spd) + d.eax * Spd)
	end
	--edi ebx edx
end
local function stpindoory(d)
	if Stp == false then
--		Party.Y = d.eax
		Party.Y = (Party.Y * (1-Spd) + d.eax * Spd)
	end
end
local function stpindoorz(d)
	if Stp == false then
		Party.Z = (Party.Z * (1-SpdZ) + d.esi * SpdZ)
	end
end
mem.hook(0x473E0F, stpoutdoorx)
mem.hook(0x473E15, stpoutdoory)
mem.hook(0x473E1B, stpoutdoorz)
mem.hook(0x47253B, stpindoorx)
mem.hook(0x472543, stpindoory)
mem.hook(0x47254B, stpindoorz)


--asmpatch(0x48E00F, [[
--	cmp ecx, ecx
--	]])

--[[
mem.nop(0x473E0F, 6)
mem.nop(0x473E15, 6)
mem.nop(0x473E1B, 6)
mem.nop(0x47253B, 5)
mem.nop(0x472543, 5)
mem.nop(0x47254B, 6)
]]--

function events.CastTelepathy(t)
	if vars.LastCastTelepathy == nil or vars.LastCastTelepathy < Game.Time then
		t.Monster.StartX = t.Monster.StartX + math.random(10,-10)
		t.Monster.StartY = t.Monster.StartY + math.random(10,-10)
		--Message(tostring(t.Monster.ArmorClass))
		PrepareMapMon(t.Monster)
		Sleep(1) 
		for i,pl in Party do
			if pl.RecoveryDelay > 9000 then
				pl.HP = -1000
				pl.SP = 0
				pl.Eradicated = 1
				sk,mas = SplitSkill(pl.Skills[const.Skills.Mind])
				pl.RecoveryDelay = 30720
				local daywait = 5 - mas
				vars.LastCastTelepathy = Game.Time + const.Day * daywait
			end
		end 
	end
end
