MountSet = {}
MountIndexes = {}

local player = {

	name = UnitName("player"),
	level = UnitLevel("player")

}

local function HandleCombatStart()
    if WhispsMountupDB and WhispsMountupDB.settings and WhispsMountupDB.settings.combatDismount then
        if IsMounted() and not IsFlying() then
            Dismount()
        end
    end
end

local combatFrame = CreateFrame("Frame")
combatFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
combatFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_REGEN_DISABLED" then
        HandleCombatStart()
    end
end)

local function mountCommand(args)
	local mountIDs = C_MountJournal.GetMountIDs()

	for i, id in ipairs(mountIDs) do
		local mount = C_MountJournal.GetMountInfoByID(id)
		if mount == args then
			C_MountJournal.SummonByID(id)
		end
	end
end

local function split (input, regex)
	local result = {}
	if input == nil then
		return nil
	elseif not string.match(input, regex) then
		return nil
	end
	for str in string.gmatch(input, "([^"..regex.."]+)") do
		table.insert(result, str)
	end
	return result
end

function addMount(category, selectedMounts)
	if not MountSet[category] then
		MountSet[category] = {}
	end
	
	for id, mountInfo in pairs(selectedMounts) do
		local alreadyExists = false
		for _, existingId in ipairs(MountSet[category]) do
			if existingId == mountInfo.id then
				alreadyExists = true
				print(mountInfo.name .. " is already in the list")
				break
			end
		end
		
		if not alreadyExists then
			table.insert(MountSet[category], mountInfo.id)
			print("Successfully added " .. mountInfo.name)
		end
	end
end

local function addCategory(args)
	if MountSet[args] ~= nil then
		print("That category already exists")
		return
	end

	MountSet[args] = {}
	print("Category added")
end

function orderedMount(arg)
	if arg == "" then
		print("You must enter a category")
		return;
	end
	if MountSet[arg] == nil then
		print("That category does not exist")
		return;
	end
	if MountIndexes[arg] == nil then
		MountIndexes[arg] = 1
	end

	current = MountIndexes[arg]
	limit = #MountSet[arg]
	attempts = 0

	while attempts < limit do
		if current >= limit then
			current = 1
		else
			current = current + 1
		end

		if MountSet[arg][current] ~= nil then
			local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(MountSet[arg][current])
			if isUsable then
				MountIndexes[arg] = current
				C_MountJournal.SummonByID(MountSet[arg][current])
				return
			end
		end

		current = current + 1
		attempts = attempts + 1
	end

	MountIndexes[arg] = current
	print("No usable mounts found in that category")
end

function randomMount(arg)
	if arg == "" then
		print("You must enter a category")
		return;
	end
	if MountSet[arg] == nil then
		print("That category does not exist")
		return;
	end
	if #MountSet[arg] == 0 then
		print("You have not added any mounts")
		return;
	end

	local usableMounts = {}

	for _, mountID in ipairs(MountSet[arg]) do
		local _, _, _, _, isUsable = C_MountJournal.GetMountInfoByID(mountID)
		if isUsable then
			table.insert(usableMounts, mountID)
		end
	end

	if #usableMounts == 0 then
		print("No usable mounts in this category")
		return
	end

	result = math.random(1, #usableMounts)
	C_MountJournal.SummonByID(usableMounts[result])
end

function removeMount(category, selectedMounts)
	if not MountSet[category] then
		return
	end
	
	for mountId, mountInfo in pairs(selectedMounts) do
		for i = #MountSet[category], 1, -1 do
			if MountSet[category][i] == mountId then
				table.remove(MountSet[category], i)
				print("Successfully removed " .. mountInfo.name)
				break
			end
		end
	end
end

local function removeCategory(arg)
	if MountSet[arg] ~= nil then
		MountSet[arg] = nil
		print("Category removed")
	else
		print("No category found with that name")
	end
end

local function list(arg)
	if arg == "" then
		print("You must enter a category")
		return;
	end

	if MountSet[arg] == nil then
		print("No category found with that name")
		return;
	end

	for mount in pairs(MountSet[arg]) do
		if string.len(mount) > 1 then
			print(mount)
		end
	end
end

local function help()
	print("/addmount:/am <category> <mount name, replacing spaces with underscores> - Adds a mount to a category")
	print("/addcategory:/ac <category> - Adds a category")
	print("/removemount:/rm <category> <mount name, replacing spaces with underscores> - Removes a mount from a category")
	print("/removecategory:/rc <category> - Removes a category")
	print("/mountlist:/ml <category> - Lists the mounts in the given category")
	print("/random <category> - Summons a random mount in the category")
	print("/ordered <category> - Summons the next mount in the category")
	print("/mounthelp:/mh - Displays this help message")
end

local function registerCommands()
	SLASH_AddMount1 = "/addmount"
	SLASH_AddMount2 = "/am"
	SlashCmdList.AddMount = addMount

	SLASH_AddCategory1 = "/addcategory"
	SLASH_AddCategory2 = "/ac"
	SlashCmdList.AddCategory = addCategory

	SLASH_Ordered1 = "/ordered"
	SlashCmdList.Ordered = orderedMount

	SLASH_Random1 = "/random"
	SlashCmdList.Random = randomMount

	SLASH_RemoveMount1 = "/removemount"
	SLASH_RemoveMount2 = "/rm"
	SlashCmdList.RemoveMount = removeMount

	SLASH_RemoveCategory1 = "/removecategory"
	SLASH_RemoveCategory2 = "/rc"
	SlashCmdList.RemoveCategory = removeCategory

    SLASH_MountList1 = "/mountlist"
    SLASH_MountList2 = "/ml"
	SlashCmdList.MountList = list

	SLASH_MountHelp1 = "/mounthelp"
	SLASH_MountHelp2 = "/mh"
	SlashCmdList.MountHelp = help
end

local function init(event, table, name)
	if name == "Whisp's Mount Up" then
		MountSet = _G["MountSet"]
		MountIndexes = _G["MountIndexes"]
		WhispsMountupDB = _G["WhispsMountupDB"]

		registerCommands();
		InitializeMinimapIcon()
        InitActionBar()
        InitializeSettingsGUI()
        InitializeSummonGUI()

		tinsert(UISpecialFrames, "WhispsMountupFrame")
		tinsert(UISpecialFrames, "WhispsMountupSelectionFrame")
	end
end

local events = CreateFrame("Frame");
events:RegisterEvent("ADDON_LOADED");
events:SetScript("OnEvent", init);