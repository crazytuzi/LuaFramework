require("scripts/game/role/horoscope/horoscope_data")
require("scripts/game/role/horoscope/horoscope_tip_view")
require("scripts/game/role/horoscope/horoscope")
HoroscopeCtrl = HoroscopeCtrl or BaseClass(BaseController)

function HoroscopeCtrl:__init()
	if HoroscopeCtrl.Instance then
		ErrorLog("[HoroscopeCtrl] attempt to create singleton twice!")
		return
	end
	HoroscopeCtrl.Instance = self

	self.data = HoroscopeData.New()

	self.tip_view = XingHunEquipTipView.New(ViewDef.XingHUnSuitTip)

	self.view = Horoscope.New(ViewDef.Horoscope)

	self:RegisterAllProtocols()
end

function HoroscopeCtrl:__delete()
	HoroscopeCtrl.Instance = nil
	
	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.tip_view then
		self.tip_view:DeleteMe()
		self.tip_view = nil
	end
	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end
end

--穿上星魂
function HoroscopeCtrl.PutOnConstellation(series)
	local protocol = ProtocolPool.Instance:GetProtocol(CSPutOnConstellation)
	protocol.series = series
	protocol:EncodeAndSend()
end

--脱下星魂
function HoroscopeCtrl.TakeOffOneConstellation(slot_idx)
	local protocol = ProtocolPool.Instance:GetProtocol(CSTakeOffConstellationBySeat)
	protocol.slot_idx = slot_idx
	protocol:EncodeAndSend()
end

--强化
function HoroscopeCtrl.StrengthenSlot(slot_idx, item_list)
	local protocol = ProtocolPool.Instance:GetProtocol(CSStrengthenSlot)
	protocol.slot_idx = slot_idx
	protocol.item_list = item_list
	protocol:EncodeAndSend()
end

--收藏请求
function HoroscopeCtrl.CollectReq(series, type, grid_idx)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCollect)
	protocol.series = series
	protocol.type = type
	protocol.grid_idx = grid_idx
	protocol:EncodeAndSend()
end

--取消收藏请求
function HoroscopeCtrl.CancleCollectReq(type, grid_idx)
	local protocol = ProtocolPool.Instance:GetProtocol(CSCancelCollect)
	protocol.type = type
	protocol.grid_idx = grid_idx
	protocol:EncodeAndSend()
end


--------------------------------------------------------------------------------
function HoroscopeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCPutOnConstellation, "OnPutOnConstellation")
	self:RegisterProtocol(SCTakeOffOneConstellation, "OnTakeOffOneConstellation")
	self:RegisterProtocol(SCStrengthenSlot, "OnStrengthenSlot")
	self:RegisterProtocol(SCCollect, "OnCollect")
	self:RegisterProtocol(SCCancelCollect, "OnCancelCollect")
	self:RegisterProtocol(SCHoroscopeInfo, "OnHoroscopeInfo")
	self:RegisterProtocol(SCCollectionInfo, "OnCollectionInfo")
end

function HoroscopeCtrl:OnPutOnConstellation(protocol)
	self.data:UpdateConstellationDataList(protocol.slot_idx, protocol.constellation)
end

function HoroscopeCtrl:OnTakeOffOneConstellation(protocol)
	self.data:UpdateConstellationDataList(protocol.slot_idx)
end

function HoroscopeCtrl:OnStrengthenSlot(protocol)
	self.data:UpdateSlotInfoDataList(protocol.slot_idx, protocol.slot_level, protocol.slot_exp)
end

function HoroscopeCtrl:OnCollect(protocol)
	self.data:UpdateCollectionDataList(protocol.type, protocol.grid_idx, protocol.item)
end

function HoroscopeCtrl:OnCancelCollect(protocol)
	self.data:UpdateCollectionDataList(protocol.type, protocol.grid_idx)
end

function HoroscopeCtrl:OnHoroscopeInfo(protocol)
	self.data:SetConstellationDataList(protocol.item_list)
	self.data:SetSlotInfoDataList(protocol.slot_list)
	--PrintTable(protocol.slot_list)
end

function HoroscopeCtrl:OnCollectionInfo(protocol)
	self.data:SetCollectionDataList(protocol.collection_list)
end


