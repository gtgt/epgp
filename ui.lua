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
	--win.caption:SetPoint("RIGHT", win.titlebar, "RIGHT")
	win.caption:SetFontSize(18)
	win.caption:SetWidth(20)
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
			if x > 150 and y > 60 then
				w = FindParent(self)
				w:SetWidth(x)
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
	-- Statusbar
	win.statusbar = UI.CreateFrame("Frame", "StatusBar", win.back)
	win.statusbar:SetLayer(6)
	win.statusbar:SetPoint("BOTTOMLEFT", win.back, "BOTTOMLEFT")
	win.statusbar:SetPoint("BOTTOMRIGHT", win.back, "BOTTOMRIGHT")
	win.statusbar:SetHeight(32)
	win.statusbar:SetBackgroundColor(bkColour.r, bkColour.g, 
		bkColour.b, bkColour.a)
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
function NewGrid(parent, numcols, numrows)
	-- Create frame
	grid = UI.CreateFrame("Frame", "AGrid", parent)
	-- Our properties
	grid.numCols = numcols
	grid.numRows = numrows
	grid.rowHeight = 26
	-- Internal properties
	grid.rows = {}
	-- position within our parent
	grid:SetLayer(0)
	grid:SetPoint("TOPLEFT", parent, "TOPLEFT", 4, 4)
	grid:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -4, -4)
	grid:SetBackgroundColor(gdColour.r, gdColour.g, gdColour.b, gdColour.a)
	
	-- Add a row
	-- A row is both a collection of UI elements and the row/cell data
	function grid:AddRow()
		row = UI.CreateFrame("Frame", "ARow", self)
		ralign = self.rows[#self.rows]
		if not ralign then
			row:SetPoint("TOPLEFT", self, "TOPLEFT")
			row:SetPoint("RIGHT", self, "RIGHT")
		else
			row:SetPoint("TOPLEFT", ralign, "BOTTOMLEFT")
			row:SetPoint("RIGHT", self, "RIGHT")			
		end
		row:SetHeight(self.rowHeight)
		-- Alternate row background colour
		c = (#self.rows % 2) / 30
		row:SetBackgroundColor(c, c, c, gdColour.a)
		row.cols = {}
		align = nil
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
			label:SetText("Testing")
			label:SetFontSize(18)
			label:SetFont("EPGP", "font/DejaVuSans.ttf")
			label:SetPoint("TOPLEFT", cell, "TOPLEFT")
			label:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT")
			table.insert(row.cols, {cell})
			
			-- Row mouse event handlers
			function row.Event:MouseIn()
				self.r, self.g, self.b, self.a = self:GetBackgroundColor()
				self:SetBackgroundColor(0.3, 0.3, 0.4, 0.3)
			end
			function row.Event:MouseOut()
				self:SetBackgroundColor(self.r, self.g, self.b, self.a)
			end
		end
		table.insert(self.rows, row)
	end
	
	-- Create our rows
	for i = 1, grid.numRows do
		grid:AddRow()
	end
	
	return grid
end
