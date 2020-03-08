local tbUi = Ui:CreateClass("WLDHBattlefieldPanel");
local tbDef = WuLinDaHui.tbDef

function tbUi:OnOpen(nGameType)
    WuLinDaHui:CheckRequestTopTeamData(nGameType)

    local tbGameFormat = WuLinDaHui.tbGameFormat[nGameType] 
    self.pPanel:Label_SetText("Title", string.format("%s·决赛战报", tbGameFormat.szName) )

    self.nGameType = nGameType
end

function tbUi:OnOpenEnd()
    self:UpdateList();
end

function tbUi:UpdateList()
    local tbSyndata, nSynTimeVersion, nWinTeamId = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. self.nGameType) ;
    if nWinTeamId ~= self.nWinTeamId and nWinTeamId then
        local tbWiinerShowInfo = Player:GetServerSyncData("WLDHFightTeam:"..nWinTeamId) ;
        if not tbWiinerShowInfo then
            RemoteServer.DoRequesWLDH("RequestFightTeamShow", nWinTeamId)
        end
    end
    self.nWinTeamId = nWinTeamId

    tbSyndata = tbSyndata or {}
    local tbAgainstPlan = tbDef.tbFinalsGame.tbAgainstPlan
    -- 先全部清除，再设置有的
    for k1,v1 in pairs(tbAgainstPlan) do
        local nMax = #v1
        for i2,v in ipairs(v1) do
            local tbTeamPanel = self[string.format("Arena%d_%d", nMax, i2)]
            tbTeamPanel.pPanel:Label_SetText("TeamName1", "")
            tbTeamPanel.pPanel:Label_SetText("TeamName2", "")
            tbTeamPanel.nFightTeamID1 = nil;
            tbTeamPanel.nFightTeamID2 = nil;
            tbTeamPanel.nGameType = self.nGameType
        end
    end

    self.bHasFinal = false
    local tbPlan = {16, 8,4,2} 
    for i = 1, 16 do
        local tbTeamInfo = tbSyndata[i]
        if tbTeamInfo then
            local nPlan = tbTeamInfo.nPlan or 16 
            if nPlan == 0 then
                nPlan = 16
            end
            local nRank = tbTeamInfo.nRank or i;
            local nRankPos = nRank
            for i2,v2 in ipairs(tbPlan) do
                if v2 < nPlan then
                    break;
                end
                local nSide, nMatch, nMatchNum = WuLinDaHui:GetMatchIndex(v2, nRankPos)
                if nPlan < v2 then --如果玩家达到下一轮
                    nRankPos = nMatch ;-- 对应上一轮的场次数
                end
                if nMatchNum == 1 then
                    self.bHasFinal = true
                end
                local tbTeamPanel = self[string.format("Arena%d_%d", nMatchNum, nMatch)]
                tbTeamPanel.pPanel:Label_SetText("TeamName" .. nSide, tbTeamInfo.szName)
                tbTeamPanel["nFightTeamID" .. nSide]  = tbTeamInfo.nFightTeamID;
            end
        end
    end

    self:UpDateChampionUi()
    self:UpdateGuessing();
end

function tbUi:UpDateChampionUi()
    self.pPanel:SetActive("Arena1_1", false)
    self.pPanel:SetActive("ChampionNoTeam", false)
    self.pPanel:SetActive("Champion", false)
    self.pPanel:SetActive("VictoryCondition", true)
    local tbOldPosGuessing = self.pPanel:GetPosition("Guessing")
    if self.nWinTeamId then
        self.pPanel:SetActive("Champion", true)
        self.pPanel:SetActive("VictoryCondition", false)

        self.pPanel:ChangePosition( "Guessing",  tbOldPosGuessing.x, -217);
        local tbFightTeam = Player:GetServerSyncData("WLDHFightTeam:" .. self.nWinTeamId) ;
        if tbFightTeam then
            self.pPanel:Label_SetText("ChampionTeamName", tbFightTeam.szName);
            local tbAllPlayer = {};
            for nPlayerID, tbShowInfo in pairs(tbFightTeam.tbAllPlayer) do
                local tbInfo = {};
                tbInfo.nPlayerID = nPlayerID;
                tbInfo.tbShowInfo = tbShowInfo;
                table.insert(tbAllPlayer, tbInfo);
            end
            table.sort(tbAllPlayer, function (a, b)
                return a.nPlayerID < b.nPlayerID;
            end)
            self.tbAllPlayer = tbAllPlayer;
            for nI, tbInfo in pairs(tbAllPlayer) do
                local tbShowInfo = tbInfo.tbShowInfo;
                self.pPanel:SetActive("ChampionItem" .. nI, true) 
                self:SetChampionPlayerInfo(nI, tbShowInfo);
            end   
            for nI=#tbAllPlayer + 1,4 do
                self.pPanel:SetActive("ChampionItem" .. nI, false) 
            end
            if tbFightTeam.szServerName then
                self.pPanel:SetActive("Server", true)
                self.pPanel:Label_SetText("Server", string.format("服务器：%s", tbFightTeam.szServerName))
            else
                self.pPanel:SetActive("Server", false)
            end
        end
    elseif self.bHasFinal then
        self.pPanel:ChangePosition( "Guessing",  tbOldPosGuessing.x, -149);
        self.pPanel:SetActive("Arena1_1", true)
    else
        self.pPanel:ChangePosition( "Guessing",  tbOldPosGuessing.x, -149);
        self.pPanel:SetActive("ChampionNoTeam", true)
    end
