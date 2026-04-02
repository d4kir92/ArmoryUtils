local _, ArmoryUtils = ...
local auf = CreateFrame("Frame")
ArmoryUtils:RegisterEvent(auf, "PLAYER_LOGIN")
ArmoryUtils:OnEvent(
	auf,
	function()
		ArmoryUtils:UnregisterEvent(auf, "PLAYER_LOGIN")
		if AUTAB == nil then
			AUTAB = AUTAB or {}
		end

		ArmoryUtils:SetDbTab(AUTAB)
		ArmoryUtils:InitItemLevel()
		ArmoryUtils:AddSlash("arut", ArmoryUtils.ToggleSettings)
		ArmoryUtils:AddSlash("ArmoryUtils", ArmoryUtils.ToggleSettings)
	end, "ArmoryUtils"
)
