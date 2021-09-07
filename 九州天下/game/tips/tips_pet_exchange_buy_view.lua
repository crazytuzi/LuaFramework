TipPetExchangeBuyView = TipPetExchangeBuyView or BaseClass(BaseView)

function TipPetExchangeBuyView:__init()
	self.ui_config = {"uis/views/tips/shoporexchangetip", "ShopOrExchangeTip"}
	self.item_info = {}
	self.buy_num_value = 0
	self.view_layer = UiLayer.Pop
	self.play_audio = true
end

function TipPetExchangeBuyView:__delete()
end

function TipPetExchangeBuyView:LoadCallBack()
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
end

function TipPetExchangeBuyView:SetItemId(item_id, close_call_back)
	local exchange_cfg = PetData.Instance:GetSingleExchangeCfg(item_id)
	local data = {}
	data = ItemData.Instance:GetItemConfig(item_id)
	data.item_id = item_id
	data.is_bind = exchange_cfg.is_bind
	self.item_info = data
	self.close_call_back = close_call_back
end

function TipPetExchangeBuyView:OpenCallBack()
	if self.item_info ~= {} then
		local exchange_cfg = PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id)
		local item_cfg = ItemData.Instance:GetItemConfig(self.item_info.item_id)

		self.item_cell:SetData(self.item_info)
		self.item_name:SetValue(self.item_info.name)
		self.buy_price:SetValue(exchange_cfg.need_score)
		self.use_level:SetValue(item_cfg.limit_level)
		self.buy_num_value = 1
		self.buy_num:SetValue(self.buy_num_value)

		self.buy_all_price:SetValue(exchange_cfg.need_score * self.buy_num_value)
		self.desc_text:SetValue(self.item_info.description)
		local temp_price = 1
		local bundle1, asset1 = ResPath.GetExchangeIcon(temp_price)
		self.coin_icon_1:SetAsset(bundle1, asset1)
		self.coin_icon_2:SetAsset(bundle1, asset1)
		self:FlushCoin()
	end
end

function TipPetExchangeBuyView:FlushCoin()
	local exchange_cfg = PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id)
	local all_num = exchange_cfg.need_score * self.buy_num_value

	local count = PetData.Instance:GetAllInfoList().score
	local flag = true  --显示绿色
	if count < all_num  then
		flag = false  --显示红色
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
	if not flag then
		count = string.format("<color='#FF0000FF'>%s</color>", count)  --红色
	else
		count = string.format("<color='#00FD00FF'>%s</color>", count) --绿色
	end

	self.my_coin_text:SetValue(count)
end

function TipPetExchangeBuyView:CloseCallBack()
	self.buy_num_value = 1
	self.buy_num:SetValue(self.buy_num_value)
	self.item_info = {}
	if self.close_call_back ~= nil then
		self.close_call_back()
		self.close_call_back = nil
	end
end

function TipPetExchangeBuyView:GetBuyNum()
	local num = 0
	local exchange_item_cfg = PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id)
	local current_score = PetData.Instance:GetAllInfoList().score
	local money_can_buy_num = math.floor(current_score/exchange_item_cfg.need_score)
	if money_can_buy_num > 99 then
		num = 99
	else
		num = money_can_buy_num
	end
	return num
end

function TipPetExchangeBuyView:OnMinusClick()
	if self.buy_num_value == 1 then
		return
	end
	self.buy_num_value = self.buy_num_value - 1
	self.buy_num:SetValue(self.buy_num_value)
	self.buy_all_price:SetValue(PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id).need_score * self.buy_num_value)
end

function TipPetExchangeBuyView:OnPlusClick()
	local temp = self:GetBuyNum()
	if temp > self.buy_num_value then
		self.buy_num_value = self.buy_num_value + 1
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_all_price:SetValue(PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id).need_score * self.buy_num_value)
	end
end

function TipPetExchangeBuyView:OnMaxClick()
	self.buy_num_value = self:GetBuyNum()
	if self.buy_num_value > 999 then
		self.buy_num_value = 999
	elseif self.buy_num_value == 0 then
		self.buy_num_value = 1
	end
	self.buy_num:SetValue(self.buy_num_value)
	self.buy_all_price:SetValue(PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id).need_score * self.buy_num_value)
end

function TipPetExchangeBuyView:OnBuyClick()
	local exchange_item_cfg = PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id)
	PetCtrl.Instance:SendLittlePetREQ(LITTLE_PET_REQ_TYPE.LITTLE_PET_REQ_EXCHANGE, exchange_item_cfg.seq, self.buy_num_value, 0)
	self.buy_num_value = 1
	self.buy_num:SetValue(self.buy_num_value)
	self:Close()
end

function TipPetExchangeBuyView:OnCloseClick()
	self:Close()
end

function TipPetExchangeBuyView:OnTextClick()
	local open_func = function(buy_num)
		self.buy_num_value = buy_num + 0
		self.buy_num:SetValue(self.buy_num_value)
		self.buy_all_price:SetValue(PetData.Instance:GetSingleExchangeCfg(self.item_info.item_id).need_score * self.buy_num_value)
	end
	local max = 0
	if self:GetBuyNum() == 0 then
		max = 1
	else
		max = self:GetBuyNum()
	end
	TipsCtrl.Instance:OpenCommonInputView(0,open_func,nil,max)
end