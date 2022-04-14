---
--- Created by  Administrator
--- DateTime: 2019/8/23 15:54
---
SevenDayPetTargetPanel = SevenDayPetTargetPanel or class("SevenDayPetTargetPanel", BaseItem)
local this = SevenDayPetTargetPanel

function SevenDayPetTargetPanel:ctor(parent_node, parent_panel,actID, assetName)

    self.abName = "sevenDayActive"
    self.assetName = assetName or "SevenDayPetTargetPanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    self.stype = 3
    self.is_ill = assetName
    self.model = SevenDayActiveModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    self.events = {}
    self.mEvents = {}
    self.rewardItems = {}
    SevenDayPetTargetPanel.super.Load(self)
end

function SevenDayPetTargetPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    for _, item in pairs(self.rewardItems) do
        item:destroy()
    end
    self.rewardItems = {}

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    if self.effect then
        self.effect:destroy()
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
    self.parentPanel = nil
end

function SevenDayPetTargetPanel:LoadCallBack()
    self.nodes = {
        "tex/rtime","tex/time","SevenDayPetRechargeItem","ScrollView/Viewport/rewardContent","tex/des",
        "ScrollView/Viewport","bg/leftbg",
    }
    self:GetChildren(self.nodes)
    self.time = GetText(self.time)
    self.rtime = GetText(self.rtime)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()

    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);
end

function SevenDayPetTargetPanel:InitUI()
    -- logError(self.actID)
    local cfg =  OperateModel:GetInstance():GetConfig(self.actID)
    --dump(cfg)
    self.des.text = "Event Rules:"..cfg.desc
    self:SetMask()
    self:InitActTime()
    self:UpdateRewards(self.data.tasks)
    if self.is_ill then
       self:SetEffect()
    end
end

function SevenDayPetTargetPanel:AddEvent()

    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandlerRewardInfo))
    self.mEvents[#self.mEvents+1] = self.model:AddListener(SevenDayActiveEvent.PaySucc,handler(self,self.PaySucc))
    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.DLIVER_YY_INFO))
end

function SevenDayPetTargetPanel:HandlerRewardInfo(data)
    if data.act_id == self.actID then
        Notify.ShowText("Claimed")
        self.data = OperateModel:GetInstance():GetActInfo(self.actID)
        self:UpdateRewards(self.data.tasks)
    end
end

function SevenDayPetTargetPanel:DLIVER_YY_INFO(data)
    --print2(data.id,self.actID)
    if data.id == self.actID then
        self:UpdateRewards(data.tasks)
    end
end

function SevenDayPetTargetPanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end


function SevenDayPetTargetPanel:UpdateRewards(tab)
    local rewards = tab
    self.rewardItems = self.rewardItems or {}

    table.sort(rewards, function(a,b)
        local r
        if a.state == b.state then
            r = a.id < b.id
        else
            r = a.state < b.state
        end
        return r
    end)
    for i = 1, #rewards do
        local item = self.rewardItems[i]
        if not item then
            item  =   SevenDayPetRechargeItem(self.SevenDayPetRechargeItem.gameObject,self.rewardContent,"UI")
            self.rewardItems[i] = item
        else
            item:SetVisible(true)
        end
        item:SetData(rewards[i],self.actID,self.stype,self.StencilId)
    end
    for i = #tab + 1,#self.rewardItems do
        local Item = self.rewardItems[i]
        Item:SetVisible(false)
    end
end


function SevenDayPetTargetPanel:PaySucc()
    local data = OperateModel:GetInstance():GetActInfo(self.actID)
    self:UpdateRewards(data.tasks)
end

function SevenDayPetTargetPanel:InitActTime()
    local stime = self:GetActTime(self.openData.act_stime)
    local etime = self:GetActTime(self.openData.act_etime)
    self.time.text = string.format("Event Time: %s-%s",stime,etime)
end

function SevenDayPetTargetPanel:GetActTime(time)
    local timeTab = TimeManager:GetTimeDate(time)
    local timestr = "";
    if timeTab.month then
        timestr = timestr .. string.format("%02d", timeTab.month) .. "M";
    end
    if timeTab.day then
        timestr = timestr .. string.format("%d", timeTab.day) .. "Sunday ";
    end
    if timeTab.hour then
        timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
    end
    if timeTab.min then
        timestr = timestr .. string.format("%02d", timeTab.min) .. "";
    end
    return timestr
end

function SevenDayPetTargetPanel:CountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";
    timeTab = TimeManager:GetLastTimeData(os.time(), self.openData.act_etime);
    if table.isempty(timeTab) then
        Notify.ShowText("The event is over");
        -- self.rtime.text = "活动剩余：已结束"
        self.rtime.text = string.format("<color=#%s>%s</color>","ff0000","Ended")
        GlobalSchedule.StopFun(self.schedules);
    else
        if timeTab.day then
            timestr = timestr .. string.format(formatTime, timeTab.day) .. "Days";
        end
        if timeTab.hour then
            timestr = timestr .. string.format(formatTime, timeTab.hour) .. "hr";
        end
        if timeTab.min then
            timestr = timestr .. string.format(formatTime, timeTab.min) .. "min";
        end
        if timeTab.sec and not timeTab.day and not timeTab.hour and not timeTab.min then
            timestr = "1 pts"
        end
        --if timeTab.sec then
        --    timestr = timestr .. string.format(formatTime, timeTab.sec);
        --end
        local color  = "53ff67"
        if not timeTab.day then
            color = "ff0000"
        end
        self.rtime.text = string.format("<color=#%s>%s</color>",color,timestr)
        -- self.rtime.text = "活动剩余：" .. timestr;
    end

end

function SevenDayPetTargetPanel:SetEffect()
    if not self.effect then
        self.effect = UIEffect(self.leftbg, 10311, false)
        --self.effect:SetOrderIndex(101)
        local cfg = {}
        cfg.scale = 1.25
        cfg.pos = {x= 0, y=-100,z=0}
        self.effect:SetConfig(cfg)
    end
    local img = GetChild(self.leftbg.transform,"img")
    local action = cc.MoveTo(1, 0, 90)
    action = cc.Sequence(action, cc.MoveTo(1, 0, 75))
    action = cc.Repeat(action, 4)
    action = cc.RepeatForever(action)
    cc.ActionManager:GetInstance():addAction(action, img.transform)
end

