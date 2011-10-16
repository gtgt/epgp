
-- Update frequency when raiding (in seconds)
-- EP is adjusted at each interval.
UpdateFreq = 10

-- Our main EPGP data
epgp = GuildEPGP:Create()

-- Create main window
win = NewWindow("Main", "Chimaera EPGP")
win:SetVisible(true)
win:SetWidth(400)
win:SetHeight(300)
win:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, 200)
win.timerActive = false

-- Rounding numbers
function round(num, places)
  local mult = 10^(places or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Update our grid with the EPGP data
function UpdateGrid()
	win.grid:Clear()
	nump = epgp:GetNumPlayers()
	numr = win.grid.numRows
	while numr < nump do
		win.grid:AddRow({"","0","0","0"}, false)
		numr = numr + 1
	end
	-- Add all the player data to the grid
	for i = 1, nump do
		player = epgp.players[i]
		row = win.grid.rows[i]
		row:SetText(1, player.playerName)
		if player.calling then
			row:SetTextColour(1, ClassColours[player.calling])
		end
		row:SetText(2, round(player:GetEP(), 1))
		row:SetText(3, player:GetGP())
		row:SetText(4, round(player:GetPR(),2))
	end
	win.grid:Resize()
end

-- Sort function
function Sort(index)
	-- Define a comparason function for each column
	function orderName(a, b)
		return a.playerName < b.playerName
	end
	function orderEP(a, b)
		return a:GetEP() > b:GetEP()
	end
	function orderGP(a, b)
		return a:GetGP() > b:GetGP()
	end
	function orderPR(a, b)
		return a:GetPR() > b:GetPR()
	end
	-- Put functions in column order
	compare = {orderName, orderEP, orderGP, orderPR}
	-- Do the sort
	table.sort(epgp.players, compare[index])
end

-- Grid header click event handler
function onHeaderClicked(index)
	-- We must clear any selection here as we don't support sorting selections
	win.grid:ClearSelection()
	Sort(index)
	UpdateGrid()
end

-- Some event handlers
function ButtonAddClick()
	raid = GetRaidMembers()
	-- Add players to guild epgp data
	for _, p in pairs(raid) do
		epgp:AddPlayer(p.name, p.calling)
	end
	UpdateGrid(win.grid, epgp)
end

-- Start/Stop raid timer
function ButtonTimerClick()
	win.timerActive = not win.timerActive
	if win.timerActive then
		win.lastFrameTime = Inspect.Time.Real()
		win.caption:SetText("Chimaera EPGP [Raid Active]")
	else
		win.caption:SetText("Chimaera EPGP")
	end
end

-- Delete players data
function ButtonDeleteClick()
	nuke = win.grid:GetSelection()
	if #nuke <= 0 then return end
	-- delete, go backwards
	for i = #nuke, 1, -1 do
		table.remove(epgp.players, nuke[i])
	end
	win.grid:ClearSelection()
	UpdateGrid()
end

-- Add some EP to all currently active players
function IncrementRaidEP()
	-- Work out the amount of EP per interval
	ep = (EPGP.epPerHour / 3600) * UpdateFreq
	-- Add this to all active players
	for _, p in ipairs(epgp.players) do
		if p.active then
			p:IncEP(ep)
		end
	end
	UpdateGrid()
end

-- Saved variables have been loaded
function onVariablesLoaded()
	for _, p in pairs(saved_epgp) do
		np = epgp:AddPlayer(p.playerName, p.calling)
		np:SetGP(tonumber(p.GP))
		np:SetEP(tonumber(p.EP))
	end
	UpdateGrid()	
end

-- About to save variables
function onVariablesSave(id)
	if id ~= "EPGP" then return end
	saved_epgp = {}
	for _, p in pairs(epgp.players) do
		player = {}
		player.playerName = p.playerName
		player.calling = p.calling
		player.EP = tostring(p:GetEP())
		player.GP = tostring(p.realGP)
		table.insert(saved_epgp, player)
	end
end

-- Frame update event handler, used for timing
function onFrameUpdate()
	-- Bail out if we're not actively timing
	if not win.timerActive then return end
	if not win.lastFrameTime then win.lastFrameTime = 0 end
	-- Get the current time
	t = Inspect.Time.Real()
	if t > win.lastFrameTime + UpdateFreq then
		win.lastFrameTime = t
		IncrementRaidEP()
	end
end

-- Slash command handler
local function slashCommand(param)
	if param == "" then
		win:SetVisible( not win:GetVisible() )
	end
end

-- Toolbar icons
win.toolbar:AddButton("iadd.png", "add.png", 
	"Add current raid members", ButtonAddClick)
win.toolbar:AddButton("idelete.png", "delete.png", 
	"Delete selected players (Warning: Permanent!)", ButtonDeleteClick)
win.toolbar:AddButton("icalculator.png", "calculator.png", "", nil)
win.toolbar:AddButton("iprocess.png", "process.png", 
	"Start/Stop raid timer", ButtonTimerClick)

-- Create our grid
win.grid = NewGrid(win.workspace, 4, 10)
win.grid:AddRow({"Name", "EP", "GP", "PR"}, true)
win.grid:SetHeaderCallback(onHeaderClicked)

-- Global event handlers
table.insert(Event.Addon.SavedVariables.Load.End, 
	{onVariablesLoaded, "EPGP", "Saved vars loaded"})
table.insert(Event.Addon.SavedVariables.Save.Begin, 
	{onVariablesSave, "EPGP", "About to save vars"})
table.insert(Event.System.Update.Begin, 
	{onFrameUpdate, "EPGP", "Frame redraw event"})
table.insert (Command.Slash.Register("epgp"), 
	{slashCommand, "EPGP", "Show/hide main window"})
