local tbUi     = Ui:CreateClass("CalendarPanel");
tbUi.DAILY     = 1;
tbUi.PRE       = 2;
tbUi.DAYTARGET = 3;
tbUi.WEEK      = 4;

tbUi.WEEK_OPEN_LEVEL = 20

local function InitButton()
    tbUi.tbOnClick =
    {
        BtnClose = function (self)
            Ui:CloseWindow(self.UI_NAME)
        end,

        BtnCheck = function (self)
            self:OpenCurActTip()
        end,
    }
    local tbBtnName = {"BtnDaily", "BtnPreview", "BtnDailyTarget", "BtnWeekCalendar"}
    for i = tbUi.DAILY, tbUi.WEEK do
        tbUi.tbOnClick[tbBtnName[i]] = function (self)
            self:ChangeTab(i)
        end
    end

    for i = 1, 5 do
        tbUi.tbOnClick["Box" .. i] = function (self)
            self:TryGainAward(i)
        end
    end
end
InitButton()

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_EVERYDAY_TARGET,   self.UpdateDailyTargetState, self },
        { UiNotify.emNOTIFY_ONACTIVITY_STATE_CHANGE,   self.OnActivityStateChange, self },
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData, self},
    };

    return tbRegEvent;
end

function tbUi:OnOpen(nTabIdx)
    if (nTabIdx == self.DAYTARGET and me.nLevel < Calendar.Def.OPEN_LEVEL) or (nTabIdx == self.WEEK and me.nLevel < self.WEEK_OPEN_LEVEL) then
        me.CenterMsg(string.format("%d级开启", nTabIdx == self.DAYTARGET and Calendar.Def.OPEN_LEVEL or self.WEEK_OPEN_LEVEL))
        return 0
    end

    local bRet = Map:IsForbidTransEnter(me.nMapTemplateId);
    if bRet then
        me.CenterMsg("当前地图无法打开", true);
        return 0;
    end

    if not self.bAsk4Team then --第一次开日历的时候请求下组队信息，避免打开组队时的bug
        TeamMgr:Ask4Activitys()
        self.bAsk4Team = true
    end

    self:RequestServerInfo();
end

function tbUi:RequestServerInfo()
    HuaShanLunJian:RequestHSLJStateInfo();
    Lib:CallBack({BossLeader.RequestHaveCrossServer, BossLeader})
end

function tbUi:OnSyncData(szType)
    if szType == "HSLJStateData" or szType == "BossCrossServer" then
        self:OnActivityStateChange();
    end
end

function tbUi:OnOpenEnd(nTabIdx, nOpenAct)
    self.nCurAct = nOpenAct
    self:ChangeTab(nTabIdx, nOpenAct)
    EverydayTarget:CheckDataVersion()
end

--bDir2Act 是否指定跳到某个活动
function tbUi:ChangeTab(nTabIdx, bDir2Act)
    if (nTabIdx == self.DAYTARGET and me.nLevel < Calendar.Def.OPEN_LEVEL) or (nTabIdx == self.WEEK and me.nLevel < self.WEEK_OPEN_LEVEL) then
        nTabIdx = self.nCurrentTab
    end

    self.nCurrentTab = nTabIdx or self.nCurrentTab or self.DAILY;
    self:Update(bDir2Act);
    if self.nCurrentTab ~= self.DAILY and self.nCurrentTab ~= self.PRE then
        self.pPanel:SetActive("ActivityTip", false)
    end
end

