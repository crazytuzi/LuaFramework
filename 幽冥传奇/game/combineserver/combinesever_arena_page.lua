CombineServerArenaPage = CombineServerArenaPage or BaseClass()


function CombineServerArenaPage:__init()
	
end	

function CombineServerArenaPage:__delete()
	if self.cell_gift_list ~= nil then
		for k,v in pairs(self.cell_gift_list) do
			v:DeleteMe()
		end
		self.cell_gift_list = {}
	end

	if self.ranking_list then
		self.ranking_list:DeleteMe()
		self.ranking_list = nil
	end 

	if self.grid_scroll_list then
		self.grid_scroll_list:DeleteMe()
		self.grid_scroll_list = nil
	end

	self:RemoveEvent()
end	

--初始化页面接口
function CombineServerArenaPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self:CreateLeitaiRank()
	self.select_index = 1

	self:InitEvent()
	self:SetBtnTouch()
	self:GetArenaTextInfo()
end	


--初始化事件
function CombineServerArenaPage:InitEvent()
	-- self.view.node_t_list.layout_arena_ranking.node:setVisible(false)
	self.view.node_t_list.layout_arena.btn_join.node:addClickEventListener(BindTool.Bind1(self.OnArenaState, self))
	self.view.node_t_list.layout_arena.btn_support.node:setVisible(false)
	-- self.view.node_t_list.layout_arena.btn_support.node:addClickEventListener(BindTool.Bind1(self.OnSupportPlayer, self))
	self.view.node_t_list.layout_arena_ranking.brn_enter.node:addClickEventListener(BindTool.Bind1(self.OnEnterBattle, self))
	self.view.node_t_list.layout_arena.btn_inleitai.node:addClickEventListener(BindTool.Bind1(self.OnEnterLeitai, self))
	-- self.toggole_flush_ranking = GlobalEventSystem:Bind(CombineServerActiviType.LEITAI, BindTool.Bind(self.FlushArenaRank, self))

	
end

--移除事件
function CombineServerArenaPage:RemoveEvent()
	-- if self.toggole_flush_ranking then
	-- 	GlobalEventSystem:UnBind(self.toggole_flush_ranking)
	-- 	self.toggole_flush_ranking = nil
	-- end
end

function CombineServerArenaPage:SetBtnTouch()
	for i = 1, 4 do
		self.view.node_t_list["layout_chest_"..i].node:setLocalZOrder(998)
		self.view.node_t_list["layout_chest_"..i].node:setTouchEnabled(true)
		self.view.node_t_list["layout_chest_"..i].node:setIsHittedScale(false)
		self.view.node_t_list["layout_chest_"..i].node:addTouchEventListener(BindTool.Bind(self.OnTouchLayout, self, i))
	end
end

function CombineServerArenaPage:OnTouchLayout(btn_type, sender, event_type, touch)
	if event_type == XuiTouchEventType.Began then
		self.is_long_click = false
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
		self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(function ()
			self.is_long_click = true
			CombineServerCtrl.Instance:OpenShowRewardView(btn_type)
		end,0.2)
	elseif event_type == XuiTouchEventType.Moved then
	elseif event_type == XuiTouchEventType.Ended then
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
	else	
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end

		if self.is_long_click then
			CombineServerCtrl.Instance:CloseTip()
		end	
	end	
end

