local RepresentSetting = luanet.import_type("RepresentSetting");
----代码区域
----Current UI-------
----Shop Common------
----TradingCenter----
----ShopSell---------
----CommonShop-------
----ReCharge---------

local CommonShop = Ui:CreateClass("CommonShop");

----Current UI-------Begin
CommonShop.tbOnClick = CommonShop.tbOnClick or {};

function CommonShop.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end


function CommonShop.tbOnClick:BtnTreasureShop()
    if self.szPage ~= "Treasure" then
        self:CheckReOpen("Treasure")
        self:SelectPage("Treasure");
        self:OnOpenEnd();
    end
end

function CommonShop.tbOnClick:BtnPrestige()
    if self.szPage~="Renown" then
        self:SelectPage("Renown")
        self:OnOpenEnd()
    end
end

-- function CommonShop.tbOnClick:BtnHonorShop()
--     if self.szPage ~= "Honor" then
--         self:SelectPage("Honor");
--         self:OnOpenEnd();
--     end
-- end

-- function CommonShop.tbOnClick:BtnBiographyShop()
--     if self.szPage ~= "Biography" then
--         self:SelectPage("Biography");
--         self:OnOpenEnd();
--     end
-- end

function CommonShop.tbOnClick:BtnRecharge()
    if self.szPage ~= "Recharge" then
        self:SelectPage("Recharge");
        self:OnOpenEnd();
    end
end

function CommonShop.tbOnClick:BtnDress()
    if self.szPage ~= "Dress" then
        self:CheckReOpen("Dress")
        self:SelectPage("Dress");
        self:OnOpenEnd(); 
    end
end

function CommonShop.tbOnClick:Label_Number()
    if not self.tbSelectItem then
        return;
    end

    local function fnUpdate(nInput)
        local nResult = self:UpdateNumberInput(nInput);
        return nResult;
    end 
    Ui:OpenWindow("NumberKeyboard", fnUpdate);
end

function  CommonShop.tbOnClick:BtnPreview() 
    if not self.tbSelectItem then
        return;
    end
    local nTemplateId = self.tbSelectItem.nTemplateId
    local tbItemBase = KItem.GetItemBaseProp(nTemplateId)
    local nTargetWaiyi;
    if tbItemBase.szClass == "ExchangeItemByFaction" then
        nTargetWaiyi = Item:GetClass("ExchangeItemByFaction"):GetExhangeItemId(nTemplateId, me.nFaction)
    else
        if Item.tbEquipExchange.tbItemSetting[nTemplateId] then
            nTargetWaiyi = Item.tbEquipExchange.tbItemSetting[nTemplateId].WaiYiItem
        end
    end 
    if not nTargetWaiyi then
        return
    end

    local tbBaseProp = KItem.GetItemBaseProp(nTargetWaiyi)
    local nFaction = me.nFaction;
    if tbBaseProp.nFactionLimit > 0 and me.nFaction ~= tbBaseProp.nFactionLimit then
        nFaction = tbBaseProp.nFactionLimit
    end
    Ui:OpenWindow("WaiyiPreview", nTargetWaiyi, nFaction);
end

CommonShop.tbPageTitle = {
    Treasure        = "珍宝阁",
    Recharge        = "充值",
    Renown          = "名望商店",
    Dress           = "黎饰商店",
}

--只是一个默认，实际还是安装页内的商品来
CommonShop.tbShopMoneyType = {
    Treasure = "Gold",
    Renown ="Renown",
    Dress = "SilverBoard",
}

function CommonShop:SetPageTitle()
    local szTitle = self.tbPageTitle[self.szPage];
    self.pPanel:Label_SetText("Title", szTitle);
end

local tbUiToTabName = 
{
    Recharge = "BtnRecharge",
    Treasure = "BtnTreasureShop",
    -- Honor    = "BtnHonorShop",
    -- Biography= "BtnBiographyShop",
    Renown = "BtnPrestige",
    Dress = "BtnDress",
}


function CommonShop:UpdatePageShow()
    for szPage, szName in pairs(tbUiToTabName) do
        local bShowTab = szPage == self.szPage
        self[szName].pPanel:SetActive("LabelLight", bShowTab);
        self[szName].pPanel:SetActive("Label", not bShowTab);
        self.pPanel:Toggle_SetChecked(szName, bShowTab)
    end
end

function CommonShop:GetShowTabs(szShopType)
    local tbShowTabs = CommonShop.tabDefaultTabs[szShopType]
    if not tbShowTabs then
        return
    end
    tbShowTabs  = Lib:CopyTB(tbShowTabs)
    if Shop.nNewstActWareUpdateTime and Shop.tbActShopTypes and Shop.tbActShopTypes[szShopType] then
        local tbWares = Shop:GetShopWares(szShopType, nil,true)
        local tbOldHasTabs = {}
        local tbHasTabs = {}
        for i,v in ipairs(tbShowTabs) do
            tbOldHasTabs[v] = 1;
        end
        for i,v in ipairs(tbWares) do
            if not Lib:IsEmptyStr(v.SubType) then
                tbHasTabs[v.SubType] = 1;
            end
        end
        for k,v in pairs(tbHasTabs) do
            if not tbOldHasTabs[k] then
                if szShopType == "Dress" and string.find(k, "tabAct") then
                    table.insert(tbShowTabs, 1,k)
                else
                    table.insert(tbShowTabs, k)
                end
            end
        end
    end
    return tbShowTabs
