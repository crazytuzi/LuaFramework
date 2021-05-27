MaFaExploreView = MaFaExploreView or BaseClass(XuiBaseView)

function MaFaExploreView:__init()
	self.texture_path_list[1] = 'res/xui/activity.png'
	self.texture_path_list[2] = 'res/xui/strength_fb.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"common_ui_cfg", 2, {0}},
		{"mafa_explore_ui_cfg", 1, {0}},
	}
	
	self.title_img_path = ResPath.GetActivityPic("mafa_title")
	self.pos_list = {}
	self.pos_index = 0 --全数 * 24 + 索引
end

function MaFaExploreView:__delete()

end

function MaFaExploreView:ReleaseCallBack()
	if self.reward_cell ~= nil then
		for k,v in pairs(self.reward_cell) do
			v:DeleteMe()
		end
		self.reward_cell = {}
	end
	if self.ranking_view_list then
		self.ranking_view_list:DeleteMe()
		self.ranking_view_list = nil 
	end
	if self.effect_data ~= nil then
		for k,v in pairs(self.effect_data) do
			if v ~= nil then
				v:setStop()
			end
		end
		self.effect_data = nil
	end

	if self.rich_man then
		self.rich_man:DeleteMe()
		self.rich_man = nil
	end	

	self.game_scene = nil
	Runner.Instance:RemoveRunObj(self)

	self.pos_list = {}
end

function MaFaExploreView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		self:SetShowPlayEff()
		self.node_t_list.layout_reawrd.txt_num.node:setString("x"..MulphaAdventureConfig.dailyGetDiceCount)
		self.node_t_list.layout_reawrd.btn_get_num.node:addClickEventListener(BindTool.Bind(self.GetDices, self))
		self.node_t_list.btn_tip.node:addClickEventListener(BindTool.Bind(self.OpenTipContent, self))
		self.node_t_list.layout_ranking.btn_ranking.node:addClickEventListener(BindTool.Bind(self.OpenRankingListView, self))
		self.node_t_list.btn_use.node:addClickEventListener(BindTool.Bind(self.UseDiceFree, self))
		self.node_t_list.btn_use_yaokong.node:addClickEventListener(BindTool.Bind(self.UseDiceByGold, self))
		self:CreateCells()
		self:CreateList()
		self:SetBtnTouch()
		-- self.node_t_list.layout_event_panel.node:setVisible(false)
		-- self.node_t_list.layout_event_panel.node:setLocalZOrder(998)
		RichTextUtil.ParseRichText(self.node_t_list.tips.node, Language.AllDayActivity.Desc_tip, 24)
		self.last_pos = 0
		Runner.Instance:AddRunObj(self)
	end
end

function MaFaExploreView:UseDiceFree()
	local pos = ActivityData.Instance:GetCurPos()
	local reward_state, reward_pos = ActivityData.Instance:BoolGetReward() 
	local cell = self.reward_cell[pos]
	local data = cell:GetData()
	if reward_state == 2 then
		ActivityCtrl.Instance:OpenEventPanel(data)
	elseif reward_state == 1 then
		if data.eventType == MulphaAdventureEvent.fight or data.eventType == MulphaAdventureEvent.canNotPassFight then
			ActivityCtrl.Instance:OpenReWardPanel(data.awardDesc, reward_pos, data)
		else
			ActivityCtrl.Instance:OpenReWardPanel(data.desc, reward_pos, data)
		end
	else
		if ActivityData.Instance:GetHadBoolRun() then
			ActivityCtrl.Instance:ReqUseDices(1, 0)
		else
			SysMsgCtrl.Instance:FloatingTopRightText(Language.AllDayActivity.DescTip_1)
		end
	end
end

function MaFaExploreView:UseDiceByGold()
	ActivityCtrl.Instance:OpenUseDice()
end

function MaFaExploreView:IngnoreBoss()
	ActivityCtrl.Instance:ReqCustomsOprate(1)
end

function MaFaExploreView:FigthtBoss()
	ActivityCtrl.Instance:ReqCustomsOprate(2)
end


function MaFaExploreView:SetBtnTouch()
	for i = 1, 5 do
		self.node_t_list["btn_mafa_chest_"..i].node:setLocalZOrder(998)
		-- self.node_t_list["btn_chest_"..i].node:setTouchEnabled(true)
		-- self.node_t_list["btn_chest_"..i].node:setIsHittedScale(false)
		-- self.node_t_list["btn_chest_"..i].node:addTouchEventListener(BindTool.Bind(self.OnTouchLayout, self, i))
		self.node_t_list["btn_mafa_chest_"..i].node:addClickEventListener(BindTool.Bind(self.GetRewardMafaByType, self, i))
	end
end

