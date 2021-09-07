require("game/midautumn_exchange/mid_autumn_exchange_view")
require("game/midautumn_exchange/mid_autumn_exchange_data")

MidAutumnExchangeCtrl = MidAutumnExchangeCtrl or BaseClass(BaseController)
function MidAutumnExchangeCtrl:__init()
	if MidAutumnExchangeCtrl.Instance then
		print_error("[MidAutumnExchangeCtrl] Attemp to create a singleton twice !")
	end
	MidAutumnExchangeCtrl.Instance = self

	self.dress_shop_data = MidAutumnExchangeData.New()
	self.dress_shop_view = MidAutumnExchangeView.New(ViewName.MidAutumnExchangeView)
	self:RegisterAllProtocols()
end

function MidAutumnExchangeCtrl:__delete()
	MidAutumnExchangeCtrl.Instance = nil

	if self.dress_shop_view then
		self.dress_shop_view:DeleteMe()
		self.dress_shop_view = nil
	end

	if self.dress_shop_data then
		self.dress_shop_data:DeleteMe()
		self.dress_shop_data = nil
	end
end

function MidAutumnExchangeCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAActiveItemExchangeInfo, "OnSCRAImageExchangeShopInfo")
end

function MidAutumnExchangeCtrl:OnSCRAImageExchangeShopInfo(protocol)
	self.dress_shop_data:SetNumTimeInfo(protocol)
	if self.dress_shop_view:IsOpen()then
		self.dress_shop_view:Flush()
	end
	RemindManager.Instance:Fire(RemindName.MidAutumnActExchange)
end
