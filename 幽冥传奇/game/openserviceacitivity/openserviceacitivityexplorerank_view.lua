local OpenServiceAcitivityExploreRankView = OpenServiceAcitivityExploreRankView or BaseClass(SubView)

function OpenServiceAcitivityExploreRankView:__init()
	self:SetModal(true)
	self.texture_path_list[1] = 'res/xui/openserviceacitivity.png'
	self.config_tab = {
		{"openserviceacitivity_ui_cfg", 3, {0}},
		{"openserviceacitivity_ui_cfg", 16, {0}},
	}
end

function OpenServiceAcitivityExploreRankView:ReleaseCallBack()
	if nil~=self.grid_explore_scroll_list then
		self.grid_explore_scroll_list:DeleteMe()
	end
	self.grid_explore_scroll_list = nil

	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
end

function OpenServiceAcitivityExploreRankView:LoadCallBack()
	self.panel_info = OpenServiceAcitivityData.Instance:GetExploreRankInfo()
	self:CreateRankGridScroll()
	EventProxy.New(OpenServiceAcitivityData.Instance, self):AddEventListener(OpenServiceAcitivityData.ExploreRankChange, BindTool.Bind(self.OnFlushExploreRankView, self))
	RichTextUtil.ParseRichText(self.node_t_list.rich_tips.node, self.panel_info.tips, 19, COLOR3B.OLIVE)
	XUI.AddClickEventListener(self.node_t_list["btn_tips"].node, BindTool.Bind(self.OnClickTips, self))
end

function OpenServiceAcitivityExploreRankView:ShowIndexCallBack()
	self:OnFlushExploreRankView()
	OpenServiceAcitivityCtrl.SendExploreRankInfo(0)
end

function OpenServiceAcitivityExploreRankView:OnFlushExploreRankView()
	self.panel_info = OpenServiceAcitivityData.Instance:GetExploreRankInfo()
	self.grid_explore_scroll_list:SetDataList(self.panel_info.item_list)
	self.grid_explore_scroll_list:JumpToTop()
	self.node_t_list.lbl_activity_tip.node:setString(self.panel_info.explore_times)
	local activity_time_text = self.panel_info.time.day .. "天" .. self.panel_info.time.hour .. "小时" .. self.panel_info.time.min .. "分钟"
	self.node_t_list.lbl_last_time.node:setString(activity_time_text)
	self.node_t_list.lbl_act_time.node:setString(self.panel_info.activity_time_interval)
	if self.panel_info.my_rank_number and self.panel_info.my_rank_number > 0 then
		self.node_t_list.lbl_ramk_num.node:setString(string.format(Language.OpenServiceAcitivity.ExploreMyRank,self.panel_info.my_rank_number))
	else
		self.node_t_list.lbl_ramk_num.node:setString(Language.OpenServiceAcitivity.NoRanking)
	end
	if self.consume_timer_quest then
		GlobalTimerQuest:CancelQuest(self.consume_timer_quest)
	end
	self.consume_timer_quest = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.SetCountdown, self), 60)
end

function OpenServiceAcitivityExploreRankView:CreateRankGridScroll()
	if nil == self.node_t_list.layout_explore_rank then
		return
	end
	if nil == self.grid_explore_scroll_list then
		local ph = self.ph_list.ph_explore_rank_view_list
		self.grid_explore_scroll_list = GridScroll.New()
		self.grid_explore_scroll_list:Create(ph.x, ph.y, ph.w, ph.h, 1, 118, ExploreRankItemRender, ScrollDir.Vertical, false, self.ph_list.ph_explore_rank_list)
		self.node_t_list.layout_explore_rank.node:addChild(self.grid_explore_scroll_list:GetView(), 100)
	end
end

function OpenServiceAcitivityExploreRankView:SetCountdown()
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
	self.node_t_list.lbl_last_time.node:setString(activity_time_text)
end

function OpenServiceAcitivityExploreRankView:OnClickTips()
	DescTip.Instance:SetContent(self.panel_info.tip_bar, Language.OpenServiceAcitivity.ExploreTips)
end

ExploreRankItemRender = ExploreRankItemRender or BaseClass(BaseRender)
function ExploreRankItemRender:__init()
end

function ExploreRankItemRender:__delete()
	if nil ~= self.cell_charge_list then
		self.cell_charge_list:DeleteMe()
		self.cell_charge_list = nil
	end

	if nil ~= self.rank_num then
		self.rank_num:DeleteMe()
		self.rank_num = nil
	end
