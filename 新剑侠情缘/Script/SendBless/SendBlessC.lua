
SendBless.tbSendData = SendBless.tbSendData or  {}
SendBless.tbGetData = SendBless.tbGetData or  {}


function SendBless:OnSynSendData(tbData)
    self.tbSendData = tbData.tbSend or {}
    self.tbGetData = tbData.tbGet or {}
    self.nCurGetBlessAwardTimes = tbData.nCurGetBlessAwardTimes or 0
    self.dwSynRoleId = me.dwID
    UiNotify.OnNotify(UiNotify.emNOTIFY_SEND_BLESS_CHANGE)
end

function SendBless:OnSendScucss(dwRoleId, nVal)
    self.tbSendData[dwRoleId] = nVal;
    local tbRoleInfo = FriendShip:GetFriendDataInfo(dwRoleId)
    local tbActSetting = self:GetActSetting()
    me.CenterMsg(string.format(tbActSetting.szSendBlessMsg, tbRoleInfo.szName))
    UiNotify.OnNotify(UiNotify.emNOTIFY_SEND_BLESS_CHANGE) 
end

function SendBless:OnGetScucss(dwRoleId, nVal, bUseGold, szWord, nCurGetBlessAwardTimes)
    self.tbGetData[dwRoleId] = nVal
    self.nCurGetBlessAwardTimes = nCurGetBlessAwardTimes or 0
    local tbActSetting = self:GetActSetting()

    local tbRoleInfo = FriendShip:GetFriendDataInfo(dwRoleId)
    local szMsg = bUseGold and string.format(tbActSetting.szGetBlessMsgGold, tbRoleInfo.szName) or string.format(tbActSetting.szGetBlessMsgNormal, tbRoleInfo.szName)
    me.CenterMsg(szMsg, true)

    if not Lib:IsEmptyStr(szWord) then
        SendBless:CheckResetClientData()
        local tbWordsGet = SendBless:GetWordsGet()
        tbWordsGet[dwRoleId] = szWord
        Client:SaveUserInfo()
    end
    UiNotify.OnNotify(UiNotify.emNOTIFY_SEND_BLESS_CHANGE, dwRoleId, bUseGold) 
end

function SendBless:CheckResetClientData()
    local _, tbActData = Activity:GetActUiSetting("SendBlessActWord")
    if tbActData then
        local tbSaveInfo = Client:GetUserInfo("SendBlessActWord")
        if tbSaveInfo.nActStartTime ~= tbActData.nStartTime then
            tbSaveInfo.nActStartTime = tbActData.nStartTime
            tbSaveInfo.tbWordsGet = {};
            tbSaveInfo.tbWordsSend = {};
        end
    end
end

function SendBless:CheckData()
    if self.dwSynRoleId ~= me.dwID then
        RemoteServer.RequestSendBlessData();
    end
    self:CheckResetClientData()
end

function SendBless:GetWordsGet()
    local tbSaveInfo = Client:GetUserInfo("SendBlessActWord")
    if not tbSaveInfo.tbWordsGet then
        tbSaveInfo.tbWordsGet = {};
    end
    return tbSaveInfo.tbWordsGet
end

function SendBless:GetWordsSend()
    local tbSaveInfo = Client:GetUserInfo("SendBlessActWord")
    if not tbSaveInfo.tbWordsSend then
        tbSaveInfo.tbWordsSend = {};
    end
    return tbSaveInfo.tbWordsSend
end

function SendBless:DoSendBless(dwRoleId, bUseGold, szWord)
    local tbRoleInfo = FriendShip:GetFriendDataInfo(dwRoleId)
    if tbRoleInfo.nState ~=  2 then
        me.CenterMsg("对方不在线，不能送出祝福！")
        return
    end
    local bRet = self:CheckSendCondition(me, dwRoleId, self.tbSendData, bUseGold)
    if not bRet then
        return
    end

    if bUseGold and me.GetMoney("Gold") < self.COST_GOLD then
        me.CenterMsg("元宝不足")
        return
    end

    if not Lib:IsEmptyStr(szWord) then
        local tbWordsSend = self:GetWordsSend()
        tbWordsSend[dwRoleId] = szWord;
        Client:SaveUserInfo()
    end

    RemoteServer.RequestSendBless(dwRoleId, bUseGold, szWord)
    UiNotify.OnNotify(UiNotify.emNOTIFY_SEND_BLESS_CHANGE) 
    Ui:CloseWindow("NewYearTxtPanel")
end


function SendBless:OnGetAwwrdSucess()
    UiNotify.OnNotify(UiNotify.emNOTIFY_SEND_BLESS_CHANGE) 
end

function SendBless:GetNextLevelAward()
    local nHasTakedLevel = me.GetUserValue(self.SAVE_GROUP, self.KEY_TakeAwardLevel)
    local tbAwardInfo = self.tbTakeAwardSet[nHasTakedLevel + 1]
    if tbAwardInfo then
        return  nHasTakedLevel + 1, tbAwardInfo.tbAward
    end
end

function SendBless:TryGetCurType()
    if not self.nType then
        for nType,v in pairs(self.tbActSetting) do
            if Activity:__IsActInProcessByType(v.szActName) then 
                self.nType = nType
                return nType
            end
                    --也有可能已经过了活动时间了道具还在
            if me.GetItemCountInBags(v.nCardItemId) > 0 then
                self.nType = nType
                return nType
            end
        end
    end
end

