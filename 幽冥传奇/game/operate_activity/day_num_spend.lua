	-- 天天消费界面
DayNumSpendPage = DayNumSpendPage or BaseClass()

function DayNumSpendPage:__init()
	self.view = nil

end

function DayNumSpendPage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end



function DayNumSpendPage:InitPage(view)
	if self.view then return end
	
	self.view = view
	self.view.node_t_list.rich_day_num_spend_num.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.view.node_t_list.rich_day_num_spend_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnDayNumSpendEvent()
end

function DayNumSpendPage:InitEvent()
	if not self.day_num_spend_event and not self.timer then
		self.day_num_spend_event = GlobalEventSystem:Bind(OperateActivityEventType.DAY_NUM_SPEND_CHANGE, BindTool.Bind(self.OnDayNumSpendEvent, self))
		self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
	end
end

function DayNumSpendPage:RemoveEvent()
	if self.day_num_spend_event then
		GlobalEventSystem:UnBind(self.day_num_spend_event)
		self.day_num_spend_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function DayNumSpendPage:CreateAwarInfoList()
	if not self.can_reward_avtivity_list then
		local ph = self.view.ph_list.ph_list_day_num_spend
		self.can_reward_avtivity_list = ListView.New()
		self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperateDayNumSpendRender, nil, nil, self.view.ph_list.ph_day_num_spend_award_item)
		self.can_reward_avtivity_list:SetItemsInterval(10)

		self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_day_num_spend.node:addChild(self.can_reward_avtivity_list:GetView(), 20)
	end
end

function DayNumSpendPage:OnDayNumSpendEvent()
	self:FlushTime()
	local num = OperateActivityData.Instance:GetDaySpendNum()
	local content = string.format(Language.OperateActivity.DayNumTexts[7], num)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_day_num_spend_num.node, content)
	local data = OperateActivityData.Instance:GetDayNumSpendData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function DayNumSpendPage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.DAY_NUM_SPEND)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_day_num_spend_time then
		self.view.node_t_list.text_day_num_spend_time.node:setString(time_str)
	end
end


function DayNumSpendPage:RoleDataChangeCallback(key,value)
	-- if key == OBJ_ATTR.ACTOR_GOLD then
	-- 	self.view:Flush()
	-- end
	
end

function DayNumSpendPage:UpdateData(param_t)
	-- local data = OperateActivityData.Instance:GetRechargeInfo()
	-- self.can_reward_avtivity_list:SetDataList(data)
	local act_cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.DAY_NUM_SPEND)
	local content = act_cfg and act_cfg.act_desc
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_day_num_spend_des.node, content, 20, COLOR3B.GREEN)
	
end


