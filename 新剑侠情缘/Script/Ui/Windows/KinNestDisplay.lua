local tbUi = Ui:CreateClass("KinNestDisplay");

function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_MAP_LEAVE, self.Close, self },
    };

    return tbRegEvent;
end

function tbUi:OnOpen(date)
	self.nNpcNumber = date.nNpcNumber;
	self.nLastTime = date.nLastTime;
    self.nPlayerNumber = date.nPlayerNumber;
    self.pPanel:Label_SetText("Title", "奸商地窖");
    self.nTimer = Timer:Register(Env.GAME_FPS * 1, self.UpdateLastTime, self);

    if date.bFireTimer == true then
        self.nFireTimer = date.nFireTimer;
    elseif date.bBossNumber == true then
        self.nBossNumber = date.nBossNumber;
    end
    self:Update();
end

function tbUi:Close()
    Ui:CloseWindow(self.UI_NAME);
end

function tbUi:OnClose()
    if self.nTimer then
        Timer:Close(self.nTimer)
        self.nTimer = nil;
    end
    if self.nTimerFire then
        Timer:Close(self.nTimerFire);
        self.nTimerFire = nil;
    end
end

function tbUi:UpdateFireTime()
    local nLastTime = self.nFireTimer or 10 * 60;
    local nLastMin  = math.floor(nLastTime / 60);
    local nLastSec  = nLastTime % 60;
    local szTime    = string.format("%d:%d", nLastMin, nLastSec);
    self.pPanel:Label_SetText("ExpRate", szTime);
    self.pPanel:Label_SetText("ExpRateLabel", "篝火时间:");

    self.nFireTimer = self.nFireTimer - 1;

    if self.nLastTime < 0 then
        self.pPanel:Label_SetText("ExpRate", "已结束")
        return
    end

    return true
end

function tbUi:UpdateLastTime()
    local nLastTime = self.nLastTime or 10 * 60;
    local nLastMin  = math.floor(nLastTime / 60);
    local nLastSec  = nLastTime % 60;
    local szTime    = string.format("%d:%d", nLastMin, nLastSec);
    self.pPanel:Label_SetText("RemainingTime", szTime);

    self.nLastTime = self.nLastTime - 1;

    if self.nLastTime < 0 then
        self.pPanel:Label_SetText("RemainingTime", "已结束")
        return
    end

    if self.nFireTimer then 
        local nLastTime = self.nFireTimer or 10 * 60;
        local nLastMin  = math.floor(nLastTime / 60);
        local nLastSec  = nLastTime % 60;
        local szTime    = string.format("%d:%d", nLastMin, nLastSec);
        self.pPanel:Label_SetText("ExpRate", szTime);
        self.pPanel:Label_SetText("ExpRateLabel", "篝火时间:");
    
        self.nFireTimer = self.nFireTimer - 1;
    
        if self.nFireTimer < 0 then
            self.pPanel:Label_SetText("ExpRate", "已结束")
            return true;
        end
    end

    return true;
end

function tbUi:Update()
    local szMemberNum = string.format("%d", self.nPlayerNumber or 0)
    self.pPanel:Label_SetText("PeopleNumber", szMemberNum);
    if self.nBossNumber and not self.nFireTimer then 
        local szMemberNum = string.format("%d", self.nBossNumber or 0)
        self.pPanel:Label_SetText("ExpRate", szMemberNum);
    end
    if not self.nFireTimer and not self.nBossNumber then
        local szMemberNum = string.format("%d", self.nNpcNumber or 0)
        self.pPanel:Label_SetText("ExpRate", szMemberNum);
    end
end

