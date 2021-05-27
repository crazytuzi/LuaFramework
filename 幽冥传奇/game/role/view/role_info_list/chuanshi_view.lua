
local ChuanShiView = BaseClass(SubView)

function ChuanShiView:__init()
	self.texture_path_list = {
		'res/xui/equipbg.png',
	}
	self.config_tab = {
		--{"chuanshi_ui_cfg", 1, {0}},
		{"role1_ui_cfg", 3, {0}},
		{"role1_ui_cfg", 8, {0}},
	}


	self.equip_list = {}
	self.select_slot = EquipData.EquipSlot.itHandedDownWeaponPos
	self.is_bullet_window = false
end

function ChuanShiView:__delete()
end

function ChuanShiView:ReleaseCallBack()
	for k, v in pairs(self.equip_list) do
		v:DeleteMe()
	end
	self.equip_list = {}
	self.equip_img_bg = nil
	self.equip_effect = nil
	self.txt_see_attr = nil
	self.is_bullet_window = nil
	if self.role_display then
		self.role_display:DeleteMe()
		self.role_display = nil
	end
end

function ChuanShiView:LoadCallBack(index, loaded_times)
	self:CreateEquipCells()

	--self.node_t_list.btn_chuanshi.node:setTitleText("")
	--self.node_t_list.btn_chuanshi.node:setTitleFontName(COMMON_CONSTS.FONT)
	--self.node_t_list.btn_chuanshi.node:setTitleFontSize(22)
	--self.node_t_list.btn_chuanshi.node:setTitleColor(COLOR3B.G_W2)
	--self.node_t_list.btn_chuanshi.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_chuanshi.node, 1)

	---- 获取材料
	--if not IS_AUDIT_VERSION then
	--	self.link_stuff = RichTextUtil.CreateLinkText("获取传世装备", 20, COLOR3B.GREEN)
	--	local x, y = self.node_t_list.btn_chuanshi.node:getPosition()
	--	self.link_stuff:setPosition(x + 170, y - 8)
	--	self.node_t_list.layout_chuanshi.node:addChild(self.link_stuff, 99)
	--	XUI.AddClickEventListener(self.link_stuff, BindTool.Bind(self.OnClickLinkStuff, self), true)
	--end

	self.equip_effect = RenderUnit.CreateEffect(nil, self.node_t_list.layout_center.node, 10)
	CommonAction.ShowJumpAction(self.equip_effect, 10)

    --XUI.RichTextSetCenter(self.node_t_list.rich_btn_above.node)

	XUI.AddClickEventListener(self.node_t_list.btn_return.node, BindTool.Bind(self.OnClickReturnRole, self))
	--
	XUI.AddClickEventListener(self.node_t_list.btn_hao_zhaung_btn.node, BindTool.Bind(self.OnClickHaoZhuang, self))

	local equip_proxy = EventProxy.New(EquipData.Instance, self)
	equip_proxy:AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnChangeOneEquip, self))
	equip_proxy:AddEventListener(EquipData.CHUANSHI_DATA_CHANGE, BindTool.Bind(self.OnChuanshiDataChange, self))
	
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	self:BindGlobalEvent(OtherEventType.REMINDGROUP_CAHANGE, BindTool.Bind(self.OnRemindGroupChange, self))

	EventProxy.New(RoleData.Instance, self):AddEventListener(RoleData.ROLE_ATTR_CHANGE, BindTool.Bind(self.RoleDataChangeCallback, self))

	self.role_display = RoleDisplay.New(self.node_t_list.layout_center.node, - 1, false, false, true, true)
	
	self.role_display:SetPosition(self.node_t_list.layout_center.node:getContentSize().width/2 , self.node_t_list.layout_center.node:getContentSize().height/2 + 40)
	self.role_display:SetScale(0.8)

	XUI.AddClickEventListener(self.node_t_list.layout_check1.node, BindTool.Bind(self.OnClickShowWeapon, self))
	self.node_t_list.img_checkBox.node:setVisible(RoleData.Instance:GetCanChuanSHiWeapon() == 1)
	XUI.AddClickEventListener(self.node_t_list.layout_check2.node, BindTool.Bind(self.OnClickShowFashion, self))
	self.node_t_list.img_checkBox2.node:setVisible(RoleData.Instance:GetShowShiFashion() == 1)
