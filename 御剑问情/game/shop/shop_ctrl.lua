require("game/shop/shop_data")
require("game/shop/shop_view")
require("game/shop/tips_jifenshop_view")

ShopCtrl = ShopCtrl or BaseClass(BaseController)
function ShopCtrl:__init()
	if ShopCtrl.Instance then
		print_error("[ShopCtrl] Attemp to create a singleton twice !")
	end
	ShopCtrl.Instance = self
	self.data = ShopData.New()
	self.view = ShopView.New(ViewName.Shop)
	self.tips_view = BuyTipsView.New(ViewName.ExchangeViewBuyTips)
	self.tips_jifenshop_view = JiFenShopView.New(ViewName.JiFenShopView)

	self.score_change_callback = BindTool.Bind1(self.ScoreDataChange, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.score_change_callback)

	self.price_change_callback = BindTool.Bind1(self.PriceDataChange, self)
	PlayerData.Instance:ListenerAttrChange(self.price_change_callback)

	self:RegisterAllProtocols()
end

function ShopCtrl:__delete()
	self.view:DeleteMe()
	self.view = nil

	self.tips_view:DeleteMe()
	self.tips_view = nil

	self.tips_jifenshop_view:DeleteMe()
	self.tips_jifenshop_view = nil

	self.data:DeleteMe()
	self.data = nil

	if self.score_change_callback then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.score_change_callback)
		self.score_change_callback = nil
	end

	if self.price_change_callback then
		PlayerData.Instance:UnlistenerAttrChange(self.price_change_callback)
		self.price_change_callback = nil
	end

	ShopCtrl.Instance = nil
end

function ShopCtrl:OpenJifenShop()
	ViewManager.Instance:Open(ViewName.JiFenShopView)
end

function ShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCSendMysteriosshopItemInfo, "ShenMiShop")
	self:RegisterProtocol(CSMysteriosshopinMallOperate)
	self:RegisterProtocol(CSMysteriosshopOperate)
end

function ShopCtrl:ShenMiShop(protocol)
	self.data:SetShenMiShop(protocol)
	self.tips_jifenshop_view:Flush()
	RemindManager.Instance:Fire(RemindName.ShenmiShop)
	self.view:Flush()
	self.view:ShenMiItem()
end

function ShopCtrl:SendMysteriosshopinMallOperate(operate_type, seq)
	local protocol = ProtocolPool.Instance:GetProtocol(CSMysteriosshopinMallOperate)
	protocol.operate_type = operate_type
	protocol.seq = seq
	protocol:EncodeAndSend()
end

function ShopCtrl:SendMysteriosshopOperate(conver_type, item_seq, item_num)
	local protocol = ProtocolPool.Instance:GetProtocol(CSScoreToItemConvert)
	protocol.scoretoitem_type = conver_type
	protocol.index = item_seq
	protocol.num = item_num
	protocol:EncodeAndSend()
end

function ShopCtrl:ScoreDataChange()
	self.view:Flush()
	self.tips_jifenshop_view:Flush()
end

function ShopCtrl:PriceDataChange(attr_name, value, old_value)
	if attr_name == "gold" or attr_name == "bind_gold" then
		self.view:Flush()
	end
end

function ShopCtrl:GetJiFenView()
	return self.tips_jifenshop_view
end