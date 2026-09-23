local _, ArmoryUtils = ...
local ITEM_LEVEL_ABBR = ITEM_LEVEL_ABBR or "ilvl"
local AUGlowAlpha = 0.75
local AUClassIDs = {
    [2] = true,
    [3] = true,
    [4] = true,
    [6] = true,
    [8] = true
}

local AUSubClassIDs15 = {
    [5] = true,
    [6] = true
}

local AUArmorSlots = {
    [1] = true,
    [3] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true
}

local AUClassArmor = {
    ["WARRIOR"] = 4,
    ["PALADIN"] = 4,
    ["DEATHKNIGHT"] = 4,
    ["HUNTER"] = 3,
    ["SHAMAN"] = 3,
    ["EVOKER"] = 3,
    ["ROGUE"] = 2,
    ["DRUID"] = 2,
    ["MONK"] = 2,
    ["DEMONHUNTER"] = 2,
    ["PRIEST"] = 1,
    ["MAGE"] = 1,
    ["WARLOCK"] = 1
}

local AUClassArmorBelow40 = {
    ["WARRIOR"] = 3,
    ["PALADIN"] = 3,
    ["HUNTER"] = 2,
    ["SHAMAN"] = 2
}

local function GetExpectedArmor(unit, classFile)
    local expected = AUClassArmor[classFile]
    if expected == nil then return nil end
    if ArmoryUtils:GetWoWBuild() == "RETAIL" and not ArmoryUtils:IsForever() then return expected end
    local below40 = AUClassArmorBelow40[classFile]
    if below40 == nil then return expected end
    local level = UnitLevel(unit)
    if level == nil or ArmoryUtils:IsSecret(level) then return nil end
    if level > 0 and level < 40 then return below40 end
    return expected
end

local function GetArmorName(subClassID)
    local getInfo = C_Item and C_Item.GetItemSubClassInfo or GetItemSubClassInfo
    if getInfo == nil then return tostring(subClassID) end
    return getInfo(4, subClassID) or tostring(subClassID)
end

local function GetWrongArmorText(unit, slotId, link)
    if not AUArmorSlots[slotId] then return nil end
    if not ArmoryUtils:DBGV("WRONGARMORTYPE", true) then return nil end
    local _, classFile = UnitClass(unit)
    if classFile == nil or ArmoryUtils:IsSecret(classFile) then return nil end
    local expected = GetExpectedArmor(unit, classFile)
    if expected == nil then return nil end
    local getInstant = C_Item and C_Item.GetItemInfoInstant or GetItemInfoInstant
    if getInstant == nil then return nil end
    local _, _, _, _, _, classID, subClassID = getInstant(link)
    if classID ~= 4 or subClassID == nil or subClassID < 1 or subClassID >= expected then return nil end
    return format(ArmoryUtils:Trans("LID_WRONGARMORTYPETT"), GetArmorName(subClassID), GetArmorName(expected))
end

local STAT_STR = "ITEM_MOD_STRENGTH_SHORT"
local STAT_AGI = "ITEM_MOD_AGILITY_SHORT"
local STAT_INT = "ITEM_MOD_INTELLECT_SHORT"
local AUPrimaryStatOrder = {STAT_STR, STAT_AGI, STAT_INT}
local AUPrimaryStatKeys = {}
if LE_UNIT_STAT_STRENGTH and LE_UNIT_STAT_AGILITY and LE_UNIT_STAT_INTELLECT then
    AUPrimaryStatKeys[LE_UNIT_STAT_STRENGTH] = STAT_STR
    AUPrimaryStatKeys[LE_UNIT_STAT_AGILITY] = STAT_AGI
    AUPrimaryStatKeys[LE_UNIT_STAT_INTELLECT] = STAT_INT
end

local AUSpecPrimaryStat = {
    [250] = STAT_STR,
    [251] = STAT_STR,
    [252] = STAT_STR,
    [66] = STAT_STR,
    [70] = STAT_STR,
    [71] = STAT_STR,
    [72] = STAT_STR,
    [73] = STAT_STR,
    [577] = STAT_AGI,
    [581] = STAT_AGI,
    [103] = STAT_AGI,
    [104] = STAT_AGI,
    [253] = STAT_AGI,
    [254] = STAT_AGI,
    [255] = STAT_AGI,
    [268] = STAT_AGI,
    [269] = STAT_AGI,
    [259] = STAT_AGI,
    [260] = STAT_AGI,
    [261] = STAT_AGI,
    [263] = STAT_AGI,
    [1480] = STAT_INT,
    [102] = STAT_INT,
    [105] = STAT_INT,
    [1467] = STAT_INT,
    [1468] = STAT_INT,
    [1473] = STAT_INT,
    [62] = STAT_INT,
    [63] = STAT_INT,
    [64] = STAT_INT,
    [270] = STAT_INT,
    [65] = STAT_INT,
    [256] = STAT_INT,
    [257] = STAT_INT,
    [258] = STAT_INT,
    [262] = STAT_INT,
    [264] = STAT_INT,
    [265] = STAT_INT,
    [266] = STAT_INT,
    [267] = STAT_INT
}

local function GetSpecStatKey(unit)
    if C_SpecializationInfo == nil then return nil end
    if unit == "player" then
        if C_SpecializationInfo.GetSpecialization == nil or C_SpecializationInfo.GetSpecializationInfo == nil then return nil end
        local spec = C_SpecializationInfo.GetSpecialization()
        if spec == nil then return nil end
        local primaryStat = select(6, C_SpecializationInfo.GetSpecializationInfo(spec, false, false, nil, UnitSex("player")))
        if primaryStat == nil then return nil end
        return AUPrimaryStatKeys[primaryStat]
    end

    local getInspectSpec = C_SpecializationInfo.GetInspectSpecialization or GetInspectSpecialization
    if getInspectSpec == nil then return nil end
    local specID = getInspectSpec(unit)
    if specID == nil or ArmoryUtils:IsSecret(specID) then return nil end
    return AUSpecPrimaryStat[specID]
