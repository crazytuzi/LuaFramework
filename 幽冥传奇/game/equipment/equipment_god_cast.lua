EquipmentGodCastPage = EquipmentGodCastPage or BaseClass()


function EquipmentGodCastPage:__init()
	
end	

function EquipmentGodCastPage:__delete()
	--self:RemoveEvent()
	if self.tabbar_equip then
		self.tabbar_equip:DeleteMe()
		self.tabbar_equip = nil 
	end

	if self.tabbar_decompose then
		self.tabbar_decompose:DeleteMe()
		self.tabbar_decompose = nil
	end

	if self.god_equip_list then
		self.god_equip_list:DeleteMe()
		self.god_equip_list = nil
	end

	if self.soures_cell then
		self.soures_cell:DeleteMe()
		self.soures_cell = nil
	end

	if self.target_cell then
		self.target_cell:DeleteMe()
		self.target_cell = nil
	end

	if self.priview_cell then
		self.priview_cell:DeleteMe()
		self.priview_cell = nil 
	end
	if self.god_grid_list then
		self.god_grid_list:DeleteMe()
		self.god_grid_list = nil 
	end

	if self.comsume_cell_equip then
		self.comsume_cell_equip:DeleteMe()
		self.comsume_cell_equip = nil 
	end

	if self.scroll_tabbar then
		self.scroll_tabbar:DeleteMe()
		self.scroll_tabbar = nil 
	end

	if self.equip_data_change_evt then
		GlobalEventSystem:UnBind(self.equip_data_change_evt)
		self.equip_data_change_evt = nil
	end
	self.check_box_list = nil

	self:RemoveEvent()
end	

--初始化页面接口
function EquipmentGodCastPage:InitPage(view)
	--绑定要操作的元素
	self.view = view

	-- 升级
	self.equip_index =1
	self.method_index =1
	self.select_equip_index = 0
	self:CreateTabbarBagAndBody()
	self:CreateTabbar()
	self:CreateCells()
	self:CreteGodEquipList()
	-- 分解
	self:CreateGridCells()
	self.check_box_state_list = {
									["prof_1"] = false,
									["prof_2"] = false,
									["prof_3"] = false,
								}
	self:CreateBox()
	for i = 1, 3 do
		self:SetCheckBoxStatus("prof_" .. i, self.check_box_state_list["prof_" .. i])
	end
	self.page_index = 1
	EquipmentData.Instance:InitGodEquipBagList()
	self:CreateScorllTabbar()
	--
	self:InitEvent()
end	

function EquipmentGodCastPage:InitEvent()
	self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:setLocalZOrder(998)
	self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:addClickEventListener(BindTool.Bind(self.ClearCell, self))
	self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_upLevel.node:addClickEventListener(BindTool.Bind(self.UpLevel, self))
	self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_desc_tip.node:addClickEventListener(BindTool.Bind(self.OpenTip, self))
	self.itemdata_change_callback = BindTool.Bind1(self.ItemDataChangeCallback,self)			--监听人物属性数据变化
	self.equipmentdata_change_callback = BindTool.Bind1(self.EquipmentDataChangeCallback,self)	--监听装备数据变化
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	EquipData.Instance:NotifyDataChangeCallBack(self.equipmentdata_change_callback)
	self.equip_data_change_evt = GlobalEventSystem:Bind(HeroDataEvent.HERO_EQUIP_CHANGE,BindTool.Bind1(self.OnHeroEquipDataChange, self))
	-- 神铸分解
	XUI.AddClickEventListener(self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.btn_left.node, BindTool.Bind1(self.MoveLeft, self))
	XUI.AddClickEventListener(self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.btn_right.node, BindTool.Bind1(self.MoveRight, self))
	self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.btn_fenjie_tip.node:addClickEventListener(BindTool.Bind(self.OpenFenJieTip,self))
	XUI.AddClickEventListener(self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.layout_fenjie.btn_quick_recycle.node, BindTool.Bind1(self.FenjieGodEquip, self), true)
end

