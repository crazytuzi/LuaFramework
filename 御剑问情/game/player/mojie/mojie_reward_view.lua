MojieGiftView = MojieGiftView or BaseClass(BaseView)

function MojieGiftView:__init()
	self.ui_config = {"uis/views/player_prefab","MojieGiftView"}
end

function MojieGiftView:__delete()

end

function MojieGiftView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = nil
	self.list_view = nil
end

function MojieGiftView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self.cell_list = {}
	self.list_view = self:FindObj("GiftList")
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self:Flush()
end

function MojieGiftView:CloseWindow()
	self:Close()
end

function MojieGiftView:OpenCallBack()
	self:Flush()
end

function MojieGiftView:GetNumberOfCells()
	local gift_id = MojieData.Instance:GetMojieGiftId()
	local data_list = ItemData.Instance:GetGiftItemList(gift_id)
	return #data_list
end

function MojieGiftView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = MojieGiftItem.New(cell.gameObject)
		star_cell.parent_view = self
		self.cell_list[cell] = star_cell
	end
	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
end

function MojieGiftView:OnFlush()
	self.list_view.scroller:ReloadData(0)
end

---------------------MojieGiftItem--------------------------------
MojieGiftItem = MojieGiftItem or BaseClass(BaseCell)

function MojieGiftItem:__init()
	self.parent_view = nil
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("ItemCell"))

	self:ListenEvent("ClickReward", BindTool.Bind(self.OnClickReward, self))
end

function MojieGiftItem:__delete()
	self.parent_view = nil
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function MojieGiftItem:SetItemIndex(index)
	self.item_index = index
end

function MojieGiftItem:OnClickReward()
	local bag_index = MojieData.Instance:GetMojieGiftBagIndex()
	if bag_index ~= -1 then
		PackageCtrl.Instance:SendUseItem(bag_index, 1, self.item_index - 1)
	end
	self.parent_view:Close()
end

function MojieGiftItem:OnFlush()
	local gift_id = MojieData.Instance:GetMojieGiftId()
	if gift_id == -1 then
		return
	end
	local data_list = ItemData.Instance:GetGiftItemList(gift_id)
	self.item_cell:SetGiftItemId(gift_id)
	self.item_cell:SetData(data_list[self.item_index])
end