end

local function GetWrongStatText(unit, slotId, link)
    if ArmoryUtils:GetWoWBuild() ~= "RETAIL" or ArmoryUtils:IsForever() or slotId == 4 or slotId == 19 then return nil end
    if not ArmoryUtils:DBGV("WRONGPRIMARYSTAT", true) then return nil end
    if type(link) ~= "string" or C_Item == nil or C_Item.GetItemStats == nil then return nil end
    local specKey = GetSpecStatKey(unit)
    if specKey == nil then return nil end
    local stats = C_Item.GetItemStats(link)
    if stats == nil or stats[specKey] then return nil end
    local itemKey = nil
    for _, key in ipairs(AUPrimaryStatOrder) do
        if stats[key] then
            itemKey = key
            break
        end
    end

    if itemKey == nil then return nil end
    return format(ArmoryUtils:Trans("LID_WRONGPRIMARYSTATTT"), _G[itemKey] or itemKey, _G[specKey] or specKey)
end

local slotbry = 0
local AUCharSlots = {"AmmoSlot", "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", "WaistSlot", "LegsSlot", "FeetSlot", "WristSlot", "HandsSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "BackSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "TabardSlot",}
local AUCharSlotsLeft = {}
for i, x in pairs({"HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot", "ShirtSlot", "TabardSlot", "WristSlot", "SecondaryHandSlot"}) do
    AUCharSlotsLeft["Character" .. x] = true
    AUCharSlotsLeft["Inspect" .. x] = true
end

local AUCharSlotsRight = {}
for i, x in pairs({"HandsSlot", "WaistSlot", "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "MainHandSlot"}) do
    AUCharSlotsRight["Character" .. x] = true
    AUCharSlotsRight["Inspect" .. x] = true
end

local lastInspectGUID = nil
local fontSizeGems = 12
local fontSizeEnchants = 8
local PDThink = CreateFrame("FRAME")
local AUILVL = nil
local emptySockets = {}
for name, v in pairs(_G) do
    if name and type(name) == "string" and string.find(name, "EMPTY_SOCKET_", 1, true) and not tContains(emptySockets, v) then tinsert(emptySockets, v) end
end

local lastInspect = 0
local ilvlTexts = {}
function ArmoryUtils:AddIlvlText(text)
    tinsert(ilvlTexts, text)
end

local sideTexts = {}
function ArmoryUtils:AddSideText(text)
    tinsert(sideTexts, text)
end

function ArmoryUtils:UpdateFonts()
    if AUTAB["ILVLFONTSIZE"] == nil then AUTAB["ILVLFONTSIZE"] = 11 end
    if AUTAB["SIDEFONTSIZE"] == nil then AUTAB["SIDEFONTSIZE"] = 11 end
    local fs1 = AUTAB["ILVLFONTSIZE"]
    for i, text in pairs(ilvlTexts) do
        local font, _, flags = text:GetFont()
        text:SetFont(font, fs1, flags)
    end

    local fs2 = AUTAB["SIDEFONTSIZE"]
    for i, text in pairs(sideTexts) do
        local font, _, flags = text:GetFont()
        text:SetFont(font, fs2, flags)
    end
end

function ArmoryUtils:AddIlvl(prefix, SLOT, i)
    prefix = prefix or ""
    if SLOT and SLOT.auinfo == nil then
        local name = ""
        if SLOT.GetName then name = ArmoryUtils:GetName(SLOT) or "UID" end
        SLOT.auinfo = CreateFrame("FRAME", name .. ".auinfo", SLOT)
        SLOT.auinfo:SetSize(SLOT:GetSize())
        SLOT.auinfo:SetPoint("CENTER", SLOT, "CENTER", 0, 0)
        SLOT.auinfo:SetFrameLevel(200)
        SLOT.auinfo:EnableMouse(false)
        SLOT.autext = SLOT.auinfo:CreateFontString("SLOT.autext", "OVERLAY")
        SLOT.autext:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        SLOT.autext:SetShadowOffset(1, -1)
        SLOT.autexth = SLOT.auinfo:CreateFontString("SLOT.autexth", "OVERLAY")
        SLOT.autexth:SetFont(STANDARD_TEXT_FONT, 9, "OUTLINE")
        SLOT.autexth:SetShadowOffset(1, -1)
        SLOT.autexte = SLOT.auinfo:CreateFontString("SLOT.autexte", "OVERLAY")
        SLOT.autexte:SetFont(STANDARD_TEXT_FONT, fontSizeEnchants, "OUTLINE")
        SLOT.autexte:SetShadowOffset(1, -1)
        SLOT.autextg = SLOT.auinfo:CreateFontString("SLOT.autextg", "OVERLAY")
        SLOT.autextg:SetFont(STANDARD_TEXT_FONT, fontSizeGems, "OUTLINE")
        SLOT.autextg:SetShadowOffset(1, -1)
        SLOT.autextu = SLOT.auinfo:CreateFontString("SLOT.autextu", "OVERLAY")
        SLOT.autextu:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        SLOT.autextu:SetShadowOffset(1, -1)
        SLOT.auborder = SLOT.auinfo:CreateTexture("SLOT.auborder", "OVERLAY")
        SLOT.auborder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        SLOT.auborder:SetBlendMode("ADD")
        SLOT.auborder:SetAlpha(1)
        ArmoryUtils:AddIlvlText(SLOT.autext)
        ArmoryUtils:AddSideText(SLOT.autexte)
        ArmoryUtils:AddSideText(SLOT.autextg)
        local px = 8
        slotbry = 3
        SLOT.autextu:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, 0)
        if AUCharSlotsLeft[name] then
            if i == 17 or i == 18 then
                SLOT.autexte:SetPoint("BOTTOMLEFT", SLOT.auinfo, "BOTTOMRIGHT", px, slotbry)
            else
                SLOT.autexte:SetPoint("TOPLEFT", SLOT.auinfo, "TOPRIGHT", px, -slotbry)
                SLOT.autextg:SetPoint("BOTTOMLEFT", SLOT.auinfo, "BOTTOMRIGHT", px, slotbry)
            end
        elseif AUCharSlotsRight[name] then
            if i == 17 or i == 18 then
                SLOT.autexte:SetPoint("BOTTOMRIGHT", SLOT.auinfo, "BOTTOMLEFT", -px, slotbry)
            else
                SLOT.autexte:SetPoint("TOPRIGHT", SLOT.auinfo, "TOPLEFT", -px, -slotbry)
                SLOT.autextg:SetPoint("BOTTOMRIGHT", SLOT.auinfo, "BOTTOMLEFT", -px, slotbry)
            end
        else
            SLOT.autexte:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, 0)
            SLOT.autextg:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, 0)
        end

        SLOT.autext:SetPoint("TOP", SLOT.auinfo, "TOP", 0, 0)
        SLOT.autexth:SetPoint("BOTTOM", SLOT.auinfo, "BOTTOM", 0, 0)
        local NormalTexture = SLOT.NormalTexture or _G[name .. "NormalTexture"]
        if NormalTexture then
            local sw, sh = NormalTexture:GetSize()
            SLOT.auborder:SetWidth(sw)
            SLOT.auborder:SetHeight(sh)
        end

        SLOT.auborder:SetPoint("CENTER")
        SLOT.auarmor = SLOT.auinfo:CreateTexture("SLOT.auarmor", "OVERLAY")
        SLOT.auarmor:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
        SLOT.auarmor:SetVertexColor(1, 0.2, 0.2, 1)
        SLOT.auarmor:SetSize(14, 14)
        SLOT.auarmor:SetPoint("TOPRIGHT", SLOT.auinfo, "TOPRIGHT", 3, 3)
        SLOT.auarmor:Hide()
    end
