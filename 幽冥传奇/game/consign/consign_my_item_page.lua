ConsignMyItemPage = ConsignMyItemPage or BaseClass()

ConsignMyItemPage.EditBoxInitNum = 2

function ConsignMyItemPage:__init()
	self.view = nil
end

function ConsignMyItemPage:__delete()
	self:RemoveEvent()
	if self.consign_bag_grid then
		self.consign_bag_grid:DeleteMe()
		self.consign_bag_grid = nil
	end

	-- if self.consign_bag_radio then
	-- 	self.consign_bag_radio:DeleteMe()
	-- 	self.consign_bag_radio = nil
	-- end

	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end	

	if nil ~= self.consign_cell_data then
		self.consign_cell_data = nil
	end

	if nil ~= self.my_consign_list then
		self.my_consign_list:DeleteMe()
		self.my_consign_list = nil
	end

	if self.has_consign_my_item_view_create then
		self.has_consign_my_item_view_create = nil
	end

	self.view = nil
end

--初始化页面
function ConsignMyItemPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.ph_list = self.view.ph_list
	self.node_t_list = self.view.node_t_list
	--self.layout_my_consign = self.node_t_list.layout_my_consign.node
	self.layout_consign_item = self.node_t_list.layout_consign_item.node
	self:InitEvent()
	
	local ph = self.view.ph_list.ph_item_path
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x + ph.w / 2, ph.y + ph.h / 2)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.node_t_list.layout_consign_item.node:addChild(self.cell:GetView(), 103)
	end	
	self:CreateCell()
	self:CreateEditYuanbao()

	if not self.has_consign_my_item_view_create then
		self.has_consign_my_item_view_create = true
	end
	self:OnFlushConsignMyItem()
end

function ConsignMyItemPage:InitEvent()
	self.my_consign_info_event = GlobalEventSystem:Bind(ConsignEventType.GET_MY_CONSIGN_INFO, BindTool.Bind(self.OnFlushConsignMyItem, self))
	self.node_t_list.btn_sell_tips.node:addClickEventListener(BindTool.Bind1(self.OnClickSellTipsHandler, self))
	self.node_t_list.btn_shelves_item.node:addClickEventListener(BindTool.Bind1(self.OnClickShelvesItemHandler, self))
	--self.node_t_list.btn_myself_consign.node:addClickEventListener(BindTool.Bind1(self.OnClickMyConsignHandler, self))
	--self.node_t_list.btn_back.node:addClickEventListener(BindTool.Bind1(self.OnClickBackToConsignItemHandler, self))
end

--移除事件
function ConsignMyItemPage:RemoveEvent()
	if self.my_consign_info_event then
		GlobalEventSystem:UnBind(self.my_consign_info_event)
		self.my_consign_info_event = nil
	end
end

--更新视图界面
function ConsignMyItemPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			-- self:OnFlushConsignMyItem()
		end
	end
end

-------------------------------------
-- 按钮 --
-- 上架商品
function ConsignMyItemPage:OnClickShelvesItemHandler()
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
		ConsignCtrl.Instance:SendSearchConsignItemsReq()
		ConsignCtrl.Instance:SendGetMyConsignItemsReq()
	end
end

-- -- 我的寄售
-- function ConsignMyItemPage:OnClickMyConsignHandler()
-- 	self.layout_consign_item:setVisible(false)
-- 	self.layout_my_consign:setVisible(true)
-- end

-- -- 返回出售
-- function ConsignMyItemPage:OnClickBackToConsignItemHandler()
-- 	self.layout_consign_item:setVisible(true)
-- 	self.layout_my_consign:setVisible(false)
-- end

-- 说明
function ConsignMyItemPage:OnClickSellTipsHandler()
	DescTip.Instance:SetContent(Language.Consign.SellDetail, Language.Consign.SellTitle)
end


