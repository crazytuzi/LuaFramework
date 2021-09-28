BossFamilyView = BossFamilyView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2
local SHOW_FLOOR = 4 --显示层数

function BossFamilyView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 9000
	self.select_clent_scene_id = 9000
	self.select_boss_id = 10
	self.is_cross = 0
	self.scroll_change = false 			--记录画布是否在滚动中
	self.layer = 0
	self.boss_data = {}
	self.cell_list = {}
	self.is_first = true
	self.num = 0
	self.rew_list = {}
	self.reward_data = {}

	self.scene_num = 0
	self.now_index = 0
	self.floor_list = {}

	self.enter_limit = self:FindVariable("EnterLimit")
	self.enter_cost = self:FindVariable("EnterCost")
	self.wajue_num = self:FindVariable("wajue_num")

	self.remain_count_text_list = {}
	for i=1,3 do
		self.remain_count_text_list[i] = self:FindVariable("remain_count_text_" .. i)
	end

	self.show_hl_list = {}
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")

	self.focus_toggle = self:FindObj("focus_toggle")

	self.list_view = self:FindObj("BossList")
	self.list_view_delegate = self.list_view.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.reward_list = self:FindObj("RewardList")
	self.reward_view_delegate = self.reward_list.list_simple_delegate
	self.reward_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetRewardNumberOfCells, self)
	self.reward_view_delegate.CellRefreshDel = BindTool.Bind(self.ReRewardfreshView, self)

	--toggle list
	self.togglecell_list = {}
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
	self:ListenEvent("FocusOnClick",
		BindTool.Bind(self.FocusOnClick, self))
	self:ListenEvent("OpenEquipCompose",
		BindTool.Bind(self.OpenEquipCompose, self))
	self:ListenEvent("ClickBuy",
		BindTool.Bind(self.ClickBuy, self))

	self.show_panel = self:FindVariable("ShowPanel")
	self.show_boss = self:FindVariable("ShowBoss")
	self.free_vip_text = self:FindVariable("free_vip_text")
	self.show_equip_compose = self:FindVariable("ShowEquipCompose")
	self.show_equip_compose:SetValue(false)
	self.vip_limit = self:FindVariable("VipLimit")
	self.model_display = self:FindObj("display")
	-- self.show_notice = self:FindVariable("ShowNotice")
	self.pi_lao = self:FindVariable("pi_lao")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)


	-- self.show_notice:SetValue(not IS_AUDIT_VERSION)
end

function BossFamilyView:__delete()
	if self.model_view then
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

	for _,v in pairs(self.togglecell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.togglecell_list = {}

	self.is_first = true
	self.wajue_num = nil
end

function BossFamilyView:CloseBossView()
	self.is_first = true
	self.select_index = 1
	BossData.Instance:SetBossLayer(-1)
end

function BossFamilyView:GetNumberOfCells()
	return #self.boss_data
end

function BossFamilyView:FlushToggleHL()
	for k, v in pairs(self.togglecell_list) do
		v:SetToggleState(self.layer)
	end
end

function BossFamilyView:GetRewardNumberOfCells()
	return #self.reward_data
end

function BossFamilyView:ReRewardfreshView(cell, data_index)
	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = FamilyBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetBossID(self.select_boss_id)
	reward_cell:SetData(self.reward_data[data_index])
end

function BossFamilyView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = BossFamilyItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.list_view.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])

	if data_index == self.select_index then
		boss_cell:ClickItem(true)
	end
	boss_cell:Flush()
	if not boss_cell:IsKill() then
		self.num = self.num + 1
	end
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
	local ok_fun = function ()
		local vo = GameVoManager.Instance:GetMainRoleVo()
		local _, cost_gold = BossData.Instance:GetBossVipLismit(self.select_scene_id)

		if vo.bind_gold >= cost_gold then
			BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
			ViewManager.Instance:CloseAll()
			self:SendToActtack()
		else
			if vo.gold + vo.bind_gold >= cost_gold then
				ViewManager.Instance:CloseAll()
				BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
				self:SendToActtack()
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		end
	end
	if BossData.Instance:GetFamilyBossCanGoByVip(self.select_scene_id) then
		BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
		ViewManager.Instance:CloseAll()
		self:SendToActtack()
	else
		TipsCtrl.Instance:ShowCommonTip(ok_fun, nil, Language.Boss.BossFamilyLimit)
	end
