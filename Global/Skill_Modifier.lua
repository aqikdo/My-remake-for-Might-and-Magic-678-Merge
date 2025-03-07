function events.GetLearningTotalSkill(t)
	sk,mas = SplitSkill(t.Player.Skills[const.Skills.Learning])
	if mas == 3 then
		t.Result = t.Result - math.floor(sk/2)
	elseif mas == 4 then
		t.Result = t.Result - sk * 2
	end
end