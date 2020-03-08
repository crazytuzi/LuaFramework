
Require("CommonScript/HeroChallenge/HeroChallenge.lua");
local tbDef = HeroChallenge.tbDefInfo;

local tbUi = Ui:CreateClass("HeroChallenge");
tbDef.nTotalItemSub = 1;
tbUi.tbOnClick = {};
tbUi.nAutoFightTime = 5;
HeroChallenge.nCloseResultTime = 2;


function HeroChallenge:CloseRankBattleResult()
    self.nCloseResultCount = self.nCloseResultCount or 0;
    self.nCloseResultCount = self.nCloseResultCount - 1;
    if self.nCloseResultCount <= 0 then
        self.nTimerCloseRank = nil;
        return;
    end

    if Ui:WindowVisible("RankBattleResult") == 1 then
        Timer:Register(Env.GAME_FPS * HeroChallenge.nCloseResultTime, function()
            if Ui:WindowVisible("RankBattleResult") == 1  then
                local tbResult = Ui("RankBattleResult");
                tbResult.tbOnClick.BtnOk(tbResult);
            end
        end)

        self.nTimerCloseRank = nil;
    else
        return true;
    end
end

function HeroChallenge:OnHeroChallengeFloorWin(nCurFloor, bNotCheckResult)
    if not HeroChallenge.bAutoFight then
        return;
    end

    for nFloor = 1, HeroChallenge.nMaxRankFloor do
        local bRet = HeroChallenge:CheckChallengeAward(me, nFloor)
        if bRet then
            RemoteServer.DoHeroChallengeAward(nFloor);
        end
    end

    if not bNotCheckResult then
        if self.nTimerCloseRank then
            Timer:Close(self.nTimerCloseRank);
            self.nTimerCloseRank = nil;
        end

        self.nCloseResultCount = 60;
        self.nTimerCloseRank = Timer:Register(Env.GAME_FPS, self.CloseRankBattleResult, self)
    end
end

function HeroChallenge:OnHeroChallengeFloorFaild(nCurFloor)
    if not HeroChallenge.bAutoFight then
        return;
    end

    HeroChallenge.bAutoFight = false;
end

function tbUi.tbOnClick:BtnClose()
    Ui:CloseWindow(self.UI_NAME);
    HeroChallenge.bAutoFight = false;
end

function tbUi.tbOnClick:BtnOnekey()
    if Map:IsFieldFightMap(me.nMapTemplateId) and me.nFightMode == 1 then
        me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
        local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
        AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function () Ui:OpenWindow("HeroChallenge") end);
        Ui:CloseWindow("HeroChallenge");
        return;
    elseif Map:IsHouseMap(me.nMapTemplateId) or me.nMapTemplateId == Kin.Def.nKinMapTemplateId then    
        Map:SwitchMap(10);
        return;
    end

    if HeroChallenge.bAutoFight then
        HeroChallenge.bAutoFight  = false;
        self:CloseAutoTimer();
        self.pPanel:Label_SetText("LbOnekey", "一键挑战");
    else
        HeroChallenge.bAutoFight  = true;
        self.pPanel:Label_SetText("LbOnekey", "挑战中");
        self:UpdateOnekeyFight();
    end
end

function tbUi:OnDoHeroChallenge()
    self:CloseAutoTimer();
    RemoteServer.DoHeroChallenge();
    local nCurFloor = HeroChallenge:GetPlayerChallengeFloor(me);
    HeroChallenge:OnHeroChallengeFloorWin(nCurFloor, true);

    if not AutoFight:IsAuto() then
        AutoFight:SwitchState();
    end
end

function tbUi:UpdateOnekeyFight()
    if HeroChallenge.bAutoFight then
        self.pPanel:Label_SetText("LbOnekey", "挑战中");
    else
        self.pPanel:Label_SetText("LbOnekey", "一键挑战");
    end

    if not HeroChallenge.bAutoFight then
        return;
    end

    local bRet, szMsg = HeroChallenge:CheckChallengeMaster(me);
    if not bRet then
        me.CenterMsg(szMsg, true);
        HeroChallenge.bAutoFight = false;
        self.pPanel:Label_SetText("LbOnekey", "一键挑战");
        return;
    end

    if Loading:IsLoadMapFinish() then
        self:CloseAutoTimer();
        self.nAutoTimer = Timer:Register(tbUi.nAutoFightTime * Env.GAME_FPS, self.OnDoHeroChallenge, self);
        self.nTimerLabOneKeyTimer = Timer:Register(Env.GAME_FPS, self.OnTimerLabOneKey, self);
        self.pPanel:Label_SetText("LbOnekey", string.format("挑战%s秒", tbUi.nAutoFightTime));
    else
        self:CloseStartAutoTimer();
        self.nStartAutoTimer = Timer:Register(Env.GAME_FPS, self.StartAutoFightTime, self);
    end
