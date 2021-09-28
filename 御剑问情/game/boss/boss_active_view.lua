BossActiveView = BossActiveView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2
local SHOW_FLOOR = 4  --显示层数

function BossActiveView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_boss_id, self.select_scene_id = BossData.Instance:GetInitActiveBossID()
	self.boss_data = {}
	self.cell_list = {}
	self.rew_list = {}
	self.togglecell_list = {}

	self.reward_data = BossData.Instance:GetActiveBossRewards(self.select_boss_id)

	self.scene_num = 0
	self.now_index = 0
	self.floor_list = {}

	self.layer = 0

	self.num = 0
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")

	self.boss_name = self:FindVariable("BossName")
	self.enter_btn_name = self:FindVariable("EnterBtnName")
	self.enter_btn_gray = self:FindVariable("EnterBtnGray")
	self.cur_angry = self:FindVariable("cur_angry")
	self.total_angry = self:FindVariable("total_angry")
	self.single_angry = self:FindVariable("single_angry")

	self.remain_count_text_list = {}
	for i=1,3 do
		self.remain_count_text_list[i] = self:FindVariable("RemainCountText" .. i)
	end

	--BOSSITEM展示
	self.boss_list = self:FindObj("BossList")
	self.list_view_delegate = self.boss_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	--奖励展示
	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.ReRewardfreshView, self)

	--toggle list
	self.toggle_list = self:FindObj("togglelist")
	self.toggle_list_delegate = self.toggle_list.list_simple_delegate
	self.toggle_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetToggleListNumOfCells, self)
	self.toggle_list_delegate.CellRefreshDel = BindTool.Bind(self.ToggleRefreshView, self)

	self:ListenEvent("ToActtack",
		BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick",
		BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",
		BindTool.Bind(self.OpenKillRecord, self))
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
end

function BossActiveView:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
	end
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	for _,v in pairs(self.rew_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.rew_list = {}

	for _,v in pairs(self.togglecell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.togglecell_list = {}
	self.single_angry = nil
	self.nowpanelboss_num = nil
end

function BossActiveView:ClickScene(layer)
	if self.layer == layer then
		return
	end

	self.num = 0
	for k,v in pairs(BossData.Instance:GetActiveBossLayerList()) do 					--BossData.Instance:GetActiveSceneList()
		if layer == k then
			local is_can = false
			for k1,v1 in pairs(v) do
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v1.scene_id)
				if not can_go then
					local level_text = PlayerData.GetLevelString(min_level)
					local text = string.format(Language.Boss.BossLimit, level_text)
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end

				is_can = true
				break
			end

			if is_can then
				break
			end
		end
	end
	self.layer = layer
	self:FlushBoss()
	self:FlushToggleHL()
end

function BossActiveView:FlushToggleHL()
	for k, v in pairs(self.togglecell_list) do
		v:SetToggleState(self.layer)
	end
end

function BossActiveView:FlushBossRemainCount()
	for i=1,3 do
		self.remain_count_text_list[i]:SetValue("2")
	end
end

function BossActiveView:CloseBossView()
	self.select_index = 1
	BossData.Instance:SetBossLayer(-1)
end

function BossActiveView:GetNumberOfCells()
	return #BossData.Instance:GetSingleLayerActiveBossList(self.layer) or 0
end

function BossActiveView:GetRewardNumberOfCells()
	return GetListNum(self.reward_data)
end

function BossActiveView:GetToggleListNumOfCells()
	local list = BossData.Instance:GetBossFloorList(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, SHOW_FLOOR)
	return #list
end

function BossActiveView:ToggleRefreshView(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.togglecell_list[cell]
	if not toggle_cell then
		toggle_cell = ActiveBossToggle.New(cell.gameObject)
		self.togglecell_list[cell] = toggle_cell
		toggle_cell.boss_view = self
	end
	toggle_cell:SetIndex(data_index, self.floor_list)
	toggle_cell:Flush()
	toggle_cell:SetToggleState(self.layer)
end

function BossActiveView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = ActiveBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.reward_data[data_index])
	reward_cell:SetBossID(self.select_boss_id)
	reward_cell:Flush()
end

function BossActiveView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = ActiveBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function BossActiveView:InitFloorList()
	self.scene_num = #BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE]
	self.now_index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)
	self.floor_list = BossData.Instance:GetBossFloorList(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, SHOW_FLOOR)
end


function BossActiveView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	local boss_data = BossData.Instance
	if boss_data:CanGoActiveBoss() then
		boss_data:SetCurInfo(self.select_scene_id, self.select_boss_id)
		ViewManager.Instance:CloseAll()
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_scene_id, 1, self.select_boss_id)
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BossActiveLimit)
	end
end

function BossActiveView:QuestionClick()
	local tips_id = 160
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossActiveView:FlushModel()
	if self.model_view == nil then
		return
	end
	-- if self.model_display.gameObject.activeInHierarchy then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			local display_name = BossData.Instance:DisplayName(monster_cfg.resid)
			self.model_view:SetPanelName(display_name)
			self.model_view:SetMainAsset(ResPath.GetMonsterModel(monster_cfg.resid))
			self.model_view:SetTrigger("rest1")
		end
	-- end
end

function BossActiveView:OpenKillRecord()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.drop)
end

