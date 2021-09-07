require("game/marry_me/marry_me_view")
require("game/marry_me/marry_me_data")

MarryMeCtrl = MarryMeCtrl or BaseClass(BaseController)

function MarryMeCtrl:__init()
	if MarryMeCtrl.Instance ~= nil then
		print_error("[MarryMeCtrl] attempt to create singleton twice!")
		return
	end

	MarryMeCtrl.Instance = self
	self:RegisterAllProtocols()

	self.view = MarryMeView.New(ViewName.MarryMe)
	self.data = MarryMeData.New()

	self:BindGlobalEvent(LoginEventType.RECV_MAIN_ROLE_INFO, BindTool.Bind(self.MainRoleInfo, self))
end

function MarryMeCtrl:__delete()
	MarryMeCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function MarryMeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMarryMeAllInfo, "OnMarryMeAllInfo")
end

function MarryMeCtrl:OnMarryMeAllInfo(protocol)
	self.data:SetInfo(protocol)
	self.view:Flush()
end

function MarryMeCtrl:MainRoleInfo()
	RemindManager.Instance:Fire(RemindName.MarryMe)
end