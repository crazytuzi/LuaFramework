
WeaponDecomposePage = WeaponDecomposePage or BaseClass()


function WeaponDecomposePage:__init()
	self.grid_list = nil
end	

function WeaponDecomposePage:__delete()
	self.view = nil
	self:RemoveEvent()
	if self.grid_list then
		self.grid_list:DeleteMe()
		self.grid_list = nil
	end
	if self.scroll_tabbar then
		self.scroll_tabbar:DeleteMe()
		self.scroll_tabbar = nil 
	end
end	


function WeaponDecomposePage:InitPage(view)

	self.view = view
	self:InitEvent()
	
end	


function WeaponDecomposePage:InitEvent()
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
	GodWeaponEtremeData.Instance:InitGodEquipWeaponBagList(index)
	self:CreateScorllTabbar()
	self.itemdata_change_callback = BindTool.Bind1(self.OnItemChangBack, self)
	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	XUI.AddClickEventListener(self.view.node_t_list.layout_godWeapon_decompose["btn_quick_recycle"].node, BindTool.Bind(self.FenjieWeaponEquip, self), true)
	self.view.node_t_list.layout_godWeapon_decompose["btn_fenjie_weapon"].node:addClickEventListener(BindTool.Bind(self.OpenGodWeaponFenJieTip, self))
end


function WeaponDecomposePage:RemoveEvent()
	if self.itemdata_change_callback then
		ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
		self.itemdata_change_callback = nil 
	end
end

function WeaponDecomposePage:OnItemChangBack()
	GodWeaponEtremeData.Instance:InitGodEquipWeaponBagList(index)
	self.grid_list:SetDataList(GodWeaponEtremeData.Instance:GetWeaponList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
	self:FlushCurTabbar(self.scroll_tabbar:GetCurSelectIndex())
	self:FlushItem()
end


function WeaponDecomposePage:UpdateData(data)

	local prof = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF)
	self:SetCheckBoxStatus("prof_1", prof ~= 1)
	self:SetCheckBoxStatus("prof_2", prof ~= 2)
	self:SetCheckBoxStatus("prof_3", prof ~= 3)
	self:UpdateFilterBagItem()
	self:BoolShowBtn()
	self:FlushTabbar()
	self:SelectTabCallback(1)
end	

function WeaponDecomposePage:CreateScorllTabbar()
	if self.scroll_tabbar == nil then 
		self.scroll_tabbar = ScrollTabbar.New()
		self.scroll_tabbar:CreateWithNameList(self.view.node_t_list.layout_godWeapon_decompose.scroll_tabbar.node, 36, -10,
			BindTool.Bind1(self.SelectTabCallback, self), GodWeaponEtremeData.Instance:GetDecomposeBtnList(), 
			true, ResPath.GetCommon("btn_106_normal"))
		self.scroll_tabbar:SelectIndex(1)
		self.scroll_tabbar:ChangeToIndex(1)
		self:SelectTabCallback(1)
	end
end

function WeaponDecomposePage:SelectTabCallback(index)
	if self.p_last_index then
		--GodWeaponEtremeData.Instance:InitGodEquipWeaponBagList(index)
	end
	self.p_last_index = index
	self:UpdateFilterBagItem()
	self:FlushItem()
end

function WeaponDecomposePage:CreateGridCells()
	if self.grid_list == nil then
		self.grid_list = BaseGrid.New()
		self.grid_list:SetGridName(GRID_TYPE_RECYCLE_BAG)
		self.grid_list:SetPageChangeCallBack(BindTool.Bind1(self.OnBagPageChange, self))
		local ph_baggrid = self.view.ph_list.ph_god_wapon_list
		local grid_node = self.grid_list:CreateCells({w=ph_baggrid.w, h=ph_baggrid.h, cell_count = 75, col=6, row=2, itemRender = WeaponDecomposeRender, direction = ScrollDir.Horizontal })
		grid_node:setAnchorPoint(0, 0)
		self.view.node_t_list.layout_godWeapon_decompose.node:addChild(grid_node, 100)
		grid_node:setPosition(ph_baggrid.x, ph_baggrid.y)
		self.grid_list:SetIsMultiSelect(true)
		self.grid_list:SetSelectCallBack(BindTool.Bind1(self.SelectCellCallBack, self))
	end
