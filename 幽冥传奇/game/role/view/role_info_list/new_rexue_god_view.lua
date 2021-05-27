 local NewReXueGodView  = BaseClass(SubView)
function NewReXueGodView:__init( ... )
	self.texture_path_list = {
		'res/xui/equipbg.png',
		'res/xui/rexue.png',
	}
	self.is_modal = true
	self.config_tab = {
		--{"chuanshi_ui_cfg", 1, {0}},
		{"role1_ui_cfg", 3, {0}},
		{"role1_ui_cfg", 8, {0}},
		{"role1_ui_cfg", 9, {0}},
	}
end

function NewReXueGodView:__delete( ... )
	-- body
end


function NewReXueGodView:ReleaseCallBack( ... )
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
	if self.cell_list then
		for k, v in pairs(self.cell_list) do
			v:DeleteMe()
		end
		self.cell_list = {}
	end

	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	if self.skill_cell then
		self.skill_cell:DeleteMe()
		self.skill_cell = nil
	end
	if self.skill_cell1 then
		self.skill_cell1:DeleteMe()
		self.skill_cell1 = nil
	end
	self.rich_content = nil  
end

function NewReXueGodView:LoadCallBack( ... )
	self.node_t_list.img_hz_red.node:setVisible(false)
	
	if self.role_display == nil  then
		self.role_display = RoleDisplay.New(self.node_t_list.layout_center.node, - 1, false, false, true, true)
		
		self.role_display:SetPosition(self.node_t_list.layout_center.node:getContentSize().width/2 , self.node_t_list.layout_center.node:getContentSize().height/2 + 25)
		self.role_display:SetScale(0.8)
		
	end
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	self:UpdateApperance()
	self:CreateEquipCell()
	XUI.AddClickEventListener(self.node_t_list.return_equip_btn.node,BindTool.Bind1(self.OpenRoleInfo, self))
	XUI.AddClickEventListener(self.node_t_list.btn_back_pu_tong.node,BindTool.Bind1(self.OpenPuTong, self))

	XUI.AddClickEventListener(self.node_t_list.layout_check.node,BindTool.Bind1(self.OnCheckWeapon, self))
	XUI.AddClickEventListener(self.node_t_list.layout_check1.node,BindTool.Bind1(self.OnCheckFashion, self))
	self.node_t_list.return_equip_btn.node:setVisible(false)
	self.node_t_list.btn_back_pu_tong.node:setVisible(false)
	self:SetBtnVis()
	self:ChangeState()
	self:CreateSkillCell()
	
end

function NewReXueGodView:OpenPuTong()
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList)
end

function NewReXueGodView:OnRemindGroupChange(group_name, num)
	self.node_t_list.img_hz_red.node:setVisible(RemindManager.Instance:GetRemindGroup(ViewDef.Role.RoleInfoList.LuxuryEquip.remind_group_name) > 0)
end

function NewReXueGodView:OnCheckWeapon()
	local flag = self.node_t_list.img_checkBox.node:isVisible() and 1 or 0
	self.node_t_list.img_checkBox.node:setVisible(flag == 0)
	self.set_flag[33 -1] = flag
	local data = bit:b2d(self.set_flag)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.APPEAR_SAVE, data)
end

function NewReXueGodView:OnCheckFashion()
	local flag = self.node_t_list.img_checkBox1.node:isVisible() and 1 or 0
	self.node_t_list.img_checkBox1.node:setVisible(flag == 0)
	self.set_flag[33 -2] = flag
	local data = bit:b2d(self.set_flag)
	SettingCtrl.Instance:SendChangeHotkeyReq(HOT_KEY.APPEAR_SAVE, data)
end

function NewReXueGodView:ChangeState(data)

	local data =  SettingData.Instance:GetDataByIndex(HOT_KEY.APPEAR_SAVE)
	local set_flag_t = bit:d2b(data)
	self.set_flag = set_flag_t
	local data = {}
	for i = 1, #set_flag_t do
		data[i] =  set_flag_t[33 - i]
	end
	local flag = data[2]
	local flag1 = data[1] 
	self.node_t_list.img_checkBox1.node:setVisible(flag == 0)
	self.node_t_list.img_checkBox.node:setVisible(flag1 == 0)
end

