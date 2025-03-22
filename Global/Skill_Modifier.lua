function events.GetLearningTotalSkill(t)
	sk,mas = SplitSkill(t.Player.Skills[const.Skills.Learning])
	if mas == 3 then
		t.Result = t.Result
	elseif mas == 4 then
		t.Result = t.Result - sk
	end
end