end

function ChuanShiView:OnClickShowWeapon( )
	local bool = self.node_t_list.img_checkBox.node:isVisible() and 0 or 1
	self.node_t_list.img_checkBox.node:setVisible(bool == 1)
	RoleData.Instance:SetChuanShiSHow( bool)
	self:SetFlushWeaponShow()
end

function ChuanShiView:OnClickShowFashion()
	local bool = self.node_t_list.img_checkBox2.node:isVisible() and 0 or 1
	self.node_t_list.img_checkBox2.node:setVisible(bool == 1)
	RoleData.Instance:SetChuanShiFashion( bool)
	self:SetFashionShow()
end

function ChuanShiView:SetFlushWeaponShow()
	if RoleData.Instance:GetCanChuanSHiWeapon() == 1 then
		local wapon_model = 0
		local equip_data = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itHandedDownWeaponPos)
	 	if equip_data then
	 		local config = ItemData.Instance:GetItemConfig(equip_data.item_id)
	 		wapon_model  = config.shape
	 	else
	 		local  w_fashion_data = FashionData.Instance:GetHadHuanhuaHuanWuData()
	 		if w_fashion_data then
	 			local config = ItemData.Instance:GetItemConfig(w_fashion_data.item_id)
	 			wapon_model  = config.shape
	 		else
		 		local w_equip_data = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itWeaponPos)
		 		if w_equip_data then
	 				local config = ItemData.Instance:GetItemConfig(w_equip_data.item_id)
	 				wapon_model  = config.shape
		 		end
		 	end
		 end
		 self.role_display:SetWuQiResId(wapon_model)
	else
		local wapon_model = 0
		local  w_fashion_data = FashionData.Instance:GetHadHuanhuaHuanWuData()
	 		if w_fashion_data then
	 			local config = ItemData.Instance:GetItemConfig(w_fashion_data.item_id)
	 			wapon_model  = config.shape
	 		else
		 		local w_equip_data = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itWeaponPos)
		 		if w_equip_data then
	 				local config = ItemData.Instance:GetItemConfig(w_equip_data.item_id)
	 				wapon_model  = config.shape
		 		end
		 	end
	
		 self.role_display:SetWuQiResId(wapon_model)
	end
end

function ChuanShiView:SetFashionShow( ... )
	if RoleData.Instance:GetShowShiFashion() == 1 then
		local fashion_model = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) + 10000
		local equip_data = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itHandedDownDressPos)
	 	if equip_data then
	 		local config = ItemData.Instance:GetItemConfig(equip_data.item_id)
	 		fashion_model  = config.shape
	 	else
	 		local  w_fashion_data = FashionData.Instance:GetHadHuanhuaFashionData()
	 		if w_fashion_data then
	 			local config = ItemData.Instance:GetItemConfig(w_fashion_data.item_id)
	 			fashion_model  = config.shape
	 		else
		 		local w_equip_data = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itDress)
		 		if w_equip_data then
	 				local config = ItemData.Instance:GetItemConfig(w_equip_data.item_id)
	 				fashion_model  = config.shape
		 		end
		 	end
		 end
		 self.role_display:SetRoleResId(fashion_model)
	else
		local fashion_model = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_SEX) + 10000
		local  w_fashion_data = FashionData.Instance:GetHadHuanhuaFashionData()
	 		if w_fashion_data then
	 			local config = ItemData.Instance:GetItemConfig(w_fashion_data.item_id)
	 			fashion_model  = config.shape
	 		else
		 		local w_equip_data = EquipData.Instance:GetEquipDataBySolt(EquipData.EquipSlot.itDress)
		 		if w_equip_data then
	 				local config = ItemData.Instance:GetItemConfig(w_equip_data.item_id)
	 				fashion_model  = config.shape
		 		end
		 	end
		 self.role_display:SetRoleResId(fashion_model)
	end
end