end

function ArmoryUtils:GetAUILVL()
    return AUILVL
end

function ArmoryUtils:PDUpdateDurability()
    if ArmoryUtils:DBGV("ITEMLEVELSYSTEM", true) then
        for i, slot in pairs(AUCharSlots) do
            i = i - 1
            local SLOT = _G["Character" .. slot]
            if SLOT and GetInventoryItemLink and SLOT.GetID and SLOT:GetID() then
                local slotId = SLOT:GetID()
                local Link = GetInventoryItemLink("player", slotId) or GetInventoryItemID("player", slotId)
                if Link ~= nil then
                    local current, maximum = GetInventoryItemDurability(i)
                    if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and current and maximum then
                        local per = current / maximum
                        if current == maximum then
                            SLOT.autexth:SetTextColor(0, 1, 0, 1)
                        elseif per == 0.0 then
                            SLOT.autexth:SetTextColor(0, 0, 0, 1)
                        elseif per < 0.1 then
                            SLOT.autexth:SetTextColor(1, 0, 0, 1)
                        elseif per < 0.3 then
                            SLOT.autexth:SetTextColor(1, 0.65, 0, 1)
                        elseif per < 1 then
                            SLOT.autexth:SetTextColor(1, 1, 0, 1)
                        end

                        if current ~= maximum then
                            SLOT.autexth:SetText(string.format("%0.0f", current / maximum * 100) .. "%")
                        else
                            SLOT.autexth:SetText("")
                        end
                    else
                        SLOT.autexth:SetText("")
                    end
                else
                    SLOT.autexth:SetText("")
                end
            end
        end
    end
end

local enchantSlots = {}
enchantSlots["RETAIL"] = {}
enchantSlots["RETAIL"][1] = true
enchantSlots["RETAIL"][3] = true
enchantSlots["RETAIL"][5] = true
enchantSlots["RETAIL"][7] = true
enchantSlots["RETAIL"][8] = true
enchantSlots["RETAIL"][11] = true
enchantSlots["RETAIL"][12] = true
enchantSlots["RETAIL"][16] = true
enchantSlots["RETAIL"][17] = true
enchantSlots["CAMELOT"] = {}
enchantSlots["CAMELOT"][2] = true
enchantSlots["CAMELOT"][5] = true
enchantSlots["CAMELOT"][8] = true
enchantSlots["CAMELOT"][9] = true
enchantSlots["CAMELOT"][10] = true
enchantSlots["CAMELOT"][15] = true
enchantSlots["CAMELOT"][16] = true
enchantSlots["CAMELOT"][17] = true
local function GetEnchantSlots()
    if ArmoryUtils:IsForever() then return enchantSlots["CAMELOT"] end
    return enchantSlots[ArmoryUtils:GetWoWBuild()]
end

function ArmoryUtils:IsOffhandAWeapon(unit, slotId)
    local itemID = GetInventoryItemID(unit, slotId)
    if not itemID then return false end
    local _, _, _, _, _, _, _, _, invType = C_Item.GetItemInfo(itemID)
    return invType and invType == "INVTYPE_WEAPON"