end

function tbUi:OnTimerLabOneKey()
    local nTime = 0;
    if self.nAutoTimer then
        nTime = Timer:GetRestTime(self.nAutoTimer);
    end

    self.pPanel:Label_SetText("LbOnekey", string.format("挑战%s秒", math.floor(nTime / Env.GAME_FPS)));
    return true;
end

function tbUi:StartAutoFightTime()
    if not Loading:IsLoadMapFinish() then
        return true;
    end

    self:CloseStartAutoTimer();
    self:UpdateOnekeyFight();
end

function tbUi:CloseAutoTimer()
    if self.nAutoTimer then
        Timer:Close(self.nAutoTimer);
        self.nAutoTimer = nil;
    end

    if self.nTimerLabOneKeyTimer then
        Timer:Close(self.nTimerLabOneKeyTimer);
        self.nTimerLabOneKeyTimer = nil;
    end
end

function tbUi:CloseStartAutoTimer()
    if self.nStartAutoTimer then
        Timer:Close(self.nStartAutoTimer);
        self.nStartAutoTimer = nil;
    end
end

function tbUi:OnClose()
    self:CloseAutoTimer();
    self:CloseStartAutoTimer();
    Client:SaveUserInfo();
end

function tbUi:OnOpen(bNotCalendarOpen)
    if tbDef.nMinPlayerLevel > me.nLevel then
        me.CenterMsg(string.format("参加等级不足%s级", tbDef.nMinPlayerLevel));
        return 0;
    end

    RemoteServer.RequestHeroChallengeInfo();

    local bEffect = bNotCalendarOpen;
    local nCurFloor = HeroChallenge:GetPlayerChallengeFloor(me) + 1;
    if bEffect and nCurFloor == self.nLastFloor then
        bEffect = false;
    end

    self.bEffect = bEffect;
    self:UpdateSection();
    self.nLastFloor = nCurFloor;

    self:UpdateOnekeyFight();
end

function tbUi:UpdateSection(bNotChange)
    local  fnSectionItem = function (tbItem, nIndex)
        tbItem.bEffect = self.bEffect;
        tbItem:UpdateInfo(nIndex)
    end

    --local nTotal = math.ceil(HeroChallenge.nMaxRankFloor / tbDef.nTotalItemSub);
    self.ScrollView:Update(HeroChallenge.nMaxRankFloor, fnSectionItem);
    local nFloor = HeroChallenge:GetPlayerChallengeFloor(me) + 1;
    if not bNotChange then
        self.ScrollView.pPanel:ScrollViewGoToIndex("Main", nFloor + 1);
    end
end

function tbUi:OnEnterMap(nMapTID)
    if nMapTID == tbDef.nFightMapID then
        Ui:CloseWindow(self.UI_NAME);
    end
end

function tbUi:OnSyncData(szType)
    if szType ~= "HeroChallenge" then
        return;
    end

    self:UpdateSection(true);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_ENTER,           self.OnEnterMap},
        { UiNotify.emNOTIFY_SYNC_DATA,                  self.OnSyncData},
    };

    return tbRegEvent;
end


local tbUiItem = Ui:CreateClass("HeroChallengeItem");
tbUiItem.tbOnClick = tbUiItem.tbOnClick or {};

function tbUiItem.tbOnClick:Btnchallenge1()
    if Map:IsFieldFightMap(me.nMapTemplateId) and me.nFightMode == 1 then
        me.CenterMsg("当前不允许参与，正在自动寻路回安全区")
        local nX, nY = Map:GetDefaultPos(me.nMapTemplateId)
        AutoPath:GotoAndCall(me.nMapTemplateId, nX, nY, function () Ui:OpenWindow("HeroChallenge") end);
        Ui:CloseWindow("HeroChallenge");
        return;
    elseif Map:IsHouseMap(me.nMapTemplateId) or me.nMapTemplateId == Kin.Def.nKinMapTemplateId then    
        Map:SwitchMap(10);
        return;
    end

    RemoteServer.DoHeroChallenge();
