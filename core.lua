local _, ArmoryUtils = ...
local auf = CreateFrame("Frame")
ArmoryUtils:RegisterEvent(auf, "PLAYER_LOGIN")
ArmoryUtils:OnEvent(
	auf,
	function()
		ArmoryUtils:UnregisterEvent(auf, "PLAYER_LOGIN")
		ArmoryUtils:SetAddonOutput("ArmoryUtils", 134952)
		ArmoryUtils:SetVersion(134952, "1.1.1")
		if AUTAB == nil then
			AUTAB = AUTAB or {}
		end

		ArmoryUtils:SetDbTab(AUTAB)
		ArmoryUtils:InitItemLevel()
	end, "ArmoryUtils"
)
--[[
	AddCategory("ITEMLEVEL")
	AddCheckBox(4, "ITEMLEVELSYSTEM")
	AddCheckBox(24, "ITEMLEVELSYSTEMSIDEWAYS", true)
	AddCheckBox(24, "ITEMLEVELNUMBER", false, ImproveAny.UpdateILVLIcons)
	AddCheckBox(24, "ITEMLEVELBORDER", false, ImproveAny.UpdateILVLIcons)
]]
