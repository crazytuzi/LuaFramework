BrowseView = BrowseView or BaseClass(SubView)

function BrowseView:__init()
	self:SetModal(true)
	-- self:SetBackRenderTexture(true)
	
	self.def_index = 1

	self.record_cur_index = 1

	self.config_tab = {
		
   		{"browse_ui_cfg", 3, {0}},
   		{"browse_ui_cfg", 5, {0}, false},
   		--{"browse_ui_cfg", 2, {0}},
	}

	self.texture_path_list = {
		"res/xui/role.png",
		"res/xui/equipbg.png",
		"res/xui/role_btn.png",
		'res/xui/guard_equip.png',
		'res/xui/mainui.png',
	}
	
end

function BrowseView:__delete()

end

function BrowseView:ReleaseCallBack()
	if self.role_info_widget then
		self.role_info_widget:DeleteMe()
		self.role_info_widget = nil
	end
	if self.equip_list then
		for k,v in pairs(self.equip_list) do
			v:DeleteMe()
		end
		self.equip_list = {}
	end
	if self.cell_list then
		for k,v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
	if self.slot_type then
		self.slot_type:DeleteMe()
		self.slot_type = nil
	end
end

function BrowseView:LoadCallBack(index, loaded_times)
	local content_size = self.root_node:getContentSize()
	self:CreateTopTitle()
	if loaded_times <= 1 then
		self:CreateRoleInfoWidget()
		self:CreateEquipCells()
		self:CreateEquipGrid()
		self:CreateRoleDisplay()
		self:CreateSlotType()
	end
	self.index = 1
	self:SetVis()
	self.page_index = 1
	self:SetBtnVis()
	self.node_t_list.layout_equip.node:setVisible(true)
	
	XUI.AddClickEventListener(self.node_t_list.luxury_equip_btn.node, BindTool.Bind1(self.openLuxEquip, self), true)
	XUI.AddClickEventListener(self.node_t_list.chuanshi_btn.node, BindTool.Bind1(self.openChuanshiEquip, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_guard_equip.node, BindTool.Bind1(self.openShouHuEquip, self), true)


	XUI.AddClickEventListener(self.node_t_list.btn_return.node, BindTool.Bind1(self.ReturnEquip, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_back.node, BindTool.Bind1(self.ReturnEquip, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_back1.node, BindTool.Bind1(self.ReturnEquip, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_left.node, BindTool.Bind1(self.MoveLeft, self), true)
	XUI.AddClickEventListener(self.node_t_list.btn_right.node, BindTool.Bind1(self.MoveRight, self), true)
	self.node_t_list.layout_btn_list.node:setLocalZOrder(9999)
	self.node_t_list.btn_return.node:setLocalZOrder(9999)
end


function BrowseView:CreateRoleDisplay( ... )
	self.role_display = RoleDisplay.New(self.node_t_list.layout_center1.node, - 1, false, false, true, true)
	
	self.role_display:SetPosition(self.node_t_list.layout_center1.node:getContentSize().width/2 , self.node_t_list.layout_center1.node:getContentSize().height/2 + 40)
	self.role_display:SetScale(0.8)

	
end

function BrowseView:openLuxEquip()
	self.index = 3
	self:SetVis()
end

function BrowseView:openChuanshiEquip()
	self.index = 2
	self:SetVis()
end


function BrowseView:ReturnEquip()
	self.index = 1
	self:SetVis()
end

function BrowseView:openShouHuEquip( ... )
	self.index = 4
	self:SetVis()
end

function BrowseView:SetVis( ... )
	self.node_t_list.layout_chuanshi.node:setVisible(self.index == 2)
	self.node_t_list.layout_lux_equip.node:setVisible(self.index == 3)
	self.node_t_list.layout_equip.node:setVisible(self.index == 1)
	self.node_t_list.layout_guard_equip.node:setVisible(self.index == 4)
end

-- BrowseView.EQUIP_POS = {
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownWeaponPos, row = 5, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_1")},	-- 武器
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownDressPos, row = 4, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_2")},	-- 衣服
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownHelmetPos, row = 5, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 头盔
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownNecklacePos, row = 4, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 项链
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownLeftBraceletPos, row = 3, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 手镯左
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownRightBraceletPos, row = 3, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 手镯右
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownLeftRingPos, row = 2, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 戒指左
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownRightRingPos, row = 2, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 戒指右
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownGirdlePos, row = 1, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_7")},	-- 腰带
-- 	{equip_slot = EquipData.EquipSlot.itHandedDownShoesPos, row = 1, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_8")},	-- 鞋子
-- }

BrowseView.EQUIP_POS = {

	[EquipData.EquipSlot.itWarmBloodDivineswordPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodDivineswordPos, cell_pos = 1,cell_img = ResPath.GetEquipImg("cs_bg_1"), decorate_img =ResPath.GetCommon("cell_120") },	-- 神兵
	[EquipData.EquipSlot.itWarmBloodGodNailPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodGodNailPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_2"), decorate_img =ResPath.GetCommon("cell_120")},	-- 神甲
		
	--战神装
	[EquipData.EquipSlot.itGodWarHelmetPos] = {equip_slot = EquipData.EquipSlot.itGodWarHelmetPos, cell_pos = 3,cell_img = ResPath.GetEquipImg("cs_bg_3"),decorate_img =ResPath.GetCommon("cell_120")},	-- 头盔
	[EquipData.EquipSlot.itGodWarNecklacePos] = {equip_slot = EquipData.EquipSlot.itGodWarNecklacePos, cell_pos = 4,cell_img = ResPath.GetEquipImg("cs_bg_4"),decorate_img =ResPath.GetCommon("cell_120")},	-- 项链
	[EquipData.EquipSlot.itGodWarLeftBraceletPos] = {equip_slot = EquipData.EquipSlot.itGodWarLeftBraceletPos, cell_pos = 5,cell_img = ResPath.GetEquipImg("cs_bg_5"),decorate_img =ResPath.GetCommon("cell_120")},	-- 左手
	[EquipData.EquipSlot.itGodWarRightBraceletPos] = {equip_slot = EquipData.EquipSlot.itGodWarRightBraceletPos, cell_pos = 6,cell_img = ResPath.GetEquipImg("cs_bg_5"),decorate_img =ResPath.GetCommon("cell_120")},	--右手
	[EquipData.EquipSlot.itGodWarLeftRingPos] = {equip_slot = EquipData.EquipSlot.itGodWarLeftRingPos, cell_pos = 7,cell_img = ResPath.GetEquipImg("cs_bg_6"),decorate_img =ResPath.GetCommon("cell_120")},	-- 左戒
	[EquipData.EquipSlot.itGodWarRightRingPos] = {equip_slot = EquipData.EquipSlot.itGodWarRightRingPos, cell_pos = 8,cell_img = ResPath.GetEquipImg("cs_bg_6"),decorate_img =ResPath.GetCommon("cell_120")},	-- 右戒
	[EquipData.EquipSlot.itGodWarGirdlePos] = {equip_slot = EquipData.EquipSlot.itGodWarGirdlePos, cell_pos = 9,cell_img = ResPath.GetEquipImg("cs_bg_7"),decorate_img =ResPath.GetCommon("cell_120")},	-- 腰带
	[EquipData.EquipSlot.itGodWarShoesPos] = {equip_slot = EquipData.EquipSlot.itGodWarShoesPos, cell_pos = 10,cell_img = ResPath.GetEquipImg("cs_bg_8"),decorate_img =ResPath.GetCommon("cell_120")},	-- 鞋子

	--杀神装备
	[EquipData.EquipSlot.itKillArrayShaPos] = {equip_slot = EquipData.EquipSlot.itKillArrayShaPos, cell_pos = 11,cell_img = ResPath.GetEquipImg("41"),decorate_img =ResPath.GetCommon("cell_120")},	-- 天煞
	[EquipData.EquipSlot.itKillArrayMostPos] = {equip_slot = EquipData.EquipSlot.itKillArrayMostPos, cell_pos = 12,cell_img = ResPath.GetEquipImg("42"),decorate_img =ResPath.GetCommon("cell_120")},	-- 天绝
	[EquipData.EquipSlot.itKillArrayRobberyPos] = {equip_slot = EquipData.EquipSlot.itKillArrayRobberyPos, cell_pos = 13,cell_img = ResPath.GetEquipImg("43"),decorate_img =ResPath.GetCommon("cell_120")},	-- 天劫
	[EquipData.EquipSlot.itKillArrayLifePos] = {equip_slot = EquipData.EquipSlot.itKillArrayLifePos, cell_pos = 14,cell_img = ResPath.GetEquipImg("44"),decorate_img =ResPath.GetCommon("cell_120")},	-- 天命
	
	--霸者装备
	[EquipData.EquipSlot.itWarmBloodElbowPadsPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodElbowPadsPos, cell_pos = 15,cell_img = ResPath.GetEquipImg("35"),decorate_img =ResPath.GetCommon("cell_121")},	-- 面甲
	[EquipData.EquipSlot.itWarmBloodShoulderPadsPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodShoulderPadsPos, cell_pos = 16,cell_img = ResPath.GetEquipImg("37"),decorate_img =ResPath.GetCommon("cell_121")},	-- 护肩
	[EquipData.EquipSlot.itWarmBloodPendantPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodPendantPos, cell_pos = 17,cell_img = ResPath.GetEquipImg("38"),decorate_img =ResPath.GetCommon("cell_121")},	-- 护膝
	[EquipData.EquipSlot.itWarmBloodKneecapPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodKneecapPos, cell_pos = 18,cell_img = ResPath.GetEquipImg("36"),decorate_img =ResPath.GetCommon("cell_121")},	-- 吊坠
	--[EquipData.EquipSlot.itHandedDownWeaponPos] = {equip_slot = EquipData.EquipSlot.itHandedDownWeaponPos, cell_pos = 1 cell_img = ResPath.GetEquipImg("cs_bg_1")},	-- 武器
	
}


-- 基础装备格子
function BrowseView:CreateEquipCells()
	self.equip_list = {}
	--local ChuanshiEquipRender = ChuanShiView.ChuanshiEquipRender
	--local container_size = self.node_t_list.layout_chuanshi.node:getContentSize()
	--local ph =
	for k, v in pairs(BrowseView.EQUIP_POS) do
		-- local x = (v.col == 1) and (50) or (container_size.width - 50)
		-- local y = (v.row - 1) * (5 + ChuanshiEquipRender.size.height) + 30
		local ph = self.ph_list["ph_item_"..(v.cell_pos)]
		local equip = ChuanShiCell.New()
		self.equip_list[v.equip_slot] = equip
		-- local bg_ta = ResPath.GetEquipImg(v.cell_img[1])
		-- local bg_ta2 = ResPath.GetEquipWord(v.cell_img[2])
		equip:SetPosition(ph.x, ph.y - 2)
		equip:SetItemIcon(v.cell_img)
		local data =BrowseData.Instance:GetEquipBySolt(v.equip_slot)
		equip:SetData(data)
		if data == nil then
			equip:SetItemIcon(v.cell_img)
		end
		equip:SetCellBg(ResPath.GetCommon("cell_120"))
		--equip:GetView():setAnchorPoint(0.5, 0.5)
		--XUI.AddClickEventListener(equip:GetView(), BindTool.Bind1(self.SelectCellCallBack, self), false)
		self.node_t_list.layout_chuanshi.node:addChild(equip:GetView(), 10)

		--equip:SetSelect(v.equip_slot == self.select_slot)
	end
end

--=豪装==-------
BrowseView.LuxuryEquipPos = BrowseView.LuxuryEquipPos or {
    { equip_slot = EquipData.EquipSlot.itSubmachineGunPos, cell_col = 3, cell_row = 4.1, },
    { equip_slot = EquipData.EquipSlot.itOpenCarPos, cell_col = 2.5, cell_row = 2, },
    { equip_slot = EquipData.EquipSlot.itAnCrownPos, cell_col = 1, cell_row = 6, },
    { equip_slot = EquipData.EquipSlot.itGoldenSkullPos, cell_col = 1, cell_row = 5, },
    { equip_slot = EquipData.EquipSlot.itGoldChainPos, cell_col = 1, cell_row = 4, },
    { equip_slot = EquipData.EquipSlot.itGoldPipePos, cell_col = 1, cell_row = 3, },
    { equip_slot = EquipData.EquipSlot.itGoldDicePos, cell_col = 1, cell_row = 2, },
    { equip_slot = EquipData.EquipSlot.itGlobeflowerPos, cell_col = 6, cell_row = 6, },
    { equip_slot = EquipData.EquipSlot.itJazzHatPos, cell_col = 6, cell_row = 5, },
    { equip_slot = EquipData.EquipSlot.itRolexPos, cell_col = 6, cell_row = 4, },
    { equip_slot = EquipData.EquipSlot.itDiamondRingPos, cell_col = 6, cell_row = 3, },
    { equip_slot = EquipData.EquipSlot.itGentlemenBootsPos, cell_col = 6, cell_row = 2, },
}

function BrowseView:CreateEquipGrid()
    local cell_size = cc.size(72, 72)
    local col_interval = 12
    local row_interval = 12
    local begin_x = 18
    local begin_y = 10
     self.cell_list = {}
    for k, v in pairs(BrowseView.LuxuryEquipPos) do
        local x = (v.cell_col - 1) * (cell_size.width + col_interval) + begin_x
        local y = (v.cell_row - 1) * (cell_size.height + row_interval)

        local cell = LuxuryEquipViewCell.New()
        cell:SetIndex(v.equip_slot)
        cell:GetView():setPosition(x, y)
        self.node_t_list.layout_lux_equip.node:addChild(cell:GetView(), 99)
        self.cell_list[k] = cell
        local  data = BrowseData.Instance:GetHowEquip(v.equip_slot)
        cell:SetData(data)
    end

end


function BrowseView:OpenCallBack()
	self.index = 1
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BrowseView:ShowIndexCallBack(index)
	self:Flush()
end

function BrowseView:CloseCallBack()
	AudioManager.Instance:PlayOpenCloseUiEffect()
end

function BrowseView:CreateRoleInfoWidget()
	local size = self.node_t_list.layout_equip.node:getContentSize()
	self.role_info_widget = RoleInfoView.New(EquipTip.FROME_BROWSE_ROLE)
	self.role_info_widget:SetFormView(EquipTip.FROME_BROWSE_ROLE)
	self.role_info_widget:SetRoleDisplayOffsetPos(cc.p(0, 20))
	local view_node = self.role_info_widget:CreateView()
	view_node:setPosition(size.width / 2, size.height / 2 - 5)
	self.node_t_list.layout_equip.node:addChild(view_node, 99)
end

function BrowseView:OnFlush(param_list, index)
	local role_vo = BrowseData.Instance:GetRoleInfo()
	self.role_info_widget:SetRoleVo(role_vo)

	-- 普通装备
	local equip_list = {}
	for _, equip in pairs(role_vo.equip_list) do
		local slot = EquipData.Instance:GetEquipSlotByType(equip.type, equip.hand_pos)
		equip_list[slot] = equip

		-- 强化等级
		equip.strengthen_level = role_vo.equip_slots[slot] or 0

		-- 宝石镶嵌
		local equip_inset_info = role_vo.stone_info[slot]
		if equip_inset_info then
			for index, v in pairs(equip_inset_info) do
				equip["slot_" .. index] = v
			end
		end

		-- 铸魂
		equip.slot_soul = role_vo.soul_info[slot] or 0

		-- 精炼
		equip.slot_apotheosis = role_vo.apotheosis_info[slot] or 0

		-- 神铸槽位
		equip.shenzhu_slot = ReXueGodEquipData.Instance:GetShenzhuSlotByEquipSlot(slot)
		-- 神铸等级
		equip.shenzhu_level = role_vo.all_shenzhu_data[equip.shenzhu_slot]
		-- 神格等级
		equip.shenge_level = role_vo.all_shenge_data[equip.shenzhu_slot]
	end
	
	-- 神炉装备
	for k, v in pairs(role_vo.godf_eq_levels) do
		GodFurnaceData.Instance:SetOtherVirtualEquipData(role_vo[OBJ_ATTR.ACTOR_PROF], k, v)
	end

	self.role_info_widget:SetGetEquipData(function(slot_data)
		if slot_data.equip_slot then
			return equip_list[slot_data.equip_slot]
		elseif slot_data.gf_equip_slot then
			return GodFurnaceData.Instance:GetOtherVirtualEquipData(slot_data.gf_equip_slot)
		end
		return nil
	end)

	----设置神器数据来源
	--self.role_info_widget.shenqi_cell:SetGetShenqiLevelFunc(function ()
	--	return role_vo.shenqi_level
	--end)
	--self.role_info_widget.shenqi_cell:SetGetShenqiEquipDataFunc(function ()
	--	return ShenqiData.Instance:GetOtherVirtualEquipData(role_vo)
	--end)

	self.role_info_widget:FlushEquipGrid()

	local role_vo = BrowseData.Instance:GetRoleInfo()
	self.role_display:SetRoleVo(role_vo)

   for k, v in pairs(BrowseView.LuxuryEquipPos) do
   		local  data = BrowseData.Instance:GetHowEquip(v.equip_slot)
   		 local cell = self.cell_list[k]
   		 if cell then
   		 	 cell:SetData(data)
   		 end
        
   end
   				
   -- local value = BrowseData.Instance:GetAttr(OBJ_ATTR.ACTOR_PRESTIGE_VALUE)
   -- local level = BrowseData.Instance:GetAttr(OBJ_ATTR.CREATURE_LEVEL)
   -- self.role_info_widget:SetValueShow(value, level)
end

function BrowseView:ItemConfigCallback(item_config_t)
	self:Flush()
end


--守护神装
function BrowseView:CreateSlotType()
	local ph = self.ph_list["ph_guard_equip_list"]
	local ph_item = ph
	local parent = self.node_t_list["layout_guard_equip"].node
	local base_grid = BaseGrid.New()
	base_grid:SetPageChangeCallBack(BindTool.Bind(self.OnPageChangeCallBack, self))
	self.slot_type = base_grid
	-- self:AddObj("slot_type")

	local table ={w = ph.w,h = ph.h, cell_count = 4, col = 1, row = 1, itemRender = self.GuardEquipItemBrowse, ui_config = ph_item}
	self.guard_type_item = base_grid:CreateCells(table)
	self.guard_type_item:setPosition(ph.x, ph.y)
	parent:addChild(self.guard_type_item, 2)

	local data = BrowseData.Instance:GetShouHuData()
	self.slot_type:SetDataList(data)
end


function BrowseView:OnPageChangeCallBack(grid_render, page_index, prve_page_index)
	self.page_index = page_index
end


function BrowseView:MoveLeft( ... )
	if self.page_index > 1 then
		self.page_index = self.page_index - 1
		self.slot_type:ChangeToPage(self.page_index)
	end
	self:SetBtnVis()
end

function BrowseView:MoveRight( ... )
	if self.page_index < 4 then
		self.page_index = self.page_index + 1
		self.slot_type:ChangeToPage(self.page_index)
	end
	self:SetBtnVis()
end


function BrowseView:SetBtnVis( )
	self.node_t_list.btn_left.node:setVisible(self.page_index ~= 1)
	self.node_t_list.btn_right.node:setVisible(self.page_index ~= 4)
end

--角色属性itemrender
BrowseRoleAttrItem = BrowseRoleAttrItem or BaseClass(BaseRender)
function BrowseRoleAttrItem:__init()

end

function BrowseRoleAttrItem:__delete()
	if self.cd_timer then
		GlobalTimerQuest:CancelQuest(self.cd_timer)
		self.cd_timer = nil
	end
end

function BrowseRoleAttrItem:OnFlush()
	if self.data == nil then return end
	local attr_value = 0
	local attr_v1, attr_v2 = 0, 0
	if type(self.data) == "table" then
		self.node_tree.lbl_attr_name.node:setString(Language.Role.AttrNameList[self.data[1]])
		attr_v1, attr_v2 = BrowseData.Instance:GetAttr(self.data[1]) or 0, BrowseData.Instance:GetAttr(self.data[2]) or 0
		if self.data[1] == OBJ_ATTR.CREATURE_HP or self.data[1] == OBJ_ATTR.CREATURE_MP or self.data[1] == OBJ_ATTR.ACTOR_INNER then
			attr_value = attr_v1 .. "/" .. attr_v2
			if nil == self.pro_bar then
				local size= self.node_tree.img9_bg.node:getContentSize()
				local bg = nil
				if self.data[1] == OBJ_ATTR.CREATURE_HP then
					bg = ResPath.GetRole("hp_loading")
				elseif self.data[1] == OBJ_ATTR.CREATURE_MP then
					bg = ResPath.GetRole("mp_loading")
				else
					bg = ResPath.GetRole("ng_loading")
				end
				self.pro_bar = XUI.CreateLoadingBar(size.width / 2, size.height / 2, bg)
				self.node_tree.img9_bg.node:addChild(self.pro_bar)			
			end
			self.pro_bar:setPercent(attr_v1 / attr_v2 * 100)
		else
			attr_value = attr_v1 .. "-" .. attr_v2
		end 
	else
		self.node_tree.lbl_attr_name.node:setString(Language.Role.AttrNameList[self.data])
		attr_value = BrowseData.Instance:GetAttr(self.data) or 0
		if self.data == OBJ_ATTR.ACTOR_DIERRFRESHCD then
			if attr_value == 0 then
				attr_value = TimeUtil.FormatSecond(0, 3)
			elseif attr_value > TimeCtrl.Instance:GetServerTime() then
				local cd_time = attr_value - TimeCtrl.Instance:GetServerTime()
				if self.cd_timer then
					GlobalTimerQuest:CancelQuest(self.cd_timer)
  					self.cd_timer = nil
				end
				self.cd_timer = GlobalTimerQuest:AddTimesTimer(BindTool.Bind1(self.UpdateBtnCd, self), 1, cd_time)
				attr_value = TimeUtil.FormatSecond(cd_time, 3)
			else
				attr_value = TimeUtil.FormatSecond(0, 3)
			end
		elseif self.data == OBJ_ATTR.ACTOR_CRITRATE 
				or self.data == OBJ_ATTR.ACTOR_RESISTANCECRITRATE 
				or self.data == OBJ_ATTR.ACTOR_BOSSCRITRATE then
				attr_value = string.format("%.2f", attr_value / 100) .. "%"
		elseif self.data == OBJ_ATTR.ACTOR_WARRIOR_DAMAGE_ADD or		
			   self.data == OBJ_ATTR.ACTOR_WARRIOR_DAMAGE_DEC or		
			   self.data == OBJ_ATTR.ACTOR_MAGICIAN_DAMAGE_ADD or		
			   self.data == OBJ_ATTR.ACTOR_MAGICIAN_DAMAGE_DEC or		
			   self.data == OBJ_ATTR.ACTOR_WIZARD_DAMAGE_ADD or		
			   self.data == OBJ_ATTR.ACTOR_WIZARD_DAMAGE_DEC then 
			attr_value = string.format("%.2f", attr_value / 100) .. "%"
		end
	end
	local show_pro_bar = type(self.data) == "table" and (self.data[1] == OBJ_ATTR.CREATURE_HP or self.data[1] == OBJ_ATTR.CREATURE_MP or self.data[1] == OBJ_ATTR.ACTOR_INNER)
	if self.pro_bar then
		self.pro_bar:setVisible(show_pro_bar)
	end
	self.node_tree.img9_bg.node:loadTexture(show_pro_bar and ResPath.GetCommon("img9_101") or ResPath.GetCommon("img9_100"))


	self.node_tree.lbl_attr_value.node:setString(attr_value)
end

function BrowseRoleAttrItem:UpdateBtnCd()
	local attr_value = BrowseData.Instance:GetAttr(self.data) or 0
	if attr_value - TimeCtrl.Instance:GetServerTime() > 0 then
		local show_str = TimeUtil.FormatSecond(attr_value - TimeCtrl.Instance:GetServerTime(), 3)
		self.node_tree.lbl_attr_value.node:setString(show_str)
	else
		self.node_tree.lbl_attr_value.node:setString(TimeUtil.FormatSecond(0, 3))
	end
end

function BrowseRoleAttrItem:CreateSelectEffect()
	-- body
end

ChuanShiCell = ChuanShiCell or BaseClass(BaseCell)
function ChuanShiCell:OnClick( ... )
	BaseRender.OnClick(self)
	if self.data == nil then
		return 
	end
	local  item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	local slot = EquipData.Instance:GetEquipSlotByType(item_cfg.type, self.data.hand_pos)
	TipCtrl.Instance:OpenItem(self.data, EquipTip.FROME_BROWSE_ROLE)
end


------------------------------------------------------------------------------------------------------------------------
LuxuryEquipViewCell = LuxuryEquipViewCell or BaseClass(BaseRender)

function LuxuryEquipViewCell:__init()

end

function LuxuryEquipViewCell:__delete()
    --if self.cell then
    --    self.cell:DeleteMe()
    --    self.cell = nil
    --end
end

function LuxuryEquipViewCell:CreateChild()
    --local ui_config = { bg = ResPath.GetCommon("cell_100"),
    --                    bg_ta = ResPath.GetRole("luxury_equip_cell_bg")}
    --self.cell = BaseCell.New()
    local bg = nil
    if EquipData.EquipSlot.itSubmachineGunPos == self.index then
        bg = XUI.CreateImageViewScale9(76,93, 152, 186, ResPath.GetCommon("cell_100"), true, cc.rect(10, 10, 10, 10))
    elseif EquipData.EquipSlot.itOpenCarPos == self.index then
        bg = XUI.CreateImageViewScale9(124,79, 248, 158, ResPath.GetCommon("cell_100"), true, cc.rect(10, 10, 10, 10))
    else
        bg = XUI.CreateImageView(BaseCell.SIZE / 2,BaseCell.SIZE / 2, ResPath.GetCommon("cell_100"))
    end
    self:SetContentSize(bg:getContentSize().width, bg:getContentSize().height)
    local bg2 = XUI.CreateImageView(self.view:getContentSize().width / 2,self.view:getContentSize().height / 2, ResPath.GetRole("luxury_equip_cell_bg"))
    self.view:addChild(bg)
    self.view:addChild(bg2)

    self:AddClickEventListener(BindTool.Bind(self.OnCellClick, self))
end

function LuxuryEquipViewCell:SetData(data)
    self.data = data
    self:Flush()
end

function LuxuryEquipViewCell:OnCellClick()
	if self.data == nil then
		return 
	end
   TipCtrl.Instance:OpenItem(self.data, EquipTip.BROWSE_FROM_HAO_EQUIP,{pos = self.index, item_id = self.data.item_id})
end

function LuxuryEquipViewCell:SetData(data)
    self.data = data
    self:Flush()
end
--function Cell:SetScaleX(scale)


function LuxuryEquipViewCell:OnFlush()
    local eff_id = 0
    if self.data then
        --self.cell:SetData(self.data)
        eff_id = EquipData.Instance:GetLuxuryEquipEffectId(self.data and self.data.item_id  or 0, self.index)
    end
    if eff_id > 0 and nil == self.item_effect then
        self.item_effect = RenderUnit.CreateEffect(eff_id, self:GetView(), 99, nil, nil,
                self.view:getContentSize().width / 2, self.view:getContentSize().height / 2 - 10)
        --CommonAction.ShowJumpAction(self.item_effect, 4, 1.5)
        self.item_effect:setScale(0.8)
        self.item_effect.SetAnimateRes = function(node, res_id)
            if nil ~= node.animate_res_id and node.animate_res_id == res_id then
                return
            end

            node.animate_res_id = res_id
            if res_id == 0 then
                node:setStop()
                return
            end

            local anim_path, anim_name = ResPath.GetEffectUiAnimPath(res_id)
            node:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
        end
    elseif nil ~= self.item_effect then
        self.item_effect:SetAnimateRes(eff_id)
        self.item_effect:setVisible(eff_id > 0)
    end
end


BrowseView.GuardEquipItemBrowse = BaseClass(BaseRender)
local GuardEquipItemBrowse = BrowseView.GuardEquipItemBrowse
function GuardEquipItemBrowse:__init()
	--self.item_cell = nil
end

function GuardEquipItemBrowse:__delete()
	if self.slot_list then
		for i,v in ipairs(self.slot_list) do
			v:DeleteMe()
		end
		self.slot_list = nil
	end

end

-- SlotItemBrowse坐标
local pos_list = {
	{{115, 405}, {80, 285}, {140, 110}, {195,230},{320, 175},{395, 75}, {415, 245},},
	{{25, 82}, {75, 212}, {170, 355}, {225, 255},{250, 135},{375, 225}, {335, 385},},
	{{110, 355}, {80, 230}, {85,80}, {165, 165},{255, 105},{270, 260}, {385, 120},},
	{{132, 395}, {155, 270}, {225, 170}, {240, 35},{330, 115},{350, 255}, {350, 390},},
	{{115, 250}, {160, 415}, {170, 130}, {200, 10}, {225, 315}, {310, 100}, {340, 210},},
	{{110, 255}, {160, 390}, {215, 50}, {260, 255}, {285, 395}, {300, 165}, {400, 230},},
}

local eff_pos_list = {{265, 269}, {288, 284}, {268, 274}, {295, 290},}

function GuardEquipItemBrowse:CreateChild()
	BaseRender.CreateChild(self)

	local index = self.index + 1

	local path = ResPath.GetBigPainting("guard_equip_bg_" .. index, true)
	self.node_tree["img_bg"].node:loadTexture(path)
	local path = ResPath.GetGuardEquip("guard_equip_type_" .. index)
	self.node_tree["img_type_name"].node:loadTexture(path)

	local effect_list = GuardGodEquipConfig and GuardGodEquipConfig.effect_id or {}
	local effect_id = effect_list and effect_list[self.index + 1] or 0
	local size = self.view:getContentSize()
	local eff = AnimateSprite:create()
	local anim_path, anim_name = ResPath.GetEffectUiAnimPath(effect_id)
	eff:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, 0.17, false)
	local pos = eff_pos_list[self.index + 1] or {268.5, 269.5}
	local x, y = pos[1], pos[2]
	eff:setPosition(x, y)
	self.view:addChild(eff, 1)
end

function GuardEquipItemBrowse:OnFlush()
	if nil == self.data then return end
	local index = self.index + 1

	if nil == self.slot_list then
		-- 创建槽位
		self.slot_list = {}
		local cfg = GuardGodEquipConfig or {}
		local max_slot = cfg.max_slot or 0
		for i = 1, max_slot do
			local pos = pos_list[index] and pos_list[index][i] or pos_list[1][i]
			local slot = self.SlotItemBrowse.New(index)
			slot:SetUiConfig(self.ph_list["ph_slot_item"], true)
			slot:SetPosition(pos[1], pos[2])
			slot:SetIndex(i)
			slot:AddClickEventListener(BindTool.Bind(self.SlotCallback, self))
			slot:SetData(self.data[i])
			self.view:addChild(slot:GetView(), 99)
			self.slot_list[i] = slot
		end
	else
		for i,v in ipairs(self.slot_list) do
			v:SetData(self.data[i] or {})
		end
	end

end

function GuardEquipItemBrowse:SlotCallback(slot)
	if slot == nil or slot:GetData() == nil then
		return
	end
	local data = slot:GetData()
	TipCtrl.Instance:OpenItem(data)
	-- local index = self.index + 1
	-- local remind_list = GuardEquipData.Instance:GetRemindIndexList()
	-- local remind_index = remind_list[index] and remind_list[index][slot]
	-- if remind_index then
	-- 	local item_id = remind_index
	-- 	local series = BagData.Instance:GetItemSeriesInBagById(item_id)
	-- 	GuardEquipCtrl.SendWearGuardEquipReq(series)
	-- end
end

function GuardEquipItemBrowse:FlushSlot(slot, equip)
	local slot_item = self.slot_list[slot]
	if slot_item then
		slot_item:SetData(equip)
	end
end

function GuardEquipItemBrowse:CreateSelectEffect()
	return
end

function GuardEquipItemBrowse:OnClick()
	if nil ~= self.click_callback then
		-- self.click_callback(self)
	end
end


GuardEquipItemBrowse.SlotItemBrowse = BaseClass(BaseRender)
local SlotItemBrowse = GuardEquipItemBrowse.SlotItemBrowse
function SlotItemBrowse:__init(type)
	self.type = type
	self.img_equip = nil
end

function SlotItemBrowse:__delete()
	if self.order then
		self.order:DeleteMe()
		self.order = nil
	end

	self.img_equip = nil
end

function SlotItemBrowse:CreateChild()
	BaseRender.CreateChild(self)

	local ph = self.ph_list["ph_order"]
	local path = ResPath.GetCommon("num_2_")
	local parent = parent
	local number_bar = NumberBar.New()
	number_bar:Create(ph.x, ph.y, ph.w, ph.h, path)
	number_bar:SetSpace(-8)
	number_bar:SetGravity(NumberBarGravity.Center)
	self.view:addChild(number_bar:GetView(), 99)
	self.order = number_bar

	self.node_tree["img_order"].node:setAnchorPoint(0, 0)

	--XUI.AddRemingTip(self.view, BindTool.Bind(self.FlushRemind, self), nil, 75, 90)
end

function SlotItemBrowse:OnFlush()

	if nil == self.data then 
		local phase =  0 -- 未装备时,显示0
		self.order:SetNumber(phase)
		local is_grey = phase == 0
		XUI.SetLayoutImgsGrey(self.view, is_grey)
		self.order:SetGrey(is_grey)

		local num_size = self.order:GetNumberBar():getContentSize()
		local view_size = self.order:GetView():getContentSize()
		local order_x, order_y = self.order:GetView():getPosition()
		local space = 2 -- 美术字"阶"和 order 的间隔
		local order_low_right_x = order_x + num_size.width / 2 + view_size.width / 2 -- order的右下角x坐标
		local x = order_low_right_x + space
		self.node_tree["img_order"].node:setPosition(x, order_y)

		local cfg = GuardGodEquipConfig or {}
		local max_slot = cfg.max_slot or 7
		local slot_index = (self.type - 1) * max_slot + self.index
		self.node_tree["lbl_slot_name"].node:setString(Language.GuardEquip.SlotName[slot_index] or "")
		return 
	end
	local phase = self.data.quality or 0 -- 未装备时,显示0
	self.order:SetNumber(phase)
	local is_grey = phase == 0
	XUI.SetLayoutImgsGrey(self.view, is_grey)
	self.order:SetGrey(is_grey)

	if self.data.item_id then
		local item_cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
		local icon_id = tonumber(item_cfg.icon)
		local path = ResPath.GetItem(icon_id)
		if self.img_equip then
			self.img_equip:loadTexture(path)
		else
			local x, y = self.node_tree["img_cell"].node:getPosition()
			local z = self.node_tree["img_cell"].node:getLocalZOrder()
			-- self.node_tree["img_cell"].node:loadTexture(path)
			self.img_equip = XUI.CreateImageView(x, y, path, XUI.IS_PLIST)
			self.img_equip:setScale(0.85)
			self.view:addChild(self.img_equip, z)
		end

		self.node_tree["img_cell"].node:setGrey(true)
	end

	----------------------------------------
	-- 调整 美术字"阶" 的坐标
	----------------------------------------
	local num_size = self.order:GetNumberBar():getContentSize()
	local view_size = self.order:GetView():getContentSize()
	local order_x, order_y = self.order:GetView():getPosition()
	local space = 2 -- 美术字"阶"和 order 的间隔
	local order_low_right_x = order_x + num_size.width / 2 + view_size.width / 2 -- order的右下角x坐标
	local x = order_low_right_x + space
	self.node_tree["img_order"].node:setPosition(x, order_y)
	----------------------------------------

	local cfg = GuardGodEquipConfig or {}
	local max_slot = cfg.max_slot or 7
	local slot_index = (self.type - 1) * max_slot + self.index
	self.node_tree["lbl_slot_name"].node:setString(Language.GuardEquip.SlotName[slot_index] or "")

	--self.view:UpdateReimd()
	--self.view.remind_img:setGrey(false)
end

-- function SlotItemBrowse:FlushRemind()
-- 	local remind_list = GuardEquipData.Instance:GetRemindIndexList()
-- 	local remind_index = remind_list[self.type] and remind_list[self.type][self.index] 
-- 	local vis = nil ~= remind_index
-- 	return vis
-- end

function SlotItemBrowse:CreateSelectEffect()
	return
end

return BrowseView