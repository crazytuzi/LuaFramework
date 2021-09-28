MarketQuickSellView = MarketQuickSellView or BaseClass(BaseView)

function MarketQuickSellView:__init()
	self.ui_config = {"uis/views/market_prefab","QuickSell"}
end

function MarketQuickSellView:__delete()

end

function MarketQuickSellView:LoadCallBack()
	self.select_cell = ItemCell.New()
	self.select_cell:SetInstanceParent(self:FindObj("SelectCell"))
	self.input_count = self:FindObj("Count"):GetComponent("InputField")
	self.input_total_price = self:FindObj("TotalPrice"):GetComponent("InputField")
	self.input_price = self:FindObj("Price"):GetComponent("InputField")

	self.item_name = self:FindVariable("ItemName")
	self.item_level = self:FindVariable("ItemLevel")

	self:ListenEvent("OnPlus",
		BindTool.Bind(self.OnPlus, self))
	self:ListenEvent("OnReduce",
		BindTool.Bind(self.OnReduce, self))
	self:ListenEvent("OnSell",
		BindTool.Bind(self.OnSell, self))
	self:ListenEvent("OnSellAll",
		BindTool.Bind(self.OnSellAll, self))
	self:ListenEvent("OnClickCount",
		BindTool.Bind(self.OnClickCount, self))
	self:ListenEvent("OnClickTotalPrice",
		BindTool.Bind(self.OnClickTotalPrice, self))
	self:ListenEvent("Close",
		BindTool.Bind(self.OnClose, self))
end

function MarketQuickSellView:ReleaseCallBack()
	if self.select_cell then
		self.select_cell:DeleteMe()
		self.select_cell = nil
	end
	self.input_count = nil
	self.input_total_price = nil
	self.input_price = nil
	self.item_name = nil
	self.item_level = nil
end

function MarketQuickSellView:OnFlush(param)
	if not param then self:Close() return end
	MarketCtrl.Instance:SendPublicSaleGetUserItemListReq()
	param = param.all
	self.item_index = param.index
	local item_id = param.item_id
	local item_cfg, big_type = ItemData.Instance:GetItemConfig(item_id)

	self.item_name:SetValue(ToColorStr(item_cfg.name, ITEM_COLOR[item_cfg.color]))
	self.item_level:SetValue("LV." .. item_cfg.limit_level)

	self.select_cell:SetData({item_id = item_id})

	self.select_item_count = param.num
	self.total_price = 20

	self.input_count.text = "1"
	self.input_total_price.text = "20"
	self.input_price.text = "2"
end

-- 增加数量
function MarketQuickSellView:OnPlus()
	if(self.select_item_count ~= nil) then
		local count = tonumber(self.input_count.text)
		count = count + 1
		if(count > self.select_item_count) then
			count = self.select_item_count
		end
		self.input_count.text = "" .. count
		self:OnCountChanged()
	end
end

-- 减少数量
function MarketQuickSellView:OnReduce()
	if(self.select_item_count ~= nil) then
		local count = tonumber(self.input_count.text)
		count = count - 1
		if(count < 1) then
			count = 1
		end
		self.input_count.text = "" .. count
		self:OnCountChanged()
	end
end

-- 最大数量
function MarketQuickSellView:OnSellAll()
	if(self.select_item_count ~= nil) then
		local count = self.select_item_count
		self.input_count.text = "" .. count
		self:OnCountChanged()
	end
end


-- 点击数量输入框
function MarketQuickSellView:OnClickCount()
	if(self.select_item_count == nil) then
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.CountInputEnd, self))
end

-- 点击总价输入框
function MarketQuickSellView:OnClickTotalPrice()
	if(self.select_item_count == nil) then
		return
	end
	TipsCtrl.Instance:OpenCommonInputView(nil, BindTool.Bind(self.OnTotalPriceEnd, self), nil, MarketData.MaxPriceGold)
end

function MarketQuickSellView:CountInputEnd(str)
	local count = tonumber(str)
	if(count < 1) then
		count = 1
	elseif(count > self.select_item_count) then
		count = self.select_item_count
	end
	self.input_count.text = count
	self.price = math.floor(self.total_price / count)
	self.input_price.text = self.price <= 1 and 1 or self.price
	self:OnCountChanged()
end

-- 数量改变时
function MarketQuickSellView:OnCountChanged()
	local count = tonumber(self.input_count.text)
	self.price = math.floor(self.total_price / count) <= 1 and 1 or math.floor(self.total_price / count)
	self.input_price.text = "" .. self.price
	self.input_count.text = tostring(count)
end

-- 总价输入完成后
function MarketQuickSellView:OnTotalPriceEnd(str)
	local count = tonumber(str)
	if(count < 2) then
		count = 2
	elseif(count > MarketData.MaxPriceGold) then
		count = MarketData.MaxPriceGold
	end
	self.total_price = count
	self.input_total_price.text = count
	self.price = math.floor(self.total_price / tonumber(self.input_count.text))
	self.input_price.text = self.price <= 1 and 1 or self.price
end

-- 出售
function MarketQuickSellView:OnSell()
	local sale_index = MarketData.Instance:GetValidIndex()

	local sale_num = tonumber(self.input_count.text)
	local sale_price = tonumber(self.input_total_price.text)
	if nil == sale_num or nil == sale_price then
		return
	end
	if 0 == sale_num and 0 == sale_price then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.OtherErrors)
		return
	end
	if 0 == sale_num and 0 ~= sale_price then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.OtherErrors1)
		return
	end
	if 0 ~= sale_num and 0 == sale_price then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.OtherErrors2)
		return
	end
	if sale_index < 0 then
		SysMsgCtrl.Instance:ErrorRemind(Language.Market.JiShouCountLimit)
		return
	end
	local price_type = MarketData.PriceTypeGold
	MarketCtrl.Instance:SendAddPublicSaleItemReq(sale_index, self.item_index, sale_num, sale_price, price_type)
	self:Close()
end

function MarketQuickSellView:OnClose()
	self:Close()
end