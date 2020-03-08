Require("Script/Ui/Logic/RedPointNotify.lua")

NewInformation.szHadClear = "NewInformation_ClearSession"
NewInformation.tbShowedRedPoint = NewInformation.tbShowedRedPoint or {}

NewInformation.tbGetTitle = 
{
    ["WebActivity"] = function ()
        local tbActData = NewInformation:GetActData("WebActivity")
        local nLinkId = tbActData and tbActData[1]
        nLinkId = tonumber(nLinkId) or -1
        local tbUiData = Player.tbH5NewInfoUi[nLinkId]
        return tbUiData and tbUiData.szTitle
    end;
}

function NewInformation:Init()
    self.tbInfoData = self.tbInfoData or {}
    self.tbActRegUi = self.tbActRegUi or {}
    self.tbLocalSetting = {}

    local tbTabFile = Lib:LoadTabFile("Setting/NewInformation/TimingInformation.tab", { nReqLevel = 1, nShowPriority = 0, nBtnCloseWnd = 0 })
    assert(self.tbLocalSetting, "[NewInformation Init] Err, Not Found TabFile")

    local tbRedpoint = {}
    for _, tbInfo in ipairs(tbTabFile) do
        tbInfo.szOrgKey = tbInfo.szKey
        tbInfo.szKey = "Local_" .. tbInfo.szKey
        tbInfo.szUiName = tbInfo.szUiName == "" and "Normal" or tbInfo.szUiName
        table.insert(tbRedpoint, "NI_" .. tbInfo.szKey)
        self.tbLocalSetting[tbInfo.szKey] = tbInfo
    end

    for szKey, tbInfo in pairs(self.tbActivity) do
        table.insert(tbRedpoint, "NI_" .. szKey)
        tbInfo.szUiName = tbInfo.szUiName or szKey
    end

    Ui:InitRedPointNode("NewMessageRedPoint", tbRedpoint, "BtnTopFold")
end
NewInformation:Init()

function NewInformation:AddLocalSetting(tbLocalParam)
    local szOrgKey = tbLocalParam.szKey
    local szKey = "Local_" .. szOrgKey

    if self.tbLocalSetting[szKey] then
        return false
    end

    local tbInfo =
    {
        szOrgKey = szOrgKey,
        szKey = szKey,
        szUiName = tbLocalParam.szUiName == "" and "Normal" or tbLocalParam.szUiName,
        nReqLevel = tbLocalParam.nReqLevel or 1,
        szTitle = tbLocalParam.szTitle or "",
        nShowPriority = tbLocalParam.nShowPriority or 0,
        nOperationType = tbLocalParam.nOperationType,
        szContent = tbLocalParam.szContent or "",
        szLinkParam = tbLocalParam.szLinkParam or "",
        szTimeFunc = tbLocalParam.szTimeFunc or "",
        szTimeParam1 = tbLocalParam.szTimeParam1 or "",
        szTimeParam2 = tbLocalParam.szTimeParam2 or "",
        szTimeFrameLimit1 =   tbLocalParam.szTimeFrameLimit1 or "",
        szTimeFrameLimit2 = tbLocalParam.szTimeFrameLimit2 or "",
        szClickFunc = tbLocalParam.szClickFunc or "",
        szSwitchFunc = tbLocalParam.szSwitchFunc or "",
        szCheckShowFunc = tbLocalParam.szCheckShowFunc or "",
    };

    self.tbLocalSetting[tbInfo.szKey] = tbInfo

    local tbRedpoint = {}
    table.insert(tbRedpoint, "NI_" .. tbInfo.szKey)
    Ui:InitRedPointNode("NewMessageRedPoint", tbRedpoint)
