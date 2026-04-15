local _, ArmoryUtils = ...
local AUTABSetup = CreateFrame("FRAME", "AUTABSetup")
ArmoryUtils:RegisterEvent(AUTABSetup, "PLAYER_LOGIN")
AUTABSetup:SetScript(
    "OnEvent",
    function(self, event, ...)
        if event == "PLAYER_LOGIN" then
            AUTAB = AUTAB or {}
            ArmoryUtils:SetVersion(134952, "1.1.51")
            ArmoryUtils:SetAddonOutput("ArmoryUtils", 134952)
            local mmbtn = nil
            ArmoryUtils:CreateMinimapButton(
                {
                    ["name"] = "ArmoryUtils",
                    ["icon"] = 134952,
                    ["var"] = mmbtn,
                    ["dbtab"] = AUTAB,
                    ["vTT"] = {{"ArmoryUtils", "v" .. ArmoryUtils:GetVersion()}, {ArmoryUtils:Trans("LID_LEFTCLICK"), ArmoryUtils:Trans("LID_OPENSETTINGS")}, {ArmoryUtils:Trans("LID_RIGHTCLICK"), ArmoryUtils:Trans("LID_HIDEMINIMAPBUTTON")}},
                    ["funcL"] = function()
                        ArmoryUtils:ToggleSettings()
                    end,
                    ["funcR"] = function()
                        ArmoryUtils:SV(AUTAB, "SHOWMINIMAPBUTTON", false)
                        ArmoryUtils:HideMMBtn("ArmoryUtils")
                        ArmoryUtils:MSG("Minimap Button is now hidden.")
                    end,
                    ["dbkey"] = "SHOWMINIMAPBUTTON"
                }
            )

            ArmoryUtils:InitSettings()
        end
    end
)

local au_settings = nil
function ArmoryUtils:ToggleSettings()
    if au_settings then
        if au_settings:IsShown() then
            au_settings:Hide()
        else
            au_settings:Show()
        end
    end
end

function ArmoryUtils:InitSettings()
    AUTAB = AUTAB or {}
    au_settings = ArmoryUtils:CreateWindow(
        {
            ["name"] = "ArmoryUtils",
            ["pTab"] = {"CENTER"},
            ["sw"] = 520,
            ["sh"] = 520,
            ["title"] = format("ArmoryUtils v%s", ArmoryUtils:GetVersion())
        }
    )

    local x = 15
    local y = 10
    ArmoryUtils:SetAppendX(x)
    ArmoryUtils:SetAppendY(y)
    ArmoryUtils:SetAppendParent(au_settings)
    ArmoryUtils:SetAppendTab(AUTAB)
    ArmoryUtils:AppendCategory("GENERAL")
    ArmoryUtils:AppendCheckbox(
        "SHOWMINIMAPBUTTON",
        ArmoryUtils:GetWoWBuild() ~= "RETAIL",
        function()
            if ArmoryUtils:GV(AUTAB, "SHOWMINIMAPBUTTON", ArmoryUtils:GetWoWBuild() ~= "RETAIL") then
                ArmoryUtils:ShowMMBtn("ArmoryUtils")
            else
                ArmoryUtils:HideMMBtn("ArmoryUtils")
            end
        end
    )

    ArmoryUtils:AppendCategory("TOOLTIP")
    ArmoryUtils:AppendCheckbox("SHOWITEMLEVEL", true)
end
