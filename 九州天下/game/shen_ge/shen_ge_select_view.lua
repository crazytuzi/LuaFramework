ShenGeSelectView = ShenGeSelectView or BaseClass(BaseView)

local COLUMN = 2
local PAGE_NUM = 4		-- 一页格子数
local FROM_INLAY = "from_inlay"
local FROM_COMPOSE = "from_compose"

function ShenGeSelectView:__init()
	self.ui_config = {"uis/views/shengeview", "ShenGeSelectView"}
	self:SetMaskBg(true)
	self.play_audio = true
	self.fight_info_view = true
	self.had_data_list = {}
	self.list_data = {}
	self.from_view = ""
	self.max_pagg_count = 0
	self.now_page = 1
end

function ShenGeSelectView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量
	self.list_view = nil
	self.cur_page = nil
	self.max_page = nil
	self.show_enough_toggle = nil
	self.ehough_toggle = nil
end

function ShenGeSelectView:LoadCallBack()
	self.cell_list = {}

	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.ehough_toggle = self:FindObj("EnoughToggle").toggle
	self.ehough_toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))

	self.cur_page = self:FindVariable("CurPage")
	self.max_page = self:FindVariable("MaxPage")
	self.show_enough_toggle = self:FindVariable("ShowEnough")
end

function ShenGeSelectView:OpenCallBack()
	if self.from_view == FROM_COMPOSE then
		self.ehough_toggle.isOn = true
		self.list_data = ShenGeData.Instance:GetCanComposeDataList(self.had_data_list, self.ehough_toggle.isOn)
	elseif self.from_view == FROM_INLAY then
		self.list_data = ShenGeData.Instance:GetSameQuYuDataList(self.had_data_list[1])
	end

	self:SetPageData()

	self.show_enough_toggle:SetValue(self.from_view == FROM_COMPOSE)

	if self.list_view.list_view.isActiveAndEnabled then
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function ShenGeSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.had_data_list = {}
	self.list_data = {}
end

function ShenGeSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function ShenGeSelectView:SetHadSelectData(data_list)
	self.had_data_list = data_list or {}
end

function ShenGeSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function ShenGeSelectView:GetNumberOfCells()
	if self.from_view == FROM_COMPOSE and (self.had_data_list.count > 0 or self.ehough_toggle.isOn) then
		return math.ceil(#self.list_data / 2)
	end
	if self.from_view == FROM_INLAY then
		return math.ceil(#ShenGeData.Instance:GetSameQuYuDataList(self.had_data_list[1]) / 2)
	end
	return math.ceil(ShenGeData.Instance:GetBagListCount() / 2)
end

function ShenGeSelectView:OnSelectToggleChange(is_on)
	if self.had_data_list.count > 0 then
		return
	end

	self.list_data = ShenGeData.Instance:GetCanComposeDataList(self.had_data_list, is_on)
	if self.list_view.list_view.isActiveAndEnabled then
		self:SetPageData()
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function ShenGeSelectView:SetPageData()
	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	self.list_view.list_page_scroll2:SetPageCount(self.max_pagg_count)

	self.now_page = 1
	self.cur_page:SetValue(self.now_page)
	self.max_page:SetValue(self.max_pagg_count <= 0 and 1 or self.max_pagg_count)
end

function ShenGeSelectView:OnValueChanged(normalizedPosition)
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page then
		self.cur_page:SetValue(now_page)
		self.now_page = now_page
	end
end

function ShenGeSelectView:RefreshCell(data_index, cellObj)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = ShenGeSelectGroup.New(cellObj)
		cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.item_id > 0))
		cell:SetData(i, data)
		cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function ShenGeSelectView:ItemCellClick(cell)
	if self.call_back ~= nil then
		self.call_back(cell.data)
		self.call_back = nil
	end
	self:Close()
end

function ShenGeSelectView:CloseWindow()
	self:Close()
end

function ShenGeSelectView:OnFlush(param_list)
end


-------------------ShenGeSelectGroup-----------------------
ShenGeSelectGroup = ShenGeSelectGroup or BaseClass(BaseRender)
function ShenGeSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = ShenGeSelectCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function ShenGeSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function ShenGeSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function ShenGeSelectGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function ShenGeSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function ShenGeSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function ShenGeSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------ShenGeSelectCell-----------------------
ShenGeSelectCell = ShenGeSelectCell or BaseClass(BaseCell)
function ShenGeSelectCell:__init()
	self.level_num = self:FindVariable("Level_num")
	self.level_des = self:FindVariable("LevelDes")
	self.attr_des_1 = self:FindVariable("AttrDes1")
	self.attr_des_2 = self:FindVariable("AttrDes2")
	self.attr_des_3 = self:FindVariable("AttrDes3")
	self.is_show_attr = self:FindVariable("IsShowAttr")

	self.show_repeat = self:FindVariable("ShowRepeat")
	local item = ItemCell.New()
	item:SetInstanceParent(self:FindObj("ItemCell"))
	item:ListenClick(BindTool.Bind(self.OnClick, self))
	item:ShowHighLight(false)
	self.item_cell = item
	item:ShowQuality(false)

	self.qualityBao = self:FindVariable("QualityBao")	
	self.show_qualityItem = self:FindVariable("ShowQualityItem")
	self.shen_back_level = self:FindVariable("ShenBackLevel")

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function ShenGeSelectCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function ShenGeSelectCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function ShenGeSelectCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end

function ShenGeSelectCell:OnFlush()
	self.show_qualityItem:SetValue(false)

	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data)

	local shen_ge_data = self.data.shen_ge_data
	if nil == shen_ge_data then
		return
	end

	self.qualityBao:SetAsset(ResPath.GetRomeNumImage(self.data.shen_ge_data.quality))
	self.show_qualityItem:SetValue(true)
	self.shen_back_level:SetValue(self.data.shen_ge_data.level)

	local attr_cfg = ShenGeData.Instance:GetShenGeAttributeCfg(shen_ge_data.type, shen_ge_data.quality, shen_ge_data.level)
	if nil == attr_cfg then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if nil == item_cfg then
		return
	end
	local level_str = attr_cfg.name
	local level_to_num = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..attr_cfg.level.."</color>"
	local level_to_color = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..level_str.."</color>"
	self.level_num:SetValue(level_to_num)
	self.level_des:SetValue(level_to_color)
	self.is_show_attr:SetValue(true)

	for i = 0, 2 do
		local attr_value = attr_cfg["add_attributes_"..i]
		local attr_type = attr_cfg["attr_type_"..i]
		if attr_value > 0 then
			--if attr_type == 8 or attr_type == 9 then
			--	self["attr_des_"..(i + 1)]:SetValue(Language.ShenGe.AttrTypeName[attr_type].."  +"..(attr_value / 100).."%")
			--else
				self["attr_des_"..(i + 1)]:SetValue(Language.ShenGe.AttrTypeName[attr_type].."  +"..attr_value)
			--end
		else
			self["attr_des_"..(i + 1)]:SetValue("")
			self.is_show_attr:SetValue(false)
		end
	end
end