function MaFaExploreView:GetRewardMafaByType(type)
	local data = ActivityData.Instance:GetBoxState()
	local cur_data = data[type] or {}
	if cur_data.reward_state == 1 then
		ActivityCtrl.Instance:GetMaFaExporeRewardReq(type)
	else
		ActivityCtrl.Instance:OpenRewardLongClickTip(type*2)
	end
end

function MaFaExploreView:OpenRankingListView()
	ActivityCtrl.Instance:GetMaFaExporeRankingReq()
end


function MaFaExploreView:CreateList()
	if self.ranking_view_list == nil then
		local ph = self.ph_list.ph_ranking_list
		self.ranking_view_list = ListView.New()
		self.ranking_view_list:Create(ph.x, ph.y, ph.w, ph.h, nil, MaFaRankingRender, nil, nil, self.ph_list.ph_ranking_item_mafa)
		self.ranking_view_list:GetView():setAnchorPoint(0, 0)
		self.ranking_view_list:SetMargin(2)
		self.ranking_view_list:SetItemsInterval(5)
		self.ranking_view_list:SetJumpDirection(ListView.Top)
		self.node_t_list.layout_ranking.node:addChild(self.ranking_view_list:GetView(), 100)
	end
end

function MaFaExploreView:CreateCells()
	self.reward_cell = {}
	for i = 1, 24 do
		local ph = self.ph_list["ph_cell_"..i]
		local cell = self:CreateRender(ph)
		cell:SetIndex(i)
		table.insert(self.reward_cell, cell)
	end
	local container = self.node_t_list.layout_pos.node
	local size = container:getContentSize()
	self.game_scene = GameScene:create()
	self.game_scene:SetViewRect(cc.rect(0, 0, size.width, size.height))
	container:addChild(self.game_scene, 99)

	local role_vo = GameVoManager.Instance:CreateVo(RoleVo)
	role_vo[OBJ_ATTR.CREATURE_HP] = 1
	role_vo[OBJ_ATTR.ENTITY_MODEL_ID] = RoleData.Instance:GetAttr(OBJ_ATTR.ENTITY_MODEL_ID)
	role_vo[OBJ_ATTR.ACTOR_WEAPON_APPEARANCE] = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_WEAPON_APPEARANCE)
	role_vo[OBJ_ATTR.ACTOR_WING_APPEARANCE] = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_WING_APPEARANCE)
	
	self.rich_man = RichMan.New(role_vo, self.game_scene)
	self.rich_man:SetEndMoveCallBack(BindTool.Bind(self.OnMoveEnd,self))
	self.rich_man:Init()
end

function MaFaExploreView:OnMoveEnd()
	if #self.pos_list > 0 then
		local pos = table.remove(self.pos_list,1)
		self.rich_man:AppendConcatAction(ActionType.Move,pos,0.5)
		ActivityData.Instance:SetBoolActivityBoolRun(false)
	else
		self:BoolShowBossPanel()	
		self:FlushMyCircle(circle)	
		ActivityData.Instance:SetBoolActivityBoolRun(true)	
	end
end	

function MaFaExploreView:CreateRender(ph)
	local cell = MaFaRender.New()
	local render_ph = self.ph_list.ph_render  
	cell:SetUiConfig(render_ph, true)
	cell:GetView():setPosition(ph.x, ph.y)
	self.node_t_list.layout_pos.node:addChild(cell:GetView())
	return cell
end

function MaFaExploreView:Update(now_time, elapse_time)
	if self.rich_man then
		self.rich_man:Update(now_time, elapse_time)
	end	
end		

function MaFaExploreView:OpenCallBack()
	ActivityCtrl.Instance:ReqMafaexploreInfo()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function MaFaExploreView:ShowIndexCallBack(index)
	self:Flush(index)
end

function MaFaExploreView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
	ActivityCtrl.Instance:CloseRewardTip()
	ActivityCtrl.Instance:CloseRankingTip()
	ActivityCtrl.Instance:CloseEventPanelTip()
end

