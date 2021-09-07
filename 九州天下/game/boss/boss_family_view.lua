BossFamilyView = BossFamilyView or BaseClass(BaseRender)

function BossFamilyView:__init()
	self.select_index = 1
	self.select_scene_id = 9000
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

function BossFamilyView:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
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

function BossFamilyView:LoadCallBack()
	
	self.focus_toggle = self:FindObj("focus_toggle")
	for i=1, 5 do
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
		self:ListenEvent("ClickBoss"..i, BindTool.Bind(self.ClickBoss, self, i))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
		self.show_lock_list[i] = self:FindVariable("show_lock_" .. i)
	end
	self.list_view = self:FindObj("BossList")
	self.boss_list_view_delegate = self.list_view.list_simple_delegate
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

	self.free_vip_text = self:FindVariable("free_vip_text")
	self.model_display = self:FindObj("display")
	self.cost_enter = self:FindVariable("CostEnter")

	self.model_view = RoleModel.New("boss_view")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
end

function BossFamilyView:CloseBossView()
	self.select_index = 1
end

function BossFamilyView:GetBossNumberOfCells()
	return #BossData.Instance:GetBossFamilyList(self.select_scene_id) or 0
end

function BossFamilyView:GetRewardNumberOfCells()
	local index = 0
	local item_list = BossData.Instance:GetBossFamilyFallList(self.select_boss_id)
	if #item_list > 0 then
		for i = 1, #item_list do
			if item_list[i] and item_list[i].item_id and item_list[i].item_id > 0 then
				index = index + 1
			end
		end
	end
	return index
end

function BossFamilyView:FlushToggleHL()
	for i=1,5 do
		self.show_hl_list[i]:SetValue(i == self.layer)
	end
end

function BossFamilyView:RefreshBossView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = BossFamilyItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.list_view.toggle_group
		boss_cell.boss_view = self
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function BossFamilyView:RefreshRewardView(cell, data_index)
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

function BossFamilyView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end

	ViewManager.Instance:CloseAll()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_scene_id)
end

function BossFamilyView:QuestionClick()
	local tips_id = 141 -- boss之家
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossFamilyView:OpenKillRecord()
	--BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, self.select_scene_id)
	BossCtrl.Instance:SendBossKillDropInfo(COMMON_OPERATE_TYPE.COT_REQ_WORLD_BOSS_DROP_RECORD)
end

function BossFamilyView:FlushModel()
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

function BossFamilyView:ClickBoss(layer, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetBossFamilyListClient()) do
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
				self:SetSelectIndex(1)
				local boss_list = BossData.Instance:GetBossFamilyList(self.select_scene_id)
				self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10
				break
			end
		end
		self.layer = layer
		local vip_level, cost_gold = BossData.Instance:GetBossVipLismit(self.select_scene_id)
		local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
		local vip_text = Language.Common.VIP..vip_level
		if my_vip < vip_level then
			vip_text = ToColorStr(vip_text, TEXT_COLOR.RED)
		end
		self.free_vip_text:SetValue(vip_text)
		self.cost_enter:SetValue(cost_gold)
		self:FlushInfoList()
		self:FlushBossList()
		self:FlushToggleHL()
		self:FlushFocusState()
	end
end
function BossFamilyView:FlushItemList()
	local item_list = BossData.Instance:GetBossFamilyFallList(self.select_boss_id)
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

function BossFamilyView:FlushFocusState()
	self.focus_toggle.toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function BossFamilyView:FocusOnClick(is_click)
	if is_click then
		if not BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.FOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, self.select_scene_id)
		end
	else
		if BossData.Instance:BossIsFollow(self.select_boss_id) then
			BossCtrl.SendFollowBossReq(BossData.FOLLOW_BOSS_OPE_TYPE.UNFOLLOW_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_boss_id, self.select_scene_id)
		end
	end
end

function BossFamilyView:OnFlush(param_t)
	if param_t then
		for k,v in pairs(param_t) do
			if k == "vip_boss_index" then
				local layer = tonumber(v.to_ui_name or 1)
				for k,v in pairs(self.toggle_list) do
					v.toggle.isOn = layer == k
				end
				self:SetSelectIndex(tonumber(v.to_ui_param or 1))
			end
		end
	end
	-- self:CheckFrameIsOpen()
	self:FlushBossView()
end

function BossFamilyView:CheckFrameIsOpen()
	for i = 1, 5 do
		if self.toggle_list[i].toggle.isOn then
			self.toggle_list[i].toggle.isOn = false
			break
		end
	end
end

function BossFamilyView:CheckLevelLockShow()
	for k, v in pairs(BossData.Instance:GetBossFamilyListClient()) do
		self.show_lock_list[k]:SetValue(false)
		local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
		if min_level then
			self.show_lock_list[k]:SetValue(not can_go)
		end
	end
end

function BossFamilyView:FlushInfoList()
	self:FlushItemList()
	self:FlushModel()
end

function BossFamilyView:FlushBossList()
	local boss_list = BossData.Instance:GetBossFamilyList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
	end
	if self.select_index == 1 then
		self.list_view.scroller:ReloadData(0)
	else
		self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossFamilyView:FlushBossView()
	local boss_list = BossData.Instance:GetBossFamilyList(self.select_scene_id)
	self.select_boss_id = boss_list[self.select_index] and boss_list[self.select_index].bossID or 10
	self:FlushBossList()
	self:FlushFocusState()
	self:FlushInfoList()
	self:CheckLevelLockShow()
end

function BossFamilyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossFamilyView:GetSelectIndex()
	return self.select_index or 1
end

function BossFamilyView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function BossFamilyView:FlushAllHL()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL()
	end
end
-------------------------------------------------------------------------
BossFamilyItemCell = BossFamilyItemCell or BaseClass(BaseCell)

function BossFamilyItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.level = self:FindVariable("Level")
	self.show_hl = self:FindVariable("show_hl")
	-- self.image_gray_scale = self:FindVariable("image_gray_scale")

	self.index = 0

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function BossFamilyItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function BossFamilyItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:FlushFocusState()
		self.boss_view:FlushAllHL()
		if self.data == nil or select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function BossFamilyItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		-- local lv, zhuan = PlayerData.GetLevelAndRebirth(monster_cfg.level)
		-- self.level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
		self.level:SetValue("Lv." .. monster_cfg.level)

		local bundle, asset = ResPath.GetBossView(monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	self.next_refresh_time, self.status = BossData.Instance:GetFamilyBossRefreshTime(self.data.bossID, self.data.scene_id)
	self.iskill:SetValue(self.status == 0 and self.next_refresh_time > TimeCtrl.Instance:GetServerTime())
	if self.next_refresh_time > TimeCtrl.Instance:GetServerTime() then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self:OnBossUpdate()
		-- self.image_gray_scale:SetValue(false)
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		-- self.image_gray_scale:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	end
	self:FlushHL()
end

function BossFamilyItemCell:OnBossUpdate()
	local next_refresh_time = self.next_refresh_time or 0
	local status = self.status or 0
	local time = math.max(0, next_refresh_time - TimeCtrl.Instance:GetServerTime())
	self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED))
	if status == 1 then
		self.iskill:SetValue(false)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	else
		self.iskill:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.NextFlush .. TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function BossFamilyItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end