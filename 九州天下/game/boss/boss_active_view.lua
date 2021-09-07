BossActiveView = BossActiveView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2

function BossActiveView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 9040
	self.item_cell = {}
	self.boss_data = {}
	self.cell_list = {}
	self.layer = 1
end

function BossActiveView:LoadCallBack()	
	self.select_boss_id = BossData.Instance:GetActiveBossList(self.select_scene_id)[1].bossID	
	for i = 1, 8 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("Item" .. i))
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	self.boss_name = self:FindVariable("BossName")
	self.enter_limit = self:FindVariable("EnterLimit")
	self.enter_btn_name = self:FindVariable("EnterBtnName")
	-- self.enter_btn_gray = self:FindVariable("EnterBtnGray")

	self.remain_count_text_list = {}
	for i=1,3 do
		self.remain_count_text_list[i] = self:FindVariable("RemainCountText" .. i)
	end

	self.boss_list = self:FindObj("BossList")

	self.list_view_delegate = self.boss_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.show_hl_list = {}
	for i=1,5 do
		self:ListenEvent("ClickScene"..i, BindTool.Bind(self.ClickScene, self, i))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
	end
	self:ListenEvent("ToActtack",
		BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick",
		BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenBossInfo",
		BindTool.Bind(self.OpenBossInfo, self))
	self:ListenEvent("OpenKillRecord",
		BindTool.Bind(self.OpenKillRecord, self))
	self:ListenEvent("OpenItemInfo",
		BindTool.Bind(self.OpenItemInfo, self))
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_boss = self:FindVariable("ShowBoss")
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New()
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

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end

	self.item_cell = {}
end

function BossActiveView:ClickScene(layer, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetActiveSceneList()) do
			if layer == k then
				local can_go, min_level = BossData.Instance:GetCanToSceneLevel(v)
				if not can_go then
					local lv1, zhuan1 = PlayerData.GetLevelAndRebirth(min_level)
					local level_text = string.format(Language.Common.ZhuanShneng, lv1, zhuan1)
					local text = string.format(Language.Boss.BossLimit, level_text)
					TipsCtrl.Instance:ShowSystemMsg(text)
					return
				end
				self.select_scene_id = v
				break
			end
		end
		self.layer = layer
		self:FlushBossView()
		self:FlushToggleHL()
	end
end

function BossActiveView:FlushToggleHL()
	for i=1,5 do
		self.show_hl_list[i]:SetValue(i == self.layer)
	end
end

function BossActiveView:OpenBossView()
	self.select_scene_id = 9040
	self:FlushBossView()
end

function BossActiveView:FlushBossRemainCount()
	for i=1,3 do
		self.remain_count_text_list[i]:SetValue("2")
	end
end

function BossActiveView:CloseBossView()
	self.select_index = 1
end

function BossActiveView:GetNumberOfCells()
	return #BossData.Instance:GetActiveBossList(self.select_scene_id) or 0
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
	if boss_data:CanGoActiveBoss(self.select_scene_id) then
		boss_data:SetCurInfo(self.select_scene_id, self.select_boss_id)
		ViewManager.Instance:CloseAll()
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_scene_id, 1)
	else
		local _a, _b, enter_item, _d = BossData.Instance:GetBossVipLismit(self.select_scene_id)
		local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[enter_item]
		if item_cfg == nil then
			TipsCtrl.Instance:ShowItemGetWayView(enter_item)
			return
		end

		-- if item_cfg.bind_gold == 0 then
		-- 	TipsCtrl.Instance:ShowShopView(enter_item, 2)
		-- 	return
		-- end

		local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
		end

		TipsCtrl.Instance:ShowCommonBuyView(func, enter_item, nil, 1)
		return
	end
end

function BossActiveView:QuestionClick()
	local tips_id = 160
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function BossActiveView:OpenItemInfo()
	self.show_panel:SetValue(true)
	self.show_boss:SetValue(false)
end

function BossActiveView:OpenBossInfo()
	self.show_panel:SetValue(false)
	self.show_boss:SetValue(true)
	self:FlushModel()
end

function BossActiveView:FlushModel()
	if self.model_view == nil then
		return
	end
	if self.model_display.gameObject.activeInHierarchy then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			self.model_view:SetMainAsset(ResPath.GetMonsterModel(monster_cfg.resid))
			self.model_view:SetModelTransformParameter(DISPLAY_MODEL_TYPE[DISPLAY_TYPE.MONSTER], monster_cfg.resid, DISPLAY_PANEL.FULL_PANEL)
			self.model_view:SetTrigger("attack1")
		end
	end
end

function BossActiveView:OpenKillRecord()
	BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_ACTIVE, self.select_boss_id, self.select_scene_id)
end

function BossActiveView:FlushItemList()
	local item_list = BossData.Instance:GetActiveBossRewards(self.select_boss_id)
	for k, v in ipairs(self.item_cell) do
		if item_list[k] then
			local data = ItemData.Instance:GetItemConfig(item_list[k])
			data.item_id = item_list[k]
			v:SetData(data)
		else
			v:SetData(nil)
		end
	end
end

function BossActiveView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			self.boss_name:SetValue(monster_cfg.name)
		end
		self:FlushItemList()
		local _a, _b, item_id, num = BossData.Instance:GetBossVipLismit(self.select_scene_id)
		local my_count = ItemData.Instance:GetItemNumInBagById(item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		if my_count >= num then
			self.enter_limit:SetValue(item_cfg.name .. ToColorStr(tostring(cost), TEXT_COLOR.GREEN))
		else
			self.enter_limit:SetValue(item_cfg.name .. ToColorStr(tostring(cost), TEXT_COLOR.RED))
		end
		self.enter_btn_name:SetValue(Language.Boss.EnterBtnName[1])
		self:FlushModel()
	end
end

function BossActiveView:FlushBossList()
	local boss_list = BossData.Instance:GetActiveBossList(self.select_scene_id)
	if #boss_list > 0 then
		for i = 1, #boss_list do
			self.boss_data[i] = boss_list[i]
		end
		self.select_boss_id = boss_list[1].bossID
	end
	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function BossActiveView:OnFlush()
	self:FlushBossView()
end

function BossActiveView:FlushBossView()
	self.select_index = 1
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushBossRemainCount()
	self:FlushToggleHL()
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

function BossActiveView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end
----------------------------------------------------------------------
ActiveBossItemCell = ActiveBossItemCell or BaseClass(BaseCell)

function ActiveBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.show_hl = self:FindVariable("show_hl")
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

		local bundle, asset = ResPath.GetBossView(monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	local reflash_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
	if reflash_time > 0 then
		if nil == self.time_coundown then
			self.time_coundown = GlobalTimerQuest:AddTimesTimer(
					BindTool.Bind(self.OnBossUpdate, self), 1, reflash_time - TimeCtrl.Instance:GetServerTime())
				self:OnBossUpdate()
		end
		self:OnBossUpdate()
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
	else
		if self.time_coundown then
			GlobalTimerQuest:CancelQuest(self.time_coundown)
			self.time_coundown = nil
		end
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	end
	self:FlushHL()
end

function ActiveBossItemCell:OnBossUpdate()
	local reflash_time = BossData.Instance:GetActiveStatusByBossId(self.data.bossID, self.data.scene_id)
	local time = math.max(0, reflash_time - TimeCtrl.Instance:GetServerTime())
	if time <= 0 then
		self.iskill:SetValue(false)
		self.image_gray_scale:SetValue(true)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	else
		self.iskill:SetValue(true)
		self.image_gray_scale:SetValue(false)
		self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time,3), TEXT_COLOR.RED))
	end
end

function ActiveBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end