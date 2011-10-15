
-- Our main EPGP data
epgp = GuildEPGP:Create()

-- Create main window
win = NewWindow("Main", "Chimaera EPGP")
win:SetVisible(true)
win:SetWidth(400)
win:SetHeight(300)
win:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, 200)

-- Update our grid with the EPGP data
function UpdateGrid()
	win.grid:Clear()
	nump = epgp:GetNumPlayers()
	numr = win.grid.numRows
	while numr < nump do
		win.grid:AddRow({"Foo","0","0","0"})
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
		row:SetText(2, player:GetEP())
		row:SetText(3, player:GetGP())
		row:SetText(4, player:GetPR())
	end
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
		player.GP = tostring(p:GetGP())
		table.insert(saved_epgp, player)
	end
end

-- Toolbar icons
win.toolbar:AddButton("iadd.png", "add.png", "Add raid members", ButtonAddClick)
win.toolbar:AddButton("idelete.png", "delete.png", "", nil)
win.toolbar:AddButton("icalculator.png", "calculator.png", "", nil)
win.toolbar:AddButton("process.png", "process.png", "", nil)

win.grid = NewGrid(win.workspace, 4, 10)

-- Global event handlers
table.insert(Event.Addon.SavedVariables.Load.End, 
	{onVariablesLoaded, "EPGP", "Saved vars loaded"})
table.insert(Event.Addon.SavedVariables.Save.Begin, 
	{onVariablesSave, "EPGP", "About to save vars"})
