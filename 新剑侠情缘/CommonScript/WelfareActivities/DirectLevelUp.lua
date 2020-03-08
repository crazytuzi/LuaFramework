--2019.5.12
Require("CommonScript/Item/Class/AddPlayerLevel.lua")

DirectLevelUp.GROUP = 66
DirectLevelUp.DATA_DAY = 56
DirectLevelUp.SAVE_KEY = 57
DirectLevelUp.SEND_KEY = 58
DirectLevelUp.SEND_TIME = 59

DirectLevelUp.nSendInterval = 30*24*3600 --两次赠送间的间隔
DirectLevelUp.nFreeVipLevel = 6
DirectLevelUp.nImityLevel = 15
DirectLevelUp.tbItem = {
    --{道具ID，保存的位置（保证每条不一样，从1开始，连续，运营后不可修改），开始时间轴，结束时间轴（在这段时间内可购买，使用时会按照这段时间算能升到多少级）}
    -- 开服114天时,可直升75级,开服174天时,可直升85级,而开服144天时,基础等级增加=(144-114)*10/(174-114)=5，即开服144天时,直升基础等级为75+5=80级
    [3559] = {nSaveBit = 1, szBeginTF = "OpenLevel69", szEndTF = "OpenLevel79", nMaxLv = 10},
    [3560] = {nSaveBit = 2, szBeginTF = "OpenLevel79", szEndTF = "OpenLevel89", nMaxLv = 10},
    [3561] = {nSaveBit = 3, szBeginTF = "OpenLevel89", szEndTF = "OpenLevel99", nMaxLv = 10},
    [3562] = {nSaveBit = 4, szBeginTF = "OpenLevel99", szEndTF = "OpenLevel109", nMaxLv = 10},
    [3563] = {nSaveBit = 5, szBeginTF = "OpenLevel109", szEndTF = "OpenLevel119", nMaxLv = 10},
}
DirectLevelUp.tbBeAskList = DirectLevelUp.tbBeAskList or {}
DirectLevelUp.tbAppList = DirectLevelUp.tbAppList or {}

local tbItem = Item:GetClass("AddPlayerLevel")
DirectLevelUp.nExtPrice = tbItem.nExtPrice

function DirectLevelUp:GetCanBuyItem()
    local nDefault = next(self.tbItem)
    for nItemTID, tbInfo in pairs(self.tbItem) do
        if GetTimeFrameState(tbInfo.szBeginTF) == 1 and GetTimeFrameState(tbInfo.szEndTF) ~= 1 then
            return nItemTID
        end
        --道具ID遵从从小到大的规律
        nDefault = math.max(nDefault, nItemTID)
    end
    if GetTimeFrameState(self.tbItem[nDefault].szBeginTF) == 1 then
        return nDefault
    end
end

function DirectLevelUp:GetItemLevelUpLevel(nVipLv, nItemTID)
    local nFinalLevel = Item:GetClass("AddPlayerLevel"):GetFinalLevel(nVipLv, nItemTID)
    return nFinalLevel
end

function DirectLevelUp:OnLogin(pPlayer)
    local nPlayerId = pPlayer.dwID
    pPlayer.CallClientScript("DirectLevelUp:OnSyncData", self.tbBeAskList[nPlayerId], self.tbAppList[nPlayerId], self.nActStartTime, self.nActEndTime)
end

function DirectLevelUp:OnNewServerVersionChange(nActStartTime, nActEndTime)
    self.nActStartTime = nActStartTime
    self.nActEndTime = nActEndTime
end

function DirectLevelUp:CheckPlayerData(pPlayer)
    if not MODULE_GAMESERVER then
        return
    end

    if not RegressionPrivilege:IsInPrivilegeTime(pPlayer) then
        return
    end

    local nBeginTime = pPlayer.GetUserValue(RegressionPrivilege.GROUP, RegressionPrivilege.BEGIN_TIME)
    local nDataVersion = pPlayer.GetUserValue(self.GROUP, self.DATA_DAY)
    if nBeginTime ~= nDataVersion then
        pPlayer.SetUserValue(self.GROUP, self.DATA_DAY, nBeginTime)
        pPlayer.SetUserValue(self.GROUP, self.SAVE_KEY, 0)
        -- Gift.GiftManager:ClearMailItemTimes(pPlayer, "LevelUpItem")
        Log("DirectLevelUp CheckPlayerData Update BuyTime", pPlayer.dwID, nBeginTime, nDataVersion)
    end
end

function DirectLevelUp:CheckHadBuyOne(pPlayer)
    self:CheckPlayerData(pPlayer)
    return pPlayer.GetUserValue(self.GROUP, self.SAVE_KEY) > 0