function BossActiveView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			self.boss_name:SetValue(monster_cfg.name)
		end
		self.enter_btn_gray:SetValue(BossData.Instance:CanGoActiveBoss())
		self:FlushModel()
	end

	local data = BossData.Instance:GetActiveBossCfg()
	if nil == data then
		return
	end

	self.single_angry:SetValue(data[1].add_weary)
end

function BossActiveView:FlushBossList()
	self.num = 0
	-- local boss_list = BossData.Instance:GetActiveBossList(self.select_scene_id)
	local boss_list = BossData.Instance:GetSingleLayerActiveBossList(self.layer)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			local reflash_time = BossData.Instance:GetActiveStatusByBossId(boss_list[i].bossID, boss_list[1].scene_id)
			if reflash_time == 0 then
				self.num = self.num + 1
			end
		end
		self.select_boss_id = boss_list[1].bossID
		self.select_scene_id = boss_list[1].scene_id
	end
	self.nowpanelboss_num:SetValue(self.num.." / "..#boss_list)
	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossActiveView:FlushReward()
	self.reward_data = BossData.Instance:GetActiveBossRewards(self.select_boss_id)
	self.reward_list.scroller:ReloadData(0)
end

function BossActiveView:FlushBossView()
	self.select_index = 1
	self:InitFloorList()
	local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE)
	local layer = BossData.Instance:GetBossLayer()
	if -1 ~= layer then
		index = layer
		BossData.Instance:SetBossLayer(-1)
	end

	self:ClickScene(index)
	self.toggle_list.scroller:ReloadData(self.layer / #self.floor_list)
	self.reward_data = BossData.Instance:GetActiveBossRewards(self.select_boss_id)
	self:FlushBoss()
end

function BossActiveView:FlushBoss()
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushReward()
	self:FlushBossRemainCount()
	self:FlushToggleHL()
	self:FlushAllHL()
	self:FlushModel()
	local boss_data = BossData.Instance
	self.cur_angry:SetValue(boss_data:GetActiveBossInfo())
	self.total_angry:SetValue(boss_data:GetActiveMaxValue())
end

function BossActiveView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossActiveView:GetSelectIndex()
	return self.select_index or 1
end

function BossActiveView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function BossActiveView:SetSelectScenceId(scene_id)
	self.select_scene_id = scene_id
end

function BossActiveView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

----------------------------------------------------------------------
--奖励展示
ActiveBossRewardCell = ActiveBossRewardCell or BaseClass(BaseCell)

function ActiveBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
	self.boss_id = 0
end

function ActiveBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function ActiveBossRewardCell:OnFlush()
	if nil == self.data then
		return
	end
	local item_id = self.data
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	self.rew_cell:SetData({item_id = item_id})
end

function ActiveBossRewardCell:SetBossID(index)
	self.boss_id = index
end

----------------------------------------------------------------------
--BOSSITEM展示
ActiveBossItemCell = ActiveBossItemCell or BaseClass(BaseCell)

function ActiveBossItemCell:__init()
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
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function ActiveBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function ActiveBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:SetSelectScenceId(self.data.scene_id)
		self.boss_view:FlushReward()
		self.boss_view:FlushAllHL()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function ActiveBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.boss_name:SetValue(monster_cfg.name)
		self.canKill:SetValue(true)
		local bundele2,asset1 = ResPath.GetBossItemIcon(monster_cfg.headid)
		self.icon_image:SetAsset(bundele2, asset1)
		if BOSS_TYPE_INFO.RARE == monster_cfg.boss_type then
			self.show_labelrare:SetValue(true)
			local bundle, asset = ResPath.GetBoss("bg_rare_01")
			self.icon:SetAsset(bundle, asset)
		else
			self.show_labelrare:SetValue(false)
			local bundle, asset = ResPath.GetBoss("bg_rare_02")
			self.icon:SetAsset(bundle, asset)
		end
	end
	local reflash_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
	if reflash_time > 0 then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime())
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

	self:FlushHL()
end

function ActiveBossItemCell:OnBossUpdate()
	local reflash_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
	local time = math.max(0, reflash_time - TimeCtrl.Instance:GetServerTime())
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

function ActiveBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

function ActiveBossItemCell:FlushLimit()

end


---------------------------------------------------------
--toggle展示
ActiveBossToggle = ActiveBossToggle or BaseClass(BaseCell)

function ActiveBossToggle:__init()
	self.floor_index = 0
	self.list_toggle = {}
	self.toggle_index = 0
	self.text = self:FindVariable("Floor_Text")
	self.show_hl = self:FindVariable("Show_Hl")
	self:ListenEvent("ClickToggle", BindTool.Bind(self.ClickToggle, self))
end

function ActiveBossToggle:__delete()

end

function ActiveBossToggle:ClickToggle()
	self.boss_view:SetSelectIndex(1)
	self.boss_view:ClickScene(self.toggle_index)
end

function ActiveBossToggle:SetIndex(index, list)
	self.index = index
	self.list_toggle = list
end

function ActiveBossToggle:OnFlush()
	self:SwitchScene()
end

function ActiveBossToggle:SetToggleState(index)
	self.show_hl:SetValue(self.toggle_index == index)
end

function ActiveBossToggle:SwitchScene()
	self.text:SetValue(string.format(Language.Boss.Floor, self.list_toggle[self.index]))
	self.toggle_index = self.list_toggle[self.index]
end

