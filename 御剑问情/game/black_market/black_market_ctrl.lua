require("game/black_market/black_market_view")
require("game/black_market/black_market_bid_view")
require("game/black_market/black_market_data")

BlackMarketCtrl = BlackMarketCtrl or BaseClass(BaseController)
function BlackMarketCtrl:__init()
	if BlackMarketCtrl.Instance then
		print_error("[BlackMarketCtrl] Attemp to create a singleton twice !")
	end
	BlackMarketCtrl.Instance = self

	self.black_market_data = BlackMarketData.New()
	self.black_market_view = BlackMarketView.New(ViewName.BlackMarket)
	self.black_market_bid_view = BlackMarketBidView.New()

	self:RegisterAllProtocols()
end

function BlackMarketCtrl:__delete()
	BlackMarketCtrl.Instance = nil

	if self.black_market_view then
		self.black_market_view:DeleteMe()
		self.black_market_view = nil
	end

	if self.black_market_data then
		self.black_market_data:DeleteMe()
		self.black_market_data = nil
	end

	if self.black_market_bid_view then
		self.black_market_bid_view:DeleteMe()
		self.black_market_bid_view = nil
	end
end

function BlackMarketCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRABlackMarketAllInfo, "OnRABlackMarketAllInfo")
end

function BlackMarketCtrl:OnRABlackMarketAllInfo(protocol)
	self.black_market_data:SetItemInfoData(protocol.item_info_list)
	self.black_market_view:Flush()
end

function BlackMarketCtrl:OpenBlackMarketBidView(data)
	if self.black_market_bid_view then
		self.black_market_bid_view:SetData(data)
		self.black_market_bid_view:Open()
	end
end