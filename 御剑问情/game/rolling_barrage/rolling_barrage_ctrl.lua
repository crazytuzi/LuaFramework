require("game/rolling_barrage/rolling_barrage_data")
require("game/rolling_barrage/rolling_barrage_view")

RollingBarrageCtrl = RollingBarrageCtrl or BaseClass(BaseController)

function RollingBarrageCtrl:__init()
	if nil ~= RollingBarrageCtrl.Instance then
		return
	end
	RollingBarrageCtrl.Instance = self

	self.data = RollingBarrageData.New()
	self.view = RollingBarrageView.New(ViewName.RollingBarrageView)

	self:RegisterAllProtocols()
end

function RollingBarrageCtrl:__delete()
	self.data:DeleteMe()
	self.data = nil

	self.view:DeleteMe()
	self.view = nil

	RollingBarrageCtrl.Instance = nil
end

function RollingBarrageCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCChestShopRecordList, "OnChestShopRecordList")
end

function RollingBarrageCtrl:OnChestShopRecordList(protocol)
	self.data:SetRecordList(protocol)
end

-- 请求寻宝其记录
function RollingBarrageCtrl:SendChestShopRecordListReq(shop_type)
	local send_protocol = ProtocolPool.Instance:GetProtocol(CSChestShopRecordList)
	send_protocol.shop_type = shop_type or 0
	send_protocol:EncodeAndSend()
end

function RollingBarrageCtrl:OpenView(text)
	RollingBarrageData.Instance:SetTextData(text)
	self.view:FlushTextTab()
	if not self.view:IsOpen() then
		self.view:Open()
	end
end