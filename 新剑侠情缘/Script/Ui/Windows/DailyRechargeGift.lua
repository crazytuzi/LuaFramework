local tbUi = Ui:CreateClass("DailyRechargeGift")
--一三六对应的随机道具展示部分
tbUi.tbShowRandItemSetting = {
    --时间轴(从低到高) ，随机奖励列表
    [1] = {
        { "OpenLevel39",   { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel59",   { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel69",   { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel79",   { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel89",   { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel99",   { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel109",  { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel119",  { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel129",  { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
        { "OpenLevel139",  { {"item", 994251, 1} , {"item", 994254, 1}, {"item", 994257, 1} } };
    };
    [2] = {
        { "OpenLevel39",   { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel59",   { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel69",   { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel79",   { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel89",   { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel99",   { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel109",  { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel119",  { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel129",  { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
        { "OpenLevel139",  { {"item", 994252, 1} , {"item", 994255, 1}, {"item", 994258, 1} } };
    };
    [3] = {
        { "OpenLevel39",   { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel59",   { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel69",   { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel79",   { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel89",   { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel99",   { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel109",  { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel119",  { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
        { "OpenLevel129",  { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };      
        { "OpenLevel139",  { {"item", 994253, 1} , {"item", 994256, 1}, {"item", 994259, 1} } };
    };
}

function tbUi:OnOpen()
    self.tbGiftId = self.tbGiftId or {}
    self:Update()

    Client:SetFlag("hasViewRechargeGift", Lib:GetLocalDay())
    Recharge:CheckRedPoint()
end

function tbUi:GetRandItemList(index)
    local tbInfo = self.tbShowRandItemSetting[index]
    if not tbInfo then
        return
    end

    local tbItemList;
    for i,v in ipairs(tbInfo) do
        if GetTimeFrameState(v[1]) == 1 then
            tbItemList = v[2]
        end
    end
    return tbItemList
end

function tbUi:GetGiftInfo(nIdx)
    local tbSetting = Recharge.tbSettingGroup.DayGift
    return tbSetting[nIdx]
end

function tbUi:GetItemFramAward(tbAward)
    for i,v in ipairs(tbAward) do
        local szType, nPram1 = unpack(v)
        if szType == "item" then
            return nPram1
        end
    end
end

function tbUi:Update()
    local bCanBuyAll, szMsg, bShow = Recharge:CanBuyOneDayCardSet(me);
    self.pPanel:SetActive("btnBuyAll", bShow)

    local bCanBuy7, szMsg, bShowBuy7 = Recharge:CanBuyOneDayCardPlus(me)
    self.pPanel:SetActive("btnBuyAll7Days", bShowBuy7)
    local bShowRed = false;
    if bShowBuy7 then
        local bCanTake, szMsg, nLeftCount = Recharge:CanTakeOneDayCardPlusAward(me)
        if bCanTake then
            bShowRed = true;
        end
        if nLeftCount  and nLeftCount > 0 then
            self.pPanel:Label_SetText("All7DaysTxt",  string.format("剩余可领(%d/7)", nLeftCount))
            self.pPanel:SetActive("Discount", false)
        else
            local tbBuyInfo = Recharge.tbSettingGroup.DayGiftPlus[1]
            local szShowBuyPrice = Recharge:GetShowBuyPriceDesc(tbBuyInfo.nMoney, tbBuyInfo.szMoneyType)
            self.pPanel:Label_SetText("All7DaysTxt", string.format("   %s购买(7天)", szShowBuyPrice))    
            self.pPanel:SetActive("Discount", true)
        end
    end
    if bShowRed then
        Ui:SetRedPointNotify("DailyRechargeGift7")
    else
        Ui:ClearRedPointNotify("DailyRechargeGift7")
    end

    local tbShow = self:GetShowGift()
    local nGiftNum = #tbShow
    local tbRandTimeClass = Item:GetClass("RandomItemByTimeFrame")
    for i = 1, 3 do
        self.pPanel:SetActive("Package" .. i, nGiftNum >= i)
        if nGiftNum >= i then
            local tbSetting = self:GetGiftInfo(i)
            local nItemId = self:GetItemFramAward(tbSetting.tbAward)
            local bRet, tbFixItemList = tbRandTimeClass:GetFixRandItemAward(nItemId)
            for j = 1, 4 do
                local tbItemGrid = self["itemframe" .. i .. j]
				if tbItemGrid then
                    if bRet == 1 and tbFixItemList[j] then
                        tbItemGrid.pPanel:SetActive("Main", true)
                        tbItemGrid:SetGenericItem(tbFixItemList[j])
                        tbItemGrid.fnClick = tbItemGrid.DefaultClick
                    else
                        tbItemGrid.pPanel:SetActive("Main", false)
                        tbItemGrid:Clear();
                    end
				end
            end

            local tbRandAwardList = self:GetRandItemList(i)
            for j = 1, 4 do
                local tbItemGrid = self["itemframe" .. i .. (4 + j)]
				if tbItemGrid then
                    if tbRandAwardList and tbRandAwardList[j] then
                        tbItemGrid.pPanel:SetActive("Main", true)
                        tbItemGrid:SetGenericItem(tbRandAwardList[j])
                        tbItemGrid.fnClick = tbItemGrid.DefaultClick
                    else
                        tbItemGrid.pPanel:SetActive("Main", false)
                        tbItemGrid:Clear();
                    end
				end
            end

            local bCanBuy = tbShow[i]
            self.pPanel:SetActive("BtnBuy" .. i, bCanBuy)
            self.pPanel:Button_SetText("BtnBuy" .. i, tbSetting.szNoromalDesc)
            self.pPanel:SetActive("AlreadyBuyTip" .. i, not bCanBuy)
        end
    end

    if not self.tbPosX then
        self.tbPosX = {};
        local tbPostion;
        for i=1,3 do
            tbPostion = self.pPanel:GetPosition("Package" .. i)
            table.insert(self.tbPosX, tbPostion.x)
        end
        self.nPosDefaultY = tbPostion.y
    end

    if nGiftNum == 1 then
        self.pPanel:ChangePosition("Package1", self.tbPosX[2], self.nPosDefaultY)    
    else
        self.pPanel:ChangePosition("Package1", self.tbPosX[1], self.nPosDefaultY)    
    end

    local bIsLotteryOpen = Lottery:IsOpen();
    for i = 1, 3 do
        local szKey = "Vips0" .. i;
        self.pPanel:SetActive(szKey, bIsLotteryOpen);

        if bIsLotteryOpen then
            self.pPanel:Label_SetText(szKey, string.format("另获盟主的馈赠%d张", Lottery:GetAwardTicketCount("Daily" .. i)));
        end
    end
end

function tbUi:GetShowGift()
    local nToday = Lib:GetLocalDay(GetTime() - 3600 * 4)
    local tbShow = {}
    local bBuyeadAll = false;
    if Recharge.tbSettingGroup.DayGiftSet then
         bBuyeadAll = me.GetUserValue(Recharge.SAVE_GROUP, Recharge.tbSettingGroup.DayGiftSet[1].nBuyDayKey) >= nToday ;
    end
    if not bBuyeadAll and Recharge.tbSettingGroup.DayGiftPlus then
        if not Recharge:IsNotTakeOrBuyedOneDayCardPlus(me) then
            bBuyeadAll = true;     
        end
    end

    for i, v in ipairs(Recharge.tbSettingGroup.DayGift) do
        local bCanBuy = nToday > me.GetUserValue(Recharge.SAVE_GROUP, v.nBuyDayKey) and not bBuyeadAll
        table.insert(tbShow, bCanBuy)        
    end

    return tbShow
end

function tbUi:TryBuyGift(nIdx)
    local tbSetting = self:GetGiftInfo(nIdx)
    if not tbSetting then
        return
    end

    Recharge:RequestBuyOneDayCard(tbSetting.ProductId)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_LOTTERY_DATA,      self.Update },
    };
    return tbRegEvent;
end

tbUi.tbOnClick = {}
for i = 1, 3 do
    tbUi.tbOnClick["BtnBuy" .. i] = function (self)
        self:TryBuyGift(i)
    end
end

tbUi.tbOnClick.btnBuyAll = function (self)
    Recharge:RequestBuyOneDayCardSet()
end

tbUi.tbOnClick.btnBuyAll7Days = function (self)
   Recharge:RequestBuyOrTakeOneDayCardPlus() 
end