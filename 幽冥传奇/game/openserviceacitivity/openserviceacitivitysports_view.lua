local OpenServiceAcitivitySportsView = OpenServiceAcitivitySportsView or BaseClass(SubView)

function OpenServiceAcitivitySportsView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 4, {0}},
	}
end

function OpenServiceAcitivitySportsView:LoadCallBack()
	self:CreateList()
	self.sports_type = OpenServiceAcitivityData.Instance:GetSportsShowIndex()
	self.panel_info = OpenServiceAcitivityData.Instance:GetSportsInfo(self.sports_type)
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.tips, 21, COLOR3B.OLIVE)
	self.node_t_list.img_level.node:loadTexture(ResPath.GetOpenServerActivities("sports_level_text" .. self.sports_type))
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.SportsChange, BindTool.Bind(self.OnFlushSportsView, self))
end

function OpenServiceAcitivitySportsView:ReleaseCallBack()
	if self.sports_list then
		self.sports_list:DeleteMe()
		self.sports_list = nil
	end
	self.panel_info = {}
	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
end

function OpenServiceAcitivitySportsView:ShowIndexCallBack()
	self:OnFlushSportsView()
end

function OpenServiceAcitivitySportsView:OnFlushSportsView()
	self.panel_info = OpenServiceAcitivityData.Instance:GetSportsInfo(self.sports_type)

	if SPROT_TYPE.MoldingSoulSports == self.panel_info.sports_type or SPROT_TYPE.CardHandlebookSports == self.panel_info.sports_type then
		self.node_t_list.lbl_level.node:setString(self.panel_info.my_grade)
	elseif SPROT_TYPE.GemStoneSports == self.panel_info.sports_type or SPROT_TYPE.DragonSpiritSports == self.panel_info.sports_type then
		local grade = GodFurnaceData.Instance:GetGradeNum(self.panel_info.my_grade)
		local star = GodFurnaceData.Instance:GetStarNum(self.panel_info.my_grade)
		self.node_t_list.lbl_level.node:setString(grade .. "阶" .. star .. "星")
	elseif SPROT_TYPE.WingSports == self.panel_info.sports_type then
		self.node_t_list.lbl_level.node:setString(self.panel_info.my_grade .. "阶")
	elseif SPROT_TYPE.CircleSports == self.panel_info.sports_type then
		self.node_t_list.lbl_level.node:setString(self.panel_info.my_grade .. "转")
	end

	local activity_time_text = self.panel_info.time.day .. "天" .. self.panel_info.time.hour .. "小时" .. self.panel_info.time.min .. "分钟"
	self.node_t_list.lbl_left_time.node:setString(activity_time_text)

	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.consume_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetCountdown, self), 60)

	self.sports_list:SetDataList(self.panel_info.item_list)
	-- for k, v in pairs(self.panel_info.item_list) do
	-- 	print("++++++++item_index", v.index, v.need_level)
	-- end
end

function OpenServiceAcitivitySportsView:SetCountdown()
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

function OpenServiceAcitivitySportsView:CreateList()
	if self.sports_list then return end
	local ph = self.ph_list.ph_sports_list
	self.sports_list = ListView.New()
	self.sports_list:Create(ph.x, ph.y, ph.w, ph.h, nil, SportsListRender, nil, nil, self.ph_list.ph_sports_item)
	self.sports_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_sports.node:addChild(self.sports_list:GetView(), 100)
	self.sports_list:SetItemsInterval(1)
	self.sports_list:SetJumpDirection(ListView.Top)
end

----------------------------------------------
-- 奖励列表item
----------------------------------------------

SportsListRender = SportsListRender or BaseClass(BaseRender)

function SportsListRender:__init()
end

function SportsListRender:__delete()
end

