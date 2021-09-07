MiJiSelectView = MiJiSelectView or BaseClass(BaseView)

local COLUMN = 2
local PAGE_NUM = 4		-- 一页格子数
local FROM_INLAY = "from_inlay"
local FROM_COMPOSE = "from_compose"

function MiJiSelectView:__init()
	self.ui_config = {"uis/views/shengeview", "MiJiSelectView"}
	self.play_audio = true
	self.fight_info_view = true
	self.had_data_list = {}
	self.list_data = {}
	self.from_view = ""
	self.max_pagg_count = 0
	self.now_page = 1
end

function MiJiSelectView:ReleaseCallBack()
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

function MiJiSelectView:LoadCallBack()
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

function MiJiSelectView:OpenCallBack()

	self.list_data = MiJiComposeData.Instance:GetMiJiItemListByBag(self.had_data_list)
	self:SetPageData()

	self.show_enough_toggle:SetValue(false)

	if self.list_view.list_view.isActiveAndEnabled then
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function MiJiSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.had_data_list = {}
	self.list_data = {}
end

function MiJiSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function MiJiSelectView:SetHadSelectData(data_list)
	self.had_data_list = data_list or {}
end

function MiJiSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function MiJiSelectView:GetNumberOfCells()
	return math.ceil(#self.list_data / 2)
end

function MiJiSelectView:OnSelectToggleChange(is_on)
	if self.had_data_list.count > 0 then
		return
	end

	self.list_data = MiJiComposeData.Instance:GetCanComposeDataList(self.had_data_list, is_on)
	if self.list_view.list_view.isActiveAndEnabled then
		self:SetPageData()
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function MiJiSelectView:SetPageData()
	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	self.list_view.list_page_scroll2:SetPageCount(self.max_pagg_count)

	self.now_page = 1
	self.cur_page:SetValue(1)
	self.max_page:SetValue(self.max_pagg_count)
end

function MiJiSelectView:OnValueChanged(normalizedPosition)
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page then
		self.cur_page:SetValue(now_page)
		self.now_page = now_page
	end
end

function MiJiSelectView:RefreshCell(data_index, cellObj)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = MiJiSelectGroup.New(cellObj)
		cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.bag_info.item_id > 0))
		cell:SetData(i, data)
		cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function MiJiSelectView:ItemCellClick(cell)
	if self.call_back ~= nil then
		self.call_back(cell.data)
		self.call_back = nil
	end
	self:Close()
end

function MiJiSelectView:CloseWindow()
	self:Close()
end

function MiJiSelectView:OnFlush(param_list)
end


-------------------MiJiSelectGroup-----------------------
MiJiSelectGroup = MiJiSelectGroup or BaseClass(BaseRender)
function MiJiSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = MiJiSelectCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function MiJiSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function MiJiSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function MiJiSelectGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function MiJiSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function MiJiSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function MiJiSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

-------------------MiJiSelectCell-----------------------
MiJiSelectCell = MiJiSelectCell or BaseClass(BaseCell)
function MiJiSelectCell:__init()
	self.level_des = self:FindVariable("LevelDes")
	self.attr_des_1 = self:FindVariable("AttrDes1")
	self.attr_des_2 = self:FindVariable("AttrDes2")
	self.show_repeat = self:FindVariable("ShowRepeat")
	-- self.image_res = self:FindVariable("ImageRes")
	-- self.num = self:FindVariable("num")
	local item = ItemCell.New()
	item:SetInstanceParent(self:FindObj("ItemCell"))
	self.item_cell = item

	self:ListenEvent("Click", BindTool.Bind(self.OnClick, self))
end

function MiJiSelectCell:__delete()
	self.item_cell:DeleteMe()
	self.item_cell = nil
end

function MiJiSelectCell:SetToggleGroup(group)
	self.root_node.toggle.group = group
end

function MiJiSelectCell:SetHighLight(state)
	self.root_node.toggle.isOn = state
end



function MiJiSelectCell:OnFlush()
	if not self.data or not next(self.data) then
		return
	end
	self.item_cell:SetData(self.data.bag_info)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local miji_cfg = ShengXiaoData.Instance:GetMijiCfgByItemId(self.data.item_id)
	local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"

	self.level_des:SetValue(name_str)
	self.attr_des_1:SetValue(miji_cfg.type_name)
	self.attr_des_2:SetValue(miji_cfg.capacity)
	if miji_cfg.type < 10 then
		local data = {}
		data[SHENGXIAO_MIJI_TYPE[miji_cfg.type]] = miji_cfg.value
		self.attr_des_2:SetValue(CommonDataManager.GetCapabilityCalculation(data))
	end
	self.show_repeat:SetValue(self.data.have_type == 0)
end