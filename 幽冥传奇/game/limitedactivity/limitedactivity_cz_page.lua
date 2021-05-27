	-- 累计充值界面
LimitedActivityCzPage = LimitedActivityCzPage or BaseClass()

function LimitedActivityCzPage:__init()
	self.view = nil
	self.page = nil

end

function LimitedActivityCzPage:__delete()
	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end
end



function LimitedActivityCzPage:InitPage(view)
	self.view = view

	local ph = self.view.ph_list.scroll_recharge
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActivityRewardRender, nil, nil, self.view.ph_list.ph_recharge_item)
	self.can_reward_avtivity_list:SetItemsInterval(10)

	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.can_reward_avtivity_list:SetSelectCallBack(BindTool.Bind(self.SelectRewardListCallback, self))
	self.view.node_t_list.layout_recharge.node:addChild(self.can_reward_avtivity_list:GetView(), 20)

	self.view.node_t_list.active_btn1.node:addClickEventListener(BindTool.Bind(self.OnClickChongzhiHandler, self))

	self.select_index = 1
	self:InitEvent()
	self:OnTimeLimitedRechargeEvent()
end

function LimitedActivityCzPage:OnClickChongzhiHandler()
	
end

function LimitedActivityCzPage:SelectRewardListCallback(item, index)

end

function LimitedActivityCzPage:InitEvent()
	self.time_limited_recharge_event = GlobalEventSystem:Bind(OtherEventType.TIME_LIMITED_HEAP_RECHARGE_CHANGE, BindTool.Bind(self.OnTimeLimitedRechargeEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 60)
end

function LimitedActivityCzPage:RemoveEvent()
	if self.time_limited_recharge_event then
		GlobalEventSystem:UnBind(self.time_limited_recharge_event)
		self.time_limited_recharge_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function LimitedActivityCzPage:OnTimeLimitedRechargeEvent()
	self:FlushTime()
end

-- 倒计时
function LimitedActivityCzPage:FlushTime()
	local time = LimitedActivityData.Instance:GetRewardDaojishi()
	if not time then 
		return
	end
	time = math.floor(time - Status.NowTime)
	if time < 1 then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end

	local day = math.floor(time / (24 * 3600))
	local hour = math.floor((time / (60 * 60)) % 24)
	local minute = math.floor((time / 60) % 60)
	if self.view.node_t_list.text_time_3 then
		self.view.node_t_list.text_time_3.node:setString(string.format(Language.Limited.Time, day, hour, minute))
	end
end


function LimitedActivityCzPage:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		self.view:Flush()
	end
	
end

function LimitedActivityCzPage:UpdateData(param_t)
	local data = LimitedActivityData.Instance:GetChargeCfg()
	self.can_reward_avtivity_list:SetDataList(data)
end


ActivityRewardRender = ActivityRewardRender or BaseClass(BaseRender)

function ActivityRewardRender:__init()

end

function ActivityRewardRender:__delete()
	for k,v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ActivityRewardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1)*85, ph.y)
		equip_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function ActivityRewardRender:OnFlush()

	if nil == self.data then return end
	if self.data.state == 0 then
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local my_money = LimitedActivityData.Instance:GetRewardMoney()
		local need_money = self.data.money - my_money
		local txt_1 = string.format(Language.Limited.Need, need_money)
		self.node_tree.layout_nodabiao.txt_need_name.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_reward.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_reward.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		self.cell_list[k]:SetData(v)
	end
	
	local txt = string.format(Language.Limited.Reward, self.data.money)
	self.node_tree.txt_name.node:setString(txt)

end

function ActivityRewardRender:CreateSelectEffect()

end

function ActivityRewardRender:GetReward()
	LimitedActivityCtrl.Instance:SendCzGetGiftReq(self.index)
end