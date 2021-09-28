ShenShouFulingView = ShenShouFulingView or BaseClass(BaseRender)

ShenShouFulingView.CACHE_SHOW_ID = -1
ShenShouFulingView.CACHE_SOLT_INDEX = -1
MaterialBagCount = 198
MaxType = 10
function ShenShouFulingView:__init(instance, mother_view)
	self.eqlist_data = {}
	self[1] = item_cell
	self.shenshow_grid_list = {}
	self.select_type_index = 0
	self.packbag_item_list = {}

	self.list_view_left = self:FindObj("ListViewLeft")
	local list_delegate_left = self.list_view_left.list_simple_delegate
	list_delegate_left.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsLeft, self)
	list_delegate_left.CellRefreshDel = BindTool.Bind(self.RefreshCellLeft, self)
	self.left_current_equip_index = -1
	self.left_contain_cell_list = {}
	self.list_view_left.scroller.scrollerScrolled = BindTool.Bind(self.ScrollerScrolledDelegate, self)

	self.list_view_right = self:FindObj("ListViewRight")
	local list_delegate_right = self.list_view_right.list_simple_delegate
	list_delegate_right.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCellsRight, self)
	list_delegate_right.CellRefreshDel = BindTool.Bind(self.RefreshCellRight, self)
	self.right_current_suit_index = -1
	self.right_contain_cell_list = {}
	self.count = 0

	self.select_equip = self:FindObj("select_equip")
	self.select_equip_item = ShenShouEquip.New()
	self.select_equip_item:SetInstanceParent(self.select_equip)

	self.is_click_select = self:FindVariable("is_click_select")
	self.is_click_select:SetValue(false)

	self:ListenEvent("ClickUpGrade", BindTool.Bind(self.ClickUpGrade, self))
	self:ListenEvent("ClickSelectMaterialQuality", BindTool.Bind(self.ClickSelectMaterialQuality, self))
	self:ListenEvent("ClickDouble", BindTool.Bind(self.ClickDouble, self))
	self:ListenEvent("ClickAllSelect", BindTool.Bind(self.ClickAllSelect, self))
	self:ListenEvent("ClickHelp" ,BindTool.Bind(self.ClickHelp, self))

	self.double_toggle = self:FindObj("double_toggle")
	self.all_toggle = self:FindObj("all_toggle")

	self.exp_slider = self:FindVariable("exp_slider")

	self.show_attr = self:FindVariable("show_attr")

	self.current_level = self:FindVariable("current_level")
	self.next_level = self:FindVariable("next_level")

	self.select_type = self:FindVariable("select_type")
	self.select_type:SetValue(Language.ShenShou.SelectType[self.select_type_index + 1])

	self.current_shuliandu = self:FindVariable("current_shuliandu")
	self.add_shuliandu = self:FindVariable("add_shuliandu")
	self.need_shuliandu = self:FindVariable("need_shuliandu")
	self.cap = self:FindVariable("cap")

	self.attr_list = {}
	self.attr_name_list = {}
	self.attr_add_list = {}
	self.is_show_attr_list = {}
	self.attr_icon_list = {}
	for i = 1, 3 do
		self.attr_list[i] = self:FindVariable("attr_"..i)
		self.attr_name_list[i] = self:FindVariable("attr_"..i.."_name")
		self.attr_add_list[i] = self:FindVariable("attr_"..i.."_add")
		self.is_show_attr_list[i] = self:FindVariable("is_show_attr_list_"..i)
		self.attr_icon_list[i] = self:FindVariable("attr_icon_"..i)
	end

	self.is_double = false
	self.is_select_all = false
	self.double_toggle.toggle.isOn = false
	self.all_toggle.toggle.isOn = false
	self.is_jum_flag = false
end

function ShenShouFulingView:__delete()
	self.select_equip_item:DeleteMe()

	for k,v in pairs(self.left_contain_cell_list) do
		v:DeleteMe()
	end
	self.left_contain_cell_list = {}

	for k,v in pairs(self.right_contain_cell_list) do
		v:DeleteMe()
	end
	self.right_contain_cell_list = {}
	self.packbag_item_list = {}

	self.is_double = false
	self.is_select_all = false
	self.double_toggle.toggle.isOn = false
	self.all_toggle.toggle.isOn = false
	self.select_type_index = 0
end

