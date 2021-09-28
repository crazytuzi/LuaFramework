require("game/compose/duihuan/duihuan_content_view")
DuihuanView = DuihuanView or BaseClass(BaseView)
function DuihuanView:__init()
	self.ui_config = {"uis/views/composeview_prefab","DuiHuanView"}
	self.full_screen = false
	self.play_audio = true
	self.sub_type = 101
	self.parent_cell_list = {}
	self.item_data_notice = function ()
		self:Flush()
	end
	self.full_screen = true
	self.cur_index = 0
end

function DuihuanView:__delete()
end

function DuihuanView:ReleaseCallBack()
	if self.duihuan_content_view ~= nil then
		self.duihuan_content_view:DeleteMe()
		self.duihuan_content_view = nil
	end

	for k,v in pairs(self.parent_cell_list) do
		v:DeleteMe()
	end
	self.parent_cell_list = {}
	self.parent_list = nil
	self.cur_index = 0
	self.sub_type = 101
end

function DuihuanView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_data_notice)
end


function DuihuanView:CloseCallBack()
	ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_notice)
end

function DuihuanView:LoadCallBack()
	local content_view = self:FindObj("duihuan_content_view")
	UtilU3d.PrefabLoad("uis/views/composeview_prefab", "DuiHuanContent",
	function(obj)
		obj.transform:SetParent(content_view.transform, false)
		obj = U3DObject(obj)
		self.duihuan_content_view = DuiHuanContentView.New(obj)
		self.duihuan_content_view:OnFlushListView(self.sub_type)
	end)

	-- self:CreateParentList()
	self:ListenEvent("close_view", BindTool.Bind(self.OnCloseBtnClick, self))
end

function DuihuanView:OnCloseBtnClick()
	self:Close()
end

function DuihuanView:CreateParentList()
	self.parent_list = self:FindObj("DuiHuanTypeList")
	local parent_group = self.parent_list:GetComponent("ToggleGroup")
	local list_delegate = self.parent_list.list_simple_delegate
	list_delegate.NumberOfCellsDel = function ()
		return #ComposeData.Instance:GetDuihuanMenuList()
	end
	list_delegate.CellRefreshDel = function (cell, data_index)
		local cell_item = self.parent_cell_list[cell]
		if cell_item == nil then
			cell_item = DuiHuanMenuCell.New(cell.gameObject, self)
			cell_item:SetToggleGroup(parent_group)
			self.parent_cell_list[cell] = cell_item
		end
		local data_list = ComposeData.Instance:GetDuihuanMenuList()
		local data = data_list[data_index + 1]
		cell_item:SetIndex(data_index)
		cell_item:SetData(data)
		cell_item:ListenClick(BindTool.Bind(self.OnClickTabButton, self, data))
	end
end

function DuihuanView:OnClickTabButton(data)
	self.sub_type = data.sub_type
	self:Flush()
end

function DuihuanView:SetCurIndex(index)
	self.cur_index = index
end

function DuihuanView:GetCurIndex()
	return self.cur_index
end


function DuihuanView:OnFlush()
	if self.duihuan_content_view then
		self.duihuan_content_view:OnFlushListView(self.sub_type)
	end
end


DuiHuanMenuCell = DuiHuanMenuCell or BaseClass(BaseCell)
function DuiHuanMenuCell:__init(instance, parent)
	self.name = self:FindVariable("Name")
	self.parent = parent
end

function DuiHuanMenuCell:__delete()
	self.name = nil
	self.parent = nil
end

function DuiHuanMenuCell:OnFlush()
	self.name:SetValue(self.data.sub_name)

	self.root_node.toggle.isOn = (self.parent:GetCurIndex() == self.index)
end

function DuiHuanMenuCell:SetToggleGroup(toggle_group)
	self.root_node.toggle.group = toggle_group
end

function DuiHuanMenuCell:SetToggle(value)
	self.root_node.toggle.isOn = value
end

function DuiHuanMenuCell:SetIndex(index)
	self.index = index
end

function DuiHuanMenuCell:ListenClick(handler)
	self:ClearEvent("OnClick")
	self:ListenEvent("OnClick", function ()
		if self.parent:GetCurIndex() ~= self.index then
			handler()
			self.parent:SetCurIndex(self.index)
		end
	end)
end

