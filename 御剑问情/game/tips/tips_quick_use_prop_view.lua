TipsQuickUsePropView = TipsQuickUsePropView or BaseClass(BaseView)

function TipsQuickUsePropView:__init()
	self.ui_config = {"uis/views/tips/proptips_prefab", "PropQuickUseTip"}
	self.view_layer = UiLayer.Pop
	self.cell_list = {}
	self.is_click_all = false
	self.data_list = {}
	self.play_audio = true
end

function TipsQuickUsePropView:LoadCallBack()
	self:ListenEvent("OnClickClose",
		BindTool.Bind(self.OnClickClose, self))
	self:ListenEvent("OnClickUseAll",
		BindTool.Bind(self.OnClickUseAll, self))

	self.list_view = self:FindObj("ListView")
end

function TipsQuickUsePropView:__delete()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.is_click_all = nil
	self.data_list = {}
	self.close_callback = nil
end

function TipsQuickUsePropView:ReleaseCallBack()
	for k, v in pairs(self.cell_list) do
		v:DeleteMe()
	end
	self.cell_list = {}
	self.is_click_all = nil
	self.data_list = {}
	self.close_callback = nil

	-- 清理变量和对象
	self.list_view = nil
end

function TipsQuickUsePropView:GetNumberOfCells()
	return #PackageData.Instance:GetQuickUseItem(self.data_list)
end

function TipsQuickUsePropView:RefreshMountCell(cell, data_index)
	local item_cell = self.cell_list[cell]
	if not item_cell then
		item_cell = QuickUsePropTipCell.New(cell)
		self.cell_list[cell] = item_cell
	end
	local data = PackageData.Instance:GetQuickUseItem(self.data_list)[data_index + 1]
	item_cell:SetData(data)
	item_cell:ListenClick(BindTool.Bind(self.ClickUse, self, data))
end

function TipsQuickUsePropView:ClickUse(data)
	if not data then return end
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	self.is_click_all = false
	PackageCtrl.Instance:SendUseItem(data.index, data.num, data.sub_type, item_cfg and item_cfg.need_gold or 0)
end

function TipsQuickUsePropView:OnClickClose()
	self:Close()
end

function TipsQuickUsePropView:OpenCallBack()
	self.is_click_all = false
	local list_delegate = self.list_view.list_simple_delegate
	list_delegate.NumberOfCellsDel = BindTool.Bind(self.GetNumberOfCells, self)
	list_delegate.CellRefreshDel = BindTool.Bind(self.RefreshMountCell, self)

	if self.item_data_event == nil then
		self.item_data_event = BindTool.Bind1(self.ItemDataChangeCallback, self)
		ItemData.Instance:NotifyDataChangeCallBack(self.item_data_event)
	end
	self.list_view.scroll_rect.normalizedPosition = Vector2(0, 1)
	self:FlushCellView()
end

function TipsQuickUsePropView:CloseCallBack()
	if self.item_data_event ~= nil then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_data_event)
		self.item_data_event = nil
	end

	if self.close_callback then
		self.close_callback()
		self.close_callback = nil
	end
end

function TipsQuickUsePropView:ItemDataChangeCallback(item_id, index, reason, put_reason, old_num, new_num)
	if not self.is_click_all then
		if #PackageData.Instance:GetQuickUseItem(self.data_list) <= 0 then
			self:Close()
			return
		end
		self:FlushCellView()
	end
end

function TipsQuickUsePropView:OnClickUseAll()
	self.is_click_all = true
	local max_count = #PackageData.Instance:GetQuickUseItem(self.data_list)
	local count = 0
	for k, v in pairs(PackageData.Instance:GetQuickUseItem(self.data_list)) do
		PackageCtrl.Instance:SendUseItem(v.index, v.num, v.sub_type, 0)
		count = count + 1
		if count >= max_count then
			self:Close()
			self.is_click_all = false
		end
	end
end

function TipsQuickUsePropView:SetDataList(data_list)
	self.data_list = data_list
end

function TipsQuickUsePropView:SetCloseCallBack(close_callback)
	self.close_callback = close_callback
end

function TipsQuickUsePropView:FlushCellView()
	if self.list_view.scroller.isActiveAndEnabled then
		self.list_view.scroller:ReloadData(0)
	end
end


QuickUsePropTipCell = QuickUsePropTipCell or BaseClass(BaseRender)

function QuickUsePropTipCell:__init(instance)
	self.item = ItemCell.New()
	self.item:SetInstanceParent(self:FindObj("Item"))

	self.prop_name = self:FindVariable("PropName")
end

function QuickUsePropTipCell:__delete()
	if self.item then
		self.item:DeleteMe()
		self.item = nil
	end
end

function QuickUsePropTipCell:SetData(data)
	if not data then return end
	self.item:SetData(data)
	local item_cfg = ItemData.Instance:GetItemConfig(data.item_id)
	if not item_cfg then return end

	local name_str = "<color="..ITEM_TIP_NAME_COLOR[item_cfg.color]..">"..item_cfg.name.."</color>"
	self.prop_name:SetValue(name_str)
end

function QuickUsePropTipCell:ListenClick(handler)
	self:ClearEvent("ClickUse")
	self:ListenEvent("ClickUse", handler)
end