KuafuSwBossView = KuafuSwBossView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2

function KuafuSwBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_boss_id = 0
	self.scroll_change = false 			--记录画布是否在滚动中
	self.select_scene_id = 8301

	self.boss_data = {}
	self.cell_list = {}
	self.rew_list = {}
	self.num = 0
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")
	self.diamon = self:FindVariable("Diamon")
	self.weary_val = self:FindVariable("WearyVal")
	self.open_time = self:FindVariable("OpenTime")

	self.list_view = self:FindObj("BossList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.reward_data = {}
	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.ReRewardfreshView, self)

	self:ListenEvent("QuestionClick",BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",BindTool.Bind(self.OpenKillRecord, self))
	self:ListenEvent("ToActtack",BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("OnPlusBtn",BindTool.Bind(self.OnPlusBtn, self))

	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
	self.is_first_open = true

	self:FlushOpenTime()
end

function KuafuSwBossView:__delete()
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

function KuafuSwBossView:GetNumberOfCells()
	return #self.boss_data or 0
end

function KuafuSwBossView:GetRewardNumberOfCells()
	return #self.reward_data
end

function KuafuSwBossView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = SwBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.reward_data[data_index])
end

function KuafuSwBossView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = SwBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.list_view.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetTheIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function KuafuSwBossView:CloseBossView()
	self.select_index = 1
end

function KuafuSwBossView:ToActtack()
	CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_SHENWU_BOSS, self.select_boss_id)
end

function KuafuSwBossView:OnPlusBtn()
	local function func()
		KuafuGuildBattleCtrl.Instance:SendCrossShenWuOperatorReq(CROSS_SHENWU_BOSS_OPER_TYPE.CROSS_SHENWU_BOSS_OPER_TYPE_BUY_WEARY_LIMIT)
	end
	local cost_cfg = KuafuGuildBattleData.Instance:GetShenWuBossCost()
	if cost_cfg then
		local des = string.format(Language.KuafuGuildBattle.KfLiuJieBuyCount, cost_cfg.cost)
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	end
end

function KuafuSwBossView:QuestionClick()
	local tips_id = 265
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuafuSwBossView:OpenKillRecord()
	local cur_boss_info = KuafuGuildBattleData.Instance:GetBossStatusByBossId(self.select_scene_id, self.select_boss_id)
	BossData.Instance:SetCheckKillInfoBossID(self.select_boss_id)
	local kill_data = BossData.Instance:ComBossKillerInfo(cur_boss_info.killer_info)
	TipsCtrl.Instance:OpenKillBossTip(kill_data)
end

function KuafuSwBossView:FlushModel()
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

function KuafuSwBossView:FlushInfoList()
	self:FlushModel()
end