end

local function ShortenEnchant(text)
    if text == nil then return text end
    local short = string.match(text, "%-%s+(.+)$")
    if short and short ~= "" then return short end
    return text
end

local fixedInspect = true
local characterIlvlHooked = false
function ArmoryUtils:UpdateChar(frame, unit, prefix, func)
    if unit == nil then return end
    if prefix == "Inspect" then
        if not CanInspect(InspectFrame.unit) then return end
        if not fixedInspect then
            fixedInspect = true
            -- Some Addons Clear Inspect when the InspectFrame is open! it will make it blank
            ClearInspectPlayer = function() end
            local originalNotifyInspect = NotifyInspect
            NotifyInspect = function(inspectUnit)
                if InspectFrame and InspectFrame:IsShown() then -- only allow when its closed
                    return
                end

                originalNotifyInspect(inspectUnit)
            end
        end
    end

    if ArmoryUtils:DBGV("ITEMLEVELSYSTEM", true) then
        local count = 0
        local sum = 0
        for i, slot in pairs(AUCharSlots) do
            i = i - 1
            local SLOT = _G[prefix .. slot]
            if SLOT and GetInventoryItemLink and SLOT.GetID and SLOT:GetID() then
                local slotId = SLOT:GetID()
                local Link = GetInventoryItemLink(unit, slotId) or GetInventoryItemID(unit, slotId)
                if Link ~= nil then
                    SLOT.auarmortext = GetWrongArmorText(unit, slotId, Link)
                    SLOT.austattext = GetWrongStatText(unit, slotId, Link)
                    SLOT.auarmor:SetShown(SLOT.auarmortext ~= nil or SLOT.austattext ~= nil)
                    local _, _, rarity, _, _, _, _, _, itemEquipLoc = ArmoryUtils:GetItemInfo(Link)
                    local ilvl = nil
                    if unit == "player" then
                        local itemLoc = ItemLocation:CreateFromEquipmentSlot(slotId)
                        if itemLoc and itemLoc:IsValid() then ilvl = C_Item.GetCurrentItemLevel(itemLoc) end
                    else
                        ilvl, _, _ = ArmoryUtils:GetDetailedItemLevelInfo(Link)
                    end

                    local color = ITEM_QUALITY_COLORS[rarity]
                    if C_TooltipInfo then
                        local tooltipData = C_TooltipInfo.GetInventoryItem(unit, slotId)
                        local foundEnchant = false
                        if tooltipData ~= nil then
                            local gems = {}
                            for gid = 1, 4 do
                                local gemLink = select(2, ArmoryUtils:GetItemGem(Link, gid))
                                if gemLink then tinsert(gems, gemLink) end
                            end

                            for x, line in pairs(tooltipData.lines) do
                                local text = line.leftText
                                local enchantString = string.match(text, ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.*)"))
                                if enchantString ~= nil then
                                    foundEnchant = true
                                    if string.find(enchantString, "|A:") then
                                        local itemEnchant, itemEnchantAtlas = string.match(enchantString, "(.*)|A:(.*):20:20|a")
                                        itemEnchant = ShortenEnchant(itemEnchant)
                                        if ArmoryUtils:DBGV("ENCHANTONLYICON", true) then
                                            SLOT.autexte:SetText("|cFF00FF00|A:" .. itemEnchantAtlas .. ":16:16:0:0|a")
                                        elseif ArmoryUtils:DBGV("ITEMLEVELSYSTEMSIDEWAYS", true) then
                                            SLOT.autexte:SetText("|cFF00FF00|A:" .. itemEnchantAtlas .. ":16:16:0:0|a " .. string.sub(itemEnchant, 1, 12) .. "..." .. "|r")
                                        else
                                            SLOT.autexte:SetText("|cFF00FF00|A:" .. itemEnchantAtlas .. ":24:24:0:0|a")
                                        end
                                    else
                                        local itemEnchant = ShortenEnchant(enchantString)
                                        SLOT.autexte:SetText("|cFF00FF00" .. itemEnchant .. "|r")
                                    end
                                end

                                for index, name in pairs(emptySockets) do
                                    if string.find(text, name) then
                                        local gemString = string.match(text, name:gsub("%%s", "(.*)"))
                                        tinsert(gems, gemString)
                                    end
                                end
                            end

                            if #gems > 0 then
                                local text = ""
                                for x, gem in pairs(gems) do
                                    if x > 1 then text = text .. "  " end
                                    local gemName, _, _, _, _, _, _, _, _, gemIcon, _, gemClassID = ArmoryUtils:GetItemInfo(gem)
                                    if gemName == nil then
                                        text = text .. "|T" .. "Interface/ItemsocketingFrame/UI-EmptySocket-Prismatic" .. ":" .. fontSizeGems .. ":" .. fontSizeGems .. ":0:0|t"
                                    else
                                        text = text .. "|T" .. gemIcon .. ":" .. fontSizeGems .. ":" .. fontSizeGems .. ":0:0|t|A:" .. "Professions-ChatIcon-Quality-Tier" .. gemClassID .. ":" .. fontSizeGems .. ":" .. fontSizeGems .. ":0:0|a"
                                    end
                                end

                                SLOT.autextg:SetText(text)
                            else
                                SLOT.autextg:SetText("")
                            end
                        end

                        if not foundEnchant then
                            local slots = GetEnchantSlots()
                            if slots then
                                if SLOT:GetID() and (SLOT:GetID() ~= 17 or ArmoryUtils:IsForever() or ArmoryUtils:IsOffhandAWeapon(unit, 17)) and slots[SLOT:GetID()] then
                                    SLOT.autexte:SetText("|T130775:0:0:0:0|t")
                                else
                                    SLOT.autexte:SetText("")
                                end
                            else
                                SLOT.autexte:SetText("")
                            end
                        end
                    else
                        SLOT.autexte:SetText("")
                        SLOT.autextg:SetText("")
                    end

                    if color then
                        if C_Item and C_Item.GetItemUpgradeInfo then
                            local upgrade = C_Item.GetItemUpgradeInfo(Link)
                            if upgrade and upgrade.maxLevel > 0 and (upgrade.currentLevel ~= upgrade.maxLevel or not ArmoryUtils:DBGV("HIDEMAXUPGRADE", false)) then
                                SLOT.autextu:SetText(string.format("%s%s/%s", color.hex, upgrade.currentLevel, upgrade.maxLevel))
                            else
                                SLOT.autextu:SetText("")
                            end
                        end

                        if ilvl then
                            if slot == "AmmoSlot" then
                                local COUNT = _G["Character" .. slot .. "Count"]
                                if COUNT.hooked == nil then
                                    COUNT.hooked = true
                                    COUNT:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
                                    SLOT.maxDisplayCount = 999999
                                    COUNT:SetText(COUNT:GetText())
                                end
                            end

                            -- ignore: shirt, tabard, ammo
                            if i ~= 4 and i ~= 19 and i ~= 20 and ilvl and ilvl > 1 then
                                count = count + 1
                                sum = sum + ilvl
                            end

                            if i == 16 and itemEquipLoc and itemEquipLoc == "INVTYPE_2HWEAPON" then sum = sum + ilvl end
                            if ArmoryUtils:DBGV("ITEMLEVEL" .. unit, true) then
                                if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and ArmoryUtils:DBGV("ITEMLEVELNUMBER", true) and ilvl and ilvl > 1 then SLOT.autext:SetText(color.hex .. ilvl) end
                                local alpha = AUGlowAlpha
                                if color.r == 1 and color.g == 1 and color.b == 1 then alpha = alpha - 0.2 end
                                if rarity and rarity > 1 and ArmoryUtils:DBGV("ITEMLEVELBORDER", true) then
                                    SLOT.auborder:SetVertexColor(color.r, color.g, color.b, alpha)
                                else
                                    SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                                end
                            else
                                SLOT.autext:SetText("")
                                SLOT.autexte:SetText("")
                                SLOT.autextg:SetText("")
                                SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                            end
                        end
                    end
                else
                    SLOT.autext:SetText("")
                    SLOT.autexte:SetText("")
                    SLOT.autextg:SetText("")
                    SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                    SLOT.auarmortext = nil
                    SLOT.austattext = nil
                    SLOT.auarmor:Hide()
                end
            end
        end

        local statsPaneValue = nil
        if prefix == "Character" and CharacterStatsPane and CharacterStatsPane.ItemLevelFrame and CharacterStatsPane.ItemLevelFrame.Value then
            statsPaneValue = CharacterStatsPane.ItemLevelFrame.Value
            if frame.ilvl then frame.ilvl:SetText("") end
        end

        if statsPaneValue == nil and frame.ilvl == nil and ArmoryUtils:GetName(frame) then
            local mainFrame = _G[prefix .. "Frame"] or frame
            local anchor = _G[prefix .. "NameFrame"]
            local offset = 22
            if anchor == nil and mainFrame.TitleContainer then
                anchor = mainFrame.TitleContainer
                offset = 21
            end

            if anchor == nil then
                anchor = mainFrame
                offset = 4
            end

            local holder = CreateFrame("FRAME", nil, anchor)
            holder:SetSize(1, 1)
            holder:SetFrameLevel(anchor:GetFrameLevel() + 10)
            holder:SetPoint("BOTTOM", anchor, "TOP", 0, offset)
            frame.ilvl = holder:CreateFontString("ArmoryUtils.ilvl", "OVERLAY")
            frame.ilvl:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
            frame.ilvl:SetPoint("BOTTOM", holder, "BOTTOM", 0, 0)
            frame.ilvl:SetText("")
        end

        if count > 0 then
            local max = 17
            if ArmoryUtils:GetWoWBuild() == "RETAIL" then max = 16 end
            AUILVL = string.format("%0.2f", sum / max)
            if ArmoryUtils:GetAUILVL() then
                if statsPaneValue then
                    if characterIlvlHooked == false then
                        characterIlvlHooked = true
                        local setText = false
                        hooksecurefunc(statsPaneValue, "SetText", function(sel)
                            if setText then return end
                            setText = true
                            sel:SetText(ArmoryUtils:GetAUILVL())
                            setText = false
                        end)
                    end

                    statsPaneValue:SetText(ArmoryUtils:GetAUILVL())
                elseif frame.ilvl then
                    frame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": |r" .. ArmoryUtils:GetAUILVL())
                end
            end

            if unit ~= "player" then lastInspectGUID = nil end
        elseif statsPaneValue then
            if ArmoryUtils:GetAUILVL() then statsPaneValue:SetText(ArmoryUtils:GetAUILVL()) end
        elseif frame.ilvl then
            frame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": " .. "|cFFFF0000?")
        end
    end
