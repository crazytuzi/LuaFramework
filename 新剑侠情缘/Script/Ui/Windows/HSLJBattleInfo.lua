
local tbUi = Ui:CreateClass("HSLJBattleInfo");
tbUi.tbOnClick = {};

tbUi.tbHelpInfo =
{
    ["HSLJFinalsNew"] = function(self)
        Ui:OpenWindow("HSLJBattlefieldPanel");
    end;

    ["WLDHFinalsNew1"] = function (self)
        Ui:OpenWindow("WLDHBattlefieldPanel", 1)
    end;
    ["WLDHFinalsNew2"] = function (self)
        Ui:OpenWindow("WLDHBattlefieldPanel", 2)
    end;
    ["WLDHFinalsNew3"] = function (self)
        Ui:OpenWindow("WLDHBattlefieldPanel", 3)
    end;
    ["WLDHFinalsNew4"] = function (self)
        Ui:OpenWindow("WLDHBattlefieldPanel", 4)
    end;
    ["WLDHPre1"] = function (self)
        Ui:OpenWindow("WLDHRankPanel", 1)
    end;
    ["WLDHPre2"] = function (self)
        Ui:OpenWindow("WLDHRankPanel", 2)
    end;
    ["WLDHPre3"] = function (self)
        Ui:OpenWindow("WLDHRankPanel", 3)
    end;
    ["WLDHPre4"] = function (self)
        Ui:OpenWindow("WLDHRankPanel", 4)
    end;



};

tbUi.tbPlayInfo =
{
    ["JiFen"] =
    {
        tbBgSize = {220, 20};
        tbCamp =
        {
            {"积分：%s", "nDamage"};
        };
        tbEnemyCamp = 
        {
            {"排名：%s", "nDamage"};
        };
        tbCampName = {["My"] = "", ["Enemy"] = ""};
    };
    ["Normal"] = 
    {
        tbBgSize = {220, 74};
        tbCamp =
        {
            {"伤敌数：%s", "nKill"};
            {"同伴数：%s", "nPartner"};
            {"总伤害：%s", "nDamage"};
        };
        tbCampName = {["My"] = "我方", ["Enemy"] = "对手"};
    };
    ["TeamJiFen"] =
    {
        tbBgSize = {220, 20};
        tbCamp =
        {
            {"我方积分：%s", "nDamage"};
        };
        tbEnemyCamp = 
        {
            {"敌方积分：%s", "nDamage"};
        };
        tbCampName = {["My"] = "", ["Enemy"] = ""};
    };
}

function tbUi.tbOnClick:BtnHelp()
    if not self.tbShowInfo or not self.tbShowInfo.szHelp then
        return;
    end

    local funHelp = tbUi.tbHelpInfo[self.tbShowInfo.szHelp];
    if not funHelp then
        return;
    end

    funHelp(self);    
end

function tbUi:OnClose()
    self:CloseAllTimer();
end

function tbUi:CloseAllTimer()
    for _, nTimer in pairs(self.tbAllTimer) do
        Timer:Close(nTimer);
    end

    self.tbAllTimer = {};    
end

function tbUi:OnOpen(szType, tbInfo)
    self.szType = szType;
    self.tbShowInfo = tbInfo;
    local fnOn = self["On"..self.szType];
    if not fnOn then
        return;
    end

    self.tbAllTimer = self.tbAllTimer or {};
    self:CloseAllTimer();
    fnOn(self);
    if tbInfo.szHelp then
        self.pPanel:SetActive("BtnHelp", true);
    else
        self.pPanel:SetActive("BtnHelp", false);    
    end    
end

function tbUi:OnShowInfo()
    self:CloseAllTimer();
    if self.tbShowInfo.nTime and self.tbShowInfo.nTime > 0 then
        self.pPanel:SetActive("ShowTime", true);
        self.tbAllTimer["Time"] = Timer:Register(Env.GAME_FPS * self.tbShowInfo.nTime, self.OnTime, self)
        self.tbAllTimer["ShowTime"] = Timer:Register(Env.GAME_FPS, self.ShowTimeInfo, self);
        self.pPanel:Label_SetText("ShowTime", Lib:TimeDesc(self.tbShowInfo.nTime) or "0");
    else
        self.pPanel:SetActive("ShowTime", false);      
    end

    self.pPanel:SetActive("ShowInfo", true);
    self.pPanel:SetActive("MyInfo", false);
    self.pPanel:SetActive("EnemyInfo", false);
    self.pPanel:Label_SetText("ShowInfo", self.tbShowInfo.szShow or "-");   