function EquipmentGodCastPage:CreateTabbarBagAndBody()
	if self.tabbar_equip == nil then
		self.tabbar_equip = Tabbar.New()
		self.tabbar_equip:CreateWithNameList(self.view.node_t_list.layout_god_equip.node, 9, 559,
			BindTool.Bind1(self.SelectEquipCallback, self), 
			Language.Equipment.TabGroup_1, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_equip:SetSpaceInterval(5)
	end
end

function EquipmentGodCastPage:OnHeroEquipDataChange()
	self.view:Flush(TabIndex.equipment_god_cast)
end

function EquipmentGodCastPage:SelectEquipCallback(index)
	self.equip_index = index 
	self.select_data = nil
	self:FlushData()
end

function EquipmentGodCastPage:CreateTabbar()
	if self.tabbar_decompose == nil then
		self.tabbar_decompose = Tabbar.New()
		self.tabbar_decompose:CreateWithNameList(self.view.node_t_list.layout_god_equip.node, 760, 559,
			BindTool.Bind1(self.SelectEquipFenjieCallback, self), 
			Language.Equipment.TabGroup_6, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_decompose:SetSpaceInterval(5)
	end
end

function EquipmentGodCastPage:SelectEquipFenjieCallback(index)
	self.method_index = index
	self:BoolShowLayout()
	-- if self.method_index == 1 then
	self:FlushData()
	--end
end

function EquipmentGodCastPage:BoolShowLayout()
	self.view.node_t_list.layout_god_equip.layout_god_cast.node:setVisible(self.method_index == 1)
	self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.node:setVisible(self.method_index == 2)
	self.tabbar_equip:SetToggleVisible(1, self.method_index == 1)
	self.tabbar_equip:SetToggleVisible(2, self.method_index == 1)
	self.tabbar_equip:SetToggleVisible(3, self.method_index == 1)
end

--神装列表
function EquipmentGodCastPage:CreteGodEquipList()
	if self.god_equip_list == nil then
		local ph = self.view.ph_list.ph_god_list
		self.god_equip_list = ListView.New()
		self.god_equip_list:Create(ph.x, ph.y, ph.w, ph.h, nil, GodEquipListItem, nil, nil, self.view.ph_list.ph_god_item)
		self.view.node_t_list.layout_god_equip.layout_god_cast.node:addChild(self.god_equip_list:GetView(), 999)
		self.god_equip_list:SetMargin(5)
		self.god_equip_list:SetItemsInterval(10)
		self.god_equip_list:SelectIndex(1)
		self.god_equip_list:GetView():setAnchorPoint(0, 0)
		self.god_equip_list:SetJumpDirection(ListView.Top)
		self.god_equip_list:SetSelectCallBack(BindTool.Bind1(self.SelectEquipListCallBack, self))
	end
end

function EquipmentGodCastPage:SelectEquipListCallBack(item, index)
	if item == nil or item:GetData() == nil then return end
	self.select_equip_data = item:GetData()
	self.select_equip_index = item:GetIndex()
	self:FlushGodListData(self.select_equip_data)
end


function EquipmentGodCastPage:CreateCells( )
	if self.priview_cell == nil then
		local ph = self.view.ph_list.ph_gold_cell_1
		self.priview_cell = BaseCell.New()
		self.priview_cell:SetPosition(ph.x+8, ph.y+10)
		self.priview_cell:GetView():setAnchorPoint(0, 0)
		self.priview_cell:SetCellBg(ResPath.GetEquipment("cell_1_bg"))
		self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.node:addChild(self.priview_cell:GetView(), 100)
	end

	if self.soures_cell == nil then
		local ph = self.view.ph_list.ph_gold_cell_2
		self.soures_cell = BaseCell.New()
		self.soures_cell:SetPosition(ph.x, ph.y)
		self.soures_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.node:addChild(self.soures_cell:GetView(), 100)
	end

	if self.target_cell == nil then
		local ph = self.view.ph_list.ph_gold_cell_3
		self.target_cell = BaseCell.New()
		self.target_cell:SetPosition(ph.x, ph.y)
		self.target_cell:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.node:addChild(self.target_cell:GetView(), 100)
	end

	if self.comsume_cell_equip == nil then
		local ph = self.view.ph_list.ph_gold_cell_4
		self.comsume_cell_equip = BaseCell.New()
		self.comsume_cell_equip:SetPosition(ph.x, ph.y)
		self.comsume_cell_equip:GetView():setAnchorPoint(0, 0)
		self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.node:addChild(self.comsume_cell_equip:GetView(), 100)
	end
end

function EquipmentGodCastPage:UpdateData(data)
	for k,v in pairs(data) do
		if k == "all" then
			if self.method_index == 1 then
				local data_1 = EquipmentData.Instance:GetBodyEquipCanShenZhu()
				if data_1[1] == nil then 
					local data = EquipmentData.Instance:GetBagEquipCanShenZhu()
					if data[1] ~= nil then
						self.tabbar_equip:SelectIndex(2)
					else
						self.tabbar_equip:SelectIndex(1)
					end
				else
					self.tabbar_equip:SelectIndex(1)
				end
			end
			self:BoolShowLayout()
			self:FlushData()
			local caozuo_type, caozuo_result = EquipmentData.Instance:GetCaoZuoTypeAndResult()
			if caozuo_type == 1 and caozuo_result == 1 then
				self:ClearCell()
			end
		elseif k == "god_equip_change" then
			EquipmentData.Instance:InitGodEquipBagList()
			self.god_grid_list:SetDataList(EquipmentData.Instance:GetGodEquipBagList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
			self:FlushCurTabbar(self.scroll_tabbar:GetCurSelectIndex())
			self:FlushItem()
		end
	end
	
end

function EquipmentGodCastPage:FlushData()
	self.equip_data = {}
	if self.method_index == 1 then
		if self.equip_index == 1 then
			self.equip_data = EquipmentData.Instance:GetBodyEquipCanShenZhu()
			self.god_equip_list:SetDataList(self.equip_data)
		elseif self.equip_index == 2 then
			self.equip_data = EquipmentData.Instance:GetBagEquipCanShenZhu()
			self.god_equip_list:SetDataList(self.equip_data)
		elseif self.equip_index == 3 then
			self.equip_data = EquipmentData.Instance:GetHeroDataCanShenZhu()
			self.god_equip_list:SetDataList(self.equip_data)
		end
		self:FlushRigthtView(self.equip_data)
		self:YongYouSuiPianNum()	
	elseif self.method_index == 2 then
		self:UpdateFilterBagItem()
		self:BoolShowBtn()
		self:FlushTabbar()
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		self:SetCheckBoxStatus("prof_1", prof ~= 1)
		self:SetCheckBoxStatus("prof_2", prof ~= 2)
		self:SetCheckBoxStatus("prof_3", prof ~= 3)
		self:SelectTabCallback(1)
		self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.txt_suipian.node:setString(Language.Equipment.Name_SuiPian)
		self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.txt_shiled.node:setString("")
	end
end

function EquipmentGodCastPage:BoolShowBtn()
	self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.btn_left.node:setVisible(self.page_index ~= 1)
	self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.btn_right.node:setVisible(self.page_index ~= 7)
end

function EquipmentGodCastPage:FlushRigthtView(data)
	self.select_data = data[self.select_equip_index] 
	if self.select_equip_data ~= nil  and data[self.select_equip_index] ~= nil then
		self:FlushGodListData(self.select_data)
	else
		if self.soures_cell:GetData() ~= nil then
			self.soures_cell:ClearData()
		end
		if self.target_cell:GetData() ~= nil then
			self.target_cell:ClearData()
		end
		if self.priview_cell:GetData() ~= nil then
			self.priview_cell:ClearData()
		end
		if self.comsume_cell_equip:GetData() ~= nil then
			self.comsume_cell_equip:ClearData()
		end
		self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
	end
end

function EquipmentGodCastPage:FlushGodListData(select_data)
	if select_data ~= nil then
		self.soures_cell:SetData(select_data)
		local cfg = EquipmentData.GetConfigDataById(select_data.item_id) 
		if cfg ~= nil then
			local consume_data  = {item_id = cfg.consumes[1].id, num = 1, is_bind = 0}
			self.target_cell:SetData(consume_data)
			local had_consume = ItemData.Instance:GetItemNumInBagById(cfg.consumes[1].id, bind_type)
			local color = COLOR3B.GREEN 
			local txt_2 =  had_consume .. "/" .. cfg.consumes[1].count
			if had_consume >= cfg.consumes[1].count then
				color = COLOR3B.GREEN 
			else
				color = COLOR3B.RED 
			end
			self.target_cell:SetCenterBottomText(txt_2, color)
			local priview_data = {item_id = cfg.newEquipId, num = 1, is_bind = 0, strengthen_level = select_data.strengthen_level,
			infuse_level = select_data.infuse_level, property_1 = select_data.property_1, property_2 = select_data.property_2, property_3 = select_data.property_3 }
			self.priview_cell:SetData(priview_data)

			local consume_equip = {item_id = cfg.consumes[2].id, num = 1, is_bind = 0}
			self.comsume_cell_equip:SetData(consume_equip)
			local had_consume_1 = ItemData.Instance:GetItemNumInBagById(cfg.consumes[2].id, bind_type)
			local color = COLOR3B.GREEN 
			local txt =  had_consume_1 .. "/" .. cfg.consumes[2].count
			if had_consume_1 >= cfg.consumes[2].count then
				color = COLOR3B.GREEN 
			else
				color = COLOR3B.RED 
			end
			self.comsume_cell_equip:SetCenterBottomText(txt, color)

		end
		if self.target_cell:GetData() == nil then
			self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
		else
			self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(true)
		end
	else
		if self.soures_cell:GetData() ~= nil then
			self.soures_cell:ClearData()
		end
		if self.target_cell:GetData() ~= nil then
			self.target_cell:ClearData()
		end
		if self.priview_cell:GetData() ~= nil then
			self.priview_cell:ClearData()
		end
		if self.comsume_cell_equip:GetData() ~= nil then
			self.comsume_cell_equip:ClearData()
		end
		self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
	end
end

function EquipmentGodCastPage:YongYouSuiPianNum()
	local item_cfg = ItemData.Instance:GetItemConfig(4093)
	local num = ItemData.Instance:GetItemNumInBagById(4093, nil)
	if item_cfg ~= nil then
		local name = item_cfg.name
		local color = string.format("%06x", item_cfg.color)
		local txt = string.format(Language.Equipment.HadYongYou, color, name, num)
		RichTextUtil.ParseRichText(self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.txt_had_num.node, txt)
		XUI.RichTextSetCenter(self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.txt_had_num.node)
	end
end

function EquipmentGodCastPage:ClearCell()
	if self.soures_cell:GetData() ~= nil then
		self.soures_cell:ClearData()
	end
	if self.target_cell:GetData() ~= nil then
		self.target_cell:ClearData()
	end
	if self.priview_cell:GetData() ~= nil then
		self.priview_cell:ClearData()
	end
	if self.comsume_cell_equip:GetData() ~= nil then
		self.comsume_cell_equip:ClearData()
	end
	self.view.node_t_list.layout_god_equip.layout_god_cast.layout_god_uplevel.btn_clear_cell.node:setVisible(false)
end

function EquipmentGodCastPage:EquipmentDataChangeCallback()
	self.view:Flush(TabIndex.equipment_god_cast)
end

function EquipmentGodCastPage:ItemDataChangeCallback(change_type, item_id, item_index, series)
	if self.method_index == 1 then
		self:YongYouSuiPianNum()
	elseif self.method_index == 2 then
		self.view:Flush(TabIndex.equipment_god_cast, "god_equip_change")
	end
end

function EquipmentGodCastPage:RemoveEvent()
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
	if self.equipmentdata_change_callback then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equipmentdata_change_callback)
		self.equipmentdata_change_callback = nil 
	end
end

function EquipmentGodCastPage:UpLevel()
	local data = self.soures_cell:GetData()
	if data ~= nil then
		EquipmentCtrl.Instance:SendUpLevelEquip(data.series)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Equipment.Input_Desc)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentGodCastPage:OpenTip()
	DescTip.Instance:SetContent(Language.Equipment.GodEquipContent, Language.Equipment.GodEquipTitle)
end

--
function EquipmentGodCastPage:CreateScorllTabbar()
	if self.scroll_tabbar ~= nil then return end
	self.scroll_tabbar = ScrollTabbar.New()
	self.scroll_tabbar:CreateWithNameList(self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.scroll_tabbar.node, 36, 0,
		BindTool.Bind1(self.SelectTabCallback, self), EquipmentData.Instance:GetBtnList(), 
		true, ResPath.GetCommon("btn_106_normal"))
	self.scroll_tabbar:SelectIndex(1)
	self.scroll_tabbar:ChangeToIndex(1)
	self:SelectTabCallback(1)
end

function EquipmentGodCastPage:SelectTabCallback(index)
	if self.p_last_index then
		EquipmentData.Instance:InitGodEquipBagList(index)
	end
	self.p_last_index = index
	self:UpdateFilterBagItem()
	self:FlushItem()
end

function EquipmentGodCastPage:UpdateFilterBagItem()
	EquipmentData.Instance:InitGodEquipList()
	self.god_grid_list:SetDataList(EquipmentData.Instance:GetGodEquipBagList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
end	

function EquipmentGodCastPage:FlushTabbar()
	if self.scroll_tabbar == nil then return end

	for k, v in pairs(EquipmentData.Instance:GetBtnList()) do
		self:FlushCurTabbar(k)
	end
end

function EquipmentGodCastPage:FlushCurTabbar(index)
	if self.scroll_tabbar ~= nil then
		local length = #EquipmentData.Instance:GetBtnList()
		local equip_t = EquipmentData.Instance:GetGodEquipBagList()[index] or {}
		local  n = 0
		for k,v in pairs(equip_t) do
			n = n + 1
		end
		if n > 0 then
			self.scroll_tabbar:SetNameByIndex(index, EquipmentData.Instance:GetBtnList()[index] or "", COLOR3B.WHITE)
		else
			self.scroll_tabbar:SetNameByIndex(index, EquipmentData.Instance:GetBtnList()[index] or "", COLOR3B.GRAY)
		end	
	end
end

function EquipmentGodCastPage:CreateGridCells()
	if self.god_grid_list == nil then
		self.god_grid_list = BaseGrid.New()
		self.god_grid_list:SetGridName(GRID_TYPE_RECYCLE_BAG)
		self.god_grid_list:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
		local ph_baggrid = self.view.ph_list.ph_grid_list
		local grid_node = self.god_grid_list:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = 75, col=6, row=2, itemRender = DecomposeRender, direction = ScrollDir.Horizontal })
		grid_node:setAnchorPoint(0, 0)
		self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.god_grid_list:SetIsMultiSelect(true)
		self.god_grid_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	end