end
function NewInformation:OnAddInformation(szKey, nCurSession, nValidTime, tbSetting)
    if not self.tbActivity[szKey] or tbSetting then
        tbSetting.szUiName = tbSetting.szUiName or "Normal"
        self.tbActivity[szKey] = tbSetting
        Ui:InitRedPointNode("NI_" .. szKey, nil, "NewMessageRedPoint")
    end
    self.tbInfoData[szKey] = { nSession = nCurSession, nValidTime = nValidTime }
    self.tbShowedRedPoint[szKey] = nil

    self:CheckRedPoint() --todo 这里不应检查红点
    Log("[NewInformation OnAddInformation]", szKey, nCurSession, nValidTime)
end

function NewInformation:OnSyncInfoSession(tbActSession, tbChangedSetting)
    self.tbInfoData = {}
    for szKey, tbActData in pairs(tbActSession) do
        self:OnAddInformation(szKey, unpack(tbActData))
    end

    self:OnSettingChange(tbChangedSetting)
    Log("[NewInformation OnSyncInfoSession]", GetTime())
end

function NewInformation:OnSettingChange(tbChangedSetting)
    if ((not tbChangedSetting) or (not next(tbChangedSetting))) then
        return
    end

    local fnReset = function (szKey, tbInfo)
        local szLocalKey = "Local_" .. szKey
        if not self.tbLocalSetting[szLocalKey] then
            return
        end

        for szRow, data in pairs(tbInfo) do
            self.tbLocalSetting[szLocalKey][szRow] = data
        end
        self.tbInfoData[szLocalKey] = nil
    end

    for szKey, tbInfo in pairs (tbChangedSetting) do
        fnReset(szKey, tbInfo)
    end
    self:PushLocalInformation()
    Log("NewInformation OnSettingChange", #tbChangedSetting)
end

function NewInformation:OnRemoveInformation(szKey)
    if not self.tbInfoData[szKey] then
        return
    end

    self.tbInfoData[szKey] = nil
    self:CheckRedPoint()
end

function NewInformation:OnSyncActData(szKey, tbActData)
    self.tbInfoData[szKey] = tbActData

    UiNotify.OnNotify(UiNotify.emNOTIFY_ONSYNC_NEWINFORMATION, szKey, tbActData.tbData)
    Log("[NewInformation OnSyncActData]", szKey, type(tbActData))
end

NewInformation.tbCustomCheckRP = {
    fnPandoraCheckRp = function (szKey, tbInfo)
        return Pandora:IsShowRedPoint("NewInformationPanel", tbInfo.szOrgKey)
    end,

    fnBeautyRewardCheckRp = function (szKey, tbSetting, tbActData)
        local tbAct = Activity.BeautyPageant
        if me.nLevel < tbAct.LEVEL_LIMIT then
            return false
        end

        for nIndex,_ in ipairs(tbAct.tbVotedAward) do
            local tbAward, nCanGet, nGotCount, bIsShow = tbAct:GetVotedAward(me, nIndex)
            if nCanGet > 0 then
                return true
            end
        end

        return false
    end,

    fnGoodVoiceRewardCheckRp = function (szKey, tbSetting, tbActData)
        local tbAct = Activity.GoodVoice
        if me.nLevel < tbAct.LEVEL_LIMIT then
            return false
        end

        for nIndex,_ in ipairs(tbAct.tbVotedAward) do
            local tbAward, nCanGet, nGotCount, bIsShow = tbAct:GetVotedAward(me, nIndex)
            if nCanGet > 0 then
                return true
            end
        end

        return false
    end,

    fnKinElectCheckRp = function (szKey, tbSetting, tbActData)
        local tbAct = Activity.KinElect
        if me.nLevel < tbAct.LEVEL_LIMIT then
            return false
        end

        for nIndex,_ in ipairs(tbAct.tbVotedAward) do
            local tbAward, nCanGet, nGotCount, bIsShow = tbAct:GetVotedAward(me, nIndex)
            if nCanGet > 0 then
                return true
            end
        end

        return false
    end,

    fnShowDaily = function (szKey, _, tbActData)
        if not tbActData or not tbActData.nSession then
            return
        end

        local nToday = Lib:GetLocalDay()
        local tbData = Client:GetUserInfo("NewInformation_ClearDay")
        if not tbData[szKey] or tbData[szKey] ~= nToday then
            return true
        end

        local tbClearSession = Client:GetUserInfo(NewInformation.szHadClear)
        if not tbClearSession[szKey] or tbClearSession[szKey] ~= tbActData.nSession then
            return true
        end
    end,

    fnShowOnLogin = function (szKey)
        return not NewInformation.tbShowedRedPoint[szKey]
    end,
}
function NewInformation:CheckRedPoint()
    self:CheckActData()

    local tbRedPoint = {}
    for szKey, tbInfo in pairs(self.tbActivity) do
        table.insert(tbRedPoint, szKey)
    end
    for szKey, tbInfo in pairs(self.tbLocalSetting) do
        table.insert(tbRedPoint, szKey)
    end
    local tbClearSession = Client:GetUserInfo(self.szHadClear)
    for _, szKey in ipairs(tbRedPoint) do
        local szRedPoint    = "NI_" .. szKey
        local tbActData     = self.tbInfoData[szKey]
        local nClearSession = tbClearSession[szKey] or 0
        local nReqLevel     = self:GetReqLevel(szKey)
        local tbSetting     = self.tbActivity[szKey] or self.tbLocalSetting[szKey]
        local bIsShowRedPoint = false;

        if tbSetting and tbSetting.szCheckRpFunc and self.tbCustomCheckRP[tbSetting.szCheckRpFunc] then
            bIsShowRedPoint = self.tbCustomCheckRP[tbSetting.szCheckRpFunc](szKey, tbSetting, tbActData)
        elseif tbActData and tbActData.nSession > nClearSession then
            bIsShowRedPoint = true;
        end
        if me.nLevel >= nReqLevel and bIsShowRedPoint then
            Ui:SetRedPointNotify(szRedPoint)
        else
            Ui:ClearRedPointNotify(szRedPoint)
        end
    end
    Activity:CheckRedPoint()
end

function NewInformation:CheckActData()
    for szKey, tbInfo in pairs(self.tbInfoData) do
        if tbInfo.nValidTime <= GetTime() then
            self.tbInfoData[szKey] = nil
        end
    end
end

function NewInformation:OnOpenUi(szKey)
    local tbActData = self.tbInfoData[szKey]
    if not tbActData then
        return
    end

    local tbClearSession = Client:GetUserInfo(self.szHadClear)
    tbClearSession[szKey] = tbActData.nSession

    local tbClearDay = Client:GetUserInfo("NewInformation_ClearDay")
    tbClearDay[szKey] = Lib:GetLocalDay()
    Client:SaveUserInfo()

    self.tbShowedRedPoint[szKey] = true
    self:CheckRedPoint()

    if self.tbLocalSetting[szKey] then
        return
    end

    if tbActData.nValidTime <= GetTime() then
        me.CenterMsg("消息已过期")
        return
    end
    if not tbActData.tbData then
        RemoteServer.TryUpdateNewInformation(szKey, tbActData.nSession or 0)
    end
end

function NewInformation:GetActData(szKey)
	local szActKeyName = Activity:GetActKeyName(szKey);
	if szActKeyName then
        local tbActInfo, tbData = Activity:GetActUiSetting(szActKeyName);
        if tbActInfo.FnCustomData then
            return tbActInfo.FnCustomData(szActKeyName, tbData)
        end
		local tbData = {szKey, tbActInfo.szTitle};
		return tbData;
	end
    return (self.tbInfoData[szKey] or {}).tbData
end

function NewInformation:GetShowActivity()
    self:CheckActData()
    local nMyLevel = me.nLevel
    local tbShowAct = {}
    for szKey, tbInfo in pairs(self.tbInfoData) do
        if nMyLevel >= self:GetReqLevel(szKey) then

            local fnCheckShow = nil
            local tbLocalInfo = self.tbLocalSetting[szKey]

            if tbLocalInfo and tbLocalInfo.szCheckShowFunc  then
                fnCheckShow = self.tbCheckShowFunc[tbLocalInfo.szCheckShowFunc];
            end

            if not fnCheckShow or fnCheckShow(tbLocalInfo) then
                table.insert(tbShowAct, szKey)
            end
        end
    end

    Activity:GetActList(tbShowAct);

    table.sort( tbShowAct, function (szKey1,szKey2)
        local nPriority1 = self:GetShowPriority(szKey1);
        local nPriority2 = self:GetShowPriority(szKey2);
        return nPriority1 > nPriority2
    end );

    return tbShowAct
end

NewInformation.tbOperationType2Priority = {
    [1] = 4,
    [2] = 3,
    [3] = 2,
    [4] = 1,
}
function NewInformation:GetShowPriority(szKey)
    local szActKeyName = Activity:GetActKeyName(szKey)
    if szActKeyName then
        local tbActInfo = Activity:GetActUiSetting(szActKeyName)
        return tbActInfo.nShowPriority or 0
    end

    local tbInfo = self.tbActivity[szKey] or self.tbLocalSetting[szKey]
    if not tbInfo then
        return 0
    end

    if tbInfo.nOperationType then
        return (self.tbOperationType2Priority[tbInfo.nOperationType] or 1) * 1000000 + (tbInfo.nShowPriority or 0)
    end

    return tbInfo.nShowPriority or 0
end
------------------------------------------本地消息------------------------------------------
function NewInformation:OnLogin()
    for szKey, _ in pairs(self.tbInfoData) do
        if not self.tbActivity[szKey] then
            self.tbInfoData[szKey] = nil
        end
    end

    self:PushLocalInformation()
    self.tbShowedRedPoint = {}
end

function NewInformation:OnEnterMap()
    self:PushLocalInformation()
end

--返回的数据格式跟服务端一致
NewInformation.tbTimeJudge = {
    fnOpenServer = function (tbInfo)
        local szOpenTime = tbInfo.szTimeParam1
        local szEndTime  = tbInfo.szTimeParam2
        if string.find(szOpenTime, "|") then

            local tbOpenInfo = Lib:SplitStr(szOpenTime, "|");
            local nOpenDay = TimeFrame:CalcRealOpenDay(tbOpenInfo[1], tonumber(tbOpenInfo[2]));

            local tbEndInfo = Lib:SplitStr(szEndTime, "|");
            local nEndDay = TimeFrame:CalcRealOpenDay(tbEndInfo[1], tonumber(tbEndInfo[2]));

            local nOpenServerDay = Lib:GetServerOpenDay()
            if nOpenDay <= nOpenServerDay and nEndDay >= nOpenServerDay then
                local nBeginDay = Lib:GetLocalDay() - nOpenServerDay - nOpenDay
                local nEndTime = (nEndDay-nOpenServerDay+1)*24*60*60 - Lib:GetTodaySec()
                return true, { nSession = nBeginDay, nValidTime = GetTime() + nEndTime, tbData = {tbInfo.szContent} }
            end
        else
            local bOpen = TimeFrame:GetTimeFrameState(szOpenTime) == 1
            local bClose = TimeFrame:GetTimeFrameState(szEndTime) == 1
            if bOpen and not bClose then
                local nBeginTime = CalcTimeFrameOpenTime(szOpenTime)
                local nOpenTime = CalcTimeFrameOpenTime(szEndTime)
                return true, { nSession = Lib:GetLocalDay(nBeginTime), nValidTime = nOpenTime, tbData = {tbInfo.szContent} }
            end
        end
    end,

    fnSpecialTime = function (tbInfo)
        --可能会有时区问题
        local nBegin = Lib:ParseDateTime(tbInfo.szTimeParam1)
        local nEnd   = Lib:ParseDateTime(tbInfo.szTimeParam2)
        local nCurTime = GetTime()
        if nCurTime >= nBegin and nCurTime <= nEnd then
            local nOpenServerDay = Lib:GetLocalDay(GetServerCreateTime())
            local nNewsBenginDay = Lib:GetLocalDay(nBegin)
            if not Lib:IsEmptyStr(tbInfo.szTimeFrameLimit1) then
                local tbOpenInfo = Lib:SplitStr(tbInfo.szTimeFrameLimit1, "|");
                local nOpenDay = TimeFrame:CalcRealOpenDay(tbOpenInfo[1], tonumber(tbOpenInfo[2]));
                if nNewsBenginDay - nOpenServerDay + 1 < nOpenDay then
                    return
                end
            end
            if not Lib:IsEmptyStr(tbInfo.szTimeFrameLimit2) then
                local tbEndInfo = Lib:SplitStr(tbInfo.szTimeFrameLimit2, "|");
                local nEndDay = TimeFrame:CalcRealOpenDay(tbEndInfo[1], tonumber(tbEndInfo[2]));
                if nNewsBenginDay - nOpenServerDay + 1 > nEndDay then
                    return
                end
            end

            return true, { nSession = Lib:GetLocalDay(nBegin), nValidTime = nEnd, tbData = {tbInfo.szContent} }
        end
    end,

    fnCheckPandora = function (tbInfo)
        local nCurTime = GetTime()
        return Pandora:IsShowIcon("NewInformationPanel", tbInfo.szOrgKey),
         {nSession  = Lib:GetLocalDay(nCurTime),
         nValidTime = nCurTime+99999999,
         tbData     = {tbInfo.szContent},
         }
    end,

    fnShowInWeek = function (tbInfo)
        local nWeek = Lib:GetLocalWeekDay()
        local szShowWeek = tbInfo.szTimeParam1
        if string.find(szShowWeek, nWeek) then
            local nTodaySec = Lib:GetTodaySec()
            local nValidTime = GetTime() - nTodaySec + 24*60*60
            return true, { nSession = Lib:GetLocalWeek(), nValidTime = nValidTime, tbData = {tbInfo.szContent}}
        end
    end,

    fnNewPackage = function ()
        local nVersion = NewPackageGift:GetVersion()
        local nCurVersion = math.floor(GAME_VERSION / 100000)
        if nVersion and nVersion == nCurVersion then
            local nCloseTime = NewPackageGift:GetCloseTime()
            return true, { nSession = nVersion, nValidTime = nCloseTime, tbData = {}}
        end
    end
}

NewInformation.tbClickFunc = {
    fnClickPandora = function (tbInfo)
        Pandora:Open("NewInformationPanel", tbInfo.szOrgKey)
    end,
}

NewInformation.tbSwitchFunc = {
    fnSwitchPandora = function (tbInfo)
        Pandora:Hide("NewInformationPanel", tbInfo.szOrgKey)
    end,
}

NewInformation.tbCheckShowFunc = {
    fnCheckShowPandora = function (tbInfo)
        return Pandora:IsShowIcon("NewInformationPanel", tbInfo.szOrgKey);
    end
}

function NewInformation:IsPush(tbInfo)
    if tbInfo.nReqLevel > me.nLevel then
        return false
    end

    if Lib:IsEmptyStr(tbInfo.szTimeFunc) then
        return false
    end

    local fnJudge = self.tbTimeJudge[tbInfo.szTimeFunc]
    local bPush, tbInfoData = fnJudge(tbInfo)
    return bPush, tbInfoData
end

function NewInformation:PushLocalInformation()
    for _, tbInfo in pairs(self.tbLocalSetting) do
        local bPush, tbActData = self:IsPush(tbInfo)
        if bPush then
            self:AddLocalInformation(tbInfo.szKey, tbActData)
        end
    end
    self:CheckRedPoint()
end

function NewInformation:AddLocalInformation(szKey, tbActData)
    local tbOldData = self.tbInfoData[szKey]
    if tbOldData and tbOldData.nSession == tbActData.nSession then
        return
    end

    Log("NewInformation AddLocalInformation", szKey, tbActData.nSession)
    self:OnSyncActData(szKey, tbActData)
end

-----------------------------------UI-----------------------------------
function NewInformation:GetInfoDetail(szKey)
    local tbInfo
    if self.tbActivity[szKey] then
        tbInfo = self.tbActivity[szKey]
    end

    if self.tbLocalSetting[szKey] then
        tbInfo = self.tbLocalSetting[szKey]
    end

    if tbInfo then
        return {"NI_" .. szKey, tbInfo.szTitle, tbInfo.szUiName, tbInfo.szOrgKey}
    end

	local szActKeyName = Activity:GetActKeyName(szKey);
	if szActKeyName then
		local tbActInfo = Activity:GetActUiSetting(szActKeyName);
		return {szKey, tbActInfo.szTitle or "", tbActInfo.szUiName or "DragonBoatFestival"};
	end
end

function NewInformation:GetAllActivityUi()
    local tbUi = {}
    for _, tbInfo in pairs(self.tbActivity) do
        tbUi[tbInfo.szUiName] = 1
    end

    for _, tbInfo in pairs(self.tbLocalSetting) do
        tbUi[tbInfo.szUiName] = 1
    end

    for _, tbInfo in pairs(Activity.tbUiSetting) do
        if tbInfo.szUiName then
            tbUi[tbInfo.szUiName] = 1
        end
    end

    for szUiName, _ in pairs(self.tbActRegUi) do
        tbUi[szUiName] = 1
    end
    return tbUi
end

--提供给不在第一层定义的UI
function NewInformation:RegisterUi(szUiName)
    self.tbActRegUi[szUiName] = 1
end

function NewInformation:GetActivityUi(szKey)
    local tbInfo = self:GetInfoDetail(szKey) or {}
    return tbInfo[3]
end

function NewInformation:GetReqLevel(szKey)
    local tbInfo = self.tbActivity[szKey] or self.tbLocalSetting[szKey]
    if not tbInfo then
        return 99999
    end

    return tbInfo.nReqLevel or 0
end

function NewInformation:GetTableFromString(szValue)
    local tbResult = {};
    local tbLines = Lib:SplitStr(szValue, ";")
    for nIdx, szCell in ipairs(tbLines) do
        if szCell ~= "" then
            local tbElem = Lib:SplitStr(szCell, "|")
            tbResult[nIdx] = {unpack(tbElem)}
        end
    end

    return tbResult
end

function NewInformation:OnClickTab(szKey)
    local tbInfo = self.tbActivity[szKey] or self.tbLocalSetting[szKey]
    if not tbInfo or not tbInfo.szClickFunc then
        return
    end
    local fnClick = self.tbClickFunc[tbInfo.szClickFunc]

    if fnClick then
        fnClick(tbInfo)
    end
end

function NewInformation:OnSwitchTab(szKey)
    local tbInfo = self.tbActivity[szKey] or self.tbLocalSetting[szKey]
    if not tbInfo or not tbInfo.szSwitchFunc  then
        return
    end


    local fnSwitch = self.tbSwitchFunc[tbInfo.szSwitchFunc]

    if fnSwitch then
        fnSwitch(tbInfo)
    end
end

function NewInformation:GetOperationType(szKey)
    local szActKeyName = Activity:GetActKeyName(szKey)
    if szActKeyName then
        local tbActInfo = Activity:GetActUiSetting(szActKeyName)
        return tbActInfo.nOperationType
    end
    local tbInfo = self.tbActivity[szKey] or self.tbLocalSetting[szKey]
    if not tbInfo then
        return
    end
    return tbInfo.nOperationType
end