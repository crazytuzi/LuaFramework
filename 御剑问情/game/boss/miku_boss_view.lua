MikuBossView = MikuBossView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2
local SHOW_FLOOR = 4 --显示层数

function MikuBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 9010
	self.select_boss_id = 10
	self.scroll_change = false 			--记录画布是否在滚动中
	self.layer = 0
	self.boss_data = {}
	self.cell_list = {}
	self.rew_list = {}
	self.togglecell_list = {}

	self.scene_num = 0
	self.now_index = 0
	self.floor_list = {}

	self.reward_data = BossData.Instance:GetMikuBossFallList(self.select_boss_id)

	--引导用按钮
	self.fatigue_guide = self:FindObj("FatigueGuide")
	self.num = 0
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")

	self.pi_lao = self:FindVariable("pi_lao")
	self.pi_lao_buy_text = self:FindVariable("pi_lao_buy_text")
	self.remain_count_text_list = {}
	for i=1, 3 do
		self.remain_count_text_list[i] = self:FindVariable("remain_count_text_" .. i)
	end
	self.focus_toggle = self:FindObj("focus_toggle")
	self.boss_list = self:FindObj("BossList")
	self.turntable_info = TurntableInfoCell.New(self:FindObj("Turntable"))
	self.list_view_delegate = self.boss_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

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
	self:ListenEvent("FocusOnClick",
		BindTool.Bind(self.FocusOnClick, self))
	self:ListenEvent("BuyPiLaoClick",
		BindTool.Bind(self.BuyPiLaoClick, self))
	self:ListenEvent("OpenEquipCompose",
		BindTool.Bind(self.OpenEquipCompose, self))

	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New("boss_panel")
	self.model_view:SetDisplay(self.model_display.ui3d_display)
	self.old_res_id =nil
	self.money_image = self:FindVariable("MoneyImage")
	self.show_equip_compose = self:FindVariable("ShowEquipCompose")
	self.add_remind = self:FindVariable("addremind")
	self.add_remind:SetValue(BossData.Instance:GetMiKuSmallRemindFlag())

end

function MikuBossView:__delete()
	self:RemoveDelayBossTime()
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

	self.nowpanelboss_num = nil
	self.turntable_info:DeleteMe()
	self.turntable_info = nil
end

function MikuBossView:CloseBossView()
	self.select_index = 1
	BossData.Instance:SetBossLayer(-1)
end

function MikuBossView:GetNumberOfCells()
	return GetListNum(self.boss_data)
end

function MikuBossView:GetRewardNumberOfCells()
	return GetListNum(self.reward_data)
end

function MikuBossView:GetToggleListNumOfCells()
	local list = BossData.Instance:GetBossFloorList(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU ,SHOW_FLOOR)
	return #list
end

function MikuBossView:ToggleRefreshView(cell, data_index)
	data_index = data_index + 1
	local toggle_cell = self.togglecell_list[cell]
	if not toggle_cell then
		toggle_cell = MiKuBossToggle.New(cell.gameObject)
		self.togglecell_list[cell] = toggle_cell
		toggle_cell.boss_view = self
	end
	toggle_cell:SetIndex(data_index, self.floor_list)
	toggle_cell:Flush()
	toggle_cell:SetToggleState(self.layer)
end

function MikuBossView:ReRewardfreshView(cell, data_index)

	data_index = data_index + 1
	local reward_cell = self.rew_list[cell]
	if not reward_cell then
		reward_cell = MiKuBossRewardCell.New(cell.gameObject)
		self.rew_list[cell] = reward_cell
	end
	reward_cell:SetIndex(data_index)
	reward_cell:SetBossID(self.select_boss_id)
	reward_cell:SetData(self.reward_data[data_index])
end

function MikuBossView:RefreshView(cell, data_index)
	data_index = data_index + 1
	self:FlushInfoList()
	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = MikuBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
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
	ViewManager.Instance:CloseAll()
	BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
	BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU, self.select_scene_id, 0, self.select_boss_id)
end

function MikuBossView:InitFloorList()
	self.scene_num = #BOSS_SCENE_LIST[BOSS_ENTER_TYPE.TYPE_BOSS_MIKU]
	self.now_index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	self.floor_list = BossData.Instance:GetBossFloorList(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU ,SHOW_FLOOR)
end

function MikuBossView:OpenKillRecord()
	ViewManager.Instance:Open(ViewName.Boss, TabIndex.drop)
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

