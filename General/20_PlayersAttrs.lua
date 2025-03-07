-- Save and restore Player.Attrs to/from vars.PlayersAttrs
local LogId = "PlayersAttrs"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MF, MV = Merge.Functions, Merge.Vars

function events.GameInitialized2()
	MV.PlayersAttrs = MV.PlayersAttrs or {}

	-- Rod:
	-- "Player" is lua table with custom metatable, thus we have
	--     to edit metatable to properly add new field:
	local player = Party.PlayersArray[0]
	local metatable = getmetatable(player)
	if not metatable.offsets.Attrs then
		metatable.offsets.Attrs = 0
		metatable.members.Attrs = function(offset, parent, field, value)
			local playerId = (parent["?ptr"] - Party.PlayersArray["?ptr"])/parent["?size"]
			if value then
				MV.PlayersAttrs[playerId] = value
			else
				return MV.PlayersAttrs[playerId]
			end
		end
		setmetatable(player, metatable)
	end
	-- Rod.
end

function events.BeforeSaveGame()
	Log(Merge.Log.Info, "PlayersAttrs: BeforeSaveGame")
	vars.PlayersAttrs = MV.PlayersAttrs
end

function events.BeforeLoadMap(WasInGame)
	if not WasInGame then
		Log(Merge.Log.Info, "PlayersAttrs: BeforeLoadMap")
		-- Looks like new game start time can be bigger than 138240
		if not vars.PlayersAttrs and Game.Time <= 138245 and not MV.NewGame then
			-- Clear PlayersAttrs on non-initial new game autosave load
			Log(Merge.Log.Warning, "%s: [%d] No vars.PlayersAttrs, reset PlayersAttrs", LogId, Game.Time)
			MF.ResetPlayersAttrs()
		end

		MV.PlayersAttrs = vars.PlayersAttrs or MV.PlayersAttrs
		if MV.PlayersAttrs == nil then
			Log(Merge.Log.Info, "PlayersAttrs: neither MV.PlayersAttrs nor vars.Players.Attrs")
			MV.PlayersAttrs = {}
		end

		for k = 0, Party.PlayersArray.count - 1 do
			local player = Party.PlayersArray[k]
			--Log(Merge.Log.Info, "PlayersAttrs: Player %d", k)
			MV.PlayersAttrs[k] = MV.PlayersAttrs[k] or {}
			if player.Attrs.Race == nil then
				player.Attrs.Race = GetCharRace(player)
				Log(Merge.Log.Info, "Set default race %d for player %d", player.Attrs.Race, k)
			end
			if player.Attrs.PromoAwards == nil then
				player.Attrs.PromoAwards = {}
			end
		end
	end
end

local function player_attrs_clear(roster_id)
	if not roster_id then return end
	--MV.PlayersAttrs[roster_id] = {}
	MV.PlayersAttrs[roster_id] = MV.PlayersAttrs[roster_id] or {}
	local attrs = MV.PlayersAttrs[roster_id]
	attrs.Race = nil
	attrs.Maturity = nil
	attrs.Alignment = nil
	attrs.PromoAwards = {}
end
MF.PlayerAttrsClear = player_attrs_clear

local function reset_players_attrs()
	for k = 0, Party.PlayersArray.count - 1 do
		player_attrs_clear(k)
	end
end
MF.ResetPlayersAttrs = reset_players_attrs

function events.NewGame(WasInGame, Continent)
	Log(Merge.Log.Info, "%s: NewGame, was in game: %d", LogId, WasInGame and 1 or 0)
	reset_players_attrs()
end

Log(Merge.Log.Info, "Init finished: %s", LogId)

