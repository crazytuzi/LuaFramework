KuafuLiuJieBossInfoView = KuafuLiuJieBossInfoView or BaseClass(BaseRender)
function KuafuLiuJieBossInfoView:__init()
	self.select_index = 1
	self.select_boss_id = 50233
end

function KuafuLiuJieBossInfoView:LoadCallBack()
	self.boss_data = {}
	self.boss_cell_list = {}
	self.boss_list = self:FindObj("BossList")
	self.boss_list_view_delegate = self.boss_list.list_simple_delegate
	self.boss_list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetBossNumberOfCells, self)
	self.boss_list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshBossView, self)

	self.reward_item_list = {}
	self.reward_item_parent = self:FindObj("RewardParent")
	local main_city_cfg = KuafuGuildBattleData.Instance:GetCityShowItemCfg(0)
	for i = 1, #main_city_cfg do
		local data = {item_id = main_city_cfg[i]} 
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self.reward_item_parent)
		item_cell:SetData(data)
		table.insert(self.reward_item_list, item_cell)
	end

	self.display = self:FindObj("DisPlay")
	self.model_view = RoleModel.New("boss_view")
	self.model_view:SetDisplay(self.display.ui3d_display)

	self:ListenEvent("OnBossHelpClick", BindTool.Bind(self.OnBossHelpClick, self))

	self:Flush()
end

function KuafuLiuJieBossInfoView:OpenCallBack()
	local role_vo = PlayerData.Instance:GetRoleVo()
	local uuid = role_vo.uuid or 0
	CrossServerCtrl.Instance:SendCSCrossCommonOperaReq(CROSS_COMMON_OPERA_REQ.CROSS_COMMON_OPERA_REQ_CROSS_GUILDBATTLE_BOSS_INFO, KuafuGuildBattleData.Instance:GetSceneIdByIndex(), uuid)
end

function KuafuLiuJieBossInfoView:__delete()
	if self.model_view then
		self.model_view:DeleteMe()
		self.model_view = nil
	end

	for _, v in pairs(self.boss_cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.boss_cell_list = {}

	for _, v in pairs(self.reward_item_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.reward_item_list = {}
end

function KuafuLiuJieBossInfoView:OnFlush()
	self:FlushBossList()
	self:FlushModel()
end

function KuafuLiuJieBossInfoView:OnBossHelpClick()
	TipsCtrl.Instance:ShowHelpTipView(251)
end

function KuafuLiuJieBossInfoView:SetSelectIndex(index)
	if index then
		self.select_index = index
	end
end

function KuafuLiuJieBossInfoView:GetSelectIndex()
	return self.select_index or 1
end

function KuafuLiuJieBossInfoView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function KuafuLiuJieBossInfoView:FlushBossList()
	self.boss_data = KuafuGuildBattleData.Instance:GetBossList() or {}
	if self.boss_list.scroller.isActiveAndEnabled then
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuafuLiuJieBossInfoView:FlushAllHL()
	for k,v in pairs(self.boss_cell_list) do
		v:FlushHL()
	end
end

function KuafuLiuJieBossInfoView:FlushModel()
	if self.model_view == nil then
		return
	end
	if self.display.gameObject.activeInHierarchy then
		local res_id = BossData.Instance:GetMonsterInfo(self.select_boss_id).resid
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
		self.model_view:SetTrigger("rest1")
	end
end

function KuafuLiuJieBossInfoView:GetBossNumberOfCells()
	return  #self.boss_data or 0
end

function KuafuLiuJieBossInfoView:RefreshBossView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.boss_cell_list[cell]
	if boss_cell == nil then
		boss_cell = KuafuLiuJieBossItemCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		boss_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		self.boss_cell_list[cell] = boss_cell
	end
	boss_cell:SetIndex(data_index)
	boss_cell:SetData(self.boss_data[data_index])
end

function KuafuLiuJieBossInfoView:OnClickItemCallBack(cell, select_index)
	if nil == cell or nil == cell.data then
		return
	end

	cell.root_node.toggle.isOn = true
	local cur_select_index = self:GetSelectIndex()
	self:SetSelectIndex(cell.index)
	self:SetSelectBossId(cell.data.boss_id)
	self:FlushAllHL()
	if cur_select_index == cell.index then
		return
	end
	self:FlushModel()
end

------------------------------------------------------------------------------
KuafuLiuJieBossItemCell = KuafuLiuJieBossItemCell or BaseClass(BaseCell)

function KuafuLiuJieBossItemCell:__init()
	self.boss_name = self:FindVariable("Name")
	self.icon = self:FindVariable("Icon")
	self.time = self:FindVariable("Time")
	self.iskill = self:FindVariable("IsKill")
	self.level = self:FindVariable("Level")
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function KuafuLiuJieBossItemCell:__delete()
	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuafuLiuJieBossItemCell:ClickItem(is_click)
	if is_click then
		if nil ~= self.click_callback then
			self.click_callback(self)
		end
	end
end

function KuafuLiuJieBossItemCell:OnFlush()
	if not self.data then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = BossData.Instance:GetMonsterInfo(self.data.boss_id)
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		self.level:SetValue("Lv." .. monster_cfg.level)
		local bundle, asset = ResPath.GetBossView(monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end

	if self.time_coundown then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
	if self.data.status >= 1 then
		self.iskill:SetValue(false)
		self.time:SetValue(ToColorStr(Language.Boss.HadFlush, TEXT_COLOR.GREEN))
	else
		self.iskill:SetValue(true)
		self.time_coundown = GlobalTimerQuest:AddRunQuest(BindTool.Bind(self.OnBossUpdate, self), 0)
	end
	self:FlushHL()
end

function KuafuLiuJieBossItemCell:OnBossUpdate()
	local time = math.max(0, self.data.next_refresh_time - TimeCtrl.Instance:GetServerTime())
	self.time:SetValue(ToColorStr(TimeUtil.FormatSecond(time, 3), TEXT_COLOR.RED))
	if time <= 0 then
		GlobalTimerQuest:CancelQuest(self.time_coundown)
		self.time_coundown = nil
	end
end

function KuafuLiuJieBossItemCell:FlushHL()
	local select_index = self.boss_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end