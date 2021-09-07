-- require("game/advance/equipupgrade/advance_equip_up_view")
-- require("game/advance/equipupgrade/advance_equip_mount_view")
-- require("game/advance/equipupgrade/advance_equip_wing_view")
-- require("game/advance/equipupgrade/advance_equip_halo_view")
-- require("game/advance/equipupgrade/advance_equip_shengong_view")
-- require("game/advance/equipupgrade/advance_equip_shenyi_view")

AdvanceEquipUpCtrl = AdvanceEquipUpCtrl or BaseClass(BaseController)

function AdvanceEquipUpCtrl:__init()
	if AdvanceEquipUpCtrl.Instance ~= nil then
		print_error("[AdvanceEquipUpCtrl]:Attempt to create singleton twice!")
		return
	end
	AdvanceEquipUpCtrl.Instance = self

	-- self.equip_up_view = AdvanceEquipUpView.New(ViewName.AdvanceEquipUp)
	self:RegisterAllProtocols()
end

function AdvanceEquipUpCtrl:__delete()
	if self.equip_up_view ~= nil then
	   self.equip_up_view:DeleteMe()
	end
	AdvanceEquipUpCtrl.Instance = nil
end

function AdvanceEquipUpCtrl:RegisterAllProtocols()
	self:RegisterProtocol(CSMountUplevelEquip);
	self:RegisterProtocol(CSWingUplevelEquip);
	self:RegisterProtocol(CSHaloUplevelEquip);
	self:RegisterProtocol(CSShengongUplevelEquip);
	self:RegisterProtocol(CSShenyiUplevelEquip);
end

-- 发送坐骑装备升级请求
function AdvanceEquipUpCtrl:SendMountEquipUpLevelReq(equip_idx, is_only_one_level, is_only_bind, is_only_equip)
	print("SendMountEquipUpLevelReq equip_idx", equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSMountUplevelEquip)
	send_protocol.equip_idx = equip_idx
	send_protocol.is_only_one_level = is_only_one_level
	send_protocol.is_only_bind = is_only_bind
	send_protocol.is_only_equip = is_only_equip
	send_protocol:EncodeAndSend()
end

-- 发送羽翼装备升级请求
function AdvanceEquipUpCtrl:SendWingEquipUpLevelReq(equip_idx, is_only_one_level, is_only_bind, is_only_equip)
	print("SendWingEquipUpLevelReq equip_idx", equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSWingUplevelEquip)
	send_protocol.equip_idx = equip_idx
	send_protocol.is_only_one_level = is_only_one_level
	send_protocol.is_only_bind = is_only_bind
	send_protocol.is_only_equip = is_only_equip
	send_protocol:EncodeAndSend()
end

-- 发送光环装备升级请求
function AdvanceEquipUpCtrl:SendHaloEquipUpLevelReq(equip_idx, is_only_one_level, is_only_bind, is_only_equip)
	print("SendHaloEquipUpLevelReq equip_idx", equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSHaloUplevelEquip)
	send_protocol.equip_idx = equip_idx
	send_protocol.is_only_one_level = is_only_one_level
	send_protocol.is_only_bind = is_only_bind
	send_protocol.is_only_equip = is_only_equip
	send_protocol:EncodeAndSend()
end

-- 发送神弓装备升级请求
function AdvanceEquipUpCtrl:SendShengongEquipUpLevelReq(equip_idx, is_only_one_level, is_only_bind, is_only_equip)
	print("SendShengongEquipUpLevelReq equip_idx", equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShengongUplevelEquip)
	send_protocol.equip_idx = equip_idx
	send_protocol.is_only_one_level = is_only_one_level
	send_protocol.is_only_bind = is_only_bind
	send_protocol.is_only_equip = is_only_equip
	send_protocol:EncodeAndSend()
end

-- 发送神翼装备升级请求
function AdvanceEquipUpCtrl:SendShenyiEquipUpLevelReq(equip_idx, is_only_one_level, is_only_bind, is_only_equip)
	print("SendShenyiEquipUpLevelReq equip_idx", equip_idx)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSShenyiUplevelEquip)
	send_protocol.equip_idx = equip_idx
	send_protocol.is_only_one_level = is_only_one_level
	send_protocol.is_only_bind = is_only_bind
	send_protocol.is_only_equip = is_only_equip
	send_protocol:EncodeAndSend()
end

