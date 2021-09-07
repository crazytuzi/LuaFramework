RebirthSuitView = RebirthSuitView or BaseClass(BaseView)

-- 转生套装界面
function RebirthSuitView:__init()
	self.ui_config = {"uis/views/rebirthview","RebirthSuitView"}
	self:SetMaskBg()
	self.full_screen = false
	self.play_audio = true
	self.contain_cell_list = {}
	self.attr_cell_list = {}
	self.select_suit = 1
end

function RebirthSuitView:__delete()
end

function RebirthSuitView:ReleaseCallBack()
	self.contain_cell_list = {}
	self.suit_name = nil
	self.type = nil
	self.value = nil
	self.capability = nil

	self.list_view = nil 
	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.attr_list_view = nil 
	for k,v in pairs(self.attr_cell_list) do
		v:DeleteMe()
	end
end

function RebirthSuitView:LoadCallBack()
	self:ListenEvent("Close", BindTool.Bind(self.OnCloseHandler, self))

	self.suit_name = self:FindVariable("SuitName")
	self.type = self:FindVariable("Type")
	self.value = self:FindVariable("Value")
	self.capability = self:FindVariable("Capability")

	self.select_suit = RebirthCtrl.Instance:GetCurSelectSuit()
	self.list_view = self:FindObj("EquipItemList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)

	self.attr_list_view = self:FindObj("AttrListView")
	local attr_list_delegate = self.attr_list_view.list_simple_delegate
	attr_list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetAttrNumrOfCells, self)
	attr_list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshAttrCell, self)

	self:Flush()
end

function RebirthSuitView:GetNumberOfCells()
	return 5
end

function RebirthSuitView:GetAttrNumrOfCells()
	return 10
end

function RebirthSuitView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RebirthSuitEquipContain.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	local equip_data = RebirthData.Instance:GetSuitEquipData(self.select_suit)
	contain_cell:SetIndex(cell_index + 1)
	contain_cell:SetData(equip_data[cell_index + 1])
end

function RebirthSuitView:RefreshAttrCell(cell, cell_index)
	local attr_cell = self.attr_cell_list[cell]
	if attr_cell == nil then
		attr_cell = RebirthSuitEquipNameItem.New(cell.gameObject, self)
		self.attr_cell_list[cell] = attr_cell
	end
	local equip_id = RebirthData.Instance:GetEquipId(self.select_suit,cell_index + 1)
	attr_cell:SetIndex(cell_index + 1)
	attr_cell:SetData(equip_id)
end

function RebirthSuitView:OnCloseHandler()
	ViewManager.Instance:Close(ViewName.RebirthSuitView)
end

function RebirthSuitView:OnFlush()
	local suit_grade_cfg = RebirthData.Instance:GetSuitGradeCfg(self.select_suit)
	if self.suit_name then
		self.suit_name:SetValue(suit_grade_cfg.suit_name)
	end

	local value, suit_type, attr_type = RebirthData.Instance:GetSuitAttr(self.select_suit)
	if self.type then
		self.type:SetValue(suit_type)
	end
	if self.value then
		local blank_begin, blank_end = string.find(attr_type, "per")
		if blank_begin and blank_end then
			self.value:SetValue((value/100).."%")
		else
			self.value:SetValue(value)
		end
	end

	local capability_value,total_attr_cfg = RebirthData.Instance:GetAttrTotal(self.select_suit)
	if self.capability then
		self.capability:SetValue(capability_value)
	end
end

function RebirthSuitView:OpenCallBack()
	self.select_suit = RebirthCtrl.Instance:GetCurSelectSuit()
	self.list_view.scroller:ReloadData(0)
	self.attr_list_view.scroller:ReloadData(0)
	self:Flush()
end
---------------------------------------------------------------
-- 2个item
RebirthSuitEquipContain = RebirthSuitEquipContain  or BaseClass(BaseCell)

function RebirthSuitEquipContain:__init()
	self.shop_contain_list = {}
	for i = 1, 2 do
		self.shop_contain_list[i] = RebirthSuitEquipItem.New(self:FindObj("item_" .. i))
	end
end

function RebirthSuitEquipContain:__delete()
	for i = 1, 2 do
		self.shop_contain_list[i]:DeleteMe()
		self.shop_contain_list[i] = nil
	end
end

function RebirthSuitEquipContain:OnFlush()
	if not self.data then
		return
	end

	for i = 1, 2 do
		self.shop_contain_list[i]:SetData(self.data[i])
		self.shop_contain_list[i]:SetIndex(i)
	end

end

---------------------------------------------------------------------
-- 一个item
RebirthSuitEquipItem = RebirthSuitEquipItem or BaseClass(BaseCell)
function RebirthSuitEquipItem:__init()
	self.name = self:FindVariable("name")
	self.text = self:FindVariable("Text")

	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	local bunble_cell, asset_cell = ResPath.GetImages("bg_cell_equip")
	self.item_cell:SetItemCellBg(bunble_cell, asset_cell)
	self.item_cell:ListenClick(BindTool.Bind(self.OnToggleClick, self))
	self.item_cell:ShowHighLight(false)
	self:ListenEvent("OnClickToggle", BindTool.Bind(self.OnToggleClick, self))
