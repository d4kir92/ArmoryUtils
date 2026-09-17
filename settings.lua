local _, ArmoryUtils = ...
local ICON = 134952
local VERSION = "1.3.2"
local DEFAULT_WIDTH = 460
local DEFAULT_HEIGHT = 520
local DEFAULT_ILVLFONTSIZE = 11
local DEFAULT_SIDEFONTSIZE = 11
local au_settings = nil
local function ShowMinimapButtonDefault()
    return ArmoryUtils:GetWoWBuild() ~= "RETAIL"
end

local function ApplyDefaults()
    AUTAB = AUTAB or {}
    ArmoryUtils:SV(AUTAB, "SHOWMINIMAPBUTTON", ArmoryUtils:GV(AUTAB, "SHOWMINIMAPBUTTON", ShowMinimapButtonDefault()))
    ArmoryUtils:SV(AUTAB, "SHOWITEMLEVEL", ArmoryUtils:GV(AUTAB, "SHOWITEMLEVEL", true))
    ArmoryUtils:SV(AUTAB, "ENCHANTONLYICON", ArmoryUtils:GV(AUTAB, "ENCHANTONLYICON", true))
    ArmoryUtils:SV(AUTAB, "HIDEMAXUPGRADE", ArmoryUtils:GV(AUTAB, "HIDEMAXUPGRADE", false))
    ArmoryUtils:SV(AUTAB, "WRONGARMORTYPE", ArmoryUtils:GV(AUTAB, "WRONGARMORTYPE", true))
    ArmoryUtils:SV(AUTAB, "WRONGPRIMARYSTAT", ArmoryUtils:GV(AUTAB, "WRONGPRIMARYSTAT", true))
    ArmoryUtils:SV(AUTAB, "ILVLFONTSIZE", ArmoryUtils:GV(AUTAB, "ILVLFONTSIZE", DEFAULT_ILVLFONTSIZE))
    ArmoryUtils:SV(AUTAB, "SIDEFONTSIZE", ArmoryUtils:GV(AUTAB, "SIDEFONTSIZE", DEFAULT_SIDEFONTSIZE))
end

local function GetCollapsed(key)
    if key == nil then return nil end
    if type(AUTAB) ~= "table" then return nil end
    if type(AUTAB["COLLAPSED"]) ~= "table" then return nil end
    return AUTAB["COLLAPSED"][key]
end

local function SetCollapsed(key, collapsed)
    if key == nil then return end
    if type(AUTAB) ~= "table" then return end
    if type(AUTAB["COLLAPSED"]) ~= "table" then AUTAB["COLLAPSED"] = {} end
    if collapsed then
        AUTAB["COLLAPSED"][key] = true
    else
        AUTAB["COLLAPSED"][key] = nil
    end
end

function ArmoryUtils:ToggleSettings()
    if au_settings then au_settings:Toggle() end
end

