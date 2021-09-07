ForgeCast = ForgeCast or BaseClass(BaseRender)

function ForgeCast:__init()
	self.cell_list = {}
	self.select_index = 1
	self.equip_index = 0
end

function ForgeCast:__delete()
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
end

function ForgeCast:LoadCallBack()
	self.equip_index = ForgeData.Instance:GetDefaultEquipIndex()
	
	self.cur_level = self:FindVariable("cur_level")
	self.next_level = self:FindVariable("next_level")
	self.now_level = self:FindVariable("now_level")

	self.cur_attr_name = self:FindVariable("cur_attr_name")
	self.next_attr_name = self:FindVariable("next_attr_name")
	self.cur_attr_value = self:FindVariable("cur_attr_value")
	self.next_attr_value = self:FindVariable("next_attr_value")

	self.cur_power = self:FindVariable("cur_power")
	self.next_power = self:FindVariable("next_power")
	self.total_power = self:FindVariable("total_power")

	self.is_max_level = self:FindVariable("is_max_level")
	self.is_total_max_level = self:FindVariable("is_total_max_level")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_num = self:FindVariable("item_num")

	self.curLevel_go = self:FindObj("CurLevelGo")
	self.curattr_go = self:FindObj("CurAttrGo")
	self.power_go = self:FindObj("PowerGo")

	self.attr_tips = CastAttrTips.New(self:FindObj("AttrTips"))
	self.attr_tips:SetActive(false)

	self.equip_list = self:FindObj("CastList")
	self.list_view_delegate = self.equip_list.list_simple_delegate

	self.list_view_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	self.list_view_delegate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self:ListenEvent("OnClickCast", BindTool.Bind(self.OnClickCast, self))
	self:ListenEvent("OnClickDescTips", BindTool.Bind(self.OnClickDescTips, self))
	self:ListenEvent("OnClickTotalAttr", BindTool.Bind(self.OnClickTotalAttr, self))
	self:ListenEvent("OnClickCloseTips", BindTool.Bind(self.OnClickCloseTips, self))

	self:Flush()
end

function ForgeCast:GetNumberOfCells()
	return EquipData.Instance:GetDataCount()
end

function ForgeCast:RefreshView(cell, data_index)
	data_index = data_index + 1

	local equip_cell = self.cell_list[cell]
	if equip_cell == nil then
		equip_cell = CastItemCell.New(cell.gameObject)
		equip_cell.parent_view = self
		self.cell_list[cell] = equip_cell
	end
	equip_cell:SetIndex(data_index)
	local data = ForgeData.Instance:GetCurEquipList()
	equip_cell:SetData(data[data_index])
end

function ForgeCast:SetSelectIndex(select_index, equip_index)
	self.select_index = select_index
	self.equip_index = equip_index
end

function ForgeCast:GetSelectIndex()
	return self.select_index or 1
end

function ForgeCast:FlushAllHL()
	for k,v in pairs(self.cell_list) do
		v:FlushHL()
	end
end

function ForgeCast:OnClickCast()
	ForgeCtrl.Instance:SendCast(self.equip_index)
end

function ForgeCast:OnClickDescTips()
	TipsCtrl.Instance:ShowHelpTipView(153)
end

function ForgeCast:OnClickTotalAttr()
	if self.attr_tips.root_node.gameObject.activeSelf then
		self.attr_tips:SetActive(false)
	else
		self.attr_tips:SetData()
		self.attr_tips:SetActive(true)
	end
end

function ForgeCast:OnClickCloseTips()
	self.attr_tips:SetActive(false)
end

function ForgeCast:FlushStuffItem()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end
	
	local attr = ForgeData.Instance:GetShenOpSingleCfg(self.equip_index, equip_data.param.shen_level + 1)

	if attr then
		local vo = GameVoManager.Instance:GetMainRoleVo()
		self.item_cell:SetData({item_id = attr["stuff_id_prof_" .. vo.prof], num = 0, is_bind = 0})
		local has_num = ItemData.Instance:GetItemNumInBagById(attr["stuff_id_prof_" .. vo.prof])
		if has_num < attr.stuff_count then
			self.item_num:SetValue(ToColorStr(has_num, TEXT_COLOR.RED) .. "/" .. attr.stuff_count)
		else
			self.item_num:SetValue(ToColorStr(has_num, TEXT_COLOR.GREEN) .. "/" .. attr.stuff_count)
		end
	end
end

