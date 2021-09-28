ShengXiaoBagView = ShengXiaoBagView or BaseClass(BaseView)

local MAX_COUNT = 5

function ShengXiaoBagView:__init()
	self.ui_config = {"uis/views/shengxiaoview_prefab", "ShengXiaoBagView"}
	self.view_layer = UiLayer.Pop
	self.chapter = 1
	self.item_cell_list = {}
end

function ShengXiaoBagView:__delete()

end

function ShengXiaoBagView:ReleaseCallBack()
	for k,v in pairs(self.item_cell_list) do
		v:DeleteMe()
		v = nil
	end
	self.item_cell_list = {}
	self.bottom = nil
	self.compose_desc = nil
	self.button = nil
	self.can_compose = nil
	self.list_view = nil

	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end
	self.select_index = 1
	self.chapter = 1
end

function ShengXiaoBagView:LoadCallBack()
	self:ListenEvent("CloseWindow", BindTool.Bind(self.CloseWindow, self))
	self:ListenEvent("OnClickCompose", BindTool.Bind(self.OnClickCompose, self))
	self:ListenEvent("OnClickUse", BindTool.Bind(self.OnClickUse, self))
	self.bottom = self:FindObj("Bottom").toggle_group
	self.button = self:FindObj("BtnCompose")

	self.list_view = self:FindObj("ListView")

	local delgate = self.list_view.list_simple_delegate

	delgate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	delgate.CellRefreshDel = BindTool.Bind(self.RefreshView, self)

	self.list_view.scroller:ReloadData(0)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.compose_desc = self:FindVariable("compose_desc")
	self.can_compose = self:FindVariable("can_compose")
	self.can_compose:SetValue(true)
	self.select_index = 1
	self:Flush()
end


function ShengXiaoBagView:ItemDataChangeCallback()
	self:Flush()
end

function ShengXiaoBagView:OpenCallBack()
	self:Flush()

end

function ShengXiaoBagView:FlushDesc()
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	--橙色不能合成红色，所以-1
	if self.select_index > 0 and self.select_index < MAX_COUNT - 1 then
		local chose_data = bag_list[self.select_index + 1]
		local compose_item = ComposeData.Instance:GetComposeItem(chose_data.item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(chose_data.item_id)
		local name_str = "<color="..SOUL_NAME_COLOR[item_cfg.color]..">"..item_cfg.name .."</color>"
		local desc = string.format(Language.ShengXiao.PieceCompose, compose_item.stuff_count_1, name_str)
		self.compose_desc:SetValue(desc)
	else
		self.compose_desc:SetValue("")
	end
	self.button.grayscale.GrayScale = self.select_index < (MAX_COUNT - 1) and 0 or 255
	self.can_compose:SetValue(self.select_index < (MAX_COUNT - 1))
	self:FlushHl()
end

function ShengXiaoBagView:OnFlush()
	self.list_view.scroller:RefreshAndReloadActiveCellViews(true)
end

function ShengXiaoBagView:CloseWindow()
	self:Close()
end

function ShengXiaoBagView:SetViewChapter(chapter)
	self.chapter = chapter
end

function ShengXiaoBagView:OnClickCompose()
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseFirst)
		return
	end
	if self.select_index < (MAX_COUNT - 1) then
		local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
		local chose_data = bag_list[self.select_index + 1]
		local compose_item = ComposeData.Instance:GetComposeItem(chose_data.item_id)
		local bag_num = bag_list[self.select_index].num
		ComposeCtrl.Instance:SendItemCompose(compose_item.producd_seq, 1, 0)
	end
end

function ShengXiaoBagView:OnClickUse()
	if self.select_index == 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.ShengXiao.ChoseFirst)
		return
	end
	local bag_list = ShengXiaoData.Instance:GetBeadInBagList()
	local chose_data = bag_list[self.select_index]
	if chose_data.num > 0 then
		ShengXiaoCtrl.Instance:SendPutBeadReq(self.select_index, self.chapter - 1)
	else
		TipsCtrl.Instance:ShowItemGetWayView(chose_data.item_id)
	end
end

function ShengXiaoBagView:RefreshView(cell, data_index)
	data_index = data_index + 1
	local item = self.item_cell_list[cell]
	local data = ShengXiaoData.Instance:GetBeadInBagList()
	if nil == data or nil == data[data_index] then
		return 
	end

	if nil == item then
		item = BagItemCell.New(cell)
		self.item_cell_list[cell] = item
		item.parent_view = self
	end

	item:SetIndex(data_index)
	item:SetData(data[data_index])
end

function ShengXiaoBagView:GetNumberOfCells()
	local list = ShengXiaoData.Instance:GetBeadInBagList()
	if nil == list then
		return 0
	end

	return GetListNum(list)
end

function ShengXiaoBagView:SetSelectIndex(index)
	self.select_index = index
end

function ShengXiaoBagView:GetSelectIndex()
	return self.select_index
end

function ShengXiaoBagView:FlushHl()
	for k,v in pairs(self.item_cell_list) do
		if v then
			v:FlushHL(self.select_index)
		end
	end
end

BagItemCell = BagItemCell or BaseClass(BaseCell)

function BagItemCell:__init()
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self.root_node)

	self.item_cell:ListenClick(BindTool.Bind(self.ClickItem, self))
end

function BagItemCell:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	self.parent_view = nil 
end

function BagItemCell:OnFlush()
	if nil == self.data then
		return
	end

	self.item_cell:SetData(self.data)
	if 0 == self.data.num then
		self.item_cell:SetQualityGray(true)
		self.item_cell:SetIconGrayScale(true)
	else
		self.item_cell:SetQualityGray(false)
		self.item_cell:SetIconGrayScale(false)
	end

	self:FlushHL(self.parent_view:GetSelectIndex())
end

function BagItemCell:ClickItem()
	self.parent_view:SetSelectIndex(self.index)
	self.parent_view:FlushDesc()
end

function BagItemCell:FlushHL(index)
	self.item_cell:SetHighLight(index == self.index)
end
