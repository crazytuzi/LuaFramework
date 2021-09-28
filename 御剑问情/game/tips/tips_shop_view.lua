TipShopView = TipShopView or BaseClass(BaseView)

function TipShopView:__init()
	self.ui_config = {"uis/views/tips/shoporexchangetip_prefab", "ShopOrExchangeTip"}
	self.item_info = {}
	self.buy_num_value = 0
	self.consume_type = 0
	self.close_call_back = nil
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipShopView:__delete()

end

function TipShopView:LoadCallBack()
	self.title_name = self:FindVariable("title_name")
	self.item_name = self:FindVariable("item_name")
	self.use_level = self:FindVariable("use_level")
	self.level_color = self:FindVariable("level_color")
	self.buy_num = self:FindVariable("buy_num")
	self.buy_price = self:FindVariable("buy_price")
	self.buy_all_price = self:FindVariable("buy_all_price")
	self.item_icon = self:FindVariable("item_icon")
	self.btn_text = self:FindVariable("btn_text")
	self.coin_icon_1 = self:FindVariable("coin_icon_1")
	self.coin_icon_2 = self:FindVariable("coin_icon_2")
	self.desc_text = self:FindVariable("desc")
	self.my_coin_text = self:FindVariable("my_coin_text")
	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.item_cell:ListenClick(handler)
	self:ListenEvent("minus_click",BindTool.Bind(self.OnMinusClick, self))
	self:ListenEvent("plus_click",BindTool.Bind(self.OnPlusClick, self))
	self:ListenEvent("max_click",BindTool.Bind(self.OnMaxClick, self))
	self:ListenEvent("buy_click",BindTool.Bind(self.OnBuyClick, self))
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("input_click",BindTool.Bind(self.OnTextClick, self))
	self.btn_text:SetValue(Language.Common.CanPurchase)
	self.title_name:SetValue(Language.Common.Shop)
end

function TipShopView:ReleaseCallBack()
	self.item_cell:DeleteMe()
	self.item_cell = nil

	-- 清理变量和对象
	self.title_name = nil
	self.item_name = nil
	self.use_level = nil
	self.level_color = nil
	self.buy_num = nil
	self.buy_price = nil
	self.buy_all_price = nil
	self.item_icon = nil
	self.btn_text = nil
	self.coin_icon_1 = nil
	self.coin_icon_2 = nil
	self.desc_text = nil
	self.my_coin_text = nil
end

function TipShopView:SetItemId(item_id, consume_type, close_call_back, is_use)
	local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	if consume_type == SHOP_BIND_TYPE.BIND then
		data.is_bind = 1
	elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
		data.is_bind = 0
	end
	data.item_id = item_id
	self.item_info = data
	self.close_call_back = close_call_back
	self.consume_type = consume_type
	self.is_use = is_use
end

function TipShopView:CloseCallBack()
	self.close_call_back = nil
	self.item_info = {}
	self.is_use = nil
end

function TipShopView:OpenCallBack()
	local shop_item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	local res_id = 0
	local price = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		res_id = 3
		price = shop_item_cfg.bind_gold
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		res_id = 2
		price = shop_item_cfg.gold
	end
	if next(self.item_info) ~= nil then
		self.item_name:SetValue(ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color]))
		self.buy_price:SetValue(price)
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_price:SetValue(price)
		self:SetAllPrice()
		self.item_cell:SetData(self.item_info)
		self.use_level:SetValue(PlayerData.GetLevelString(self.item_info.limit_level))
		local role_level = GameVoManager.Instance:GetMainRoleVo().level or 0
		self.level_color:SetValue(role_level < self.item_info.limit_level and "#fe3030" or "#00842c")
	end
	local bundle, asset = ResPath.GetDiamonIcon(res_id)
	self.coin_icon_1:SetAsset(bundle, asset)
	self.coin_icon_2:SetAsset(bundle, asset)
	self.desc_text:SetValue(self.item_info.description)

	self:FlushCoin()