--更新视图界面
function CombineServerArenaPage:UpdateData(data)
	-- local state = CombineServerData.Instance:CombineServerArenaState()
	-- if state == 1 then
	-- 	self.view.node_t_list.layout_arena.btn_join.node:setTitleText(Language.CombineServerActivity.CancelEnroll)
	-- else
	-- 	self.view.node_t_list.layout_arena.btn_join.node:setTitleText(Language.CombineServerActivity.EnrollJoin)
	-- end
	local marge_day = OtherData.Instance:GetCombindDays()						-- 合服时间
	local role_level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)		-- 人物等级
	local circle_level = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)		-- 人物转生等级
	local open_time = CombineServerData.Instance:CheckArenaOpenState()		
	local combine_time = marge_day >= CombineServerArenaCfg.arena.combineServerDay[1] and marge_day <= CombineServerArenaCfg.arena.combineServerDay[2]
	if role_level >= CombineServerArenaCfg.arena.levelLimit[2] and circle_level >= CombineServerArenaCfg.arena.levelLimit[1] and combine_time and open_time then
		self.view.node_t_list.layout_arena.btn_join.node:setEnabled(true)
		self.view.node_t_list.layout_arena.btn_inleitai.node:setEnabled(true)
	else
		self.view.node_t_list.layout_arena.btn_join.node:setEnabled(false)
		self.view.node_t_list.layout_arena.btn_inleitai.node:setEnabled(false)
	end

	local data_1 = MagicCityData.Instance:GetRankingList(4)
	local data_2 = MagicCityData.Instance:GetRankingList(5)

	if next(data_2) == nil then
		self.view.node_t_list.layout_arena_ranking.node:setVisible(false)
		self.view.node_t_list.layout_arena.node:setVisible(true)
		self.ranking_list:SetDataList(data_1)
	else
		self.view.node_t_list.layout_arena_ranking.node:setVisible(true)
		self.view.node_t_list.layout_arena.node:setVisible(false)
		self:CreateArenaRank()
		self:GetBattleTextInfo()
		local data = {}
		local index = 0
		for k,v in pairs(data_2) do
			data[index] = v
			index = index + 1
		end
		self.grid_scroll_list:SetDataList(data)
	end


	local my_rank, my_jifen = MagicCityData.Instance:GetMyArenaRankingData()
	local txt_jifen = string.format(Language.CombineServerActivity.MyArenaScore, my_jifen or 0)
	local txt_rank = string.format(Language.CombineServerActivity.MyArenaRank, my_rank or 0)
	if my_rank == 0 then
		self.view.node_t_list.layout_arena.txt_my_score.node:setString(txt_jifen)
		self.view.node_t_list.layout_arena.txt_my_rank.node:setString(Language.CombineServerActivity.NotRanking)
	else
		self.view.node_t_list.layout_arena.txt_my_score.node:setString(txt_jifen)
		self.view.node_t_list.layout_arena.txt_my_rank.node:setString(txt_rank)
	end

end	

function CombineServerArenaPage:OnArenaState()
	CombineServerCtrl.Instance:ReqCombineServerArenaIsEnroll(1)
end

function CombineServerArenaPage:OnSupportPlayer()
	CombineServerCtrl.Instance:ReqBattleSupport(1)
end

function CombineServerArenaPage:OnEnterLeitai()
	CombineServerCtrl.Instance:ReqEnterBattle(1)
end

function CombineServerArenaPage:OnEnterBattle()
	CombineServerCtrl.Instance:ReqEnterBattle(2)
end

