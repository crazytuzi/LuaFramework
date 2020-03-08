local DAY_SEC = 24*60*60
local WEEK_NAME
local WEEK
if version_vn or version_th or version_kor then
    WEEK_NAME = ""
    if version_vn then
        WEEK = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"} --特供越南版本使用
    else
        WEEK = {"周1", "周2", "周3", "周4", "周5", "周6", "周7"} --特供泰国版用，后韩国版本也使用
    end
else
    WEEK_NAME = "周"
    WEEK = {"一", "二", "三", "四", "五", "六", "日"}
end
function Calendar:LoadSetting()
    local tbRewardSetting = Lib:LoadTabFile("Setting/Calendar/ActivityReward.tab", {nId = 1, nLevelMin = 1, nLevelMax = 1})
    assert(tbRewardSetting, "[Calendar LoadSetting ActivityReward.tab] Error")

    self.tbRewardSetting   = {};
    for _, tbInfo in pairs(tbRewardSetting) do
        tbInfo.tbAwardInfo = Lib:GetAwardFromString(tbInfo.tbAwardInfo)
        self.tbRewardSetting[tbInfo.nId] = self.tbRewardSetting[tbInfo.nId] or {};
        table.insert(self.tbRewardSetting[tbInfo.nId], tbInfo)
    end

    local tbCalendarSetting = Lib:LoadTabFile("Setting/Calendar/Calendar.tab", {nId = 1, nLevelMin = 1, nLevelMax = 1, nSort = 1, nStarLevel = 1, nTimeGroup = 1, bWeek = 1, bNotPreview = 1})
    assert(tbCalendarSetting, "[Calendar LoadSetting Calendar.tab] Error")

    self.tbCalendarSetting = {};
    for _, tbInfo in ipairs(tbCalendarSetting) do
        tbInfo.bWeek = (tbInfo.bWeek == 1)
        tbInfo.nDefaultSort = tbInfo.nSort
        tbInfo.nLevelMax = tbInfo.nLevelMax > 0 and tbInfo.nLevelMax or 99999
        self.tbCalendarSetting[tbInfo.nId] = tbInfo
    end
end

function Calendar:LoadTimeSetting()
    self.tbTimeGroupSetting  = {};
    local tbKey = {"Name", "WeekFlag", "TimeFrame", "CloseTimeFrame"};
    local szKey = "ssss";
    for i = 1, 15 do
        table.insert(tbKey, "Time" .. i);
        szKey = szKey .. "s";
    end
    local tbScheduleSetting  = LoadTabFile("Setting/ScheduleTask.tab", szKey, "Name", tbKey);

    local tbTimeGroupSetting = LoadTabFile(
        "Setting/Calendar/ActivityTimeGroup.tab",
        "dss", nil,
        {"TimeGroup", "Start", "End"});
    for _, tbInfo in pairs(tbTimeGroupSetting) do
        self.tbTimeGroupSetting[tbInfo.TimeGroup] = self.tbTimeGroupSetting[tbInfo.TimeGroup] or {};
        local tbStart = {};
        local tbStartList = tbScheduleSetting[tbInfo.Start];
        local tbEndList = tbScheduleSetting[tbInfo.End];
        if tbStartList and tbEndList then
            for i = 1, 15 do
                if tbStartList["Time" .. i] ~= "" and tbEndList["Time" .. i] ~= "" then
                    local nStartSec = Lib:ParseTodayTime(tbStartList["Time" .. i]);
                    local nEndSec = Lib:ParseTodayTime(tbEndList["Time" .. i]);
                    table.insert(self.tbTimeGroupSetting[tbInfo.TimeGroup], {nStartSec, nEndSec, tbStartList.WeekFlag, tbStartList.TimeFrame, tbStartList.CloseTimeFrame, tbInfo.Start});
                end
            end
        end
    end

    for nId, tbInfo in pairs(self.tbCalendarSetting) do
        local szTimeFrame = tbInfo.szActiveTimeFrame
        if szTimeFrame ~= "" and tbScheduleSetting[szTimeFrame] then
            tbInfo.szTimeFrameOpen = tbScheduleSetting[szTimeFrame].TimeFrame
        end
    end
end

function Calendar:LoadTipSetting()
    self.tbActivityTip = LoadTabFile("Setting/Calendar/ActivityTip.tab", "sssss", "Key", { "Key", "HelpKey", "Type", "Time", "Desc" })
    assert(self.tbActivityTip, "[Calendar LoadTipSetting] Error TabFile Not Found")
end

Calendar:LoadSetting()
Calendar:LoadTimeSetting()
Calendar:LoadTipSetting()

function Calendar:GetSysNotiyTable()
    --目前通知消息列表里只能是随时间轴增长的，不然 安卓:ClearSysNotifyCation不对
    if self.tbSysNotiy and self.nSysNotifyDataDay == Lib:GetLocalDay() and me.nLevel ~= 0 then --因为刚进游戏时的等级是0，
        return  self.tbSysNotiy
    end

    if ANDROID and (version_hk or version_tw) then
        return {};
    end

    local tbLimitFunc = {
        ["NeedKin"] = function ()
            return me.dwKinId ~= 0
        end;
    }

    local tbMySysNotify = Client:GetUserInfo("MySysNotify", -1)
    local bUseDefault = not next(tbMySysNotify)
    local tbSysNotiyFile = LoadTabFile("Setting/Calendar/SysNotify.tab", "sdsssdd", nil, {"StringKey", "LevelMin", "LimitFunc", "Name", "Message", "BeforSec", "DefaultSel"});
    local tbSysNotiy = {}
    local nMyLevel = me.nLevel
    for i, v in ipairs(tbSysNotiyFile) do
        if bUseDefault then
            tbMySysNotify[v.StringKey] = v.DefaultSel == 0;
        end
        if  nMyLevel >= v.LevelMin  then
            if v.LimitFunc == "" or tbLimitFunc[v.LimitFunc]() then
                local szKey = v.StringKey
                local nActivityID = Calendar:GetActivityId(szKey)
                local tbOpenTime = self:GetTodayOpenTime(nActivityID)
                local tbNotiTimes = {}
                for i2,v2 in ipairs(tbOpenTime) do
                    table.insert(tbNotiTimes, v2[1] - v.BeforSec)
                end
                if next(tbNotiTimes) then
                    -- {nStartSec, nEndSec, tbStartList.WeekFlag, tbStartList.TimeFrame, tbStartList.CloseTimeFrame});
                    local bRepeat = not Calendar:IsWeekActivity(nActivityID)
                    if bRepeat then --心魔和战场这种非周活动显示的但也不是天天开的，所以判断下第二天开不开
                        local tbOpenTime2 = self:GetTodayOpenTime(nActivityID,  - 3600 * 24)
                        if not next(tbOpenTime2) then
                            bRepeat = false
                        end
                    end
                    table.insert(tbSysNotiy, {szKey = szKey, nId = i, szName = v.Name, tbTimeGroup = tbNotiTimes, szMsg = v.Message, BeforSec = v.BeforSec ,bRepeat = bRepeat})
                end
            end
        end
    end
    if bUseDefault then
        Client:SaveUserInfo();
    end
    if Login.bEnterGame then
        self.tbSysNotiy = tbSysNotiy
    end
    self.nSysNotifyDataDay = Lib:GetLocalDay()
    return tbSysNotiy;
