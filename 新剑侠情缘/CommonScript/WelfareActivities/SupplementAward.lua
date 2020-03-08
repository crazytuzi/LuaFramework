SupplementAward.GROUP = 56
SupplementAward.DAY_LOGIN_TIME = 1
SupplementAward.SHOW_FLAG = 2
SupplementAward.REF_TIME = 4*3600
SupplementAward.DAY_BIT = 100

SupplementAward.ITEM_TYPE_TID = 3525 --完美补领对应的道具模板ID

--打折信息
SupplementAward.tbDiscount = {
--活动type，减少的价格（如打5折，填0.5，打8折，填0.2）
    ReduceFatigueAct = 0.5,
}

function SupplementAward:LoadSetting()
    local tbSetting = Lib:LoadTabFile("Setting/WelfareActivity/SupplementAward.tab", {nLevel = 1, nTimes = 1, nPrice = 1, nPrice_Coin = 1, nTimeSaveKey = 1, nSupplementKey = 1})
    self.tbSupplement = {}
    local tbSaveKey = {}
    for _, tbInfo in ipairs(tbSetting) do
        assert(not self.tbSupplement[tbInfo.szKey], "[SupplementAward Error], Key Repeat " .. tbInfo.szKey)
        assert(tbInfo.nSupplementKey > self.SHOW_FLAG, "[SupplementAward Error], SaveKey Must Big Then 2 " .. tbInfo.szKey)
        assert(not tbSaveKey[tbInfo.nTimeSaveKey] and not tbSaveKey[tbInfo.nSupplementKey], "[SupplementAward Error], SaveKey Repeat " .. tbInfo.szKey)
        tbSaveKey[tbInfo.nTimeSaveKey] = tbInfo.nTimeSaveKey > 0 and tbInfo.nTimeSaveKey or tbSaveKey[tbInfo.nTimeSaveKey]
        tbSaveKey[tbInfo.nSupplementKey] = tbInfo.nSupplementKey > 0 and tbInfo.nSupplementKey or tbSaveKey[tbInfo.nSupplementKey]
        self.tbSupplement[tbInfo.szKey] = tbInfo
    end
end
SupplementAward:LoadSetting()

function SupplementAward:AnalyzeLastTimes(nNum)
    local nYesterday = math.floor(nNum%self.DAY_BIT)
    local nTheDayBeforeYesterday = math.floor(nNum/self.DAY_BIT)
    return nYesterday, nTheDayBeforeYesterday
end

function SupplementAward:GetCanSupplementNum(pPlayer, szKey)
    local tbInfo = self.tbSupplement[szKey]
    if not tbInfo then
        return 0
    end

    local nYesterday, nTheDayBeforeYesterday = self:AnalyzeLastTimes(pPlayer.GetUserValue(self.GROUP, tbInfo.nSupplementKey))
    return nYesterday + nTheDayBeforeYesterday, nYesterday, nTheDayBeforeYesterday
end

function SupplementAward:GetMaxSupplementCount()
    local nCount = 0
    for szKey, tbInfo in pairs(self.tbSupplement) do
        nCount = nCount + tbInfo.nTimes
    end
    return nCount
end

function SupplementAward:GetDiscount()
    local nAllDisCount = 1
    for szActType, nDiscount in pairs(self.tbDiscount) do
        if Activity:__IsActInProcessByType(szActType) then
            nAllDisCount = nAllDisCount - nDiscount
        end
    end
    return nAllDisCount > 0 and nAllDisCount or 1
end

function SupplementAward:GetInfo(szKey)
    local tbInfo        = self.tbSupplement[szKey]
    local tbDisInfo     = Lib:CopyTB(tbInfo)
    local nCurDiscount  = self:GetDiscount()
    tbDisInfo.nPrice        = math.floor(tbDisInfo.nPrice * nCurDiscount)
    tbDisInfo.nPrice_Coin   = math.floor(tbDisInfo.nPrice_Coin * nCurDiscount)
    tbDisInfo.nPrice_NotDis = tbInfo.nPrice
    tbDisInfo.nPrice_Coin_NotDis = tbInfo.nPrice_Coin
    return tbDisInfo
end
-----------------------Client-----------------------
function SupplementAward:GetSupplementList()
    local tbSupplementList = {}
    local nShowFlag = me.GetUserValue(self.GROUP, self.SHOW_FLAG)
    for szKey, tbInfo in pairs(self.tbSupplement) do
        local nFlag = KLib.GetBit(nShowFlag, tbInfo.nSupplementKey - self.SHOW_FLAG)
        if nFlag == 1 then
            local tbDisInfo = self:GetInfo(szKey)
            table.insert(tbSupplementList, tbDisInfo)
        end
    end
    return tbSupplementList
end

function SupplementAward:IsShowUi()
    local tbSupplementList = self:GetSupplementList() or {}
    return #tbSupplementList > 0
end

function SupplementAward:CheckRedPoint()
    local tbSupplementList = self:GetSupplementList()
    for _, tbInfo in ipairs(tbSupplementList or {}) do
        local nTimes = me.GetUserValue(self.GROUP, tbInfo.nSupplementKey)
        if nTimes > 0 then
            Ui:SetRedPointNotify("Activity_SupplementPanel")
            return
        end
    end
    
    Ui:ClearRedPointNotify("Activity_SupplementPanel")
end

function SupplementAward:OnRespon()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SUPPLEMENT_RSP)
end