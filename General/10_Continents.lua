local LogId = "Continents"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MV = Merge.Functions, Merge.Vars

function events.BeforeLoadMap(WasInGame)
	Log(Merge.Log.Info, "%s: BeforeLoadMap", LogId)
	if WasInGame then
		MV.PrevContinent = MV.Continent
		MV.PrevMap = MV.Map
	else
		MV.PrevContinent = nil
		MV.PrevMap = nil
	end
	MV.World = 1
	MV.Continent = MF.GetContinent()
	MV.Map = Map.MapStatsIndex
	if MV.Continent ~= MV.PrevContinent then
		events.call("ContinentChange1")
	end
end

function events.LoadMap()
	Log(Merge.Log.Info, "%s: LoadMap", LogId)
	if MV.Continent ~= MV.PrevContinent then
		events.call("ContinentChange2")
	end
end

function events.AfterLoadMap()
	Log(Merge.Log.Info, "%s: AfterLoadMap", LogId)
	if MV.Continent ~= MV.PrevContinent then
		events.call("ContinentChange3")
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)

