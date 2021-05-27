CrossEatChickenView = CrossEatChickenView or BaseClass(XuiBaseView)

function CrossEatChickenView:__init()
	self:SetModal(true)
	self.def_index = 1

	self.texture_path_list[1] = "res/xui/strength_fb.png"
	self.texture_path_list[2] = "res/xui/activity.png"
	self.texture_path_list[3] = "res/xui/cross_server.png"
	self.title_img_path = ResPath.GetCrossServer("title_eat_chicken")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"cross_eat_chicken_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	self.ranking_list = nil
end

function CrossEatChickenView:__delete()
	
end

function CrossEatChickenView:ReleaseCallBack()
	if self.ranking_list ~= nil then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end

	if self.choice_list ~= nil then
		self.choice_list:DeleteMe()
		self.choice_list = nil
	end
	self.selec_idx = nil
	self.my_enroll_state = nil
end

function CrossEatChickenView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:CreateChildElements()
		self:SetDesTipInfo()
		XUI.AddClickEventListener(self.node_t_list.btn_match.node, BindTool.Bind(self.OnStartMate, self))
		XUI.AddClickEventListener(self.node_t_list.btn_drop_point_chose.node, BindTool.Bind(self.OnChoiceSwitch, self), true)
		-- self:RandomChoseDropRange()
	end
	
end

function CrossEatChickenView:OpenCallBack()
	CrossEatChickenCtrl.CrossEatChickenInfoReq()
	-- print("open-----------------")
end

function CrossEatChickenView:CloseCallBack()
	
end

function CrossEatChickenView:OnFlush(param_t, index)
	for k, v in pairs(param_t) do
		if k == "all_info" then
			self:FlushEnrollState()
			self:FlushDropRangeTxt()
			self:FlushRankList()
			self:FlushCurMatchNum()
			self:FlushRankAndScore()
			self:FlushRestCnt()
		elseif k == "enroll" then
			self:FlushEnrollState(v.key)
		elseif k == "drop_range" then
			self:FlushDropRangeTxt(v.key)
		elseif k == "award_fetch" then
			self:FlushRankAndScore(v.keys[1], v.keys[2])
			self:FlushRankList()
		elseif k == "match_player" then
			self:FlushCurMatchNum(v.key)
		end
	end
end

function CrossEatChickenView:ShowIndexCallBack(index)
	self:Flush(index)
end

function CrossEatChickenView:RandomChoseDropRange()
	if self.my_enroll_state == 1 then
		local rand_idx = math.random(1, 9)
		if self.choice_list then
			self.choice_list:SelectIndex(rand_idx)
		end
	end
end

function CrossEatChickenView:FlushEnrollState(key)
	key = key or "my_enroll_state"
	self.my_enroll_state = CrossEatChickenData.Instance:GetMyInfo(key)
	-- print("my_enroll_state=====", self.my_enroll_state)
	self.node_t_list.btn_match.node:setEnabled(self.my_enroll_state ~= 0)
	local txt = Language.CrossEatChicken.MatchBtnTxts[self.my_enroll_state] or Language.CrossEatChicken.MatchBtnTxts[1]
	self.node_t_list.btn_match.node:setTitleText(txt)
	self:RandomChoseDropRange()
end

function CrossEatChickenView:FlushDropRangeTxt(key)
	key = key or "my_drop_range"
	local my_drop_range = CrossEatChickenData.Instance:GetMyInfo(key)
	local name = CrossEatChickenData.Instance:GetDropRangeList(my_drop_range) and CrossEatChickenData.Instance:GetDropRangeList(my_drop_range).name or ""
	self.node_t_list.txt_drop_point_name.node:setString(name)
end

function CrossEatChickenView:FlushRankList()
	local rank_list = CrossEatChickenData.Instance:GetRankList()
	self.ranking_list:SetDataList(rank_list)
end

function CrossEatChickenView:FlushCurMatchNum(key)
	key = key or "cur_match_player_cnt"
	local cur_match_player_cnt = CrossEatChickenData.Instance:GetMyInfo(key)
	self.node_t_list.txt_cur_match_num.node:setString(string.format(Language.CrossEatChicken.CurMatchTxt, cur_match_player_cnt, CrossEatChickenData.Instance:GetNeedJoinCnt()))
end

function CrossEatChickenView:FlushRankAndScore(key1, key2)
	key1 = key1 or "my_rank"
	key2 = key2 or "my_score"
	local my_rank = CrossEatChickenData.Instance:GetMyInfo(key1)
	local my_score = CrossEatChickenData.Instance:GetMyInfo(key2)
	self.node_t_list.txt_my_rank.node:setString(my_rank)
	self.node_t_list.txt_my_score.node:setString(my_score)
end

function CrossEatChickenView:FlushRestCnt()
	local rest_cnt = CrossEatChickenData.Instance:GetRestCnt()
	self.node_t_list.txt_rest_cnt.node:setString(rest_cnt)
