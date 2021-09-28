require("game/market/market_sell_view")
require("game/market/market_buy_view")
require("game/market/market_table_view")

MarketView = MarketView or BaseClass(BaseView)

function MarketView:__init()
	self.ui_config = {"uis/views/market_prefab","MarketView"}
	self.play_audio = true
	self.full_screen = true
	if self.audio_config then
		self.open_audio_id = AssetID("audios/sfxs/uis", self.audio_config.other[1].OpenShichang)
	end
	self.money_change_callback = BindTool.Bind(self.PlayerDataChangeCallback, self)
end

function MarketView:__delete()

end

function MarketView:LoadCallBack()
	self.gold = self:FindVariable("Gold")
	self.bind_gold = self:FindVariable("BindGold")
	-- 子面板
	self.buy_content = self:FindObj("BuyView")
	self.sell_content = self:FindObj("SellView")
	self.table_content = self:FindObj("TableView")

	self.toggle_buy = self:FindObj("ToggleBuy")
	self.toggle_sell = self:FindObj("ToggleSell")
	self.toggle_table = self:FindObj("ToggleTable")

	self:ListenEvent("Close",
		BindTool.Bind(self.HandleClose, self))
	self:ListenEvent("OnOpenSell",
		BindTool.Bind(self.OnOpenSell, self))
	self:ListenEvent("OnOpenBuy",
		BindTool.Bind(self.OnOpenBuy, self))
	self:ListenEvent("OnOpenTable",
		BindTool.Bind(self.OnOpenTable, self))
	self:ListenEvent("AddGold",
		BindTool.Bind(self.HandleAddGold, self))

	-- 首次刷新数据
	self:PlayerDataChangeCallback("gold", PlayerData.Instance.role_vo["gold"])
	self:PlayerDataChangeCallback("bind_gold", PlayerData.Instance.role_vo["bind_gold"])
	PlayerData.Instance:ListenerAttrChange(self.money_change_callback)

	self:OnOpenBuy()
end

function MarketView:OpenCallBack()
	-- 是否处于封测期间
	if LoginData.Instance:IsClosedTest() then
		TipsCtrl.Instance:ShowSystemMsg(Language.Common.MarketClosedTestTips)
		self:Close()
	end
	MarketData.Instance:InitMarketTypeCfg()
	MarketCtrl.Instance:SendSaleTypeCountReq()
end


-- 玩家钻石改变时
function MarketView:PlayerDataChangeCallback(attr_name, value)
	if attr_name == "gold" then
		self.gold:SetValue(CommonDataManager.ConverMoney(value))
	elseif attr_name == "bind_gold" then
		self.bind_gold:SetValue(CommonDataManager.ConverMoney(value))
	end
end

function MarketView:FlushGold()
	local vo = GameVoManager.Instance:GetMainRoleVo()
	local gold = vo.gold
	self.gold:SetValue(CommonDataManager.ConverMoney(gold))
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

	if PlayerData.Instance then
		PlayerData.Instance:UnlistenerAttrChange(self.money_change_callback)
	end

	-- 清理变量和对象
	self.gold = nil
	self.bind_gold = nil
	self.toggle_buy = nil
	self.toggle_sell = nil
	self.toggle_table = nil

	self.sell_content = nil
	self.table_content = nil
	self.buy_content = nil
end


function MarketView:AsyncLoadView(index)
	if index == TabIndex.market_sell and not self.sell_view then
		UtilU3d.PrefabLoad("uis/views/market_prefab", "SellView",
			function(obj)
				obj.transform:SetParent(self.sell_content.transform, false)
				obj = U3DObject(obj)
				self.sell_view = MarketSellView.New(obj)
				self.sell_view:Flush()
			end)
	end
	if index == TabIndex.market_buy and not self.buy_view then
		UtilU3d.PrefabLoad("uis/views/market_prefab", "BuyView",
			function(obj)
				obj.transform:SetParent(self.buy_content.transform, false)
				obj = U3DObject(obj)
				self.buy_view = MarketBuyView.New(obj)
				self.buy_view:OnSearch(0)
				self.buy_view:Flush()
				self:FlushGold()
			end)
	end
	if index == TabIndex.market_table and not self.table_view then
		UtilU3d.PrefabLoad("uis/views/market_prefab", "TableView",
			function(obj)
				obj.transform:SetParent(self.table_content.transform, false)
				obj = U3DObject(obj)
				self.table_view = MarketTableView.New(obj)
				self.table_view:Flush()
			end)
	end
end

function MarketView:ShowIndexCallBack(index)
	self:AsyncLoadView(index)
	if index == TabIndex.market_buy then
		self.toggle_buy.toggle.isOn = true
		if self.buy_view then
			self.buy_view:Flush()
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

function MarketView:OnFlush(param_t)
	for k, v in pairs(param_t) do
		if k == "flush_buy_list" and self.buy_view then
			self.buy_view:FlushListData()
		else
			if self.buy_view then
				self.buy_view:Flush()
				self:FlushGold()
			end
			if self.sell_view then
				self.sell_view:Flush()
			end
			if self.table_view then
				self.table_view:Flush()
			end
		end
	end
end

function MarketView:HandleClose()
	ViewManager.Instance:Close(ViewName.Market)
end

function MarketView:OnOpenSell()
	self:ShowIndex(TabIndex.market_sell)
	if self.sell_view then
		self.sell_view:Flush()
	end
end

function MarketView:OnOpenBuy()
	self:ShowIndex(TabIndex.market_buy)
	if self.buy_view then
		self.buy_view:FlushCurPage()
		self:FlushGold()
	end
end

function MarketView:HandleAddGold()
	VipData.Instance:SetOpenType(OPEN_VIP_RECHARGE_TYPE.RECHANRGE)
	ViewManager.Instance:Open(ViewName.VipView)
end

function MarketView:OnOpenTable()
	self:ShowIndex(TabIndex.market_table)
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