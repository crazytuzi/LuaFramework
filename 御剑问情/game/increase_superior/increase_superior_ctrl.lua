require("game/increase_superior/increase_superior_data")
require("game/increase_superior/increase_superior_view")
IncreaseSuperiorCtrl = IncreaseSuperiorCtrl or BaseClass(BaseController)

function IncreaseSuperiorCtrl:__init()
	if IncreaseSuperiorCtrl.Instance then
		print_error("[IncreaseSuperiorCtrl] Attemp to create a singleton twice !")
	end
	IncreaseSuperiorCtrl.Instance = self
	self.data = IncreaseSuperiorData.New()
	self.view = IncreaseSuperiorView.New(ViewName.IncreaseSuperiorView)
	self:RegisterAllProtocols()
end

function IncreaseSuperiorCtrl:__delete()

	self.view:DeleteMe()

	self.data:DeleteMe()

	IncreaseSuperiorCtrl.Instance = nil
end

function IncreaseSuperiorCtrl:RegisterAllProtocols()
	
end

function IncreaseSuperiorCtrl:OnRAIncreastCapabilityInfo(protocol)

end