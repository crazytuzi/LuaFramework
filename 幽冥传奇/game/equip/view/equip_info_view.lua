
CSEquipInfoView = BaseClass(SubView)

function CSEquipInfoView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 4, {0}},
	}
	self.select_slot = 0
end

function CSEquipInfoView:__delete()
end

function CSEquipInfoView:ReleaseCallBack()
	if self.equip then
		self.equip:DeleteMe()
		self.equip = nil
	end

	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end
end

function CSEquipInfoView:LoadCallBack(index, loaded_times)
	self.equip = CSEquipInfoView.ChuanShiEquipRender.New()
	self.equip:SetPosition(self.ph_list.ph_cell1.x, self.ph_list.ph_cell1.y)
	self.equip:SetAnchorPoint(0.5, 0.5)

	self.node_t_list.layout_equip_normal_info.node:addChild(self.equip:GetView(), 10)

	self.fight_power_view = FightPowerView.New(200, 450, self.node_t_list.layout_equip_normal_info.node, 99)

	self.node_t_list.rich_attr.node:setVerticalSpace(4)
end

function CSEquipInfoView:ShowIndexCallBack(index)
	self.select_slot = ViewDef.ChuanShiEquip._select_slot or self.select_slot
	self:Flush()
end

function CSEquipInfoView:OnFlush(param_t, index)
	self:FlushIntro()

	self:ParseAttr()
end

function CSEquipInfoView:FlushIntro()
	local equip_item_id
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip_data then
		local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(self.select_slot))
		equip_item_id = act_cfg and act_cfg.targetEquips
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

function CSEquipInfoView:ParseAttr()
	local equip_item_id
	local equip_data = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip_data then
		local act_cfg = EquipData.GetChuanShiActiveCfg(EquipData.ChuanShiCfgIndex(self.select_slot))
		equip_item_id = act_cfg and act_cfg.targetEquips
	else
		equip_item_id = equip_data.item_id
	end

	if nil == equip_item_id then
		return
	end

	self.equip:SetData({equip_item_id = equip_item_id})

	local item_cfg = ItemData.Instance:GetItemConfig(equip_item_id)
	local content = ""
	local mark = "\n      "

	content = content .. "{image;res/xui/common/orn_100.png;25,20}{color;ff7f00;基础属性}"
	local base_attr
	if equip_data then
		base_attr = EquipData.Instance:GetChuanShiBaseAttr(self.select_slot, true)
	else
		base_attr = ItemData.GetStaitcAttrs(item_cfg)
	end

	local base_content = RoleData.FormatAttrContent(EquipData.ChuanshiBaseAttrFilter(base_attr or {}), nil, mark)
	content = content .. mark .. base_content .. "\n\n"

	content = content .. "{image;res/xui/common/orn_100.png;25,20}{color;ff7f00;特殊属性}"
	content = content .. mark .. string.format("{color;ff2828;%s基础属性增加：%.2f%%}",
		Language.EquipTypeName[item_cfg.type] or "", nil ~= item_cfg.basePlus and (item_cfg.basePlus) or 0) .. "\n\n"

	local chuanshi_special_cfg = EquipData.GetChuanShiSpecialCfg(EquipData.ChuanShiCfgIndex(self.select_slot), equip_item_id)
	if chuanshi_special_cfg and chuanshi_special_cfg.skill_desc then
		content = content .. "{image;res/xui/common/orn_100.png;25,20}{color;ff7f00;特殊技能}\n" .. chuanshi_special_cfg.skill_desc
	end

	RichTextUtil.ParseRichText(self.node_t_list.rich_attr.node, content, nil, COLOR3B.OLIVE)

	self.fight_power_view:SetNumber(CommonDataManager.GetAttrSetScore(base_attr))
end
----------------------------------------------------------------
----------------------------------------------------------------
local ChuanShiEquipRender = BaseClass(BaseRender)
CSEquipInfoView.ChuanShiEquipRender = ChuanShiEquipRender
ChuanShiEquipRender.size = cc.size(80, 80)
function ChuanShiEquipRender:__init()
	self.view:setContentSize(ChuanShiEquipRender.size)

	self.cell = BaseCell.New()
	self.cell:SetPosition(ChuanShiEquipRender.size.width / 2, BaseCell.SIZE / 2)
	self.cell:SetAnchorPoint(0.5, 0.5)
	self.cell:SetIsShowTips(false)
	self.view:addChild(self.cell:GetView(), 10)
	self.click_cell_callback = nil
	self.cell:AddClickEventListener(function()
		if self.click_cell_callback then
			self.click_cell_callback(self)
		end
	end)
end

function ChuanShiEquipRender:__delete()
	if self.cell then
		self.cell:DeleteMe()
		self.cell = nil
	end
	self.click_cell_callback = nil
end

function ChuanShiEquipRender:CreateChild()
	ChuanShiEquipRender.super.CreateChild(self)

	self.rich_under = XUI.CreateRichText(ChuanShiEquipRender.size.width / 2, BaseCell.SIZE + 5, 300, 20)
	XUI.RichTextSetCenter(self.rich_under)
	self.rich_under:setAnchorPoint(0.5, 0)
	self.view:addChild(self.rich_under, 20)
end

function ChuanShiEquipRender:OnFlush()
	local equip_slot = -1
	local content = ""
	local equip_id = 0

	if self.data then
		equip_slot = self.data.slot
		equip_id = self.data.equip_item_id or 0
	end

	local equip_data = EquipData.Instance:GetEquipDataBySolt(equip_slot)
	if equip_data then
		equip_id = equip_data.item_id
	end

    if equip_id ~= 0 then
		local item_cfg = ItemData.Instance:GetItemConfig(equip_id)
		local item_color = string.format("%06x", item_cfg.color)
		content = string.format("{color;%s;%s}", item_color, item_cfg.name)

		self.cell:SetData({item_id = equip_id, num = 1, is_bind = 0})
	else
		self.cell:SetData()
    end

    RichTextUtil.ParseRichText(self.rich_under, content)
end

return CSEquipInfoView
