RebirthEquipView = RebirthEquipView or BaseClass(BaseRender)
-- 转生洗练界面
function RebirthEquipView:__init()
	self.cell_list = {}
	self.cur_select = 0
	self.cells = {}
	self.level_list_cell = {}
	self.equip_bg = {}
	self.equip_index = 0
	self.extra_attr_list = {}
	self.xilian_attr_list = {}
	self.select_type = 1 				-- 洗练材料类型
	self.select_stuff_item_id = nil		-- 洗练材料id
	self.equip_temp_index = 0
	self.capability_value = 0			-- 战力
	self.cur_temp_select = nil
end

function RebirthEquipView:__delete()
	for k, v in pairs(self.cells) do
		v:DeleteMe()
	end
	self.cells = {}

	for i,v in ipairs(self.level_list_cell) do
		v:DeleteMe()
	end
	self.level_list_cell = {}

	if self.material_item_cell then
		self.material_item_cell:DeleteMe()
		self.material_item_cell = nil
	end

	if self.select_stuff then
		GlobalEventSystem:UnBind(self.select_stuff)
	end
end

function RebirthEquipView:ReleaseCallBack()

end

function RebirthEquipView:OpenCallBack()
	RebirthSuitItem.SelectLevelIndex = RebirthData.Instance:GetSuitOpenedGrade()
	if self.suit_list_view then
		self.suit_list_view.scroller:ReloadData(0)
	end
end

function RebirthEquipView:LoadCallBack()
	-- 套装
	self.suit_list_view = self:FindObj("SuitListView")
	local suit_list_delegate = self.suit_list_view.list_simple_delegate
	suit_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetSuitNumOfCells, self)
	suit_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshSuitListView, self)

	local bunble_cell, asset_cell = ResPath.GetImages("bg_cell_equip")
	
	for i = 1, 10 do
		local item = ItemCell.New()
		item:SetInstanceParent(self:FindObj("ItemCell"..i))
		item:SetItemCellBg(bunble_cell, asset_cell)
		item:SetIconGrayScale(false)
		item:SetIsShowGrade(false)
		self.cells[i] = item

		self.equip_bg[i] = self:FindVariable("EquipBg"..i)
	end


	self.base_type = self:FindVariable("BaseType")
	self.base_value = self:FindVariable("BaseValue")
	self.equip_title = self:FindVariable("EquipTitle")
	self.equip_prefix = self:FindVariable("EquipPrefix")
	self.show_prefix = self:FindVariable("ShowPrefix")

	self.extra_attr_list = self:FindObj("ExtraAtrrList")
	local extra_attr_list_delegate = self.extra_attr_list.list_simple_delegate
	extra_attr_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GeExtraAtrrtNumOfCells, self)
	extra_attr_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshExtraAttrListView, self)

	self.xilian_attr_list = self:FindObj("XilianAtrrList")
	local xilian_attr_list_delegate = self.xilian_attr_list.list_simple_delegate
	xilian_attr_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetXilianAttrNumOfCells, self)
	xilian_attr_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshXilianAttrListView, self)

	self.capability = self:FindVariable("Capability")

	self:ListenEvent("OnClickXilian", BindTool.Bind(self.OnClickXilian, self))
	self:ListenEvent("OnClickReplace", BindTool.Bind(self.OnClickReplace, self))
	self:ListenEvent("OnClickOpenAttr", BindTool.Bind(self.OnClickOpenAttr, self))
	self:ListenEvent("OnClickOpenAttrTotal", BindTool.Bind(self.OnClickOpenAttrTotal, self))
	self:ListenEvent("OnClickRule", BindTool.Bind(self.OnClickRule, self))

	self.material_item_cell = ItemCell.New()
	self.material_item_cell:SetInstanceParent(self:FindObj("MaterialItemCell"))
	self.material_item_cell:ShowHighLight(false)
	self.material_item_cell:ListenClick(BindTool.Bind(self.SelectStuff, self))
	self:ListenEvent("SelectStuff", BindTool.Bind(self.SelectStuff, self))
	self.material_item_num = self:FindVariable("MaterialItemNum")
	self.show_tip_text = self:FindVariable("ShowTipText")
	self.xilian_text = self:FindVariable("XilianText")
	self.show_xilian_gray = self:FindVariable("ShowXiLianGray")
	self.show_replace_gray = self:FindVariable("ShowReplaceGray")
	self.btn_xilian = self:FindObj("BtnXiLian")
	self.btn_replace = self:FindObj("BtnReplace")

	self.select_stuff = GlobalEventSystem:Bind(OtherEventType.REBIRTH_STUFF_SELECT, BindTool.Bind(self.OnSelectStuff, self))
	self.show_xilian_red = self:FindVariable("ShowXilianRed")

	self.show_equip_red = {}
	for i = 1,10 do
		self.show_equip_red[i] = self:FindVariable("ShowEquipRed"..i)
	end
