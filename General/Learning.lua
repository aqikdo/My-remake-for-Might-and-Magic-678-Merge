-- Learning related hooks
local LogId = "Learning"
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MM = Merge.Functions, Merge.ModSettings

local asmpatch, hook, u4 = mem.asmpatch, mem.hook, mem.u4
local max = math.max

local LEARNING = const.Skills.Learning

-- Reduce training time by player Learning mastery
local function ReduceTrainingTime()
	-- Ignore MM8 check for maximal amount of level-ups this session
	-- Get training hours to be added in according to Learning mastery
	local NewCode = asmpatch(0x4B3606, [[
	inc dword ptr [eax]
	mov eax, dword ptr [eax]
	nop
	nop
	nop
	nop
	nop
	test edi, edi
	je absolute 0x4B3640
	push eax
	]])

	hook(NewCode + 4, function(d)
		local cur_pl = Game.CurrentPlayer
		local cur_levels = d.eax
		local days, total_levels = 0, 0
		-- Get already spent days during this session for other players
		for k, pl in Party do
			if k ~= cur_pl then
				local levels = u4[0xFFD3AC + k * 4]
				if levels > 0 then
					local _, mastery = SplitSkill(pl.Skills[LEARNING])
					local pl_days = 1
					if pl_days > days then
						days = pl_days
					end
					total_levels = total_levels + levels
				end
			end
		end
		local _, mastery = SplitSkill(Party[cur_pl].Skills[LEARNING])
		local cur_days = 1
		if cur_days > days then
			if cur_levels > 1 then
				-- Check if current player already spent more days than others
				local prev_days = 1
				days = max(days, prev_days)
			end
			d.edi = (cur_days - days) * 1
		else
			d.edi = 0
		end
		total_levels = total_levels + cur_levels
		d.eax = total_levels
	end)

	-- Ignore extra hours for non first level-up.
	-- Check for next 9 AM to be in 24 hours for first level-up.
	-- ecx - level-ups this sesssion
	-- eax - hours till next dawn
	-- edi - training hours to be added
	asmpatch(0x4B3617, [[
	pop ecx
	cmp ecx, 1
	jle @first
	xor eax, eax
	jmp @std
	@first:
	add eax, 4
	cmp eax, 0x18
	jle @std
	sub eax, 0x18
	@std:
	add eax, edi
	]])
end

local function IncreaseEvtExperience()
	asmpatch(0x4487F1, [[
	test eax, eax
	je @end
	push ebx
	mov ebx, eax
	mov ecx, esi
	call absolute 0x49036E
	imul eax, ebx
	cdq
	push 0x64
	pop ecx
	idiv ecx
	add eax, ebx
	pop ebx
	@end:
	cdq
	add [esi+0xA0], eax
	]])
end

function events.GameInitialized2()
	if MF.GtSettingNum(MM.LearningReduceTrainingTime, 0) then
		ReduceTrainingTime()
	end
	if MF.GtSettingNum(MM.LearningIncreaseEvtExperience, 0) then
		IncreaseEvtExperience()
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
