KuafuTjBossView = KuafuTjBossView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2
local SHOW_FLOOR = 4  --显示层数

function KuafuTjBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 8251
	self.select_boss_id = KuafuGuildBattleData.Instance:GetLayerBossList(self.select_scene_id)[1].monster_id
	self.boss_data = {}
	self.cell_list = {}
	self.rew_list = {}
	self.togglecell_list = {}

	self.reward_data = KuafuGuildBattleData.Instance:GetTjBossRewards(self.select_scene_id, self.select_boss_id)
	self.floor_list = {}
	self.layer = 1
	self.num = 0
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")

	self.boss_name = self:FindVariable("BossName")
	self.enter_btn_name = self:FindVariable("EnterBtnName")
	self.enter_btn_gray = self:FindVariable("EnterBtnGray")
	self.diamon = self:FindVariable("Diamon")
	self.is_bindgold = self:FindVariable("IsBindGold")
	self.count_text = self:FindVariable("CountText")
	self.is_max_vip_count = self:FindVariable("IsMaxVipCount")

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

	self:ListenEvent("ToActtack",BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick",BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenKillRecord",BindTool.Bind(self.OpenKillRecord, self))
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
end

function KuafuTjBossView:__delete()
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

	self.nowpanelboss_num = nil
end

function KuafuTjBossView:ClickScene(layer)
	if self.layer == layer then
		return
	end
	for k,v in pairs(KuafuGuildBattleData.Instance:GetTianjiangSceneList()) do
		if layer == k then
			self.select_scene_id = scene_id
			break
		end
	end
	self.layer = layer
	self:FlushBoss()
	self:FlushToggleHL()
end

function KuafuTjBossView:FlushToggleHL()
	for k, v in ipairs(self.togglecell_list) do
		v:SetToggleState(self.layer)
	end
end

function KuafuTjBossView:FlushBossRemainCount()
	for i=1,3 do
		self.remain_count_text_list[i]:SetValue("2")
	end
end

function KuafuTjBossView:CloseBossView()
	self.select_index = 1
end

function KuafuTjBossView:GetNumberOfCells()
	return #self.boss_data or 0
end

function KuafuTjBossView:GetRewardNumberOfCells()
	return GetListNum(self.reward_data)
end

function KuafuTjBossView:GetToggleListNumOfCells()
	local list = KuafuGuildBattleData.Instance:GetTianjiangSceneList()
	return #list
end

function KuafuTjBossView:ToggleRefreshView(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.togglecell_list[data_index]
	if not toggle_cell then
		toggle_cell = TjBossToggle.New(cell.gameObject)
		self.togglecell_list[data_index] = toggle_cell
		toggle_cell.boss_view = self
	end
	toggle_cell:SetIndex(data_index, self.floor_list)
	toggle_cell:Flush()
end

function KuafuTjBossView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = TjBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetData(self.reward_data[data_index])
	reward_cell:SetBossID(self.select_boss_id)
	reward_cell:Flush()
end

function KuafuTjBossView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = TjBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function KuafuTjBossView:InitFloorList()
	self.floor_list = {1}
end


function KuafuTjBossView:ToActtack()
	if KuafuGuildBattleData.Instance:GetTiangJiangIsMaxCount() then
		if KuafuGuildBattleData.Instance:GetIsMaxVipCount() then
			TipsCtrl.Instance:ShowSystemMsg(Language.KuafuGuildBattle.KfLiuJieMaxCount)
			self.is_max_vip_count:SetValue(true)
		else
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.TIANJIANG_ENTER_TIMES)
		end
		return
	end
	local function func()
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_TIANJIANG_BOSS, self.select_boss_id)
	end
	local cost_info = KuafuGuildBattleData.Instance:GetTianJiangBossCost()
	if cost_info then
		local gold = cost_info.is_bind == 1 and Language.Common.IsBindGoldZuanShi or Language.Common.ZuanShi
		local des = string.format(Language.KuafuGuildBattle.KfLiuJieBuyCount, cost_info.cost, gold)
		TipsCtrl.Instance:ShowCommonAutoView("", des, func)
	end
end

function KuafuTjBossView:QuestionClick()
	local tips_id = 264
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuafuTjBossView:FlushModel()
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

function KuafuTjBossView:OpenKillRecord()
	local cur_boss_info = KuafuGuildBattleData.Instance:GetTianJiangStatusByBossId(self.select_boss_id, self.select_scene_id)
	BossData.Instance:SetCheckKillInfoBossID(self.select_boss_id)
	local kill_data = BossData.Instance:ComBossKillerInfo(cur_boss_info.killer_info)
	TipsCtrl.Instance:OpenKillBossTip(kill_data)
end

function KuafuTjBossView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			self.boss_name:SetValue(monster_cfg.name)
		end
		self.enter_btn_gray:SetValue(true)
		self:FlushModel()
	end
end

