NatiLoginSendGiftPage = NatiLoginSendGiftPage or BaseClass()

function NatiLoginSendGiftPage:__init()
	self.view = nil
	self.selec_item_index = 1
end

function NatiLoginSendGiftPage:__delete()
	self:RemoveEvent()
	if self.day_reward_list then
		self.day_reward_list:DeleteMe()
		self.day_reward_list = nil
	end

	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

	self.selec_item_index = 1

	self.view = nil
end

function NatiLoginSendGiftPage:InitPage(view)
	self.view = view
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_fetch_gift.node, BindTool.Bind(self.OnFetchClick, self), true)
	self:CreateEveryDayReward()
	self:CreateAwarItemList()
	self.btn_left_move = self.view.node_tree.layout_nationalday_online.btn_left.node
	self.btn_right_move = self.view.node_tree.layout_nationalday_online.btn_right.node
	self.remind_lef = self.view.node_tree.layout_nationalday_online.img_remind_flag_lef.node
	self.remind_rig = self.view.node_tree.layout_nationalday_online.img_remind_flag_rig.node
	self.remind_lef:setVisible(false)
	self.remind_rig:setVisible(false)
	self:InitEvent()
end

function NatiLoginSendGiftPage:InitEvent()
	XUI.AddClickEventListener(self.btn_left_move, BindTool.Bind(self.OnClickMoveLeftHandler, self))
	XUI.AddClickEventListener(self.btn_right_move, BindTool.Bind(self.OnClickMoveRightHandler, self))
	self.daily_online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateOnlineAwarInfo, self), 1)
	self.seven_event = GlobalEventSystem:Bind(OperateActivityEventType.LOGIN_SEND_GIFT_DATA, BindTool.Bind(self.OnSevenDaysInfoChange, self))
end

function NatiLoginSendGiftPage:RemoveEvent()
	if self.seven_event then
		GlobalEventSystem:UnBind(self.seven_event)
		self.seven_event = nil
	end

	if self.daily_online_timer then
		GlobalTimerQuest:CancelQuest(self.daily_online_timer)
		self.daily_online_timer = nil
	end
end

--更新视图界面
function NatiLoginSendGiftPage:UpdateData(data)
	local data = OperateActivityData.Instance:GetLoginSendGiftDayListData()
	self.day_reward_list:SetDataList(data)
	local cur_day = OperateActivityData.Instance:GetLoginSendGiftCurDay()
	self.day_reward_list:SelectCellByIndex(cur_day-1)
	self.day_reward_list:JumpToPage(math.ceil(cur_day / 5))
	self:FlushBtn()
	-- self:OnSevenDaysInfoChange()
end	

function NatiLoginSendGiftPage:CreateEveryDayReward()
	if nil == self.day_reward_list then
		local ph_start = self.view.ph_list.ph_day_item_start
		local ph = self.view.ph_list.ph_day_list
		self.day_reward_list = BaseGrid.New()
		local count = OperateActivityData.Instance:GetLoginSendGiftTotalDay()
		local grid_node = self.day_reward_list:CreateCells({w = ph.w, h = ph.h, itemRender = NationalDayLoginAwardRender, direction = ScrollDir.Horizontal,cell_count = count, col = OperateActivityData.LoginSendGiftPerPageCnt, row = 1, ui_config = ph_start})
		self.day_reward_list:SetSelectCallBack(BindTool.Bind(self.SelectRewardList, self))
		grid_node:setPosition(ph.x, ph.y)
		grid_node:setAnchorPoint(0.5, 0.5)
		
		self.cur_page_idx = self.day_reward_list:GetCurPageIndex()
		self.day_reward_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
		self.view.node_tree.layout_nationalday_online.node:addChild(grid_node, 999)
		local data = OperateActivityData.Instance:GetLoginSendGiftDayListData()
		self.day_reward_list:SetDataList(data)  

	end
end

