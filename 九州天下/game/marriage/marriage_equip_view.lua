MarriageEquipView = MarriageEquipView or BaseClass(BaseRender)

local BAG_ROW = 2
local BAG_COLUMN = 5

local EquipIdList = {27013, 27058, 27103, 27148}
function MarriageEquipView:__init()
	self.equip_select_index = 1

	self.gua_ji_item_index = 0 					--选择的挂机吸收的装备类型
	self.select_toggle_index = 0 				--选择的挂机吸收的装备品质

	self.select_use_item_list = {}				--选择融合的物品列表

	self.is_in_levelup = true					--是否在升级打造面板

	self.bag_cell_list = {}
	self.bag_data = {}

	--装备信息
	self.equip_item_list = {}
	for i = 1, 4 do
		local item = self:FindObj("Equip" .. i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item)
		local data = {}
		data.item_id = EquipIdList[i]
		item_cell:SetData(data)
		item_cell:ShowQuality(false)
		item_cell:SetIconGrayScale(true)
		item_cell.root_node.toggle:AddValueChangedListener(BindTool.Bind(self.OnEquipToggleChange,self, i, item_cell))
		item_cell:ListenClick(BindTool.Bind(self.EquipItemClick, self, i, item_cell))
		table.insert(self.equip_item_list, item_cell)
	end

	self.bag_list = self:FindObj("BagList")
	self.role_display = self:FindObj("RoleDisplay")
	self.toggle1 = self:FindObj("Toggle1")

	local scroller_delegate = self.bag_list.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	--装备名字相关
	self.select_equip_name = self:FindVariable("SelectEquipName")
	self.now_level = self:FindVariable("NowLevel")
	self.next_level = self:FindVariable("NextLevel")

	--属性相关
	self.now_attr1 = self:FindVariable("NowAttr1")
	self.now_attr2 = self:FindVariable("NowAttr2")
	self.next_attr1 = self:FindVariable("NextAttr1")
	self.next_attr2 = self:FindVariable("NextAttr2")
	self.now_power = self:FindVariable("NowPower")
	self.next_power = self:FindVariable("NextPower")

	--进度条相关
	self.now_exp = self:FindVariable("NowExp")
	self.add_exp = self:FindVariable("AddExp")
	self.need_exp = self:FindVariable("NeedExp")
	self.progress = self:FindVariable("Progress")
	self.add_progress = self:FindVariable("AddProgress")

	self.show_dazhao_btn = self:FindVariable("ShowDaZhaoBtn")
	self.set_toggle_active = self:FindVariable("SetToggleActive")
	self.show_next = self:FindVariable("ShowNext")

	self.have_equip = self:FindVariable("HaveEquip")
	self.equip_name = self:FindVariable("EquipName")
	self.show_auto_select = self:FindVariable("ShowAutoSelect")
	self.show_two_attr = self:FindVariable("ShowTwoAttr")
	self.show_guaji_view = self:FindVariable("ShowGuaJiView")

	for i = 1, 6 do
		local toggle_btn = self:FindObj("SelectQuilty" .. i)
		toggle_btn.toggle:AddValueChangedListener(BindTool.Bind(self.SelectQuiltyChange, self, i))
	end

	self.guaji_item_list = {}
	for i = 1, 4 do
		local guaji_item = self:FindObj("GuaJiItem" .. i)
		item_cell = ItemCell.New()
		item_cell:SetInstanceParent(guaji_item)
		item_cell:AddValueChangedListener(BindTool.Bind(self.SelectEquipChange, self, i))

		item_cell:SetData(nil)
		table.insert(self.guaji_item_list, item_cell)
	end

	local select_list = self:FindObj("SelectTable")
	local count = select_list.transform.childCount
	self.gua_ji_select_list = {}
	for i = 0, count - 1 do
		local child = select_list.transform:GetChild(i).gameObject
		local toggle = child:GetComponent(typeof(UnityEngine.UI.Toggle))
		toggle:AddValueChangedListener(BindTool.Bind(self.SelectToggleChange, self, i + 1))
		table.insert(self.gua_ji_select_list, toggle)
	end

	self:ListenEvent("ClickGuaJiSet", BindTool.Bind(self.ClickGuaJiSet, self))
	self:ListenEvent("ClickDaZhao", BindTool.Bind(self.ClickDaZhao, self))
	self:ListenEvent("ClickBack", BindTool.Bind(self.ClickBack, self))
	self:ListenEvent("ClickAutoSelect", BindTool.Bind(self.ClickAutoSelect, self))
	self:ListenEvent("ClickUpLevel", BindTool.Bind(self.ClickUpLevel, self))
	self:ListenEvent("CloseAutoSelect", BindTool.Bind(self.CloseAutoSelect, self))
	self:ListenEvent("CloseGuaJiView", BindTool.Bind(self.CloseGuaJiView, self))
	self:ListenEvent("ClickConserve", BindTool.Bind(self.ClickConserve, self))