function ShenShouFulingView:OpenCallBack()
	self.is_double = false
	self.is_select_all = false
	self.double_toggle.toggle.isOn = false
	self.all_toggle.toggle.isOn = false
	self.select_type_index = 0
	self:FlushHightLight()

	self:FlushView()
end

function ShenShouFulingView:FlushView()
	--拿到强化装备列表
	self.eqlist_data = ShenShouData.Instance:GetShenShouEqListData()
	if next(self.eqlist_data) then
		self.left_current_equip_index = 1
		for k,v in pairs(self.eqlist_data) do
			if ShenShouFulingView.CACHE_SHOW_ID == v.shou_id and ShenShouFulingView.CACHE_SOLT_INDEX == v.slot_index then
				self.left_current_equip_index = k
				self.is_jum_flag = true
				ShenShouFulingView.CACHE_SHOW_ID = -1
				ShenShouFulingView.CACHE_SOLT_INDEX = -1
			end
		end
	else
		self.left_current_equip_index = 0
	end
	if self.is_jum_flag then
		self.list_view_left.scroller:ReloadData(1)
	else
		self.list_view_left.scroller:ReloadData(0)
	end

	self:FlushMiddleContent()
	--拿到背包信息
	self.shenshow_grid_list = ShenShouData.Instance:GetShenshouGridList()
	self.list_view_right.scroller:ReloadData(0)
end

function ShenShouFulingView:CheckToJump(index)
	self.list_view_left.scroller:JumpToDataIndex(index - 1)
	self.is_jum_flag = false
end

function ShenShouFulingView:ScrollerScrolledDelegate(go, param1, param2, param3)
	if self.is_jum_flag then
		self:CheckToJump(self.left_current_equip_index)
	end
end

--左边列表
function ShenShouFulingView:GetNumberOfCellsLeft()
	return #self.eqlist_data or 0
end

function ShenShouFulingView:RefreshCellLeft(cell, cell_index)
	local contain_cell = self.left_contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = FulingEquipItem.New(cell.gameObject)
		self.left_contain_cell_list[cell] = contain_cell
		contain_cell:SetClickCallBack(BindTool.Bind(self.OnClickEquip, self))
		contain_cell:SetToggleGroup(self.list_view_left.toggle_group)
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)
	contain_cell:SetData(self.eqlist_data[cell_index])
	if cell_index ~= self.left_current_equip_index then
		contain_cell.bg_toggle.toggle.isOn = false
	else
		contain_cell.bg_toggle.toggle.isOn = true
	end
end

function ShenShouFulingView:OnClickEquip(equip_cell)
	self.left_current_equip_index = equip_cell:GetIndex()
	self:FlushMiddleContent()
end

--右边列表
function ShenShouFulingView:GetNumberOfCellsRight()
	return  MaterialBagCount / 3
end

function ShenShouFulingView:RefreshCellRight(cell, cell_index)
	local contain_cell = self.right_contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = FulingItemGroup.New(cell.gameObject)
		self.right_contain_cell_list[cell] = contain_cell
		for i = 1, 3 do
			local index = 3 * cell_index - 3 + i
			self.packbag_item_list[index] = contain_cell.item_cell_list[i]
			self.packbag_item_list[index].item_cell:ListenClick(BindTool.Bind(self.OnClickItemCell, self, self.packbag_item_list[index], self.packbag_item_list[index].item_cell, index))
		end
	end
	cell_index = cell_index + 1
	contain_cell:SetIndex(cell_index)

	local data = {}
	for i = 3 * cell_index - 2, cell_index * 3 do
		if nil ~= self.shenshow_grid_list[i] then
			table.insert(data, self.shenshow_grid_list[i])
		else
			table.insert(data, {})
		end
	end
	contain_cell:SetSelectType(self.select_type_index)
	contain_cell:SetData(data)

	for i = 1, 3 do
		local index = 3 * cell_index - 3 + i
		self.packbag_item_list[index] = contain_cell.item_cell_list[i]
		local cell = contain_cell.item_cell_list[i].item_cell
		if next(contain_cell.item_cell_list[i]:GetData()) and true == contain_cell.item_cell_list[i]:GetIsSelect() then
			cell:SetToggle(true)
			cell:ShowHighLight(true)
		else
			cell:SetToggle(false)
			cell:ShowHighLight(false)
		end
	end
end

