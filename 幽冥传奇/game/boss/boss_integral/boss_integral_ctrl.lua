require("scripts/game/boss/boss_integral/boss_integral_data")

BossIntegralCtrl = BossIntegralCtrl or BaseClass(BaseController)

function BossIntegralCtrl:__init()
	if	BossIntegralCtrl.Instance then
		ErrorLog("[BossIntegralCtrl]:Attempt to create singleton twice!")
	end
    BossIntegralCtrl.Instance = self
    
	self.data = BossIntegralData.New()
	self:RegisterAllProtocols()
	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.OnRecvMainRoleInfo))
end

function BossIntegralCtrl:__delete()
    BossIntegralCtrl.Instance = nil
end

function BossIntegralCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCCrestInfo, "OnCrestInfo")
	-- self:RegisterProtocol(SCUpCrestSlotResult, "OnUpCrestSlotResult")
end

function BossIntegralCtrl:OnRecvMainRoleInfo()
	-- GlobalTimerQuest:AddDelayTimer(function ()
	-- 	BossIntegralCtrl.SendCrestInfoReq()
	-- 	end, 2)
end

function BossIntegralCtrl:OnCrestInfo(protocol)
	--self.data:SetCrestInfo(protocol)
end

function BossIntegralCtrl:OnUpCrestSlotResult(protocol)
	--self.data:SetCrestSlotLevel(protocol)
end

function BossIntegralCtrl.SendCrestInfoReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSCrestInfoReq)
	protocol:EncodeAndSend()
end

function BossIntegralCtrl.SendUpCrestSlotReq(slot)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpCrestSlotReq)
	protocol.crest_slot = slot
	protocol:EncodeAndSend()
end
