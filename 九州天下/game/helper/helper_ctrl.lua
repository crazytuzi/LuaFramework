require("game/helper/helper_data")
require("game/helper/helper_view")
HelperCtrl = HelperCtrl or BaseClass(BaseController)

function HelperCtrl:__init()
	if HelperCtrl.Instance then
		print_error("[HelperCtrl] Attemp to create a singleton twice !")
	end
	HelperCtrl.Instance = self
	self.data = HelperData.New()
	self.view = HelperView.New(ViewName.HelperView)
	self:RegisterAllProtocols()
end

function HelperCtrl:RegisterAllProtocols()
	
end

function HelperCtrl:__delete()
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	HelperCtrl.Instance = nil
end

function HelperCtrl:GetView()
	return self.view
end

function HelperCtrl:GetData()
	return self.data
end