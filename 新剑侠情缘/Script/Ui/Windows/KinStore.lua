local tbUi = Ui:CreateClass("KinStore");

function tbUi:RegisterEvent()
	local tbRegEvent =
	{
        { UiNotify.emNOTIFY_SYNC_SHOP_WARE,      self.SyncShopWare},
        { UiNotify.emNOTIFY_SHOP_BUY_RESULT,     self.OnResponseBuy},
	};

	return tbRegEvent;
end

function tbUi:GetShopType(nBuildingId)
    local szShopType = Shop.tbFamilyShopIdToChar[nBuildingId];
    if szShopType then
        return szShopType, true
    end
    return nBuildingId
end

function tbUi:OnOpen(nBuildingId)
    local szShopType, bKinStore = self:GetShopType(nBuildingId)
    self.szShopType = szShopType
    self.bKinStore = bKinStore

    if bKinStore and not Kin:HasKin() then
        me.CenterMsg("当前没有家族，请先加入一个家族");
        Ui:OpenWindow("KinJoinPanel");
        return 0;
    end
    Kin:UpdateBuildingData()

    if szShopType == "WarShop" then
        if not Kin:GetBaseInfo() then
            Kin:UpdateBaseInfo()
        end
        local tbCareer = Kin:GetMemberCareer()
        if not tbCareer or not next(tbCareer) then
            Kin:UpdateMemberCareer();
        end 
    end

    self:UpdateSlideBar();
    self.tbSelectItem = nil;
    self:OpenShopPanel();
end


function tbUi:OnResponseBuy()
    self:UpdateWares();
    self:UpdateRightPanel();
end


function tbUi:SyncShopWare()
    self:UpdateWares();
    self:UpdateRightPanel();
end

function tbUi:UpdateSlideBar()
    local szBuildingName1 = Shop.tbCustomShopName[self.szShopType] or ""
    self.pPanel:Label_SetText("Title", szBuildingName1);
end

tbUi.tbOnClick = {};

function tbUi.tbOnClick:BtnMinus()
	self:ReduceCount();
end

function tbUi.tbOnClick:BtnPlus()
	self:AddCount();
end

function tbUi.tbOnClick:BtnOperation()
    if not self.tbSelectItem then
        me.CenterMsg("你没有选中物品");
        return;
    end

    local szMoneyType = self.tbSelectItem.szMoneyType;
    local nbuyCount   = self.tbSelectItem.nCount;
    local nTemplateId = self.tbSelectItem.nTemplateId;
    local nGoodsId = self.tbSelectItem.nGoodsId;

    local bSuccess, szInfo;
    if self.bKinStore then
        bSuccess, szInfo = Shop:CanBuyWare(me, self.szShopType, nTemplateId, nbuyCount);
    else
        bSuccess, szInfo = Shop:CanBuyGoodsWare(me, self.szShopType, nGoodsId, nbuyCount);
    end    
    if not bSuccess then
        me.CenterMsg(szInfo);
        return;
    end

    Shop:TryBuyItem(self.bKinStore, self.szShopType, nTemplateId, nGoodsId, nbuyCount, self.tbSelectItem.nPrice)
end

function tbUi.tbOnClick:BtnCheckEquipment()
    if not self.tbSelectItem then
        return;
    end

    Shop:ViewMyEquip(self.tbSelectItem.nTemplateId)
end

function tbUi.tbOnClick:BtnClose()
	Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OpenShopPanel()
	self.pPanel:SetActive("BuildingPanel", true);
	if self.szShopType == "DrugShop" then
        self.pPanel:SetActive("RefreshTime", true)
    else
        self.pPanel:SetActive("RefreshTime", false)
    end

    self:UpdateWares();
    self:UpdateRightPanel();
    --只是珍宝坊
    if self.szShopType == "DrugShop" then
        RemoteServer.OnShopRequest("CheckFamilyShop");
        Client:SetFlag("OpenKinStoreDay", Lib:GetLocalDay(GetTime() - 3600 * 4))
        Kin:UpdateRedPoint()
    end