function KuafuTjBossView:FlushBossList()
	self.num = 0
	local boss_list = KuafuGuildBattleData.Instance:GetLayerBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			local state = KuafuGuildBattleData.Instance:GetTianJiangStatusByBossId(boss_list[i].monster_id, boss_list[i].scene_id)
			if state and state.status ~= 0 then
				self.num = self.num + 1
			end
		end
		self.select_boss_id = boss_list[1].monster_id
	end
	self.nowpanelboss_num:SetValue(self.num .." / ".. #boss_list)
	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuafuTjBossView:FlushReward()
	self.reward_data = KuafuGuildBattleData.Instance:GetTjBossRewards(self.select_scene_id, self.select_boss_id)
	self.reward_list.scroller:ReloadData(0)
end

function KuafuTjBossView:FlushBossView()
	self.select_index = 1
	self:InitFloorList()
	self.toggle_list.scroller:ReloadData(0)
	self:FlushBoss()
end

function KuafuTjBossView:FlushBoss()
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushReward()
	self:FlushBossRemainCount()
	self:FlushToggleHL()
	self:FlushModel()
	local cost_info = KuafuGuildBattleData.Instance:GetTianJiangBossCost()
	if cost_info then
		self.diamon:SetValue(cost_info.cost)
		self.is_bindgold:SetValue(cost_info.is_bind == 1)
	end
	self.is_max_vip_count:SetValue(KuafuGuildBattleData.Instance:GetTiangJiangIsMaxCount() and KuafuGuildBattleData.Instance:GetIsMaxVipCount())
	local cur_count, max_count = KuafuGuildBattleData.Instance:GetTiangJiangCount()
	self.count_text:SetValue(string.format(Language.KuafuGuildBattle.KfLiuJieShowCount, cur_count.. " / " .. max_count))
end

function KuafuTjBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function KuafuTjBossView:GetSelectIndex()
	return self.select_index or 1
end

function KuafuTjBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function KuafuTjBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

----------------------------------------------------------------------
--奖励展示
TjBossRewardCell = TjBossRewardCell or BaseClass(BaseCell)

function TjBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
	self.boss_id = 0
end

function TjBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function TjBossRewardCell:OnFlush()
	if nil == self.data then
		return
	end
	local item_id = self.data
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if monster_cfg and item_cfg and item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
		self.rew_cell:SetData(BossData.Instance:GetShowEquipItemList(item_id, monster_cfg.boss_type))
		self.rew_cell:NotShowStar()
		if BOSS_TYPE_INFO.RARE == monster_cfg.boss_type then
			self.rew_cell:SetShowStar(4)
		else
			self.rew_cell:SetShowStar(1)
		end
	else
		self.rew_cell:SetData({item_id = item_id})
	end
end

function TjBossRewardCell:SetBossID(index)
	self.boss_id = index
end

----------------------------------------------------------------------
--BOSSITEM展示
TjBossItemCell = TjBossItemCell or BaseClass(BaseCell)

function TjBossItemCell:__init()
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

function TjBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function TjBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.monster_id)
		self.boss_view:FlushReward()
		self.boss_view:FlushAllHL()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function TjBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
	if monster_cfg then
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.boss_name:SetValue(monster_cfg.name)
		self.canKill:SetValue(true)
		self:FlushLimit(monster_cfg)
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
	local reflash_time = KuafuGuildBattleData.Instance:GetTjStatusByBossId(self.data.monster_id, self.data.scene_id)
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

function TjBossItemCell:OnBossUpdate()
	local reflash_time = KuafuGuildBattleData.Instance:GetTjStatusByBossId(self.data.monster_id, self.data.scene_id)
	local time = math.max(0, reflash_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self:FlushLimit()
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(Language.Boss.HadFlush)
	else
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time,3), TEXT_COLOR.RED_1))
	end
end

function TjBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

function TjBossItemCell:FlushLimit(monster_cfg)
	local monster_cfg = monster_cfg or ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.monster_id]
	if monster_cfg then
		local my_level = GameVoManager.Instance:GetMainRoleVo().level
		self.show_limit:SetValue(false)
	end
end


---------------------------------------------------------
--toggle展示
TjBossToggle = TjBossToggle or BaseClass(BaseCell)

function TjBossToggle:__init()
	self.floor_index = 0
	self.list_toggle = {}
	self.toggle_index = 0
	self.text = self:FindVariable("Floor_Text")
	self.show_hl = self:FindVariable("Show_Hl")
	self:ListenEvent("ClickToggle", BindTool.Bind(self.ClickToggle, self))
end

function TjBossToggle:__delete()

end

function TjBossToggle:ClickToggle()
	self.boss_view:ClickScene(self.toggle_index)
end

function TjBossToggle:SetIndex(index, list)
	self.index = index
	self.list_toggle = list
end

function TjBossToggle:OnFlush()
	self:SwitchScene()
end

function TjBossToggle:SetToggleState(index)
	self.show_hl:SetValue(self.toggle_index == index)
end

function TjBossToggle:SwitchScene()
	for i=1,SHOW_FLOOR do
		if i == self.index then
			self.text:SetValue(string.format(Language.Boss.Floor, self.list_toggle[i]))
			self.toggle_index = self.list_toggle[i]
		end
	end
end

