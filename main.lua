
win = NewWindow("Main", "Chimaera EPGP")
win:SetVisible(true)
win:SetWidth(400)
win:SetHeight(300)
win:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, 200)

-- Toolbar icons
win.toolbar.icon1 = UI.CreateFrame("Texture", "AddButton", win.toolbar)
win.toolbar.icon1:SetTexture("EPGP", "gfx/iadd.png")
win.toolbar.icon1:SetPoint("TOPLEFT", win.toolbar, "TOPLEFT", 4, 6)
win.toolbar.icon1:ResizeToTexture()
win.toolbar.icon1:SetLayer(8)

win.toolbar.icon2 = UI.CreateFrame("Texture", "Button2", win.toolbar)
win.toolbar.icon2:SetTexture("EPGP", "gfx/idelete.png")
win.toolbar.icon2:SetPoint("TOPLEFT", win.toolbar.icon1, "TOPRIGHT", 8, 0)
win.toolbar.icon2:ResizeToTexture()
win.toolbar.icon2:SetLayer(8)

win.toolbar.icon3 = UI.CreateFrame("Texture", "Button3", win.toolbar)
win.toolbar.icon3:SetTexture("EPGP", "gfx/icalculator.png")
win.toolbar.icon3:SetPoint("TOPLEFT", win.toolbar.icon2, "TOPRIGHT", 8, 0)
win.toolbar.icon3:ResizeToTexture()
win.toolbar.icon3:SetLayer(8)

win.toolbar.icon4 = UI.CreateFrame("Texture", "Button4", win.toolbar)
win.toolbar.icon4:SetTexture("EPGP", "gfx/process.png")
win.toolbar.icon4:SetPoint("TOPLEFT", win.toolbar.icon3, "TOPRIGHT", 8, 0)
win.toolbar.icon4:ResizeToTexture()
win.toolbar.icon4:SetLayer(8)
