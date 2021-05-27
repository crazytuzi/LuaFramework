BagQuickUseView = BagQuickUseView or BaseClass(XuiBaseView)

function BagQuickUseView:__init()
	self.is_modal = true
	self.config_tab = {
		{"role_ui_cfg", 11, {0}},
	}

	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback, self)
end

function BagQuickUseView:__delete()
end

function BagQuickUseView:ReleaseCallBack()
	if nil ~= self.quick_use_list then
		self.quick_use_list:DeleteMe()
		self.quick_use_list = nil
	end
end

function BagQuickUseView:LoadCallBack()
	local ph_list = self.ph_list.ph_quick_use_list
	self.quick_use_list = ListView.New()
	self.quick_use_list:CreateView({width = ph_list.w, height = ph_list.h, direction=1, itemRender = QuickUseRender, ui_config = self.ph_list.ph_quick_use_item})
	self.quick_use_list:SetItemsInterval(5)
	self.quick_use_list:GetView():setPosition(ph_list.x, ph_list.y)
	self.root_node:addChild(self.quick_use_list:GetView(), 1)

	self.node_t_list.btn_all_use.node:addClickEventListener(BindTool.Bind1(self.OnClickAllUseHandler, self))
end

function BagQuickUseView:ShowIndexCallBack()
	self:Flush()
end

function BagQuickUseView:OpenCallBack()
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
end

function BagQuickUseView:CloseCallBack()
	-- ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)

	BagCtrl.Instance:SendKnapsackStoragePutInOrder(GameEnum.STORAGER_TYPE_BAG, 0)
end

function BagQuickUseView:OnFlush()
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
	local data = {}
	local item_cfg = nil
	for k,v in pairs(bag_data_list) do
		item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg and 1 == item_cfg.choose_use then
			table.insert(data, v)
		end
	end
	self.quick_use_list:SetDataList(data)
end

function BagQuickUseView:ItemDataChangeCallback()
	if ItemData.Instance:GetIsHasQuickUseItem() then
		self:Flush()
	else
		self:Close()
	end
end

function BagQuickUseView:OnClickAllUseHandler()
	local bag_data_list = ItemData.Instance:GetBagItemDataList()
	for k,v in pairs(bag_data_list) do
		item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if nil ~= item_cfg and 1 == item_cfg.choose_use then
			BagCtrl.Instance:SendUseItem(v.index, 0, v.num, item_cfg.need_gold)
		end
	end

	self:Close()
end



-------------------------------------------------
-------------------------快速使用Render------------------------
-------------------------------------------------
QuickUseRender = QuickUseRender or BaseClass(BaseRender)

function QuickUseRender:__init()

end

function QuickUseRender:__delete()
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function QuickUseRender:CreateChild()
	BaseRender.CreateChild(self)

	local ph_cell = self.ph_list.ph_cell
	self.cell = BaseCell.New()
	self.cell:SetPosition(ph_cell.x, ph_cell.y)
	self.view:addChild(self.cell:GetView(), 100)

	self.node_tree.btn_use.node:addClickEventListener(BindTool.Bind1(self.OnClickUseHandler, self))
end

function QuickUseRender:OnFlush()
	self.cell:SetData(self.data)

	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.node_tree.label_name.node:setString(item_cfg.name)
	self.node_tree.label_name.node:setColor(ITEM_COLOR[item_cfg.color])
end

function QuickUseRender:OnClickUseHandler()
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	BagCtrl.Instance:SendUseItem(self.data.index, 0, self.data.num, item_cfg.need_gold)
end

function QuickUseRender:CreateSelectEffect()
end
