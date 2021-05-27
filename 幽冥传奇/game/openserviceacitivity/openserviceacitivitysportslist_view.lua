local OpenServiceAcitivitySportsListView = OpenServiceAcitivitySportsListView or BaseClass(SubView)

function OpenServiceAcitivitySportsListView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 5, {0}},
	}
	self.is_create_award = false
end

function OpenServiceAcitivitySportsListView:LoadCallBack()
	self.sports_type = OpenServiceAcitivityData.Instance:GetSportsShowIndex()
	-- self.panel_info = OpenServiceAcitivityData.Instance:GetSportsListInfo(self.sports_type)
	self:CreateTitle()
	self:CreateListBtn()
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.SportsListChange, BindTool.Bind(self.OnFlushSportsListView, self))
end

function OpenServiceAcitivitySportsListView:ReleaseCallBack()
	self.sports_type = nil
	self.panel_info = {}
	if self.title then
		self.title:DeleteMe()
		self.title = nil
	end
	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.is_create_award = false
	self.list_text = nil
end

function OpenServiceAcitivitySportsListView:ShowIndexCallBack()
	self.sports_type = OpenServiceAcitivityData.Instance:GetSportsShowIndex()
	OpenServiceAcitivityCtrl:SendSportsListInfo(self.sports_type)
	-- self:OnFlushSportsListView()
end

function OpenServiceAcitivitySportsListView:OnFlushSportsListView()
	self.panel_info = OpenServiceAcitivityData.Instance:GetSportsListInfo(self.sports_type)
	self:CreateShowAward()
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.tips, 21, COLOR3B.OLIVE)
	local level_content = OpenServiceAcitivityData.GetGredeContent(OpenServiceAcitivityData.Instance:GetMySportsGrade(self.sports_type))
	RichTextUtil.ParseRichText(self.node_t_list.rich_sports_level.node, level_content, 22)
	local rank_text = ""
	if 0 == self.panel_info.my_rank then
		rank_text = "20名以后"
	else
		rank_text = self.panel_info.my_rank .. "名"
	end
	self.node_t_list.lbl_my_ranking.node:setString(rank_text)

	-- 剩余时间倒计时
	local activity_time_text = self.panel_info.time.day .. "天" .. self.panel_info.time.hour .. "小时" .. self.panel_info.time.min .. "分钟"
	self.node_t_list.lbl_left_time.node:setString(activity_time_text)

	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.consume_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetCountdown, self), 60)

	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.content, 21)
end

function OpenServiceAcitivitySportsListView:SetCountdown()
	self.panel_info.time.min = self.panel_info.time.min - 1
	if self.panel_info.time.min < 0 then
		self.panel_info.time.min = 59
		self.panel_info.time.hour = self.panel_info.time.hour - 1
		if self.panel_info.time.hour < 0 then
			self.panel_info.time.hour = 23
			self.panel_info.time.day = self.panel_info.time.day - 1
			if self.panel_info.time.day < 0 then
				----------------------------------------------------------
				OpenServiceAcitivityData.Instance:UpdateTabbarMarkList()
				----------------------------------------------------------
			end
		end
	end
	
	local activity_time_text = self.panel_info.time.day .. "天" .. self.panel_info.time.hour .. "小时" .. self.panel_info.time.min .. "分钟"
	self.node_t_list.lbl_left_time.node:setString(activity_time_text)
end

function OpenServiceAcitivitySportsListView:CreateTitle()
	if nil ~= self.title then return end
	self.title = Title.New()
	self.title:GetView():setPosition(self.ph_list.ph_title.x, self.ph_list.ph_title.y)
	self.node_t_list.layout_sport_list.node:addChild(self.title:GetView(), 20)
	self.title:SetTitleId(SPORT_LIST_TITLE_ID[self.sports_type])
end

function OpenServiceAcitivitySportsListView:CreateListBtn()
	if self.list_text then return end
	local x, y = self.ph_list.ph_list_btn.x, self.ph_list.ph_list_btn.y
	self.list_text = RichTextUtil.CreateLinkText("查看上榜名单", 17, COLOR3B.GREEN, nil, true)
	self.list_text:setPosition(x, y)
	self.node_t_list.layout_sport_list.node:addChild(self.list_text, 10)
	XUI.AddClickEventListener(self.list_text, BindTool.Bind(self.OnClickList, self), true)
end

function OpenServiceAcitivitySportsListView:CreateShowAward()
	if self.is_create_award then return end
	for i = 1, 4 do
		local ph = {}
		for k, v in pairs(self.panel_info.awards_list[i]) do
			ph = self.ph_list["ph_award_" .. i .. "_" .. k]
			local cell = BaseCell.New()
			cell:SetPosition(ph.x, ph.y)
			cell:SetAnchorPoint(0.5, 0.5)
			self.node_t_list.layout_sport_list.node:addChild(cell:GetView(), 99)
			cell:SetData(v)
			local award_name = ItemData.Instance:GetItemName(v.item_id)
			local award_text = XUI.CreateText(ph.x, ph.y - 50, 200, 0, cc.TEXT_ALIGNMENT_CENTER, award_name, nil, 17)
			local text_color = ItemData.Instance:GetItemColor(v.item_id)
			award_text:setColor(text_color)
			self.node_t_list.layout_sport_list.node:addChild(award_text, 20)
		end
		if i <= 3 then
			-- local content, rank_grade = OpenServiceAcitivityData.GetGredeContent(nil ~= self.panel_info.rank_data[i] and self.panel_info.rank_data[i].fraction or 0)
			self.node_t_list["lbl_name_" .. i].node:setString(nil ~= self.panel_info.rank_data[i] and self.panel_info.rank_data[i].name or "暂无上榜名单")
			-- self.node_t_list["lbl_fraction_" .. i].node:setString(rank_grade)
		end
	end
	self.is_create_award = true
end

function OpenServiceAcitivitySportsListView:OnClickList()
	ViewManager.Instance:OpenViewByDef(ViewDef.OpenServiceAcitivitySportsList)
end

return OpenServiceAcitivitySportsListView