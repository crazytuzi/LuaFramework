local tbUI = Ui:CreateClass("RenownShopPanel")

tbUI.tbOnClick = 
{
    BtnOperation = function(self)
    	if not self.tbSelectItem then
	        me.CenterMsg("你没有选中物品");
	        return;
	    end
	    Shop:RenownShopBuy(self.tbSelectItem.nId, self.tbSelectItem.nCount)
    end,

    BtnMinus = function(self)
    	self:ReduceCount()
    end,

    BtnPlus = function(self)
    	self:AddCount()
    end,

    InputNumber = function(self)
	    if not self.tbSelectItem then
	        return
	    end

	    local function fnUpdate(nInput)
	        local nResult = self:UpdateNumberInput(nInput)
	        return nResult
	    end 
	    Ui:OpenWindow("NumberKeyboard", fnUpdate)
    end,
}

function tbUI:OnOpenEnd()
	self.tbSelectItem = nil
	self.pPanel:SetActive("BtnCheckEquipment", false)
    self.pPanel:Label_SetText("RefreshTime", "刷新时间：周一凌晨4:00")
	Shop:RenownShopRefresh()
	self:Refresh()
end

function tbUI:UpdateNumberInput(nNum)
    if not self.tbSelectItem then
        self.pPanel:Label_SetText("InputCountText", 0);
        return;
    end

    if not self:SetCount(nNum) then
        self:SetCount(self.tbSelectItem.nCount, true);
        return self.tbSelectItem.nCount;
    end

    return nNum;
end

function tbUI:AddCount()
    if not self.tbSelectItem then
        return;
    end

    local nCount = self.tbSelectItem.nCount;
    local nToCount = nCount + 1;
    
    self:SetCount(nToCount);
end

function tbUI:ReduceCount()
    if not self.tbSelectItem then
        return;
    end
    local nCount = self.tbSelectItem.nCount;
    local nToCount = nCount - 1;
    nToCount = nToCount < 1  and 1 or nToCount;
    self:SetCount(nToCount);
end

function tbUI:SetCount(nToCount, bAjustment)
    local szMoneyType   = self.tbSelectItem.szMoneyType;
    local nPrice        = self.tbSelectItem.nPrice;

    local nRemainCount = self.tbSelectItem.nRemainCount
    if bAjustment then
        local nMoney = me.GetMoney(szMoneyType)
        local nMax = math.floor(nMoney / nPrice);
        nToCount = nMax;

        if nRemainCount then
            nToCount = nToCount > nRemainCount and nRemainCount or nToCount;
        end
        nToCount = nToCount > 0 and nToCount or 1;
    end

    local nHasMoney = me.GetMoney(szMoneyType)
    if nPrice * nToCount > nHasMoney then
        me.CenterMsg("购买数量已达上限");
        return false;
    end

    if nRemainCount and nToCount > nRemainCount then
        me.CenterMsg("库存不足");
        return false;
    end

    self.tbSelectItem.nCount = nToCount;
    self.pPanel:Label_SetText("InputCountText", nToCount);
    self.pPanel:Label_SetText("TxtCostMoney", self.tbSelectItem.nPrice * nToCount);
    self.pPanel:Label_SetColorByName("TxtCostMoney", "White");

    return true;
end

