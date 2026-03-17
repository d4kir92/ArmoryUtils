local _, ArmoryUtils = ...
local auf = CreateFrame("Frame")
ArmoryUtils:RegisterEvent(auf, "PLAYER_LOGIN")
ArmoryUtils:OnEvent(
	auf,
	function()
		ArmoryUtils:UnregisterEvent(auf, "PLAYER_LOGIN")
		ArmoryUtils:SetAddonOutput("ArmoryUtils", 134952)
		ArmoryUtils:SetVersion(134952, "1.1.30")
		if AUTAB == nil then
			AUTAB = AUTAB or {}
		end

		ArmoryUtils:SetDbTab(AUTAB)
		ArmoryUtils:InitItemLevel()
		ArmoryUtils:AddSlash("arut", ArmoryUtils.ToggleSettings)
		ArmoryUtils:AddSlash("ArmoryUtils", ArmoryUtils.ToggleSettings)
		local mmbtn = nil
		ArmoryUtils:CreateMinimapButton(
			{
				["name"] = "ArmoryUtils",
				["icon"] = 134952,
				["var"] = mmbtn,
				["dbtab"] = AUTAB,
				["vTT"] = {{"|T134952:16:16:0:0|t ArmoryUtils v" .. ArmoryUtils:GetVersion()}, {ArmoryUtils:Trans("LID_LEFTCLICK"), ArmoryUtils:Trans("LID_OPENSETTINGS")}, {ArmoryUtils:Trans("LID_RIGHTCLICK"), ArmoryUtils:Trans("LID_HIDEMINIMAPBUTTON")}},
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
	end, "ArmoryUtils"
)