function KuafuSwBossView:FlushBossList()
	self.num = 0
	local boss_list = KuafuGuildBattleData.Instance:GetLayerSwBossList(self.select_scene_id)
	self.boss_data = {}
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			local state = KuafuGuildBattleData.Instance:GetBossStatusByBossId(boss_list[i].scene_id, boss_list[i].monster_id)
			if state and state.status ~= 0 then
				self.num = self.num + 1
			end
		end
		self.nowpanelboss_num:SetValue(self.num .." / ".. #boss_list)
	end
	if self.select_index == 1 then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuafuSwBossView:FlushReward()
	self.reward_data = KuafuGuildBattleData.Instance:GetShenWuBossRewardList(self.select_boss_id) or {}
	self.reward_list.scroller:ReloadData(0)
end

function KuafuSwBossView:ChangeOpenState(is_on)
	self.is_first_open = is_on
end

function KuafuSwBossView:FlushBossView()
	self.select_index = 1
	self.select_boss_id = KuafuGuildBattleData.Instance:GetLayerSwBossList(self.select_scene_id)[1].monster_id
	self:FlushBossList()
	if self.is_first_open then
		self:FlushInfoList()
		self.is_first_open = false
	end
	self:FlushReward()
	local cost_cfg = KuafuGuildBattleData.Instance:GetShenWuBossCost()
	if cost_cfg then
		self.diamon:SetValue(cost_cfg.cost)
	end
	local weary_info = KuafuGuildBattleData.Instance:GetShenWuBosswearyInfo()
	local other_cfg = KuafuGuildBattleData.Instance:GetShenWuBossOther()
	if other_cfg and weary_info and weary_info.weary_val then
		self.weary_val:SetValue(string.format(Language.KuafuGuildBattle.KfLiuJieWeary, weary_info.weary_val .. " / " .. weary_info.weary_val_limit + other_cfg.weary_val_limit))
	end
end

function KuafuSwBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function KuafuSwBossView:GetSelectIndex()
	return self.select_index or 1
end

function KuafuSwBossView:SetSelectBossId(boss_id, scene_id)
	self.select_boss_id = boss_id
	self.select_scene_id = scene_id
end

function KuafuSwBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function KuafuSwBossView:FlushOpenTime()
	local open_time, close_time = KuafuGuildBattleData.Instance:GetShenWuBossOpenTime()
	if open_time and close_time then
		local time = string.format("%02d", open_time / 100) .. ":" .. string.format("%02d", open_time % 100)
		time = time .. " - " .. string.format("%02d", close_time / 100) .. ":" .. string.format("%02d", close_time % 100)
		self.open_time:SetValue(ToColorStr(time, TEXT_COLOR.BLUE1))
	end
end

------------------------------------------------------------------
SwBossItemCell = SwBossItemCell or BaseClass(BaseCell)

function SwBossItemCell:__init()
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

function SwBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function SwBossItemCell:SetTheIndex(index)
	self.the_index = index
end

function SwBossItemCell:ClickItem(is_click)
	if is_click then
		local select_index = self.boss_view:GetSelectIndex()
		local boss_id = self.data.monster_id
		self.boss_view:SetSelectBossId(boss_id, self.data.scene_id)
		self.boss_view:SetSelectIndex(self.the_index)
		self.boss_view:FlushAllHL()
		if select_index == self.the_index then
			return
		end
		self.boss_view:FlushReward()
		self.boss_view:FlushInfoList()
	end
end

function SwBossItemCell:OnFlush()
	if not next(self.data) then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
	if nil ~= monster_cfg and monster_cfg.headid > 0 then
		local bundle, asset = ResPath.GetBossItemIcon(monster_cfg.headid)
		self.icon_image:SetAsset(bundle, asset)
	end
	local bundle, asset = ResPath.GetBoss("bg_rare_02")
	self.icon:SetAsset(bundle, asset)
	self.boss_name:SetValue(monster_cfg.name or "")
	-- self.level:SetValue(boss_data.boss_level)
	local state_info = KuafuGuildBattleData.Instance:GetBossStatusByBossId(self.data.scene_id, self.data.monster_id)
	local state = state_info and state_info.status or 0
	local next_time = state_info and state_info.next_refresh_timestamp or 0
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	if next_time > 0 then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(BindTool.Bind(self.OnBossUpdate, self), 1, next_time - TimeCtrl.Instance:GetServerTime())
		end
		self:OnBossUpdate()
	else
		self.refresh_time:SetValue(Language.Boss.HadFlush)
	end

	self.iskill:SetValue(state == 0)
	self.image_gray_scale:SetValue(state == 0)
	local level_text = "Lv." .. monster_cfg.level
	self.show_time:SetValue(true)
	self.canKill:SetValue(true)
	self.level:SetValue(level_text)
	self:FlushHL()
end

function SwBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.the_index)

	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
	if monster_cfg then
		local my_level = GameVoManager.Instance:GetMainRoleVo().level
		self.show_limit:SetValue(false)
	end
end

function SwBossItemCell:OnBossUpdate()
	local state_info = KuafuGuildBattleData.Instance:GetBossStatusByBossId(self.data.scene_id, self.data.monster_id)
	local next_time = state_info and state_info.next_refresh_timestamp or 0
	local time = math.max(0, next_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.refresh_time:SetValue(Language.Boss.HadFlush)
	else
		self.refresh_time:SetValue(ToColorStr(TimeUtil.FormatSecond(time,3), TEXT_COLOR.RED_1))
	end
end
----------------------------------------------------------------------
SwBossRewardCell = SwBossRewardCell or BaseClass(BaseCell)

function SwBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
end

function SwBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function SwBossRewardCell:OnFlush()
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