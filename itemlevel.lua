local _, ArmoryUtils = ...
local GetItemGem = (C_Item and C_Item.GetItemGem) and C_Item.GetItemGem or GetItemGem
local AUGlowAlpha = 0.75
local AUClassIDs = {2, 3, 4, 6, 8}
-- 15
local AUSubClassIDs15 = {5, 6}
local slotbry = 0
local AUCharSlots = {"AmmoSlot", "HeadSlot", "NeckSlot", "ShoulderSlot", "ShirtSlot", "ChestSlot", "WaistSlot", "LegsSlot", "FeetSlot", "WristSlot", "HandsSlot", "Finger0Slot", "Finger1Slot", "Trinket0Slot", "Trinket1Slot", "BackSlot", "MainHandSlot", "SecondaryHandSlot", "RangedSlot", "TabardSlot",}
local AUCharSlotsLeft = {}
AUCharSlotsLeft["CharacterHeadSlot"] = true
AUCharSlotsLeft["CharacterNeckSlot"] = true
AUCharSlotsLeft["CharacterShoulderSlot"] = true
AUCharSlotsLeft["CharacterBackSlot"] = true
AUCharSlotsLeft["CharacterChestSlot"] = true
AUCharSlotsLeft["CharacterShirtSlot"] = true
AUCharSlotsLeft["CharacterTabardSlot"] = true
AUCharSlotsLeft["CharacterWristSlot"] = true
AUCharSlotsLeft["CharacterSecondaryHandSlot"] = true
local AUCharSlotsRight = {}
AUCharSlotsRight["CharacterHandsSlot"] = true
AUCharSlotsRight["CharacterWaistSlot"] = true
AUCharSlotsRight["CharacterLegsSlot"] = true
AUCharSlotsRight["CharacterFeetSlot"] = true
AUCharSlotsRight["CharacterFinger0Slot"] = true
AUCharSlotsRight["CharacterFinger1Slot"] = true
AUCharSlotsRight["CharacterTrinket0Slot"] = true
AUCharSlotsRight["CharacterTrinket1Slot"] = true
AUCharSlotsRight["CharacterMainHandSlot"] = true
local fontSizeGems = 12
local fontSizeEnchants = 8
local PDThink = CreateFrame("FRAME")
local AUILVL = nil
local emptySockets = {}
for name, v in pairs(_G) do
    if name and type(name) == "string" and string.find(name, "EMPTY_SOCKET_", 1, true) and not tContains(emptySockets, v) then
        tinsert(emptySockets, v)
    end
end

