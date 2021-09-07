require("game/cupmoonactivity/cup_moon_activity_view")
require("game/cupmoonactivity/cup_moon_activity_data")
CupMoonActivityCtrl = CupMoonActivityCtrl or BaseClass(BaseController)
function CupMoonActivityCtrl:__init()
	if CupMoonActivityCtrl.Instance then
		print_error("[CupMoonActivityCtrl] Attemp to create a singleton twice !")
	end
	CupMoonActivityCtrl.Instance = self
	self.data = CupMoonActivityData.New()
	self.view = CupMoonActivityView.New(ViewName.CupMoonActivityView) 
    self:RegisterAllProtocols()
end

function CupMoonActivityCtrl:__delete()
	CupMoonActivityCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end
function CupMoonActivityCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRATotalCharge5Info,"OnSCRATotalCharge5Info")
end

function CupMoonActivityCtrl:OnSCRATotalCharge5Info(protocol)
	self.data:SetMidAutumnCupInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
    RemindManager.Instance:Fire(RemindName.MidAutumnCupMoon) 
end