end

function tbUiItem.tbOnClick:BtnRewards()
    if not self.nSubFloor then
        return;
    end

    RemoteServer.DoHeroChallengeAward(self.nSubFloor);
end

function tbUiItem:UpdateSubSection(nSub)
    local nFloor = (self.nIndex - 1) * tbDef.nTotalItemSub + nSub;
    local tbFloorInfo = HeroChallenge:GetFloorInfo(nFloor);
    if not tbFloorInfo then
        return;
    end
    self.nSubFloor = nFloor;
    self.pPanel:Label_SetText("Name1", string.format("第\n%s\n层\n英\n雄", Lib:Transfer4LenDigit2CnNum(nFloor)));

    local nFaceID = HeroChallenge:GetFloorFaceID(me, nFloor);
    local szAtlas = nil;
    local szSprite = nil;
    if nFaceID > 0 then
        szSprite, szAtlas = PlayerPortrait:GetPortraitBigIcon(nFaceID);
    end

    if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
        self.pPanel:Sprite_SetSprite("head1", szSprite, szAtlas);
    end

    local nCurFloor = HeroChallenge:GetPlayerChallengeFloor(me) + 1;
     self.pPanel:SetActive("texiaotiaozhan1", false);
    Timer:Register(5, function()
        if Ui:WindowVisible("HeroChallenge") ~= 1 then
            return;
        end

        if not Loading:IsLoadMapFinish() then
            return true;
        end

        self.pPanel:SetActive("texiaotiaozhan1", nCurFloor == nFloor and self.bEffect);
        self.bEffect = false;
        Ui("HeroChallenge").bEffect = false;
    end)

    self.pPanel:SetActive("HaveChallenge", nFloor < nCurFloor);
    self.pPanel:SetActive("NotChallenge", nCurFloor == nFloor);
    self.pPanel:SetActive("unknown", nFloor > nCurFloor);
    self.pPanel:SetActive("head1", nFloor <= nCurFloor);
    self.pPanel:SetActive("red", nFloor == nCurFloor);
    self.pPanel:SetActive("blue", nFloor ~= nCurFloor);
    self.pPanel:SetActive("Ordinary", nFloor <= nCurFloor);

    local bRet = HeroChallenge:CheckChallengeAward(me, nFloor);
    self.pPanel:SetActive("BtnRewards", bRet);

    local tbClientData = HeroChallenge:GetPlayerClientData();
    local tbChallengeInfo = tbClientData.tbFloorInfo[nFloor];
    if tbChallengeInfo and nFloor <= nCurFloor then
        self:UpdateChallengeHero(tbChallengeInfo);
        Log("HeroChallenge UpdateSubSection tbCurChallengeInfo ", nCurFloor, nFloor);
    end
end

function tbUiItem:ShowNpcInfo(tbChallengeInfo)

    local tbNpcTeamInfo = RankBattle.tbNpcSetting[tbChallengeInfo[1]];
    self.pPanel:Label_SetText("PlayerName1", tbNpcTeamInfo.HeroName or "");
    if version_tx then
        self.pPanel:Label_SetText("level", string.format("%s级", tbNpcTeamInfo.Level or ""));
    else
        self.pPanel:Label_SetText("level", string.format("Lv.%s", tbNpcTeamInfo.Level or ""));
    end
    self.pPanel:Sprite_SetSprite("united", Faction:GetIcon(tbNpcTeamInfo.Faction or 1));
    self.pPanel:Label_SetText("zhandouli", "");

    for nI = 1, 4 do
        local nPartnerId = tbNpcTeamInfo["PartnerId"..nI];
        if nPartnerId and nPartnerId ~= 0 then
            local nGrowthLevel = tbNpcTeamInfo.GrowthLevel;
            local nLevel       = tbNpcTeamInfo.PartnerLevel;

            local szName, nQualityLevel, nNpcTemplateId, nType = GetOnePartnerBaseInfo(nPartnerId);
            self["PartnerHead"..nI]:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower);
        else
            self["PartnerHead"..nI]:Clear();
        end
    end
