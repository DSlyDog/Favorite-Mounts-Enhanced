function ShowMountSelectionDialog(listName)
    if not WhispsMountupSelectionFrame then
        local mountSelectFrame = CreateFrame("Frame", "WhispsMountupSelectionFrame", UIParent, "BackdropTemplate")
        mountSelectFrame:SetSize(320, 470)
        mountSelectFrame:SetPoint("CENTER")
        mountSelectFrame:SetFrameStrata("DIALOG")
        mountSelectFrame:SetMovable(true)
        mountSelectFrame:EnableMouse(true)
        mountSelectFrame:RegisterForDrag('LeftButton')
        mountSelectFrame:SetScript("OnDragStart", mountSelectFrame.StartMoving)
        mountSelectFrame:SetScript("OnDragStop", mountSelectFrame.StopMovingOrSizing)

        if BackdropTemplateMixin then
            Mixin(mountSelectFrame, BackdropTemplateMixin)
        end

        mountSelectFrame:SetBackdrop({
            bgFile = "Interface/FrameGeneral/UI-Background-Marble",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            tile = true,
            tileSize = 128,
            edgeSize = 32,
            insets = { left = 4, right = 4, top = 4, bottom = 4 }
        })
        mountSelectFrame:SetBackdropColor(1, 1, 1, 0.9)
        mountSelectFrame:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)

        local titleBar = CreateFrame("Frame", nil, mountSelectFrame, "BackdropTemplate")
        titleBar:SetPoint("TOPLEFT", mountSelectFrame, "TOPLEFT", 2.5, 0)
        titleBar:SetPoint("TOPRIGHT", mountSelectFrame, "TOPRIGHT", 0, 0)
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

        local title = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
        title:SetText("Select Mount to Add")

        local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
        closeButton:SetPoint("TOPRIGHT", titleBar, "TOPRIGHT", 0, 0)
        closeButton:SetScript("OnClick", function() mountSelectFrame:Hide() end)

        local mountListDropdown = CreateFrame("Frame", "WhispsMountupAddDropdown", mountSelectFrame, "UIDropDownMenuTemplate")
        mountListDropdown:SetPoint("TOP", titleBar, "BOTTOM", 0, -15)

        local function InitializeMountListDropdown(self, level)
            local info = UIDropDownMenu_CreateInfo()

            local summonMethods = {
                { text = "Alphabetical", value = "Alphabetical", description = "Sorts your mounts by name from A to Z" },
                { text = "Reverse Alphabetical", value = "Reverse Alphabetical", description = "Sorts your mounts by name from Z to A"},
                { text = "Newest to WoW", value = "Newest to WoW", description = "Sorts your mounts by when they were introduced" },
            }

            for _, method in ipairs(summonMethods) do
                info.text = method.text
                info.value = method.value
                info.tooltipTitle = method.text
                info.tooltipText = method.description
                info.func = function(self)
                    UIDropDownMenu_SetSelectedValue(mountListDropdown, self.value)
                    UIDropDownMenu_SetText(mountListDropdown, self.value)
                    CloseDropDownMenus()
                    if mountSelectFrame.PopulateMounts then
                        mountSelectFrame.PopulateMounts()
                    end
                end
                info.checked = (UIDropDownMenu_GetSelectedValue(mountListDropdown) == method)
                info.notCheckable = false
                UIDropDownMenu_AddButton(info, level)
            end
        end

        UIDropDownMenu_Initialize(mountListDropdown, InitializeMountListDropdown)
        UIDropDownMenu_SetWidth(mountListDropdown, 160)
        UIDropDownMenu_SetButtonWidth(mountListDropdown, 174)
        UIDropDownMenu_JustifyText(mountListDropdown, "LEFT")
        UIDropDownMenu_SetSelectedValue(mountListDropdown, nil)
        UIDropDownMenu_SetText(mountListDropdown, "Sort type...")

        local searchBox = CreateFrame("EditBox", nil, mountSelectFrame, "InputBoxTemplate")
        searchBox:SetSize(200, 20)
        searchBox:SetPoint("TOP", mountListDropdown, "BOTTOM", 0, -5)
        searchBox:SetAutoFocus(false)
        searchBox:SetMaxLetters(80)
        searchBox:SetFontObject(ChatFontNormal)
        searchBox:SetFrameLevel(mountSelectFrame:GetFrameLevel() + 10)

        local searchPlaceholder = searchBox:CreateFontString(nil, "ARTWORK", "GameFontDisable")
        searchPlaceholder:SetPoint("LEFT", searchBox, "LEFT", 5, 0)
        searchPlaceholder:SetText("Search mounts...")

        searchBox:SetScript("OnTextChanged", function(self)
            if self:GetText() == "" then
                searchPlaceholder:Show()
            else
                searchPlaceholder:Hide()
            end
            if mountSelectFrame.PopulateMounts then
                mountSelectFrame.PopulateMounts()
            end
        end)
        searchBox:SetScript("OnEscapePressed", function(self)
            self.ClearFocus()
        end)
        searchBox:SetScript("OnEnterPressed", function(self)
            self:ClearFocus()
        end)

        mountSelectFrame.searchBox = searchBox

        local scrollFrame = CreateFrame("ScrollFrame", nil, mountSelectFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 15, -105)
        scrollFrame:SetPoint("BOTTOMRIGHT", -35, 50)

        local content = CreateFrame("Frame", nil, scrollFrame)
        content:SetSize(scrollFrame:GetWidth(), 1)
        scrollFrame:SetScrollChild(content)

        local confirmButton = CreateFrame("Button", nil, mountSelectFrame, "UIPanelButtonTemplate")
        confirmButton:SetSize(100, 22)
        confirmButton:SetPoint("BOTTOM", 0, 15)
        confirmButton:SetText("Add Selected")
        confirmButton:SetScript("OnClick", function()
            local targetList = mountSelectFrame.targetListName
            if targetList then
                addMount(targetList, mountSelectFrame.selectedMounts)
                UpdateMountList(targetList)
                
                mountSelectFrame.selectedMounts = {}
                
                if UpdateList then
                    UpdateList()
                end
                
                mountSelectFrame:Hide()
            end
        end)

        mountSelectFrame.PopulateMounts = function()
            for _, child in ipairs({content:GetChildren()}) do
                child:Hide()
                child:SetParent(nil)
            end

            local mounts = C_MountJournal.GetMountIDs()
            local buttonHeight = 30

            local collectedMounts = {}
            for i, mountID in ipairs(mounts) do
                local name, spellID, icon, _, _, _, _, _, _, _, isCollected, displayID = C_MountJournal.GetMountInfoByID(mountID)
                local _, _, _, _, _, _, _, _, _, mountType = C_MountJournal.GetMountInfoExtraByID(mountID)
                if isCollected then
                    table.insert(collectedMounts, {id = mountID, name = name, icon = icon, mountType = mountType, displayID = displayID})
                end
            end

            local selectedSortMethod = UIDropDownMenu_GetSelectedValue(mountListDropdown)
            if selectedSortMethod == "Alphabetical" then
                table.sort(collectedMounts, function(a, b) return a.name < b.name end)
            elseif selectedSortMethod == "Reverse Alphabetical" then
                table.sort(collectedMounts, function(a, b) return a.name > b.name end)
            elseif selectedSortMethod == "Newest to WoW" then
                table.sort(collectedMounts, function(a, b)
                    if a.displayID ~= b.displayID then
                        return a.displayID > b.displayID
                    end

                    return a.id > b.id
                end)
            end

            local searchText = mountSelectFrame.searchBox and mountSelectFrame.searchBox:GetText() or ""
            if searchText ~= "" then
                searchText = searchText:lower()
                local filtered = {}
                for _, mount in ipairs(collectedMounts) do
                    if mount.name:lower():find(searchText, 1, true) then
                        table.insert(filtered, mount)
                    end
                end
                collectedMounts = filtered
            end

            local totalHeight = #collectedMounts * buttonHeight
            content:SetHeight(totalHeight)

            for i, mountInfo in ipairs(collectedMounts) do
                local yOffset = -(i-1) * buttonHeight
                local button = CreateFrame("Button", "WhispsMountupSelectButton" .. i, content, "BackdropTemplate")
                button:SetSize(content:GetWidth() - 10, buttonHeight)
                button:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
                button:SetPoint("TOPRIGHT", content, "TOPRIGHT", -5, yOffset)

                button:SetBackdrop({
                    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
                    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
                    title = true,
                    titleSize = 16,
                    edgeSize = 16,
                    insets = { left = 4, right = 4, top = 4, bottom = 4 }
                })
                button:SetBackdropColor(0.1, 0.1, 0.1, 1)
                button:SetHighlightTexture("Interface\\Buttons\\UI-ListBox-Highlight", "ADD")

                local iconTexture = button:CreateTexture(nil, "ARTWORK")
                iconTexture:SetSize(buttonHeight - 6, buttonHeight - 6)
                iconTexture:SetPoint("LEFT", button, "LEFT", 3, 0)
                iconTexture:SetTexture(mountInfo.icon)

                local label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                label:SetPoint("LEFT", iconTexture, "RIGHT", 8, 0)
                label:SetText(mountInfo.name)
                label:SetJustifyH("LEFT")

                button:SetScript("OnClick", function()
                    if not mountSelectFrame.selectedMounts then
                        mountSelectFrame.selectedMounts = {}
                    end

                    if mountSelectFrame.selectedMounts[mountInfo.id] then
                        mountSelectFrame.selectedMounts[mountInfo.id] = nil
                    else
                        mountSelectFrame.selectedMounts[mountInfo.id] = mountInfo
                    end

                    if button.isHighlighted then
                        button:UnlockHighlight()
                        button.isHighlighted = false
                    else
                        for _, child in ipairs(content:GetChildren()) do
                            if child.isHighlighted then
                                child:UnlockHighlight()
                                child.isHighlighted = false
                            end
                        end
                        button:LockHighlight()
                        button.isHighlighted = true
                    end
                end)
            end
        end
    end

    WhispsMountupSelectionFrame.targetListName = listName
    
    WhispsMountupSelectionFrame.PopulateMounts()
    WhispsMountupSelectionFrame:Show()
end