end

function RebirthEquipView:SelectStuff()
	ViewManager.Instance:Open(ViewName.RebirthXiLianStuffView)
end

-- 改变物品id
function RebirthEquipView:OnSelectStuff(select_type,item_id)
	self.select_type = select_type
	self.select_stuff_item_id = item_id
	self:FlushStuffItem()
end

function RebirthEquipView:GetSuitNumOfCells()
	return RebirthData.Instance:GetSuitOpenedGrade()
end

function RebirthEquipView:GeExtraAtrrtNumOfCells()
	return #RebirthData.Instance:GetExtraAttrtCfg(self.cur_select,self.equip_index) or 0
end

function RebirthEquipView:GetXilianAttrNumOfCells()
	return #RebirthData.Instance:GetXilianAttrCfg(self.cur_select,self.equip_index) or 0
end

function RebirthEquipView:RefreshExtraAttrListView(cell,data_index)
	local item_cell = self.extra_attr_list[cell]
	if nil == item_cell then
		item_cell = RebirthAttrItem.New(cell.gameObject,self)
		self.extra_attr_list[cell] = item_cell
	end
	local extra_attr_cfg = RebirthData.Instance:GetExtraAttrtCfg(self.cur_select, self.equip_index)
	item_cell:SetIndex(data_index)
	item_cell:SetData(extra_attr_cfg[data_index + 1])
end

function RebirthEquipView:RefreshXilianAttrListView(cell,data_index)
	local item_cell = self.xilian_attr_list[cell]
	if nil == item_cell then
		item_cell = RebirthAttrItem.New(cell.gameObject, self)
		self.xilian_attr_list[cell] = item_cell
	end
	local xilianl_attr_cfg = RebirthData.Instance:GetXilianAttrCfg(self.cur_select, self.equip_index)
	item_cell:SetIndex(data_index)
	item_cell:SetData(xilianl_attr_cfg[data_index + 1])
end

function RebirthEquipView:RefreshSuitListView(cell,data_index)
	local icon_cell = self.level_list_cell[cell]
	if nil == icon_cell then
		icon_cell = RebirthSuitItem.New(cell.gameObject)
		icon_cell:SetClickCallBack(BindTool.Bind(self.OnClickItemCallBack, self))
		icon_cell:SetToggleGroup(self.suit_list_view.toggle_group, data_index == self.cur_select)
		self.level_list_cell[cell] = icon_cell
		RebirthSuitItem.SelectLevelIndex = RebirthData.Instance:GetSuitOpenedGrade()
	end
	local open_suit_cfg = RebirthData.Instance:GetSuitGradeCfg(data_index + 1)
	icon_cell:SetIndex(data_index + 1)
	icon_cell:SetData(open_suit_cfg)
end

-- 点击套装
function RebirthEquipView:OnClickItemCallBack(cell)
	if nil == cell or nil == cell.data and self.cur_select == cell.index then return end
	self.cur_select = cell.index
	local suit_activity_grade = RebirthData.Instance:GetSuitActivityGrade()
	local is_open = self.cur_select <= suit_activity_grade
	if is_open then 				-- 已激活,读配置
		self:FlushActivedEquipData()
	else 							-- 未激活，读协议
		self:FlushEquipData()
	end
	self:FlushStuffItem()