end

function DirectLevelUp:CheckCanBuy(pPlayer, nBuyItemTID)
    if not RegressionPrivilege:IsInPrivilegeTime(pPlayer) then
        return false, "不在回归特权期间，不可购买"
    end

    local nCanBuyItem = self:GetCanBuyItem()
    if not nCanBuyItem or nBuyItemTID ~= nCanBuyItem then
        return false, "该道具不能购买"
    end

    local nFinalLevel = self:GetItemLevelUpLevel(pPlayer.GetVipLevel(), nBuyItemTID)
    if pPlayer.nLevel >= nFinalLevel then
        return false, "等级太高，不可购买"
    end

    if self:CheckHadBuyOne(pPlayer) then
        return false, "该道具只能购买或者领取一次"
    end
    return true
end

function DirectLevelUp:TryBuyItem(pPlayer, nBuyItemTID)
    local bRet, szMsg = self:CheckCanBuy(pPlayer, nBuyItemTID)
    if not bRet then
        pPlayer.CenterMsg(szMsg)
        return
    end

    local fnCostCallback = function (nPlayerId, bSuccess, szBillNo, nBuyItemTID)
        return self:BuySuccess(nPlayerId, bSuccess, nBuyItemTID)
    end

    if pPlayer.GetVipLevel() >= self.nFreeVipLevel then
        self:BuySuccess(pPlayer.dwID, true, nBuyItemTID)
        return
    end

    local nPrice = KItem.GetItemExtParam(nBuyItemTID, self.nExtPrice)
    -- CostGold谨慎调用, 调用前请搜索 _LuaPlayer.CostGold 查看使用说明, 它处调用时请保留本注释
    local bRet = pPlayer.CostGold(nPrice, Env.LogWay_DirectLevelUp, nil, fnCostCallback, nBuyItemTID)
    if not bRet then
        pPlayer.CenterMsg("支付失败，请重试")
    end
end

function DirectLevelUp:BuySuccess(nPlayerId, bSuccess, nBuyItemTID)
    local pPlayer = KPlayer.GetPlayerObjById(nPlayerId)
    if not pPlayer then
        return false, "玩家已下线"
    end

    if not bSuccess then
        return false, "购买失败"
    end

    local bRet, szMsg = self:CheckCanBuy(pPlayer, nBuyItemTID)
    if not bRet then
        pPlayer.CenterMsg(szMsg, true)
        return false, szMsg
    end

    self:AddBuyedFlag(pPlayer, nBuyItemTID)

    local nEndTime = RegressionPrivilege:GetPrivilegeTime(pPlayer)
    pPlayer.SendAward({{"Item", nBuyItemTID, 1, nEndTime}}, false, true, Env.LogWay_DirectLevelUp)
    local bFree = pPlayer.GetVipLevel() >= self.nFreeVipLevel
    pPlayer.CenterMsg(bFree and "领取成功" or "购买成功")
    Log("DirectLevelUp BuySuccess", pPlayer.dwID, bFree)
    return true
end

function DirectLevelUp:AddBuyedFlag(pPlayer, nBuyItemTID)
    self:CheckPlayerData(pPlayer)
    local nBuyFlag = pPlayer.GetUserValue(self.GROUP, self.SAVE_KEY)
    local tbInfo = self.tbItem[nBuyItemTID]
    if tbInfo then
        nBuyFlag = KLib.SetBit(nBuyFlag, tbInfo.nSaveBit, 1)
    else
        nBuyFlag = 1
        Log("DirectLevelUp AddBuyedFlag Err", pPlayer.dwID, nBuyItemTID)
    end
    pPlayer.SetUserValue(self.GROUP, self.SAVE_KEY, nBuyFlag)

    if self.tbAppList[pPlayer.dwID] then
        for nHelper, _ in pairs(self.tbAppList[pPlayer.dwID]) do
            if self.tbBeAskList[nHelper] then
                self.tbBeAskList[nHelper][pPlayer.dwID] = nil
                if not next(self.tbBeAskList[nHelper]) then
                    self.tbBeAskList[nHelper] = nil
                end
            end
        end
        self.tbAppList[pPlayer.dwID] = nil
    end
    Log("DirectLevelUp AddBuyedFlag", pPlayer.dwID, nBuyItemTID, nBuyFlag)
end

