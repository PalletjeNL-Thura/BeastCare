local ADDON_NAME = "BeastCare"
local ADDON_AUTHOR = "ThuraNL"

local DEFAULT_SETTINGS = {
    warningsEnabled = true,
    soundEnabled = true,
    warningInterval = 20,
}

local function GetAddonVersion()
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        return C_AddOns.GetAddOnMetadata(ADDON_NAME, "Version") or "Unknown"
    end

    if GetAddOnMetadata then
        return GetAddOnMetadata(ADDON_NAME, "Version") or "Unknown"
    end

    return "Unknown"
end

local ADDON_VERSION = GetAddonVersion()

local function PrintMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format("|cff33ff99%s:|r %s", ADDON_NAME, message)
    )
end

local function GetSettings()
    if type(BeastCareDB) ~= "table" then
        BeastCareDB = {}
    end

    for setting, defaultValue in pairs(DEFAULT_SETTINGS) do
        if BeastCareDB[setting] == nil then
            BeastCareDB[setting] = defaultValue
        end
    end

    return BeastCareDB
end

local function FormatNumber(number)
    return BreakUpLargeNumbers(number or 0)
end

local function GetHappinessText()
    if not GetPetHappiness then
        return "Unavailable"
    end

    local happiness = GetPetHappiness()

    local happinessLabels = {
        [1] = "Unhappy",
        [2] = "Content",
        [3] = "Happy",
    }

    return happinessLabels[happiness] or "Unknown"
end

local function GetLoyaltyInfo()
    if not GetPetLoyalty then
        return nil, nil
    end

    local loyaltyText = GetPetLoyalty()

    if not loyaltyText or loyaltyText == "" then
        return nil, nil
    end

    local loyaltyLevel, loyaltyName = string.match(
        loyaltyText,
        "%(Loyalty Level (%d+)%)%s*(.+)"
    )

    return tonumber(loyaltyLevel), loyaltyName
end

local function GetLoyaltyText()
    local loyaltyLevel, loyaltyName = GetLoyaltyInfo()

    if not loyaltyLevel or not loyaltyName then
        return "Unknown"
    end

    return string.format("Level %d - %s", loyaltyLevel, loyaltyName)
end

local function GetPetFamily()
    if not UnitExists("pet") then
        return "Unknown"
    end

    return UnitCreatureFamily("pet") or "Unknown"
end

local function GetPetFoodTypesText()
    if not UnitExists("pet") then
        return "Unknown"
    end

    if not GetPetFoodTypes then
        return "Unavailable"
    end

    local function CollectFoodTypes(...)
        local foodTypes = {}
        local numberOfValues = select("#", ...)

        for index = 1, numberOfValues do
            local foodType = select(index, ...)

            if type(foodType) == "string" and foodType ~= "" then
                table.insert(foodTypes, foodType)
            end
        end

        if #foodTypes == 0 then
            return "Unknown"
        end

        return table.concat(foodTypes, ", ")
    end

    return CollectFoodTypes(GetPetFoodTypes())
end

local function PrintStatusLine(label, value)
    PrintMessage(string.format(
        "|cff9fc5e8%s:|r |cffffffff%s|r",
        label,
        value
    ))
end

local function PrintHelpLine(command, description)
    PrintMessage(string.format(
        "|cff9fc5e8%s|r |cffffffff- %s|r",
        command,
        description
    ))
end