function ArmoryUtils:AddIlvl(SLOT, i)
    if SLOT and SLOT.auinfo == nil then
        local name = ""
        if SLOT.GetName then
            name = ArmoryUtils:GetName(SLOT)
        end

        SLOT.auinfo = CreateFrame("FRAME", name .. ".auinfo", SLOT)
        SLOT.auinfo:SetSize(SLOT:GetSize())
        SLOT.auinfo:SetPoint("CENTER", SLOT, "CENTER", 0, 0)
        SLOT.auinfo:SetFrameLevel(200)
        SLOT.auinfo:EnableMouse(false)
        SLOT.autext = SLOT.auinfo:CreateFontString(nil, "OVERLAY")
        SLOT.autext:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
        SLOT.autext:SetShadowOffset(1, -1)
        SLOT.autexth = SLOT.auinfo:CreateFontString(nil, "OVERLAY")
        SLOT.autexth:SetFont(STANDARD_TEXT_FONT, 9, "THINOUTLINE")
        SLOT.autexth:SetShadowOffset(1, -1)
        SLOT.autexte = SLOT.auinfo:CreateFontString(nil, "OVERLAY")
        SLOT.autexte:SetFont(STANDARD_TEXT_FONT, fontSizeEnchants, "THINOUTLINE")
        SLOT.autexte:SetShadowOffset(1, -1)
        SLOT.autextg = SLOT.auinfo:CreateFontString(nil, "OVERLAY")
        SLOT.autextg:SetFont(STANDARD_TEXT_FONT, fontSizeGems, "THINOUTLINE")
        SLOT.autextg:SetShadowOffset(1, -1)
        SLOT.auborder = SLOT.auinfo:CreateTexture("SLOT.auborder", "OVERLAY")
        SLOT.auborder:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
        SLOT.auborder:SetBlendMode("ADD")
        SLOT.auborder:SetAlpha(1)
        local px = 8
        if false and ArmoryUtils:DBGV("ITEMLEVELSYSTEMSIDEWAYS", true) then
            slotbry = 2
            if AUCharSlotsLeft[name] then
                if i == 17 or i == 18 then
                    SLOT.autexte:SetPoint("BOTTOMLEFT", SLOT.auinfo, "BOTTOMRIGHT", px, slotbry)
                else
                    SLOT.autexte:SetPoint("LEFT", SLOT.auinfo, "RIGHT", px, 0)
                    SLOT.autextg:SetPoint("BOTTOMLEFT", SLOT.auinfo, "BOTTOMRIGHT", px, slotbry)
                end
            elseif AUCharSlotsRight[name] then
                if i == 17 or i == 18 then
                    SLOT.autexte:SetPoint("BOTTOMRIGHT", SLOT.auinfo, "BOTTOMLEFT", -px, slotbry)
                else
                    SLOT.autexte:SetPoint("RIGHT", SLOT.auinfo, "LEFT", -px, 0)
                    SLOT.autextg:SetPoint("BOTTOMRIGHT", SLOT.auinfo, "BOTTOMLEFT", -px, slotbry)
                end
            else
                slotbry = 0
                SLOT.autexte:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, 0)
                SLOT.autextg:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, slotbry)
            end
        else
            slotbry = 6
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
                slotbry = 0
                SLOT.autexte:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, 0)
                SLOT.autextg:SetPoint("CENTER", SLOT.auinfo, "CENTER", 0, slotbry)
            end
        end

        if false and ArmoryUtils:DBGV("ITEMLEVELSYSTEMSIDEWAYS", true) then
            slotbry = 2
            if AUCharSlotsLeft[name] then
                SLOT.autext:SetPoint("TOPLEFT", SLOT.auinfo, "TOPRIGHT", px, -slotbry)
            elseif AUCharSlotsRight[name] then
                SLOT.autext:SetPoint("TOPRIGHT", SLOT.auinfo, "TOPLEFT", -px, -slotbry)
            else
                slotbry = 0
                SLOT.autext:SetPoint("TOP", SLOT.auinfo, "TOP", 0, -slotbry)
            end
        else
            slotbry = 0
            SLOT.autext:SetPoint("TOP", SLOT.auinfo, "TOP", 0, -slotbry)
        end

        if false and ArmoryUtils:DBGV("ITEMLEVELSYSTEMSIDEWAYS", true) then
            slotbry = 2
            if AUCharSlotsLeft[name] then
                SLOT.autexth:SetPoint("BOTTOMLEFT", SLOT.auinfo, "BOTTOMRIGHT", px, slotbry)
            elseif AUCharSlotsRight[name] then
                SLOT.autexth:SetPoint("BOTTOMRIGHT", SLOT.auinfo, "BOTTOMLEFT", -px, slotbry)
            else
                slotbry = 0
                SLOT.autexth:SetPoint("BOTTOM", SLOT.auinfo, "BOTTOM", 0, slotbry)
            end
        else
            slotbry = 0
            SLOT.autexth:SetPoint("BOTTOM", SLOT.auinfo, "BOTTOM", 0, slotbry)
        end

        local NormalTexture = _G[ArmoryUtils:GetName(SLOT) .. "NormalTexture"]
        if NormalTexture then
            local sw, sh = NormalTexture:GetSize()
            SLOT.auborder:SetWidth(sw)
            SLOT.auborder:SetHeight(sh)
        end

        SLOT.auborder:SetPoint("CENTER")
    end
end

function ArmoryUtils:GetAUILVL()
    return AUILVL
end

