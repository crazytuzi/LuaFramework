CollectionView = CollectionView or BaseClass(SubView)

function CollectionView:__init()
	self.is_model = true
	self.texture_path_list = {
		'res/xui/bag.png',
	}
	self.config_tab = {
		{"horoscope_ui_cfg", 1, {0}},
		{"horoscope_ui_cfg", 2, {0}},
		{"horoscope_ui_cfg", 5, {0}},
		{"horoscope_ui_cfg", 7, {0}},

	}
	self.need_del_objs = {}
	self.fight_power_view = nil
	self.collection_bag_grid = nil
	self.purple_grid = nil
	self.orange_grid = nil
	self.red_grid = nil
	--self:GetConstellationDataList(function(data)
	--    HoroscopeData.Instance:GetConstellationData(data.equip_slot)
	--end)
	-- self.select_index = 0
end


function CollectionView:LoadCallBack()
	self.fight_power_view = FightPowerView.New(136, 35, self.node_t_list.layout_fighting_power.node, 99)
	self.need_del_objs[#self.need_del_objs + 1] = self.fight_power_view
	self:CreateSelectGridView()
	self:CreateCollectionView()
	self:CreateBagView()

	XUI.AddClickEventListener(self.node_t_list.btn_back.node, BindTool.Bind(self.OnBtnBack, self))
	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind(self.OnBtnLeft, self))
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind(self.OnBtnRight, self))
	XUI.AddClickEventListener(self.node_t_list.btn_xhsc_ques.node, BindTool.Bind2(self.OpenTip, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.BagItemChangeCallBack, self))
	--EventProxy.New(HoroscopeData.Instance, self):AddEventListener(HoroscopeData.SLOT_STRENGTHEN_DATA_CHANGE, BindTool.Bind(self.SlotStrengthenDataChange, self))
end

function CollectionView:OpenTip()
	DescTip.Instance:SetContent(Language.DescTip.ShouhuContent, Language.DescTip.ShouhuTitle)
end