function ChuanShiView:RoleDataChangeCallback(vo)
	if vo.key == OBJ_ATTR.ENTITY_MODEL_ID or vo.key == OBJ_ATTR.ACTOR_WEAPON_APPEARANCE or vo.key == OBJ_ATTR.ACTOR_WING_APPEARANCE  or vo.key == OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE or
		vo.key == OBJ_ATTR.ACTOR_FOOT_APPEARANCE then
		self:SetRole()
	end
end

function ChuanShiView:SetRole( ... )
	if nil ~= self.role_display then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()


		 
		self.chibang_res_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_WING_APPEARANCE) or 0
		self.hand_res_id = RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_THANOSGLOVE_APPEARANCE) or 0

		self.douli_res_id = bit:_rshift(RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_FOOT_APPEARANCE), 16)


		self.role_display:SetChiBangResId(self.chibang_res_id)
		self.role_display:SetHandResId(self.hand_res_id)
		self.role_display:SetDouliResId(self.douli_res_id)
		self:SetFlushWeaponShow()
		self:SetFashionShow()
		
		self.node_t_list.lbl_role_name.node:setString(role_vo.name)
	end
end

function ChuanShiView:OnClickReturnRole( ... )
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList)
end

function ChuanShiView:OnClickHaoZhuang( ... )
	ViewManager.Instance:OpenViewByDef(ViewDef.Role.RoleInfoList.LuxuryEquip)
end

function ChuanShiView:OpenCallBack()
	self.select_slot = EquipData.EquipSlot.itHandedDownWeaponPos
end

function ChuanShiView:ShowIndexCallBack(index)
	self:Flush()
end

function ChuanShiView:OnFlush(param_t, index)
	if param_t.flush_equips then
		for k, v in pairs(self.equip_list) do
			v:Flush()
		end
	end

	if param_t.all then
		self:FlushParts()
	end
	self:SetRole()
	
end



----------------------------------------------------------------------------------
function ChuanShiView:OnClickLinkStuff()
	if nil ~= self.need_item_id then
		TipCtrl.Instance:OpenGetStuffTip(self.need_item_id)
	end
end

function ChuanShiView:OnRemindGroupChange(group_name, num)
	if group_name == self:GetViewDef().remind_group_name then
		self:Flush(0, "flush_equips")
	end
end

function ChuanShiView:OnBagItemChange()
	self:Flush(0, "flush_equips")
	self:Flush()
end

function ChuanShiView:OnChuanshiDataChange()
	self:Flush(0, "flush_equips")
end

function ChuanShiView:OnChangeOneEquip(vo)
	if vo.slot and self.equip_list[vo.slot] then
		self.equip_list[vo.slot]:Flush()
	end

	self:Flush()
end

-- 面板显示变化
function ChuanShiView:FlushParts()
	local equip = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	local consume_str = ""
	local equip_item_id
	local is_act = nil ~= equip
	local is_enough = false

	self.need_item_id = nil
	if nil == equip then
		local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(self.select_slot))
		if act_cfg then
			equip_item_id = act_cfg.targetEquips
			local consume_cfg = act_cfg.consume
			local need_item_id = consume_cfg[1].id
			self.need_item_id = need_item_id
			local need_num = consume_cfg[1].count
			local item_cfg = ItemData.Instance:GetItemConfig(need_item_id)
			local bag_num = BagData.Instance:GetItemNumInBagById(need_item_id)
			local item_color = string.format("%06x", item_cfg.color)
			is_enough = bag_num >= need_num
			
			consume_str = string.format("消耗：{color;%s;%s}({color;%s;%d}/%d)", item_color, item_cfg.name, is_enough and COLORSTR.GREEN or COLORSTR.RED, bag_num, need_num)
		end
	else
		equip_item_id = equip.item_id
	end
    --RichTextUtil.ParseRichText(self.node_t_list.rich_btn_above.node, consume_str)
	--self.node_t_list.btn_chuanshi.node:setTitleText(not is_act and "激活" or "查看属性")
	--self.node_t_list.btn_chuanshi.node:setVisible(not is_act)
	--self.node_t_list.btn_chuanshi.remind_eff:setVisible(is_enough)
	--if not IS_AUDIT_VERSION then
	--	self.link_stuff:setVisible(not is_act)
	--end
	
	--if nil == self.txt_see_attr and is_act then
	--	local x, y = self.node_t_list.btn_chuanshi.node:getPosition()
	--	self.txt_see_attr = XUI.CreateText(x, y + 20, 0, 0, nil, "点击装备图可查看属性", nil, 20, COLOR3B.OLIVE)
	--	self.node_t_list.layout_chuanshi.node:addChild(self.txt_see_attr, 99)
	--elseif self.txt_see_attr then
	--	self.txt_see_attr:setVisible(is_act)
	--end

	-- local chuanshi_special_cfg = EquipData.GetChuanShiSpecialCfg(EquipData.ChuanShiCfgIndex(self.select_slot), equip_item_id)
	-- local anim_path, anim_name = ResPath.GetEffectUiAnimPath(chuanshi_special_cfg and chuanshi_special_cfg.effect_id or 0)
	-- self.equip_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
	-- XUI.MakeGrey(self.equip_effect, nil == equip)

	self.is_bullet_window = not is_enough
