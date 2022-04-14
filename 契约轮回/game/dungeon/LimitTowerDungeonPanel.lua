---
--- Created by  Administrator
--- DateTime: 2019/11/1 14:58
---
LimitTowerDungeonPanel = LimitTowerDungeonPanel or class("LimitTowerDungeonPanel", DungeonMainBasePanel)
local this = LimitTowerDungeonPanel

function LimitTowerDungeonPanel:ctor(parent_node, parent_panel)
    self.abName = "dungeon"
    self.assetName = "LimitTowerDungeonPanel"
    self.events = {}
    self.schedules = {}
    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_YUNYING_LIMITTOWER
    self.use_background = false
    self.change_scene_close = true
end

function LimitTowerDungeonPanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    --if self.timeschedules then
    --    GlobalSchedule:Stop(self.timeschedules);
    --end
    --
    --if self.startSchedule then
    --    GlobalSchedule.StopFun(self.startSchedule);
    --end
    --self.startSchedule = nil;

    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end
    self:StopAllSchedules()
end

function LimitTowerDungeonPanel:LoadCallBack()
    self.nodes = {
        "endTime/endTitleTxt", "endTime", "hardshow/floorTex", "hardshow",
        "startTime", "startTime/time",
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.floorTex = GetText(self.floorTex);
    self.time = GetText(self.time);
    SetVisible(self.endTime,false)
    SetAlignType(self.hardshow.transform, bit.bor(AlignType.Left, AlignType.Null))
    self:InitUI()
    self:AddEvent()
    DungeonCtrl:GetInstance():RequeseExpDungeonInfo()
end

function LimitTowerDungeonPanel:InitUI()

end

function LimitTowerDungeonPanel:AddEvent()
  --  self.equipschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

    local function callBack()
        SetGameObjectActive(self.endTime.gameObject, true);
        self.hideByIcon = false;
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.HideTopRightIcon, callBack)

  --  AddEventListenerInTab(DungeonEvent.UpdateReddot, handler(self, self.UpdateReddot), self.events);

    local function callBack()
        SetGameObjectActive(self.endTime.gameObject, false);
        self.hideByIcon = true;
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.ShowTopRightIcon, callBack)

    local function callBack(data)
        if self.timeschedules then
            GlobalSchedule:Stop(self.timeschedules);
        end
        SetVisible(self.endTime, false)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_AUTO_EXIT, callBack)

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self,self.HandleDungeonInfo))



end



function LimitTowerDungeonPanel:HandleDungeonInfo(data)
    self.end_time = data.end_time
    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
    end
    self.timeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

    OperationManager:GetInstance():StopAStarMove();
    AutoFightManager:GetInstance():StartAutoFight()
    local id = DungeonModel:GetInstance().curDungeonID
    if DungeonModel.GetInstance().DungeEnter[id] then
        self.floorTex.text = string.format("%sc", DungeonModel.GetInstance().DungeEnter[id].floor)
    else
        self.floorTex.text = "";
    end

    self:StartDungeonCD();

end


function LimitTowerDungeonPanel:StartDungeonCD()
    SetGameObjectActive(self.startTime, true);
    SetGameObjectActive(self.endTime.gameObject, false);
    local dungeConfig = Config.db_dunge[self.model.curDungeonID];
    if dungeConfig then
        local prep = DungeonModel.GetInstance().DungeEnter[self.model.curDungeonID].ptime;
        self.startDungeonTime = prep

        if self.startSchedule then
            GlobalSchedule.StopFun(self.startSchedule);
        end
        self.endDungeonStartCountDownFun = function()
            if self.startSchedule then
                GlobalSchedule.StopFun(self.startSchedule);
            end
            self.startSchedule = nil;
            SetGameObjectActive(self.endTime.gameObject, true);
        end
        self.time.text = os.time() - prep
        self.startSchedule = GlobalSchedule.StartFun(handler(self, self.HandleDungeonStartCountDown), 0.2, -1);
    end
end

function LimitTowerDungeonPanel:StartDungeon()
    -- local timeTab = nil;
    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
    --停止自动寻路
    OperationManager:GetInstance():StopAStarMove();
    SetGameObjectActive(self.startTime, true);
    SetGameObjectActive(self.endTime.gameObject, false);
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.start_dungeon_time);
    local timestr = "";
    local formatTime = "%02d";
    if table.isempty(timeTab) then
        self.startTime.gameObject:SetActive(false);
        self.endTime.gameObject:SetActive(true)
        if self.schedules[1] then
            GlobalSchedule:Stop(self.schedules[1]);
        end
    else
        --timeTab.min = timeTab.min or 0;
        --timeTab.hour = timeTab.hour or 0;
        --if timeTab.hour then
        --    timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
        --end
        --if timeTab.min then
        --    timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
        --end
        --if timeTab.sec then
        --    timestr = timestr .. string.format("%02d", timeTab.sec);
        --end
        self.time.text = timeTab.sec;--"副本倒计时: " ..
    end
end

function LimitTowerDungeonPanel:EndDungeon()
    --if self.end_time and self.start_dungeon_time <= 0 then
    --    self.endTime.gameObject:SetActive(true);
    --end
    --local timeTab = nil;
    --local timestr = "";
    --local formatTime = "%02d";
    ----整个副本的结束时间
    --if self.end_time then
    --    --SetGameObjectActive(self.endTime.gameObject, true);
    --    timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
    --    if table.isempty(timeTab) then
    --        Notify.ShowText("副本结束了,需要做清理了");
    --        GlobalSchedule.StopFun(self.equipschedules);
    --    else
    --        if timeTab.min then
    --            timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
    --        end
    --        if timeTab.sec then
    --            timestr = timestr .. string.format(formatTime, timeTab.sec);
    --        end
    --        self.endTitleTxt.text = timestr;--"副本倒计时: " ..
    --    end
    --end
    --LimitTowerDungeonPanel.super.EndDungeon(self);
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    if self.end_time then
        SetVisible(self.endTime, true)
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            Notify.ShowText("The dungeon is over. It's time to clean up");
            GlobalSchedule.StopFun(self.timeschedules);
        else
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endTitleTxt.text = timestr;--"副本倒计时: " ..
        end
    end

    LimitTowerDungeonPanel.super.EndDungeon(self);
end


function  LimitTowerDungeonPanel:StopAllSchedules()
    if self.startSchedule then
        GlobalSchedule.StopFun(self.startSchedule);
    end
    self.startSchedule = nil;

    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
    end
    self.timeschedules = nil

end
