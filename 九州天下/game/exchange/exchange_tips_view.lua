ExchangeTipView = ExchangeTipView or BaseClass(BaseView)

function ExchangeTipView:__init()
	self.ui_config = {"uis/views/exchangeview", "ExchangeTip"}
	self.item_info = {}
	self.buy_num_value = 1
	self.close_call_back = nil
	self.tips_text = Language.Exchange.CanNotBuy
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function ExchangeTipView:__delete()
end

function ExchangeTipView:ReleaseCallBack()
	if self.item_cell then
		self.item_cell:DeleteMe()
		self.item_cell = nil
	end

	-- 清理变量和对象
	self.item_name = nil
	self.use_level = nil
	self.buy_num = nil
	self.buy_price = nil
	self.count = nil
	self.desc_text = nil
	self.my_coin_text = nil
	self.coin_icon_1 = nil
	self.coin_icon_2 = nil
	self.show_is_max_multiple = nil
	self.level_color = nil
end

function ExchangeTipView:LoadCallBack()
	self.item_name = self:FindVariable("item_name")
	self.use_level = self:FindVariable("use_level")
	self.buy_num = self:FindVariable("buy_num")
	self.buy_price = self:FindVariable("buy_price")
	self.count = self:FindVariable("count")
	self.desc_text = self:FindVariable("desc")
	self:ListenEvent("buy_click",BindTool.Bind(self.OnBuyClick, self))
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self.my_coin_text = self:FindVariable("my_coin_text")
	self.coin_icon_1 = self:FindVariable("coin_icon_1")
	self.coin_icon_2 = self:FindVariable("coin_icon_2")
	self.show_is_max_multiple = self:FindVariable("is_max_multiple")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))
	self.level_color = self:FindVariable("level_color")
	local handler = function()
		local close_call_back = function()
			self.item_cell:ShowHighLight(false)
		end
		self.item_cell:ShowHighLight(true)
		TipsCtrl.Instance:OpenItem(self.item_cell:GetData(), nil, nil, close_call_back)
	end
	self.item_cell:ListenClick(handler)
	self:Flush()
end

function ExchangeTipView:SetItemId(item_id, price_type, conver_type, close_call_back, cur_multile_price, multiple_time, is_max_multiple, click_func)
	local exchange_cfg = ExchangeData.Instance:GetExchangeCfg(item_id, price_type)
	local data, big_type = ItemData.Instance:GetItemConfig(item_id)
	
	self.price_type = price_type
	self.conver_type = conver_type
	self.item_info = TableCopy(data)
	self.item_info.item_id = item_id
	self.item_info.is_bind = exchange_cfg.is_bind
	
	self.close_call_back = close_call_back
	self.cur_multile_price = cur_multile_price
	self.multiple_time = multiple_time
	self.is_max_multiple = is_max_multiple
	self.click_func = click_func

	local prof = PlayerData.Instance:GetRoleBaseProf()
	if big_type == GameEnum.ITEM_BIGTYPE_GIF and (self.item_info.description or self.item_info.description == "") then
		if self.item_info.need_gold and self.item_info.need_gold > 0 then
			self.item_info.description = string.format(Language.Tip.GlodGiftTip, self.item_info.need_gold)
			if self.item_info.rand_num and self.item_info.rand_num ~= "" and self.item_info.rand_num > 0 then
				self.item_info.description = string.format(Language.Tip.GlodRandomGiftTip, self.item_info.need_gold, self.item_info.rand_num)
			end
		else
			self.item_info.description = Language.Tip.FixGiftTip
			if self.item_info.rand_num and self.item_info.rand_num ~= "" then
				self.item_info.description = string.format(Language.Tip.RandomGiftTip, self.item_info.rand_num)
			end
		end
		for k, v in pairs(ItemData.Instance:GetGiftItemList(item_id)) do
			local item_cfg2 = ItemData.Instance:GetItemConfig(v.item_id)
			if item_cfg2 and (item_cfg2.limit_prof == prof or item_cfg2.limit_prof == 5) then
				local color_name_str = "<color="..SOUL_NAME_COLOR[item_cfg2.color]..">"..item_cfg2.name.."</color>"
				if self.item_info.description ~= "" then
					self.item_info.description = self.item_info.description.."\n"..color_name_str.."X"..v.num
				else
					self.item_info.description = self.item_info.description..color_name_str.."X"..v.num
				end
			end
		end
	end
	self:Flush()
