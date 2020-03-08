
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef = HuaShanLunJian.tbDef;
local tbFinalsDef = tbDef.tbFinalsGame;
local tbUi = Ui:CreateClass("HSLJBattlefieldPanel");
tbUi.tbOnClick = {};
tbUi.tbAgainstPlanIndex = {[1] = 8, [2] = 4, [3] = 2};

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("HSLJBattlefieldPanel");
end

function tbUi.tbOnClick:BtnHelp()
    Ui:OnHelpClicked("ChampionGuessHelp");
end

function tbUi.tbOnClick:BtnGuessing()
    local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
    if tbStateData and tbStateData.nPlayState ~= tbDef.nPlayStatePrepare then
        me.CenterMsg("竞猜已经结束", true);
        return;
    end    

    local nGuessing = HuaShanLunJian:GetHSLJGuessingTeamID();
    if nGuessing > 0 then
        return;
    end

    Ui:OpenWindow("GuessingChampionPanel");    
end

function tbUi.tbOnClick:BtnAdditional()
    local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
    if tbStateData and tbStateData.nPlayState ~= tbDef.nPlayStatePrepare then
        me.CenterMsg("竞猜已经结束", true);
        return;
    end 

    Ui:OpenWindow("GuessingChampionPanel"); 
end

function tbUi:OnClose()
    
end

function tbUi:ClearAllInfo()
    for nPlan, tbAgainst in pairs(tbFinalsDef.tbAgainstPlan) do
        for nArena, tbInfo in pairs(tbAgainst) do
            local szSuffix = string.format("%s_%s", nPlan, nArena);
            self["Arena"..szSuffix]:ClearInfo();
        end    
    end

    self.pPanel:SetActive("ChampionTeamName", false);
    self.pPanel:SetActive("ChampionNoTeam", true);
    for nI = 1, 4 do
        self.pPanel:SetActive("ChampionItem"..nI, false);
    end    
end

function tbUi:OnOpen()
    self:ClearAllInfo();
    RemoteServer.DoRequesHSLJ("RequestFinalsData");
    RemoteServer.DoRequesHSLJ("RequestStateData");
    self:UpdateArenaData();
    self:UpdateChampion();
end

function tbUi:GetAgainstPlan(nPlan)
    return tbFinalsDef.tbAgainstPlan[nPlan];
end

function tbUi:UpdateArenaData()
    local tbArena = Player:GetServerSyncData("HSLJFinalsMatch") or {};
    for nIndex, tbPlanData in pairs(tbArena) do
        local nPlan = self.tbAgainstPlanIndex[nIndex];
        if nPlan then
            local tbPlan = self:GetAgainstPlan(nPlan);
            for nArena, tbInfo in pairs(tbPlan) do
                local szSuffix = string.format("%s_%s", nPlan, nArena);
                local tbUiArena = self["Arena"..szSuffix];
                tbUiArena:ClearInfo();
                tbUiArena.nPlan = nPlan;
                tbUiArena.nArena = nArena;
                local tbFightTeam = {};
                tbFightTeam[1] = tbPlanData[tbInfo.tbIndex[1]];
                tbFightTeam[2] = tbPlanData[tbInfo.tbIndex[2]];

                tbUiArena:UpdateInfo(tbFightTeam);
            end
        end     
    end

    self:UpdateGuessing();
end

function tbUi:UpdateGuessing()
    self.pPanel:Label_SetText("GuessingName", "点击竞猜冠军");
    local nGuessing = HuaShanLunJian:GetHSLJGuessingTeamID();
    if nGuessing > 0 then
        local tbFightTeam = self:GetFightTeamInfo(nGuessing);
        if tbFightTeam then
            self.pPanel:Label_SetText("GuessingName", tbFightTeam.szName);
        end    
    end

    local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
    if (tbStateData and tbStateData.nPlayState ~= tbDef.nPlayStatePrepare) or nGuessing <= 0 then
        self.pPanel:Button_SetEnabled("BtnAdditional", false);   
    else
        self.pPanel:Button_SetEnabled("BtnAdditional", true);
    end  
end    

function tbUi:GetFightTeamInfo(nFightTeamID)
    local tbArena = Player:GetServerSyncData("HSLJFinalsMatch");
    if not tbArena then
        return;
    end

    local tbPlanData = tbArena[1];
    if not tbPlanData then
        return;
    end

    for _, tbFightTeam in pairs(tbPlanData) do
        if tbFightTeam.nId == nFightTeamID then
            return tbFightTeam;
        end    
    end    
end

function tbUi:UpdateChampion()
    self.pPanel:SetActive("ChampionNoTeam", true);
    local tbHSLJChampion = Player:GetServerSyncData("HSLJChampion");
    if not tbHSLJChampion then
        RemoteServer.DoRequesHSLJ("RequestHSLJChampion");
        return;
    end   
    self.pPanel:SetActive("ChampionNoTeam", false);
    self.pPanel:SetActive("ChampionTeamName", true);
    self.pPanel:Label_SetText("ChampionTeamName", tbHSLJChampion.szName);
    local tbAllPlayer = {};
    for nPlayerID, tbShowInfo in pairs(tbHSLJChampion.tbAllPlayer) do
        local tbInfo = {};
        tbInfo.nPlayerID = nPlayerID;
        tbInfo.tbShowInfo = tbShowInfo;
        table.insert(tbAllPlayer, tbInfo);
    end

    table.sort(tbAllPlayer, function (a, b)
        return a.nPlayerID < b.nPlayerID;
    end)

    for nI, tbInfo in pairs(tbAllPlayer) do
        local tbShowInfo = tbInfo.tbShowInfo;
        self:SetPlayerInfo(nI, tbShowInfo);
    end 
end

function tbUi:SetPlayerInfo(nIndex, tbShowInfo)
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

function tbUi:OnSyncData(szName)
    if szName == "HSLJFinalsMatch" then
        self:UpdateArenaData();
    elseif szName == "HSLJChampion" then
        self:UpdateChampion();
    elseif szName == "HSLJGuessing" then
        self:UpdateGuessing();       
    end    
end    

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end

local tbSubItem = Ui:CreateClass("PlanArena");
tbSubItem.tbOnClick = {};

function tbSubItem.tbOnClick:Team1()
    if not self.tbFightTeam then
        return;
    end

    local tbInfo = self.tbFightTeam[1];
    if not tbInfo then
        return;
    end

    Ui:OpenWindow("TeamDetailsPanel", tbInfo.nId, true);
end

function tbSubItem.tbOnClick:Team2()
    if not self.tbFightTeam then
        return;
    end

    local tbInfo = self.tbFightTeam[2];
    if not tbInfo then
        return;
    end

    Ui:OpenWindow("TeamDetailsPanel", tbInfo.nId, true);
end

function tbSubItem:UpdateInfo(tbFightTeam)
    self.tbFightTeam = tbFightTeam or {};
    for nI, tbInfo in pairs(self.tbFightTeam) do
        self.pPanel:SetActive("TeamName"..nI, true);
        self.pPanel:Label_SetText("TeamName"..nI, tbInfo.szName or "-");
    end    
end

function tbSubItem:ClearInfo()
    self.pPanel:SetActive("TeamName1", false);
    self.pPanel:SetActive("TeamName2", false);    
end 

