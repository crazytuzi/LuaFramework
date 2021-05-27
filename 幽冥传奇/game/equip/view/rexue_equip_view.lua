------------------------------------------------------------
-- 热血装备
------------------------------------------------------------
RexueEquipView = RexueEquipView or BaseClass(BaseView)

function RexueEquipView:__init()
	self:SetModal(true)
	self.texture_path_list = {
	}
	self.config_tab = {
		{"rexue_equip_ui_cfg", 1, {0}},
		{"rexue_equip_ui_cfg", 2, {0}, nil, 999},
	}

	self.sub_view_list = {
		ViewDef.ReXueShiEquip.EquipInfo,
		ViewDef.ReXueShiEquip.Zhuling,
		ViewDef.ReXueShiEquip.Fumo,
	}

	require("scripts/game/equip/view/rexue_equip_info_view").New(ViewDef.ReXueShiEquip.EquipInfo)
	require("scripts/game/equip/view/rexue_zhuling_view").New(ViewDef.ReXueShiEquip.Zhuling)
	require("scripts/game/equip/view/rexue_fumo_view").New(ViewDef.ReXueShiEquip.Fumo)

	self.select_slot = 0
end

function RexueEquipView:__delete()
end

function RexueEquipView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function RexueEquipView:LoadCallBack(index, loaded_times)
	local name_list = {}
	for k, v in pairs(self.sub_view_list) do
		name_list[#name_list + 1] = v.name
	end
	self.tabbar = Tabbar.New()
	self.tabbar:CreateWithNameList(self.node_t_list.layout_bg.node, 465, 650, BindTool.Bind(self.SelectTabCallback, self),
		name_list, true, ResPath.GetCommon("btn_144"), 22
	)
	self.tabbar:SetSpaceInterval(40)

	EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
	EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.REXUE_ZHULING_DATA_CHANGE, BindTool.Bind(self.OnZhulingDataChange, self))
end

function RexueEquipView:OpenCallBack()
end

function RexueEquipView:ShowIndexCallBack(index)
	self:CreateTopTitle(ResPath.GetWord("word_rexue_tip_" .. (ViewDef.ReXueShiEquip._select_slot or EquipData.EquipSlot.itWarmBloodDivineswordPos)), self:GetRootNode():getContentSize().width / 2, 695)
	self.select_slot = ViewDef.ReXueShiEquip._select_slot

	self:FlushTabbar()
end

function RexueEquipView:FlushTabbar()
	local equip = EquipData.Instance:GetEquipDataBySolt(self.select_slot)
	if nil == equip then
		self.tabbar:SetVisible(false)
	else
		self.tabbar:SetVisible(true)
		for k, v in pairs(self.sub_view_list) do
			if ViewManager.Instance:IsOpen(v) then
				-- 当前选中的tabbar
				self.tabbar:ChangeToIndex(k)
			end
			-- 提醒
			if v == ViewDef.ReXueShiEquip.Zhuling then
				self.tabbar:SetRemindByIndex(k, EquipData.Instance:GetRexueCanZhuling(self.select_slot) > 0)
			elseif v == ViewDef.ReXueShiEquip.Fumo then
				self.tabbar:SetRemindByIndex(k, EquipData.Instance:GetRexueCanFumo(self.select_slot) > 0)
			end
		end
	end
end

function RexueEquipView:OnFlush(param_t, index)
	self:FlushTabbar()
end

function RexueEquipView:SelectTabCallback(index)
	ViewManager.Instance:OpenViewByDef(self.sub_view_list[index])
end

function RexueEquipView:OnZhulingDataChange()
	self:Flush()
end

function RexueEquipView:OnBagItemChange()
	self:Flush()
end

return RexueEquipView