end

function BossFamilyView:SendToActtack()
	if self.is_cross == 1 then
		CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_COMMON_BOSS, BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_scene_id, self.select_boss_id)
	else
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY, self.select_scene_id, 0, self.select_boss_id)
	end
end

function BossFamilyView:QuestionClick()
	local tips_id = 141 -- boss之家
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossFamilyView:OpenKillRecord()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.drop)
end

function BossFamilyView:FlushModel()
	if self.model_view == nil then
		return
	end
--	if self.model_display.gameObject.activeInHierarchy then
		local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
		local display_name = BossData.Instance:DisplayName(res_id)
		self.model_view:SetPanelName(display_name)
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
		self.model_view:SetTrigger("rest1")
--	end
end

function BossFamilyView:FlushRemainCount()
	local boss_data = BossData.Instance
	local boss_id_list = boss_data:GetBossFamilyIdList()
	local text = ""
	for k,v in pairs(boss_id_list) do
		local count = boss_data:GetBossFamilyRemainEnemyCount(v, self.select_scene_id)
		if count <= 0 then
			text = ToColorStr(tostring(count), TEXT_COLOR.RED)
		else
			text = ToColorStr(tostring(count), TEXT_COLOR.GREEN)
		end
		self.remain_count_text_list[k]:SetValue(text)
	end
end

function BossFamilyView:ClickBoss(layer)
	self.num = 0
	if self.layer == layer then
		return
	end
	for k,v in pairs(BossData.Instance:GetBossFamilyListClient()) do
		if layer == k then
			local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
			if not can_go then
				local level_text = PlayerData.GetLevelString(min_level)
				local text = string.format(Language.Boss.BossLimit, level_text)
				TipsCtrl.Instance:ShowSystemMsg(text)
				return
			end
			self.select_clent_scene_id = v.scene_id
			local boss_list = BossData.Instance:GetBossFamilyList(self.select_clent_scene_id, true)
			self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10
			self.is_cross = boss_list[1] and boss_list[1].is_cross or 0
			if self.is_cross == 1 then
				self.select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_clent_scene_id) or 0
			else
				self.select_scene_id = self.select_clent_scene_id
			end
			break
		end
	end
	local vip_level = BossData.Instance:GetBossVipLismit(self.select_clent_scene_id)
	local my_vip = GameVoManager.Instance:GetMainRoleVo().vip_level
	local vip_text = Language.Common.VIP..vip_level
	if my_vip < vip_level then
		vip_text = ToColorStr(vip_text, TEXT_COLOR.RED)
	end
	self.vip_limit:SetValue(vip_text)
	self.layer = layer
	self:FlushBossList()
	self:FlushToggleHL()
	self:FlushPanel()
	self:FlushAllHL()
end

function BossFamilyView:FlushFocusState()
	self.focus_toggle.toggle.isOn = BossData.Instance:BossIsFollow(self.select_boss_id)
end

function BossFamilyView:OpenEquipCompose()
	ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_equip)
end

function BossFamilyView:ClickBuy()
	local money_num = BossData.Instance:GetMobeyNum() or 0

	local yes_func = function()
		BossCtrl.SendBossFamilyOperate(BOSS_FAMILY_OPERATE_TYPE.BOSS_FAMILY_BUY_GATHER_TIMES, 1)
	end

	local text = string.format(Language.Common.BuyNum, money_num)
	TipsCtrl.Instance:ShowCommonAutoView("", text, yes_func)
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

function BossFamilyView:FlushBossList()
	self.num = 0
	local boss_list = BossData.Instance:GetBossFamilyList(self.select_clent_scene_id, true)
	self.boss_data = {}
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			local next_refresh_time = BossData.Instance:GetFamilyBossRefreshTime(boss_list[i].bossID, boss_list[i].scene_id)
			if not (next_refresh_time > TimeCtrl.Instance:GetServerTime()) then
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

function BossFamilyView:FlushReward()
	self.reward_data = BossData.Instance:GetBossFamilyFallList(self.select_boss_id)
	self.reward_list.scroller:ReloadData(0)
end

