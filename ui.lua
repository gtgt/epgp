--[[
	EPGP GUI
	UI Implementation
	Jug <jug@mangband.org>
--]]

-- Default border colour
local bdColour = {r = 0.2, g = 0.2, b = 0.2, a = 1.0}
-- Default inner border colour 
local bdInsideColour = {r = 0.0, g = 0.0, b = 0.0, a = 1.0}
-- Default background colour 
local bkColour = {r = 0.15, g = 0.15, b = 0.15, a = 1.0}
-- Default workspace colour
local wkColour = {r = 0.25, g = 0.25, b = 0.25, a = 1.0}
-- Default grid background colour
local gdColour = {r = 0.0, g = 0.0, b = 0.0, a = 1.0}
-- Default grid header colour
local ghColour = {r = 0.25, g = 0.25, b = 0.25, a = 1.0}
-- Default row selected background colour
local gsColour = {r = 0.2, g = 0.25, b = 0.4, a = 1.0}


-- Border width
local bdWidth = 2
-- Inner border width
local bdInsideWidth = 6

local context = UI.CreateContext("EPGP")

-- Find our ultimate parent window
function FindParent(ctrl)
	parent = ctrl
	while not ctrl.rootWindow do
		ctrl = ctrl:GetParent()
	end
	return ctrl
end

