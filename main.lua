--[[
	Chimaera EPGP
	Raid loot allocation system.
	Jug <jug@mangband.org>
	
	An implementation of the EPGP raid loot allocation system.  Based on the
	documentation available at epgpweb.com.
--]]

-- Update frequency when raiding (in seconds)
-- EP is adjusted at each interval.
UpdateFreq = 60*5

-- Decay amount (this should not be here)
DecayAmount = 7 -- in percent

-- Our main EPGP data
epgp = GuildEPGP:Create()

-- Our configuration options
settings = nil

-- Default GP price list
GPPriceList = {
	{"Neck / Ring", 40},
	{"Gloves / Feet / Belt", 60},
	{"Head / Shoulders", 60},
	{"1 Handed / Ranged / Wand", 60},
	{"Trinket", 75},
	{"Chest / Legs", 100},
	{"Relic 1 Handed", 150},
	{"Relic Ranged / Wand", 150},
	{"2 Handed", 180},
	{"Relic 2 Hand", 300},
}

-- Our grid status icons
StatusGreen = "gfx/icons/status_green.png"
StatusAmber = "gfx/icons/status_orange.png"
StatusRed = "gfx/icons/status_red.png"

-- Remember our sort order
LastSort = 4 -- also default sort order

-- Create main window
win = NewWindow("Main", "Chimaera EPGP")
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
	local players = nil
	-- Only display active players if we're raiding
	if win.timerActive then
		players = epgp:GetActivePlayers()
	else
		players = epgp.players
	end
	-- Get player list
	nump = #players
	numr = win.grid.numRows
	while numr < nump do
		win.grid:AddRow({"","0","0","0"}, false)
		numr = numr + 1
	end
	-- Add all the player data to the grid
	for i = 1, nump do
		player = players[i]
		row = win.grid.rows[i]
		row:SetText(1, player.playerName)
		if player.calling then
			row:SetTextColour(1, ClassColours[player.calling])
		end
		row:SetText(2, round(player:GetEP(), 1))
		row:SetText(3, player:GetGP())
		row:SetText(4, round(player:GetPR(),2))
		for j = 2, 4 do
			row:SetTextColour(j, {r=1, g=1, b=1, a=1})
		end
		-- Set status icon
		if player.standby then
			row:SetIcon(StatusAmber)
		elseif player.active then
			row:SetIcon(StatusGreen)
		else
			row:SetIcon(StatusRed)
		end
	end
	win.grid:Resize()
end

-- Sort function
function Sort(index)
	-- We must clear any selection here as we don't support sorting selections
	win.grid:ClearSelection()
	if not index then
		index = LastSort
	else
		LastSort = index
	end
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
	UpdateGrid()
end

-- Grid header click event handler
function onHeaderClicked(index)
	Sort(index)
end

-- Some event handlers
function ButtonAddClick()
	raid = GetRaidMembers(true)
	-- Add players to guild epgp data
	for _, p in pairs(raid) do
		epgp:AddPlayer(p.name, p.calling)
	end
	UpdateGrid(win.grid, epgp)
end

-- Start/Stop raid timer
function ButtonTimerClick()
	win.grid:ClearSelection()
	-- Start/stop raiding
	win.timerActive = not win.timerActive
	if win.timerActive then
		win.lastFrameTime = Inspect.Time.Real()
		win.caption:SetText("Chimaera EPGP [Raid Active]")
		-- Determine who is active and mark them
		UpdateActive()
	else
		win.caption:SetText("Chimaera EPGP")
		-- Coming out of raid mode, clear all "active" flags
		for i = 1, #epgp.players do
			epgp.players[i].active = false
		end		
	end
	UpdateGrid()
end

-- Determine who is active/standby and update the database status
function UpdateActive()
	active = GetRaidMembers(false)
	-- Iterate all players in the database, set active if they are in 
	-- our "active" list
	for i = 1, #epgp.players do
		player = epgp.players[i].playerName
		epgp.players[i].active = false
		-- Brute force search, there aren't too many...
		for j = 1, #active do
			if player == active[j].name then
				epgp.players[i].active = true
				break
			end
		end
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

-- Mark players as standby
function ButtonStandbyClick()
	standby = win.grid:GetSelection(true)
	if #standby <= 0 then return end
	-- mark as standby
	for i = 1, #standby do
		epgp:SetStandbyStatus(standby[i], not epgp:GetStandbyStatus(standby[i]))
	end
	win.grid:ClearSelection()
	UpdateGrid()
end

