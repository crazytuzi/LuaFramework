ExploreBagView = ExploreBagView or BaseClass(XuiBaseView)

function ExploreBagView:__init()
	self.texture_path_list[1] = 'res/xui/explore.png'
	self.config_tab = {
		{"explore_ui_cfg", 2, {0}},
	}
	self.def_index = 1
	self.toggle_list = {}
	self.explore_btn_index = 1
end

function ExploreBagView:__delete()	
end

function ExploreBagView:ReleaseCallBack()
	if self.bag_cell_grid_list then
		self.bag_cell_grid_list:DeleteMe()
		self.bag_cell_grid_list = nil
	end

	if self.explore_bag_radio then
		self.explore_bag_radio:DeleteMe()
		self.explore_bag_radio = nil
	end	

	if self.tabbar ~= nil then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function ExploreBagView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self:InitTabbar()
		self:CreateLockToggleButton()
		self.node_t_list.btn_cleanup.node:setVisible(false)
		-- self.node_t_list.btn_recover.node:setVisible(false)
		self.node_t_list.btn_cleanup.node:addClickEventListener(BindTool.Bind1(self.OnClickCleanUpHandler, self))
		self.node_t_list.btn_extract.node:addClickEventListener(BindTool.Bind1(self.OnClickExtractHandler, self))
		self.node_t_list.btn_recover.node:addClickEventListener(BindTool.Bind1(self.OnClickRecoverHandler, self))
		self:CreateItemCell()
	end
end

function ExploreBagView:InitTabbar()
	if self.tabbar == nil then
		self.explore_bag = self.node_t_list.layout_bag
		self.tabbar = Tabbar.New()
		self.tabbar:CreateWithNameList(self.explore_bag.node, 20, 555,
		BindTool.Bind1(self.SelectEquipCallback, self), Language.Explore.TabGroup, false, ResPath.GetCommon("toggle_105"), nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar:ChangeToIndex(self:GetShowIndex())
		self.tabbar:SetSpaceInterval(5)

	end
end

function ExploreBagView:SelectEquipCallback(index)
	self.explore_btn_index = index 
	self:ChongZhiBtn()
	self:UpdateGridContent()
end

function ExploreBagView:CreateLockToggleButton()
	self.toggle_list = {}
	for i = 1, 3 do
		local ph = self.ph_list["ph_box_"..i]
		local toggle = XUI.CreateToggleButton(ph.x+20, ph.y+30, 60, 60, false, ResPath.GetCommon("check_bg"), ResPath.GetCommon("bg_checkbox_hook"), "", true)
		self.node_t_list.layout_bag.node:addChild(toggle, 999)
		XUI.AddClickEventListener(toggle, BindTool.Bind1(self.LockOpen, self), true)
		self.toggle_list[i] = toggle
	end
end

function ExploreBagView:LockOpen()
	self:UpdateGridContent()
end

function ExploreBagView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if ExploreData.Instance:GetChangeData() == true then
		ExploreCtrl.Instance:SendReturnWarehouseDataReq()
	end
	self.explore_btn_index = 1
	if self.tabbar ~= nil then
		self.tabbar:SelectIndex(1)
	end
end

function ExploreBagView:ShowIndexCallBack(index)
	self:Flush(index)
end

function ExploreBagView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function ExploreBagView:OnFlush(param_t, index)
	self:ChongZhiBtn()
	self:FlushItem(self.explore_btn_index)
	local length = ExploreData.Instance:GetWearHouseLength()
	self.node_t_list.txt_rongliang.node:setString(length.."/".. 400)
end

function ExploreBagView:FlushItem(index)
	self:UpdateGridContent()
end

-- 整理
function ExploreBagView:OnClickCleanUpHandler()
	self:UpdateGridContent()
end

function ExploreBagView:ChongZhiBtn()
	for i = 1, 3 do
		self.toggle_list[i]:setTogglePressed(false)
		-- self.toggle_list[i]:setVisible(true)
		-- self.node_t_list["txt_name_"..i].node:setVisible(true)
	end
	if self.explore_btn_index == 1 or self.explore_btn_index == 5 then
		for i = 1, 3 do
			self.toggle_list[i]:setVisible(false)
			-- self.node_t_list["txt_name_"..i].node:setVisible(false)
		end
	end
end

function ExploreBagView:UpdateGridContent()
	local bool_select_1 = self.toggle_list[1]:isTogglePressed() or false
	local bool_select_2 = self.toggle_list[2]:isTogglePressed() or false
	local bool_select_3 = self.toggle_list[3]:isTogglePressed() or false
	local data = ExploreData.Instance:GetItemData(self.explore_btn_index, bool_select_1, bool_select_2, bool_select_3)
	self.bag_cell_grid_list:SetDataList(data)
end	

function ExploreBagView:OnClickExtractHandler()
	local bool_select_1 = self.toggle_list[1]:isTogglePressed() or false
	local bool_select_2 = self.toggle_list[2]:isTogglePressed() or false
	local bool_select_3 = self.toggle_list[3]:isTogglePressed() or false
	local data = ExploreData.Instance:GetItemData(self.explore_btn_index, bool_select_1, bool_select_2, bool_select_3)
	local num = ItemData.Instance:GetEmptyNum()
	for k, v in pairs(data) do
		if k <= num then
			ExploreCtrl.Instance:SendMovetoBagReq(v.series)
		end
	end
	--ExploreCtrl.Instance:SendMovetoBagReq(0)
end

function ExploreBagView:OnClickRecoverHandler()
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) <= 0 then
		return SystemHint.Instance:FloatingTopRightText(Language.Bag.NotSuperMe)
	end
	ViewManager.Instance:Open(ViewName.ExploreBagRecycle)
	-- ViewManager.Instance:FlushView(ViewName.Recycle, 0, "exploreBag")
