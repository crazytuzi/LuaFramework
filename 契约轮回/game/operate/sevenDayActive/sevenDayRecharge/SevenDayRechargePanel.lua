---
--- Created by  Administrator
--- DateTime: 2019/4/18 15:37
---
SevenDayRechargePanel = SevenDayRechargePanel or class("SevenDayRechargePanel", BaseItem)
local this = SevenDayRechargePanel

function SevenDayRechargePanel:ctor(parent_node, parent_panel,actID)
    self.abName = "sevenDayActive"
    self.assetName = "SevenDayRechargePanel"
    self.layer = "UI"
    self.parentPanel = parent_panel
    self.events = {}
    self.actID = actID
    self.stype = 1
    self.model = SevenDayActiveModel:GetInstance()
    self.openData = OperateModel:GetInstance():GetAct(self.actID)
    self.data = OperateModel:GetInstance():GetActInfo(self.actID)
   -- dump(self.data)
    self.events = {}
    self.mEvents = {}
    self.rewardItems = {}
    self:BeforeLoad()
end

function SevenDayRechargePanel:BeforeLoad()
    SevenDayRechargePanel.super.Load(self)
end

function SevenDayRechargePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.mEvents)
    for _, item in pairs(self.rewardItems) do
        item:destroy()
    end
    self.rewardItems = {}




    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    if self.StencilMask then
        destroy(self.StencilMask)
        self.StencilMask = nil
    end
end

function SevenDayRechargePanel:LoadCallBack()
    self.nodes = {
        "tex/rtime","tex/time","SevenDayRechargeItem","ScrollView/Viewport/rewardContent","tex/des",
        "ScrollView/Viewport"
    }
    self:GetChildren(self.nodes)
    self.time = GetText(self.time)
    self.rtime = GetText(self.rtime)
    self.des = GetText(self.des)
    self:InitUI()
    self:AddEvent()

    self.schedules = GlobalSchedule:Start(handler(self, self.CountDown), 0.2, -1);
end

function SevenDayRechargePanel:InitUI()
    --dump(self.data)
    local cfg =  OperateModel:GetInstance():GetConfig(self.actID)
    --dump(cfg)
    self.des.text = "Event Rules:"..cfg.desc
    self:SetMask()
    self:InitActTime()
    self:UpdateRewards(self.data.tasks)
end

function SevenDayRechargePanel:AddEvent()


   self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.SUCCESS_GET_REWARD, handler(self, self.HandlerRewardInfo))
   self.mEvents[#self.mEvents+1] = self.model:AddListener(SevenDayActiveEvent.PaySucc,handler(self,self.PaySucc))
    self.events[#self.events + 1] = GlobalEvent:AddListener(OperateEvent.DLIVER_YY_INFO, handler(self, self.DLIVER_YY_INFO))
end

function SevenDayRechargePanel:HandlerRewardInfo(data)
    if data.act_id == self.actID then
        Notify.ShowText("Claimed")
        self.data = OperateModel:GetInstance():GetActInfo(self.actID)
        self:UpdateRewards(self.data.tasks)
    end

end

function SevenDayRechargePanel:DLIVER_YY_INFO(data)
    --print2(data.id,self.actID)
    if data.id == self.actID then
        self:UpdateRewards(data.tasks)
    end

end

function SevenDayRechargePanel:PaySucc()
   -- print2("充值成功")
  --  dump(self.data)
    --self.data = OperateModel:GetInstance():GetActInfo(self.actID)
    --self:UpdateRewards(self.data.tasks)
   -- OperateController:GetInstance():Request1700006(self.actID)
end


function SevenDayRechargePanel:SetMask()
    self.StencilId = GetFreeStencilId()
    self.StencilMask = AddRectMask3D(self.Viewport.gameObject)
    self.StencilMask.id = self.StencilId
end

function SevenDayRechargePanel:UpdateRewards(tab)
    local rewards = tab
    self.rewardItems = self.rewardItems or {}

    table.sort(rewards, function(a,b)
        local r
        if a.state == b.state then
            r = a.level < b.level
        else
            r = a.state < b.state
        end
        return r
    end)

    for i = 1, #rewards do
        local item = self.rewardItems[i]
        if not item then
            item  =   SevenDayRechargeItem(self.SevenDayRechargeItem.gameObject,self.rewardContent,"UI")
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

function SevenDayRechargePanel:InitActTime()
    local stime = self:GetActTime(self.openData.act_stime)
    local etime = self:GetActTime(self.openData.act_etime)
    self.time.text = string.format("Event Time: %s-%s",stime,etime)
end

function SevenDayRechargePanel:GetActTime(time)
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

function SevenDayRechargePanel:CountDown()
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
        local color  = "27C31F"
        if not timeTab.day then
            color = "ff0000"
        end
        self.rtime.text = string.format("<color=#%s>%s</color>",color,timestr)
        -- self.rtime.text = "活动剩余：" .. timestr;
    end

end

