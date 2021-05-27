EquipmentXuanBinPage = EquipmentXuanBinPage or BaseClass()


function EquipmentXuanBinPage:__init()
	
end	

function EquipmentXuanBinPage:__delete()
	if self.tabbar_equip then
		self.tabbar_equip:DeleteMe()
		self.tabbar_equip = nil
	end
	if self.tabbar_fenjie then
		self.tabbar_fenjie:DeleteMe()
		self.tabbar_fenjie = nil 
	end
	if self.xuanbin_soures_cell then
		self.xuanbin_soures_cell:DeleteMe()
		self.xuanbin_soures_cell = nil
	end
	if self.xuanbin_priview_cell then
		self.xuanbin_priview_cell:DeleteMe()
		self.xuanbin_priview_cell = nil 
	end
	if self.xuanbin_target_cell then
		self.xuanbin_target_cell:DeleteMe()
		self.xuanbin_target_cell = nil 
	end
	if self.xuanbin_equip_list then
		self.xuanbin_equip_list:DeleteMe()
		self.xuanbin_equip_list = nil 
	end
	if self.consumes_cell then
		self.consumes_cell:DeleteMe()
		self.consumes_cell = nil
	end
	if self.xuanbin_grid_list then
		self.xuanbin_grid_list:DeleteMe()
		self.xuanbin_grid_list = nil 
	end
	if self.scroll_tabbar then
		self.scroll_tabbar:DeleteMe()
		self.scroll_tabbar = nil 
	end
	self:RemoveEvent()
	self.view = nil
end	

--初始化页面接口
function EquipmentXuanBinPage:InitPage(view)
	--绑定要操作的元素
	-- 玄兵升阶
	self.view = view	
	self:CreateTabbar()
	self:CreateFenJieTabbar()
	self:CreateCells()
	
	self.cur_index = 1
	self.cur_type = 1
	self.select_equip_index = 0

 	-- 玄兵分解
 	self.check_box_state_list = {
									["prof_1"] = false,
									["prof_2"] = false,
									["prof_3"] = false,
								}
	self:CreateXuanBinBox()
	for i = 1, 3 do
		self:SetCheckBoxStatus("prof_" .. i, self.check_box_state_list["prof_" .. i])
	end
	self:CreateXuanBinGridCells()
 	self:CreateXuanBinEquipList()
 	self.page_index = 1
 	EquipmentData.Instance:InitXuanBinEquip()
 	self:CreateXuanBinScorllTabbar()
	self:InitEvent()
	
end	

--初始化事件
function EquipmentXuanBinPage:InitEvent()
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback,self)			--监听人物属性数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:setLocalZOrder(998)
	self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:addClickEventListener(BindTool.Bind(self.ClearXuBinCell, self))
	self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_upLevel.node:addClickEventListener(BindTool.Bind(self.UpXuanBinLevel, self))
	self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_desc_tip.node:addClickEventListener(BindTool.Bind(self.OpenXuanBinTip, self))

	--玄兵分解
	XUI.AddClickEventListener(self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.btn_left_1.node, BindTool.Bind1(self.MoveXuanBinLeft, self))
	XUI.AddClickEventListener(self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.btn_right_1.node, BindTool.Bind1(self.MoveXuanBinRight, self))
	self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.btn_fenjie_tip_1.node:addClickEventListener(BindTool.Bind(self.OpenFenJieDescTip,self))
	XUI.AddClickEventListener(self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.layout_fenjie_xuanbin.btn_quick_recycle.node, BindTool.Bind1(self.FenjieXuanBinEquip, self), true)
end

function EquipmentXuanBinPage:ClearXuBinCell()
	if self.xuanbin_soures_cell:GetData() ~= nil then
		self.xuanbin_soures_cell:ClearData()
	end
	if self.xuanbin_target_cell:GetData() ~= nil then
		self.xuanbin_target_cell:ClearData()
	end
	if self.xuanbin_priview_cell:GetData() ~= nil then
		self.xuanbin_priview_cell:ClearData()
	end
	if self.consumes_cell:GetData() ~= nil then
		self.consumes_cell:ClearData()
	end
	self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