end

function ArmoryUtils:PDUpdateItemInfos()
    ArmoryUtils:UpdateChar(PaperDollFrame, "player", "Character", ArmoryUtils.PDUpdateItemInfos)
end

local tab = {}
for i = 1, 20 do
    tinsert(tab, "ContainerFrame" .. i)
end

local bagSetups = {}
local bagUpdatePending = false
function ArmoryUtils:UpdateBagsIlvl(event)
    if ContainerFrameCombinedBags then
        if bagSetups[ContainerFrameCombinedBags] == nil then
            bagSetups[ContainerFrameCombinedBags] = true
            ContainerFrameCombinedBags:HookScript("OnShow", function(sel) ArmoryUtils:UpdateBag(ContainerFrameCombinedBags) end)
        end

        ArmoryUtils:UpdateBag(ContainerFrameCombinedBags)
    end

    for x, bagName in pairs(tab) do
        local bag = _G[bagName]
        if bag then
            if bagSetups[bag] == nil then
                bagSetups[bag] = true
                bag:HookScript("OnShow", function(sel) ArmoryUtils:UpdateBag(bag, x - 1) end)
            end

            ArmoryUtils:UpdateBag(bag, x - 1)
        end
    end
end

function ArmoryUtils:UpdateBagItem(bagID, size, SLOT, i)
    if SLOT then
        local slotID = i
        local slotLink = ArmoryUtils:GetContainerItemLink(bagID, slotID)
        ArmoryUtils:AddIlvl(nil, SLOT, slotID)
        if slotLink then
            local _, _, rarity, _, _, _, _, _, _, _, _, classID, subclassID = ArmoryUtils:GetItemInfo(slotLink)
            local ilvl, _, _ = ArmoryUtils:GetDetailedItemLevelInfo(slotLink)
            local color = ITEM_QUALITY_COLORS[rarity]
            if ilvl and color then
                if ArmoryUtils:DBGV("ITEMLEVEL", true) then
                    if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and ArmoryUtils:DBGV("ITEMLEVELNUMBER", true) and (AUClassIDs[classID] or (classID == 15 and AUSubClassIDs15[subclassID])) and ilvl and ilvl > 1 then
                        SLOT.autext:SetText(color.hex .. ilvl)
                    else
                        SLOT.autext:SetText("")
                    end

                    local alpha = AUGlowAlpha
                    if color.r == 1 and color.g == 1 and color.b == 1 then alpha = alpha - 0.2 end
                    if rarity and rarity > 1 and ArmoryUtils:DBGV("ITEMLEVELBORDER", true) then
                        SLOT.auborder:SetVertexColor(color.r, color.g, color.b, alpha)
                    else
                        SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                    end
                else
                    SLOT.autext:SetText("")
                    SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                end
            else
                SLOT.autext:SetText("")
                SLOT.auborder:SetVertexColor(1, 1, 1, 0)
            end
        else
            SLOT.autext:SetText("")
            SLOT.auborder:SetVertexColor(1, 1, 1, 0)
        end
    end
