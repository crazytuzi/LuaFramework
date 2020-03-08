
local tbUi = Ui:CreateClass("HomeScreenExpBar");
tbUi.nMaxTimePing = 3;
tbUi.nMaxDelayTime = 1000; --毫秒

tbUi.nMaxTimeCheckBattery = 60;

function tbUi:OnOpen()
	self:OnExpChange()
	self:TimerUpdate(true)

    self:SendPing()
    if self.nPingTimer then
        Timer:Close(self.nPingTimer)
        self.nPingTimer = nil;
    end

    self.nPingTimer = Timer:Register(tbUi.nMaxTimePing * Env.GAME_FPS, self.SendPing, self);

    self:CheckBattery()
    if self.nBatteryTimer then
        Timer:Close(self.nBatteryTimer)
        self.nBatteryTimer = nil
    end
    self.nBatteryTimer = Timer:Register(tbUi.nMaxTimeCheckBattery * Env.GAME_FPS,self.CheckBattery,self)

    self.pPanel:SetActive("FreeFlow", Login:IsFreeFlow());

    self.pPanel:SetActive("Lightning", self:IsCharging());
end

function tbUi:CheckBattery()
    local fRemainBattery = self:GetRemainBattery()
    fRemainBattery = tonumber(fRemainBattery)
    if fRemainBattery then
        if fRemainBattery < 0 then
            fRemainBattery = 0
        end
         self.pPanel:Sprite_SetFillPercent("DumpEnergy", fRemainBattery/100);
    end
    return true
end

function tbUi:GetRemainBattery()
    if ANDROID then
        return Ui.UiManager.GetBatteryLevel() or 0;
    elseif IOS then
        return GetAppleBatteryLevel() or 0;
    elseif WINDOWS then
        return 100;
    else
        return 100;
    end
end

function tbUi:IsCharging()
    if ANDROID then
        return Ui.UiManager.IsCharging();
    elseif IOS then
        return IsAppleCharging();
    elseif WINDOWS then
        return false;
    else
        return false;
    end
end

function tbUi:SendPing()
    local fSignal = self:GetSignal();
    self.pPanel:SliderBar_SetValue("SignalBg", fSignal);
    return true;
end

function tbUi:GetSignal()
    local dwDelayTime = GetPingDelay();
    local fFillDelay = (tbUi.nMaxDelayTime - dwDelayTime) / tbUi.nMaxDelayTime;
    if fFillDelay <= 0.0001 then
        fFillDelay = 0.0001;
    end
    if fFillDelay == 0.0001 then
        return 0;
    elseif fFillDelay <= 0.25 then
        return 0.25;
    elseif fFillDelay <=0.5 then
        return 0.5;
    elseif fFillDelay <= 0.75 then
        return 0.75;
    else
        return 1;
    end
end

function tbUi:OnClose()
	if self.nTimerId then
		Timer:Close(self.nTimerId)
		self.nTimerId = nil;
	end

    if self.nPingTimer then
        Timer:Close(self.nPingTimer)
        self.nPingTimer = nil;
    end

    if self.nBatteryTimer then
        Timer:Close(self.nBatteryTimer)
        self.nBatteryTimer = nil
    end
end

function tbUi:OnExpChange()
	local nExpPercent = me.GetExp() / me.GetNextLevelExp();
	self.pPanel:Label_SetText("TxtPercent", string.format("%d%%", nExpPercent * 100))
	self.pPanel:Sprite_SetFillPercent("Exp", nExpPercent)
	local szExp = string.format("%s / %s (%0.2f%%)", me.GetExp(),me.GetNextLevelExp(), nExpPercent * 100)
	self.pPanel:Label_SetText("Label",szExp)
end

function tbUi:TimerUpdate(bUpdateGMT)
	if not self.nTimerId then
        self.nTimerId = Timer:Register(Env.GAME_FPS * 3, self.TimerUpdate, self) -- 3秒更新一次
    end

    local nTime = GetTime()
    local tbDate = os.date("*t", nTime)
    local bClientIsDST = tbDate.isdst
    local bServerIsDST = Env.bIsDST

    if bServerIsDST ~= nil then
        if bClientIsDST ~= bServerIsDST then
            if bClientIsDST then
                nTime = nTime - 3600
            else
                nTime = nTime + 3600
            end
        end
    end

    self.pPanel:Label_SetText("TxtTime", Lib:LocalDate("%H:%M", nTime, bUpdateGMT))
    return true;
end


function tbUi:RegisterEvent()
    local tbRegEvent =
    {
        { UiNotify.emNOTIFY_CHANGE_PLAYER_EXP,      self.OnExpChange},
        { UiNotify.emNOTIFY_CHANGE_PLAYER_LEVEL,    self.OnExpChange},
        { UiNotify.emNOTIFY_ON_BATTERY_STATE_CHANGE, self.OnRefreshBatteryState, self },
    };

    return tbRegEvent;
end

function tbUi:OnRefreshBatteryState(bIsCharging)
    Log("OnRefreshBatteryState", tostring(bIsCharging))
    self.pPanel:SetActive("Lightning", bIsCharging);
end