function ArmoryUtils:PDUpdateItemInfos()
    if ArmoryUtils:DBGV("ITEMLEVELSYSTEM", true) then
        local count = 0
        local sum = 0
        for i, slot in pairs(AUCharSlots) do
            i = i - 1
            local SLOT = _G["Character" .. slot]
            if SLOT and SLOT.autext ~= nil and GetInventoryItemLink and SLOT.GetID and SLOT:GetID() then
                local slotId = SLOT:GetID()
                local Link = GetInventoryItemLink("player", slotId) or GetInventoryItemID("player", slotId)
                if Link ~= nil and GetDetailedItemLevelInfo then
                    local _, _, rarity = ArmoryUtils:GetItemInfo(Link)
                    local ilvl, _, _ = GetDetailedItemLevelInfo(Link)
                    local color = ITEM_QUALITY_COLORS[rarity]
                    local current, maximum = GetInventoryItemDurability(i)
                    if C_TooltipInfo then
                        local tooltipData = C_TooltipInfo.GetInventoryItem("player", slotId)
                        local foundEnchant = false
                        if tooltipData ~= nil then
                            local gems = {}
                            if GetItemGem then
                                for gid = 1, 4 do
                                    local gemLink = select(2, GetItemGem(Link, gid))
                                    if gemLink then
                                        tinsert(gems, gemLink)
                                    end
                                end
                            end

                            for x, line in pairs(tooltipData.lines) do
                                local text = line.leftText
                                local enchantString = string.match(text, ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.*)"))
                                if enchantString ~= nil then
                                    foundEnchant = true
                                    if string.find(enchantString, "|A:") then
                                        local itemEnchant, itemEnchantAtlas = string.match(enchantString, "(.*)|A:(.*):20:20|a")
                                        if ArmoryUtils:DBGV("ITEMLEVELSYSTEMSIDEWAYS", true) then
                                            SLOT.autexte:SetText("|cFF00FF00|A:" .. itemEnchantAtlas .. ":16:16:0:0|a " .. string.sub(itemEnchant, 1, 12) .. "..." .. "|r")
                                        else
                                            SLOT.autexte:SetText("|cFF00FF00|A:" .. itemEnchantAtlas .. ":24:24:0:0|a")
                                        end
                                    else
                                        local itemEnchant = enchantString
                                        SLOT.autexte:SetText("|cFF00FF00" .. itemEnchant .. "|r")
                                    end
                                end

                                for index, name in pairs(emptySockets) do
                                    if string.find(text, name) then
                                        foundGem = true
                                        local gemString = string.match(text, name:gsub("%%s", "(.*)"))
                                        tinsert(gems, gemString)
                                    end
                                end
                            end

                            if #gems > 0 then
                                local text = ""
                                for x, gem in pairs(gems) do
                                    if x > 1 then
                                        text = text .. "  "
                                    end

                                    local item = GetItemInfo(gem)
                                    if item == nil then
                                        text = text .. "|T" .. "Interface/ItemsocketingFrame/UI-EmptySocket-Prismatic" .. ":" .. fontSizeGems .. ":" .. fontSizeGems .. ":0:0|t"
                                    else
                                        local icon = select(10, GetItemInfo(gem))
                                        local classID = select(12, GetItemInfo(gem))
                                        text = text .. "|T" .. icon .. ":" .. fontSizeGems .. ":" .. fontSizeGems .. ":0:0|t|A:" .. "Professions-ChatIcon-Quality-Tier" .. classID .. ":" .. fontSizeGems .. ":" .. fontSizeGems .. ":0:0|a"
                                    end
                                end

                                SLOT.autextg:SetText(text)
                            end
                        end

                        if not foundEnchant then
                            SLOT.autexte:SetText("")
                        end
                    else
                        SLOT.autexte:SetText("")
                        SLOT.autextg:SetText("")
                    end

                    if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and current and maximum then
                        local per = current / maximum
                        -- 100%
                        if current == maximum then
                            SLOT.autexth:SetTextColor(0, 1, 0, 1)
                        elseif per == 0.0 then
                            -- = 0%, black
                            SLOT.autexth:SetTextColor(0, 0, 0, 1)
                        elseif per < 0.1 then
                            -- < 10%, red
                            SLOT.autexth:SetTextColor(1, 0, 0, 1)
                        elseif per < 0.3 then
                            -- < 30%, orange
                            SLOT.autexth:SetTextColor(1, 0.65, 0, 1)
                        elseif per < 1 then
                            -- < 100%, red
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

                    if ilvl and color then
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

                        if ArmoryUtils:DBGV("ITEMLEVEL", true) then
                            if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and ArmoryUtils:DBGV("ITEMLEVELNUMBER", true) and ilvl and ilvl > 1 then
                                SLOT.autext:SetText(color.hex .. ilvl)
                            end

                            local alpha = AUGlowAlpha
                            if color.r == 1 and color.g == 1 and color.b == 1 then
                                alpha = alpha - 0.2
                            end

                            if rarity and rarity > 1 and ArmoryUtils:DBGV("ITEMLEVELBORDER", true) then
                                SLOT.auborder:SetVertexColor(color.r, color.g, color.b, alpha)
                            else
                                SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                            end
                        else
                            SLOT.autext:SetText("")
                            SLOT.autexth:SetText("")
                            SLOT.autexte:SetText("")
                            SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                        end
                    else
                        SLOT.autext:SetText("")
                        SLOT.autexth:SetText("")
                        SLOT.autexte:SetText("")
                        SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                    end
                else
                    SLOT.autext:SetText("")
                    SLOT.autexth:SetText("")
                    SLOT.autexte:SetText("")
                    SLOT.auborder:SetVertexColor(1, 1, 1, 0)
                end
            end
        end

        if count > 0 then
            local max = 16 -- when only AUnhand
            if GetInventoryItemID("PLAYER", 17) then
                local t1 = ArmoryUtils:GetItemInfo(GetInventoryItemLink("PLAYER", 17))
                -- when 2x 1handed
                if t1 then
                    max = 17
                end
            end

            if ArmoryUtils:GetWoWBuild() == "RETAIL" then
                max = max - 1
            end

            AUILVL = string.format("%0.2f", sum / max)
            if PaperDollFrame.ilvl then
                if ArmoryUtils:GetWoWBuild() == "RETAIL" then
                    PaperDollFrame.ilvl:SetText("")
                else
                    PaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": |r" .. ArmoryUtils:GetAUILVL())
                end
            end
        elseif PaperDollFrame.ilvl then
            if ArmoryUtils:GetWoWBuild() == "RETAIL" then
                PaperDollFrame.ilvl:SetText("")
            else
                PaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": " .. "|cFFFF0000?")
            end
        end
    end