function SportsListRender:CreateChild()
	BaseRender.CreateChild(self)
	self:CreateAwardScroll()
	XUI.AddClickEventListener(self.node_tree.btn_receive.node, BindTool.Bind(self.OnClickReceive, self))
	self.node_tree.btn_receive.node:setVisible(true)
	self.node_tree.img_stamp.node:setVisible(false)
	self.node_tree.btn_receive.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_receive.node, 1)
end

function SportsListRender:OnFlush()
	if nil == self.data then return end

	if SPROT_TYPE.MoldingSoulSports == self.data.sports_type or SPROT_TYPE.CardHandlebookSports == self.data.sports_type then
		self.node_tree.lbl_level.node:setString(self.data.need_level)
	elseif SPROT_TYPE.GemStoneSports == self.data.sports_type or SPROT_TYPE.DragonSpiritSports == self.data.sports_type then
		local grade = GodFurnaceData.Instance:GetGradeNum(self.data.need_level)
		local star = GodFurnaceData.Instance:GetStarNum(self.data.need_level)
		self.node_tree.lbl_level.node:setString(grade .. "阶" .. star .. "星")
	elseif SPROT_TYPE.WingSports == self.data.sports_type then
		self.node_tree.lbl_level.node:setString(self.data.need_level .. "阶")
	elseif SPROT_TYPE.CircleSports == self.data.sports_type then
		self.node_tree.lbl_level.node:setString(self.data.need_level .. "转")
	end

	self.node_tree.img_item_level.node:loadTexture(ResPath.GetOpenServerActivities("sports_level_need_word" .. self.data.sports_type))
	self:CreateAwardList()
	if self.data.btn_state == 0 then
		self.node_tree.btn_receive.node:setEnabled(false)
		self.node_tree.btn_receive.node:setTitleText("未完成")
		self.node_tree.btn_receive.remind_eff:setVisible(false)
	elseif self.data.btn_state == 1 then
		self.node_tree.btn_receive.node:setEnabled(true)
		self.node_tree.btn_receive.node:setTitleText("领    取")
		self.node_tree.btn_receive.remind_eff:setVisible(true)
	else
		self.node_tree.btn_receive.node:setVisible(false)
		self.node_tree.img_stamp.node:setVisible(true)
	end
end

function SportsListRender:CreateAwardList()
	if self.award_cell_list then 
		for k, v in pairs(self.award_cell_list) do
			v:GetView():removeFromParent()
			v:DeleteMe()
			v = nil
		end
		self.award_cell_list = {}
	end
	self.award_cell_list = {}
	local x, y = 0, 2
	local x_interval = 85
	for k, v in pairs(self.data.award_list) do
		local award_cell = BaseCell.New()
		award_cell:SetAnchorPoint(0, 0)
		self.reward_list_view:addChild(award_cell:GetView(), 99)
		award_cell:SetPosition(x, y)
		award_cell:SetData(v)
		-- local award_name = ItemData.Instance:GetItemName(v.item_id)
		-- local award_text = XUI.CreateText(37, - 10, 100, 0, cc.TEXT_ALIGNMENT_CENTER, award_name, nil, 17)
		-- local text_color = ItemData.Instance:GetItemColor(v.item_id)
		-- award_text:setColor(text_color)
		-- award_cell:GetView():addChild(award_text, 20)
		table.insert(self.award_cell_list, award_cell)
		x = x + x_interval
	end
	local w = #self.data.award_list * x_interval
	self.reward_list_view:setInnerContainerSize(cc.size(w, 80))
end

function SportsListRender:CreateAwardScroll()
	self.reward_items = {}
	self.reward_list_view = self.node_tree.scroll_award_view.node
	self.reward_list_view:setScorllDirection(ScrollDir.Horizontal)
end

-- 创建选中特效
function SportsListRender:CreateSelectEffect()
end

-- 领取奖励按钮回调
function SportsListRender:OnClickReceive()
	OpenServiceAcitivityCtrl.SendGetSportGift(self.data.sports_type, self.data.index)
end

return OpenServiceAcitivitySportsView