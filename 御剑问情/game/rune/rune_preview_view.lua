RunePreviewView = RunePreviewView or BaseClass(BaseView)
local COLUMN = 3
function RunePreviewView:__init()
    self.ui_config = {"uis/views/rune_prefab", "RunePreviewView"}
    self.play_audio = true
end

function RunePreviewView:__delete()
end

function RunePreviewView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}

	-- 清理变量和对象
	self.list_view = nil
end

function RunePreviewView:LoadCallBack()
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

function RunePreviewView:OpenCallBack()
	self:FlushView()
end

function RunePreviewView:CloseCallBack()

end

function RunePreviewView:GetCellSize(data_index)
	if self.is_first_list[data_index + 1] then
		return 224
	else
		return 183
	end
end

function RunePreviewView:FlushView()
	local list = RuneData.Instance:GetRuneListByLayer()
	self.list_data = {}
	self.is_first_list = {}
	local last_layer = -1
	local index = 0
	local count = 1
	for k,v in ipairs(list) do
		if v.in_layer_open ~= last_layer then
			index = index + 1
			self.list_data[index] = {}
			self.is_first_list[index] = true
			last_layer = v.in_layer_open
			count = 1
		else
			if count > COLUMN then
				index = index + 1
				self.list_data[index] = {}
				count = 1
			end
		end
		self.list_data[index][count] = v
		count = count + 1
	end
	self.total_count = index
	self.list_view.scroller:ReloadData(0)
end

function RunePreviewView:CloseWindow()
	self:Close()
end

function RunePreviewView:GetCellNumber()
	return self.total_count
end

function RunePreviewView:CellRefresh(cell, data_index)
	local group_cell = self.cell_list[cell]
	if nil == group_cell then
		group_cell = RunePreviewGroupCell.New(cell.gameObject)
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
	if self.is_first_list[data_index + 1] then
		group_cell:ShowTitle(true)
	else
		group_cell:ShowTitle(false)
	end
end

function RunePreviewView:ItemCellClick(cell)
	local data = cell:GetData()
	if not data or not next(data) then
		return
	end

	local function callback()
		if not cell:IsNil() then
			cell:SetToggleHighLight(false)
		end
	end
	RuneCtrl.Instance:SetTipsData(data)
	RuneCtrl.Instance:SetTipsCallBack(callback)
	ViewManager.Instance:Open(ViewName.RuneItemTips)
end

function RunePreviewView:OnFlush(params_t)
	self:FlushView()
end

--------------------RunePreviewGroupCell---------------------------
RunePreviewGroupCell = RunePreviewGroupCell or BaseClass(BaseRender)
function RunePreviewGroupCell:__init()
	self.item_list = {}
	for i = 1, COLUMN do
		local item_cell = RuneAnalyzeItemCell.New(self:FindObj("Item" .. i))
		table.insert(self.item_list, item_cell)
	end
	self.show_title = self:FindVariable("ShowTitle")
	self.title = self:FindVariable("Title")
end

function RunePreviewGroupCell:__delete()
	for k, v in ipairs(self.item_list) do
		v:DeleteMe()
	end
	self.item_list = {}
end

function RunePreviewGroupCell:SetActive(i, state)
	self.item_list[i]:SetActive(state)
end

function RunePreviewGroupCell:SetData(i, data)
	self.item_list[i]:SetData(data)
	self.data = data
end

function RunePreviewGroupCell:SetIndex(i, index)
	self.item_list[i]:SetIndex(index)
end

function RunePreviewGroupCell:SetClickCallBack(i, callback)
	self.item_list[i]:SetClickCallBack(callback)
end

function RunePreviewGroupCell:SetToggleHighLight(i, state)
	self.item_list[i]:SetToggleHighLight(state)
end

function RunePreviewGroupCell:ShowTitle(state)
	self.show_title:SetValue(state or false)
	if state then
		if self.data then
			local str = string.format(Language.Rune.JieSuo, self.data.in_layer_open or 0) or ""
			self.title:SetValue(str)
		end
	end
end