end

function ExploreRankItemRender:CreateChild()
	BaseRender.CreateChild(self)
	self.cell_charge_list = ListView.New()
	self.cell_charge_list:Create(230, 10, 290, 90, ScrollDir.Horizontal, ExploreRankBaseCell, nil, nil, {w = BaseCell.SIZE, h = BaseCell.SIZE})
	self.cell_charge_list:GetView():setAnchorPoint(0, 0)
	self.cell_charge_list:SetItemsInterval(10)
	self.view:addChild(self.cell_charge_list:GetView(), 10)

	ph = self.ph_list.ph_score
	self.rank_num = NumberBar.New()
	self.rank_num:Create(ph.x, ph.y, 0, 0, ResPath.GetCommon("num_150_"))
	self.rank_num:SetGravity(NumberBarGravity.Left)
	self.view:addChild(self.rank_num:GetView(), 101)
	XUI.AddClickEventListener(self.node_tree.btn_gift_lingqu.node, BindTool.Bind(self.OnClickGetRewardBtn, self), true)
	self.remind_eff = RenderUnit.CreateEffect(23, self.node_tree.btn_gift_lingqu.node, 1)
end

function ExploreRankItemRender:OnClick()
	if nil ~= self.click_callback then
		self.click_callback(self)
	end
end

function ExploreRankItemRender:OnFlush()
	if nil == self.data then
		return
	end
	
	local r_index = self:GetIndex()
	if self.data.btn_state ~= 2 then
		self.rank_num:GetView():setVisible(false)
		self.node_tree.img_rank_3.node:setVisible(true)
		self.node_tree.img_rank_1.node:setVisible(false)
		self.node_tree.img_rank_2.node:setVisible(false)
		self.node_tree.lbl_long_rolename.node:setString(" ")
		if self.data.btn_state == 1 then    --可以领取
			self.node_tree.btn_gift_lingqu.node:setVisible(true)
			self.remind_eff:setVisible(true)
			self.node_tree.img_explore_reward_state.node:setVisible(false)
		elseif self.data.btn_state == 4 then   --已经领取
			self.node_tree.img_explore_reward_state.node:setVisible(true)
			self.node_tree.btn_gift_lingqu.node:setVisible(false)
			self.remind_eff:setVisible(false)
			self.node_tree.img_explore_reward_state.node:loadTexture(ResPath.GetCommon("stamp_1"))
		elseif self.data.btn_state == 3 then       --未达到
			self.node_tree.img_explore_reward_state.node:setVisible(true)
			self.node_tree.btn_gift_lingqu.node:setVisible(false)
			self.remind_eff:setVisible(false)
			self.node_tree.img_explore_reward_state.node:loadTexture(ResPath.GetCommon("stamp_3"))
		end
	else
		self.rank_num:GetView():setVisible(true)
		self.node_tree.img_rank_3.node:setVisible(false)
		self.node_tree.img_rank_1.node:setVisible(true)
		self.node_tree.img_rank_2.node:setVisible(true)
		self.rank_num:SetNumber(self.data.index)
		self.node_tree.img_explore_reward_state.node:setVisible(false)
		self.node_tree.btn_gift_lingqu.node:setVisible(false)
		self.remind_eff:setVisible(false)
		if self.data.rank_info_list then
			self.node_tree.lbl_long_rolename.node:setString(self.data.rank_info_list.name)
		else
			self.node_tree.lbl_long_rolename.node:setString(Language.OpenServiceAcitivity.NoRanking)
		end
	end

	local data_list = {}
	for k, v in pairs(self.data.award_list) do
		if type(v) == "table" then
			table.insert(data_list, v)
		end
	end
	self.cell_charge_list:SetDataList(data_list)
	self.cell_charge_list:SetJumpDirection(ListView.Left)
	
end

function ExploreRankItemRender:OnClickGetRewardBtn()
	if self.data == nil then return end
	OpenServiceAcitivityCtrl.SendExploreRankInfo(1)
end

ExploreRankBaseCell = ExploreRankBaseCell or BaseClass(BaseCell)

function ExploreRankBaseCell:OnFlush()
	BaseCell.OnFlush(self)
	self:SetQualityEffect(self.data and self.data.effectId or 0)
end

function ExploreRankBaseCell:CreateSelectEffect()
end

return OpenServiceAcitivityExploreRankView