BabyBossView = BabyBossView or BaseClass(BaseRender)

function BabyBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 8201
	self.select_boss_id = 0
	self.layer = 0
	self.boss_cell_list = {}
	self.rew_list = {}
	self.toggle_cell_list = {}

	self.scene_num = 0
	self.now_index = 0
	self.floor_list = {}

	self.remain_boss_num = self:FindVariable("RemainingNum")
	self.enter_cost = self:FindVariable("Cost")
	self.is_bind_gold = self:FindVariable("IsBindGold")
	self.can_enter = self:FindVariable("CanEnter")
	self.enter_times_tip = self:FindVariable("EnterTimes")

	-- BOSS_ITEM展示
	self.boss_list = self:FindObj("BossList")
	self.list_view_delegate = self.boss_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfBossCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.BossRefreshView, self)

	-- 奖励展示
	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfRewardCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.RewardRefreshView, self)

	-- toggle list
	self.toggle_list = self:FindObj("togglelist")
	self.toggle_list_delegate = self.toggle_list.list_simple_delegate
	self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfToggleCells, self)
	self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)
	-- self.toggle_list.scroll_rect.horizontal = false

	-- 模型
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)

	self:ListenEvent("ToActtack",
		BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick",
		BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",
		BindTool.Bind(self.OnClickOpenKillRecord, self))
end

function BabyBossView:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
	end

	for _,v in pairs(self.boss_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.boss_cell_list = {}

	for _,v in pairs(self.rew_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.rew_list = {}

	for _,v in pairs(self.toggle_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.toggle_cell_list = {}

	self.toggle_list = {}
	self.boss_list = {}
	self.reward_list = {}

	self.remain_boss_num = nil
	self.enter_cost = nil
	self.is_bind_gold = nil
	self.can_enter = nil
	self.enter_times_tip = nil
end

function BabyBossView:CloseBossView()
	self.select_index = 1
end

function BabyBossView:GetNumberOfBossCells()
	local baby_boss_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	return #baby_boss_list or 0
end

function BabyBossView:GetNumberOfRewardCells()
	local reward_list = BossData.Instance:GetBabyBossFallList(self.select_boss_id)
	return #reward_list + 1
end

function BabyBossView:GetNumberOfToggleCells()
	local layer_list = BossData.Instance:GetBabyBossFloorList()
	return #layer_list or 0
end

function BabyBossView:ToggleRefreshView(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.toggle_cell_list[cell]
	if not toggle_cell then
		toggle_cell = BabyBossToggle.New(cell.gameObject)
		self.toggle_cell_list[cell] = toggle_cell
		toggle_cell:SetClickCallBack(BindTool.Bind(self.OnClickToggleCell, self))
	end
	toggle_cell:SetIndex(data_index)
	local data = BossData.Instance:GetBabyBossFloorList()
	toggle_cell:SetData(data[data_index])
end

function BabyBossView:RewardRefreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = BabyBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	local data = BossData.Instance:GetBabyBossFallList(self.select_boss_id)
	reward_cell:SetData(data[data_index - 1])
end

function BabyBossView:BossRefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = BabyBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		self.boss_cell_list[cell] = boss_cell
		boss_cell:SetClickCallBack(BindTool.Bind(self.OnClickBossCell, self))
	end
	boss_cell:SetIndex(data_index)
	local data = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	boss_cell:SetData(data[data_index])
	boss_cell:SetOpenBossItemState(self.select_boss_id)
end

function BabyBossView:OnClickToggleCell(cell)
	self:ClickLayer(cell:GetOnClickToggleLayer())
end

function BabyBossView:OnClickBossCell(cell)
	local index = cell:GetIndex()
	local boss_id = cell:GetSelectedBossId()
	if index == self.select_index then
		return
	end

	self.select_index = index
	self:SetSelectBossId(boss_id)
	self:FlushReward()
	self:FlushBossCellHL(index)
	self:FlushInfoList()
end

function BabyBossView:FlushBossCellHL(index)
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL(index)
	end
end

function BabyBossView:FlushToggleHL(layer)
	for k, v in pairs(self.toggle_cell_list) do
		v:SetToggleState(layer)
	end
end

function BabyBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function BabyBossView:FlushBossView()
	self.select_index = 1

	self.toggle_list.scroller:ReloadData(0)
	local layer = BossData.Instance:GetBabyBossCanGoLevel()
	self:ClickLayer(layer)
end

function BabyBossView:ToActtack()
	local gold_cost, is_bind = BossData.Instance:GetBabyBossEnterCost()

	local enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	local enter_times = BossData.Instance:GetBabyBossEnterTimes()
	local enter_times_max_vip = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES, VipData.Instance:GetVipMaxLevel())
	-- 进入次数已达上限
	if enter_times >= enter_limit or gold_cost == -1 then
		if enter_limit < enter_times_max_vip then
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BABYBOSS_ENTER_TIMES)
		else
			TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BabyBossEnterTimesLimit)
		end
		return
	end

	local vo = GameVoManager.Instance:GetMainRoleVo()

	-- 元宝不足
	if is_bind then
		if vo.bind_gold < gold_cost and vo.gold < gold_cost then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
	else
		if vo.gold < gold_cost then
			TipsCtrl.Instance:ShowLackDiamondView()
			return
		end
	end

	local des = string.format(Language.Boss.EnterBabyBossTips2, gold_cost, self.layer)
	if is_bind then
		des = string.format(Language.Boss.EnterBabyBossTips1, gold_cost, self.layer)
	end
	local ok_callback = function ()
		local layer_scene = BossData.Instance:GetBabyBossListClient()
		if nil == layer_scene or nil == layer_scene[self.layer] then
			return
		end
		scene_id = layer_scene[self.layer].scene_id or 0
		BossCtrl.Instance:SendBabyBossRequest(BABY_BOSS_OPERATE_TYPE.BABY_BOSS_SCENE_ENTER_REQ, scene_id, self.select_boss_id)
	end
	if gold_cost > 0 then
		TipsCtrl.Instance:ShowCommonAutoView("EnterBabyBoss", des, ok_callback, nil, nil, nil, nil, nil, nil, false)
	else
		ok_callback()
	end

end

function BabyBossView:QuestionClick()
	local tips_id = 263
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BabyBossView:FlushModel()
	if self.model_view == nil then
		return
	end

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
	if monster_cfg then
		local display_name = BossData.Instance:DisplayName(monster_cfg.resid)
		self.model_view:SetPanelName(display_name)
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(monster_cfg.resid))
		self.model_view:SetTrigger("rest1")
	end
