TipsOtherHelpData = TipsOtherHelpData or BaseClass()

function TipsOtherHelpData:__init()
	if TipsOtherHelpData.Instance ~= nil then
		print_error("[TipsOtherHelpData] Attemp to create a singleton twice !")
	end
	TipsOtherHelpData.Instance = self

	-- 配置表数据
	self.tips_list = ConfigManager.Instance:GetAutoConfig("tips_all_auto").tips_list
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.is_auto_buy = false
end

function TipsOtherHelpData:__delete()
	TipsOtherHelpData.Instance = nil
end

function TipsOtherHelpData:GetTipsTextById(tips_id)
	local data = {}
	data = self.tips_list[tips_id]
	return data and data.text or ""
end

function TipsOtherHelpData:GetIsAutoBuy()
	return self.is_auto_buy
end

function TipsOtherHelpData:SetIsAutoBuy(is_auto_buy)
	self.is_auto_buy = is_auto_buy
end