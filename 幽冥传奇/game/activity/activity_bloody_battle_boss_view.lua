BattleBossView = BattleBossView or BaseClass(XuiBaseView)

function BattleBossView:__init()
	self.texture_path_list[1] = 'res/xui/boss.png'
	self.texture_path_list[1] = 'res/xui/activity.png'
	self.title_img_path = ResPath.GetActivityPic("activity_fight")
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"welkin_ui_cfg", 5, {0}},
		{"common_ui_cfg", 2, {0}},
	}
	
end

function BattleBossView:__delete()

end

function BattleBossView:ReleaseCallBack()
	if self.boss_battle_list then
		self.boss_battle_list:DeleteMe()
		self.boss_battle_list = nil 
	end
	-- if self.my_ranking_data then
	-- 	GlobalEventSystem:UnBind(self.my_ranking_data)
	-- 	self.my_ranking_data = nil
	-- end

	-- if self.my_level then
	-- 	GlobalEventSystem:UnBind(self.my_level)
	-- 	self.my_level = nil
	-- end
end

function BattleBossView:LoadCallBack(index, loaded_times)	
	if loaded_times <= 1 then
		--self.title_img_path = ResPath.GetBoss("boss_battle")
		self:CreateBossBattleListView()
		self.node_t_list.btn_inspire.node:addClickEventListener(BindTool.Bind(self.Inspire, self))
		self.node_t_list.btn_refresh.node:addClickEventListener(BindTool.Bind(self.RefreshBoss, self))
		self.node_t_list.btn_ranking.node:addClickEventListener(BindTool.Bind(self.OpenRankingPanel, self))
		self.node_t_list.btn_question_activity.node:addClickEventListener(BindTool.Bind(self.OpenTips, self))
		-- self.my_ranking_data = GlobalEventSystem:Bind(AllDayActivityEvent.BLOODLD_BATTLE_BOOS,BindTool.Bind(self.SetMybattleBossData, self))
		-- self.my_level = GlobalEventSystem:Bind(AllDayActivityEvent.BLOODLD_LEVEL,BindTool.Bind(self.ShowMyLevel, self))
		local type_name = Language.Equipment.Money_type[BloodFightCfg.freshRoomFee.type]
		local txt = string.format(Language.AllDayActivity.ConsumeMoney, type_name, BloodFightCfg.freshRoomFee.count)
		self.node_t_list.txt_consuem.node:setString(txt)
	end
end

function BattleBossView:OpenTips()
	DescTip.Instance:SetContent(Language.AllDayActivity.BossBattleContent, Language.AllDayActivity.BossBattleTitle)
end

function BattleBossView:Inspire()
	local oprate_type, oprate_time = ActivityData.Instance:GetOprateResult()
	ActivityCtrl.Instance:OprateBattleBossFuben(1, oprate_time +1)
end

function BattleBossView:RefreshBoss()
	ActivityCtrl.Instance:OprateBattleBossFuben(2, 0)
end

function BattleBossView:CreateBossBattleListView()
	if self.boss_battle_list == nil then
		local ph = self.ph_list.ph_list
		self.boss_battle_list = ListView.New()
		self.boss_battle_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, BossBattleRender, nil, nil, self.ph_list.ph_list_item)
		self.boss_battle_list:GetView():setAnchorPoint(0, 0)
		self.boss_battle_list:SetItemsInterval(8)
		self.boss_battle_list:SetJumpDirection(ListView.Top)
		--self.boss_battle_list:SetMargin(3)
		self.node_t_list.layout_battle_boss_activity.node:addChild(self.boss_battle_list:GetView(), 100)
		--self.boss_battle_list:GetView():setEnabled(false)
	end
end

function BattleBossView:OpenCallBack()
	ActivityCtrl.Instance:OprateBattleBossFuben(3, 0)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BattleBossView:ShowIndexCallBack(index)
	self:Flush(index)
end

function BattleBossView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

