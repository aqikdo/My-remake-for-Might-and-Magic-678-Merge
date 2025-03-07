local LogId = "DamageTweaks"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF = Merge.Functions

local asmpatch, asmproc, nop, u4 = mem.asmpatch, mem.asmproc, mem.nop, mem.u4

-- Monster attack type
-- Fix 'Elec' and 'Ener' attack types
-- MMPatch 2.5 fixes 'Ener' only
asmpatch(0x45251F, [[
call absolute 0x4DB94E
pop ecx
cmp eax, 0x6C
jnz @ener
push 1
jmp absolute 0x452508
@ener:
cmp eax, 0x6E
jnz @earth
push 0xC
jmp absolute 0x452508
@earth:
]], 0x452525 - 0x45251F)

-- Fix monster spell projectile attack type
-- fixed in MMPatch 2.5
--[=[
asmpatch(0x404D97, [[
mov eax, dword ptr [ebp+0xC]
mov byte ptr [ebp-0x1F], al
call absolute 0x455B09
]])
nop(0x404E45, 4)
nop(0x405895, 4)
]=]

-- Fix 'Cyclops Projectile' object
local NewCode = asmproc([[
mov word ptr [ebp-0x74], 0x235
jmp absolute 0x404BA9
]])

mem.IgnoreProtection(true)
u4[0x404D5F] = NewCode
mem.IgnoreProtection(false)

asmpatch(0x46A72D, [[
cmp eax, 0x41
jz absolute 0x46AB1E
cmp eax, 0x3C
ja absolute 0x46B6A5
]])

-- Fix monster 'Rock' missile projectile
-- MMPatch 2.5 fixes 'Rock' by setting it to 6 (Earth) so we'll overwrite it
local rock = MF.cstring("Rock")
asmpatch(0x452753, [[
test eax, eax
pop ecx
pop ecx
jz @end
push ]] .. rock .. [[;
push esi
call absolute 0x4DA920
pop ecx
pop ecx
test eax, eax
jnz absolute 0x45275C
push 0xC
jmp absolute 0x45275B
@end:
]])

Log(Merge.Log.Info, "Init finished: %s", LogId)

