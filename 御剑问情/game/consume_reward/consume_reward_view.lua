ConsumeRewardView = ConsumeRewardView or BaseClass(BaseView)

function ConsumeRewardView:__init()
	self.ui_config = {"uis/views/consumereward_prefab", "ConsumeRewardView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function ConsumeRewardView:__delete()
	-- body
end

function ConsumeRewardView:LoadCallBack()
	local cfg = ConsumeRewardData.Instance:GetRewardGiftCfg()
	self.show_info_list = cfg.reward_item
	self.item_cell_list = {}
	for i = 1, 3 do
		self.item_cell_list[i] = self:FindObj("Item"..i)


		if nil ~= self.item_cell_list[i] then
			local item_cell = ItemCell.New()
			--设置位置
			item_cell:SetInstanceParent(self.item_cell_list[i])
			--设置奖励
			local cfg_index = i - 1
			item_cell:SetData(self.show_info_list[cfg_index])
		end
	end

	self:ListenEvent("CloseView", BindTool.Bind(self.CloseView, self))
	self:ListenEvent("ClickRecharge", BindTool.Bind(self.ClickRecharge, self))
	self:ListenEvent("ClickGetReward", BindTool.Bind(self.ClickGetReward, self))

	self.ButtonGetReward = self:FindObj("ButtonGetReward")
	self.ButtonGetReward:SetActive(true)
	self.is_reward = self:FindVariable("IsReward")
	self.ButtonConsume = self:FindObj("ButtonConsume")
	self.res_time = self:FindVariable("res_time")
	self.CostText = self:FindVariable("CostText")
end

--释放回调
function ConsumeRewardView:ReleaseCallBack()
	self.ButtonGetReward = nil
	self.ButtonConsume = nil
	self.is_reward = nil
	self.res_time = nil
	self.CostText = nil
	self.show_info_list = nil
	self.fetch_reward_flag = nil
	self.consume_gold = nil
end

function ConsumeRewardView:OnFlush()
	local consume_reward_info = ConsumeRewardData.Instance:GetRewardGiftInfo()
	if not consume_reward_info then
		return
	end
    
	self.consume_gold = consume_reward_info.consume_gold or 0
	self.fetch_reward_flag = consume_reward_info.fetch_reward_flag or 1
	local cfg = ConsumeRewardData.Instance:GetRewardGiftCfg()
	if not cfg or not cfg.consume_gold then
		return
    end
    
    local consume_gold = cfg.consume_gold
	if self.fetch_reward_flag == 0 and self.consume_gold >= consume_gold then
		self.ButtonGetReward:SetActive(true)
		self.ButtonConsume:SetActive(false)
	end

	if self.fetch_reward_flag == 0 and self.consume_gold < consume_gold  then
		self.ButtonGetReward:SetActive(false)
		self.ButtonConsume:SetActive(true)
	end

	if self.fetch_reward_flag ~= 0 then
		self.is_reward:SetValue(true)
		self.ButtonConsume:SetActive(false)
	end

	if cfg.consume_gold == nil or cfg.consume_gold - self.consume_gold <= 0 then
		local Ctext = string.format(0)
		self.CostText:SetValue(Ctext)
	else
		local Ctext = string.format(cfg.consume_gold - self.consume_gold)
		self.CostText:SetValue(Ctext)
	end

end

--关闭页面
function ConsumeRewardView:CloseView()
	self:Close()
end

--点击消费按钮
function ConsumeRewardView:ClickRecharge()
	self:CloseView()
	ViewManager.Instance:Open(ViewName.Shop)
end

--设置时间
function ConsumeRewardView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = ""
	if time_tab.day and time_tab.day >=1 then
	    str = string.format(Language.ConsumeReward.ResTime, time_tab.day, time_tab.hour, time_tab.min, time_tab.s)
    else
    	str = string.format(Language.ConsumeReward.ResTime2, time_tab.hour, time_tab.min, time_tab.s)
    end

	self.res_time:SetValue(str)
end

function ConsumeRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

end

--打开回调函数
function ConsumeRewardView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
			RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO)
	local activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI
	local time_tab = ActivityData.Instance:GetActivityResidueTime(activity_type)
	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	if time_tab >= 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(time_tab, 1, function ()
				time_tab = time_tab - 1
				self:SetTime(time_tab)
		end)
	end

end

--关闭回调函数
function ConsumeRewardView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

end

--点击领取礼包
function ConsumeRewardView:ClickGetReward()
    if self.fetch_reward_flag >= 1 then
        return
    end
   	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
				RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_FETCH)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_CONSUME_GOLD_FANLI,
				RA_CONSUME_GOLD_REWARD_OPERATE_TYPE.RA_CONSUME_GOLD_REWARD_OPERATE_TYPE_INFO)
	self:CloseViewEver()
end

--领取完礼包后界面不再出现
function  ConsumeRewardView:CloseViewEver()
	--调用关闭页面函数
	self:CloseView()
end