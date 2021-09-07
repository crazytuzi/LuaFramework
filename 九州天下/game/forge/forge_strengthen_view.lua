ForgeStrengthen = ForgeStrengthen or BaseClass(BaseRender)

function ForgeStrengthen:__init()
	self.cell_list = {}
	self.select_index = 1
	self.equip_index = 0
	self.is_auto_buy_stone = 0
	self.item_has_num = 0
	self.item_need_num = 0
	self.old_strengthen_level = 0

	if self.item_change == nil then
		self.item_change = BindTool.Bind(self.ItemChange, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_change)
	end
end

function ForgeStrengthen:__delete()
	for _,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
		end
	end
	self.cell_list = {}

	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	if self.attr_tips then
		self.attr_tips:DeleteMe()
		self.attr_tips = nil
	end

	if self.item_change then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_change)
		self.item_change = nil
	end
end

function ForgeStrengthen:LoadCallBack()
	self.equip_index = ForgeData.Instance:GetDefaultEquipIndex()

	self.is_max_level = self:FindVariable("is_max_level")
	self.is_total_max_level = self:FindVariable("is_total_max_level")

	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.now_level = self:FindVariable("now_level")

	self.cur_reduce_value = self:FindVariable("cur_reduce_value")
	self.cur_increase_value = self:FindVariable("cur_increase_value")
	self.cur_attr_name = self:FindVariable("cur_attr_name")
	self.cur_attr_value = self:FindVariable("cur_attr_value")
	self.cur_power = self:FindVariable("cur_power")

	self.next_reduce_value = self:FindVariable("next_reduce_value")
	self.next_increase_value = self:FindVariable("next_increase_value")
	self.next_attr_name = self:FindVariable("next_attr_name")
	self.next_attr_value = self:FindVariable("next_attr_value")
	self.next_power = self:FindVariable("next_power")

	self.total_power = self:FindVariable("total_power")
	self.add_power = self:FindVariable("add_power")

	self.exp_radio = self:FindVariable("exp_radio")
	self.cur_process = self:FindVariable("cur_process")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_num = self:FindVariable("item_num")

	self.show_text = self:FindVariable("show_protext")

	self.auto_buy_toggle = self:FindObj("AutoBuyToggle").toggle

	self.equip_list = self:FindObj("StrengthList")
	self.list_view_delegate = self.equip_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.mark_list = self:FindObj("MarkList")
	self.mark_item = {}
	for i = 1, 30 do
		self.mark_item[i] = self.mark_list:FindObj("Mark" .. i)
	end

	self.attr_tips = StrengthAttrTips.New(self:FindObj("AttrTips"))
	self.attr_tips:SetActive(false)

	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if equip_data then
		self.old_strengthen_level = equip_data.param.strengthen_level
	end

	self:ListenEvent("OnClickAutoBuy", BindTool.Bind(self.OnClickAutoBuy, self))
	self:ListenEvent("OnClickStrength", BindTool.Bind(self.OnClickStrength, self))
	self:ListenEvent("OnClickTotalAttr", BindTool.Bind(self.OnClickTotalAttr, self))
	self:ListenEvent("OnClickCloseTips", BindTool.Bind(self.OnClickCloseTips, self))
	self:ListenEvent("OnClickDescTips", BindTool.Bind(self.OnClickDescTips, self))

	self:Flush()
end

function ForgeStrengthen:ItemChange()
	self:FlushStuffItem()
end

function ForgeStrengthen:GetNumberOfCells()
	return EquipData.Instance:GetDataCount()
end

function ForgeStrengthen:RefreshView(cell, data_index)
	data_index = data_index + 1

	local equip_cell = self.cell_list[cell]
	if equip_cell == nil then
		equip_cell = StrengthItemCell.New(cell.gameObject)
		equip_cell.parent_view = self
		self.cell_list[cell] = equip_cell
	end
	equip_cell:SetIndex(data_index)
	local data = ForgeData.Instance:GetCurEquipList()
	equip_cell:SetData(data[data_index])
end