end

-- function ExploreBagView:CreateCheckBox()

-- 	self.checkBox1 = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
-- 	self.checkBox1:setVisible(false)
-- 	self.node_t_list.checkBox1.node:addChild(self.checkBox1,10)
-- 	XUI.AddClickEventListener(self.node_t_list.checkBox1.node, BindTool.Bind(self.OnClickSelectBox1Handler, self))

-- 	self.checkBox2 = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
-- 	self.checkBox2:setVisible(false)
-- 	self.node_t_list.checkBox2.node:addChild(self.checkBox2,10)
-- 	XUI.AddClickEventListener(self.node_t_list.checkBox2.node, BindTool.Bind(self.OnClickSelectBox2Handler, self))

-- end	

-- function ExploreBagView:OnClickSelectBox1Handler()
-- 	if self.checkBox1:isVisible() then
-- 		self.checkBox1:setVisible(false)
-- 		self.explore_btn_index = 1
-- 	else	
-- 		if self.checkBox2:isVisible() then
-- 			self.checkBox2:setVisible(false)
-- 		end	
-- 		self.checkBox1:setVisible(true)
-- 		self.explore_btn_index = 2
-- 	end	
-- 	self:UpdateGridContent()
-- end	

-- function ExploreBagView:OnClickSelectBox2Handler()
-- 	if self.checkBox2:isVisible() then
-- 		self.checkBox2:setVisible(false)
-- 		self.explore_btn_index = 1
-- 	else	
-- 		if self.checkBox1:isVisible() then
-- 			self.checkBox1:setVisible(false)
-- 		end	
-- 		self.checkBox2:setVisible(true)
-- 		self.explore_btn_index = 3
-- 	end	
-- 	self:UpdateGridContent()
-- end	

function ExploreBagView:CreateItemCell()
	self.bag_cell_grid_list = BaseGrid.New() 
	self.bag_cell_grid_list:SetGridName(GRID_TYPE_BAG)
	local ph_grid = self.ph_list.ph_bag_cell_list
	local grid_node = self.bag_cell_grid_list:CreateCells({w = ph_grid.w, h = ph_grid.h, cell_count = 400, col = 7, row = 5, itemRender = CellRender})
	grid_node:setPosition(ph_grid.x, ph_grid.y)
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_bag.node:addChild(grid_node, 999)
	self.bag_index = self.bag_cell_grid_list:GetCurPageIndex()
	self.bag_cell_grid_list:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.bag_cell_grid_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	self.explore_bag_radio = RadioButton.New()
	local radiobutton_list = {}
	for i = 1, 12 do
		radiobutton_list[i] = self.node_t_list.layout_bag_grid_page["toggle_radio"..i].node
	end
	self.explore_bag_radio:SetToggleList(radiobutton_list)
	self.explore_bag_radio:SetSelectCallback(BindTool.Bind1(self.BagRadioHandler, self))
	self.bag_cell_grid_list:SetRadioBtn(self.explore_bag_radio)
end

function ExploreBagView:OnPageChangeCallBack(grid, page_index, prve_page_index)
end

function ExploreBagView:SelectCellCallBack(cell)
	if nil == cell or nil == cell:GetData() then return end
	TipsCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_XUNBAO_BAG)
end

function ExploreBagView:BagRadioHandler(index)
	if nil ~= self.bag_cell_grid_list then
		self.bag_cell_grid_list:ChangeToPage(index)
	end
end

CellRender = CellRender or BaseClass(BaseCell)
function CellRender:__init()
	self:SetCellBg(ResPath.GetCommon("cell_100"))	
end

function CellRender:__delete()	
end

function CellRender:CreateChild()
end










