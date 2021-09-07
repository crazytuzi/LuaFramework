require("game/increase_capability/increase_capability_data")
require("game/increase_capability/increase_capability_view")
IncreaseCapabilityCtrl = IncreaseCapabilityCtrl or BaseClass(BaseController)

function IncreaseCapabilityCtrl:__init()
	if IncreaseCapabilityCtrl.Instance then
		print_error("[IncreaseCapabilityCtrl] Attemp to create a singleton twice !")
	end
	IncreaseCapabilityCtrl.Instance = self
	self.data = IncreaseCapabilityData.New()
	self.view = IncreaseCapabilityView.New(ViewName.IncreaseCapabilityView)
	self:RegisterAllProtocols()
end

function IncreaseCapabilityCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	IncreaseCapabilityCtrl.Instance = nil
end

function IncreaseCapabilityCtrl:RegisterAllProtocols()
	
end

function IncreaseCapabilityCtrl:OnRAIncreastCapabilityInfo(protocol)

end