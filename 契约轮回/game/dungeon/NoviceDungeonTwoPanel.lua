NoviceDungeonTwoPanel = NoviceDungeonTwoPanel or class("NoviceDungeonTwoPanel", DungeonMainBasePanel)
local NoviceDungeonTwoPanel = NoviceDungeonTwoPanel

function NoviceDungeonTwoPanel:ctor()
    self.abName = "dungeon"
    self.imageAb = "dungeon_image"
    self.assetName = "NoviceDungeonTwoPanel"
    self.events = {}
    self.mType = 0
    self.schedules = {}
end

function NoviceDungeonTwoPanel:dctor()
    self.model = nil;
    GlobalEvent:RemoveTabListener(self.events);
    self:StopAllSchedules()
end

function NoviceDungeonTwoPanel:Open(data)
    WindowPanel.Open(self)
    self.data = data;
end

function NoviceDungeonTwoPanel:LoadCallBack()
    self.nodes =
    {
        "endTime/endTitleTxt", "endTime", "hardshow","hardshow/dun_name","hardshow/des", "startTime", "startTime/time",
    }
    self:GetChildren(self.nodes);
    SetLocalPosition(self.transform, 0, 0, 0)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.dun_name = GetText(self.dun_name)
    self.des = GetText(self.des)
    self.time = GetText(self.time)
    self.endTime.gameObject:SetActive(false);
    self:InitUI();
    self:AddEvent();
    --Config.db_activity
    SceneManager:GetInstance():SetMainRoleRotateY(45);
    SetAlignType(self.hardshow.transform, bit.bor(AlignType.Left, AlignType.Top))

    --  self:RequseInfo();
end

function NoviceDungeonTwoPanel:InitUI()
    -- self.endTime.gameObject:SetActive(false);
end
function NoviceDungeonTwoPanel:AddEvent()
    --结束副本时间
    self.equipschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
    self:HandleData()
    --self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.ResEnterDungeonInfo, handler(self, self.HandleData))
end

--副本信息的返回
function NoviceDungeonTwoPanel:HandleData()
    local id = DungeonModel:GetInstance().curDungeonID
    local dungeonCfg = Config.db_dunge[id]
    if not dungeonCfg then
        return
    end
    self.dun_name.text = dungeonCfg.name
    self.des.text = dungeonCfg.des
    --local key = id.."@"..1
    --local dungeonWaveCfg = Config.db_dunge_wave[tostring(key)]
    --if not dungeonWaveCfg then
    --    return
    --end
    --local creepsTab = String2Table(dungeonWaveCfg.creeps)
    --local creepID = creepsTab[1]
    --
    --local creepCfg = Config.db_creep[creepID]
    --if not creepCfg then
    --    return
    --end
    --local bossName = creepCfg.name
    --self.round.text = string.format("<color=#5BD022>%s</color>：0/1",bossName)

    if DungeonModel.GetInstance().DungeEnter[id].ptime then
        self.prep_time = DungeonModel.GetInstance().DungeEnter[id].ptime
    end
    if DungeonModel.GetInstance().DungeEnter[id].etime then
        self.end_time = DungeonModel.GetInstance().DungeEnter[id].etime
    end


    if self.prep_time and not self.start_dungeon_time then
        if self.prep_time < os.time() then
            self.start_dungeon_time = 0;
            self.time.text = tostring(self.start_dungeon_time);
            self:StartDungeon();
        else
            local preptime = self.prep_time;
            local ostime = math.round(os.time());
            self.start_dungeon_time = preptime - ostime - 1;
            self.time.text = tostring(self.start_dungeon_time);
            self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
        end
    end


    print2(self.ptime,self.end_time)
end



--请求副本信息
function NoviceDungeonTwoPanel:RequseInfo()
    DungeonCtrl:GetInstance():RequestEnterDungeon(enum.SCENE_STYPE.SCENE_STYPE_NEWBIE_BOSS)
end

function NoviceDungeonTwoPanel:StartDungeon()
    self.start_dungeon_time = self.start_dungeon_time - 1;
    self.time.text = tostring(self.start_dungeon_time);
    if self.start_dungeon_time <= 0 then
        self.startTime.gameObject:SetActive(false);

        if self.schedules[1] then
            GlobalSchedule:Stop(self.schedules[1]);
        end
        self.schedules[1] = nil;
        --防止自动战斗不打
        TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
        --停止自动寻路
        OperationManager:GetInstance():StopAStarMove();
    end
end

--结束倒计时
function NoviceDungeonTwoPanel:EndDungeon()

    if self.end_time and self.start_dungeon_time <= 0 then
        self.endTime.gameObject:SetActive(true);
    end
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        --SetGameObjectActive(self.endTime.gameObject, true);
        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            Notify.ShowText("The dungeon is over. It's time to clean up");
            GlobalSchedule.StopFun(self.equipschedules);
        else
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endTitleTxt.text = "Time Left: " .. timestr;
        end
    end
end
function NoviceDungeonTwoPanel:StopAllSchedules()
    for i = 1, #self.schedules, 1 do
        GlobalSchedule:Stop(self.schedules[i]);
    end
    self.schedules = {};
    if self.equipschedules then
        GlobalSchedule:Stop(self.equipschedules);
    end
    self.equipschedules = nil;
    self.schedules = {};
end