local ADDON_NAME = "BeastCare"
local ADDON_AUTHOR = "ThuraNL (PalletjeNL)"

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

    local foodTypes = { GetPetFoodTypes() }
    local validFoodTypes = {}

    for index = 1, select("#", GetPetFoodTypes()) do
        local foodType = foodTypes[index]

        if type(foodType) == "string" and foodType ~= "" then
            table.insert(validFoodTypes, foodType)
        end
    end

    if #validFoodTypes == 0 then
        return "Unknown"
    end

    return table.concat(validFoodTypes, ", ")
end

local function PrintStatusLine(label, value)
    PrintMessage(string.format(
        "|cff9fc5e8%s:|r |cffffffff%s|r",
        label,
        tostring(value)
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

local function ShowSettings()
    local settings = GetSettings()

    local warningsStatus = settings.warningsEnabled and "Enabled" or "Disabled"
    local soundStatus = settings.soundEnabled and "Enabled" or "Disabled"

    PrintMessage("|cff00aaffSettings|r")
    PrintStatusLine("Warnings", warningsStatus)
    PrintStatusLine("Sound", soundStatus)
    PrintStatusLine(
        "Warning interval",
        string.format("%d seconds", settings.warningInterval)
    )
end

local function ShowHelp()
    PrintMessage("|cff00aaffCommands|r")

    PrintHelpLine("/bc status", "Show active pet status.")
    PrintHelpLine(
        "/bc inspect",
        "Show the name and family of a selected player's pet."
    )
    PrintHelpLine("/bc settings", "Show current BeastCare settings.")
    PrintHelpLine("/bc options", "Open BeastCare options.")
    PrintHelpLine("/bc interval 20", "Set warning interval.")
    PrintHelpLine("/bc warnings on/off", "Enable or disable feeding warnings.")
    PrintHelpLine("/bc sound on/off", "Enable or disable warning sounds.")
    PrintHelpLine(
        "/bc feedwindow reset",
        "Reset Feed Pet Effect window position."
    )
    PrintHelpLine(
        "/bc mendwindow reset",
        "Reset Mend Pet window position."
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

-- Creates a movable window for an active pet aura.
local function CreateBuffTimerWindow(frameName, title, titleColor)
    local window = CreateFrame("Frame", frameName, UIParent)

    window:SetSize(210, 50)
    window:SetFrameStrata("MEDIUM")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetClampedToScreen(true)
    window:Hide()

    window.background = window:CreateTexture(nil, "BACKGROUND")
    window.background:SetAllPoints()
    window.background:SetColorTexture(0, 0, 0, 0.75)

    window.icon = window:CreateTexture(nil, "ARTWORK")
    window.icon:SetSize(38, 38)
    window.icon:SetPoint("LEFT", window, "LEFT", 6, 0)

    window.title = window:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    window.title:SetPoint("TOPLEFT", window.icon, "TOPRIGHT", 8, -3)
    window.title:SetText(title)
    window.title:SetTextColor(
        titleColor[1],
        titleColor[2],
        titleColor[3]
    )

    window.timer = window:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    window.timer:SetPoint("BOTTOMLEFT", window.icon, "BOTTOMRIGHT", 8, 4)
    window.timer:SetText("")

    return window
end

local feedWindow = CreateBuffTimerWindow(
    "BeastCareFeedWindow",
    "Feed Pet Effect",
    { 1.0, 0.82, 0.0 }
)

local mendWindow = CreateBuffTimerWindow(
    "BeastCareMendWindow",
    "Mend Pet",
    { 0.35, 0.85, 1.0 }
)

local function SaveWindowPosition(window, settingName)
    local point, _, relativePoint, xOffset, yOffset = window:GetPoint(1)

    GetSettings()[settingName] = {
        point = point,
        relativePoint = relativePoint,
        xOffset = xOffset,
        yOffset = yOffset,
    }
end

local function SetDefaultWindowPosition(window, xOffset, yOffset)
    window:ClearAllPoints()
    window:SetPoint("CENTER", UIParent, "CENTER", xOffset, yOffset)
end

local function LoadWindowPosition(window, settingName, xOffset, yOffset)
    local position = GetSettings()[settingName]

    if not position then
        SetDefaultWindowPosition(window, xOffset, yOffset)
        return
    end

    window:ClearAllPoints()
    window:SetPoint(
        position.point or "CENTER",
        UIParent,
        position.relativePoint or "CENTER",
        position.xOffset or xOffset,
        position.yOffset or yOffset
    )
end

feedWindow:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

feedWindow:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveWindowPosition(self, "feedWindowPosition")
end)

mendWindow:SetScript("OnDragStart", function(self)
    self:StartMoving()
end)

mendWindow:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    SaveWindowPosition(self, "mendWindowPosition")
end)

local function ResetFeedWindowPosition()
    GetSettings().feedWindowPosition = nil
    SetDefaultWindowPosition(feedWindow, 0, -180)
end

local function ResetMendWindowPosition()
    GetSettings().mendWindowPosition = nil
    SetDefaultWindowPosition(mendWindow, 0, -240)
end

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

    if UnitAffectingCombat("player") or UnitAffectingCombat("pet") then
        ResetHappinessWarningState()
        return
    end

    if not GetPetHappiness then
        return
    end

    local happiness = GetPetHappiness()

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

local function GetPetAuraByName(auraName, allowRankSuffix)
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

        local matchesAura = name == auraName

        if allowRankSuffix and type(name) == "string" then
            matchesAura = string.find(name, "^" .. auraName) ~= nil
        end

        if matchesAura then
            return icon, duration, expirationTime
        end
    end

    return nil
end

local function UpdateBuffTimerWindow(window, auraName, allowRankSuffix)
    local icon, duration, expirationTime = GetPetAuraByName(
        auraName,
        allowRankSuffix
    )

    if not icon then
        window:Hide()
        return
    end

    window.icon:SetTexture(icon)

    local remainingTime = 0

    if expirationTime and expirationTime > 0 then
        remainingTime = math.max(0, math.ceil(expirationTime - GetTime()))
    elseif duration and duration > 0 then
        remainingTime = math.ceil(duration)
    end

    if remainingTime > 0 then
        window.timer:SetText(
            string.format("%d seconds remaining", remainingTime)
        )
    else
        window.timer:SetText("Active")
    end

    window:Show()
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
optionsPanel.subtitle:SetPoint(
    "TOPLEFT",
    optionsPanel.title,
    "BOTTOMLEFT",
    0,
    -8
)
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

optionsPanel.resetFeedButton = CreateFrame(
    "Button",
    "BeastCareResetFeedWindowButton",
    optionsPanel,
    "UIPanelButtonTemplate"
)
optionsPanel.resetFeedButton:SetSize(260, 24)
optionsPanel.resetFeedButton:SetPoint(
    "TOPLEFT",
    optionsPanel.intervalSlider,
    "BOTTOMLEFT",
    0,
    -35
)
optionsPanel.resetFeedButton:SetText(
    "Reset Feed Pet Effect Window Position"
)

optionsPanel.resetMendButton = CreateFrame(
    "Button",
    "BeastCareResetMendWindowButton",
    optionsPanel,
    "UIPanelButtonTemplate"
)
optionsPanel.resetMendButton:SetSize(260, 24)
optionsPanel.resetMendButton:SetPoint(
    "TOPLEFT",
    optionsPanel.resetFeedButton,
    "BOTTOMLEFT",
    0,
    -8
)
optionsPanel.resetMendButton:SetText("Reset Mend Pet Window Position")

optionsPanel.helpText = optionsPanel:CreateFontString(
    nil,
    "ARTWORK",
    "GameFontHighlightSmall"
)
optionsPanel.helpText:SetPoint(
    "TOPLEFT",
    optionsPanel.resetMendButton,
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

optionsPanel.resetFeedButton:SetScript("OnClick", function()
    ResetFeedWindowPosition()
    PrintMessage("Feed Pet Effect window position reset.")
end)

optionsPanel.resetMendButton:SetScript("OnClick", function()
    ResetMendWindowPosition()
    PrintMessage("Mend Pet window position reset.")
end)

optionsPanel:SetScript("OnShow", function()
    UpdateOptionsPanel()
end)

local function RegisterOptionsPanel()
    if Settings and Settings.RegisterCanvasLayoutCategory then
        local category = Settings.RegisterCanvasLayoutCategory(
            optionsPanel,
            ADDON_NAME
        )

        Settings.RegisterAddOnCategory(category)
        optionsPanel.category = category
        return
    end

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
local elapsedSinceBuffCheck = 0

frame:SetScript("OnUpdate", function(_, elapsed)
    elapsedSinceLastCheck = elapsedSinceLastCheck + elapsed
    elapsedSinceBuffCheck = elapsedSinceBuffCheck + elapsed

    if elapsedSinceLastCheck >= 1 then
        elapsedSinceLastCheck = 0

        CheckPetHappiness()
        CheckPetLoyalty()
    end

    if elapsedSinceBuffCheck >= 0.25 then
        elapsedSinceBuffCheck = 0

        UpdateBuffTimerWindow(
            feedWindow,
            "Feed Pet Effect",
            false
        )

        UpdateBuffTimerWindow(
            mendWindow,
            "Mend Pet",
            true
        )
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
            ResetFeedWindowPosition()
            PrintMessage("Feed Pet Effect window position reset.")
            return
        end

        PrintMessage(
            "Use |cffffffff/bc feedwindow reset|r to reset the window position."
        )
        return
    end

    if command == "mendwindow" then
        if argument == "reset" then
            ResetMendWindowPosition()
            PrintMessage("Mend Pet window position reset.")
            return
        end

        PrintMessage(
            "Use |cffffffff/bc mendwindow reset|r to reset the window position."
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

        LoadWindowPosition(
            feedWindow,
            "feedWindowPosition",
            0,
            -180
        )

        LoadWindowPosition(
            mendWindow,
            "mendWindowPosition",
            0,
            -240
        )

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