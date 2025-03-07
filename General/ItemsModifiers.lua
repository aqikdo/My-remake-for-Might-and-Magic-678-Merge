local LogId = "ItemsModifiers"
Log(Merge.Log.Info, "Init started: %s", LogId)
local MT = Merge.Tables

local asmpatch, asmproc, autohook2, hook = mem.asmpatch, mem.asmproc, mem.autohook2, mem.hook
local i4, u4 = mem.i4, mem.u4

local NewCode

local function ProcessItemsExtraTxt()
	local items_extra = {}
	local table_file = "Data/Tables/ItemsExtra.txt"
	local header = "Id\9Note\9Continent\9QuestItem\9LostQBit\9StartQBit\9EndQBit\9PostEnd"

	local txt_table = io.open(table_file, "r")
	if not txt_table then
		Log(Merge.Log.Warning, "%s: No ItemsExtra.txt found", LogId)
	else
		local iter = txt_table:lines()
		if iter() ~= header then
			Log(Merge.Log.Warning, "%s: ItemsExtra.txt has wrong header", LogId)
		else
			local line_num = 1
			for line in iter do
				line_num = line_num + 1
				local words = string.split(line, "\9")
				if tonumber(words[1]) then
					items_extra[tonumber(words[1])] = {
						Continent = tonumber(words[3]),
						QuestItem = words[4] == "x",
						LostQBit  = tonumber(words[5]),
						StartQBit = tonumber(words[6]),
						EndQBit = tonumber(words[7]),
						PostEnd = words[8] == "x"
					}
				end
			end
		end
		io.close(txt_table)
	end

	MT.ItemsExtra = items_extra
end

