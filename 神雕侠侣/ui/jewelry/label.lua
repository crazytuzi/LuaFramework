local prefix = "jewelry"
local function ShowJewelryLabel()
	local label = require "ui.label"
	local cur = label.getLabelById(prefix)
	if cur then
		return
	end
	local self = label.new(prefix)
	local utils = require "utils.mhsdutils"
	
	local dlgs = {require "ui.jewelry.ringmake", require "ui.jewelry.ringdecomposition",
		require "ui.jewelry.ringstrong"}
	
	self:InitButtons(utils.get_resstring(3001), utils.get_resstring(3002), 
		utils.get_resstring(3003))
		--, utils.get_resstring(3004)
	for i = 1, #dlgs do
		self.m_labels[i]:subscribeEvent("Clicked", function(e)
			for j = 1, #dlgs do
				if j == i then
					local dlg = dlgs[j]:GetSingletonDialogAndShowIt()
				else
					local dlg = dlgs[j]:getInstanceOrNot()
					if dlg then
						dlg:SetVisible(false)
					end
				end
			end
		end)
	end
	function self:OnClose()
		Dialog.OnClose(self)
		if self.prefix then
		--	local label = require "ui.label"
			label.RemoveLabel(prefix)
		end
		for i = 1, #dlgs do
			local dlg = dlgs[i]:getInstanceOrNot()
			if dlg then
				dlg:OnClose()
			end
		end
	end
	return self
end


return ShowJewelryLabel