function ShenShouFulingView:OnClickItemCell(parent_cell, item_cell, index)
	local is_show = item_cell.show_high_light:GetBoolean()
	item_cell:SetToggle(true)
	item_cell:ShowHighLight(not is_show)
	parent_cell:SetIsSelect(not is_show)
	self:FlushAddShuliandu()
end

function ShenShouFulingView:FlushMiddleContent()
	self.current_equip_data = ShenShouData.Instance:GetCurEqData(self.left_current_equip_index)
	if nil ~= self.current_equip_data then

		--GetShenshouLevelList(slot_index, strength_level)
		local attr_list = self.current_equip_data.attr_list
		local strength_level = self.current_equip_data.strength_level
		self.current_level:SetValue(strength_level)
		self.next_level:SetValue(strength_level)
		self.select_equip_item:SetData(self.current_equip_data)
		self.select_equip_item:SetInteractable(false)
		local shuliandu = self.current_equip_data.shuliandu
		self.current_shuliandu:SetValue(shuliandu)
		local current_info = ShenShouData.Instance:GetShenshouLevelList(self.current_equip_data.slot_index, strength_level)
		local next_info = ShenShouData.Instance:GetShenshouLevelList(self.current_equip_data.slot_index, strength_level + 1)

		local attar_info = {}

		if next_info ~= nil then
			for k,v in pairs(next_info) do
				if nil ~= Language.ShenShou.Attr[k] and 0 ~= v then
				table.insert(attar_info, {key = k, name = Language.ShenShou.Attr[k], value = v,})
				end
			end
		end

		local attr_count = #attar_info
		local total_attr_struct = CommonStruct.AttributeNoUnderline()
		for i = 1 , 3 do
			self.is_show_attr_list[i]:SetValue(i <= attr_count)
			if i <= attr_count then
				self.attr_icon_list[i]:SetAsset(ResPath.GetBaseAttrIcon(attar_info[i].key))
				self.attr_list[i]:SetValue(current_info[attar_info[i].key])
				self.attr_name_list[i]:SetValue(attar_info[i].name)
				self.attr_add_list[i]:SetValue(attar_info[i].value - current_info[attar_info[i].key])
				total_attr_struct[attar_info[i].key] = current_info[attar_info[i].key]
			end
		end
		local capability = CommonDataManager.GetCapability(total_attr_struct)
		self.cap:SetValue(capability)

		self.need_shuliandu:SetValue(current_info.upgrade_need_shulian)
		if 0 == shuliandu or 0 == current_info.upgrade_need_shulian then
			self.exp_slider:SetValue(0)
		else
			self.exp_slider:SetValue(shuliandu / current_info.upgrade_need_shulian)
		end

		self.show_attr:SetValue(true)

		self:FlushAddShuliandu()
	else
		self:ClearContent()
	end
end

function ShenShouFulingView:ClearContent()
	self.exp_slider:SetValue(0)
	self.current_shuliandu:SetValue(0)
	self.add_shuliandu:SetValue(0)
	self.need_shuliandu:SetValue(0)

	self.show_attr:SetValue(false)

	self.is_double = false
	self.is_select_all = false
	self.double_toggle.toggle.isOn = false
	self.all_toggle.toggle.isOn = false
	self.select_equip_item:SetData({})
end

function ShenShouFulingView:ClickDouble()
	self.is_double = not self.is_double
	self.double_toggle.toggle.isOn = self.is_double
	self:FlushAddShuliandu()
end

function ShenShouFulingView:ClickAllSelect()
	self.is_select_all = not self.is_select_all
	self.all_toggle.toggle.isOn = self.is_select_all

	self.select_type_index = self.all_toggle.toggle.isOn and MaxType or 0

	self:FlushHightLight()
end

function ShenShouFulingView:FlushHightLight()
	for k,v in pairs(self.shenshow_grid_list) do
		local item_cfg = ShenShouData.Instance:GetShenShouEqCfg(v.item_id)
		if item_cfg.quality < self.select_type_index then
			v.is_select = true
		else
			if self.select_type_index > 0 and 0 == item_cfg.is_equip then
				v.is_select = true
			else
				v.is_select = false
			end
		end

	end
	-- self.list_view_right.scroller:RefreshActiveCellViews()
	self.list_view_right.scroller:ReloadData(0)

	for k,v in pairs(self.packbag_item_list) do
		if next(v:GetData()) and true == v:GetIsSelect() then
			v.item_cell:SetToggle(true)
			v.item_cell:ShowHighLight(true)
		else
			v.item_cell:SetToggle(false)
			v.item_cell:ShowHighLight(false)
		end
	end
	self:FlushAddShuliandu()
