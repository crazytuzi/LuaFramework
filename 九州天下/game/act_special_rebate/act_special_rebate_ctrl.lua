require("game/act_special_rebate/act_special_rebate_view")
require("game/act_special_rebate/act_special_rebate_data")

ActSpecialRebateCtrl = ActSpecialRebateCtrl or BaseClass(BaseController)
function ActSpecialRebateCtrl:__init()
	if ActSpecialRebateCtrl.Instance then
		print_error("[ActSpecialRebateCtrl] Attemp to create a singleton twice !")
	end
	ActSpecialRebateCtrl.Instance = self

	self.data = ActSpecialRebateData.New()
	self.view = ActSpecialRebateView.New(ViewName.ActSpecialRebateView)
	
	self:RegisterAllProtocols()
end

function ActSpecialRebateCtrl:__delete()
	ActSpecialRebateCtrl.Instance = nil

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end
end

function ActSpecialRebateCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAShengongUpgradeInfo, "OnSCRAShengongUpgradeInfo")
	self:RegisterProtocol(SCRAYaoShiUpgradeInfo, "OnSCRAYaoShiUpgradeInfo")
	self:RegisterProtocol(SCRATouShiUpgradeInfo, "OnSCRATouShiUpgradeInfo")
	self:RegisterProtocol(SCRAQiLinBiUpgradeInfo, "OnSCRAQiLinBiUpgradeInfo")
	self:RegisterProtocol(SCRAMaskUpgradeInfo, "OnSCRAMaskUpgradeInfo")
	self:RegisterProtocol(SCRAXianBaoUpgradeInfo, "OnSCRAXianBaoUpgradeInfo")
	self:RegisterProtocol(SCRALingZhuUpgradeInfo, "OnSCRALingZhuUpgradeInfo")
	self:RegisterProtocol(SCUpgradeCardBuyInfo, "OnSCUpgradeCardBuyInfo")

	self:RegisterProtocol(CSUpgradeCardBuyReq)
end

function ActSpecialRebateCtrl:OnSCRAShengongUpgradeInfo(protocol)
	self.data:SetShenGongData(protocol)

	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.FOOT})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateFoot)
end

function ActSpecialRebateCtrl:OnSCRAYaoShiUpgradeInfo(protocol)
	self.data:SetYaoShiData(protocol)

	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.WAIST})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateYaoShi)
end

function ActSpecialRebateCtrl:OnSCRATouShiUpgradeInfo(protocol)
	self.data:SetTouShiData(protocol)

	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.HEAD})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateTouShi)
end

function ActSpecialRebateCtrl:OnSCRAQiLinBiUpgradeInfo(protocol)
	self.data:SetQiLinBiData(protocol)

	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.ARM})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateQiLingBi)
end

function ActSpecialRebateCtrl:OnSCRAMaskUpgradeInfo(protocol)
	self.data:SetMaskData(protocol)

	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.FACE})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateMask)
end


function ActSpecialRebateCtrl:OnSCRAXianBaoUpgradeInfo(protocol)
	self.data:SetXianBaoData(protocol)

	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.TREASURE})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateXianBao)
end

function ActSpecialRebateCtrl:OnSCRALingZhuUpgradeInfo(protocol)
	self.data:SetLingZhuData(protocol)
	
	if self.view:IsOpen() then
		self.view:Flush("flush_view", {view_type = ACT_SPECIAL_REBATE_TYPE.BEAD})
	end

	RemindManager.Instance:Fire(RemindName.ActRebateLingBao)
end

function ActSpecialRebateCtrl:OnSCUpgradeCardBuyInfo(protocol)
	self.data:SetUpgradeCardByData(protocol)
	local show_view_type = nil
	for k,v in pairs(ActSpecialRebateData.ACT_TYPE) do
		if protocol.activity_id == v then
			show_view_type = k
			break
		end
	end

	if show_view_type ~= nil then
		if self.view:IsOpen() then
			self.view:Flush("flush_view", {view_type = show_view_type})
		end
	end
end

function ActSpecialRebateCtrl:SendUpgradeCardBuyReq(activity_id, item_id)
	local protocol = ProtocolPool.Instance:GetProtocol(CSUpgradeCardBuyReq)
	protocol.activity_id = activity_id or 0
	protocol.item_id = item_id or 0
	protocol:EncodeAndSend()
end

function ActSpecialRebateCtrl:SetViewType(view_type)
	self.view:SetViewType(view_type)
end