require("game/cross_crystal/cross_crystal_data")
require("game/cross_crystal/cross_crystal_info_view")

CrossCrystalCtrl = CrossCrystalCtrl or  BaseClass(BaseController)

function CrossCrystalCtrl:__init()
	if CrossCrystalCtrl.Instance ~= nil then
		print_error("[CrossCrystalCtrl] attempt to create singleton twice!")
		return
	end
	CrossCrystalCtrl.Instance = self

	self:RegisterAllProtocols()

	self.data = CrossCrystalData.New()
	self.info_view = CrossCrystalInfoView.New(ViewName.CrossCrystalInfoView)
end

function CrossCrystalCtrl:__delete()
	if self.data ~= nil then
		self.data:DeleteMe()
		self.data = nil
	end
	if self.info_view ~= nil then
		self.info_view:DeleteMe()
		self.info_view = nil
	end

	CrossCrystalCtrl.Instance = nil
end

function CrossCrystalCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCShuijingPlayerInfo, "OnSCShuijingPlayerInfo")
	self:RegisterProtocol(SCShuijingGatherInfo, "OnSCShuijingGatherInfo")
end

function CrossCrystalCtrl:OnSCShuijingPlayerInfo(protocol)
	self.data:SetCrystalInfo(protocol)
	self:InfoViewFlush()
end

function CrossCrystalCtrl:OnSCShuijingGatherInfo(protocol)
	self.data:SetCrystalPosInfo(protocol)
	self:InfoViewFlush()
end

function CrossCrystalCtrl:OnShuijingBuyBuff()
	local protocol = ProtocolPool.Instance:GetProtocol(CSShuijingBuyBuff)
	protocol:EncodeAndSend()
end

function CrossCrystalCtrl:InfoViewFlush()
	self.info_view:Flush()
end

function CrossCrystalCtrl:ClearSelectGatherType()
	if self.info_view then
		self.info_view:ClearSelectGatherType()
	end
end