end

function Calendar:GetPreviewInfo()
    local tbPreViewInfo = {}
    local nCurOpenServerDay = Lib:GetLocalDay(GetServerCreateTime())
    local nToday = Lib:GetLocalDay()
    local nNextOpenLevelSeverDay = 0

    for _, tbInfo in ipairs(TimeFrame.tbOpenNewMaxLevelTimeFrame) do
        local nRealOpenDay, nOpenTime = TimeFrame:CalcRealOpenDay(tbInfo.szEvent);
        if TimeFrame:GetTimeFrameState(tbInfo.szEvent) == 1 then
            tbPreViewInfo.nNowLevelOpenDay = nToday - nCurOpenServerDay + 2 - nRealOpenDay;
            tbPreViewInfo.nCurMaxLevel = tbInfo.nMaxLevel
        else
            nNextOpenLevelSeverDay = Lib:GetLocalDay(nOpenTime);
            tbPreViewInfo.nNextMaxLevel = tbInfo.nMaxLevel
            break;
        end
    end

    tbPreViewInfo.nCurMaxLevel = tbPreViewInfo.nCurMaxLevel or 0
    tbPreViewInfo.nNextOpenDay = nNextOpenLevelSeverDay
    tbPreViewInfo.nWillOpenDay = nNextOpenLevelSeverDay - nToday
    return tbPreViewInfo
end

function Calendar:IsOpenWeek(nActivityID, nTime)
    local tbSetting = self.tbCalendarSetting[nActivityID]
    local nTimeGroup = tbSetting.nTimeGroup
    local tbTimeSetting = self.tbTimeGroupSetting[nTimeGroup]
    if not tbTimeSetting then
        return true
    end

    for _, tbInfo in ipairs(tbTimeSetting) do
        local _, _, _, szOpenTimeFrame, szCloseTimeFrame, szKey = unpack(tbInfo)

        while true do
            if szOpenTimeFrame and szOpenTimeFrame ~= "" then
                if TimeFrame:GetTimeFrameState(szOpenTimeFrame) ~= 1 then
                    break
                end
            end

            if szCloseTimeFrame and szCloseTimeFrame ~= "" then
                if TimeFrame:GetTimeFrameState(szCloseTimeFrame) == 1 then
                    break
                end
            end

            if Lib.ScheduleTask:IsOpenWeek(szKey, nTime) then
                return true
            end

            break
        end
    end
    return false
end

function Calendar:GetDailyActivity()
    local tbList = {{}, {}}
    for nId, tbInfo in pairs(self.tbCalendarSetting) do
        if me.nLevel <= tbInfo.nLevelMax then
            local szOpenTime = tbInfo.szTimeFrameOpen
            if (Lib:IsEmptyStr(szOpenTime) or GetTimeFrameState(szOpenTime) == 1) and tbInfo.nLevelMin <= me.nLevel and self:IsAdditionalShowActivity(tbInfo.szKey) then
                if self:IsTimeLimit(nId) then
                    local tbTime = self:GetTodayNextOpenTime(nId)
                    local bInProgress = self:IsActivityInOpenState(tbInfo.szKey)
                    if self:IsComplete(nId) then
                        tbInfo.nSort = 10000000 + tbInfo.nDefaultSort
                        table.insert(tbList[2], tbInfo)
                    elseif bInProgress then
                        tbInfo.nSort = tbInfo.nDefaultSort
                        table.insert(tbList[2], tbInfo)
                    elseif tbTime then
                        if self:IsOpenWeek(nId, GetTime()) then
                            tbInfo.nSort = tbTime[1] + tbInfo.nDefaultSort
                            table.insert(tbList[2], tbInfo)
                        end
                    else
                        if self:IsOpenWeek(nId, GetTime()) then
                            tbInfo.nSort = 1000000 + tbInfo.nDefaultSort
                            table.insert(tbList[2], tbInfo)
                        end
                    end
                else
                    if self:IsOpenWeek(nId, GetTime()) then
                        local nSort = self:IsComplete(nId) and 100000 or 0
                        tbInfo.nSort = tbInfo.nDefaultSort + nSort
                        table.insert(tbList[1], tbInfo)
                    end
                end
            end
        end
    end
    for _, tbInfo in ipairs(tbList) do
        table.sort(tbInfo, function (a1, a2)
            return a1.nSort < a2.nSort
        end)
    end
    return unpack(tbList)
end

function Calendar:GetPreviewActivity()
    local tbList = {{}, {}}
    local nToday = Lib:GetLocalDay()
    local nNextOpenLevelSeverDay = self:GetPreviewInfo().nNextOpenDay
    for nId, tbInfo in pairs(self.tbCalendarSetting) do
        if self:IsAdditionalShowActivity(tbInfo.szKey) then
            local bShow = false
            local szOpenTime = tbInfo.szTimeFrameOpen
            if Lib:IsEmptyStr(szOpenTime) or GetTimeFrameState(szOpenTime) == 1 then
                if tbInfo.nLevelMin > me.nLevel and tbInfo.nLevelMin - me.nLevel <= 10 then
                    tbInfo.nSort = tbInfo.nLevelMin
                    bShow = true
                end
            else
                local nOpenServerTime = CalcTimeFrameOpenTime(szOpenTime)
                local nOpenServerDay = Lib:GetLocalDay(nOpenServerTime)
                if nNextOpenLevelSeverDay <= 0 or nOpenServerDay <= nNextOpenLevelSeverDay and
                    ((tbInfo.nLevelMin > me.nLevel and tbInfo.nLevelMin - me.nLevel <= 10) or me.nLevel >= tbInfo.nLevelMin) then
                    tbInfo.nSort = (nOpenServerDay - nToday) + 100
                    bShow = true
                end
            end

            if tbInfo.bNotPreview == 1 then
                bShow = false;
            end

            if bShow then
                if self:IsTimeLimit(nId) then
                    table.insert(tbList[2], tbInfo)
                else
                    table.insert(tbList[1], tbInfo)
                end
            end
        end
    end
    for _, tbInfo in ipairs(tbList) do
        table.sort(tbInfo, function (a1, a2)
            return a1.nSort < a2.nSort
        end)
    end
    return unpack(tbList)
