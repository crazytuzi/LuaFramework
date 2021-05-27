require("scripts/game/equip_compose/eq_compose_view")
require("scripts/game/equip_compose/eq_compose_data")


-- 装备合成
EqComposeCtrl = EqComposeCtrl or BaseClass(BaseController)

function EqComposeCtrl:__init()
	if EqComposeCtrl.Instance then
		ErrorLog("[EqComposeCtrl] attempt to create singleton twice!")
		return
	end
	EqComposeCtrl.Instance =self

	self.data = EqComposeData.New()
	self.view = EqComposeView.New(ViewName.EqCompose)
	
	self.itemdata_change_callback = BindTool.Bind(self.OnItemDataChange, self)
	self.itemconfig_change_callback = BindTool.Bind(self.OnItemConfigChange, self)
	self.role_data_event = BindTool.Bind(self.OnRoleDataChanged, self)
	self:RegisterAllProtocals()
end

function EqComposeCtrl:__delete()
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	ItemData.Instance:UnNotifyDataChangeCallBack(self.itemdata_change_callback)
	ItemData.Instance:UnNotifyItemConfigCallBack(self.itemconfig_change_callback)
	RoleData.Instance:UnNotifyAttrChange(self.role_data_event)
	EqComposeCtrl.Instance = nil
end

function EqComposeCtrl:RegisterAllProtocals()
	self:RegisterProtocol(SCComposeEquipResult,"OnComposeEquipResult")

	ItemData.Instance:NotifyDataChangeCallBack(self.itemdata_change_callback)
	ItemData.Instance:NotifyItemConfigCallBack(self.itemconfig_change_callback)
	RoleData.Instance:NotifyAttrChange(self.role_data_event)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindEqComposeSign, self), RemindName.StoneCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindEqComposeSign, self), RemindName.GodEquipmentCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindEqComposeSign, self), RemindName.ExtantCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindEqComposeSign, self), RemindName.ExtantDecompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindEqComposeSign, self), RemindName.EquipCompose)
	RemindManager.Instance:RegisterCheckRemind(BindTool.Bind(self.GetRemindEqComposeSign, self), RemindName.PetEquipCompose)
	GlobalEventSystem:Bind(OtherEventType.REMIND_CAHANGE, BindTool.Bind(self.OnRemindChange, self))
end

function EqComposeCtrl:OnComposeEquipResult(protocol)
	if protocol.item_type ~= nil then
		self.view:Flush(self.view:GetShowIndex(), "compose_succ")
	end
	GlobalEventSystem:Fire(KnapsackEventType.KNAPSACK_COMPOSE_EQUIP, protocol.item_type, protocol.result)
end

function EqComposeCtrl:OnItemDataChange(change_type, change_item_id)
	RemindManager.Instance:DoRemind(RemindName.StoneCompose)
	RemindManager.Instance:DoRemind(RemindName.GodEquipmentCompose)
	RemindManager.Instance:DoRemind(RemindName.ExtantCompose)
	RemindManager.Instance:DoRemind(RemindName.ExtantDecompose)
	RemindManager.Instance:DoRemind(RemindName.EquipCompose)
	RemindManager.Instance:DoRemind(RemindName.PetEquipCompose)
	self.view:Flush(self.view:GetShowIndex(), "itemdata_chage")
end

function EqComposeCtrl:OnItemConfigChange()
	
end

function EqComposeCtrl:OnRoleDataChanged(key, value)
	if key == OBJ_ATTR.CREATURE_LEVEL 
		or key == OBJ_ATTR.ACTOR_CIRCLE
		or key == OBJ_ATTR.ACTOR_VIP_GRADE then
		-- self.data:SetComposeTypeDataList(TabIndex.eqcompose_stone)
		-- self.data:SetComposeTypeDataList(TabIndex.eqcompose_god)
		-- self.data:SetComposeTypeDataList(TabIndex.eqcompose_cp_extant)
		-- self.data:SetComposeTypeDataList(TabIndex.eqcompose_dp_extant)
		self.data:SetComposeTypeDataList(TabIndex.eqcompose_dp_equip)
		self.data:SetComposeTypeDataList(TabIndex.eqcompose_equip)
	end
end

function EqComposeCtrl:OnRemindChange(remind_name, num)
	if remind_name == RemindName.StoneCompose then
		self.data:SetTabbarRemindNum(TabIndex.eqcompose_stone, num)
	elseif remind_name == RemindName.GodEquipmentCompose then
		self.data:SetTabbarRemindNum(TabIndex.eqcompose_god, num)
	elseif remind_name == RemindName.ExtantCompose then
		self.data:SetTabbarRemindNum(TabIndex.eqcompose_cp_extant, num)
	elseif remind_name == RemindName.ExtantDecompose then
		self.data:SetTabbarRemindNum(TabIndex.eqcompose_dp_extant, num)
	elseif remind_name == RemindName.PetEquipCompose then
		self.data:SetTabbarRemindNum(TabIndex.eqcompose_pet, num)
	end
	self.view:Flush(0, "remind_change")
end

-- 装备合成
function EqComposeCtrl.SendComposeEquipGem(compose_type, compose_index, item_index, stone_type, item_id, is_onekey_compose)
	local protocol = ProtocolPool.Instance:GetProtocol(CSComposeEquipGem)
	protocol.compose_type = compose_type
	protocol.compose_index = compose_index 
	protocol.item_index = item_index
	protocol.stone_type = stone_type
	protocol.item_id = item_id
	protocol.is_onekey_compose = is_onekey_compose
	protocol:EncodeAndSend()
end

function EqComposeCtrl:GetRemindEqComposeSign(remind_name)
	if remind_name == RemindName.StoneCompose then
		return self.data:GetCanCompose(TabIndex.eqcompose_stone)
	elseif remind_name == RemindName.GodEquipmentCompose then
		return self.data:GetCanCompose(TabIndex.eqcompose_god)
	elseif remind_name == RemindName.ExtantCompose then
		return self.data:GetCanCompose(TabIndex.eqcompose_cp_extant)
	elseif remind_name == RemindName.ExtantDecompose then
		return self.data:GetCanCompose(TabIndex.eqcompose_dp_extant)
	elseif remind_name == RemindName.EquipCompose then
		return self.data:GetCanCompose(TabIndex.eqcompose_equip)
	elseif remind_name == RemindName.PetEquipCompose then
		return self.data:GetCanCompose(TabIndex.eqcompose_pet)
	end
end