--刷新界面
function BattleBossView:OnFlush(param_t, index)
	local data = ActivityData.Instance:GetBossBattleInfo()
	self.boss_battle_list:SetDataList(data)
	local oprate_type, oprate_time = ActivityData.Instance:GetOprateResult()
	local consume = ActivityData.Instance:GetConsume(oprate_time+1)
	local txt = ""
	if consume == nil then
		txt = ""
		self.node_t_list.star_img.node:setVisible(false)
	else
		self.node_t_list.star_img.node:setVisible(true)
		txt = string.format(Language.AllDayActivity.Insprite_Consume, consume)
	end
	self.node_t_list.txt_inspride.node:setString(string.format(Language.AllDayActivity.Insprite_time, oprate_time))
	self.node_t_list.txt_had_property.node:setString(txt)
	local data = ActivityData.Instance:GetProtery()
	for k, v in pairs(data) do
		local name = v.name
		local str = (oprate_time * v.value *100) .."%"
		if self.node_t_list["txt_shuxing_"..k] ~= nil then
			self.node_t_list["txt_shuxing_"..k].node:setString(name.."+"..str)
		end
	end
	local my_rank, my_star = MagicCityData.Instance:GetMyRankingData()
	self.node_t_list.txt_had_star.node:setString(my_star)
	self.node_t_list.txt_my_ranking.node:setString(my_rank)
	local my_guanka_level, max_guanka_level = BossData.Instance:GetMYGuanKaLevel()
	self.node_t_list.txt_level.node:setString(string.format(Language.AllDayActivity.Pass_through, (max_guanka_level - my_guanka_level), max_guanka_level))
	local failed_remain_num, failed_max_num =  BossData.Instance:GetMyFailedNum()
	self.node_t_list.txt_faied_num.node:setString((failed_max_num - failed_remain_num).."/"..failed_max_num)
	local level = RoleData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
	local circle = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE)
	local cur_level = circle*255 +level 
	local color = COLOR3B.RED
	if cur_level >= BloodFightCfg.enterLevelLimit[2] and circle >= BloodFightCfg.enterLevelLimit[1] then
		color = COLOR3B.GREEN
	end
	self.node_t_list.txt_consume_level.node:setString(string.format(Language.AllDayActivity.BattleBossLevel,BloodFightCfg.enterLevelLimit[1],BloodFightCfg.enterLevelLimit[2]))
	self.node_t_list.txt_consume_level.node:setColor(color)
end

function BattleBossView:SetMybattleBossData()
		
end

function BattleBossView:OpenRankingPanel()
	MagicCityCtrl.Instance:ReqRankinglistData(MagicCityRankingListData_TYPE.JIZhanBossRanking) -- 活动答题共用排行榜， 不区分类型
end

BossBattleRender = BossBattleRender or BaseClass(BaseRender)

function BossBattleRender:__init()
end

function BossBattleRender:__delete()
	if nil ~= self.monster_display then
		self.monster_display:DeleteMe()
		self.monster_display = nil
	end
end

function BossBattleRender:CreateChild()
	BaseRender.CreateChild(self)
	if self.monster_display == nil then
		ph = self.ph_list.img_bg
		self.monster_display = ModelAnimate.New(ResPath.GetMonsterAnimPath, self.view, GameMath.MDirDown)
		self.monster_display:SetAnimPosition(ph.x+40,ph.y-45)
		self.monster_display:SetFrameInterval(FrameTime.RoleStand)
		self.monster_display:SetZOrder(30)
	end
	self.node_tree.img_bottom.node:setOpacity(128)
	self.node_tree.btn_tiaozhan.node:addClickEventListener(BindTool.Bind(self.EnterBossRoom, self))
end

function BossBattleRender:OnFlush()
	if self.data == nil then return end
	local cfg = BossData.GetMosterCfg(self.data.boss_id)
	if cfg ~= nil then
		local name = DelNumByString(cfg.name)
		self.node_tree.txt_name.node:setString(name)
		local color = ACTIVITY_BOSS_COLOR[self.data.boss_index]
		--print("3333333333", color, boss_index)
		self.node_tree.txt_name.node:setColor(Str2C3b(color or "00ff2a"))
		self.monster_display:Show(cfg.modelid)
		self.monster_display:SetScale(0.6)
	end
	self.node_tree.txt_star.node:setString(self.data.star)
end

function BossBattleRender:EnterBossRoom()
	ActivityCtrl.Instance:ReqEnterBattleBossFuben(self.index)
end

