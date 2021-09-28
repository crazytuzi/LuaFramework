TipsActivityRewardView = TipsActivityRewardView or BaseClass(BaseView)

function TipsActivityRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips_prefab", "ActivityRewardTips"}
	self.baseitem_list = {}
	self.myitem_list = {}
	self.data = {}
	self.mydata = {}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.id = 0
	self.index = 0
	self.staus = 0
end

function TipsActivityRewardView:__delete()
	self.data_list = nil
	for k, v in pairs(self.baseitem_list) do
		v:DeleteMe()
	end
	self.baseitem_list = {}

	for k,v in pairs(self.myitem_list) do
		v:DeleteMe()
	end
	self.myitem_list = {}
end

function TipsActivityRewardView:ReleaseCallBack()
	self.reward_text = nil
	self.title_id = nil
	self.show_myreward = nil
	self.str_result = nil
	self.str_reward = nil
	self.showtext = nil
end

function TipsActivityRewardView:CloseCallBack()
	if self.ok_callback then
		self.ok_callback()
	end

end

function TipsActivityRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickConfirm", BindTool.Bind(self.ClickConfirm, self))
	self.reward_text = self:FindVariable("RewardText")
	self.title_id = self:FindVariable("TitleID")
	self.show_myreward = self:FindVariable("ShowMyReward")
	self.str_result = self:FindVariable("strResult")
	self.str_reward = self:FindVariable("strReward")
	self.showtext = self:FindVariable("ShowText")
	for i = 1, 10 do
		self.baseitem_list[i] = ItemCell.New()
		self.baseitem_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end

	for i = 1, 4 do
		self.myitem_list[i] = ItemCell.New()
		self.myitem_list[i]:SetInstanceParent(self:FindObj("MyItem" .. i))
	end
end

function TipsActivityRewardView:CloseView()
	self:Close()
end

function TipsActivityRewardView:ClickConfirm()
	self:Close()
end

function TipsActivityRewardView:SetData(data, id, ok_callback)
	self.id = id or 0
	self.staus = 0
	self.data = data or {}
	self.ok_callback = ok_callback
	self:Open()
	self:Flush()
end

function TipsActivityRewardView:SetData2(data, data2, res, id, ok_callback)
	self.id = id or 0
	self.staus = 1
	self.index = res or 0
	self.data = data or {}
	self.mydata = data2 or {}
	self.ok_callback = ok_callback
	self:Open()
	self:Flush()
end

function TipsActivityRewardView:OpenCallBack()

end

function TipsActivityRewardView:OnFlush()

	local reward_list = self.data or {}
	local my_list = self.mydata.reward_item or {}
	for k,v in pairs(self.baseitem_list) do
		v:SetData(reward_list[k])
		v:SetParentActive(reward_list[k] ~= nil)
	end

	if self.index ~= 0 then
		self.str_result:SetValue("第"..self.index.."名")
	end
	
	if self.staus == 0 then
		self.showtext:SetValue(false)
		self.str_reward:SetValue("")
	else
		self.showtext:SetValue(true)
		self.str_reward:SetValue(Language.FuBen.Reward1)
	end

	for k,v in pairs(self.myitem_list) do
		v:SetData(my_list[k])
		v:SetParentActive(my_list[k] ~= nil)
	end

	if my_list[1] then
		self.show_myreward:SetValue(true)
	else
		self.show_myreward:SetValue(false)
	end

	local text = self.data.reward_text or ""
	self.reward_text:SetValue(text)
	self.title_id:SetValue(self.id)
end