end


function tbUiItem:ShowPlayerInfo(tbChallengeInfo)
    local tbSyncInfo = tbChallengeInfo;
    local tbPlayerInfo = tbSyncInfo[1];
    self.pPanel:Label_SetText("PlayerName1", tbPlayerInfo[1] or "");
    if version_tx then
        self.pPanel:Label_SetText("level", string.format("%s级", tostring(tbPlayerInfo[2] or "")));
    else
        self.pPanel:Label_SetText("level", string.format("Lv.%s", tostring(tbPlayerInfo[2] or "")));
    end
    self.pPanel:Sprite_SetSprite("united", Faction:GetIcon(tbPlayerInfo[3] or 1));
    self.pPanel:Label_SetText("zhandouli", string.format("战力：%s", tbPlayerInfo[4] or "-"));

    for nI = 1, 4 do
        local tbPartnerInfo = tbSyncInfo[nI + 1];
        if tbPartnerInfo then
            local nPartnerId   = tbPartnerInfo[1];
            local nLevel       = tbPartnerInfo[2];
            local nFightPower  = tbPartnerInfo[3];

            local szName, nQualityLevel, nNpcTemplateId, nType = GetOnePartnerBaseInfo(nPartnerId);
            self["PartnerHead"..nI]:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower);
        else
            self["PartnerHead"..nI]:Clear();
        end
    end
end

function tbUiItem:UpdateChallengeHero(tbChallengeInfo)
    if tbChallengeInfo[2] == "Npc" then
        self:ShowNpcInfo(tbChallengeInfo);
    else
        self:ShowPlayerInfo(tbChallengeInfo);
    end

    local nCount = DegreeCtrl:GetDegree(me, tbDef.szHeroChallengeCount);
    local nMaxCount = DegreeCtrl:GetMaxDegree(tbDef.szHeroChallengeCount, me);
    self.pPanel:Label_SetText("HeroTime1", string.format("%s/%s", nCount, nMaxCount));
end

function tbUiItem:UpdateInfo(nIndex)
    self.nIndex = nIndex;
    for nI = 1, tbDef.nTotalItemSub do
        self:UpdateSubSection(nI);
    end
end


local tbUiChosse= Ui:CreateClass("HeroChallengeChosse");
tbUiChosse.tbOnClick = {};

function tbUiChosse.tbOnClick:BtnBack()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUiChosse.tbOnClick:Btnchallenge()
    RemoteServer.DoHeroChallenge();
end

function tbUiChosse:OnOpen()
    if not HeroChallenge.tbCurChallengeInfo then
        return;
    end

    self:UpdateChallenge();
end

function tbUiChosse:UpdateChallenge()
    if HeroChallenge.tbCurChallengeInfo[2] == "Npc" then
        self:ShowNpcInfo();
    else
        self:ShowPlayerInfo();
    end

    self:UpdateFaceID();
end

function tbUiChosse:ShowNpcInfo()
    local tbNpcTeamInfo = RankBattle.tbNpcSetting[HeroChallenge.tbCurChallengeInfo[1]];
    self.pPanel:Label_SetText("PlayerName1", tbNpcTeamInfo.HeroName or "");
    self.pPanel:Label_SetText("PlayerName2", tbNpcTeamInfo.HeroName or "");
    self.pPanel:Label_SetText("levelnum", tostring(tbNpcTeamInfo.Level or ""));
    self.pPanel:Label_SetText("menpai", Faction:GetName(tbNpcTeamInfo.Faction));
    self.pPanel:Label_SetText("zhandoulinum", "-");

    for nI = 1, 2 do
        local nPartnerId = tbNpcTeamInfo["PartnerId"..nI];
        if nPartnerId ~= 0 then
            local nGrowthLevel = tbNpcTeamInfo.GrowthLevel;
            local nLevel       = tbNpcTeamInfo.PartnerLevel;

            local szName, nQualityLevel, nNpcTemplateId, nType = GetOnePartnerBaseInfo(nPartnerId);
            self["PartnerHead"..nI]:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower);
        else
            self["PartnerHead"..nI]:Clear();
        end
    end
end

