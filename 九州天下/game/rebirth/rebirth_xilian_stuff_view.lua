RebirthXiLianStuffView = RebirthXiLianStuffView or BaseClass(BaseView)
-- 套装洗练材料面板
function RebirthXiLianStuffView:__init()
	self.ui_config = {"uis/views/rebirthview","RebirthXilianStuffView"}
	self:SetMaskBg()
	self.select_data = {}
end

function RebirthXiLianStuffView:__delete()

end

function RebirthXiLianStuffView:ReleaseCallBack()
	self.list_view = nil

	for k,v in pairs(self.contain_cell_list) do
		v:DeleteMe()
	end

	self.contain_cell_list = nil
end

function RebirthXiLianStuffView:LoadCallBack()
	self:ListenEvent("CloseWindow",BindTool.Bind(self.BackOnClick, self))
	self.contain_cell_list = {}
	self.list_view = self:FindObj("list")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
end

function RebirthXiLianStuffView:GetNumberOfCells()
	return 4
end

function RebirthXiLianStuffView:RefreshCell(cell, cell_index)
	local contain_cell = self.contain_cell_list[cell]
	if contain_cell == nil then
		contain_cell = RebirthStuffItem.New(cell.gameObject, self)
		self.contain_cell_list[cell] = contain_cell
	end
	local item_instruction = RebirthData.Instance:GetItemInstruction(RebirthCtrl.Instance:GetCurSelectSuit())
	contain_cell:SetIndex(cell_index + 1)
	contain_cell:SetData(item_instruction)
end

function RebirthXiLianStuffView:OpenCallBack()
	if self.list_view then
		self.list_view.scroller:ReloadData(0)
	end
end

function RebirthXiLianStuffView:CloseCallBack()
end

function RebirthXiLianStuffView:OnFlush()
end

--关闭面板
function RebirthXiLianStuffView:BackOnClick()
	ViewManager.Instance:Close(ViewName.RebirthXiLianStuffView)
end


------------------------------------------------------------------------------
RebirthStuffItem = RebirthStuffItem or BaseClass(BaseCell)
function RebirthStuffItem:__init()
	self:ListenEvent("OnClickSelect", BindTool.Bind(self.OnClickSelect, self))
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item"))
	self.name = self:FindVariable("item_name")
	self.desc = self:FindVariable("item_desc")
end

function RebirthStuffItem:OnClickSelect()
	local item_id = self.data["item_id_".. self.index]
	GlobalEventSystem:Fire(OtherEventType.REBIRTH_STUFF_SELECT, self.index,item_id)
	ViewManager.Instance:Close(ViewName.RebirthXiLianStuffView)
end

function RebirthStuffItem:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function RebirthStuffItem:OnFlush()
	if not self.data then
		return
	end
	local item_id = self.data["item_id_".. self.index]
	self.item_cell:SetData({item_id = item_id})

	local item_cfg = ItemData.Instance:GetItemConfig(item_id)
	self.name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))

	local desc = self.data["describe_".. self.index]
	self.desc:SetValue(ToColorStr(desc, ITEM_COLOR[item_cfg.color]))

	local num = ItemData.Instance:GetItemNumInBagById(item_id)
	self.item_cell:SetNum(num)
	self.item_cell:SetItemNumVisible(true)
	self.item_cell:SetItemNum(num)
end
