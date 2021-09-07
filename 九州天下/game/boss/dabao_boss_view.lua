DabaoBossView = DabaoBossView or BaseClass(BaseRender)

local PageUp = 1
local PageDown = 2

function DabaoBossView:__init()
	self.select_index = 1
	self.select_monster_res_id = 0
	self.select_scene_id = 9020
	self.select_boss_id = BossData.Instance:GetDaBaoBossList(self.select_scene_id)[1].bossID
	self.boss_data = {}
	self.cell_list = {}
	self.layer = 1
	self.item_cell = {}
	self.remain_count_text_list = {}
	self.show_hl_list = {}
end

function DabaoBossView:__delete()
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

	for k, v in ipairs(self.item_cell) do
		v:DeleteMe()
	end
	self.item_cell = {}
end

function DabaoBossView:LoadCallBack()
	for i = 1, 8 do
		local item = ItemCell.New(self:FindObj("Item" .. i))
		item:SetData(nil)
		table.insert(self.item_cell, item)
	end

	self.boss_name = self:FindVariable("BossName")
	self.enter_limit = self:FindVariable("EnterLimit")
	self.enter_btn_name = self:FindVariable("EnterBtnName")
	self.enter_btn_gray = self:FindVariable("EnterBtnGray")
	self.show_diamond = self:FindVariable("ShowDiamond")

	for i=1,3 do
		self.remain_count_text_list[i] = self:FindVariable("RemainCountText" .. i)
	end

	self.boss_list = self:FindObj("BossList")

	self.list_view_delegate = self.boss_list.list_simple_delegate
	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	for i=1,5 do
		self:ListenEvent("ClickScene"..i, BindTool.Bind(self.ClickScene, self, i))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
	end
	self:ListenEvent("ToActtack", BindTool.Bind(self.ToActtack, self))
	self:ListenEvent("QuestionClick", BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenBossInfo", BindTool.Bind(self.OpenBossInfo, self))
	self:ListenEvent("OpenKillRecord", BindTool.Bind(self.OpenKillRecord, self))
	self:ListenEvent("OpenItemInfo", BindTool.Bind(self.OpenItemInfo, self))
	self.show_panel = self:FindVariable("ShowPanel")
	self.show_boss = self:FindVariable("ShowBoss")
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.model_display.ui3d_display)
end

function DabaoBossView:ClickScene(layer, is_click)
	if is_click then
		for k,v in pairs(BossData.Instance:GetDabaoBossClientCfg()) do
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
				break
			end
		end
		self.layer = layer
		self:FlushBossView()
		self:FlushToggleHL()
	end
end

function DabaoBossView:FlushToggleHL()
	for i=1,5 do
		self.show_hl_list[i]:SetValue(i == self.layer)
	end
end

function DabaoBossView:OpenBossView()
	self.select_scene_id = 9020
	self:FlushBossView()
end

function DabaoBossView:FlushBossRemainCount()
	for i=1,3 do
		self.remain_count_text_list[i]:SetValue("2")
	end
end

function DabaoBossView:CloseBossView()
	self.select_index = 1
	-- self.select_boss_id = 10
end

function DabaoBossView:GetNumberOfCells()
	return #BossData.Instance:GetDaBaoBossList(self.select_scene_id) or 0
end

function DabaoBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = DabaoBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function DabaoBossView:ToActtack()
	if not BossData.Instance:GetCanGoAttack() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Map.TransmitLimitTip)
		return
	end
	if self.select_scene_id == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Boss.SelectBoss)
		return
	end
	local enter_count = BossData.Instance:GetDabaoBossCount()
	local max_count = BossData.Instance:GetDabaoFreeTimes()
	if enter_count >= max_count and BossData.Instance:GetDabaoEnterGold(enter_count - max_count) then
		local cost = BossData.Instance:GetDabaoEnterGold(enter_count - max_count)
		local func = function()
			BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
			ViewManager.Instance:CloseAll()
			BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
		end
		TipsCtrl.Instance:ShowCommonAutoView(nil, string.format(Language.Boss.BuyEnterDabao, cost), func, nil, true)
		return
	else
		BossData.Instance:SetCurInfo(self.select_scene_id, self.select_boss_id)
		ViewManager.Instance:CloseAll()
		BossCtrl.SendEnterBossFamily(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_scene_id, 1)
	end
