RuneExchangeView = RuneExchangeView or BaseClass(BaseRender)

local COLUMN = 4
function RuneExchangeView:__init()
	self.list_data = {}
	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
end

function RuneExchangeView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function RuneExchangeView:InitView()
	GlobalTimerQuest:AddDelayTimer(function()
		self.list_data = RuneData.Instance:GetExchangeList()
		self.list_view.scroller:ReloadData(0)
	end, 0)
end

function RuneExchangeView:FlushView()
	self.list_view.scroller:RefreshActiveCellViews()
end

function RuneExchangeView:GetCellNumber()
	return math.ceil(#self.list_data/COLUMN)
end

function RuneExchangeView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RuneExchangeGroupCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		group_cell:SetIndex(i, index)
		local data = self.list_data[index]
		group_cell:SetActive(i, data ~= nil)
		group_cell:SetData(i, data)

		group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function RuneExchangeView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	--层数不够
	local pass_layer = RuneData.Instance:GetPassLayer()
	local need_pass_layer = data.in_layer_open
	if pass_layer < need_pass_layer then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Rune.OpenSlotDes, need_pass_layer))
		return
	end

	--符文碎片不足
	local have_suipian = RuneData.Instance:GetSuiPian()
	local need_suipian = data.convert_consume_rune_suipian
	if have_suipian < need_suipian then
		SysMsgCtrl.Instance:ErrorRemind(Language.Rune.SuiPianNotEnough)
		return
	end

	local function ok_callback()
		RuneCtrl.Instance:RuneSystemReq(RUNE_SYSTEM_REQ_TYPE.RUNE_SYSTEM_REQ_TYPE_CONVERT, data.item_id)
	end
	local level_color = RUNE_COLOR[data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[data.type] or ""
	local name_str = ToColorStr(level_name, level_color)
	local des = string.format(Language.Rune.SuiPianExchange, need_suipian, name_str)
	TipsCtrl.Instance:ShowCommonAutoView("rune_exchange", des, ok_callback)
end

------------------RuneExchangeGroupCell----------------------
RuneExchangeGroupCell = RuneExchangeGroupCell or BaseClass(BaseRender)
function RuneExchangeGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RuneExChangeItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, item_cell)
	end
end

function RuneExchangeGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RuneExchangeGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RuneExchangeGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function RuneExchangeGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RuneExchangeGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

--------------------RuneExChangeItemCell----------------------
RuneExChangeItemCell = RuneExChangeItemCell or BaseClass(BaseCell)
function RuneExChangeItemCell:__init()
	self.tite_name = self:FindVariable("TiteName")
	self.image_res = self:FindVariable("ImageRes")
	self.attr_des_1 = self:FindVariable("AttrDes1")
	self.attr_des_2 = self:FindVariable("AttrDes2")
	self.sui_pian = self:FindVariable("SuiPian")
	self.pass_layer_des = self:FindVariable("PassLayerDes")
	self.show_two_attr = self:FindVariable("ShowTwoAttr")
	self.show_special_effect = self:FindVariable("ShowSpecialEffect")
	self.power = self:FindVariable("Power")
	self.show_price = self:FindVariable("show_price")
	self.is_gray = self:FindVariable("is_gray")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function RuneExChangeItemCell:__delete()

end

function RuneExChangeItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	if self.data.item_id > 0 then
		self.image_res:SetAsset(ResPath.GetItemIcon(self.data.item_id))
		--展示特殊特效
		if self.show_special_effect then
			if self.data.quality == 4 and self.data.type ~= GameEnum.RUNE_JINGHUA_TYPE then
				self.show_special_effect:SetValue(true)
			else
				self.show_special_effect:SetValue(false)
			end
		end
	end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.Rune.AttrTypeName[self.data.type] or ""
	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
	self.tite_name:SetValue(level_str)

	local have_suipian = RuneData.Instance:GetSuiPian()
	local need_suipian = self.data.convert_consume_rune_suipian
	local color = "#0000f1"
	local suipian_str = ""
	if have_suipian < need_suipian then
		color = "#fe3030"
	end
	suipian_str = ToColorStr(need_suipian, color)
	self.sui_pian:SetValue(suipian_str)

	local pass_layer = RuneData.Instance:GetPassLayer()
	local need_pass_layer = self.data.in_layer_open
	local pass_des = ""
	if pass_layer < need_pass_layer then
		pass_des = string.format(Language.Rune.OpenSlotDes, need_pass_layer)
	end
	self.show_price:SetValue(pass_layer >= need_pass_layer)
	self.is_gray:SetValue(pass_layer < need_pass_layer)
	self.pass_layer_des:SetValue(pass_des)

	-- 设置战斗力
	-- local attr_info = CommonStruct.AttributeNoUnderline()
	-- local attr_type_1 = Language.Rune.AttrType[self.data.attr_type_0]
	-- local attr_type_2 = Language.Rune.AttrType[self.data.attr_type_1]
	-- if attr_type_1 then
	-- 	RuneData.Instance:CalcAttr(attr_info, attr_type_1, self.data.add_attributes_0)
	-- end
	-- if attr_type_2 then
	-- 	RuneData.Instance:CalcAttr(attr_info, attr_type_2, self.data.add_attributes_1)
	-- end
	-- local capability = CommonDataManager.GetCapabilityCalculation(attr_info)
	self.power:SetValue(self.data.power)

	local attr_type_name = ""
	local attr_value = 0
	if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
		--符文精华特殊处理
		attr_type_name = Language.Rune.JingHuaAttrName
		attr_value = self.data.dispose_fetch_jinghua
		local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_des_1:SetValue(str)
		self.attr_des_2:SetValue("")
		self.show_two_attr:SetValue(false)
		return
	end

	attr_type_name = Language.Rune.AttrName[self.data.attr_type_0] or ""
	attr_value = self.data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
		attr_value = (self.data.add_attributes_0/100.00) .. "%"
	end
	local attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	self.attr_des_1:SetValue(attr_des)

	if self.data.attr_type_1 > 0 then
		attr_type_name = Language.Rune.AttrName[self.data.attr_type_1] or ""
		attr_value = self.data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(self.data.attr_type_1) then
			attr_value = (self.data.add_attributes_1/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_des_2:SetValue(attr_des)
		self.show_two_attr:SetValue(true)
	else
		self.attr_des_2:SetValue("")
		self.show_two_attr:SetValue(false)
	end
end