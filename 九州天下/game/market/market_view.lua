require("game/market/market_sell_view")
require("game/market/market_buy_view")
require("game/market/market_table_view")

MarketView = MarketView or BaseClass(BaseView)

function MarketView:__init()
	self.ui_config = {"uis/views/market","MarketView"}
	self.play_audio = true
	self:SetMaskBg()
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenShichang)
	end
end

function MarketView:__delete()

end

function MarketView:LoadCallBack()
	local sell_content = self:FindObj("SellView")
	sell_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.sell_view = MarketSellView.New(obj)
	end)
	self.gold = self:FindVariable("Gold")
	self.coin = self:FindVariable("Coin")
	-- 子面板
	local buy_content = self:FindObj("BuyView")
	buy_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.buy_view = MarketBuyView.New(obj)
		self.buy_view:OnSearch(0)
		self.buy_view:Flush()
		self:FlushGold()
	end)

	local table_content = self:FindObj("TableView")
	table_content.uiprefab_loader:Wait(function(obj)
		obj = U3DObject(obj)
		self.table_view = MarketTableView.New(obj)
	end)

	self.toggle_buy = self:FindObj("ToggleBuy")
	self.toggle_sell = self:FindObj("ToggleSell")
	self.toggle_table = self:FindObj("ToggleTable")

	self:ListenEvent("add_gold", BindTool.Bind(self.HandleAddGold, self))
	self:ListenEvent("Close", BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OnOpenSell", BindTool.Bind(self.OnOpenSell, self))
	self:ListenEvent("OnOpenBuy", BindTool.Bind(self.OnOpenBuy, self))
	self:ListenEvent("OnOpenTable", BindTool.Bind(self.OnOpenTable, self))

	self.money_bar = MoneyBar.New()
	self.money_bar:SetInstanceParent(self:FindObj("MoneyBar"))
end

function MarketView:FlushGold()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local gold = vo.gold
	local coin = vo.coin
	self.gold:SetValue(CommonDataManager.ConverMoney(gold))
	self.coin:SetValue(CommonDataManager.ConverMoney(coin))
end

function MarketView:ReleaseCallBack()
	if self.sell_view then
		self.sell_view:DeleteMe()
		self.sell_view = nil
	end
	if self.buy_view then
		self.buy_view:DeleteMe()
		self.buy_view = nil
	end

	if self.table_view then
		self.table_view:DeleteMe()
		self.table_view = nil
	end
	
	if self.money_bar then
		self.money_bar:DeleteMe()
		self.money_bar = nil
	end

	self.toggle_buy = nil
	self.toggle_sell = nil
	self.toggle_table = nil
	self.gold = nil
	self.coin = nil

end

function MarketView:ShowIndexCallBack(index)
	if index == TabIndex.market_buy then
		self.toggle_buy.toggle.isOn = true
		if self.buy_view then
			self.buy_view:FlushMarketBuy()
		end
	elseif index == TabIndex.market_sell then
		self.toggle_sell.toggle.isOn = true
		if self.sell_view then
			self.sell_view:Flush()
		end
	elseif index == TabIndex.market_table then
		self.toggle_table.toggle.isOn = true
		if self.table_view then
			self.table_view:Flush()
		end
	end
end

function MarketView:OnFlush(param_list)
	for k,v in pairs(param_list) do
		if k == "all" then
			if self.buy_view then
				self.buy_view:FlushMarketBuy()
				self:FlushGold()
			end
			if self.sell_view then
				self.sell_view:Flush()
			end
			if self.table_view then
				self.table_view:Flush()
			end
		elseif k == "flush_buy" then
			if self.buy_view then
				self.buy_view:OnClickType(v.item_id,v.item_name)
			end
		elseif k == "flush_market_buy" then
			if self.buy_view then
				self.buy_view:FlushMarketBuy()
			end
		end
	end
end

function MarketView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MarketView:HandleClose()
	ViewManager.Instance:Close(ViewName.Market)
end

function MarketView:OnOpenSell()
	if self.sell_view then
		self.sell_view:Flush()
	end
end

function MarketView:OnOpenBuy()
	if self.buy_view then
		self.buy_view:FlushCurPage()
		self:FlushGold()
	end
end

function MarketView:OnOpenTable()
	MarketCtrl.Instance:SendPublicSaleGetUserItemListReq()
	if self.table_view then
		self.table_view:Flush()
	end
end

function MarketView:FlushTable()
	if self.table_view then
		self.table_view:Flush()
	end
end