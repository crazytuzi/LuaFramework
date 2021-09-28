KuaFuBossView = KuaFuBossView or BaseClass(BaseRender)

function KuaFuBossView:__init()
	self.select_index = 1
	self.cell_list = {}
	self.boss_data = {}
	self.num = 0
	self.nowpanelboss_num = self:FindVariable("NowPanelBossNum")
	
	self.explain = self:FindVariable("Explain")
	self.need_num = self:FindVariable("Num")
	self.item_name = self:FindVariable("ItemName")

	self.boss_list = self:FindObj("BossList")

	self.list_view_delegate = self.boss_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)
	self.is_first = true
	self.item_list = {}
	for i = 1, 8 do
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(self:FindObj("Item" .. i))
		item_cell:SetData(nil)
		table.insert(self.item_list, item_cell)
	end
	self.toggle_list = {}
	self.show_hl_list = {}
	for i=1, 4 do
		self.toggle_list[i] = self:FindObj("toggle_" .. i)
		self:ListenEvent("toggle_" .. i ,BindTool.Bind2(self.OnToggleClick, self, i))
		self.show_hl_list[i] = self:FindVariable("show_hl_" .. i)
	end

	self.select_boss_id = KfBossData.Instance:GetCrossBossInfoByLevel(1).boss_id
	self.pingtai_move_offest = 0
	self.is_moveing = false

	self.boss_index_list = {0,1,2}

	self:ListenEvent("ClickEnter",BindTool.Bind(self.ClickEnter, self))
	self:ListenEvent("QuestionClick",BindTool.Bind(self.QuestionClick, self))
	self:ListenEvent("OpenBossInfo",
		BindTool.Bind(self.OpenBossInfo, self))
	self:ListenEvent("OpenItemInfo",
		BindTool.Bind(self.OpenItemInfo, self))

	self.show_panel = self:FindVariable("ShowPanel")
	self.show_boss = self:FindVariable("ShowBoss")
	self.model_display = self:FindObj("display")
	self.model_view = RoleModel.New()
	self.model_view:SetDisplay(self.model_display.ui3d_display)
	self.item_data_event = nil
	self:SetNotifyDataChangeCallBack()
end

function KuaFuBossView:__delete()
	if nil ~= self.model_view then
		self.model_view:DeleteMe()
	end

	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end

	if self.item_data_event ~= nil then
		if ItemData.Instance then
			ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		end
		self.item_data_event = nil
	end

	self.item_list = {}

	self.pingtai_move_offest = 0
	self.is_first = true
end

function KuaFuBossView:GetNumberOfCells()
	return #KfBossData.Instance:GetCrossBossInfoByLevel(self.select_index) or 0
end

function KuaFuBossView:SetSelectBossId(boss_id)
	self.select_boss_id = boss_id
end

function KuaFuBossView:GetSelectBossId()
	return self.select_boss_id
end

function KuaFuBossView:FlushToggleHL()
	for i=1,4 do
		self.show_hl_list[i]:SetValue(i == self.select_index)
	end
end

function KuaFuBossView:OnToggleClick(i, is_click)
	if is_click then
		local can_go, min_level = KfBossData.Instance:GetCanToSceneLevel(i)
		if not can_go then
			local level_text = PlayerData.GetLevelString(min_level)
			local text = string.format(Language.Boss.BossLimit, level_text)
			TipsCtrl.Instance:ShowSystemMsg(text)
			return
		end
		self.select_index = i
		self:FlushBossList()
		self:FlushModel()
		self:FlushToggleHL()
	end
end

function KuaFuBossView:RefreshView(cell, data_index)
	data_index = data_index + 1

	local boss_cell = self.cell_list[cell]
	if boss_cell == nil then
		boss_cell = KfBossCell.New(cell.gameObject)
		boss_cell.root_node.toggle.group = self.boss_list.toggle_group
		boss_cell.boss_view = self
		self.cell_list[cell] = boss_cell
	end
	boss_cell:SetData(self.boss_data[data_index])
end

-- 设置物品回调
function KuaFuBossView:SetNotifyDataChangeCallBack()
	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
end

