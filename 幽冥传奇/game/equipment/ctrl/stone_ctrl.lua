require("scripts/game/equipment/data/stone_data")

StoneCtrl = StoneCtrl or BaseClass(BaseController)
function StoneCtrl:__init()
	if StoneCtrl.Instance then
		ErrorLog("[StoneCtrl]:Attempt to create singleton twice!")
	end
	StoneCtrl.Instance = self
	self.data = StoneData.New()
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function StoneCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
    StoneCtrl.Instance = nil
end

function StoneCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCEquipInsetInfo, "OnEquipInsetInfo")
	self:RegisterProtocol(SCEquipInsetResult, "OnEquipInsetResult")
	self:RegisterProtocol(SCEquipUnloadStoneResult, "OnEquipUnloadStoneResult")
	self:RegisterProtocol(SCStoneUpgradeResult, "OnStoneUpgradeResult")
end

function StoneCtrl:OnRecvMainRoleInfo()
	self.SendEquipInsetInfoReq()
end

-- 宝石镶嵌结果(7, 26)
function StoneCtrl:OnEquipInsetResult(protocol)
	self.data:ChangeEquipInsetInfo(protocol.equip_slot, protocol.stone_slot, protocol.stone_index, protocol.stone_is_blind)
end

function StoneCtrl:OnStoneUpgradeResult(protocol)
	local equip_inset_info =StoneData.Instance:GetEquipInsetInfo()
	local stone_info = equip_inset_info[protocol.equip_slot][protocol.stone_slot]
	self.data:ChangeEquipInsetInfo(protocol.equip_slot, protocol.stone_slot, stone_info.stone_index + 1)
end

-- 下发宝石镶嵌信息(7, 27)
function StoneCtrl:OnEquipInsetInfo(protocol)
	self.data:SetEquipInsetInfo(protocol.stone_info)
	EquipData.Instance:SetGemLevel()
end

-- 卸下宝石结果(7, 29)
function StoneCtrl:OnEquipUnloadStoneResult(protocol)
	self.data:ChangeEquipInsetInfo(protocol.equip_slot, protocol.stone_slot, 0)
end

--装备镶嵌宝石(7, 23)
function StoneCtrl.SendEquipInlayGemReq(equip_slot, stone_slot, stone_series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipInsetReq)
	protocol.equip_slot = equip_slot
	protocol.stone_slot = stone_slot
	protocol.stone_series = stone_series
	protocol:EncodeAndSend()
end


-- 请求宝石镶嵌信息(7, 24)
function StoneCtrl.SendEquipInsetInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipInsetInfoReq)
	protocol:EncodeAndSend()
end

--卸下宝石(7, 27)
function StoneCtrl.SendEquipUnloadStoneReq(equip_slot, stone_slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipUnloadStoneReq)
	protocol.equip_slot = equip_slot
	protocol.stone_slot = stone_slot
	protocol:EncodeAndSend()
end

--请求宝石升级(7, 29)
function StoneCtrl.SendStoneUpgradeReq(equip_slot, stone_slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStoneUpgrade)
	protocol.equip_slot = equip_slot
	protocol.stone_slot = stone_slot
	protocol:EncodeAndSend()
end
