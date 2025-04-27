local LogId = "OutdoorTravels"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)

local random = math.random

---- Parse table

local TravelsTable = {}
Game.OutdoorTravels = TravelsTable

function ParseTravelsTable(FilePath, Table)

	local File	= io.open(FilePath)

	if not File then
		return
	end

	local LineIt 	= File:lines()
	LineIt()

	for line in LineIt do
		local Words = string.split(line, "\9")
		if string.len(Words[1]) == 0 then
			break
		end

		local Key = string.lower(Words[1])

		Table[Key] = {}

		if string.len(Words[2]) > 0 then
			Table[Key].up 		= {map = Words[2], side = tonumber(Words[3]) or Words[3], days = tonumber(Words[4]) or 0}
		end

		if string.len(Words[5]) > 0 then
			Table[Key].down 	= {map = Words[5], side = tonumber(Words[6]) or Words[6], days = tonumber(Words[7]) or 0}
		end

		if string.len(Words[8]) > 0 then
			Table[Key].left 	= {map = Words[8], side = tonumber(Words[9]) or Words[9], days = tonumber(Words[10]) or 0}
		end

		if string.len(Words[11]) > 0 then
			Table[Key].right 	= {map = Words[11], side = tonumber(Words[12]) or Words[12], days = tonumber(Words[13]) or 0}
		end

		Table[Key].StraightTravel = Words[14] == "x"

	end

	io.close(File)

end

ParseTravelsTable("Data/Tables/Outdoor travels.txt", TravelsTable)

----

local SwCoord = "X"
local StTrConns = {up = "Y", down = "Y", left = "X", right = "X"}
local NeedST = 0

function events.WalkToMap(t)

	local L = TravelsTable[string.lower(t.LeaveMap)]

	if L then
		local ST = L.StraightTravel
		L = L[t.LeaveSide]
		if L then
			t.Days = L.days
			t.EnterMap = L.map
			t.EnterSide = L.side
			if ST then
				SwCoord = StTrConns[L.side]
			end
		end
	end

end

-- Triggers during travel between outdoor maps by walk
mem.autohook2(0x4307e9, function(d)
	local t = {Map = d.eax, Straight = false}
	events.call("LeftToMap", t)
	if t.Straight then
		mem.i4[0x6F399C] = -1
	end
end)

function events.LeftToMap(t)
	local L = TravelsTable[string.lower(Game.MapStats[t.Map].FileName)]
	if L and L.StraightTravel then
		local A = Party[SwCoord] > 0 and -1 or 1
		Party[SwCoord] = (math.abs(Party[SwCoord]) - 30) * A
		t.Straight = true
	end
end

 -- Death map

 -- Disable original death movie, show one according to current continent.
mem.IgnoreProtection(true)
mem.u4[0x4a7c5e+4*6] = mem.u4[0x4a7c5e+4*4]
mem.IgnoreProtection(false)

function events.LoadMap()
	if Map.IsOutdoor() then
		vars.LastOutdoorMap = Map.Name
	end
end

function events.DeathMap(t)

	local CurCont = TownPortalControls.GetCurrentSwitch()
	local ContMap = Game.DeathMaps[CurCont]
	local DefMap = ContMap[1].n == "" and ContMap[2] or ContMap[1]

	if DefMap.n == "" then
		CurCont = random(1, 3)
		ContMap = Game.DeathMaps[CurCont]
		DefMap = ContMap[1].n == "" and ContMap[2] or ContMap[1]
	end

	-- Show death movie
	local tmpT = {movie = Game.ContinentSettings[CurCont].DeathMovie}
	events.call("ShowDeathMovie", tmpT)
	if string.len(tmpT.movie) > 0 then
		if CurCont == 3 then
			evt.ShowMovie{0, 0, tmpT.movie}
		else
			evt.ShowMovie{1, 0, tmpT.movie}
		end
	end
	--

	if Map.Name == ContMap[1].n or vars.LastOutdoorMap == ContMap[1].n then
		ContMap = ContMap[1]
	else
		ContMap = ContMap[2]
	end

	ContMap = ContMap.n ~= "" and ContMap or DefMap

	t.Name = ContMap.n
	Party.X = ContMap.X
	Party.Y = ContMap.Y
	Party.Z = ContMap.Z
	Party.Direction = ContMap.Dir

end

-- New game map

function events.NewGameMap()
	Log(Merge.Log.Info, "%s: NewGameMap", LogId)

	local ContMap = Game.DeathMaps[TownPortalControls.GetCurrentSwitch()][1]
	Party.X = ContMap.X
	Party.Y = ContMap.Y
	Party.Z = ContMap.Z
	Party.Direction = ContMap.Dir

end

function events.IsUnderwater(t)
	for i,v in Game.MapStats do
		if v.FileName == t.Map then
			if v.EaxEnvironments == 22 then
				t.Result = true
			end
			break
		end
	end
end

-- Dimension door setup
local DimDoorSet = false
local StdTPHeader = Game.GlobalTxt[10]

function events.LeaveMap()
	if TownPortalControls.GetCurrentSwitch() == 4 then
		Game.GlobalTxt[10] = StdTPHeader
	end
	DimDoorSet = false
end

function TownPortalControls.RevertTPSwitch()
	TownPortalControls.CheckSwitch()
	Game.GlobalTxt[10] = StdTPHeader
	RemoveTimer(TownPortalControls.RevertTPSwitch)
end

