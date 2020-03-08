
Require("CommonScript/BossLeader/BossLeader.lua");
local tbUi = Ui:CreateClass("BossLeaderPanel");
BossLeader.tbSyncData = BossLeader.tbSyncData or {};
tbUi.tbActivityID =
{
    ["Boss"] = 12;
    ["Leader"] = 13;
};

tbUi.tbTitleName =
{
    ["Boss"] = "历代名将";
    ["Leader"] = "野外首领";
}

tbUi.tbOnClick = {};
tbUi.tbOnDrag =
{
    PartnerView = function (self, szWnd, nX, nY)
        self.pPanel:NpcView_ChangeDir("PartnerView", -nX, true)
    end,
}

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi.tbOnClick:BtnGo()
    if not self.nSelectIndex then
        return;
    end

    local tbInfo = self.tbCurListItem[self.nSelectIndex];
    if not tbInfo then
        return;
    end

    local nMapType = Map:GetMapType(tbInfo.nMapTID);
    if nMapType == Map.emMap_Fuben then
        RemoteServer.BossLeaderEnterFuben(self.szType, tbInfo.nMapTID);
        Ui:CloseWindow(self.UI_NAME);
    else
        Map:SwitchMap(tbInfo.nMapTID);
        Ui:CloseWindow(self.UI_NAME);
    end
    AutoFight:StopAll();
end

function tbUi:OnOpen(szType)
    self.szType = szType;
    self.nCalendarID = self.tbActivityID[szType];

    local tbMapNpcGroup = BossLeader:GetTimeFrameNpcGroup(self.szType);
    if not tbMapNpcGroup then
        me.CenterMsg("尚未开启");
        return 0;
    end

    Timer:Register(Env.GAME_FPS, function ()
        if BossLeader:IsBossLeaderMap(me.nMapTemplateId, "Boss") then
            Ui:CloseWindow("BossLeaderPanel");
        end
    end)

    self.pPanel:Label_SetText("TitleType", self.tbTitleName[self.szType]);
    self.pPanel:NpcView_Open("PartnerView");
    self.pPanel:NpcView_ShowNpc("PartnerView", 0);
    self.pPanel:NpcView_SetScale("PartnerView", 0.95);
    self:RequestData();
    if szType == "Boss" then
        BossLeader:RequestHaveCrossServer();
    end    
    self:UpdateAllInfo();
end

function BossLeader:RequestHaveCrossServer()
    local tbMapNpcGroup = self:GetCrossTimeFrameNpcGroup("Boss");
    if not tbMapNpcGroup then
        return;
    end

    self.nRequestCrossTime = self.nRequestCrossTime or 0;
    if GetTime() - self.nRequestCrossTime > 30 then
        RemoteServer.RequestHaveCrossServer();
        self.nRequestCrossTime = GetTime();
    end
end

function tbUi:UpdateAllInfo()
    local bCrossBoss = Player:GetServerSyncData("BossCrossServer");
    local tbMapNpcGroup = nil;
    if not bCrossBoss or self.szType ~= "Boss" then
        tbMapNpcGroup = BossLeader:GetTimeFrameNpcGroup(self.szType);
        self.pPanel:SetActive("Mark", false);
    else
        tbMapNpcGroup = BossLeader:GetCrossTimeFrameNpcGroup("Boss");
        self.pPanel:SetActive("Mark", true);
    end 

    self.tbCurListItem = self:GetOrgShowInfo(tbMapNpcGroup);
    self:UpdateListLeft(self.tbCurListItem);
end

function tbUi:OnClose()
    self.pPanel:NpcView_ShowNpc("PartnerView", 0);
    self.pPanel:NpcView_Close("PartnerView");
end