local function ShowPetStatus()
    if not UnitExists("pet") then
        PrintMessage("No active pet detected.")
        return
    end

    local petName = UnitName("pet") or "Unknown"
    local petFamily = GetPetFamily()
    local petLevel = UnitLevel("pet") or 0
    local currentHealth = UnitHealth("pet") or 0
    local maximumHealth = UnitHealthMax("pet") or 0

    local currentExperience = 0
    local maximumExperience = 0

    if GetPetExperience then
        currentExperience, maximumExperience = GetPetExperience()
    end

	local availableTrainingPoints = nil

	if GetPetTrainingPoints then
		local totalTrainingPoints, spentTrainingPoints = GetPetTrainingPoints()

		if totalTrainingPoints and spentTrainingPoints then
			availableTrainingPoints = totalTrainingPoints - spentTrainingPoints
		end
	end

    PrintMessage("|cff00aaffPet Status|r")

    PrintStatusLine("Name", petName)
    PrintStatusLine("Family", petFamily)
    PrintStatusLine("Level", petLevel)

    PrintStatusLine(
        "Health",
        string.format(
            "%s / %s",
            FormatNumber(currentHealth),
            FormatNumber(maximumHealth)
        )
    )

    if maximumExperience and maximumExperience > 0 then
        local experiencePercent = math.ceil(
            currentExperience / maximumExperience * 100
        )

        PrintStatusLine(
            "Experience",
            string.format(
                "%s / %s (%d%%)",
                FormatNumber(currentExperience),
                FormatNumber(maximumExperience),
                experiencePercent
            )
        )
    elseif GetPetExperience then
        PrintStatusLine("Experience", "No experience available")
    else
        PrintStatusLine("Experience", "Unavailable")
    end

    if availableTrainingPoints ~= nil then
		PrintStatusLine("Training Points", availableTrainingPoints)
	else
		PrintStatusLine("Training Points", "Unavailable")
	end
		PrintStatusLine("Happiness", GetHappinessText())
		PrintStatusLine("Food types", GetPetFoodTypesText())
		PrintStatusLine("Loyalty", GetLoyaltyText())
	end

local function ShowTrainingPointsDebug()
    if not UnitExists("pet") then
        PrintMessage("No active pet detected.")
        return
    end

    local value1, value2, value3, value4, value5 = GetPetTrainingPoints()

    PrintMessage("Training points debug:")
    PrintMessage(string.format("Value 1: %s", tostring(value1)))
    PrintMessage(string.format("Value 2: %s", tostring(value2)))
    PrintMessage(string.format("Value 3: %s", tostring(value3)))
    PrintMessage(string.format("Value 4: %s", tostring(value4)))
    PrintMessage(string.format("Value 5: %s", tostring(value5)))

    if GetNumPetSkills then
        PrintMessage(string.format(
            "Pet skills: %s",
            tostring(GetNumPetSkills())
        ))
    end
end

local function ShowSettings()
    local settings = GetSettings()

    local warningsStatus = settings.warningsEnabled and "Enabled" or "Disabled"
    local soundStatus = settings.soundEnabled and "Enabled" or "Disabled"

    PrintMessage("Settings:")
    PrintMessage(string.format("Warnings: |cffffffff%s|r", warningsStatus))
    PrintMessage(string.format("Sound: |cffffffff%s|r", soundStatus))
    PrintMessage(string.format(
        "Warning interval: |cffffffff%d seconds|r",
        settings.warningInterval
    ))
end

local function ShowHelp()
    PrintMessage("|cff00aaffCommands|r")

    PrintHelpLine("/bc status", "Show active pet status.")
    PrintHelpLine("/bc settings", "Show current BeastCare settings.")
    PrintHelpLine("/bc options", "Open BeastCare options.")
	PrintHelpLine("/bc inspect", "Show the name and family of a selected player's pet.")
    PrintHelpLine("/bc interval 20", "Set warning interval.")
    PrintHelpLine("/bc warnings on/off", "Enable or disable feeding warnings.")
    PrintHelpLine("/bc sound on/off", "Enable or disable warning sounds.")
    PrintHelpLine(
        "/bc feedwindow reset",
        "Reset Feed Pet Effect window position."
    )
end

local function ShowPetWarning(message)
    local settings = GetSettings()

    if not settings.warningsEnabled then
        return
    end

    RaidNotice_AddMessage(
        RaidWarningFrame,
        message,
        ChatTypeInfo["RAID_WARNING"]
    )

    if settings.soundEnabled then
        if SOUNDKIT and SOUNDKIT.RAID_WARNING then
            PlaySound(SOUNDKIT.RAID_WARNING, "Master")
        else
            PlaySound("RaidWarning", "Master")
        end
    end
end

local function ShowLoyaltyAnnouncement(message)
    local settings = GetSettings()

    UIErrorsFrame:AddMessage(message, 1.0, 0.82, 0.0, 1.0)

    if settings.soundEnabled then
        if SOUNDKIT and SOUNDKIT.IG_QUEST_LIST_OPEN then
            PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN, "Master")
        else
            PlaySound("igQuestListOpen", "Master")
        end
    end
end

local frame = CreateFrame("Frame")

frame.lastHappinessWarning = nil
frame.lastWarningTime = nil
frame.lastPetGUID = nil
frame.lastLoyaltyLevel = nil

