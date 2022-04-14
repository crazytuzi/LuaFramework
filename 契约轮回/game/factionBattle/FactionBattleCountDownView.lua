---
--- Created by  R2D2
--- DateTime: 2019/2/23 16:18
---
---公会战剩余时间计时
FactionBattleCountDownView = FactionBattleCountDownView or class("FactionBattleCountDownView", BaseItem)
local this = FactionBattleCountDownView

function FactionBattleCountDownView:ctor(parent_node, layer)
    self.alertTime = 100 * 60

    self.abName = "factionbattle"
    self.assetName = "FactionBattleCountDownView"
    self.layer = layer
    self.model = FactionBattleModel:GetInstance()
    self.events = {}
    FactionBattleCountDownView.super.Load(self)
end

function FactionBattleCountDownView:dctor()
    self:StopSchedule()
    self:StopWaitSchedule()
    GlobalEvent:RemoveTabListener(self.events)
end

function FactionBattleCountDownView:LoadCallBack()
    self.nodes = {"Timer"}
    self:GetChildren(self.nodes)

    self:InitUI()
    self:AddEvent()
    self:CheckCountDown()
end

function FactionBattleCountDownView:InitUI()
    self.countDownText = GetText(self.Timer)
end

function FactionBattleCountDownView:AddEvent()
    self.events[#self.events + 1] =
        GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, handler(self, self.OnMainTopRightHide))
    self.events[#self.events + 1] =
        GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, handler(self, self.OnMainTopRightShow))
end

function FactionBattleCountDownView:OnMainTopRightHide()
    SetVisible(self.transform, true)
end

function FactionBattleCountDownView:OnMainTopRightShow()
    SetVisible(self.transform, false)
end

function FactionBattleCountDownView:CheckCountDown()
    self:StopWaitSchedule()

    if (self.model.endTime) then
        self.EndTime = self.model.endTime

        local alert = self.EndTime - self.alertTime
        local serverTime = TimeManager.Instance:GetServerTime()

        if (alert >= serverTime) then
            SetVisible(self, false)
            local waitTime = alert - serverTime
            self.WaitSchedule = GlobalSchedule.StartFunOnce(handler(self, self.EndWait), waitTime)
        else
            self:ShowCountDown()
        end
    else
        SetVisible(self, false)
    end
end

function FactionBattleCountDownView:EndWait()
    self:StopWaitSchedule()
    self:ShowCountDown()
end

function FactionBattleCountDownView:ShowCountDown()
    SetVisible(self, true)

    self:StopSchedule()
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.EndTime)
    if (timeTab) then
        self.schedule = GlobalSchedule.StartFun(handler(self, self.StartCountDown), 1, -1)
    end
end

function FactionBattleCountDownView:StartCountDown()
    local timeTab = TimeManager:GetLastTimeData(TimeManager.Instance:GetServerTime(), self.EndTime)
   
    local minStr = ""
    local secStr = ""

    if timeTab then
        if (timeTab.hour) then
            local hourStr = string.format("%02d", timeTab.hour or 0)
            minStr = string.format("%02d", timeTab.min or 0)
            secStr = string.format("%02d", timeTab.sec or 0)
            self.countDownText.text = string.format("%s：%s：%s", hourStr, minStr, secStr)
        else
            minStr = string.format("%02d", timeTab.min or 0)
            secStr = string.format("%02d", timeTab.sec or 0)
            self.countDownText.text = string.format("%s：%s", minStr, secStr)
        end
    else
        self:StopSchedule()
    end
end

function FactionBattleCountDownView:StopWaitSchedule()
    if self.WaitSchedule then
        GlobalSchedule:Stop(self.WaitSchedule)
    end
    self.WaitSchedule = nil
end

function FactionBattleCountDownView:StopSchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule)
    end
    self.countDownText.text = "00_00_00"
end