function tbUI:UpdateRightPanel()
    self.pPanel:Label_SetText("TxtCostMoney", 0);
    local nHasMoney = me.GetMoney("Renown")
    self.pPanel:Label_SetText("TxtHaveMoney", nHasMoney);

    local szIcon, szIconAtlas = Shop:GetMoneyIcon("Renown");
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:SetActive("BtnCheckEquipment", false)

    if self.tbSelectItem then
        local nPrice = self.tbSelectItem.nPrice;
        local nCount = self.tbSelectItem.nCount;
        local nCost = nPrice * nCount;

        self.pPanel:Label_SetText("TxtCostMoney", nCost);
        
        if nPrice * nCount <= nHasMoney then
            self.pPanel:Label_SetColorByName("TxtCostMoney", "White");
        else
            self.pPanel:Label_SetColorByName("TxtCostMoney", "Red");
        end

        self.pPanel:Label_SetText("InputCountText", self.tbSelectItem.nCount or 1);

        local tbBaseInfo = KItem.GetItemBaseProp(self.tbSelectItem.nTemplateId);
        local szTitle = tbBaseInfo.szName;
        local szDetail = tbBaseInfo.szIntro;
        if StoneMgr:IsStone(self.tbSelectItem.nTemplateId) then
            local szClassName = tbBaseInfo.szClass
            local tbClass = Item.tbClass[szClassName]

            local szDesc = ""
            local szConbineTip,szLevelTip,szProperty,szUnique

            if tbClass and tbClass.GetIntrol then
                szConbineTip,szLevelTip,szProperty,szUnique = tbClass:GetIntrol(self.tbSelectItem.nTemplateId);
            end

            if szConbineTip and szConbineTip ~="" then
                szDesc = string.format("镶嵌位置：%s\n", szConbineTip)
            end

            if szLevelTip and szLevelTip ~="" then
                szDesc = string.format("%s魂石等级：%s\n", szDesc, szLevelTip)
            end

            if szProperty and szProperty ~="" then
                szDesc = string.format("%s镶嵌属性：%s\n", szDesc, szProperty)
            end

            if szUnique and szUnique~="" then
                szDesc = string.format("%s%s", szDesc, szUnique)
            end

            if szDesc and szDesc~="" then
                szDetail = szDesc
            end
        end
        szDetail = string.gsub(szDetail, "\\n", "\n") ;

        szDetail = szDetail .. "\n\n" .. "剩余库存:" .. self.tbSelectItem.nRemainCount;
        
        if tbBaseInfo.szClass == "XiuLianDan" then
            local tbItem = Item:GetClass("XiuLianDan");
            local szTipShow = tbItem:GetShowTipInfo(me, tbItem.tbShowShopTip) or "";
            local nCount = tbItem:GetOpenResidueCount(me);
            szTipShow = szTipShow .. "剩余库存:" .. self.tbSelectItem.nRemainCount;
            szDetail = string.format(szTipShow.."\n[FFFE0D]         累积可使用次数：%s[-]", nCount);
        elseif tbBaseInfo.szClass == "ChuangGongDan" then
            local bUse = ChuangGong:IsUsedChuangGongDan(me)
            if bUse then
                szDetail = szDetail.."\n\n\n[ff0000]                     今日已使用[-]";
            end 
        elseif tbBaseInfo.szClass == "waiyi_exchange" then
             local szTip =  Item:GetClass("waiyi_exchange"):GetIntrol(self.tbSelectItem.nTemplateId)
             if not Lib:IsEmptyStr(szTip) then
                szDetail = szTip
             end
        end
        
        self.pPanel:SetActive("GoodsTitle", true)
        self.pPanel:Label_SetText("TxtDetailTitle", szTitle);
        self.pPanel:Label_SetText("TxtDetailContent", szDetail);

        local tbTextSize1 = self.pPanel:Label_GetPrintSize("TxtDetailTitle");
        local tbTextSize2 = self.pPanel:Label_GetPrintSize("TxtDetailContent");
        local tbSize = self.pPanel:Widget_GetSize("datagroup");
        self.pPanel:Widget_SetSize("datagroup", tbSize.x, 20 + tbTextSize1.y + tbTextSize2.y);
        self.pPanel:DragScrollViewGoTop("datagroup");
        self.pPanel:UpdateDragScrollView("datagroup");

    else
        self.pPanel:SetActive("GoodsTitle", false)
        self.pPanel:Label_SetText("TxtDetailContent", ""); 
        self.pPanel:Label_SetText("InputCountText", 0);
        self.pPanel:UpdateDragScrollView("datagroup");
    end
end

function tbUI:Select(nId)
	local tbItems = Shop:RenownShopGetItems()
	local tbItem = nil
    for _, tb in pairs(tbItems) do
        if tb.nId==nId then
            tbItem = tb
            break
        end
    end
    if not tbItem then
        return
    end
	self.tbSelectItem = {
		nId 			= tbItem.nId,
        nTemplateId     = tbItem.nItemId,
        nPrice          = tbItem.nPrice,
        nCount          = 1,
        nRemainCount 	= tbItem.nLeft,
        szMoneyType     = "Renown",
    }
    self:UpdateRightPanel()
end

function tbUI:Refresh()
	if self.tbSelectItem then
		self:Select(self.tbSelectItem.nId)
    else
        self:UpdateRightPanel()
	end

	local tbItems = Shop:RenownShopGetItems()
	local nCount = #tbItems
	local nRows = math.ceil(nCount/2)
	self.RenownGoods:Update(nRows, function(pGrid, nIdx)
		for i=1, 2 do
			local nRealIdx = 2*(nIdx-1)+i
			local tbItem = tbItems[nRealIdx]
			local pItem = pGrid["item"..i]
			pItem.pPanel:SetActive("Main", not not tbItem)
			if tbItem then
				local szName = Item:GetItemTemplateShowInfo(tbItem.nItemId, me.nFaction, me.nSex)
				pItem.pPanel:Label_SetText("TxtItemName", szName)
				pItem.pPanel:SetActive("TipIcon", false)
				pItem.pPanel:SetActive("New", false)

				local szIcon, szIconAtlas = Shop:GetMoneyIcon("Renown")
				pItem.pPanel:Sprite_SetSprite("MoneyIcon", szIcon, szIconAtlas)
				pItem.pPanel:Label_SetText("TxtPrice", tbItem.nPrice)

                local bSoldOut = tbItem.nLeft<=0
				pItem.Item:SetItemByTemplate(tbItem.nItemId, nil, me.nFaction, me.nSex, {
                    bShowCDLayer = bSoldOut,
                })
		        pItem.pPanel:SetActive("TagDT", bSoldOut)
				if bSoldOut then
			        pItem.pPanel:Sprite_SetSprite("TagDT", "OutOfStock")
			    end

			    pItem.pPanel.OnTouchEvent = function()
			    	self:Select(tbItem.nId)
			    end
			    pItem.Item.fnClick = function()
			    	self:Select(tbItem.nId)
			    end 
			end
		end
	end)
end