-- Feed Pet Effect window
local feedWindow = CreateFrame("Frame", "BeastCareFeedWindow", UIParent)

feedWindow:SetSize(210, 50)
feedWindow:SetFrameStrata("MEDIUM")
feedWindow:SetMovable(true)
feedWindow:EnableMouse(true)
feedWindow:RegisterForDrag("LeftButton")
feedWindow:SetClampedToScreen(true)
feedWindow:Hide()

feedWindow.background = feedWindow:CreateTexture(nil, "BACKGROUND")
feedWindow.background:SetAllPoints()
feedWindow.background:SetColorTexture(0, 0, 0, 0.75)

feedWindow.icon = feedWindow:CreateTexture(nil, "ARTWORK")
feedWindow.icon:SetSize(38, 38)
feedWindow.icon:SetPoint("LEFT", feedWindow, "LEFT", 6, 0)

feedWindow.title = feedWindow:CreateFontString(nil, "OVERLAY", "GameFontNormal")
feedWindow.title:SetPoint("TOPLEFT", feedWindow.icon, "TOPRIGHT", 8, -3)
feedWindow.title:SetText("Feed Pet Effect")
feedWindow.title:SetTextColor(1.0, 0.82, 0.0)

feedWindow.timer = feedWindow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
feedWindow.timer:SetPoint("BOTTOMLEFT", feedWindow.icon, "BOTTOMRIGHT", 8, 4)
feedWindow.timer:SetText("")

local function SaveFeedWindowPosition()
    local point, _, relativePoint, xOffset, yOffset = feedWindow:GetPoint(1)

    GetSettings().feedWindowPosition = {
        point = point,
        relativePoint = relativePoint,
        xOffset = xOffset,
        yOffset = yOffset,
    }
end

local function SetDefaultFeedWindowPosition()
    feedWindow:ClearAllPoints()
    feedWindow:SetPoint("CENTER", UIParent, "CENTER", 0, -180)
end

local function LoadFeedWindowPosition()
    local position = GetSettings().feedWindowPosition

    if not position then
        SetDefaultFeedWindowPosition()
        return
    end

    feedWindow:ClearAllPoints()
    feedWindow:SetPoint(
        position.point or "CENTER",
        UIParent,
        position.relativePoint or "CENTER",
        position.xOffset or 0,
        position.yOffset or -180
    )
end

feedWindow:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

feedWindow:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveFeedWindowPosition()
end)

local function ResetHappinessWarningState()
    frame.lastHappinessWarning = nil
    frame.lastWarningTime = nil
end

local function ResetLoyaltyTracking()
    frame.lastPetGUID = nil
    frame.lastLoyaltyLevel = nil
end

local function CheckPetHappiness()
    local settings = GetSettings()

    if not UnitExists("pet") or UnitIsDeadOrGhost("pet") then
        ResetHappinessWarningState()
        return
    end

    -- Feeding is not available while the Hunter or pet is in combat.
    if UnitAffectingCombat("player") or UnitAffectingCombat("pet") then
        ResetHappinessWarningState()
        return
    end

    if not GetPetHappiness then
        return
    end

    local happiness = GetPetHappiness()

    -- Warnings are only needed for Content or Unhappy pets.
    if happiness ~= 1 and happiness ~= 2 then
        ResetHappinessWarningState()
        return
    end

    local currentTime = GetTime()
    local happinessChanged = frame.lastHappinessWarning ~= happiness
    local warningDue = not frame.lastWarningTime
        or (currentTime - frame.lastWarningTime >= settings.warningInterval)

    if not happinessChanged and not warningDue then
        return
    end

    frame.lastHappinessWarning = happiness
    frame.lastWarningTime = currentTime

    if happiness == 2 then
        ShowPetWarning("BEASTCARE: PET IS CONTENT - FEED IT PLEASE!")
    elseif happiness == 1 then
        ShowPetWarning("BEASTCARE: PET IS UNHAPPY - FEED IT NOW!")
    end
end