-- Create a new window generic top level window
function NewWindow(description, title)
	win = UI.CreateFrame("Frame", description, context)
	win.rootWindow = true
	-- Window border
	win.border = UI.CreateFrame("Frame", "Border", win)
	win.border:SetLayer(0)
	win.border:SetPoint("TOPLEFT", win, "TOPLEFT")
	win.border:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT")
	win.border:SetBackgroundColor(bdColour.r, bdColour.g, bdColour.b, 
		bdColour.a)
	-- Window inner border
	win.iborder = UI.CreateFrame("Frame", "InnerBorder", win)
	win.iborder:SetLayer(1)
	win.iborder:SetPoint("TOPLEFT", win, "TOPLEFT", bdWidth, bdWidth)
	win.iborder:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT", -bdWidth, 
		-bdWidth)
	win.iborder:SetBackgroundColor(bdInsideColour.r, bdInsideColour.g, 
		bdInsideColour.b, bdInsideColour.a)
	-- Window background
	win.back = UI.CreateFrame("Frame", "Background", win)
	win.back:SetLayer(2)
	win.back:SetPoint("TOPLEFT", win, "TOPLEFT", 
		bdInsideWidth, bdInsideWidth)
	win.back:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT",
		-bdInsideWidth, -bdInsideWidth)
	win.back:SetBackgroundColor(bkColour.r, bkColour.g, 
		bkColour.b, bkColour.a)
	-- Window Title Bar
	win.titlebar = UI.CreateFrame("Frame", "Title", win.back)
	win.titlebar:SetLayer(3)
	win.titlebar:SetPoint("TOPLEFT", win.back, "TOPLEFT")
	win.titlebar:SetPoint("TOPRIGHT", win.back, "TOPRIGHT")
	win.titlebar:SetHeight(26)
	win.titlebar:SetBackgroundColor(bdInsideColour.r, bdInsideColour.g, 
		bdInsideColour.b, bdInsideColour.a)
	function win.titlebar.Event:LeftDown()
		-- Where are we clicked?
		m = Inspect.Mouse()
		self.x = self:GetLeft()
		self.y = self:GetTop()
		self.dx = m.x - self.x
		self.dy = m.y - self.y
		self.dragging = true
		-- Enable these events only when needed
		self.Event.LeftUp = self.LeftUp
		self.Event.LeftUpoutside = self.LeftUp
	end
	function win.titlebar:LeftUp()
		self.dragging = false
		self.Event.LeftUpoutside = nil
		self.Event.LeftUp = nil
	end
	function win.titlebar.Event:MouseMove()
		if self.dragging then
			local x, y
			m = Inspect.Mouse()
			x = m.x - self.dx
			y = m.y - self.dy
			w = FindParent(self)
			w:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
		end
	end
	-- Window Caption
	win.caption = UI.CreateFrame("Text", "TitleText", win.titlebar)
	win.caption:SetText(title)
	win.caption:SetPoint("TOPLEFT", win.titlebar, "TOPLEFT", 4, -2)
	win.caption:SetPoint("RIGHT", win.titlebar, "RIGHT")
	win.caption:SetFontSize(18)
	win.caption:SetLayer(4)
	-- Close icon
	win.closeicon = UI.CreateFrame("Texture", "CloseButton", win.titlebar)
	win.closeicon:SetTexture("EPGP", "gfx/close-unfocused.png")
	win.closeicon:SetPoint("TOPRIGHT", win.titlebar, "TOPRIGHT", 
		-bdWidth, bdWidth)
	win.closeicon:ResizeToTexture()
	win.closeicon:SetLayer(5)
	function win.closeicon.Event:MouseIn()
		self:SetTexture("EPGP", "gfx/close-focused.png")
	end
	function win.closeicon.Event:MouseOut()
		self:SetTexture("EPGP", "gfx/close-unfocused.png")
	end
	function win.closeicon.Event:LeftDown()
		print("Closed EPGP Window, use /epgp to show it again")
		parent = FindParent(self)
		parent:SetVisible(false)
	end
	-- Resize grip
	win.resize = UI.CreateFrame("Texture", "ResizeButton", win.back)
	win.resize:SetTexture("EPGP", "gfx/resize-grip.png")
	win.resize:SetPoint("BOTTOMRIGHT", win.back, "BOTTOMRIGHT", 0, 0)
	win.resize:ResizeToTexture()
	win.resize:SetLayer(9)	
	function win.resize.Event:LeftDown()
		-- Where are we clicked?
		m = Inspect.Mouse()
		w = FindParent(self)
		self.x = w:GetLeft()
		self.y = w:GetTop()
		self.dx = m.x - self.x
		self.dy = m.y - self.y
		self.dragging = true
		-- Enable these events only when needed
		self.Event.LeftUp = self.LeftUp
		self.Event.LeftUpoutside = self.LeftUp
	end
	function win.resize:LeftUp()
		self.dragging = false
		self.Event.LeftUpoutside = nil
		self.Event.LeftUp = nil
	end
	function win.resize.Event:MouseMove()
		if self.dragging then
			local x, y
			m = Inspect.Mouse()
			x = m.x - self.x
			y = m.y - self.y
			if y > 60 then
				w = FindParent(self)
				if not w.minWidth then w.minWidth = 0 end
				if x > w.minWidth then
					w:SetWidth(x)
				end
				w:SetHeight(y)
			end
		end
	end
	-- Toolbar
	win.toolbar = UI.CreateFrame("Frame", "Toolbar", win.back)
	win.toolbar:SetLayer(6)
	win.toolbar:SetPoint("TOPLEFT", win.titlebar, "BOTTOMLEFT")
	win.toolbar:SetPoint("TOPRIGHT", win.titlebar, "BOTTOMRIGHT")
	win.toolbar:SetHeight(32)
	win.toolbar:SetBackgroundColor(bkColour.r, bkColour.g, 
		bkColour.b, bkColour.a)
	win.toolbar.buttons = {}
	function win.toolbar:AddButton(icon, iconhighlight, tooltip, callback)
		but = UI.CreateFrame("Texture", "AddButton", win.toolbar)
		-- Remember icons
		but:SetTexture("EPGP", "gfx/"..icon)
		but.activeIcon = iconhighlight
		but.inactiveIcon = icon
		-- Remember tooltips
		but.tooltip = tooltip
		if #self.buttons == 0 then
			-- first button aligned to toolbar
			but:SetPoint("TOPLEFT", win.toolbar, "TOPLEFT", 4, 6)
		else
			-- subsequent buttons aligned to previous button
			but:SetPoint("TOPLEFT", 
				self.buttons[#self.buttons], "TOPRIGHT", 8, 0)
		end
		but:ResizeToTexture()
		but:SetLayer(8)
		table.insert(self.buttons, but)
		-- Set click handler
		but.Event.LeftDown = callback
		-- Mouseover highlights
		function but.Event:MouseIn()
			self:SetTexture("EPGP", "gfx/"..self.activeIcon)
			parent = FindParent(self)
			parent:SetStatus(self.tooltip)
		end
		function but.Event:MouseOut()
			self:SetTexture("EPGP", "gfx/"..self.inactiveIcon)
			parent = FindParent(self)
			parent:SetStatus("")
		end
	end
	-- Statusbar
	win.statusbar = UI.CreateFrame("Frame", "StatusBar", win.back)
	win.statusbar:SetLayer(6)
	win.statusbar:SetPoint("BOTTOMLEFT", win.back, "BOTTOMLEFT")
	win.statusbar:SetPoint("BOTTOMRIGHT", win.back, "BOTTOMRIGHT")
	win.statusbar:SetHeight(32)
	win.statusbar:SetBackgroundColor(bkColour.r, bkColour.g, 
		bkColour.b, bkColour.a)
	win.statusbar.label = UI.CreateFrame("Text", "Status", win.statusbar)
	win.statusbar.label:SetText("")
	win.statusbar.label:SetPoint("TOPLEFT", win.statusbar, "TOPLEFT", 8, 0)
	win.statusbar.label:SetPoint("BOTTOMRIGHT", win.statusbar, "BOTTOMRIGHT")
	win.statusbar.label:SetFontSize(14)
	win.caption:SetLayer(9)
	-- Allow setting of the status
	function win:SetStatus(text)
		win.statusbar.label:SetText(text)
	end
	-- Workspace
	win.workspace = UI.CreateFrame("Frame", "Workspace", win.back)
	win.workspace:SetLayer(6)
	win.workspace:SetPoint("TOPLEFT", win.toolbar, "BOTTOMLEFT", 4, 4)
	win.workspace:SetPoint("BOTTOMRIGHT", win.statusbar, "TOPRIGHT", -4, -4)
	win.workspace:SetBackgroundColor(wkColour.r, wkColour.g, 
		wkColour.b, wkColour.a)	
	-- Mouse handling mode
	win:SetMouseMasking("limited")
	return win
end

-- Create a new grid
function NewGrid(parent)
	-- Create frame
	grid = UI.CreateFrame("Frame", "AGrid", parent)
	-- Our properties
	grid.numCols = 0
	grid.numRows = 0
	grid.rowHeight = 26
	-- Internal properties
	grid.rows = {}
	-- position within our parent
	grid:SetLayer(0)
	grid:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, 4)
	grid:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, -4)
	grid:SetBackgroundColor(gdColour.r, gdColour.g, gdColour.b, gdColour.a)
	-- column headers
	grid.headers = UI.CreateFrame("Frame", "Headers", grid)
	grid.headers:SetPoint("TOPLEFT", grid, "TOPLEFT")
	grid.headers:SetPoint("RIGHT", grid, "RIGHT")
	grid.headers:SetHeight(grid.rowHeight)
	grid.headers:SetBackgroundColor(
		ghColour.r, ghColour.g, ghColour.b, ghColour.a)
	-- Column header click handling
	function grid:SetHeaderCallback(func)
		-- We call "func" with the index of the column header clicked
		for i = 1, self.numCols do
			self.headers.cols[i].headerClicked = func
		end
	end
	-- Clear grid selection
	function grid:ClearSelection()
		for i = 1, self.numRows do
			self.rows[i]:Deselect()
		end
	end
	-- Get indexes of selected rows
	function grid:GetSelection()
		selection = {}
		for i = 1, self.numRows do
			if self.rows[i].selected then
				table.insert(selection, i)
			end
		end	
		return selection
	end
	-- Resize handler
	function grid:Resize()
		if not self.numRows or self.numRows <= 0 then return end
		-- Adjust width of our columns, first find min widths
		widths = {}
		for i = 1, self.numCols do table.insert(widths, 0) end
		for i, row in pairs(self.rows) do
			for j = 1, self.numCols do
				wid = row.cols[j].label:GetFullWidth()
				if wid > widths[j] then
					widths[j] = wid
				end
			end
		end
		-- Now set width of columns
		wid = self:GetWidth() / self.numCols
		for i, row in pairs(self.rows) do
			for j = 1, self.numCols do
				if wid > widths[j] then
					row.cols[j]:SetWidth(wid)
				else
					row.cols[j]:SetWidth(widths[j])
				end
			end
		end
		-- And width of headers
		for j = 1, self.numCols do
			if wid > widths[j] then
				self.headers.cols[j]:SetWidth(wid)
			else
				self.headers.cols[j]:SetWidth(widths[j])
			end
		end		
		-- Hide rows that would hang off the bottom of the grid
		space = self:GetHeight()
		maxrows = math.floor(space / self.rowHeight)
		for i = 1, self.numRows do
			self.rows[i]:SetVisible(i < maxrows)
		end
		-- Limit minimum width to avoid columns hanging off edge
		-- XXX This is a pathetic hack
		minwidth = 0
		for i = 1, #widths do
			minwidth = minwidth + widths[i]
		end
		parent = FindParent(self)
		parent.minWidth = widths[1] + minwidth
	end
	function grid.Event:Size()
		self:Resize()
	end
	
	-- Clear all contents (not the actual row UI elements)
	function grid:Clear()
		for _, row in pairs(self.rows) do
			for i = 1, #row.cols do
				row:SetText(i, "")
			end
		end
	end
	
	-- Add a row
	-- A row is both a collection of UI elements and the row/cell data
	-- If headers is true this is the special column title headers row
	function grid:AddRow(rowdata, headers)
		-- Create the row
		if not headers then
			row = UI.CreateFrame("Frame", "ARow", self)
			row.selected = false
		else
			row = self.headers
		end
		ralign = self.rows[#self.rows]
		if headers then
			row:SetPoint("TOPLEFT", self, "TOPLEFT")
			row:SetPoint("RIGHT", self, "RIGHT")
		else
			if not ralign then
				row:SetPoint("TOPLEFT", self.headers, "BOTTOMLEFT")
				row:SetPoint("RIGHT", self, "RIGHT")
			else
				row:SetPoint("TOPLEFT", ralign, "BOTTOMLEFT")
				row:SetPoint("RIGHT", self, "RIGHT")			
			end
		end
		row:SetHeight(self.rowHeight)
		-- Alternate row background colour
		row.index = (#self.rows)+1
		c = (#self.rows % 2) / 30
		if not headers then
			row:SetBackgroundColor(c, c, c, gdColour.a)
		end
		row.cols = {}
		align = nil
		-- If this is first row, determine how many columns we need
		if headers then
			self.numCols = #rowdata
		else
			self.numRows = self.numRows + 1
		end
		for i = 1, self.numCols do 
			-- Create and align the cell
			cell = UI.CreateFrame("Frame", "ACell", row)
			if not align then
				-- align to row start
				cell:SetPoint("TOPLEFT", row, "TOPLEFT")
				cell:SetPoint("BOTTOM", row, "BOTTOM")				
			else
				-- align to last cell
				cell:SetPoint("TOPLEFT", align, "TOPRIGHT")
				cell:SetPoint("BOTTOM", row, "BOTTOM")							
			end
			cell:SetWidth(row:GetWidth() / self.numCols)
			align = cell
			-- Add a label to the cell
			label = UI.CreateFrame("Text", "ALabel", cell)
			cell.label = label
			label:SetText(rowdata[i])
			label:SetFontSize(16)
			--label:SetFont("EPGP", "font/DejaVuSans.ttf")
			label:SetPoint("TOPLEFT", cell, "TOPLEFT")
			label:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT")
			table.insert(row.cols, cell)
			-- Header specific mouse event handlers
			if headers then
				function cell.Event:LeftDown()
					if self.headerClicked then
						self.headerClicked(i)
					end
				end
			end
		end
		-- Row mouse event handlers
		if not headers then
			function row.Event:MouseIn()
				if self.selected then
				else
					self.r, self.g, self.b, self.a = self:GetBackgroundColor()
				end
				self:SetBackgroundColor(0.3, 0.3, 0.4, 0.3)
			end
			function row.Event:MouseOut()
				if self.selected then
					self:SetBackgroundColor(gsColour.r, gsColour.g, 
						gsColour.b, gsColour.a)
				else
					c = (self.index % 2) / 30
					self:SetBackgroundColor(self.r, self.g, self.b, self.a)
				end
			end
			function row.Event:LeftDown()
				if self.selected then
					self:Deselect()
				else
					self:Select()
				end
			end
		end
		function row:Select()
			self.selected = true
			self:SetBackgroundColor(gsColour.r, gsColour.g, 
				gsColour.b, gsColour.a)			
		end
		function row:Deselect()
			self.selected = false
			c = (self.index % 2) / 30
			self:SetBackgroundColor(c, c, c, 1)
		end
		-- Set a cell's text by index
		function row:SetText(index, text)
			self.cols[index].label:SetText(tostring(text))
		end
		-- Set a cell's text colour by index
		function row:SetTextColour(index, c)
			self.cols[index].label:SetFontColor(c.r,c.g,c.b,1)
		end
		if not headers then
			table.insert(self.rows, row)
		else
			self.headers = row
		end
	end
	
	return grid
end
