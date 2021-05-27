-- 宝藏仓库
local ExploreStorageView = BaseClass(SubView)

function ExploreStorageView:__init()
	self.texture_path_list = {'res/xui/explore.png', 'res/xui/bag.png'}
	self.config_tab = {
		{"explore_ui_cfg", 3, {0}},	
	}

	self.bag_cell_grid_list = nil
	-- self.explore_bag_radio = nil
	self.bag_cell_grid_list = nil
end

--删除宝藏仓库视图
function ExploreStorageView:ReleaseCallBack()
	if self.bag_cell_grid_list then
		self.bag_cell_grid_list:DeleteMe()
		self.bag_cell_grid_list = nil
	end

	-- if self.explore_bag_radio then
	-- 	self.explore_bag_radio:DeleteMe()
	-- 	self.explore_bag_radio = nil
	-- end
end

function ExploreStorageView:LoadCallBack(index, loaded_times)
	--仓库网格
	self.bag_cell_grid_list = BaseGrid.New() 
	self.bag_cell_grid_list:SetGridName(GRID_TYPE_BAG)
	local ph_grid = self.ph_list.ph_bag_cell_list
	local grid_node = self.bag_cell_grid_list:CreateCells({w = ph_grid.w, h = ph_grid.h, cell_count = 44 * 15, col = 10, row = 5})
	grid_node:setPosition(ph_grid.x, ph_grid.y)
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_xb_storage.node:addChild(grid_node, 20)
	self.bag_index = self.bag_cell_grid_list:GetCurPageIndex()

	--页面更改回调
	self.bag_cell_grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	--选择单元格回调
	self.bag_cell_grid_list:SetSelectCallBack(BindTool.Bind(self.SelectCellCallBack, self))

	self.node_t_list.layout_bag_grid_page.node:setVisible(false)
	--单选按钮
	-- self.explore_bag_radio = RadioButton.New()
	-- local radiobutton_list = {}
	-- for i = 1, 15 do
	-- 	radiobutton_list[i] = self.node_t_list.layout_bag_grid_page["toggle_radio"..i].node
	-- end
	-- self.explore_bag_radio:SetToggleList(radiobutton_list)
	-- self.explore_bag_radio:SetSelectCallback(BindTool.Bind(self.BagRadioHandler, self))
	-- self.bag_cell_grid_list:SetRadioBtn(self.explore_bag_radio)

	-- self.melting = XUI.CreateImageView(860, 55, ResPath.GetBag("btn_melting"))
	-- self.node_t_list.layout_xb_storage.node:addChild(self.melting, 99)
	-- local size = self.melting:getContentSize()
	-- RenderUnit.CreateEffect(270, self.melting, 1, nil, nil, size.width / 2 - 2, size.height / 2 + 10)
	-- XUI.AddClickEventListener(self.melting, function() ViewManager.Instance:OpenViewByDef(ViewDef.Recycle) end, true)
	-- self:FlushMeltingEff()

	--宝藏仓库按钮监听
	XUI.AddClickEventListener(self.node_t_list.btn_clearup.node, BindTool.Bind(self.OnClickCleanUpHandler, self), true)	--整理
	XUI.AddClickEventListener(self.node_t_list.btn_out.node, BindTool.Bind(self.OnClickExtractHandler, self), true)	--提取
	XUI.AddClickEventListener(self.node_t_list.btn_recycle.node, BindTool.Bind(self.OnClickRecycle, self), true)	--回收
	-- XUI.AddClickEventListener(self.node_t_list.btn_black.node, BindTool.Bind(self.OnClickBlack, self), true)	--返回

	EventProxy.New(ExploreData.Instance, self):AddEventListener(ExploreData.WEAR_HOUSE_DATA_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.ItemDataListChangeCallback, self))
end

--显示指数回调
function ExploreStorageView:ShowIndexCallBack(index)
	-- self:ShowXBStorageView()
	self:FlushXBStorageView()
end

function ExploreStorageView:OnFlush(param_list)
	if param_list.wear_house_data_change then
		self:FlushXBStorageView()
	end
end

function ExploreStorageView:OnBagItemChange()
	self:Flush(0, "wear_house_data_change")
end

--请求宝藏仓库数据
-- function ExploreStorageView:ShowXBStorageView()
-- 	if ExploreData.Instance:GetChangeData() then
-- 		-- ExploreCtrl.Instance:SendReturnWarehouseDataReq()
-- 	end
-- end

--刷新宝藏仓库
function ExploreStorageView:FlushXBStorageView()
	if nil == self.bag_cell_grid_list then return end
	local bag_data = ExploreData.Instance:GetWearHouseAllData()
 	self.bag_cell_grid_list:SetDataList(bag_data)
end

--单击整理
function ExploreStorageView:OnClickCleanUpHandler()
	self:FlushXBStorageView()
end

-- 点击回收
function ExploreStorageView:OnClickRecycle()
	BagData.Instance:RecycleStorageChree(2)
	ViewManager.Instance:OpenViewByDef(ViewDef.Recycle)
	ViewManager.Instance:CloseViewByDef(ViewDef.Explore)
end

function ExploreStorageView:OnClickBlack()
	ViewManager.Instance:OpenViewByDef(ViewDef.Explore.Xunbao)
end

--页面更改回调 已屏蔽
function ExploreStorageView:OnPageChangeCallBack(grid, page_index, prve_page_index)
end

--选择单元格回调
function ExploreStorageView:SelectCellCallBack(cell)
	if nil == cell or nil == cell:GetData() then return end
	TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_XUNBAO_BAG)
end

--单击提取
function ExploreStorageView:OnClickExtractHandler()
	ExploreCtrl.Instance:SendMovetoBagReq(0)
end

--宝藏仓库物品数据
-- function ExploreStorageView:BagRadioHandler(index)
-- 	if self.bag_cell_grid_list then
-- 		self.bag_cell_grid_list:ChangeToPage(index)
-- 	end
-- end

function ExploreStorageView:ItemDataListChangeCallback(event)
	-- event.CheckAllItemDataByFunc(function (vo)
	-- 	if ItemData.GetIsEquip(vo.item_id) then
	-- 		self:FlushMeltingEff()
	-- 	end
	-- end)
end

-- function ExploreStorageView:FlushMeltingEff()
-- 	if self.melting then
-- 		self.melting:getChildByTag(1):setVisible(BagData.Instance:GetCanRecycleReimdNum() > 0)
-- 	end
-- end

return ExploreStorageView