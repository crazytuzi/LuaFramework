MikuBossView = MikuBossView or BaseClass(BaseRender)

function MikuBossView:__init(instance)
	self.select_index = 1
	self.select_scene_id = 9010
	self.select_boss_id = 10
	self.layer = 0
	self.boss_data = {}
	self.boss_cell_list = {}
	self.reward_data = {}
	self.reward_cell_list = {}
	self.toggle_list = {}
	self.show_hl_list = {}
	self.show_lock_list = {}
end

function MikuBossView:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	if self.moster_model then
		self.moster_model:DeleteMe()
		self.moster_model = nil
	end

	for _,v in pairs(self.boss_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.boss_cell_list = {}

	for _,v in pairs(self.reward_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_cell_list = {}
end

function MikuBossView:LoadCallBack(instance)
	local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10

	self.pi_lao = self:FindVariable("pi_lao")

	for i = 1, 5 do
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
		self:ListenEvent("ClickBoss"..i, BindTool.Bind(self.ClickBoss, self, i, false))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
		self.show_lock_list[i] = self:FindVariable("show_lock_" .. i)
	end
	
	self.focus_toggle = self:FindObj("focus_toggle")
	self.boss_btngo = self:FindObj("boss_btngo")
	self.boss_list = self:FindObj("BossList")
	self.boss_list_view_delegate = self.boss_list.list_simple_delegate
	self.boss_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBossNumberOfCells, self)
	self.boss_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossView, self)

	self.reward_list = self:FindObj("RewardList")
	
	self.reward_list_view_delegate = self.reward_list.list_simple_delegate
	self.reward_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshRewardView, self)

	self:ListenEvent("ToActtack", BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick", BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord", BindTool.Bind(self.OpenKillRecord, self))
	self:ListenEvent("FocusOnClick", BindTool.Bind(self.FocusOnClick, self))
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_view")
	self.model_view:SetDisplay(self.model_display.ui3d_display)

	self:ClickBoss(1, false, true)
	self:FlushModel()
end

function MikuBossView:GetBossBtngo()
	return self.boss_btngo
end

function MikuBossView:CloseBossView()
	self.select_index = 1
end

function MikuBossView:GetBossNumberOfCells()
	return #BossData.Instance:GetMikuBossList(self.select_scene_id) or 0
end

function MikuBossView:GetRewardNumberOfCells()
	local index = 0
	local item_list = BossData.Instance:GetMikuBossFallList(self.select_boss_id)
	if #item_list > 0 then
		for i = 1, #item_list do
			if item_list[i] and item_list[i].item_id and item_list[i].item_id > 0 then
				index  = index + 1
			end
		end
	end
	return index
end

function MikuBossView:RefreshBossView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = MikuBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		boss_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function MikuBossView:RefreshRewardView(cell, data_index)
	data_index = data_index + 1

	local reward_cell = self.reward_cell_list[cell]
	if reward_cell == nil then
		reward_cell = ItemCell.New()
		reward_cell:SetInstanceParent(cell.gameObject)
		self.reward_cell_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.reward_data[data_index])
end

function MikuBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	local role_vo_camp = GameVoManager.Instance:GetMainRoleVo().camp
	ViewManager.Instance:CloseAll()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_scene_id + role_vo_camp * 4 - 4, 0, self.select_boss_id)
end

function MikuBossView:OpenKillRecord()
	--local role_vo_camp = PlayerData.Instance.role_vo.camp
	--BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_boss_id, self.select_scene_id + role_vo_camp * 4 - 4)
	BossCtrl.Instance:SendBossKillDropInfo(COMMON_OPERATE_TYPE.COT_REQ_WORLD_BOSS_DROP_RECORD)
end

function MikuBossView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_boss_id, self.select_scene_id)
		end
	end
end

function MikuBossView:FlushFocusState()
	self.focus_toggle.toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function MikuBossView:QuestionClick()
	local tips_id = 142
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function MikuBossView:FlushModel()
	if self.model_view == nil then
		return
	end
	if self.model_display.gameObject.activeInHierarchy then
		local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
		-- self.model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MONSTER], res_id, DISPLAY_PANEL.FULL_PANEL)
		self.model_view:SetTrigger("rest1")
	end
end

function MikuBossView:FlushToggleHL()
	for i = 1, 5 do
		self.show_hl_list[i]:SetValue(i == self.layer)
	end
end

