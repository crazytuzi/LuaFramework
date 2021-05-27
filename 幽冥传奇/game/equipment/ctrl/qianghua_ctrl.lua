require("scripts/game/equipment/data/qianghua_data")

QianghuaCtrl = QianghuaCtrl or BaseClass(BaseController)

function QianghuaCtrl:__init()
	if QianghuaCtrl.Instance then
		ErrorLog("[QianghuaCtrl]:Attempt to create singleton twice!")
	end
	QianghuaCtrl.Instance = self
	self.data = QianghuaData.New()
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function QianghuaCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
    QianghuaCtrl.Instance = nil
end

function QianghuaCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCEquipstrengthenInfo, "OnEquipstrengthenInfo")
	self:RegisterProtocol(SCEquipstrengthenResult, "OnEquipstrengthenResult")
	self:RegisterProtocol(SCOneKeyStrengthenEquipResult, "OnOneKeyStrengthenEquipResult")
end

function QianghuaCtrl:OnRecvMainRoleInfo()
	self.SendEquipStrengthenInfoReq()
end

--下发装备槽强化数据(7, 15)
function QianghuaCtrl:OnEquipstrengthenInfo(protocol)
	self.data:SetStrengthList(protocol.strengthen_list)
end

--强化装备槽结果
function QianghuaCtrl:OnEquipstrengthenResult(protocol)
	self.data:StrengthenChange(protocol)
end

-- 一键强化装备槽结果
function QianghuaCtrl:OnOneKeyStrengthenEquipResult(protocol)
	if next(protocol.strengthen_list) then
		self.data:SetOneKeyStrengthList(protocol.strengthen_list)
	end
end

--请求装备槽强化数据
function QianghuaCtrl.SendEquipStrengthenInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipStrengthenInfoReq)
	protocol:EncodeAndSend()
end

--获得装备槽强化数据
function QianghuaCtrl:SendEquipStrengthen(slot, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSEquipStrengthen)
	protocol.slot = slot
	protocol.index = index
	protocol:EncodeAndSend()
end

--一键强化装备
function QianghuaCtrl.SendOneKeyStrengthen()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOnekeyStrenthenEquipReq)
	protocol:EncodeAndSend()
end