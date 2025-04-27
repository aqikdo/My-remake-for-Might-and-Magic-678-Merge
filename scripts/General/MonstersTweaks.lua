local LogId = "MonstersTweaks"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)

local asmpatch = mem.asmpatch

--------------------
-- MapMonster Allies
-- Support Group as negative in Ally (1)
asmpatch(0x4386B6, [[
jns @std
test edi, edi
js absolute 0x4386D8
mov edi, dword ptr [ebx+0x34C]
neg edi
jmp absolute 0x4386D8
@std:
jnz absolute 0x4386C6
movsx eax, word ptr [ecx+0x6A]
]])

-- Support Group as negative in Ally (2)
asmpatch(0x4386C8, [[
jns @std
mov esi, dword ptr [ecx+0x34C]
neg esi
jmp absolute 0x4386D8
@std:
jnz absolute 0x4386D8
movsx eax, word ptr [ebx+0x6A]
]])

-- Use sane comparison first
asmpatch(0x4386DB, [[
cmp esi, edi
jz short 0x43874D - 0x4386DB
push 0x80
pop edx
]], 12)

-- MM7 human, dwarf, elf peasants
asmpatch(0x4386FB, [[
push 0x75
pop ecx
cmp esi, ecx
jl @opt1
cmp esi, edx
jg @end
cmp edi, ecx
jl @end
cmp edi, edx
jg @end
jmp short 0x43874D - 0x4386FB
@opt1:
push 0x69
pop ecx
push 0x6E
pop edx
cmp esi, ecx
jl @end
cmp esi, edx
jg @opt2
cmp edi, ecx
jl @end
cmp edi, edx
jg @end
jmp short 0x43874D - 0x4386FB
@opt2:
push 0x74
pop edx
cmp edi, edx
jle short 0x43874D - 0x4386FB
@end:
]], 0x438737 - 0x4386FB)

-- MM7 goblin peasants, MM6 peasants
asmpatch(0x43872F, [[
push 0x90
pop ecx
push 0x95
pop edx
cmp esi, ecx
jl @end
cmp esi, edx
jg @opt1
cmp edi, ecx
jl @end
cmp edi, edx
jg @end
jmp absolute 0x43874D
@opt1:
push 0xC1
pop ecx
push 0xCB
pop edx
cmp esi, ecx
jl @end
cmp esi, edx
jg @end
cmp edi, ecx
jl @end
cmp edi, edx
jl @end
push 0xC2
pop ecx
push 0xC6
pop edx
cmp esi, ecx
jl @opt2
cmp esi, edx
jg @opt2
cmp edi, ecx
jl @opt2
cmp edi, edx
jg @opt2
jmp @end
@opt2:
push 0xC9
pop ecx
push 0xCA
pop edx
cmp esi, ecx
jl @ok
cmp esi,edx
jg @ok
cmp edi, ecx
jl @ok
cmp edi, edx
jg @ok
jmp @end
@ok:
jmp absolute 0x43874D
@end:
]])

Log(Merge.Log.Info, "Init finished: %s", LogId)