end

function EquipmentXuanBinPage:ItemDataChangeCallback(change_type, item_id, item_index, series)
	if self.cur_type == 1 then
		self.view:Flush(TabIndex.equipment_xuan_bin)
	elseif self.cur_type == 2 then
		self.view:Flush(TabIndex.equipment_xuan_bin, "xuan_bin_equip_change")
	end
end

function EquipmentXuanBinPage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_xuan_bin)
end

function EquipmentXuanBinPage:UpXuanBinLevel()
	local data = self.xuanbin_soures_cell:GetData()
	if data ~= nil then
		EquipmentCtrl.Instance:SendUpLevelEquip(data.series)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.Xuanbin_Input_desc)
	end
end

function EquipmentXuanBinPage:OpenXuanBinTip()
	DescTip.Instance:SetContent(Language.Equipment.XuanBinContent, Language.Equipment.XuanBinTitle)
end

function EquipmentXuanBinPage:CreateTabbar()
	if self.tabbar_equip == nil then
		self.tabbar_equip = Tabbar.New()
		self.tabbar_equip:CreateWithNameList(self.view.node_t_list.layout_xuan_bin.node, 5, 557,
			BindTool.Bind1(self.SelectXuanBinEquipCallback, self), 
			Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_equip:SetSpaceInterval(5)
	end
end

function EquipmentXuanBinPage:SelectXuanBinEquipCallback(index)
	self.cur_index = index
	self:FlushRightData()
end

function EquipmentXuanBinPage:CreateFenJieTabbar()
	if self.tabbar_fenjie == nil then
		self.tabbar_fenjie = Tabbar.New()
		self.tabbar_fenjie:CreateWithNameList(self.view.node_t_list.layout_xuan_bin.node, 760, 557,
			BindTool.Bind1(self.SelectEquipFenDeComposeCallback, self), 
			Language.Equipment.TabGroup_7, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_fenjie:SetSpaceInterval(5)
	end
end

function EquipmentXuanBinPage:SelectEquipFenDeComposeCallback(index)
	self.cur_type = index
	self:BoolShowLayout()
	self:FlushRightData()
end

function EquipmentXuanBinPage:BoolShowLayout()
	self.view.node_t_list.layout_xunbin_cast.node:setVisible(self.cur_type == 1)
	self.view.node_t_list.layout_xuan_bin_decompose.node:setVisible(self.cur_type == 2)
	self.tabbar_equip:SetToggleVisible(1, self.cur_type == 1)
	self.tabbar_equip:SetToggleVisible(2, self.cur_type == 1)
end

function EquipmentXuanBinPage:CreateCells()
	if self.xuanbin_priview_cell == nil then
		local ph = self.view.ph_list.ph_xuanbin_cell_1
		self.xuanbin_priview_cell = BaseCell.New()
		self.xuanbin_priview_cell:SetPosition(ph.x, ph.y)
		self.xuanbin_priview_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.node:addChild(self.xuanbin_priview_cell:GetView(), 100)
	end

	if self.xuanbin_soures_cell == nil then
		local ph = self.view.ph_list.ph_xuanbin_cell_2
		self.xuanbin_soures_cell = BaseCell.New()
		self.xuanbin_soures_cell:SetPosition(ph.x, ph.y)
		self.xuanbin_soures_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.node:addChild(self.xuanbin_soures_cell:GetView(), 100)
	end

	if self.xuanbin_target_cell == nil then
		local ph = self.view.ph_list.ph_xuanbin_cell_3
		self.xuanbin_target_cell = BaseCell.New()
		self.xuanbin_target_cell:SetPosition(ph.x, ph.y)
		self.xuanbin_target_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.node:addChild(self.xuanbin_target_cell:GetView(), 100)
	end

	if self.consumes_cell == nil then
		local ph = self.view.ph_list.ph_xuanbin_cell_4
		self.consumes_cell = BaseCell.New()
		self.consumes_cell:SetPosition(ph.x, ph.y)
		self.consumes_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.node:addChild(self.consumes_cell:GetView(), 100)
	end
end

-- 玄兵列表
function EquipmentXuanBinPage:CreateXuanBinEquipList()
	if self.xuanbin_equip_list == nil then
		local ph = self.view.ph_list.ph_god_list
		self.xuanbin_equip_list = ListView.New()
		self.xuanbin_equip_list:Create(ph.x, ph.y, ph.w, ph.h, nil, XuanBinEquipListItem, nil, nil, self.view.ph_list.ph_god_item)
		self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.node:addChild(self.xuanbin_equip_list:GetView(), 999)
		self.xuanbin_equip_list:SetMargin(5)
		self.xuanbin_equip_list:SetItemsInterval(5)
		self.xuanbin_equip_list:SelectIndex(1)
		self.xuanbin_equip_list:GetView():setAnchorPoint(0, 0)
		self.xuanbin_equip_list:SetJumpDirection(ListView.Top)
		self.xuanbin_equip_list:SetSelectCallBack(BindTool.Bind1(self.SelectXuanBinEquipListCallBack, self))
	end
end

function EquipmentXuanBinPage:SelectXuanBinEquipListCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_equip_data = item:GetData()
	self.select_equip_index = item:GetIndex()
	self:FlushRightData()
end

--移除事件
function EquipmentXuanBinPage:RemoveEvent()
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
end

--更新视图界面
function EquipmentXuanBinPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			if self.method_index == 1 then
				local data_1 = EquipmentData.Instance:GetCanShengJieXuanBinEquip()
				if data_1[1] == nil then 
					local data = EquipmentData.Instance:GetBagCanShengJieXuanBinEquip()
					if data[1] ~= nil then
						self.tabbar_equip:SelectIndex(2)
					else
						self.tabbar_equip:SelectIndex(1)
					end
				else
					self.tabbar_equip:SelectIndex(1)
				end
			end
			self:FlushRightData()
			local caozuo_type, caozuo_result = EquipmentData.Instance:GetCaoZuoTypeAndResult()
			if caozuo_type == 1 and caozuo_result == 1 then
				self:ClearXuBinCell()
			end
		elseif k == "xuan_bin_equip_change" then
			EquipmentData.Instance:InitXuanBinEquip()
			self.xuanbin_grid_list:SetDataList(EquipmentData.Instance:GetXuanBinList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
			self:FlushCurTabbar(self.scroll_tabbar:GetCurSelectIndex())
			self:FlushItem()
		end
	end
end	

function EquipmentXuanBinPage:FlushRightData()
	if self.cur_type == 1 then
		if self.cur_index == 1 then
			self.equip_data = EquipmentData.Instance:GetCanShengJieXuanBinEquip()
			self.xuanbin_equip_list:SetDataList(self.equip_data)
		elseif self.cur_index == 2 then
			self.equip_data = EquipmentData.Instance:GetBagCanShengJieXuanBinEquip()
			self.xuanbin_equip_list:SetDataList(self.equip_data)
		end
		self:FlushData(self.equip_data)
		self:YongYouItemNum()
		self:BoolShowLayout()
	elseif self.cur_type == 2 then
		self:UpdateFilterBagItem()
		self:BoolShowBtn()
		self:FlushTabbar()
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		self:SelectTabCallback(1)
		self:SetCheckBoxStatus("prof_1", prof ~= 1)
		self:SetCheckBoxStatus("prof_2", prof ~= 2)
		self:SetCheckBoxStatus("prof_3", prof ~= 3)
		self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.txt_suipian.node:setString(Language.Equipment.Name_XuanBin)
		self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.txt_shiled.node:setString(Language.Equipment.Name_Shiled)
	end
end

function EquipmentXuanBinPage:BoolShowBtn()
	self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.btn_left_1.node:setVisible(self.page_index ~= 1)
	self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.btn_right_1.node:setVisible(self.page_index ~= 7)
end

function EquipmentXuanBinPage:FlushData(data)
	self.select_data = data[self.select_equip_index]
	if self.select_equip_data ~= nil  and data[self.select_equip_index] ~= nil then
		if self.select_data ~= nil then
			self.xuanbin_soures_cell:SetData(self.select_data)
			local cfg = EquipmentData.GetConfigDataById(self.select_data.item_id) 
			if cfg ~= nil then
				local consume_data_1  = {item_id = cfg.consumes[1].id, num = 1, is_bind = 0}
				self.xuanbin_target_cell:SetData(consume_data_1)
				local had_consume_1 = ItemData.Instance:GetItemNumInBagById(cfg.consumes[1].id, bind_type)
				local color = COLOR3B.GREEN 
				local txt =  had_consume_1 .. "/" .. cfg.consumes[1].count
				if had_consume_1 >= cfg.consumes[1].count then
					color = COLOR3B.GREEN 
				else
					color = COLOR3B.RED 
				end
				self.xuanbin_target_cell:SetCenterBottomText(txt, color)
				local consume_data_2 = {item_id = (cfg.consumes[2] and cfg.consumes[2].id), num = (cfg.consumes[2] and cfg.consumes[2].count), is_bind = 0}
				self.consumes_cell:SetData(consume_data_2)
				local had_consume_2 = ItemData.Instance:GetItemNumInBagById(cfg.consumes[2].id, bind_type)
				local color_1 = COLOR3B.GREEN 
				local txt_1 =  had_consume_2 .. "/" .. cfg.consumes[2].count
				if had_consume_2 >= cfg.consumes[2].count then
					color_1 = COLOR3B.GREEN 
				else
					color_1 = COLOR3B.RED 
				end
				self.consumes_cell:SetRightBottomText(txt_1, color_1)
				local strengthen_my_level = (self.select_data.strengthen_level - (cfg.upgrade and cfg.upgrade.decStar or 0)) >= 0 and self.select_data.strengthen_level - (cfg.upgrade and cfg.upgrade.decStar or 0) or 0
				local infuse_my_level = (self.select_data.infuse_level - (cfg.upgrade and cfg.upgrade.decInject or 0)) >= 0 and self.select_data.infuse_level - (cfg.upgrade and cfg.upgrade.decInject or 0) or 0
				local priview_data = {item_id = cfg.newEquipId, num = 1, is_bind = 0, strengthen_level = strengthen_my_level,
				infuse_level = infuse_my_level, property_1 = self.select_data.property_1, property_2 = self.select_data.property_2, property_3 = self.select_data.property_3 }
				self.xuanbin_priview_cell:SetData(priview_data)
			end
			if self.xuanbin_soures_cell:GetData() == nil then
				self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
			else
				self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(true)
			end
		else
			if self.xuanbin_soures_cell:GetData() ~= nil then
				self.xuanbin_soures_cell:ClearData()
			end
			if self.xuanbin_target_cell:GetData() ~= nil then
				self.xuanbin_target_cell:ClearData()
			end
			if self.xuanbin_priview_cell:GetData() ~= nil then
				self.xuanbin_priview_cell:ClearData()
			end
			if self.consumes_cell:GetData() ~= nil then
				self.consumes_cell:ClearData()
			end
			self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
		end
	else
		if self.xuanbin_soures_cell:GetData() ~= nil then
			self.xuanbin_soures_cell:ClearData()
		end
		if self.xuanbin_target_cell:GetData() ~= nil then
			self.xuanbin_target_cell:ClearData()
		end
		if self.xuanbin_priview_cell:GetData() ~= nil then
			self.xuanbin_priview_cell:ClearData()
		end
		if self.consumes_cell:GetData() ~= nil then
			self.consumes_cell:ClearData()
		end
		self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
	end
end


function EquipmentXuanBinPage:YongYouItemNum()
	local item_cfg = ItemData.Instance:GetItemConfig(4093)
	local num = ItemData.Instance:GetItemNumInBagById(4093, nil)
	if item_cfg ~= nil then
		local name = item_cfg.name
		local color = string.format("%06x", item_cfg.color)
		local txt = string.format(Language.Equipment.HadYongYou, color, name, num)
		RichTextUtil.ParseRichText(self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.txt_had_num.node, txt)
		XUI.RichTextSetCenter(self.view.node_t_list.layout_xuan_bin.layout_xunbin_cast.layout_god_uplevel.txt_had_num.node)
	end
end

-- 玄兵分解
function EquipmentXuanBinPage:CreateXuanBinGridCells()
	if self.xuanbin_grid_list == nil then
		self.xuanbin_grid_list = BaseGrid.New()
		self.xuanbin_grid_list:SetGridName(GRID_TYPE_RECYCLE_BAG)
		self.xuanbin_grid_list:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
		local ph_baggrid = self.view.ph_list.ph_xuanbin_grid_list
		local grid_node = self.xuanbin_grid_list:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = 75, col=6, row=2, itemRender = DecomposeXuanBinRender, direction = ScrollDir.Horizontal })
		grid_node:setAnchorPoint(0, 0)
		self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.xuanbin_grid_list:SetIsMultiSelect(true)
		self.xuanbin_grid_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	end
end

function EquipmentXuanBinPage:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	self.page_index = cur_page_index
	self:BoolShowBtn()
end

function EquipmentXuanBinPage:SelectCellCallBack(cell)
	if cell == nil or cell:GetData() == nil then return end
	self:FlushXuanBinRigthtData()
end

function EquipmentXuanBinPage:CreateXuanBinScorllTabbar()
	if self.scroll_tabbar ~= nil then return end
	self.scroll_tabbar = ScrollTabbar.New()
	self.scroll_tabbar:CreateWithNameList(self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.scroll_tabbar.node, 36, 0,
		BindTool.Bind1(self.SelectTabCallback, self), EquipmentData.Instance:GetXuanBinBtnList(), 
		true, ResPath.GetCommon("btn_106_normal"))
	self.scroll_tabbar:SelectIndex(1)
	self.scroll_tabbar:ChangeToIndex(1)
	self:SelectTabCallback(1)
end

function EquipmentXuanBinPage:SelectTabCallback()
	if self.p_last_index then
		EquipmentData.Instance:InitXuanBinEquip(index)
	end
	self.p_last_index = index
	self:UpdateFilterBagItem()
	self:FlushItem()
end

function EquipmentXuanBinPage:UpdateFilterBagItem()
	EquipmentData.Instance:InitXuanBinEquip()
	self.xuanbin_grid_list:SetDataList(EquipmentData.Instance:GetXuanBinList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
end	

function EquipmentXuanBinPage:FlushTabbar()
	if self.scroll_tabbar == nil then return end

	for k, v in pairs(EquipmentData.Instance:GetXuanBinBtnList()) do
		self:FlushCurTabbar(k)
	end
end

function EquipmentXuanBinPage:FlushCurTabbar(index)
	if self.scroll_tabbar ~= nil then
		local length = #EquipmentData.Instance:GetXuanBinBtnList()
		local equip_t = EquipmentData.Instance:GetXuanBinList()[index] or {}
		local  n = 0
		for k,v in pairs(equip_t) do
			n = n + 1
		end
		if n > 0 then
			self.scroll_tabbar:SetNameByIndex(index, EquipmentData.Instance:GetXuanBinBtnList()[index] or "", COLOR3B.WHITE)
		else
			self.scroll_tabbar:SetNameByIndex(index, EquipmentData.Instance:GetXuanBinBtnList()[index] or "", COLOR3B.GRAY)
		end	
	end
end

function EquipmentXuanBinPage:CreateXuanBinBox()
	local check_node_list = {
								self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.layout_select_prof.node,
								self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.layout_select_prof_2.node,
								self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.layout_select_prof_3.node,
							}
	for i = 1, 3 do
		self:CreateCheckBox("prof_" .. i, check_node_list[i])
	end
end

function EquipmentXuanBinPage:CreateCheckBox(key, node)
	self.check_box_list = self.check_box_list or {}
	self.check_box_list[key] = {}
	self.check_box_list[key].status = self.check_box_state_list[key]
	self.check_box_list[key].node = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	node:addChild(self.check_box_list[key].node, 10)
	XUI.AddClickEventListener(node, BindTool.Bind2(self.OnClickSelectBoxHandler, self, key), true)
end

function EquipmentXuanBinPage:OnClickSelectBoxHandler(key)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = not self.check_box_list[key].status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	self.check_box_state_list[key] = self.check_box_list[key].status
	self:FlushItem()
end

function EquipmentXuanBinPage:SetCheckBoxStatus(key, status)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
end

function EquipmentXuanBinPage:FlushItem()
	local prof_check_1 = self.check_box_list["prof_1"].status
	local prof_check_2 = self.check_box_list["prof_2"].status
	local prof_check_3 = self.check_box_list["prof_3"].status
	local select_list_0 = {}
	local select_list_1 = {}
	local select_list_2 = {}
	local select_list_3 = {}
	for k, v in pairs(EquipmentData.Instance:GetXuanBinList()[self.scroll_tabbar:GetCurSelectIndex()] or {}) do
		local value = nil 
		local item_cfg = ItemData.Instance:GetItemConfig(v.item_id)
		if item_cfg then
			for k_2,v_2 in pairs(item_cfg.conds) do
				if v_2.cond == ItemData.UseCondition.ucJob then
					if v_2.value == 1 then
						select_list_1[k] = v
					end
				
					if v_2.value == 2 then
						select_list_2[k] = v
					end
				
					if v_2.value == 3 then
						select_list_3[k] = v
					end
				else
					select_list_0[k] = v
				end
			end
		end
	end

	for k,v in pairs(select_list_0) do
		self.xuanbin_grid_list:CancleSelectCellByIndex(k)
		self.xuanbin_grid_list:SelectCellByIndex(k)
	end

	for k, v in pairs(select_list_3) do
		self.xuanbin_grid_list:CancleSelectCellByIndex(k)
		if prof_check_3 then
			self.xuanbin_grid_list:SelectCellByIndex(k)
		end
	end

	for k, v in pairs(select_list_2) do
		self.xuanbin_grid_list:CancleSelectCellByIndex(k)
		if prof_check_2 then
			self.xuanbin_grid_list:SelectCellByIndex(k)
		end
	end

	for k,v in pairs(select_list_1) do
		self.xuanbin_grid_list:CancleSelectCellByIndex(k)
		if prof_check_1 then
			self.xuanbin_grid_list:SelectCellByIndex(k)		
		end
	end
	self:FlushXuanBinRigthtData()
end

function EquipmentXuanBinPage:FlushXuanBinRigthtData()
	local cell_list = self.xuanbin_grid_list:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	local shen_zhu_num, shiled_num = EquipmentData.Instance:GetReward(data)
	self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.exp_num_1.node:setString(shen_zhu_num)
	self.view.node_t_list.layout_xuan_bin.layout_xuan_bin_decompose.shiled_num_1.node:setString(shiled_num)
end

function EquipmentXuanBinPage:FenjieXuanBinEquip()
	local equip_t = {}
	local cell_list = self.xuanbin_grid_list:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	for k,v in pairs(data) do
		equip_t[#equip_t + 1] = v.series
	end
	if #equip_t > 0 then
		BagCtrl.EquipRecycle(self.scroll_tabbar:GetCurSelectIndex(), 2, equip_t,0)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Bag.NotEquip)
	end
end

function EquipmentXuanBinPage:MoveXuanBinLeft()
	if self.page_index > 1 then
		self.page_index = self.page_index - 1
		self.xuanbin_grid_list:ChangeToPage(self.page_index)
	end
end

function EquipmentXuanBinPage:MoveXuanBinRight()
	if self.page_index < 7  then
		self.page_index = self.page_index + 1
		self.xuanbin_grid_list:ChangeToPage(self.page_index)
	end
end

function EquipmentXuanBinPage:OpenFenJieDescTip()
	DescTip.Instance:SetContent(Language.Equipment.XuanBinFenJieContent, Language.Equipment.XuanBinFenJieTitle)
end

--神铸装备Render
XuanBinEquipListItem = XuanBinEquipListItem or BaseClass(BaseRender)
function XuanBinEquipListItem:__init()
	
end

function XuanBinEquipListItem:__delete()
	if self.equip_xuanbin_cell ~= nil then
		self.equip_xuanbin_cell:DeleteMe()
		self.equip_xuanbin_cell = nil 
	end
end

function XuanBinEquipListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_xuanbin_cell == nil then
		local ph = self.ph_list.ph_xuanbin_cell
		self.equip_xuanbin_cell = GodCastEquipCell.New()
		self.equip_xuanbin_cell:SetPosition(ph.x, ph.y)
		self.equip_xuanbin_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.equip_xuanbin_cell:GetView(), 100)
	end
end

function XuanBinEquipListItem:OnFlush()
	if self.data == nil then return end
	if self.data.item_id == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	self.node_tree["txt_xunbin_name"].node:setString(item_cfg.name)
	if item_cfg.color ~= nil then
		local color = string.format("%06x", item_cfg.color)
		self.node_tree["txt_xunbin_name"].node:setColor(Str2C3b(color))
	end
	self.equip_xuanbin_cell:SetData(self.data)
end

DecomposeXuanBinRender = DecomposeXuanBinRender or BaseClass(BaseCell)
function DecomposeXuanBinRender:__init()
	self.view:setTouchEnabled(true)
	self.view:setIsHittedScale(false)
	self.view:addTouchEventListener(BindTool.Bind(self.OnTouchCellLayout, self))
	self.is_long_click = false
end

function DecomposeXuanBinRender:__delete()
	if self.delay_flush_time ~= nil  then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil
	end
end

function DecomposeXuanBinRender:OnClick()
end

function DecomposeXuanBinRender:OnTouchCellLayout(sender, event_type, touch)
	if self.data == nil then return end
	if event_type == XuiTouchEventType.Began then
		self.is_long_click = false
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end
		self.delay_flush_time = GlobalTimerQuest:AddDelayTimer(function ()
			self.is_long_click = true
			TipsCtrl.Instance:OpenItem(self.data, EquipTip.FROM_NORMAL)
		end,0.2)
	elseif event_type == XuiTouchEventType.Moved then
	elseif event_type == XuiTouchEventType.Ended then
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end

		if self.is_long_click then
			TipsCtrl.Instance:CloseEquip()
		else
			BaseCell.OnClick(self)
		end	
	else	
		if self.delay_flush_time ~= nil  then
			GlobalTimerQuest:CancelQuest(self.delay_flush_time)
			self.delay_flush_time = nil
		end

		if self.is_long_click then
			TipsCtrl.Instance:CloseEquip()
		end	
	end	
end

function DecomposeXuanBinRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(BaseCell.SIZE / 2 + 7, BaseCell.SIZE / 2, 
		ResPath.GetCommon("base_cell_bg_3"), true)
	if nil == self.select_effect then
		ErrorLog("BaseCell:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999, 999)
end
