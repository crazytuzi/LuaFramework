require("game/moonlight_landing/moonlight_landing_data")
require("game/moonlight_landing/moonlight_landing_view")

MoonLightLandingCtrl = MoonLightLandingCtrl or BaseClass(BaseController)

function MoonLightLandingCtrl:__init()
	if MoonLightLandingCtrl.Instance then
		print_error("[MoonLightLandingCtrl] Attemp to create a singleton twice !")
	end
	MoonLightLandingCtrl.Instance = self

	self.view = MoonLightLandingView.New(ViewName.MoonLightLandingView)
	self.data = MoonLightLandingData.New()
	self:RegisterAllProtocols()
end

function MoonLightLandingCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end   
	MoonLightLandingCtrl.Instance = nil
end

function MoonLightLandingCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRALjdlAllInfo, "OnSCRALjdlAllInfo")
end

function MoonLightLandingCtrl:OnSCRALjdlAllInfo(protocol)
	self.data:SetMoonLightLanding(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end

	RemindManager.Instance:Fire(RemindName.MoonLightLanding)
end

function MoonLightLandingCtrl:SendLotteryInfo(operate_type, param1, param2)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSRandActivityOperaReq)
	send_protocol.rand_activity_type = ACTIVITY_TYPE.RAND_ACTIVITY_TYPE_MIDAUTUMN				
	send_protocol.opera_type = operate_type or 0
	send_protocol.param_1 = param1 or 0
	send_protocol.param_2 = param2 or 0
	send_protocol:EncodeAndSend()	
end