function MikuBossView:ClickBoss(layer, is_jump_panel, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetMikuBossListClient()) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
				if not can_go then
					local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(min_level)
					local level_text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
					local text = string.format(Language.Boss.BossLimit, level_text)
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v.scene_id
				local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
				if is_jump_panel then
					self.select_boss_id = boss_list[self.select_index] and boss_list[self.select_index].bossID or 10
				else
					self:SetSelectIndex(1)
					self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10
				end
			end
		end
		self.layer = layer
		self:FlushInfoList()
		self:FlushBossList()
		self:FlushToggleHL()
		self:FlushFocusState()
		self:FlushModel()
	end
end

function MikuBossView:FlushItemList()
	local item_list = BossData.Instance:GetMikuBossFallList(self.select_boss_id)
	local index = 1
	if #item_list > 0 then
		for i = 1, #item_list do
			if item_list[i] and item_list[i].item_id and item_list[i].item_id > 0 then
				self.reward_data[index] = item_list[i]
				index = index + 1
			end
		end
	end

	if self.reward_list.scroller.isActiveAndEnabled then
		self.reward_list.scroller:ReloadData(0)
	end
end

function MikuBossView:CheckLevelLockShow()
	for k, v in pairs(BossData.Instance:GetMikuBossListClient()) do
		self.show_lock_list[k]:SetValue(false)
		local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
		if min_level then
			self.show_lock_list[k]:SetValue(not can_go)
		end
	end
end

function MikuBossView:FlushInfoList()
	local boss_data = BossData.Instance
	local max_wearry = boss_data:GetMikuBossMaxWeary()
	local weary = max_wearry - boss_data:GetMikuBossWeary()
	local pi_lao_text = ""
	if weary <= 0 then
		pi_lao_text = ToColorStr(string.format("%s/%s", tostring(weary), tostring(max_wearry)), TEXT_COLOR.RED)
	else
		pi_lao_text = ToColorStr(string.format("%s/%s", tostring(weary), tostring(max_wearry)), TEXT_COLOR.GREEN)
	end
	
	self.pi_lao:SetValue(pi_lao_text)
	if self.select_boss_id ~= 0 then
		self:FlushItemList()
	end
end

function MikuBossView:FlushBossList()
	local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
	end

	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function MikuBossView:FlushBossView()
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushFocusState()
	self:CheckLevelLockShow()
end

function MikuBossView:OnFlush(param_t)
	if param_t then
		for k,v in pairs(param_t) do
			if k == "neutral_boss_index" then
				local layer = tonumber(v.to_ui_name or 1)
				for k,v in pairs(self.toggle_list) do
					v.toggle.isOn = layer == k
				end
				self:SetSelectIndex(tonumber(v.to_ui_param or 1))
				self:ClickBoss(layer, true, true)
			end
		end
	end
	self:FlushBossView()
end

function MikuBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function MikuBossView:GetSelectIndex()
	return self.select_index or 1
end

function MikuBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function MikuBossView:FlushAllHL()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL()
	end
end

function MikuBossView:OnClickItemCallBack(cell, select_index)
	if nil == cell or nil == cell.data then
		return
	end

	cell.root_node.toggle.isOn = true
	local cur_select_index = self:GetSelectIndex()
	self:SetSelectIndex(cell.index)
	self:SetSelectBossId(cell.data.bossID)
	self:FlushAllHL()
	self:FlushFocusState()
	if cur_select_index == cell.index then
		return
	end
	self:FlushInfoList()
	self:FlushModel()
end

------------------------------------------------------------------------------
MikuBossItemCell = MikuBossItemCell or BaseClass(BaseCell)

function MikuBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.level = self:FindVariable("Level")
	-- self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function MikuBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function MikuBossItemCell:ClickItem(is_click)
	if is_click then
		if nil ~= self.click_callback then
			self.click_callback(self)
		end
	end
end

function MikuBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		self.level:SetValue("Lv." .. monster_cfg.level)
		local bundle, asset = ResPath.GetBossView(monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	self.next_refresh_time = BossData.Instance:GetMikuBossRefreshTime(self.data.bossID, self.data.scene_id)
	local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
	if diff_time <= 0 then
		self.iskill:SetValue(false)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
		-- self.image_gray_scale:SetValue(true)
	else
		self.iskill:SetValue(true)
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
		self:OnBossUpdate()
		-- self.image_gray_scale:SetValue(false)
	end
	self:FlushHL()
end

function MikuBossItemCell:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED))
	if time <= 0 then
		self.iskill:SetValue(false)
		-- self.image_gray_scale:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	else
		self.iskill:SetValue(true)
		-- self.image_gray_scale:SetValue(false)
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function MikuBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end