end

function EquipmentGodCastPage:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	self.page_index = cur_page_index
	self:BoolShowBtn()
end

function EquipmentGodCastPage:SelectCellCallBack(cell)
	if cell == nil then return end
	self:FlushRigthtData()
end

function EquipmentGodCastPage:CreateBox()
	local check_node_list = {
								self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.layout_select_prof.node,
								self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.layout_select_prof_2.node,
								self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.layout_select_prof_3.node,
							}
	for i = 1, 3 do
		self:CreateCheckBox("prof_" .. i, check_node_list[i])
	end
end

function EquipmentGodCastPage:CreateCheckBox(key, node)
	self.check_box_list = self.check_box_list or {}
	self.check_box_list[key] = {}
	self.check_box_list[key].status = self.check_box_state_list[key]
	self.check_box_list[key].node = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	node:addChild(self.check_box_list[key].node, 10)
	XUI.AddClickEventListener(node, BindTool.Bind2(self.OnClickSelectBoxHandler, self, key), true)
end

function EquipmentGodCastPage:OnClickSelectBoxHandler(key)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = not self.check_box_list[key].status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	self.check_box_state_list[key] = self.check_box_list[key].status
	self:FlushItem()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function EquipmentGodCastPage:SetCheckBoxStatus(key, status)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
