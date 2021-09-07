NeutralBossView = NeutralBossView or BaseClass(BaseRender)

-- 此功能代码垃圾垃圾垃圾！！G16第一个人开始写的就是垃圾代码了。完全无法阅读。
function NeutralBossView:__init(instance)
	self.select_index = 1
	self.select_scene_id = 101
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

function NeutralBossView:__delete()
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

function NeutralBossView:LoadCallBack(instance)
	self.pi_lao = self:FindVariable("pi_lao")

	for i = 1, 5 do
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
		-- self.toggle_list[i]:SetActive(false)
		self:ListenEvent("Click_Boss"..i, BindTool.Bind(self.ClickBossLayer, self, i, false))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
		self.show_lock_list[i] = self:FindVariable("show_lock_" .. i)
	end

	-- local boss_list_client = BossData.Instance:GetNeutralBossListClient()
	-- for i = 1, #boss_list_client do
	-- 	self.toggle_list[i]:SetActive(true)
	-- end

	self.focus_toggle = self:FindObj("focus_toggle")

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

	self:ClickBossLayer(1, false, true)

	local neutral_boss_list = BossData.Instance:GetNeutralBossListCfg()
	for k, v in pairs(neutral_boss_list) do
		if not BossData.Instance:BossIsFollow(v.boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL, v.boss_id, v.scene_id)
		end
	end
end

function NeutralBossView:CloseBossView()
	self.select_index = 1
end

function NeutralBossView:GetBossNumberOfCells()
	return #BossData.Instance:GetNeutralBossList(self.select_scene_id) or 0
end

function NeutralBossView:GetRewardNumberOfCells()
	local item_list = BossData.Instance:GetNeutralBossFallList(self.select_boss_id)
	local index = 0
	if #item_list > 0 then
		for i = 1, #item_list do
			if item_list[i] and item_list[i].item_id and item_list[i].item_id > 0 then
				index = index + 1
			end
		end
	end
	return index
end

function NeutralBossView:RefreshBossView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = NeutralBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		boss_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function NeutralBossView:RefreshRewardView(cell, data_index)
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

function NeutralBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	local role_vo_camp = PlayerData.Instance.role_vo.camp
	ViewManager.Instance:CloseAll()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL, self.select_scene_id, 0, self.select_boss_id)
	BossData.Instance:SetActtackNeutralBoss(self.select_boss_id, self.select_scene_id)

	local boss_id = self.select_boss_id
	local boss_scene_id = self.select_scene_id
	if boss_id ~= nil and boss_scene_id ~= nil then
		local cfg = BossData.Instance:GetNeutralBossSceneList(boss_id)
		if cfg ~= nil and next(cfg) ~= nil then
			--GuajiCtrl.Instance:MoveToScenePos(boss_scene_id, cfg.born_x, cfg.born_y)
			--BossData.Instance:SetActtackNeutralBoss(nil, nil)
			MoveCache.end_type = MoveEndType.Auto
			if Scene.Instance:GetSceneId() ~= self.select_scene_id then
				Scene.Instance.move_to_pos_cache.x = cfg.born_x
				Scene.Instance.move_to_pos_cache.y = cfg.born_y
				Scene.Instance.move_to_pos_cache.scene_id = boss_scene_id
				Scene.Instance.move_to_pos_cache.is_special = true
			else
				--GuajiCtrl.Instance:MoveToScenePos(boss_scene_id, cfg.born_x, cfg.born_y)
				GuajiCtrl.Instance:MoveToPos(boss_scene_id, cfg.born_x, cfg.born_y, 10, 10, nil, nil, true)
			end

		end
	end
end

function NeutralBossView:OpenKillRecord()
	--BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL, self.select_boss_id, self.select_scene_id)
	BossCtrl.Instance:SendBossKillDropInfo(COMMON_OPERATE_TYPE.COT_REQ_WORLD_BOSS_DROP_RECORD)
end

function NeutralBossView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_NEUTRAL, self.select_boss_id, self.select_scene_id)
		end
	end
end

function NeutralBossView:FlushFocusState()
	self.focus_toggle.toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function NeutralBossView:QuestionClick()
	TipsCtrl.Instance:ShowHelpTipView(143)
end

function NeutralBossView:FlushModel()
	if self.model_view == nil then
		return
	end
	if self.model_display.gameObject.activeInHierarchy then
		local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
		self.model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MONSTER], res_id, DISPLAY_PANEL.FULL_PANEL)
		self.model_view:SetTrigger("rest1")
	end
end

function NeutralBossView:FlushToggleHL()
	for i=1,5 do
		self.show_hl_list[i]:SetValue(i == self.layer)
	end
end