function CollectionView:CreateCollectionView()
	self.purple_grid = self:CreateGrid(self.ph_list.ph_start_0)
	--self.purple_grid:SetSelectCallBack(BindTool.Bind(self.OnClickCollectionGrid, self, 0))
	self.purple_grid:GetView():addScrollEventListener(BindTool.Bind1(self.OnScrollChange, self))
	self.purple_grid:GetView().page = 0
	self.purple_grid:JumpToPage(1)
	self.need_del_objs[#self.need_del_objs + 1] = self.purple_grid


	self.orange_grid = self:CreateGrid(self.ph_list.ph_start_1)
	--self.orange_grid:SetSelectCallBack(BindTool.Bind(self.OnClickCollectionGrid, self, 1))
	self.orange_grid:GetView():addScrollEventListener(BindTool.Bind1(self.OnScrollChange, self))
	self.orange_grid:GetView().page = 1
	self.orange_grid:JumpToPage(2)
	self.need_del_objs[#self.need_del_objs + 1] = self.orange_grid

	self.red_grid = self:CreateGrid(self.ph_list.ph_start_2)
	--self.red_grid:SetSelectCallBack(BindTool.Bind(self.OnClickCollectionGrid, self, 2))
	self.red_grid:GetView():addScrollEventListener(BindTool.Bind1(self.OnScrollChange, self))
	self.red_grid:GetView().page = 2
	self.red_grid:JumpToPage(3)
	self.need_del_objs[#self.need_del_objs + 1] = self.red_grid
end
--屏蔽滚动
function CollectionView:OnScrollChange(sender, event, x, y)
	sender:jumpToPage(sender.page)
end

function CollectionView:CreateSelectGridView()
	local ph = self.ph_list.ph_list
	self.slot_grid = BaseGrid.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.slot_grid
	local grid_node = self.slot_grid:CreateCells({ w=ph.w, h=ph.h, cell_count=12, col=4, row=1, itemRender = CollectTionRender,
												   direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_item_render1})
	grid_node:setPosition(ph.x, ph.y)
	self.slot_grid:SetSelectCallBack(BindTool.Bind(self.OnClickSelectGrid, self))
	-- self.slot_grid:SetIsShowTips(false)
	self.slot_grid:SelectCellByIndex(0)
	self.node_t_list.layout_list.node:addChild(grid_node, 100)
	self.slot_grid:SetDataList(HoroscopeData.Instance:GetAllConstellationData())
end

-- 创建网格
function CollectionView:CreateGrid(ph)
	local grid_scroll_list = BaseGrid.New()
	grid_scroll_list:SetSelectCallBack(BindTool.Bind(self.OnClickCollectionGrid, self))
	local grid_node = grid_scroll_list:CreateCells({ w=ph.w, h=ph.h, cell_count=15, col=5, row=1, itemRender = BaseCell,
							  direction = ScrollDir.Horizontal,})
	grid_node:setPosition(ph.x, ph.y)
	self.node_t_list.layout_collection.node:addChild(grid_node, 100)
	return grid_scroll_list
end

-- 创建背包
function CollectionView:CreateBagView()
	local ph = self.ph_list.ph_bag
	self.collection_bag_grid = BaseGrid.New()
	self.need_del_objs[#self.need_del_objs + 1] = self.collection_bag_grid
	local grid_node = self.collection_bag_grid:CreateCells({ w=ph.w, h=ph.h, cell_count=110, col=4, row=3, itemRender = BaseCell,
															 direction = ScrollDir.Horizontal, ui_config = self.ph_list.ph_item})
	--self.collection_bag_grid:JumpToTop()
	self.collection_bag_grid:SetSelectCallBack(BindTool.Bind(self.OnClickBagGridHandle, self))
	self.node_t_list.layout_bag.node:addChild(grid_node, 100)

end

function CollectionView:ReleaseCallBack()
	for k, v in pairs(self.need_del_objs) do
		v:DeleteMe()
	end
	self.need_del_objs = {}
end

function CollectionView:ShowIndexCallBack()
	self:Flush()
end


function CollectionView:OnFlush()
	self:FlushPowerValueView()
	self:FlushCollectionGrid()
	local senior_constellation_list = HoroscopeData.GetSeniorConstellationList(self.select_index)
	if self.collection_bag_grid then
		self.collection_bag_grid:SetDataList(senior_constellation_list)
	end
	self.node_t_list.img_star_soul_name.node:loadTexture(ResPath.Horoscope("collection_word_"..self.select_index))
end

function CollectionView:FlushCollectionGrid()
	local collection_list = HoroscopeData.Instance:GetCollectionDataListBySlot(self.select_index)
	self.purple_grid:SetDataList(collection_list)
	self.orange_grid:SetDataList(collection_list)
	self.red_grid:SetDataList(collection_list)
	self.slot_grid:SetDataList(HoroscopeData.Instance:GetAllConstellationData())
end  ---CommonDataManager.AddAttr(attr, attr1) 



--背包数据改变时刷新
function CollectionView:BagItemChangeCallBack()
	self:OnFlush()
end

-- 刷新战力值视图
function CollectionView:FlushPowerValueView()
	local attr = {}
	for i = 0, 11 do
		local senior_constellation_list = HoroscopeData.Instance:GetCollectionDataListBySlot(i)
		for k, v in pairs(senior_constellation_list) do
			local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
			attr = CommonDataManager.AddAttr(attr, item_cfg.staitcAttrs) 
		end
	end
	local power_value = CommonDataManager.GetAttrSetScore(attr)
	self.fight_power_view:SetNumber(power_value)
end


function CollectionView:OnClickSelectGrid(cell)
	if nil == cell then
		return
	end
	self.select_index = cell.index
	self:Flush()
end

function CollectionView:OnClickCollectionGrid(cell)
	if nil == cell:GetData() then
		return
	end
	--local grid_idx = grid_start * 5 + cell:GetIndex() - 1
	TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_COLLECTION, {grid_idx = cell:GetIndex()})
end

function CollectionView:OnClickBagGridHandle(cell)
	if nil == cell:GetData() then
		return
	end
	local grid_idx = HoroscopeData.Instance:GetCollectionGrid(self.select_index, cell:GetData().item_id)

	TipCtrl.Instance:OpenItem(cell:GetData(), 41, {type = self.select_index, grid_idx = grid_idx})
end

function CollectionView:OnBtnLeft()
	local idx = self.slot_grid:GetCurPageIndex()
   
	idx = idx - 1
	if idx > 0 then
		self.slot_grid:ChangeToPage(idx)
	end
end

function CollectionView:OnBtnRight()
	local idx = self.slot_grid:GetCurPageIndex()
	 local count = self.slot_grid:GetPageCount()
	idx = idx + 1
	if idx <= count then
		self.slot_grid:ChangeToPage(idx)
	end
end

function CollectionView:OnBtnBack()
	ViewManager.Instance:OpenViewByDef(ViewDef.Horoscope.HoroscopeView)
end

CollectTionRender = CollectTionRender or BaseClass(BaseRender)

function CollectTionRender:__init()
end

function CollectTionRender:__delete()
end

function CollectTionRender:CreateChild()
	BaseRender.CreateChild(self)
	self:AddClickEventListener(self.click_callback)
end

function CollectTionRender:OnFlush()
	self:Clear()
	if self.data == nil then
		return
	end
	self.node_tree.img_bg11.node:setVisible(false)
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local icon = ResPath.GetItem(item_cfg.icon)
	self.node_tree.img_icon1.node:setVisible(true)
	self.node_tree.img_icon1.node:loadTexture(icon)
end

function CollectTionRender:Clear()
	 self.node_tree.text_strength_level1.node:setString("")
	self.node_tree.img_icon1.node:setVisible(false)
	self.node_tree.img_bg11.node:setVisible(true)
	self.node_tree.img_bg11.node:loadTexture(ResPath.Horoscope("constellatory_bg_" .. self.index + 1))

	local showVis = HoroscopeData.Instance:GetCanShowListByType(self.index)
	self.node_tree.img_red1.node:setVisible(showVis)
end

function CollectTionRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(size.width / 2 - 1, size.height / 2 - 1,  ResPath.GetRole("img_select1"), true)
	if nil == self.select_effect then
		ErrorLog("BaseRender:CreateSelectEffect fail")
		return
	end

	self.view:addChild(self.select_effect, 999)
end



return CollectionView