end

function WeaponDecomposePage:OnBagPageChange(grid_view, cur_page_index, prve_page_index)
	self.page_index = cur_page_index
	self:BoolShowBtn()
end

function WeaponDecomposePage:BoolShowBtn()
	self.view.node_t_list.btn_left_weapon.node:setVisible(self.page_index ~= 1)
	self.view.node_t_list.btn_right_weapon.node:setVisible(self.page_index ~= 7)
end


function WeaponDecomposePage:UpdateFilterBagItem()
	--GodWeaponEtremeData.Instance:InitGodEquipList()
	self.grid_list:SetDataList(GodWeaponEtremeData.Instance:GetWeaponList()[self.scroll_tabbar:GetCurSelectIndex()] or {})
end	

function WeaponDecomposePage:SelectCellCallBack(cell)
	if cell == nil then return end
	self:FlushRigthtData()
end

function WeaponDecomposePage:CreateBox()
	local check_node_list = {
								self.view.node_t_list.layout_godWeapon_decompose.layout_select_prof.node,
								self.view.node_t_list.layout_godWeapon_decompose.layout_select_prof_2.node,
								self.view.node_t_list.layout_godWeapon_decompose.layout_select_prof_3.node,
							}
	for i = 1, 3 do
		self:CreateCheckBox("prof_" .. i, check_node_list[i])
	end
end

function WeaponDecomposePage:CreateCheckBox(key, node)
	self.check_box_list = self.check_box_list or {}
	self.check_box_list[key] = {}
	self.check_box_list[key].status = self.check_box_state_list[key]
	self.check_box_list[key].node = XUI.CreateImageView(30, 30, ResPath.GetCommon("bg_checkbox_hook"), true)
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	node:addChild(self.check_box_list[key].node, 10)
	XUI.AddClickEventListener(node, BindTool.Bind2(self.OnClickSelectBoxHandler, self, key), true)
end

function WeaponDecomposePage:OnClickSelectBoxHandler(key)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = not self.check_box_list[key].status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
	self.check_box_state_list[key] = self.check_box_list[key].status
	self:FlushItem()
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function WeaponDecomposePage:SetCheckBoxStatus(key, status)
	if self.check_box_list == nil or self.check_box_list[key] == nil then return end

	self.check_box_list[key].status = status
	self.check_box_list[key].node:setVisible(self.check_box_list[key].status)
end

function WeaponDecomposePage:FlushItem()
	local prof_check_1 = self.check_box_list["prof_1"].status
	local prof_check_2 = self.check_box_list["prof_2"].status
	local prof_check_3 = self.check_box_list["prof_3"].status
	local select_list_0 = {}
	local select_list_1 = {}
	local select_list_2 = {}
	local select_list_3 = {}
	for k, v in pairs(GodWeaponEtremeData.Instance:GetWeaponList()[self.scroll_tabbar:GetCurSelectIndex()] or {}) do
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
				if v_2.value == 0 then
					select_list_0[k] = v
				end
			end
		end
	end

	for k,v in pairs(select_list_0) do
		self.grid_list:CancleSelectCellByIndex(k)
		
		self.grid_list:SelectCellByIndex(k)
		
	end
	for k, v in pairs(select_list_3) do
		self.grid_list:CancleSelectCellByIndex(k)
		if prof_check_3 then
			self.grid_list:SelectCellByIndex(k)
		end
	end

	for k, v in pairs(select_list_2) do
		self.grid_list:CancleSelectCellByIndex(k)
		if prof_check_2 then
			self.grid_list:SelectCellByIndex(k)
		end
	end

	for k,v in pairs(select_list_1) do
		self.grid_list:CancleSelectCellByIndex(k)
		if prof_check_1 then
			self.grid_list:SelectCellByIndex(k)		
		end
	end
	self:FlushRigthtData()
end
end

