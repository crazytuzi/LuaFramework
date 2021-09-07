require("game/war_report/war_report_view")
require("game/war_report/war_report_data")
require("game/war_report/war_report_cell")

WarReportCtrl = WarReportCtrl or BaseClass(BaseController)
function WarReportCtrl:__init()
	if WarReportCtrl.Instance ~= nil then
		print_error("[WarReportCtrl] attempt to create singleton twice!")
		return
	end
	WarReportCtrl.Instance = self

	self:RegisterAllProtocols()

	self.view = WarReportView.New(ViewName.WarReport)
	self.data = WarReportData.New()
end

function WarReportCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

	WarReportCtrl.Instance = nil
end

function WarReportCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCQueryBattleReportHonorList, "OnSCQueryBattleReportHonorList")
	self:RegisterProtocol(SCQueryBattleReportNormalList, "OnSCQueryBattleReportNormalList")
end

function WarReportCtrl:OnSCQueryBattleReportHonorList(protocol)
	self.data:SetSCQueryBattleReportHonorList(protocol)
	self:Flush()
end

function WarReportCtrl:OnSCQueryBattleReportNormalList(protocol)
	self.data:SetSCQueryBattleReportNormalList(protocol)
	self:Flush()
end

function WarReportCtrl:SendBattleReportList()
	local protocol = ProtocolPool.Instance:GetProtocol(CSQueryBattleReportList)
	protocol:EncodeAndSend()
end

function WarReportCtrl:Flush(param_t)
	self.view:Flush(param_t)
end