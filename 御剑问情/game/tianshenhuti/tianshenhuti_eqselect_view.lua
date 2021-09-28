TianshenhutiEqSelectView = TianshenhutiEqSelectView or BaseClass(BaseView)

local COLUMN = 6
local PAGE_NUM = 4		-- 一页格子数
local FROM_COMPOSE = "from_compose"

function TianshenhutiEqSelectView:__init()
    self.ui_config = {"uis/views/tianshenhutiview_prefab", "ComposeSelectView"}
   	self.play_audio = true
	self.fight_info_view = true
	self.had_data_list = {}
	self.list_data = {}
	self.from_view = ""
	self.max_pagg_count = 0
	self.now_page = 1
	self.index = 1
	self.is_compose = false
end

function TianshenhutiEqSelectView:__delete()

end

function TianshenhutiEqSelectView:CloseCallBack()
	if self.call_back ~= nil then
		self.call_back()
		self.call_back = nil
	end
	self.had_data_list = {}
	self.list_data = {}
end

function TianshenhutiEqSelectView:ReleaseCallBack()
	for _, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量
	self.list_view = nil
	self.cur_page = nil
	self.max_page = nil
	self.ehough_toggle = nil
end

function TianshenhutiEqSelectView:LoadCallBack()
	self.cell_list = {}
	self:ListenEvent("CloseWindow",BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("UpPageBtn",BindTool.Bind(self.OnClickUp, self))
	self:ListenEvent("DownPageBtn",BindTool.Bind(self.OnClickDown, self))

	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.page_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self.list_view.scroll_rect.onValueChanged:AddListener(BindTool.Bind(self.OnValueChanged, self))

	self.ehough_toggle = self:FindObj("EnoughToggle").toggle
	self.ehough_toggle:AddValueChangedListener(BindTool.Bind(self.OnSelectToggleChange, self))

	self.cur_page = self:FindVariable("CurPage")
	self.max_page = self:FindVariable("MaxPage")
end

function TianshenhutiEqSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function TianshenhutiEqSelectView:OpenCallBack()
	self.list_data = TianshenhutiData.Instance:GetCanComposeDataList(self.from_view == FROM_COMPOSE)

	self:SetPageData()

	if self.list_view.list_view.isActiveAndEnabled then
		self.list_view.list_view:Reload()
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(0)
	end
end

function TianshenhutiEqSelectView:SetSelectIndex(index)
	self.index = index
end

function TianshenhutiEqSelectView:GetNumberOfCells()
	return math.ceil(TianshenhutiData.Instance:GetBagListCount() / 6)
end

function TianshenhutiEqSelectView:OnSelectToggleChange(is_on)

end

function TianshenhutiEqSelectView:SetSelectCallBack(call_back)
	self.call_back = call_back
end

function TianshenhutiEqSelectView:SetHadSelectData(data_list)    --已经选择的
	self.had_data_list = data_list or {}
end

function TianshenhutiEqSelectView:SetFromView(from_view)
	self.from_view = from_view or ""
end

function TianshenhutiEqSelectView:OnClickUp()
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page > 1 then
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(now_page - 2)
	end
end

function TianshenhutiEqSelectView:OnClickDown()
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page < self.max_pagg_count then
		self.list_view.list_page_scroll2:JumpToPageImmidateWithoutToggle(now_page)
	end
end

function TianshenhutiEqSelectView:SetPageData()
	self.max_pagg_count = math.ceil(#self.list_data / COLUMN / PAGE_NUM)
	self.list_view.list_page_scroll2:SetPageCount(self.max_pagg_count)

	self.now_page = 1
	self.cur_page:SetValue(1)
	self.max_page:SetValue(self.max_pagg_count)
end

function TianshenhutiEqSelectView:OnValueChanged(normalizedPosition)
	local now_page = self.list_view.list_page_scroll2:GetNowPage() + 1
	if now_page ~= self.now_page then
		self.cur_page:SetValue(now_page)
		self.now_page = now_page
	end
end

function TianshenhutiEqSelectView:RefreshCell(data_index, cellObj)
	local cell = self.cell_list[cellObj]
	if nil == cell then
		cell = TianshenhutiEqSelectGroup.New(cellObj)
		cell:SetToggleGroup(self.list_view.toggle_group)
		self.cell_list[cellObj] = cell
	end

	for i = 1, COLUMN do
		local index = (data_index)*COLUMN + i - 1
		cell:SetIndex(i, index)
		local data = self.list_data[index]
		cell:SetActive(i, (data ~= nil and data.item_id > 0))
		cell:SetData(i, data)
		cell:SetClickCallBack(i, BindTool.Bind(self.ItemCellClick, self))
	end
end

function TianshenhutiEqSelectView:ItemCellClick(cell)
	if self.call_back ~= nil then
		self.call_back(cell.data)
		self.call_back = nil
	end
	TianshenhutiData.Instance:AddComposeSelect(self.index, cell.data)
	self:Close()
end

function TianshenhutiEqSelectView:CloseWindow()
	self:Close()
end

function TianshenhutiEqSelectView:OnFlush(param_list)
end


-------------------TianshenhutiEqSelectGroup-----------------------
TianshenhutiEqSelectGroup = TianshenhutiEqSelectGroup or BaseClass(BaseRender)
function TianshenhutiEqSelectGroup:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local bag_item = TianshenhutiEquipItemCell.New()
		bag_item:SetInstanceParent(self:FindObj("Item" .. i))
		table.insert(self.item_list, bag_item)
	end
end

function TianshenhutiEqSelectGroup:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function TianshenhutiEqSelectGroup:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function TianshenhutiEqSelectGroup:SetData(i, data)
	self.item_list[i]:SetData(data)
end

function TianshenhutiEqSelectGroup:SetToggleGroup(group)
	for k, v in ipairs(self.item_list) do
		v:SetToggleGroup(group)
	end
end

function TianshenhutiEqSelectGroup:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function TianshenhutiEqSelectGroup:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

