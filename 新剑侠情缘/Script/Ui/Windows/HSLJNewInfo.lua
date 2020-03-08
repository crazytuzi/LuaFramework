


local tbHSLJUi = Ui:CreateClass("NewInfo_HSLJEightRank")
tbHSLJUi.tbOnClick = {};
tbHSLJUi.nMaxIndex = 8;
for nI = 1, tbHSLJUi.nMaxIndex do
    tbHSLJUi.tbOnClick["TeamName"..nI] = function (self)
        if not self.tbAllTeamInfo then
            return;
        end 

        local tbInfo = self.tbAllTeamInfo[nI];
        if not tbInfo then
            return;
        end

        Ui:OpenWindow("TeamDetailsPanel", tbInfo.nId, true);
    end
end

function tbHSLJUi.tbOnClick:BtnFinalsRankCheck()
    Ui:OpenWindow("HSLJBattlefieldPanel");    
end    

function tbHSLJUi:ClearAllInfo()
    for nI = 1, tbHSLJUi.nMaxIndex do
        self.pPanel:SetActive("TopFinalsRanking"..nI, false);    
    end  
end

function tbHSLJUi:OnOpen(tbData)
    self.tbAllTeamInfo = tbData or {};
    self:ClearAllInfo();

    for nRank, tbInfo in pairs(self.tbAllTeamInfo) do
        self:SetSubItemInfo(nRank, tbInfo);
    end    
end

function tbHSLJUi:SetSubItemInfo(nI, tbInfo)
    self.pPanel:SetActive("TopFinalsRanking"..nI, true);
    self.pPanel:Label_SetText("TeamNameTxt"..nI, tbInfo.szName or "");   
    self.pPanel:Label_SetText("FinalsRanking"..nI, tostring(nI));   
    self.pPanel:Label_SetText("Integral"..nI, tostring(tbInfo.nJiFen));
    self.pPanel:Label_SetText("WinsNumber"..nI, tostring(tbInfo.nWin));
    self.pPanel:Label_SetText("GameTime"..nI, Lib:TimeDesc(tbInfo.nTime));
end


local tbChamppUi = Ui:CreateClass("NewInfo_HSLJChampionship")
tbChamppUi.tbOnClick = {};
tbChamppUi.nMaxIndex = 4;

for nI = 1, tbChamppUi.nMaxIndex do
    tbChamppUi.tbOnClick["BtnCheck"..nI] = function (self)
        if not self.tbAllPlayer then
            return;
        end

        local nCount = Lib:CountTB(self.tbAllPlayer);
        local nExtIndex = 1;
        if nCount >= 3 then
            nExtIndex = 0;
        end

        local tbInfo = self.tbAllPlayer[nI - nExtIndex];
        if not tbInfo then
            return;
        end

        ViewRole:OpenWindow("ViewRolePanel", tbInfo.nPlayerID)        
    end
end

function tbChamppUi.tbOnClick:BtnHSLJShowOff()
    Ui:OpenWindow("MainShowOffPanel", "HSLJ", self.tbChampionship);
end

function tbChamppUi:ClearAllInfo()
    for nI = 1, tbChamppUi.nMaxIndex do
        self.pPanel:SetActive("PlayerInfo"..nI, false);
    end    
end

function tbChamppUi:OnOpen(tbData)
    self.tbChampionship = tbData or {};
    if not Lib:HaveCountTB(self.tbChampionship) then
        self.pPanel:SetActive("NoChampion", true);
        self.pPanel:SetActive("HavaChampion", false);
        self.pPanel:SetActive("BtnHSLJShowOff", false);
        return;
    end

    self.pPanel:SetActive("NoChampion", false);
    self.pPanel:SetActive("HavaChampion", true);
    self:ClearAllInfo();
    self.pPanel:Label_SetText("TeamName", self.tbChampionship.szName or ""); 

    local tbAllPlayer = {};
    local bIsChampion = false;
    for nPlayerID, tbShowInfo in pairs(self.tbChampionship.tbAllPlayer) do
        local tbInfo = {};
        tbInfo.nPlayerID = nPlayerID;
        tbInfo.tbShowInfo = tbShowInfo;
        table.insert(tbAllPlayer, tbInfo);

        if nPlayerID == me.dwID then
            bIsChampion = true;
        end
    end

    if bIsChampion then
        self.pPanel:SetActive("BtnHSLJShowOff", Sdk:IsLoginByQQ() or Sdk:IsLoginByWeixin());
    else
        self.pPanel:SetActive("BtnHSLJShowOff", false);
    end

    table.sort(tbAllPlayer, function (a, b)
        return a.nPlayerID < b.nPlayerID;
    end) 

    local nCount = Lib:CountTB(tbAllPlayer);
    local nExtIndex = 1;
    if nCount >= 3 then
        nExtIndex = 0;
    end
    self.tbAllPlayer = tbAllPlayer;
    for nI, tbPlayerInfo in pairs(tbAllPlayer) do
        local tbShowInfo = tbPlayerInfo.tbShowInfo;
        self:SetPlayerInfo(nI + nExtIndex, tbShowInfo);
    end  
end

function tbChamppUi:SetPlayerInfo(nIndex, tbShowInfo)
    self.pPanel:SetActive("PlayerInfo"..nIndex, true);
    
    self.pPanel:Label_SetText("PlayerName"..nIndex, tbShowInfo.szName);
    self.pPanel:Label_SetText("PlayerFighting"..nIndex, string.format("战力：%s", tbShowInfo.nFightPower));
    if tbShowInfo.nHonorLevel > 0 then
        self.pPanel:SetActive("PlayerTitle"..nIndex, true);
        local ImgPrefix, Atlas = Player:GetHonorImgPrefix(tbShowInfo.nHonorLevel)
        self.pPanel:Sprite_Animation("PlayerTitle"..nIndex, ImgPrefix, Atlas);
    else
        self.pPanel:SetActive("PlayerTitle"..nIndex, false);
    end

    local nTmpBigFace = PlayerPortrait:CheckBigFaceId(tbShowInfo.nBigFace, tbShowInfo.nPortrait, 
        tbShowInfo.nFaction, tbShowInfo.nSex);
    local szHead, szAtlas = PlayerPortrait:GetPortraitBigIcon(nTmpBigFace);
    self.pPanel:Sprite_SetSprite("PlayerHead"..nIndex, szHead, szAtlas);
    --local szFactionIcon = Faction:GetIcon(tbShowInfo.nFaction);
    --self.pPanel:Sprite_SetSprite("SpFaction"..nIndex, szFactionIcon);
    self.pPanel:Label_SetText("PlayerLevel"..nIndex, string.format("等级：%s", tbShowInfo.nLevel));
end