end

function BabyBossView:OnClickOpenKillRecord()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.drop)
end

function BabyBossView:FlushInfoList()
	local cost, is_bind = BossData.Instance:GetBabyBossEnterCost()
	local vip_enter_limit = VipData.Instance:GetBabyBossEnterTimes(VIPPOWER.BABYBOSS_ENTER_TIMES)
	local cfg_enter_limit = BossData.Instance:GetBabyBossEnterLimitTimes()
	local enter_limit = math.min(vip_enter_limit, cfg_enter_limit)
	local enter_times = BossData.Instance:GetBabyBossEnterTimes()
	-- 返回-1表示已达今日可进入次数上限
	if cost == -1 or enter_times > enter_limit then
		self.can_enter:SetValue(false)
	else
		self.can_enter:SetValue(true)
		self.enter_cost:SetValue(cost)
		self.is_bind_gold:SetValue(is_bind)
	end

	self.enter_times_tip:SetValue(enter_times .. " / " .. enter_limit)

	self:FlushModel()
end

function BabyBossView:FlushBossList()
	local boss_list = BossData.Instance:GetBabyBossDataListByLayer(self.layer)
	local alive_boss_num = BossData.Instance:GetBabyBossAliveNumByLayer(self.layer)
	self.remain_boss_num:SetValue(alive_boss_num.." / "..#boss_list)

	if boss_list[1] then
		self.select_boss_id = boss_list[1].boss_id or 0
	end

	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BabyBossView:FlushReward()
	self.reward_list.scroller:ReloadData(0)
end

function BabyBossView:FlushBoss()
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushReward()
	self:FlushModel()
end

function BabyBossView:ClickLayer(layer, index)

	if self.layer == layer then
		return
	end

	local layer_list = BossData.Instance:GetBabyBossListClient() or {}
	for k,v in pairs(layer_list) do
		if layer == k then
			local can_go, min_level = BossData.Instance:GetBabyBossCanToSceneLevel(v.scene_id)
			if not can_go then
				local level_text = PlayerData.GetLevelString(min_level)
				local text = string.format(Language.Boss.BossLimit, level_text)
				TipsCtrl.Instance:ShowSystemMsg(text)
				return
			end
			self.select_scene_id = v.scene_id
			local cango_list = BossData.Instance:GetBabyBossDataListByLayer(layer)
			self.select_boss_id = cango_list[1] and cango_list[1].boss_id or 10
		end
	end
	self.layer = layer
	self.select_index = 1

	self:FlushBoss()
	self:FlushToggleHL(self.layer)
end

----------------------------------------------------------------------
-- 奖励展示
BabyBossRewardCell = BabyBossRewardCell or BaseClass(BaseCell)

function BabyBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
	self.boss_id = 0
end

function BabyBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function BabyBossRewardCell:SetData(data)
	if data == nil then
		self.rew_cell:SetActive(false)
		return
	end
	self.rew_cell:SetData(data)
end

function BabyBossRewardCell:SetBossID(index)
	self.boss_id = index
end

----------------------------------------------------------------------
-- BOSSITEM展示
BabyBossItemCell = BabyBossItemCell or BaseClass(BaseCell)

function BabyBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.canKill = self:FindVariable("canKill")
	self.show_hl = self:FindVariable("show_hl")
	self.show_limit = self:FindVariable("show_limit")
	self.show_labelrare = self:FindVariable("show_label_rare")
	self.icon_image = self:FindVariable("icon_image")
	self:ListenEvent("ClickItem", BindTool.Bind(self.OnClick, self))
end

function BabyBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BabyBossItemCell:GetSelectedBossId()
	return self.data.boss_id
end

function BabyBossItemCell:FlushHL(index)
	self.show_hl:SetValue(index == self.index)
end

function BabyBossItemCell:SetOpenBossItemState(boss_id)
	self.show_hl:SetValue(boss_id == self.data.boss_id)
end

function BabyBossItemCell:SetData(data)
	self.data = data
	if nil == data or nil == data.boss_info then
		return
	end

	local boss_info = data.boss_info
	self.level:SetValue(string.format(Language.Boss.BossLevelText, boss_info.level))
	self.boss_name:SetValue(boss_info.name)
	self.canKill:SetValue(true)
	local bundle, asset = ResPath.GetBossItemIcon(boss_info.headid)
	self.icon_image:SetAsset(bundle, asset)
	if BOSS_TYPE_INFO.RARE == boss_info.boss_type then
		self.show_labelrare:SetValue(true)
		local bundle1, asset1 = ResPath.GetBoss("bg_rare_01")
		self.icon:SetAsset(bundle1, asset1)
	else
		self.show_labelrare:SetValue(false)
		local bundle1, asset1 = ResPath.GetBoss("bg_rare_02")
		self.icon:SetAsset(bundle1, asset1)
	end

	-- 击杀/刷新显示
	local refresh = data.next_refresh_time
	if refresh > 0 then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, refresh - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self.iskill:SetValue(true)
		self:OnBossUpdate()
		self.image_gray_scale:SetValue(false)
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(Language.Boss.HadFlush)
	end
end

function BabyBossItemCell:OnBossUpdate()
	if nil == self.data then
		return
	end

	local refresh = self.data.next_refresh_time
	local time = math.max(0, refresh - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(Language.Boss.HadFlush)
	else
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time,3), TEXT_COLOR.RED_1))
	end
end

---------------------------------------------------------
-- toggle展示
BabyBossToggle = BabyBossToggle or BaseClass(BaseCell)

function BabyBossToggle:__init()
	self.text = self:FindVariable("Floor_Text")
	self.show_hl = self:FindVariable("Show_Hl")
	self.layer = 1
	self:ListenEvent("ClickToggle", BindTool.Bind(self.OnClick, self))
end

function BabyBossToggle:__delete()

end

function BabyBossToggle:SetIndex(index)
	self.index = index
end

function BabyBossToggle:SetToggleState(layer)
	self.show_hl:SetValue(self.layer == layer)
end

function BabyBossToggle:SetData(data)
	if nil == data then return end
	self.text:SetValue(string.format(Language.Boss.Floor, data))
	self.layer = data
end

function BabyBossToggle:GetOnClickToggleLayer()
	return self.layer
end