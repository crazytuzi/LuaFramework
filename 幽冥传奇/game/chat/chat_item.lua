ChatItemView = ChatItemView or BaseClass(XuiBaseView)

function ChatItemView:__init()
	self.ctrl = ChatCtrl.Instance
	
	-- self.is_modal = true
	self.is_any_click_close = true

	self.texture_path_list[1] = 'res/xui/chat.png'
	self.config_tab = {{"chat_ui_cfg", 4, {0}}}
	self.selcetec_index = 1
	self:SetRootNodeOffPos({x = 40, y = -46})
end

function ChatItemView:__delete()
	if nil ~= self.bag_grid then
		self.bag_grid:DeleteMe()
		self.bag_grid = nil
	end
end

function ChatItemView:LoadCallBack()
	self:InitChatItem()
	self:RegisterChatItemEvent()
end

function ChatItemView:InitChatItem()
	-- self.tab_list = {self.node_t_list.btn_chat_item_tab1.node, self.node_t_list.btn_chat_item_tab2.node}
	local bag_cells = 84
	--创建格子
	self.bag_grid = BaseGrid.New()
	local grid_node = self.bag_grid:CreateCells({w = 580, h = 330 , cell_count = bag_cells, col = 7, row = 4, is_show_tips = false})
	self.node_t_list.layout_chat_item.node:addChild(grid_node,1000, 1000)  				--将网格实体添加显示	
	grid_node:setPosition(60, 12)

	self.bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))

	self.bag_radio = RadioButton.New()
	local radio_btns = {}
	for i = 0, 2 do
		 radio_btns[i + 1] = self.node_t_list["toggle_radio" .. i].node
		 self.node_t_list["toggle_radio" .. i].node:setVisible(false)
	end
	self.bag_radio:SetToggleList(radio_btns)
	self.bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
	self.bag_grid:SetRadioBtn(self.bag_radio)

	ItemData.Instance:NotifyDataChangeCallBack(BindTool.Bind1(self.OnItemDataListChange, self),true)
end

function ChatItemView:OpenCallBack()

end

function ChatItemView:ShowIndexCallBack(index)
	self:SetTabSelect(self.selcetec_index)
end


function ChatItemView:SetTabSelect(index)
	-- for k,v in pairs(self.tab_list) do
	-- 	v:setTogglePressed(k == index)
	-- end
	local item_data = BagData.Instance:GetItemDataList()
	if index ~= 1 then
		item_data = TableCopy(EquipData.Instance:GetEquipData())
	end
	local data = {}
	local i = 0
	for k,v in pairs(item_data) do
		data[i] = v
		i = i + 1
	end
	self.bag_grid:SetDataList(data)
	--初始化的时候0为恢复为第一页物品
	--self.bag_grid:ChangeToPage(0)
	self.selcetec_index = index
end


function ChatItemView:BagRadioHandler(index)
	if nil ~= self.bag_grid then
		self.bag_grid:ChangeToPage(index)
	end
end

function ChatItemView:RegisterChatItemEvent()
	XUI.AddClickEventListener(self.node_t_list.btn_chat_item_tab1.node, BindTool.Bind2(self.SetTabSelect, self, 1))
	XUI.AddClickEventListener(self.node_t_list.btn_chat_item_tab2.node, BindTool.Bind2(self.SetTabSelect, self, 2))
	self.node_t_list.btn_chat_item_tab1.node:setTitleText("背\n包")
	self.node_t_list.btn_chat_item_tab2.node:setTitleText("身\n上")
end

function ChatItemView:OnItemDataListChange(change_type, item_id, item_index, series)
	self:Flush({item_datalist_change = true})
end

function ChatItemView:OnFlush(param_t)
	if param_t.item_datalist_change then
		self:SetTabSelect(self.selcetec_index)
	end
end

function ChatItemView:SelectCellCallBack(cell)
	if nil == cell then
		return
	end
	
	local cell_data = cell:GetData()
	if nil == cell_data then
		return
	end
	local item_data = ItemData.Instance:GetItemConfig(cell_data.item_id)
	if nil == item_data then
		return
	end
	TipCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_CHAT_BAG, {selcetec_index = self.selcetec_index})
end

function ChatItemView:SetPosition(x, y)
	if nil ~= self.root_node then
		self.root_node:setPosition(x, y)
	end
end