function tbUi:Update(bDir2Act)
    self.pPanel:SetActive("BtnDailyTarget", me.nLevel >= Calendar.Def.OPEN_LEVEL)
    self.pPanel:SetActive("BtnWeekCalendar", me.nLevel >= self.WEEK_OPEN_LEVEL)
    self.pPanel:SetActive("EverydayGroup", self.nCurrentTab == self.DAILY or self.nCurrentTab == self.PRE);
    self.pPanel:SetActive("DailyTargetGroup", self.nCurrentTab == self.DAYTARGET);
    self.pPanel:SetActive("WeekCalendarNew", me.nLevel >= self.WEEK_OPEN_LEVEL and self.nCurrentTab == self.WEEK)
    self.pPanel:SetActive("ActivityTipBg", self.nCurrentTab == self.PRE or self.nCurrentTab == self.DAILY)

    if self.nCurrentTab == self.WEEK then
        self:UpdateWeek()
        self:UpdatePreviewInfoTxt()
    elseif self.nCurrentTab == self.DAYTARGET then
        self:UpdateDailyTarget()
    else
        self:UpdateContent(bDir2Act);
    end

    self.pPanel:Toggle_SetChecked("BtnDaily", self.nCurrentTab == self.DAILY)
    self.pPanel:Toggle_SetChecked("BtnPreview", self.nCurrentTab == self.PRE)
    self.pPanel:Toggle_SetChecked("BtnDailyTarget", self.nCurrentTab == self.DAYTARGET)
    self.pPanel:Toggle_SetChecked("BtnWeekCalendar", self.nCurrentTab == self.WEEK)
end

function tbUi:UpdatePreviewInfoTxt()
    local tbPreViewInfo = Calendar:GetPreviewInfo()
    self.pPanel:Widget_SetSize("Txt1", 600, 22)
    self.pPanel:Label_SetText("Txt1", string.format("[92d2ff]当前等级上限：[-]%d级（已开放%d天）", tbPreViewInfo.nCurMaxLevel, tbPreViewInfo.nNowLevelOpenDay));
    self.pPanel:SetActive("Txt2", false)

    local nNextDayTime = 24 * 3600 * tbPreViewInfo.nNextOpenDay;
    if tbPreViewInfo.nWillOpenDay > 0 then
        self.pPanel:SetActive("Txt3", true)
        local tbTime = os.date("*t", nNextDayTime);
        self.pPanel:Label_SetText("Txt3", string.format("[92d2ff]距离开放%d级上限：[-]%d天后（%d月%d日 4:00）",
            tbPreViewInfo.nNextMaxLevel, tbPreViewInfo.nWillOpenDay, tbTime.month, tbTime.day));
    else
        self.pPanel:SetActive("Txt3", false);
    end
end

function tbUi:UpdateContent(bDir2Act)
    if self.nCurrentTab ~= self.DAILY and self.nCurrentTab ~= self.PRE then
        return
    end

    self.pPanel:Label_SetText("TypeDesc", self.nCurrentTab == self.DAILY and "每日限时活动" or "限时活动")

    if self.nCurrentTab == self.DAILY then
        self:UpdateDaily(bDir2Act)
    else
        self:UpdatePreview()
    end
end

function tbUi:OnActivityStateChange()
    if self.nCurrentTab == self.DAILY then
        self:UpdateDaily()
    end
end

function tbUi:UpdateDailyTarget()
    self:UpdateDailyTargetState()

    local nTotalValue = EverydayTarget:GetTotalActiveValue(me)
    for nIdx, nValue in ipairs(EverydayTarget.Def.tbActiveScale) do
        self.pPanel:SetActive("texiao_2" .. nIdx, false)
    end
end

function tbUi:UpdateDailyTargetState()
    local nTotalValue = EverydayTarget:GetTotalActiveValue(me)
    local nAwardIdx = 1
    for nIdx, nValue in ipairs(EverydayTarget.Def.tbActiveScale) do
        local bCanGain  = EverydayTarget:CheckGainAward(me, nIdx)
        local bComplete = nTotalValue >= nValue
        self.pPanel:SetActive("texiao_1" .. nIdx, bCanGain)

        local szGetText = bCanGain and "点击领取" or "已领取"
        self.pPanel:SetActive("Get" .. nIdx, bComplete)
        self.pPanel:Label_SetText("Get" .. nIdx, szGetText)

        if bComplete then
            nAwardIdx = nIdx
        end
    end
    self.pPanel:Label_SetText("ActiveValueNumber", string.format("%d", nTotalValue))
    self.pPanel:Sprite_SetFillPercent("Bar", nTotalValue / 100)

    self:UpdateDailyTargetList()
    self:UpdateTargetAward(nAwardIdx)
