
local RexueZhulingView = BaseClass(SubView)

function RexueZhulingView:__init()
	self.texture_path_list = {
	}
	self.config_tab = {
		{"rexue_equip_ui_cfg", 4, {0}},
	}
end

function RexueZhulingView:__delete()
end

function RexueZhulingView:ReleaseCallBack()
	if self.equip then
		self.equip:DeleteMe()
		self.equip = nil
	end

	if self.select_item_list then
		self.select_item_list:DeleteMe()
		self.select_item_list = nil
	end

	if self.fight_power_view then
		self.fight_power_view:DeleteMe()
		self.fight_power_view = nil
	end

	if self.attr_view then
		self.attr_view:DeleteMe()
		self.attr_view = nil
	end
end

local ConsumeEquipCell = BaseClass(BaseCell)
function ConsumeEquipCell:__init()
	self:SetIsShowTips(false)
end
function ConsumeEquipCell:__delete()
end

function RexueZhulingView:LoadCallBack(index, loaded_times)
	self.equip = BaseCell.New()
	self.equip:SetPosition(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y)
	-- self.equip:SetIsShowTips(false)
	self.equip:SetAnchorPoint(0.5, 0.5)
	self.node_t_list.layout_zhuling.node:addChild(self.equip:GetView(), 10)

	self.fight_power_view = FightPowerView.New(self.ph_list.ph_cell.x, self.ph_list.ph_cell.y + 75, self.node_t_list.layout_zhuling.node, 99)
	
	self.node_t_list.btn_zhuling.node:setTitleText("注灵")
	self.node_t_list.btn_zhuling.node:setTitleFontName(COMMON_CONSTS.FONT)
	self.node_t_list.btn_zhuling.node:setTitleFontSize(22)
	self.node_t_list.btn_zhuling.node:setTitleColor(COLOR3B.G_W2)
	self.node_t_list.btn_zhuling.remind_eff = RenderUnit.CreateEffect(23, self.node_t_list.btn_zhuling.node, 1)

    XUI.RichTextSetCenter(self.node_t_list.rich_equip_name.node)

    local attr_view = AttrView.New(300, 25, 20)
	attr_view:SetDefTitleText("")
	attr_view:SetTextAlignment(RichHAlignment.HA_LEFT, RichVAlignment.VA_CENTER)
	attr_view:GetView():setPosition(self.ph_list.ph_attr.x, self.ph_list.ph_attr.y - 20)
	attr_view:GetView():setAnchorPoint(0.5, 0.5)
	attr_view:SetContentWH(self.ph_list.ph_attr.w, self.ph_list.ph_attr.h)
	self.node_t_list.layout_zhuling.node:addChild(attr_view:GetView(), 50)
	self.attr_view = attr_view

    self.select_item_list = ListView.New()
    local ph = self.ph_list.ph_item_list
    self.select_item_list:Create(ph.x, ph.y, ph.w, ph.h, ScrollDir.Horizontal, ConsumeEquipCell, nil, false)
    self.node_t_list.layout_zhuling.node:addChild(self.select_item_list:GetView(), 99)
	self.select_item_list:SetSelectCallBack(BindTool.Bind(self.SelectOneEquip, self))
	self.select_item_list:SetItemsInterval(10)

	XUI.AddClickEventListener(self.node_t_list.btn_zhuling.node, BindTool.Bind(self.OnClickZhuling, self))
	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.REXUE_ZHULING_DATA_CHANGE, BindTool.Bind(self.OnZhulingDataChange, self))
end

function RexueZhulingView:ShowIndexCallBack(index)
	self.select_slot = ViewDef.ReXueShiEquip._select_slot
	self:Flush()
end

function RexueZhulingView:OnFlush(param_t, index)
	self:FlushConsumeList()

	local equip = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	local zl_data = EquipData.Instance:GetRexueZhulingData(self.select_slot)

	self.equip:SetData(equip)
	RichTextUtil.ParseRichText(self.node_t_list.rich_equip_name.node, equip and ItemData.Instance:GetItemNameRich(equip.item_id) .. "Lv" .. zl_data.level or "", nil, COLOR3B.WHITE)

	local can_consume = false
	local consume_cfg = EquipData.GetRexueZhulingConsumeCfg(self.select_slot, zl_data.level + 1)
	if consume_cfg then
		local consume_val = consume_cfg.consume
		self.node_t_list.lbl_prog.node:setString(string.format("%d/%d", zl_data.val, consume_val))
		self.node_t_list.prog9_val_prog.node:setPercent(zl_data.val / consume_val * 100)

		can_consume = self.select_item_list:GetCount() > 0
	else
		self.node_t_list.lbl_prog.node:setString("已满级")
		self.node_t_list.prog9_val_prog.node:setPercent(100)
	end
	self.node_t_list.btn_zhuling.remind_eff:setVisible(can_consume)

	local attrs = EquipData.GetRexueZhulingAttrs(self.select_slot, zl_data.level)
	local next_attrs = EquipData.GetRexueZhulingAttrs(self.select_slot, zl_data.level + 1)

	self.fight_power_view:SetNumber(attrs and CommonDataManager.GetAttrSetScore(attrs) or 0)

	local plus_cfg = CommonDataManager.LerpAttributeAttr(attrs, next_attrs)
	if nil == attrs or nil == next(attrs) then
		attrs = CommonDataManager.MulAtt(plus_cfg, 0)
	end
	self.attr_view:SetData(attrs, plus_cfg)
end

function RexueZhulingView:SelectOneEquip(cell)
end

function RexueZhulingView:OnZhulingDataChange()
	self:Flush()
end

function RexueZhulingView:FlushConsumeList()
	local data = {}
	local item_type = EquipData.Instance:GetTypeByEquipSlot(self.select_slot)
	local consume_item_table = EquipData.GetRexueConsumeItemTable()
	for k, v in pairs(BagData.Instance:GetItemDataList(item_type)) do
		if consume_item_table[v.item_id] then
			data[#data + 1] = v
		end
	end
	self.select_item_list:SetDataList(data)
end

function RexueZhulingView:OnClickZhuling()
	local item = self.select_item_list:GetSelectItem()
	if item then
		if item:GetData() then
			EquipCtrl.SendRexueEquipZhulingOptReq(self.select_slot, {item:GetData()})
		end
	else
		SysMsgCtrl.Instance:FloatingTopRightText("{color;ff2828;请选择多余装备}")
	end
end

function RexueZhulingView:OnBagItemChange(vo)
	self:FlushConsumeList()
end

return RexueZhulingView
