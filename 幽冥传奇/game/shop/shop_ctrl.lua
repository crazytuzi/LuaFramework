require("scripts/game/shop/shop_data")
require("scripts/game/shop/shop_view")

--------------------------------------------------------------
--商城
--------------------------------------------------------------
ShopCtrl = ShopCtrl or BaseClass(BaseController)
ShopCtrl.BUY_CELL_BACK = "buy_cell_back"

function ShopCtrl:__init()
	if ShopCtrl.Instance then
		ErrorLog("[ShopCtrl] Attemp to create a singleton twice !")
	end
	ShopCtrl.Instance = self

	self.view = ShopView.New(ViewDef.Shop)
	self.data = ShopData.New()

	self:RegisterAllProtocols()
end

function ShopCtrl:__delete()
	ShopCtrl.Instance = nil

	self.view:DeleteMe()
	self.view = nil

	self.data:DeleteMe()
	self.data = nil

end

function ShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCReplyBuyItemResult, "OnReplyBuyItemResult")
	self:RegisterProtocol(SCMysticalShopData, "OnMysticalShopData")
	self:RegisterProtocol(SCShopLimitInfo, "OnShopLimitInfo")
end

--回应获取神秘商店信息的结果
function ShopCtrl:OnMysticalShopData(protocol)
	self.data:SetMysticalShopData(protocol)
end

-- 回应购买其它商城物品的结果
function ShopCtrl:OnReplyBuyItemResult(protocol)
	self.data:BuyReplyResult(protocol)
end

function ShopCtrl:OnShopLimitInfo(protocol)
	self.data:SetShopLimitInfo(protocol)
end

--从商城购买东西
function ShopCtrl.BuyItemFromStore(buy_id, buy_count, item_id, auto_use)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyItemFromStore)
	protocol.buy_id = buy_id
	protocol.buy_count = buy_count
	protocol.item_id = item_id
	protocol.auto_use = auto_use or 0
	protocol:EncodeAndSend()
end

--购买神秘商店物品
function ShopCtrl.SendBuyMysticalItemReq(shop_idx)
	local protocol = ProtocolPool.Instance:GetProtocol(CSBuyMysticalItemReq)
	protocol.shop_idx = shop_idx
	protocol:EncodeAndSend()
end

--刷新神秘商店
function ShopCtrl.SendRefreshMysticalItemReq(refresh_type)
	local protocol = ProtocolPool.Instance:GetProtocol(CSRefreshMysticalItemReq)
	protocol.refresh_type = refresh_type
	protocol:EncodeAndSend()
end