local function CheckPetLoyalty()
    if not UnitExists("pet") then
        ResetLoyaltyTracking()
        return
    end

    local petGUID = UnitGUID("pet")
    local loyaltyLevel, loyaltyName = GetLoyaltyInfo()

    if not petGUID or not loyaltyLevel or not loyaltyName then
        return
    end

    -- Store the current loyalty level for a newly detected pet.
    -- This prevents an announcement at login or when summoning a pet.
    if frame.lastPetGUID ~= petGUID then
        frame.lastPetGUID = petGUID
        frame.lastLoyaltyLevel = loyaltyLevel

        PrintMessage(string.format(
            "Tracking %s at Loyalty Level %d - %s.",
            UnitName("pet") or "pet",
            loyaltyLevel,
            loyaltyName
        ))
        return
    end

    if not frame.lastLoyaltyLevel then
        frame.lastLoyaltyLevel = loyaltyLevel
        return
    end

    if loyaltyLevel > frame.lastLoyaltyLevel then
        local petName = UnitName("pet") or "Your pet"
        local message = string.format(
            "%s reached Loyalty Level %d - %s!",
            petName,
            loyaltyLevel,
            loyaltyName
        )

        PrintMessage(message)
        ShowLoyaltyAnnouncement(message)
    end

    frame.lastLoyaltyLevel = loyaltyLevel
end

local function GetFeedPetAura()
    if not UnitExists("pet") then
        return nil
    end

    for index = 1, 40 do
        local name, icon, _, _, duration, expirationTime = UnitAura(
            "pet",
            index,
            "HELPFUL"
        )

        if not name then
            break
        end

        if name == "Feed Pet Effect" then
            return icon, duration, expirationTime
        end
    end

    return nil
end

local function UpdateFeedWindow()
    local icon, duration, expirationTime = GetFeedPetAura()

    if not icon then
        feedWindow:Hide()
        return
    end

    feedWindow.icon:SetTexture(icon)

    local remainingTime = 0

    if expirationTime and expirationTime > 0 then
        remainingTime = math.max(0, math.ceil(expirationTime - GetTime()))
    elseif duration and duration > 0 then
        remainingTime = math.ceil(duration)
    end

    if remainingTime > 0 then
        feedWindow.timer:SetText(
            string.format("%d seconds remaining", remainingTime)
        )
    else
        feedWindow.timer:SetText("Active")
    end

    feedWindow:Show()
end

-- Options panel
local optionsPanel = CreateFrame("Frame", "BeastCareOptionsPanel", UIParent)
optionsPanel.name = ADDON_NAME

optionsPanel.title = optionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontNormalLarge"
)
optionsPanel.title:SetPoint("TOPLEFT", optionsPanel, "TOPLEFT", 16, -16)
optionsPanel.title:SetText("BeastCare")

optionsPanel.subtitle = optionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontHighlightSmall"
)
optionsPanel.subtitle:SetPoint("TOPLEFT", optionsPanel.title, "BOTTOMLEFT", 0, -8)
optionsPanel.subtitle:SetText(
    "Hunter pet-care tools for Burning Crusade Anniversary."
)

optionsPanel.warningCheckbox = CreateFrame(
    "CheckButton",
    "BeastCareWarningsCheckbox",
    optionsPanel,
    "InterfaceOptionsCheckButtonTemplate"
)
optionsPanel.warningCheckbox:SetPoint(
    "TOPLEFT",
    optionsPanel.subtitle,
    "BOTTOMLEFT",
    -2,
    -22
)

optionsPanel.warningCheckbox.label = optionsPanel.warningCheckbox:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontNormal"
)
optionsPanel.warningCheckbox.label:SetPoint(
    "LEFT",
    optionsPanel.warningCheckbox,
    "RIGHT",
    2,
    1
)
optionsPanel.warningCheckbox.label:SetText("Enable feeding warnings")

optionsPanel.soundCheckbox = CreateFrame(
    "CheckButton",
    "BeastCareSoundCheckbox",
    optionsPanel,
    "InterfaceOptionsCheckButtonTemplate"
)
optionsPanel.soundCheckbox:SetPoint(
    "TOPLEFT",
    optionsPanel.warningCheckbox,
    "BOTTOMLEFT",
    0,
    -8
)

optionsPanel.soundCheckbox.label = optionsPanel.soundCheckbox:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontNormal"
)
optionsPanel.soundCheckbox.label:SetPoint(
    "LEFT",
    optionsPanel.soundCheckbox,
    "RIGHT",
    2,
    1
)
optionsPanel.soundCheckbox.label:SetText("Enable warning sounds")

