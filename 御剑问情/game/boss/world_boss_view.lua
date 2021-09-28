WorldBossView = WorldBossView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2

function WorldBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_boss_id = 10
	self.scroll_change = false 			--记录画布是否在滚动中

	self.boss_data = {}
	self.cell_list = {}
	self.rew_list = {}
	self.num = 0
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")

	self.list_view = self:FindObj("BossList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.reward_data = {}
	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.ReRewardfreshView, self)

	self:ListenEvent("QuestionClick",
		BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",
		BindTool.Bind(self.OpenKillRecord, self))
	self:ListenEvent("ToActtack",
		BindTool.Bind(self.ToActtack, self))

	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
	self.is_first_open = true
end

function WorldBossView:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
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

	self.model_display = nil
	self.nowpanelboss_num = nil
end

function WorldBossView:GetNumberOfCells()
	return #self.boss_data or 0
end

function WorldBossView:GetRewardNumberOfCells()
	return #self.reward_data
end

function WorldBossView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = WorldBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.reward_data[data_index])
end


function WorldBossView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = WorldBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.list_view.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetTheIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function WorldBossView:CloseBossView()
	self.select_index = 1
end

function WorldBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	local my_level = GameVoManager.Instance:GetMainRoleVo().level
	local min_level = BossData.Instance:GetBossCfgById(self.select_boss_id).min_lv
	if my_level >= min_level then
		if self.select_boss_id == 0 then
			SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
			return
		end
		ViewManager.Instance:CloseAll()
		local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
		if ActivityCtrl.Instance:CanNotFly() then
			GuajiCtrl:FlyToScene(boss_data.scene_id)
		end
	else
		local limit_text = PlayerData.GetLevelString(min_level)
		limit_text = string.format(Language.Common.CanNotEnter, limit_text)
		TipsCtrl.Instance:ShowSystemMsg(limit_text)
	end
end

function WorldBossView:QuestionClick()
	local tips_id = 140 -- 世界boss
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function WorldBossView:OpenKillRecord()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.drop)
end

function WorldBossView:FlushModel()
	if self.model_view == nil then
		return
	end
	-- if self.model_display.gameObject.activeInHierarchy then
		local boss_data = BossData.Instance:GetWorldBossInfoById(self.select_boss_id)
		local display_name = BossData.Instance:DisplayName(boss_data.resid)
		self.model_view:SetPanelName(display_name)
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(boss_data.resid))
		self.model_view:SetTrigger("rest1")
	-- end
end

function WorldBossView:FlushInfoList()
	self:FlushModel()
end

function WorldBossView:FlushBossList()
	self.num = 0
	local boss_list = BossData.Instance:GetShowWorldBossList()
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			local state = BossData.Instance:GetBossStatusByBossId(boss_list[i].bossID)
			if state ~= 0 then
				self.num = self.num + 1
			end
		end
		self.nowpanelboss_num:SetValue(self.num.." / "..#boss_list)
	end
	if self.select_index == 1 then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function WorldBossView:FlushReward()
	self.reward_data = BossData.Instance:GetWorldBossRewardList(self.select_boss_id) or {}
	self.reward_list.scroller:ReloadData(0)
end

function WorldBossView:ChangeOpenState(is_on)
	self.is_first_open = is_on
end

function WorldBossView:FlushBossView()
	self.select_index = 1
	self.select_boss_id = BossData.Instance:GetShowWorldBossList()[1].bossID
	self:FlushBossList()
	if self.is_first_open then
		self:FlushInfoList()
		self.is_first_open = false
	end
	self:FlushReward()
end

function WorldBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function WorldBossView:GetSelectIndex()
	return self.select_index or 1
end

function WorldBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function WorldBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end
------------------------------------------------------------------
WorldBossItemCell = WorldBossItemCell or BaseClass(BaseCell)

function WorldBossItemCell:__init()
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.iskill = self:FindVariable("IsKill")
	self.show_lock = self:FindVariable("show_lock")
	self.image = self:FindObj("image")
	self.boss_name = self:FindVariable("Name")
	self.refresh_time = self:FindVariable("Time")
	self.show_hl = self:FindVariable("show_hl")
	self.show_time = self:FindVariable("show_time")
	self.canKill = self:FindVariable("canKill")
	self.show_limit = self:FindVariable("show_limit")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.icon_image = self:FindVariable("icon_image")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function WorldBossItemCell:__delete()

end

function WorldBossItemCell:SetTheIndex(index)
	self.the_index = index
end

function WorldBossItemCell:ClickItem(is_click)
	if is_click then
		local select_index = self.boss_view:GetSelectIndex()
		local boss_id = self.data.bossID
		self.boss_view:SetSelectBossId(boss_id)
		self.boss_view:SetSelectIndex(self.the_index)
		self.boss_view:FlushAllHL()
		if select_index == self.the_index then
			return
		end
		self.boss_view:FlushReward()
		self.boss_view:FlushInfoList()
	end
end

function WorldBossItemCell:OnFlush()
	if not next(self.data) then return end
	self.root_node.toggle.isOn = false
	local boss_data = BossData.Instance:GetWorldBossInfoById(self.data.bossID)
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if nil ~= monster_cfg and monster_cfg.headid > 0 then
		local bundle, asset = ResPath.GetBossItemIcon(monster_cfg.headid)
		self.icon_image:SetAsset(bundle, asset)
	end
	local bundle, asset = ResPath.GetBoss("bg_rare_02")
	self.icon:SetAsset(bundle, asset)
	self.boss_name:SetValue(boss_data.boss_name or "")
	local refresh_time_str = os.date("%H:00", BossData.Instance:GetBossNextReFreshTime()) .. Language.Boss.Flush
	self.refresh_time:SetValue(refresh_time_str)
	-- self.level:SetValue(boss_data.boss_level)
	local state = BossData.Instance:GetBossStatusByBossId(self.data.bossID)
	self.iskill:SetValue(state == 0)
	self.image_gray_scale:SetValue(state ~= 0)
	local level_text = ""
	if self.data.min_lv > GameVoManager.Instance:GetMainRoleVo().level then
		local lv = PlayerData.GetLevelString(self.data.min_lv)
		level_text = ToColorStr(lv .. Language.Dungeon.CanKill, TEXT_COLOR.RED)
		self.canKill:SetValue(false)
		self.show_time:SetValue(false)
	else
		level_text = "Lv." .. boss_data.boss_level
		self.show_time:SetValue(true)
		self.canKill:SetValue(true)
	end
	self.level:SetValue(level_text)
	self:FlushHL()
end

function WorldBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.the_index)

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		local my_level = GameVoManager.Instance:GetMainRoleVo().level
		self.show_limit:SetValue(false)
	end
end

----------------------------------------------------------------------
WorldBossRewardCell = WorldBossRewardCell or BaseClass(BaseCell)

function WorldBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
end

function WorldBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function WorldBossRewardCell:OnFlush()
	if nil == self.data then
		return
	end

	local item_id = self.data.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
		self.rew_cell:SetData(BossData.Instance:GetShowEquipItemList(item_id, BOSS_TYPE_INFO.RARE))
	else
		self.rew_cell:SetData({item_id = item_id})
	end
end