end

function ShenShouFulingView:ClickSelectMaterialQuality()
	self.is_click_select:SetValue(not self.is_click_select:GetBoolean())
	local function func(index)
		self.select_type_index = index
		self:FlushHightLight()
		self.select_type:SetValue(Language.ShenShou.SelectType[self.select_type_index + 1])
	end

	local function close_call_back()
		self.is_click_select:SetValue(not self.is_click_select:GetBoolean())
	end
	ShenShouCtrl.Instance:SetFulingSelectMaterialViewCloseCallBack(close_call_back)
	ShenShouCtrl.Instance:SetFulingSelectMaterialViewCallBack(func)
	ViewManager.Instance:Open(ViewName.FulingSelectMaterialView)
end

function ShenShouFulingView:FlushAddShuliandu()
	local total_shulian = 0
	self.count = 0
	if nil == self.current_equip_data or self.current_equip_data.strength_level == GameEnum.SHENSHOU_EQ_MAX_LV or not next(self.current_equip_data) then
		self.add_shuliandu:SetValue(0)
		return
	end
	for k,v in pairs(self.shenshow_grid_list) do
		if v.is_select == true then
			local current_material_info = ShenShouData.Instance:GetShenShouEqCfg(v.item_id)
			local current_info = ShenShouData.Instance:GetShenshouLevelList(current_material_info.slot_index, v.strength_level)

			total_shulian = total_shulian + current_info.contain_shulian + v.shuliandu + current_material_info.contain_shulian
			--如果是双倍 --剔除已经进阶的
			if self.is_double then
				if v.strength_level > 0 then
				else
					self.count = self.count + current_material_info.contain_shulian * 2
					total_shulian = total_shulian + current_material_info.contain_shulian
				end
			end
		end
	end
	self.add_shuliandu:SetValue(total_shulian)
	local all_info = ShenShouData.Instance:GetLevelInfoByIndex(self.current_equip_data.slot_index)

	local current_level_info = ShenShouData.Instance:GetShenshouLevelList(self.current_equip_data.slot_index, self.current_equip_data.strength_level)

	total_shulian = current_level_info.contain_shulian + total_shulian + self.current_equip_data.shuliandu

	for k,v in pairs(all_info) do
		if total_shulian < v.contain_shulian then
			self.next_level:SetValue(v.strength_level - 1)
			return
		end
	end
end

function ShenShouFulingView:ClickUpGrade()
	if nil == self.current_equip_data or not next(self.current_equip_data) or self.current_equip_data.strength_level == GameEnum.SHENSHOU_EQ_MAX_LV then
		return
	end
	--shenshou_id, equip_index, is_double_shuliandu, destroy_num, destroy_backpack_index_list

	local destroy_list_1, destroy_list_2 = self:GetDestroyList()
	local is_double_shuliandu = 0
	if not next(destroy_list_1) and not next(destroy_list_2) then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShenShou.NoSelect)
		return
	end
	if self.is_double then
		--如果双倍
		is_double_shuliandu = 1

		local function close_callback()
			if next(destroy_list_1) then
				ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
					is_double_shuliandu, #destroy_list_1, destroy_list_1)
			end
			if next(destroy_list_2) then
				ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
					0, #destroy_list_2, destroy_list_2)
			end
		end

		local cost = math.floor(self.count / ShenShouData.Instance:GetOther()[1].equip_double_shulian_per_gold)
		local str = string.format(Language.ShenShou.FulingTips, cost)
		TipsCtrl.Instance:ShowCommonAutoView("", str, close_callback)
	else
		is_double_shuliandu = 0
		if next(destroy_list_1) then
			ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
				is_double_shuliandu, #destroy_list_1, destroy_list_1)
		end
		if next(destroy_list_2) then
			ShenShouCtrl.Instance:SendSHenshouReqStrength(self.current_equip_data.shou_id, self.current_equip_data.slot_index,
				0, #destroy_list_2, destroy_list_2)
		end
	end
end

function ShenShouFulingView:GetDestroyList()
	local select_material_list = {}
	local has_strength_list = {}
	for k,v in pairs(self.shenshow_grid_list) do
		if v.is_select == true then
			if v.strength_level > 0 then
				table.insert(has_strength_list, v.index)
			else
				table.insert(select_material_list, v.index)
			end
		end
	end
	return select_material_list, has_strength_list
end

function ShenShouFulingView:OnFlush(param_t)
	self.eqlist_data = ShenShouData.Instance:GetShenShouEqListData()
	self.list_view_left.scroller:ReloadData(0)
	local index = self.left_current_equip_index - 1
	if #self.eqlist_data - self.left_current_equip_index < 4 then
		index = self.left_current_equip_index - 5
	end
	self.list_view_left.scroller:JumpToDataIndex(index)

	--拿到背包信息
	self.shenshow_grid_list = ShenShouData.Instance:GetShenshouGridList()
	self.list_view_right.scroller:ReloadData(0)
	self:FlushMiddleContent()
end

function ShenShouFulingView:ClickHelp()
	TipsCtrl.Instance:ShowHelpTipView(221)
end
--------------------------------FulingEquipItem-----------------------------------
FulingEquipItem = FulingEquipItem or BaseClass(BaseCell)
function FulingEquipItem:__init()
	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))

	self.bg_toggle = self:FindObj("bg_toggle")
	self.show_rep = self:FindVariable("show_rep")
	self.equip_name = self:FindVariable("equip_name")
	self.yinling_name = self:FindVariable("yinling_name")

	self.item_cell_obj = self:FindObj("item")
	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.item_cell_obj)
	self.item_cell:ShowHighLight(false)
	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function FulingEquipItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function FulingEquipItem:SetIndex(index)
	self.index = index