function tbUi:GetOrgShowInfo(tbMapNpcGroup)
    local tbListItem = {};
    local bSortNum = false;
    local tbLinkGroup = {};

    for _, tbAllMapInfo in pairs(tbMapNpcGroup) do
        for _, tbInfo in pairs(tbAllMapInfo) do
            local nGroupID  = tbInfo.tbGroupNpc[1].nNpcGroupID;
            local tbGropNpc = BossLeader:GetGroupNpc(nGroupID);
            local tbNpcInfo = tbGropNpc.tbRateNpc[1];
            local nNpcTID   = tbNpcInfo.NpcID;
            local tbSubInfo     = {};
            tbSubInfo.nNpcTID   = nNpcTID;
            tbSubInfo.nMapTID    = tbInfo.nMapTID;
            tbSubInfo.nNpcCount = tbInfo.nNpcRateCount * tbInfo.nNpcGroupRateCount;
            tbSubInfo.nNpcLevel = tbNpcInfo.NpcLevel;
            tbSubInfo.nSortNum  = tbInfo.nSortNum;
            tbSubInfo.tbAllNpcTID = {};
            tbSubInfo.nLinkMapID = tbInfo.nLinkMapID;

            for _, tbGropInfo in pairs(tbInfo.tbGroupNpc) do
                local tbAllNpc = BossLeader:GetGroupNpc(tbGropInfo.nNpcGroupID);
                for _, tbRateNpcInfo in pairs(tbAllNpc.tbRateNpc) do
                    tbSubInfo.tbAllNpcTID[tbRateNpcInfo.NpcID] = 1; 
                end    
            end

            if tbInfo.nNpcLevel and tbInfo.nNpcLevel > 0 then
                tbSubInfo.nNpcLevel = tbInfo.nNpcLevel;
            end

            if tbSubInfo.nSortNum > 0 then
               bSortNum = true; 
            end 

            tbSubInfo.szNpcName = KNpc.GetNameByTemplateId(nNpcTID);
            tbSubInfo.nShowNpcID = tbInfo.nShowNpcID;
            tbSubInfo.tbShowAward = {};
            local tbShowAllAward = BossLeader:GetShowAward(tbInfo.nShowAwardID);
            if tbShowAllAward then
                tbSubInfo.tbShowAward = tbShowAllAward.tbAllAward;
            end

            if not Lib:IsEmptyStr(tbInfo.szShowName) then
                tbSubInfo.szNpcName = tbInfo.szShowName;
            end

            local bAddListItem = true;
            if tbInfo.nLinkMapID and tbInfo.nLinkMapID > 0 then
                if tbLinkGroup[tbInfo.nShowNpcID] then
                    bAddListItem = false;
                end

                tbLinkGroup[tbInfo.nShowNpcID] = tbLinkGroup[tbInfo.nShowNpcID] or {};
                tbLinkGroup[tbInfo.nShowNpcID].tbAllNpc = tbLinkGroup[tbInfo.nShowNpcID].tbAllNpc or {};
                tbLinkGroup[tbInfo.nShowNpcID].tbAllMap = tbLinkGroup[tbInfo.nShowNpcID].tbAllMap or {};
                table.insert(tbLinkGroup[tbInfo.nShowNpcID].tbAllMap, tbInfo.nMapTID);

                tbSubInfo.tbLinkMapID = tbLinkGroup[tbInfo.nShowNpcID].tbAllMap;

                for _, tbGropInfo in pairs(tbInfo.tbGroupNpc) do
                    local tbAllNpc = BossLeader:GetGroupNpc(tbGropInfo.nNpcGroupID);
                    for _, tbRateNpcInfo in pairs(tbAllNpc.tbRateNpc) do
                        tbLinkGroup[tbInfo.nShowNpcID].tbAllNpc[tbRateNpcInfo.NpcID] = 1; 
                    end    
                end

                tbSubInfo.tbAllNpcTID = tbLinkGroup[tbInfo.nShowNpcID].tbAllNpc;
            end
            
            if bAddListItem then        
                table.insert(tbListItem, tbSubInfo);
            end    
        end
    end

    for _, tbLinkInfo in pairs(tbLinkGroup) do
        table.sort(tbLinkInfo, function(a, b)
            return a > b;
        end);
    end    

    if bSortNum then
        table.sort(tbListItem, function(a, b)
            return a.nSortNum < b.nSortNum;
        end);

    else    
        table.sort(tbListItem, function(a, b)
            return a.nNpcTID < b.nNpcTID;
        end);

        table.sort(tbListItem, function(a, b)
            return a.nNpcLevel > b.nNpcLevel;
        end);
    end
        
    return tbListItem;
