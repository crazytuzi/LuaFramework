	-- 开服超级团购活动界面
OpenServerSuperGroupPurchasePage = OpenServerSuperGroupPurchasePage or BaseClass()

function OpenServerSuperGroupPurchasePage:__init()
	self.view = nil

end

function OpenServerSuperGroupPurchasePage:__delete()
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

function OpenServerSuperGroupPurchasePage:InitPage(view)
	self.view = view
	-- self.view.node_t_list.rich_super_total_buy_time.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	-- self.view.node_t_list.rich_super_group_purchase_des.node:setHorizontalAlignment(RichHAlignment.HA_CENTER)
	self.view.node_t_list.btn_super_group_left.node:setScale(0.8)
	self.view.node_t_list.btn_super_group_right.node:setScale(0.8)
	self:CreateAwarInfoList()
	self:InitEvent()
	self:OnGroupPurchaseEvent()

end

function OpenServerSuperGroupPurchasePage:OnBuyClicked()
	-- local cmd_id = OpenServiceAcitivityData.Instance:GetOneOpenActCmdID(OPERATE_ACTIVITY_ID.GROUP_PURCHASE)
	-- if cmd_id then
	-- 	local index = OpenServiceAcitivityData.Instance:GetChosenItemIdx()
	-- 	OperateActivityCtrl.Instance:ReqOperateActOpr(cmd_id, OPERATE_ACTIVITY_ID.GROUP_PURCHASE, index, 1)
	-- end
end

function OpenServerSuperGroupPurchasePage:InitEvent()
	XUI.AddClickEventListener(self.view.node_t_list.btn_super_group_left.node, BindTool.Bind(self.OnClickMoveLeftHandler, self), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_super_group_right.node, BindTool.Bind(self.OnClickMoveRightHandler, self), true)
	self.group_purchase_event = GlobalEventSystem:Bind(OpenServerActivityEventType.SUPER_GROUP_PURCHASE_DATA_CHANGE, BindTool.Bind(self.OnGroupPurchaseEvent, self))
	self.timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind1(self.FlushTime, self), 1)
end

function OpenServerSuperGroupPurchasePage:RemoveEvent()
	if self.group_purchase_event then
		GlobalEventSystem:UnBind(self.group_purchase_event)
		self.group_purchase_event = nil
	end

	if self.timer then
		GlobalTimerQuest:CancelQuest(self.timer)
		self.timer = nil
	end
end

function OpenServerSuperGroupPurchasePage:UpdateData(param_t)
	local begin_date_t, end_date_t = OpenServiceAcitivityData.Instance:GetActivityTime(TabIndex.openserve_super_group_purchase)
	if begin_date_t and end_date_t then 
		local begin_date_s = string.format("%d/%d/%d", begin_date_t.year or 0, begin_date_t.month or 0, begin_date_t.day or 0)
		local end_date_s = string.format("%d/%d/%d", end_date_t.year or 0, end_date_t.month or 0, end_date_t.day or 0)
		self.view.node_t_list.text_super_group_time.node:setString(begin_date_s .. "-" .. end_date_s)
	end
	local content = OPEN_SERVER_ACTS_INTERPS[TabIndex.openserve_super_group_purchase]
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_super_group_purchase_des.node, content, 22, COLOR3B.GREEN)
	-- OpenServiceAcitivityCtrl.Instance:ReqOpenServerSuperGPurData()
	self:FlushTime()
	self:FlushArrowBtns()
end

function OpenServerSuperGroupPurchasePage:OnGroupPurchaseEvent()
	-- self:FlushTime()
	local all_buy_time = OpenServiceAcitivityData.Instance:GetSuperGroupPurchaseAllBuyTime()
	local content = string.format(Language.OperateActivity.GroupPurchaseTexts[1], all_buy_time)
	RichTextUtil.ParseRichText(self.view.node_t_list.rich_super_total_buy_time.node, content, 22)
	local chosen_item = OpenServiceAcitivityData.Instance:GetSuperGroupPurchaseChosenItems()
	local real_data = {}
	local arr_idx = 0
	for k, v in ipairs(chosen_item) do
		real_data[arr_idx] = v
		arr_idx = arr_idx + 1
	end
	self.grid_list:SetDataList(real_data)
	
	local data = OpenServiceAcitivityData.Instance:GetSuperGroupPurchaseStandardData()
	self.can_reward_avtivity_list:SetDataList(data)
end

-- 倒计时
local super_end_time = 24 * 3600
function OpenServerSuperGroupPurchasePage:FlushTime()
	local now_time = ActivityData.GetNowShortTime()
	local rest_time = super_end_time - now_time
	local time_str = TimeUtil.FormatSecond2Str(rest_time, 1, true)
	time_str = Language.Common.RemainTime.."：".. time_str
	self.view.node_t_list.supergp_rest_time.node:setString(time_str)