end

function Calendar:GetWeekActivity()
    local tbList = {}
    for nId, tbInfo in pairs(self.tbCalendarSetting) do
        local szOpenTime = tbInfo.szTimeFrameOpen
        if tbInfo.nTimeGroup > 0 and not tbInfo.bWeek and tbInfo.nLevelMin <= me.nLevel and self:IsAdditionalShowActivity(tbInfo.szKey) then
            if Lib:IsEmptyStr(szOpenTime) or GetTimeFrameState(szOpenTime) == 1 then
                local tbTodayOpenTime = self:GetTodayOpenTime(nId)
                if #tbTodayOpenTime > 0 then
                    table.insert(tbList, tbInfo)
                end
            end
        end
    end
    table.sort(tbList, function (a1, a2)
        return a1.nDefaultSort < a2.nDefaultSort
    end)
    return tbList
end

function Calendar:GetActivityDetail(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID]
    if not tbSetting then
        return
    end

    local tbInfo = self.tbActivityTip[tbSetting.szKey]
    if not tbInfo then
        return
    end

    return tbInfo.Time, tbInfo.Type, tbInfo.Desc, tbInfo.HelpKey
end

function Calendar:IsOpenAtTime(tbInfo, nRefTime)
    if not Lib.ScheduleTask:IsOpenWeek(tbInfo[6], GetTime()) then
        return false
    end

    local szWeek = tbInfo[3]
    if not self:InWeekDay(szWeek, nRefTime) then
        return false
    end

    local nBeginTime = GetTime() - Lib:GetTodaySec() + tbInfo[1]
    local szOpenTF = tbInfo[4]
    if not Lib:IsEmptyStr(szOpenTF) then
        local nTimeFrameOpen = CalcTimeFrameOpenTime(szOpenTF)
        if nBeginTime < nTimeFrameOpen then
            return false
        end
    end

    local szCloseTF = tbInfo[5]
    if not Lib:IsEmptyStr(szCloseTF) then
        local nTimeFrameOpen = CalcTimeFrameOpenTime(szCloseTF) --活动关闭时间
        if nTimeFrameOpen < nBeginTime then
            return false
        end
    end

    return true
end

Calendar.tbTodayOpenExtFunc = {
    ["FactionBattle"] = function ()
        return FactionBattle:IsCanStart()
    end,
}

function Calendar:GetTodayOpenTime(nActivityID, nRefTime)
    local tbSetting = self.tbCalendarSetting[nActivityID];
    local nTimeGroup = tbSetting.nTimeGroup;
    local tbTimeSetting = self.tbTimeGroupSetting[nTimeGroup];
    local tbTime = {};
    for _, tbInfo in ipairs(tbTimeSetting or {}) do
        local bOpen = self:IsOpenAtTime(tbInfo, nRefTime)
        if bOpen then
            local fn = self.tbTodayOpenExtFunc[tbSetting.szKey]
            if not fn or fn(tbInfo) then
                table.insert(tbTime, tbInfo)
            end
        end
    end
    table.sort(tbTime, function (a1, a2)
        return a1[1] < a2[1]
    end)

    return tbTime;
end

function Calendar:GetTodayNextOpenTime(nActivityID)
    local tbTodayOpenTime = self:GetTodayOpenTime(nActivityID)
    if not next(tbTodayOpenTime) then
        return
    end

    table.sort(tbTodayOpenTime, function (a1, a2)
        return a1[1] < a2[1]
    end)

    local nSec = Lib:GetTodaySec()
    local szKey = Calendar:GetActivityStringKey(nActivityID)
    for _, tbInfo in ipairs(tbTodayOpenTime) do
        if (nSec >= tbInfo[1] and nSec <= tbInfo[2] and self:IsActivityInOpenState(szKey)) or nSec < tbInfo[1] then
            return {tbInfo[1], tbInfo[2]}
        end
    end
end