function DirectLevelUp:Ask4Help(pPlayer, nHelper)
    local pHelper = KPlayer.GetPlayerObjById(nHelper)
    if not pHelper then
        pPlayer.CenterMsg("对方不在线，无法求助")
        return
    end

    local nItemTID = self:GetCanBuyItem()
    local bRet, szMsg = self:CheckCanBuy(pPlayer, nItemTID)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    bRet, szMsg = self:CheckCanSendToFriend(pPlayer, pHelper)
    self.tbAppList[pPlayer.dwID] = self.tbAppList[pPlayer.dwID] or {}
    self.tbAppList[pPlayer.dwID][nHelper] = true
    pPlayer.CallClientScript("DirectLevelUp:OnHelpRsp", nHelper)
    if not bRet then
        pPlayer.CenterMsg(szMsg or "")
        return
    end

    self.tbBeAskList[nHelper] = self.tbBeAskList[nHelper] or {}
    self.tbBeAskList[nHelper][pPlayer.dwID] = pPlayer.szName
    pHelper.CallClientScript("DirectLevelUp:OnReceiveAsk", self.tbBeAskList[nHelper], pPlayer.szName)
    pPlayer.CenterMsg("求助已发送，请等待对方回应")
end

function DirectLevelUp:GetLastHelpTimes(pHelper)
    local nLastSendTime = pHelper.GetUserValue(self.GROUP, self.SEND_TIME)
    if self.nActStartTime and self.nActEndTime and GetTime() > self.nActStartTime and GetTime() < self.nActEndTime then
        if nLastSendTime >= self.nActStartTime then
            return 0, "活动期间已赠送一次"
        end
    else
        if (GetTime() - nLastSendTime) < self.nSendInterval then
            return 0, "该侠士已赠送过他人，请另寻一位侠士求助"
        end
    end
    return 1
end

function DirectLevelUp:CheckCanHelp(pHelper)
    local nVipLv = pHelper.nVipLevel or pHelper.GetVipLevel()
    if nVipLv < self.nFreeVipLevel then
        return false, "剑侠V等级不足，无法赠送"
    end
    local nItemTID = self:GetCanBuyItem()
    if not nItemTID then
        return false, "当前没有可赠送道具"
    end
    if pHelper.GetUserValue then
        local nLast, szMsg = self:GetLastHelpTimes(pHelper)
        if nLast <= 0 then
            return false, szMsg
        end
    end
    local nFinalLevel = self:GetItemLevelUpLevel(nVipLv, nItemTID)
    if pHelper.nLevel < nFinalLevel then
        return false, "等级太低，不能赠送"
    end
    return true
end

function DirectLevelUp:CheckCanSendToFriend(pPlayer, pHelper)
    local nImityLv = FriendShip:GetFriendImityLevel(pHelper.dwID, pPlayer.dwID)
    if not nImityLv then
        return false, "非好友"
    end

    if nImityLv < self.nImityLevel then
        return false, "亲密度等级不足"
    end

    local nItemTID = self:GetCanBuyItem()
    if not nItemTID then
        return false, "没有适合当前时间的道具"
    end
    local tbBaseInfo = KItem.GetItemBaseProp(nItemTID)
    if pPlayer.nLevel < tbBaseInfo.nRequireLevel then
        return false, string.format("好友等级不足[FFFE0D] %d [-]，未达到使用该道具的最低等级，不可赠送！", tbBaseInfo.nRequireLevel)
    end

    if not RegressionPrivilege:IsInPrivilegeTime(pPlayer) then
        return false, "好友不在特权时间内，赠送失败"
    end
    if self:CheckHadBuyOne(pPlayer) then
        return false, "好友已购买或已被赠送"
    end

    local bRet, szMsg = self:CheckCanHelp(pHelper)
    return bRet, szMsg
end

function DirectLevelUp:TrySendGift(pHelper, nBeSender)
    local pReceiver = KPlayer.GetPlayerObjById(nBeSender)
    if not pReceiver then
        pHelper.CenterMsg("对方不在线，无法赠送")
        return
    end

    local bRet, szMsg = self:CheckCanSendToFriend(pReceiver, pHelper)
    if not bRet then
        pHelper.CenterMsg(szMsg or "")
        return
    end

    local nEndTime = RegressionPrivilege:GetPrivilegeTime(pReceiver)
    pHelper.SetUserValue(self.GROUP, self.SEND_TIME, GetTime())
    local nItemTID = self:GetCanBuyItem()
    self:AddBuyedFlag(pReceiver, nItemTID, pHelper.dwID)
    pReceiver.SendAward({{"Item", nItemTID, 1, nEndTime}}, true, true, Env.LogWay_DirectLevelUp)
    pHelper.CenterMsg("赠送成功")
    pHelper.CallClientScript("Ui:CloseWindow", "SendGiftPanel")
    Log("DirectLevelUp TrySendGift Success", pHelper.dwID, nBeSender, nItemTID)
