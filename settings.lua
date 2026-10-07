local _, ArmoryUtils = ...
local ICON = 134952
local VERSION = "1.3.14"
local DEFAULT_WIDTH = 460
local DEFAULT_HEIGHT = 520
local DEFAULT_ILVLFONTSIZE = 11
local DEFAULT_SIDEFONTSIZE = 11
local au_settings = nil
ArmoryUtils.LANGUAGES = {{"English", "enUS"}, {"Deutsch", "deDE"}, {"Español (España)", "esES"}, {"Español (México)", "esMX"}, {"Français", "frFR"}, {"Italiano", "itIT"}, {"한국어", "koKR"}, {"Português (Brasil)", "ptBR"}, {"Русский", "ruRU"}, {"简体中文", "zhCN"}, {"繁體中文", "zhTW"}}
local languageNames = {}
for _, info in ipairs(ArmoryUtils.LANGUAGES) do
    languageNames[info[2]] = info[1]
end

function ArmoryUtils:GetLanguage()
    local lang = type(AUTAB) == "table" and AUTAB["LANGUAGE"] or nil
    if languageNames[lang] then return lang end
    return languageNames[GetLocale()] and GetLocale() or "enUS"
end

function ArmoryUtils:GetLanguageName()
    return languageNames[ArmoryUtils:GetLanguage()]
end

local LibTrans = ArmoryUtils.Trans
function ArmoryUtils:Trans(key, lang, ...)
    return LibTrans(self, key, lang or ArmoryUtils:GetLanguage(), ...)
end

function ArmoryUtils:SetLanguage(lang)
    if not languageNames[lang] or lang == ArmoryUtils:GetLanguage() or type(AUTAB) ~= "table" then return end
    AUTAB["LANGUAGE"] = lang ~= GetLocale() and lang or nil
    if not au_settings then return end
    for _, refresh in ipairs(au_settings.languageRefresh) do refresh() end
    au_settings.Language:SetText(ArmoryUtils:GetLanguageName())
    au_settings.search.Hint:SetText(ArmoryUtils:Trans("LID_SEARCH"))
    au_settings:Filter(au_settings.search:GetText())
end

local function AddLanguageSelector(window)
    window.languageRefresh = {}
    for _, method in ipairs({"AddCategory", "AddCheckbox", "AddSlider"}) do
        local add = window[method]
        window[method] = function(self, tab)
            local key = tab.label
            tab.label = ArmoryUtils:Trans(key)
            local widget = add(self, tab)
            local element = self.elements[#self.elements]
            local function Refresh()
                local text = ArmoryUtils:Trans(key)
                if method == "AddSlider" then
                    widget.Label:SetText(text .. ": " .. widget.slider:GetValue())
                else
                    widget.Label:SetText(text)
                end
                ArmoryUtils.UI:SetLabel(element, text)
            end
            if method == "AddSlider" then widget.slider:HookScript("OnValueChanged", Refresh) end
            table.insert(self.languageRefresh, Refresh)
            return widget
        end
    end

    function window.LanguageMenu(_, root)
        root:CreateTitle(ArmoryUtils:Trans("LID_LANGUAGE"))
        for _, info in ipairs(ArmoryUtils.LANGUAGES) do
            local lang = info[2]
            root:CreateRadio(format("%s (%s)", info[1], lang), function() return ArmoryUtils:GetLanguage() == lang end, function() ArmoryUtils:SetLanguage(lang) end)
        end
    end

    if ArmoryUtils:GetWoWBuild() == "RETAIL" and ArmoryUtils:CheckTemplates("WowStyle1DropdownTemplate") then
        window.Language = CreateFrame("DropdownButton", "ArmoryUtilsSettings_Language", window.titleBar or window, "WowStyle1DropdownTemplate")
        window.Language:SetScale(0.8)
        window.Language:SetSize(162.5, 25)
        window.Language:SetPoint("TOPLEFT", window.titleBar or window, "TOPLEFT", 10, -1.25)
        window.Language:SetSelectionText(function() return ArmoryUtils:GetLanguageName() end)
        window.Language:SetTooltip(function(tooltip) tooltip:SetText(ArmoryUtils:Trans("LID_LANGUAGE")) end)
        window.Language:SetupMenu(window.LanguageMenu)
    else
        window.Language = ArmoryUtils:CreateButton("ArmoryUtilsSettings_Language", window.titleBar or window)
        window.Language:SetSize(130, 20)
        window.Language:SetPoint("TOPLEFT", window.titleBar or window, "TOPLEFT", 7, -2)
        window.Language.Arrow = window.Language:CreateTexture(nil, "OVERLAY")
        window.Language.Arrow:SetTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
        window.Language.Arrow:SetSize(16, 16)
        window.Language.Arrow:SetPoint("RIGHT", window.Language, "RIGHT", -2, 0)
        window.Language:SetScript("OnClick", function(button)
            if MenuUtil and MenuUtil.CreateContextMenu then
                MenuUtil.CreateContextMenu(button, window.LanguageMenu)
            else
                local current = 1
                for i, info in ipairs(ArmoryUtils.LANGUAGES) do
                    if info[2] == ArmoryUtils:GetLanguage() then current = i end
                end
                ArmoryUtils:SetLanguage(ArmoryUtils.LANGUAGES[current % #ArmoryUtils.LANGUAGES + 1][2])
            end
        end)
        window.Language:SetScript("OnEnter", function(button)
            GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
            GameTooltip:SetText(ArmoryUtils:Trans("LID_LANGUAGE"))
            GameTooltip:Show()
        end)
        window.Language:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end
    window.Language:SetText(ArmoryUtils:GetLanguageName())
end
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
        ["escClose"] = false,
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

    AddLanguageSelector(au_settings)
    au_settings:EnableKeyboard(true)
    au_settings:SetPropagateKeyboardInput(true)
    au_settings:SetScript("OnKeyDown", function(window, key)
        if not InCombatLockdown() then window:SetPropagateKeyboardInput(key ~= "ESCAPE") end
        if key == "ESCAPE" then window:Hide() end
    end)

    au_settings:RegisterEvent("PLAYER_ENTERING_WORLD")
    au_settings:HookScript("OnEvent", function(window, event) if event == "PLAYER_ENTERING_WORLD" then window:Hide() end end)
    au_settings:SuspendLayout()
    au_settings:AddSearch({["label"] = ArmoryUtils:Trans("LID_SEARCH")})
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

    if ArmoryUtils:GetWoWBuild() == "RETAIL" and not ArmoryUtils:IsForever() then
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
