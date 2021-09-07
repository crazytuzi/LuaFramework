require("game/qixi_marriage/qixi_marriage_view")
require("game/qixi_marriage/qixi_marriage_data")

QiXiMarriageCtrl = QiXiMarriageCtrl or BaseClass(BaseController)

function QiXiMarriageCtrl:__init()
	if QiXiMarriageCtrl.Instance ~= nil then
		print_error("[QiXiMarriageCtrl] attempt to create singleton twice!")
		return
	end
	QiXiMarriageCtrl.Instance = self

	self.view = QiXiMarriageView.New(ViewName.QiXiMarriageView)
	self.data = QiXiMarriageData.New()

	self:RegisterAllProtocols()
end

function QiXiMarriageCtrl:__delete()
	QiXiMarriageCtrl.Instance = nil
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function QiXiMarriageCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAHunyanYuyueActivityInfo, "OnSCRAHunyanYuyueActivityInfo")	
end

function QiXiMarriageCtrl:OnSCRAHunyanYuyueActivityInfo(protocol)
	self.data:SetQiXiMarriageInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end


