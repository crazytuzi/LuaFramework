require("game/activity_online/activity_online_danbi_chongzhi/kuanghuan_activity_panel_danbichongzhi_data")
KuanHuanActivityPanelDanBiChongZhiCtrl = KuanHuanActivityPanelDanBiChongZhiCtrl or BaseClass(BaseController)

function KuanHuanActivityPanelDanBiChongZhiCtrl:__init()
	if nil ~= KuanHuanActivityPanelDanBiChongZhiCtrl.Instance then
		return
	end

	KuanHuanActivityPanelDanBiChongZhiCtrl.Instance = self
	self.data = KuanHuanActivityPanelDanBiChongZhiData.New()
	self:RegisterAllProtocols()
end

function KuanHuanActivityPanelDanBiChongZhiCtrl:__delete()
	KuanHuanActivityPanelDanBiChongZhiCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function KuanHuanActivityPanelDanBiChongZhiCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAOfflineSingleChargeInfo, "OnSCRAOfflineSingleChargeInfo")
end

function KuanHuanActivityPanelDanBiChongZhiCtrl:OnSCRAOfflineSingleChargeInfo(protocol)
	self.data:SetSingleInfo(protocol)
	ActivityOnLineCtrl.Instance:FlushView("danbi")
end
