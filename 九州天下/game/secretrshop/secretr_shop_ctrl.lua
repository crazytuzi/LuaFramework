require("game/secretrshop/secretr_shop_data")
require("game/secretrshop/secretr_shop_view")
SecretrShopCtrl = SecretrShopCtrl or BaseClass(BaseController)

function SecretrShopCtrl:__init()
	if SecretrShopCtrl.Instance then
		print_error("[SecretrShopCtrl] Attemp to create a singleton twice !")
	end
	SecretrShopCtrl.Instance = self

	self.data = SecretrShopData.New()
	self.view = SecretrShopView.New(ViewName.SecretrShopView)
	self.mainui_open_comlete = GlobalEventSystem:Bind(MainUIEventType.MAINUI_OPEN_COMLETE, BindTool.Bind(self.MainuiOpenCreate, self))
	self:RegisterAllProtocols()
end

function SecretrShopCtrl:RegisterAllProtocols()
	self:RegisterProtocol(SCRARmbBugChestShopInfo, "OnRARmbBugChestShopInfo")
end

function SecretrShopCtrl:OnRARmbBugChestShopInfo(protocol)
	self.data:SetRARmbBugChestShopInfo(protocol)
	RemindManager.Instance:Fire(RemindName.SecretrShop)
	self.view:Flush()
end

function SecretrShopCtrl:__delete()
	if self.mainui_open_comlete then
		GlobalEventSystem:UnBind(self.mainui_open_comlete)
		self.mainui_open_comlete = nil
	end

	if self.view then
		self.view:DeleteMe()
		self.view = nil
	end

	if self.data then
		self.data:DeleteMe()
		self.data = nil
	end

	SecretrShopCtrl.Instance = nil
end

function SecretrShopCtrl:GetView()
	return self.view
end

function SecretrShopCtrl:MainuiOpenCreate()
	if ActivityData.Instance:GetActivityIsOpen(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP) then
		KaifuActivityCtrl.Instance:SendGetKaifuActivityInfo(ACTIVITY_TYPE.RAND_ACTIVITY_RMB_BUY_COUNT_SHOP)
	end
end