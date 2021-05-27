	-- 团购活动界面
GroupPurchasePage = GroupPurchasePage or BaseClass()

function GroupPurchasePage:__init()
	self.view = nil

end

function GroupPurchasePage:__delete()
	self:RemoveEvent()
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end

	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	if self.chosen_item_cell then
		self.chosen_item_cell:DeleteMe()
		self.chosen_item_cell = nil
	end

	self.view = nil
end



function GroupPurchasePage:InitPage(view)
	self.view = view
	self.view.node_t_list.rich_total_buy_time.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- self.view.node_t_list.rich_group_purchase_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnGroupPurchaseEvent()

end

function GroupPurchasePage:OnBuyClicked()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	if cmd_id then
		local index = OperateActivityData.Instance:GetChosenItemIdx()
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.GROUP_PURCHASE, index, 1)
	end
end

function GroupPurchasePage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_group_buy.node, BindTool.Bind(self.OnBuyClicked, self), true)
	self.group_purchase_event = GlobalEventSystem:Bind(OperateActivityEventType.GROUP_PURCHASE_DATA_CHANGE, BindTool.Bind(self.OnGroupPurchaseEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function GroupPurchasePage:RemoveEvent()
	if self.group_purchase_event then
		GlobalEventSystem:UnBind(self.group_purchase_event)
		self.group_purchase_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function GroupPurchasePage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_list_group_purchase
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, nil, GroupPurchaseAwardRender, nil, nil, self.view.ph_list.ph_group_purchase_item)
	self.can_reward_avtivity_list:SetItemsInterval(10)

	self.can_reward_avtivity_list:SetJumpDirection(ListView.Top)
	self.view.node_t_list.layout_group_purchase.node:addChild(self.can_reward_avtivity_list:GetView(), 20)

	ph = self.view.ph_list.ph_chosen_item_cell
	self.chosen_item_cell = BaseCell.New()
	self.chosen_item_cell:SetPosition(ph.x, ph.y)
	self.chosen_item_cell:GetView():setAnchorPoint(0, 0)
	self.view.node_t_list.layout_group_buy_panel.node:addChild(self.chosen_item_cell:GetView(), 100)

	self.draw_node = cc.DrawNode:create()
	self.view.node_t_list.layout_group_buy_panel.node:addChild(self.draw_node, 100)
end

function GroupPurchasePage:OnGroupPurchaseEvent()
	local all_buy_time = OperateActivityData.Instance:GetGroupPurchaseAllBuyTime()
	local content = string.format(Language.OperateActivity.GroupPurchaseTexts[1], all_buy_time)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_total_buy_time.node, content)
	self:FlushTime()
	local chosen_item = OperateActivityData.Instance:GetGroupPurchaseChosenItem()
	if chosen_item and next(chosen_item) then
		local rest_buy_time = OperateActivityData.Instance:GetGroupPurchaseRestBuyTime()
		self.chosen_item_cell:SetData(chosen_item)
		local item_cfg = ItemData.Instance:GetItemConfig(chosen_item.item_id)
		if item_cfg then
			self.view.node_t_list.txt_group_item_name.node:setString(item_cfg.name)
		end
		local rest_buy = string.format(Language.OperateActivity.GroupPurchaseTexts[4], rest_buy_time)
		self.view.node_t_list.txt_group_rest_buy_time.node:setString(rest_buy)
		content = string.format(Language.OperateActivity.GroupPurchaseTexts[5], chosen_item.now_price, chosen_item.old_price)
		self.view.node_t_list.txt_cost_price.node:setString(chosen_item.now_price)
		self.view.node_t_list.txt_old_price.node:setString(chosen_item.old_price)
		local old_price = chosen_item.old_price
		old_price = tostring(old_price)
		local str_len = string.len(old_price)
		local line_len = 10 * str_len
		self.draw_node:clear()
		local x, y = self.view.node_t_list.txt_old_price.node:getPositionX(), self.view.node_t_list.txt_old_price.node:getPositionY()

		local pos1 = cc.p(x + 3, y - 10)
		local pos2 = cc.p(pos1.x + line_len, pos1.y)
		self.draw_node:drawSegment(pos1, pos2, 0.45, cc.c4f(1, 0, 0, 1))
	end
	
	local data = OperateActivityData.Instance:GetGroupPurchaseStandardData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function GroupPurchasePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_time_7 then
		self.view.node_t_list.text_time_7.node:setString(time_str)
	end
end

function GroupPurchasePage:UpdateData(param_t)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_group_purchase_des.node, content, 24, COLOR3B.YELLOW)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	OperateActivityCtrl.Instance:ReqOperateActData(cmd_id or 1, OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
end