end

-- 读配置
function RebirthEquipView:FlushActivedEquipData()
	if not next(self.cells) then return end
	local cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
	local suit_prefix_cfg = RebirthData.Instance:GetSuitPrefixCfg(self.cur_select)
	local flush_equip_slot = true
	
	for i = 1,GameEnum.ZHUANSHENGSYSTEM_SLOT_COUNT_MAX do
		local bundle_equip, asset_equip = ResPath.GetRebirthEquipImage("suit_bg" .. self.cur_select)
		self.cells[i]:SetAsset(bundle_equip, asset_equip)

		self.cells[i]:ShowQuality(true)
		self.cells[i]:QualityColor(5)
		
		self.cells[i]:SetItemNumVisible(true)
		self.cells[i]:SetItemNum("Lv5")

		self.equip_bg[i]:SetValue(false)
		local pre = suit_prefix_cfg["slot_" .. i .. "_prefix"]
		local str = Language.Rebirth.PrefixType[pre]
		self.cells[i]:SetEquipGradeText(str)		-- 前缀

		self.cells[i]:ListenClick(BindTool.Bind(self.OnClickEquipItemActived, self, i))
		if flush_equip_slot then
			if self.equip_index == 0 then
				self.equip_index = i
			end
			if self.equip_temp_index ~= 0 then
				self.equip_index = self.equip_temp_index
			end
			flush_equip_slot = false
		end
		self.cells[i]:ShowHighLight(i == self.equip_index)
		self.cells[i]:SetHighLight(i == self.equip_index)
		self.extra_attr_list.scroller:ReloadData(0)
		self.xilian_attr_list.scroller:ReloadData(0)

		local bunble, asset = ResPath.GetItemEffect()
		self.cells[i]:SetSpecialEffect(bunble, asset)
		self.cells[i]:ShowSpecialEffect(true)

		self.show_equip_red[i]:SetValue(false)
	end
	self:FlushActiveEquipInfo(self.equip_index)
	self:FlushEquipAttr(self.equip_index)
	self.show_xilian_red:SetValue(false)
	self.equip_temp_index = 0
end

 -- 点击装备按钮，读配置
function RebirthEquipView:OnClickEquipItemActived(equip_index)
	self.equip_index = equip_index
	for i = 1, 10 do
		self.cells[i]:ShowHighLight(i == equip_index)
		self.cells[i]:SetHighLight(i == equip_index)
	end
	self.extra_attr_list.scroller:ReloadData(0)
	self.xilian_attr_list.scroller:ReloadData(0)

	self:FlushActiveEquipInfo(equip_index)

	self:FlushEquipAttr(equip_index)
	self:FlushStuffItem()
end

function RebirthEquipView:FlushActiveEquipInfo(equip_index)
	local cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
	local item_id = cfg["slot_" .. equip_index .. "_itemid"]
	local name = ItemData.Instance:GetItemName(item_id)

	local suit_prefix_cfg = RebirthData.Instance:GetSuitPrefixCfg(self.cur_select)
	local pre = suit_prefix_cfg["slot_" .. equip_index .. "_prefix"]
	local str = Language.Rebirth.PrefixType[pre]

	self.equip_title:SetValue(name)
	self.equip_prefix:SetValue(str)
	self.show_prefix:SetValue(true)
	self.show_tip_text:SetValue(true)
	self.xilian_text:SetValue(Language.Rebirth.NoXilian)

	self.show_xilian_gray:SetValue(false)
	self.btn_xilian.button.interactable = false
	self.show_replace_gray:SetValue(false)
	self.btn_replace.button.interactable = false
end

