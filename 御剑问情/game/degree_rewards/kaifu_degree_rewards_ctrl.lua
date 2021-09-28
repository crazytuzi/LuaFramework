require("game/degree_rewards/kaifu_degree_rewards_data")
require("game/degree_rewards/kaifu_degree_rewards_view")

KaiFuDegreeRewardsCtrl = KaiFuDegreeRewardsCtrl or BaseClass(BaseController)

function KaiFuDegreeRewardsCtrl:__init()
	if KaiFuDegreeRewardsCtrl.Instance ~= nil then
		print_error("[KaiFuDegreeRewardsCtrl] Attemp to create a singleton twice !")
	end

	KaiFuDegreeRewardsCtrl.Instance = self
	self.view = KaiFuDegreeRewardsView.New(ViewName.KaiFuDegreeRewardsView)
	self.data = KaiFuDegreeRewardsData.New()

	self.activity_change = BindTool.Bind(self.ActivityChangeCallBack, self)
	ActivityData.Instance:NotifyActChangeCallback(self.activity_change)

	self:RegisterAllProtocols()
end

function KaiFuDegreeRewardsCtrl:__delete()
	if self.view then
		self.view:DeleteMe()
		self.view = nil
    end

    if self.data then
    	self.data:DeleteMe()
    	self.data = nil
    end

    KaiFuDegreeRewardsCtrl.Instance = nil
end

function KaiFuDegreeRewardsCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAMountUpgradeInfo, "OnSCRAMountUpgradeInfo") --坐骑
	self:RegisterProtocol(SCRAWingUpgradeInfo, "OnSCRAWingUpgradeInfo") --羽翼
	self:RegisterProtocol(SCRAHaloUpgradeInfo, "OnSCRAHaloUpgradeInfo") --光环
	self:RegisterProtocol(SCRAFootPrintUpgradeInfo, "OnSCRAFootPrintUpgradeInfo") --足迹
	self:RegisterProtocol(SCRAFightMountUpgradeInfo, "OnSCRAFightMountUpgradeInfo") --战骑
	self:RegisterProtocol(SCRAShengongUpgradeInfo, "OnSCRAShengongUpgradeInfo") --神弓
	self:RegisterProtocol(SCRAShenyiUpgradeInfo, "OnSCRAShenyiUpgradeInfo") --神翼
	self:RegisterProtocol(SCRAYaoShiUpgradeInfo, "OnSCRAYaoShiUpgradeInfo") --腰饰
	self:RegisterProtocol(SCRATouShiUpgradeInfo, "OnSCRATouShiUpgradeInfo") --头饰
	self:RegisterProtocol(SCRAQiLinBiUpgradeInfo, "OnSCRAQiLinBiUpgradeInfo") --麒麟臂
	self:RegisterProtocol(SCRAMaskUpgradeInfo, "OnSCRAMaskUpgradeInfo") --面具
	self:RegisterProtocol(SCRAXianBaoUpgradeInfo, "OnSCRAXianBaoUpgradeInfo") --仙宝
	self:RegisterProtocol(SCRALingZhuUpgradeInfo, "OnSCRALingZhuUpgradeInfo") --灵珠
	self:RegisterProtocol(SCRALingChongUpgradeInfo, "OnSCRALingChongUpgradeInfo") --灵宠
	self:RegisterProtocol(SCRALingGongUpgradeInfo, "OnSCRALingGongUpgradeInfo") --灵弓
	self:RegisterProtocol(SCRALingQiUpgradeInfo, "OnSCRALingQiUpgradeInfo") --灵骑
	self:RegisterProtocol(SCUpgradeCardBuyInfo, "SCUpgradeCardBuyInfo")		-- 购买直升丹信息
	self:RegisterProtocol(CSUpgradeCardBuyReq)
end

function KaiFuDegreeRewardsCtrl:ActivityChangeCallBack(activity_type, status, next_time, open_type)
	if KaiFuDegreeRewardsData.IsDegreeRewardsType(activity_type) and status == ACTIVITY_STATUS.OPEN then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_QUERY_INFO)
	end
end

function KaiFuDegreeRewardsCtrl:OnSCRAMountUpgradeInfo(protocol)
	self.data:SetDegreeMountInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.MountDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAWingUpgradeInfo(protocol)
	self.data:SetDegreeWingInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.WingDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAHaloUpgradeInfo(protocol)
	self.data:SetDegreeHaloInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.HaloDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAFootPrintUpgradeInfo(protocol)
	self.data:SetDegreeFootInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.FootDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAFightMountUpgradeInfo(protocol)
	self.data:SetDegreeFightMountInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.FightMountDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAShengongUpgradeInfo(protocol)
	self.data:SetDegreeShenGongInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ShenGongDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAShenyiUpgradeInfo(protocol)
	self.data:SetDegreeShenYiInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.ShenYiDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAYaoShiUpgradeInfo(protocol)
	self.data:SetDegreeYaoShiInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.YaoShiDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRATouShiUpgradeInfo(protocol)
	self.data:SetDegreeTouShiInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.TouShiDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAQiLinBiUpgradeInfo(protocol)
	self.data:SetDegreeQiLinBiInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.QiLinBiDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAMaskUpgradeInfo(protocol)
	self.data:SetDegreeMaskInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.MaskDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRAXianBaoUpgradeInfo(protocol)
	self.data:SetDegreeXianBaoInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.XianBaoDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRALingZhuUpgradeInfo(protocol)
	self.data:SetDegreeLingZhuInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.LingZhuDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRALingChongUpgradeInfo(protocol)
	self.data:SetDegreeLingChongInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.LingChongDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRALingGongUpgradeInfo(protocol)
	self.data:SetDegreeLingGongInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.LingGongDegree)
end

function KaiFuDegreeRewardsCtrl:OnSCRALingQiUpgradeInfo(protocol)
	self.data:SetDegreeLingQiInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.LingQiDegree)
end

--设置循环进阶活动类型
function KaiFuDegreeRewardsCtrl:SetDegreeRewardsActivityType(activity_type)
	KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(activity_type, RA_UPGRADE_NEW_OPERA_TYPE.RA_UPGRADE_NEW_OPERA_TYPE_QUERY_INFO)
	self.data:SetDegreeActivityType(activity_type)
	self.view:SetDegreeActivityType(activity_type)

	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaiFuDegreeRewardsCtrl:SCUpgradeCardBuyInfo(protocol)
	self.data:SetBuyInfo(protocol)
	if self.view:IsOpen() then
		self.view:Flush()
	end
end

function KaiFuDegreeRewardsCtrl:SendUpgradeCardBuyReq(activity_type, item_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeCardBuyReq)
	protocol.activity_id = activity_type
	protocol.item_id = item_id
	protocol:EncodeAndSend()
end