local tbUi = Ui:CreateClass("ItemSellPanel")

tbUi.tbOnClick = {
	BtnClose = function(self)
		Ui:CloseWindow(self.UI_NAME)
	end,
	BtnBuy = function(self)
		local pItem = KItem.GetItemObj(self.nItemId)
		if not pItem then
			return
		end
		local count = self:GetCurCount()
     	local tbToSell = {
            {
                nId = self.nItemId,
                nCount = count,
            }
        }

        local fnAgree = function ()
        	if not InDifferBattle.bRegistNotofy then
        		RemoteServer.OnShopRequest("Sell", tbToSell, Shop.nRequestIndex);    
        	else
        		RemoteServer.InDifferBattleRequestInst("SellItem", self.nItemId, count);	
        	end
            
            Ui:CloseWindow(self.UI_NAME)
        end
        if pItem.szClass== "equip" then
            local tbRandomAttrib, nMaxQuality = Item:GetClass("equip"):GetRandomAttrib(pItem, me)
            if nMaxQuality < 4 then
                fnAgree()
            else
                Ui:OpenWindow("MessageBox","这件装备上还有一些不错的属性，你确认要出售吗？",
                 { {fnAgree},{} }, 
                 {"同意", "取消"});
            end  
		elseif pItem.szClass == "ZhenYuan" and pItem.GetIntValue(Item.tbZhenYuan.nItemKeySKillInfo) ~= 0 then
			    Ui:OpenWindow("MessageBox","你要出售的这个真元，当前附带有[FFFE0D]技能[-]，出售后将会永久失去该真元，你确定要出售吗？",
                 { {fnAgree},{} }, 
                 {"同意", "取消"});
        else
            fnAgree()  
        end
	end,
	BtnMinus = function(self)
		local count = self:GetCurCount()
		if count<=1 then
			me.CenterMsg("出售数量不能再少了")
			return
		end
		self:SetCurCount(count-1)
	end,
	BtnPlus = function(self)
		local count = self:GetCurCount()
		if count>=self.nMaxCount then
			me.CenterMsg("物品数量就这么多了")
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

function tbUi:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:UpdateNumberInput(nInput)
	local ret = nInput
	if nInput>self.nMaxCount then
		me.CenterMsg("物品数量就这么多了")
		ret = self.nMaxCount
	end

	if nInput<1 then
		me.CenterMsg("出售数量不能再少了")
		ret = 1
	end
	self:SetCurCount(ret)
	return ret
end

function tbUi:GetSellSumPrice(pItem)
	local dwTemplateId = pItem.dwTemplateId
	if InDifferBattle.bRegistNotofy then
		return  InDifferBattle:GetSellSumPrice(dwTemplateId, 1)
	else
		return Shop:GetSellSumPrice(me, dwTemplateId, 1, pItem)
	end
end

function tbUi:OnOpen(nItemId)
	self.nItemId = nItemId
	local pItem = KItem.GetItemObj(nItemId)
    if not pItem then
        return 0;
    end

    self.nMaxCount = pItem.nCount
    self.nPrice, self.szMoneyType = self:GetSellSumPrice(pItem)

    local name = Item:GetDBItemShowInfo(pItem, me.nFaction)
	self.pPanel:Label_SetText("ItemName", name)

	local tbGridParams = {bShowTip = true}
	self.itemframe:SetItem(self.nItemId, tbGridParams)

	self.itemframe.fnClick = self.itemframe.DefaultClick

	local szIcon, szAtlas = Shop:GetMoneyIcon(self.szMoneyType)
	self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szAtlas)
	self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szAtlas)
	self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(self.szMoneyType))
	self:SetCurCount(1)
end

function tbUi:GetCurCount()
	return tonumber(self.pPanel:Label_GetText("Label_Number"))
end

function tbUi:SetCurCount(count)
	self.pPanel:Label_SetText("Label_Number", count)
	self:UpdateCost()
end

function tbUi:UpdateCost()
	local num = self:GetCurCount()
	self.pPanel:Label_SetText("TxtCostMoney", self.nPrice*num)
end