end

function MarriageEquipView:__delete()
	for k, v in ipairs(self.equip_item_list) do
		v:DeleteMe()
	end
	self.equip_item_list = {}

	for k, v in pairs(self.bag_cell_list) do
		v:DeleteMe()
	end
	self.bag_cell_list = {}

	for k, v in ipairs(self.guaji_item_list) do
		v:DeleteMe()
	end
	self.guaji_item_list = {}
end

function MarriageEquipView:CloseAutoSelect()
	self.show_auto_select:SetValue(false)
end

function MarriageEquipView:CloseGuaJiView()
	self.show_guaji_view:SetValue(false)
end

function MarriageEquipView:ClickConserve()
	local equip_index = self.gua_ji_item_index			--挂机选择吸收的装备
	local select_index = self.select_toggle_index		--挂机选择吸收的品质
	if select_index > 0 and equip_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.SelectEquipDes)
		return
	end
	local item_id = equip_index * 10 + select_index
	MarriageData.Instance:SetGuaJiSettingParam(item_id)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.MARRY_EQUIP, item_id)
	SysMsgCtrl.Instance:ErrorRemind(Language.Role.FashionSaveTips[2])
	self.show_guaji_view:SetValue(false)
end

function MarriageEquipView:SelectEquipChange(i, ison)
	if ison then
		self.gua_ji_item_index = i
	else
		self.gua_ji_item_index = 0
	end
end

function MarriageEquipView:SelectToggleChange(i, ison)
	if ison then
		self.select_toggle_index = i
	else
		self.select_toggle_index = 0
	end
end

--选择品质
function MarriageEquipView:SelectQuiltyChange(i)
	self.show_auto_select:SetValue(false)
	self.select_use_item_list = {}
	for k, v in ipairs(self.bag_data) do
		if i == 6 then
			self.select_use_item_list[k-1] = v
		else
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id) or {}
			local color = item_cfg.color
			if color <= i then
				self.select_use_item_list[k-1] = v
			end
		end
	end
	self.bag_list.scroller:ReloadData(0)
	self:FlushProgress()
end

function MarriageEquipView:OnEquipToggleChange(index, cell, ison)
	if ison then
		local data = cell:GetData()
		if data.locked then
			cell:SetHighLight(false)
			SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.MarryOpenEquipDes)
			self.equip_item_list[4]:SetHighLight(true)
			return
		end
		if index == self.equip_select_index then
			return
		end
		self.equip_select_index = index
		MarriageData.Instance:SetSelectEquipIndex(index)
		self:FlushAttrList()
		-- if not self.is_in_levelup then
		self:FlushBagList()
		-- end
	end
end

function MarriageEquipView:EquipItemClick(index, cell)
	if self.equip_select_index == index then
		cell:SetHighLight(true)
		return
	end
end

function MarriageEquipView:ClickGuaJiSet()
	self.show_guaji_view:SetValue(true)
	self:FlushGuaJiView()
end

function MarriageEquipView:ClickDaZhao()
	self.select_use_item_list = {}
	self.is_in_levelup = not self.is_in_levelup
	self.show_dazhao_btn:SetValue(self.is_in_levelup)
	self:FlushBagList()
	self:FlushAttrList()
end

function MarriageEquipView:ClickBack()
	self.select_use_item_list = {}
	self.is_in_levelup = not self.is_in_levelup
	self.show_dazhao_btn:SetValue(self.is_in_levelup)
	self:FlushBagList()
	self:FlushAttrList()
