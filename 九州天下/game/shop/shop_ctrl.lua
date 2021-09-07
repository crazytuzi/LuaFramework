require("game/shop/shop_data")
require("game/shop/shop_view")
ShopCtrl = ShopCtrl or BaseClass(BaseController)
function ShopCtrl:__init()
	if ShopCtrl.Instance then
		print_error("[ShopCtrl] Attemp to create a singleton twice !")
	end
	ShopCtrl.Instance = self
	self.data = ShopData.New()
	self.view = ShopView.New(ViewName.Shop)

	self:RegisterAllProtocols()
end

function ShopCtrl:__delete()
	ShopCtrl.Instance = nil
	if nil ~= self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	if nil ~= self.view then
		self.view:DeleteMe()
		self.view = nil
	end
end

function ShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRoleShopBuyLimit, 'OnRoleShopBuyLimit')
end

function ShopCtrl:SendShopBuy()
	local cmd = ProtocolPool.Instance:GetProtocol(CSGetRoleShopBuyLimit)
	cmd:EncodeAndSend()
end

function ShopCtrl:OnRoleShopBuyLimit(protocol)
	self.data:SetShopBuyLimit(protocol)
	self.view:Flush("flush_buy_limit")
	self.view:Flush("flush_buy_limit_zero")
end