end

--当前有活动时界面会变化
function CommonShop:CheckReOpen(szPage)
    local tbCurTabs = CommonShop.tbTabText[szPage]
    if not tbCurTabs then
       return
    end
    local tbShouldTabs = self:GetShowTabs(szPage)
    local bRet = not Lib:CompareArray(tbCurTabs, tbShouldTabs)
    CommonShop.tbTabText[szPage] = tbShouldTabs
    return bRet 
end

function CommonShop:OnOpen(szPage, param2, param3)    
    if not  Recharge.IS_OPEN then
        self.pPanel:SetActive(tbUiToTabName.Recharge, false)
        if szPage == "Recharge" then
            -- me.CenterMsg("本次测试期间，不开放充值")
            return 0;
        end    
    end

    if szPage and (szPage == "Honor" or szPage == "Biography") then
        return 0;
    end

    self.pPanel:SetActive("BtnDress", Recharge:CanBuyDressMoney() and true or false)

    Shop:RequestLimitInfo();
    

    if not szPage then
        if not self.szPage then
            szPage = "Treasure"; --默认打开
        else
            szPage = self.szPage;
        end
    end
    self.OpenParam2 = param2

    self:CheckReOpen(szPage) 
    self:SelectPage(szPage);
    
end

local function fnFindTargetItem(self, nTemplateId)
    if not self.tbScrollView then
        return
    end
    for i, v in ipairs(self.tbScrollView) do
        for i2 =1, 2 do
            if v[i2] and v[i2].nTemplateId == nTemplateId then
                return i, i2
            end
        end
    end
end 

function CommonShop:OnOpenEnd(szPage, param2, param3)
    self:UpdatePageShow();
    if self.szPage == "Recharge" then
        self.Recharge:OnOpenEnd(param2, param3)
        return;
    elseif self.szPage == "Dress" then
        self.DressShop:OnOpenEnd(param2, param3)
        return 
    elseif  self.szPage == "Treasure" then
        self:UpdateTabPanel();    
        --选中指定商品
        if  param3 and type(param3) == "number" then --指定道具
            local nFindRow, nFindCol = fnFindTargetItem(self, param3);
            if nFindRow and nFindCol then
                self.ScrollViewGoods.pPanel:ScrollViewGoToIndex("Main", nFindRow);
                local Grid = self.ScrollViewGoods.Grid;
                local szCol = "item" .. nFindCol
                for i = 0, 100 do
                    local itemObj = Grid["Item" .. i]
                    if itemObj then
                        local goodItem = itemObj[szCol]                    
                        if goodItem and goodItem.tbData and goodItem.tbData.nTemplateId == param3 then
                            goodItem.pPanel.OnTouchEvent(goodItem)
                            break;
                        end
                    else
                        break;
                    end
                end
            end

        end
        

    end
end

function CommonShop:SelectPage(szPage)
    self.szPage = szPage;
    local param2 = self.OpenParam2
    if type(param2) == "number" then
        self.nSelectTab = param2 --标签页
    elseif type(param2) == "string" then
        local tbPages = CommonShop.tbTabText[szPage]
        if tbPages then
            for i, v in pairs(tbPages) do
                if v == param2 then
                    self.nSelectTab = i;
                    break;
                end
            end
        end
        
    else
        if CommonShop.tbTabText[szPage] and #CommonShop.tbTabText[szPage] >= 3 then
            self.nSelectTab = 3 --活动页是逻辑上的第三个
        else
            self.nSelectTab = 1
        end
    end
    self:CloseTimer();
    self:SetPageTitle();


    self.pPanel:SetActive("Recharge", szPage == "Recharge");
    self.pPanel:SetActive("Shop", szPage == "Treasure");
    self.pPanel:SetActive("PrestigeShop", szPage == "Renown")
    self.pPanel:SetActive("DressShop", szPage == "Dress")
    self.pPanel:SetActive("BtnOperation", true)
    self.pPanel:SetActive("BtnOperation2", false)
    self.pPanel:SetActive("BtnExchange", false)

    if self.szPage == "Recharge" then
        self:OnOpenRecharge();
    elseif self.szPage == "Treasure" then
        self:OnOpenCommonShop();
    elseif self.szPage == "Dress" then
        self:OnOpenDressShop();
    elseif self.szPage == "Renown" then
        self:OnOpenRenown()
    end
end

function CommonShop:CloseTimer()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil
    end
end


function CommonShop:SyncShopWare()
    --假如现在有商品act但之前只有2getab，或者是反过来的情况  则是重新打开 
    if self:CheckReOpen(self.szPage) then
        self:SelectPage(self.szPage);        
        if self.szPage == "Dress" then
            self.DressShop:OnOpenEnd()
        else
            self:UpdateTabPanel()
        end
    end

    if self.szPage == "Dress" then
       self.DressShop:UpdateShopWares()
    else 
        self:UpdateWares();
        self:UpdateRightPanel();    
    end