end

function EquipmentGodCastPage:FlushItem()
	local prof_check_1 = self.check_box_list["prof_1"].status
	local prof_check_2 = self.check_box_list["prof_2"].status
	local prof_check_3 = self.check_box_list["prof_3"].status
	local select_list_0 = {}
	local select_list_1 = {}
	local select_list_2 = {}
	local select_list_3 = {}
	for k, v in pairs(EquipmentData.Instance:GetGodEquipBagList()[self.scroll_tabbar:GetCurSelectIndex()] or {}) do
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
		self.god_grid_list:CancleSelectCellByIndex(k)
		self.god_grid_list:SelectCellByIndex(k)
	end

	for k, v in pairs(select_list_3) do
		self.god_grid_list:CancleSelectCellByIndex(k)
		if prof_check_3 then
			self.god_grid_list:SelectCellByIndex(k)
		end
	end

	for k, v in pairs(select_list_2) do
		self.god_grid_list:CancleSelectCellByIndex(k)
		if prof_check_2 then
			self.god_grid_list:SelectCellByIndex(k)
		end
	end

	for k,v in pairs(select_list_1) do
		self.god_grid_list:CancleSelectCellByIndex(k)
		if prof_check_1 then
			self.god_grid_list:SelectCellByIndex(k)		
		end
	end
	self:FlushRigthtData()