end

function OpenServerSuperGroupPurchasePage:CreateAwarInfoList()
	local ph = self.view.ph_list.ph_super_group_award_list
	self.can_reward_avtivity_list = ListView.New()
	self.can_reward_avtivity_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, OpenSerSuperGPurAwardRender, nil, nil, self.view.ph_list.ph_super_group_award_item)
	self.can_reward_avtivity_list:SetItemsInterval(16)

	-- self.can_reward_avtivity_list:SetJumpDirection(ListView.Left)
	self.view.node_t_list.layout_super_group_purchase.node:addChild(self.can_reward_avtivity_list:GetView(), 20)

	ph = self.view.ph_list.ph_list_super_group_purchase
	self.grid_list = BaseGrid.New()
	local max_count = OpenServiceAcitivityData.Instance:GetSuperGroupChoiceItemNum()
	local grid_node = self.grid_list:CreateCells({w = ph.w, h = ph.h, cell_count = max_count, col = 4, row = 1, itemRender = OpenSerSuperGroupChosenItem, direction = ScrollDir.Horizontal, ui_config = self.view.ph_list.ph_super_group_buy_item})
	grid_node:setPosition(ph.x, ph.y)
	grid_node:setAnchorPoint(0.5, 0.5)
	self.view.node_t_list.layout_super_group_purchase.node:addChild(grid_node, 999)
	self.cur_index = self.grid_list:GetCurPageIndex()
	self.max_page_idx = self.grid_list:GetPageCount()
	self.grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
end

function OpenServerSuperGroupPurchasePage:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_index = page_index
	self:FlushArrowBtns()
end

function OpenServerSuperGroupPurchasePage:OnClickMoveLeftHandler()
	if self.cur_index > 1 then
		self.cur_index = self.cur_index - 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function OpenServerSuperGroupPurchasePage:OnClickMoveRightHandler()
	if self.cur_index < self.max_page_idx then
		self.cur_index = self.cur_index + 1
		self.grid_list:ChangeToPage(self.cur_index)
	end
end

function OpenServerSuperGroupPurchasePage:FlushArrowBtns()
	-- XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_super_group_left.node, self.cur_index == 1, true)
	-- XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_super_group_right.node, self.cur_index == self.max_page_idx, true)
	self.view.node_t_list.btn_super_group_left.node:setVisible(self.cur_index ~= 1)
	self.view.node_t_list.btn_super_group_right.node:setVisible(self.cur_index ~= self.max_page_idx)
end


-- 超级团购活动奖励Render
OpenSerSuperGPurAwardRender = OpenSerSuperGPurAwardRender or BaseClass(BaseRender)
function OpenSerSuperGPurAwardRender:__init()

end

function OpenSerSuperGPurAwardRender:__delete()
	for k,v in pairs(self.cells_list) do
		v:DeleteMe()
	end
	self.cells_list = {}
	self.cells_view_container:removeFromParent()
	self.cells_view_container = nil
end

function OpenSerSuperGPurAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cells_list = {}
	self:CreateCellsContainer()
	self.node_tree.btn_get_reward.node:addClickEventListener(BindTool.Bind(self.GetReward, self))
end

function OpenSerSuperGPurAwardRender:OnFlush()
	if nil == self.data then return end
	self.node_tree.btn_get_reward.node:setVisible(self.data.state == 1)
	self.node_tree.img_standard.node:setVisible(self.data.state == 2)
	self.node_tree.img_not_standard.node:setVisible(self.data.state == 0)

	local txt_1 = ""
	if self.data.state == 0 then

		local buy_cnt = OpenServiceAcitivityData.Instance:GetSuperGroupPurchaseAllBuyTime()
		local need_buy_cnt = self.data.buyCnt - buy_cnt
		if need_buy_cnt <= 0 then
			txt_1 = Language.OperateActivity.GroupPurchaseTexts[6]
		else
			txt_1 = string.format(Language.OperateActivity.GroupPurchaseTexts[2], need_buy_cnt)
		end
	end
	self.node_tree.txt_need_name.node:setString(txt_1)

	self:SetAwardCells(self.data.awards_t)
	
	local txt = string.format(Language.OperateActivity.GroupPurchaseTexts[3], self.data.buyCnt)
	self.node_tree.txt_name.node:setString(txt)

end

function OpenSerSuperGPurAwardRender:CreateSelectEffect()

end

