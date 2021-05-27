------------------------------------------------------------
-- 回收
------------------------------------------------------------
ExploreRecycleBagView = ExploreRecycleBagView or BaseClass(XuiBaseView)

function ExploreRecycleBagView:__init()
	self.is_async_load = false
	self:SetModal(true)
	self.texture_path_list[2] = 'res/xui/equipbg.png'
	self.texture_path_list[1] = 'res/xui/role.png'
	self.texture_path_list[3] = 'res/xui/exchange.png'
	self.config_tab = {
		{"common_ui_cfg", 1, {0}},
		{"explore_ui_cfg", 6, {0}},
		{"common_ui_cfg", 2, {0}},
	}

	-- self.is_vip_opt = false
	
	self.item_list_event = BindTool.Bind1(self.ItemDataListChangeCallback, self)
	self.role_data_event = BindTool.Bind1(self.RoleDataChangeCallback, self)
	self.tabbar_list = nil 
	self.bag_index = 1
	self.recycle_index = 1
	self.select_data = {}
	-- 勾选框按钮状态记录表
	self.check_box_state_list = {
									["prof_1"] = false,
									["prof_2"] = false,
									["prof_3"] = false,
								}
	self.is_first_login = true
end

function ExploreRecycleBagView:__delete()
end

function ExploreRecycleBagView:ReleaseCallBack()

	self.p_last_index = nil
	self.check_box_list = nil
	

	if self.scroll_tabbar ~= nil then
		self.scroll_tabbar:DeleteMe()
		self.scroll_tabbar = nil
	end

	if self.bag_grid ~= nil then
		self.bag_grid:DeleteMe()
		self.bag_grid = nil
	end

	if self.tabbar_list ~= nil then
		self.tabbar_list:DeleteMe()
		self.tabbar_list = nil
	end

	if self.recycle_grid ~= nil then
		self.recycle_grid:DeleteMe()
		self.recycle_grid = nil
	end

	if self.play_effect ~= nil then
		self.play_effect:setStop()
		self.play_effect = nil 
	end

	if self.number ~= nil then
		self.number:DeleteMe()
		self.number = nil
	end

	if ItemData.Instance then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.item_list_event)
	end
	if RoleData.Instance then
		RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
	end
	ViewManager.Instance:UnRegsiterTabFunUi(ViewName.ExploreBagRecycle)
end

function ExploreRecycleBagView:LoadCallBack(index, loaded_times)
	if loaded_times <= 1 then
		self.title_img_path = ResPath.GetRole("btn_explore_recycle_txt")
		-- ExploreData.Instance:InitRecycleBagList()
		self:SetSelectAllJob()
		RoleData.Instance:NotifyAttrChange(self.role_data_event)
		self:CreateBagGrid()
		self:RegisterEvents()
		self:CreateTabbar()
		ViewManager.Instance:RegsiterTabFunUi(ViewName.ExploreBagRecycle, self.scroll_tabbar)
		self.node_t_list.btn_bag_move_up.node:addClickEventListener(BindTool.Bind1(self.OnMoveBagUp,self))
		self.node_t_list.btn_bag_renove_down.node:addClickEventListener(BindTool.Bind1(self.OnMoveBagDown,self))
		local ph = self.ph_list.ph_render
		self.number = self:CreateNumBar(ph.x - 5, ph.y -5, 30, 29)
		self.node_t_list.layout_explore_recycle.node:addChild(self.number:GetView(), 102)
		self.number:SetGravity(NumberBarGravity.Center)
	end
end

function ExploreRecycleBagView:OnMoveBagUp()
	if self.bag_index > 1 then
		self.bag_index = self.bag_index - 1
		self.bag_grid:ChangeToPage(self.bag_index)
	end
end

function ExploreRecycleBagView:OnMoveBagDown()
	if self.bag_index < 4  then
		self.bag_index = self.bag_index + 1
		self.bag_grid:ChangeToPage(self.bag_index)
	end
end

function ExploreRecycleBagView:OpenCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
	if self.is_first_login then
		local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
		self.is_first_login = false
		for i = 1, 3 do
			self.check_box_state_list["prof_" .. i] = prof ~= i
		end
	end
	for i = 1, 3 do
		self:SetCheckBoxStatus("prof_" .. i, self.check_box_state_list["prof_" .. i])
	end

end

function ExploreRecycleBagView:SetSelectAllJob()		
	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	for i = 1, 3 do
		self.check_box_state_list["prof_" .. i] = prof ~= i
		self:SetCheckBoxStatus("prof_" .. i, self.check_box_state_list["prof_" .. i])
	end
	self:SelectTabCallback(1)
end	

function ExploreRecycleBagView:ResetAllJob()
	self.is_first_login = true
end	