-- 读协议
function RebirthEquipView:FlushEquipData()
	if not next(self.cells) then return end
	local inuse_equip_list = RebirthData.Instance:GetInuseEquipList()
	local equip_level_list = RebirthData.Instance:GetEquipLevel()
	local mini_level = RebirthData.Instance:GetMiniEquipLevel()
	local cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
	local suit_prefix_cfg = RebirthData.Instance:GetSuitPrefixCfg(self.cur_select)
	local flush_equip_slot = true
	for i = 1,GameEnum.ZHUANSHENGSYSTEM_SLOT_COUNT_MAX do
		local item_id = cfg["slot_" .. i .. "_itemid"]
		if inuse_equip_list[i].slot_flag ~= 0 then	-- 已装备
			self.cells[i]:ShowQuality(true)
			self.equip_bg[i]:SetValue(false)
			self.cells[i]:SetData({item_id = item_id, num = equip_level_list[i].level, is_bind = 0})
			self.cells[i]:SetItemNumVisible(true)
			self.cells[i]:SetItemNum("Lv" .. equip_level_list[i].level)
			local pre = inuse_equip_list[i].prefix_type
			local str = Language.Rebirth.PrefixType[pre]
			self.cells[i]:SetEquipGradeText(str)		
			self.show_tip_text:SetValue(true)
			
			if flush_equip_slot then
				if self.equip_index == 0 then
					self.equip_index = i
				end
				if self.equip_temp_index ~= 0 then
					self.equip_index = self.equip_temp_index
				end
				flush_equip_slot = false
			end
			
			self.cells[i]:ShowHighLight(i == self.equip_index)
			self.cells[i]:SetHighLight(i == self.equip_index)
			self:FlushEquipAttr(self.equip_index)
			self.capability:SetValue(self.capability_value)
			self.extra_attr_list.scroller:ReloadData(0)
			self.xilian_attr_list.scroller:ReloadData(0)


			local suit_grade_cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
			local item_id = suit_grade_cfg.upgrade_item_id
			local item_num = ItemData.Instance:GetItemNumInBagById(item_id)
		
			local pre = inuse_equip_list[i].prefix_type
			local is_prefix = RebirthData.Instance:GetIsPreFix(self.cur_select, i , pre)
			if is_prefix then
				local bunble, asset = ResPath.GetItemEffect()
				self.cells[i]:SetSpecialEffect(bunble, asset)
				self.cells[i]:ShowSpecialEffect(true)
				self.cells[i]:QualityColor(5)
			end

			if (mini_level.seq == i) and (item_num > 0) and (not is_prefix) then
				self.show_equip_red[i]:SetValue(true)
			else
				self.show_equip_red[i]:SetValue(false)
			end
		else 											-- 未装备
			self.cells[i]:ShowQuality(false)
			self.cells[i]:SetData({item_id = item_id, num = 0, is_bind = 0})
			local bundle_equip, asset_equip = ResPath.GetRebirthEquipImage("equip_bg" .. i)
			self.cells[i]:SetAsset(bundle_equip, asset_equip)
			local is_enough = ItemData.Instance:GetItemNumIsEnough(item_id, 1)
			if is_enough then
				self.equip_bg[i]:SetValue(true)
			end
			-- self.base_type:SetValue("")
			-- self.base_value:SetValue("")
			self.extra_attr_list.scroller:ReloadData(0)
			self.xilian_attr_list.scroller:ReloadData(0)
		end
		self.cells[i]:ListenClick(BindTool.Bind(self.OnClickEquipItem, self, i))
	end

	if self.equip_index ~= 0 then
		local pre = inuse_equip_list[self.equip_index].prefix_type
		local str = Language.Rebirth.PrefixType[pre]
		local item_id = cfg["slot_" .. self.equip_index .. "_itemid"]
		local name = ItemData.Instance:GetItemName(item_id)
		self.equip_title:SetValue(name)
		self.equip_prefix:SetValue(str)
		self.show_prefix:SetValue(str ~= "")
		local is_prefix = RebirthData.Instance:GetIsPreFix(self.cur_select, self.equip_index, pre)
		if is_prefix then
			self.xilian_text:SetValue(Language.Rebirth.NoXilian)
		else
			self.xilian_text:SetValue(string.format(Language.Rebirth.CanXilian, Language.Rebirth.PrefixType[suit_prefix_cfg["slot_" .. self.equip_index .. "_prefix"]]))
		end
		self.show_xilian_gray:SetValue(not is_prefix)
		self.btn_xilian.button.interactable = not is_prefix
		self.show_replace_gray:SetValue(not is_prefix)
		self.btn_replace.button.interactable = not is_prefix
		self.show_xilian_red:SetValue(not is_prefix)
	end

	self.equip_temp_index = 0