end

function ArmoryUtils:UpdateBag(bag, id)
    local name = ArmoryUtils:GetName(bag)
    local bagID = bag:GetID()
    if GetCVarBool("combinedBags") then
        if id and id < 5 then return end
        bagID = bag:GetBagID()
    end

    local size = ArmoryUtils:GetContainerNumSlots(bagID)
    if bag.Items then
        for i, itemButton in bag:EnumerateValidItems() do
            if itemButton then ArmoryUtils:UpdateBagItem(itemButton:GetBagID(), size, itemButton, itemButton:GetID()) end
        end
    else
        for i = 1, size do
            local SLOT = _G[name .. "Item" .. i]
            if GetCVarBool("combinedBags") then SLOT = _G[name .. "Item" .. i] end
            ArmoryUtils:UpdateBagItem(bagID, size, SLOT, SLOT:GetID())
        end
    end
end

function ArmoryUtils:CheckInspectSlot(slot)
    if ArmoryUtils:GetWoWBuild() == "RETAIL" then return slot ~= "AmmoSlot" and slot ~= "ShirtSlot" and slot ~= "TabardSlot" and slot ~= "RangedSlot" end
    return slot ~= "AmmoSlot" and slot ~= "ShirtSlot" and slot ~= "TabardSlot"
end

function ArmoryUtils:IFUpdateItemInfos()
    if InspectFrame and InspectFrame.unit then
        ArmoryUtils:UpdateChar(InspectPaperDollFrame, InspectFrame.unit, "Inspect", ArmoryUtils.IFUpdateItemInfos)
    else
        C_Timer.After(0.1, function() ArmoryUtils:IFUpdateItemInfos() end)
    end
end

function ArmoryUtils:WaitForInspectFrame()
    if InspectPaperDollFrame == nil then
        ArmoryUtils:After(0.16, function() ArmoryUtils:WaitForInspectFrame() end, "ArmoryUtils.IFUpdateItemInfos 2")
        return
    end

    IFThink = CreateFrame("FRAME")
    for i, slot in pairs(AUCharSlots) do
        ArmoryUtils:AddIlvl("Inspect", _G["Inspect" .. slot], i)
    end

    local inspect = false
    ArmoryUtils:RegisterEvent(IFThink, "INSPECT_READY")
    ArmoryUtils:OnEvent(IFThink, function(sel, event, guid, ...)
        if inspect then return end
        inspect = true
        pcall(function() ArmoryUtils:IFUpdateItemInfos() end)
        inspect = false
    end, "IFThink")
end

