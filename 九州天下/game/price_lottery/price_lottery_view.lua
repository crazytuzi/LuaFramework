TallPriceLotteryView = TallPriceLotteryView or BaseClass(BaseView)

function TallPriceLotteryView:__init()
	self.ui_config = {"uis/views/serveractivity/gaojiacaipiao", "PriceLottery"}
	self:SetMaskBg()
	self.chouma_reward = {}
end

function TallPriceLotteryView:LoadCallBack()
	self.residue_time = self:FindVariable("residue_time")			-- 活动剩余时间
	self.current_chouma = self:FindVariable("current_chouma")		-- 当前筹码Num
	self:ListenEvent("OnRecharBtn", BindTool.Bind(self.OnRecharBtn, self))	
	self:ListenEvent("explain_click", BindTool.Bind(self.ExplainClick, self))
	self:ListenEvent("close", BindTool.Bind(self.Close, self))
	self.cell_list = {}
	self:LoadInstanFindObj()
	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))	
end

function TallPriceLotteryView:ReleaseCallBack()
	self.residue_time = nil
	self.current_chouma = nil
	self.list_view = nil

	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end
	self.cell_list = {}

end

function TallPriceLotteryView:OnFlush()
	self.current_chouma:SetValue(TallPriceLotteryData.Instance:GetBetNum())
	self:FlushItemData()
end

function TallPriceLotteryView:ExplainClick()
	local tips_id = 256
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function TallPriceLotteryView:OpenCallBack()
	if self.time_quest == nil then
		self.time_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.FlushNextTime, self), 1)
		self:FlushNextTime()
	end
		TallPriceLotteryCtrl.Instance:SendLotteryInfo(0, 0)

end

function TallPriceLotteryView:CloseCallBack()
	if self.time_quest then
		GlobalTimerQuest:CancelQuest(self.time_quest)
		self.time_quest = nil
	end
end

function TallPriceLotteryView:FlushNextTime()
	local time = ActivityData.Instance:GetActivityResidueTime(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_LOTTERY)
	if time <= 0 then
		if self.time_quest then
			GlobalTimerQuest:CancelQuest(self.time_quest)
			self.time_quest = nil
		end
	end
	self.residue_time:SetValue(TimeUtil.FormatSecond2DHMS(time, 1))
end

function TallPriceLotteryView:LoadInstanFindObj()
	for i = 1, 6 do
		PrefabPool.Instance:Load(AssetID("uis/views/serveractivity/gaojiacaipiao_prefab", "item1"), function (prefab)
			if nil == prefab then
				return
			end		
			local obj = GameObject.Instantiate(prefab)
			local obj_transform = obj.transform
			local parentobj = self:FindObj("cellitem" .. i)
			obj_transform:SetParent(parentobj.transform)
			obj_transform.localScale = Vector3(1, 1, 1)
			obj_transform.localPosition = Vector3(0, 0, 0)
			local item = ChipRewardItem.New(obj)
			table.insert(self.cell_list, item)
			PrefabPool.Instance:Free(prefab)

			self:Flush()
		end)
	end		
end

function TallPriceLotteryView:FlushItemData()
	local reward_seq = TallPriceLotteryData.Instance:GetRewardSeq()
	local present_bet_num = TallPriceLotteryData.Instance:GetRewardBetNum()		
	for i = 1, 6 do
		local get_reward_cfg = TallPriceLotteryData.Instance:GetLotteryRewardLotteryCfg(reward_seq[i])
		if get_reward_cfg and get_reward_cfg.reward_item then 
			if self.cell_list[i] then
				self.cell_list[i]:SetData(get_reward_cfg.reward_item)
				self.cell_list[i]:SetInfoData(present_bet_num[i])
				self.cell_list[i]:SetAllChip(get_reward_cfg.most_votes)
				self.cell_list[i]:SetIndex(i)
			end
		end
	end
end

function TallPriceLotteryView:OnRecharBtn()
	ViewManager.Instance:Open(ViewName.RechargeView)
end
----------------------------------------------------------------
--  筹码Item
----------------------------------------------------------------
ChipRewardItem = ChipRewardItem or BaseClass(BaseCell)

function ChipRewardItem:__init(instance)
	self.present_bet_num = self:FindVariable("present_bet_num")	-- 当前投注数
	self.all_bet_num = self:FindVariable("all_bet_num")			-- 总共投注数			
	self:ListenEvent("betclick", BindTool.Bind(self.BetClick, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("reward_item"))
end

function ChipRewardItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function ChipRewardItem:OnFlush()
	if not next(self.data) then return end
	self.item_cell:SetData(self.data)	
end

function ChipRewardItem:BetClick()
	local data = {}
	data.param_1 = self.index
	local all_bet_num = TallPriceLotteryData.Instance:GetBetNum()
	local reward_seq = TallPriceLotteryData.Instance:GetRewardSeq()
	local get_reward_cfg = TallPriceLotteryData.Instance:GetLotteryRewardLotteryCfg(reward_seq[self.index])	
	local present_bet_num_list = TallPriceLotteryData.Instance:GetRankBetNum()	
	local all_present_bet_num = 0
	for i, v in ipairs(present_bet_num_list) do
		all_present_bet_num = all_present_bet_num + v
	end
	local all_bet = get_reward_cfg.most_votes - all_present_bet_num
	local bet_num = 0
	if all_bet > 0 then
		if all_bet <= all_bet_num then
			bet_num = all_bet
		else
			bet_num = all_bet_num
		end
	else
		bet_num = all_bet_num	
	end
	TipsCtrl.Instance:OpenCommonInputView(0, nil, nil, bet_num, nil, true, data)
end

function ChipRewardItem:SetInfoData(present_bet_num)
	self.present_bet_num:SetValue(present_bet_num)
end

function ChipRewardItem:SetAllChip(most_votes)
	self.all_bet_num:SetValue(most_votes)
end