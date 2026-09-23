local _, _, _, interfaceVersion = GetBuildInfo()

if interfaceVersion ~= 16001 then
    return
end

BeastCare = BeastCare or {}

function BeastCare.GetPetHappiness()
    if C_PetInfo and type(C_PetInfo.GetPetHappiness) == "function" then
        return C_PetInfo.GetPetHappiness()
    end

    return nil
end

function BeastCare.GetPetLoyalty()
    if C_PetInfo and type(C_PetInfo.GetPetLoyalty) == "function" then
        return C_PetInfo.GetPetLoyalty()
    end

    return nil
end

function BeastCare.GetPetFoodTypes()
    if C_PetInfo and type(C_PetInfo.GetPetFoodTypes) == "function" then
        return C_PetInfo.GetPetFoodTypes()
    end

    return nil
end

function BeastCare.GetPetTrainingPoints()
    if C_PetInfo
        and type(C_PetInfo.GetPetTrainingPoints) == "function"
    then
        local spentPoints, availablePoints =
            C_PetInfo.GetPetTrainingPoints()

        return availablePoints, spentPoints
    end

    return nil, nil
end

-- Finds a helpful pet aura through the public WoW Forever aura API.
-- Tested with Feed Pet Effect, spell ID 1539.
function BeastCare.GetPetAuraByName(auraName, allowRankSuffix)
    if not UnitExists("pet") then
        return nil
    end

    if not C_UnitAuras
        or type(C_UnitAuras.GetAuraDataByIndex) ~= "function"
    then
        return nil
    end

    for index = 1, 40 do
        local success, auraData = pcall(
            C_UnitAuras.GetAuraDataByIndex,
            "pet",
            index,
            "HELPFUL"
        )

        if not success then
            return nil
        end

        if auraData == nil then
            break
        end

        if type(auraData) == "table" then
            local auraDataName = auraData.name
            local matchesAura = auraDataName == auraName

            if allowRankSuffix
                and type(auraDataName) == "string"
            then
                matchesAura = string.find(
                    auraDataName,
                    "^" .. auraName
                ) ~= nil
            end

            if matchesAura then
                return
                    auraData.icon,
                    auraData.duration,
                    auraData.expirationTime
            end
        end
    end

    return nil
end

DEFAULT_CHAT_FRAME:AddMessage(
    "|cff33ff99BeastCare:|r WoW Forever pet API module loaded."
)