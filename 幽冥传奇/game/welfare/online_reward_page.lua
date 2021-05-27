-- 在线奖励页面
OnlineRewardPage = OnlineRewardPage or BaseClass()

function OnlineRewardPage:__init()
	self.view = nil
	self.need_set_list_data = true
end

function OnlineRewardPage:__delete()
	self.need_set_list_data = true
	self:RemoveEvent()
	if self.award_list then
		self.award_list:DeleteMe()
		self.award_list = nil
	end

	self.view = nil
end

function OnlineRewardPage:InitPage(view)
	self.view = view
	self:CreateAwarItemList()
	-- XUI.AddClickEventListener(self.view.node_t_list.btn_get_onlin.node, BindTool.Bind(self.OnGetOnlinClick), true)
	XUI.AddClickEventListener(self.view.node_t_list.btn_get_bIngot.node, BindTool.Bind(self.OnGetBIngotClick), true)
	XUI.AddClickEventListener(self.view.node_t_list.layout_interp.node, BindTool.Bind(self.OnInterpClick), true)

	self:OnOnlineAwarDataChange()
	self:OnWeekOnlinDataChange()
	self:InitEvent()
end

function OnlineRewardPage:InitEvent()
	self.online_award_event = GlobalEventSystem:Bind(WelfareEventType.DAILY_ONLIN_AWARD_DATA_CHANGE, BindTool.Bind(self.OnOnlineAwarDataChange, self))	-- 每日在线奖励物品
	self.daily_online_timer = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.UpdateOnlineAwarInfo, self), 1)
	self.week_award_event = GlobalEventSystem:Bind(WelfareEventType.WEEK_ONLIN_BIND_DATA_CHANGE, BindTool.Bind(self.OnWeekOnlinDataChange, self))	--周累计在线奖励绑元

end

function OnlineRewardPage:RemoveEvent()
	if self.online_award_event then
		GlobalEventSystem:UnBind(self.online_award_event)
		self.online_award_event = nil
	end

	if self.daily_online_timer then
		GlobalTimerQuest:CancelQuest(self.daily_online_timer)
		self.daily_online_timer = nil
	end

	if self.week_award_event then
		GlobalEventSystem:UnBind(self.week_award_event)
		self.week_award_event = nil
	end
end

function OnlineRewardPage:CreateAwarItemList()
	if not self.award_list then
		local ph = self.view.ph_list.ph_online_list
		self.award_list = ListView.New()
		self.award_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Vertical, OnlineAwardRender, nil, nil, self.view.ph_list.ph_online_item)
		self.award_list:SetMargin(2)
		-- self.award_list:SetIsUseStepCalc(false)
		-- local interval = (ph.w - 6 - self.view.ph_list.ph_online_item.w * ONLINE_AWARD_STAGE) / (ONLINE_AWARD_STAGE - 1)
		self.award_list:SetItemsInterval(4)
		self.award_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.page2.node:addChild(self.award_list:GetView(), 99)
	end
end

--更新视图界面
function OnlineRewardPage:UpdateData(data)
	-- WelfareCtrl.Instance:OnlineRewardInfoReq(ONLINE_AWARD_REQ_TYPE.REQ_DATA)
	-- WelfareCtrl.Instance:WeekOnliAwardBIngotInfoReq()
end	

function OnlineRewardPage:OnOnlineAwarDataChange()
	self:UpdateOnlineAwarInfo()
end

function OnlineRewardPage:OnWeekOnlinDataChange()
	local week_onlin_data = WelfareData.Instance:GetOnlinWeekBIngotData()
	if not next(week_onlin_data) then return end
	self.view.node_t_list.lbl_last_week.node:setString(week_onlin_data.lastW_can_num)
	self.view.node_t_list.lbl_this_week.node:setString(week_onlin_data.thisW_total_fetch_num)
	-- self.view.node_t_list.btn_get_bIngot.node:setEnabled(week_onlin_data.lastW_can_num > 0 and week_onlin_data.fetch_state == ONLINE_AWARD_FETCH_STATE.CAN)
	XUI.SetLayoutImgsGrey(self.view.node_t_list.btn_get_bIngot.node, week_onlin_data.lastW_can_num <= 0 or week_onlin_data.fetch_state ~= ONLINE_AWARD_FETCH_STATE.CAN, true)
	local path = ""
	-- 已领取换图片
	if week_onlin_data.fetch_state == ONLINE_AWARD_FETCH_STATE.FETCHED then
		path = ResPath.GetCommon("stamp_15")
	else
		path = ResPath.GetCommon("stamp_17")
	end
	if path ~= "" then
		self.view.node_tree.page2.btn_get_bIngot.btn_txt.node:loadTexture(path)
	end
end

