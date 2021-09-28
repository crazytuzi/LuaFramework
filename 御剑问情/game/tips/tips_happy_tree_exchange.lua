HappyTreeExchangeView = HappyTreeExchangeView or BaseClass(BaseView)

function HappyTreeExchangeView:__init()
	self.ui_config = {"uis/views/tips/shoporexchangetip_prefab", "ShopOrExchangeTip"}
	self.buy_num = 1
	self.play_audio = true
	self.view_layer = UiLayer.Pop
end

function HappyTreeExchangeView:ReleaseCallBack()
	if self.flush_callback ~= nil then
		ExchangeCtrl.Instance:UnNotifyWhenScoreChange(self.flush_callback)
		self.flush_callback = nil
	end
end

function HappyTreeExchangeView:LoadCallBack()
	self.title_name = self:FindVariable("title_name")
	self.item_name = self:FindVariable("item_name")
	self.use_level = self:FindVariable("use_level")
	self.buy_num_text = self:FindVariable("buy_num")
	self.buy_price = self:FindVariable("buy_price")
	self.buy_all_price = self:FindVariable("buy_all_price")
	self.item_icon = self:FindVariable("item_icon")
	self.btn_text = self:FindVariable("btn_text")
	self.desc_text = self:FindVariable("desc")
	self.coin_icon_1 = self:FindVariable("coin_icon_1")
	self.coin_icon_2 = self:FindVariable("coin_icon_2")
	self.item_cell = ItemCell.New()
	self.item_cell:SetInstanceParent(self:FindObj("item_cell"))

	self:ListenEvent("minus_click",BindTool.Bind(self.OnMinusClick, self))
	self:ListenEvent("plus_click",BindTool.Bind(self.OnPlusClick, self))
	self:ListenEvent("max_click",BindTool.Bind(self.OnMaxClick, self))
	self:ListenEvent("buy_click",BindTool.Bind(self.OnBuyClick, self))
	self:ListenEvent("close_click",BindTool.Bind(self.OnCloseClick, self))
	self:ListenEvent("input_click",BindTool.Bind(self.OnTextClick, self))

	self.title_name:SetValue("兑换")
	self.btn_text:SetValue("兑换")
	self.coin_icon_1:SetAsset(ResPath.GetItemIcon(90008))
	self.coin_icon_2:SetAsset(ResPath.GetItemIcon(90008))
	self.flush_callback = BindTool.Bind(self.Flush, self)
	ExchangeCtrl.Instance:NotifyWhenScoreChange(self.flush_callback)
end

function HappyTreeExchangeView:ShowView(data)
	self.data = data
	self:Open()
end

function HappyTreeExchangeView:OpenCallBack()
	self:SetBuyNum(1)
	ExchangeCtrl.Instance:SendGetSocreInfoReq()
end

function HappyTreeExchangeView:OnFlush()
	self.had_score = ExchangeData.Instance:GetScoreList()[7]

	local tmp_num = self.buy_num
	if (tmp_num * self.data.price) > self.had_score then
		self:SetBuyNum(1)
	end

	local cfg = ItemData.Instance:GetItemConfig(self.data.item_id)
	self.item_name:SetValue(cfg.name)
	self.item_cell:SetData({item_id = self.data.item_id})
	if cfg.description ~= nil then
		self.desc_text:SetValue(cfg.description)
	else
		self.desc_text:SetValue("该物品没有描述")
	end
	self.buy_num_text:SetValue(self.buy_num)
	self.buy_price:SetValue(self.data.price)
	self.buy_all_price:SetValue(self.data.price * self.buy_num)
	self.use_level:SetValue(cfg.limit_level or 0)
end

--减号按下
function HappyTreeExchangeView:OnMinusClick()
	local tmp_num = self.buy_num
	tmp_num = tmp_num - 1
	if tmp_num >= 1 then
		self:SetBuyNum(tmp_num)
	end
end

--加号按下
function HappyTreeExchangeView:OnPlusClick()
	local tmp_num = self.buy_num
	tmp_num = tmp_num + 1
	if (tmp_num * self.data.price) <= self.had_score and tmp_num <= 999 then
		self:SetBuyNum(tmp_num)
	else
		TipsCtrl.Instance:ShowSystemMsg("已达最大可兑换数量")
	end
end

--获取能兑换的最大数量
function HappyTreeExchangeView:GetMaxNum()
	local had_score = ExchangeData.Instance:GetScoreList()[7]
	local num = math.floor(had_score / self.data.price)
	if num <= 0 then
		num = 1
	end
	return num
end

--最大按下
function HappyTreeExchangeView:OnMaxClick()
	local max_num = self:GetMaxNum()
	if self.buy_num ~= max_num then
		self:SetBuyNum(max_num)
	else
		TipsCtrl.Instance:ShowSystemMsg("已达最大可兑换数量")
	end
end

--购买按下
function HappyTreeExchangeView:OnBuyClick()
	if self.buy_num * self.data.price <= self.had_score then
		WelfareCtrl.Instance:SendHappyTreeExchange(self.data.conver_type, self.data.seq, self.buy_num)
	else
		TipsCtrl.Instance:ShowSystemMsg("成长值不足")
	end
end

--关闭按下
function HappyTreeExchangeView:OnCloseClick()
	self:Close()
end

--输入框按下
function HappyTreeExchangeView:OnTextClick()
	local ok_func = function(buy_num)
		self:SetBuyNum(buy_num)
	end
	local max_num = self:GetMaxNum()
	TipsCtrl.Instance:OpenCommonInputView(self.buy_num,ok_func,nil,max_num)
end

--设置购买数量
function HappyTreeExchangeView:SetBuyNum(num)
	if num < 1 then
		num = 1
	end
	self.buy_num = num
	self.buy_num_text:SetValue(self.buy_num)
	self.buy_all_price:SetValue(self.data.price * self.buy_num)
end