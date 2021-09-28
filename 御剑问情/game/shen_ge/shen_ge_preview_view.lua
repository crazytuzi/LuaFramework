ShenGePreviewView = ShenGePreviewView or BaseClass(BaseView)
local COLUMN = 4
function ShenGePreviewView:__init()
    self.ui_config = {"uis/views/shengeview_prefab", "ShenGePreviewView"}
    self.play_audio = true
end

function ShenGePreviewView:__delete()
end

function ShenGePreviewView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
end

function ShenGePreviewView:LoadCallBack()
	self.list_data = {}
	self.cell_list = {}
	self.is_first_list = {}

	self.list_view = self:FindObj("ListView")
	local scroller_delegate = self.list_view.list_simple_delegate
	scroller_delegate.NumberOfCellsDel = BindTool.Bind(self.GetCellNumber, self)
	scroller_delegate.CellRefreshDel = BindTool.Bind(self.CellRefresh, self)
	scroller_delegate.CellSizeDel = BindTool.Bind(self.GetCellSize, self)
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
end

function ShenGePreviewView:OpenCallBack()
	self:FlushView()
end

function ShenGePreviewView:CloseCallBack()

end

function ShenGePreviewView:GetCellSize(data_index)
	if self.is_first_list[data_index + 1] then
		return 224
	else
		return 183
	end
end

function ShenGePreviewView:FlushView()
	self.list_data = {}
	self.is_first_list = {}
	self.list = {}
	local ShenGeData = ShenGeData.Instance
	local last_layer = -1
	local index = 0
	local count = 2
	local types = ShenGeData:GetShenGepreviewCfgForTypes()
	for i = 1, 6 do
		for quality = 2, 5 do
			local item_id = ShenGeData:GetShenGeItemId(types[i], quality)
			local data = ShenGeData:GetShenGepreviewCfg(types[i], quality, 1)
			table.insert(list, data)
		end
	end
	for k,v in ipairs(list) do
		if v.in_layer_open ~= last_layer then
			index = index + 1
			self.list_data[index] = {}
			last_layer = v.in_layer_open
			count = 1
		else
			if count > COLUMN then
				index = index + 1
				self.list_data[index] = {}
				count = 1
			end
		end
		-- if count > COLUMN then
		-- 	index = index + 1
		-- 	self.list_data[index] = {}
		-- 	count = 1
		-- end
		self.list_data[index][count] = v
		count = count + 1
	end
	self.total_count = index
	self.list_view.scroller:ReloadData(0)
end

function ShenGePreviewView:CloseWindow()
	self:Close()
end

function ShenGePreviewView:GetCellNumber()
	return 6
end

function ShenGePreviewView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = ShenGePreviewGroupCell.New(cell.gameObject)
		self.cell_list[cell] = group_cell
	end

	local data_list = self.list_data[data_index + 1] or {}
	for i = 1, COLUMN do
		local data = data_list[i]
		if data then
			group_cell:SetActive(i, true)
			group_cell:SetData(i, data)
			group_cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
		else
			group_cell:SetActive(i, false)
		end
	end
	group_cell:SetImage(data_index)
	if self.is_first_list[data_index + 1] then
		group_cell:ShowTitle(true)
	else
		group_cell:ShowTitle(false)
	end
end

function ShenGePreviewView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	local function callback()
		if not cell:IsNil() then
			cell:SetToggleHighLight(false)
		end
	end
	ShenGeCtrl.Instance:SetTipsData(data)
	ShenGeCtrl.Instance:SetTipsCallBack(callback)
	ViewManager.Instance:Open(ViewName.ShenGeItemTips)
end

function ShenGePreviewView:OnFlush(params_t)
	self:FlushView()
end

--------------------ShenGePreviewGroupCell---------------------------
ShenGePreviewGroupCell = ShenGePreviewGroupCell or BaseClass(BaseRender)
function ShenGePreviewGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = ShenGeAnalyzeItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, item_cell)
	end
	self.show_title = self:FindVariable("ShowTitle")
	self.title = self:FindVariable("Title")
end

function ShenGePreviewGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenGePreviewGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenGePreviewGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
	self.data = data
end

function ShenGePreviewGroupCell:SetImage(data_index)
end

function ShenGePreviewGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenGePreviewGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function ShenGePreviewGroupCell:SetToggleHighLight(i, state)
	self.item_list[i]:SetToggleHighLight(state)
end

