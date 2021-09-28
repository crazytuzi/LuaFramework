TipsMoneyTreeRewardView = TipsMoneyTreeRewardView or BaseClass(BaseView)

function TipsMoneyTreeRewardView:__init()
	self.ui_config = {"uis/views/tips/rewardtips_prefab", "MoneyTreeRewardTips"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
	self.item_list = {}
end

function TipsMoneyTreeRewardView:__delete()
	for k,v in pairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TipsMoneyTreeRewardView:ReleaseCallBack()
	self.bind_coin = nil
	self.rank = nil
	self.show_rank = nil
end

function TipsMoneyTreeRewardView:CloseCallBack()

end

function TipsMoneyTreeRewardView:LoadCallBack()
	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickConfirm", BindTool.Bind(self.ClickConfirm, self))
	self.bind_coin = self:FindVariable("bind_coin")
	self.rank = self:FindVariable("rank")
	self.show_rank = self:FindVariable("show_rank")

	for i = 1, 2 do
		self.item_list[i] = ItemCell.New()
		self.item_list[i]:SetInstanceParent(self:FindObj("Item" .. i))
	end
end

function TipsMoneyTreeRewardView:CloseView()
	self:Close()
end

function TipsMoneyTreeRewardView:ClickConfirm()
	self:Close()
end

function TipsMoneyTreeRewardView:OpenCallBack()
	self:Flush()
end

function TipsMoneyTreeRewardView:OnFlush()
	local mojing_list = {}
	local bangyuan_list = {}
	local reward_list = GuildData.Instance:GetMoneyTreeReward()

	if nil == reward_list or nil == next(reward_list) then
		return
	end

	local rank = reward_list.rank_pos or 0
	local my_reward_list = {}

	if rank > 0 and rank <= 3 then
		self.show_rank:SetValue(true)
		self.rank:SetValue(Language.Guild.MoneyTreeRank[rank])
	end

	mojing_list.item_id = reward_list.reward_item_id
	mojing_list.num = reward_list.reward_item_num
	bangyuan_list.item_id = reward_list.reward_id_bigcoin
	bangyuan_list.num = reward_list.reward_num_bigcoin

	if reward_list.reward_item_num > 0 then
		table.insert(my_reward_list,mojing_list)
	end

	if reward_list.reward_num_bigcoin > 0 then
		table.insert(my_reward_list,bangyuan_list)
	end

	for k,v in pairs(self.item_list) do
		v:SetData(my_reward_list[k])
		v:SetParentActive(my_reward_list[k] ~= nil)
	end
end