end

function CommonShop:OnResponseBuy()
    self:UpdateRightPanel();
    self:UpdateWares();
end

function CommonShop:UpdateWares()
    self:UpdateShopWares()
end

function CommonShop:OnResponseSell()
    self.tbSelectItem = nil;
    self:UpdateSellPanel();
    self:UpdateRightPanel();
end

function CommonShop:OnResponseRecharge()
    if self.szPage ~= "Recharge" then
        return
    end

    self:SelectPage("Recharge")
    self:OnOpenEnd();
end

function CommonShop:RefreshRenown()
    if self.szPage~="Renown" then
        return
    end

    self.PrestigeShop:Refresh()
end

function CommonShop:OnRefresMoney()
    if self.szPage == "Dress" then
        self.DressShop:UpdateShopWares();
        self.DressShop:UpdateRightPanel();      
    else
        self:UpdateRightPanel();
    end
end

function CommonShop:OnLoadResFinish()
    if self.szPage == "Dress" then
        self.DressShop:OnLoadResFinish()        
    end
end

function CommonShop:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_SHOP_WARE,           self.SyncShopWare},
        { UiNotify.emNOTIFY_SHOP_BUY_RESULT,          self.OnResponseBuy},
        { UiNotify.emNOTIFY_SHOP_SELL_RESULT,         self.OnResponseSell},
        { UiNotify.emNOTIFY_RECHARGE_PANEL,            self.OnResponseRecharge},
        { UiNotify.emNoTIFY_RENOWN_SHOP_REFRESH, self.RefreshRenown, self },
        { UiNotify.emNOTIFY_CHANGE_MONEY, self.OnRefresMoney },
        { UiNotify.emNOTIFY_LOAD_RES_FINISH,    self.OnLoadResFinish, self},
    };

    return tbRegEvent;
end
----Current UI-------End

----Shop Common------Begin
--[[
数据定义

self.szPage 当前页名
self.nSelectTab 当前子页

购买
self.tbSelectItem = {
    nPrice = 123--单价
    nCount = 10--数量
    szMoneyType = "Honor"--货币类型
    szShopType = "Honor"
}
]]

--[[
出售
self.tbSelectItem = {
    nItemId = 111,
    nTemplateId = 123--单价
    nCount = 10--数量
    szMoneyType = "TongBao"--货币类型
}

self.tbSellThings 
]]    


CommonShop.tbOnClick.BtnOperation = function (self)
    self:DoBuy();
end

CommonShop.tbOnClick.BtnOperation2 = function (self)
    self:DoBuy();
end




function CommonShop:GetShopMoneyType()
    return  self.tbShopMoneyType[self.szPage];
end

CommonShop.DefaultTabs = {
    "tabLimitShop",
    "tabAllShop", 
}
CommonShop.ActDefaultTabs = {
    "tabLimitShop",
    "tabAllShop", 
    "tabActShop",
}
CommonShop.DressShopTabs = {
    "tabDressWaiyiShop",
    "tabDressHeadShop",
    "tabDressWeaponShop",
    "tabDressHorseShop",
    "tabDressOtherShop",
    "tabDressRareShop",
}
CommonShop.ActDressShopTabs = {
    "tabActShop",
    "tabDressWaiyiShop",
    "tabDressHeadShop",
    "tabDressWeaponShop",
    "tabDressHorseShop",
    "tabDressOtherShop",
    "tabDressRareShop",
}

CommonShop.tabDefaultTabs = {
    Treasure = CommonShop.DefaultTabs,
    Dress = CommonShop.DressShopTabs,
}

CommonShop.tbTabText = Lib:CopyTB(CommonShop.tabDefaultTabs)

CommonShop.tbTabBtn = 
{
    "BtnTab1";
    "BtnTab2";
    "BtnTab3";
    "BtnTab4";
}

CommonShop.TabsLabelSetting = {
    tabDefault = function (self, szBtnName)
        local ColorOuline = RepresentSetting.CreateColor(0, 84/255, 167/255, 1.0);
        local pPanel = self[szBtnName].pPanel
        pPanel:Label_SetOutlineColor("LabelLight", ColorOuline);
        pPanel:Label_SetOutlineColor("LabelDark", ColorOuline);
        pPanel:Label_SetColor("LabelDark", 115, 203, 213);
        pPanel:Toggle_SetChecked("Main",false) --因为现在设button的Sprite只是normal的显示才立即更改，所以先将状态设为normal
        pPanel:Button_SetSprite("Main", "Tab2_1", 0)
        pPanel:Button_SetSprite("Main", "Tab2_2", 3)
    end;
    tabActShop = function (self, szBtnName)
        local ColorOuline = RepresentSetting.CreateColor(167/ 255, 45/255, 0.0, 1.0);
        local pPanel = self[szBtnName].pPanel
        pPanel:Label_SetOutlineColor("LabelLight", ColorOuline);
        pPanel:Label_SetOutlineColor("LabelDark", ColorOuline);
        pPanel:Label_SetColor("LabelDark", 213, 166,115);
        pPanel:Toggle_SetChecked("Main",false)
        pPanel:Button_SetSprite("Main", "BtnNewYearShop1", 0)
        pPanel:Button_SetSprite("Main", "BtnNewYearShop2", 3)
    end;
}