function OpenSerSuperGPurAwardRender:CreateCellsContainer()
	if not self.cells_view_container then
		local ph = self.ph_list.ph_cells_container
		self.cells_view_container = XLayout:create(0, 64)
		self.cells_view_container:setAnchorPoint(0.5, 0)
		self.cells_view_container:setPosition(ph.x, ph.y)
		self.view:addChild(self.cells_view_container, 100)
	end
end

function OpenSerSuperGPurAwardRender:SetAwardCells(awards_data)
	if not awards_data or not next(awards_data) then return end

	local gap = 2
	local award_cnt = #awards_data
	local need_width = (64 * award_cnt) + (award_cnt - 1) * gap
	self.cells_view_container:setContentWH(need_width, 64)
	-- 多余的删除掉
	if #self.cells_list > award_cnt then
		local no_need_cnt = #self.cells_list - award_cnt
		for i = 1, no_need_cnt do
			local cell = table.remove(self.cells_list, #self.cells_list)
			if cell then
				cell:GetView():removeFromParent()
				cell:DeleteMe()
			end
		end
	end

	for i, v in ipairs(awards_data) do
		if not self.cells_list[i] then
			local cell = BaseCell.New()
			cell:GetView():setScale(0.8)
			cell:SetPosition((i - 1) * (64 + gap), 0)
			cell:SetData(v)
			self.cells_view_container:addChild(cell:GetView(), 100)
			self.cells_list[i] = cell
		else
			local cell = self.cells_list[i]
			cell:GetView():setPositionX((i - 1) * (64 + gap))
			cell:SetData(v)
		end
	end
end

function OpenSerSuperGPurAwardRender:GetReward()
	OpenServiceAcitivityCtrl.Instance:OpenServerSuperGPurOperate(self.index, 2)
end

-- 超级团购活动选中出售Render
OpenSerSuperGroupChosenItem = OpenSerSuperGroupChosenItem or BaseClass(BaseRender)
function OpenSerSuperGroupChosenItem:__init()

end

function OpenSerSuperGroupChosenItem:__delete()
	if self.draw_node then
		self.draw_node:clear()
		self.draw_node:removeFromParent()
		self.draw_node = nil
	end

	if self.chosen_item_cell then
		self.chosen_item_cell:DeleteMe()
		self.chosen_item_cell = nil
	end
end

function OpenSerSuperGroupChosenItem:CreateChild()
	BaseRender.CreateChild(self)
	XUI.AddClickEventListener(self.node_tree.btn_group_buy.node, BindTool.Bind(self.BuyItem, self), true)
	local ph = self.ph_list.ph_chosen_item_cell
	self.chosen_item_cell = BaseCell.New()
	self.chosen_item_cell:SetPosition(ph.x, ph.y)
	-- self.chosen_item_cell:GetView():setAnchorPoint(0.5, 0.5)
	self.view:addChild(self.chosen_item_cell:GetView(), 100)

	self.draw_node = cc.DrawNode:create()
	self.view:addChild(self.draw_node, 99)
end

function OpenSerSuperGroupChosenItem:OnFlush()
	if nil == self.data then return end
	self.chosen_item_cell:SetData(self.data.item)
	local rest_buy = string.format(Language.OperateActivity.GroupPurchaseTexts[4], self.data.rest_buy_time)
	self.node_tree.txt_group_rest_buy_time.node:setString(rest_buy)
	self.node_tree.btn_group_buy.node:setEnabled(self.data.rest_buy_time > 0)
	local content = string.format(Language.OperateActivity.GroupPurchaseTexts[5], self.data.now_price, self.data.old_price)
	self.node_tree.txt_cost_price.node:setString(self.data.now_price)
	self.node_tree.txt_old_price.node:setString(self.data.old_price)
	local old_price = self.data.old_price
	old_price = tostring(old_price)
	local str_len = string.len(old_price)
	local line_len = 10 * str_len
	self.draw_node:clear()
	local x, y = self.node_tree.txt_old_price.node:getPositionX(), self.node_tree.txt_old_price.node:getPositionY()

	local pos1 = cc.p(x + 3, y - 10)
	local pos2 = cc.p(pos1.x + line_len, pos1.y)
	self.draw_node:drawSegment(pos1, pos2, 0.45, cc.c4f(1, 0, 0, 1))
end

function OpenSerSuperGroupChosenItem:CreateSelectEffect()

end

function OpenSerSuperGroupChosenItem:BuyItem()
	if not self.data then return end
	ViewManager.Instance:Open(ViewName.SuperGroupBuy)
	ViewManager.Instance:FlushView(ViewName.SuperGroupBuy, 0, "param", {self.data})
	-- OpenServiceAcitivityCtrl.Instance:OpenServerSuperGPurOperate(self.data.idx, 1)
end

