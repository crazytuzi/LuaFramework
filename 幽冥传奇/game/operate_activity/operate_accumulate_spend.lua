-- 累计消费界面
OperateActAccumuSpendPage = OperateActAccumuSpendPage or BaseClass()

function OperateActAccumuSpendPage:__init()
	self.view = nil

end

function OperateActAccumuSpendPage:__delete()
	self:RemoveEvent()
	if self.can_consume_avtivity_list then
		self.can_consume_avtivity_list:DeleteMe()
		self.can_consume_avtivity_list = nil
	end

	self.view = nil
end



function OperateActAccumuSpendPage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnTimeLimitedConsumeEvent()
end

function OperateActAccumuSpendPage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_recharge_2.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self.time_limited_consume_event  = GlobalEventSystem:Bind(OperateActivityEventType.TIME_LIMITED_HEAP_CONSUME_CHANGE, BindTool.Bind(self.OnTimeLimitedConsumeEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self),  1)
end

function OperateActAccumuSpendPage:RemoveEvent()
	if self.time_limited_consume_event then
		GlobalEventSystem:UnBind(self.time_limited_consume_event)
		self.time_limited_consume_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OperateActAccumuSpendPage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_item_list
	self.can_consume_avtivity_list = ListView.New()
	self.can_consume_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateAccumuSpendRender, nil, nil, self.view.ph_list.ph_spend_item)
	self.can_consume_avtivity_list:SetItemsInterval(10)

	self.can_consume_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_consume.node:addChild(self.can_consume_avtivity_list:GetView(), 20)
end

function OperateActAccumuSpendPage:OnTimeLimitedConsumeEvent()
	local data = OperateActivityData.Instance:GetConsumeData()
	self.can_consume_avtivity_list:SetDataList(data)
	self:FlushTime()
end

function OperateActAccumuSpendPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.ACCUMULATE_SPEND)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_time_2 then
		self.view.node_t_list.text_time_2.node:setString(time_str)
	end

end

function OperateActAccumuSpendPage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function OperateActAccumuSpendPage:UpdateData()
	-- local data = OperateActivityData.Instance:GetConsumeCfg()
	-- self.can_consume_avtivity_list:SetDataList(data)
end


