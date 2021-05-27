
local CSUpLevelView = BaseClass(SubView)

function CSUpLevelView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 4, {0}},
		{"chuanshi_equip_ui_cfg", 6, {0}},
	}
	self.select_slot = 0
	self.is_bullet_window = false
end

function CSUpLevelView:__delete()
end

function CSUpLevelView:ReleaseCallBack()
	if self.equip then
		self.equip:DeleteMe()
		self.equip = nil
	end

	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end

	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end
	self.is_bullet_window = nil
end

function CSUpLevelView:LoadCallBack(index, loaded_times)
	self.equip = CSEquipInfoView.ChuanShiEquipRender.New()
	self.equip:SetPosition(self.ph_list.ph_cell1.x, self.ph_list.ph_cell1.y)
	self.equip:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_equip_normal_info.node:addChild(self.equip:GetView(), 10)

	self.fight_power_view = FightPowerView.New(200, 450, self.node_t_list.layout_equip_normal_info.node, 99)
	
	self.node_t_list.btn_up.node:setTitleText("升级")
	self.node_t_list.btn_up.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_up.node:setTitleFontSize(22)
	self.node_t_list.btn_up.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_up.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_up.node, 1)

	local attr_view = AttrView.New(300, 25, 20)
	attr_view:SetDefTitleText("")
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(self.ph_list.ph_attr.x, self.ph_list.ph_attr.y)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(self.ph_list.ph_attr.w, self.ph_list.ph_attr.h)
	self.node_t_list.layout_up_attr.node:addChild(attr_view:GetView(), 50)
	self.attr_view = attr_view

    XUI.RichTextSetCenter(self.node_t_list.rich_consume.node)
    XUI.RichTextSetCenter(self.node_t_list.rich_show.node)

	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind(self.OnClickBtnUp, self))

	self.link_stuff = RichTextUtil.CreateLinkText("分解传世模具", 20, COLOR3B.GREEN)
	self.link_stuff:setPosition(370, -70)
	self.node_t_list.layout_up_attr.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, function()
		-- self:GetViewManager():OpenViewByDef(ViewDef.ChuanShiDecompose)
		EquipCtrl.Instance.chuanshi_equip_view.tabbar:SelectIndex(4)
	end, true)

	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHUANSHI_DATA_CHANGE, BindTool.Bind(self.OnChuanshiDataChange, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function CSUpLevelView:ShowIndexCallBack(index)
	self.select_slot = ViewDef.ChuanShiEquip._select_slot
	self:Flush()
end

function CSUpLevelView:OnFlush(param_t, index)
	self.equip:SetData({slot = self.select_slot})

	self:FlushIntro()

	local cs_info = EquipData.Instance:GetChuanShiInfo(self.select_slot)
	local attr = EquipData.GetChuanShiLevelAttr(EquipData.ChuanShiCfgIndex(self.select_slot), cs_info.level)
	local next_attr = EquipData.GetChuanShiLevelAttr(EquipData.ChuanShiCfgIndex(self.select_slot), cs_info.level + 1)

	local cur_cfg = attr
	local plus_cfg = CommonDataManager.LerpAttributeAttr(attr, next_attr)
	if nil == cur_cfg then
		cur_cfg = CommonDataManager.MulAtt(plus_cfg, 0)
	end
	self.attr_view:SetData(EquipData.ChuanshiBaseAttrFilter(cur_cfg), EquipData.ChuanshiBaseAttrFilter(plus_cfg))

	self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(cur_cfg))

	local level_cfg = EquipData.GetChuanShiLevelCfg(EquipData.ChuanShiCfgIndex(self.select_slot), cs_info.level + 1)
	local consume_str = ""
	local is_enough = false
	if level_cfg then
		local consume_cfg = level_cfg.consume
		local need_item_id = consume_cfg[1].id
		local need_num = consume_cfg[1].count
		local item_cfg = ItemData.Instance:GetItemConfig(need_item_id)
		local bag_num = BagData.Instance:GetItemNumInBagById(need_item_id)
		local item_color = string.format("%06x", item_cfg.color)
		is_enough = bag_num >= need_num
		
		consume_str = string.format("消耗：{color;%s;%s}({color;%s;%d}/%d)", item_color, item_cfg.name, is_enough and COLORSTR.GREEN or COLORSTR.RED, bag_num, need_num)
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, consume_str)
	self.node_t_list.btn_up.remind_eff:setVisible(is_enough)

	local chuanshi_info = EquipData.Instance:GetChuanShiInfo(self.select_slot)
	RichTextUtil.ParseRichText(self.node_t_list.rich_show.node, EquipData.GetChuanShiLevelRich(chuanshi_info.level), nil, COLOR3B.OLIVE)

	self.is_bullet_window = not is_enough
end

function CSUpLevelView:OnClickBtnUp()
	if self.is_bullet_window then
		local cfg = ConfigManager.Instance:GetClientConfig("item_synthesis_view_cfg") and ConfigManager.Instance:GetClientConfig("item_synthesis_view_cfg")[ITEM_SYNTHESIS_TYPES.CHUANSHI]
--		TipCtrl.Instance:OpenGetStuffTip(cfg.get_item_id)
	else
		EquipCtrl.SendChuanShiOptReq(CSChuanShiOptReq.OPT_TYPE.UP_LEVEL, EquipData.ChuanShiCfgIndex(self.select_slot))
	end
end

function CSUpLevelView:OnChuanshiDataChange()
	self:Flush()
end

function CSUpLevelView:OnBagItemChange()
	self:Flush()
end

function CSUpLevelView:FlushIntro()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip_data then
		return
	end
	local item_cfg = ItemData.Instance:GetItemConfig(equip_data.item_id)
	local color = ItemData.Instance:GetItemColor(equip_data.item_id, equip_data)
	self.node_t_list.lbl_pos.node:setColor(COLOR3B.YELLOW)
	self.node_t_list.lbl_pos.node:setString(string.format(Language.Tip.ZhuangBeiLeiXing, Language.EquipTypeName[item_cfg.type] or ""))
	self.node_t_list.lbl_prof.node:setColor(COLOR3B.YELLOW)
	self.node_t_list.lbl_prof.node:setString(prof_str)
	self.node_t_list.lbl_circle.node:setColor(COLOR3B.YELLOW)

	self.limit_level = 0
	self.circle_level = 0
	self.item_prof_limit = 0
	for k,v in pairs(item_cfg.conds) do
		if v.cond == ItemData.UseCondition.ucLevel then
			self.limit_level = v.value
			if not RoleData.Instance:IsEnoughLevelZhuan(v.value) then
				self.node_t_list.lbl_circle.node:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucMinCircle then
			self.circle_level = v.value
			if v.value > RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_CIRCLE) then
				self.node_t_list.lbl_circle.node:setColor(COLOR3B.RED)
			end
		end
		if v.cond == ItemData.UseCondition.ucJob then
			self.item_prof_limit = v.value
			self.node_t_list.lbl_prof.node:setString(string.format(Language.Tip.Prof, Language.Common.ProfName[v.value]))
			if v.value ~= 0 and v.value ~= RoleData.Instance:GetAttr(OBJ_ATTR.ACTOR_PROF) then
				self.node_t_list.lbl_prof.node:setColor(COLOR3B.RED)
			end
		end
	end
	if self.circle_level > 0 then
		self.node_t_list.lbl_circle.node:setString(string.format(Language.Tip.ZhuanDengJi, self.circle_level, self.limit_level))
	else
		self.node_t_list.lbl_circle.node:setString(string.format(Language.Tip.DengJi, self.limit_level))
	end
end

return CSUpLevelView
