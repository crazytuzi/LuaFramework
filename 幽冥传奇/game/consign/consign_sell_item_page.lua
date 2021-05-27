ConsignSellItemPage = ConsignSellItemPage or BaseClass()

function ConsignSellItemPage:__init()
	self.view = nil
	self.list_lengh = 1
end

function ConsignSellItemPage:__delete()
	self:RemoveEvent()
	if self.consign_bag_grid then
		self.consign_bag_grid:DeleteMe()
		self.consign_bag_grid = nil
	end

	self.view = nil
end

--初始化页面
function ConsignSellItemPage:InitPage(view)
	--绑定要操作的元素
	self.view = view
	self.ph_list = self.view.ph_list
	self.node_t_list = self.view.node_t_list
	self.layout_stand_item = self.node_t_list.layout_stand_item.node
	self:InitEvent()
	
	
	self:CreateCell()
	self:CreateMineConsignList()

	self:OnFlushConsignMyItem()

	ConsignCtrl.Instance:SendGetMyConsignItemsReq()
end

function ConsignSellItemPage:InitEvent()
	self.my_consign_info_event = GlobalEventSystem:Bind(ConsignEventType.GET_MY_CONSIGN_INFO, BindTool.Bind(self.OnFlushConsignMyItem, self))
	self.node_t_list.btn_sell_tips.node:addClickEventListener(BindTool.Bind1(self.OnClickSellTipsHandler, self))
end

--移除事件
function ConsignSellItemPage:RemoveEvent()
	if self.my_consign_info_event then
		GlobalEventSystem:UnBind(self.my_consign_info_event)
		self.my_consign_info_event = nil
	end


	if self.consign_type_list then
		self.consign_type_list:DeleteMe()
		self.consign_type_list = nil
	end
end

--更新视图界面
function ConsignSellItemPage:UpdateData(data)
	
end

-- 说明
function ConsignSellItemPage:OnClickSellTipsHandler()
	DescTip.Instance:SetContent(Language.Consign.SellDetail, Language.Consign.SellTitle)
end


function ConsignSellItemPage:OnFlushConsignMyItem()
	-- 刷新右侧背包网格
	self:OnFlushConsignMyItemBagGrid()

	local data = ConsignData.Instance:GetMyConsignItemsData()
	self.consign_type_list:SetDataList(data.item_list)
	self.list_lengh = #data.item_list

	local yuanbao = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_GOLD)				--元宝
	self.node_t_list.lbl_gold_count.node:setString(yuanbao)

end


-------------------------------------
-- 出售界面
function ConsignSellItemPage:SetMyItemCellData(data)
	self:OnFlushConsignMyItemBagGrid()
end

function ConsignSellItemPage:CreateCell()
	self.consign_bag_grid = BaseGrid.New()
	self.consign_bag_grid:SetGridName(GRID_TYPE_BAG)
	local ph_grid = self.ph_list.ph_grid
	local grid_node = self.consign_bag_grid:CreateCells({w = ph_grid.w, h = ph_grid.h, cell_count = 75, col = 5, row = 5})
	grid_node:setPosition(ph_grid.x, ph_grid.y)
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_stand_item.node:addChild(grid_node, 999)
	self.bag_index = self.consign_bag_grid:GetCurPageIndex()
	self.consign_bag_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.consign_bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	self.consign_bag_grid:SetIsShowTips(false)

end

function ConsignSellItemPage:OnPageChangeCallBack(grid, page_index, prve_page_index)
end

function ConsignSellItemPage:SelectCellCallBack(cell)
	if cell == nil then
		return
	end

	local cell_data = cell:GetData()
	TipsCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_BAG_ON_BAG_SALE, {data = 1})				--打开tip

	
end

