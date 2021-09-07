require("game/midautumn_exchange/mid_autumn_task_view")
require("game/midautumn_exchange/mid_autumn_task_data")

MidAutumnTaskCtrl = MidAutumnTaskCtrl or BaseClass(BaseController)
function MidAutumnTaskCtrl:__init()
	if MidAutumnTaskCtrl.Instance then
		print_error("[MidAutumnTaskCtrl] Attemp to create a singleton twice !")
	end
	MidAutumnTaskCtrl.Instance = self
	self.data = MidAutumnTaskData.New()
	self.view = MidAutumnTaskView.New(ViewName.MidAutumnTaskView)
	self:RegisterAllProtocols()	
end

function MidAutumnTaskCtrl:__delete()
	MidAutumnTaskCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function MidAutumnTaskCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAActiveTaskExchangeInfo, "OnSCMidAuActiveTaskInfo")
end

function MidAutumnTaskCtrl:OnSCMidAuActiveTaskInfo(protocol)
	self.data:SetExchangeInfo(protocol)
	self.view:Flush()
	RemindManager.Instance:Fire(RemindName.MidAutumnActTask)
end