function ForgeStrengthen:SetSelectIndex(select_index, equip_index)
	self.select_index = select_index
	self.equip_index = equip_index
end

function ForgeStrengthen:GetSelectIndex()
	return self.select_index or 1
end

function ForgeStrengthen:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ForgeStrengthen:OnClickAutoBuy(is_on)
	if is_on then
		self.is_auto_buy_stone = 1
	else
		self.is_auto_buy_stone = 0
	end
end

function ForgeStrengthen:OnClickStrength()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if equip_data == nil or next(equip_data) == nil then return end
	if self.is_auto_buy_stone == 0 and self.item_has_num < self.item_need_num then
		local func = function(item_id, item_num, is_bind, is_use, is_buy_quick)
			MarketCtrl.Instance:SendShopBuy(item_id, item_num, is_bind, is_use)
			if is_buy_quick then
				self.auto_buy_toggle.isOn = true
				self.is_auto_buy_stone = 1
			end
		end
		local attr = ForgeData.Instance:GetStrengthSingleCfg(self.equip_index, equip_data.param.strengthen_level + 1)
		TipsCtrl.Instance:ShowCommonBuyView(func, attr.stuff_id, nil, need_num)
	else
		ForgeCtrl.Instance:SendQianghua(self.equip_index, self.is_auto_buy_stone, 0)
	end
	self.old_strengthen_level = equip_data.param.strengthen_level
end

function ForgeStrengthen:OnClickTotalAttr()
	if self.attr_tips.root_node.gameObject.activeSelf then
		self.attr_tips:SetActive(false)
	else
		self.attr_tips:SetData()
		self.attr_tips:SetActive(true)
	end
end

function ForgeStrengthen:OnClickCloseTips()
	self.attr_tips:SetActive(false)
end

function ForgeStrengthen:OnClickDescTips()
	TipsCtrl.Instance:ShowHelpTipView(146)
end

function ForgeStrengthen:FlushStuffItem()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	
	if equip_data.param.strengthen_level >= ForgeData.Instance:GetStrengthMaxLevel() then
		return
	end

	if self.item_cell == nil then
		return 
	end

	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	local attr = ForgeData.Instance:GetStrengthSingleCfg(self.equip_index, equip_data.param.strengthen_level + 1)
	self.item_cell:SetData({item_id = attr.stuff_id, num = 0, is_bind = 0})
	self.item_has_num = ItemData.Instance:GetItemNumInBagById(attr.stuff_id)
	self.item_need_num = attr.stuff_count
	self.item_num:SetValue(self.item_has_num .. "/" .. self.item_need_num)
	if self.item_has_num < self.item_need_num then
		self.item_num:SetValue(ToColorStr(self.item_has_num, TEXT_COLOR.RED) .. "/" .. self.item_need_num)
	else
		self.item_num:SetValue(ToColorStr(self.item_has_num, TEXT_COLOR.GREEN) .. "/" .. self.item_need_num)
	end
end