function ExploreRecycleBagView:ShowIndexCallBack(index)
	
	if nil ~= self.bag_grid then
		self.bag_grid:JumpToPage(1)
	end
	self:Flush()
end

function ExploreRecycleBagView:CreateBtn()
	if nil == self.tabbar_list then
		self.tabbar_list = Tabbar.New()
		self.tabbar_list:CreateWithNameList(self.node_t_list.layout_explore_recycle.node, 270, 538,
			BindTool.Bind1(self.SelectBagEquip, self), 
			Language.Bag.TabGroup, false, ResPath.GetCommon("toggle_104_normal"),nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
		self.tabbar_list:SetSpaceInterval(5)
	end
end

function ExploreRecycleBagView:SelectBagEquip(index)
	self:UpdateFilterBagItem()
end

function ExploreRecycleBagView:UpdateFilterBagItem()	
	local AllData = ExploreData.Instance:GetMinIndex()
	if self.bag_grid then
		self.bag_grid:SetDataList(AllData[self.scroll_tabbar:GetCurSelectIndex()] or {})
	end

	-- self:FlushTabbar()
end	

function ExploreRecycleBagView:OnFlush(param_t, index)
	for k,v in pairs(param_t) do
		if k == "all" then
			self:UpdateFilterBagItem()
			self:FlushItem()
			self:FlushTabbar()
			local index = 1
			local data = ExploreData.Instance:GetMinIndex()
			for i,v in ipairs(data) do
				if next(v) then
					index = i
					break
				end
			end
			if index >0 then
				self.scroll_tabbar:SelectIndex(index)
			end
		elseif k == "recycle_bag_list" then
			self.bag_grid:SetDataList(ExploreData.Instance:GetMinIndex()[self.scroll_tabbar:GetCurSelectIndex()] or {})
			self:FlushCurTabbar(self.scroll_tabbar:GetCurSelectIndex())
			self:FlushTabbar()
			self:FlushItem()
		elseif k == "recycle_success" then
			self:SetShowPlayEff(3, 500, 360)
		end
	end
	-- 		self.scroll_tabbar:SelectIndex(2)
	-- 	elseif k == "recycle_bag_list" then
	-- 		self.bag_grid:SetDataList(BagData.Instance:GetRecycleBagList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
	-- 		--self:FlushCurTabbar(self.scroll_tabbar:GetCurSelectIndex())
			-- self:FlushTabbar()
	-- 	elseif k == "recycle_list" then
	-- 		for k_2,v_2 in pairs(v) do
	-- 			if v_2.change_type == ITEM_CHANGE_TYPE.DEL then
	-- 				BagData.Instance:DelRecycleData(v_2.series)
	-- 				BagData.Instance:DelRecycleBagData({series = v_2.series, item_id = v_2.item_id})
	-- 			elseif v_2.change_type == ITEM_CHANGE_TYPE.ADD then
	-- 				local item = ItemData.Instance:GetGridData(k_2)
	-- 				if item then
	-- 					local type_index = BagData.GetRecycleBagType(item.item_id)
	-- 					if type_index > 0 then
	-- 						BagData.Instance:AddRecycleBagData(item, type_index)
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	elseif k == "vip_opt" then
	-- 		-- self.is_vip_opt = true
	-- 	elseif k == "select_level" then
	-- 		-- self:FlushAutoRecycleBtn()
end


function ExploreRecycleBagView:CloseCallBack(is_all)
	AudioManager.Instance:PlayOpenCloseUiEffect()

	-- BagData.Instance:InitRecycleBagList(self.scroll_tabbar:GetCurSelectIndex())	
	self.p_last_index = nil
end

function ExploreRecycleBagView:CreateBagGrid()
	self.bag_grid = BaseGrid.New()
	self.bag_grid:SetGridName(GRID_TYPE_RECYCLE_BAG)
	self.bag_grid:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
	local ph_baggrid = self.ph_list.ph_bag_grid
	local grid_node = self.bag_grid:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count=80, col=4, row=5, itemRender = RecycleRender})
	grid_node:setAnchorPoint(0, 0)
	self.node_t_list.layout_explore_recycle.node:addChild(grid_node, 100)
	grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
	self.bag_grid:SetIsMultiSelect(true)
	self.bag_grid:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
end

function ExploreRecycleBagView:SelectCellCallBack(cell)
	if cell == nil then
		return
	end
	local cell_data = cell:GetData()
	if cell:GetName() == GRID_TYPE_RECYCLE_BAG then
		--TipsCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_BAG_ON_RECYCLE)
	elseif cell:GetName() == GRID_TYPE_RECYCLE then
		--TipsCtrl.Instance:OpenItem(cell_data, EquipTip.FROM_RECYCLE)
	end
	
	self:FlushRigthtData()