function KuaFuBossView:ItemDataChangeCallback(item_id)
	local need_item_id = KfBossData.Instance:GetCrossBossSingleInfo(self.select_index, self.select_boss_id).need_item_id
	if item_id == need_item_id then
		self:FlushNum()
	end
end

function KuaFuBossView:ResMonsterIndexList()
	self.boss_index_list = {1, 2, 3}
	for i=1,3 do
		self.boss_cell_list[i]:SetBossIndex(self.boss_index_list[i])
	end
	self:SetLeftAndRightButtonState()
end

function KuaFuBossView:RecycleCell(data_index, cell)
	local boss_cell = self.cell_list[cell]
	if boss_cell ~= nil then
		boss_cell:DeleteMe()
		self.cell_list[cell] = nil
	end
end

function KuaFuBossView:OpenItemInfo()
	self.show_panel:SetValue(true)
	self.show_boss:SetValue(false)
end

function KuaFuBossView:SetLeftAndRightButtonState()
	if #self.boss_data == 0 then
		self.boss_data = KfBossData.Instance:GetCrossBossInfoByLevel(self.select_index)
	end
	self:FlushInfo()
end

function KuaFuBossView:ClickEnter()
	if BossData.Instance:GetCanGoAttack() then
		info = KfBossData.Instance:GetCrossBossSingleInfo(self.select_index, self.select_boss_id)
		local my_count = ItemData.Instance:GetItemNumInBagById(info.need_item_id)
		if my_count >= info.need_item_num then
			ViewManager.Instance:CloseAll()
			KfBossData.Instance:SetCurInfo(self.select_index, self.select_boss_id)
			CrossServerCtrl.Instance:SendCrossStartReq(ACTIVITY_TYPE.KF_BOSS, self.select_index)
		else
			local item_cfg = ConfigManager.Instance:GetAutoConfig("shop_auto").item[info.need_item_id]
			if item_cfg == nil then
				TipsCtrl.Instance:ShowItemGetWayView(info.need_item_id)
				return
			end

			if item_cfg.bind_gold == 0 then
				TipsCtrl.Instance:ShowShopView(info.need_item_id, 2)
				return
			end

			local func = function(item_id2, item_num, is_bind, is_use, is_buy_quick)
				MarketCtrl.Instance:SendShopBuy(item_id2, item_num, is_bind, is_use)
			end

			TipsCtrl.Instance:ShowCommonBuyView(func, info.need_item_id, nil, 1)
			return
		end
	end
end

function KuaFuBossView:IsCanRollToRight()
	return self.pingtai_move_offest < KfBossData.Instance:GetLevelCount() - 1
end

function KuaFuBossView:IsCanRollToLeft()
	return self.pingtai_move_offest > 0
end

function KuaFuBossView:QuestionClick()
	local tips_id = 144 -- 跨服boss
	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function KuaFuBossView:OpenBossInfo()
	self.show_panel:SetValue(false)
	self.show_boss:SetValue(true)
	self:FlushModel()
end

function KuaFuBossView:FlushModel()
	if self.model_view == nil then
		return
	end
	if self.model_display.gameObject.activeInHierarchy then
		local res_id = KfBossData.Instance:GetBossResIdById(self.select_boss_id)
		self.model_view:SetMainAsset(ResPath.GetMonsterModel(res_id))
		self.model_view:SetTrigger("rest1")
	end
end

function KuaFuBossView:SetSelectIndex(index)
	self.select_index = index
end

function KuaFuBossView:GetSelectIndex()
	return self.select_index
end

function KuaFuBossView:FlushInfo()
	local boss_info = KfBossData.Instance:GetCrossBossSingleInfo(self.select_index, self.select_boss_id)
	if boss_info then
		self:FlushNum(boss_info)
		local item_cfg = ItemData.Instance:GetItemConfig(boss_info.need_item_id)
		if item_cfg then
			self.item_name:SetValue(item_cfg.name)
			local my_count = ItemData.Instance:GetItemNumInBagById(boss_info.need_item_id)
			local my_text = my_count .. ""
			if my_count < boss_info.need_item_num then
				my_text = ToColorStr(tostring(my_count), TEXT_COLOR.RED)
			end
			self.need_num:SetValue(my_text .. "/" .. boss_info.need_item_num)
		end
		for i = 1, 8 do
			local item_id = boss_info["drop_show" .. i]
			if item_id then
				local item_data = {}
				item_data.item_id = item_id
				item_data.num = 1
				item_data.is_gray = false
				item_data.is_up_arrow = false
				if self.item_list[i] then
					self.item_list[i]:SetIsTianSheng(true)
					self.item_list[i]:SetData(item_data)
				end
			end
		end
		self:FlushModel()
	end
