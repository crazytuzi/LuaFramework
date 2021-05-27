
local CSUpGradeView = BaseClass(SubView)

function CSUpGradeView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 5, {0}, nil, 10},
		{"chuanshi_equip_ui_cfg", 6, {0}},
	}
	self.is_bullet_window = false
end

function CSUpGradeView:__delete()
end

function CSUpGradeView:ReleaseCallBack()
	if self.equip1 then
		self.equip1:DeleteMe()
		self.equip1 = nil
	end

	if self.equip2 then
		self.equip2:DeleteMe()
		self.equip2 = nil
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

function CSUpGradeView:LoadCallBack(index, loaded_times)
	self.equip1 = CSEquipInfoView.ChuanShiEquipRender.New()
	self.equip1:SetPosition(self.ph_list.ph_cell2.x, self.ph_list.ph_cell2.y)
	self.equip1:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_upgrade.node:addChild(self.equip1:GetView(), 10)

	self.equip2 = CSEquipInfoView.ChuanShiEquipRender.New()
	self.equip2:SetPosition(self.ph_list.ph_cell3.x, self.ph_list.ph_cell3.y)
	self.equip2:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_upgrade.node:addChild(self.equip2:GetView(), 10)

	self.fight_power_view = FightPowerView.New(160, -84, self.node_t_list.layout_upgrade.node, 99)
	
	self.node_t_list.btn_up.node:setTitleText("进阶")
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

    -- 获取材料
	self.link_stuff = RichTextUtil.CreateLinkText("获取模具", 20, COLOR3B.GREEN)
	self.link_stuff:setPosition(383, -70)
	self.node_t_list.layout_up_attr.node:addChild(self.link_stuff, 99)
	XUI.AddClickEventListener(self.link_stuff, BindTool.Bind(self.OnClickGetStuff, self), true)

	XUI.AddClickEventListener(self.node_t_list.btn_up.node, BindTool.Bind(self.OnClickBtnUp, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function CSUpGradeView:ShowIndexCallBack(index)
	self.select_slot = ViewDef.ChuanShiEquip._select_slot
	self:Flush()
end

function CSUpGradeView:OnFlush(param_t, index)
	self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(EquipData.Instance:GetChuanShiBaseAttr(self.select_slot, false)))

	local next_equip_data

	self.need_item_id = nil
	local equip = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	local consume_str = ""
	local is_enough = false
	if nil ~= equip then
		local cur_grade_cfg = EquipData.GetChuanShiGradeCfg(EquipData.ChuanShiCfgIndex(self.select_slot), equip.item_id)
		if cur_grade_cfg then
			next_equip_data = {equip_item_id = cur_grade_cfg.targetEquips}
			local next_grade_cfg = EquipData.GetChuanShiGradeCfg(EquipData.ChuanShiCfgIndex(self.select_slot), cur_grade_cfg.targetEquips)
			local consume_cfg = cur_grade_cfg.consume
			local need_item_id = consume_cfg[1].id
			self.need_item_id = need_item_id
			local need_num = consume_cfg[1].count
			local item_cfg = ItemData.Instance:GetItemConfig(need_item_id)
			local bag_num = BagData.Instance:GetItemNumInBagById(need_item_id)
			local item_color = string.format("%06x", item_cfg.color)
			is_enough = bag_num >= need_num
			
			consume_str = string.format("消耗：{color;%s;%s}({color;%s;%d}/%d)", item_color, item_cfg.name, is_enough and COLORSTR.GREEN or COLORSTR.RED, bag_num, need_num)
		end
	end
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, consume_str, nil, COLOR3B.OLIVE)
	self.node_t_list.btn_up.remind_eff:setVisible(is_enough)

	self.equip1:SetData({slot = self.select_slot})
	self.equip2:SetData(next_equip_data)

	self.link_stuff:setVisible(nil ~= self.need_item_id)

	local base_attr = EquipData.Instance:GetChuanShiBaseAttr(self.select_slot, false)
	local next_base_attr = nil
	if next_equip_data then
		local item_cfg = ItemData.Instance:GetItemConfig(next_equip_data.equip_item_id)
		next_base_attr = ItemData.GetStaitcAttrs(item_cfg)
	end

	local cur_cfg = base_attr
	local next_attr = next_base_attr
	local plus_cfg = CommonDataManager.LerpAttributeAttr(base_attr, next_attr)
	if nil == cur_cfg then
		cur_cfg = CommonDataManager.MulAtt(plus_cfg, 0)
	end
	self.attr_view:SetData(cur_cfg, plus_cfg)
	self.is_bullet_window = not is_enough
end

function CSUpGradeView:OnClickGetStuff()
	if nil ~= self.need_item_id then
		TipCtrl.Instance:OpenGetStuffTip(self.need_item_id)
	end
end

function CSUpGradeView:OnClickBtnUp()
	if self.is_bullet_window then
		self:OnClickGetStuff()
	else
		EquipCtrl.SendChuanShiOptReq(CSChuanShiOptReq.OPT_TYPE.UP_GRADE, EquipData.ChuanShiCfgIndex(self.select_slot))
	end
end

function CSUpGradeView:OnBagItemChange()
	self:Flush()
end

return CSUpGradeView