end


function tbUi:UpdateGuessing()
    self.pPanel:Label_SetText("GuessingName", "点击竞猜冠军");
    local nGuessing = WuLinDaHui:GetGuessingTeamID(self.nGameType)
    if nGuessing > 0 then
        local tbFightTeam = self:GetFightTeamInfo(nGuessing);
        if tbFightTeam then
            self.pPanel:Label_SetText("GuessingName", tbFightTeam.szName);
        end    
    end

    --决赛开了 或者是冠军已经出来了则不能竞猜
    local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
    if  nGuessing <= 0 or not  WuLinDaHui:CanGuessing(self.nGameType) then
        self.pPanel:Button_SetEnabled("BtnAdditional", false);   
    else
        self.pPanel:Button_SetEnabled("BtnAdditional", true);
    end  
end

function tbUi:GetFightTeamInfo(nFightTeamID)
    local tbSyndata = Player:GetServerSyncData("WLDHTopPreFightTeamList" .. self.nGameType) ;
    if not tbSyndata then
        return
    end

    for i,v in ipairs(tbSyndata) do
        if v.nFightTeamID == nFightTeamID then
            return v;
        end
    end
end

function tbUi:SetChampionPlayerInfo(nIndex, tbShowInfo)
    self.pPanel:SetActive("ChampionItem"..nIndex, true);
    self.pPanel:Label_SetText("ChaName"..nIndex, tbShowInfo.szName);
    self.pPanel:Label_SetText("ChaFighting"..nIndex, string.format("战力：%s", tbShowInfo.nFightPower));
    if tbShowInfo.nHonorLevel > 0 then
        self.pPanel:SetActive("ChaPlayerTitle"..nIndex, true);
        local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbShowInfo.nHonorLevel)
        self.pPanel:Sprite_Animation("ChaPlayerTitle"..nIndex, ImgPrefix, Atlas);
    else
        self.pPanel:SetActive("ChaPlayerTitle"..nIndex, false);
    end

    local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbShowInfo.nPortrait);
    self.pPanel:Sprite_SetSprite("SpRoleHead"..nIndex, szHead, szAtlas);
    local szFactionIcon = Faction:GetIcon(tbShowInfo.nFaction);
    self.pPanel:Sprite_SetSprite("SpFaction"..nIndex, szFactionIcon);
    self.pPanel:Label_SetText("lbLevel"..nIndex, tostring(tbShowInfo.nLevel));
end

function tbUi:OnLeaveMap()
    Ui:CloseWindow(self.UI_NAME)
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,  self.OnSyncData},
        { UiNotify.emNOTIFY_MAP_LEAVE,           self.OnLeaveMap},
    };

    return tbRegEvent;
end

function tbUi:OnSyncData(szType)
    if szType == "WLDHTopPreFightTeamList" .. self.nGameType then
        self:UpdateList()
    elseif string.find(szType, "WLDHFightTeam:") then
        self:UpDateChampionUi()
    elseif szType == "WLDHGuessing" then
        self:UpdateGuessing()
    end
end

tbUi.tbOnClick = {}

tbUi.tbOnClick.BtnClose = function (self)
    Ui:CloseWindow(self.UI_NAME)
end

tbUi.tbOnClick.BtnGuessing = function (self)
    if not WuLinDaHui:CanGuessing(self.nGameType) then
         me.CenterMsg("竞猜已经结束", true);
        return;
    end

    local nGuessing = WuLinDaHui:GetGuessingTeamID(self.nGameType)
    if nGuessing > 0 then
        return;
    end

    Ui:OpenWindow("GuessingChampionPanel", self.nGameType);    
end

tbUi.tbOnClick.BtnAdditional = function (self)
   if not WuLinDaHui:CanGuessing(self.nGameType) then
         me.CenterMsg("竞猜已经结束", true);
        return;
    end

    Ui:OpenWindow("GuessingChampionPanel", self.nGameType);    
end

tbUi.tbOnClick.BtnHelp = function (self)
    Ui:OpenWindow("NewInformationPanel", WuLinDaHui.tbDef.szNewsKeyNotify)
end

for i=1,4 do
    tbUi.tbOnClick["ChampionItem" .. i] = function (self)
        if not self.tbAllPlayer then
            return
        end
        local tbInfo = self.tbAllPlayer[i]
        if not tbInfo then
            return
        end
        local tbFightTeam = Player:GetServerSyncData("WLDHFightTeam:" .. self.nWinTeamId) ;
        if not tbFightTeam then
            return
        end

        ViewRole:OpenWindowWithServerId("ViewRolePanel", tbInfo.nPlayerID, tbFightTeam.nServerId)    
    end    
end

local tbSubItem = Ui:CreateClass("PlanArenaWLDH");
tbSubItem.tbOnClick = {};
function tbSubItem.tbOnClick:Team1()
    local nFightTeamID = self.nFightTeamID1
    if not nFightTeamID then
        return;
    end
    Ui:OpenWindow("TeamDetailsPanel", nFightTeamID, false, self.nGameType);
end

function tbSubItem.tbOnClick:Team2()
    local nFightTeamID = self.nFightTeamID2
    if not nFightTeamID then
        return;
    end

    Ui:OpenWindow("TeamDetailsPanel", nFightTeamID, false, self.nGameType);
end