function WeaponDecomposePage:FlushRigthtData()
	local cell_list = self.grid_list:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	local name = self.scroll_tabbar:GetCurSelectIndex() == 1 and Language.GodWeapon.TextShowName[1] or Language.GodWeapon.TextShowName[2]
	self.view.node_t_list.txt_suipian_wapon.node:setString(name)
	local index = self.scroll_tabbar:GetCurSelectIndex() == 1 and GODWEAPONETREMEDATA_TYPE.WEAPON or GODWEAPONETREMEDATA_TYPE.FASHION
	local recyecle_num = GodWeaponEtremeData.Instance:GetDecomposeNum(data, index)
	self.view.node_t_list.exp_num_weapon.node:setString(recyecle_num)
end

function WeaponDecomposePage:MoveLeft()
	if self.page_index > 1 then
		self.page_index = self.page_index - 1
		self.grid_list:ChangeToPage(self.page_index)
	end
end

function WeaponDecomposePage:MoveRight()
	if self.page_index < 7  then
		self.page_index = self.page_index + 1
		self.grid_list:ChangeToPage(self.page_index)
	end
end
function WeaponDecomposePage:OpenGodWeaponFenJieTip()
	DescTip.Instance:SetContent(Language.GodWeapon.GodWeaponDecomposeContent, Language.GodWeapon.GodWeaponDecomposeTip)
end

function WeaponDecomposePage:FenjieWeaponEquip()
	local equip_t = {}
	local cell_list = self.grid_list:GetMultiSelectCell()
	local data = {}
	for k, v in pairs(cell_list) do
		data[k] = v:GetData()
	end
	for k,v in pairs(data) do
		equip_t[#equip_t + 1] = v.series
	end

	local recycletype = self.scroll_tabbar:GetCurSelectIndex() == 1 and 3 or 4

	if #equip_t > 0 then
		BagCtrl.EquipRecycle(self.scroll_tabbar:GetCurSelectIndex(), recycletype, equip_t,0)
	else
		SysMsgCtrl.Instance:FloatingTopRightText(Language.Bag.NotEquip)
	end
	AudioManager.Instance:PlayClickBtnSoundEffect()
end

function WeaponDecomposePage:FlushTabbar()
	if self.scroll_tabbar == nil then return end

	for k, v in pairs(GodWeaponEtremeData.Instance:GetDecomposeBtnList()) do
		self:FlushCurTabbar(k)
	end
end

function WeaponDecomposePage:FlushCurTabbar(index)
	if self.scroll_tabbar ~= nil then
		local equip_t = GodWeaponEtremeData.Instance:GetWeaponList()[index] or {}

		local  n = 0
		for k,v in pairs(equip_t) do
			n = n + 1
		end

		if n > 0 then
			self.scroll_tabbar:SetNameByIndex(index, GodWeaponEtremeData.Instance:GetDecomposeBtnList()[index] or "", COLOR3B.WHITE)
		else
			self.scroll_tabbar:SetNameByIndex(index, GodWeaponEtremeData.Instance:GetDecomposeBtnList()[index] or "", COLOR3B.GRAY)
		end	
	end
end


WeaponDecomposeRender = WeaponDecomposeRender or BaseClass(BaseCell)
function WeaponDecomposeRender:__init()
	self.view:setTouchEnabled(true)
	self.view:setIsHittedScale(false)
	self.view:addTouchEventListener(BindTool.Bind(self.OnTouchCellLayout, self))
	self.is_long_click = false
end

function WeaponDecomposeRender:__delete()
	if self.delay_flush_time ~= nil  then
		GlobalTimerQuest:CancelQuest(self.delay_flush_time)
		self.delay_flush_time = nil
	end
end

function WeaponDecomposeRender:OnClick()
end

function WeaponDecomposeRender:OnTouchCellLayout(sender, event_type, touch)
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

function WeaponDecomposeRender:CreateSelectEffect()
	local size = self.view:getContentSize()
	self.select_effect = XUI.CreateImageView(BaseCell.SIZE / 2 + 7, BaseCell.SIZE / 2, 
		ResPath.GetCommon("base_cell_bg_3"), true)
	if nil == self.select_effect then
		ErrorLog("BaseCell:CreateSelectEffect fail")
		return
	end
	self.view:addChild(self.select_effect, 999, 999)
end