end

 -- 点击装备按钮，读协议
function RebirthEquipView:OnClickEquipItem(equip_index)
	self.select_type = 1
	
	local inuse_equip_list = RebirthData.Instance:GetInuseEquipList()
	local cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
	local suit_prefix_cfg = RebirthData.Instance:GetSuitPrefixCfg(self.cur_select)
	local item_id = cfg["slot_" .. equip_index .. "_itemid"]
	if inuse_equip_list[equip_index].slot_flag ~= 0 then -- 已穿装备，设置装备属性
		self.equip_index = equip_index
		for i = 1, 10 do
			self.cells[i]:ShowHighLight(i == equip_index)
			self.cells[i]:SetHighLight(i == equip_index)
		end
		self.extra_attr_list.scroller:ReloadData(0)
		self.xilian_attr_list.scroller:ReloadData(0)

		local pre = inuse_equip_list[equip_index].prefix_type
		local str = Language.Rebirth.PrefixType[pre]

		local name = ItemData.Instance:GetItemName(item_id)
		self.equip_title:SetValue(name)
		self.equip_prefix:SetValue(str)
		self.show_prefix:SetValue(str ~= "")

		self.show_tip_text:SetValue(true)
		self:FlushEquipAttr(equip_index)

		local is_prefix = RebirthData.Instance:GetIsPreFix(self.cur_select, equip_index, pre)
		if is_prefix then
			self.xilian_text:SetValue(Language.Rebirth.NoXilian)
		else
			self.xilian_text:SetValue(string.format(Language.Rebirth.CanXilian, Language.Rebirth.PrefixType[suit_prefix_cfg["slot_" .. self.equip_index .. "_prefix"]]))
		end
		self.show_xilian_gray:SetValue(not is_prefix)
		self.btn_xilian.button.interactable = not is_prefix
		self.show_replace_gray:SetValue(not is_prefix)
		self.btn_replace.button.interactable = not is_prefix
		self.show_xilian_red:SetValue(not is_prefix)
	else 												 --未穿装备
		local is_enough = ItemData.Instance:GetItemNumIsEnough(item_id, 1)
		if is_enough then 			-- 背包有装备
			RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_SLOT_ITEM_CONSUME, equip_index - 1, 1)
		else 						-- 背包没装备
			local close_call_back = function() self.cells[equip_index]:SetHighLight(false) end
			TipsCtrl.Instance:OpenItem({item_id = item_id}, nil, nil, close_call_back)
		end
		self.show_xilian_red:SetValue(false)
	end	

	local suit_grade_cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
	self.select_stuff_item_id = suit_grade_cfg.upgrade_item_id
	self:FlushStuffItem()
end

-- 基础属性和战力
function RebirthEquipView:FlushEquipAttr(equip_index)
	local suit_base_attr_cfg = RebirthData.Instance:GetSuitBaseAttrCfg(self.cur_select, equip_index - 1)
	local attr_type = Language.Rebirth.BaseAttrType[suit_base_attr_cfg.base_attr_type]

	self.base_type:SetValue(attr_type)
	self.base_value:SetValue(suit_base_attr_cfg.base_attr_value)

	--基础属性表
	local base_attr_cfg = {}
	base_attr_cfg[RebirthData.BaseAttrType[suit_base_attr_cfg.base_attr_type]] = suit_base_attr_cfg.base_attr_value
	local base_data = CommonDataManager.GetAttributteByClass(base_attr_cfg)

	local extra_attr_cfg = RebirthData.Instance:GetExtraAttrtCfg(self.cur_select, equip_index)
	-- 额外属性表
	for k,v in pairs(extra_attr_cfg) do
		local up_attr_rate_cfg = RebirthData.Instance:GetUpAttrRateCfg(self.cur_select, v.attr_type,v.attr_level)
		local up_attr_cfg ={}
		up_attr_cfg[RebirthData.UpAttrType[v.attr_type]] = up_attr_rate_cfg.attr_value
		local up_base_data = CommonDataManager.GetAttributteByClass(up_attr_cfg)
		base_data = CommonDataManager.AddAttributeAttr(base_data, up_base_data)
	end

	-- 战力
	self.capability_value = CommonDataManager.GetCapabilityCalculation(base_data)
	self.capability:SetValue(self.capability_value)
