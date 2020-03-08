
Require("CommonScript/HuaShanLunJian/LunJianDef.lua");
local tbDef = HuaShanLunJian.tbDef;

local tbUi = Ui:CreateClass("TeamDetailsPanel");
tbUi.tbOnClick = {};
tbUi.nMaxItemCount = 4;

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow("TeamDetailsPanel");
end

for nI = 1, tbUi.nMaxItemCount do
    tbUi.tbOnClick["ChampionItem"..nI] = function (self)
        if not self.tbAllPlayer then
            return;
        end

        local tbInfo = self.tbAllPlayer[nI];
        if not tbInfo then
            return;
        end
        local tbFightTeam = Player:GetServerSyncData(self:GetFightTeamKey());
        if not tbFightTeam then
            return
        end

        ViewRole:OpenWindowWithServerId("ViewRolePanel", tbInfo.nPlayerID, tbFightTeam.nServerId)
    end
end

function tbUi.tbOnClick:BtnGuessing()
    local tbFightTeam = Player:GetServerSyncData("HSLJFightTeam:"..self.nFightTeam);
    if not tbFightTeam then
        return;
    end

    local tbTeam = {};
    tbTeam.szName = tbFightTeam.szName;
    tbTeam.nId = self.nFightTeam;
    Ui:OpenWindow("GuessingSurePanel", tbTeam);
    Ui:CloseWindow("TeamDetailsPanel");
end

function tbUi:RequesData()
    local tbFightTeam = Player:GetServerSyncData(self:GetFightTeamKey());
    local bReques = true;
    if tbFightTeam then
        tbFightTeam.__RequesTime =  tbFightTeam.__RequesTime or GetTime();
        if GetTime() - tbFightTeam.__RequesTime < 60 * 30 then
            bReques = false;
        end
    end

    if bReques then
        if  self.nWLDHType then
            RemoteServer.DoRequesWLDH("RequestFightTeamShow", self.nFightTeam);
        else
            RemoteServer.DoRequesHSLJ("RequestFightTeamShow", self.nFightTeam); --看需不需要优化一下 不同的角色有可能冲突了
        end
    end
end

function tbUi:GetFightTeamKey()
    if not self.nWLDHType then
        return "HSLJFightTeam:"..self.nFightTeam
    else
        return "WLDHFightTeam:"..self.nFightTeam
    end
end

function tbUi:OnOpen(nFightTeam, bOpenGuessing, nWLDHType)
    if not nFightTeam then return end;
    self.nWLDHType = nWLDHType
    self.nFightTeam = nFightTeam;
    self.tbAllPlayer = {};
    self:RequesData();
    self:UpdateFightTeam();

    local bIsOpen = false;
    if bOpenGuessing then
        bIsOpen = true;

        local tbStateData = Player:GetServerSyncData("HSLJStateData") or {};
        if (tbStateData and tbStateData.nPlayState ~= tbDef.nPlayStatePrepare) then
            bIsOpen = false;
        end
    end

    local nTeamID = HuaShanLunJian:GetHSLJGuessingTeamID();
    if nTeamID ~= nFightTeam then
        if nTeamID == 0 then
            self.pPanel:Label_SetText("LbGuessing", "竞猜冠军");
        else
            self.pPanel:Label_SetText("LbGuessing", "更换竞猜");
        end
    else
        bIsOpen = false;
    end

    self.pPanel:SetActive("BtnGuessing", bIsOpen);
end

function tbUi:UpdateFightTeam()
    self:ClearAllInfo();
    local tbFightTeam = Player:GetServerSyncData(self:GetFightTeamKey());
    if not tbFightTeam then
        return;
    end

    self.pPanel:Label_SetText("TeamName", tbFightTeam.szName);
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
        self:SetPlayerInfo(nI, tbShowInfo);
    end

    if tbFightTeam.szServerName then
        self.pPanel:SetActive("Server", true)
        self.pPanel:Label_SetText("Server", string.format("服务器：%s", tbFightTeam.szServerName))
    else
        self.pPanel:SetActive("Server", false)
    end
end

function tbUi:SetPlayerInfo(nIndex, tbShowInfo)
    self.pPanel:SetActive("ChampionItem"..nIndex, true);
    self.pPanel:Label_SetText("PlayerName"..nIndex, tbShowInfo.szName);
    self.pPanel:Label_SetText("Fighting"..nIndex, string.format("战力：%s", tbShowInfo.nFightPower));
    if tbShowInfo.nHonorLevel > 0 then
        self.pPanel:SetActive("PlayerTitle"..nIndex, true);
        local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbShowInfo.nHonorLevel)
        self.pPanel:Sprite_Animation("PlayerTitle"..nIndex, ImgPrefix, Atlas);
    else
        self.pPanel:SetActive("PlayerTitle"..nIndex, false);
    end

    local szHead, szAtlas = PlayerPortrait:GetSmallIcon(tbShowInfo.nPortrait);
    self.pPanel:Sprite_SetSprite("SpRoleHead"..nIndex, szHead, szAtlas);
    local szFactionIcon = Faction:GetIcon(tbShowInfo.nFaction);
    self.pPanel:Sprite_SetSprite("SpFaction"..nIndex, szFactionIcon);
    self.pPanel:Label_SetText("lbLevel"..nIndex, tostring(tbShowInfo.nLevel));
end

function tbUi:ClearAllInfo()
    for nI = 1, self.nMaxItemCount do
        self.pPanel:SetActive("ChampionItem"..nI, false);
    end
end

function tbUi:OnSyncData(szName)
    if string.find(szName, "HSLJFightTeam:") or string.find(szName, "WLDHFightTeam:") then
        self:UpdateFightTeam();
    end
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end