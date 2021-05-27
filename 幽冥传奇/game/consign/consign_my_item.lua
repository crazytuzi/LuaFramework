local ConsignSellView = BaseClass(SubView)

ConsignSellView.EditBoxInitNum = 0

function ConsignSellView:__init()
	self.texture_path_list[1] = 'res/xui/consign.png'
	self.config_tab = {
		{"consign_ui_cfg", 3, {0}},
		{"consign_ui_cfg", 4, {0}, false},
	}
	if ConsignSellView.Instance then
		ErrorLog("[ConsignData] Attemp to create a singleton twice !")
	end
	
	ConsignSellView.Instance = self
end

function ConsignSellView:LoadCallBack()
	self.layout_my_consign = self.node_t_list.layout_my_consign.node
	self.layout_consign_item = self.node_t_list.layout_consign_item.node
	
	self.node_t_list.btn_sell_tips.node:addClickEventListener(BindTool.Bind1(self.OnClickSellTipsHandler, self))
	self.node_t_list.btn_shelves_item.node:addClickEventListener(BindTool.Bind1(self.OnClickShelvesItemHandler, self))
	local ph = self.ph_list.ph_item_path
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x, ph.y)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_1.node:addChild(self.cell:GetView(), 103)
	end	
	self:CreateCell()
	self:CreateEditYuanbao()
	------ 寄售天数 ----
	-- self:UpdateMyConsignList()
	
	if not self.has_consign_my_item_view_create then
		ConsignCtrl.Instance:SendGetMyConsignItemsReq()
		self.has_consign_my_item_view_create = true
	end
	
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(ConsignData.Instance, self):AddEventListener(ConsignData.MY_CONSIGN_DATA, BindTool.Bind(self.OnMyConsignData, self))--事件监听
	EventProxy.New(ConsignData.Instance, self):AddEventListener(ConsignData.PUTAWAY_RESULT, BindTool.Bind(self.EmptyMyCell, self))--事件监听
	self.consign_cell_data = nil
end

function ConsignSellView:ReleaseCallBack()
	if self.consign_bag_grid then
		self.consign_bag_grid:DeleteMe()
		self.consign_bag_grid = nil
	end
	
	if self.consign_bag_radio then
		self.consign_bag_radio:DeleteMe()
		self.consign_bag_radio = nil
	end
	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end	
	
	if nil ~= self.consign_cell_data then
		self.consign_cell_data = nil
	end
	
	if nil ~= self.consign_day_list then
		self.consign_day_list:DeleteMe()
		self.consign_day_list = nil
	end
	
	if self.has_consign_my_item_view_create then
		self.has_consign_my_item_view_create = nil
	end
end

-------------------------------------
-- 按钮 --
-- 上架商品
function ConsignSellView:OnClickShelvesItemHandler()
	if nil == self.consign_cell_data then
		SysMsgCtrl.Instance:ErrorRemind(Language.Consign.ConsignDataNil)
		return
	end
	
	local my_consign_data = ConsignData.Instance:GetMyConsignItemsData()
	if my_consign_data.item_num >= ConsignData.MaxConsignNum then
		SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Consign.ConsignMax, my_consign_data.item_num))
		return
	end
	
	local price = tonumber(self.edit_yuanbao:getText())
	if price <= 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Consign.PriceIsZero)
	else
		ConsignCtrl.Instance:SendConsignItemReq(self.consign_cell_data.series, price)
	end
end

-- 说明
function ConsignSellView:OnClickSellTipsHandler()
	DescTip.Instance:SetContent(Language.Consign.SellDetail, Language.Consign.SellTitle)
end

function ConsignSellView:ShowIndexCallBack()
	self:Flush()
end

function ConsignSellView:OnFlush(param_t)
	---- 出售界面 ----
	local bd_yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)		--绑定元宝
	local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)				--元宝
	-- self.node_t_list.lbl_bd_gold_count.node:setString(bd_yuanbao)
	-- self.node_t_list.lbl_gold_count.node:setString(yuanbao)
	
	self:OnFlushConsignMyItemInformation()
	self.node_t_list.txt_sale_price.node:setString(self.edit_yuanbao:getText())
	-- 刷新右侧背包网格
	self:OnFlushConsignMyItemBagGrid()
end

function ConsignSellView:OnMyConsignData()
	self:Flush()
end

-------------------------------------
-- 出售界面
function ConsignSellView:SetMyItemCellData(data)
	if nil ~= self.cell then
		self.consign_cell_data = data
		self.cell:SetData(data)
		self:Flush()
	end
end

function ConsignSellView:CreateCell()
	self.consign_bag_grid = BaseGrid.New()
	self.consign_bag_grid:SetGridName(GRID_TYPE_BAG)
	local ph_grid = self.ph_list.ph_grid
	local grid_node = self.consign_bag_grid:CreateCells({w = ph_grid.w, h = ph_grid.h, cell_count = 75, col = 5, row = 5, direction = ScrollDir.Vertical})
	grid_node:setPosition(ph_grid.x, ph_grid.y)
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_consign_item.node:addChild(grid_node, 999)
	self.bag_index = self.consign_bag_grid:GetCurPageIndex()
	self.consign_bag_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.consign_bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	
	self.consign_bag_radio = RadioButton.New()
	-- self.consign_bag_radio:SetRadioButton(self.node_t_list.layout_bag_grid_page)
	self.consign_bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
	self.consign_bag_grid:SetRadioBtn(self.consign_bag_radio)
end