end

function tbUi:GetSyncData()
    return BossLeader.tbSyncData[self.szType] or {};
end

function tbUi:UpdateListItemMap(tbSubInfo)
    local szNameMsg = string.format("[faffa3]%s[-]  [ffffff]%s级[-]", tbSubInfo.szNpcName, tbSubInfo.nNpcLevel);
    if self.szType == "Boss" then
        szNameMsg = string.format("[faffa3]%s[-]", tbSubInfo.szNpcName);
    end 

    self.pPanel:Label_SetText("LeadName", szNameMsg);
    --self.pPanel:Label_SetText("LeadLevel", tbSubInfo.nNpcLevel);
    self.pPanel:Label_SetText("Place", Map:GetMapName(tbSubInfo.nMapTID) or "");
    local nShowNpcID = tbSubInfo.nShowNpcID or 0;
    if nShowNpcID <= 0 then
        nShowNpcID = tbSubInfo.nNpcTID;
    end

    local _, nResId = KNpc.GetNpcShowInfo(nShowNpcID);
    self.pPanel:NpcView_ShowNpc("PartnerView", nResId);

    self:UpdateSubAward(tbSubInfo);
    if tbSubInfo.nLinkMapID and tbSubInfo.nLinkMapID > 0 then
        self.pPanel:SetActive("Time", false);
        self.pPanel:SetActive("Time2", true);
        self.pPanel:SetActive("BtnGo", false);  
        self.Time2:UpdateInfo(self, tbSubInfo);
    else
        self.pPanel:SetActive("BtnGo", true);  
        self.pPanel:SetActive("Time", true);
        self.pPanel:SetActive("Time2", false);        
        self:UpdateSubContent(tbSubInfo);
    end    
end

function tbUi:UpdateSubAward(tbSubInfo)
    for nI = 1, 5 do
        local tbReward = tbSubInfo.tbShowAward[nI];
        self.pPanel:SetActive("itemframe"..nI, tbReward ~= nil);
        if tbReward then
            if tbReward[1] == "item" then
                self["itemframe"..nI]:SetItemByTemplate(tbReward[2], tbReward[3] or 1, me.nFaction);
            else
                self["itemframe"..nI]:SetDigitalItem(tbReward[1], tbReward[2] or 1);
            end
            self["itemframe"..nI].fnClick = self["itemframe"..nI].DefaultClick;
        end
    end
end

function tbUi:UpdateSubContent(tbSubInfo)
    local tbContent = {};
    for nI = 1, 4 do
        tbContent[nI] = "";
        self.pPanel:SetActive("DeathLine"..nI, false);
    end

    local tbOpenTime = Calendar:GetTodayOpenTime(self.nCalendarID);
    local nTotalCount = #tbOpenTime;
    if nTotalCount > 0 then
        local nContentIdx = 1;
        for nI, tbTimeInfo in ipairs(tbOpenTime) do
            local nHour, nMinute = Lib:TransferSecond2NormalTime(tbTimeInfo[1]);
            local szContent = string.format("%.2d:%.2d", nHour, nMinute);
            if tbSubInfo.nNpcCount > 1 then
                szContent = szContent..string.format(" %s个", tbSubInfo.nNpcCount);
            end

            local szState = self:GetActivityState(tbTimeInfo);
            local bAllDeath = false;
            if szState == "Start" then
                local nCount = self:GetSyncMapCount(tbSubInfo.nMapTID, tbSubInfo.tbAllNpcTID);
                if nCount > 0 then
                    szContent = szContent.." [ff4444]已刷新[-]";
                else
                    bAllDeath = true;
                end
            elseif szState == "End" then
                bAllDeath = true;
            end

            if bAllDeath then
                self.pPanel:SetActive("DeathLine"..nContentIdx, true);
                local tbDeathInfo = self:GetNpcDeathInfo(tbSubInfo.nMapTID, tbTimeInfo, tbSubInfo.tbAllNpcTID);
                if tbDeathInfo then
                    szContent = szContent.. string.format(" [92d2ff]击败者：[-][faffa3]%s[-]", tbDeathInfo[1][1] or "-");
                    tbContent[nContentIdx] = szContent;

                    nContentIdx = nContentIdx + 1;
                    szContent = string.format("          [92d2ff]家族：[-][faffa3]%s[-]", tbDeathInfo[1][2] or "-");
                else
                    szContent = szContent.."       [1eff00]已全部被击败[-]";
                end
            end

            tbContent[nContentIdx] = szContent;
            nContentIdx = nContentIdx + 1;
        end
    end

    for nI, szContent in pairs(tbContent) do
        if nI <= 4 then
            self.pPanel:Label_SetText("Content"..nI, szContent);
        end
    end
