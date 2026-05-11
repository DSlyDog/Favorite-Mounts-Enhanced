WhispsMountupDB = WhispsMountupDB or {}

local saveFrame = CreateFrame("Frame")

if not WhispsMountupDB.minimap or type(WhispsMountupDB.minimap) ~= "table" then
    WhispsMountupDB.minimap = {
        hide = false,
        minimapPos = 45
    }
elseif not WhispsMountupDB.minimap.minimapPos then
    WhispsMountupDB.minimap.minimapPos = 45
end

local ldb = LibStub:GetLibrary('LibDataBroker-1.1')
local icon = LibStub:GetLibrary("LibDBIcon-1.0")

local WhispsMountupLauncher = ldb:NewDataObject("WhispsMountup", {
    type = "launcher",
    icon = "Interface\\ICONS\\foxmounticon",
    OnClick = function(self, button)
        if button == "LeftButton" then
            if WhispsMountupSummonFrame then
                if WhispsMountupSummonFrame:IsShown() then
                    WhispsMountupSummonFrame:Hide()
                else
                    UIDropDownMenu_Initialize(WhispsMountupSummonDropdown, InitializeMountListDropdown)
                    WhispsMountupSummonFrame:Show()
                end
            end
        elseif button == "RightButton" then
            if WhispsMountupSettingsFrame then
                if WhispsMountupSettingsFrame:IsShown() then
                    WhispsMountupSettingsFrame:Hide()
                else
                    if ShowSettingsGUI then
                        ShowSettingsGUI()
                    end
                end
            elseif ShowSettingsGUI then
                ShowSettingsGUI()
            end
        end
    end,
    OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        tooltip:AddLine("Favorite Mounts Enhanced")
        tooltip:AddLine("|cff00ff00Left-click:|r Open/close Summon Mounts panel", 1, 1, 1)
        tooltip:AddLine("|cffff8000Right-click:|r Open/close Settings", 1, 1, 1)
    end,
})

local function MonitorMinimapPositionChanges()
    local function CheckPosition()
        local oldPos = WhispsMountupDB.minimap.minimapPos
        if WhispsMountupDB.minimap and WhispsMountupDB.minimap.minimapPos and
                oldPos ~= WhispsMountupDB.minimap.minimapPos then

            oldPos = WhispsMountupDB.minimap.minimapPos
        end
    end

    saveFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timeSinceLastCheck = (self.timeSinceLastCheck or 0) + elapsed
        if self.timeSinceLastCheck >= 0.5 then  -- Check every half second
            CheckPosition()
            self.timeSinceLastCheck = 0
        end
    end)
end

-- Register for events to ensure data persistence
saveFrame:RegisterEvent("PLAYER_LOGOUT")
saveFrame:RegisterEvent("ADDON_LOADED")

saveFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Whisp's Mount Up" then
        if not WhispsMountupDB.minimap then
            WhispsMountupDB.minimap = {
                hide = false,
                minimapPos = 45
            }
        elseif not WhispsMountupDB.minimap.minimapPos then
            WhispsMountupDB.minimap.minimapPos = 45
        end

        MonitorMinimapPositionChanges()
    elseif event == "PLAYER_LOGOUT" then
        if not WhispsMountupDB then WhispsMountupDB = {} end
        if not WhispsMountupDB.minimap then
            WhispsMountupDB.minimap = {
                hide = false,
                minimapPos = 45
            }
        elseif not WhispsMountupDB.minimap.minimapPos then
            WhispsMountupDB.minimap.minimapPos = 45
        end

        print("MiniMapButton2: Saving minimap position:", WhispsMountupDB.minimap.minimapPos)
    end
end)


function InitializeMinimapIcon()
    icon:Register("WhispsMountup", WhispsMountupLauncher, WhispsMountupDB.minimap)
    icon:Show("WhispsMountup")
end