function TownPortalControls.GenDimDoor()
	local UseDDMapBuffs = Merge and Merge.Settings
		and Merge.Settings.DimensionDoor
		and Merge.Settings.DimensionDoor.RestrictMaps or false

	local JadamMaps 	= {1,2,6,1,2,7,7,8}
	local AntagrichMaps	= {64,67,67,68,70,65,66,72}
	local EnrothMaps	= {144,151,150,143,147}

	local StartingMaps = {1, 62, 151}
	local SecondaryMaps = {2, 63, nil}
	local SecondaryMapsQBits = {{93, false}, {648, true}, nil}

	local DDMapBuffs = {
		--[1] = {
			[1] = 801, [2] = 802, [3] = 803, [4] = 804,
			[5] = 805, [6] = 806, [7] = 807, [8] = 808,
			[13] = 813,
		--},
		--[2] = {
			[62] = 816, [63] = 817, [64] = 818, [65] = 819,
			[66] = 820, [67] = 821, [68] = 824, [69] = 825,
			[70] = 826, [71] = 827, [72] = 828, [73] = 829,
		--},
		--[3] = {
			[137] = 831, [138] = 832, [139] = 833, [140] = 834,
			[141] = 835, [142] = 836, [143] = 837, [144] = 838,
			[145] = 839, [146] = 840, [147] = 841, [148] = 842,
			[149] = 843, [150] = 844, [151] = 845
		--}
	}

	local DDMapExtra = {
		[1] = {X = 3560, Y = 7696, Z = 544, Dir = 0, Pic = 1},
		[2] = {X = 10219, Y = -15624, Z = 265, Dir = -12, Pic = 2},
		[62] = {X = 12552, Y = 800, Z = 193, Dir = 512, Pic = 8},
		[63] = {X = -16832, Y = 12512, Z = 372, Dir = 0, Pic = 1},
		[151] = {X = -9728, Y = -11319, Z = 160, Dir = 512, Pic = 2}
	}

	local TPSets = TownPortalControls.Sets[4]

	local function ProcessContinent(ContId, PicPrefix, TPSet, Maps)
		if UseDDMapBuffs then
			local DDMaps, MapsIdx = {}, {}
			for k, map in pairs(Maps) do
				if Party.QBits[DDMapBuffs[map]] then
					table.insert(DDMaps, map)
					table.insert(MapsIdx, k)
				end
			end
			if table.isempty(DDMaps) then
				if SecondaryMaps[ContId]
						and SecondaryMapsQBits[ContId][2]
						and Party.QBits[SecondaryMapsQBits[ContId][1]] then
					table.insert(DDMaps, SecondaryMaps[ContId])
					table.insert(MapsIdx, 0)
				else
					table.insert(DDMaps, StartingMaps[ContId])
					table.insert(MapsIdx, 0)
				end
			end
			local CurMap = random(1, #DDMaps)
			--Log(Merge.Log.Info, "DDMap[%d]=%d,%d", CurMap, DDMaps[CurMap], MapsIdx[CurMap])
			TPSet.IN = PicPrefix .. MapsIdx[CurMap]
			TPSet.Map = DDMaps[CurMap]
			if DDMapExtra[TPSet.Map] then
				TPSet.X = DDMapExtra[TPSet.Map].X
				TPSet.Y = DDMapExtra[TPSet.Map].Y
				TPSet.Z = DDMapExtra[TPSet.Map].Z
				TPSet.Dir = DDMapExtra[TPSet.Map].Dir
				if MapsIdx[CurMap] == 0 then
					TPSet.IN = PicPrefix .. DDMapExtra[TPSet.Map].Pic
				end
			end
			--Log(Merge.Log.Info, "TPSet: %d", TPSet.Map)
		else
			local CurMap = random(1, #Maps)
			TPSet.IN	= PicPrefix .. CurMap
			TPSet.Map	= Maps[CurMap]
		end
	end

	ProcessContinent(1, "TPJadam",	TPSets[1], JadamMaps)
	ProcessContinent(2, "TPAntag", TPSets[3], AntagrichMaps)
	ProcessContinent(3, "TPEnroth",TPSets[5], EnrothMaps)

end

function TownPortalControls.DimDoorEvent()
	Log(Merge.Log.Info, "%s: DimDoor event; x = %d, y = %d", LogId, Party.X, Party.Y)
	Game.ShowStatusText(Game.GlobalTxt[737])

	if not DimDoorSet then
		TownPortalControls.GenDimDoor()
		DimDoorSet = true
	end

	TownPortalControls.SwitchTo(4)
	Timer(TownPortalControls.RevertTPSwitch, const.Minute*8, Game.Time+const.Minute*8, false, false)

	Game.GlobalTxt[10] = " "

end

-- Different loading screens for continents
local function MapOfContinent(Map)
	local MapId

	for i,v in Game.MapStats do
		if v.FileName == Map then
			MapId = i
			break
		end
	end

	if not MapId then
		return TownPortalControls.GetCurrentSwitch()
	end

	return Game.Bolster.MapsSource[MapId].Continent or TownPortalControls.GetCurrentSwitch()
end

function events.GetLoadingPic(t)
	local CurCont = MapOfContinent(Map.Name) -- Name used instead of index, because, "MapStatsIndex" field of map structure have not been changed yet.
	local ContPicList = Game.ContinentSettings[CurCont].LoadingPics
	t.Pic = ContPicList[random(1, #ContPicList)]
end

Log(Merge.Log.Info, "Init finished: %s", LogId)