function BossFamilyView:FlushPanel()
	local boss_data = BossData.Instance
	local max_wearry = boss_data:GetMikuBossMaxWeary()
	local x = boss_data:GetMikuBossWeary()
	local weary = max_wearry - (x + boss_data:GetBuyMiKuWearyCount())
    local pi_lao_text = ""
	if weary <= 0 then
		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
	else
		pi_lao_text = tostring(weary)
	end
	local max_text = tostring(max_wearry)
	self.pi_lao:SetValue(pi_lao_text .. " / " .. max_text)
	self:FlushModel()
end

function BossFamilyView:FlushBossView(prarm_t)
	self.select_index = 1
	if self.is_first == true then
		local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
		if -1 ~= BossView.CACHE_LAYER_INDEX then
			index = BossView.CACHE_LAYER_INDEX
			BossView.CACHE_LAYER_INDEX = -1
		end

		self.is_first = false
		self:ClickBoss(index)
	end
	self:InitFloorList()
	self.toggle_list.scroller:ReloadData(self.layer > 1 and self.layer / #self.floor_list or 0)

	local boss_list = BossData.Instance:GetBossFamilyList(self.select_clent_scene_id, true)
	self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10
	self.is_cross = boss_list[1] and boss_list[1].is_cross or 0
	if self.is_cross == 1 then
		self.select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_clent_scene_id) or 0
	else
		self.select_scene_id = self.select_clent_scene_id
	end
	self:FlushBossList()
	self:FlushFocusState()
	self:FlushReward()
	self:FlushPanel()
	self:FlushGatherNum()
end

function BossFamilyView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function BossFamilyView:GetSelectIndex()
	return self.select_index or 1
end

function BossFamilyView:SetSelectBossId(boss_id, is_cross)
	self.select_boss_id = boss_id
	self.is_cross = is_cross
	if self.is_cross == 1 then
		self.select_scene_id = BossData.Instance:GetBossFamilyKfScene(self.select_clent_scene_id) or 0
	else
		self.select_scene_id = self.select_clent_scene_id
	end
end

function BossFamilyView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function BossFamilyView:InitFloorList()
	self.scene_num = #BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY]
	self.now_index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY)
	self.floor_list = BossData.Instance:GetBossFloorList(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY ,SHOW_FLOOR)
end

function BossFamilyView:GetToggleListNumOfCells()
	local list = BossData.Instance:GetBossFloorList(BOSS_ENTER_TYPE.TYPE_BOSS_FAMILY ,SHOW_FLOOR)
	return #list
end

function BossFamilyView:ToggleRefreshView(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.togglecell_list[cell]
	if not toggle_cell then
		toggle_cell = FamilyBossToggle.New(cell.gameObject)
		self.togglecell_list[cell] = toggle_cell
		toggle_cell.boss_view = self
	end
	toggle_cell:SetIndex(data_index, self.floor_list)
	toggle_cell:Flush()
	toggle_cell:SetToggleState(self.layer)
end

function BossFamilyView:FlushGatherNum()
	local info = BossData.Instance:GetMikuBossInfo() or {}
	local num = info.boss_family_left_gather_times or 0
	local gather_times = BossData.Instance:GetMikuBossNum() or 0
	self.wajue_num:SetValue(num .. "/" .. gather_times)
end
-------------------------------------------------------------------------
BossFamilyItemCell = BossFamilyItemCell or BaseClass(BaseCell)

function BossFamilyItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.icon_image = self:FindVariable("icon_image")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.level = self:FindVariable("Level")
	self.show_hl = self:FindVariable("show_hl")
	self.show_limit = self:FindVariable("show_limit")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.canKill = self:FindVariable("canKill")
	self.show_labelrare = self:FindVariable("show_label_rare")
	self.show_labelkf = self:FindVariable("show_label_kuafu")
	self.wajue_num = self:FindVariable("wajuenum")
	self.shownum = self:FindVariable("is_shownum")
	self.index = 0

	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function BossFamilyItemCell:__delete()
	self.show_labelkf:SetValue(false)
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	self.root_node = nil
end

function BossFamilyItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID, self.data.is_cross)
		self.boss_view:FlushFocusState()
		self.boss_view:FlushAllHL()
		self.boss_view:FlushReward()