end

function tbUi:GetSyncData()
    return BossLeader.tbSyncData[self.szType] or {};
end

function tbUi:GetSyncState(tbTime)
    local tbSyncData = self:GetSyncData();
    if not tbSyncData[4] then
        return;
    end

    local nLocalDay = Lib:GetLocalDay(tbSyncData[4]);
    if nLocalDay ~= Lib:GetLocalDay() then
        return;
    end

    local nDaySec = Lib:GetTodaySec(tbSyncData[4]);
    if tbTime[1] > nDaySec or nDaySec > tbTime[2] then
        return;
    end

    return tbSyncData[3];
end

function tbUi:GetNpcDeathInfo(nMapTID, tbTime, tbAllNpcTID)
    local tbSyncData = self:GetSyncData();
    local tbNpcDeath = tbSyncData[2];
    if not tbNpcDeath then
        return;
    end

    for nTime, tbMapInfo in pairs(tbNpcDeath) do
        local nDaySec = Lib:GetTodaySec(nTime);
        if tbTime[1] <= nDaySec and nDaySec <= tbTime[2] then
            for nDeathMapID, tbAllDeathInfo in pairs(tbMapInfo) do
                if nDeathMapID == nMapTID then
                    local tbNpcAllDeath = nil;
                    for _, tbInfo in pairs(tbAllDeathInfo) do
                        if tbAllNpcTID[tbInfo[3]] then
                            tbNpcAllDeath = tbNpcAllDeath or {};
                            table.insert(tbNpcAllDeath, tbInfo);
                        end
                    end

                    return tbNpcAllDeath;
                end
            end
        end
    end
end

function tbUi:GetSyncMapCount(nMapTID, tbAllNpcTID)
    local tbSyncData = self:GetSyncData();
    if not tbSyncData[1] or not tbSyncData[1][nMapTID] then
        return 0;
    end

    local nCount = 0;
    for _, nCurNpcTID in pairs(tbSyncData[1][nMapTID]) do
        if tbAllNpcTID[nCurNpcTID] then
            nCount = nCount + 1;
        end
    end

    return nCount;
end

function tbUi:IsOpenTime(tbTime)
    local nCurTime = Lib:GetTodaySec();
    if nCurTime >= tbTime[1] and nCurTime <= tbTime[2] then
        return true;
    end

    return false;
end

function tbUi:GetActivityState(tbTime)
    local nCurTime = Lib:GetTodaySec();
    if tbTime[1] <= nCurTime and nCurTime < tbTime[2] then
        local nState = self:GetSyncState(tbTime);
        if nState == 1 then
            return "Start";
        elseif nState == 2 then
            return "End";
        end

        return "NotStart";
    end

    if tbTime[1] > nCurTime then
        return "NotStart"
    end

    if tbTime[2] < nCurTime then
        return "End";
    end
end

