local tbBuy = Ui:CreateClass("MarketStallBuyPanel")

tbBuy.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnBuy = function(self)
		local count = self:GetCurCount()
		if me.GetMoney(self.szMoneyType) < count * self.tbData.nPrice then
			local szMoneyName = Shop:GetMoneyName(self.szMoneyType)
			me.CenterMsg(string.format("您的%s不足", szMoneyName))
			return
		end
		if not self.tbData.bInDifferBattle then
			if MarketStall:Buy(self.tbData, count) then
				Ui:CloseWindow(self.UI_NAME)
			end
		else
			RemoteServer.InDifferBattleRequestInst("ShopBuy", self.tbData.nDifferNpcId, self.tbData.nTemplateId, count);
			Ui:CloseWindow(self.UI_NAME)
		end

	end,
	BtnMinus = function(self)
		local count = self:GetCurCount()
		if count<=1 then
			me.CenterMsg("购买数量不能再少了")
			return
		end
		self:SetCurCount(count-1)
	end,
	BtnPlus = function(self)
		local count = self:GetCurCount()
		if count>=self.tbData.nCount then
			me.CenterMsg("购买数量已达上限")
			return
		end
		if me.GetMoney(self.szMoneyType) < (count + 1) * self.tbData.nPrice then
			me.CenterMsg("购买数量已达上限")
			return
		end
		self:SetCurCount(count+1)
	end,
	Label_Number = function(self)
		 local function fnUpdate(nInput)
	        local nResult = self:UpdateNumberInput(nInput)
	        return nResult
	    end
	    Ui:OpenWindow("NumberKeyboard", fnUpdate)
	end,
}

function tbBuy:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_MS_GET_AVG_PRICE, self.OnGetAvgPrice, self},
	}
	return tbRegEvent
end

function tbBuy:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbBuy:UpdateNumberInput(nInput)
	local ret = nInput
	if nInput>self.tbData.nCount then
		me.CenterMsg("购买数量已达上限")
		ret = self.tbData.nCount
	end

	if me.GetMoney(self.szMoneyType) < ret * self.tbData.nPrice then
		me.CenterMsg("购买数量已达上限")
		ret = math.floor(me.GetMoney(self.szMoneyType) / self.tbData.nPrice)
	end

	if ret<1 then
		me.CenterMsg("购买数量不能再少了")
		ret = 1
	end
	self:SetCurCount(ret)
	return ret
end

function tbBuy:OnOpenInDiffer(tbData)
	self.itemframe:SetItemByTemplate(tbData.nTemplateId, tbData.nCount);
	self.itemframe.fnClick = self.itemframe.DefaultClick
	local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId);
	self.pPanel:Label_SetText("ItemName", tbBaseInfo.szName)
	local szIcon, szIconAtlas = Shop:GetMoneyIcon(self.szMoneyType);
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(self.szMoneyType))
    self:SetCurCount(1)
end

function tbBuy:_UpdateAvgPrice()
	MarketStall:GetAvgPrice(self.tbData.szMainType, self.tbData.nSubType)
end

function tbBuy:OnOpen(tbData)
	self.tbData = tbData
	self.szMoneyType = "Gold"

	self.pPanel:SetActive("AveragePrice", not tbData.bInDifferBattle)
	if tbData.bInDifferBattle then
		self.szMoneyType = InDifferBattle.tbDefine.szMonoeyType
		return self:OnOpenInDiffer(tbData)
	end

	local szIcon, szIconAtlas = Shop:GetMoneyIcon(self.szMoneyType);
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);

	local szMainType = self.tbData.szMainType
	local nSubType = self.tbData.nSubType
	local name = MarketStall:GetItemName(szMainType, nSubType)
	self.pPanel:Label_SetText("ItemName", name)
	local tb = MarketStall:GetStallAward(szMainType, nSubType, self.tbData.nCount)
	self.itemframe:SetGenericItem(tb)
	self.itemframe.fnClick = self.itemframe.DefaultClick

	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney("Gold"))
	self:SetCurCount(1)
	self.pPanel:Label_SetText("AveragePrice", "-")
	self:_UpdateAvgPrice()
