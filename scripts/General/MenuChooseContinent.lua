local LogId = "MenuChooseContinent"
local Log = Log
Log(Merge.Log.Info, "Init started: %s", LogId)
local MSA = Merge.Settings.Animations

local CreateButton, CreateIcon, UnloadIcons = CustomUI.CreateButton, CustomUI.CreateIcon, CustomUI.UnloadIcons
local SlJadam, SlEnroth, SlAntagrich, SlBackground

local ChooseContinentScreen = 97

-- Skip starting logo animations
if MSA and MSA.SkipLogos and MSA.SkipLogos == 1 then
	mem.nop2(0x4BD288, 0x4BD2D8)
end

-- Disable mm8 intro. Show it after continent selection.
mem.nop2(0x4BD2D8, 0x4BD2EB)

-- Do not set QBits[85] at the start of the new game
mem.nop(0x49077B, 2)
mem.nop(0x490786, 5)

 -- Process "Continent settings.txt"

local function ProcessContSets()

	local TxtTab = io.open("Data/Tables/Continent settings.txt", "r")
	if not TxtTab then
		Game.ContinentSettings = {[1] = {}, [2] = {}, [3] = {}, [4] = {}}

		Game.DeathMaps =	{{[1] = {n = "out01.odm", X = 3560, Y = 7696, Z = 544, Dir = 0},		[2] = {n = "out02.odm", X = 10219, Y = -15624, Z = 265, Dir = -12}},

							{[1] = {n = "7out01.odm", X = 12552, Y = 800, Z = 193, Dir = 512},		[2] = {n = "7out02.odm", X = -16832, Y = 12512, Z = 372, Dir = 0}},

							{[1] = {n = "oute3.odm", X = -9728, Y = -11319, Z = 160, Dir = 512}, 	[2] = {n = "oute3.odm", X = -9728, Y = -11319, Z = 160, Dir = 512}}}
		return
	end

	local ContSets = {}
	local DeathMaps = {}
	local LineIt = TxtTab:lines()

	LineIt() -- skip header
	for line in LineIt do
		local Words = string.split(line, "\9")

		table.insert(ContSets, {
			UseRep		= (tonumber(Words[4]) or tonumber(Words[5])) and true or Words[6] == "x",
			RepCont		= tonumber(Words[3]),
			RepGuards	= tonumber(Words[4]),
			RepShops	= tonumber(Words[5]),
			RepNPC		= Words[6] == "x",
			RepDecMult	= tonumber(Words[7]),
			RepDecFlat	= tonumber(Words[8]),
			RepDecMin	= tonumber(Words[9]),
			ProfNews	= Words[10] == "x",
			NPCFollowers	= Words[11] == "x",
			Saturation	= tonumber(Words[12]),
			Softness	= tonumber(Words[13]),
			DeathMovie	= Words[14],
			Water		= string.split(string.replace(Words[15], " ", ""), ","),
			Skies		= string.split(string.replace(Words[26], " ", ""), ","),
			LoadingPics	= string.split(string.replace(Words[27], " ", ""), ",")
		})

		table.insert(DeathMaps, {
			[1] = {n = Words[16], X = tonumber(Words[17]) or 0, Y = tonumber(Words[18]) or 0, Z = tonumber(Words[19]) or 0, Dir = tonumber(Words[20]) or 0},
			[2] = {n = Words[21], X = tonumber(Words[22]) or 0, Y = tonumber(Words[23]) or 0, Z = tonumber(Words[24]) or 0, Dir = tonumber(Words[25]) or 0}
		})
	end

	io.close(TxtTab)
	Game.ContinentSettings = ContSets
	Game.DeathMaps = DeathMaps

end
ProcessContSets()

 --	Menu
local SelectionStarted = false
local FromScreen = 0
function events.GameInitialized2()
	local function MOStd()
		Game.PlaySound(12100)
	end

	local function SlChosen(StartMap, Continent)
		UnloadIcons(ChooseContinentScreen)
		if StartMap then
			local Intros = {"intro", "7intro", "6intro"}
			events.call("NewGame", FromScreen > 0, Continent)
			Game.NewGameMap = StartMap
			TownPortalControls.SwitchTo(Continent)
			if FromScreen == 0 then -- Main menu
				Game.CurrentScreen = 0
				if not MSA or not MSA.SkipNewGameIntro or MSA.SkipNewGameIntro < 2 then
					evt.ShowMovie{1, 0, Intros[Continent]}
				end
				mem.u4[0x6ceb24] = 1 -- new game menu action
				mem.u4[0x51e330] = 1 -- action in queue flag
			else
				Game.CurrentScreen = 21
				if not MSA or not MSA.SkipNewGameIntro or MSA.SkipNewGameIntro == 0 then
					evt.ShowMovie{1, 0, Intros[Continent]}
				end
				DoGameAction(124, 0, 0, true) -- Start new game
			end
		else
			Game.CurrentScreen = FromScreen
		end
	end

	-- Setup special screen for interface manager
	const.Screens.ChooseContinent = ChooseContinentScreen
	CustomUI.NewScreen(ChooseContinentScreen)

	SlBackground	= CreateIcon{Icon = "SlBackgr",
							Condition = function()
								if Keys.IsPressed(const.Keys.ESCAPE) then
									SlChosen()
								end
								return true
							end,
							BlockBG		= true,
							Screen		= ChooseContinentScreen,
							Layer		= 1,
							DynLoad = true}

	SlJadam 		= CreateButton{IconUp = "SlJadamDw", IconDown = "SlJadamUp", IconMouseOver = "SlJadamUp",
							Action = function()
								SlChosen("out01.odm", 1)
							end,
							MouseOverAction = MOStd,
							DynLoad = true,
							Layer		= 1,
							IsEllipse 	= true,
							Screen		= ChooseContinentScreen,
							X = 208, Y = 31}

	SlAntagrich		= CreateButton{IconUp = "SlAntagDw", IconDown = "SlAntagUp", IconMouseOver = "SlAntagUp",
							Action = function()
								SlChosen("7out01.odm", 2)
							end,
							MouseOverAction = MOStd,
							DynLoad = true,
							Layer		= 0,
							IsEllipse 	= true,
							Screen		= ChooseContinentScreen,
							X = 322, Y = 228}

	SlEnroth		= CreateButton{IconUp = "SlEnrothDw", IconDown = "SlEnrothUp", IconMouseOver = "SlEnrothUp",
							Action = function()
								SlChosen("oute3.odm", 3)
							end,
							MouseOverAction = MOStd,
							DynLoad = true,
							Layer		= 0,
							IsEllipse 	= true,
							Screen		= ChooseContinentScreen,
							X = 94, Y = 229}

end

function events.MenuAction(t)
	-- Override "New game" button original behaivor
	if t.Action == 54 and not t.Handled then
		SelectionStarted = true
		t.Handled = true
		FromScreen = 0 -- Main menu
		Game.CurrentScreen = const.Screens.ChooseContinent
		Game.PlaySound(66)
	end
end

function events.Action(t)
	-- Override "New game" button original behaivor
	if t.Action == 124 and not t.Handled and mem.u4[0x6f30c0] == 124 and Game.CurrentScreen == 1 then
		t.Handled = true
		FromScreen = 1 -- Ingame menu
		Game.CurrentScreen = const.Screens.ChooseContinent
		Game.PlaySound(66)
	end
end

Log(Merge.Log.Info, "Init finished: %s", LogId)

