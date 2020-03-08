local tbUi = Ui:CreateClass("ItemTemplateSellPanel")

tbUi.tbDoSell =
{
	["Furniture"] = function (self)
		RemoteServer.SellFurniture(self.nItemTemplateId, self.nCurCount);
	end,
}

tbUi.tbGetSellPrice = 
{
	["Furniture"] = function (self)
		return math.floor(KItem.GetBaseValue(self.nItemTemplateId) / 100 * House.fFurnitureSellRatio) , "Contrib";
	end,
}

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,

	BtnBuy = function(self)
		local fnSell = self.tbDoSell[self.szType];
		if not fnSell then
			me.CenterMsg("未知异常！请联系客服");
			return;
		end
		fnSell(self);

		Ui:CloseWindow(self.UI_NAME);
	end,

	BtnMinus = function(self)
		if self.nCurCount <= 1 then
			me.CenterMsg("出售数量不能再少了");
			return;
		end
		self.nCurCount = self.nCurCount - 1;
		self:Refresh();
	end,

	BtnPlus = function(self)
		if self.nCurCount >= self.nMaxCount then
			me.CenterMsg("物品数量就这么多了")
			return;
		end
		self.nCurCount = self.nCurCount + 1;
		self:Refresh();
	end,

	Label_Number = function(self)
		 local function fnUpdate(nInput)
	        local nResult = self:UpdateNumberInput(nInput)
	        return nResult;
	    end 
	    Ui:OpenWindow("NumberKeyboard", fnUpdate)
	end,
}

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:UpdateNumberInput(nInput)
	local nResult = nInput;
	if nInput > self.nMaxCount then
		me.CenterMsg("物品数量就这么多了");
		nResult = self.nMaxCount;
	end

	if nInput < 1 then
		me.CenterMsg("出售数量不能再少了")
		nResult = 1;
	end

	self.nCurCount = nResult;
	self:Refresh();

	return nResult;
end

function tbUi:OnOpen(szType, nItemTemplateId, nMaxCount)
	if nMaxCount <= 0 then
		return 0;
	end

	local tbItemInfo = KItem.GetItemBaseProp(nItemTemplateId);
    if not tbItemInfo then
        return 0;
    end

    self.szType = szType;
	self.nItemTemplateId = nItemTemplateId;
	self.nMaxCount = nMaxCount;
	self.nCurCount = 1;

    local fnGetPrice = self.tbGetSellPrice[self.szType];
    self.nPrice, self.szMoneyType = fnGetPrice(self);

	self.pPanel:Label_SetText("ItemName", tbItemInfo.szName);

	self.itemframe:SetGenericItemTemplate(self.nItemTemplateId, 1);
	self.itemframe.fnClick = self.itemframe.DefaultClick;

	local szIcon, szAtlas = Shop:GetMoneyIcon(self.szMoneyType);
	self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szAtlas);
	self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szAtlas);
	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(self.szMoneyType));
	self:Refresh();
end

function tbUi:Refresh()
	self.pPanel:Label_SetText("Label_Number", self.nCurCount);
	self.pPanel:Label_SetText("TxtCostMoney", self.nPrice * self.nCurCount);
end