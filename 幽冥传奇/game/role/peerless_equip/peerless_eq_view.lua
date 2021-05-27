RoleView = RoleView or BaseClass(XuiBaseView)

function RoleView:PeerlessLoadCallBack()
	self:CreatePeerlessDisplay()
	self:CreatePeerlessEquip()
	self:CreatePeerlessAttrList()
	self.layout_hidesq_hook = self.node_tree.layout_peerless_info.layout_equip_peerless.layout_hidesq_hook
	self.layout_hidesq_hook.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickHideSqAuto, self)) 
	self.layout_hidesj_hook = self.node_tree.layout_peerless_info.layout_equip_peerless.layout_hidesj_hook
	self.layout_hidesj_hook.btn_nohint_checkbox.node:addClickEventListener(BindTool.Bind1(self.OnClickHideSjAuto, self)) 
	self.layout_hidesq_hook.img_hook.node:setVisible(RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.PEERLESS_WEAPON_HIDE))
	self.layout_hidesj_hook.img_hook.node:setVisible(RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.PEERLESS_DRESS_HIDE))

	EquipData.Instance:NotifyDataChangeCallBack(self.equip_data_change_fun)
	self.node_t_list.btn_open_exchange.node:addClickEventListener(BindTool.Bind(self.OnClickOpenExchange, self))
	self.node_t_list.btn_decompose.node:addClickEventListener(BindTool.Bind(self.OnClickDecompose, self))
	XUI.AddClickEventListener(self.node_t_list.img_eq_tips.node, BindTool.Bind(self.OnClickPeerlessEquipTip, self, 4))
	XUI.AddClickEventListener(self.node_t_list.img_strength_tips.node, BindTool.Bind(self.OnClickPeerlessEquipTip, self, 5))
	self:UpdateAddPeerlessTip()
end

function RoleView:PeerlessDelete()
	if EquipData.Instance then
		EquipData.Instance:UnNotifyDataChangeCallBack(self.equip_data_change_fun)
	end
	if self.peerless_role_display then
		self.peerless_role_display:DeleteMe()
		self.peerless_role_display = nil
	end
	if self.peerless_attr_list then
		self.peerless_attr_list:DeleteMe()
		self.peerless_attr_list = nil
	end
	if self.peerless_equip_grid then
		self.peerless_equip_grid:DeleteMe()
		self.peerless_equip_grid = nil
	end
	if self.peerless_cap then
		self.peerless_cap:DeleteMe()
		self.peerless_cap = nil
	end
end

function RoleView:OnClickHideSqAuto()
	if Status.NowTime - self.change_sq_time < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OperateFrequencyTip)
		return 
	end
	self.change_sq_time = Status.NowTime
	local vis = self.layout_hidesq_hook.img_hook.node:isVisible()
	self.layout_hidesq_hook.img_hook.node:setVisible(not vis)
	self.show_wuqi = vis and 0 or 1
	self.show_cloth = self.layout_hidesj_hook.img_hook.node:isVisible() and 1 or 0
	EquipCtrl.SendSetShowPeerlessReq(self.show_wuqi, self.show_cloth)
end

function RoleView:OnClickHideSjAuto()
	if Status.NowTime - self.change_sj_time < 1 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Common.OperateFrequencyTip)
		return 
	end
	self.change_sj_time = Status.NowTime
	local vis = self.layout_hidesj_hook.img_hook.node:isVisible()
	self.layout_hidesj_hook.img_hook.node:setVisible(not vis)
	self.show_cloth = vis and 0 or 1
	self.show_wuqi = self.layout_hidesq_hook.img_hook.node:isVisible() and 1 or 0
	EquipCtrl.SendSetShowPeerlessReq(self.show_wuqi, self.show_cloth)
end

