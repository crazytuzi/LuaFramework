require("scripts/game/pray/pray_data")
require("scripts/game/pray/pray_view")

PrayCtrl = PraCtrl or BaseClass(BaseController)

function PrayCtrl:__init()
	if PrayCtrl.Instance then
		ErrorLog("[PrayCtrl] attempt to create singleton twice!")
		return
	end
	PrayCtrl.Instance = self

	self:CreateRelatedObjs()
	self:RegisterAllProtocols()

end

function PrayCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	PrayCtrl.Instance = nil
end	

function PrayCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCTodayPrayMoneyDataIss, "OnTodayPrayMoneyDataIss")
end

function PrayCtrl:CreateRelatedObjs()
	self.data = PrayData.New()
	self.view = PrayView.New(ViewName.Pray)
end

function PrayCtrl:OnTodayPrayMoneyDataIss(protocol)
	self.data:SetPrayMoneyData(protocol)
	self.view:Flush()
end

function PrayCtrl:PrayMoneyReq(req_type,do_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTodayPrayMoneyInfoReq)
	protocol.req_type = req_type or 0
	protocol.do_type = do_type or 1
	protocol:EncodeAndSend()
end