function ConsignSellItemPage:CreateMineConsignList()
	local ph = self.ph_list.ph_stall_list
	self.consign_type_list = GridScroll.New()
	local grid_node = self.consign_type_list:Create(ph.x, ph.y, ph.w,ph.h, 2, self.ph_list.ph_stall_item.h + 5, ConsignRender, ScrollDir.Vertical, false, self.ph_list.ph_stall_item)
	self.node_t_list.layout_stand_item.node:addChild(grid_node, 999)
	grid_node:setAnchorPoint(0, 0)
	grid_node:setPosition(ph.x, ph.y)
	self.consign_type_list:SetSelectCallBack(BindTool.Bind(self.SelectCosignCallback, self))	
	self.consign_type_list:JumpToTop()
end

function ConsignSellItemPage:SelectCosignCallback(item)
	
end


function ConsignSellItemPage:BagRadioHandler(index)
	if nil ~= self.consign_bag_grid then
		self.consign_bag_grid:ChangeToPage(index)
	end
end


function ConsignSellItemPage:OnFlushConsignMyItemBagGrid()
	if nil == self.consign_bag_grid then return end

	self.consign_bag_grid:SetDataList(ConsignData.Instance:GetBagCanSellItem())
	local data = ConsignData.Instance:GetBagCanSellItem()
	local n = 0
	for k,v in pairs(data) do
		n = n + 1
	end
	self.node_t_list.txt_percent.node:setString(n.."/"..75)
end

function ConsignSellItemPage:EmptyMyCell()
	self:SetMyItemCellData(nil)
	self.node_t_list.txt_item_type.node:setString("")
	self.node_t_list.txt_consume_level.node:setString("")
	self.node_t_list.rich_item_name.node:removeAllElements()
end


-------------------------------------
ConsignRender = ConsignRender or BaseClass(BaseRender)
function ConsignRender:__init()
	
end

function ConsignRender:__delete()
	if nil ~= self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end	
end

function ConsignRender:CreateChild()
 	BaseRender.CreateChild(self)

 	local ph = self.ph_list.ph_item_path
	if nil == self.cell then
		self.cell = BaseCell.New()
		self.cell:SetPosition(ph.x + ph.w / 2, ph.y + ph.h / 2)
		self.cell:SetIndex(i)
		self.cell:SetAnchorPoint(0.5, 0.5)
		self.view:addChild(self.cell:GetView(), 103)
	end	

	XUI.AddClickEventListener(self.node_tree.img9_bg.node, BindTool.Bind1(self.OnRemoveStall, self))
end

function ConsignRender:OnFlush()
	local cfg = ItemData.Instance:GetItemConfig(self.data.item_data.item_id)
	self.cell:SetData(self.data.item_data)
	self.node_tree.txt_item_name.node:setString(cfg.name)
	self.node_tree.txt_sell_price.node:setString(self.data.item_price)
	if not self.remain_time then
		self.remain_time = XUI.CreateRichText(250, 58 ,20, 68,false)
		self.view:addChild(self.remain_time,999)
	end
	self.remain_time:setVisible(self.data and self.data.remain_time and self.data.remain_time <=TimeCtrl.Instance:GetServerTime() or false)
	RichTextUtil.ParseRichText(self.remain_time, Language.Consign.ConsignOutTip, 20, cc.c3b(0xff, 0x28, 0x28))
end

function ConsignRender:OnRemoveStall()
	if nil == self.data then return end
	TipsCtrl.Instance:OpenItem(self.data.item_data, EquipTip.FROM_BAG_ON_BAG_SALE, {data = self.data})
end

-- 创建选中特效
function ConsignRender:CreateSelectEffect()
	if nil == self.node_tree.img9_bg then
		self.cache_select = true
		return
	end
	local size = self.node_tree.img9_bg.node:getContentSize()
	self.select_effect = XUI.CreateImageViewScale9(size.width / 2, size.height / 2, size.width + 15, size.height + 18, ResPath.GetCommon("img9_173"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.node_tree.img9_bg.node:addChild(self.select_effect, 999)
end