optionsPanel.intervalLabel = optionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontNormal"
)
optionsPanel.intervalLabel:SetPoint(
    "TOPLEFT",
    optionsPanel.soundCheckbox,
    "BOTTOMLEFT",
    2,
    -30
)
optionsPanel.intervalLabel:SetText("Warning interval")

optionsPanel.intervalValue = optionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontHighlight"
)
optionsPanel.intervalValue:SetPoint(
    "LEFT",
    optionsPanel.intervalLabel,
    "RIGHT",
    12,
    0
)

optionsPanel.intervalSlider = CreateFrame(
    "Slider",
    "BeastCareIntervalSlider",
    optionsPanel,
    "OptionsSliderTemplate"
)
optionsPanel.intervalSlider:SetPoint(
    "TOPLEFT",
    optionsPanel.intervalLabel,
    "BOTTOMLEFT",
    0,
    -20
)
optionsPanel.intervalSlider:SetWidth(300)
optionsPanel.intervalSlider:SetMinMaxValues(5, 60)
optionsPanel.intervalSlider:SetValueStep(1)
optionsPanel.intervalSlider:SetObeyStepOnDrag(true)

_G[optionsPanel.intervalSlider:GetName() .. "Low"]:SetText("5 seconds")
_G[optionsPanel.intervalSlider:GetName() .. "High"]:SetText("60 seconds")
_G[optionsPanel.intervalSlider:GetName() .. "Text"]:SetText("")

optionsPanel.resetButton = CreateFrame(
    "Button",
    "BeastCareResetFeedWindowButton",
    optionsPanel,
    "UIPanelButtonTemplate"
)
optionsPanel.resetButton:SetSize(250, 24)
optionsPanel.resetButton:SetPoint(
    "TOPLEFT",
    optionsPanel.intervalSlider,
    "BOTTOMLEFT",
    0,
    -35
)
optionsPanel.resetButton:SetText("Reset Feed Pet Effect Window Position")

optionsPanel.helpText = optionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontHighlightSmall"
)
optionsPanel.helpText:SetPoint(
    "TOPLEFT",
    optionsPanel.resetButton,
    "BOTTOMLEFT",
    0,
    -22
)
optionsPanel.helpText:SetText(
    "Use /bc status to view your active pet status."
)

local function UpdateOptionsPanel()
    local settings = GetSettings()

    optionsPanel.isRefreshing = true

    optionsPanel.warningCheckbox:SetChecked(settings.warningsEnabled)
    optionsPanel.soundCheckbox:SetChecked(settings.soundEnabled)
    optionsPanel.intervalSlider:SetValue(settings.warningInterval)
    optionsPanel.intervalValue:SetText(
        string.format("%d seconds", settings.warningInterval)
    )

    optionsPanel.isRefreshing = false
end

optionsPanel.warningCheckbox:SetScript("OnClick", function(self)
    GetSettings().warningsEnabled = self:GetChecked() and true or false
    ResetHappinessWarningState()
end)

optionsPanel.soundCheckbox:SetScript("OnClick", function(self)
    GetSettings().soundEnabled = self:GetChecked() and true or false
end)

optionsPanel.intervalSlider:SetScript("OnValueChanged", function(_, value)
    if optionsPanel.isRefreshing then
        return
    end

    local interval = math.floor(value + 0.5)

    GetSettings().warningInterval = interval
    optionsPanel.intervalValue:SetText(
        string.format("%d seconds", interval)
    )

    ResetHappinessWarningState()
end)

optionsPanel.resetButton:SetScript("OnClick", function()
    GetSettings().feedWindowPosition = nil
    SetDefaultFeedWindowPosition()
    PrintMessage("Feed Pet Effect window position reset.")
end)

optionsPanel:SetScript("OnShow", function()
    UpdateOptionsPanel()
end)

local function RegisterOptionsPanel()
    -- Newer clients use the Settings API.
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(
            optionsPanel,
            ADDON_NAME
        )

        Settings.RegisterAddOnCategory(category)
        optionsPanel.category = category
        return
    end

    -- TBC Classic and older clients use InterfaceOptions.
    if InterfaceOptions_AddCategory then
        InterfaceOptions_AddCategory(optionsPanel)
    end
end