end

function DabaoBossView:QuestionClick()
	local tips_id = 143
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function DabaoBossView:OpenItemInfo()
	self.show_panel:SetValue(true)
	self.show_boss:SetValue(false)
end

function DabaoBossView:OpenBossInfo()
	self.show_panel:SetValue(false)
	self.show_boss:SetValue(true)
	self:FlushModel()
end

function DabaoBossView:FlushModel()
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

function DabaoBossView:OpenKillRecord()
	BossCtrl.SendBossKillerInfoReq(BOSS_ENTER_TYPE.TYPE_BOSS_DABAO, self.select_boss_id, self.select_scene_id)
end

function DabaoBossView:FlushItemList()
	local item_list = BossData.Instance:GetDabaoBossRewards(self.select_boss_id)
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

function DabaoBossView:FlushInfoList()
	if self.select_scene_id ~= 0 and self.select_boss_id ~= 0 then
		local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.select_boss_id]
		if monster_cfg then
			self.boss_name:SetValue(monster_cfg.name)
		end
		self:FlushItemList()
		local enter_count = BossData.Instance:GetDabaoBossCount()
		local max_count = BossData.Instance:GetDabaoFreeTimes()
		local has_count = math.max(max_count - enter_count, 0)
		if has_count > 0 then
			self.show_diamond:SetValue(false)
			self.enter_limit:SetValue(Language.Boss.ResetEnterTimes .. ToColorStr(tostring(has_count), TEXT_COLOR.GREEN))
		else
			self.show_diamond:SetValue(true)
			local cost = BossData.Instance:GetDabaoEnterGold(enter_count - max_count)
			self.enter_limit:SetValue(Language.Boss.XiaoHao .. ToColorStr(tostring(cost), TEXT_COLOR.YELLOW))
		end
		self.enter_btn_name:SetValue(BossData.Instance:GetDabaoEnterGold(enter_count - max_count) and Language.Boss.EnterBtnName[2] or Language.Boss.EnterBtnName[1])
		self.enter_btn_gray:SetValue(has_count > 0 or BossData.Instance:GetDabaoEnterGold(enter_count - max_count))
		self:FlushModel()
	end
end

function DabaoBossView:FlushBossList()
	local boss_list = BossData.Instance:GetDaBaoBossList(self.select_scene_id)
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

function DabaoBossView:FlushBossView()
	self.select_index = 1
	self:FlushBossList()
	self:FlushInfoList()
	self:FlushBossRemainCount()
	self:FlushToggleHL()
end

function DabaoBossView:OnFlush()
	self:FlushBossView()
end

function DabaoBossView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function DabaoBossView:GetSelectIndex()
	return self.select_index or 1
end

function DabaoBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function DabaoBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end
----------------------------------------------------------------------
DabaoBossItemCell = DabaoBossItemCell or BaseClass(BaseCell)

function DabaoBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function DabaoBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function DabaoBossItemCell:ClickItem(is_click)
	if is_click then
		self.root_node.toggle.isOn = true
		local select_index = self.boss_view:GetSelectIndex()
		self.boss_view:SetSelectIndex(self.index)
		self.boss_view:SetSelectBossId(self.data.bossID)
		self.boss_view:FlushAllHL()
		if select_index == self.index then
			return
		end
		self.boss_view:FlushItemList()
	end
end

function DabaoBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.bossID]
	if monster_cfg then
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.boss_name:SetValue(monster_cfg.name)

		local bundle, asset = ResPath.GetBossView(monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
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

function DabaoBossItemCell:OnBossUpdate()
	local reflash_time = BossData.Instance:GetDaBaoStatusByBossId(self.data.bossID, self.data.scene_id)
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

function DabaoBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end