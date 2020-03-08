local tbUi = Ui:CreateClass("TeamBattleInfo");
local  MyScore = 0;
local  EnemyScore = 0;

function tbUi:OnOpenEnd(nLayers, nFightTimes, nMaxFightTimes)
    self.pPanel:SetActive("StarTowerScore", true);
    self.pPanel:SetActive("Time", true);
    self.pPanel:Label_SetText("Layers","第"..tostring(nLayers).."层");
    self:CloseTimer();
    self.nTotalTime = 10;
    self.nFightTimes = nFightTimes;
    self.nMaxFightTimes = nMaxFightTimes;
    self:UpdateInfo(0,0,0,0,"等待开始",self.nTotalTime);
end

function tbUi:OnClose()
    self:CloseTimer();
end

function tbUi:EmptyTime()
    if self.nTotalTime <= 0 then
        self.nTimeTimer = nil;
        return;
    end

    self.nTimeTimer = Timer:Register(self.nTotalTime * Env.GAME_FPS, self.EmptyTime, self);
end

function tbUi:OnUpdateTime()
    self.nUpdateTimer = nil;
    if not self.nTimeTimer then
        self.pPanel:Label_SetText("Time", "0");
        return;
    end

    local nLastTime = math.floor(Timer:GetRestTime(self.nTimeTimer) / Env.GAME_FPS);
    if nLastTime <= 0 then
        nLastTime = 0;
    end

    self.pPanel:Label_SetText("Time", Lib:TimeDesc3(nLastTime));
    self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self)
end

function tbUi:CloseTimer()
    if self.nTimeTimer then
        Timer:Close(self.nTimeTimer);
        self.nTimeTimer = nil;
    end

    if self.nUpdateTimer then
        Timer:Close(self.nUpdateTimer);
        self.nUpdateTimer = nil;
    end
end

function tbUi:UpdateInfo(nMyScore, nEnemyScore, nMyTotalDmg, nEnemyTotalDmg, szStateInfo,nStartTime)
    if nMyScore and nMyScore >= 0 then
        self.pPanel:Label_SetText("MyScore", nMyScore);
    end

    if nEnemyScore and nEnemyScore >= 0 then
        self.pPanel:Label_SetText("EnemyScore", nEnemyScore);
    end

    if nMyTotalDmg and nMyTotalDmg >= 0 then
        self.pPanel:Label_SetText("MyOutputDamage", "输出:"..nMyTotalDmg);
    end

    if nEnemyTotalDmg and nEnemyTotalDmg >= 0 then
        self.pPanel:Label_SetText("EnemyOutputDamage", "输出:"..nEnemyTotalDmg);
    end

    if szStateInfo and szStateInfo ~= "" then
        local szInfo = string.format("[73CBD5FF]%s[-]", szStateInfo);
        if self.nFightTimes then
            local nFightTimes = self.nFightTimes;
            if szStateInfo == "等待匹配" then
                nFightTimes = nFightTimes + 1;
            end
            szInfo = string.format("[73CBD5FF]第[-][FFFE0D]%s[-][73CBD5FF]/%s场%s[-]", nFightTimes, self.nMaxFightTimes, szStateInfo);
        end

        self.pPanel:Label_SetText("StateTxt", szInfo);
    end

    if nStartTime and nStartTime > 0 then
        self:CloseTimer();
        self.pPanel:Label_SetText("Time", Lib:TimeDesc3(nStartTime));
        self.nTimeTimer = Timer:Register(nStartTime * Env.GAME_FPS, self.EmptyTime, self);
        self.nUpdateTimer = Timer:Register(Env.GAME_FPS, self.OnUpdateTime, self);
    end
end

function tbUi:OnChangeTime(nTime)
    self.nTotalTime = nTime;
    self:UpdateInfo(-1, -1, -1, -1,"", nTime);
end

function tbUi:OnChangeFightInfo(nMyScore, nEnemyScore,nMyTotalDmg, nEnemyTotalDmg,szStateInfo)
    self:UpdateInfo(nMyScore, nEnemyScore,nMyTotalDmg, nEnemyTotalDmg,szStateInfo);
end

function tbUi:HideStarTowerScore( bShowTime )
    print("in HideStarTowerScore  bShowTime = "..tostring(bShowTime));
    self.pPanel:SetActive("StarTowerScore", false);
    self.pPanel:SetActive("Time", bShowTime);
end

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        {UiNotify.emNOTIFY_TEAM_BATTLE_KILL_INFO,       self.OnChangeFightInfo, self},
        {UiNotify.emNOTIFY_TEAM_BATTLE_TIME,            self.OnChangeTime, self},
        {UiNotify.emNOTIFY_TEAM_BATTLE_HIDE_SCORE,      self.HideStarTowerScore, self},
    };

    return tbRegEvent;
end
