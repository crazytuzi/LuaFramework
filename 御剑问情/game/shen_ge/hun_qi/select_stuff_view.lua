
SelectStuffView = SelectStuffView or BaseClass(BaseView)

function SelectStuffView:__init()
	self.ui_config = {"uis/views/hunqiview_prefab","SelectStuffView"}
	self.select_data = {}
end

function SelectStuffView:__delete()

end

function SelectStuffView:ReleaseCallBack()
	self.list_view = nil

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.contain_cell_list = nil
end

function SelectStuffView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.BackOnClick, self))
	self.contain_cell_list = {}
	self.list_view = self:FindObj("list")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function SelectStuffView:GetNumberOfCells()
	local consume_list = HunQiData.Instance:GetHunQiXiLianStuffList()
	return #consume_list
end

function SelectStuffView:RefreshCell(cell, cell_index)
	local consume_list = HunQiData.Instance:GetHunQiXiLianStuffList()
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = SelectItem.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	cell_index = cell_index + 1
	contain_cell:SetData(consume_list[cell_index])
	contain_cell:SetIndex(cell_index)
end

function SelectStuffView:OpenCallBack()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
end

function SelectStuffView:CloseCallBack()

end

--关闭面板
function SelectStuffView:BackOnClick()
	ViewManager.Instance:Close(ViewName.HunQiXiLianStuffView)
end

function SelectStuffView:ShowIndexCallBack(index)
	-- self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
end


function SelectStuffView:SetHeChengData(select_data)
	self.select_data = select_data
end

SelectItem = SelectItem or BaseClass(BaseCell)

function SelectItem:__init()
	self:ListenEvent("OnClickSelect", BindTool.Bind(self.OnClickSelect, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.name = self:FindVariable("item_name")
	self.desc = self:FindVariable("item_desc")
end

function SelectItem:OnClickSelect()
	GlobalEventSystem:Fire(OtherEventType.HUNQI_XILIAN_STUFF_SELECT, 2, self.data)
	ViewManager.Instance:Close(ViewName.HunQiXiLianStuffView)
end

function SelectItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function SelectItem:OnFlush()
	if not self.data then
		return
	end
	self.item_cell:SetData(self.data.consume_item)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.consume_item.item_id)
	self.name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color])) 
	if self.data.max_star_number and self.data.max_star_number > 0 then
	    self.desc:SetValue(string.format(Language.HunQi.MaxStarNum, self.data.max_star_number))
    end

	self.item_cell:SetHighLight(false)
	local num = ItemData.Instance:GetItemNumInBagById(self.data.consume_item.item_id)
	self.item_cell:SetNum(num)
	self.item_cell:SetItemNumVisible(true)
	self.item_cell:SetItemNum(num)
end