local function SetItemsModifiersHooks()

	-------------------------------------
	-- Double Damage item special bonuses
	--   * Extends amount of bonuses
	--   * Allows item to have more than one Double Damage bonus
	--   * Adds event ItemHasBonus2

	-- edx - MonsterId
	-- edi - Player pointer
	-- [ebp+0] - Item.Number
	-- [ebp+0xC] - Item.Bonus2
	NewCode = asmproc([[
	cmp eax, dword ptr [ebp+0xC]
	jz @end
	mov ecx, dword ptr [ebp+0]
	nop
	nop
	nop
	nop
	nop
	@end:
	retn
	]])

	hook(NewCode + 8, function(d)
		local t = {PlayerPtr = d.edi, ItemId = d.ecx, Bonus2 = d.eax, MonsterId = d.edx, Result = 0}
		--Log(Merge.Log.Info, "ItemHasBonus2: 0x%X, %d, %d, %d", t.PlayerPtr, t.ItemId, t.Bonus2, t.MonsterId)
		events.call("ItemHasBonus2", t)
		d.eax = t.Result
	end)

	-- CalcMeleeDamage: Right hand
	--   ebx - MonsterId
	--   edi - Player pointer
	--   esi - Damage
	--   [ebp+0] - Item.Number
	--   [ebp+0xC] - Item.Bonus2
	asmpatch(0x48C810, [[
	mov ebx, ecx
	xor edx, edx
	inc edx
	call absolute 0x436542
	test eax, eax
	jz @dragon
	mov eax, 0x40
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@dragon:
	mov edx, 2
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @swimmer
	mov eax, 0x28
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@swimmer:
	mov edx, 3
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @ogre
	mov eax, 0x4F
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@ogre:
	mov edx, 7
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @elemental
	mov eax, 0x27
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@elemental:
	mov edx, 8
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @demon
	mov eax, 0x3F
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@demon:
	mov edx, 9
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @titan
	mov eax, 0x4A
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@titan:
	mov edx, 0xA
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @elf
	mov eax, 0x41
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@elf:
	mov edx, 0xB
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @goblin
	mov eax, 0x4B
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@goblin:
	mov edx, 0xC
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @dwarf
	mov eax, 0x4C
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@dwarf:
	mov edx, 0xD
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @human
	mov eax, 0x4D
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@human:
	mov edx, 0xE
	mov ecx, ebx
	call absolute 0x436542
	test eax, eax
	jz @end
	mov eax, 0x4E
	mov edx, ebx
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C824
	@end:
	jmp absolute 0x48C868
	]])

	-- CalcMeleeDamage: Left hand
	--   esi - MonsterId
	--   edi - Player pointer
	--   ebx - Damage
	--   [ebp+0] - Item.Number
	--   [ebp+0xC] - Item.Bonus2
	asmpatch(0x48C92A, [[
	mov esi, ecx
	xor edx, edx
	inc edx
	call absolute 0x436542
	test eax, eax
	jz @dragon
	mov eax, 0x40
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@dragon:
	mov edx, 2
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @swimmer
	mov eax, 0x28
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@swimmer:
	mov edx, 3
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @ogre
	mov eax, 0x4F
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@ogre:
	mov edx, 7
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @elemental
	mov eax, 0x27
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@elemental:
	mov edx, 8
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @demon
	mov eax, 0x3F
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@demon:
	mov edx, 9
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @titan
	mov eax, 0x4A
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@titan:
	mov edx, 0xA
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @elf
	mov eax, 0x41
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@elf:
	mov edx, 0xB
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @goblin
	mov eax, 0x4B
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@goblin:
	mov edx, 0xC
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @dwarf
	mov eax, 0x4C
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@dwarf:
	mov edx, 0xD
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @human
	mov eax, 0x4D
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@human:
	mov edx, 0xE
	mov ecx, esi
	call absolute 0x436542
	test eax, eax
	jz @end
	mov eax, 0x4E
	mov edx, esi
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48C93E
	@end:
	jmp absolute 0x48C971
	]])

	-- Missile
	--   [ebp+8] - MonsterId
	--   ebx - Player pointer
	--   esi - Damage
	--   [edi+0] - Item.Number
	--   [edi+0xC] - Item.Bonus2
	NewCode = asmproc([[
	cmp eax, dword ptr [edi+0xC]
	jz @end
	mov ecx, dword ptr [edi+0]
	mov edx, dword ptr [ebp+8]
	nop
	nop
	nop
	nop
	nop
	@end:
	retn
	]])

	hook(NewCode + 10, function(d)
		local t = {PlayerPtr = d.ebx, ItemId = d.ecx, Bonus2 = d.eax, MonsterId = d.edx, Result = 0}
		--Log(Merge.Log.Info, "ItemHasBonus2: 0x%X, %d, %d, %d", t.PlayerPtr, t.ItemId, t.Bonus2, t.MonsterId)
		events.call("ItemHasBonus2", t)
		d.eax = t.Result
	end)

	-- CalcRangedDamage
	asmpatch(0x48CB80, [[
	xor edx, edx
	inc edx
	call absolute 0x436542
	test eax, eax
	jz @dragon
	mov eax, 0x40
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@dragon:
	mov edx, 2
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @swimmer
	mov eax, 0x28
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@swimmer:
	mov edx, 3
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @ogre
	mov eax, 0x4F
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@ogre:
	mov edx, 7
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @elemental
	mov eax, 0x27
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@elemental:
	mov edx, 8
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @demon
	mov eax, 0x3F
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@demon:
	mov edx, 9
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @titan
	mov eax, 0x4A
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@titan:
	mov edx, 0xA
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @elf
	mov eax, 0x41
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@elf:
	mov edx, 0xB
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @goblin
	mov eax, 0x4B
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@goblin:
	mov edx, 0xC
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @dwarf
	mov eax, 0x4C
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@dwarf:
	mov edx, 0xD
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @human
	mov eax, 0x4D
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@human:
	mov edx, 0xE
	mov ecx, dword ptr [ebp+8]
	call absolute 0x436542
	test eax, eax
	jz @end
	mov eax, 0x4E
	call absolute ]] .. NewCode .. [[;
	test eax, eax
	jnz absolute 0x48CB94
	@end:
	jmp absolute 0x48CBCC
	]])

	---------------------------------
	-- ItemAdditionalDamage

	local CheckItemAddDamageAsm = asmproc([[
	push ebp
	mov ebp, esp
	push esi
	mov esi, dword ptr [ebp+0x10]
	push dword ptr [ebp+0xC]
	push dword ptr [ebp+8]
	call absolute 0x4378CD
	pop esi
	pop esi
	pop ebp
	retn 12
	]])

	-- Test additional damage from item against monster
	--   itemptr - Item struct (like Party[x].Items[y]) or pointer (like Party[x].Items[y]["?ptr"])
	--   playerptr - Player struct (like Party[x]) or pointer (like Party[x]["?ptr"])
	--   monster - either MapMonster pointer (Map.Monsters[z]["?ptr"]) or monster id (less than 65536)
	--     If monster id has been passed - creates monster with AIState = Removed.
	function CheckItemAdditionalDamage(itemptr, playerptr, monster)
		local a, v = mem.malloc(4), mem.malloc(4)
		local monptr
		if type(itemptr) == "table" then
			itemptr = itemptr["?ptr"]
		end
		if type(playerptr) == "table" then
			playerptr = playerptr["?ptr"]
		end
		if monster < 0x10000 then
			local n = Map.Monsters.Count
			local x, y, z = XYZ(Party)
			mem.call(offsets.SummonMonster, 2, monster, x, y, z)
			if Map.Monsters.Count == n + 1 then
				local mon = Map.Monsters[n]
				local place
				mon.AIState = 11
				for i = 0, n - 1 do
					if Map.Monsters[i].AIState == 11 then  -- const.AIState.Removed
						place = i
						break
					end
				end
				if place then
					local a = Map.Monsters[place]
					mem.copy(a["?ptr"], mon["?ptr"], mon["?size"])
					Map.Monsters.Count = n
					mon = a
				end
				monptr = mon["?ptr"]
			end
		else
			monptr = mon
		end
		local dmg = mem.call(CheckItemAddDamageAsm, 2, itemptr, a, v, playerptr, monptr)
		local res1, res2 = u4[a], u4[v]
		mem.free(a)
		mem.free(v)
		return dmg, res1, res2
	end

	-- Check for Vampiric bonus
	NewCode = asmpatch(0x4378FA, [[
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	jz @end
	mov dword ptr [edi], 0xA
	mov eax, dword ptr [ebp+8]
	mov dword ptr [eax], 1
	@end:
	mov ebx, 2
	jmp absolute 0x437997
	]])

	hook(NewCode, function(d)
		local t = {ItemId = i4[d.ebx], Bonus2 = i4[d.ebx + 0xC], Group = 2, Result = 0}
		events.call("ItemHasBonus2OfGroup", t)
		--Log(Merge.Log.Info, "Bonus2OfGroup: %d - %d (%d)", t.ItemId, t.Result, t.Group)
		d.eax = t.Result
	end)

	-- Check for additional damage bonuses
	-- Notes:
	--   * ebx should contain 2
	--   * Vampiric bonuses are ignored here (unlike vanilla MM8)
	NewCode = asmpatch(0x43799A, [[
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	jz absolute 0x43793E
	cmp eax, 0x2E
	jle absolute 0x4379A6
	cmp eax, 0x43
	jl absolute 0x4378E3
	jz absolute 0x437ABD
	cmp eax, 0x44
	jz absolute 0x437A4E
	sub eax, 0x50
	jl absolute 0x4378E3
	cmp eax, 8
	jg absolute 0x4378E3
	cmp eax, 3
	jle @two
	add eax, 2
	@two:
	mov dword ptr [edi], eax
	jmp absolute 0x437ADC
	]])

	hook(NewCode, function(d)
		local t = {ItemId = i4[d.eax], Bonus2 = i4[d.eax + 0xC], Group = 1, Result = 0}
		events.call("ItemHasBonus2OfGroup", t)
		--Log(Merge.Log.Info, "Bonus2OfGroup: %d - %d (%d)", t.ItemId, t.Result, t.Group)
		d.eax = t.Result
	end)

	-- Fix bonus 15: use Body rather than Water
	-- fixed in MMPatch 2.5
	--[=[
	asmpatch(0x437AAD, [[
	mov dword ptr [edi], 8
	push 0xC
	jmp absolute 0x437AC5
	]])
	]=]

	---------------------------------
	-- 'of Carnage' bonus
	NewCode = mem.asmpatch(0x42642E, [[
	lea edi, [ebp-0x88]
	cmp dword ptr [edi+0xC], 3
	je @end
	mov eax, dword ptr [edi]
	nop
	nop
	nop
	nop
	nop
	test eax, eax
	jz @end
	mov dword ptr [edi+0xC], 3
	@end:
	or byte ptr [ebp-0x91], 1
	]])

	mem.hook(NewCode + 0xE, function(d)
		local t = {ItemId = d.eax, Bonus2 = 3, Result = 0}
		events.call("ItemHasBonus2", t)
		--Log(Merge.Log.Info, "ItemHasBonus2: %d, %d - %d", t.ItemId, t.Bonus2, t.Result)
		d.eax = t.Result
	end)

	-- Make Carnage bows to deal damage to paralyzed monsters
	-- fixed in MMPatch 2.5
	--[=[
	local ignore_paralyze = mem.malloc(4)
	mem.u4[ignore_paralyze] = 0
	mem.asmpatch(0x436CB3, [[
	mov dword ptr []] .. ignore_paralyze .. [[], 1
	call absolute 0x409069
	mov dword ptr []] .. ignore_paralyze .. [[], 0
	]])
	mem.asmpatch(0x409086, [[
	mov eax, dword ptr []] .. ignore_paralyze .. [[]
	test eax, eax
	jnz absolute 0x40909B
	cmp dword ptr [ecx+0x140], esi
	]])
	]=]

	-- Item cost increase based on StdBonus
	autohook2(0x453D13, function(d)
		local t = {Item = u4[d.esi], BaseCost = d.edi, StdBonus = u4[d.esi+4],
			BonusStrength = u4[d.esi+8], Result = d.eax}
		events.cocall("GetItemStdBonusCost", t)
		d.edi = t.BaseCost
		d.eax = t.Result
	end)
end

function events.GameInitialized1()
	SetItemsModifiersHooks()
end

function events.GameInitialized2()
	ProcessItemsExtraTxt()
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
