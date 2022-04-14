DailyDungeonPanel = DailyDungeonPanel or class("DailyDungeonPanel", DungeonMainBasePanel)
local DailyDungeonPanel = DailyDungeonPanel

function DailyDungeonPanel:ctor()
    self.abName = "dungeon"
    self.imageAb = "dungeon_image"
    self.assetName = "DailyDungeonPanel"
    self.events = {}
    self.mType = 0
    self.schedules = {}
    self.creeps = {}
    self.isOver = false
    self.dungeonType = 0 -- 1波数副本  2怪物副本
end

function DailyDungeonPanel:dctor()
    self.model.dungeonInfo = nil
    self.model = nil;
    GlobalEvent:RemoveTabListener(self.events);
    self:StopAllSchedules()
    self.creeps = {}
end

function DailyDungeonPanel:Open(data)
    --dump(data)
    --print2(data)
    WindowPanel.Open(self)
    self.data = data;
    dump(self.data)
end

function DailyDungeonPanel:LoadCallBack()
    self.nodes =
    {
        "endTime/endTitleTxt", "endTime", "hardshow","hardshow/head/round","hardshow/des","hardshow/head/bosshead","hardshow/head/bossheadframe","hardshow/dun_name", "startTime", "startTime/time","hardshow/head"
    }
    self:GetChildren(self.nodes);
    SetLocalPosition(self.transform, 0, 0, 0)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.round = GetText(self.round)
    self.des = GetText(self.des)
    self.time = GetText(self.time)
    self.bosshead = GetImage(self.bosshead)
    self.dun_name = GetText(self.dun_name)

    self.endTime.gameObject:SetActive(false);
  --  self.startTime.gameObject:SetActive(false);
    self:InitUI();
    self:AddEvent();
    --Config.db_activity
    SceneManager:GetInstance():SetMainRoleRotateY(45);
    SetAlignType(self.hardshow.transform, bit.bor(AlignType.Left, AlignType.Top))

    self:RequseInfo();
    
    self:checkAdaptUI()
end

function DailyDungeonPanel:checkAdaptUI()
    UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.hardshow)
end


function DailyDungeonPanel:InitUI()
    -- self.endTime.gameObject:SetActive(false);
end
function DailyDungeonPanel:AddEvent()
    --结束副本时间
    self.equipschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
    self:HandleData()


    local function callBack(data)
        if self.equipschedules then
            GlobalSchedule:Stop(self.equipschedules);
        end
        SetVisible(self.endTime,false)
        self.isOver = true
    --    self.round.text = string.format("<color=#5BD022>%s</color>：1/1",self.bossName )
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_AUTO_EXIT, callBack)

    local call_back = function()
        if self.isOver == true then
            return
        end
        SetGameObjectActive(self.endTime.gameObject , false);
        self.hideByIcon = true;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        if self.isOver == true then
            return
        end
      --  SetGameObjectActive(self.endTime.gameObject , true);
        self.hideByIcon = false;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);


    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self, self.HandleDungeonInfo))
    self:HandleDungeonInfo()
end


function DailyDungeonPanel:HandleDungeonInfo(tab)
    local data = self.model.dungeonInfo
    if  not data then
        return
    end
    if data.stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_DAILY then
        return
    end
    if self.dungeonType == 1 then
        if data.cur_wave and data.max_wave then
            self.round.text = string.format("Current Wave：<color=#5BD022>%s/%s</color>",data.cur_wave,data.max_wave)
        end
    else
        if data.count then
            for i, v in pairs(data.count) do
                self.creeps[i] = v
            end
            local complete = String2Table(self.dungeonCfg.complete)
            local str = ""
            for i = 1, #complete do
                local id = complete[i][2]
                local num = complete[i][3]
                local creepCfg = Config.db_creep[id]
                str = str..string.format("<color=#5BD022>%s</color>:%s/%s\n",creepCfg.name,self.creeps[id],num)
            end
            self.round.text = str
        end
    end




end

--副本信息的返回
function DailyDungeonPanel:HandleData()
    local id = DungeonModel:GetInstance().curDungeonID
    self.dungeonCfg = Config.db_dunge[id]
    if not self.dungeonCfg then
        return
    end
    self.dun_name.text = self.dungeonCfg.name
    self.des.text = self.dungeonCfg.des
    local complete = String2Table(self.dungeonCfg.complete)
    local type = complete[1][1]
    local num = complete[1][2]

    --print2(complete[1][1])8
    --dump(complete)
    if type == "wave" then -- 波数副本
        self.dungeonType = 1
        --SetVisible(self.bosshead,false)
      --  SetVisible(self.bossheadframe,false)
        self.round.text = string.format("Current Wave：<color=#5BD022>%s/%s</color>","0",num)
    elseif type == "creep" then
        self.dungeonType = 2
        local str = ""
        for i = 1, #complete do
            local id = complete[i][2]
            local num = complete[i][3]
            local creepCfg = Config.db_creep[id]
            self.creeps[id] = 0
            str = str..string.format("<color=#5BD022>%s</color>:%s/%s\n",creepCfg.name,0,num)
        end
        self.round.text = str
    end


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
            self.start_dungeon_time = preptime - ostime;
            self.time.text = tostring(self.start_dungeon_time);
            self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
        end
    end
    -- print2(self.ptime,self.end_time)
end

function DailyDungeonPanel:SetBossHead(avatarId)
    local headId = avatarId or 50101
    --  lua_resMgr:SetImageTexture(self, self.bosshead, "iconasset/icon_boss_head", bossid, false);
    lua_resMgr:SetImageTexture(self, self.bosshead, "iconasset/icon_boss_head", headId, true);
end


--请求副本信息
function DailyDungeonPanel:RequseInfo()
  --  DungeonCtrl:GetInstance():RequeseExpDungeonInfo()
end

function DailyDungeonPanel:StartDungeon()
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
function DailyDungeonPanel:EndDungeon()
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
            self.endTitleTxt.text = timestr;--"副本倒计时: " ..
        end
    end
    DailyDungeonPanel.super.EndDungeon(self);
end
function DailyDungeonPanel:StopAllSchedules()
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