function NatiLoginSendGiftPage:CreateAwarItemList()
	if not self.award_list then
		local ph = self.view.ph_list.ph_login_list
		self.award_list = ListView.New()
		self.award_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, NatiDayOnlineAwardRender, nil, nil, self.view.ph_list.ph_online_item)
		self.award_list:SetMargin(2)
		self.award_list:SetItemsInterval(4)
		self.award_list:SetJumpDirection(ListView.Top)
		self.view.node_tree.layout_nationalday_online.node:addChild(self.award_list:GetView(), 99)
	end
end

function NatiLoginSendGiftPage:UpdateOnlineAwarInfo()
	if nil == self.view then return end
	if self.selec_item_index ~= OperateActivityData.Instance:GetLoginSendGiftCurDay() then return end
	local cur_day_data = OperateActivityData.Instance:GetLoginSendGiftDataByDay(self.selec_item_index)
	if not cur_day_data or cur_day_data.state == ONLINE_AWARD_FETCH_STATE.FETCHED or cur_day_data.check_num <= 0 then 
		if self.daily_online_timer then
			GlobalTimerQuest:CancelQuest(self.daily_online_timer)
			self.daily_online_timer = nil
		end
	end
	local onlin_time = OperateActivityData.Instance:GetOnlineTime()
	OperateActivityData.Instance:ClientSetOnlinAwarRestTime(onlin_time)
	local onlin_info = OperateActivityData.Instance:GetLoginSendGiftAwards(self.selec_item_index)
	self.award_list:SetData(onlin_info)
end

function NatiLoginSendGiftPage:OnPageChangeCallBack(grid, page_index, prve_page_index)
	self.cur_page_idx = page_index
	self:FlushBtn()
end

function NatiLoginSendGiftPage:OnClickMoveLeftHandler()
	if self.cur_page_idx > 1 then
		self.cur_page_idx = self.cur_page_idx - 1
		self.day_reward_list:ChangeToPage(self.cur_page_idx)
	end
end

function NatiLoginSendGiftPage:OnClickMoveRightHandler()
	if self.cur_page_idx < self.day_reward_list:GetPageCount() then
		self.cur_page_idx = self.cur_page_idx + 1
		self.day_reward_list:ChangeToPage(self.cur_page_idx)
	end
end

function NatiLoginSendGiftPage:FlushBtn()
	local min,max = OperateActivityData.Instance:GetLoginSendGiftMinMaxRemindPage()
	self.remind_lef:setVisible(min > 0 and self.cur_page_idx > min)
	self.remind_rig:setVisible(max > 0 and self.cur_page_idx < max)
	self.btn_left_move:setVisible(self.cur_page_idx ~= 1)
	self.btn_right_move:setVisible(self.cur_page_idx ~= self.day_reward_list:GetPageCount())
end

function NatiLoginSendGiftPage:SetRewardCellData(index)
	local onlin_info = OperateActivityData.Instance:GetLoginSendGiftAwards(self.selec_item_index)
	self.award_list:SetData(onlin_info)
end

function NatiLoginSendGiftPage:SelectRewardList(item)
	if nil == item or nil == item:GetData() then return end
	local data = item:GetData()
	self.selec_item_index = data.day
	self:SetRewardCellData(self.selec_item_index)
	local cur_day = OperateActivityData.Instance:GetLoginSendGiftCurDay()
	if self.selec_item_index == cur_day then
		self:UpdateOnlineAwarInfo()
	end
end

function NatiLoginSendGiftPage:OnFetchClick()
	-- if self.selec_item_index then
	-- 	WelfareCtrl:GetSevenDaysLoginAwardReq(self.selec_item_index)
	-- end
end

function NatiLoginSendGiftPage:OnSevenDaysInfoChange()
	local data = OperateActivityData.Instance:GetLoginSendGiftDayListData()
	self.day_reward_list:SetDataList(data)
	self.day_reward_list:SelectCellByIndex(self.selec_item_index-1)
	local cur_day = OperateActivityData.Instance:GetLoginSendGiftCurDay()
	local cur_day_data = OperateActivityData.Instance:GetLoginSendGiftDataByDay(cur_day)
	if self.daily_online_timer == nil and cur_day_data and cur_day_data.check_num > 0 then
		self.daily_online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateOnlineAwarInfo, self), 1)
	end

end




