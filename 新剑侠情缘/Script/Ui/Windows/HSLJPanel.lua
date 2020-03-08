
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef = HuaShanLunJian.tbDef;
local tbUi = Ui:CreateClass("HSLJPanel");
tbUi.tbOnClick = {};
tbUi.nActivityID = 35; --活动的ID

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("HSLJPanel");
end

function tbUi.tbOnClick:BtnTip()
    Ui:OnHelpClicked("HuaShanLunJianHelp");
end

function tbUi.tbOnClick:BtnTeamRelated()
    Ui:OpenWindow("TeamRelatedPanel");
end

function tbUi.tbOnClick:BtnBattlefield()
    Ui:OpenWindow("HSLJBattlefieldPanel");
end

function tbUi.tbOnClick:BtnRank()
    Ui:OpenWindow("RankBoardPanel", tbDef.szRankBoard);
end

function tbUi.tbOnClick:BtnJoin()
    RemoteServer.DoRequesHSLJ("ApplyPlayGame");
end

function tbUi:OnOpen()
    RemoteServer.DoRequesHSLJ("RequestFightTeam");
    RemoteServer.DoRequesHSLJ("RequestStateData");
    self.pPanel:SetActive("PreparationTime", false)
    RemoteServer.DoRequesHSLJ("RequestReadyMapTime")

    self:UpdateInfo();
end

function tbUi:OnClose(  )
    if self.nTimerReady then
        Timer:Close(self.nTimerReady)
        self.nTimerReady = nil
    end
end

function tbUi:UpdateInfo()
    self:UpdateFightTeamInfo();

    local tbRewards = Calendar:GetActivityReward(tbUi.nActivityID);
    for nI = 1, 5 do
        local tbReward = tbRewards[nI];
        self.pPanel:SetActive("itemframe"..nI, tbReward ~= nil);
        if tbReward then
            self["itemframe" .. nI]:SetGenericItem(tbReward)
            self["itemframe"..nI].fnClick = self["itemframe"..nI].DefaultClick
        end
    end

    self.pPanel:SetActive("BtnBattlefield",  HuaShanLunJian:IsFinalsPlayGamePeriod());
end

function tbUi:UpdateFightTeamInfo()
    local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
    local tbTeamInfo = Player:GetServerSyncData("HSLJFightTeamInfo");
    if tbTeamInfo and tbTeamInfo.szName then
        self.pPanel:SetActive("TeamTime", true);
        self.pPanel:SetActive("WinningProbability", true);
        self.pPanel:Label_SetText("TeamTitle1", "战队名字：");
        self.pPanel:Label_SetText("TeamName", tbTeamInfo.szName or "-");

        local nWeekDay = tbStateData.nWeekDay or Lib:GetLocalWeek();
        local nMaxCount = HuaShanLunJian:GetPreGameJoinCount(nWeekDay);
        local szExtInfo = string.format("(最大%s场)", tbDef.tbPrepareGame.nMaxPlayerJoinCount);
        if nMaxCount == tbDef.tbPrepareGame.nMaxPlayerJoinCount then
            szExtInfo = "";
        end
        self.pPanel:Label_SetText("TeamTime", string.format("%s/%s" .. szExtInfo, (tbTeamInfo.nJoinCount or 0), nMaxCount));

        local nPro = math.floor(tbDef.tbPrepareGame.nDefWinPercent * 100);
        if tbTeamInfo.nJoinCount and tbTeamInfo.nWinCount and tbTeamInfo.nJoinCount > 0 then
            nPro = math.floor(tbTeamInfo.nWinCount / tbTeamInfo.nJoinCount * 100);
        end    
        self.pPanel:Label_SetText("WinningProbability", string.format("%s%%", nPro));
        local nPerCount = tbTeamInfo.nPerCount or 0;
        self.pPanel:Label_SetText("RemainTime", string.format("%s/%s", tbDef.tbPrepareGame.nPerDayJoinCount - nPerCount, tbDef.tbPrepareGame.nPerDayJoinCount));
    else
        self.pPanel:Label_SetText("TeamTitle1", "请创建战队");
        self.pPanel:Label_SetText("TeamName", " ");
        self.pPanel:SetActive("TeamTime", false);
        self.pPanel:SetActive("WinningProbability", false);
    end

    local tbGameFormat = tbDef.tbGameFormat[1];
    if tbStateData.nGameFormatType and tbDef.tbGameFormat[tbStateData.nGameFormatType] then
        tbGameFormat = tbDef.tbGameFormat[tbStateData.nGameFormatType];
    end

    local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
    if tbStateData and tbStateData.nPlayState == tbDef.nPlayStatePrepare then
        self.pPanel:SetActive("GuessingMark", true);
    else
        self.pPanel:SetActive("GuessingMark", false);
    end    
    
    self.pPanel:Label_SetText("GameType", tbGameFormat.szName or "-");
    self.pPanel:Label_SetText("TipTxtDesc", tbGameFormat.szHSLJPanelContent or "-");

    if HuaShanLunJian:IsOpenFinalsGameUi() then
        if tbTeamInfo and tbTeamInfo.nFinals == 1 then
            self.pPanel:Label_SetText("LbJoin", "参加比赛");   
        else
            self.pPanel:Label_SetText("LbJoin", "观战");    
        end
        self.pPanel:SetActive("RemainTime", false);    
    else
        self.pPanel:SetActive("RemainTime", true);
        self.pPanel:Label_SetText("LbJoin", "参加比赛");     
    end    