function ConsignMyItemPage:OnFlushConsignMyItem()
	---- 出售界面 ----
	--local bd_yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_BIND_GOLD)		--绑定元宝
	local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)				--元宝
	--self.node_t_list.lbl_bd_gold_count.node:setString(bd_yuanbao) 
	self.node_t_list.lbl_gold_count.node:setString(yuanbao)

	self:OnFlushConsignMyItemInformation()
	self.node_t_list.txt_sale_price.node:setString(self.edit_yuanbao:getText()) 
	-- 刷新右侧背包网格
	self:OnFlushConsignMyItemBagGrid()

	---- 我的寄售界面 ----
	--self:OnFlushMyConsignList()
end


-------------------------------------
-- 出售界面
function ConsignMyItemPage:SetMyItemCellData(data)
	if nil ~= self.cell then
		self.consign_cell_data = data
		self.cell:SetData(data)
		self:OnFlushConsignMyItemInformation()
	end
end

function ConsignMyItemPage:CreateCell()
	self.consign_bag_grid = BaseGrid.New()
	self.consign_bag_grid:SetGridName(GRID_TYPE_BAG)
	local ph_grid = self.ph_list.ph_grid
	local grid_node = self.consign_bag_grid:CreateCells({w = ph_grid.w, h = ph_grid.h, cell_count = 75, col = 5, row = 5})
	grid_node:setPosition(ph_grid.x, ph_grid.y)
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_consign_item.node:addChild(grid_node, 999)
	self.bag_index = self.consign_bag_grid:GetCurPageIndex()
	self.consign_bag_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.consign_bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))

	-- self.consign_bag_radio = RadioButton.New()
	-- self.consign_bag_radio:SetRadioButton(self.node_t_list.layout_bag_grid_page)
	-- self.consign_bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
	-- self.consign_bag_grid:SetRadioBtn(self.consign_bag_radio)
end

function ConsignMyItemPage:CreateEditYuanbao()
	--设置用户名输入框
	self.edit_yuanbao = self.node_t_list.edit_yuanbao.node
	self.edit_yuanbao:setFontSize(22)
	self.edit_yuanbao:setFontColor(COLOR3B.G_W)
	self.edit_yuanbao:setText(ConsignMyItemPage.EditBoxInitNum)
	self.edit_yuanbao:registerScriptEditBoxHandler(BindTool.Bind(self.ExamineEditYuanbaoNum, self, self.edit_yuanbao, 9))
end

function ConsignMyItemPage:ExamineEditYuanbaoNum(edit, num, e_type)
	if e_type == "return" then
		local text = edit:getText()
		text = string.gsub(text, "[^0-9]", "")			-- 非数字
		edit:setText((text ~= "" and tonumber(text) > 0) and text or ConsignMyItemPage.EditBoxInitNum)

		local text_num = AdapterToLua:utf8FontCount(text)
		if text_num > num then
			text = AdapterToLua:utf8TruncateByFontCount(text, num)
			edit:setText(text)
			SysMsgCtrl.Instance:ErrorRemind(string.format(Language.Consign.ContentToLong, num))
		end

		self:OnFlushConsignMyItem()
	end
end

function ConsignMyItemPage:OnPageChangeCallBack(grid, page_index, prve_page_index)
end

function ConsignMyItemPage:SelectCellCallBack(cell)
	if cell == nil then
		return
	end

	local cell_data = cell:GetData()
	TipsCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_CONSIGN_ON_SELL)				--打开tip,提示投入
end

function ConsignMyItemPage:BagRadioHandler(index)
	if nil ~= self.consign_bag_grid then
		self.consign_bag_grid:ChangeToPage(index)
	end
end

function ConsignMyItemPage:OnFlushConsignMyItemInformation()
	if nil == self.consign_cell_data then return end
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.consign_cell_data.item_id)
	if nil == item_cfg then return end

	local str = EquipTip.GetEquipName(item_cfg, self.consign_cell_data, EquipTip.FROM_CONSIGN_ON_SELL)
	RichTextUtil.ParseRichText(self.node_t_list.rich_item_name.node, str, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))
	self.node_t_list.txt_item_type.node:setString(Language.EquipTypeName[item_cfg.type] or ItemData.GetConsignmentTypeName(item_cfg.type) or "")

	local lbl_level = self.node_t_list.txt_consume_level.node
	local level = 0
	local zhuan = 0
	for k,v in pairs(item_cfg.conds) do
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

