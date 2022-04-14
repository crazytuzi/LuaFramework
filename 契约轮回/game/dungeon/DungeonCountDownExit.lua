DungeonCountDownExit = DungeonCountDownExit or class("DungeonCountDownExit", BaseItem);
local this = DungeonCountDownExit

function DungeonCountDownExit:ctor(parent_node, layer, time)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonCountDownExit"
    self.layer = layer or "UI"
    self.events = {};
    self.schedules = {};
    self.time = time;
    self.items = {};
    self.formatTime = "%d";
    self.isShowMin = false;--是否需要显示分钟--默认为true
    self.isShowHour = false;--是否需要显示小时--默认为false
    self.isShowDay = false;--是否需要显示天数
    self.formatText = "%s";
    self.duration = 0.3;
    DungeonCountDownExit.super.Load(self)
end

function DungeonCountDownExit:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self:StopSchedule();
end

function DungeonCountDownExit:LoadCallBack()
    self.nodes = {
        "bg", "time_txt",
    }
    self:GetChildren(self.nodes)

    self:InitUI();

    self:AddEvents();

    if self.time then
        self:Start(self.time , self.callback);
    end
end

function DungeonCountDownExit:Start(time, callback)
    self.time = time;
    self.callback = callback;
    self.time_txt.text = "";
    local timeTab = TimeManager:GetLastTimeData(os.time(), time);
    if timeTab then
        self:StopSchedule();
        self.schedule = GlobalSchedule.StartFun(handler(self, self.CountTime), self.duration, -1);
        self.isRuning = true;
        self:CountTime();
    else
        if callback then
            callback();
        end
        self:destroy();
    end
end

function DungeonCountDownExit:CountTime()
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.time);
    local timestr = "";
    if timeTab then
        if self.isShowMin then
            timeTab.min = timeTab.min or 0;
        end
        if self.isShowHour then
            timeTab.hour = timeTab.hour or 0;
        end
        if self.isShowDay then
            timeTab.day = timeTab.day or 0;
        end
        if self.isChineseType then
            if timeTab.day then
                timestr = timestr .. string.format(self.formatTime, timeTab.day) .. "Days ";
            end
            if timeTab.hour then
                timestr = timestr .. string.format(self.formatTime, timeTab.hour) .. "hr ";
            end
            if timeTab.min then
                timestr = timestr .. string.format(self.formatTime, timeTab.min) .. "min ";
            end
        else
            if timeTab.day then
                timestr = timestr .. string.format(self.formatTime, timeTab.day) .. ":";
            end
            if timeTab.hour then
                timestr = timestr .. string.format(self.formatTime, timeTab.hour) .. ":";
            end
            if timeTab.min then
                timestr = timestr .. string.format(self.formatTime, timeTab.min) .. ":";
            end
        end
        if self.isChineseType then
            if timeTab.sec then
                timestr = timestr .. string.format(self.formatTime, timeTab.sec) .. "sec";
            end
        else
            if timeTab.sec then
                timestr = timestr .. string.format(self.formatTime, timeTab.sec);
            end
        end
        self.time_txt.text = string.format(self.formatText, timestr);
        self.isRuning = true;
    else
        if self.schedule then
            GlobalSchedule:Stop(self.schedule);
        end
        if self.callback then
            self.callback();
        end
        self.time_txt.text = "";
        self.time_txt.gameObject:SetActive(false);

        self.isRuning = false;
        self.schedule = nil;

        self:destroy();
    end
end

function DungeonCountDownExit:InitUI()
    self.time_txt = GetText(self.time_txt);
end

function DungeonCountDownExit:AddEvents()
    AddEventListenerInTab(EventName.ChangeSceneEnd, handler(self, self.HandleChangeScene), self.events);
end

--@ling autofun
function DungeonCountDownExit:HandleChangeScene()
    self:destroy();
end
function DungeonCountDownExit:StopSchedule()
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end
end