end

function MarriageEquipView:ClickAutoSelect()
	self.show_auto_select:SetValue(true)
end

function MarriageEquipView:ClickUpLevel()
	if not next(self.select_use_item_list) then
		SysMsgCtrl.Instance:ErrorRemind(Language.Marriage.SelectEquipUpLevelDes)
		return
	end

	for k, v in pairs(self.select_use_item_list) do
		MarriageCtrl.Instance:SendQingyuanUpLevel(v.item_id, self.equip_select_index - 1)
	end
end

function MarriageEquipView:GetNumberOfCells()
	local num = math.ceil(#self.bag_data/(BAG_ROW*BAG_COLUMN)) * BAG_COLUMN
	return num < 1 and BAG_COLUMN or num
end

function MarriageEquipView:RefreshCell(cell, data_index)
	local grounp_cell = self.bag_cell_list[cell]
	if not grounp_cell then
		grounp_cell = MarryEquipItemCell.New(cell.gameObject)
		grounp_cell:SetParent(self) 
		self.bag_cell_list[cell] = grounp_cell
	end

	-- if self.is_in_levelup then
	-- 	grounp_cell:SetToggleGrounp(nil)
	-- else
	-- 	grounp_cell:SetToggleGrounp(self.bag_list.toggle_group)
	-- end

	local page = math.floor(data_index / BAG_COLUMN)
	local column = data_index - page * BAG_COLUMN
	local grid_count = BAG_COLUMN * BAG_ROW
	for i = 1, BAG_ROW do
		local index = (i - 1) * BAG_COLUMN  + column + (page * grid_count)
		local data = self.bag_data[index + 1] or {}
		grounp_cell:SetHighLight(false, i)
		grounp_cell:SetData(data, i)
		grounp_cell:ListenClick(BindTool.Bind(self.BagItemCellClick, self, index, data, grounp_cell, i), i)
		if not next(data) then
			grounp_cell:SetInteractable(false, i)
		else
			grounp_cell:SetInteractable(true, i)
		end
	end
end

function MarriageEquipView:BagItemCellClick(index, data, group, i)
	if data.item_id == 0 then
		return
	end

	local function close_call_back()
		if not IsNil(group.root_node.gameObject) then
			group:SetHighLight(false, i)
		end
	end
	if not self.is_in_levelup then
		TipsCtrl.Instance:OpenItem(data, TipsFormDef.FROM_QINGYUAN_BAG, nil, close_call_back)
	else
		if group:GetToggleIsOn(i) then
			self.select_use_item_list[index] = data
		else
			self.select_use_item_list[index] = nil
		end
		self:FlushProgress()
	end
end

function MarriageEquipView:FlushGuaJiView()
	--设置装备信息
	local equip_list = MarriageData.Instance:GetQyEquipInfoList()
	for k, v in ipairs(equip_list) do
		if v.item_id > 0 then
			local data = {}
			data.item_id = v.item_id
			self.guaji_item_list[k]:SetData(data)
			self.guaji_item_list[k]:ShowStrengthLable(true)
			self.guaji_item_list[k]:SetStrength(v.level)
		else
			local data = {}
			data.locked = true
			self.guaji_item_list[k]:SetData(data)
			self.guaji_item_list[k]:SetInteractable(false)
		end
		self.guaji_item_list[k]:ClearItemEvent()
	end

	--设置选中信息
	local param = MarriageData.Instance:GetGuaJiSettingParam()
	local equip_select, select_index = GameMath.SplitNum(param)
	if equip_select == 0 or select_index == 0 then
		self.gua_ji_item_index = 0
		for k, v in ipairs(self.guaji_item_list) do
			v:SetHighLight(false)
		end

		self.select_toggle_index = 1
		for k, v in ipairs(self.gua_ji_select_list) do
			v.isOn = false
		end
	else
		self.gua_ji_item_index = equip_select
		self.select_toggle_index = select_index

		self.guaji_item_list[equip_select]:SetHighLight(true)
		self.gua_ji_select_list[select_index].isOn = true
	end
end

--刷新进度条
function MarriageEquipView:FlushProgress()
	local index = self.equip_select_index
	local equip_data = MarriageData.Instance:GetQyEquipInfoBySlot(index)
	if equip_data then
		local now_exp = equip_data.cur_exp
		self.now_exp:SetValue(now_exp)

		local add_des = ""
		local add_exp = 0
		for k, v in pairs(self.select_use_item_list) do
			local temp_add_exp = MarriageData.Instance:GetAddExpByItemId(v.item_id)
			add_exp = add_exp + temp_add_exp
		end
		if add_exp > 0 then
			add_des = "+" .. tostring(add_exp)
		end
		self.add_exp:SetValue(add_des)

		local level_info = MarriageData.Instance:GetLevelInfo(index, equip_data.level)
		local need_exp = level_info.max_exp or 0
		self.need_exp:SetValue(need_exp)
		if need_exp > 0 then
			self.progress:SetValue(now_exp/need_exp)
			self.add_progress:SetValue((add_exp + now_exp)/need_exp)
		end
	else
		self.now_exp:SetValue(0)
		self.add_exp:SetValue("")
		self.need_exp:SetValue(0)
		self.progress:SetValue(0)
	end
end

function MarriageEquipView:FlushAttrList()
	local index = self.equip_select_index
	--获取服务端发过来的装备信息
	local equip_data = MarriageData.Instance:GetQyEquipInfoBySlot(index)
	self:FlushProgress()

	self.show_next:SetValue(self.is_in_levelup)
	if equip_data then
		if equip_data.item_id <= 0 then
			self.have_equip:SetValue(false)
			local equip_name = Language.Marriage.EquipName[index] or ""
			self.equip_name:SetValue(equip_name)
		else
			self.have_equip:SetValue(true)
			local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id) or {}
			local item_name = item_cfg.name or ""
			if item_name ~= "" then
				item_name = ToColorStr(item_name, ITEM_COLOR[item_cfg.color])
			end
			self.select_equip_name:SetValue(item_name)

			self.now_level:SetValue(equip_data.level)

			--展示当前属性
			local data = MarriageData.Instance:GetAttrList(equip_data.item_id, equip_data.level)
			local now_capability = CommonDataManager.GetCapability(data)
			self.now_power:SetValue(now_capability)
			local set_num = 0
			for k, v in pairs(data) do
				if set_num > 2 then
					break
				end
				if v > 0 then
					set_num = set_num + 1
					local attr_name = Language.Common.AttrName[k]
					local des = string.format("%s: <color=#00ff00>%s</color>", attr_name, v)
					self["now_attr" .. set_num]:SetValue(des)
				end
			end
			self.show_two_attr:SetValue(set_num >= 2)

			if self.is_in_levelup then
				--展示下级属性
				local next_data = MarriageData.Instance:GetAttrList(equip_data.item_id, equip_data.level + 1)
				if not next(next_data) then
					self.show_next:SetValue(false)
					return
				end
				local next_capability = CommonDataManager.GetCapability(next_data)
				self.next_power:SetValue(next_capability)
				local next_set_num = 0
				for k, v in pairs(next_data) do
					if next_set_num > 2 then
						break
					end
					if v > 0 then
						next_set_num = next_set_num + 1
						local attr_name = Language.Common.AttrName[k]
						local des = string.format("%s: <color=#00ff00>%s</color>", attr_name, v)
						self["next_attr" .. next_set_num]:SetValue(des)
					end
				end

				self.next_level:SetValue(equip_data.level + 1)
			end
		end
	end