end

function KuaFuBossView:FlushNum(boss_info)
	local boss_info = boss_info or KfBossData.Instance:GetCrossBossSingleInfo(self.select_index, self.select_boss_id)
	if boss_info then
		local item_cfg = ItemData.Instance:GetItemConfig(boss_info.need_item_id)
		if item_cfg then
			self.item_name:SetValue(item_cfg.name)
			local my_count = ItemData.Instance:GetItemNumInBagById(boss_info.need_item_id)
			local my_text = my_count .. ""
			if my_count < boss_info.need_item_num then
				my_text = ToColorStr(tostring(my_count), TEXT_COLOR.RED)
			end
			self.need_num:SetValue(my_text .. "/" .. boss_info.need_item_num)
		end
	end
end

function KuaFuBossView:FlushBossList()
	self.select_boss_id = KfBossData.Instance:GetCrossBossInfoByLevel(self.select_index)[1].boss_id
	self.boss_data = KfBossData.Instance:GetCrossBossInfoByLevel(self.select_index)
	if self.select_index == 1 then
		self.boss_list.scroller:ReloadData(0)
	else
		self.boss_list.scroller:RefreshAndReloadActiveCellViews(true)
	end
end

function KuaFuBossView:FlushKfBossView()
	self.select_boss_id = KfBossData.Instance:GetCrossBossInfoByLevel(self.select_index)[1].boss_id
	self.boss_data = KfBossData.Instance:GetCrossBossInfoByLevel(self.select_index)
	self:FlushInfo()
	self:FlushBossList()
	self:FlushToggleHL()
	if self.is_first == true then
		local index = KfBossData.Instance:GetKfCanGoLevel()
		self.toggle_list[index].toggle.isOn = true
		self.is_first = false
	end
end

function KuaFuBossView:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end
------------------------------------------------------------------
KfBossCell = KfBossCell or BaseClass(BaseCell)

function KfBossCell:__init()
	self.level = self:FindVariable("Level")
	self.icon = self:FindVariable("Icon")
	self.iskill = self:FindVariable("IsKill")
	self.show_lock = self:FindVariable("show_lock")
	self.image = self:FindObj("image")
	self.boss_name = self:FindVariable("Name")
	self.refresh_time = self:FindVariable("Time")
	self.level_zhuan = self:FindVariable("level_zhuan")
	self.canKill = self:FindVariable("canKill")
	self.image_gray_scale = self:FindVariable("image_gray_scale")
	self.image_gray_scale:SetValue(true)
	self.show_hl = self:FindVariable("show_hl")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function KfBossCell:__delete()

end

function KfBossCell:ClickItem(is_click)
	if is_click then
		self.boss_view:SetSelectBossId(self.data.boss_id)
		self.boss_view:FlushAllHL()
		self.boss_view:FlushInfo()
	end
end

function KfBossCell:OnFlush()
	if not next(self.data) then return end
	self.root_node.toggle.isOn = false
	local monster_cfg = ConfigManager.Instance:GetAutoConfig("monster_auto").monster_list[self.data.boss_id]
	if monster_cfg then
		self.boss_name:SetValue(monster_cfg.name)
		self.level:SetValue("Lv." .. monster_cfg.level)
		self.canKill:SetValue(true)
		local bundle, asset = ResPath.GetBoss("boss_item_" .. monster_cfg.headid)
		self.icon:SetAsset(bundle, asset)
	end
	self.iskill:SetValue(false)
	self:FlushHL()
end

function KfBossCell:FlushHL()
	local boss_id = self.boss_view:GetSelectBossId()
	self.show_hl:SetValue(boss_id == self.data.boss_id)
end