end

function tbUi:OnSyncData(szType)
    if szType == "HSLJFightTeamInfo" or szType == "HSLJStateData" then
        self:UpdateFightTeamInfo();
    elseif szType == "HSLJCreateFightTeam" then
        self:CloseFightTeamUI();
    elseif szType == "HSLJJoinFightTeam" then
        self:CloseFightTeamUI();       
    elseif szType == "HSLJQuitFightTeam" then 
        self:CloseFightTeamUI();
    elseif szType == "HSLJReadyMapLeftTime" then
        self:UpdateLeftTime()
    end    
end

function tbUi:UpdateLeftTime()
    if self.nTimerReady then
        Timer:Close(self.nTimerReady)
    end
    local nBattelReadyMapTime = Player:GetServerSyncData("HSLJReadyMapLeftTime")
    nBattelReadyMapTime = nBattelReadyMapTime + 1;
    self.pPanel:SetActive("PreparationTime", true)
    local fnUpdate = function ( )
        nBattelReadyMapTime = nBattelReadyMapTime - 1
        if nBattelReadyMapTime < 0 then
            self.nTimerReady = nil;
            return 
        end
        self.pPanel:Label_SetText("PreparationTime", string.format("本场准备时间：[FFFE0D]%s[-]", Lib:TimeDesc(nBattelReadyMapTime)))
        return true
    end
    fnUpdate()
    self.nTimerReady = Timer:Register(Env.GAME_FPS * 1, fnUpdate)
end

function tbUi:CloseFightTeamUI()
    if Ui:WindowVisible("TeamRelatedPanel") == 1 then
        Ui:CloseWindow("TeamRelatedPanel");
    end
    
    if Ui:WindowVisible("CreateTeamPanel") == 1 then
        Ui:CloseWindow("CreateTeamPanel");
    end    
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow("HSLJPanel");
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end


function HuaShanLunJian:IsOpenHSLJUi()
    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return false;
    end

    local tbStateData = Player:GetServerSyncData("HSLJStateData");
    if not tbStateData then
        return false;
    end

    local nMonth = Lib:GetLocalMonth();
    if nMonth ~= tbStateData.nGameMonth then
        return false;
    end

    return true;    
end


function HuaShanLunJian:IsOpenPreGameUi()
    local bRet = self:IsOpenHSLJUi();
    if not bRet then
        return false;
    end

    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay < tbDef.tbPrepareGame.nStartMonthDay or nMonthDay > tbDef.tbPrepareGame.nEndMothDay then
        return false;
    end

    return true;
end

function HuaShanLunJian:IsOpenFinalsGameUi()
    local bRet = self:IsOpenHSLJUi();
    if not bRet then
        return false;
    end

    local nMonthDay = Lib:GetMonthDay();
    if nMonthDay ~= tbDef.tbFinalsGame.nMonthDay then
        return false;
    end

    return true;