-- Delete players data
function DeleteSelection()
	nuke = win.grid:GetSelection(true)
	if #nuke <= 0 then return end
	-- delete
	for i = 1, #nuke do
		epgp:DeletePlayer(nuke[i])
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
	GetOption("Enter the number of Gear Points:",
		DoAddGP)
end

function DoAddEP(text)
	-- Bail out if we don't have a valid number
	ep = tonumber(text)
	if not ep then return end
	-- Add ep to all selected players
	add = win.grid:GetSelection(true)
	if #add <= 0 then return end
	-- Add the EP
	for i = 1, #add do
		p = epgp:GetPlayer(add[i])
		if p then
			p:IncEP(ep)
		end
	end
	Sort()	
end

function DoAddGP(text)
	-- Bail out if we don't have a valid number
	gp = tonumber(text)
	if not gp then return end
	-- Add gp to selected player
	add = win.grid:GetSelection(true)
	if #add ~= 1 then 
		GetConfirmation("Must select only *one* player when adding GP.", nil)
		return
	end
	-- Add the GP
	p = epgp:GetPlayer(add[1])
	if p then
		p:IncGP(gp)
	end
	Sort()
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

-- Show a dialog prompting for an option selection
function GetOption(msg, ok)
	promptDialog:SetOKCallback(ok)	
	promptDialog:GetOption(msg, GPPriceList)
end

-- Add some EP to all currently active players
function IncrementRaidEP()
	-- Work out the amount of EP per interval
	ep = (EPGP.epPerHour / 3600) * UpdateFreq
	-- Get all active players
	active = epgp:GetActivePlayers()
	-- Add this to all active players
	for _, p in ipairs(active) do
		p:IncEP(ep)
	end
	UpdateGrid()
end

-- Saved variables have been loaded
function onVariablesLoaded(id)
	if id ~= "EPGP" then return end
	-- load the config
	for _, p in pairs(saved_epgp) do
		np = epgp:AddPlayer(p.playerName, p.calling)
		np:SetGP(tonumber(p.GP))
		np:SetEP(tonumber(p.EP))
	end
	-- Other settings
	if not saved_config then
		-- Go for defaults
		saved_config = {}
		saved_config["visible"] = true
	end
	-- Apply configuration options
	win:SetVisible(saved_config["visible"])
	if not saved_config["visible"] then
		print("EPGP loaded, main window is hidden, use /epgp to show it")
	end
	if saved_config["gp_prices"] then
		GPPriceList = saved_config["gp_prices"]
	else
		saved_config["gp_prices"] = GPPriceList
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

-- Main Window closed
function onMainWindowClose()
	print("Closed EPGP Window, use /epgp to show it again")
	win:SetVisible(false)
	saved_config["visible"] = false
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

-- Detailed slash command handler
local function ProcessCommand(args)
	if args[1] == "add" then
		if #args >= 2 then
			-- Import the player, we don't know their calling yet
			epgp:AddPlayer(args[2], "")
			UpdateGrid()
			Sort()
		end
	end
end

-- Base Slash command handler
local function slashCommand(param)
	if param == "" then
		local visible = not win:GetVisible()
		win:SetVisible( visible )
		saved_config["visible"] = visible
	else
		local parts = {}
		for w in param:gmatch("%w+") do
			table.insert(parts, w)
		end
		if #parts >= 1 then
			ProcessCommand(parts)
		end
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
	"Add/remove Effort Points to selected players", ButtonAddEPClick)
win.toolbar:AddButton("addgp.png", 
	"Add/remove loot for selected player (Add GP)", ButtonAddGPClick)
win.toolbar:AddButton("decay.png", 
	"Calculate and apply decay for all players", ButtonDecayClick)
win.toolbar:AddButton("standby.png", 
	"Toggle standby status of selected players", ButtonStandbyClick)

-- Create our grid
win.grid = NewGrid(win.workspace, 4, 10)
win.grid:AddRow({"Name", "EP", "GP", "PR"}, true)
win.grid:SetHeaderCallback(onHeaderClicked)
-- Hook close event
win:SetCloseCallback(onMainWindowClose)

-- Global event handlers
table.insert(Event.Addon.SavedVariables.Load.End, 
	{onVariablesLoaded, "EPGP", "Saved vars loaded"})
table.insert(Event.Addon.SavedVariables.Save.Begin, 
	{onVariablesSave, "EPGP", "About to save vars"})
table.insert(Event.System.Update.Begin, 
	{onFrameUpdate, "EPGP", "Frame redraw event"})
table.insert (Command.Slash.Register("epgp"), 
	{slashCommand, "EPGP", "Show/hide main window"})