end

-- 设置洗练物品
function RebirthEquipView:FlushStuffItem()
	local suit_grade_cfg = RebirthData.Instance:GetSuitGradeCfg(self.cur_select)
	local item_id = self.select_stuff_item_id or suit_grade_cfg.upgrade_item_id
	local upgrade_count = suit_grade_cfg.upgrade_count
	local item_num = ItemData.Instance:GetItemNumInBagById(item_id)

	self.material_item_cell:SetData({item_id = item_id})
	if self.select_type == 1 then
		if item_num >= upgrade_count then
			self.material_item_num:SetValue(ToColorStr(item_num, COLOR.GREEN).."/"..upgrade_count)
		else
			self.material_item_num:SetValue(ToColorStr(item_num, COLOR.RED).."/"..upgrade_count)
		end
	else
		if item_num >= 1 then
			self.material_item_num:SetValue(ToColorStr(item_num, COLOR.GREEN).."/".."1")
		else
			self.material_item_num:SetValue(ToColorStr(item_num, COLOR.RED).."/".."1")
		end
	end

	local inuse_equip_list = RebirthData.Instance:GetInuseEquipList()
	if self.equip_index ~= 0 then
		local pre = inuse_equip_list[self.equip_index].prefix_type

		local is_prefix = RebirthData.Instance:GetIsPreFix(self.cur_select, self.equip_index, pre)
		if is_prefix then
			self.show_xilian_red:SetValue(false)
		else
			local suit_activity_grade = RebirthData.Instance:GetSuitActivityGrade() -- 套装当前激活等级
			local is_open = self.cur_select <= suit_activity_grade
			if is_open then 	
				self.show_xilian_red:SetValue(false)
			else
				if inuse_equip_list[self.equip_index].slot_flag == 0 then -- 未穿装备
					self.show_xilian_red:SetValue(false)
				else
					self.show_xilian_red:SetValue(item_num > 0)
				end
			end
		end
	end
end

function RebirthEquipView:OnFlush()
	self.cur_select = self.cur_temp_select or RebirthData.Instance:GetSuitOpenedGrade()

	local suit_activity_grade = RebirthData.Instance:GetSuitActivityGrade() -- 套装当前激活等级
	local is_open = self.cur_select <= suit_activity_grade
	if is_open then 				-- 已激活,读配置
		self:FlushActivedEquipData()
	else 							-- 未激活，读协议
		self:FlushEquipData()
	end

	self:FlushStuffItem()
	self.cur_temp_select = nil
	
	if self.suit_list_view then
		self.suit_list_view.scroller:ReloadData(0)
	end
end

-- 洗练
function RebirthEquipView:OnClickXilian()
	local inuse_equip_list = RebirthData.Instance:GetInuseEquipList()
	if self.equip_index == 0 or inuse_equip_list[self.equip_index].slot_flag == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rebirth.XianlianButtonText)
		return
	end
	local func = function ()
		if self.select_type == 1 then
			RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_SLOT_ITEM_UPGRADE,self.equip_index - 1,1)
		elseif self.select_type == 2 then
			RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_TO_LEVEL_FIVE,self.equip_index - 1,1)
		elseif self.select_type == 3 then
			RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_SAME_LEVEL,self.equip_index - 1,1)
		elseif self.select_type == 4 then
			RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_TO_NEED_PREFIX,self.equip_index - 1,1)
		end
	end
	if RebirthData.Instance:GetIsXiLianAllMaxLevel(self.equip_index) then
		TipsCtrl.Instance:ShowCommonTip(func, nil, Language.Rebirth.GiveUpCurAttr)
	else
		func()
	end