function MaFaExploreView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			ActivityData.Instance:SetBoolActivityBoolRun(true)
			self:FlushAll()
			self:FlushBtn()
		elseif k == "oprate_result" then
			local circle = ActivityData.Instance:GetMyCircle()
			--self.node_t_list.layout_event_panel.node:setVisible(false)
			
			local pos = ActivityData.Instance:GetCurPos()
			local temp = circle * 24 + pos - 1
			local dir = 1
			if temp > self.pos_index then
				dir = 1
			else
				dir = -1
			end	
			local num = math.abs(self.pos_index - temp)
			for i = self.pos_index + dir, temp ,dir do
				local index = (i % 24) + 1
				local x,y = self.reward_cell[index]:GetView():getPosition()
				table.insert(self.pos_list,cc.p(x + 40,y + 40))
			end	
			self.pos_index = temp

			if #self.pos_list > 0 then
				local pos = table.remove(self.pos_list,1)
				self.rich_man:AppendConcatAction(ActionType.Move,pos,0.5)
			end

			local cur_number = ActivityData.Instance:GetCurNumber()
			self.node_t_list.img_dices.node:loadTexture(ResPath.GetActivityPic("dice_"..cur_number))
			
			self:FlushMydices()
			self:SetRankingList()
			self:FlushBoxState()
			self:SetCellData()
		elseif k == "close_view" then
			self:SetCellData()
			self:FlushMydices()
			--self.node_t_list.layout_event_panel.node:setVisible(false)
		elseif k == "box_state_change" then
			self:FlushBoxState()
		elseif k == "dices_change" then
			self:FlushBtn()
			self:FlushMydices()
		elseif k == "ranking_change" then
			self:SetRankingList()
		end
	end
end

function MaFaExploreView:SetCellData()
	local circle = ActivityData.Instance:GetMyCircle()
	if circle >= MAX_CIRCLE_NUM then
		local data = ActivityData.Instance:GetSpecialItemData()
		for k, v in pairs(data) do
			if self.reward_cell[k] ~= nil then
				self.reward_cell[k]:SetData(v)
			end
		end
	end
end

function MaFaExploreView:FlushAll()
	local data = {} 
	local circle = ActivityData.Instance:GetMyCircle()
	data = ActivityData.Instance:GetNormalConfig()
	if circle >= MAX_CIRCLE_NUM then
		data = ActivityData.Instance:GetSpecialItemData()
	end
	for k, v in pairs(data) do
		if self.reward_cell[k] ~= nil then
			self.reward_cell[k]:SetData(v)
		end
	end
	
	local pos = ActivityData.Instance:GetCurPos()
	self.pos_index = circle * 24 + pos - 1 
	local x,y = self.reward_cell[(self.pos_index % 24) + 1]:GetView():getPosition()
	self.rich_man:SetRealPos(x + 40,y + 40)

	local cur_number = ActivityData.Instance:GetCurNumber()
	if cur_number == 0 then
		cur_number = 1
	end
	self.node_t_list.img_dices.node:loadTexture(ResPath.GetActivityPic("dice_"..cur_number))
	self:BoolShowBossPanel()
	self:FlushMyCircle(circle)
	self:FlushMydices()
	self:SetRankingList()
	self:FlushBoxState()
end

function MaFaExploreView:FlushBtn()
	self.dice_bool_get = ActivityData.Instance:GetMaFaInfo() 
	XUI.SetButtonEnabled(self.node_t_list.layout_reawrd.btn_get_num.node, self.dice_bool_get == 0)
end

function MaFaExploreView:FlushMyCircle(circle)
	circle = circle or  ActivityData.Instance:GetMyCircle()
	self.node_t_list.txt_my_circle.node:setString(circle)
	self.node_t_list.prog9_reward.node:setPercent(circle/MAX_CIRCLE_NUM*100)
end

function MaFaExploreView:FlushMydices()
	local _, had_dices_num = ActivityData.Instance:GetMaFaInfo()
	self.node_t_list.txt_guzi_num.node:setString(had_dices_num)
end

function MaFaExploreView:FlushBoxState()
	local data = ActivityData.Instance:GetBoxState()
	for k,v in pairs(self.effect_data) do
		v:setVisible(false)
	end
	for i,v in ipairs(data) do
		local path =(v.reward_state == 2 and ResPath.GetStrenfthFb("chest_get_"..i) or ResPath.GetStrenfthFb("chest_"..i))
		self.node_t_list["btn_mafa_chest_"..i].node:loadTextures(path)
		if v.reward_state == 1 then
			local pos_x, pos_y = self.node_t_list["btn_mafa_chest_"..i].node:getPosition()
			self.effect_data[i]:setPosition(pos_x+50, pos_y+20)
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(29)
			self.effect_data[i]:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
			self.effect_data[i]:setVisible(true)
		end
	end
end

function MaFaExploreView:GetDices()
	ActivityCtrl.Instance:ReqGetDices()
end

function MaFaExploreView:OpenTipContent()
	DescTip.Instance:SetContent(Language.AllDayActivity.DescContent, Language.AllDayActivity.DescTitle)
end

function MaFaExploreView:SetRankingList()
	local list, my_ranking =  ActivityData.Instance:GetViewRankingListView()
	self.ranking_view_list:SetDataList(list)
	local txt = ""
	if my_ranking == 0 then
		txt = Language.Guild.WeiShangBang
	else
		txt = my_ranking
	end
	self.node_t_list.layout_ranking.txt_my_ranking.node:setString(txt)