end

function EquipmentGodCastPage:FlushRigthtData()
	local cell_list = self.god_grid_list:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	local shen_zhu_num, shiled_num = EquipmentData.Instance:GetReward(data)
	self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.exp_num.node:setString(shen_zhu_num)
	self.view.node_t_list.layout_god_equip.layout_god_equip_decompose.shiled_num.node:setString("")
end

function EquipmentGodCastPage:MoveLeft()
	if self.page_index > 1 then
		self.page_index = self.page_index - 1
		self.god_grid_list:ChangeToPage(self.page_index)
	end
end

function EquipmentGodCastPage:MoveRight()
	if self.page_index < 7  then
		self.page_index = self.page_index + 1
		self.god_grid_list:ChangeToPage(self.page_index)
	end
end
function EquipmentGodCastPage:OpenFenJieTip()
	DescTip.Instance:SetContent(Language.Equipment.EquipFenJieContent, Language.Equipment.EquipFenJieTitle)
end

function EquipmentGodCastPage:FenjieGodEquip()
	local equip_t = {}
	local cell_list = self.god_grid_list:GetMultiSelectCell()
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
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

--神铸装备Render
GodEquipListItem = GodEquipListItem or BaseClass(BaseRender)
function GodEquipListItem:__init()
	
end

function GodEquipListItem:__delete()
	if self.equip_cell ~= nil then
		self.equip_cell:DeleteMe()
		self.equip_cell = nil 
	end
