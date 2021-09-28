--------------------------------------------------------------------------
--TimeLimitGiftView 	限时礼包总面板
--------------------------------------------------------------------------

TimeLimitGiftView = TimeLimitGiftView or BaseClass(BaseView)

function TimeLimitGiftView:__init()
	self.ui_config = {"uis/views/timelimitgiftview_prefab", "TimeLimitGiftView"}
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function TimeLimitGiftView:__delete()
	-- body
end

function TimeLimitGiftView:LoadCallBack()

	local cfg = TimeLimitGiftData.Instance:GetLimitGiftCfg()
	self.show_info_list = cfg.reward_item
	self.show_info_list_seq = cfg.seq
	self.limit_time	= cfg.limit_time
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
	--self.ButtonGetReward:SetActive(false)
	self.ButtonRecharge = self:FindObj("ButtonRecharge")
	--self.ButtonGetReward:SetActive(true)
	self.res_time = self:FindVariable("res_time")

	self.is_get = self:FindVariable("is_get")
	self.is_able_get = self:FindVariable("is_able_get")

	self.CostText = self:FindVariable("CostText")
	self.DiamondTip = self:FindVariable("DiamondTip")
	self.MoneyTip = self:FindVariable("MoneyTip")
	local Ctext = string.format(648)
	local Dtext = string.format(6480)
	self.CostText:SetValue(Ctext)
	self.DiamondTip:SetValue(Dtext)
	local Mtext = string.format(2699)
	self.MoneyTip:SetValue(Mtext)
	if cfg.charge_value == nil then

		local Ctext = string.format(648)
		local Dtext = string.format(6480)
		self.CostText:SetValue(Ctext)
		self.DiamondTip:SetValue(Dtext)
	else
		local Ctext = string.format(cfg.charge_value)
		local Dtext = string.format(cfg.charge_value)
		self.CostText:SetValue(Ctext)
		self.DiamondTip:SetValue(Dtext)
	end

	if cfg.gift_value == nil then
		local Mtext = string.format(2699)
		self.MoneyTip:SetValue(Mtext)
	else
		local Mtext = string.format(cfg.gift_value)
		self.MoneyTip:SetValue(Mtext)
	end

	self.EndTime = 0;

end

--释放回调
function TimeLimitGiftView:ReleaseCallBack()

	self.reward_cell_list = {}
	self.ButtonGetReward = nil
	self.ButtonRecharge = nil
	self.res_time = nil
	self.CostText = nil
	self.DiamondTip = nil
	self.MoneyTip = nil

	self.is_get = nil
	self.is_able_get = nil
	self.show_info_list = nil
	self.reward_can_fetch_flag = nil
	self.EndTime = nil;

end

function TimeLimitGiftView:OnFlush()

	self.reward_can_fetch_flag = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().reward_can_fetch_flag
	self.reward_fetch_flag = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().reward_fetch_flag
	self.open_flag = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().open_flag
	if self.reward_fetch_flag == 0 and self.reward_can_fetch_flag > 0 then
		self.ButtonGetReward:SetActive(true)
		self.ButtonRecharge:SetActive(false)
	end

	if self.reward_fetch_flag == 0 and self.reward_can_fetch_flag == 0 then
		self.ButtonGetReward:SetActive(false)
		self.ButtonRecharge:SetActive(true)
	end

	if self.reward_fetch_flag ~= 0 then
		self.ButtonGetReward:SetActive(false)
		self.ButtonRecharge:SetActive(false)
	end

end

--关闭页面
function TimeLimitGiftView:CloseView()
	self:Close()
end

--点击充值按钮
function TimeLimitGiftView:ClickRecharge()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
	self:Close()
end

--设置时间
function TimeLimitGiftView:SetTime(time)
	time_tab = TimeUtil.Format2TableDHMS(time)
	local str = string.format(Language.TimeLimitGift.ResTime, time_tab.hour, time_tab.min, time_tab.s)
	--local str = string.format(Language.IncreaseCapablity.ResTime, time_tab.hour, time_tab.min, time_tab.s)
	self.res_time:SetValue(str)
end

--打开回调函数
function TimeLimitGiftView:OpenCallBack()
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
				RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO)
	self.reward_can_fetch_flag = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().reward_can_fetch_flag
	self.reward_fetch_flag = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().reward_fetch_flag
	self.begin_timestamp = TimeLimitGiftData.Instance:GetTimeLimitGiftInfo().begin_timestamp
	self.EndTime = self.begin_timestamp + self.limit_time
	if self.reward_fetch_flag ~= 1 and self.reward_can_fetch_flag > 0 then
		self.ButtonGetReward:SetActive(true)
	end

	if self.reward_fetch_flag == 1 and self.reward_can_fetch_flag == 0 then
		self.ButtonGetReward:SetActive(false)
		self.ButtonRecharge:SetActive(false)
	end

	if self.least_time_timer then
		CountDown.Instance:RemoveCountDown(self.least_time_timer)
		self.least_time_timer = nil
	end

	local rest_time = self.EndTime - TimeCtrl.Instance:GetServerTime()
	self:SetTime(rest_time)
    if rest_time >= 0 then
		self.least_time_timer = CountDown.Instance:AddCountDown(rest_time, 1, function ()
				rest_time = rest_time - 1
				self:SetTime(rest_time)
		end)
	end
end

--关闭回调函数
function TimeLimitGiftView:CloseCallBack()
	if self.least_time_timer then
        CountDown.Instance:RemoveCountDown(self.least_time_timer)
        self.least_time_timer = nil
    end

end

--点击领取礼包
function TimeLimitGiftView:ClickGetReward()
	self.ButtonGetReward:SetActive(false)
   	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
				RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_FETCH_REWARD,
				self.show_info_list_seq)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_TIME_LIMIT_GIFT,
				RA_TIMELIMIT_GIFT_OPERA_TYPE.RA_TIMELIMIT_GIFT_OPERA_TYPE_QUERY_INFO)
	self:CloseViewEver()
end

--领取完礼包后界面不再出现
function  TimeLimitGiftView:CloseViewEver()
	--调用关闭页面函数
	self:CloseView()

end