ShenGeGroupView = ShenGeGroupView or BaseClass(BaseRender)

-- 神格最大品质
local MAX_QUALITY = 5

-- 组合格子坐标列表
local ITEM_POSITION_LIST = {
	[4] = {
		[1] = {x = -305, y = 123.9},
		[2] = {x = -331.4, y = -49.9},
		[5] = {x = 292.9, y = 35.4},
		[6] = {x = 292.9, y = -142.5},
	},
	[5] = {
		[1] = {x = -314.5, y = 150.5},
		[2] = {x = -283.8, y = -3.5},
		[3] = {x = -320.58, y = -164},
		[5] = {x = 289.8, y = 68.7},
		[6] = {x = 282.6, y = -121.4},
	},
	[6] = {
		[1] = {x = -314.5, y = 150.5},
		[2] = {x = -283.8, y = -3.5},
		[3] = {x = -320.58, y = -164},
		[5] = {x = 291.7, y = 109},
		[6] = {x = 282.6, y = -41.1},
		[7] = {x = 277, y = -198.2},
	},
	[7] = {
		[1] = {x = -305, y = 192.4},
		[2] = {x = -344, y = 66},
		[3] = {x = -270, y = -51.7},
		[4] = {x = -338, y = -171},
		[5] = {x = 252, y = 206},
		[6] = {x = 309, y = 78},
		[7] = {x = 277, y = -35},
	},
	[8] = {
		[1] = {x = -305, y = 192.4},
		[2] = {x = -344, y = 66},
		[3] = {x = -270, y = -51.7},
		[4] = {x = -338, y = -171},
		[5] = {x = 252, y = 206},
		[6] = {x = 309, y = 78},
		[7] = {x = 277, y = -35},
		[8] = {x = 339, y = -158},
	},
}

function ShenGeGroupView:__init(instance)
	self.cur_toggle_index = 1

	self:ListenEvent("OnClickHelp", BindTool.Bind(self.OnClickHelp, self))

	self.toggle_list = {}
	self.button_name_list = {}
	self.show_active_list = {}
	self.show_gray_list = {}
	for i = 1, 5 do
		self:ListenEvent("OnClickButton"..i, BindTool.Bind(self.OnClickButton, self, i))

		self.toggle_list[i] = self:FindObj("Toggle"..i).toggle
		self.button_name_list[i] = self:FindVariable("ButtonName"..i)
		self.show_active_list[i] = self:FindVariable("ShowHadActive"..i)
		self.show_gray_list[i] = self:FindVariable("ShowGray"..i)
	end

	self.group_cell_list = {}
	self.attr_var_list = {}
	for i = 1, 8 do
		self.group_cell_list[i] = ShenGeGroupCell.New(self:FindObj("Item"..i))
		self.attr_var_list[i] = {text = self:FindVariable("Attr"..i), is_show = self:FindVariable("ShowAttr"..i)}
	end

	self.had_active_num = self:FindVariable("HadActiveNum")
	self.total_item_cell = self:FindVariable("TotalItemCellNum")

	self:SetButtonName()
end

function ShenGeGroupView:__delete()
	for k, v in pairs(self.group_cell_list) do
		v:DeleteMe()
	end
	self.group_cell_list = {}
end

function ShenGeGroupView:OnClickButton(index)
	if self.cur_toggle_index == index then
		return
	end

	self:ResetAttr()
	self:Flush()
end

function ShenGeGroupView:OnClickHelp()
	local tips_id = 169
 	TipsCtrl.Instance:ShowHelpTipView(tips_id)
end

function ShenGeGroupView:OnDataChange(info_type, param1, param2, param3)
	if info_type == SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ACTIVE_COMBINE_INFO then
		self:Flush()
	end
end

function ShenGeGroupView:ResetAttr()
	for k, v in pairs(self.attr_var_list) do
		v.is_show:SetValue(false)
	end
end

function ShenGeGroupView:SetAttrAndGroupCellData(index)
	local group_cfg = ShenGeData.Instance:GetShenGeGroupCfg(index)
	if nil == group_cfg then
		return
	end
	local count = 0
	local value = 0
	local attr_count = 1
	local total_active_num = 0
	local value_list = {}
	local quality = 0

	for i = 0, 14 do
		value = group_cfg["type_"..i] or 0
		if value > 0 then
			quality = group_cfg["quality_"..i]

			local actived_num = 0
			for i2 = quality, MAX_QUALITY do
				actived_num = actived_num + ShenGeData.Instance:GetSameQualityInlayDataNum(i, i2)
			end

			if actived_num >= value then
				total_active_num = total_active_num + 1
			end
			table.insert(value_list, {index = i, value = value, actived_num = actived_num, quality = quality})
			count = count + 1
		end

		if nil ~= group_cfg["add_attr_percen_"..i] and group_cfg["add_attr_percen_"..i] > 0 and self.attr_var_list[attr_count] then
			self.attr_var_list[attr_count].is_show:SetValue(true)

			local name = Language.ShenGe.AttrTypeName[group_cfg["attr_type_"..i]]
			local str_format = string.format(Language.ShenGe.AddAttrType, name, group_cfg["add_attr_percen_"..i].."%")
			local attr_str = string.format(Language.ShenGe.AttrColor, SOUL_NAME_COLOR[1], str_format)
			self.attr_var_list[attr_count].text:SetValue(attr_str)
			attr_count = attr_count + 1
		end
	end

	for i = 0, 14 do
		if nil ~= group_cfg["percen_value_"..i] and group_cfg["percen_value_"..i] > 0 and self.attr_var_list[attr_count] then
			self.attr_var_list[attr_count].is_show:SetValue(true)

			local name = Language.ShenGe.EffectAttrType[group_cfg["effect_type_"..i]]
			local percen_value = group_cfg["percen_value_"..i] / 100
			local attr_str = string.format(Language.ShenGe.AttrColor, SOUL_NAME_COLOR[6], name.."\n+"..percen_value.."%")
			self.attr_var_list[attr_count].text:SetValue(attr_str)
			attr_count = attr_count + 1
		end
	end

	if total_active_num >= count then
		total_active_num = string.format(Language.Mount.ShowGreenStr, total_active_num)
	else
		total_active_num = string.format(Language.Mount.ShowRedStr, total_active_num)
	end
	self.had_active_num:SetValue(total_active_num)
	self.total_item_cell:SetValue(count)

	self:SetGroupCellPositionAndAttr(count, value_list)