end

function ArmoryUtils:UpdateBagsIlvl()
    local tab = {}
    for i = 1, 20 do
        tinsert(tab, _G["ContainerFrame" .. i])
    end

    if ContainerFrameCombinedBags and ContainerFrameCombinedBags.ausetup == nil then
        ContainerFrameCombinedBags.ausetup = true
        ContainerFrameCombinedBags:HookScript(
            "OnShow",
            function(sel)
                ArmoryUtils:UpdateBagsIlvl()
            end
        )
    end

    for x, bag in pairs(tab) do
        if bag.ausetup == nil then
            bag.ausetup = true
            bag:HookScript(
                "OnShow",
                function(sel)
                    ArmoryUtils:UpdateBag(bag, x - 1)
                end
            )
        end

        ArmoryUtils:UpdateBag(bag, x - 1)
    end
end

function ArmoryUtils:GetContainerNumSlots(bagID)
    local cur = 0
    if C_Container and C_Container.GetContainerNumSlots then
        cur = C_Container.GetContainerNumSlots(bagID)
    else
        cur = GetContainerNumSlots(bagID)
    end

    local max = cur
    if bagID == 0 and not IsAccountSecured() then
        max = cur + 4
    end

    return max, cur
end

function ArmoryUtils:GetContainerItemLink(bagID, slotID)
    if C_Container and C_Container.GetContainerItemLink then return C_Container.GetContainerItemLink(bagID, slotID) end

    return GetContainerItemLink(bagID, slotID)
end

-- BAGS
function ArmoryUtils:UpdateBag(bag, id)
    local name = ArmoryUtils:GetName(bag)
    local bagID = bag:GetID()
    if GetCVarBool("combinedBags") then
        bagID = id
    end

    local size = ArmoryUtils:GetContainerNumSlots(bagID)
    for i = 1, size do
        local SLOT = _G[name .. "Item" .. i]
        if GetCVarBool("combinedBags") then
            SLOT = _G[name .. "Item" .. i]
        end

        if SLOT then
            local slotID = size - i + 1
            local slotLink = ArmoryUtils:GetContainerItemLink(bagID, slotID)
            ArmoryUtils:AddIlvl(SLOT, slotID)
            if slotLink and GetDetailedItemLevelInfo then
                local _, _, rarity, _, _, _, _, _, _, _, _, classID, subclassID = ArmoryUtils:GetItemInfo(slotLink)
                local ilvl, _, _ = GetDetailedItemLevelInfo(slotLink)
                local color = ITEM_QUALITY_COLORS[rarity]
                if ilvl and color then
                    if ArmoryUtils:DBGV("ITEMLEVEL", true) then
                        if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and ArmoryUtils:DBGV("ITEMLEVELNUMBER", true) and tContains(AUClassIDs, classID) or (classID == 15 and tContains(AUSubClassIDs15, subclassID)) and ilvl and ilvl > 1 then
                            SLOT.autext:SetText(color.hex .. ilvl)
                        else
                            SLOT.autext:SetText("")
                        end

                        local alpha = AUGlowAlpha
                        if color.r == 1 and color.g == 1 and color.b == 1 then
                            alpha = alpha - 0.2
                        end

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
end