end

-- 替换
function RebirthEquipView:OnClickReplace()
	local is_same_attr = RebirthData.Instance:IsSameAttr(self.equip_index)
	if is_same_attr then
		local ok_func = function ()
			RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_ATTR_REPLACE,self.equip_index - 1)
		end
		TipsCtrl.Instance:ShowCommonTip(ok_func, nil, Language.Rebirth.AtrrText)
		return
	end

	if #RebirthData.Instance:GetXilianAttrCfg(self.cur_select,self.equip_index) == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rebirth.ReplaceText)
		return
	end

	RebirthCtrl.Instance:SendReqRebirthAllInfo(REBIRTH_REQ_TYPE.ZHUANSHENGSYSTEM_REQ_TYPE_ATTR_REPLACE,self.equip_index - 1)
end

function RebirthEquipView:OnClickOpenAttr()
	ViewManager.Instance:Open(ViewName.RebirthSuitView)
end

function RebirthEquipView:OnClickOpenAttrTotal()
	local capability_value,total_attr_cfg = RebirthData.Instance:GetAttrTotal(self.cur_select)
	TipsCtrl.Instance:OpenGeneralView(total_attr_cfg)
end

function RebirthEquipView:GetCurSelectSuit()
	return self.cur_select or 0
end

function RebirthEquipView:SetCurSelectSuit(cur_select)
	self.cur_temp_select = cur_select or 0
end

function RebirthEquipView:SetEquipIndex(equip_index)
	self.equip_temp_index = equip_index
end

function RebirthEquipView:GetCapability()
	return self.capability_value
end

function RebirthEquipView:OnClickRule()
	TipsCtrl.Instance:ShowHelpTipView(250)
end

------------------------------------------------------------------------------
-- 装备格子列表
RebirthAttrItem = RebirthAttrItem or BaseClass(BaseCell)

function RebirthAttrItem:__init(instance, parent)
	self.parent = parent
	self.level = self:FindVariable("Level")
	self.type = self:FindVariable("Type")
	self.value = self:FindVariable("Value")
end

function RebirthAttrItem:__delete()
end

function RebirthAttrItem:OnFlush()
	if nil == self.data then return end

	self.level:SetValue(self.data.attr_level)

	local attr_type = Language.Rebirth.UpAttrType[self.data.attr_type]
	self.type:SetValue(attr_type)
	local up_attr_rate_cfg = RebirthData.Instance:GetUpAttrRateCfg(self.parent:GetCurSelectSuit(), self.data.attr_type,self.data.attr_level)
	self.value:SetValue(up_attr_rate_cfg.attr_value)
end

------------------------------------------------------------------------------
-- 套装格子列表
RebirthSuitItem = RebirthSuitItem or BaseClass(BaseCell)
RebirthSuitItem.SelectLevelIndex = 0
function RebirthSuitItem:__init(instance)
	 self:ListenEvent("ItemClick",BindTool.Bind(self.OnIconBtnClick, self))
	 self.name = self:FindVariable("IconName")
	 self.show_suit_red = self:FindVariable("ShowSuitRed")
end

function RebirthSuitItem:__delete()
end

function RebirthSuitItem:SetToggleGroup(group, bool)
	self.root_node.toggle.group = group
end

function RebirthSuitItem:SetToggleOn(index)
	self.root_node.toggle.isOn = self.index == index
end

function RebirthSuitItem:OnIconBtnClick()
	self:OnClick()
	RebirthSuitItem.SelectLevelIndex = self.index
end

function RebirthSuitItem:OnFlush()
	if nil == self.data then return end
	if self.data then
		self.name:SetValue(self.data.suit_name)
	end
	local suit_opened_grade = RebirthData.Instance:GetSuitOpenedGrade()
	local show_red = RebirthData.Instance:ShowXilianRed()
	self.show_suit_red:SetValue(suit_opened_grade == self.index and show_red)
	self.root_node.toggle.isOn = RebirthSuitItem.SelectLevelIndex == self.index
end
