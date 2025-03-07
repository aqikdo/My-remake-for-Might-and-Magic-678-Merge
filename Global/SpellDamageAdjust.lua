local function GenRandom(maxnum)
	res = 0
	for i = 1,10 do
		res = res + math.random(maxnum)
	end
	return res / 10
end

function events.CalcSpellDamage(t)
	if t.Spell == 43 then
		t.Result = (t.Skill * 20 + 200) * (t.Mastery - 2)
	elseif t.Spell == 10 then
		t.Result = t.Skill * (t.Mastery + 1)
	elseif t.Spell == 52 then
		t.Result = -12321
	elseif t.Spell == 15 then
		t.Result = t.Skill * 2
	elseif t.Spell == 111 then
		--Message(tostring(t.HP))
		--t.Result = 14 + t.Mastery * 4 + t.Skill * GenRandom(14 + t.Mastery * 4) + t.HP * 0.001 * t.Mastery
		t.Result = -12321
	elseif t.Spell == const.Spells.ShootDragon then
		t.Result = -12321
	elseif t.Spell == const.Spells.Souldrinker then
		t.Result = t.Skill * 10 + 25
	end
end