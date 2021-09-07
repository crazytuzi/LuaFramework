ShopInfoView = ShopInfoView or BaseClass(BaseRender)

function ShopInfoView:__init()
	self.item_info = {}
	self.buy_num_value = 0
	self.consume_type = 0
end

function ShopInfoView:__delete()

	-- 清理变量和对象
	self.buy_num = nil
	self.buy_all_price = nil
	self.coin_icon = nil
	self.desc_text = nil
	self.item_info = {}
end

function ShopInfoView:LoadCallBack()
	self.limit_num = self:FindVariable("limit_num")
	self.is_show_limit = self:FindVariable("is_show_limit")
	self.buy_num = self:FindVariable("buy_num")
	self.buy_all_price = self:FindVariable("buy_all_price")
	self.coin_icon = self:FindVariable("coin_icon")
	self.desc_text = self:FindVariable("desc")
	self.remind_str = self:FindVariable("remind_str")

	self:ListenEvent("buy_click",BindTool.Bind(self.OnBuyClick, self))
	self:ListenEvent("input_click",BindTool.Bind(self.OnTextClick, self))
end

function ShopInfoView:SetItemId(item_id, consume_type)
	local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	if not data or not next(data) then return end
	if consume_type == SHOP_BIND_TYPE.BIND then
		data.is_bind = 1
	elseif consume_type == SHOP_BIND_TYPE.NO_BIND then
		data.is_bind = 0
	end
	data.item_id = item_id
	self.item_info = data
	self.consume_type = consume_type

	self:Flush()
end

function ShopInfoView:OnFlush()
	if not self.item_info or not next(self.item_info) then return end

	local shop_item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)
	local res_id = 1000
	local price = 0
	if self.consume_type == SHOP_BIND_TYPE.BIND then
		res_id = 1001
	end
	if next(self.item_info) ~= nil then
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		self:SetAllPrice()
	end
	local bundle, asset = ResPath.GetGoldIcon(res_id)
	self.coin_icon:SetAsset(bundle, asset)

	local description = ItemData.Instance:GetItemDescription(self.item_info.id)
	self.desc_text:SetValue(description)
	
	local buy_limit_num = shop_item_cfg.buy_limit - ShopData.Instance:GetShopBuyNum(self.item_info.id)
	self.is_show_limit:SetValue(shop_item_cfg.buy_limit > 0)
	self.limit_num:SetValue(buy_limit_num)
	if shop_item_cfg.buy_limit > 0 then
		self.remind_str:SetValue(Language.Shop.ShopLimitRemind)
	else
		--self.remind_str:SetValue(Language.Shop.ShopGoldRemind)
		self.remind_str:SetValue("")
	end
end

function ShopInfoView:OnFlushLimitZero()
	if not self.item_info or not next(self.item_info) then return end

	if self.consume_type == SHOP_BIND_TYPE.IS_LIMUIT then 
		if ShopData.Instance:GetLimitMaxNum(self.item_info.id) <= 0 then
			ShopContentView.Instance:ClearCurIndex()
			ShopContentView.Instance:SetShowInfoView(false)
			ShopContentView.Instance:OnFlushListView()
		end
	end
end

function ShopInfoView:GetCanBuyNum()
	local can_buy_num = 0
	local money_can_buy = 0
	local pile_limit = 0 
	local main_vo = GameVoManager.Instance:GetMainRoleVo()
	local shop_item_cfg = ShopData.Instance:GetShopItemCfg(self.item_info.id)

	if self.consume_type == SHOP_BIND_TYPE.IS_LIMUIT then
		money_can_buy = math.floor(main_vo.gold / shop_item_cfg.vip_gold)
		pile_limit = ShopData.Instance:GetLimitMaxNum(self.item_info.id)
	elseif self.consume_type == SHOP_BIND_TYPE.BIND then
		money_can_buy = math.floor((main_vo.bind_gold + main_vo.gold) / shop_item_cfg.bind_gold)
		pile_limit = self.item_info.pile_limit
	else
		money_can_buy = math.floor(main_vo.gold / shop_item_cfg.gold)
		pile_limit = self.item_info.pile_limit
	end

	if pile_limit >= money_can_buy then
		can_buy_num = money_can_buy
	else
		can_buy_num = pile_limit
	end
	return can_buy_num
end

function ShopInfoView:SetAllPrice()
	if self.consume_type == SHOP_BIND_TYPE.IS_LIMUIT then
		self.buy_all_price:SetValue(ShopData.Instance:GetShopItemCfg(self.item_info.id).vip_gold * self.buy_num_value)
	elseif consume_type == SHOP_BIND_TYPE.BIND then
		self.buy_all_price:SetValue(ShopData.Instance:GetShopItemCfg(self.item_info.id).bind_gold * self.buy_num_value)
	else
		self.buy_all_price:SetValue(ShopData.Instance:GetShopItemCfg(self.item_info.id).gold * self.buy_num_value)
	end
end

function ShopInfoView:OnBuyClick()
	if self.buy_num_value == 0 then
		return
	end
	
	if self.consume_type == SHOP_BIND_TYPE.IS_LIMUIT then
		ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 0, self.item_info.is_diruse, 0, 0, 1) 
	elseif self.consume_type == SHOP_BIND_TYPE.BIND then
		local role_vo = GameVoManager.Instance:GetMainRoleVo()
		local role_bind_gold = role_vo.bind_gold
		local role_gold = role_vo.gold
		local item_bind_gold = ShopData.Instance:GetShopItemCfg(self.item_info.id).bind_gold
		if role_bind_gold >= item_bind_gold then
			ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 1, self.item_info.is_diruse, 0, 0, 0) --使用绑钻
		else
			if role_gold + role_bind_gold >= item_bind_gold then
				local des = Language.Shop.ShopBuyRemind
				local function ok_callback()
					ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 1, self.item_info.is_diruse, 0, 0, 0)
				end
				TipsCtrl.Instance:ShowCommonAutoView("true", des, ok_callback)
			else
				ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 1, self.item_info.is_diruse, 0, 0, 0)
			end
		end
	else
		ExchangeCtrl.Instance:SendCSShopBuy(self.item_info.id, self.buy_num_value, 0, self.item_info.is_diruse, 0, 0, 0) --使用钻石
	end

	self:Flush()
end

function ShopInfoView:OnTextClick()
	local open_func = function(buy_num)
		local can_buy_num = self:GetCanBuyNum()
		if buy_num + 0 <= 0 then
			self.buy_num_value = 1
			self.buy_num:SetValue(self.buy_num_value)
			return
		end

		if buy_num + 0 <= can_buy_num then
			self.buy_num_value = buy_num + 0
		else
			if can_buy_num <= 0 then
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
	if self:GetCanBuyNum() <= 0 then
		max = 1
	else
		max = self:GetCanBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0, open_func, close_func, max)
end