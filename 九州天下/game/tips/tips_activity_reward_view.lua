TipsActivityRewardView = TipsActivityRewardView or BaseClass(BaseView)

function TipsActivityRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips", "ActivityRewardTips"}
	self.item_list = {}
	self.data = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self:SetMaskBg(true)
end

function TipsActivityRewardView:__delete()

end

function TipsActivityRewardView:ReleaseCallBack()
	for i = 1, 6 do
		self.item_list[i]:DeleteMe()
	end
	self.item_list = {}
	self.reward_text = nil
	self.experience = nil
end

function TipsActivityRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickConfirm", BindTool.Bind(self.ClickConfirm, self))
	self.reward_text = self:FindVariable("RewardText")
	for i = 1, 6 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end
	self.experience = self:FindVariable("Experience")
end

function TipsActivityRewardView:CloseView()
	self:Close()
end

function TipsActivityRewardView:ClickConfirm()
	self:Close()
end


function TipsActivityRewardView:SetData(data, extra_data)
	self.data = data or {}
	self.extra_data = extra_data or {}
	self:Open()
	self:Flush()
end

function TipsActivityRewardView:OpenCallBack()

end

function TipsActivityRewardView:OnFlush()
	local reward_list = self.data.reward_list or {}

	for k,v in pairs(self.item_list) do
		v:SetData(reward_list[k])
		v:SetParentActive(reward_list[k] ~= nil)
	end
	local text = self.data.reward_text or ""
	self.reward_text:SetValue(text)
	self.experience:SetValue(self.extra_data.num)
end