end


function HuaShanLunJian:RequestHSLJStateInfo(bForce)
    if GetTimeFrameState(tbDef.szOpenTimeFrame) ~= 1 then
        return;
    end

    self.nRequestTime = self.nRequestTime or 0;
    local nCurTime = GetTime();
    local bRet = self:IsOpenPreGameUi();
    if (nCurTime - self.nRequestTime > 60 * 3 and not bRet) or bForce then
        self.nRequestTime = GetTime();
        RemoteServer.DoRequesHSLJ("RequestStateData");
    end    
end

function HuaShanLunJian:GetHSLJGuessingTeamID()
    local tbSyncData = Player:GetServerSyncData("HSLJGuessingData") or {};
    local nFightTeam = tbSyncData.nFightTeamID or 0;
    return nFightTeam;
end

function HuaShanLunJian:GetHSLJFinalsWatchTeam()
    local tbSyncData = Player:GetServerSyncData("HSLJTeamWatchData");
    if not tbSyncData then
        return;
    end

    local tbShowData = {};
    tbShowData.nCurWatchId = 0;
    tbShowData.szType = "HSLJTeam";
    tbShowData.tbPlayer = {};
    tbShowData.nShowMatch = 1;


    for _, tbAllTeam in ipairs(tbSyncData) do
        for nI, tbInfo in ipairs(tbAllTeam) do
           tbShowData.tbPlayer[nI] = tbShowData.tbPlayer[nI] or {}; 
           local tbTeamInfo = {};
           tbTeamInfo.name = tbInfo.szName;
           tbTeamInfo.id = tbInfo.nId;
           table.insert(tbShowData.tbPlayer[nI], tbTeamInfo);
        end    
    end

    return tbShowData;    
end

function HuaShanLunJian:GetHSLJWatchPlayerData(nFightTeamID)
    local tbSyncData = Player:GetServerSyncData(string.format("HSLJWatchPlayer:%s", nFightTeamID));
    local tbShowData = {};
    tbShowData.nCurWatchId = 0;
    tbShowData.szType = "HSLJPlayer";
    tbShowData.tbPlayer = {};
    tbShowData.nShowMatch = 1;
    tbShowData.tbPlayer[1] = {};
    if not tbSyncData then
        return tbShowData;
    end

    local tbAllPlayer = {};
    for nPlayerID, szName in pairs(tbSyncData) do
        local tbInfo = {};
        tbInfo.name = szName;
        tbInfo.id = nPlayerID;
        table.insert(tbAllPlayer, tbInfo);
    end

    table.sort(tbAllPlayer, function (a, b)
        return a.id < b.id;
    end);

    for nI, tbInfo in pairs(tbAllPlayer) do
        local nIndex = (nI - 1) % 2 + 1;
        tbShowData.tbPlayer[nIndex] = tbShowData.tbPlayer[nIndex] or {};
        table.insert(tbShowData.tbPlayer[nIndex], tbInfo); 
    end

    return tbShowData;    
end    

--特定时间下活动是否开启了
function HuaShanLunJian:IsOpenGameInTime(nTime)
    nTime = nTime or GetTime()
    local nTFOpenTime = CalcTimeFrameOpenTime(tbDef.szOpenTimeFrame)
    local nMonthDay = Lib:GetMonthDay(nTime)
    if nTFOpenTime > nTime or nMonthDay < tbDef.tbPrepareGame.nStartMonthDay or nMonthDay > tbDef.tbFinalsGame.nMonthDay then
        return false
    else
        if nMonthDay <= tbDef.tbPrepareGame.nStartEndMonthDay then
            return true
        end

        local nTFOpenMonth = Lib:GetLocalMonth(nTFOpenTime)
        local nMonth = Lib:GetLocalMonth(nTime)
        if nMonth == nTFOpenMonth then
            local nTFMonthDay = Lib:GetMonthDay(nTFOpenTime)
            return nTFMonthDay <= tbDef.tbPrepareGame.nStartEndMonthDay
        end
        return nMonth > nTFOpenMonth
    end
end