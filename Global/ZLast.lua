local MV = Merge.Vars

-- Clear NewGame flag
function events.AfterLoadMap()
	MV.NewGame = false
end