function ConsignSellView:CreateEditYuanbao()
	--设置用户名输入框
	self.edit_yuanbao = self.node_t_list.edit_yuanbao.node
	self.edit_yuanbao:setFontSize(22)
	self.edit_yuanbao:setFontColor(COLOR3B.G_W)
	self.edit_yuanbao:setText(ConsignSellView.EditBoxInitNum)
	self.edit_yuanbao:registerScriptEditBoxHandler(BindTool.Bind(self.ExamineEditYuanbaoNum, self, self.edit_yuanbao, 9))
end

function ConsignSellView:ExamineEditYuanbaoNum(edit, num, e_type)
	if e_type == "return" then
		local text = edit:getText()
		text = string.gsub(text, "[^0-9]", "")			-- 非数字
		edit:setText((text ~= "" and tonumber(text) > 0) and text or ConsignSellView.EditBoxInitNum)
		
		local text_num = AdapterToLua:utf8FontCount(text)
		if text_num > num then
			text = AdapterToLua:utf8TruncateByFontCount(text, num)
			edit:setText(text)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Consign.ContentToLong, num))
		end
		
		self:Flush()
	end
end

function ConsignSellView:OnPageChangeCallBack(grid, page_index, prve_page_index)
end

function ConsignSellView:SelectCellCallBack(cell)
	if cell == nil then
		return
	end
	
	local cell_data = cell:GetData()
	TipCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_CONSIGN_ON_SELL)				--打开tip,提示投入
end

function ConsignSellView:BagRadioHandler(index)
	if nil ~= self.consign_bag_grid then
		self.consign_bag_grid:ChangeToPage(index)
	end
end

function ConsignSellView:OnFlushConsignMyItemInformation()
	if nil == self.consign_cell_data then return end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.consign_cell_data.item_id)
	if nil == item_cfg then return end
	
	local str = EquipTip.GetEquipName(item_cfg, self.consign_cell_data, EquipTip.FROM_CONSIGN_ON_SELL)
	RichTextUtil.ParseRichText(self.node_t_list.rich_item_name.node, str, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	self.node_t_list.txt_item_type.node:setString(Language.EquipTypeName[item_cfg.type] or ItemData.GetConsignmentTypeName(item_cfg.type) or "")
	
	local lbl_level = self.node_t_list.txt_consume_level.node
	local level = 0
	local zhuan = 0
	for k, v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				lbl_level:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			zhuan = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				lbl_level:setColor(COLOR3B.RED)
			end
		end
	end
	if zhuan > 0 then
		lbl_level:setString(string.format(Language.Consign.ItemLevelZhuan, zhuan, level))
	else
		lbl_level:setString(level)
	end
end

function ConsignSellView:OnBagItemChange()
	self:Flush()
end

function ConsignSellView:OnFlushConsignMyItemBagGrid()
	if nil == self.consign_bag_grid then return end
	
	self.consign_bag_grid:SetDataList(ConsignData.Instance:GetBagItemDataList())
end

function ConsignSellView:EmptyMyCell()
	self.result = ConsignData.Instance:GetResult()
	if self.result==1 then
		self:SetMyItemCellData(nil)
		self.node_t_list.txt_item_type.node:setString("")
		self.node_t_list.txt_consume_level.node:setString("")
		self.node_t_list.rich_item_name.node:removeAllElements()
		self.edit_yuanbao:setText(ConsignSellView.EditBoxInitNum)
	end
end


-------------------------------------
-- -- 寄售天数
-- function ConsignSellView:UpdateMyConsignList()
-- 	if self.consign_day_list == nil then
-- 		local ph = self.ph_list.ph_js_day_list
-- 		self.consign_day_list = ListView.New()
-- 		self.consign_day_list:Create(ph.x, ph.y, ph.w, ph.h, nil, ConsignItemRender, ScrollDir.Horizontal, nil, self.ph_list.ph_js_day_item)
-- 		self.consign_day_list:GetView():setAnchorPoint(0, 0)
-- 		self.consign_day_list:SetItemsInterval(2)
-- 		self.consign_day_list:SetJumpDirection(ListView.Top)
-- 		self.consign_day_list:JumpToTop(true)
-- 		self.layout_my_consign:addChild(self.consign_day_list:GetView(), 100)
-- 	end
	
-- 	local data = {"", "", ""}
-- 	self.consign_day_list:SetDataList(data)
-- end

-------------------------------------
-- ConsignItemRender
-------------------------------------
-- ConsignItemRender = ConsignItemRender or BaseClass(BaseRender)
-- function ConsignItemRender:__init()
-- end

-- function ConsignItemRender:__delete()	
-- 	if nil ~= self.cell then
-- 		self.cell:DeleteMe()
-- 		self.cell = nil
-- 	end
-- end

-- function ConsignItemRender:CreateChild()
-- 	BaseRender.CreateChild(self)
-- 	local ph = self.ph_list.ph_item_cell
-- 	if nil == self.cell then
-- 		self.cell = BaseCell.New()
-- 		self.cell:SetPosition(ph.x, ph.y)
-- 		self.cell:SetIndex(i)
-- 		self.cell:SetAnchorPoint(0.5, 0.5)
-- 		self.view:addChild(self.cell:GetView(), 103)
		
-- 		self.cell:SetName(GRID_TYPE_BAG)
-- 	end
	
-- 	self.node_tree.btn_remove.node:addClickEventListener(BindTool.Bind(self.OnClickRemoveHandler, self))
-- end

-- function ConsignItemRender:OnClickRemoveHandler()
-- 	if nil == self.data then return end
-- 	local operation = 0
-- 	if self.data.remain_time <= Status.NowTime then operation = 1 end
-- 	ConsignCtrl.Instance:SendCancelConsignItemReq(self.data.item_data.series, self.data.item_handle, operation)
-- end

-- function ConsignItemRender:OnFlush()

-- end

return ConsignSellView 