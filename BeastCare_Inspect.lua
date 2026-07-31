BeastCare = BeastCare or {}

local function PrintInspectMessage(message)
    DEFAULT_CHAT_FRAME:AddMessage(
        string.format("|cff33ff99BeastCare:|r %s", message)
    )
end

local function PrintInspectLine(label, value)
    PrintInspectMessage(string.format(
        "|cff9fc5e8%s:|r |cffffffff%s|r",
        label,
        value
    ))
end

function BeastCare.InspectTargetPet()
    if not UnitExists("target") then
        PrintInspectMessage("Select another player's pet first.")
        return
    end

    if UnitIsUnit("target", "pet") then
        PrintInspectMessage(
            "This is your active pet. Use |cffffffff/bc status|r instead."
        )
        return
    end

    if not UnitIsOtherPlayersPet("target") then
        PrintInspectMessage("Select another player's pet first.")
        return
    end

    local petName = UnitName("target") or "Unknown"
    local petFamily = UnitCreatureFamily("target") or "Unknown"

    PrintInspectMessage("|cff00aaffPet Inspect|r")
    PrintInspectLine("Name", petName)
    PrintInspectLine("Family", petFamily)
end