CommonShop.tbTabBtnIndex = 
{
    BtnTab1 = 1;
    BtnTab2 = 2;
    BtnTab3 = 3;
    BtnTab4 = 4;
}

function CommonShop:UpdateTabPanel()
    local tbTabText = self.tbTabText[self.szPage];
    if not tbTabText then
        return
    end
    local tbFromPos = {
        -199, -64, 71, 206,
    }  
    self.pPanel:ChangePosition("BtnTab1", tbFromPos[#tbTabText - 1], -16)
    self.pPanel:ChangePosition("BtnTab2", tbFromPos[#tbTabText], -16)

    for i = 1, 4 do
        local szBtnName = self.tbTabBtn[i];
        local szTxt = tbTabText[i];
        if szTxt then
            szTxt = Shop.tabUiKeyName[szTxt];
        end
        self.pPanel:SetActive("BtnTab" .. i, szTxt ~= nil);
        self[szBtnName].pPanel:Label_SetText("LabelLight", szTxt or "");
        self[szBtnName].pPanel:Label_SetText("LabelDark", szTxt or "");
        self.pPanel:Toggle_SetChecked("BtnTab" .. i, self.nSelectTab == i);
    end

    local szBtnName = self.tbTabBtn[self.nSelectTab];
    self:SelectTabShow(szBtnName);
end

function CommonShop:SelectTabShow(szBtnName)
    for _, szName in ipairs(self.tbTabBtn) do
        self[szName].pPanel:SetActive("LabelLight", szBtnName == szName);
        self[szName].pPanel:SetActive("LabelDark", szBtnName ~= szName);
        -- self[szName].pPanel:SetActive("Pointer", szBtnName == szName);
    end
end


local ClickTab = function (self, szBtnName) --ugly
    local nIndex = self.tbTabBtnIndex[szBtnName];
    if self.nSelectTab ~= nIndex then
        self.nSelectTab = nIndex;
        self.tbSelectItem = nil;

        self:UpdateShopWares();            

        self:UpdateRightPanel();
        self:SelectTabShow(szBtnName);
    end
end

CommonShop.tbOnClick.BtnTab1 = ClickTab;
CommonShop.tbOnClick.BtnTab2 = ClickTab;
CommonShop.tbOnClick.BtnTab3 = ClickTab;
CommonShop.tbOnClick.BtnTab4 = ClickTab;

function CommonShop.tbOnClick:BtnMinus()
    self:ReduceCount();
end

function CommonShop.tbOnClick:BtnPlus()
    self:AddCount();
end

function CommonShop:AddCount()
    if not self.tbSelectItem then
        me.CenterMsg("请先选择要购买的道具")
        return;
    end

    local nCount = self.tbSelectItem.nCount;
    local nToCount = nCount + 1;
    
    self:SetCount(nToCount);
end

function CommonShop:ReduceCount()
    if not self.tbSelectItem then
        me.CenterMsg("请先选择要购买的道具")
        return;
    end
    local nCount = self.tbSelectItem.nCount;
    local nToCount = nCount - 1;
    nToCount = nToCount < 1  and 1 or nToCount;
    self:SetCount(nToCount);
end

function CommonShop:SetCount(nToCount, bAjustment)

    --On Buy
    local szMoneyType   = self.tbSelectItem.szMoneyType;
    local nPrice        = self.tbSelectItem.nPrice;
    local szIcon, szIconAtlas = Shop:GetMoneyIcon(szMoneyType);
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas)

    if bAjustment then
        local nMoney = me.GetMoney(szMoneyType);
        local nMax = math.floor(nMoney / nPrice);
        nToCount = nMax;

        if self.tbSelectItem.nLimitType then
            local nRemainCount = Shop:GetWareRemainCount(me, self.tbSelectItem);
            nToCount = nToCount > nRemainCount and nRemainCount or nToCount;
        end

        nToCount = nToCount > 0 and nToCount or 1;
    end
    if not Shop:HasEnoughMoney(me, szMoneyType, nPrice, nToCount) then
        me.CenterMsg("购买数量已达上限");
        return false;
    end

    if self.tbSelectItem.nLimitType then
        local nRemainCount = Shop:GetWareRemainCount(me, self.tbSelectItem);
        if nToCount > nRemainCount then
            me.CenterMsg(nRemainCount == 0 and "库存不足" or "购买数量已达上限");
            self:SetCount(nRemainCount)
            return false;
        end
    end

    self.tbSelectItem.nCount = nToCount;
    self.pPanel:Label_SetText("Label_Number", nToCount);
    self.pPanel:PlayUiAnimation("ShopCountScale", false, false, {});
    self.pPanel:Label_SetText("TxtCostMoney", self.tbSelectItem.nPrice * nToCount);
    self.pPanel:Label_SetColorByName("TxtCostMoney", "White");

    return true;
end

function CommonShop:UpdateNumberInput(nNum)
    if not self.tbSelectItem then
        self.pPanel:Label_SetText("Label_Number", 0);
        return;
    end

    if not self:SetCount(nNum) then
        self:SetCount(self.tbSelectItem.nCount, true);
        return self.tbSelectItem.nCount;
    end

    return nNum;
end

function CommonShop:UpdateRightPanel()
    if self.szPage == "Recharge" then
        return
    end
    local szTxtPay, szTxtOperation;
        szTxtPay = "花费";
        szTxtOperation = "购买";

    self.pPanel:Button_SetText("BtnOperation", szTxtOperation);
    self.pPanel:Label_SetText("TxtPay", szTxtPay);
    self.pPanel:Label_SetText("TxtCostMoney", 0);

    local nPrice, szMoneyType = 0, self.tbShopMoneyType[self.szPage];

    if self.tbSelectItem then
        --数量及价格
        local nCount = self.tbSelectItem.nCount;
        szMoneyType  = self.tbSelectItem.szMoneyType;
        nPrice = self.tbSelectItem.nPrice * nCount;

        if Shop:HasEnoughMoney(me, szMoneyType, self.tbSelectItem.nPrice, nCount) then
            self.pPanel:Label_SetColorByName("TxtCostMoney", "White");
        else
            self.pPanel:Label_SetColorByName("TxtCostMoney", "Red");
        end

        self.pPanel:Label_SetText("Label_Number", self.tbSelectItem.nCount or 1);

        --详细描述
        local tbBaseInfo = KItem.GetItemBaseProp(self.tbSelectItem.nTemplateId);
        local szTitle = Item:GetItemTemplateShowInfo(self.tbSelectItem.nTemplateId, me.nFaction, me.nSex)
         
        local szDetail = string.gsub(tbBaseInfo.szIntro, "\\n", "\n");

        local szShowTxt = szDetail;
        
        if tbBaseInfo.szClass == "Stone" then
            szShowTxt = "";
            local szName1, szValue1, szName2, szValue2 = StoneMgr:GetStoneMagicDesc(self.tbSelectItem.nTemplateId)
            if szValue1 then
                szShowTxt = string.format("效果：[FAFFA3]%s  %s[-]\n\n", szName1, szValue1) 
            end
            if szValue2 then
                szShowTxt = szShowTxt .. string.format("效果：[FAFFA3]%s  %s[-]\n\n", szName2, szValue2) 
            end

            local szInsetPosDes = StoneMgr:GetCanInsetPosDes(self.tbSelectItem.nTemplateId)
            if szInsetPosDes then
               szShowTxt  = string.format("%s镶嵌位置：[FAFFA3]%s[-]\n\n镶嵌等级：[FAFFA3]%d级[-]\n\n", 
                                szShowTxt, szInsetPosDes, tbBaseInfo.nRequireLevel)
            end
            szShowTxt = szShowTxt .. szDetail
        elseif tbBaseInfo.szClass == "XiuLianDan" then
            local tbItem = Item:GetClass("XiuLianDan");
            szShowTxt = tbItem:GetShopTip({});
        elseif tbBaseInfo.szClass == "ChuangGongDan" then
            local bUse = ChuangGong:IsUsedChuangGongDan(me)
            if bUse then
                szShowTxt = szShowTxt.."\n\n[ff0000]                     今日已使用[-]";
            end 
        elseif tbBaseInfo.szClass == "waiyi_exchange" then
             local szTip =  Item:GetClass("waiyi_exchange"):GetIntrol(self.tbSelectItem.nTemplateId)
             if not Lib:IsEmptyStr(szTip) then
                szShowTxt = szTip
             end
        end

        local bShowBtnPreview = false
        if tbBaseInfo.szClass == "waiyi_exchange" then
            bShowBtnPreview = true;
        elseif tbBaseInfo.szClass == "ExchangeItemByFaction" then

            local nExhangeItem = Item:GetClass("ExchangeItemByFaction"):GetExhangeItemId(self.tbSelectItem.nTemplateId, me.nFaction)
            local tbItemBase = KItem.GetItemBaseProp(nExhangeItem)
            if tbItemBase.szClass == "waiyi" then
                bShowBtnPreview = true;
            end
        end
        self.pPanel:SetActive("PanelBtns", bShowBtnPreview);

        if self.tbSelectItem.nLimitType then
            local nRemainCount = Shop:GetWareRemainCount(me, self.tbSelectItem);
            local szRemainDesc;
            if nRemainCount == 0 then
                szRemainDesc = "[ff6464]还可购买：0个[-]";
            elseif nRemainCount < 10000 then
                szRemainDesc = string.format("[64fa50]还可购买：%d个[-]", nRemainCount)
            end
            if szRemainDesc then
                szShowTxt = szShowTxt .. "\n\n" .. szRemainDesc;
            end
        end

        local tbWareInfo = Shop:GetGoodsWare(self.szPage, self.tbSelectItem.nGoodsId)
        if tbWareInfo and tbWareInfo.nMinLevel and tbWareInfo.nMinLevel > me.nLevel then
            szShowTxt = szShowTxt .. string.format("\n\n[ff6464]%d级后可购买[-]", tbWareInfo.nMinLevel) 
        end

        self.pPanel:Label_SetText("TxtDetailTitle", szTitle);
        self.pPanel:Label_SetText("TxtDesc", szShowTxt);

        --local tbTextSize1 = self.pPanel:Label_GetPrintSize("TxtDetailTitle");
        self.pPanel:SetActive("DetailPanel", true);
        local tbTextSize2 = self.pPanel:Label_GetPrintSize("TxtDesc");
        local tbSize = self.pPanel:Widget_GetSize("datagroup");
        self.pPanel:Widget_SetSize("datagroup", tbSize.x, 50 + tbTextSize2.y);
        self.pPanel:DragScrollViewGoTop("datagroup");
        self.pPanel:UpdateDragScrollView("datagroup");
    else
        self.pPanel:SetActive("DetailPanel", false);
        self.pPanel:Label_SetText("Label_Number", 0);
        self.pPanel:SetActive("PanelBtns", false);

    end

    local szIcon, szIconAtlas = Shop:GetMoneyIcon(szMoneyType);
    self.pPanel:Sprite_SetSprite("CostMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Sprite_SetSprite("HasMoneyIcon", szIcon, szIconAtlas);
    self.pPanel:Label_SetText("TxtCostMoney", nPrice);
    self.pPanel:Label_SetText("TxtHaveMoney", me.GetMoney(szMoneyType));
    

    self:CheckCountdown();
end

----Shop Common------End




----ShopSell---------End

----CommonShop-------Begin


function CommonShop:DoBuy()
    if not self.tbSelectItem then
        me.CenterMsg("你没有选中物品");
        return;
    end

    local szMoneyType = self.tbSelectItem.szMoneyType;
    local nbuyCount   = self.tbSelectItem.nCount;
    local nTemplateId = self.tbSelectItem.nTemplateId;
    local nGoodsId = self.tbSelectItem.nGoodsId;

    local bSuccess, szInfo = Shop:CanBuyGoodsWare(me, self.szPage, nGoodsId, nbuyCount);
    if not bSuccess then
        me.CenterMsg(szInfo);
        return;
    end

    Shop:TryBuyItem(false, self.szPage, nTemplateId, nGoodsId, nbuyCount, self.tbSelectItem.nPrice)
end

CommonShop.fnOnClickWare = function (self, buttonObj)
    buttonObj.pPanel:Toggle_SetChecked("Main", true);
    self.tbSelectItem = {
        nTemplateId     = buttonObj.tbData.nTemplateId,
        nGoodsId        = buttonObj.tbData.nGoodsId,
        nPrice          = buttonObj.tbData.nPrice,
        nCount          = 1,
        szMoneyType     = buttonObj.tbData.szMoneyType,
        nLimitType      = buttonObj.tbData.nLimitType,
        nLimitNum       = buttonObj.tbData.nLimitNum,
        };
    self:UpdateRightPanel();
end

CommonShop.fnSetWareItem = function (self, goodItem, tbData, nFaction, nSex)
    nFaction = nFaction or me.nFaction
    nSex = nSex or me.nSex;
    nSex = Player:Faction2Sex(nFaction, nSex)
    if tbData.nDiscount ~= 0 and tbData.szShopType == "Dress" and tbData.nOriginPrice ~= nil then
        goodItem.pPanel:SetActive("RedLine", true);
        goodItem.pPanel:Label_SetText("TxtPrice", tbData.nOriginPrice);
        goodItem.pPanel:SetActive("TxtDiscountPrice", true);
        goodItem.pPanel:Label_SetText("TxtDiscountPrice", tbData.nPrice);

    else
        goodItem.pPanel:Label_SetText("TxtPrice", tbData.nPrice);
        goodItem.pPanel:SetActive("RedLine", false);
        goodItem.pPanel:SetActive("TxtDiscountPrice", false);
    end

    local tbBaseInfo = KItem.GetItemBaseProp(tbData.nTemplateId);
    local szName = Item:GetItemTemplateShowInfo(tbData.nTemplateId, nFaction, nSex)
    goodItem.pPanel:Label_SetText("TxtItemName", szName);
    local szIcon, szIconAtlas = Shop:GetMoneyIcon(tbData.szMoneyType);
    goodItem.pPanel:Sprite_SetSprite("MoneyIcon", szIcon, szIconAtlas);

    CommonShop:SetGoodTip(tbData, goodItem);
    local bCheck = false;
    if self.tbSelectItem and self.tbSelectItem.nTemplateId == tbData.nTemplateId then
        bCheck = true;
    end
    goodItem.pPanel:Toggle_SetChecked("Main", bCheck);
    
    local tbControls = {};
    local bOutOfStock = false
    if tbData.nLimitType then
        local nRemainCount = Shop:GetWareRemainCount(me, tbData);
        tbControls.bShowCDLayer = nRemainCount == 0;
        bOutOfStock = nRemainCount == 0;
    else
        tbControls.bShowCDLayer = false;
    end
    if tbData.bForbidStall then
       tbControls.bShowForbit = true
    end
    goodItem.Item:SetItemByTemplate(tbData.nTemplateId, nil, nFaction, nSex, tbControls);
    if bOutOfStock then
        goodItem.pPanel:SetActive("TagDT", true)
        goodItem.pPanel:Sprite_SetSprite("TagDT", "OutOfStock")   
    else
        goodItem.pPanel:SetActive("TagDT", false)
    end
    
    goodItem.pPanel.OnTouchEvent = function (buttonObj)
        CommonShop.fnOnClickWare(self, buttonObj)
    end;
    goodItem.Item.fnClick = function (itemGrid)
        CommonShop.fnOnClickWare(self, goodItem)
        if self.OnClickItem then
            self:OnClickItem()
        end
    end 
    goodItem.tbData = tbData;
    if bCheck == true then
        CommonShop.fnOnClickWare(self, goodItem);
    end
end

function CommonShop:CheckSeeActShop()
    local nNow = GetTime()
    Client:SetFlag("SeeShopActStartTime", nNow)
    Shop:CheckRedPoint()
end

function CommonShop:OnOpenCommonShop()
    self:CheckSeeActShop()

    self:UpdateShopWares();
    self:UpdateRightPanel();
end

function CommonShop:OnOpenDressShop()
    self:CheckSeeActShop()

end

function CommonShop.GetWaresTimeSort( tbViewWares )
    if not Activity:__IsActInProcessByType("ShopAct") then
        return {}
    end
    local tbTimesTypes = { } --按开始和结束时间都一样才是一个key [szStartTime][szCloseTime] = nKey
    local tbViewData = {}; --[nKey] = {wares}
    local nDataKey = 0;
    -- tb  [szStartTime, szCloseTime, nTime1,  nTime2]
    for i,v in ipairs(tbViewWares) do
        local szOpenTime = v.szOpenTime
        
        local nStarTime = Lib:IsEmptyStr(szOpenTime) and v.nStartTime or Lib:ParseDateTime(szOpenTime)
        local nCloseTime = Lib:IsEmptyStr(v.szCloseTime) and v.nCloseTime or Lib:ParseDateTime(v.szCloseTime)
        tbTimesTypes[nStarTime] = tbTimesTypes[nStarTime] or {}
        if not tbTimesTypes[nStarTime][nCloseTime] then
            nDataKey = nDataKey + 1;
            tbTimesTypes[nStarTime][nCloseTime] = nDataKey
            tbViewData[nDataKey] = {}
        end
        local nCurKey = tbTimesTypes[nStarTime][nCloseTime]
        local tbViews = tbViewData[nCurKey] 
        table.insert(tbViews, v)
    end    

    local tbCurTimes = {}
    for k1,v1 in pairs(tbTimesTypes) do
        for k2,v2 in pairs(v1) do
            table.insert(tbCurTimes, { k1, k2 })
        end
    end
    table.sort( tbCurTimes, function (a, b)
        if a[1] == b[1] then
            return a[2] < b[2]
        else
            return a[1] > b[1]
        end
    end )

    local tbScrollViewData = {}
    for i,v in ipairs(tbCurTimes) do
        local nStarTime, nCloseTime = unpack(v)
        local tbData = {nIndex = i, nStarTime = nStarTime, nEndTime = nCloseTime };
        table.insert(tbScrollViewData, tbData)

        local nDataKey = tbTimesTypes[nStarTime][nCloseTime]
        local tbViews = tbViewData[nDataKey] 
        for i2 = 1, math.ceil(#tbViews / 2) do
            local tbData = {}
            local v2 = tbViews[ (i2 - 1) * 2 + 1]
            if v2 then
                table.insert(tbData, v2)
            end
            local v2 = tbViews[ (i2 - 1) * 2 + 2]
            if v2 then
                table.insert(tbData, v2)
            end
            table.insert(tbScrollViewData, tbData)
        end
    end
    return tbScrollViewData
end

-- 三种商店都是用的这个更新道具列表
function CommonShop:UpdateShopWares()
    if self.szPage ~= "Treasure" and self.szPage ~= "Dress" then
        return
    end
    local szMoneyType = self:GetShopMoneyType();
    assert(szMoneyType)
    local szTabKey = self.nSelectTab
    if CommonShop.tbTabText[self.szPage] then
        szTabKey = CommonShop.tbTabText[self.szPage][szTabKey]
    end
    local bShowWareEndTime = false
    if szTabKey == "tabActShop" or szTabKey == "tabActShopDress" then
        bShowWareEndTime = true
    end
    self.pPanel:SetActive("ScrollViewGoods2", bShowWareEndTime)
    self.pPanel:SetActive("ScrollViewGoods", not bShowWareEndTime)

    local tbView  = Shop:GetShopWares(self.szPage, szTabKey);
    table.sort(tbView, function (item1, item2)
        return item1.nSort < item2.nSort;
    end);
    
    if not bShowWareEndTime then
        self:UpdateShopWaresNormal(tbView)        
    else
        self:UpdateShopWaresAct(tbView)
    end
end

function CommonShop:UpdateShopWaresNormal( tbView )
    self.tbScrollView = {};
    for i,v in ipairs(tbView) do
        if i % 2 == 1 then
            table.insert(self.tbScrollView, {[1] = v});
        else
            self.tbScrollView[i/2][2] = v;
        end
    end
    local fnSetItem = function (itemObj, index)
        for i = 1,2 do
            local tbData = self.tbScrollView[index][i]; 
            if tbData then
                itemObj.pPanel:SetActive("item"..i, true);
                local goodItem = itemObj["item"..i];
                CommonShop.fnSetWareItem(self, goodItem, tbData);
            else
                itemObj.pPanel:SetActive("item"..i, false);
            end
        end
    end
    self.ScrollViewGoods:Update(#self.tbScrollView, fnSetItem);
end

function CommonShop:UpdateShopWaresAct( tbView )
    self.tbScrollView = self.GetWaresTimeSort(tbView)
    local tbHeight = {};
    local fnSetItem = function (itemObj, index)
        local tbData = self.tbScrollView[index]
        local pPanel = itemObj.pPanel
        if tbData.nIndex then
            local tbSize = pPanel:Widget_GetSize("Title")
            tbHeight[index] = tbSize.y
            pPanel:SetActive("item1", false)
            pPanel:SetActive("item2", false)
            pPanel:SetActive("Title", true)
            itemObj.nEndTime = tbData.nEndTime
            local szName = Shop:GetActShopPartName(tbData.nStarTime, tbData.nEndTime) 
            if not szName then
                szName = "活动" .. Lib:Transfer4LenDigit2CnNum(tbData.nIndex)
            end
            itemObj.Title.pPanel:Label_SetText("Name", szName)
        else
            local tbSize = pPanel:Widget_GetSize("item1")
            tbHeight[index] = tbSize.y
            pPanel:SetActive("Title", false)
            for i=1,2 do
                local tbOneData = tbData[i]
                if tbOneData then
                    pPanel:SetActive("item" .. i, true)
                    self.fnSetWareItem(self, itemObj["item" .. i], tbOneData)
                else
                    pPanel:SetActive("item" .. i, false)
                end
            end
        end
    end
    self.ScrollViewGoods2:Update(#self.tbScrollView, fnSetItem);
    self.ScrollViewGoods2:UpdateItemHeight(tbHeight);
    self:CloseTimer()
    self:UpdateTimer();
    self.nTimer = Timer:Register(Env.GAME_FPS , function ()
        self:UpdateTimer()
        return true
    end)
end

function CommonShop:UpdateTimer()
    if not self.pPanel:IsActive("ScrollViewGoods2") then
        return
    end
    local nNow = GetTime()
    local pScrollViewDress = self.ScrollViewGoods2
    local Grid = pScrollViewDress.Grid;
    for i = 0, 15 do
        local itemObj = Grid["Item" .. i]
        if itemObj and itemObj.nEndTime then
            if itemObj.pPanel:IsActive("Title") then
                local nLeftTime = itemObj.nEndTime - nNow
                nLeftTime = nLeftTime < 0 and 0 or nLeftTime;
                itemObj.Title.pPanel:Label_SetText("Time", string.format("剩余时间 [ffff00]%s[-]", Lib:TimeDesc2(nLeftTime) ) )
            end
        end
    end
end

function CommonShop:SetGoodTip(tbData, goodItem)
    if tbData.nDiscount and tbData.nDiscount ~= 0 then
        local szDiscountIcon = "Discount" .. tbData.nDiscount;
        goodItem.pPanel:Sprite_SetSprite("TipIcon", szDiscountIcon);
        goodItem.pPanel:SetActive("TipIcon", true);
    elseif tbData.New then
        goodItem.pPanel:Sprite_SetSprite("TipIcon", "New");
        goodItem.pPanel:SetActive("TipIcon", true);
    elseif tbData.bHotTip then
        goodItem.pPanel:Sprite_SetSprite("TipIcon", "Hot");
        goodItem.pPanel:SetActive("TipIcon", true);
    elseif not Lib:IsEmptyStr(tbData.szOpenTime) then
        goodItem.pPanel:Sprite_SetSprite("TipIcon", "TimeLimit");
        goodItem.pPanel:SetActive("TipIcon", true);
    else
        goodItem.pPanel:SetActive("TipIcon", false);
    end
end

function CommonShop:CheckCountdown()
    local bShowCountDown = false;
    local bShowActShopTime = false
    if self.szPage == "Treasure" and not self.nTimer then
        if self.nSelectTab then
            local szTabKey = CommonShop.tbTabText.Treasure[self.nSelectTab]
            if szTabKey == "tabLimitShop" then
                bShowCountDown = true;
            elseif szTabKey == "tabActShop" then
                local szBtnName = self.tbTabBtn[self.nSelectTab];
                if self[szBtnName].pPanel:IsActive("Main") then
                    bShowActShopTime = true
                end
            end
        end
    end
    self.pPanel:SetActive("TxtTimeLimit", bShowCountDown);
    self.pPanel:SetActive("NewYearTimes", false)
end

function CommonShop:OnClose()
    self.tbSelectItem = nil;
    self.DressShop:OnClose()
    self:CloseTimer()
end

----CommonShop-------End

function CommonShop:OnOpenRenown()
    self.PrestigeShop:OnOpenEnd()
end

----ReCharge---------Begin

function CommonShop:OnOpenRecharge()
    self.Recharge:OnOpenEnd()
end

----ReCharge---------End