function ForgeStrengthen:FlushStrengthAttr()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	local cur_attr = ForgeData.Instance:GetStrengthSingleCfg(self.equip_index, equip_data.param.strengthen_level)
	local next_attr = ForgeData.Instance:GetStrengthSingleCfg(self.equip_index, equip_data.param.strengthen_level + 1)
    local is_max = equip_data.param.strengthen_level >= ForgeData.Instance:GetStrengthMaxLevel()
	self.is_max_level:SetValue(is_max)
	self.is_total_max_level:SetValue(ForgeData.Instance:GetIsStrengthMaxLevel())

	if nil == cur_attr or nil == next(cur_attr) then
		local cur_attr_name = ForgeData.Instance:GetStrengthShowAttr(next_attr)
		self.cur_attr_value:SetValue(0)
		self.cur_reduce_value:SetValue(0)
		self.cur_increase_value:SetValue(0)
		self.cur_attr_name:SetValue(Language.Common.AttrNameNoUnderline[cur_attr_name] .. "：")
		self.cur_power:SetValue(0)
	else
		local cur_attr_name = ForgeData.Instance:GetStrengthShowAttr(cur_attr)
		self.cur_attr_value:SetValue(cur_attr[cur_attr_name])
		self.cur_reduce_value:SetValue((cur_attr.per_pvp_hurt_reduce / 100) .. "%")
		self.cur_increase_value:SetValue((cur_attr.per_pvp_hurt_increase / 100) .. "%")
		self.cur_attr_name:SetValue(Language.Common.AttrNameNoUnderline[cur_attr_name] .. "：")
		local cur_power = CommonDataManager.GetCapabilityCalculation(cur_attr)
		self.cur_power:SetValue(cur_power)
	end

	if nil ~= next_attr and nil ~= next(next_attr) then
		local next_attr_name = ForgeData.Instance:GetStrengthShowAttr(next_attr)
		self.next_attr_value:SetValue(next_attr[next_attr_name])
		self.next_reduce_value:SetValue((next_attr.per_pvp_hurt_reduce / 100) .. "%")
		self.next_increase_value:SetValue((next_attr.per_pvp_hurt_increase / 100) .. "%")
		self.next_attr_name:SetValue(Language.Common.AttrNameNoUnderline[next_attr_name] .. "：")
		local cur_power = 0
		if nil ~= cur_attr and nil ~= next(cur_attr) then
			cur_power = CommonDataManager.GetCapabilityCalculation(cur_attr)
		end
		local next_power = CommonDataManager.GetCapabilityCalculation(next_attr)
		self.next_power:SetValue(next_power)
		self.add_power:SetValue(next_power - cur_power)
	end

	local cur_strength_level, cur_level, _ = ForgeData.Instance:GetLevelCfgByStrengthLv(self.equip_index, equip_data.param.strengthen_level)
	local next_strength_level, next_level, _ = ForgeData.Instance:GetLevelCfgByStrengthLv(self.equip_index, equip_data.param.strengthen_level + 1)
	self.cur_level:SetValue(is_max and string.format(Language.Forge.TheMaxLv, cur_strength_level)
	or string.format(Language.Forge.StrengthLevel, cur_strength_level, cur_level))
	self.next_level:SetValue(string.format(Language.Forge.StrengthLevel, next_strength_level, next_level))
	self.now_level:SetValue(string.format(Language.Forge.StrengthFormatLevel, cur_strength_level))
	self.show_text:SetValue(is_max)

	local total_attr = ForgeData.Instance:GetStrengthTotalAttr()
	local total_cap = CommonDataManager.GetCapabilityCalculation(total_attr)
	self.total_power:SetValue(total_cap)
end

function ForgeStrengthen:FlushProgress()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end

	local equip_strength_level, cur_level, total_level = ForgeData.Instance:GetLevelCfgByStrengthLv(self.equip_index, equip_data.param.strengthen_level)
	local next_level = ForgeData.Instance:GetTotalLvByStrengthLv(equip_strength_level + 1)
	local tmp_cur_level = cur_level == total_level and 0 or cur_level
	local tmp_total_level = cur_level == total_level and next_level or total_level

	if cur_level == 0 then
		tmp_total_level = ForgeData.Instance:GetTotalLvByStrengthLv(equip_strength_level)
	end

	local percent_exp = tmp_cur_level/tmp_total_level
	if tmp_total_level == 0 then
		percent_exp = 0
	end
	self.exp_radio:SetValue(percent_exp)
	self.cur_process:SetValue(tmp_cur_level .. "/" .. tmp_total_level)

	for i = 1, 30 do
		self.mark_item[i]:SetActive(i <= tmp_total_level)
	end
end

