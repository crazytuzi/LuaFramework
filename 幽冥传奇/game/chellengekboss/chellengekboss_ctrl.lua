require("scripts/game/chellengekboss/chellengekboss_data")
require("scripts/game/chellengekboss/chellengekboss_view")

ChellengeKBossCtrl = ChellengeKBossCtrl or BaseClass(BaseController)

function ChellengeKBossCtrl:__init()
	if ChellengeKBossCtrl.Instance then
		ErrorLog("[ChellengeKBossCtrl] attempt to create singleton twice!")
		return
	end
	ChellengeKBossCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function ChellengeKBossCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	ChellengeKBossCtrl.Instance = nil
end	

function ChellengeKBossCtrl:RegisterAllProtocols()
	-- self:RegisterProtocol(SCTodayPrayMoneyDataIss, "OnTodayPrayMoneyDataIss")
end

function ChellengeKBossCtrl:CreateRelatedObjs()
	self.data = ChellengeKBossData.New()
	self.view = ChellengeKBossView.New(ViewName.ChellengeKBoss)
end

function ChellengeKBossCtrl:OnTodayPrayMoneyDataIss(protocol)
	self.data:SetPrayMoneyData(protocol)
	self.view:Flush()
end

function ChellengeKBossCtrl:BossReq()
	local protocol = ProtocolPool.Instance:GetProtocol(CSKuangChellengeBossReq)
	protocol:EncodeAndSend()
end