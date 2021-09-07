require("game/serveractivity/dress_shop/dress_shop_view")
require("game/serveractivity/dress_shop/dress_shop_data")

DressShopCtrl = DressShopCtrl or BaseClass(BaseController)
function DressShopCtrl:__init()
	if DressShopCtrl.Instance then
		print_error("[DressShopCtrl] Attemp to create a singleton twice !")
	end
	DressShopCtrl.Instance = self

	self.dress_shop_data = DressShopData.New()
	self.dress_shop_view = DressShopView.New(ViewName.DressShopView)
	self:RegisterAllProtocols()
end

function DressShopCtrl:__delete()
	DressShopCtrl.Instance = nil

	if self.dress_shop_view then
		self.dress_shop_view:DeleteMe()
		self.dress_shop_view = nil
	end

	if self.dress_shop_data then
		self.dress_shop_data:DeleteMe()
		self.dress_shop_data = nil
	end
end

function DressShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRAImageExchangeShopInfo, "OnSCRAImageExchangeShopInfo")
end

function DressShopCtrl:OnSCRAImageExchangeShopInfo(protocol)
	self.dress_shop_data:SetNumTimeInfo(protocol)
	if self.dress_shop_view then
		self.dress_shop_view:Flush()
	end
end