function ArmoryUtils:CheckInspectSlot(slot)
    if ArmoryUtils:GetWoWBuild() == "RETAIL" then return slot ~= "AmmoSlot" and slot ~= "ShirtSlot" and slot ~= "TabardSlot" and slot ~= "RangedSlot" end

    return slot ~= "AmmoSlot" and slot ~= "ShirtSlot" and slot ~= "TabardSlot"
end

function ArmoryUtils:IFUpdateItemInfos()
    local count = 0
    local sum = 0
    for i, slot in pairs(AUCharSlots) do
        local SLOT = _G["Inspect" .. slot]
        if SLOT and SLOT.autext ~= nil and GetInventoryItemLink then
            local ItemID = GetInventoryItemLink("TARGET", SLOT:GetID()) --GetInventoryItemID("PLAYER", SLOT:GetID())
            if ItemID and GetDetailedItemLevelInfo then
                local _, _, rarity = ArmoryUtils:GetItemInfo(ItemID)
                local ilvl, _, _ = GetDetailedItemLevelInfo(ItemID)
                local color = ITEM_QUALITY_COLORS[rarity]
                if ArmoryUtils:DBGV("ITEMLEVEL", true) and ilvl and color then
                    -- ignore: shirt, tabard, ammo
                    if ArmoryUtils:CheckInspectSlot(slot) and ilvl and ilvl > 1 then
                        count = count + 1
                        sum = sum + ilvl
                    end

                    if ArmoryUtils:DBGV("ITEMLEVEL", true) then
                        if not ArmoryUtils:IsAddOnLoaded("DejaCharacterStats") and ArmoryUtils:DBGV("ITEMLEVELNUMBER", true) and ilvl and ilvl > 1 then
                            SLOT.autext:SetText(color.hex .. ilvl)
                        end

                        local alpha = AUGlowAlpha
                        if color.r == 1 and color.g == 1 and color.b == 1 then
                            alpha = alpha - 0.2
                        end

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

    if count > 0 then
        local max = 16 -- when only Mainhand
        local ItemID = GetInventoryItemLink("TARGET", 17)
        if GetItemInfo and GetInventoryItemID and ItemID ~= nil then
            local t1 = ArmoryUtils:GetItemInfo(ItemID)
            -- when 2x 1handed
            if t1 then
                max = 17
            end
        end

        if ArmoryUtils:GetWoWBuild() == "RETAIL" then
            max = max - 1
        end

        AUILVLINSPECT = string.format("%0.2f", sum / max)
        if ArmoryUtils:DBGV("ITEMLEVEL", true) and ArmoryUtils:DBGV("ITEMLEVELNUMBER", true) and InspectPaperDollFrame.ilvl then
            InspectPaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": |r" .. AUILVLINSPECT)
        else
            InspectPaperDollFrame.ilvl:SetText("")
        end
    elseif InspectPaperDollFrame.ilvl then
        InspectPaperDollFrame.ilvl:SetText("|cFFFFFF00" .. ITEM_LEVEL_ABBR .. ": " .. "|cFFFF0000?")
    end
end

function ArmoryUtils:WaitForInspectFrame()
    if InspectPaperDollFrame then
        IFThink = CreateFrame("FRAME")
        InspectPaperDollFrame.ilvl = InspectPaperDollFrame:CreateFontString(nil, "ARTWORK")
        InspectPaperDollFrame.ilvl:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        InspectPaperDollFrame.ilvl:SetPoint("TOPLEFT", InspectWristSlot, "BOTTOMLEFT", 24, -15)
        InspectPaperDollFrame.ilvl:SetText(ITEM_LEVEL_ABBR .. ": ?")
        for i, slot in pairs(AUCharSlots) do
            ArmoryUtils:AddIlvl(_G["Inspect" .. slot], i)
        end

        ArmoryUtils:After(0.5, ArmoryUtils.IFUpdateItemInfos, "ArmoryUtils.IFUpdateItemInfos 1")
        ArmoryUtils:RegisterEvent(IFThink, "INSPECT_READY")
        ArmoryUtils:OnEvent(
            IFThink,
            function(sel, event, slotid, ...)
                ArmoryUtils:After(0.1, ArmoryUtils.IFUpdateItemInfos, "ArmoryUtils.IFUpdateItemInfos 2")
            end, "IFThink"
        )
    else
        ArmoryUtils:After(0.3, ArmoryUtils.WaitForInspectFrame, "ArmoryUtils.WaitForInspectFrame")
    end