function RoleView:CreatePeerlessAttrList()
	local ph = self.ph_list.ph_peerless_zhuattr_list
	self.peerless_attr_list = ListView.New()
	self.peerless_attr_list:Create(ph.x, ph.y, ph.w, ph.h, nil, PeerlessAttrItem, nil, nil, self.ph_list.ph_peerless_attr_item)
	self.peerless_attr_list:GetView():setAnchorPoint(0, 0)
	self.node_t_list.layout_peerless_info.node:addChild(self.peerless_attr_list:GetView(), 100)
	self.peerless_attr_list:SetItemsInterval(5)
	self.peerless_attr_list:SetJumpDirection(ListView.Top)
	local attr_cfg = PeerlessEqData.GetPeerLessAttr()
	self.peerless_attr_list:SetDataList(RoleData.FormatRoleAttrStr(attr_cfg))

	local cap_x, cap_y = self.node_tree.layout_peerless_info.img_peerless_cap.node:getPosition()
	self.peerless_cap = NumberBar.New()
	self.peerless_cap:SetRootPath(ResPath.GetMainui("num_"))
	self.peerless_cap:SetPosition(cap_x + 50, cap_y - 15)
	self.peerless_cap:SetSpace(-2)
	self.peerless_cap:SetNumber(CommonDataManager.GetAttrSetScore(attr_cfg))
	self.node_t_list.layout_peerless_info.node:addChild(self.peerless_cap:GetView(), 300, 300)
end

function RoleView:CreatePeerlessDisplay()
	self.peerless_role_display = RoleDisplay.New(self.node_t_list.layout_equip_peerless.node, 100, false, true, true, false, false, false)
	self.peerless_role_display:SetPosition(260, 270)
	self.peerless_role_display:SetScale(1.2)
	local mainrole = Scene.Instance:GetMainRole()
	if nil ~= mainrole then
		self.peerless_role_display:Reset(mainrole)
	end
end


function RoleView:CreatePeerlessEquip()
	--装备网格
	local pos_t = {}
	local celllist = {}
	for i = 0, 9 do
		local ph_cell= self.ph_list["ph_equip_cell_" .. i]
		if ph_cell ~= nil then
			pos_t[i] = {ph_cell.x, ph_cell.y}	-- 获取占位符的位置
			celllist[i] = {bg_ta = ResPath.GetEquipBg("cs_ta_" .. (i + 1))}
		end
	end

	self.peerless_equip_grid = BaseGrid.New()
	self.peerless_equip_grid:SetGridName("equip")
	local size = self.node_t_list.layout_equip_peerless.node:getContentSize()
	local grid_node = self.peerless_equip_grid:CreateCellsByPos({w = size.width + 20, h = size.height + 20}, pos_t)
	self.node_t_list.layout_equip_peerless.node:addChild(grid_node, 0)
	self.peerless_equip_grid:SetSelectCallBack(BindTool.Bind(self.SelectPeerlessCellCallBack, self))
	-- self.peerless_equip_grid:SetIsShowTips(false)
	self.peerless_equip_grid:SetCellSkinStyle(celllist)
	self.peerless_equip_grid:CanSelectNilData(true)

	for k,v in pairs(self.peerless_equip_grid:GetAllCell()) do
		v:SetRemind(BagData.Instance:GetMaxEquipByIndex(k + EquipData.EquipIndex.PeerlessWeaponPos) ~= nil, true)
	end

	self:FlushEquip()
end

function RoleView:SelectPeerlessCellCallBack(cell)
	local equip_index = cell.index + EquipData.EquipIndex.PeerlessWeaponPos
	if cell and cell:GetName() == "equip" then
		local max_data = BagData.Instance:GetMaxEquipByIndex(equip_index)
		if max_data then
			local item_cfg = ItemData.Instance:GetItemConfig(max_data.item_id)
			if item_cfg then
				local hand_pos = 0
				if equip_index == EquipData.EquipIndex.PeerlessBraceletPosR or equip_index == EquipData.EquipIndex.PeerlessRingPosR then
					hand_pos = 1
				end
				EquipCtrl.Instance:FitOutEquip(max_data, hand_pos)
			end
			return
		end
	end
	if cell ~= nil and cell:GetData() == nil then
		-- SysMsgCtrl.Instance:ErrorRemind(Language.Common.NormalEquipGetTip)
		return
	end
	--打开tip, 提示脱下装备
	if cell:GetName() == "equip" then
		TipCtrl.Instance:OpenItem(cell:GetData(), EquipTip.FROM_BAG_EQUIP, {fromIndex = equip_index})
	end
end

--主角身上的装备变化
function RoleView:OnEquipDataChange(is_list, item_id, index, reason)
	self:Flush(TabIndex.role_peerless, "equip_change")
end