end

function FulingEquipItem:GetIndex()
	return self.index or 0
end

function FulingEquipItem:ClickItem()
	BaseCell.OnClick(self)
	self.bg_toggle.toggle.isOn = true
end

function FulingEquipItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data)
		local config = ShenShouData.Instance:GetShenShouEqCfg(self.data.item_id)
		self.equip_name:SetValue(config.name)
		local cfg = ShenShouData.Instance:GetShenShouCfg(self.data.shou_id)
		self.yinling_name:SetValue("<color="..ITEM_TIP_COLOR[cfg.quality]..">"..cfg.name.."</color>")
	end
end

function FulingEquipItem:SetToggleGroup(toggle_group)
	if self.bg_toggle.toggle then
		self.bg_toggle.toggle.group = toggle_group
	end
end

--------------------------------------FulingItemGroup--------------------------------------
FulingItemGroup = FulingItemGroup or BaseClass(BaseCell)
function FulingItemGroup:__init()
	self.item_cell_list = {}
	for i = 1, 3 do
		local item_cell_obj = self:FindObj("item_"..i)
		self.item_cell_list[i] = FulingMaterialItem.New(item_cell_obj.gameObject)
	end
	self.type = 0
end

function FulingItemGroup:__delete()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function FulingItemGroup:SetIndex(index)
	self.index = index
	for k,v in pairs(self.item_cell_list) do
		v:SetIndex(3 * (index - 1) + k)
	end
end

function FulingItemGroup:SetSelectType(type)
	self.type = type
end

function FulingItemGroup:OnFlush()
	self.data = self:GetData()
	for k,v in pairs(self.item_cell_list) do
		v:SetSelectType(self.type)
		v:SetData(self.data[k])
	end
end

--------------------------------------FulingMaterialItem--------------------------------------
FulingMaterialItem = FulingMaterialItem or BaseClass(BaseCell)
function FulingMaterialItem:__init()
	self.item_cell = ShenShouEquip.New()
	self.item_cell:SetInstanceParent(self.root_node)
	self.type = 0
end

function FulingMaterialItem:__delete()
	self.item_cell:DeleteMe()
end

function FulingMaterialItem:SetIndex(index)
	self.index = index
end

function FulingMaterialItem:GetIndex()
	return self.index or 0
end

function FulingMaterialItem:SetSelectType(type)
	self.type = type
end

function FulingMaterialItem:OnFlush()
	self.data = self:GetData()
	if next(self.data) then
		self.item_cell:SetData(self.data)
	else
		self.item_cell:SetData({})
	end
end

function FulingMaterialItem:GetIsSelect()
	return self.data.is_select or false
end

function FulingMaterialItem:SetIsSelect(enable)
	if next(self.data) then
		self.data.is_select = enable
	end
end