end

function tbBuy:GetCurCount()
	return tonumber(self.pPanel:Label_GetText("Label_Number"))
end

function tbBuy:SetCurCount(count)
	self.pPanel:Label_SetText("Label_Number", count)
	self:UpdateCost()
end

function tbBuy:UpdateCost()
	local num = self:GetCurCount()
	self.pPanel:Label_SetText("TxtCostMoney", self.tbData.nPrice*num)
end

function tbBuy:OnGetAvgPrice(nPrice)
	self.pPanel:Label_SetText("AveragePrice", nPrice)
end

---------------------------------------------------------

local tbSell = Ui:CreateClass("MarketStallSellPanel")

tbSell.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnMinus1 = function(self)
		local can, newPrice = self:GetNextPrice(true)
		if can then
			self:SetCurPrice(newPrice)
			return
		end
		me.CenterMsg("不能再便宜了")
	end,
	BtnPlus1 = function(self)
		local can, newPrice = self:GetNextPrice(false)
		if can then
			self:SetCurPrice(newPrice)
			return
		end
		me.CenterMsg("不能再贵了")
	end,
	BtnMinus2 = function(self)
		local can, newCount = self:GetNextCount(true)
		if can then
			self:SetCurCount(newCount)
			return
		end
		me.CenterMsg("出售数量不能再少了")
	end,
	BtnPlus2 = function(self)
		local can, newCount = self:GetNextCount(false)
		local maxCount = MarketStall.tbData.tbAvaliableItems[self.curIndex].nCount
		if can and newCount<=maxCount then
			self:SetCurCount(newCount)
			return
		end
		me.CenterMsg("上架数量已达上限")
	end,
	BtnSell = function(self)
		local nPrice = self:GetCurPrice()
		local nCount = self:GetCurCount()
		if MarketStall:NewSell(self.curIndex, nPrice, nCount) then
			Ui:CloseWindow(self.UI_NAME)
		end
	end,
	BtnFreeDownload = function(self)
		if MarketStall:CancelSell(self.curIndex) then
			Ui:CloseWindow(self.UI_NAME)
		end
	end,
	BtnReshelves = function(self)
		local nPrice = self:GetCurPrice()
		local nCount = self:GetCurCount()
		if MarketStall:UpdateSell(self.curIndex, nCount, nPrice) then
			Ui:CloseWindow(self.UI_NAME)
		end
	end,
}

function tbSell:RegisterEvent()
	local tbRegEvent = {
		{UiNotify.emNOTIFY_MS_GET_AVG_PRICE, self.OnGetAvgPrice, self},
	}
	return tbRegEvent
end

function tbSell:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbSell:IsPriceValid(nPrice)
	for _,v in ipairs(self.tbAllowPrice) do
		if nPrice==v then
			return true
		end
	end
	return false
end

function tbSell:GetNextPrice(bDesc)
	local curPrice = self:GetCurPrice()
	for i,v in ipairs(self.tbAllowPrice) do
		if v==curPrice then
			if bDesc then
				if i>1 then
					return true, self.tbAllowPrice[i-1]
				end
				return false
			else
				if i<#self.tbAllowPrice then
					return true, self.tbAllowPrice[i+1]
				end
				return false
			end
		end
	end
	return false
end

function tbSell:InitValidCounts()
	self.tbValidCounts = {}
	for k in pairs(MarketStall.tbAllowCount) do
		table.insert(self.tbValidCounts, k)
	end
	table.sort(self.tbValidCounts, function(a,b) return a<b end)
end

function tbSell:GetNextCount(bDesc)
	local cur = self:GetCurCount()
	if not MarketStall.tbAllowCount then
		cur = self.tbValidCounts[1]
		return true, cur
	end

	for i,v in ipairs(self.tbValidCounts) do
		if v==cur then
			if bDesc then
				if i>1 then
					return true, self.tbValidCounts[i-1]
				end
				return false
			else
				if i<#self.tbValidCounts then
					return true, self.tbValidCounts[i+1]
				end
				return false
			end
			return false
		end
	end

	return false
end