function RoleView:PeerlessFlush(param_t)
	for k,v in pairs(param_t) do
		if k == "model_change" then
			local mainrole = Scene.Instance:GetMainRole()
			if nil ~= mainrole then
				self.peerless_role_display:Reset(mainrole)
			end
		elseif k == "equip_change" then
			self:FlushEquip()
			local attr_cfg = PeerlessEqData.GetPeerLessAttr()
			self.peerless_attr_list:SetDataList(RoleData.FormatRoleAttrStr(attr_cfg))
			self.peerless_cap:SetNumber(CommonDataManager.GetAttrSetScore(attr_cfg))
			self:UpdateAddPeerlessTip()
		elseif k == "sociaL_mask" then
			self.layout_hidesq_hook.img_hook.node:setVisible(RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.PEERLESS_WEAPON_HIDE))
			self.layout_hidesj_hook.img_hook.node:setVisible(RoleData.Instance:IsSocialMask(SOCIAL_MASK_DEF.PEERLESS_DRESS_HIDE))
		end
	end
end

function RoleView:UpdateAddPeerlessTip()
	local xuelian_level = RoleRuleData.GetXueLianTipsLevel()
	local peerless_suit_level = EquipData.Instance:GetPeerlessEquipLevel()
	if xuelian_level <= 0 then
		self.node_t_list.img_eq_tips.node:setGrey(true)
	else
		self.node_t_list.img_eq_tips.node:setGrey(false)
	end

	if peerless_suit_level <= 0 then
		self.node_t_list.img_strength_tips.node:setGrey(true)
	else
		self.node_t_list.img_strength_tips.node:setGrey(false)
	end
end

function RoleView:FlushEquip()
	local data_list = EquipData.Instance:GetDataList()
	local list = {}
	for i = EquipData.EquipIndex.PeerlessWeaponPos, EquipData.EquipIndex.PeerlessShoesPos do
		if data_list[i] then
			list[i - EquipData.EquipIndex.PeerlessWeaponPos] = data_list[i]
		end
	end
	self.peerless_equip_grid:SetDataList(list)
end

function RoleView:OnClickOpenExchange()
	ViewManager.Instance:Open(ViewName.Conversion)
end

function RoleView:OnClickDecompose()
	ViewManager.Instance:Open(ViewName.Decompose)
end


function RoleView:OnClickPeerlessEquipTip(tips_type)
	ViewManager.Instance:Open(ViewName.RoleRule, tips_type)
	local data = {}
	if tips_type == 4 then
		local blood_mixing_tip_level = RoleRuleData.GetXueLianTipsLevel()
		local strenth_level = EquipmentData.Instance:GetAllBmStrengthLevel()
		data = {tiptype = tips_type, level = blood_mixing_tip_level, blood_mixing_level = strenth_level}
	elseif tips_type == 5 then
		local suit_level = EquipData.Instance:GetPeerlessEquipLevel()
		local suit_count_min = RoleRuleData.GetPeerlessSuitNum(1)
		local suit_count_max = RoleRuleData.GetPeerlessSuitNum(#RoleRuleData.Instance:GetPeerlessSuitPlusConfig())
		local suit_next_count = RoleRuleData.GetPeerlessSuitNum(suit_level + 1)
		local suit_cur_data = RoleRuleData.Instance:GetPeerlessSuitData(suit_level)
		local suit_next_data = RoleRuleData.Instance:GetPeerlessSuitData(suit_level+1)
		data = {tiptype = tips_type, level = suit_level, min_count = suit_count_min, max_count = suit_count_max, next_count = suit_next_count, tab = suit_cur_data, tab_1 = suit_next_data}
	end
	ViewManager.Instance:FlushView(ViewName.RoleRule, 0, nil, data)
end

----------------------------------------------------------------------------------------------------
-- 绝世神装属性item
----------------------------------------------------------------------------------------------------
PeerlessAttrItem = PeerlessAttrItem or BaseClass(BaseRender)
function PeerlessAttrItem:__init()
end

function PeerlessAttrItem:CreateChild()
	BaseRender.CreateChild(self)
end

function PeerlessAttrItem:OnFlush()
	if self.data == nil then return end
	self.node_tree.lbl_attr_name.node:setString(self.data.type_str .. "：")
	self.node_tree.lbl_attr_value.node:setString(self.data.value_str)
end

function PeerlessAttrItem:CreateSelectEffect()
end
