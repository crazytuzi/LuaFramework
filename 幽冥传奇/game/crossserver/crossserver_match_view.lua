CrossServerMatchView = CrossServerMatchView or BaseClass(XuiBaseView)

function CrossServerMatchView:__init()
	self:SetModal(true)
	self.def_index = 1

	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/activity.png"
	self.texture_path_list[3] = "res/xui/cross_server.png"
	self.title_img_path = ResPath.GetCrossServer("title_match")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"cross_server_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.ranking_list = nil
	self.my_enroll_state = 0
	self.my_reward_state = 0

end

function CrossServerMatchView:__delete()
	
end

function CrossServerMatchView:ReleaseCallBack()
	if self.ranking_list ~= nil then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end
end

function CrossServerMatchView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateLeitaiRank()
		self:GetMatchTextInfo()
		XUI.AddClickEventListener(self.node_t_list.btn_join.node, BindTool.Bind1(self.OnStartMate, self))
		
	end
end

function CrossServerMatchView:OpenCallBack()
	CrossServerMatchCtrl.Instance:CrossServerInfoReq()
end

function CrossServerMatchView:CloseCallBack()
	
end

function CrossServerMatchView:OnFlush(param_t, index)
	local data = CrossServerMatchData.Instance:GetCrossServerMatchRankData()
	self.ranking_list:SetDataList(data)
	local my_score, my_high_time, my_low_time, my_enroll_state = CrossServerMatchData.Instance:GetRoleInfo()
	self.my_reward_state = CrossServerMatchData.Instance:GetMyRewardState()
	self.my_enroll_state = my_enroll_state
	local my_rank = CrossServerMatchData.Instance:GetMyBattleRank()
	self.node_t_list.txt_high_site.node:setString(string.format(Language.CrossServerMatch.HighTimes, my_high_time))
	self.node_t_list.txt_low_site.node:setString(string.format(Language.CrossServerMatch.LowTimes, my_low_time))
	self.node_t_list.txt_my_score.node:setString(string.format(Language.CrossServerMatch.MyScore, my_score))
	self.node_t_list.txt_my_rank.node:setString(string.format(Language.CrossServerMatch.MyRanking, my_rank))
	if self.my_enroll_state == 0 then
		self.node_t_list.btn_join.node:setEnabled(false)
		self.node_t_list.btn_join.node:setTitleText(Language.CombineServerActivity.EnrollJoin)
	elseif self.my_enroll_state == 1 then
		self.node_t_list.btn_join.node:setEnabled(true)
		self.node_t_list.btn_join.node:setTitleText(Language.CombineServerActivity.EnrollJoin)
	else
		self.node_t_list.btn_join.node:setEnabled(true)
		self.node_t_list.btn_join.node:setTitleText(Language.CombineServerActivity.CancelEnroll)
	end
	
	if my_rank == 0 then
		self.node_t_list.txt_my_rank.node:setString(Language.CombineServerActivity.NotRanking)
	end
end

function CrossServerMatchView:ShowIndexCallBack(index)
	self:Flush(index)
end

function CrossServerMatchView:CreateLeitaiRank()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CrossServerMatchRender, nil, nil, self.ph_list.ph_list_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_cross_server.node:addChild(self.ranking_list:GetView(), 100)
	end		
end

function CrossServerMatchView:OnStartMate()
	self.my_enroll_state = CrossServerMatchData.Instance:GetMyEnrollState()
	if self.my_enroll_state == 2 then
		CrossServerMatchCtrl.Instance:CrossServerEnrollReq(2)
		self.node_t_list.btn_join.node:setTitleText(Language.CombineServerActivity.EnrollJoin)
	else
		CrossServerMatchCtrl.Instance:CrossServerEnrollReq(1)
		self.node_t_list.btn_join.node:setTitleText(Language.CombineServerActivity.CancelEnroll)
	end
end

function CrossServerMatchView:GetMatchTextInfo()
	local scroll_node = self.node_t_list.layout_cross_server["txt_arena_info"].node
	local rich_content = XUI.CreateRichText(50, 0, 250, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	HtmlTextUtil.SetString(rich_content, Language.CrossServerMatch.EnrollInfo or "")
	rich_content:refreshView()
	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end


-- 排行榜
CrossServerMatchRender = CrossServerMatchRender or BaseClass(BaseRender)

function CrossServerMatchRender:__init()

end

function CrossServerMatchRender:__delete()
	if self.rewrd_cell then
		self.rewrd_cell:DeleteMe()
		self.rewrd_cell = nil 
	end
end

function CrossServerMatchRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list.ph_rewrd_cell
	self.rewrd_cell = BaseCell.New()
	self.rewrd_cell:SetPosition(ph.x, ph.y)
	self.rewrd_cell:GetView():setAnchorPoint(0, 0)
	self.view:addChild(self.rewrd_cell:GetView(), 100)

	XUI.AddClickEventListener(self.node_tree.btn_reward.node, BindTool.Bind1(self.OnGetMyReward, self))
end

function CrossServerMatchRender:OnFlush()
	if self.data == nil then return end

	local reward_data = CrossServerMatchData.Instance:SetMatchRankGift(self.index)
	self.rewrd_cell:SetData({item_id = reward_data.id, num = reward_data.count, is_bind = reward_data.bind})

	local is_ranking = CrossServerMatchData.Instance:GetMyBattleRank()
	if is_ranking == self.index then
		self.node_tree.btn_reward.node:setVisible(true)
	else
		self.node_tree.btn_reward.node:setVisible(false)
	end
	self.my_reward_state = CrossServerMatchData.Instance:GetMyRewardState()
	self.node_tree.btn_reward.node:setEnabled(self.my_reward_state ~= 0)
	if self.my_reward_state == 2 then
		self.node_tree.btn_reward.node:setEnabled(false)
		self.node_tree.btn_reward.node:setTitleText(Language.Common.YiLingQu)
	end

	self.node_tree.txt_name.node:setString(self.data.player_name)
	self.node_tree.txt_rank.node:setString(self.index)
	self.node_tree.txt_zhanli.node:setString(self.data.zhanli)
	self.node_tree.txt_jifen.node:setString(self.data.score)
end

function CrossServerMatchRender:OnGetMyReward()
	CrossServerMatchCtrl.Instance:CrossServerAwardReq()
end