function tbUi:UpdateListLeft(tbListItem)
    if not tbListItem then
        return;
    end

    local fnSelLeftKey = function (tbItem)
        self.nSelectIndex = tbItem.nIndex;
        self:UpdateListItemMap(tbItem.tbInfo);
    end

    local fnSetItem = function (tbItem, nIndex)
        local tbInfo = tbListItem[nIndex];
        tbItem.tbInfo = tbInfo;
        tbItem.nIndex = nIndex;
        local szSubName = string.format("%s (%s级)", tbInfo.szNpcName, tbInfo.nNpcLevel);
        if self.szType == "Boss" then
            szSubName = string.format("%s", tbInfo.szNpcName);
        end
            
        local nFaceId = KNpc.GetNpcShowInfo(tbInfo.nNpcTID);
        local szAtlas, szSprite = Npc:GetFace(nFaceId);
        if szSprite then
            tbItem.pPanel:SetActive("BossHead", true);
            tbItem.pPanel:Sprite_SetSprite("BossHead", szSprite, szAtlas);
        else
            tbItem.pPanel:SetActive("BossHead", false);
        end
        tbItem.pPanel:Label_SetText("LabelDark", szSubName);
        tbItem.pPanel:Label_SetText("LabelLight", szSubName);
        tbItem.pPanel.OnTouchEvent = fnSelLeftKey;
    end

    local nTotalCount = #tbListItem;
    self.ScrollViewBtn:Update(nTotalCount, fnSetItem);

    self.nSelectIndex = self.nSelectIndex or 1;
    if self.nSelectIndex > nTotalCount then
        self.nSelectIndex = 1;
    end

    if nTotalCount >= self.nSelectIndex then
        self:UpdateListItemMap(tbListItem[self.nSelectIndex]);
    end
end

function tbUi:RequestData()
    self.nRequestTime = self.nRequestTime or 0;
    if GetTime() - self.nRequestTime > 20 then
        RemoteServer.RequestDataBossLeader(self.szType);
        self.nRequestTime = GetTime();
    end
end

function tbUi:UpdateSyncData()
    self:UpdateListLeft(self.tbCurListItem);
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow("CalendarPanel");
end

function tbUi:OnLoadedMap(nMapTID)
    if BossLeader:IsBossLeaderMap(nMapTID, "Boss") then
        Ui:CloseWindow("BossLeaderPanel");
    end  
end

function tbUi:OnSyncData(szType)
    if szType == "BossCrossServer" then
        self:UpdateAllInfo();
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
        {UiNotify.emNOTIFY_MAP_LOADED,          self.OnLoadedMap},
        { UiNotify.emNOTIFY_SYNC_DATA,          self.OnSyncData},
    };

    return tbRegEvent;
end

function BossLeader:OnSyncMapData(szType, tbSyncData)
    BossLeader.tbSyncData[szType] = tbSyncData;
    if Ui:WindowVisible("BossLeaderPanel") == 1 then
        Ui("BossLeaderPanel"):UpdateSyncData();
    end
end

function BossLeader:BlackMsg(szType, nMapTID)
    self.nMapTID = nMapTID;
    self.szBlackType = szType;
end

function BossLeader:SyncCrossTimeFrame(szTimeFrame)
    self.szCrossBossTimeFrame = szTimeFrame;
end

function BossLeader:GetCrossBossTimeFrame()
    return self.szCrossBossTimeFrame;
end

-- function BossLeader:OnMapLoaded(nMapTID)
--     if nMapTID ~= self.nMapTID then
--         return;
--     end

--     self.nMapTID = nil;
--     local szMsg = BossLeader.tbMapBackNotic[self.szBlackType];
--     if not Lib:IsEmptyStr(szMsg) then
--         me.SendBlackBoardMsg(szMsg);
--     end
-- end

-- PlayerEvent:RegisterGlobal("OnMapLoaded", BossLeader.OnMapLoaded, BossLeader);