Calendar.tbWeekCondition = {
    ["FactionBattle"] = function(nTime)
        --周四场次的门派竞技在群英会或者华山论剑开启后不开放该场次
        local nWeek = Lib:GetLocalWeekDay(nTime)
        if nWeek ~= 4 then
            return true
        end
        -- 判断群英会开没开，11为群英会ID
        local tbSetting = Calendar.tbCalendarSetting[11]
        local szOpenTime = tbSetting.szTimeFrameOpen
        if CalcTimeFrameOpenTime(szOpenTime) <= nTime then
            return false
        end

        return not HuaShanLunJian:IsOpenGameInTime(nTime)
    end
}
function Calendar:GetActTime(szKey, tbTimeSetting, nWeekBeginTime, nOpenTime)
    local tbWeekTime = {}
    for _, tbTimeInfo in ipairs(tbTimeSetting) do
        for i = 1, 7 do
            if string.find(tbTimeInfo[3], tostring(i)) then
                local nBegTime = DAY_SEC * (i-1) + tbTimeInfo[1]
                local nEndTime = DAY_SEC * (i-1) + tbTimeInfo[2]
                tbWeekTime[i] = tbWeekTime[i] or {}
                table.insert(tbWeekTime[i], {{nBegTime, nEndTime, tbTimeInfo[5]}, tbTimeInfo[6]})

            end
        end
    end

    local nTodayWeek = Lib:GetLocalWeekDay()
    local nTodaySec  = Lib:GetTodaySec()
    local tbOpenTime = {}
    for nWeek, tbTimeList in pairs(tbWeekTime) do
        table.sort(tbTimeList, function (a1, a2)
            local nStartTime1, _, szCloseFrame1 = unpack(a1[1])
            local nStartTime2, _, szCloseFrame2 = unpack(a2[1])
            local bOpen1 = Lib:IsEmptyStr(szCloseFrame1) or nWeekBeginTime + nStartTime1 < CalcTimeFrameOpenTime(szCloseFrame1)
            local bOpen2 = Lib:IsEmptyStr(szCloseFrame2) or nWeekBeginTime + nStartTime2 < CalcTimeFrameOpenTime(szCloseFrame2)
            if bOpen1 ~= bOpen2 then
                return bOpen1
            end
            return nStartTime1 < nStartTime2
        end)
        local tbTimeTmp
        if #tbTimeList > 1 and nTodayWeek == nWeek then
            for _, tbTime in ipairs(tbTimeList) do
                local nTime = tbTime[1][2]%(24*60*60)
                if nTodaySec <= nTime then
                    tbTimeTmp = tbTime
                    break
                end
            end
            tbTimeTmp = tbTimeTmp or tbTimeList[#tbTimeList]
        else
            tbTimeTmp = tbTimeList[1]
        end
        table.insert(tbOpenTime, tbTimeTmp)
    end

    local tbShow = {}
    for _, tb in ipairs(tbOpenTime) do
        local tbTime = tb[1]
        local szCloseTimeFrame = tbTime[3]
        local nBeginTime = tbTime[1] + nWeekBeginTime
        if (nBeginTime >= nOpenTime) and
            (Lib:IsEmptyStr(szCloseTimeFrame) or nBeginTime < CalcTimeFrameOpenTime(szCloseTimeFrame)) then
            local fnCondition = self.tbWeekCondition[szKey]
            if not fnCondition or fnCondition(nBeginTime) then
                if Lib.ScheduleTask:IsOpenWeek(tb[2], nBeginTime) then
                    table.insert(tbShow, tbTime)
                end
            end
        end
    end
    return tbShow
end
function Calendar:GetWeekOpenAct() --获取这周开启的活动
    local nWeekBeginTime = GetTime() - Lib:GetLocalWeekTime()
    local tbWeekOpenAct  = {}
    for nId, tbInfo in pairs(self.tbCalendarSetting) do
        local nTimeGroup = tbInfo.nTimeGroup
        if tbInfo.bWeek and not Lib:IsEmptyStr(tbInfo.szTimeFrameOpen) and nTimeGroup > 0 then
            local nOpenTime = CalcTimeFrameOpenTime(tbInfo.szTimeFrameOpen)
            local tbTime = self:GetActTime(tbInfo.szKey, self.tbTimeGroupSetting[nTimeGroup], nWeekBeginTime, nOpenTime)
            if next(tbTime) then
                for _, tbInfo in ipairs(tbTime) do
                    local nActOpenTime = tbInfo[1] + nWeekBeginTime
                    local nActEndTime = tbInfo[2] + nWeekBeginTime
                    local nWeekDay = Lib:GetLocalWeekDay(nActOpenTime)
                    table.insert(tbWeekOpenAct, {nId, nActOpenTime, nActEndTime, nWeekDay})
                end
            end
        end
    end
    table.sort(tbWeekOpenAct, function (a1, a2) return a1[2] < a2[2] end)
    return tbWeekOpenAct
end

function Calendar:GetTip(nId)
    local tbSetting = self.tbCalendarSetting[nId] or {}
    return tbSetting.szOpenActivityTip
end

function Calendar:GetWeekOpenDay(nId)
    local tbSetting = self.tbCalendarSetting[nId]
    if tbSetting.nTimeGroup <= 0 then
        return
    end

    local szWeek = ""
    if tbSetting.bWeek then
        local tbWeekOpen = Calendar:GetWeekOpenAct()
        for _, tbInfo in pairs(tbWeekOpen or {}) do
            if tbInfo[1] == nId then
                szWeek = szWeek .. tbInfo[4]
            end
        end
    end

    if Lib:IsEmptyStr(szWeek) then
        local tbOpenTime = self.tbTimeGroupSetting[tbSetting.nTimeGroup]
        for _, tbInfo in pairs(tbOpenTime) do
            if Lib:IsEmptyStr(tbInfo[5]) or GetTimeFrameState(tbInfo[5]) ~= 1 then
                szWeek = szWeek .. tbInfo[3]
            end
        end
    end

    local tbOpenDay = {}
    for i = 1, 7 do
        if string.find(szWeek, i) then
            table.insert(tbOpenDay, i)
        end
    end
    return tbOpenDay
end

function Calendar:InWeekDay(szWeek, nRefTime)
    local nWeekDay = nRefTime and Lib:GetLocalWeekDay(GetTime() - nRefTime) or Lib:GetLocalWeekDay();
    local nRet = string.find(szWeek, tostring(nWeekDay));
    return nRet ~= nil;
end

function Calendar:GetCountFuncInfo(tbSetting)
    local szFunction = tbSetting.szJoinCountFunc
    if Lib:IsEmptyStr(szFunction) then
        return
    end

    local nCount, nMaxCount;
    if string.find(szFunction, ":") then
        local szTable, szFunc = string.match(szFunction, "^(.*):(.*)$");
        local tb = loadstring("return " .. szTable)();
        nCount, nMaxCount = tb[szFunc](tb, me);
    else
        local func = loadstring("return " .. szFunction)();
        nCount, nMaxCount = func(me);
    end

    if not nCount then
        return;
    end

    return type(nCount) == "string" and nCount or string.format("次数: %d/%d", nCount, nMaxCount);
end

function Calendar:GetDXZCount(pPlayer)
    local nCount = Activity.tbDaXueZhang:GetDXZJoinCount(pPlayer);
    local nMaxCount = nCount;
    if nMaxCount <= 0 then
        nMaxCount = 1;
    end
    return nCount, nMaxCount;
end

function Calendar:GetDegree(szDegree)
    local nMax = DegreeCtrl:GetMaxDegree(szDegree, me)
    local nDegree = DegreeCtrl:GetDegree(me, szDegree)
    local _, _, nDan = ChuangGong:GetDegree(me, szDegree)
    local szDes = string.format("%d/%d", math.max(nDegree, 0), nMax)
    if nDan > 0 then
        szDes = string.format("%d[C8FF00]+%d[-]/%d", math.max(nDegree, 0), nDan, nMax)
    end
    return szDes
end

function Calendar:GetDegreeInfo(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID]
    if not tbSetting then
        Log("[Calendar GetDegreeInfo Error] Not Found Setting", nActivityID)
        return "无限"
    end

    local szInfo = self:GetCountFuncInfo(tbSetting)
    if szInfo then
        return szInfo
    end

    local szDegree = tbSetting.szJoinCount
    if szDegree == "NULL" then
        return ""
    end
    return Lib:IsEmptyStr(szDegree) and "次数: 无限" or string.format("次数: %s", self:GetDegree(szDegree))
end

--比如战场、心魔这种存在不同的日历使用相同的degree
function Calendar:GetUseDegreeCalenderIds(szDegree)
    if not self.tbCacheUseDegreeCalenderIds then
        self.tbCacheUseDegreeCalenderIds = {};
        for nActivityID, tbSetting in pairs(self.tbCalendarSetting) do
            if not Lib:IsEmptyStr(tbSetting.szJoinCount) then
                self.tbCacheUseDegreeCalenderIds[tbSetting.szJoinCount] = self.tbCacheUseDegreeCalenderIds[tbSetting.szJoinCount] or {}
                table.insert(self.tbCacheUseDegreeCalenderIds[tbSetting.szJoinCount], nActivityID)
            end
        end
    end
    return self.tbCacheUseDegreeCalenderIds[szDegree]
end

function Calendar:IsTimeLimit(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID];
    return tbSetting.nTimeGroup ~= 0;
end

function Calendar:GetActivityStringKey(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID];
    return tbSetting.szKey;
end

function Calendar:GetActivityId(szKey)
    for nId, tbInfo in pairs(self.tbCalendarSetting) do
        if tbInfo.szKey == szKey then
            return nId
        end
    end
end

function Calendar:GetActivityLevelMin(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID];
    return tbSetting.nLevelMin;
end

Calendar.tbSpecialActivityReward = {
    [3] = function ( self )
        --战场的先写死吧，太特殊了
        local tbTime = {};
        local tbHundrendsTimes = self.tbTimeGroupSetting[28]
        for _, tbInfo in ipairs(tbHundrendsTimes or {}) do
            local bOpen = self:IsOpenAtTime(tbInfo)
            if bOpen then
                table.insert(tbTime, tbInfo)
            end
        end
        local tbHundrendsTimes = self.tbTimeGroupSetting[29]
        for _, tbInfo in ipairs(tbHundrendsTimes or {}) do
            local bOpen = self:IsOpenAtTime(tbInfo)
            if bOpen then
                table.insert(tbTime, tbInfo)
            end
        end
        table.sort(tbTime, function (a1, a2)
            return a1[1] < a2[1]
        end)
        local nSec = Lib:GetTodaySec()
        for _, tbInfo in ipairs(tbTime) do
            if (nSec >= tbInfo[1] and nSec <= tbInfo[2] ) or nSec < tbInfo[1] then
                return 46 --攻防战的
            end
        end
    end;
};


function Calendar:GetActivityReward(nActivityID)
    local fnSpecialActivityReward = self.tbSpecialActivityReward[nActivityID]
    if fnSpecialActivityReward  then
        local nChangenActivityID = fnSpecialActivityReward(self)
        if nChangenActivityID then
            nActivityID = nChangenActivityID
        end
    end
    local tbSetting = self.tbRewardSetting[nActivityID] or {}
    local tbAward   = {}
    local nMyLevel  = me.nLevel
    local fnIsInTime = function (szTimeBegin, szTimeEnd)
        return (szTimeBegin == "" and szTimeEnd == "") or
        (szTimeBegin == "" and GetTimeFrameState(szTimeEnd) ~= 1) or
        (szTimeEnd == "" and GetTimeFrameState(szTimeBegin) == 1) or
        (GetTimeFrameState(szTimeBegin) == 1 and GetTimeFrameState(szTimeEnd) ~= 1)
    end
    for _, tbInfo in pairs(tbSetting) do
        if nMyLevel >= tbInfo.nLevelMin and nMyLevel <= tbInfo.nLevelMax and fnIsInTime(tbInfo.szTimeBegin, tbInfo.szTimeEnd) then
            local tbSingle = unpack(tbInfo.tbAwardInfo)
            if tbSingle then
                table.insert(tbAward, unpack(tbInfo.tbAwardInfo))
            end
        end
    end
    return tbAward
end

Calendar.tbSpecialName = {
    ["Battle"] = function (tbData)
        local tbBattleSetting = Battle:GetCanSignBattleSetting(me)
        if tbBattleSetting and tbBattleSetting.bZone then
            return tbBattleSetting.szName
        end
        if Battle.bShowItemBoxInBackCamp then
            return tbData.szName.. "(星移)"
        end
        return tbData.szName
    end;
};

function Calendar:GetActivityName(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID];
    local fnFunc = self.tbSpecialName[tbSetting.szKey]
    if not fnFunc then
        return tbSetting.szName
    end
    return fnFunc(tbSetting)
end

function Calendar:GetWeekBg(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID]
    return tbSetting.szWeekIcon
end

function Calendar:IsWeekActivity(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID]
    return tbSetting.bWeek
end

local tbCheckComplete = {
    ["ChuanGong"] = function (szJoinCount)
        return ChuangGong:CheckIsDegreeOut(me)
    end,
    ["CommerceTask"] = function (szJoinCount)
        local nDegree = DegreeCtrl:GetDegree(me, szJoinCount)
        return (nDegree == 0 and not CommerceTask:IsDoingTask(me))
    end,
    ["HeroChallenge"] = function ()
        for nFloor = 1, HeroChallenge.nMaxRankFloor do
            local bRet = HeroChallenge:CheckChallengeAward(me, nFloor)
            if bRet then
                return false;
            end
        end

        return not HeroChallenge:CheckChallengeMaster(me, true)
    end,
    ["ActivityQuestion"] = function ()
        local _, _, bComplete = ActivityQuestion:GetState()
        return bComplete
    end,
    ["Rank"] = function ()
        return false
    end,
    ["CardCollection_1"] = function()
        return DegreeCtrl:GetDegree(me, "RandomFuben") == 0
    end,
    ["ImperialTomb"] = function()
        return ImperialTomb:GetStayTime(me) <= 0
    end,
    ["Battle"] = function()
        return false
    end,
    ["BattleMoba"] = function()
        return false
    end,
    ["InDifferBattle"] = function ()
        return false
    end,
    ["InDifferBattleJuedi"] = function ()
        return false
    end,
}
local tbCheckEarlyComplete = {
    ["KinEscort"] = function ()
        return Kin:IsEscortFinished()
    end,
    ["PartnerCardTask"] = function ()
        return PartnerCard:IsCompleteTask()
    end,
    ["LoverTask"] = function ()
        return LoverTask:IsCompleteTask()
    end,
}
function Calendar:IsComplete(nActivityID)
    local tbSetting = self.tbCalendarSetting[nActivityID]
    if not tbSetting then
        return
    end

    local fnCheck = tbCheckComplete[tbSetting.szKey]
    if fnCheck then
        return fnCheck(tbSetting.szJoinCount)
    end

    local fnCheck = tbCheckEarlyComplete[tbSetting.szKey]
    if fnCheck and fnCheck() then
        return true
    end

    if not Lib:IsEmptyStr(tbSetting.szJoinCount) then
        return DegreeCtrl:GetDegree(me, tbSetting.szJoinCount) == 0
    end

    if tbSetting.nTimeGroup <= 0 then
        return
    end

    if self:IsActivityInOpenState(tbSetting.szKey) then
        return false
    end

    local tbTimeSetting = self.tbTimeGroupSetting[tbSetting.nTimeGroup]
    if not tbTimeSetting or not next(tbTimeSetting) then
        return false
    end

    local tbNextOpenTime = self:GetTodayNextOpenTime(nActivityID)
    if tbNextOpenTime then
        return false
    end

    local tbTodayOpenTime = self:GetTodayOpenTime(nActivityID)
    return #tbTodayOpenTime > 0
end

local tbCompleteFunc = {
    ["CommerceTask"] = function()
        return CommerceTask:GetCompleteText()
    end,
}
function Calendar:GetCompleteText(nId)
    local tbSetting = self.tbCalendarSetting[nId]
    local szKey = tbSetting.szKey
    local szDefault = tbSetting.nTimeGroup > 0 and "已结束" or "[0aff19]已完成"
    return tbCompleteFunc[szKey] and tbCompleteFunc[szKey]() or szDefault
end

--非限时类预告描述，非限时类在日常中没有描述
function Calendar:GetNotTimeLimitPreviewDesc(nId)
    local tbSetting = self.tbCalendarSetting[nId]
    local szOpenTime = tbSetting.szTimeFrameOpen
    if Lib:IsEmptyStr(szOpenTime) or GetTimeFrameState(szOpenTime) == 1 then
        return string.format("%d级开放", tbSetting.nLevelMin)
    else
        local nOpenServerTime = CalcTimeFrameOpenTime(szOpenTime)
        local nOpenServerDay = Lib:GetLocalDay(nOpenServerTime)
        local nToday = Lib:GetLocalDay()
        if nOpenServerDay == nToday then
            local nTime = Lib:GetLocalDayHour(nOpenServerTime)
            return string.format("%d点开放", nTime)
        elseif nOpenServerDay > nToday then
            return string.format("%d天后开放", nOpenServerDay - nToday)
        end
    end
end

function Calendar:TimeDesc(nSec, bAddGMT)
    nSec = bAddGMT and (nSec + Lib:GetGMTSec()) or nSec
    nSec = math.mod(nSec, DAY_SEC)
    return string.format("%02d:%02d", nSec / 3600, nSec % 3600 / 60)
end

function Calendar:TimeToString(nTimeBegin, nTimeEnd, bAddGMT)
    local szBegin = self:TimeDesc(nTimeBegin, bAddGMT)
    local szEnd   = self:TimeDesc(nTimeEnd, bAddGMT)
    return string.format("%s-%s", szBegin, szEnd)
end

--限时类活动描述
function Calendar:GetTimeLimitActDesc(nId)
    local tbSetting  = self.tbCalendarSetting[nId]
    local szOpenTime = tbSetting.szTimeFrameOpen
    if me.nLevel < tbSetting.nLevelMin then
        return string.format("%d级开放", tbSetting.nLevelMin)
    end

    if GetTimeFrameState(szOpenTime) == 1 then
        local tbOpenTime = self:GetTodayOpenTime(nId)
        if next(tbOpenTime) then
            local nOpenTime1, nCloseTime1 = unpack(tbOpenTime[1])
            local szTime = self:TimeToString(nOpenTime1, nCloseTime1)
            for _, tbInfo in ipairs(tbOpenTime) do
                local nOpenTime  = tbInfo[1]
                local nCloseTime = tbInfo[2]
                if nOpenTime > Lib:GetTodaySec() then
                    szTime = self:TimeToString(nOpenTime, nCloseTime)
                    break
                end
            end
            return szTime
        end

        local tbOpenDay = Calendar:GetWeekOpenDay(nId)
        local nOpenDayLen = #tbOpenDay
        local szWeek = nOpenDayLen > 3 and WEEK_NAME or ""
        for nIdx, nWeek in ipairs(tbOpenDay) do
            local bEnd = nIdx == nOpenDayLen
            if nOpenDayLen > 3 then
                szWeek = string.format("%s%s%s", szWeek, WEEK[nWeek], bEnd and "" or ",")
            elseif nOpenDayLen == 3 then
                szWeek = string.format("%s%s%s%s", szWeek, WEEK_NAME, WEEK[nWeek], bEnd and "" or "、")
            else
                szWeek = string.format("%s%s%s%s", szWeek, WEEK_NAME, WEEK[nWeek], bEnd and "开启" or "、")
            end
        end
        return szWeek
    end

    local tbTodayNextTime = self:GetTodayNextOpenTime(nId)
    if tbTodayNextTime then
        local szTime = self:TimeDesc(tbTodayNextTime[1])
        return string.format("%s开放", szTime)
    else
        local nRefDay = Lib:GetLocalDay(CalcTimeFrameOpenTime(szOpenTime)) - Lib:GetLocalDay()
        if nRefDay == 0 then
            local tbOpenDay  = Calendar:GetWeekOpenDay(nId)
            local nShowWeek  = tbOpenDay[1] or 1
            local nTodayWeek = Lib:GetLocalWeekDay()
            for _, nWeek in ipairs(tbOpenDay) do
                if nWeek > nTodayWeek then
                    nShowWeek = nWeek
                    break
                end
            end
            return string.format("%s%s开放", WEEK_NAME, WEEK[nShowWeek])
        end
        return string.format("%d天后开放", nRefDay)
    end
end

--活动显示附加条件
local tbAdditionalActive = {
    ["FactionMonkey"] = function ()
        return FactionBattle.FactionMonkey:IsMonkeyStarting()
    end,

    ["SeriesFuben"] = function()
        return not SeriesFuben:IsTaskFinish()
    end,

    ["CardCollection_1"] = function()
        return CollectionSystem:GetActivityState(CollectionSystem.RANDOMFUBEN_ID)
    end,

    ["FieldBoss"] = function ()
        local bCrossBoss = Player:GetServerSyncData("BossCrossServer");
        if bCrossBoss then
            return false;
        end

        return true;
    end,

    ["FieldCrossBoss"] = function ()
        local bCrossBoss = Player:GetServerSyncData("BossCrossServer");
        return bCrossBoss;
    end,

    ["HuaShanLunJian"] = function()
        return HuaShanLunJian:IsOpenPreGameUi();
    end,

    ["HuaShanLunJian1"] = function()
        return HuaShanLunJian:IsOpenFinalsGameUi();
    end,

    ["ImperialTomb"] = function()
        return not Calendar:IsActivityInOpenState("ImperialTombEmperor")
    end,

    ["FactionBattle"] = function()
        return FactionBattle:IsCanStart()
    end,
    ["WeekendQuestion"] = function()
        local tbData = Activity:GetUiSetting("WeekendQuestion"):GetData()
        if tbData and tbData.nEndTime and tbData.nEndTime ~= 0 and GetTime() < tbData.nEndTime then
            return true
        end
        return false
    end,
    ["IdiomsAct"] = function ()
        if IdiomFuben.nEndTime and IdiomFuben.nEndTime ~= 0 and GetTime() < IdiomFuben.nEndTime then
            return true
        end
        return false
    end,
    ["DefendAct"] = function ()
        if DefendFuben.nEndTime and DefendFuben.nEndTime ~= 0 and GetTime() < DefendFuben.nEndTime then
            return true
        end
        return false
    end,

    ["DaXueZhang"] = function ()
        return Activity:__IsActInProcessByType("DaXueZhang")
    end,

    ["TeamBattle"] = function ()
        --如果跨服攻城战开启(每月最后一周周日)则关闭通天塔
       return (not DomainBattle.tbCross:CheckCrossDay()) and not (KinEncounter:IsOpenToday() and Lib:GetLocalDayHour()<KinEncounter.Def.nOpenHour)
    end,

    ["CrossDomainBattle"] = function ()
        return DomainBattle.tbCross:CheckCrossWeek()
    end,

    ["KinEncounterAct"] = function()
        return Activity:__IsActInProcessByType("KinEncounterAct") and KinEncounter:IsOpenToday()
    end,

    ["KinFuben"] = function()
        return not (Activity:__IsActInProcessByType("KinEncounterAct") and KinEncounter:IsOpenToday())
    end,
    ["PartnerCardTask"] = function()
        return PartnerCard:IsOpen()
    end,
     ["LoverTask"] = function()
        return LoverTask:IsOpen()
    end,
}

function Calendar:IsAdditionalShowActivity(szKey)
    local fnActive = tbAdditionalActive[szKey]
    if fnActive then
        return fnActive()
    end

    return true
end

---------------------------------------红点相关---------------------------------------
-- 活动对应红点树的定义
local tbRedTreeDefine =
{
    ["Rank"] = "RankBattle";
    ["ImperialTomb"] = "ImperialTomb";
}
function Calendar:IsShowRedpoint(szKey)
    -- 红点树
    if tbRedTreeDefine[szKey] then
        return Ui:GetRedPointState(tbRedTreeDefine[szKey])
    end

    return false
end

------------------------------定时活动状态------------------------------
function Calendar:OnSyncActivityState(tbState)
    self.tbActivityState = tbState
    UiNotify.OnNotify(UiNotify.emNOTIFY_ONACTIVITY_STATE_CHANGE)
end

function Calendar:OnActivityStateChange(szKey, nState)
    self.tbActivityState = self.tbActivityState or {}
    self.tbActivityState[szKey] = nState
    UiNotify.OnNotify(UiNotify.emNOTIFY_ONACTIVITY_STATE_CHANGE)
end

function Calendar:IsActivityInOpenState(szKey)
    self.tbActivityState = self.tbActivityState or {}
    return self.tbActivityState[szKey] == 1
end

---------------------------------------------------
Calendar.OnClicked = {
    ["OpenUi"]   = function (...)
        Ui:OpenWindow(...)
        Ui:CloseWindow("CalendarPanel");
    end;

    ["DoCommerceTask"] = function ( ... )
        if not CommerceTask:IsDoingTask(me) then
            CommerceTask:AutoPathToTaskNpc();
        else
            Ui:OpenWindow("CommerceTaskPanel")
        end
        Ui:CloseWindow("CalendarPanel");
    end;

    ["DoZhenFaTask"] = function ()
        local nZhenFaTaskId = ZhenFaTask:GetZhenFaTask(me);
        if not nZhenFaTaskId then
            ZhenFaTask:AutoPathToTaskNpc();
        else
            Task:OnTrack(nZhenFaTaskId);
        end
        Ui:CloseWindow("CalendarPanel");
    end;

    ["AutoPath"] = function ( ... )
        local tbParams       = { ... };
        local nNpcTemplateId = tonumber(tbParams[1]);
        local nMapTemplateId = tonumber(tbParams[2]);
        local nPosX, nPosY   = AutoPath:GetNpcPos(nNpcTemplateId, nMapTemplateId);
        local fnCallback     = function ()
            local nNpcId = AutoAI.GetNpcIdByTemplateId(nNpcTemplateId);
            if nNpcId then
                Operation.SimpleTap(nNpcId);
            end
        end;
        AutoPath:GotoAndCall(nMapTemplateId, nPosX, nPosY, fnCallback);
        Ui:CloseWindow("CalendarPanel");
    end;


    ["OpenChuangGong"] = function ( ... )
        Ui:OpenWindow(Kin:HasKin() and "KinDetailPanel" or "SocialPanel")
    Ui:CloseWindow("CalendarPanel");
    end;


    ["OpenTip"] = function (param1)
        Ui:OpenWindow("ActivityTip", tonumber(param1));
    end;

    ["KinNest"] = function ( ... )
        RemoteServer.ActivityCalendarInterface();
        Ui:CloseWindow("CalendarPanel");
    end;

    ["BackToKinMap"] = function ()
        if Kin:HasKin() then
            Kin:GoKinMap()
        else
            me.CenterMsg("少侠还没有家族")
            Ui:OpenWindow("KinJoinPanel")
        end
        Ui:CloseWindow("CalendarPanel")
    end;
    ["GotoKinManager"] = function ()
        if not Kin:HasKin() then
            Ui:OpenWindow("KinJoinPanel")
        end

        Ui.HyperTextHandle:Handle("[url=npc:KinManager, 266,1004]");
        Ui:CloseWindow("CalendarPanel")
    end;
    ["ActivityQuestion"] = function ()
        ActivityQuestion:OnTrack()
        Ui:CloseWindow("CalendarPanel")
    end;

    ["JoinWTFuben"] = function ()
        Fuben.WhiteTigerFuben:Join()
        Ui:CloseWindow("CalendarPanel")
    end;
	
	--神之墓地-活动日历-左侧
	["BeichenActivityBB"] = function ()
		RemoteServer.BeichenBossHomeJoin()
        Ui:CloseWindow("CalendarPanel")
    end;

    ["JoinFactionBattle"] = function ()
        FactionBattle:Join()
        Ui:CloseWindow("CalendarPanel")
    end;

    ["JoinKinTrain"] = function ()
        AutoFight:StopAll();
        RemoteServer.TryJoinKinTrain()
        Ui:CloseWindow("CalendarPanel")
    end;

    ["JoinKinSecretFuben"] = function()
        AutoFight:StopAll()
        Ui:OpenWindow("KinSecretSelectPanel")
        Ui:CloseWindow("CalendarPanel")
    end;

    ["JoinKinDefendFuben"] = function()
        AutoFight:StopAll()
        Ui:OpenWindow("KinDefendPanel")
        Ui:CloseWindow("CalendarPanel")
    end;

    ["JoinKinEncounter"] = function()
        AutoFight:StopAll()
        Ui:OpenWindow("KinEncounterJoinPanel")
        Ui:CloseWindow("CalendarPanel")
    end;

    ["OpenPunishTask"] = function ()
        local tbActivitys = TeamMgr:GetActivityList()
        local tbLevel = {}
        for _, tbActivity in ipairs(tbActivitys or {}) do
            if tbActivity.szType == "PunishTask" then
                table.insert(tbLevel, tonumber(tbActivity.subtype))
            end
        end
        if not next(tbLevel) then
            tbLevel = {20, 40, 60, 80, 100} --当没开过组队页面时，是拿不到活动数据的，这里写一个默认值
        else
            table.sort(tbLevel)
        end
        local nEnterLevel = tbLevel[1]
        for i, nLevel in ipairs(tbLevel) do
            if nLevel > me.nLevel then
                break
            end

            nEnterLevel = nLevel
        end

        if me.nLevel >= nEnterLevel then
            Ui:OpenWindow("TeamPanel", "TeamActivity", "PunishTask", nEnterLevel)
        else
            me.CenterMsg("等级不足，无法进入")
        end
        Ui:CloseWindow("CalendarPanel")
    end;

    ["OpenKinMember"] = function ()
        if ChuangGong:CheckIsDegreeOutCanUseCGD(me) then
            local nItemTId = Item:GetClass("ChuangGongDan").nItemId
            local nHave, tbItem = me.GetItemCountInBags(nItemTId)
            if nHave > 0 then
                local pItem = tbItem and tbItem[1]
                Ui:OpenWindow("ItemBox")
                Ui:OpenWindow("ItemTips", "Item", pItem and pItem.dwId, nItemTId, me.nFaction);
            else
                Ui:OpenWindow("CommonShop", "Treasure", "tabAllShop", nItemTId)
            end
        else
            if Kin:HasKin() then
                Ui:OpenWindow("KinDetailPanel", "FamilyMembers")
            else
                me.CenterMsg("少侠还没有家族")
                Ui:OpenWindow("KinJoinPanel")
            end
        end
        Ui:CloseWindow("CalendarPanel")
    end;

    ["ImperialTomb"] = function ()
        if ImperialTomb:EnterTombRequest() then
            Ui:CloseWindow("CalendarPanel")
        end
    end;

    ["ImperialTombEmperor"] = function ()
        Ui:OpenWindow("ImperialTombPanel", false)
        Ui:CloseWindow("CalendarPanel")
    end;
    ["ImperialTombFemaleEmperor"] = function ()
        Ui:OpenWindow("ImperialTombPanel", true)
        Ui:CloseWindow("CalendarPanel")
    end;

    ["DefendsAct"] = function ()
        DefendFuben:GoNpc()
    end;
    ["GoToRandomFuben"] = function ()
        local tbInfo = Client:GetUserInfo("RandomFubenLevel", me.dwID);
        if tbInfo.nLevel then
            Ui:OpenWindow("TeamPanel", "TeamActivity", "RandomFuben", "RandomFuben_" .. tbInfo.nLevel);
        else
            Ui:OpenWindow("TeamPanel", "TeamActivity", "RandomFuben");
        end
    end,

    ["GotoMuse"]= function ()
        House:GotoMuse();
        Ui:CloseWindow("CalendarPanel");
    end,

    ["CangBaoTu"] = function()
        local tbItem = me.FindItemInBag(787)
        if next(tbItem) then
            Ui:OpenWindow("ItemBox")
            Ui:OpenWindow("ItemTips", "Item", tbItem[1].dwId)
        else
            me.CenterMsg("找了一圈，背包里似乎没有藏宝图")
        end
    end,

    ["JoinQYHCross"] = function ()
        if not Calendar:IsActivityInOpenState("QunYingHui") then
            me.SendBlackBoardMsg(XT("活动尚未开启"), true)
            return
        end
        Ui:OpenWindow("QYHNewEntrance");
        Ui:CloseWindow("CalendarPanel");
    end;
    ["PartnerCardTask"] = function ()
        if not House.bHasHouse then
            me.CenterMsg("您还没有家园", true)
            return
        end
        RemoteServer.PartnerCardOnClientCall("ActivityTask")
    end;
    ["LoverTask"] = function ()
        LoverTask:TrackTask()
        Ui:CloseWindow("CalendarPanel")
    end;

}

function Calendar:Dirt2Act(nID)
    local tbInfo = self.tbCalendarSetting[nID]
    if not tbInfo or Lib:IsEmptyStr(tbInfo.szFuncName) then
        return
    end

    local tbParams = Lib:SplitStr(tbInfo.szParams, "|")
    self.OnClicked[tbInfo.szFuncName](unpack(tbParams))
end

Calendar.tbExtAwardState = {
    Boss = function(self)
        return Boss:IsAuctionRewardOnSale()
    end,

    KinGather = function(self)
        return Kin:IsGatherExtraReward()
    end,

    DomainBattle = function ()
        return Activity:__IsActInProcessByType("DomainBattleAct")
    end,
}

function Calendar:GetExtAwardState(szKey)
    local fnState = self.tbExtAwardState[szKey]
    if fnState then
        return fnState(self)
    end
end

local tbSideTips =
{
    ["ImperialTomb"] = function (nID)
        Ui:ClearRedPointNotify("ImperialTomb_FullTime")
        return string.format(XT("剩余停留时间：\n%s"), Lib:TimeDesc8(ImperialTomb:GetStayTime(me)))
    end;
}

function Calendar:GetSideTipFunc(szKey)
    return tbSideTips[szKey]
end
local tbJoinBtnTxt =
{
    ["ChuanGong"] = function ()
        if ChuangGong:CheckIsDegreeOutCanUseCGD(me)then
            return "增加次数"
        end
    end;
}
function Calendar:GetJoinBtnTxt(szKey)
    local fnGetBtnTxt = tbJoinBtnTxt[szKey]
    return fnGetBtnTxt and fnGetBtnTxt()
end
