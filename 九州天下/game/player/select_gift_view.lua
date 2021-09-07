SelectGiftView = SelectGiftView or BaseClass(BaseView)
local ItemCount = 4
function SelectGiftView:__init()
	self.ui_config = {"uis/views/player", "MojieGiftView"}
	self:SetMaskBg(true)
end

function SelectGiftView:__delete()

end

function SelectGiftView:ReleaseCallBack()
	for k,v in pairs(self.cell_list) do
		if v then
			v:DeleteMe()
			v = nil
		end
	end
	self.cell_list = nil
	self.list_view = nil
	self.list_len = nil
	self.left = nil
	self.right = nil
end

function SelectGiftView:LoadCallBack()
	self.left = self:FindVariable("is_left")
	self.right = self:FindVariable("is_right")	
	self:ListenEvent("ClickLeft", BindTool.Bind(self.ClickLeft, self))
	self:ListenEvent("ClickRight", BindTool.Bind(self.ClickRight, self))		
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self.cell_list = {}
	self.list_view = self:FindObj("GiftList")
	self.list_len = self:FindVariable("ListLen") --只有2个物品时用来偏移
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshCell, self)
	self:Flush()
end

function SelectGiftView:CloseWindow()
	self:Close()
end

function SelectGiftView:ClickRight()
	local move_pos = 1 / ((math.ceil(self:GetNumberOfCells() / ItemCount)) - 1) 
	if self.list_view.scroll_rect.horizontalNormalizedPosition >= 1 then 
		self.list_view.scroll_rect.horizontalNormalizedPosition = 1
	else
		self.list_view.scroll_rect.horizontalNormalizedPosition = self.list_view.scroll_rect.horizontalNormalizedPosition + move_pos
	end
end

function SelectGiftView:ClickLeft()
	local move_pos = 1 / ((math.ceil(self:GetNumberOfCells() / ItemCount)) - 1) 
	if self.list_view.scroll_rect.horizontalNormalizedPosition <= 0 then 
		self.list_view.scroll_rect.horizontalNormalizedPosition = 0
	else
		self.list_view.scroll_rect.horizontalNormalizedPosition = self.list_view.scroll_rect.horizontalNormalizedPosition - move_pos
	end
end

function SelectGiftView:OpenCallBack()
	self:Flush()
end

function SelectGiftView:GetNumberOfCells()
	local gift_id = MojieData.Instance:GetMojieGiftId()
	local data_list = ItemData.Instance:GetGiftItemList(gift_id)
	if self.list_len then
		self.list_len:SetValue(#data_list)
	end
	return #data_list
end

function SelectGiftView:RefreshCell(cell, data_index)
	data_index = data_index + 1
	local star_cell = self.cell_list[cell]
	if star_cell == nil then
		star_cell = MojieGiftItem.New(cell.gameObject)
		star_cell.parent_view = self
		self.cell_list[cell] = star_cell
	end
	star_cell:SetItemIndex(data_index)
	star_cell:SetData({})
	

	if self:GetNumberOfCells() > ItemCount then
		if self.list_view.scroll_rect.horizontalNormalizedPosition <= 0 then 
			self.right:SetValue(true) 
			self.left:SetValue(false)
		elseif self.list_view.scroll_rect.horizontalNormalizedPosition >= 1 then
			self.right:SetValue(false)
			self.left:SetValue(true)
		else
			self.right:SetValue(true)
			self.left:SetValue(true)
		end
	else
		self.right:SetValue(false)
		self.left:SetValue(false)
	end
end

function SelectGiftView:OnFlush()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
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
	self.item_cell:SetData(data_list[self.item_index])
end