end

function ArmoryUtils:InitItemLevel()
    if ArmoryUtils:DBGV("ITEMLEVELSYSTEM", true) and PaperDollFrame then
        PaperDollFrame.ilvl = PaperDollFrame:CreateFontString(nil, "ARTWORK")
        PaperDollFrame.ilvl:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        PaperDollFrame.ilvl:SetPoint("TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 24, -15)
        if ArmoryUtils:GetWoWBuild() == "RETAIL" then
            PaperDollFrame.ilvl:SetText("")
        else
            PaperDollFrame.ilvl:SetText(ITEM_LEVEL_ABBR .. ": ?")
        end

        for i, slot in pairs(AUCharSlots) do
            ArmoryUtils:AddIlvl(_G["Character" .. slot], i)
        end

        function PDThink.Loop()
            ArmoryUtils:PDUpdateItemInfos()
            ArmoryUtils:After(1, PDThink.Loop, "PDThink.Loop 2")
        end

        ArmoryUtils:After(1, PDThink.Loop, "PDThink.Loop 1")
        ArmoryUtils:RegisterEvent(PDThink, "PLAYER_EQUIPMENT_CHANGED")
        ArmoryUtils:OnEvent(
            PDThink,
            function(sel, event, slotid, ...)
                ArmoryUtils:PDUpdateItemInfos()
            end, "PDThink"
        )

        PaperDollFrame.btn = CreateFrame("CheckButton", "PaperDollFrame" .. "btn", PaperDollFrame, "UICheckButtonTemplate")
        PaperDollFrame.btn:SetSize(20, 20)
        PaperDollFrame.btn:SetPoint("TOPLEFT", CharacterWristSlot, "BOTTOMLEFT", 6, -10)
        PaperDollFrame.btn:SetChecked(ArmoryUtils:DBGV("ITEMLEVEL", true))
        PaperDollFrame.btn:SetScript(
            "OnClick",
            function(sel)
                local newval = sel:GetChecked()
                ArmoryUtils:DBSV("ITEMLEVEL", newval)
                ArmoryUtils:PDUpdateItemInfos()
                if ArmoryUtils.IFUpdateItemInfos then
                    ArmoryUtils:IFUpdateItemInfos()
                end

                if ArmoryUtils.UpdateBagsIlvl then
                    ArmoryUtils:UpdateBagsIlvl()
                end
            end
        )

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
        ArmoryUtils:OnEvent(
            frame,
            function(sel, event)
                ArmoryUtils:UpdateBagsIlvl()
            end, "UpdateBagsIlvl"
        )

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
                    search:SetScript(
                        "OnUpdate",
                        function(sel, ...)
                            if ArmoryUtils:DBGV("IMPROVEBAGS", true) then
                                if IsBagOpen(0) and cf:GetID() == 0 then
                                    sel:SetAlpha(1)
                                    sel:EnableMouse(true)
                                else
                                    sel:SetAlpha(0)
                                    sel:EnableMouse(false)
                                end
                            else
                                sel:SetAlpha(0)
                                sel:EnableMouse(false)
                            end
                        end
                    )
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
        BagItemAutoSortButton:SetScript(
            "OnClick",
            function(sel, ...)
                PlaySound(SOUNDKIT.UI_BAG_SORTING_01)
                if SortBags then
                    SortBags()
                elseif C_Container and C_Container.SortBags then
                    C_Container.SortBags()
                end
            end
        )

        BagItemAutoSortButton:SetScript(
            "OnEnter",
            function(sel, ...)
                if sel then
                    GameTooltip:SetOwner(sel)
                    GameTooltip:SetText(BAG_CLEANUP_BAGS)
                    GameTooltip:Show()
                end
            end
        )

        BagItemAutoSortButton:SetScript(
            "OnLeave",
            function(sel, ...)
                GameTooltip_Hide()
            end
        )
    end
end