function ForgeCast:FlushCastAttr()
	local equip_data = EquipData.Instance:GetGridData(self.equip_index)
	if nil == equip_data then return end

	local cur_attr = ForgeData.Instance:GetShenOpSingleCfg(self.equip_index, equip_data.param.shen_level)
	local next_attr = ForgeData.Instance:GetShenOpSingleCfg(self.equip_index, equip_data.param.shen_level + 1)
	if equip_data.param.shen_level >= ForgeData.Instance:GetCastMaxLevel() then
		self.curLevel_go.transform.localPosition = Vector3(0, 33, 0)
		self.curattr_go.transform.localPosition = Vector3(0, -66, 0)
		self.power_go.transform.localPosition = Vector3(0, -240, 0)
	else
		self.curLevel_go.transform.localPosition = Vector3(-122.15, 33, 0)
		self.curattr_go.transform.localPosition = Vector3(-105, -66, 0)
		self.power_go.transform.localPosition = Vector3(0, -185, 0)
	end

	self.is_max_level:SetValue(equip_data.param.shen_level >= ForgeData.Instance:GetCastMaxLevel())
	self.is_total_max_level:SetValue(ForgeData.Instance:GetIsCastMaxLevel())

	if nil == cur_attr or nil == next(cur_attr) then
		local cur_attr_name = ForgeData.Instance:GetCastShowAttr(next_attr)
		self.cur_attr_value:SetValue(0)
		self.cur_attr_name:SetValue(Language.Common.AttrNameNoUnderline[cur_attr_name] .. "：")
		self.cur_power:SetValue(0)
	else
		local cur_attr_name = ForgeData.Instance:GetCastShowAttr(cur_attr)
		self.cur_attr_value:SetValue(cur_attr[cur_attr_name])
		self.cur_attr_name:SetValue(Language.Common.AttrNameNoUnderline[cur_attr_name] .. "：")
		local cur_power = CommonDataManager.GetCapabilityCalculation(cur_attr)
		self.cur_power:SetValue(cur_power)
	end

	if nil ~= next_attr and nil ~= next(next_attr) then
		local next_attr_name = ForgeData.Instance:GetCastShowAttr(next_attr)
		self.next_attr_value:SetValue(next_attr[next_attr_name])
		self.next_attr_name:SetValue(Language.Common.AttrNameNoUnderline[next_attr_name] .. "：")
		local next_power = CommonDataManager.GetCapabilityCalculation(next_attr)
		self.next_power:SetValue(next_power)
	end

	self.cur_level:SetValue(string.format(Language.Forge.ShenZhuLevel, equip_data.param.shen_level))
	self.next_level:SetValue(string.format(Language.Forge.ShenZhuLevel, equip_data.param.shen_level + 1))
	self.now_level:SetValue(string.format(Language.Forge.ShenZhuFormatLevel, equip_data.param.shen_level))

	local total_attr = ForgeData.Instance:GetCastTotalAttr()
	local total_cap = CommonDataManager.GetCapabilityCalculation(total_attr)
	self.total_power:SetValue(total_cap)
end

function ForgeCast:OnFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "all" then
			if v.need_flush == nil or v.need_flush then
				if self.select_index == 1 then
					self.equip_list.scroller:ReloadData(0)
				else
					self.equip_list.scroller:RefreshAndReloadActiveCellViews(true)
				end
			end

			self:FlushCastAttr()
			self:FlushStuffItem()
		end
	end
end

------------------------CastItemCell------------------------------
CastItemCell = CastItemCell or BaseClass(BaseCell)

function CastItemCell:__init()
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

function CastItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function CastItemCell:ClickItem()
	local select_index = self.parent_view:GetSelectIndex()
	self.parent_view:SetSelectIndex(self.index, self.data.index)
	self.parent_view:FlushAllHL()
	self.parent_view:Flush("all", {need_flush = false})
end

function CastItemCell:OnFlush()
	if nil == self.data or nil == next(self.data) then return end

	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.name:SetValue(cfg.name)
	self.item_cell:SetData({item_id = self.data.item_id, num = self.data.num, is_bind = self.data.is_bind})

	self.level:SetValue(string.format(Language.Forge.ShenZhuLevel, self.data.param.shen_level))

	self:FlushHL()

	self.show_red_point:SetValue(ForgeData.Instance:GetCastRemindByIndex(self.data.index))
end

function CastItemCell:FlushHL()
	local select_index = self.parent_view:GetSelectIndex()
	self.show_hl:SetValue(select_index == self.index)
end

----------------CastAttrTips-----------------------
CastAttrTips = CastAttrTips or BaseClass(BaseCell)

function CastAttrTips:__init()
	self.cur_pofang_value = self:FindVariable("cur_pofang_value")
	self.cur_mianshang_value = self:FindVariable("cur_mianshang_value")
	self.next_pofang_value = self:FindVariable("next_pofang_value")
	self.next_mianshang_value = self:FindVariable("next_mianshang_value")
	self.cur_min_level = self:FindVariable("cur_min_level")
	self.next_min_level = self:FindVariable("next_min_level")

	self.progress_desc = self:FindVariable("progress_desc")
	self.progress_num = self:FindVariable("progress_num")
end

function CastAttrTips:__delete()
end

function CastAttrTips:OnFlush()
	local cur_min_level = ForgeData.Instance:GetCastMinLevel()
	self.cur_min_level:SetValue(string.format(Language.Forge.AllShenLevel, cur_min_level))
	self.next_min_level:SetValue(string.format(Language.Forge.AllShenLevel, cur_min_level + 1))

	local cur_shen_cfg = ForgeData.Instance:GetCastCfgByLevel(cur_min_level)
	local next_shen_cfg = ForgeData.Instance:GetCastCfgByLevel(cur_min_level + 1)
	self.cur_pofang_value:SetValue(cur_shen_cfg.per_pofang and (cur_shen_cfg.per_pofang / 100) .. "%" or 0)
	self.cur_mianshang_value:SetValue(cur_shen_cfg.per_mianshang and (cur_shen_cfg.per_mianshang / 100) .. "%" or 0)
	if next_shen_cfg and next(next_shen_cfg) then
		self.next_pofang_value:SetValue((next_shen_cfg.per_pofang / 100) .. "%" or 0)
		self.next_mianshang_value:SetValue((next_shen_cfg.per_pofang / 100) .. "%" or 0)
	end

	local next_min_level = cur_min_level + 1
	next_min_level = next_min_level > ForgeData.Instance:GetCastMaxLevel() and ForgeData.Instance:GetCastMaxLevel() or next_min_level
	local num = ForgeData.Instance:GetCastNumByLevel(next_min_level)
	self.progress_desc:SetValue(string.format(Language.Forge.ShenZhuProgressDesc, next_min_level))
	self.progress_num:SetValue(num .. "/8")
end