function ShenGePreviewGroupCell:ShowTitle(state)
	self.show_title:SetValue(state or false)
	if state then
		if self.data then
			local str = string.format(Language.Rune.JieSuo, self.data.in_layer_open or 0) or ""
			self.title:SetValue(str)
		end
	end
end

--------------------ShenGeAnalyzeItemCell----------------------
ShenGeAnalyzeItemCell = ShenGeAnalyzeItemCell or BaseClass(BaseCell)
function ShenGeAnalyzeItemCell:__init()
	self.level_text = self:FindVariable("LevelText")
	self.attr_text_1 = self:FindVariable("AttrText1")
	self.attr_text_2 = self:FindVariable("AttrText2")
	self.image_res = self:FindVariable("ImageRes")
	self.show_text_2 = self:FindVariable("ShowText2")
	self.show_special_effect = self:FindVariable("ShowSpecialEffect")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function ShenGeAnalyzeItemCell:__delete()

end

function ShenGeAnalyzeItemCell:SetToggleHighLight(state)
	self.root_node.toggle.isOn = state
end

function ShenGeAnalyzeItemCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end

	-- print_error(self.data.item_id)
	-- if self.data.item_id > 0 then
	-- 	self.image_res:SetAsset(ResPath.GetItemIcon(self.data.item_id))
	-- 	--展示特殊特效
	-- 	if self.show_special_effect then
	-- 		if self.data.quality == 4 and self.data.type ~= GameEnum.RUNE_JINGHUA_TYPE then
	-- 			self.show_special_effect:SetValue(true)
	-- 		else
	-- 			self.show_special_effect:SetValue(false)
	-- 		end
	-- 	end
	-- end

	local level_color = RUNE_COLOR[self.data.quality] or TEXT_COLOR.WHITE
	local level_name = Language.ShenGe.AttrTypeName[self.data.types] or ""
	local level_str = string.format(Language.Rune.LevelDes, level_color, level_name, self.data.level)
	self.level_text:SetValue(level_str)

	local attr_type_name = ""
	local attr_value = 0
	local capability = Language.Rune.ShenGeCapability
	-- if self.data.type == GameEnum.RUNE_JINGHUA_TYPE then
	-- 	--符文精华特殊处理
	-- 	attr_type_name = Language.Rune.JingHuaAttrName
	-- 	attr_value = self.data.dispose_fetch_jinghua
	-- 	local str = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
	-- 	self.attr_text_1:SetValue(str)
	-- 	self.attr_text_2:SetValue("")
	-- 	return
	-- end

	attr_type_name = Language.ShenGe.AttrTypeName[self.data.attr_type_0] or ""
	attr_value = self.data.add_attributes_0
	if RuneData.Instance:IsPercentAttr(self.data.attr_type_0) then
		attr_value = (self.data.add_attributes_0/100.00) .. "%"
	end

	if self.data.attr_type_1 > 0 then
		attr_type_name = Language.ShenGe.AttrTypeName[self.data.attr_type_1] or ""
		attr_value = self.data.add_attributes_1
		if RuneData.Instance:IsPercentAttr(self.data.attr_type_1) then
			attr_value = (self.data.add_attributes_1/100.00) .. "%"
		end
		attr_des = string.format(Language.Rune.AttrDes, attr_type_name, attr_value)
		self.attr_text_2:SetValue(attr_des)
		self.show_text_2:SetValue(false)
	else
		self.attr_text_2:SetValue("")
		self.show_text_2:SetValue(false)
	end
	local item_id = ShenGeData.Instance:GetShenGeItemId(self.data.types, self.data.quality)
	local item_cfg = ItemData.Instance:GetItemConfig(item_id)

	if nil == item_cfg then return end
	
	-- 设置战斗力
	local attr_info = CommonStruct.AttributeNoUnderline()
	local attr_type_1 = Language.ShenGe.AttrType[self.data.attr_type_0]
	local attr_type_2 = Language.ShenGe.AttrType[self.data.attr_type_1]
	if attr_type_1 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_1, self.data.add_attributes_0)
	end
	if attr_type_2 then
		RuneData.Instance:CalcAttr(attr_info, attr_type_2, self.data.add_attributes_1)
	end
	local zhanli = CommonDataManager.GetCapabilityCalculation(attr_info)
	local attr_des = string.format(Language.Rune.AttrDes, capability, zhanli)
	self.attr_text_1:SetValue(attr_des)
	self.image_res:SetAsset(ResPath.GetItemIcon(item_cfg.icon_id))
end