function ArmoryUtils:InitItemLevel()
    if ArmoryUtils:DBGV("ITEMLEVELSYSTEM", true) and PaperDollFrame then
        for i, slot in pairs(AUCharSlots) do
            ArmoryUtils:AddIlvl("Character", _G["Character" .. slot], i)
        end

        if PaperDollFrame then PaperDollFrame:HookScript("OnShow", function() ArmoryUtils:After(0.33, function() ArmoryUtils:PDUpdateItemInfos() end, "PaperDollFrameOnShow") end) end
        local pdUpdatePending = false
        local function PDUpdateSoon(delay, from)
            if pdUpdatePending then return end
            pdUpdatePending = true
            ArmoryUtils:After(delay, function()
                pdUpdatePending = false
                ArmoryUtils:PDUpdateItemInfos()
            end, from)
        end

        ArmoryUtils:RegisterEvent(PDThink, "PLAYER_EQUIPMENT_CHANGED")
        ArmoryUtils:RegisterEvent(PDThink, "UPDATE_INVENTORY_DURABILITY")
        ArmoryUtils:RegisterEvent(PDThink, "UNIT_INVENTORY_CHANGED", "player")
        ArmoryUtils:RegisterEvent(PDThink, "ENCHANT_SPELL_COMPLETED")
        ArmoryUtils:RegisterEvent(PDThink, "SOCKET_INFO_SUCCESS")
        ArmoryUtils:RegisterEvent(PDThink, "SOCKET_INFO_UPDATE")
        ArmoryUtils:RegisterEvent(PDThink, "SOCKET_INFO_CLOSE")
        ArmoryUtils:RegisterEvent(PDThink, "ITEM_CHANGED")
        ArmoryUtils:RegisterEvent(PDThink, "PLAYER_SPECIALIZATION_CHANGED", "player")
        ArmoryUtils:OnEvent(PDThink, function(sel, event, ...)
            if event == "PLAYER_EQUIPMENT_CHANGED" then
                PDUpdateSoon(0.41, "PLAYER_EQUIPMENT_CHANGED")
            elseif event == "ENCHANT_SPELL_COMPLETED" then
                local successful, _ = ...
                if successful then PDUpdateSoon(0.41, "ENCHANT_SPELL_COMPLETED") end
            elseif event == "UNIT_INVENTORY_CHANGED" or event == "ITEM_CHANGED" or event == "PLAYER_SPECIALIZATION_CHANGED" then
                PDUpdateSoon(0.41, event)
            elseif event == "SOCKET_INFO_SUCCESS" or event == "SOCKET_INFO_UPDATE" or event == "SOCKET_INFO_CLOSE" then
                PDUpdateSoon(0.41, event)
            end

            ArmoryUtils:PDUpdateDurability()
        end, "PDThink")

        ArmoryUtils:PDUpdateItemInfos()
        ArmoryUtils:WaitForInspectFrame()
        local frame = CreateFrame("FRAME")
        ArmoryUtils:RegisterEvent(frame, "BAG_OPEN")
        ArmoryUtils:RegisterEvent(frame, "BAG_CLOSED")
        ArmoryUtils:RegisterEvent(frame, "QUEST_ACCEPTED")
        ArmoryUtils:RegisterEvent(frame, "UNIT_QUEST_LOG_CHANGED")
        ArmoryUtils:RegisterEvent(frame, "BAG_UPDATE")
        ArmoryUtils:RegisterEvent(frame, "UNIT_INVENTORY_CHANGED")
        ArmoryUtils:RegisterEvent(frame, "ITEM_LOCK_CHANGED")
        ArmoryUtils:RegisterEvent(frame, "DISPLAY_SIZE_CHANGED")
        ArmoryUtils:RegisterEvent(frame, "INVENTORY_SEARCH_UPDATE")
        ArmoryUtils:RegisterEvent(frame, "BAG_NEW_ITEMS_UPDATED")
        ArmoryUtils:RegisterEvent(frame, "BAG_SLOT_FLAGS_UPDATED")
        ArmoryUtils:OnEvent(frame, function(sel, event, ...)
            if not bagUpdatePending then
                bagUpdatePending = true
                C_Timer.After(0.1, function()
                    bagUpdatePending = false
                    ArmoryUtils:UpdateBagsIlvl(event)
                end)
            end
        end, "UpdateBagsIlvl")

        ArmoryUtils:UpdateBagsIlvl()
    end

    if ArmoryUtils:GetWoWBuild() ~= "RETAIL" and BagItemSearchBox == nil and BagItemAutoSortButton == nil and ArmoryUtils:DBGV("IMPROVEBAGS", true) then
        -- Bag Searchbar
        if not ArmoryUtils:IsOldWow() then
            for i = 1, 6 do
                local cf = _G["ContainerFrame" .. i]
                if cf then
                    local search = CreateFrame("EditBox", "BagItemSearchBox" .. i, cf, "BagSearchBoxTemplate")
                    search:SetSize(110, 18)
                    search:SetPoint("TOPLEFT", cf, "TOPLEFT", 50, -30)
                    local function updateSearchVisibility()
                        if ArmoryUtils:DBGV("IMPROVEBAGS", true) and IsBagOpen(0) and cf:GetID() == 0 then
                            search:SetAlpha(1)
                            search:EnableMouse(true)
                        else
                            search:SetAlpha(0)
                            search:EnableMouse(false)
                        end
                    end

                    cf:HookScript("OnShow", updateSearchVisibility)
                    cf:HookScript("OnHide", updateSearchVisibility)
                    updateSearchVisibility()
                end
            end
        end

        -- Bag SortButton
        BagItemAutoSortButton = CreateFrame("Button", "BagItemAutoSortButton", ContainerFrame1)
        BagItemAutoSortButton:SetSize(16, 16)
        BagItemAutoSortButton:SetPoint("TOPLEFT", ContainerFrame1, "TOPLEFT", 164, -30)
        --[[
		BagItemAutoSortButton:SetNormalTexture("bags-button-autosort-up")
		BagItemAutoSortButton:SetPushedTexture("bags-button-autosort-down")
		BagItemAutoSortButton:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square")
		]]
        BagItemAutoSortButton:SetScript("OnClick", function(sel, ...)
            PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
            local SortBags = getglobal("SortBags")
            if SortBags then
                SortBags()
            elseif C_Container and C_Container.SortBags then
                C_Container.SortBags()
            end
        end)

        BagItemAutoSortButton:SetScript("OnEnter", function(sel, ...)
            if sel then
                GameTooltip:SetOwner(sel, "ANCHOR_TOPLEFT")
                GameTooltip:SetText(BAG_CLEANUP_BAGS)
                GameTooltip:Show()
            end
        end)

        BagItemAutoSortButton:SetScript("OnLeave", function(sel, ...) GameTooltip_Hide() end)
    end

    ArmoryUtils:UpdateFonts()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("INSPECT_READY")