end

function MarriageEquipView:FlushBagList()
	local data = {}
	self.select_use_item_list = {}
	if not self.is_in_levelup then
		data = MarriageData.Instance:GetQualityListByIndex(index)
	else
		local index = self.equip_select_index
		data = MarriageData.Instance:GetCanUpLevelEquipList(index)
	end
	self.bag_data = data
	local page = math.ceil(#self.bag_data/(BAG_ROW*BAG_COLUMN))
	page = page < 1 and 1 or page
	self.set_toggle_active:SetValue(page)
	self.bag_list.list_page_scroll:SetPageCount(page)
	self.bag_list.scroller:ReloadData(0)
	if page > 1 then
		self.toggle1.toggle.isOn = true
	end
end

--打开情缘装备界面回调
function MarriageEquipView:OpenEquipViewCallBack()
	self.show_guaji_view:SetValue(false)
	self.show_auto_select:SetValue(false)
	-- self.is_in_levelup = false
	-- self.show_dazhao_btn:SetValue(self.is_in_levelup)
	
	local index = 1
	local equip_data = MarriageData.Instance:GetQyEquipInfoList()
	local mian_vo = GameVoManager.Instance:GetMainRoleVo()
	for k, v in ipairs(equip_data) do
		if mian_vo.last_marry_time <= 0 and mian_vo.lover_uid <= 0 then
			index = 4
		end
	end
	self.equip_select_index = index
	MarriageData.Instance:SetSelectEquipIndex(index)
	local toggle_ison = self.equip_item_list[index]:GetToggleIsOn()
	if toggle_ison then
		self:FlushBagList()
	else
		self.equip_item_list[index]:SetHighLight(true)
	end
	self:FlushEquipView()
end

function MarriageEquipView:FlushEquipView()
	local mian_vo = GameVoManager.Instance:GetMainRoleVo()
	local equip_data = MarriageData.Instance:GetQyEquipInfoList()
	for k, v in ipairs(equip_data) do
		if mian_vo.last_marry_time <= 0 and mian_vo.lover_uid <= 0 and v.item_id <= 0 and k ~= 4 then
			local data = {}
			data.locked = true
			self.equip_item_list[k]:SetData(data)
		else
			if v.item_id <= 0 then
				local data = {}
				data.item_id = EquipIdList[k]
				self.equip_item_list[k]:SetData(data)
				self.equip_item_list[k]:SetIconGrayScale(true)
				self.equip_item_list[k]:ShowQuality(false)
			else
				self.equip_item_list[k]:SetData(v)
				--显示等级
				self.equip_item_list[k]:ShowStrengthLable(true)
				self.equip_item_list[k]:SetStrength(v.level)

				self.equip_item_list[k]:SetIconGrayScale(false)
				--显示品质
				self.equip_item_list[k]:ShowQuality(true)
			end
			--显示是否可升品
			local quality_list = MarriageData.Instance:GetQualityListByIndex(k)
			if not next(quality_list) then
				self.equip_item_list[k]:SetShowUpQuality(false)
			else
				self.equip_item_list[k]:SetShowUpQuality(true)
			end
		end
	end
	self:FlushBagList()
	self:FlushAttrList()
end


------------------------MarryEquipItemCell------------------------------
MarryEquipItemCell = MarryEquipItemCell or BaseClass(BaseRender)

function MarryEquipItemCell:__init()
	self.item_cell_list = {}
	for i = 1, 2 do
		local item = self:FindObj("ItemCell" .. i)
		local item_cell = ItemCell.New()
		item_cell:SetInstanceParent(item)
		item_cell:SetData(nil)
		table.insert(self.item_cell_list, item_cell)
	end
end

function MarryEquipItemCell:__delete()
	for k, v in ipairs(self.item_cell_list) do
		v:DeleteMe()
	end
	self.item_cell_list = {}
end

function MarryEquipItemCell:SetData(data, i)
	self.item_cell_list[i]:SetData(data)
	local select_used_item_list = self.parent.select_use_item_list
	for k, v in pairs(select_used_item_list) do
		if v.index == data.index then
			self:SetHighLight(true, i)
		end
	end
end

function MarryEquipItemCell:SetParent(parent)
	self.parent = parent
	for k, v in ipairs(self.item_cell_list) do
		v.parent = parent
	end
end

function MarryEquipItemCell:SetToggleGrounp(group)
	for k, v in ipairs(self.item_cell_list) do
		v.root_node.toggle.group = group
	end
end

function MarryEquipItemCell:ListenClick(func, i)
	self.item_cell_list[i]:ListenClick(func)
end

function MarryEquipItemCell:SetHighLight(enable, i)
	self.item_cell_list[i]:SetHighLight(enable)
end

function MarryEquipItemCell:GetToggleIsOn(i)
	return self.item_cell_list[i]:GetToggleIsOn()
end

function MarryEquipItemCell:SetInteractable(enable, i)
	self.item_cell_list[i]:SetInteractable(enable)
end