function tbUiChosse:UpdateFaceID()
    local nFloor = HeroChallenge:GetPlayerChallengeFloor(me) + 1;
    local nFaceID = HeroChallenge:GetFloorFaceID(me, nFloor);
    local szAtlas = nil;
    local szSprite = nil;
    if nFaceID > 0 then
        szSprite, szAtlas = PlayerPortrait:GetSmallIcon(nFaceID);
    else
        szAtlas, szSprite = Npc:GetFace(998);
    end

    if not Lib:IsEmptyStr(szSprite) and not Lib:IsEmptyStr(szAtlas) then
        self.pPanel:Sprite_SetSprite("head01", szSprite, szAtlas);
    end
end

function tbUiChosse:ShowPlayerInfo()
    local tbSyncInfo = HeroChallenge.tbCurChallengeInfo;
    local tbPlayerInfo = tbSyncInfo[1];
    self.pPanel:Label_SetText("PlayerName1", tbPlayerInfo[1] or "");
    self.pPanel:Label_SetText("PlayerName2", tbPlayerInfo[1] or "");
    self.pPanel:Label_SetText("levelnum", tostring(tbPlayerInfo[2] or ""));
    self.pPanel:Label_SetText("menpai", Faction:GetName(tbPlayerInfo[3]));
    self.pPanel:Label_SetText("zhandoulinum", tostring(tbPlayerInfo[4] or "-"));

    for nI = 1, 2 do
        local tbPartnerInfo = tbSyncInfo[nI + 1];
        if tbPartnerInfo then
            local nPartnerId   = tbPartnerInfo[1];
            local nLevel       = tbPartnerInfo[2];
            local nFightPower  = tbPartnerInfo[3];

            local szName, nQualityLevel, nNpcTemplateId, nType = GetOnePartnerBaseInfo(nPartnerId);
            self["PartnerHead"..nI]:SetPartnerFace(nNpcTemplateId, nQualityLevel, nLevel, nFightPower);
        else
            self["PartnerHead"..nI]:Clear();
        end
    end
end

function tbUiChosse:OnEnterMap()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUiChosse:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_ENTER,           self.OnEnterMap},
    };

    return tbRegEvent;
end

function HeroChallenge:IsChallengeSameDay(pPlayer)
    local nTime           = GetTime();
    local nLastTime       = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSavePerTime);
    local nParseTodayTime = Lib:ParseTodayTime(tbDef.szDayUpdateTime);
    local nUpdateDay      = Lib:GetLocalDay((nTime - nParseTodayTime));
    local nUpdateLastDay  = Lib:GetLocalDay((nLastTime - nParseTodayTime));
    if nUpdateDay == nUpdateLastDay then
        return true;
    end

    return false;
end

function HeroChallenge:GetPlayerChallengeFloor(pPlayer)
    if not self:IsChallengeSameDay(pPlayer) then
        return 0;
    end

    local nFloor = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveFloorCount);
    return nFloor;
end

function HeroChallenge:GetPlayerAwardFlag(pPlayer)
    if not self:IsChallengeSameDay(pPlayer) then
        return 0;
    end

    local nFlage = pPlayer.GetUserValue(tbDef.nSaveGroupID, tbDef.nSaveGetAwardFlag);
    return nFlage;
end

function HeroChallenge:GetFloorFaceID(pPlayer, nFloor)
    if not self:IsChallengeSameDay(pPlayer) then
        return 0;
    end

    local nFaceID = pPlayer.GetUserValue(tbDef.nSaveShowGroupID, nFloor);
    return nFaceID;
end

function HeroChallenge:UpdateCurChallengeInfo(tbSyncInfo)
    local nFloor = self:GetPlayerChallengeFloor(me) + 1;
    local tbClientData = self:GetPlayerClientData();
    tbClientData.tbFloorInfo[nFloor] = tbSyncInfo;
    self.tbCurChallengeInfo = tbSyncInfo;

    if Ui:WindowVisible("HeroChallenge") == 1 then
        Ui("HeroChallenge"):UpdateSection();
    end

    if Ui:WindowVisible("HeroChallengeChosse") == 1 then
        Ui:CloseWindow("HeroChallengeChosse");
    end
end

function HeroChallenge:GetPlayerClientData()
    local tbData = Client:GetUserInfo("HeroChallengeData", me.dwID);
    if not tbData.tbFloorInfo then
        tbData.tbFloorInfo = {};
    end

    return tbData;
end