end

function tbUi:UpdateTargetAward(nIdx)
    local tbAward = {unpack(EverydayTarget.tbShowAward[nIdx] or {})}
    local tbExtAward = RegressionPrivilege:GetDayTargetAward(nIdx) or {}
    Lib:MergeTable(tbAward, tbExtAward)
    for i = 1, 5 do
        self.pPanel:SetActive("itemframe" .. i, tbAward[i] or false)
        if tbAward[i] then
            local tbGrid = self["itemframe" .. i]
            tbGrid:SetGenericItem(tbAward[i])
            tbGrid.fnClick = tbGrid.DefaultClick
        end
    end

    self.pPanel:Label_SetText("AwardTxt", EverydayTarget.Def.tbActiveScale[nIdx] .. "活跃奖励")
end

tbUi.tbTrack = {
    JumpToAct = function (self, szKey)
        local nId = Calendar:GetActivityId(szKey)
        if nId then
            self.nCurAct = nId
            self:ChangeTab(self.DAILY, true)
        end
    end;
    OpenWindow = function (self, szKey, ... )
        local nRet = Ui:OpenWindow( ... )
        if nRet and nRet == 1 then
            Ui:CloseWindow(self.UI_NAME)
        end
    end;
    OpenKinVaultPanel = function (self, szKey)
        if Kin:HasKin() then
            Ui:OpenWindow("KinVaultPanel")
        else
            me.CenterMsg("少侠还没有家族")
            Ui:OpenWindow("KinJoinPanel");
        end
        Ui:CloseWindow(self.UI_NAME)
    end;
}
function tbUi:UpdateDailyTargetList()
    local tbList = EverydayTarget:GetTargetList()
    local function fnInit(itemObj, nIdx)
        local tbTarget = tbList[nIdx]
        itemObj.pPanel:Label_SetText("ActivityName", tbTarget.szName)
        itemObj.pPanel:Label_SetText("ActivityTime", tbTarget.szTimes)
        itemObj.pPanel:Label_SetText("ActiveValueNumber", tbTarget.szValue)
        itemObj.pPanel:SetActive("BtnGo", not tbTarget.bComplete)
        if not tbTarget.bComplete then
            itemObj.tbOnClick = {
                BtnGo = function ()
                    local szTrack, tbParam = EverydayTarget:GetTrack(tbTarget.szKey)
                    self.tbTrack[szTrack](self, tbTarget.szKey,  unpack(tbParam))
                end
            }
            itemObj.pPanel:RegisterEvent(1, "BtnGo");
        end
    end
    self.ScrollViewActiveValue:Update(#tbList, fnInit)
end

function tbUi:TryGainAward(nIdx)
    if EverydayTarget:CheckGainAward(me, nIdx) then
        RemoteServer.TryGetDayTargetAward(nIdx)
        self.pPanel:SetActive("texiao_2" .. nIdx, false)
        self.pPanel:SetActive("texiao_2" .. nIdx, true)
        if nIdx == 1 then
            Guide.tbNotifyGuide:ClearNotifyGuide("EverydayTarget_First")
        end
    else
        self:UpdateTargetAward(nIdx)
    end

    if nIdx == 5 then
        Guide.tbNotifyGuide:ClearNotifyGuide("EverydayTarget_Preview")
    end
end

local tbCnWeek = {"周一", "周二", "周三", "周四", "周五", "周六", "周日"}
function tbUi:UpdateWeek()
    --每周新开活动
    local tbWeekAct = Calendar:GetWeekOpenAct()
    local nWeek = Lib:GetLocalWeekDay()
    local szTime = ""
    local szTodayName = tbCnWeek[nWeek] .. "·暂无"
    local tbWeek = {}
    for _, tbInfo in pairs(tbWeekAct) do
        tbWeek[tbInfo[4]] = tbInfo
    end
    for i = 1, 7 do
        local tbAct = tbWeek[i]
        if tbAct then
            local nWeekDay = tbAct[4]
            local szName = Calendar:GetActivityName(tbAct[1])
            self.pPanel:Label_SetText("Name" .. i, szName)
            self.pPanel:Label_SetText("Label" .. i, tbCnWeek[nWeekDay])

            if nWeek == nWeekDay then
                local szActTime = Calendar:TimeToString(tbAct[2], tbAct[3], true)
                szTime = szTime .. szActTime .. "\n"
                szTodayName = string.format("%s·%s", tbCnWeek[nWeek], szName)
            end
        else
            self.pPanel:Label_SetText("Name" .. i, "暂无")
            self.pPanel:Label_SetText("Label" .. i, tbCnWeek[i])
        end
    end

    local szDate = os.date("%Y/%m/%d", GetTime())
    self.pPanel:Label_SetText("DateTxt", szDate)
    self.pPanel:Label_SetText("NameTxt", szTodayName or "无")
    self.pPanel:Label_SetText("TimeTxt", szTime or "")

    self:UpdateWeekList()
end

function tbUi:UpdateWeekItem(itemObj)
    local tbAct = itemObj.tbActivity
    local tbOpenTime = Calendar:GetTodayOpenTime(tbAct.nId)
    local nCurTime = Lib:GetTodaySec()
    local szTime
    local szAllTime = ""
    local szStateSprite
    for _, tbInfo in ipairs(tbOpenTime) do
        local nOpenTime = tbInfo[1]
        local nCloseTime = tbInfo[2]
        local szSingleTime = Calendar:TimeToString(nOpenTime, nCloseTime)
        szAllTime = szAllTime .. "\n" .. szSingleTime
        if nCurTime >= nOpenTime and nCurTime <= nCloseTime and Calendar:IsActivityInOpenState(tbAct.szKey) then
            szStateSprite = "Mark_InProgress"
            szTime = szSingleTime
        end
        if (nCurTime >= nOpenTime - 60*60) and nCurTime < nOpenTime then
            szStateSprite = "Mark_SoonOpen"
        end
        if not szTime and nCurTime < nOpenTime then
            szTime = szSingleTime
        end
    end

    if not szTime then
        local tbFirst = tbOpenTime[1]
        szTime = Calendar:TimeToString(tbFirst[1], tbFirst[2])
    end

    local bSelected = (tbAct.nId == self.nCurWeekId)
    if bSelected then
        self.tbCurWeekItem = itemObj
    end

    local pPanel = itemObj.pPanel
    pPanel:SetActive("StateMark", szStateSprite and true or false)
    if szStateSprite then
        pPanel:Sprite_SetSprite("StateMark", szStateSprite)
    end
    pPanel:Label_SetText("Name", tbAct.szName)
    pPanel:Label_SetText("Time", bSelected and szAllTime or szTime)
    pPanel:Texture_SetTexture("Main", Calendar:GetWeekBg(tbAct.nId))

    pPanel:SetActive("Select", bSelected)

    pPanel.OnTouchEvent = function ()
        self:OnWeekItemSelected(itemObj)
    end
end

function tbUi:OnWeekItemSelected(itemObj)
    if self.nCurWeekId == itemObj.tbActivity.nId then
        return
    end
    local tbWeek = Calendar:GetWeekActivity()
    if #tbWeek < 0 then
        return
    end

    self.nCurWeekId = itemObj.tbActivity.nId
    self:UpdateWeekItem(self.tbCurWeekItem)
    self:UpdateWeekItem(itemObj)
end

function tbUi:UpdateWeekList()
    local tbWeek = Calendar:GetWeekActivity()
    if #tbWeek <= 0 then
        return
    end
    self.nCurWeekId = self.nCurWeekId or tbWeek[1].nId

    local fnSetItem = function (itemObj, nIdx)
        for i = 1, 2 do
            local tbAct = tbWeek[2*(nIdx-1) + i]
            local szItem = "Item" .. i
            itemObj.pPanel:SetActive(szItem, tbAct and true or false)

            if tbAct then
                itemObj[szItem].tbActivity = tbAct
                self:UpdateWeekItem(itemObj[szItem])
            end
        end
    end

    self.ScrollView:Update(math.ceil(#tbWeek/2), fnSetItem)
end

local fnJoin = function (buttonObj)
    Calendar:Dirt2Act(buttonObj.nCalendarId)
end

local fnOpenTip = function (nId, szTip)
    szTip = szTip or Calendar:GetTip(nId)
    if Lib:IsEmptyStr(szTip) then
        Ui:OpenWindow("ActivityTip", nId)
    else
        local tbParams = Lib:SplitStr(szTip, "|");
        Ui:OpenWindow(unpack(tbParams));
    end
end

-------------------------------------------------Daily-------------------------------------------------
function tbUi:UpdateDaily(bDir2Act)
    local tbNormal, tbTime = Calendar:GetDailyActivity()
    self.pPanel:SetActive("ActivityTip", #tbNormal > 0 or #tbTime > 0)
    self.pPanel:SetActive("NoActivity", #tbNormal == 0 and #tbTime == 0)
    self.pPanel:SetActive("SV_Bg", #tbNormal > 0 or #tbTime > 0)
    self.pPanel:SetActive("SV_Daily", #tbNormal > 0)
    self.pPanel:SetActive("SV_TimeLimit", #tbTime > 0)
    if not next(tbNormal) and not next(tbTime) then
        return
    end

    if not self.nCurAct then
        if tbNormal[1] then
            self.nCurAct = tbNormal[1].nId
        else
            self.nCurAct = tbTime[1].nId
        end
    end
    self:UpdateActDetail(self.nCurAct, true)

    local nSVItemIdx = 0
    local nItemNum = 3
    for i, tbInfo in ipairs(tbNormal) do
        if tbInfo.nId == self.nCurAct then
            nSVItemIdx = math.floor((i-1)/3) + 1
        end
    end
    local fnSetItem = function (itemObj, nIndex)
        for i = 1, nItemNum do
            local nIdx = (nIndex - 1)*nItemNum + i
            local tbAct = tbNormal[nIdx]
            local szItem = "Item" .. i
            if tbAct then
                itemObj.pPanel:SetActive(szItem, true)

                local child = itemObj[szItem]
                if tbAct.nId == self.nCurAct then
                    self.tbCurDailyItem = child
                end
                child.tbActivity = tbAct
                child.pPanel.OnTouchEvent = function ()
                    self:UpdateNormalItem(child)
                    Guide.tbNotifyGuide:ClearNotifyGuide(tbAct.szKey)
                end
                child:Init(tbAct)
                child.pPanel:SetActive("Select", tbAct.nId == self.nCurAct)
            else
                itemObj.pPanel:SetActive(szItem, false)
            end
        end
    end

    self.SV_Daily:Update(math.ceil(#tbNormal/3), fnSetItem)
    if bDir2Act and nSVItemIdx > 0 then
        self.SV_Daily.pPanel:ScrollViewGoToIndex("Main", nSVItemIdx);
    end

    local nTimeIdx = 0
    for i, tbInfo in ipairs(tbTime) do
        if tbInfo.nId == self.nCurAct then
            nTimeIdx = i
            break
        end
    end
    local fnSetTimeItem = function (itemObj, nIdx)
        local tbAct = tbTime[nIdx]
        itemObj.tbActivity = tbAct
        if tbAct.nId == self.nCurAct then
            self.tbCurDailyItem = itemObj
        end
        itemObj.pPanel.OnTouchEvent = function ()
            self:UpdateNormalItem(itemObj)
            Guide.tbNotifyGuide:ClearNotifyGuide(tbAct.szKey)
        end
        itemObj:Init(tbAct)
        itemObj.pPanel:SetActive("Select", tbAct.nId == self.nCurAct)
    end
    self.SV_TimeLimit:Update(#tbTime, fnSetTimeItem)
    if bDir2Act and nTimeIdx > 0 then
        self.SV_TimeLimit.pPanel:ScrollViewGoToIndex("Main", nTimeIdx);
    end
end

local function UpdateActDetail(self, nActivityID)
    local szTime, szType, szDesc, szHelpKey = Calendar:GetActivityDetail(nActivityID);
    if not szTime or not szType or not szDesc or not szHelpKey then
        Log("[ActivityTip OnOpen] Error, Not Found This Activity's Tip >>>>", nActivityID)
        return 0
    end

    if szHelpKey and szHelpKey ~= "" then
        self.pPanel:SetActive("BtnInfo", true)
        self.pPanel:ResetGeneralHelp("BtnInfo", szHelpKey)
    else
        self.pPanel:SetActive("BtnInfo", false)
    end

    local nActiveValue = 0;
    local szKey = Calendar:GetActivityStringKey(nActivityID);
    if szKey then
        local nTodayLevel = EverydayTarget:GetTodayLevel(me, szKey)
        if nTodayLevel then
            local _, nValue = EverydayTarget:GetCountAndValue(nTodayLevel, szKey)
            nActiveValue = nValue
        end
    end
    local nLevelLimit = Calendar:GetActivityLevelMin(nActivityID);
    local szLimit = "无";
    if nLevelLimit and nLevelLimit ~= 0 then
        szLimit = string.format("达到%d级", nLevelLimit);
    end

    szDesc = string.gsub(szDesc, "\\n", "\n");
    self.pPanel:Label_SetText("Description", szDesc);

    local tbRewards = Calendar:GetActivityReward(nActivityID);
    for i = 1, 10 do
        local tbReward = tbRewards[i];
        self.pPanel:SetActive("aitemframe"..i, tbReward ~= nil);
        if tbReward then
            self["aitemframe" .. i]:SetGenericItem(tbReward)
            self["aitemframe"..i].fnClick = self["aitemframe"..i].DefaultClick
        end
    end
end

function tbUi:UpdateActDetail(nActivityID)
    UpdateActDetail(self, nActivityID)

    local szTip = Calendar:GetTip(nActivityID)
    self.pPanel:SetActive("BtnCheck", not Lib:IsEmptyStr(szTip) and self.nCurrentTab == self.DAILY)
end

function tbUi:OpenCurActTip()
    fnOpenTip(self.nCurAct)
end

function tbUi:UpdateNormalItem(itemObj, bPreview)
    local nSelectId = itemObj.tbActivity.nId
    if bPreview then
        self.nCurPreviewAct = nSelectId
        self.tbCurPreviewItem.pPanel:SetActive("Select", false)
        if self.tbCurPreviewItem.pPanel:CheckHasChildren("RemainingTime") then
            self.tbCurPreviewItem.pPanel:SetActive("RemainingTime", false)
        end
        self.tbCurPreviewItem = itemObj

    else
        self.nCurAct = nSelectId
        self.tbCurDailyItem.pPanel:SetActive("Select", false)
        if self.tbCurDailyItem.pPanel:CheckHasChildren("RemainingTime") then
            self.tbCurDailyItem.pPanel:SetActive("RemainingTime", false)
        end
        self.tbCurDailyItem = itemObj
    end

    itemObj.pPanel:SetActive("Select", true)
    self:UpdateActDetail(nSelectId)
end

function tbUi:UpdatePreview()
    local tbNormal, tbTime = Calendar:GetPreviewActivity()
    self.pPanel:SetActive("ActivityTip", #tbNormal > 0 or #tbTime > 0)
    self.pPanel:SetActive("NoActivity", #tbNormal == 0 and #tbTime == 0)
    self.pPanel:SetActive("SV_Bg", #tbNormal > 0 or #tbTime > 0)
    self.pPanel:SetActive("SV_Daily", #tbNormal > 0)
    self.pPanel:SetActive("SV_TimeLimit", #tbTime > 0)

    if not next(tbNormal) and not next(tbTime) then
        return
    end
    if not self.nCurPreviewAct then
        self.nCurPreviewAct = (tbNormal[1] or {}).nId or (tbTime[1] or {}).nId
    end

    self:UpdateActDetail(self.nCurPreviewAct, true)

    local nItemNum = 3
    local fnSetItem = function (itemObj, nIndex)
        for i = 1, nItemNum do
            local nIdx = (nIndex - 1)*nItemNum + i
            local tbAct = tbNormal[nIdx]
            local szItem = "Item" .. i
            if tbAct then
                itemObj.pPanel:SetActive(szItem, true)

                local child = itemObj[szItem]
                child.tbActivity = tbAct
                if tbAct.nId == self.nCurPreviewAct then
                    self.tbCurPreviewItem = child
                end
                child.pPanel.OnTouchEvent = function ()
                    self:UpdateNormalItem(child, true)
                    Guide.tbNotifyGuide:ClearNotifyGuide(tbAct.szKey)
                end
                child:Init(tbAct, true)
                child.pPanel:SetActive("Select", self.nCurPreviewAct == tbAct.nId)
            else
                itemObj.pPanel:SetActive(szItem, false)
            end
        end
    end

    self.SV_Daily:Update(math.ceil(#tbNormal/3), fnSetItem)
    local fnSetTimeItem = function (itemObj, nIdx)
        local tbAct = tbTime[nIdx]
        itemObj.tbActivity = tbAct
        if tbAct.nId == self.nCurPreviewAct then
            self.tbCurPreviewItem = itemObj
        end
        itemObj.pPanel.OnTouchEvent = function ()
            self:UpdateNormalItem(itemObj, true)
            Guide.tbNotifyGuide:ClearNotifyGuide(tbAct.szKey)
        end
        itemObj:Init(tbAct, true)
        itemObj.pPanel:SetActive("Select", tbAct.nId == self.nCurAct)
    end
    self.SV_TimeLimit:Update(#tbTime, fnSetTimeItem)
end

--------------------------------------Activity Tip--------------------------------------
local ActivityTip = Ui:CreateClass("ActivityTip")
function ActivityTip:OnOpenEnd(nActivityID)
    UpdateActDetail(self, nActivityID)
end

function ActivityTip:OnScreenClick()
    Ui:CloseWindow(self.UI_NAME);
end

ActivityTip.tbOnClick = ActivityTip.tbOnClick or {};
ActivityTip.tbOnClick.BtnBg = function (self)
    Ui:CloseWindow(self.UI_NAME);
end

-----------------------------------NormalItem-----------------------------------
local function fnRegisterRedpoint(pPanel, szNodeName, szKey)
    local szNgKey = "NG_" .. szKey
    Ui.UnRegisterRedPoint(szNgKey)
    pPanel:RegisterRedPoint(szNodeName, szNgKey)
end

local tbItem = Ui:CreateClass("CalendarNormal")
function tbItem:Init(tbData, bPreview)
    self.pPanel:Sprite_SetSprite("Icon", tbData.szIcon, tbData.szIconAtlas)
    self.pPanel:Label_SetText("Name", tbData.szName)
    self.pPanel:Sprite_SetSprite("Mark", tbData.szTag)

    local szDegree = Calendar:GetDegreeInfo(tbData.nId)
    self.pPanel:Label_SetText("Degree", szDegree)

    local bComplete = Calendar:IsComplete(tbData.nId)
    self.pPanel:SetActive("Completed", not bPreview and bComplete)
    if bComplete then
        self.pPanel:Label_SetText("Completed", Calendar:GetCompleteText(tbData.nId))
    end

    self.pPanel:SetActive("BtnJoin", not bPreview and not bComplete)
    self.BtnJoin.pPanel:Label_SetText("Label", Calendar:GetJoinBtnTxt(tbData.szKey) or "参加")
    if not bComplete and not bPreview then
        self.BtnJoin.pPanel.OnTouchEvent = fnJoin
        self.BtnJoin.nCalendarId = tbData.nId

        local bRedpoint = Calendar:IsShowRedpoint(tbData.szKey)
        self.BtnJoin.pPanel:SetActive("Redmark", bRedpoint)
    end

    self.pPanel:SetActive("Time", bPreview or false)
    if bPreview then
        local szTime = Calendar:GetNotTimeLimitPreviewDesc(tbData.nId)
        self.pPanel:Label_SetText("Time", szTime or "")
    end

    self.pPanel:SetActive("GuideTips", not bPreview)
    if not bPreview then
        fnRegisterRedpoint(self.pPanel, "GuideTips", tbData.szKey)
    end
end

-----------------------------------TimeLimit-----------------------------------
local tbTime = Ui:CreateClass("CalendarTime")

function tbTime:GetActProcessMark(nId)
    local szKey = Calendar:GetActivityStringKey(nId)
    if Calendar:IsActivityInOpenState(szKey) then
        return "Mark_InProgress"
    end

    local tbOpenTime = Calendar:GetTodayOpenTime(nId)
    if not next(tbOpenTime) then
        return
    end

    local nCurTime = Lib:GetTodaySec()
    for _, tbInfo in ipairs(tbOpenTime) do
        local nOpenTime  = tbInfo[1]
        if (nCurTime >= (nOpenTime - 60*60)) and nCurTime < nOpenTime then
            return "Mark_SoonOpen"
        end
    end
end

function tbTime:Init(tbData, bPreview)
    self.pPanel:Sprite_SetSprite("Icon", tbData.szIcon, tbData.szIconAtlas);
    self.pPanel:Label_SetText("Name", Calendar:GetActivityName(tbData.nId))
    self.pPanel:Sprite_SetSprite("Mark", tbData.szTag)

    local bComplete = Calendar:IsComplete(tbData.nId)
    local bOpen     = Calendar:IsActivityInOpenState(tbData.szKey)
    self.pPanel:SetActive("BtnJoin", bOpen and not bComplete and not bPreview)
    if bOpen and not bComplete and not bPreview then
        self.BtnJoin.pPanel.OnTouchEvent = fnJoin;
        self.BtnJoin.nCalendarId = tbData.nId
        self.pPanel:SetActive("Time", false)
    else
        local szTime = Calendar:GetTimeLimitActDesc(tbData.nId)
        self.pPanel:SetActive("Time", true)
        self.pPanel:Label_SetText("Time", szTime)
    end

    local szStateSprite = self:GetActProcessMark(tbData.nId)
    self.pPanel:SetActive("Mark_State", not bComplete and not bPreview and szStateSprite)
    self.pPanel:SetActive("End", bComplete and not bPreview and not bOpen)
    if szStateSprite then
        self.pPanel:Sprite_SetSprite("Mark_State", szStateSprite)
    end

    if bPreview then
        self.pPanel:SetActive("GuideTips", false)
    else
        fnRegisterRedpoint(self.pPanel, "GuideTips", tbData.szKey)
    end

    local bShowExtraReward = Calendar:GetExtAwardState(tbData.szKey)
    self.pPanel:SetActive("RewardPlus", bShowExtraReward or false)
    self:UpdateSideTip(tbData, bPreview)
end

function tbTime:UpdateSideTip(tbData, bPreview)
    local fnSideTips = Calendar:GetSideTipFunc(tbData.szKey)
    if not bPreview and fnSideTips then
        self.pPanel:SetActive("BtnGo", true)
        self.BtnGo.pPanel.OnTouchEvent = function ()

            if self.pPanel:IsActive("RemainingTime") then
                self.pPanel:SetActive("RemainingTime", false)
            else
                local szSideTips = fnSideTips(tbData.nId)
                if szSideTips then
                    self.pPanel:SetActive("RemainingTime", true)
                    self.pPanel:Label_SetText("RemainingTime", szSideTips)
                end
            end

            self.BtnGo.pPanel:SetActive("BookedUp", false)
        end

        local bRedpoint = Calendar:IsShowRedpoint(tbData.szKey)
        self.BtnGo.pPanel:SetActive("BookedUp", bRedpoint)

    else
        self.pPanel:SetActive("BtnGo", false)
    end

    self.pPanel:SetActive("RemainingTime", false)
end