function NeutralBossView:ClickBossLayer(layer, is_jump_panel, is_click)
	if is_click then
		local boss_list_client = BossData.Instance:GetNeutralBossListClient()
		for k,v in pairs(boss_list_client) do
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
				local boss_list = BossData.Instance:GetNeutralBossList(self.select_scene_id)
				if is_jump_panel then
					self.select_boss_id = boss_list[self.select_index] and boss_list[self.select_index].boss_id or 1
				else
					self:SetSelectIndex(1)
					self.select_boss_id = boss_list[1] and boss_list[1].boss_id or 1 
				end
			end
		end
		if layer > #boss_list_client then
			self.select_scene_id = 0
		end
		self.layer = layer
		self:FlushInfoList()
		self:FlushBossList()
		self:FlushToggleHL()
		self:FlushFocusState()
	end
end

function NeutralBossView:FlushItemList()
	local item_list = BossData.Instance:GetNeutralBossFallList(self.select_boss_id)
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

function NeutralBossView:CheckLevelLockShow()
	for k, v in pairs(BossData.Instance:GetNeutralBossListClient()) do
		self.show_lock_list[k]:SetValue(false)
		local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
		if min_level then
			self.show_lock_list[k]:SetValue(not can_go)
		end
	end
end

function NeutralBossView:FlushInfoList()
	self.pi_lao:SetValue(Language.Boss.NeutralEnter)--不要疲劳了
	if self.select_boss_id ~= 0 then
		self:FlushItemList()
		self:FlushModel()
	end
end

function NeutralBossView:FlushBossList()
	local boss_list = BossData.Instance:GetNeutralBossList(self.select_scene_id)
	self.boss_data = boss_list

	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function NeutralBossView:FlushBossView()

	local boss_list = BossData.Instance:GetNeutralBossList(self.select_scene_id)

	self.select_boss_id = boss_list[self.select_index] and boss_list[self.select_index].boss_id or 10

	self:FlushBossList()
	self:FlushInfoList()
	self:FlushFocusState()
	self:CheckLevelLockShow()
end

function NeutralBossView:OnFlush(param_t)
	if param_t then
		for k,v in pairs(param_t) do
			if k == "neutral_boss_index" then
				local layer = tonumber(v.to_ui_name or 1)
				for k,v in pairs(self.toggle_list) do
					v.toggle.isOn = layer == k
				end
				self:SetSelectIndex(tonumber(v.to_ui_param or 1))
				self:ClickBossLayer(layer, true, true)
			end
		end
	end

	self:FlushBossView()
end

function NeutralBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function NeutralBossView:GetSelectIndex()
	return self.select_index or 1
end

function NeutralBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function NeutralBossView:FlushAllHL()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL()
	end
end

function NeutralBossView:OnClickItemCallBack(cell, select_index)
	if nil == cell or nil == cell.data then
		return
	end
	
	cell.root_node.toggle.isOn = true
	local cur_select_index = self:GetSelectIndex()
	self:SetSelectIndex(cell.index)
	self:SetSelectBossId(cell.data.boss_id)
	self:FlushAllHL()
	self:FlushFocusState()
	if cur_select_index == cell.index then
		return
	end
	self:FlushInfoList()
end


------------------------------------------------------------------------------
NeutralBossItemCell = NeutralBossItemCell or BaseClass(BaseCell)

function NeutralBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.level = self:FindVariable("Level")
	-- self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function NeutralBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function NeutralBossItemCell:ClickItem(is_click)
	if is_click then
		if nil ~= self.click_callback then
			self.click_callback(self)
		end
	end
end

function NeutralBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		self.level:SetValue("Lv." .. monster_cfg.level)
		local bundle, asset = ResPath.GetBossView(monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	self.next_refresh_time, self.status = BossData.Instance:GetNeutralBossRefreshTime(self.data.boss_id, self.data.scene_id)
	local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
	self.iskill:SetValue(self.status == 0 and self.next_refresh_time > TimeCtrl.Instance:GetServerTime())
	if diff_time <= 0 then
		--self.iskill:SetValue(false)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
		-- self.image_gray_scale:SetValue(true)
	else
		--self.iskill:SetValue(true)
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

function NeutralBossItemCell:OnBossUpdate()
	--local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	local next_refresh_time = self.next_refresh_time or 0
	local status = self.status or 0
	local time = math.max(0, next_refresh_time - TimeCtrl.Instance:GetServerTime())
	self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED))
	--if time <= 0 then
	if status == 1 then
		self.iskill:SetValue(false)
		-- self.image_gray_scale:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	else
		self.iskill:SetValue(true)
		-- self.image_gray_scale:SetValue(false)
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function NeutralBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

	if flag == true then
		return true
	end

	if is_first == true then
		return true
	end