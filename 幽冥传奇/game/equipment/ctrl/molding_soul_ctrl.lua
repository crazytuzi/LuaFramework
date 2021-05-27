require("scripts/game/equipment/data/molding_soul_data")

MoldingSoulCtrl = MoldingSoulCtrl or BaseClass(BaseController)
function MoldingSoulCtrl:__init()
	if MoldingSoulCtrl.Instance then
		ErrorLog("[MoldingSoulCtrl]:Attempt to create singleton twice!")
	end
	MoldingSoulCtrl.Instance = self
	self.data = MoldingSoulData.New()
	self:RegisterAllProtocols()
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo, self))
end

function MoldingSoulCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil
    MoldingSoulCtrl.Instance = nil
end

function MoldingSoulCtrl:RegisterAllProtocols()
    self:RegisterProtocol(SCMsStrengthInfo, "OnMoldingSoulInfo")
	self:RegisterProtocol(SCMoldingSoulResult, "OnMoldingSoulResult")
	self:RegisterProtocol(SCMsStrengthOneKeyInfo, "OnMoldingSoulOneKeyInfo")
end

function MoldingSoulCtrl:OnRecvMainRoleInfo()
	self.SendMsStrengthenInfoReq()
end

-- 请求铸魂数据
function MoldingSoulCtrl.SendMsStrengthenInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetMoldingSoulInfo)
	protocol:EncodeAndSend()
end

-- 接收铸魂信息数据(7, 24)
function MoldingSoulCtrl:OnMoldingSoulInfo(protocol)
	self.data:SetEquipSoulInfo(protocol.ms_strength_list)
end

-- 下发一键铸魂信息数据
function MoldingSoulCtrl:OnMoldingSoulOneKeyInfo(protocol)
	if next(protocol.ms_strength_list) then
		self.data:SetEquipSoulOneKeyInfo(protocol.ms_strength_list)
	end
end

--请求铸魂(7, 21)
function MoldingSoulCtrl.SendMsStrengthen()
	local protocol = ProtocolPool.Instance:GetProtocol(CSMoldingSoulReq)
	protocol:EncodeAndSend()
end


--请求一键铸魂
function MoldingSoulCtrl.OneKeyMoldingSoulReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSOneKeyMoldingSoulReq)
	protocol:EncodeAndSend()
end

-- 铸魂结果
function MoldingSoulCtrl:OnMoldingSoulResult(protocol)
	self.data:ChangeEqSoulLevel(protocol.slot + 1, protocol.strengthen_level)
end