function MikuBossView:OpenEquipCompose()
	ViewManager.Instance:Open(ViewName.Compose, TabIndex.compose_equip)
end

function MikuBossView:BuyPiLaoClick()
	local old_remind = BossData.Instance:GetMiKuSmallRemindFlag()
	BossData.Instance:SetMiKuSmallRemindFlag(false)
	if old_remind then
		ViewManager.Instance:FlushView(ViewName.Boss)
	end
	self.add_remind:SetValue(BossData.Instance:GetMiKuSmallRemindFlag())
    local can_buy_count = VipData.Instance:GetVipPowerList(15)[VIPPOWER.BUY_DABAO_COUNT]
    if BossData.Instance:GetBuyMiKuWearyCount() < can_buy_count then
		if BossData.Instance:GetCanBuyMikuWearry() then
			if ItemData.Instance:GetItemNumInBagById(GameEnum.PILAO_CARD) > 0 then
				local describe = Language.Boss.BossConsumePiLaoCard
				local call_back = function ()
					BossCtrl.SendBossFamilyOperate(BOSS_FAMILY_OPERATE_TYPE.BOSS_FAMILY_BUY_MIKU_WEARY)
					BossData.Instance:ChangeOpenMiKu()
				end
				TipsCtrl.Instance:ShowCommonAutoView("BuyPiLao", describe, call_back, nil, nil)

				return
			end
			local gold = GameVoManager.Instance:GetMainRoleVo().gold
			local buy_weary_gold = BossData.Instance:GetBuyWearyGold()
			if gold >= buy_weary_gold then
				local describe = string.format(Language.Boss.BossBuyPiLao, ToColorStr(tostring(buy_weary_gold), TEXT_COLOR.BLUE_SPECIAL))
				local call_back = function ()
					BossCtrl.SendBossFamilyOperate(BOSS_FAMILY_OPERATE_TYPE.BOSS_FAMILY_BUY_MIKU_WEARY)
				end
				TipsCtrl.Instance:ShowCommonAutoView("BuyPiLao", describe, call_back, nil, nil)
			else
				TipsCtrl.Instance:ShowLackDiamondView()
			end
		else
			TipsCtrl.Instance:ShowLockVipView(VIPPOWER.BUY_DABAO_COUNT)
		end
	else
		TipsCtrl.Instance:ShowSystemMsg(Language.Boss.BossBuyPiLaoLimit)
	end
	BossData.Instance:ChangeOpenMiKu()
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

	local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
	if res_id == self.old_res_id then
		return
	else
		self.old_res_id = res_id
	end
	local display_name = BossData.Instance:DisplayName(res_id)
	self.model_view:SetPanelName(display_name)
	self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
	self.model_view:SetTrigger("rest1")

end

function MikuBossView:FlushToggleHL()
	for k, v in pairs(self.togglecell_list) do
		v:SetToggleState(self.layer)
	end
end


function MikuBossView:ClickBoss(layer)
	if self.layer == layer then
		return
	end

	self.num = 0
	for k,v in pairs(BossData.Instance:GetMikuBossListClient()) do
		if layer == k then
			local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v.scene_id)
			if not can_go then
				local level_text = PlayerData.GetLevelString(min_level)
				local text = string.format(Language.Boss.BossLimit, level_text)
				TipsCtrl.Instance:ShowSystemMsg(text)
				return
			end
			self.select_scene_id = v.scene_id
			local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
			self.select_boss_id = boss_list[1] and boss_list[1].bossID or 10
		end
	end
	self.select_index = 1
	self.layer = layer
	self:FlushInfoList()
	self:FlushBossList()
	self:FlushToggleHL()
	self:FlushReward()
	self:FlushFocusState()
	if BossData.Instance:GetSelectIndexFlag() then
		self.select_index = self:JumpIndex(layer)
		self:RemoveDelayBossTime()
		self.boss_timer = GlobalTimerQuest:AddDelayTimer(function() self:ListJumpToIndex() end, 0.1)
		BossData.Instance:SetSelectIndexFlag(false)
	end
end

function MikuBossView:RemoveDelayBossTime()
	if self.boss_timer then
		GlobalTimerQuest:CancelQuest(self.boss_timer)
		self.boss_timer = nil
	end
end

function MikuBossView:ListJumpToIndex()
	self.boss_list.scroller:JumpToDataIndex(self.select_index - 1)
	self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
