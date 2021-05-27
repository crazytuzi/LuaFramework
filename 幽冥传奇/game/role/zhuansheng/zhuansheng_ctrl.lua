require("scripts/game/role/zhuansheng/zhuansheng_data")

ZhuangShengCtrl = ZhuangShengCtrl or BaseClass(BaseController)

function ZhuangShengCtrl:__init()
	if ZhuangShengCtrl.Instance then
		ErrorLog("[ZhuangShengCtrl] attempt to create singleton twice!")
		return
	end
	ZhuangShengCtrl.Instance = self

	self.data = ZhuanshengData.New()

	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind1(self.OnRecvMainRoleInfo))
end

function ZhuangShengCtrl:__delete()
	ZhuangShengCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function ZhuangShengCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCExchangeCultivationRemainingTime, "OnExchangeCultivationRemainingTime")
	self:RegisterProtocol(SCPointInfo, "OnPointInfo")
	self:RegisterProtocol(SCReincarnationScuccess, "OnReincarnationScuccess")
end

function ZhuangShengCtrl:OnRecvMainRoleInfo()
	ZhuangShengCtrl.SendExchangeCultivationRemainingTimeReq()
	--ZhuangShengCtrl.SendInitPointReq()
end

function ZhuangShengCtrl:OnExchangeCultivationRemainingTime(protocol)
	--设置剩余次数
	self.data:SetLeftExchangeTimes(#Circle.CircleSoulExchange - protocol.cultivation_remaining_time)
end

function ZhuangShengCtrl:OnPointInfo(protocol)
	self.data:SetPointInfo(protocol)

end

function ZhuangShengCtrl:OnReincarnationScuccess(protocol)
	self.data:SetPointChange(protocol)
end

function ZhuangShengCtrl.SendExchangeCultivationRemainingTimeReq()
	-- local protocol = ProtocolPool.Instance:GetProtocol(CSExchangeCultivationRemainingTimeReq)
	-- protocol:EncodeAndSend()
end

function ZhuangShengCtrl.SendTurnReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSTurnReq)
	protocol:EncodeAndSend()
end

function ZhuangShengCtrl.SendExchangeTurnTimeReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSExchangeTurnTimeReq)
	protocol:EncodeAndSend()
end

function ZhuangShengCtrl.SendAddPointInfReq(point_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPointInfoReq)
	protocol.point_list = point_list
	protocol:EncodeAndSend()
end

function ZhuangShengCtrl.SendInitPointReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSInitPointReq)
	protocol:EncodeAndSend()
end