function ConsignMyItemPage:OnFlushConsignMyItemBagGrid()
	if nil == self.consign_bag_grid then return end

	self.consign_bag_grid:SetDataList(ConsignData.Instance:GetBagCanSellItem())
	local data = ConsignData.Instance:GetBagCanSellItem()
	local n = 0
	for k,v in pairs(data) do
		n = n + 1
	end
	self.node_t_list.txt_percent.node:setString(n.."/"..75)
end

function ConsignMyItemPage:EmptyMyCell()
	self:SetMyItemCellData(nil)
	self.node_t_list.txt_item_type.node:setString("")
	self.node_t_list.txt_consume_level.node:setString("")
	self.node_t_list.rich_item_name.node:removeAllElements()
	self.edit_yuanbao:setText(ConsignMyItemPage.EditBoxInitNum)
end


-------------------------------------


-------------------------------------
-- ConsignItemRender
-------------------------------------
ConsignItemRender = ConsignItemRender or BaseClass(BaseRender)
function ConsignItemRender:__init()
end

function ConsignItemRender:__delete()	
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
end

function ConsignItemRender:CreateChild()
	BaseRender.CreateChild(self)
	local ph = self.ph_list.ph_item_cell
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x + ph.w / 2, ph.y + ph.h / 2)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)

		self.cell:SetName(GRID_TYPE_BAG)
	end

	self.node_tree.btn_remove.node:addClickEventListener(BindTool.Bind(self.OnClickRemoveHandler, self))
end

function ConsignItemRender:OnClickRemoveHandler()
	if nil == self.data then return end
	local operation = 0
	if self.data.remain_time <= TimeCtrl.Instance:GetServerTime() then operation = 1 end
	ConsignCtrl.Instance:SendCancelConsignItemReq(self.data.item_data.series, self.data.item_handle, operation)
end

function ConsignItemRender:OnFlush()
	if nil == self.data then return end
	self.cell:SetData(self.data.item_data)

	local item_cfg, big_type = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	if nil == item_cfg then
		GlobalTimerQuest:AddDelayTimer(function()
			self:OnFlush()
		end, 0)
		return
	end

	local str = EquipTip.GetEquipName(item_cfg, self.data.item_data, EquipTip.FROM_CONSIGN_ON_SELL)
	RichTextUtil.ParseRichText(self.node_tree.rich_txt_item_name.node, str, 20, Str2C3b(string.sub(string.format("%06x", item_cfg.color), 1, 6)))

	local lbl_level = self.node_tree.txt_item_level.node
	local level = 0
	local zhuan = 0
	for k,v in pairs(item_cfg.conds) do
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

	self.node_tree.txt_price.node:setString(self.data.item_price)

	self:SetTimerCountDown()
end

-- 设置倒计时
function ConsignItemRender:SetTimerCountDown()
	if nil == self.data then return end
	if self.data.remain_time <= TimeCtrl.Instance:GetServerTime() then
		self.node_tree.txt_remain_time.node:setString(Language.Consign.TimeOut)
		self.node_tree.txt_remain_time.node:setColor(COLOR3B.RED)
		return
	end
	local time_tab = TimeUtil.Format2TableDHM(self.data.remain_time - TimeCtrl.Instance:GetServerTime())
	self.node_tree.txt_remain_time.node:setString(string.format(Language.Consign.TimeTips, time_tab.day, time_tab.hour, time_tab.min))
	self.node_tree.txt_remain_time.node:setColor(cc.c3b(0xcc, 0xcc, 0xcc))
end

function ConsignItemRender:GetCountDownKey()
	if nil == self.data then return end
	local key = "consign_item_render_" .. self.data.item_handle
	return key
end