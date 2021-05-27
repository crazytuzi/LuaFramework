-- 累计消费界面
LimitedActivityXfPage = LimitedActivityXfPage or BaseClass()

function LimitedActivityXfPage:__init()
	self.view = nil
	self.page = nil

end

function LimitedActivityXfPage:__delete()
	if self.can_consume_avtivity_list then
		self.can_consume_avtivity_list:DeleteMe()
		self.can_consume_avtivity_list = nil
	end
end



function LimitedActivityXfPage:InitPage(view)
	self.view = view

	local ph = self.view.ph_list.ph_item_list
	self.can_consume_avtivity_list = ListView.New()
	self.can_consume_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ActivityConsumeRender, nil, nil, self.view.ph_list.ph_recharge_item)
	self.can_consume_avtivity_list:SetItemsInterval(10)

	self.can_consume_avtivity_list:SetJumpDirection(ListView.Top)
	self.can_consume_avtivity_list:SetSelectCallBack(BindTool.Bind(self.SelectConsumeListCallback, self))
	self.view.node_t_list.layout_consume.node:addChild(self.can_consume_avtivity_list:GetView(), 20)

	self.view.node_t_list.active_btn.node:addClickEventListener(BindTool.Bind(self.OnClickChongzhiHandler, self))

	self:InitEvent()
	self:OnTimeLimitedConsumeEvent()
end

function LimitedActivityXfPage:OnClickChongzhiHandler()
	
end

function LimitedActivityXfPage:SelectConsumeListCallback()
		
end

function LimitedActivityXfPage:InitEvent()
	self.time_limited_consume_event  = GlobalEventSystem:Bind(OtherEventType.TIME_LIMITED_HEAP_CONSUME_CHANGE, BindTool.Bind(self.OnTimeLimitedConsumeEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self),  60)
end

function LimitedActivityXfPage:RemoveEvent()
	if self.time_limited_consume_event then
		GlobalEventSystem:UnBind(self.time_limited_consume_event)
		self.time_limited_consume_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function LimitedActivityXfPage:OnTimeLimitedConsumeEvent()
	self:FlushTime()
end

function LimitedActivityXfPage:FlushTime()
	local time = LimitedActivityData.Instance:GetConsumeDaojishi()
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
	-- local second = math.floor(time % 60)
	if self.view.node_t_list.text_time_2 then
		self.view.node_t_list.text_time_2.node:setString(string.format(Language.Limited.Time, day, hour, minute))
	end
end

function LimitedActivityXfPage:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_GOLD then
		self.view:Flush()
	end
	
end

function LimitedActivityXfPage:UpdateData()
	local data = LimitedActivityData.Instance:GetConsumeCfg()
	self.can_consume_avtivity_list:SetDataList(data)
end

ActivityConsumeRender = ActivityConsumeRender or BaseClass(BaseRender)
function ActivityConsumeRender:__init()
	
end

function ActivityConsumeRender:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function ActivityConsumeRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_list = {}
	for i = 1, 5 do
		local ph = self.ph_list.ph_vip_cell
		local equip_cell = BaseCell.New()
		equip_cell:SetPosition(ph.x + (i-1) * 85, ph.y)
		equip_cell:SetAnchorPoint(0, 0)
		self.view:addChild(equip_cell:GetView(), 100)
		table.insert(self.cell_list, equip_cell)
	end
	self.node_tree.btn_get_consume.node:addClickEventListener(BindTool.Bind(self.GetConsume, self))
end

function ActivityConsumeRender:OnFlush()
	if nil == self.data then return end
	-- print("累计消费状态：",self.data.state)
	if self.data.state == 0 then
		self.node_tree.btn_get_consume.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(true)

		local consumemoney = LimitedActivityData.Instance:GetConsumeMoney()
		local need_money = self.data.money - consumemoney
		local txt_1 = string.format(Language.Limited.Need, need_money)
		self.node_tree.layout_nodabiao.txt_need_name1.node:setString(txt_1)

	elseif self.data.state == 1 then
		self.node_tree.btn_get_consume.node:setVisible(true)
		self.node_tree.Image_dabiao.node:setVisible(false)
		self.node_tree.layout_nodabiao.node:setVisible(false)

	else
		self.node_tree.btn_get_consume.node:setVisible(false)
		self.node_tree.Image_dabiao.node:setVisible(true)
		self.node_tree.layout_nodabiao.node:setVisible(false)
	end

	for k, v in pairs(self.data.awards) do
		self.cell_list[k]:SetData(v)
	end
	
	local txt = string.format(Language.Limited.Consume, self.data.money)
	self.node_tree.txt_name_1.node:setString(txt)	  
end

function ActivityConsumeRender:CreateSelectEffect()

end

function ActivityConsumeRender:GetConsume()
	LimitedActivityCtrl.Instance:SendXfGetGiftReq(self.index)
end