end

function DirectLevelUp:GetItemDayExtLv(nItemTID, bCalNextApp)
    local nDayExtLv = 0
    local tbInfo = self.tbItem[nItemTID]
    if tbInfo then
        local nBeginTime = CalcTimeFrameOpenTime(tbInfo.szBeginTF)
        local nEndTime = CalcTimeFrameOpenTime(tbInfo.szEndTF)
        local nMax = Lib:GetLocalDay(nEndTime)
        local nMin = Lib:GetLocalDay(nBeginTime)
        local nInterval = (Lib:GetLocalDay() - nMin)/(nMax - nMin)
        nInterval = math.min(1, math.max(0, nInterval))
        nDayExtLv = math.floor(tbInfo.nMaxLv*nInterval)
        if bCalNextApp and GetTime() >= nBeginTime and GetTime() < nEndTime then
            local nBeginIdx = Lib:GetLocalDay() - nMin
            for i = nBeginIdx, nMax - nMin do
                if math.floor(tbInfo.nMaxLv * (i/(nMax-nMin))) ~= nDayExtLv then
                    return nDayExtLv, i - nBeginIdx
                end
            end
        end
    end
    return nDayExtLv
end

DirectLevelUp.tbSafeCall = {
    TryBuyItem  = true,
    TrySendGift = true,
    Ask4Help    = true,
}

function DirectLevelUp:OnClientCall(pPlayer, szFunc, ...)
    if not self.tbSafeCall[szFunc] then
        return
    end

    self[szFunc](self, pPlayer, ...)
end


-------------------------------client-------------------------------
if MODULE_GAMESERVER then
    return
end

function DirectLevelUp:OnReceiveAsk(tbBeAskList, szCurApplyer)
    self.tbBeAskList = tbBeAskList
    local tbMsgData =
    {
        szType = "Ask4DirectLevelUpItem",
        nTimeOut = GetTime() + 3600,
        szApplyer = szCurApplyer,
    }
    Ui:SynNotifyMsg(tbMsgData)
    Ui:SetRedPointNotify("Activity_BuyLevelUp")
end

function DirectLevelUp:OnSyncData(tbBeAskList, tbAppList, nActStartTime, nActEndTime)
    self.tbBeAskList = tbBeAskList or {}
    self.tbAppList = tbAppList or {}
    self.nActStartTime = nActStartTime
    self.nActEndTime = nActEndTime
end

function DirectLevelUp:GetAsk4HelpList()
    local tbFriend = FriendShip:GetAllFriendData(true)
    local tbAskList = {}
    for _, tbInfo in ipairs(tbFriend or {}) do
        if self.tbBeAskList[tbInfo.dwID] and tbInfo.nState == 2 then
            table.insert(tbAskList, tbInfo)
        end
    end
    return tbAskList
end

function DirectLevelUp:GetCanHelpMeList()
    local tbFriendData = FriendShip:GetAllFriendData()
    local tbCanHelpList = {}
    local nItemTID = self:GetCanBuyItem()
    if not nItemTID then
        return tbCanHelpList
    end
    for _, tbInfo in ipairs(tbFriendData or {}) do
        local bRet, szMsg = self:CheckCanHelp(tbInfo)
        local nImityLv = FriendShip:GetFriendImityLevel(tbInfo.dwID, me.dwID)
        nImityLv = nImityLv or 0
        if bRet and tbInfo.nState == 2 and nImityLv >= self.nImityLevel then
            table.insert(tbCanHelpList, tbInfo)
        end
    end
    return tbCanHelpList
end

function DirectLevelUp:GetApplyFlag(nPlayerId)
    self.tbAppList = self.tbAppList or {}
    return self.tbAppList[nPlayerId]
end

function DirectLevelUp:OnHelpRsp(nHelper)
    self.tbAppList = self.tbAppList or {}
    self.tbAppList[nHelper] = true
    UiNotify.OnNotify(UiNotify.emNOTIFY_LEVELUP_ASK4HELP_RSP)
end

function DirectLevelUp:CheckShowPanel()
    if RegressionPrivilege:IsCloseMarketStall(me) then
        return
    end

    local nCanBuyID = self:GetCanBuyItem()
    local bCanBuy = self:CheckCanBuy(me, nCanBuyID)
    if bCanBuy then
        return true
    end

    local bCanHelp = self:CheckCanHelp(me)
    local tbList = self:GetAsk4HelpList() or {}
    return bCanHelp and next(tbList)
end