end

function MaFaExploreView:BoolShowBossPanel()
	local pos = ActivityData.Instance:GetCurPos()
	if pos == 0 then return end
	local ph = self.ph_list["ph_cell_"..pos]
	if ph ~= nil then
		local container = self.node_t_list.layout_pos.node
		self.node_t_list.layout_pos.img_effect_1.node:setPosition(cc.p(ph.x + 40 , ph.y + 40))
	end
	local circle = ActivityData.Instance:GetMyCircle()
	-- if circle <= MAX_CIRCLE_NUM then
	local reward_state, reward_pos = ActivityData.Instance:BoolGetReward() 
	local cell = self.reward_cell[pos]
	local data = cell:GetData()
	if reward_state == 2 then
		ActivityCtrl.Instance:OpenEventPanel(data)
	elseif reward_state == 1 then
		if data.eventType == MulphaAdventureEvent.fight or data.eventType == MulphaAdventureEvent.canNotPassFight then
			ActivityCtrl.Instance:OpenReWardPanel(data.awardDesc, reward_pos, data)
		else
			ActivityCtrl.Instance:OpenReWardPanel(data.desc, reward_pos, data)
		end
	elseif reward_state == 0 then
		local circle = ActivityData.Instance:GetMyCircle()
		if circle < MAX_CIRCLE_NUM then
			if ActivityData.Instance:GetCanShowPanel() == 1 and 
				(data.eventType == MulphaAdventureEvent.startPoint or 
				data.eventType == MulphaAdventureEvent.rest) then
				ActivityCtrl.Instance:OpenReWardPanel(data.desc, reward_pos, data)
			end
		end
	end
end

function MaFaExploreView:SetShowPlayEff()
	self.effect_data = {}
	for i = 1, 5 do
		local play_eff = AnimateSprite:create()
		self.root_node:addChild(play_eff, 999)
		self.effect_data[i] = play_eff
	end
end

MaFaRender = MaFaRender or BaseClass(BaseRender)
function MaFaRender:__init()
	
end

function MaFaRender:__delete()
	if self.reward_cell then
		self.reward_cell:DeleteMe()
		self.reward_cell = nil 
	end
end

function MaFaRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.reward_cell == nil then
		local ph = self.ph_list.ph_cell
		self.reward_cell = BaseCell.New()
		self.reward_cell:SetPosition(ph.x, ph.y)
		self.reward_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.reward_cell:GetView())
	end
end

function MaFaRender:OnFlush()

	if self.data == nil then return end
	if self.data.awards ~= nil then
		local id = self.data.awards[1].id
		local count = self.data.awards[1].count
		local bind = self.data.awards[1].bind
		self.reward_cell:SetData({item_id = id, num = count, is_bind = bind})
		if self.data.reward_state == 1 then
			self.reward_cell:MakeGray(true)
			self.node_tree.img_bg_path.node:setVisible(true)
			self.node_tree.img_bg_path.node:loadTexture(ResPath.GetCommon("stamp_27"))
		else
			self.node_tree.img_bg_path.node:setVisible(false)
		end
	else
		self.node_tree.img_bg_path.node:setVisible(true)
		self.node_tree.img_bg_path.node:loadTexture(ResPath.GetActivityPic("mafa_fa_icon_"..self.data.icon))
	end
end

MaFaRankingRender = MaFaRankingRender or BaseClass(BaseRender)
function MaFaRankingRender:__init()
	--self.cache_select = true
end

function MaFaRankingRender:__delete()

end

function MaFaRankingRender:CreateChild()
	BaseRender.CreateChild(self)
end

function MaFaRankingRender:OnFlush()
	if self.data == nil then return end
	if self.index == 1 then
		self.node_tree.txt_ranking_mafa.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("ffff00"))
		self.node_tree.txt_bu_shu.node:setColor(Str2C3b("ffff00"))
	elseif self.index == 2 then
		self.node_tree.txt_ranking_mafa.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_name.node:setColor(Str2C3b("de00ff"))
		self.node_tree.txt_bu_shu.node:setColor(Str2C3b("de00ff"))
	elseif self.index == 3 then
		self.node_tree.txt_ranking_mafa.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_name.node:setColor(Str2C3b("00ff00"))
		self.node_tree.txt_bu_shu.node:setColor(Str2C3b("00ff00"))
	end
	self.node_tree.txt_ranking_mafa.node:setString(string.format(Language.AllDayActivity.Ranking,self.data.rank))
	self.node_tree.txt_name.node:setString(self.data.role_name)
	self.node_tree.txt_bu_shu.node:setString(string.format(Language.AllDayActivity.Step,self.data.step))
end