end

function tbUi:UpdateWares()
    local tbWares = Shop:GetShopWares(self.szShopType);
    local tbView = tbWares;

    table.sort(tbView, function (item1, item2)
        return item1.nSort < item2.nSort;
    end);

    self.tbScrollView = {};
    for i,v in ipairs(tbView) do
        if i % 2 == 1 then
            table.insert(self.tbScrollView, {[1] = v});
        else
            self.tbScrollView[i/2][2] = v;
        end
    end

    local fnOnClick = function (buttonObj)
        if self.tbSelectItem and self.tbSelectItem.nTemplateId == buttonObj.tbData.nTemplateId then
            buttonObj.pPanel:Toggle_SetChecked("Main", true);
        else
            self.tbSelectItem = {
                nTemplateId     = buttonObj.tbData.nTemplateId,
                nPrice          = buttonObj.tbData.nPrice,
                nCount          = 1,
                szMoneyType     = buttonObj.tbData.szMoneyType,
                nGoodsId        = buttonObj.tbData.nGoodsId,
                };
            self:UpdateRightPanel();
        end
    end

    local fnSetItem = function (itemObj, index)
        for i = 1,2 do
            local tbData = self.tbScrollView[index][i]; 
            if tbData then

                itemObj.pPanel:SetActive("item"..i, true);
                local goodItem = itemObj["item"..i];
                goodItem.pPanel:Label_SetText("TxtPrice", tbData.nPrice);
                local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId);
                goodItem.pPanel:Label_SetText("TxtItemName", tbBaseInfo.szName);
                local szIcon, szIconAtlas = Shop:GetMoneyIcon(tbData.szMoneyType);
                goodItem.pPanel:Sprite_SetSprite("MoneyIcon", szIcon, szIconAtlas);

                if tbData.nDiscount and tbData.nDiscount > 0 then
                    goodItem.pPanel:SetActive("TipIcon", true);
                    goodItem.pPanel:Sprite_SetSprite("TipIcon", "Discount" .. tbData.nDiscount)
                else    
                    goodItem.pPanel:SetActive("TipIcon", false);
                end

                local bCheck = false;
                if self.tbSelectItem and self.tbSelectItem.nTemplateId == tbData.nTemplateId then
                    bCheck = true;
                end
                goodItem.pPanel:Toggle_SetChecked("Main", bCheck);
                
                local tbControls = {};
                local bOutOfStock = false
                if tbData.nRemainCount then
                    tbControls.bShowCDLayer = tbData.nRemainCount == 0;
                    bOutOfStock = tbData.nRemainCount == 0;
                else
                    tbControls.bShowCDLayer = false;
                end
                goodItem.Item:SetItemByTemplate(tbData.nTemplateId, nil, me.nFaction, nil, tbControls);
                if bOutOfStock then
                    goodItem.pPanel:SetActive("TagDT", true)
                    goodItem.pPanel:Sprite_SetSprite("TagDT", "OutOfStock")   
                else
                    goodItem.pPanel:SetActive("TagDT", false)
                end
                
                goodItem.tbData = tbData;
                goodItem.pPanel.OnTouchEvent = fnOnClick;
            else
                itemObj.pPanel:SetActive("item"..i, false);
            end
        end
    end

    self.ScrollViewGoods:Update(#self.tbScrollView, fnSetItem);
end

function tbUi:UpdateRightPanel()
    self.pPanel:Label_SetText("TxtCostMoney", 0);
    local szMoneyType = Shop:GetShopMoneyType(self.szShopType);

    local nHasMoney = self:GetMoneyNum(szMoneyType) 
    self.pPanel:Label_SetText("TxtHaveMoney", nHasMoney);
    

    local szIcon, szIconAtlas = Shop:GetMoneyIcon(szMoneyType);
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:SetActive("BtnCheckEquipment", false)

    if self.tbSelectItem then
        local nPrice = self.tbSelectItem.nPrice;
        local nCount = self.tbSelectItem.nCount;
        local nCost = nPrice * nCount;

        self.pPanel:Label_SetText("TxtCostMoney", nCost);
        
        if nPrice * nCount < nHasMoney then
            self.pPanel:Label_SetColorByName("TxtCostMoney", "White");
        else
            self.pPanel:Label_SetColorByName("TxtCostMoney", "Red");
        end

        self.pPanel:Label_SetText("InputCountText", self.tbSelectItem.nCount or 1);

        local tbBaseInfo = KItem.GetItemBaseProp(self.tbSelectItem.nTemplateId);
        local szTitle = tbBaseInfo.szName;
        local szDetail = tbBaseInfo.szIntro;
        szDetail = string.gsub(szDetail, "\\n", "\n") ;
        

        local nRemainCount = Shop:GetFaimlyWareRemainClient(self.szShopType, self.tbSelectItem.nTemplateId);
        if nRemainCount then
            szDetail = szDetail .. "\n\n" .. "剩余库存:" .. nRemainCount;
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


---------------------数值面板---------------------
function tbUi:AddCount()
    if not self.tbSelectItem then
        return;
    end

    local nCount = self.tbSelectItem.nCount;
    local nToCount = nCount + 1;
    
    self:SetCount(nToCount);
end

function tbUi:ReduceCount()
    if not self.tbSelectItem then
        return;
    end
    local nCount = self.tbSelectItem.nCount;
    local nToCount = nCount - 1;
    nToCount = nToCount < 1  and 1 or nToCount;
    self:SetCount(nToCount);
end

function tbUi:GetMoneyNum(szMoneyType)
    if self.szShopType == "WarShop" then
        local tbKinBase = Kin:GetBaseInfo() or {}
        return tbKinBase and tbKinBase.nFound or 0
    end
    return me.GetMoney(szMoneyType)
end

function tbUi:SetCount(nToCount, bAjustment)
    local szMoneyType   = self.tbSelectItem.szMoneyType;
    local nPrice        = self.tbSelectItem.nPrice;

    if bAjustment then
        local nMoney = self:GetMoneyNum(szMoneyType) 
        local nMax = math.floor(nMoney / nPrice);
        nToCount = nMax;

        local nRemainCount = Shop:GetFaimlyWareRemainClient(self.szShopType, self.tbSelectItem.nTemplateId);
        if nRemainCount then
            nToCount = nToCount > nRemainCount and nRemainCount or nToCount;
        end
        nToCount = nToCount > 0 and nToCount or 1;
    end

    local nHasMoney = self:GetMoneyNum(szMoneyType) 
    if nPrice * nToCount > nHasMoney then
        me.CenterMsg("购买数量已达上限");
        return false;
    end

    local nRemainCount = Shop:GetFaimlyWareRemainClient(self.szShopType, self.tbSelectItem.nTemplateId);
    if nRemainCount and nToCount > nRemainCount then
        me.CenterMsg("库存不足");
        self:SetCount(nRemainCount)
        return false;
    end

    self.tbSelectItem.nCount = nToCount;
    self.pPanel:Label_SetText("InputCountText", nToCount);
    self.pPanel:Label_SetText("TxtCostMoney", self.tbSelectItem.nPrice * nToCount);
    self.pPanel:Label_SetColorByName("TxtCostMoney", "White");

    return true;
end

function tbUi:UpdateNumberInput(nNum)
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

function tbUi.tbOnClick:InputNumber()
    if not self.tbSelectItem then
        return;
    end

    local function fnUpdate(nInput)
        local nResult = self:UpdateNumberInput(nInput);
        return nResult;
    end 
    Ui:OpenWindow("NumberKeyboard", fnUpdate);
end