end

function ShenGeGroupView:SetGroupCellPositionAndAttr(count, value_list)
	local position_list = ITEM_POSITION_LIST[count]
	if nil == position_list then
		return
	end

	local had_set_value_count = 1
	for k, v in pairs(self.group_cell_list) do
		v:SetActive(nil ~= position_list[k])
		if nil ~= position_list[k] and nil ~= value_list[had_set_value_count] then
			v:SetPosition(position_list[k])
			v:SetAttrType(value_list[had_set_value_count].index, value_list[had_set_value_count].value, value_list[had_set_value_count].actived_num, value_list[had_set_value_count].quality)

			had_set_value_count = had_set_value_count + 1
		end
	end
end

function ShenGeGroupView:SetActiveState()
	local info = ShenGeData.Instance:GetShenGeSystemBagInfo(SHENGE_SYSTEM_INFO_TYPE.SHENGE_SYSTEM_INFO_TYPE_ACTIVE_COMBINE_INFO)
	if nil == info then
		return
	end

	local bit_list = bit:d2b(info.param1)
	local gray_index = -1

	for k, v in pairs(self.show_active_list) do
		v:SetValue(bit_list[32 - k + 1] == 1)
		if bit_list[32 - k + 1]  == 0 and gray_index == -1 then
			gray_index = k + 1
		end

		self.show_gray_list[k]:SetValue(bit_list[32 - k + 1]  ~= 1 and gray_index ~= -1 and k >= gray_index)
		self.toggle_list[k].interactable = bit_list[32 - k + 1]  == 1 or gray_index == -1 or k < gray_index
	end

	if not self.toggle_list[self.cur_toggle_index].interactable then
		self.cur_toggle_index = 1
		self.toggle_list[self.cur_toggle_index].isOn = true
	end
end

function ShenGeGroupView:SetButtonName()
	local group_cfg = nil
	for k, v in pairs(self.button_name_list) do
		group_cfg = ShenGeData.Instance:GetShenGeGroupCfg(k)
		if nil ~= group_cfg then
			v:SetValue(group_cfg.name)
		end
	end
end

function ShenGeGroupView:OnFlush(param_list)
	local index = 1
	for k, v in pairs(self.toggle_list) do
		if v.isOn and v.interactable then
			index = k
			break
		end
	end
	self.cur_toggle_index = index

	self:SetAttrAndGroupCellData(index)
	self:SetActiveState()
end


------------ ShenGeGroupCell --------

ShenGeGroupCell = ShenGeGroupCell or BaseClass(BaseRender)

function ShenGeGroupCell:__init(instance)
	self.icon = self:FindVariable("Icon")
	self.actived_num = self:FindVariable("ActivedNum")
	self.need_num = self:FindVariable("NeedNum")
	self.shen_ge_name = self:FindVariable("Name")
	self.show_effect = self:FindVariable("ShowEffect")
	self.rome_icon = self:FindVariable("RomeIcon")
end

function ShenGeGroupCell:__delete()
end

function ShenGeGroupCell:SetAttrType(i, value, actived_num, quality)
	----local actived_num = ShenGeData.Instance:GetSameQualityInlayDataNum(i, quality)

	self.show_effect:SetValue(value <= actived_num)
	if actived_num < value then
		actived_num = string.format(Language.Mount.ShowRedStr, actived_num)
	else
		actived_num = string.format(Language.Mount.ShowGreenStr, actived_num)
	end

	self.actived_num:SetValue(actived_num)
	self.need_num:SetValue(value)
	self.shen_ge_name:SetValue(Language.ShenGe.GroupAttrTypeName[i])

	local item_id = ShenGeData.Instance:GetShenGeItemId(i, 0)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	if nil == item_cfg then
		return
	end
	self.icon:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))

	self.rome_icon:SetAsset(ResPath.GetRomeNumImage(quality))
end

function ShenGeGroupCell:SetPosition(position)
	self.root_node.rect.localPosition = Vector2(position.x, position.y)
end