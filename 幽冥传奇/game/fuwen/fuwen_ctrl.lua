require("scripts/game/fuwen/fuwen_data")
--------------------------------------------------------------
--符文相关
--------------------------------------------------------------
FuwenCtrl = FuwenCtrl or BaseClass(BaseController)
function FuwenCtrl:__init()
	if FuwenCtrl.Instance then
		ErrorLog("[FuwenCtrl] Attemp to create a singleton twice !")
	end
	FuwenCtrl.Instance = self
	
	self.fuwen_data = FuwenData.New()
	self:RegisterAllProtocols()
end

function FuwenCtrl:__delete()
	FuwenCtrl.Instance = nil

	self.fuwen_data:DeleteMe()
	self.fuwen_data = nil
end

function FuwenCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCUpFuwenResultAck, "OnUpFuwenResultAck")
	self:RegisterProtocol(SCFuwenEquipResultAck, "OnFuwenEquipResultAck")
	self:RegisterProtocol(SCFuwenInfo, "OnFuwenInfo")
	self:RegisterProtocol(SCFuwenStatetAck, "OnFuwenStatetAck")
end

function FuwenCtrl:OnRecvMainRoleInfo()
end

function FuwenCtrl:OnUpFuwenResultAck(protocol)
	self.fuwen_data:ChangeFuwenlv(protocol.fuwen_index, protocol.level)
end

function FuwenCtrl:OnFuwenEquipResultAck(protocol)
	self.fuwen_data:EquipOneFuwen(protocol)
end

function FuwenCtrl:OnFuwenTakeOffResultAck(protocol)
	self.fuwen_data:TakeOffOneFuwen(protocol)
end

function FuwenCtrl:OnFuwenInfo(protocol)
	self.fuwen_data:SetFuwenInfo(protocol)
end

function FuwenCtrl:OnFuwenStatetAck(protocol)
	self.fuwen_data:SetZhulingActState(protocol.state)
end

--符文注灵
function FuwenCtrl.SendUpFuwenReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpFuwenReq)
	protocol:EncodeAndSend()
end

--装上符文碎片
function FuwenCtrl.SendFuwenEquipReq(guid)
	local protocol = ProtocolPool.Instance:GetProtocol(CSFuwenEquipReq)
	protocol.guid = guid
	protocol:EncodeAndSend()
end

--卸下符文碎片
-- function FuwenCtrl.SendFuwenTakeOffReq(boss_index, fuwen_index)
-- 	local protocol = ProtocolPool.Instance:GetProtocol(CSFuwenTakeOffReq)
-- 	protocol.boss_index = boss_index
-- 	protocol.fuwen_index = fuwen_index
-- 	protocol:EncodeAndSend()
-- end

--获取符文信息
function FuwenCtrl.SendGetFuwenInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFuwenInfoReq)
	protocol:EncodeAndSend()
end

--获取符文套状态
function FuwenCtrl.SendGetFuwenStateReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSGetFuwenStateReq)
	protocol:EncodeAndSend()
end