end

function MikuBossView:JumpIndex(layer)
	local layer = layer or 1
	local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	local main_role_lv = GameVoManager.Instance:GetMainRoleVo().level
	for i=#boss_list,1,-1 do
		local monster_level = BossData.Instance:GetMonsterInfo(boss_list[i].bossID).level
		if monster_level < main_role_lv then
			return i
		end
	end
	return 1
end


function MikuBossView:FlushRemainCount()
	local boss_data = BossData.Instance
	local boss_id_list = boss_data:GetBossMikuIdList()
	local text = ""
	for k,v in pairs(boss_id_list) do
		local count = boss_data:GetBossMikuRemainEnemyCount(v, self.select_scene_id)
		if count <= 0 then
			text = ToColorStr(tostring(count), TEXT_COLOR.RED)
		else
			text = ToColorStr(tostring(count), TEXT_COLOR.GREEN)
		end
		self.remain_count_text_list[k]:SetValue(text)
	end
end

function MikuBossView:FlushInfoList()
	local boss_data = BossData.Instance
	local max_wearry = boss_data:GetMikuBossMaxWeary()
	local x = boss_data:GetMikuBossWeary()
	local weary = max_wearry - (x + boss_data:GetBuyMiKuWearyCount())
	local pilao_card_num = ItemData.Instance:GetItemNumInBagById(GameEnum.PILAO_CARD)
	if pilao_card_num > 0 then
        self.money_image:SetAsset(ResPath.GetItemIcon(GameEnum.PILAO_CARD))
        self.pi_lao_buy_text:SetValue("×".. pilao_card_num)
    else
    	self.money_image:SetAsset(ResPath.GetCurrencyIcon("diamond"))
		local buy_weary_gold = BossData.Instance:GetBuyWearyGold()
		self.pi_lao_buy_text:SetValue(buy_weary_gold)
    end
    local pi_lao_text = ""
	if weary <= 0 then
		pi_lao_text = ToColorStr(tostring(weary), TEXT_COLOR.RED)
	else
		pi_lao_text = tostring(weary)
	end
	local max_text = tostring(max_wearry)
	self.pi_lao:SetValue(pi_lao_text .. " / " .. max_text)
	if self.select_boss_id ~= 0 then
		self:FlushModel()

		--处理装备合成按钮
		local monster_cfg = BossData.Instance:GetMonsterInfo(self.select_boss_id)
		if monster_cfg then
			local other_cfg = BossData.Instance:GetOtherCfg()
			if monster_cfg.level <= other_cfg.eq_compose_limit then
				self.show_equip_compose:SetValue(true)
			else
				self.show_equip_compose:SetValue(false)
			end
		else
			self.show_equip_compose:SetValue(false)
		end
	end
end

