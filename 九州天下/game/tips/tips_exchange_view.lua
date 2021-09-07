TipExchangeView = TipExchangeView or BaseClass(BaseView)

function TipExchangeView:__init()
	self.ui_config = {"uis/views/tips/shoporexchangetip", "ShopOrExchangeTip"}
	self.item_info = {}
	self.buy_num_value = 0
	self.close_call_back = nil
	self.tips_text = "今日已达到限购数量"
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipExchangeView:__delete()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
end

function TipExchangeView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end
	if FunctionGuide.Instance then
		FunctionGuide.Instance:UnRegiseGetGuideUi(ViewName.TipExchangeView)
	end

	-- 清理变量和对象
	self.title_name = nil
	self.item_name = nil
	self.use_level = nil
	self.buy_num = nil
	self.buy_price = nil
	self.buy_all_price = nil
	self.btn_text = nil
	self.desc_text = nil
	self.my_coin_text = nil
	self.level_color = nil
	self.coin_icon_1 = nil
	self.coin_icon_2 = nil
	self.exchange_btn_buy = nil
end

function TipExchangeView:LoadCallBack()
	self.title_name = self:FindVariable("title_name")
	self.item_name = self:FindVariable("item_name")
	self.use_level = self:FindVariable("use_level")
	self.buy_num = self:FindVariable("buy_num")
	self.buy_price = self:FindVariable("buy_price")
	self.buy_all_price = self:FindVariable("buy_all_price")
	self.btn_text = self:FindVariable("btn_text")
	self.desc_text = self:FindVariable("desc")
	self:ListenEvent("minus_click",BindTool.Bind(self.OnMinusClick, self))
	self:ListenEvent("plus_click",BindTool.Bind(self.OnPlusClick, self))
	self:ListenEvent("max_click",BindTool.Bind(self.OnMaxClick, self))
	self:ListenEvent("buy_click",BindTool.Bind(self.OnBuyClick, self))
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("input_click",BindTool.Bind(self.OnTextClick, self))
	self.my_coin_text = self:FindVariable("my_coin_text")
	self.level_color = self:FindVariable("level_color")
	self.btn_text:SetValue("兑换")
	self.title_name:SetValue("兑换")
	self.coin_icon_1 = self:FindVariable("coin_icon_1")
	self.coin_icon_2 = self:FindVariable("coin_icon_2")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell:ListenClick(handler)

	self.exchange_btn_buy = self:FindObj("BtnBuy")
	FunctionGuide.Instance:RegisteGetGuideUi(ViewName.TipExchangeView, BindTool.Bind(self.GetUiCallBack, self))
end

function TipExchangeView:SetItemId(item_id, price_type, conver_type, close_call_back)
	local exchange_cfg = ExchangeData.Instance:GetExchangeCfg(item_id, price_type)
	local data = TableCopy(ItemData.Instance:GetItemConfig(item_id))
	data.item_id = item_id
	data.is_bind = exchange_cfg.is_bind
	self.price_type = price_type
	self.conver_type = conver_type
	self.item_info = data
	self.close_call_back = close_call_back
end

function TipExchangeView:OpenCallBack()
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	if next(self.item_info) ~= nil then
		self.item_cell:SetData(self.item_info)
		self.item_name:SetValue(ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color]))
		self.buy_price:SetValue(exchange_item_cfg.price)
		-- if exchange_item_cfg.require_type == 1 then
		local level = GameVoManager.Instance:GetMainRoleVo().level
		if level < self.item_info.limit_level then
			self.level_color:SetValue(TEXT_COLOR.RED)
		else
			self.level_color:SetValue(TEXT_COLOR.GREEN)
		end
		local lv, zhuan = PlayerData.GetLevelAndRebirth(self.item_info.limit_level)
		self.use_level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
		-- end
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_all_price:SetValue(exchange_item_cfg.price * self.buy_num_value)
		self.desc_text:SetValue(self.item_info.description)

		local res = ExchangeData.Instance:GetExchangeRes(self.price_type)
		local bundle1, asset1 = ResPath.GetExchangeNewIcon(res)
		self.coin_icon_1:SetAsset(bundle1, asset1)
		self.coin_icon_2:SetAsset(bundle1, asset1)
		self:FlushCoin()
	end
end

function TipExchangeView:FlushCoin()
	local count = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local str = Language.Mount.ShowBlueStr
	if tonumber(count) < tonumber(exchange_item_cfg.price) then
		str = Language.Mount.ShowRedStr
	end
	if count > 99999 and count <= 99999999 then
		count = count / 10000
		count = math.floor(count)
		count = count .. Language.Common.Wan
	elseif count > 99999999 then
		count = count / 100000000
		count = math.floor(count)
		count = count .. Language.Common.Yi
	end
	self.my_coin_text:SetValue(string.format(str, count))
end

function TipExchangeView:GetBuyNum()
	local num = 0
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local current_score = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local money_can_buy_num = 0
	if exchange_item_cfg and exchange_item_cfg.limit_convert_count ~= 0 then
		money_can_buy_num = math.floor(current_score/exchange_item_cfg.price)
		local conver_count = ExchangeData.Instance:GetConvertCount(exchange_item_cfg.seq, self.conver_type, self.price_type)
		num = exchange_item_cfg.limit_convert_count - conver_count
		if money_can_buy_num < num then
			num = money_can_buy_num
			self.tips_text = ExchangeData.Instance:GetLackScoreTis(self.price_type)
		end
	else
		if money_can_buy_num > 99 then
			num = 99
		else
			num = money_can_buy_num
		end
		self.tips_text = ExchangeData.Instance:GetLackScoreTis(self.price_type)
	end
	return num
end

function TipExchangeView:CloseCallBack()
	self.buy_num_value = 1
	self.buy_num:SetValue(self.buy_num_value)
	self.item_info = {}
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function TipExchangeView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end
	self.buy_num_value = self.buy_num_value - 1
	self.buy_num:SetValue(self.buy_num_value)
	self.buy_all_price:SetValue(ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value)
end

function TipExchangeView:OnPlusClick()
	local temp = self:GetBuyNum()
	if temp > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_all_price:SetValue(ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value)
	end
end

function TipExchangeView:OnMaxClick()
	self.buy_num_value = self:GetBuyNum()
	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end
	self.buy_num:SetValue(self.buy_num_value)
	self.buy_all_price:SetValue(ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value)
end

function TipExchangeView:OnBuyClick()
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	if self.buy_num_value > self:GetBuyNum() then
		TipsCtrl.Instance:ShowSystemMsg(self.tips_text)
	else
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, self.buy_num_value)
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		self:Close()
	end
	self.tips_text = Language.Exchange.CanNotBuy --回到默认状态
end

function TipExchangeView:OnCloseClick()
	self:Close()
end

function TipExchangeView:OnTextClick()
	local open_func = function(buy_num)
		self.buy_num_value = buy_num + 0
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_all_price:SetValue(ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type).price * self.buy_num_value)
	end
	local max = 0
	if self:GetBuyNum() == 0 then
		max = 1
	else
		max = self:GetBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,nil,max)
end

function TipExchangeView:GetUiCallBack(ui_name, ui_param)
	if not self:IsOpen() or not self:IsLoaded() then
		return
	end
	if self[ui_name] then
		if self[ui_name].gameObject.activeInHierarchy then
			return self[ui_name]
		end
	end
end