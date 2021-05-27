	-- 超级团购活动界面
SuperGroupPurchasePage = SuperGroupPurchasePage or BaseClass()

function SuperGroupPurchasePage:__init()
	self.view = nil

end

function SuperGroupPurchasePage:__delete()
	self:RemoveEvent()
	if self.can_reward_avtivity_list then
		self.can_reward_avtivity_list:DeleteMe()
		self.can_reward_avtivity_list = nil 
	end

	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil 
	end

	self.view = nil
end



function SuperGroupPurchasePage:InitPage(view)
	self.view = view
	-- self.view.node_t_list.rich_super_total_buy_time.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.view.node_t_list.rich_super_group_purchase_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.view.node_t_list.btn_super_group_left.node:setScale(0.8)
	self.view.node_t_list.btn_super_group_right.node:setScale(0.8)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnGroupPurchaseEvent()

end

function SuperGroupPurchasePage:OnBuyClicked()
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	if cmd_id then
		local index = OperateActivityData.Instance:GetChosenItemIdx()
		OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.GROUP_PURCHASE, index, 1)
	end
end

function SuperGroupPurchasePage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_super_group_left.node, BindTool.Bind(self.OnClickMoveLeftHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_super_group_right.node, BindTool.Bind(self.OnClickMoveRightHandler, self), true)
	self.group_purchase_event = GlobalEventSystem:Bind(OperateActivityEventType.SUPER_GROUP_PURCHASE_DATA_CHANGE, BindTool.Bind(self.OnGroupPurchaseEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function SuperGroupPurchasePage:RemoveEvent()
	if self.group_purchase_event then
		GlobalEventSystem:UnBind(self.group_purchase_event)
		self.group_purchase_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function SuperGroupPurchasePage:UpdateData(param_t)
	local cfg = OperateActivityData.Instance:GetActCfgByActID(OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE)
	local content = cfg and cfg.act_desc or ""
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_super_group_purchase_des.node, content, 22, COLOR3B.GREEN)
	local cmd_id = OperateActivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE)
	OperateActivityCtrl.Instance:ReqOperateActData(cmd_id or 1, OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE)
	self:FlushArrowBtns()
end

function SuperGroupPurchasePage:OnGroupPurchaseEvent()
	self:FlushTime()
	local all_buy_time = OperateActivityData.Instance:GetSuperGroupPurchaseAllBuyTime()
	local content = string.format(Language.OperateActivity.GroupPurchaseTexts[1], all_buy_time)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_super_total_buy_time.node, content)
	local chosen_item = OperateActivityData.Instance:GetSuperGroupPurchaseChosenItems()
	self.grid_list:SetDataList(chosen_item)
	
	local data = OperateActivityData.Instance:GetSuperGroupPurchaseStandardData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
function SuperGroupPurchasePage:FlushTime()
	local time_str = OperateActivityData.Instance:GetActRemainTimeStrByActId(OPERATE_ACTIVITY_ID.SUPER_GROUP_PURCHASE)
	if time_str == "" then
		if self.timer then
			GlobalTimerQuest:CancelQuest(self.timer)
			self.timer = nil
		end
		return
	end
	if self.view.node_t_list.text_super_group_time then
		self.view.node_t_list.text_super_group_time.node:setString(time_str)
	end
end

function SuperGroupPurchasePage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_super_group_award_list
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, SuperGroupPurchaseAwardRender, nil, nil, self.view.ph_list.ph_super_group_award_item)
	self.can_reward_avtivity_list:SetItemsInterval(16)

	-- self.can_reward_avtivity_list:SetJumpDirection(ListView.Left)
	self.view.node_t_list.layout_super_group_purchase.node:addChild(self.can_reward_avtivity_list:GetView(), 20)

	ph = self.view.ph_list.ph_list_super_group_purchase
	self.grid_list = BaseGrid.New()
	local max_count = OperateActivityData.Instance:GetSuperGroupChoiceItemNum()
	local grid_node = self.grid_list:CreateCells({w = ph.w, h = ph.h, cell_count = max_count, col = 4, row = 1, itemRender = SuperGroupChosenItem, direction = ScrollDir.Horizontal, ui_config = self.view.ph_list.ph_super_group_buy_item})
	grid_node:setPosition(ph.x, ph.y)
	grid_node:setAnchorPoint(0.5, 0.5)
	self.view.node_t_list.layout_super_group_purchase.node:addChild(grid_node, 999)
	self.cur_index = self.grid_list:GetCurPageIndex()
	self.max_page_idx = self.grid_list:GetPageCount()
	self.grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
end

function SuperGroupPurchasePage:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index
	self:FlushArrowBtns()
end

function SuperGroupPurchasePage:OnClickMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function SuperGroupPurchasePage:OnClickMoveRightHandler()
	if self.cur_index < self.max_page_idx then
		self.cur_index = self.cur_index + 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function SuperGroupPurchasePage:FlushArrowBtns()
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_super_group_left.node, self.cur_index == 1, true)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_super_group_right.node, self.cur_index == self.max_page_idx, true)
	-- self.view.node_t_list.btn_super_group_left.node:setVisible()
	-- self.view.node_t_list.btn_super_group_right.node:setVisible(self.cur_index ~= self.max_page_idx)
end




