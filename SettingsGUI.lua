local SettingsFrame = CreateFrame("Frame", "WhispsMountupSettingsFrame", UIParent, "BackdropTemplate")
SettingsFrame:SetSize(330, 240)
SettingsFrame:SetFrameStrata("MEDIUM")
SettingsFrame:SetFrameLevel(300)
SettingsFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
SettingsFrame:SetMovable(true)
SettingsFrame:EnableMouse(true)
SettingsFrame:RegisterForDrag('LeftButton')
SettingsFrame:SetScript("OnDragStart", SettingsFrame.StartMoving)
SettingsFrame:SetScript("OnDragStop", SettingsFrame.StopMovingOrSizing)
SettingsFrame:Hide()

local function InitializeSettingsDB()
    if not WhispsMountupDB then
        WhispsMountupDB = {}
    end
    if not WhispsMountupDB.settings then
        WhispsMountupDB.settings = {
            summonGuiEscapeClose = true,    -- Allow ESC to close SummonGUI
            actionBarEnabled = false,       -- Show the custom action bar (off by default)
            combatDismount = true          -- Automatically dismount when entering combat
        }
    end
end

if BackdropTemplateMixin then
    Mixin(SettingsFrame, BackdropTemplateMixin)
end

SettingsFrame:SetBackdrop({
    bgFile = "Interface/FrameGeneral/UI-Background-Marble",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 128,
    edgeSize = 32,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

SettingsFrame:SetBackdropColor(1, 1, 1, 0.9)
SettingsFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

local titleBar = CreateFrame("Frame", nil, SettingsFrame, "BackdropTemplate")
titleBar:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 2.5, 0)
titleBar:SetPoint("TOPRIGHT", SettingsFrame, "TOPRIGHT", 0, 0)
titleBar:SetHeight(24)

titleBar:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true,
    tileSize = 16,
    edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})

titleBar:SetBackdropColor(0.4, 0.4, 0.4, 1)

local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
title:SetText("Favorite Mounts Enhanced - Settings")

local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
closeButton:SetSize(20, 20)
closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", -2, -2)
closeButton:SetScript("OnClick", function() SettingsFrame:Hide() end)

local escCheckbox = CreateFrame("CheckButton", "WhispsMountupEscCheckbox", SettingsFrame, "UICheckButtonTemplate")
escCheckbox:SetPoint("TOPLEFT", titleBar, "BOTTOMLEFT", 20, -20)
escCheckbox:SetSize(20, 20)

local escLabel = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
escLabel:SetPoint("LEFT", escCheckbox, "RIGHT", 5, 0)
escLabel:SetText("Allow ESC to close Summon GUI")

escCheckbox:SetScript("OnClick", function(self)
    WhispsMountupDB.settings.summonGuiEscapeClose = self:GetChecked()
    UpdateSummonGUIEscapeHandling()
end)

local actionBarCheckbox = CreateFrame("CheckButton", "WhispsMountupActionBarCheckbox", SettingsFrame, "UICheckButtonTemplate")
actionBarCheckbox:SetPoint("TOPLEFT", escCheckbox, "BOTTOMLEFT", 0, -15)
actionBarCheckbox:SetSize(20, 20)

local actionBarLabel = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
actionBarLabel:SetPoint("LEFT", actionBarCheckbox, "RIGHT", 5, 0)
actionBarLabel:SetText("Enable Custom Action Bar")

actionBarCheckbox:SetScript("OnClick", function(self)
    WhispsMountupDB.settings.actionBarEnabled = self:GetChecked()
    UpdateActionBarVisibility()
end)

local combatDismountCheckbox = CreateFrame("CheckButton", "WhispsMountupCombatDismountCheckbox", SettingsFrame, "UICheckButtonTemplate")
combatDismountCheckbox:SetPoint("TOPLEFT", actionBarCheckbox, "BOTTOMLEFT", 0, -15)
combatDismountCheckbox:SetSize(20, 20)

local combatDismountLabel = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
combatDismountLabel:SetPoint("LEFT", combatDismountCheckbox, "RIGHT", 5, 0)
combatDismountLabel:SetText("Auto-dismount in combat (when grounded)")

combatDismountCheckbox:SetScript("OnClick", function(self)
    WhispsMountupDB.settings.combatDismount = self:GetChecked()
end)

local function UpdateSettingsDisplay()
    if WhispsMountupDB and WhispsMountupDB.settings then
        escCheckbox:SetChecked(WhispsMountupDB.settings.summonGuiEscapeClose)
        actionBarCheckbox:SetChecked(WhispsMountupDB.settings.actionBarEnabled)
        combatDismountCheckbox:SetChecked(WhispsMountupDB.settings.combatDismount)
    end
end

function UpdateSummonGUIEscapeHandling()
    if WhispsMountupSummonFrame then
        if WhispsMountupDB.settings.summonGuiEscapeClose then
            local found = false
            for i, frameName in ipairs(UISpecialFrames) do
                if frameName == "WhispsMountupSummonFrame" then
                    found = true
                    break
                end
            end
            if not found then
                tinsert(UISpecialFrames, "WhispsMountupSummonFrame")
            end
        else
            for i, frameName in ipairs(UISpecialFrames) do
                if frameName == "WhispsMountupSummonFrame" then
                    tremove(UISpecialFrames, i)
                    break
                end
            end
        end
    end
end

function UpdateActionBarVisibility()
    if WhispsMountupActionBar then
        if WhispsMountupDB.settings.actionBarEnabled then
            if WhispsMountupDB.ActionBar then
                WhispsMountupDB.ActionBar.visible = true
            end
            WhispsMountupActionBar:Show()
        else
            if WhispsMountupDB.ActionBar then
                WhispsMountupDB.ActionBar.visible = false
            end
            WhispsMountupActionBar:Hide()
        end
    end
end

function InitializeSettingsGUI()
    InitializeSettingsDB()
    if WhispsMountupDB.ActionBar and WhispsMountupDB.ActionBar.visible ~= nil then
        WhispsMountupDB.settings.actionBarEnabled = WhispsMountupDB.ActionBar.visible
    end
    UpdateSettingsDisplay()
    UpdateSummonGUIEscapeHandling()
    UpdateActionBarVisibility()
end

function ShowSettingsGUI()
    SettingsFrame:Show()
    UpdateSettingsDisplay()
end

SettingsFrame:SetScript("OnShow", function()
    UpdateSettingsDisplay()
end)

SettingsFrame:SetScript("OnKeyDown", function(self, key)
    if key == "ESCAPE" then
        SettingsFrame:Hide()
    end
end)
SettingsFrame:EnableKeyboard(true)
SettingsFrame:SetPropagateKeyboardInput(true)

tinsert(UISpecialFrames, "WhispsMountupSettingsFrame")
