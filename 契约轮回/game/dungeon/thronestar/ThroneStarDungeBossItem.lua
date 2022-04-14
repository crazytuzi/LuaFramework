---
--- Created by  Administrator
--- DateTime: 2020/4/3 16:17
---
ThroneStarDungeBossItem = ThroneStarDungeBossItem or class("ThroneStarDungeBossItem", BaseCloneItem)
local this = ThroneStarDungeBossItem

function ThroneStarDungeBossItem:ctor(obj, parent_node, parent_panel)
    self.events = {}
    self.model = ThroneStarModel.GetInstance()
    ThroneStarDungeBossItem.super.Load(self)
end

function ThroneStarDungeBossItem:dctor()
    self.model:RemoveTabListener(self.events)
    if self.schedule then
        --print2("=========================" .. self.schedule)
        GlobalSchedule:Stop(self.schedule);
    end
    self.schedule = nil
end

function ThroneStarDungeBossItem:LoadCallBack()
    self.nodes = {
        "boss_name", "item_bg", "status", "selected", "statustime", "order_img"
    }
    self:GetChildren(self.nodes)
    self.boss_name = GetText(self.boss_name);
    self.status = GetText(self.status);
    self.selected = GetImage(self.selected);
    self.statustime  = GetText(self.statustime)
    SetVisible(self.order_img,false)
    SetVisible(self.statustime,false)
    self:SetSelected(false)
    self:InitUI()
    self:AddEvent()
end

function ThroneStarDungeBossItem:InitUI()

end

function ThroneStarDungeBossItem:AddEvent()
    self.events[#self.events + 1] =  self.model:AddListener(ThroneStarEvent.ThroneBossUpdateInfo,handler(self,self.ThroneBossUpdateInfo))
end

function ThroneStarDungeBossItem:ThroneBossUpdateInfo(data)
    if data.id == self.data.id then
        self:StartSechudle(data.born)
    end
end

function ThroneStarDungeBossItem:SetData(data,type)
    self.data = data
    self.type = type

    self.bossCfg = Config.db_throne_boss[self.data.id]
   -- self.boss_name.text = self.bossCfg.name


    if self.type == 1 then
        self:StartSechudle(self.data.born)
        self.boss_name.text = "<color=#ffffff>" .. self.bossCfg.name .. "  " .. string.format(ConfigLanguage.Common.Level, self.data.level) .. "</color>";
    else
        local cfg = Config.db_creep[self.data.id]
        self.boss_name.text = "<color=#ffffff>" .. cfg.name.."      "..string.format(ConfigLanguage.Common.Level, cfg.level) .. "</color>";
        SetVisible(self.status,false)
    end

end

function ThroneStarDungeBossItem:StartSechudle(time)
    self.time = time;
    self.status.text = "";
    local timeTab = TimeManager:GetLastTimeData(os.time(), time);
    if timeTab then
        if self.schedule then
            --logError("=========================" .. self.schedule)
            GlobalSchedule:Stop(self.schedule);
            self.schedule = nil
        end
        self.schedule = GlobalSchedule.StartFun(handler(self, self.CountTime), 1, -1);
        self:CountTime();
    else
        self.status.text = "Refreshed";
    end
end

function ThroneStarDungeBossItem:CountTime()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.time);
    local timestr = "";
   -- logError(Table2String(timeTab))

    if timeTab then
        timeTab.hour = timeTab.hour or 0;
        timeTab.min = timeTab.min or 0;
        if timeTab.hour then
            timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
        end
        if timeTab.min then
            timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
        end
        if timeTab.sec then
            timestr = timestr .. string.format("%02d", timeTab.sec);
        end
        SetVisible(self.statustime, true);
        SetVisible(self.status, false);
        self.statustime.text = "<color=#D6302F>" .. timestr .. "</color>";
       -- logError(self.statustime.text)
    else
        if self.schedule then
            GlobalSchedule:Stop(self.schedule);
        end
        SetGameObjectActive(self.statustime, false);
        SetGameObjectActive(self.status, true);
        self.status.text = "Refreshed"
        self.schedule = nil;
    end
end

function ThroneStarDungeBossItem:SetSelected(bool)
    bool = toBool(bool);
    self.selected.gameObject:SetActive(bool);
end