end

function tbUi:OnTime()
    self.tbAllTimer["Time"] = nil;
end    

function tbUi:ShowTimeInfo()
    local nTime = self:GetTimerTime();
    local szTitle = "";
    if self.tbShowInfo and self.tbShowInfo.szTitle then
        szTitle = self.tbShowInfo.szTitle;
    end

    self.pPanel:Label_SetText("ShowTime", string.format("%s%s", szTitle or "", Lib:TimeDesc(nTime) or "0"));
    return true;
end

function tbUi:GetTimerTime()
    if not self.tbAllTimer["Time"] then
        return 0;
    end    

    local nTime = math.floor(Timer:GetRestTime(self.tbAllTimer["Time"]) / Env.GAME_FPS);
    return nTime;
end

function tbUi:OnPlay()
    self:CloseAllTimer();
    
    if self.tbShowInfo.nTime and self.tbShowInfo.nTime > 0 then
        self.pPanel:SetActive("ShowTime", true);
        self.tbAllTimer["Time"] = Timer:Register(Env.GAME_FPS * self.tbShowInfo.nTime, self.OnTime, self)
        self.tbAllTimer["ShowTime"] = Timer:Register(Env.GAME_FPS, self.ShowTimeInfo, self);
        local szTitle = "";
        if self.tbShowInfo and self.tbShowInfo.szTitle then
            szTitle = self.tbShowInfo.szTitle;
        end

        self.pPanel:Label_SetText("ShowTime", string.format("%s%s", szTitle or "", Lib:TimeDesc(self.tbShowInfo.nTime) or "0"));
    else
        self.pPanel:SetActive("ShowTime", false);  
    end

    self.pPanel:SetActive("ShowInfo", false);
    self.pPanel:SetActive("MyInfo", true);
    self.pPanel:SetActive("EnemyInfo", true);

    self:UpdatePlayAllTeam();   
end

function tbUi:UpdatePlayAllTeam()
    local nMyTeam = self.tbShowInfo.nTeam;
    for nTeam, tbTeamInfo in pairs(self.tbShowInfo.tbAllTeam or {}) do
        local szCamp = "My";
        if nTeam ~= nMyTeam then
            szCamp = "Enemy";
        end

        self:SetCampInfo(szCamp, tbTeamInfo);
    end 
end

function tbUi:SetCampInfo(szCamp, tbTeamInfo)
    local tbPlayInfo = nil;
    if self.tbShowInfo and self.tbShowInfo.szType then
        tbPlayInfo = self.tbPlayInfo[self.tbShowInfo.szType];
    end

    if not tbPlayInfo then
        tbPlayInfo = self.tbPlayInfo["Normal"];
    end    
        
    self.pPanel:SetActive(szCamp.."CompanionNumber", false);
    self.pPanel:SetActive(szCamp.."Damage", false);
    self.pPanel:Widget_SetSize(szCamp.."Bg", tbPlayInfo.tbBgSize[1], tbPlayInfo.tbBgSize[2]);


    local tbCamp = tbPlayInfo["tb" ..szCamp .. "Camp"] or tbPlayInfo.tbCamp
    local szShowMsg = "";
    for _, tbInfo in ipairs(tbCamp) do
        szShowMsg = szShowMsg..string.format(tbInfo[1], tbTeamInfo[tbInfo[2]] or "-");
        szShowMsg = szShowMsg.."\n";
    end    

    self.pPanel:Label_SetText(szCamp.."KillsNumber", szShowMsg);
    local tbCampName = tbPlayInfo.tbCampName or {}
    local szCampName = tbCampName[szCamp] or ""
    self.pPanel:Label_SetText(szCamp.."Camp", szCampName);
end

function tbUi:OnLoadedMap(nMapTID)
    if self.tbShowInfo and self.tbShowInfo.nMapTID ~= nMapTID then
        Ui:CloseWindow("HSLJBattleInfo");
    end    
end

function tbUi:OnSyncData(szName)
    if szName == "PlayAllTeam" then
        local tbAllTeam = Player:GetServerSyncData("PlayAllTeam");
        self.tbShowInfo.tbAllTeam = tbAllTeam;
        self:UpdatePlayAllTeam();
    end    
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_MAP_LOADED,          self.OnLoadedMap},
        {UiNotify.emNOTIFY_SYNC_DATA,          self.OnSyncData},
    };

    return tbRegEvent;
end