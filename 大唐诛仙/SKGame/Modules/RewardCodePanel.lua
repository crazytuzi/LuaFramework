RewardCodePanel = BaseClass(LuaUI)
function RewardCodePanel:__init( ... )
	self.URL = "ui://7hqeitv8kbgf8";
	self:__property(...)
	self:InitEvent()
	self:Config()
end
-- Set self property
function RewardCodePanel:SetProperty( ... )
end
-- start
function RewardCodePanel:Config()
	
end

function RewardCodePanel:InitEvent()
	self.btnQD.onClick:Add(function()
		local input = self.txtShuru.text
		if input == "" then
			Message:GetInstance():TipsMsg("请输入激活码")
		else
			RewardCodeCtrl:GetInstance():C_GetGiftAward(input)
		end
	end)
end

-- wrap UI to lua
function RewardCodePanel:RegistUI( ui )
	self.ui = ui or self.ui or UIPackage.CreateObject("RewardCode","CodePanel");

	self.txtShuru = self.ui:GetChild("txtShuru")
	self.btnQD = self.ui:GetChild("btnQD")
end
-- Combining existing UI generates a class
function RewardCodePanel.Create( ui, ...)
	return RewardCodePanel.New(ui, "#", {...})
end
function RewardCodePanel:__delete()
	
end