frame:SetScript("OnEvent", function(self, event, guid)
    if event == "INSPECT_READY" and lastInspectGUID and guid == lastInspectGUID then
        if ArmoryUtils:IsAddonLoaded("TooltipUtils") then
            frame:UnregisterEvent("INSPECT_READY")
            return
        end

        local cachedLevel = ArmoryUtils:GetCachedItemLevel(guid)
        if cachedLevel then return end
        pcall(function()
            local _, unit = GameTooltip:GetUnit()
            if InCombatLockdown() then return end
            if not pcall(UnitExists, unit) then return end
            if unit and UnitExists(unit) and UnitGUID(unit) == guid then
                if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
                    local ilevel = C_PaperDollInfo.GetInspectItemLevel(unit)
                    if ilevel and ilevel > 0 then
                        ArmoryUtils:SaveToItemLevelCache(guid, ilevel)
                        GameTooltip:AddDoubleLine("ilvl:", format("%d", ilevel))
                        GameTooltip:Show()
                    end
                else
                    local ilevel = ArmoryUtils:GetInspectILvl(unit)
                    if ilevel and ilevel > 0 then
                        ArmoryUtils:SaveToItemLevelCache(guid, ilevel)
                        GameTooltip:AddDoubleLine("ilvl:", format("%d", ilevel))
                        GameTooltip:Show()
                    end
                end
            end
        end)
    end
end)

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tt, data)
        if ArmoryUtils:IsAddonLoaded("TooltipUtils") then return end
        if not AUTAB["SHOWITEMLEVEL"] then return end
        pcall(function()
            if InspectFrame and InspectFrame:IsShown() then return end
            local _, unit = tt:GetUnit()
            if InCombatLockdown() then return end
            if not pcall(UnitExists, unit) then return end
            if unit and UnitExists(unit) and UnitIsPlayer(unit) and CanInspect(unit) then
                local guid = UnitGUID(unit)
                local cachedLevel = ArmoryUtils:GetCachedItemLevel(guid)
                if not cachedLevel and ArmoryUtils:GetInspectCache(guid) == nil and lastInspect < GetTime() then
                    lastInspect = GetTime() + 2
                    ArmoryUtils:SaveToInspectCache(guid)
                    lastInspectGUID = guid
                    NotifyInspect(unit)
                elseif cachedLevel then
                    tt:AddDoubleLine("ilvl:", format("%d", cachedLevel))
                    tt:Show()
                end
            end
        end)
    end)
end

if GameTooltip.HasScript and GameTooltip:HasScript("OnTooltipSetUnit") then
    GameTooltip:HookScript("OnTooltipSetUnit", function(tt, data)
        if ArmoryUtils:IsAddonLoaded("TooltipUtils") then return end
        if not AUTAB["SHOWITEMLEVEL"] then return end
        pcall(function()
            local _, unit = tt:GetUnit()
            if InCombatLockdown() then return end
            if not pcall(UnitExists, unit) then return end
            if unit and UnitExists(unit) and UnitIsPlayer(unit) and CanInspect(unit) then
                local guid = UnitGUID(unit)
                local cachedLevel = ArmoryUtils:GetCachedItemLevel(guid)
                if not cachedLevel and ArmoryUtils:GetInspectCache(guid) == nil and lastInspect < GetTime() then
                    lastInspect = GetTime() + 2
                    ArmoryUtils:SaveToInspectCache(guid)
                    lastInspectGUID = guid
                    NotifyInspect(unit)
                elseif cachedLevel then
                    tt:AddDoubleLine("ilvl:", format("%d", cachedLevel))
                end
            end
        end)
    end)
end

local function AddWrongArmorLine(tt)
    if tt == nil or tt:IsForbidden() then return end
    local owner = tt:GetOwner()
    if owner == nil or (owner.IsForbidden and owner:IsForbidden()) then return end
    if owner.auarmor == nil or not owner.auarmor:IsShown() then return end
    if owner.auarmortext == nil and owner.austattext == nil then return end
    if owner.auarmortext then tt:AddLine(owner.auarmortext, 1, 0.2, 0.2) end
    if owner.austattext then tt:AddLine(owner.austattext, 1, 0.2, 0.2) end
    tt:Show()
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt, data) AddWrongArmorLine(tt) end)
elseif GameTooltip.HasScript and GameTooltip:HasScript("OnTooltipSetItem") then
    GameTooltip:HookScript("OnTooltipSetItem", function(tt) AddWrongArmorLine(tt) end)
end
