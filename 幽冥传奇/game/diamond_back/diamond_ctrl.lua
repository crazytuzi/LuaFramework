require("scripts/game/diamond_back/diamond_data")
require("scripts/game/diamond_back/diamond_view")

DiamondBackCtrl = DiamondBackCtrl or BaseClass(BaseController)

function DiamondBackCtrl:__init()
	if	DiamondBackCtrl.Instance then
		ErrorLog("[DiamondBackCtrl]:Attempt to create singleton twice!")
	end
    DiamondBackCtrl.Instance = self
    
	self.data = DiamondBackData.New()
	self.view = DiamondBackView.New(ViewDef.DiamondBackView)
	self:RegisterAllProtocols()
end

function DiamondBackCtrl:__delete()
    DiamondBackCtrl.Instance = nil
end

function DiamondBackCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCOneEquipLimitData, "OnOneEquipLimitData")
	self:RegisterProtocol(SCBossFirstKillData, "OnBossFirstKillData")
	self:RegisterProtocol(SCOneForeverBackData, "OnOneForeverBackData")
	self:RegisterProtocol(SCSuitLimitData, "OnSuitLimitData")
	self:RegisterProtocol(SCBackRecord, "OnBackRecord")
	GlobalEventSystem:Bind(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.RecvMainRoleInfo, self))
end

function DiamondBackCtrl:RecvMainRoleInfo()
	-- 请求单件永久回收
	DiamondBackCtrl.Instance:SendBackData(3)
end

-- 请求 钻石回收操作
function DiamondBackCtrl:SendDiamondBackReq(type, index)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiamondBackReq)
	protocol.back_type = type
	protocol.back_index = index
	protocol:EncodeAndSend()
end

-- 申请钻石回收数据
function DiamondBackCtrl:SendBackData(type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSDiamondBackData)
	protocol.dia_type = type
	protocol:EncodeAndSend()
end

-- 接收单件限时首爆数据 (139, 206)
function DiamondBackCtrl:OnOneEquipLimitData(protocol)
	self.data:GetOneEquipLimitData(protocol)
end

function DiamondBackCtrl:OnBossFirstKillData(protocol)
	self.data:GetBossKillInfo(protocol)
end

function DiamondBackCtrl:OnOneForeverBackData(protocol)
	self.data:GetOneForeverBackData(protocol)
end

function DiamondBackCtrl:OnSuitLimitData(protocol)
	self.data:GetSuitLimitBack(protocol)
end

function DiamondBackCtrl:OnBackRecord(protocol)
	self.data:GetRecordData(protocol)
end