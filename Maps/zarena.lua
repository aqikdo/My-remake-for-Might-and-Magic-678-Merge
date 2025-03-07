-- The Arena (Enroth)
function events.CanSaveGame(t)
	t.IsArena = true
	t.Result = false
end

function events.CanCastLloyd(t)
	t.Result = false
end
