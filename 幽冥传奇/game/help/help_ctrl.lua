require("scripts/game/help/help_view")
require("scripts/game/help/help_data")

-- 小助手
HelpCtrl = HelpCtrl or BaseClass(BaseController)

function HelpCtrl:__init()
	if HelpCtrl.Instance ~= nil then
		ErrorLog("[HelpCtrl] attempt to create singleton twice!")
		return
	end
	HelpCtrl.Instance = self

	self.view = HelpView.New(ViewDef.Help)
	self.data = HelpData.New()

	self:RegisterAllEvents()
end

function HelpCtrl:__delete()
	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end
	HelpCtrl.Instance = nil
end

function HelpCtrl:RegisterAllEvents()
	-- self:RegisterProtocol(SCServerTime, "OnServerTime")
end

function HelpCtrl:OnServerTime(protocol)
	self.data:SetOpenServerInfo(protocol)
	self.view:Flush()
end