end

function GodEquipListItem:CreateChild()
	BaseRender.CreateChild(self)
	if self.equip_cell == nil then
		local ph = self.ph_list.ph_item_cell
		self.equip_cell = GodCastEquipCell.New()
		self.equip_cell:SetPosition(ph.x, ph.y)
		self.equip_cell:GetView():setAnchorPoint(0, 0)
		self.view:addChild(self.equip_cell:GetView(), 100)
	end
end

function GodEquipListItem:OnFlush()
	if self.data == nil then return end
	if self.data.item_id == nil then return end
	local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	if item_cfg == nil then
		return
	end
	self.node_tree["txt_equip_name"].node:setString(item_cfg.name)
	if item_cfg.color ~= nil then
		local color = string.format("%06x", item_cfg.color)
		self.node_tree["txt_equip_name"].node:setColor(Str2C3b(color))
	end
	self.equip_cell:SetData(self.data)
end


GodCastEquipCell = GodCastEquipCell or BaseClass(BaseCell)
function GodCastEquipCell:__init()
end	

function GodCastEquipCell:__delete()
end

function GodCastEquipCell:InitEvent()
end	

-- 神装分解
DecomposeRender = DecomposeRender or BaseClass(BaseCell)
function DecomposeRender:__init()
	self.view:setTouchEnabled(true)
	self.view:setIsHittedScale(false)
	self.view:addTouchEventListener(BindTool.Bind(self.OnTouchCellLayout, self))
	self.is_long_click = false
end

function DecomposeRender:__delete()
	if self.delay_flush_time ~= nil  then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil
	end
end

function DecomposeRender:OnClick()
end

function DecomposeRender:OnTouchCellLayout(sender, event_type, touch)
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

function DecomposeRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(BaseCell.SIZE / 2 + 7, BaseCell.SIZE / 2, 
		ResPath.GetCommon("base_cell_bg_3"), true)
	if nil == self.select_effect then
		ErrorLog("BaseCell:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999, 999)
end