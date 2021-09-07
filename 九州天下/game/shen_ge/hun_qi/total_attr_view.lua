TotalAttrTipView = TotalAttrTipView or BaseClass(BaseView)

function TotalAttrTipView:__init()
	self.ui_config = {"uis/views/hunqiview", "TotalAttrTipView"}
	self.ndata = {}
	self.cdata = {}
	self.view_layer = UiLayer.Pop
	self.play_audio = true
	self:SetMaskBg(true)
end

function TotalAttrTipView:__delete()
	
end

function TotalAttrTipView:LoadCallBack()
	self.capability = self:FindVariable("Capability")

	self:ListenEvent("Close", BindTool.Bind(self.CloseWindow, self))

	self.cell_list = {}
	self.list_view = self:FindObj("ListView")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetMountNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)
end

function TotalAttrTipView:ReleaseCallBack()
	self.capability = nil
	self.list_view = nil
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
end

function TotalAttrTipView:CloseWindow()
	self.ndata = {}
	self.cdata = {}
	self:Close()
end

function TotalAttrTipView:OpenCallBack()
	self:Flush()
end

function TotalAttrTipView:SetAttrData(data,cdata)
	local temp_tab = {}
	if nil ~= data then
		for k, v in pairs(data) do
			local temp_index = Language.HunQi.AttrNameIndex[k]
			local tab = {}
			tab[k] = v
			temp_tab[temp_index] = tab
		end
	end
	local tab_index = 1
	for k, v in pairs(temp_tab) do
		self.ndata[tab_index] = v
		tab_index = tab_index + 1
	end
	self.cdata = cdata or {}
end

function TotalAttrTipView:OnFlush()
 	local cap = CommonDataManager.GetCapability(self.cdata)
	if cap and cap >= 0 then
		self.capability:SetValue(cap)
	else
		self.capability:SetValue(0)
	end
	self.list_view.scroller:ReloadData(0)
end

function TotalAttrTipView:GetMountNumberOfCells()
	return #self.ndata
end

function TotalAttrTipView:RefreshMountCell(cell, cell_index)
	local mount_cell = self.cell_list[cell]
	if mount_cell == nil then
		mount_cell = TotalAttrTipCell.New(cell.gameObject)
		self.cell_list[cell] = mount_cell
	end
 
	mount_cell:SetData(self.ndata[cell_index + 1])
end

TotalAttrTipCell = TotalAttrTipCell or BaseClass(BaseCell)

function TotalAttrTipCell:__init()
	self.attr_name = self:FindVariable("attr_name")
	self.attr_value = self:FindVariable("attr_value")
	self.index = 0
end

function TotalAttrTipCell:__delete()
	self.attr_name = nil
	self.attr_value = nil
end

function TotalAttrTipCell:OnFlush()
	if nil == self.data then
		return
	end
 	for k, v in pairs(self.data) do
		self.attr_name:SetValue(k)
		self.attr_value:SetValue(v)
 	end

 	self.index = self.data.index
end
 
 
 