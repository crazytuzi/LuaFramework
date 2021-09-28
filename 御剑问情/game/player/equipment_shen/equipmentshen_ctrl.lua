require("game/player/equipment_shen/equipmentshen_data")
-- 神装
EquipmentShenCtrl = EquipmentShenCtrl or BaseClass(BaseController)

function EquipmentShenCtrl:__init()
	if EquipmentShenCtrl.Instance then
		print_error("[EquipmentShenCtrl] 尝试生成第二个单例模式")
	end
	EquipmentShenCtrl.Instance = self

	self.equipment_data = EquipmentShenData.New()

	self:RegisterShenProtocols()
end

function EquipmentShenCtrl:__delete()
	if nil ~= self.equipment_data then
		self.equipment_data:DeleteMe()
		self.equipment_data = nil
	end

	EquipmentShenCtrl.Instance = nil
end

-- 注册协议
function EquipmentShenCtrl:RegisterShenProtocols()
	self:RegisterProtocol(CSShenzhaungOper)
	self:RegisterProtocol(SCShenzhaungInfo, "OnShenzhaungInfo")
end

function EquipmentShenCtrl:MainuiOpenShenCreate()
	EquipmentShenCtrl.ReqShenzhaungOpreate(SHENZHUANG_OPERATE_TYPE.REQ)
end

------------------------神装
-- 神装升级 index装备下标
function EquipmentShenCtrl:SendShenzhuangUpLevel(index)
	EquipmentShenCtrl.ReqShenzhaungOpreate(SHENZHUANG_OPERATE_TYPE.UPLEVEL, index)
end

function EquipmentShenCtrl.ReqShenzhaungOpreate(operate_type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSShenzhaungOper)
	protocol.operate_type = operate_type
	protocol.index = index or 0
	protocol:EncodeAndSend()
end

function EquipmentShenCtrl:OnShenzhaungInfo(protocol)
	self.equipment_data:SetActSuitId(protocol.act_suit_id)
	self.equipment_data:SetPartList(protocol.part_list)

	PlayerCtrl.Instance:FlushPlayerView("shen_equip_change")
	RemindManager.Instance:Fire(RemindName.ShenEquip)
end
