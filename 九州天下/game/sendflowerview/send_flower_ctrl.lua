require("game/sendflowerview/send_flower_data")
require("game/sendflowerview/send_flower_view")
SendFlowerCtrl = SendFlowerCtrl or BaseClass(BaseController)

function SendFlowerCtrl:__init()
	if SendFlowerCtrl.Instance then
		print_error("[SendFlowerCtrl] Attemp to create a singleton twice !")
	end
	SendFlowerCtrl.Instance = self

	self.data = SendFlowerData.New()
	self.view = SendFlowerView.New(ViewName.SendFlowerView)
	self:RegisterAllProtocols()
end

function SendFlowerCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAQixiFlowerGiftInfo, "OnSCRAQixiFlowerGiftInfo")
end


function SendFlowerCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	SendFlowerCtrl.Instance = nil
end

function SendFlowerCtrl:OnSCRAQixiFlowerGiftInfo(protocol)
	self.data:SetInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.SendFlower)
end