function CombineServerArenaPage:GetArenaTextInfo()
	local scroll_node = self.view.node_t_list.layout_arena["txt_arena_info"].node
	local rich_content = XUI.CreateRichText(50, 0, 220, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	HtmlTextUtil.SetString(rich_content, Language.CombineServerActivity.EnrollInfo or "")
	rich_content:refreshView()
	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end

function CombineServerArenaPage:GetBattleTextInfo()
	local scroll_node = self.view.node_t_list.layout_arena_ranking["txt_battle_info"].node
	local rich_content = XUI.CreateRichText(50, 0, 220, 0, false)
	scroll_node:addChild(rich_content, 100, 100)
	HtmlTextUtil.SetString(rich_content, Language.CombineServerActivity.EnrollInfo or "")
	rich_content:refreshView()
	local scroll_size = scroll_node:getContentSize()
	local inner_h = math.max(rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	scroll_node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	rich_content:setPosition(scroll_size.width / 2, inner_h - 10)
	scroll_node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end

function CombineServerArenaPage:CreateLeitaiRank()
	if nil == self.ranking_list then
		local ph = self.view.ph_list.ph_ranking_list
		self.ranking_list = ListView.New()
		self.ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CombinServerLeitaiRender, nil, nil, self.view.ph_list.ph_rankinglist_item)
		self.ranking_list:GetView():setAnchorPoint(0, 0)
		self.ranking_list:SetMargin(2)
		self.ranking_list:SetItemsInterval(5)
		self.ranking_list:SetJumpDirection(ListView.Top)
		self.view.node_t_list.layout_arena.node:addChild(self.ranking_list:GetView(), 100)
	end		
end

function CombineServerArenaPage:CreateArenaRank()
	-- if nil == self.arena_ranking_list then
		
		-- self.arena_ranking_list = GridScroll.New()
		-- self.arena_ranking_list:Create(ph.x, ph.y, ph.w, ph.h, nil, CombinServerArenaRender, nil, nil, self.view.ph_list.ph_arena_list_item)
		-- self.arena_ranking_list:GetView():setAnchorPoint(0, 0)
		-- self.arena_ranking_list:SetMargin(2)
		-- self.arena_ranking_list:SetItemsInterval(5)
		-- self.arena_ranking_list:SetJumpDirection(ListView.Top)
		-- self.view.node_t_list.layout_arena_ranking.node:addChild(self.arena_ranking_list:GetView(), 100)
		if nil == self.grid_scroll_list then
			local data = MagicCityData.Instance:GetRankingList(5)
			local ph = self.view.ph_list.ph_arena_ranking_list
			self.grid_scroll_list = BaseGrid.New()
			local grid_node = self.grid_scroll_list:CreateCells({w=ph.w, h=ph.h, cell_count = #data, col=2, row=4, itemRender = CombinServerArenaRender, direction = ScrollDir.Vertical, ui_config =self.view.ph_list.ph_arena_list_item })
			-- grid_node:setAnchorPoint(0, 0)
			self.view.node_t_list.layout_arena_ranking.node:addChild(grid_node, 100)
			grid_node:setPosition(ph.x, ph.y)
		end
end

CombinServerLeitaiRender = CombinServerLeitaiRender or BaseClass(BaseRender)

function CombinServerLeitaiRender:__init()

end

function CombinServerLeitaiRender:__delete()
	
end

function CombinServerLeitaiRender:CreateChild()
	BaseRender.CreateChild(self)
end

function CombinServerLeitaiRender:OnFlush()
	if self.data == nil then return end
	-- PrintTable(self.data)
	if self.data.role_data.rank <= 3 then
		self.img_bg = XUI.CreateImageView(50, 35, ResPath.GetRankingList("bg_crowns_"..self.data.role_data.rank),true)
		self.view:addChild(self.img_bg, 100)
		self.node_tree.txt_ranking.node:setVisible(false)
	end
	self.node_tree.lbl_rankinglistplayer_name.node:setString(self.data.role_data.player_name)
	local profession_name = Language.Common.ProfName[self.data.role_data.prof]
	self.node_tree.txt_ranking.node:setString(self.data.role_data.rank)
	self.node_tree.txt_profession.node:setString(profession_name)
	self.node_tree.txt_count.node:setString(self.data.role_data.score)
	
	-- local index = COMBINESERVERDATA_PTHOTO[self.data.gift_type] or 1
	-- self.node_tree.gift_img.node:loadTexture(ResPath.GetBigPainting("gift_bg_" .. index))
end


CombinServerArenaRender = CombinServerArenaRender or BaseClass(BaseRender)

function CombinServerArenaRender:__init()

end

function CombinServerArenaRender:__delete()
	
end

function CombinServerArenaRender:CreateChild()
	BaseRender.CreateChild(self)
end

function CombinServerArenaRender:OnFlush()
	if self.data == nil then return end
	self.node_tree.txt_name.node:setString(self.data.role_data.player_name)
	self.node_tree.txt_zhanli.node:setString(string.format(Language.CombineServerActivity.Zhanli, self.data.role_data.canshu_1))
	self.node_tree.img_rank.node:setVisible(false)
	if self.data.role_data.rank <= 3 then
		self.node_tree.img_rank.node:loadTexture(ResPath.GetCombineServer("img_rank_" .. self.data.role_data.rank))
	else
		self.node_tree.img_rank.node:setVisible(false)
	end
	local profession_name = Language.Common.ProfName[self.data.role_data.prof]
	self.node_tree.txt_job.node:setString(Language.CombineServerActivity.ArenaProf .. profession_name)
	-- local index = COMBINESERVERDATA_PTHOTO[self.data.gift_type] or 1
	-- self.node_tree.gift_img.node:loadTexture(ResPath.GetBigPainting("gift_bg_" .. index))
end