local function OpenOptionsPanel()
    UpdateOptionsPanel()

    if optionsPanel.category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(optionsPanel.category.ID)
        return
    end

    if InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(optionsPanel)
        return
    end

    PrintMessage("Unable to open the Options panel in this client.")
end

-- Timers
local elapsedSinceLastCheck = 0
local elapsedSinceFeedCheck = 0

frame:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceLastCheck = elapsedSinceLastCheck + elapsed
    elapsedSinceFeedCheck = elapsedSinceFeedCheck + elapsed

    -- General pet status checks run once per second.
    if elapsedSinceLastCheck >= 1 then
        elapsedSinceLastCheck = 0

        CheckPetHappiness()
        CheckPetLoyalty()
    end

    -- Update the Feed Pet Effect timer four times per second.
    if elapsedSinceFeedCheck >= 0.25 then
        elapsedSinceFeedCheck = 0

        UpdateFeedWindow()
    end
end)

SLASH_BEASTCARE1 = "/beastcare"
SLASH_BEASTCARE2 = "/bc"

SlashCmdList["BEASTCARE"] = function(message)
    message = string.lower(message or "")
    message = string.match(message, "^%s*(.-)%s*$")

    local command, argument = string.match(message, "^(%S*)%s*(.-)%s*$")

    command = command or ""
    argument = argument or ""

    if command == "status" then
        ShowPetStatus()
        return
    end
	
	if command == "inspect" then
		if BeastCare and BeastCare.InspectTargetPet then
			BeastCare.InspectTargetPet()
		else
			PrintMessage("Pet Inspect module is not available.")
		end

		return
	end
	
	if command == "trainingdebug" then
		ShowTrainingPointsDebug()
		return
	end

    if command == "settings" then
        ShowSettings()
        return
    end

    if command == "options" then
        OpenOptionsPanel()
        return
    end

    if command == "feedwindow" then
        if argument == "reset" then
            GetSettings().feedWindowPosition = nil
            SetDefaultFeedWindowPosition()

            PrintMessage("Feed Pet Effect window position reset.")
            return
        end

        PrintMessage(
            "Use |cffffffff/bc feedwindow reset|r to reset the window position."
        )
        return
    end

    if command == "interval" then
        local interval = tonumber(argument)

        if not interval or interval < 5 or interval > 60 then
            PrintMessage("Choose an interval between 5 and 60 seconds.")
            return
        end

        GetSettings().warningInterval = math.floor(interval)
        ResetHappinessWarningState()

        PrintMessage(string.format(
            "Warning interval set to |cffffffff%d seconds|r.",
            GetSettings().warningInterval
        ))
        return
    end

    if command == "warnings" then
        if argument == "on" then
            GetSettings().warningsEnabled = true
            ResetHappinessWarningState()
            PrintMessage("Warnings enabled.")
            return
        end

        if argument == "off" then
            GetSettings().warningsEnabled = false
            ResetHappinessWarningState()
            PrintMessage("Warnings disabled.")
            return
        end

        PrintMessage(
            "Use |cffffffff/bc warnings on|r or |cffffffff/bc warnings off|r."
        )
        return
    end

    if command == "sound" then
        if argument == "on" then
            GetSettings().soundEnabled = true
            PrintMessage("Warning sound enabled.")
            return
        end

        if argument == "off" then
            GetSettings().soundEnabled = false
            PrintMessage("Warning sound disabled.")
            return
        end

        PrintMessage(
            "Use |cffffffff/bc sound on|r or |cffffffff/bc sound off|r."
        )
        return
    end

    if command == "help" then
        ShowHelp()
        return
    end

    PrintMessage(string.format(
        "v%s by %s is running.",
        ADDON_VERSION,
        ADDON_AUTHOR
    ))
    PrintMessage("Type |cffffffff/bc help|r for available commands.")
end

frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UNIT_HAPPINESS")

frame:SetScript("OnEvent", function(self, event, unit)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")

        GetSettings()
        LoadFeedWindowPosition()
        RegisterOptionsPanel()

        PrintMessage(string.format(
            "v%s by %s loaded.",
            ADDON_VERSION,
            ADDON_AUTHOR
        ))

        if UnitExists("pet") then
            PrintMessage("Active pet detected.")
        else
            PrintMessage("No active pet detected.")
        end

        return
    end

    if event == "UNIT_HAPPINESS" and unit == "pet" then
        CheckPetHappiness()
    end
end)