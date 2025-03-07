-- Maze

Game.MapEvtLines:RemoveEvent(451)
evt.hint[451] = evt.str[16]
evt.map[451] = function()
	if not evt.Cmp("BodyResBonus", 25) then
		evt.Add("BodyResBonus", 25)
	end
	evt.StatusText(18)         -- "Refreshing"
end
