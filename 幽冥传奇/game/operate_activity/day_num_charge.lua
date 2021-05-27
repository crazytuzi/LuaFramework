	-- 天数充值界面
DayNumChargePage = DayNumChargePage or BaseClass()

function DayNumChargePage:__init()
	self.view = nil

end

function DayNumChargePage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end



function DayNumChargePage:InitPage(view)
	if self.view then return end
	
	self.view = view
	self.view.node_t_list.rich_day_charge_num.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- self.view.node_t_list.rich_day_num_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnDayNumChargeEvent()
end

function DayNumChargePage:InitEvent()
	if not self.day_num_recharge_event and not self.timer then
		self.day_num_recharge_event = GlobalEventSystem:Bind(OperateActivityEventType.DAY_NUM_RECHARGE_DATA_CHANGE, BindTool.Bind(self.OnDayNumChargeEvent, self))
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
	end
end

function DayNumChargePage:RemoveEvent()
	if self.day_num_recharge_event then
		GlobalEventSystem:UnBind(self.day_num_recharge_event)
		self.day_num_recharge_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function DayNumChargePage:CreateAwarInfoList()
	if not self.can_reward_avtivity_list then
		local ph = self.view.ph_list.ph_list_day_num
		self.can_reward_avtivity_list = ListView.New()
		self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateDayNumChargeRender, nil, nil, self.view.ph_list.ph_day_num_award_item)
		self.can_reward_avtivity_list:SetItemsInterval(10)

		self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_day_num_charge.node:addChild(self.can_reward_avtivity_list:GetView(), 20)
	end
end

function DayNumChargePage:OnDayNumChargeEvent()
	self:FlushTime()
	local num = OperateActivityData.Instance:GetDayRechargeNum()
	local content = string.format(Language.OperateActivity.DayNumTexts[4], num)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_day_charge_num.node, content)
	local data = OperateActivityData.Instance:GetDayNumRechargeData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function DayNumChargePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_time_6 then
		self.view.node_t_list.text_time_6.node:setString(time_str)
	end
end


function DayNumChargePage:RoleDataChangeCallback(key,value)
	-- if key == OBJ_ATTR.ACTOR_GOLD then
	-- 	self.view:Flush()
	-- end
	
end

function DayNumChargePage:UpdateData(param_t)
	-- local data = OperateActivityData.Instance:GetRechargeInfo()
	-- self.can_reward_avtivity_list:SetDataList(data)
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.DAY_NUM_CHARGE)
	local content = act_cfg and act_cfg.act_desc
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_day_num_des.node, content, 24, COLOR3B.YELLOW)
	
end


