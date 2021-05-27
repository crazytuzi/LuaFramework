
local RexueEquipInfoView = BaseClass(SubView)

function RexueEquipInfoView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"rexue_equip_ui_cfg", 3, {0}},
	}
	self.select_slot = 0
end

function RexueEquipInfoView:__delete()
end

function RexueEquipInfoView:ReleaseCallBack()
	if self.equip then
		self.equip:DeleteMe()
		self.equip = nil
	end

	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end
end

function RexueEquipInfoView:LoadCallBack(index, loaded_times)
	self.equip = BaseCell.New()
	self.equip:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	self.equip:SetIsShowTips(false)
	self.equip:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_equip_info.node:addChild(self.equip:GetView(), 10)

	self.fight_power_view = FightPowerView.New(200, 450, self.node_t_list.layout_equip_info.node, 99)

	self.node_t_list.rich_attr.node:setVerticalSpace(4)
end

function RexueEquipInfoView:ShowIndexCallBack(index)
	self.select_slot = ViewDef.ReXueShiEquip._select_slot
	self:Flush()
end

function RexueEquipInfoView:OnFlush(param_t, index)
	self:FlushIntro()

	self:ParseAttr()
end

function RexueEquipInfoView:FlushIntro()
	local equip_item_id
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip_data then
		local first_equip_id = EquipData.GetRexueFirstEquip(self.select_slot)
		equip_item_id = first_equip_id
	else
		equip_item_id = equip_data.item_id
	end

	if nil == equip_item_id then
		return
	end

	local item_cfg = ItemData.Instance:GetItemConfig(equip_item_id)
	local color = ItemData.Instance:GetItemColor(equip_item_id)
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

function RexueEquipInfoView:ParseAttr()
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip_data then
		local first_equip_id = EquipData.GetRexueFirstEquip(self.select_slot)
		equip_item_id = first_equip_id
		self.equip:SetData({item_id = first_equip_id, num = 1, is_bind = 0})
	else
		equip_item_id = equip_data.item_id
		self.equip:SetData(equip_data)
	end

	local zl_data = EquipData.Instance:GetRexueZhulingData(self.select_slot)
	local zl_attrs = EquipData.GetRexueZhulingAttrs(self.select_slot, zl_data.level)
	local item_cfg = ItemData.Instance:GetItemConfig(equip_item_id)
	local base_attrs = ItemData.GetStaitcAttrs(item_cfg)
	local all_attrs = CommonDataManager.AddAttr(base_attrs, zl_attrs)

	local content = ""
	local mark = "\n      "

	content = content .. "{image;res/xui/common/orn_100.png;25,20}{color;ff7f00;基础属性}"

	local base_content = RoleData.FormatAttrContent(EquipData.RexueAttrsFilter(all_attrs, EquipData.REXUE_FLITER_TYPE.BASE_ATTR), nil, mark)
	content = content .. mark .. base_content .. "\n\n"

	content = content .. "{image;res/xui/common/orn_100.png;25,20}{color;ff7f00;特殊属性}"
	content = content .. mark .. RoleData.FormatAttrContent(EquipData.RexueAttrsFilter(all_attrs, EquipData.REXUE_FLITER_TYPE.SPECIAL_ATTR), nil, mark) .. "\n\n"

	local equip_client_cfg = EquipData.GetRexueEquipClientCfg(self.select_slot, equip_item_id)
	if equip_client_cfg and equip_client_cfg.skill_desc then
		content = content .. "{image;res/xui/common/orn_100.png;25,20}{color;ff7f00;特殊技能}\n" .. equip_client_cfg.skill_desc
	end

	RichTextUtil.ParseRichText(self.node_t_list.rich_attr.node, content, nil, COLOR3B.OLIVE)

	self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(all_attrs))
end

return RexueEquipInfoView
