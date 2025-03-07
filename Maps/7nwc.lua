Game.MapEvtLines:RemoveEvent(454)
evt.map[454] = function()
	evt.Subtract("Gold", 10)
	--evt.Add{"Inventory", 1022}	-- "_potion/reagent"
	evt.Add("Inventory", 220)	-- "Potion Bottle"
end
