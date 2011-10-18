--[[
	Chimaera EPGP
	Raid loot allocation system.
	Jug <jug@mangband.org>
	
	An implementation of the EPGP raid loot allocation system.  Based on the
	documentation available at epgpweb.com.
--]]

-- Update frequency when raiding (in seconds)
-- EP is adjusted at each interval.
UpdateFreq = 10

-- Decay amount (this should not be here)
DecayAmount = 7 -- in percent

-- Our main EPGP data
epgp = GuildEPGP:Create()

-- Create main window
win = NewWindow("Main", "Chimaera EPGP")
win:SetVisible(true)
win:SetWidth(400)
win:SetHeight(300)
win:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, 200)
win.timerActive = false

-- Create any dialogs
promptDialog = NewDialog(win)

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

-- Decay data
function DoDecay()
	epgp:ApplyDecay(DecayAmount)
	UpdateGrid()
end

function ButtonDecayClick()
	GetConfirmation("Apply decay to all players in the database?",
		DoDecay)
end

-- Delete players data
function DeleteSelection()
	nuke = win.grid:GetSelection()
	if #nuke <= 0 then return end
	-- delete, go backwards
	for i = #nuke, 1, -1 do
		table.remove(epgp.players, nuke[i])
	end
	win.grid:ClearSelection()
	UpdateGrid()
end

function ButtonDeleteClick()
	GetConfirmation("Really permanently delete selected players?", 
		DeleteSelection)
end

function ButtonAddEPClick()
	GetEntry("Enter the number of Effort Points to add:",
		DoAddEP)
end

function ButtonAddGPClick()
	GetEntry("Enter the number of Gear Points:",
		DoAddGP)
end

function DoAddEP(text)
	-- Bail out if we don't have a valid number
	ep = tonumber(text)
	if not ep then return end
	-- Add ep to all selected players
	add = win.grid:GetSelection()
	if #add <= 0 then return end
	-- Add the EP
	for i = 1, #add do
		epgp.players[add[i]]:IncEP(ep)
	end
	UpdateGrid()	
end

function DoAddGP(text)
	-- Bail out if we don't have a valid number
	gp = tonumber(text)
	if not gp then return end
	-- Add gp to selected player
	add = win.grid:GetSelection()
	if #add ~= 1 then 
		GetConfirmation("Must select only *one* player when adding GP.", nil)
		return
	end
	-- Add the GP
	epgp.players[add[1]]:IncGP(gp)
	UpdateGrid()
	
end

-- Show a confirmation dialog
-- Pass prompt and callback to call on OK clicked
function GetConfirmation(msg, ok)
	promptDialog:SetOKCallback(ok)	
	promptDialog:Confirm(msg)
end

-- Show a dialog prompting for user entry
function GetEntry(msg, ok)
	promptDialog:SetOKCallback(ok)	
	promptDialog:GetEntry(msg)
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
	-- bail out if we don't have a config
	if not saved_epgp then return end
	-- load the config
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
win.toolbar:AddButton("addplayers.png", 
	"Import current raid members (and current target)", ButtonAddClick)
win.toolbar:AddButton("delete.png", 
	"Delete selected players (Warning: Permanent!)", ButtonDeleteClick)
win.toolbar:AddButton("raid.png", 
	"Start/Stop raid timer", ButtonTimerClick)
win.toolbar:AddButton("addep.png", 
	"Add Effort Points to selected players", ButtonAddEPClick)
win.toolbar:AddButton("addgp.png", 
	"Add loot to selected player (Add GP)", ButtonAddGPClick)
win.toolbar:AddButton("decay.png", 
	"Calculate decay for all players", ButtonDecayClick)

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