--		self.boss_view:FlushBossList()
		self.boss_view:FlushPanel()
		if self.data == nil or select_index == self.index then
			return
		end
	end
end

function BossFamilyItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.canKill:SetValue(true)
		local bundele2,asset1 = ResPath.GetBossItemIcon(monster_cfg.headid)
		self.icon_image:SetAsset(bundele2, asset1)
		if BOSS_TYPE_INFO.RARE == monster_cfg.boss_type or self.data.is_cross == 1 then
			if self.data.is_cross == 1 then
				self.show_labelkf:SetValue(true)
				self.show_labelrare:SetValue(false)
			else
				self.show_labelrare:SetValue(true)
				self.show_labelkf:SetValue(false)
			end
			local bundle, asset = ResPath.GetBoss("bg_rare_01")
			self.icon:SetAsset(bundle, asset)
		else
			self.show_labelrare:SetValue(false)
			self.show_labelkf:SetValue(false)
			local bundle, asset = ResPath.GetBoss("bg_rare_02")
			self.icon:SetAsset(bundle, asset)
		end
	end
	local num = BossData.Instance:GetFamilyBossGatherTime(self.data.bossID, self.data.scene_id)
	if num > 0 then
		self.wajue_num:SetValue(string.format(Language.Boss.GatherNum,num))
		self.shownum:SetValue(true)
	else
		self.shownum:SetValue(false)
	end

	self.next_refresh_time = BossData.Instance:GetFamilyBossRefreshTime(self.data.bossID, self.data.scene_id)
	self.iskill:SetValue(self.next_refresh_time > TimeCtrl.Instance:GetServerTime())
	if self.next_refresh_time > TimeCtrl.Instance:GetServerTime() then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self:OnBossUpdate()
		self.image_gray_scale:SetValue(false)
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(Language.Boss.HadFlush)
	end
	self:FlushHL()
end

function BossFamilyItemCell:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.time:SetValue(Language.Boss.HadFlush)
	else
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function BossFamilyItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
	self.show_limit:SetValue(false)
end

function BossFamilyItemCell:IsKill()
	return self.next_refresh_time > TimeCtrl.Instance:GetServerTime()
end


----------------------------------------------------------------------
FamilyBossRewardCell = FamilyBossRewardCell or BaseClass(BaseCell)

function FamilyBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
	self.boss_id = 0
end

function FamilyBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function FamilyBossRewardCell:OnFlush()
	if nil == self.data then
		return
	end

	local item_id = self.data.item_id
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.boss_id]
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)
	if monster_cfg and item_cfg and item_cfg.color == GameEnum.ITEM_COLOR_RED and big_type == GameEnum.ITEM_BIGTYPE_EQUIPMENT then   -- 红色装备写死3星
		--精英BOSS强制3星展示
		self.rew_cell:SetData(BossData.Instance:GetShowEquipItemList(item_id, BOSS_TYPE_INFO.RARE))
		self.rew_cell:NotShowStar()
		self.rew_cell:SetShowStar(4)
	else
		self.rew_cell:SetData({item_id = item_id})
	end
end

function FamilyBossRewardCell:SetBossID(index)
	self.boss_id = index
end


--toggle展示
FamilyBossToggle = FamilyBossToggle or BaseClass(BaseCell)

function FamilyBossToggle:__init()
	self.floor_index = 0
	self.list_toggle = {}
	self.toggle_index = 0
	self.text = self:FindVariable("Floor_Text")
	self.show_hl = self:FindVariable("Show_Hl")
	self:ListenEvent("ClickToggle", BindTool.Bind(self.ClickToggle, self))
end

function FamilyBossToggle:__delete()

end

function FamilyBossToggle:ClickToggle()
	self.boss_view:ClickBoss(self.toggle_index)
end

function FamilyBossToggle:SetIndex(index, list)
	self.index = index
	self.list_toggle = list
end

function FamilyBossToggle:OnFlush()
	self:SwitchScene()
end

function FamilyBossToggle:SetToggleState(index)
	self.show_hl:SetValue(self.toggle_index == index)
end

function FamilyBossToggle:SwitchScene()
	self.text:SetValue(string.format(Language.Boss.Floor, self.list_toggle[self.index]))
	self.toggle_index = self.list_toggle[self.index]
end