function ForgeStrengthen:FlushFloatLabel()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end

	local add_level = equip_data.param.strengthen_level - self.old_strengthen_level
	local old_cur_level = ForgeData.Instance:GetLevelCfgByStrengthLv(self.equip_index, self.old_strengthen_level)
	local new_cur_level = ForgeData.Instance:GetLevelCfgByStrengthLv(self.equip_index, equip_data.param.strengthen_level)
	if old_cur_level ~= new_cur_level then
		TipsCtrl.Instance:ShowFloatingLabel(nil, 100, 0, false, true, ResPath.GetFloatTextRes("WordStrengthSuccess"))
	else
		if add_level > 1 then
			TipsCtrl.Instance:ShowFloatingLabel(nil, 100, 0, false, true, ResPath.GetFloatTextRes("WordStrengthBaoJi"))
			-- print(ResPath.GetFloatTextRes("WordStrengthBaoJi"))
		elseif add_level == 1 then
			TipsCtrl.Instance:ShowFloatingLabel(string.format(Language.Forge.AddProgress, add_level), 100, 0, true, false)
		end
	end
end

function ForgeStrengthen:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.need_flush == nil or v.need_flush then
				if self.select_index == 1 then
					self.equip_list.scroller:ReloadData(0)
				else
					self.equip_list.scroller:RefreshAndReloadActiveCellViews(true)
				end
			end

			self:FlushStrengthAttr()
			self:FlushStuffItem()
			self:FlushProgress()
		end
	end
end

------------------------StrengthItemCell------------------------------
StrengthItemCell = StrengthItemCell or BaseClass(BaseCell)

function StrengthItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
	self.name = self:FindVariable("name")
	self.level = self:FindVariable("level")
	self.show_hl = self:FindVariable("show_hl")
	self.show_red_point = self:FindVariable("show_red_point")
	self:ListenEvent("ClickItem", BindTool.Bind(self.ClickItem, self))
end

function StrengthItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function StrengthItemCell:ClickItem()
	self.parent_view:SetSelectIndex(self.index, self.data.index)
	self.parent_view:FlushAllHL()
	self.parent_view:Flush("all", {need_flush = false})
end

function StrengthItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.name:SetValue(cfg.name)
	self.item_cell:SetData(self.data)

	local equip_strength_level, cur_level, total_level = ForgeData.Instance:GetLevelCfgByStrengthLv(self.data.index, self.data.param.strengthen_level)
	self.level:SetValue(string.format(Language.Forge.StrengthLevel, equip_strength_level, cur_level))

	self:FlushHL()

	self.show_red_point:SetValue(ForgeData.Instance:GetStrengthRemindByIndex(self.data.index))
end

function StrengthItemCell:FlushHL()
	local select_index = self.parent_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

-------------StrengthAttrTips--------------------------------
StrengthAttrTips = StrengthAttrTips or BaseClass(BaseCell)

function StrengthAttrTips:__init()
	self.cur_attr = {}
	self.next_attr = {}
	for i = 1, 4 do
		self.cur_attr[i] = self:FindVariable("attr_value_" .. i)
		self.next_attr[i] = self:FindVariable("next_value_" .. i)
	end
	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.cur_power = self:FindVariable("cur_power")
	self.next_power = self:FindVariable("next_power")
end

function StrengthAttrTips:__delete()

end

function StrengthAttrTips:OnFlush()
	local level = ForgeData.Instance:GetStrengthMinLevel()
	local cur_cfg, next_level, next_cfg = ForgeData.Instance:GetStrengthAddCfgAndNextLevel()

	self.cur_level:SetValue(level)
	self.next_level:SetValue(next_level)
	self.cur_attr[1]:SetValue(cur_cfg.ice_master)
	self.cur_attr[2]:SetValue(cur_cfg.fire_master)
	self.cur_attr[3]:SetValue(cur_cfg.thunder_master)
	self.cur_attr[4]:SetValue(cur_cfg.poison_master)
	self.next_attr[1]:SetValue(next_cfg.ice_master)
	self.next_attr[2]:SetValue(next_cfg.fire_master)
	self.next_attr[3]:SetValue(next_cfg.thunder_master)
	self.next_attr[4]:SetValue(next_cfg.poison_master)
	self.cur_power:SetValue(CommonDataManager.GetCapabilityCalculation(cur_cfg))
	self.next_power:SetValue(CommonDataManager.GetCapabilityCalculation(next_cfg))
end