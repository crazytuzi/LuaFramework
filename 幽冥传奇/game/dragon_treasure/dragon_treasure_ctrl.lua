require("scripts/game/dragon_treasure/dragon_treasure_data")
require("scripts/game/dragon_treasure/treasure_jackpot_view")
require("scripts/game/dragon_treasure/times_treasure_view")
require("scripts/game/dragon_treasure/treasure_award_preview_view")

--------------------------------------------------------
-- 龙魂秘宝
--------------------------------------------------------

DragonTreasureCtrl = DragonTreasureCtrl or BaseClass(BaseController)

function DragonTreasureCtrl:__init()
	if	DragonTreasureCtrl.Instance then
		ErrorLog("[DragonTreasureCtrl]:Attempt to create singleton twice!")
	end
	DragonTreasureCtrl.Instance = self

	self.data = DragonTreasureData.New()
	self.treasure_view = TreasureJackpotView.New(ViewName.TreasureJackpot)
	self.times_treasure_view = TimesTreasureView.New(ViewName.TimesTreasure)
	self.treasure_award_preview_view = TreasureAwardPreviewView.New(ViewName.TreasureAwardPreview)

	-- self:RegisterAllProtocols()
end

function DragonTreasureCtrl:__delete()
	DragonTreasureCtrl.Instance = nil

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if self.treasure_view then
		self.treasure_view:DeleteMe()
		self.treasure_view = nil
	end

	if self.times_treasure_view then
		self.times_treasure_view:DeleteMe()
		self.times_treasure_view = nil
	end

	if self.treasure_award_preview_view then
		self.treasure_award_preview_view:DeleteMe()
		self.treasure_award_preview_view = nil
	end

end

-- --登记所有协议
-- function DragonTreasureCtrl:RegisterAllProtocols()
-- 	-- self:RegisterProtocol(SCDiamondsCreateResult, "OnDiamondsCreateResult")	--钻石打造
-- end

-- ----------接收----------

-- -- 接收打钻结果(8, 34)
-- function DragonTreasureCtrl:OnDiamondsCreateResult(protocol)
-- 	-- self.data:SetCreateResults(protocol)
-- end

-- ----------发送----------

-- --发送仓库数据的请求(36 4)
-- function DragonTreasureCtrl:SendReturnWarehouseDataReq()
-- 	-- self.data.storage_page_list = {}
-- 	-- local protocol = ProtocolPool.Instance:GetProtocol(CSReturnWarehouseDataReq)
-- 	-- protocol:EncodeAndSend()
-- end

-- --发送钻石打造请求(8, 33)
-- function DragonTreasureCtrl:SendDiamondsCreateReq(item_type, create_type)
-- 	-- local protocol = ProtocolPool.Instance:GetProtocol(CSDiamondsCreateReq)
-- 	-- protocol.item_type = item_type
-- 	-- protocol.create_type = create_type
-- 	-- protocol:EncodeAndSend()
-- end

-- --------------------