function OnlineRewardPage:UpdateOnlineAwarInfo()
	if nil == self.view then return end
	local onlin_time = WelfareData.Instance:GetOnlineTime()
	WelfareData.Instance:ClientSetOnlinAwarRestTime(onlin_time)

	local onlin_time_str = TimeUtil.FormatSecond(onlin_time)
	self.view.node_t_list.lbl_onlin_time.node:setString(onlin_time_str)

	if not WelfareData.Instance:IsOnlineAwarAllFetched() then
		local onlin_info = WelfareData.Instance:GetOnlinAwarInfo()
		self.award_list:SetData(onlin_info)
	elseif true == self.need_set_list_data then
		self.need_set_list_data = false
		local onlin_info = WelfareData.Instance:GetOnlinAwarInfo()
		self.award_list:SetData(onlin_info)
	end
end

--领取在线奖励
function OnlineRewardPage:OnGetOnlinClick()
	WelfareCtrl.Instance:OnlineRewardInfoReq(ONLINE_AWARD_REQ_TYPE.FETCH_AWARD)
end

function OnlineRewardPage:OnGetBIngotClick()
	WelfareCtrl.Instance:GetWeekOnliAwardBIngotReq()
end

function OnlineRewardPage:OnInterpClick()
	DescTip.Instance:SetContent(Language.Welfare.InterpContents[1], Language.Welfare.InterpTitles[1])
end


--OnlineAwardRender
OnlineAwardRender = OnlineAwardRender or BaseClass(BaseRender)
function OnlineAwardRender:__init()

end

function OnlineAwardRender:__delete()
	if self.progressbar then
		self.progressbar:DeleteMe()
		self.progressbar = nil
	end

	if self.cells_list then
		for _, v in ipairs(self.cells_list) do
			if v then
				v:DeleteMe()
			end
		end
		self.cells_list = nil
	end
end

function OnlineAwardRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cells_list = {}
	local ph = self.ph_list.ph_cell
	for i = 1, 2 do
		local cell = BaseCell.New()
		cell:SetPosition(ph.x + (i - 1) * 82, ph.y)
		cell:GetView():setVisible(false)
		self.cells_list[i] = cell
		self.view:addChild(cell:GetView(), 9)
	end
	self.node_tree.img_state.node:setVisible(false)
	self.node_tree.btn_fetch.node:setVisible(false)
	self.progressbar = ProgressBar.New()
	self.progressbar:SetView(self.node_tree.prog9_count_down.node)
	self.progressbar:SetTotalTime(0)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnFetchAward, self), true)
end

function OnlineAwardRender:OnFlush()
	if not self.data then return end
	if WelfareData.Instance:GetIsOnlineSorted() then
		for i, v in ipairs(self.data.awards) do
			if self.cells_list[i] then
				self.cells_list[i]:GetView():setVisible(true)
				self.cells_list[i]:SetData(v)
			end
		end

		self.node_tree.img_state.node:setVisible(self.data.state ~= ONLINE_AWARD_FETCH_STATE.CAN)
		self.node_tree.btn_fetch.node:setVisible(self.data.state == ONLINE_AWARD_FETCH_STATE.CAN)
		if self.node_tree.img_state.node:isVisible() then
			local path = ""
			if self.data.state == ONLINE_AWARD_FETCH_STATE.CANNOT then
				path = ResPath.GetCommon("stamp_3")
			elseif self.data.state == ONLINE_AWARD_FETCH_STATE.FETCHED then
				path = ResPath.GetCommon("stamp_10")
			end
			self.node_tree.img_state.node:loadTexture(path)
		end
	end
	if self.index == #OnlineTimeAward and WelfareData.Instance:GetIsOnlineSorted() and not WelfareData.Instance:IsOnlineAwarAllFetched() then
		WelfareData.Instance:SetIsOnlineSorted(false)
	end

	local rest_time = (self.data.rest_time > 0) and TimeUtil.FormatSecond(self.data.rest_time, 3) or ""
	local onlin_time = WelfareData.Instance:GetOnlineTime()
	local prog_percent = onlin_time / self.data.time_cond * 100
	self.progressbar:SetPercent(prog_percent)
	self.node_tree.lbl_get_state.node:setString(rest_time)					--  ~= "" and rest_time or Language.Welfare.FetchStateTexts[state]
end

--领取在线奖励
function OnlineAwardRender:OnFetchAward()
	if not self.data then return end
	WelfareCtrl.Instance:OnlineRewardInfoReq(ONLINE_AWARD_REQ_TYPE.FETCH_AWARD, self.data.idx)
end

function OnlineAwardRender:SetGrey(bool)
	-- self.node_tree.img_get_box.node:setGrey(bool)
	self.node_tree.img_frame.node:setGrey(bool)
end

function OnlineAwardRender:CreateSelectEffect()

end