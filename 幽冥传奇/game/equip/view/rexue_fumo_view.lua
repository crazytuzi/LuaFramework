
local RexueFumoView = BaseClass(SubView)

function RexueFumoView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"rexue_equip_ui_cfg", 5, {0}},
	}
end

function RexueFumoView:__delete()
end

function RexueFumoView:ReleaseCallBack()
	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end
	self.equip_effect = nil
end

function RexueFumoView:LoadCallBack(index, loaded_times)
	self.fight_power_view = FightPowerView.New(self.ph_list.ph_equip_center.x, self.ph_list.ph_equip_center.y + 170, self.node_t_list.layout_fumo.node, 99)
	
	self.node_t_list.btn_operation.node:setTitleText("附魔")
	self.node_t_list.btn_operation.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_operation.node:setTitleFontSize(22)
	self.node_t_list.btn_operation.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_operation.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_operation.node, 1)
	XUI.AddClickEventListener(self.node_t_list.btn_operation.node, BindTool.Bind(self.OnClickFumo, self))

    XUI.RichTextSetCenter(self.node_t_list.rich_consume.node)

    local attr_view = AttrView.New(300, 25, 20)
	attr_view:SetDefTitleText("")
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(self.ph_list.ph_attr.x, self.ph_list.ph_attr.y)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(self.ph_list.ph_attr.w, self.ph_list.ph_attr.h)
	self.node_t_list.layout_fumo.node:addChild(attr_view:GetView(), 50)
	self.attr_view = attr_view

	self.equip_effect = RenderUnit.CreateEffect(nil, self.node_t_list.layout_fumo.node, 10)
	self.equip_effect:setPosition(self.ph_list.ph_equip_center.x, self.ph_list.ph_equip_center.y)
	self.equip_effect:setScale(0.85)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHANGE_ONE_EQUIP, BindTool.Bind(self.OnOneEequipChange, self))
end

function RexueFumoView:ShowIndexCallBack(index)
	self.select_slot = ViewDef.ReXueShiEquip._select_slot
	self:Flush()
end

function RexueFumoView:OnFlush(param_t, index)
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)

	local attrs = nil
	local next_attrs = nil
	local consume_content = ""
	local cur_fight_power = 0
	local is_enough = false
	if equip_data then
		attrs = ItemData.GetStaitcAttrs(ItemData.Instance:GetItemConfig(equip_data.item_id), equip_data)
		cur_fight_power = CommonDataManager.GetAttrSetScore(attrs)
		local zl_data = EquipData.Instance:GetRexueZhulingData(self.select_slot)
		local equip_name = ItemData.Instance:GetItemNameRich(equip_data.item_id)
		local equip_name = string.gsub(equip_name, "·", "\n ·\n")
		RichTextUtil.ParseRichText(self.node_t_list.rich_equip_name.node, equip_name, nil, COLOR3B.OLIVE)
		local fumo_cfg = EquipData.GetRexueFumoCfg(self.select_slot, equip_data.item_id)
		if fumo_cfg then
			next_attrs = ItemData.GetStaitcAttrs(ItemData.Instance:GetItemConfig(fumo_cfg.targetEquips))

			local need_id = fumo_cfg.consume[1].id
			local need_num = fumo_cfg.consume[1].count
			local have_num = BagData.Instance:GetItemNumInBagById(need_id)
			is_enough = have_num >= need_num
			consume_content = string.format("消耗：%s({color;%s;%d}/%d)", ItemData.Instance:GetItemNameRich(need_id), is_enough and COLORSTR.GREEN or COLORSTR.RED, have_num, need_num)
		end

		local equip_client_cfg = EquipData.GetRexueEquipClientCfg(self.select_slot, equip_data.item_id)
		if equip_client_cfg then
			local anim_path, anim_name = ResPath.GetEffectUiAnimPath(equip_client_cfg.effect_id)
			self.equip_effect:setAnimate(anim_path, anim_name, COMMON_CONSTS.MAX_LOOPS, FrameTime.Effect, false)
		end
	end

	self.node_t_list.btn_operation.remind_eff:setVisible(is_enough)
	RichTextUtil.ParseRichText(self.node_t_list.rich_consume.node, consume_content, nil, COLOR3B.OLIVE)
	self.fight_power_view:SetNumber(cur_fight_power)

	local plus_cfg = CommonDataManager.LerpAttributeAttr(attrs, next_attrs)
	if nil == attrs then
		attrs = CommonDataManager.MulAtt(plus_cfg, 0)
	end
	self.attr_view:SetData(attrs, plus_cfg)
end

function RexueFumoView:OnClickFumo()
	EquipCtrl.SendRexueEquipFumoOptReq(self.select_slot)
end

function RexueFumoView:OnOneEequipChange()
	self:Flush()
end

function RexueFumoView:OnBagItemChange()
	self:Flush()
end

return RexueFumoView