end

function CrossEatChickenView:CreateChildElements()
	if nil == self.ranking_list then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CrossEatChickenRankRender, nil, nil, self.ph_list.ph_rankinglist_item)
		-- self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_cross_eat_chicken.node:addChild(self.ranking_list:GetView(), 100)
	end	

	local name_list = CrossEatChickenData.Instance:GetDropRangeList()
	ph = self.ph_list.ph_choice_list
	if nil == self.choice_list then
		self.choice_list = ListView.New()
		self.choice_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CrossEatChickenChoiceItem, nil, nil, self.ph_list.ph_drop_choice_item)
		self.choice_list:SetItemsInterval(3)
		self.choice_list:SetSelectCallBack(BindTool.Bind(self.ChoiceListSelectCallback, self))
		-- self.choice_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_cross_eat_chicken.node:addChild(self.choice_list:GetView(), 100)
		self.choice_list:GetView():setVisible(false)
		self.choice_list:SetDataList(name_list)
	end	
	for i = 1, 9 do
		self.node_t_list["txt_map_name_" .. i].node:setString(name_list[i].name)
	end
end

function CrossEatChickenView:ChoiceListSelectCallback(item, index)
	local data = item:GetData()
	if self.selec_idx and self.selec_idx == index then return end
	if item == nil or data == nil then return end
	self.node_t_list.txt_drop_point_name.node:setString(data.name or "000")
	self.choice_list:GetView():setVisible(false)
	self.selec_idx = index
	CrossEatChickenCtrl.CrossEatChickenSetDropRangeReq(index)
end

function CrossEatChickenView:OnStartMate()
	if self.my_enroll_state then
		local join_operate = 1
		if self.my_enroll_state == 2 then
			join_operate = 2
		end
		CrossEatChickenCtrl.CrossEatChickeEnrollReq(join_operate)
	end
end

function CrossEatChickenView:OnChoiceSwitch()
	if self.choice_list then
		local vis = self.choice_list:GetView():isVisible()
		self.choice_list:GetView():setVisible(not vis)
	end
end

function CrossEatChickenView:SetDesTipInfo()
	local scroll_node = self.node_t_list.layout_cross_eat_chicken["rich_content"].node
	local rich_content = XUI.CreateRichText(50, 0, 500, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	HtmlTextUtil.SetString(rich_content, Language.CrossEatChicken.EnrollInfo or "")
	rich_content:refreshView()
	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end


-- 排行榜
CrossEatChickenRankRender = CrossEatChickenRankRender or BaseClass(BaseRender)

function CrossEatChickenRankRender:__init()

end

function CrossEatChickenRankRender:__delete()
	if self.rewrd_cell then
		self.rewrd_cell:DeleteMe()
		self.rewrd_cell = nil 
	end
end

function CrossEatChickenRankRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_cell
	self.rewrd_cell = BaseCell.New()
	self.rewrd_cell:SetPosition(ph.x, ph.y)
	self.rewrd_cell:GetView():setAnchorPoint(0, 0)
	self.view:addChild(self.rewrd_cell:GetView(), 100)
	self.node_tree.btn_fetch.node:setVisible(false)
	self.node_tree.txt_fetched.node:setVisible(false)
	XUI.AddClickEventListener(self.node_tree.btn_fetch.node, BindTool.Bind(self.OnGetMyReward, self))
end

function CrossEatChickenRankRender:OnFlush()
	if self.data == nil then return end
	local my_rank = CrossEatChickenData.Instance:GetMyInfo("my_rank")
	local my_awar_state = CrossEatChickenData.Instance:GetMyInfo("my_awar_state")
	self.node_tree.btn_fetch.node:setVisible(self.data.rank == my_rank and my_awar_state == 1)
	self.node_tree.txt_fetched.node:setVisible(self.data.rank == my_rank and my_awar_state == 2)
	local award_cfg = CrossEatChickenData.GetAwardCfgByRank(self.data.rank)
	if award_cfg then
		self.rewrd_cell:SetData({item_id = award_cfg.id, num = award_cfg.count, is_bind = award_cfg.bind})
	end
	self.node_tree.txt_stage.node:setString(self.data.rank)
	self.node_tree.txt_player.node:setString(self.data.player_name)
	self.node_tree.txt_score.node:setString(self.data.score)
end

function CrossEatChickenRankRender:OnGetMyReward()
	CrossEatChickenCtrl.CrossEatChickenGetAwardReq()
end


-- ChoiceItem
CrossEatChickenChoiceItem = CrossEatChickenChoiceItem or BaseClass(BaseRender)

function CrossEatChickenChoiceItem:__init()

end

function CrossEatChickenChoiceItem:__delete()
end

function CrossEatChickenChoiceItem:CreateChild()
	BaseRender.CreateChild(self)
end

function CrossEatChickenChoiceItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_drop_place_name.node:setString(self.data.name)
end
