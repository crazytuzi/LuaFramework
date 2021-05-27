	-- 累计充值界面
OperateActAccumuChargePage = OperateActAccumuChargePage or BaseClass()

function OperateActAccumuChargePage:__init()
	self.view = nil

end

function OperateActAccumuChargePage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end



function OperateActAccumuChargePage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnTimeLimitedRechargeEvent()
end

function OperateActAccumuChargePage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_recharge_1.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self.time_limited_recharge_event = GlobalEventSystem:Bind(OperateActivityEventType.TIME_LIMITED_HEAP_RECHARGE_CHANGE, BindTool.Bind(self.OnTimeLimitedRechargeEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function OperateActAccumuChargePage:RemoveEvent()
	if self.time_limited_recharge_event then
		GlobalEventSystem:UnBind(self.time_limited_recharge_event)
		self.time_limited_recharge_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OperateActAccumuChargePage:CreateAwarInfoList()
	local ph = self.view.ph_list.scroll_recharge
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateActAccumuChargeRender, nil, nil, self.view.ph_list.ph_recharge_item)
	self.can_reward_avtivity_list:SetItemsInterval(10)

	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_recharge.node:addChild(self.can_reward_avtivity_list:GetView(), 20)
end

function OperateActAccumuChargePage:OnTimeLimitedRechargeEvent()
	self:FlushTime()
	local data = OperateActivityData.Instance:GetRechargeData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function OperateActAccumuChargePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ACCUMULATE_RECHARGE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_time_3 then
		self.view.node_t_list.text_time_3.node:setString(time_str)
	end
end

function OperateActAccumuChargePage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function OperateActAccumuChargePage:UpdateData(param_t)
	-- local data = OperateActivityData.Instance:GetRechargeInfo()
	-- self.can_reward_avtivity_list:SetDataList(data)
end