function ArmoryUtils:InitSettings()
    ApplyDefaults()
    au_settings = ArmoryUtils:CreateUIWindow({
        ["name"] = "ArmoryUtilsSettings",
        ["pTab"] = {"CENTER"},
        ["width"] = ArmoryUtils:GV(AUTAB, "WINDOWWIDTH", DEFAULT_WIDTH),
        ["height"] = ArmoryUtils:GV(AUTAB, "WINDOWHEIGHT", DEFAULT_HEIGHT),
        ["minWidth"] = 360,
        ["minHeight"] = 240,
        ["onResize"] = function(width, height)
            ArmoryUtils:SV(AUTAB, "WINDOWWIDTH", width)
            ArmoryUtils:SV(AUTAB, "WINDOWHEIGHT", height)
        end,
        ["getCollapsed"] = function(key) return GetCollapsed(key) end,
        ["setCollapsed"] = function(key, collapsed) SetCollapsed(key, collapsed) end,
        ["title"] = format("|T%d:16:16:0:0|t ArmoryUtils v%s", ICON, ArmoryUtils:GetVersion())
    })

    au_settings:SuspendLayout()
    au_settings:AddSearch()
    au_settings:AddCategory({
        ["label"] = "LID_GENERAL",
        ["key"] = "GENERAL"
    })

    au_settings:AddCheckbox({
        ["label"] = "LID_SHOWMINIMAPBUTTON",
        ["search"] = "SHOWMINIMAPBUTTON",
        ["value"] = ArmoryUtils:GV(AUTAB, "SHOWMINIMAPBUTTON", ShowMinimapButtonDefault()),
        ["func"] = function(value)
            ArmoryUtils:SV(AUTAB, "SHOWMINIMAPBUTTON", value)
            if value then
                ArmoryUtils:ShowMMBtn("ArmoryUtils")
            else
                ArmoryUtils:HideMMBtn("ArmoryUtils")
            end
        end
    })

    if C_Item and C_Item.GetItemUpgradeInfo then
        au_settings:AddCheckbox({
            ["label"] = "LID_HIDEMAXUPGRADE",
            ["search"] = "HIDEMAXUPGRADE",
            ["value"] = ArmoryUtils:GV(AUTAB, "HIDEMAXUPGRADE", false),
            ["func"] = function(value)
                ArmoryUtils:SV(AUTAB, "HIDEMAXUPGRADE", value)
                ArmoryUtils:PDUpdateItemInfos()
            end
        })
    end

    au_settings:AddCheckbox({
        ["label"] = "LID_WRONGARMORTYPE",
        ["search"] = "WRONGARMORTYPE",
        ["value"] = ArmoryUtils:GV(AUTAB, "WRONGARMORTYPE", true),
        ["func"] = function(value)
            ArmoryUtils:SV(AUTAB, "WRONGARMORTYPE", value)
            ArmoryUtils:PDUpdateItemInfos()
            if InspectFrame and InspectFrame:IsShown() then ArmoryUtils:IFUpdateItemInfos() end
        end
    })

    if ArmoryUtils:GetWoWBuild() == "RETAIL" then
        au_settings:AddCheckbox({
            ["label"] = "LID_WRONGPRIMARYSTAT",
            ["search"] = "WRONGPRIMARYSTAT",
            ["value"] = ArmoryUtils:GV(AUTAB, "WRONGPRIMARYSTAT", true),
            ["func"] = function(value)
                ArmoryUtils:SV(AUTAB, "WRONGPRIMARYSTAT", value)
                ArmoryUtils:PDUpdateItemInfos()
                if InspectFrame and InspectFrame:IsShown() then ArmoryUtils:IFUpdateItemInfos() end
            end
        })
    end

    au_settings:AddCategory({
        ["label"] = "LID_ENCHANTS",
        ["key"] = "ENCHANTS"
    })

    au_settings:AddCheckbox({
        ["label"] = "LID_ENCHANTONLYICON",
        ["search"] = "ENCHANTONLYICON",
        ["value"] = ArmoryUtils:GV(AUTAB, "ENCHANTONLYICON", true),
        ["func"] = function(value)
            ArmoryUtils:SV(AUTAB, "ENCHANTONLYICON", value)
            ArmoryUtils:PDUpdateItemInfos()
        end
    })

    au_settings:AddCategory({
        ["label"] = "LID_TEXTSIZES",
        ["key"] = "TEXTSIZES"
    })

    au_settings:AddSlider({
        ["label"] = "LID_ILVLFONTSIZE",
        ["search"] = "ILVLFONTSIZE",
        ["value"] = ArmoryUtils:GV(AUTAB, "ILVLFONTSIZE", DEFAULT_ILVLFONTSIZE),
        ["min"] = 6,
        ["max"] = 18,
        ["step"] = 1,
        ["decimals"] = 0,
        ["func"] = function(value)
            ArmoryUtils:SV(AUTAB, "ILVLFONTSIZE", value)
            ArmoryUtils:UpdateFonts()
        end
    })

    au_settings:AddSlider({
        ["label"] = "LID_SIDEFONTSIZE",
        ["search"] = "SIDEFONTSIZE",
        ["value"] = ArmoryUtils:GV(AUTAB, "SIDEFONTSIZE", DEFAULT_SIDEFONTSIZE),
        ["min"] = 6,
        ["max"] = 14,
        ["step"] = 1,
        ["decimals"] = 0,
        ["func"] = function(value)
            ArmoryUtils:SV(AUTAB, "SIDEFONTSIZE", value)
            ArmoryUtils:UpdateFonts()
        end
    })

    au_settings:AddCategory({
        ["label"] = "LID_TOOLTIP",
        ["key"] = "TOOLTIP"
    })

    au_settings:AddCheckbox({
        ["label"] = "LID_SHOWITEMLEVEL",
        ["search"] = "SHOWITEMLEVEL",
        ["value"] = ArmoryUtils:GV(AUTAB, "SHOWITEMLEVEL", true),
        ["func"] = function(value) ArmoryUtils:SV(AUTAB, "SHOWITEMLEVEL", value) end
    })

    au_settings:ResumeLayout()
end

local AUTABSetup = CreateFrame("FRAME", "AUTABSetup")
ArmoryUtils:RegisterEvent(AUTABSetup, "PLAYER_LOGIN")
AUTABSetup:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        AUTAB = AUTAB or {}
        ArmoryUtils:SetVersion(ICON, VERSION)
        ArmoryUtils:SetAddonOutput("ArmoryUtils", ICON)
        ArmoryUtils:CreateMinimapButton({
            ["name"] = "ArmoryUtils",
            ["icon"] = ICON,
            ["dbtab"] = AUTAB,
            ["dbkey"] = "SHOWMINIMAPBUTTON",
            ["vTT"] = {{format("|T%d:16:16:0:0|t ArmoryUtils", ICON), "v" .. ArmoryUtils:GetVersion()}, {ArmoryUtils:Trans("LID_LEFTCLICK"), ArmoryUtils:Trans("LID_OPENSETTINGS")}, {ArmoryUtils:Trans("LID_RIGHTCLICK"), ArmoryUtils:Trans("LID_HIDEMINIMAPBUTTON")}},
            ["funcL"] = function() ArmoryUtils:ToggleSettings() end,
            ["funcR"] = function()
                ArmoryUtils:SV(AUTAB, "SHOWMINIMAPBUTTON", false)
                ArmoryUtils:HideMMBtn("ArmoryUtils")
                ArmoryUtils:MSG("Minimap Button is now hidden.")
            end
        })

        ArmoryUtils:InitSettings()
    end
end)
