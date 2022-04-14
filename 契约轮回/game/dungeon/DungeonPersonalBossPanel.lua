DungeonPersonalBossPanel = DungeonPersonalBossPanel or class("DungeonPersonalBossPanel", DungeonMainBasePanel)
local DungeonPersonalBossPanel = DungeonPersonalBossPanel

function DungeonPersonalBossPanel:ctor()
    self.abName = "dungeon"
    self.assetName = "DungeonPersonalBossPanel"

    self.model = DungeonModel:GetInstance()
    self.events = {}
end

function DungeonPersonalBossPanel:dctor()
    for i = 1, #self.events do
        self.model:RemoveListener(self.events[i])
    end
    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules)
    end
    self.timeschedules = nil;

    if self.schedules then
        GlobalSchedule:Stop(self.schedules);
    end
    self.schedules = nil;
end

function DungeonPersonalBossPanel:Open()
    DungeonPersonalBossPanel.super.Open(self)
end

function DungeonPersonalBossPanel:LoadCallBack()
    self.nodes = {
        "endTime/endTitleTxt", "endTime", "startTime/time", "startTime",
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.time = GetText(self.time)
    self:AddEvent()
    --为了红点
    DungeonCtrl:GetInstance():RequestDungeonPanel(enum.SCENE_STYPE.SCENE_STYPE_DUNGE_ROLE_BOSS)
end

function DungeonPersonalBossPanel:AddEvent()
    local function callBack(data)
        self:UpdateView()
    end
    self.events[#self.events + 1] = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, callBack)
end

function DungeonPersonalBossPanel:OpenCallBack()
    self:UpdateView()
end

function DungeonPersonalBossPanel:UpdateView()
    local data = self.model.DungeEnter[self.model.curDungeonID]
    if data then
        self.end_time = data.etime
        if self.timeschedules then
            GlobalSchedule:Stop(self.timeschedules);
        end
        self.timeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1)

        if data.ptime and not self.start_dungeon_time then
            if data.ptime < os.time() then
                self.start_dungeon_time = 0
                self.time.text = tostring(self.start_dungeon_time)
                self:StartDungeon()
            else
                local preptime = data.ptime
                local ostime = math.round(os.time())
                self.start_dungeon_time = preptime - ostime - 1
                self.time.text = tostring(self.start_dungeon_time)
                self.schedules = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1)
            end
        end
    end
end

function DungeonPersonalBossPanel:CloseCallBack()

end

function DungeonPersonalBossPanel:StartDungeon()
    self.start_dungeon_time = self.start_dungeon_time - 1;
    self.time.text = tostring(self.start_dungeon_time);
    if self.start_dungeon_time <= 0 then
        self.startTime.gameObject:SetActive(false);

        if self.schedules then
            GlobalSchedule:Stop(self.schedules);
        end
        self.schedules = nil;
        --防止自动战斗不打
        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
        --停止自动寻路
        OperationManager:GetInstance():StopAStarMove();
    end
end

function DungeonPersonalBossPanel:EndDungeon()
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
            self.endTitleTxt.text = timestr;--"倒计时: " ..
        end
    end

    if self.schedules then
        SetVisible(self.endTime, false)
    end
end