end

function ExchangeTipView:OnFlush()
	if next(self.item_info) ~= nil then
		self.item_cell:SetData(self.item_info)
		self.item_name:SetValue(ToColorStr(self.item_info.name, ITEM_COLOR[self.item_info.color]))
		self.buy_price:SetValue(ExchangeData.Instance:GetMultilePrice(self.item_info.item_id, self.price_type))
		local level = GameVoManager.Instance:GetMainRoleVo().level
		if level < self.item_info.limit_level then
			self.level_color:SetValue(TEXT_COLOR.RED)
		else
			self.level_color:SetValue(TEXT_COLOR.GREEN)
		end
		local lv, zhuan = PlayerData.GetLevelAndRebirth(self.item_info.limit_level)
		self.use_level:SetValue(string.format(Language.Common.ZhuanShneng, lv, zhuan))
		self.buy_num:SetValue(self.buy_num_value)
		self.desc_text:SetValue(self.item_info.description)
		self.count:SetValue(self.multiple_time)

		local res = ExchangeData.Instance:GetExchangeRes(self.price_type)
		local bundle1, asset1 = ResPath.GetExchangeNewIcon(res)
		self.coin_icon_1:SetAsset(bundle1, asset1)
		self.coin_icon_2:SetAsset(bundle1, asset1)
		self:FlushCoin()
		self.show_is_max_multiple:SetValue(self.is_max_multiple)
	end
	if ExchangeCtrl.Instance.view:IsOpen() then
		ExchangeCtrl.Instance.view:Flush()
	end
end

function ExchangeTipView:FlushCoin()
	local count = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local str = Language.Mount.ShowBlueStr
	--local all_price = ExchangeData.Instance:GetMultilePrice(self.item_info.id, self.price_type)
	--if tonumber(count) < tonumber(all_price) then
	if tonumber(count) < tonumber(exchange_item_cfg.price) then
		str = Language.Mount.ShowRedStr
	end
	count = CommonDataManager.ConverMoney(count)
	self.my_coin_text:SetValue(string.format(str, count))
end

function ExchangeTipView:GetBuyNum()
	local num = 0
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	local current_score = ExchangeData.Instance:GetCurrentScore(self.price_type)
	local money_can_buy_num = math.floor(current_score/exchange_item_cfg.price)
	if exchange_item_cfg.limit_convert_count ~= 0 then
		local conver_count = ExchangeData.Instance:GetConvertCount(self.item_info.id, self.conver_type, self.price_type)
		--local conver_count = ExchangeData.Instance:GetConvertCount(exchange_item_cfg.seq, self.conver_type, self.price_type)
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

function ExchangeTipView:CloseCallBack()
	self.buy_num_value = 1
	self.buy_num:SetValue(self.buy_num_value)
	self.item_info = {}
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function ExchangeTipView:OnBuyClick()
	local exchange_item_cfg = ExchangeData.Instance:GetExchangeCfg(self.item_info.id, self.price_type)
	if self.buy_num_value > self:GetBuyNum() then
		TipsCtrl.Instance:ShowSystemMsg(self.tips_text)
	else
		ExchangeCtrl.Instance:SendScoreToItemConvertReq(exchange_item_cfg.conver_type, exchange_item_cfg.seq, self.buy_num_value)
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)
		if self.click_func then
			self.click_func()
		end
	end
	self.tips_text = Language.Exchange.CanNotBuy --回到默认状态
end

function ExchangeTipView:OnCloseClick()
	self:Close()
end