end

function ExploreRecycleBagView:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	self.bag_index = cur_page_index
end

function ExploreRecycleBagView:RegisterEvents()
	ItemData.Instance:NotifyDataChangeCallBack(self.item_list_event, true)
	self.node_t_list.btn_recycle_tip.node:addClickEventListener(BindTool.Bind1(self.OnClickTipHandler, self))
	self.node_t_list.btn_quick_recycle.node:addClickEventListener(BindTool.Bind1(self.OnClickQuickRecycleHandler, self))
	self.node_t_list.layout_auto_recycle.node:setVisible(false)
	self.node_t_list.btn_auto_recycle.node:setVisible(false)
	self.node_t_list.txt_auto_1.node:setVisible(false)
	XUI.AddClickEventListener(self.node_t_list.btn_auto_recycle.node, BindTool.Bind(self.OnAutoRecycleLevel, self)) 
	local check_node_list = {
								self.node_t_list.layout_select_prof.node,
								self.node_t_list.layout_select_prof_2.node,
								self.node_t_list.layout_select_prof_3.node,
							}
	for i = 1, 3 do
		self:CreateCheckBox("prof_" .. i, check_node_list[i])
	end
end

function ExploreRecycleBagView:CreateCheckBox(key, node)
	self.check_box_list = self.check_box_list or {}

	self.check_box_list[key] = {}
	self.check_box_list[key].status = self.check_box_state_list[key]
	self.check_box_list[key].node = XUI.CreateImageView(37, 37, ResPath.GetCommon("check_box"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	node:addChild(self.check_box_list[key].node, 10)
	XUI.AddClickEventListener(node, BindTool.Bind2(self.OnClickSelectBoxHandler, self, key), true)
end

function ExploreRecycleBagView:OnClickSelectBoxHandler(key)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = not self.check_box_list[key].status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	self.check_box_state_list[key] = self.check_box_list[key].status
	self:FlushItem()
end

function ExploreRecycleBagView:SetCheckBoxStatus(key, status)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
end

function ExploreRecycleBagView:OnClickTipHandler()
	DescTip.Instance:SetContent(Language.Bag.RecycleTipsContent, Language.Bag.RecycleTipsTitle)
end

function ExploreRecycleBagView:FlushItem(explore)
	if not self.check_box_list then return end
	local prof_check_1 = self.check_box_list["prof_1"].status
	local prof_check_2 = self.check_box_list["prof_2"].status
	local prof_check_3 = self.check_box_list["prof_3"].status
	local select_list_0 = {}
	local select_list_1 = {}
	local select_list_2 = {}
	local select_list_3 = {}
	if not explore then
		for k, v in pairs(ExploreData.Instance:GetMinIndex()[self.scroll_tabbar:GetCurSelectIndex()] or {}) do
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
	else

	end
	for k,v in pairs(select_list_0) do
		self.bag_grid:CancleSelectCellByIndex(k)
		self.bag_grid:SelectCellByIndex(k)
	end

	for k, v in pairs(select_list_3) do
		self.bag_grid:CancleSelectCellByIndex(k)
		if prof_check_3 then
			self.bag_grid:SelectCellByIndex(k)
		end
	end

	for k, v in pairs(select_list_2) do
		self.bag_grid:CancleSelectCellByIndex(k)
		if prof_check_2 then
			self.bag_grid:SelectCellByIndex(k)
		end
	end

	for k,v in pairs(select_list_1) do
		self.bag_grid:CancleSelectCellByIndex(k)
		if prof_check_1 then
			self.bag_grid:SelectCellByIndex(k)		
		end
	end
	self:FlushRigthtData()
end

function ExploreRecycleBagView:RoleDataChangeCallback(key,value)
	if key == OBJ_ATTR.ACTOR_VIP_FLAG then
		self:FlushRigthtData()
	end
end

function ExploreRecycleBagView:FlushRigthtData()
	local cell_list = self.bag_grid:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	local shen_zhu_num, shiled_num_1 = EquipmentData.Instance:GetReward(data)
	local exp_num, shiled_num,yuanbao_num = BagData.Instance:GetRewardValue(self.scroll_tabbar:GetCurSelectIndex() or 0, data)
	local pri_data = PrivilegeData.Instance:GetCurPrivilege()
	local count = PrivilegeData:GetPrivilegeAddCntByType(pri_data, PrivilegeData.AddCntTypeT.ExpAddPercent)
	local rich_txt = "{color;55ff00;  (+%d)}"
	local link_txt = string.format(rich_txt, exp_num*count/100)
	exp_num = exp_num .. link_txt
	RichTextUtil.ParseRichText(self.node_t_list.exp_num.node, exp_num, 24)
	local num = self.scroll_tabbar:GetCurSelectIndex() == 1 and shiled_num_1 or shiled_num
	self.node_t_list.shiled_num.node:setString(num)
	self.node_t_list.suioian_num.node:setString(shen_zhu_num)
	self.node_t_list.yuanbao_num.node:setString(yuanbao_num)
	if self.number ~= nil then
		self.number:SetNumber(count)
		self.number:SetScale(1.5)
	end
end

function ExploreRecycleBagView:CreateNumBar(x, y, w, h)
	local number_bar = NumberBar.New()
	number_bar:SetRootPath(ResPath.GetCommonPath("num_100_"))
	number_bar:SetPosition(x, y)
	number_bar:SetContentSize(w, h)
	number_bar:SetSpace(-4)
	return number_bar
end

function ExploreRecycleBagView:OnAutoRecycleLevel()
	if RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SUPER_VIP) <= 0 then
		return SystemHint.Instance:FloatingTopRightText(Language.Bag.NotSuperMe)
	end
	ViewManager.Instance:Open(StorageViews.OpenAutoList)
end

function ExploreRecycleBagView:OnClickQuickRecycleHandler()
	local equip_t = {}
	local cell_list = self.bag_grid:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	for k,v in pairs(data) do
		equip_t[#equip_t + 1] = v.series
	end
	if #equip_t > 0 then
		BagCtrl.EquipRecycle(self.scroll_tabbar:GetCurSelectIndex(), 0, equip_t,1)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Bag.NotEquip)
	end
end

function ExploreRecycleBagView:CreateTabbar()
	if self.scroll_tabbar ~= nil then return end

	self.scroll_tabbar = ScrollTabbar.New()
	self.scroll_tabbar:CreateWithNameList(self.node_t_list.scroll_tabbar_recycle.node, 12, 0,
		BindTool.Bind1(self.SelectTabCallback, self), ExploreData.Instance:GetRecycleBtnList(), 
		true, ResPath.GetCommon("btn_106_normal"), nil,nil, Str2C3b("fff999"), Str2C3b("bdaa93"))
	self:InitTabbarSelect()
end

function ExploreRecycleBagView:InitTabbarSelect()
	if self.scroll_tabbar then
		local index = 1
		local data = ExploreData.Instance:GetMinIndex()
		for i,v in ipairs(data) do
			if next(v) then
				index = i
				break
			end
		end
		if index >0 then
			self.scroll_tabbar:SelectIndex(index)
			self:SelectTabCallback(index)
			self.scroll_tabbar:ChangeToIndex(index)
		end
	end
end

function ExploreRecycleBagView:FlushTabbar()
	if self.scroll_tabbar == nil then return end

	for k, v in pairs(ExploreData.Instance:GetRecycleBtnList()) do
		local tabbar = self.scroll_tabbar:GetToggleByIndex(k)
		if tabbar:isVisible() then
			self:FlushCurTabbar(k)
		end
	end
end

function ExploreRecycleBagView:FlushCurTabbar(index)
	local equip_t = ExploreData.Instance:GetMinIndex()[index] or {}
	local  n = 0
	for k,v in pairs(equip_t) do
		n = n + 1
		break
	end
	if n > 0 then
		self.scroll_tabbar:SetNameByIndex(index, ExploreData.Instance:GetRecycleBtnList()[index] or "", COLOR3B.GREEN)
	else
		self.scroll_tabbar:SetNameByIndex(index, ExploreData.Instance:GetRecycleBtnList()[index] or "", COLOR3B.GRAY)
	end
end

function ExploreRecycleBagView:SelectTabCallback(index)
	-- if self.p_last_index then
	-- 	-- BagData.Instance:InitRecycleBagList(self.p_last_index)
	-- end
	self.p_last_index = index

	self:UpdateFilterBagItem()
	self:FlushItem()
end

function ExploreRecycleBagView:ItemDataListChangeCallback(change_type, item_id, item_index, series)
	if item_id ~= nil then
		local item_cfg = ItemData.Instance:GetItemConfig(item_id)
		local change_data = {change_type = change_type, item_id = item_id, item_index = item_index, series = series}
		if item_cfg then
			if ItemData.GetIsCanRecycle(item_id) or item_cfg.flags.godEquip == true then --物品变化
				self:Flush(0, "baglist_change", {[item_index or 999] = change_data})
			end
		end
	end
end

function ExploreRecycleBagView:SetShowPlayEff(effct_id, x, y)
	if self.play_effect == nil then
		self.play_effect = AnimateSprite:create()
		self.node_t_list.layout_explore_recycle.node:addChild(self.play_effect,999)
	end	
	self.play_effect:setPosition(x, y)
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effct_id)
	self.play_effect:setAnimate(anim_path, anim_name, 1, FrameTime.Effect, false)
end

