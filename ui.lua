--[[
	ui.lua
	Main Window and grid control.
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
local gsColour = {r = 0.1, g = 0.1, b = 0.5, a = 1.0}

-- Window title font
fontWindowTitle = 16
fontStatusBar = 14
fontGrid = 14
fontOptionGroup = 14

-- Heights
heightTitleBar = 24
heightToolbar = 32
heightBar = 28
heightGridRow = 22
heightStatusBar = 28
radioHeight = 22

-- Border width
local bdWidth = 2
-- Inner border width
local bdInsideWidth = 6

-- Dialog modes
DialogConfirm = 1
DialogEdit = 2
DialogOption = 3

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
	local win = UI.CreateFrame("Frame", description, context)
	win.rootWindow = true
	win.onClose = nil
	-- Function to switch to "dialog" mode window
	function win:SetDialog()
		self.toolbar:SetHeight(0)
		self.statusbar:SetHeight(0)
		self.resize:SetVisible(false)
		self.closeicon:SetVisible(false)
	end
	-- Disable all window controls
	win.disableFrame = UI.CreateFrame("Frame", "Disable", win)
	win.disableFrame:SetPoint("TOPLEFT", win, "TOPLEFT")
	win.disableFrame:SetPoint("BOTTOMRIGHT", win, "BOTTOMRIGHT")
	win.disableFrame:SetBackgroundColor(0,0,0,0.5)
	win.disableFrame:SetVisible(false)
	win.disableFrame:SetLayer(100)
	function win.disableFrame.Event:LeftDown()
		-- fake
	end
	function win:Disable()
		-- Create a transparent frame over the entire window which catches
		-- mouse events.
		self.disableFrame:SetVisible(true)
	end
	function win:Enable()
		self.disableFrame:SetVisible(false)
	end
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
	win.titlebar:SetHeight(heightTitleBar)
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
	win.caption:SetFontSize(fontWindowTitle)
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
		p = FindParent(self)
		if p.onClose then
			p.onClose()
		end
	end
	function win:SetCloseCallback(close)
		self.onClose = close
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
			if y > 140 then
				w = FindParent(self)
				if not w.minWidth then w.minWidth = 0 end
				-- XXX Hack, never resize smaller than our toolbar
				local toolbarWidth = ((#w.toolbar.buttons) * 32) + 16
				if w.minWidth < toolbarWidth then 
					w.minWidth = toolbarWidth 
				end
				-- Limit min window size
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
	win.toolbar:SetHeight(heightToolbar)
	win.toolbar:SetBackgroundColor(bkColour.r, bkColour.g, 
		bkColour.b, bkColour.a)
	win.toolbar.buttons = {}
	-- Add a button, we assume icon is a filename that we can prefix an 
	-- underscore to, to get the "inactive" version of the icon
	function win.toolbar:AddButton(icon, tooltip, callback)
		local but = UI.CreateFrame("Texture", "AddButton", win.toolbar)
		-- Remember icons
		but.activeIcon = "gfx/icons/"..icon
		but.inactiveIcon = "gfx/icons/_"..icon
		but:SetTexture("EPGP", but.inactiveIcon)
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
			self:SetTexture("EPGP", self.activeIcon)
			parent = FindParent(self)
			parent:SetStatus(self.tooltip)
		end
		function but.Event:MouseOut()
			self:SetTexture("EPGP", self.inactiveIcon)
			parent = FindParent(self)
			local text = parent:GetStatus()
			if text == self.tooltip then
				parent:SetStatus("")
			end
		end
	end
	-- Statusbar
	win.statusbar = UI.CreateFrame("Frame", "StatusBar", win.back)
	win.statusbar:SetLayer(6)
	win.statusbar:SetPoint("BOTTOMLEFT", win.back, "BOTTOMLEFT")
	win.statusbar:SetPoint("BOTTOMRIGHT", win.back, "BOTTOMRIGHT")
	win.statusbar:SetHeight(heightStatusBar)
	win.statusbar:SetBackgroundColor(bkColour.r, bkColour.g, 
		bkColour.b, bkColour.a)
	win.statusbar.label = UI.CreateFrame("Text", "Status", win.statusbar)
	win.statusbar.label:SetText("")
	win.statusbar.label:SetPoint("TOPLEFT", win.statusbar, "TOPLEFT", 8, 0)
	win.statusbar.label:SetPoint("BOTTOMRIGHT", win.statusbar, "BOTTOMRIGHT")
	win.statusbar.label:SetFontSize(fontStatusBar)
	win.caption:SetLayer(9)
	-- Allow setting of the status
	function win:SetStatus(text)
		win.statusbar.label:SetText(text)
	end
	function win:GetStatus()
		return win.statusbar.label:GetText()
	end
	-- Workspace
	win.workspace = UI.CreateFrame("Frame", "Workspace", win.back)
	win.workspace:SetLayer(6)
	win.workspace:SetPoint("TOPLEFT", win.toolbar, "BOTTOMLEFT", 4, 4)
	win.workspace:SetPoint("BOTTOMRIGHT", win.statusbar, "TOPRIGHT", -4, -4)
	win.workspace:SetBackgroundColor(wkColour.r, wkColour.g, 
		wkColour.b, wkColour.a)	
	-- Mouse handling mode
	win:SetMouseMasking("full")
	return win
end

-- Create a new grid
function NewGrid(parent)
	-- Create frame
	grid = UI.CreateFrame("Frame", "AGrid", parent)
	-- Our properties
	grid.numCols = 0
	grid.numRows = 0
	grid.rowHeight = heightGridRow
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
	-- Get indexes of selected rows or contents of first cell
	function grid:GetSelection(names)
		selection = {}
		for i = 1, self.numRows do
			if self.rows[i].selected then
				if names then
					table.insert(selection, 
						self.rows[i].cols[1].label:GetText())
				else
					table.insert(selection, i)
				end
			end
		end	
		return selection
	end
	-- Resize handler
	function grid:Resize()
		--if not self.numRows or self.numRows <= 0 and then return end
		-- Adjust width of our columns, first find min widths
		widths = {}
		for i = 1, self.numCols do table.insert(widths, 0) end
		for i, row in pairs(self.rows) do
			for j = 1, self.numCols do
				wid = row.cols[j].label:GetFullWidth()
				if j == 1 then wid = wid + 13 end -- XXX Hack
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
		-- Hide any rows at the bottom which are not used
		for i = self.numRows, 1, -1 do
			if self.rows[i].cols[1].label:GetText() == "" then
				self.rows[i]:SetVisible(false)
			end
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
			row:SetIcon(nil)
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
			-- Add a status indicator to the first cell
			align = cell
			if i == 1 and not headers then
				cell.status = UI.CreateFrame("Texture", "Status", cell)
				cell.status:SetTexture("EPGP", "gfx/icons/status_red.png")
				cell.status:ResizeToTexture()
				cell.status:SetPoint("TOPLEFT", cell, "TOPLEFT", 4, 4)
				cell.status:SetLayer(9)	
			end
			-- Add a label to the cell
			label = UI.CreateFrame("Text", "ALabel", cell)
			cell.label = label
			label:SetText(rowdata[i])
			label:SetFontSize(fontGrid)
			--label:SetFont("EPGP", "font/DejaVuSans.ttf")
			if i == 1 and not headers then 
				-- anchor to status
				label:SetPoint("TOPLEFT", cell.status, "TOPRIGHT", 0, -4)
				label:SetPoint("RIGHT", cell, "RIGHT")
			else
				-- anchor to cell
				label:SetPoint("TOPLEFT", cell, "TOPLEFT")
				label:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT")
			end
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
		-- Set a rows icon
		function row:SetIcon(texture)
			-- XXX Hack
			if not texture then texture = "gfx/icons/status_none.png" end
			self.cols[1].status:SetTexture("EPGP", texture)
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

-- Display a dialog asking for confirmation of something
function NewDialog(mainWindow)
	local dialog = NewWindow("Confirm Dialog", "Confirm")
	dialog.mainWindow = mainWindow
	dialog:SetWidth(350)
	dialog:SetHeight(160)
	dialog:SetDialog()
	dialog:SetLayer(200)
	dialog:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	canvas = dialog.workspace
	-- Add prompt
	prompt = UI.CreateFrame("Text", "TitleText", canvas)
	canvas.prompt = prompt
	prompt:SetWordwrap(true)
	prompt:SetText("")
	prompt:SetPoint("TOPLEFT", dialog.workspace, "TOPLEFT", 4, 4)
	prompt:SetFontSize(18)
	prompt:SetWidth( canvas:GetWidth() -8 )
	prompt:SetLayer(4)
	-- OK/cancel buttons
	canvas.cancelbutton = UI.CreateFrame("Texture", "CancelButton", canvas)
	canvas.cancelbutton:SetTexture("EPGP", "gfx/cancelbut.png")
	canvas.cancelbutton:SetPoint("BOTTOMRIGHT", canvas, 
		"BOTTOMRIGHT", -4, -4)
	canvas.cancelbutton:ResizeToTexture()
	canvas.cancelbutton:SetLayer(7)
	canvas.cancelbutton.parentDialog = dialog
	canvas.okbutton = UI.CreateFrame("Texture", "OkButton", canvas)
	canvas.okbutton:SetTexture("EPGP", "gfx/okbut.png")
	canvas.okbutton:SetPoint("BOTTOMRIGHT", canvas.cancelbutton, 
		"BOTTOMLEFT", -8, 0)
	canvas.okbutton:ResizeToTexture()
	canvas.okbutton:SetLayer(7)
	canvas.okbutton.parentDialog = dialog
	dialog:SetVisible(false)
	-- Text entry
	canvas.edit = UI.CreateFrame("RiftTextfield", "TextEntry", canvas)
	canvas.edit:SetPoint("TOPCENTER", canvas.prompt, "BOTTOMCENTER")
	canvas.edit:SetLayer(8)
	canvas.edit:SetBackgroundColor(0.2,0.2,0.2,1)
	-- We can't actually free resources with the current API, so we make this
	-- dialog reusable
	function dialog:Confirm(msg)
		self.mainWindow:Disable()
		self.mode = DialogConfirm
		self.workspace.prompt:SetText(msg)
		self.workspace.edit:SetVisible(false)
		self.workspace.prompt:SetHeight( self.workspace.prompt:GetFullHeight())
		self:SetHeight(160)
		if self.radio then
			self.radio:SetVisible(false)
		end
		self:SetVisible(true)
	end
	-- Dialog mode which prompts for text entry
	function dialog:GetEntry(msg)
		self.mainWindow:Disable()
		self.mode = DialogEdit
		self.workspace.prompt:SetText(msg)
		self.workspace.edit:SetVisible(true)
		self.workspace.prompt:SetHeight( self.workspace.prompt:GetFullHeight())
		self:SetHeight(160)
		if self.radio then
			self.radio:SetVisible(false)
		end
		self:SetVisible(true)
		self.workspace.edit:SetKeyFocus(true)		
	end
	-- Dialog mode which gives a list of options
	function dialog:GetOption(msg, options)
		self.mainWindow:Disable()
		self.mode = DialogOption
		self.workspace.prompt:SetText(msg)
		self.workspace.edit:SetVisible(false)
		self.workspace.prompt:SetHeight( self.workspace.prompt:GetFullHeight())
		self:SetVisible(true)
		self.workspace.edit:SetKeyFocus(false)
		if self.radio then
			self.radio:SetVisible(false)
			self.radio = nil -- XXX We should fee this (can't: API limitation)
		end
		self.radio = NewRadioGroup(self.workspace, options)
		self.radio:SetPoint("TOPLEFT", self.workspace.prompt, "BOTTOMLEFT")
		self.radio:SetPoint("BOTTOMRIGHT", self.workspace, "BOTTOMRIGHT")
		self.radio:SetLayer(100)
		local height = self.workspace.prompt:GetFullHeight()
		height = 100 + height + (#self.radio.rows * radioHeight)
		self:SetHeight( height )
	end
	-- Mouse handlers
	function dialog:SetOKCallback(func)
		self.okCallback = func
	end
	function dialog:SetCancelCallback(func)
		self.cancelCallback = func
	end
	function dialog.workspace.okbutton.Event:LeftDown()
		-- prevent focus stealing
		if self.parentDialog.radio then
			self.parentDialog.radio.other:SetKeyFocus(false)
		end
		self.parentDialog.workspace.edit:SetKeyFocus(false)
		self.parentDialog.mainWindow:Enable()
		self.parentDialog:SetVisible(false)
		if self.parentDialog.okCallback then
			if self.parentDialog.mode == DialogConfirm then
				self.parentDialog.okCallback()
			elseif self.parentDialog.mode == DialogEdit then
				entry = self.parentDialog.workspace.edit:GetText()
				if not entry then entry = "" end
				self.parentDialog.okCallback(entry)
			elseif self.parentDialog.mode == DialogOption then
				v = self.parentDialog.radio:GetValue()
				if v then
					self.parentDialog.okCallback(v)
				end
			end
		end
	end
	function dialog.workspace.cancelbutton.Event:LeftDown()
		-- prevent focus stealing
		if self.parentDialog.radio then
			self.parentDialog.radio.other:SetKeyFocus(false)
		end
		self.parentDialog.workspace.edit:SetKeyFocus(false)
		self.parentDialog.mainWindow:Enable()
		self.parentDialog:SetVisible(false)
		if self.parentDialog.cancelCallback then
			self.parentDialog.cancelCallback()
		end
	end

	return dialog
end

-- Create a new radio group
-- Options is a table of pairs: "Label" -> "Value"
function NewRadioGroup(parent, options)
	-- Create our frame, we leave size and position to the creator
	local win = UI.CreateFrame("Frame", "RadioGroup", parent)
	win.parent = parent
	win.rows = {}
	win.selected = nil
	win.value = nil
	local align = win
	-- Add manual entry option
	opts = {}
	for _, x in ipairs(options) do
		table.insert(opts, x)
	end
	table.insert(opts, {"Other", nil})
	win.options = opts
	-- Redraw our radio group
	function win:Redraw()
		-- Set the radio options
		for i, r in ipairs(self.rows) do
			if i == self.selected then
				r.icon:SetTexture("EPGP", "gfx/radio_on.png")
			else
				r.icon:SetTexture("EPGP", "gfx/radio_off.png")
			end
		end
	end
	-- Get the currently selected value
	function win:GetValue()
		-- Last option is always manual entry "other"
		if self.selected == #self.options then
			return self.other:GetText()
		-- return the selected option's value if not "other"
		elseif self.selected then
			return self.options[self.selected][2]
		end
	end
	-- For each option, add a radio button and a label
	local row = nil
	for i = 1, #opts do
		-- Create a row for this option
		row = UI.CreateFrame("Frame", "RadioGroup", win)
		row.parent = win
		if align == win then
			row:SetPoint("TOPLEFT", win, "TOPLEFT", 0, 1)
			row:SetPoint("RIGHT", win, "RIGHT")
		else
			row:SetPoint("TOPLEFT", align, "BOTTOMLEFT")
			row:SetPoint("RIGHT", win, "RIGHT")
		end
		align = row
		row:SetHeight(radioHeight)		
		-- Create radio icon
		local icon = UI.CreateFrame("Texture", "RadioButton", row)
		icon:SetTexture("EPGP", "gfx/radio_off.png")
		icon:SetPoint("TOPLEFT", row, "TOPLEFT")
		icon:ResizeToTexture()
		icon:SetLayer(5)
		row.icon = icon
		-- Create a label
		local label = UI.CreateFrame("Text", "RadioLabel", row)
		label:SetText(opts[i][1].." ("..tostring(opts[i][2])..")")
		label:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, -4)
		--label:SetPoint("RIGHT", row, "RIGHT")
		label:SetFontSize(fontOptionGroup)
		label:SetLayer(5)
		row.label = label
		-- Row mouse events
		function row.Event:LeftDown()
			self.parent.selected = i
			self.parent:Redraw()
			-- Enable/Disable the "other" text entry
			if i == #self.parent.options then 
				self.parent.other:SetKeyFocus(true)
			else
				self.parent.other:SetKeyFocus(false)
			end
		end
		-- Remember the row
		table.insert(win.rows, row)
	end
	-- Add the text entry to the "Other" entry
	local txt = UI.CreateFrame("RiftTextfield", "OtherEntry", row)
	txt:SetPoint("TOPLEFT", row.label, "TOPRIGHT", 4, 2)
	txt:SetLayer(8)
	txt:SetText("")
	txt:SetBackgroundColor(0.2,0.2,0.2,1)
	win.other = txt
	
	return win
end