end

function ChuanShiView:FlushConsumeDesc()
end

ChuanShiView.EQUIP_POS = {
	{equip_slot = EquipData.EquipSlot.itHandedDownWeaponPos, row = 5, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_1")},	-- 武器
	{equip_slot = EquipData.EquipSlot.itHandedDownDressPos, row = 4, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_2")},	-- 衣服
	{equip_slot = EquipData.EquipSlot.itHandedDownHelmetPos, row = 5, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_3")},	-- 头盔
	{equip_slot = EquipData.EquipSlot.itHandedDownNecklacePos, row = 4, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_4")},	-- 项链
	{equip_slot = EquipData.EquipSlot.itHandedDownLeftBraceletPos, row = 3, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 手镯左
	{equip_slot = EquipData.EquipSlot.itHandedDownRightBraceletPos, row = 3, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_5")},	-- 手镯右
	{equip_slot = EquipData.EquipSlot.itHandedDownLeftRingPos, row = 2, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 戒指左
	{equip_slot = EquipData.EquipSlot.itHandedDownRightRingPos, row = 2, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_6")},	-- 戒指右
	{equip_slot = EquipData.EquipSlot.itHandedDownGirdlePos, row = 1, col = 1, cell_img = ResPath.GetEquipImg("cs_bg_7")},	-- 腰带
	{equip_slot = EquipData.EquipSlot.itHandedDownShoesPos, row = 1, col = 2, cell_img = ResPath.GetEquipImg("cs_bg_8")},	-- 鞋子
}
-- 基础装备格子
function ChuanShiView:CreateEquipCells()
	self.equip_list = {}
	local ChuanshiEquipRender = ChuanShiView.ChuanshiEquipRender
	local container_size = self.node_t_list.layout_role_equip.node:getContentSize()
	--local ph =
	for k, v in pairs(ChuanShiView.EQUIP_POS) do
		-- local x = (v.col == 1) and (50) or (container_size.width - 50)
		-- local y = (v.row - 1) * (5 + ChuanshiEquipRender.size.height) + 30
		local ph = self.ph_list["ph_item_"..k]
		local equip = ChuanshiEquipRender.New()
		self.equip_list[v.equip_slot] = equip
		-- local bg_ta = ResPath.GetEquipImg(v.cell_img[1])
		-- local bg_ta2 = ResPath.GetEquipWord(v.cell_img[2])
		equip:SetPosition(ph.x, ph.y - 2)
		--equip:SetItemIcon(v.cell_img)
		equip:SetData(v)
		--equip:GetView():setAnchorPoint(0.5, 0.5)
		equip:SetClickCellCallBack(BindTool.Bind(self.SelectCellCallBack, self))
		self.node_t_list.layout_role_equip.node:addChild(equip:GetView(), 10)

		equip:SetSelect(v.equip_slot == self.select_slot)
	end
end

local slot2handPos = {
	[EquipData.EquipSlot.itHandedDownLeftBraceletPos] = 0,	-- 传世_左手镯
    [EquipData.EquipSlot.itHandedDownRightBraceletPos] = 1,	-- 传世_右手镯
    [EquipData.EquipSlot.itHandedDownLeftRingPos] = 0,	-- 传世_左戒指
    [EquipData.EquipSlot.itHandedDownRightRingPos] = 1,	-- 传世_右戒指
}

function ChuanShiView:SelectCellCallBack(cell)
	for k, v in pairs(self.equip_list) do
		v:SetSelect(v == cell)
	end
	local slot = cell:GetData().equip_slot
	local equip =  EquipData.Instance:GetEquipDataBySolt(slot)
	local equip_data = EquipData.Instance:GetBestCSEquip(equip, slot)
	if equip_data == nil then
		if equip then
			TipCtrl.Instance:OpenItem(equip, EquipTip.FROM_ROlE_CHUANG_SHI, {chuanshi_slot = slot})
		end 
	else

		EquipCtrl.SendFitOutEquip(equip_data.series, slot2handPos[slot])
	end
	
end

function ChuanShiView:OnClickCenter()
	ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip)
	ViewDef.ChuanShiEquip._select_slot = self.select_slot
end

function ChuanShiView:OnClickChuanShiBtn()
	local equip = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip then
		if self.is_bullet_window then
            if IS_AUDIT_VERSION then
				EquipCtrl.SendChuanShiOptReq(CSChuanShiOptReq.OPT_TYPE.UP_GRADE, EquipData.ChuanShiCfgIndex(self.select_slot))
			else
				self:OnClickLinkStuff()
			end	
			
		else
			EquipCtrl.SendChuanShiOptReq(CSChuanShiOptReq.OPT_TYPE.UP_GRADE, EquipData.ChuanShiCfgIndex(self.select_slot))
		end
	else
		-- ViewManager.Instance:OpenViewByDef(ViewDef.ChuanShiEquip)
		-- ViewDef.ChuanShiEquip._select_slot = self.select_slot
	end
end

----------------------------------
-- 基础装备格子
----------------------------------
local ChuanshiEquipRender = BaseClass(BaseRender)
ChuanShiView.ChuanshiEquipRender = ChuanshiEquipRender
ChuanshiEquipRender.size = cc.size(92, 98)
function ChuanshiEquipRender:__init()
	self:SetIsUseStepCalc(true)
	self.view:setContentSize(ChuanshiEquipRender.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(ChuanshiEquipRender.size.width / 2, ChuanshiEquipRender.size.height - BaseCell.SIZE / 2 -10)
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

function ChuanshiEquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function ChuanshiEquipRender:CreateChild()
	ChuanshiEquipRender.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(ChuanshiEquipRender.size.width / 2, 0, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 10)
end

function ChuanshiEquipRender:OnFlush()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.data.equip_slot)
	if equip_data then
		self.cell:SetData(equip_data)
	end

	--self.cell:SetRemind(EquipData.Instance:GetChuanShiCanUp(self.data.equip_slot) > 0)

	local equip = EquipData.Instance:GetBestCSEquip(equip_data, self.data.equip_slot)
	local vis = equip  and true or false
	self.red_image:setVisible(vis)
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
		--self.cell:MakeGray(true)
		
	else
		local chuanshi_info = EquipData.Instance:GetChuanShiInfo(self.data.equip_slot)
		local level = chuanshi_info.level
		self.cell:MakeGray(false)
		self.cell:SetCfgEffVis(true)
	end
	self.cell:SetCellBg(ResPath.GetCommon("cell_101"))
end

function ChuanshiEquipRender:SetClickCellCallBack(func)
	self.click_cell_callback = func
end

function ChuanshiEquipRender:SetSkinStyle(...)
	if self.cell then
		self.cell:SetSkinStyle(...)
	end
end

function ChuanshiEquipRender:SetItemIcon(path)
	if self.cell then
		self.cell:SetItemIcon(path)
	end
end

function ChuanshiEquipRender:CreateSelectEffect()
	self.select_effect = XUI.CreateImageViewScale9(ChuanshiEquipRender.size.width / 2, ChuanshiEquipRender.size.height/2,
		BaseCell.SIZE, BaseCell.SIZE, ResPath.GetCommon("img9_120"), true)
	self.view:addChild(self.select_effect, 999)
end

return ChuanShiView
