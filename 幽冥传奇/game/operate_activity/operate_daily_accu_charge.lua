	-- 每日累计充值界面
OperateActDailyChargePage = OperateActDailyChargePage or BaseClass()

function OperateActDailyChargePage:__init()
	self.view = nil

end

function OperateActDailyChargePage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end



function OperateActDailyChargePage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnTimeLimitedRechargeEvent()
end

function OperateActDailyChargePage:InitEvent()
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_recharge_1.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self.time_limited_recharge_event = GlobalEventSystem:Bind(OperateActivityEventType.DAILY_ACCU_CHARGE_CHANGE, BindTool.Bind(self.OnTimeLimitedRechargeEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function OperateActDailyChargePage:RemoveEvent()
	if self.time_limited_recharge_event then
		GlobalEventSystem:UnBind(self.time_limited_recharge_event)
		self.time_limited_recharge_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OperateActDailyChargePage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_daily_recharge_item_list
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActDailyAccuChargeRender, nil, nil, self.view.ph_list.ph_daily_recharge_item)
	self.can_reward_avtivity_list:SetItemsInterval(10)

	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_daily_recharge.node:addChild(self.can_reward_avtivity_list:GetView(), 20)
end

function OperateActDailyChargePage:OnTimeLimitedRechargeEvent()
	self:FlushTime()
	local data = OperateActivityData.Instance:GetDailyRechargeData()
	local daily_charge_cnt = OperateActivityData.Instance:GetDailyRechargeMoney()
	self.view.node_t_list.txt_daily_recharge_num.node:setString(daily_charge_cnt)
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function OperateActDailyChargePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.DAILY_CHARGE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_daily_recharge_time then
		self.view.node_t_list.text_daily_recharge_time.node:setString(time_str)
	end
end

function OperateActDailyChargePage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function OperateActDailyChargePage:UpdateData(param_t)
	-- local data = OperateActivityData.Instance:GetRechargeInfo()
	-- self.can_reward_avtivity_list:SetDataList(data)
end