end

function RebirthSuitEquipItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function RebirthSuitEquipItem:OnFlush()
	if not self.data then
		return
	end

	local suit_prefix_cfg = RebirthData.Instance:GetSuitPrefixCfg(RebirthCtrl.Instance:GetCurSelectSuit())
	local pre = suit_prefix_cfg["slot_" .. self.data.index .. "_prefix"]
	local pre_str = Language.Rebirth.PrefixType[pre]

	self.select_suit = RebirthCtrl.Instance:GetCurSelectSuit()
	local suit_activity_grade = RebirthData.Instance:GetSuitActivityGrade()
	local is_open = self.select_suit <= suit_activity_grade
	if is_open then 		-- 已激活,读配置
		local bundle_equip, asset_equip = ResPath.GetRebirthEquipImage("suit_bg" .. self.select_suit)
		self.item_cell:SetAsset(bundle_equip, asset_equip)
		self.item_cell:SetNum(5)

		self.item_cell:SetItemNumVisible(true)
		self.item_cell:SetItemNum("Lv5")

		local name = ItemData.Instance:GetItemName(self.data.item_id)
		self.name:SetValue(name)

		local str = ToColorStr(string.format(Language.Rebirth.Text,pre_str), TEXT_COLOR.GREEN)
		self.text:SetValue(str)
		self.item_cell:ShowQuality(true)
		self.item_cell:QualityColor(5)
	else 					-- 未激活，读协议
		local cfg = RebirthData.Instance:GetSuitGradeCfg(self.select_suit)
		local item_id = cfg["slot_" .. self.data.index.. "_itemid"]
		local name = ItemData.Instance:GetItemName(item_id)
		self.name:SetValue(name)
		local equip_level_list = RebirthData.Instance:GetEquipLevel()
		if self.data.slot_flag ~= 0 then -- 已穿备
			self.item_cell:SetData({item_id = item_id, num = equip_level_list[self.data.index].level, is_bind = 0})
		else 							 -- 未装备
			self.item_cell:Reset()
			local bundle_equip, asset_equip = ResPath.GetRebirthEquipImage("equip_bg" .. self.data.index)
			self.item_cell:SetAsset(bundle_equip, asset_equip)
		end
		self.item_cell:SetItemNumVisible(true)
		if equip_level_list[self.data.index] then
			self.item_cell:SetItemNum("Lv" .. equip_level_list[self.data.index].level)
		else
			self.item_cell:SetItemNum("")
		end

		local pre = self.data.prefix_type
		local is_prefix = RebirthData.Instance:GetIsPreFix(self.select_suit, self.data.index, pre)
		local str = ""
		if is_prefix then
			str = ToColorStr(string.format(Language.Rebirth.Text,pre_str), TEXT_COLOR.GREEN)
			self.text:SetValue(str)
			self.item_cell:QualityColor(5)
		else
			str = ToColorStr(string.format(Language.Rebirth.Text,pre_str), TEXT_COLOR.RED)
			self.text:SetValue(str)
		end
	end

end

function RebirthSuitEquipItem:OnToggleClick()
	if self.data.slot_flag and self.data.slot_flag  == 0 then
		return
	end
	ViewManager.Instance:Close(ViewName.RebirthSuitView)
	RebirthCtrl.Instance:SetEquipIndex(self.data.index)
	RebirthCtrl.Instance:SetCurSelectSuit(RebirthCtrl.Instance:GetCurSelectSuit())
	RebirthCtrl.Instance:FlushRebirthView()
end

------------------------------------------------------------
-- 装备name
RebirthSuitEquipNameItem = RebirthSuitEquipNameItem or BaseClass(BaseCell)
function RebirthSuitEquipNameItem:__init()
	self.equip_name = self:FindVariable("EquipName")
	self.actived_text = self:FindVariable("ActivedText")
end

function RebirthSuitEquipNameItem:__delete()
end

function RebirthSuitEquipNameItem:OnFlush()
	if not self.data then
		return
	end

	local name = ItemData.Instance:GetItemName(self.data)
	self.equip_name:SetValue(name)

	self.select_suit = RebirthCtrl.Instance:GetCurSelectSuit()
	local suit_activity_grade = RebirthData.Instance:GetSuitActivityGrade()
	local is_open = self.select_suit <= suit_activity_grade
	local str = ""
	if is_open then 		-- 已激活
		str = ToColorStr(Language.Rebirth.ActiveText, TEXT_COLOR.GREEN)
		self.actived_text:SetValue(str)
	else 					-- 未激活，读协议
		local inuse_equip_list = RebirthData.Instance:GetInuseEquipList()
		local prefix_type = inuse_equip_list[self.index].prefix_type

		local is_prefix = RebirthData.Instance:GetIsPreFix(self.select_suit, self.index, prefix_type)
		local str = ""
		if is_prefix then
			str = ToColorStr(Language.Rebirth.ActiveText, TEXT_COLOR.GREEN)
			self.actived_text:SetValue(str)
		else
			str = ToColorStr(Language.Rebirth.NoActiveText, TEXT_COLOR.RED)
			self.actived_text:SetValue(str)
		end

	end
end