end

function TipShopView:FlushCoin()
	local count = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		count = GameVoManager.Instance:GetMainRoleVo().bind_gold
	elseif self.consume_type == SHOP_BIND_TYPE.NO_BIND then
		count = GameVoManager.Instance:GetMainRoleVo().gold
	end
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. "万"
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. "亿"
	end
	self.my_coin_text:SetValue(count)
end

function TipShopView:CloseCallBack()
	self.buy_num_value = 1
	if self.buy_num then
		self.buy_num:SetValue(self.buy_num_value)
	end
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function TipShopView:OnPlusClick()
	local can_buy_num = self:GetCanBuyNum()
	if can_buy_num > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		if self.buy_num_value > 999 then
			self.buy_num_value = 999
		end
		self.buy_num:SetValue(self.buy_num_value)
		self:SetAllPrice()
	end
end

function TipShopView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end
	self.buy_num_value = self.buy_num_value - 1
	self.buy_num:SetValue(self.buy_num_value)
	self:SetAllPrice()
end

function TipShopView:OnMaxClick()
	self.buy_num_value = self:GetCanBuyNum()
	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end
	self.buy_num:SetValue(self.buy_num_value)
	self:SetAllPrice()
end

function TipShopView:GetCanBuyNum()
	local can_buy_num = 0
	local money_can_buy = 0
	if self.consume_type == 1 then
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().bind_gold /ShopData.Instance:GetShopItemCfg(self.item_info.id).bind_gold)
	else
		money_can_buy = math.floor(GameVoManager.Instance:GetMainRoleVo().gold /ShopData.Instance:GetShopItemCfg(self.item_info.id).gold)
	end
	local pile_limit = self.item_info.pile_limit
	if pile_limit >= money_can_buy then
		can_buy_num = money_can_buy
	else
		can_buy_num = pile_limit
	end
	return can_buy_num
end

function TipShopView:SetAllPrice()
	if self.consume_type == 1 then
		self.buy_all_price:SetValue(ShopData.Instance:GetShopItemCfg(self.item_info.id).bind_gold * self.buy_num_value)
	else
		self.buy_all_price:SetValue(ShopData.Instance:GetShopItemCfg(self.item_info.id).gold * self.buy_num_value)
	end
end

function TipShopView:OnBuyClick()
	if self.buy_num_value == 0 then
		return
	end
	local sure_func = function()
		TipsCtrl.Instance:GetRenameView():Close()
		self:Close()
	end
	if self.buy_num_value > self:GetCanBuyNum() then
		if self.consume_type == 1 then
			TipsCtrl.Instance:ShowSystemMsg(Language.Common.NoBindGold)
		else
			TipsCtrl.Instance:ShowLackDiamondView(sure_func)
		end
	else
		if self.consume_type == 1 then
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 1, self.is_use or self.item_info.is_diruse, 0, 0) --使用绑钻
		else
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 0, self.is_use or self.item_info.is_diruse, 0, 0) --使用钻石
		end
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		self:Close()
	end
end

function TipShopView:OnCloseClick()
	self:Close()
end

function TipShopView:OnTextClick()
	local open_func = function(buy_num)
		local can_buy_num = self:GetCanBuyNum()
		if buy_num + 0 == 0 then
			self.buy_num_value = 1
			return
		end

		if buy_num + 0 <= can_buy_num then
			self.buy_num_value = buy_num + 0
		else
			if can_buy_num == 0 then
				self.buy_num_value = 1
			else
				self.buy_num_value = can_buy_num
			end
		end
		self.buy_num:SetValue(self.buy_num_value)
	end

	local close_func = function()
		self:SetAllPrice()
	end

	local max = 0
	if self:GetCanBuyNum() == 0 then
		max = 1
	else
		max = self:GetCanBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,close_func,max)
end