local tbTimeSubItem = Ui:CreateClass("BossLeaderTime");
function tbTimeSubItem:UpdateInfo(tbParentUi, tbSubInfo)
    for nI = 1, 3 do
        self.pPanel:SetActive("DeathLine"..nI, false);
        self.pPanel:SetActive("BtnGo"..nI, false);
        self.pPanel:Label_SetText("ContentTime"..nI, "-");
        self.pPanel:Label_SetText("ContentStatus"..nI, "[ffffff]未刷新[-]");
    end

    local tbLinkInfo = BossLeader:GetLinkMapInfo(tbSubInfo.nLinkMapID);
    self.pPanel:Label_SetText("TxtLabel", tbLinkInfo.ShowMsg or "-");

    local tbOpenTime = Calendar:GetTodayOpenTime(tbParentUi.nCalendarID);
    local nTotalCount = #tbOpenTime;
    if nTotalCount > 0 then
        local tbFindTimeInfo = nil;
        for nI, tbTimeInfo in ipairs(tbOpenTime) do
            if not tbFindTimeInfo then 
                tbFindTimeInfo = tbTimeInfo;
            end    

            local nCurTime = Lib:GetTodaySec();
            if nCurTime < tbTimeInfo[2] + 60 * 60 then
                tbFindTimeInfo = tbTimeInfo;
                break;
            end
        end

        local szState = tbParentUi:GetActivityState(tbFindTimeInfo);
        if szState == "Start" or szState == "End" then
            self:UpdateMapState(tbFindTimeInfo, tbParentUi, tbSubInfo);
        else
            for nIndex = 1, 3 do
                local nHour, nMinute = Lib:TransferSecond2NormalTime(tbFindTimeInfo[1]);
                local szTime = string.format("%.2d:%.2d", nHour, nMinute);
                self.pPanel:Label_SetText("ContentTime"..nIndex, szTime);
                self.pPanel:Label_SetText("ContentStatus"..nIndex, "[ffffff]未刷新[-]");
                self.pPanel:SetActive("BtnGo"..nIndex, false);
            end    
        end    
    end        
end

function tbTimeSubItem:UpdateMapState(tbFindTimeInfo, tbParentUi, tbSubInfo)
    local nCurIndex = 1;
    for _, nMapTID in pairs(tbSubInfo.tbLinkMapID) do
        local funGoMap = function ()
            local nMapType = Map:GetMapType(nMapTID);
            if nMapType == Map.emMap_Fuben then
                RemoteServer.BossLeaderEnterFuben(tbParentUi.szType, nMapTID);
                Ui:CloseWindow("BossLeaderPanel");
            else
                Map:SwitchMap(nMapTID);
                Ui:CloseWindow("BossLeaderPanel");
            end
        end

        local tbDeathInfo = tbParentUi:GetNpcDeathInfo(nMapTID, tbFindTimeInfo, tbSubInfo.tbAllNpcTID);
        if tbDeathInfo then
            for _, tbInfo in pairs(tbDeathInfo) do
                local nHour, nMinute = Lib:TransferSecond2NormalTime(tbFindTimeInfo[1]);
                local szTime = string.format("%.2d:%.2d", nHour, nMinute);
                self.pPanel:Label_SetText("ContentTime"..nCurIndex, szTime);
                self.pPanel:Label_SetText("ContentStatus"..nCurIndex, string.format("[92d2ff]击败者：[-][faffa3]%s[-]\n[92d2ff]家族：[-][faffa3]%s[-]", tbInfo[1] or "-", tbInfo[2] or "-"));
                self.pPanel:SetActive("BtnGo"..nCurIndex, false);

                nCurIndex = nCurIndex + 1;
            end    
        end 

        local nCount = tbParentUi:GetSyncMapCount(nMapTID, tbSubInfo.tbAllNpcTID);
        if nCount > 0 then
            for nI = 1, nCount do
                local nHour, nMinute = Lib:TransferSecond2NormalTime(tbFindTimeInfo[1]);
                local szTime = string.format("%.2d:%.2d", nHour, nMinute);
                self.pPanel:Label_SetText("ContentTime"..nCurIndex, szTime);
                self.pPanel:Label_SetText("ContentStatus"..nCurIndex, string.format("[ffffff]%s[-]", Map:GetMapName(nMapTID) or ""));
                self.pPanel:SetActive("BtnGo"..nCurIndex, true);
                self["BtnGo"..nCurIndex].pPanel.OnTouchEvent = funGoMap;

                nCurIndex = nCurIndex + 1;
            end    
        end   
    end
end