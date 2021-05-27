------------------------------------------------------------
-- 传世装备
------------------------------------------------------------
ChuanShiEquipView = ChuanShiEquipView or BaseClass(BaseView)

local Show_EffectId = {
--    id   特效id
	[223] = 115,--传世戒指
    [224] = 116,--传世腰带
    [225] = 117,--传世靴子
    [226] = 110,--星※传世神装·剑
    [227] = 111,--星※传世神装·甲
    [228] = 111,--星※传世神装·铠
    [229] = 112,--星※传世神装·盔
    [230] = 113,--星※传世神装·链
    [231] = 114,--星※传世神装·镯
    [232] = 115,--星※传世神装·戒
    [233] = 116,--星※传世神装·带
    [234] = 117,--星※传世神装·靴
    [235] = 110,--月※传世神装·剑
    [236] = 111,--月※传世神装·甲
    [237] = 111,--月※传世神装·铠
    [238] = 112,--月※传世神装·盔
    [239] = 113,--月※传世神装·链
    [240] = 114,--月※传世神装·镯
    [241] = 115,--月※传世神装·戒
    [242] = 116,--月※传世神装·带
    [243] = 117,--月※传世神装·靴
    [244] = 110,--日※传世神装·剑
    [245] = 111,--日※传世神装·甲
    [246] = 111,--日※传世神装·铠
    [247] = 112,--日※传世神装·盔
    [248] = 113,--日※传世神装·链
    [249] = 114,--日※传世神装·镯
    [250] = 115,--日※传世神装·戒
    [251] = 116,--日※传世神装·带
    [252] = 117,--日※传世神装·靴

}

function ChuanShiEquipView:__init()
	self:SetModal(true)
	self:SetBackRenderTexture(true)
	
	self.title_img_path = ResPath.GetWord("ChuanShiEquip")
	self.texture_path_list[1] = "res/xui/chuang_shi_equip.png"
	self.config_tab = {
		{"chuanshi_equip_ui_cfg", 1, {0}},
		-- {"chuanshi_equip_ui_cfg", 3, {0}},
		-- {"chuanshi_equip_ui_cfg", 2, {0}, nil, 999},
	}

	-- self.sub_view_list = {
	-- 	ViewDef.ChuanShiEquip.EquipInfo,
	-- 	ViewDef.ChuanShiEquip.UpLevel,
	-- 	ViewDef.ChuanShiEquip.UpGrade,
	-- 	ViewDef.ChuanShiEquip.Decompose,
	-- }

	-- require("scripts/game/equip/view/equip_info_view").New(ViewDef.ChuanShiEquip.EquipInfo)
	-- require("scripts/game/equip/view/chuanshi_uplevel_view").New(ViewDef.ChuanShiEquip.UpLevel)
	-- require("scripts/game/equip/view/chuanshi_upgrade_view").New(ViewDef.ChuanShiEquip.UpGrade)
	require("scripts/game/equip/view/chuanshi_blood_view").New(ViewDef.ChuanShiEquip.Blood)
	require("scripts/game/equip/view/chuanshi_show_view").New(ViewDef.ChuanShiEquip.Show)
	require("scripts/game/equip/view/chuanshi_decompose_view").New(ViewDef.ChuanShiEquip.Decompose)
	require("scripts/game/equip/view/chuanshi_compose_view").New(ViewDef.ChuanShiEquip.Compose)

	self.select_slot = 0
end

function ChuanShiEquipView:__delete()
end

function ChuanShiEquipView:ReleaseCallBack()
	if self.tabbar then
		self.tabbar:DeleteMe()
		self.tabbar = nil
	end
end

function ChuanShiEquipView:LoadCallBack(index, loaded_times)

	-- local name_list = {}
	-- for k, v in pairs(self.sub_view_list) do
	-- 	name_list[#name_list + 1] = v.name
	-- end
	-- self.tabbar = Tabbar.New()
	-- self.tabbar:CreateWithNameList(self.node_t_list.layout_chuanshi_equip.node, 455, 600, BindTool.Bind(self.SelectTabCallback, self),
	-- 	name_list, true, ResPath.GetCommon("btn_144"), 22	
	-- )
	-- self.tabbar:SetSpaceInterval(50)

	-- EventProxy.New(EquipData.Instance, self):AddEventListener(EquipData.CHUANSHI_DATA_CHANGE, BindTool.Bind(self.OnChuanshiDataChange, self))
	-- EventProxy.New(BagData.Instance, self):AddEventListener(BagData.BAG_ITEM_CHANGE, BindTool.Bind(self.OnBagItemChange, self))
end

function ChuanShiEquipView:OpenCallBack()
end

function ChuanShiEquipView:ShowIndexCallBack(index)
	-- self.select_slot = ViewDef.ChuanShiEquip._select_slot
	-- local title_res = ResPath.GetWord(string.format("word_chuanshi_%d", EquipData.Instance:GetTypeByEquipSlot(self.select_slot)))
	-- self:CreateTopTitle(title_res, self:GetRootNode():getContentSize().width / 2, 695)

	-- self:FlushTabbar()
end

function ChuanShiEquipView:OnFlush(param_t, index)
	-- self:FlushTabbar()
end

function ChuanShiEquipView:FlushTabbar()
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
			if v == ViewDef.ChuanShiEquip.UpLevel then
				self.tabbar:SetRemindByIndex(k, EquipData.Instance:GetChuanShiCanUpLevel(self.select_slot) > 0)
			elseif v == ViewDef.ChuanShiEquip.UpGrade then
				self.tabbar:SetRemindByIndex(k, EquipData.Instance:GetChuanShiCanUpGrade(self.select_slot) > 0)
			end
		end
	end
end

function ChuanShiEquipView:SelectTabCallback(index)
	ViewManager.Instance:OpenViewByDef(self.sub_view_list[index])
end

function ChuanShiEquipView:OnChuanshiDataChange(index)
	self:Flush()
end

function ChuanShiEquipView:OnBagItemChange()
	self:Flush()
end

return ChuanShiEquipView
