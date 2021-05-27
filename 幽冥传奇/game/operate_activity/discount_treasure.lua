-- 宝物折扣界面
DiscountTreasurePage = DiscountTreasurePage or BaseClass()

function DiscountTreasurePage:__init()
	self.view = nil

end

function DiscountTreasurePage:__delete()
	self:RemoveEvent()

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	self.view = nil
end



function DiscountTreasurePage:InitPage(view)
	self.view = view
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnDiscountTreasureEvent()
end

function DiscountTreasurePage:InitEvent()
	-- self.view.node_t_list.rich_discount_treasure_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_recharge_1.node, BindTool.Bind(self.OnClickChongzhiHandler, self), true)
	self.discount_treasure_event = GlobalEventSystem:Bind(OperateActivityEventType.DISCOUNT_TREASURE_DATA_CHANGE, BindTool.Bind(self.OnDiscountTreasureEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function DiscountTreasurePage:RemoveEvent()
	if self.discount_treasure_event then
		GlobalEventSystem:UnBind(self.discount_treasure_event)
		self.discount_treasure_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function DiscountTreasurePage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_discount_treasure_list
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, OperActDiscountTreasureRender, nil, nil, self.view.ph_list.ph_discount_treasure_item)
	self.can_reward_avtivity_list:SetItemsInterval(10)

	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_discount_treasure.node:addChild(self.can_reward_avtivity_list:GetView(), 20)
end

function DiscountTreasurePage:OnDiscountTreasureEvent()
	self:FlushTime()
	local data = OperateActivityData.Instance:GetDiscountTreasureData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function DiscountTreasurePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_discount_treasure_time then
		self.view.node_t_list.text_discount_treasure_time.node:setString(time_str)
	end
end

function DiscountTreasurePage:OnClickChongzhiHandler()
	if self.view then
		self.view:Close()
		ViewManager.Instance:Open(ViewName.ChargePlatForm)
	end
end

function DiscountTreasurePage:UpdateData(param_t)
	local des = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.DISCOUNT_TREASURE).act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_discount_treasure_des.node, des, 24, COLOR3B.YELLOW)
end