function NewReXueGodView:OpenRoleInfo( ... )
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.LuxuryEquip)
end

function NewReXueGodView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ENTITY_MODEL_ID or vo.key == OBJ_ATTR.ACTOR_WEAPON_APPEARANCE or vo.key == OBJ_ATTR.ACTOR_WING_APPEARANCE  or vo.key == OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE or
		vo.key == OBJ_ATTR.ACTOR_FOOT_APPEARANCE then
		self:UpdateApperance()
	elseif vo.key == OBJ_ATTR.ACTOR_CIRCLE or vo.key == OBJ_ATTR.CREATURE_LEVEL then
		self:FlushRemind()
		self:SetBtnVis()
	end
end


function NewReXueGodView:SetBtnVis( )

	local vis = ViewManager.Instance:CanOpen(ViewDef.Role.RoleInfoList.LuxuryEquip)
	self.node_t_list.return_equip_btn.node:setVisible(vis)
	self.node_t_list.btn_back_pu_tong.node:setVisible(not vis)
end


function NewReXueGodView:UpdateApperance( ... )
	if nil ~= self.role_display then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()

		self.role_display:SetRoleVo(role_vo)
	end
end

NewReXueGodView.EQUIP_POS = {

	[EquipData.EquipSlot.itWarmBloodDivineswordPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodDivineswordPos, cell_pos = 1,cell_img = ResPath.GetEquipImg("cs_bg_1"),  open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =1},	-- 神兵
	[EquipData.EquipSlot.itWarmBloodGodNailPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodGodNailPos, cell_pos = 2,cell_img = ResPath.GetEquipImg("cs_bg_2"), open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =1},	-- 神甲
		
	--战神装
	[EquipData.EquipSlot.itGodWarHelmetPos] = {equip_slot = EquipData.EquipSlot.itGodWarHelmetPos, cell_pos = 3,cell_img = ResPath.GetEquipImg("cs_bg_3"),open_view = ViewDef.MainGodEquipView.RexueGodEquip,open_index =3},	-- 头盔
	[EquipData.EquipSlot.itGodWarNecklacePos] = {equip_slot = EquipData.EquipSlot.itGodWarNecklacePos, cell_pos = 4,cell_img = ResPath.GetEquipImg("cs_bg_4"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =3},	-- 项链
	[EquipData.EquipSlot.itGodWarLeftBraceletPos] = {equip_slot = EquipData.EquipSlot.itGodWarLeftBraceletPos, cell_pos = 5,cell_img = ResPath.GetEquipImg("cs_bg_5"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =3},	-- 左手
	[EquipData.EquipSlot.itGodWarRightBraceletPos] = {equip_slot = EquipData.EquipSlot.itGodWarRightBraceletPos, cell_pos = 6,cell_img = ResPath.GetEquipImg("cs_bg_5"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =3},	--右手
	[EquipData.EquipSlot.itGodWarLeftRingPos] = {equip_slot = EquipData.EquipSlot.itGodWarLeftRingPos, cell_pos = 7,cell_img = ResPath.GetEquipImg("cs_bg_6"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =3},	-- 左戒
	[EquipData.EquipSlot.itGodWarRightRingPos] = {equip_slot = EquipData.EquipSlot.itGodWarRightRingPos, cell_pos = 8,cell_img = ResPath.GetEquipImg("cs_bg_6"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =3},	-- 右戒
	[EquipData.EquipSlot.itGodWarGirdlePos] = {equip_slot = EquipData.EquipSlot.itGodWarGirdlePos, cell_pos = 9,cell_img = ResPath.GetEquipImg("cs_bg_7"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =3},	-- 腰带
	[EquipData.EquipSlot.itGodWarShoesPos] = {equip_slot = EquipData.EquipSlot.itGodWarShoesPos, cell_pos = 10,cell_img = ResPath.GetEquipImg("cs_bg_8"),open_view = ViewDef.MainGodEquipView.RexueGodEquip,open_index =3},	-- 鞋子

	--杀神装备
	[EquipData.EquipSlot.itKillArrayShaPos] = {equip_slot = EquipData.EquipSlot.itKillArrayShaPos, cell_pos = 11,cell_img = ResPath.GetEquipImg("41"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =4},	-- 天煞
	[EquipData.EquipSlot.itKillArrayMostPos] = {equip_slot = EquipData.EquipSlot.itKillArrayMostPos, cell_pos = 12,cell_img = ResPath.GetEquipImg("42"),open_view = ViewDef.MainGodEquipView.RexueGodEquip,open_index =4},	-- 天绝
	[EquipData.EquipSlot.itKillArrayRobberyPos] = {equip_slot = EquipData.EquipSlot.itKillArrayRobberyPos, cell_pos = 13,cell_img = ResPath.GetEquipImg("43"),open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =4},	-- 天劫
	[EquipData.EquipSlot.itKillArrayLifePos] = {equip_slot = EquipData.EquipSlot.itKillArrayLifePos, cell_pos = 14,cell_img = ResPath.GetEquipImg("44"),open_view = ViewDef.MainGodEquipView.RexueGodEquip,open_index =4},	-- 天命
	
	--霸者装备decorate_img =ResPath.GetCommon("cell_121")},	-- 面甲
	[EquipData.EquipSlot.itWarmBloodElbowPadsPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodElbowPadsPos, cell_pos = 15,cell_img = ResPath.GetEquipImg("35"), open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =2},	-- 面甲
	[EquipData.EquipSlot.itWarmBloodShoulderPadsPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodShoulderPadsPos, cell_pos = 16,cell_img = ResPath.GetEquipImg("37"), open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =2},	-- 护肩
	[EquipData.EquipSlot.itWarmBloodPendantPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodPendantPos, cell_pos = 17,cell_img = ResPath.GetEquipImg("36"), open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =2},	-- 护膝
	[EquipData.EquipSlot.itWarmBloodKneecapPos] = {equip_slot = EquipData.EquipSlot.itWarmBloodKneecapPos, cell_pos = 18,cell_img = ResPath.GetEquipImg("38"), open_view = ViewDef.MainGodEquipView.RexueGodEquip, open_index =2},	-- 吊坠
	--[EquipData.EquipSlot.itHandedDownWeaponPos] = {equip_slot = EquipData.EquipSlot.itHandedDownWeaponPos, cell_pos = 1 cell_img = ResPath.GetEquipImg("cs_bg_1")},	-- 武器
	
}

function NewReXueGodView:CreateSkillCell( ... )
	local ph = self.ph_list.ph_skill_1
	if self.skill_cell == nil then
		self.skill_cell = NewRexueSkillCell.New()
		self.node_t_list.layout_skill_1.node:addChild(self.skill_cell:GetView(), 99)
		self.skill_cell:GetView():setPosition(ph.x, ph.y)
		XUI.AddClickEventListener(self.skill_cell:GetView(), BindTool.Bind1(self.OpenSkillTip1, self))
	end

	local ph = self.ph_list.ph_skill_2
	if self.skill_cell1 == nil then
		self.skill_cell1 = NewRexueSkillCell.New()
		self.node_t_list.layout_skill_2.node:addChild(self.skill_cell1:GetView(), 99)
		self.skill_cell1:GetView():setPosition(ph.x, ph.y)
		XUI.AddClickEventListener(self.skill_cell1:GetView(), BindTool.Bind1(self.OpenSkillTip2, self))
	end
end

function NewReXueGodView:OpenSkillTip1(index)

	local skill_id = 0
	local skill_level = 0
	local suit_type = 0
	local suitlevel = 0
	skill_id = SuitPlusConfig[10].list[1].skillid
	skill_level =  0
	suit_type = 10
	suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
	if suitlevel > 0 then
		skill_id = SuitPlusConfig[10].list[suitlevel].skillid
		skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
		
	end
	TipCtrl.Instance:OpenTipSkill(skill_id, skill_level, suit_type, suitlevel)
end


function NewReXueGodView:OpenSkillTip2( ... )
	local skill_id = SuitPlusConfig[11].list[1].skillid
	local skill_level =  0
	local suit_type = 11
	local suitlevel = EquipData.Instance:GetBazheLevel()
	if suitlevel > 0 then
		skill_id = SuitPlusConfig[11].list[suitlevel].skillid
		skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
	end
	TipCtrl.Instance:OpenTipSkill(skill_id, skill_level, suit_type, suitlevel)
end



function NewReXueGodView:CreateEquipCell( ... )
	self.equip_list = {}
	local NewGodEquipReXueRender = NewReXueGodView.NewGodEquipReXueRender
	--local container_size = self.node_t_list.layout_role_equip.node:getContentSize()
	--local ph =
	for k, v in pairs(NewReXueGodView.EQUIP_POS) do
		-- local x = (v.col == 1) and (50) or (container_size.width - 50)
		-- local y = (v.row - 1) * (5 + ChuanshiEquipRender.size.height) + 30
		if v.cell_pos then
			local ph = self.ph_list["ph_item_"..(v.cell_pos)]
			local equip = NewGodEquipReXueRender.New()
			self.equip_list[v.equip_slot] = equip
			-- local bg_ta = ResPath.GetEquipImg(v.cell_img[1])
			-- local bg_ta2 = ResPath.GetEquipWord(v.cell_img[2])
			equip:SetPosition(ph.x, ph.y - 2)
			--equip:SetItemIcon(v.cell_img)
			equip:SetData(v)
			--equip:GetView():setAnchorPoint(0.5, 0.5)
			equip:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
			self.node_t_list.layout_role_equip.node:addChild(equip:GetView(), 10)
		end
		--equip:SetSelect(v.equip_slot == self.select_slot)
	end
end

local slot2handPos = {
	[EquipData.EquipSlot.itGodWarLeftBraceletPos] = 0,	-- 传世_左手镯
    [EquipData.EquipSlot.itGodWarRightBraceletPos] = 1,	-- 传世_右手镯
    [EquipData.EquipSlot.itGodWarLeftRingPos] = 0,	-- 传世_左戒指
    [EquipData.EquipSlot.itGodWarRightRingPos] = 1,	-- 传世_右戒指
}

function NewReXueGodView:SelectCellCallBack(cell)
	if cell == nil or cell:GetData() == nil then
		return
	end

	local slot = cell:GetData().equip_slot
	local equip =  EquipData.Instance:GetEquipDataBySolt(slot)
	local equip_data  = ReXueGodEquipData.Instance:SetReXueCanBestData(slot)
	if equip_data then
		 -- EquipCtrl.Instance:FitOutEquip(item_data, slot2handPos[slot] or 0)
		EquipCtrl.SendFitOutEquip(equip_data.series, slot2handPos[slot])
	else
		if equip then
			TipCtrl.Instance:OpenItem(equip, EquipTip.FROM_ROlE_NEWREXUE_EQUIP)
		else
			if ViewManager.Instance:CanOpen(ViewDef.MainGodEquipView) then
				ViewManager.Instance:OpenViewByDef(ViewDef.MainGodEquipView)
				--ViewManager.Instance:OpenViewByDef(cell:GetData().open_view)
				ViewManager.Instance:FlushViewByDef(ViewDef.MainGodEquipView, 0, "tabbar_change", {index =1, child_index =cell:GetData().open_index})
				--GlobalEventSystem:Fire(OPEN_VIEW_EVENT.REXUEEVENTBTN,  {index =3, child_index =2})
			else
				SysMsgCtrl.Instance:FloatingTopRightText(GameCond[ViewDef.MainGodEquipView.v_open_cond].Tip or "策划需在cond配置")
			end
		end 
	end
end

function NewReXueGodView:OnChangeOneEquip(data)
	if self.equip_list[data.slot] then
		local rexue_data = NewReXueGodView.EQUIP_POS[data.slot]
		self.equip_list[data.slot]:SetData(rexue_data)
	end
	if self.delay_timer then
		GlobalTimerQuest:CancelQuest(self.delay_timer)
		self.delay_timer = nil
	end
	self.delay_timer = GlobalTimerQuest:AddDelayTimer(function ( ... )
			self:FlushRemind()
			self:SetSkillShow()

			if self.delay_timer then
				GlobalTimerQuest:CancelQuest(self.delay_timer)
				self.delay_timer = nil
			end
	end, 0.2)
	
end


function NewReXueGodView:SetSkillShow( ... )
	
	local	skill_id = SuitPlusConfig[10].list[1].skillid
	local	skill_level =  1
	local	 suitlevel = EquipData.Instance:GetZhiZunSuitLevel()
	local bool = false
	local is_show = "未激活"
	if suitlevel > 0 then
		skill_id = SuitPlusConfig[10].list[suitlevel].skillid
		skill_level =  SuitPlusConfig[10].list[suitlevel].skillLv
		bool = true
		is_show = "已激活"
	end
	local path = ResPath.GetSkillIcon("2000_1")
	self.skill_cell:SetItemIcon(path)
	self.skill_cell:MakeGray(not bool)
	local color = bool and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list.text_had_jihuo1.node:setString(is_show)
	self.node_t_list.text_had_jihuo1.node:setColor(color)
	
	local lv_cfg = SkillData.GetSkillLvCfg(skill_id, skill_level)
	local desc = lv_cfg.desc or ""
	RichTextUtil.ParseRichText(self.node_t_list.text_desc1.node,desc, 16)

	local name = "焚天灭地".."   " .. "LV."..skill_level
	self.node_t_list.text_skill_name1.node:setString(name)

	local	skill_id = SuitPlusConfig[11].list[1].skillid
	local	skill_level =  1
	local	suitlevel = EquipData.Instance:GetBazheLevel()
	local bool = false
	local is_show = "未激活"
	if suitlevel > 0 then
		skill_id = SuitPlusConfig[11].list[suitlevel].skillid
		skill_level =  SuitPlusConfig[11].list[suitlevel].skillLv
		bool = true
		is_show = "已激活"
	end
	local path = ResPath.GetSkillIcon("2001_1")
	self.skill_cell1:SetItemIcon(path)
	self.skill_cell1:MakeGray(not bool)
	local lv_cfg = SkillData.GetSkillLvCfg(skill_id, skill_level)
	local desc = lv_cfg.desc or ""
	local name = "霸者龙气".."   " .. "LV."..skill_level
	self.node_t_list.text_skill_name2.node:setString(name)
	RichTextUtil.ParseRichText(self.node_t_list.text_desc2.node,desc, 16)
	local color = bool and COLOR3B.GREEN or COLOR3B.RED
	self.node_t_list.text_had_jihuo2.node:setString(is_show)
	self.node_t_list.text_had_jihuo2.node:setColor(color)
	self:SetTextShow()
end


function NewReXueGodView:SetTextShow( ... )
	
	if self.rich_content == nil then
		self.rich_content = XUI.CreateRichText(0, 0, 350, 0, false)
		self.node_t_list.scroll_show.node:addChild(self.rich_content, 100, 100)
	end



		local	suitlevel1 =  EquipData.Instance:GetZhiZunSuitLevel()
		local 	level_data1 = EquipData.Instance:GetZunZhiSuitData()
		local   text1 = ReXueGodEquipData.Instance:GetTextByTypeData(suitlevel1, 10, level_data1,true, true)

		local	suitlevel2 =  EquipData.Instance:GetBazheLevel()
		local 	level_data2 = EquipData.Instance:GetBaZheSuitLevel()
		local   text2 = ReXueGodEquipData.Instance:GetTextByTypeData(suitlevel2, 11, level_data2, true, true)


		local	suitlevel3 =  EquipData.Instance:GetZhanShenLevel()
		local 	level_data3 = EquipData.Instance:GetZhanShenSuitLevel()
		local   text3 = ReXueGodEquipData.Instance:GetTextByTypeData(suitlevel3, 12, level_data3, true, true)


		local	suitlevel4 =  EquipData.Instance:GetShaShenLevel()
		local 	level_data4 = EquipData.Instance:GetSheShenSuitLevel()
		local   text4 = ReXueGodEquipData.Instance:GetTextByTypeData(suitlevel4, 13, level_data4, true, true)

		local text = text1.."\n".. text2 .. "\n" .. text3.."\n"..text4


	RichTextUtil.ParseRichText(self.rich_content,text, 18)
	self.rich_content:refreshView()

	local scroll_size = self.node_t_list.scroll_show.node:getContentSize()
	local inner_h = math.max(self.rich_content:getInnerContainerSize().height + 20, scroll_size.height)
	self.node_t_list.scroll_show.node:setInnerContainerSize(cc.size(scroll_size.width, inner_h))
	self.rich_content:setPosition(scroll_size.width / 2, inner_h)

	-- 默认跳到顶端
	self.node_t_list.scroll_show.node:getInnerContainer():setPositionY(scroll_size.height - inner_h)
end

-- function NewReXueGodView:SetTextShow( ... )
-- 	-- body
-- end


function NewReXueGodView:ShowIndexCallBack( ... )
	self:Flush()
end

function NewReXueGodView:FlushRemind( ... )
	for k, v in pairs(NewReXueGodView.EQUIP_POS) do
		if self.equip_list[v.equip_slot] then
			local cell = self.equip_list[v.equip_slot]
			local equip_data = ReXueGodEquipData.Instance:SetReXueCanBestData(v.equip_slot)
			local vis = equip_data ~= nil and true or false
			cell:SetRemindImage(vis)
		end
	end
end

function NewReXueGodView:OpenCallBack( ... )
	-- body
end


function NewReXueGodView:CloseCallBack( ... )
	-- body
end

function NewReXueGodView:OnFlush( ... )
	self:FlushRemind()
	self:SetSkillShow()
	self.node_t_list.img_hz_red.node:setVisible(RemindManager.Instance:GetRemindGroup(ViewDef.Role.RoleInfoList.LuxuryEquip.remind_group_name) > 0)
	self:SetBtnVis()
end

local NewGodEquipReXueRender = BaseClass(BaseRender)
NewReXueGodView.NewGodEquipReXueRender = NewGodEquipReXueRender
NewGodEquipReXueRender.size = cc.size(92, 98)
function NewGodEquipReXueRender:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(NewGodEquipReXueRender.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(NewGodEquipReXueRender.size.width / 2, NewGodEquipReXueRender.size.height - BaseCell.SIZE / 2 -10)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.cell:SetCellBgVis(true)
	
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)
	self.red_image = XUI.CreateImageView(BaseCell.SIZE-15, BaseCell.SIZE -15, ResPath.GetMainUiImg("remind_flag"), true)
	self.red_image:setVisible(false)
	self.cell:GetView():addChild(self.red_image,11)
end

function NewGodEquipReXueRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function NewGodEquipReXueRender:CreateChild()
	NewGodEquipReXueRender.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(NewGodEquipReXueRender.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function NewGodEquipReXueRender:OnFlush()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot)
	if equip_data then
		self.cell:SetData(equip_data)
	end

	--self.cell:SetRemind(EquipData.Instance:GetChuanShiCanUp(self.data.equip_slot) > 0)

	-- local equip = EquipData.Instance:GetBestCSEquip(equip_data, self.data.equip_slot)
	-- local vis = equip  and true or false
	--self.red_image:setVisible(vis)
	if nil == equip_data then
		-- local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(self.data.equip_slot))
		-- if act_cfg then
		-- 	local next_equip_id = act_cfg.targetEquips
		-- 	RichTextUtil.ParseRichText(self.rich_under, ItemData.Instance:GetItemNameRich(next_equip_id))
		-- 	self.cell:SetData({item_id = next_equip_id, num = 1, is_bind = 0})
		-- 	self.cell:SetCfgEffVis(false)
		-- end
		self.cell:SetData(nil)
		self:SetItemIcon(self.data.cell_img)
		self.cell:SetAddIconPath(true)
		--self.cell:MakeGray(true)
		
	else
		self.cell:SetAddIconPath(false)
		-- local chuanshi_info = EquipData.Instance:GetChuanShiInfo(self.data.equip_slot)
		-- local level = chuanshi_info.level
		-- self.cell:MakeGray(false)
		-- self.cell:SetCfgEffVis(true)
	end
	self.cell:SetCellBg(ResPath.GetCommon("cell_120"))
end

function NewGodEquipReXueRender:SetRemindImage(vis)
	if self.red_image then
		self.red_image:setVisible(vis)
	end
end

function NewGodEquipReXueRender:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function NewGodEquipReXueRender:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

function NewGodEquipReXueRender:SetItemIcon(path)
	if self.cell then
		self.cell:SetItemIcon(path)
	end
end

function NewGodEquipReXueRender:CreateSelectEffect()
	self.select_effect = XUI.CreateImageViewScale9(NewGodEquipReXueRender.size.width / 2, NewGodEquipReXueRender.size.height/2,
		BaseCell.SIZE, BaseCell.SIZE, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.select_effect, 999)
end

return NewReXueGodView