function MikuBossView:FlushBossList()
	self.num = 0
	local boss_list = BossData.Instance:GetMikuBossList(self.select_scene_id)
	if nil ~= boss_list and #boss_list > 0 then
		self.boss_data = {}
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
			self.next_refresh_time = BossData.Instance:GetMikuBossRefreshTime(boss_list[i].bossID, self.select_scene_id)
			local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
			if diff_time <= 0 then
				self.num = self.num + 1
			end
		end
		self.nowpanelboss_num:SetValue(self.num.." / "..#boss_list)
	end

	self.boss_list.scroller:ReloadData(0)
end

function MikuBossView:FlushReward()
	self.reward_data = BossData.Instance:GetMikuBossFallList(self.select_boss_id)
	self.reward_list.scroller:ReloadData(0)
end

function MikuBossView:FlushBossView()
	self:InitFloorList()
	local index = BossData.Instance:GetCanGoLevel(BOSS_ENTER_TYPE.TYPE_BOSS_MIKU)
	if -1 ~= BossView.CACHE_LAYER_INDEX then
		index = BossView.CACHE_LAYER_INDEX
		BossView.CACHE_LAYER_INDEX = -1
	end

	self:ClickBoss(index)
	self.toggle_list.scroller:ReloadData(self.layer > 1 and self.layer / #self.floor_list or 0)
	self.reward_data = BossData.Instance:GetMikuBossFallList(self.select_boss_id)
	self:FlushBoss()
end

function MikuBossView:FlushBoss()
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushReward()
	self:FlushModel()
	self:FlushFocusState()
	self.turntable_info:SetShowEffect(WelfareData.Instance:GetTurnTableRewardCount() ~= 0)

	--处理装备合成按钮
	local monster_cfg = BossData.Instance:GetMonsterInfo(self.select_boss_id)
	if monster_cfg then
		local other_cfg = BossData.Instance:GetOtherCfg()
		if monster_cfg.level <= other_cfg.eq_compose_limit then
			self.show_equip_compose:SetValue(true)
		else
			self.show_equip_compose:SetValue(false)
		end
	else
		self.show_equip_compose:SetValue(false)
	end
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
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end
------------------------------------------------------------------------------
MikuBossItemCell = MikuBossItemCell or BaseClass(BaseCell)

function MikuBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.level = self:FindVariable("Level")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.show_hl = self:FindVariable("show_hl")
	self.show_limit = self:FindVariable("show_limit")
	self.canKill = self:FindVariable("canKill")
	self.show_labelrare = self:FindVariable("show_label_rare")
	self.icon_image = self:FindVariable("icon_image")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function MikuBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	if self.boss_view then
		self.boss_view = nil
	end
end

function MikuBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:FlushReward()
		self.boss_view:FlushAllHL()
		self.boss_view:FlushFocusState()
		if self.data == nil or select_index == self.index then
			return
		end
		self.boss_view:FlushInfoList()
	end
end

function MikuBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = BossData.Instance:GetMonsterInfo(self.data.bossID)
	if monster_cfg then
		local bundele2,asset1 = ResPath.GetBossItemIcon(monster_cfg.headid)
		self.icon_image:SetAsset(bundele2, asset1)
		self.boss_name:SetValue(monster_cfg.name)
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.canKill:SetValue(true)
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
	self.next_refresh_time = BossData.Instance:GetMikuBossRefreshTime(self.data.bossID, self.data.scene_id)
	local diff_time = self.next_refresh_time - TimeCtrl.Instance:GetServerTime()
	if diff_time <= 0 then
		self.iskill:SetValue(false)
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.time:SetValue(Language.Boss.HadFlush)
		self.image_gray_scale:SetValue(true)
	else
		self.iskill:SetValue(true)
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
				BindTool.Bind(self.OnBossUpdate, self), 1, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
			self:OnBossUpdate()
		end
		self:OnBossUpdate()
		self.image_gray_scale:SetValue(false)
	end
	self:FlushHL()

end

function MikuBossItemCell:OnBossUpdate()
	local time = math.max(0, self.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED))
	if time <= 0 then
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.ORANGE_4))
	else
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time), TEXT_COLOR.RED))
	end
end

function MikuBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

----------------------------------------------------------------------
MiKuBossRewardCell = MiKuBossRewardCell or BaseClass(BaseCell)

function MiKuBossRewardCell:__init()
	self.rew_cell = ItemCell.New()
	self.rew_cell:SetInstanceParent(self.root_node)
	self.boss_id = 0
end

function MiKuBossRewardCell:__delete()
	if self.rew_cell then
		self.rew_cell:DeleteMe()
		self.rew_cell = nil
	end
end

function MiKuBossRewardCell:OnFlush()
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
		self.rew_cell:SetShowStar(1)
	else
		self.rew_cell:SetData({item_id = item_id})
	end
end

function MiKuBossRewardCell:SetBossID(index)
	self.boss_id = index
end


--toggle展示
MiKuBossToggle = MiKuBossToggle or BaseClass(BaseCell)

function MiKuBossToggle:__init()
	self.floor_index = 0
	self.list_toggle = {}
	self.toggle_index = 0
	self.text = self:FindVariable("Floor_Text")
	self.show_hl = self:FindVariable("Show_Hl")
	self:ListenEvent("ClickToggle", BindTool.Bind(self.ClickToggle, self))
end

function MiKuBossToggle:__delete()

end

function MiKuBossToggle:ClickToggle()
	self.boss_view:ClickBoss(self.toggle_index)
end

function MiKuBossToggle:SetIndex(index, list)
	self.index = index
	self.list_toggle = list
end

function MiKuBossToggle:OnFlush()
	self:SwitchScene()
end

function MiKuBossToggle:SetToggleState(index)
	self.show_hl:SetValue(self.toggle_index == index)
end

function MiKuBossToggle:SwitchScene()
	self.text:SetValue(string.format(Language.Boss.Floor, self.list_toggle[self.index]))
	self.toggle_index = self.list_toggle[self.index]
end