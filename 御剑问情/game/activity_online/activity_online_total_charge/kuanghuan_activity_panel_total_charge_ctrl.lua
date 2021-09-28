require("game/activity_online/activity_online_total_charge/kuanghuan_activity_panel_total_charge_data")
KuanHuanActivityTotalChargeCtrl = KuanHuanActivityTotalChargeCtrl or BaseClass(BaseController)

function KuanHuanActivityTotalChargeCtrl:__init()
	if nil ~= KuanHuanActivityTotalChargeCtrl.Instance then
		return
	end

	KuanHuanActivityTotalChargeCtrl.Instance = self
	self.data = KuanHuanActivityTotalChargeData.New()
	self:RegisterAllProtocols()
end

function KuanHuanActivityTotalChargeCtrl:__delete()
	KuanHuanActivityTotalChargeCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function KuanHuanActivityTotalChargeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAOfflineTotalChargeInfo, "OnSCRAOfflineTotalChargeInfo")
end

function KuanHuanActivityTotalChargeCtrl:OnSCRAOfflineTotalChargeInfo(protocol)
	self.data:SetTotalChargeInfo(protocol)
	ActivityOnLineCtrl.Instance:FlushView("totalcharge")
end