function tbSell:_UpdateAvgPrice()
	MarketStall:GetAvgPrice(self.tbData.szMainType, self.tbData.nSubType)
end

function tbSell:OnOpen(index, bBag)
	self.pPanel:SetActive("BtnSell", bBag)
	self.pPanel:SetActive("BtnReshelves", not bBag)
	self.pPanel:SetActive("BtnFreeDownload", not bBag)

	self.curIndex = index
	self.bBag = bBag
	self.tbData = bBag and MarketStall.tbData.tbAvaliableItems[index] or MarketStall.tbData.tbMyItems[index]
	self.nBasePrice, self.tbAllowPrice = MarketStall:GetPriceInfo(self.tbData.szMainType, self.tbData.nSubType)
	self.nBasePrice = self.nBasePrice or 0;
	self.tbAllowPrice = self.tbAllowPrice or {};
	self:InitValidCounts()

	self:_UpdateAvgPrice()

	local tbTemp = {}
	for k in pairs(self.tbAllowPrice) do
		table.insert(tbTemp, k)
	end
	table.sort(tbTemp, function(a,b) return a<b end)
	self.tbAllowPrice = tbTemp

	local tb = MarketStall:GetStallAward(self.tbData.szMainType, self.tbData.nSubType, self.tbData.nCount)
	self.itemframe:SetGenericItem(tb)
	self.itemframe.fnClick = self.itemframe.DefaultClick

	local name = MarketStall:GetItemName(self.tbData.szMainType, self.tbData.nSubType)
	self.pPanel:Label_SetText("ItemName", name)

	self:SetCurCount(bBag and 1 or self.tbData.nCount)
	self.pPanel:Button_SetEnabled("BtnMinus2", bBag)
	self.pPanel:Button_SetEnabled("BtnPlus2", bBag)

	local nPrice = bBag and self.nBasePrice or self.tbData.nPrice
	if bBag then
		local nSavedPrice = MarketStall:GetSavedPrice(self.tbData.szMainType, self.tbData.nSubType)
		if nSavedPrice and nSavedPrice>0 then
			nPrice = nSavedPrice
		end
	end
	if not self:IsPriceValid(nPrice) then
		nPrice = self.nBasePrice
	end

	if not self:IsPriceValid(nPrice) then
		nPrice = 0;
		for _, nCP in pairs(self.tbAllowPrice) do
			nPrice = math.max(nCP, nPrice);
		end
	end

	self:SetCurPrice(nPrice)
	self.pPanel:Label_SetText("AveragePrice", "-")
end

function tbSell:UpdateChargeCost()
	local nCount = self:GetCurCount()
	local nPrice = self:GetCurPrice()
	local nCost = nCount*nPrice
	local nCharge = MarketStall:GetSellCost(nCost)
	self.pPanel:Label_SetText("TxtHaveMoney", nCharge)
	self.pPanel:Label_SetText("TxtCostMoney", nCost)
end

function tbSell:UpdateIncDesc()
	local curPrice = self:GetCurPrice()
	local str = "基准价格"
	if curPrice~=self.nBasePrice then
		local delta = curPrice-self.nBasePrice
		local strPrefix = delta>0 and "+" or "-"
		local addInfo = string.format("%d%%", math.ceil(100*math.abs(delta)/self.nBasePrice))
		str = str..strPrefix..addInfo
	end
	self.pPanel:Label_SetText("RecommendedPrice", str)
end

function tbSell:GetCurPrice()
	return tonumber(self.pPanel:Label_GetText("UnitPrice_Number"))
end

function tbSell:SetCurPrice(price)
	self.pPanel:Label_SetText("UnitPrice_Number", price)
	self:UpdateIncDesc()
	self:UpdateChargeCost()
end

function tbSell:GetCurCount()
	return tonumber(self.pPanel:Label_GetText("Label_Number"))
end

function tbSell:SetCurCount(count)
	self.pPanel:Label_SetText("Label_Number", count)
	self.itemframe.pPanel:Label_SetText("LabelSuffix", count)
	self:UpdateChargeCost()
end

function tbSell:OnGetAvgPrice(nPrice)
	self.pPanel:Label_SetText("AveragePrice", nPrice)
end
