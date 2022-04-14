NoviceDungeonPanel = NoviceDungeonPanel or class("NoviceDungeonPanel", DungeonMainBasePanel)
local NoviceDungeonPanel = NoviceDungeonPanel

function NoviceDungeonPanel:ctor()
    self.abName = "dungeon"
    self.imageAb = "dungeon_image"
    self.assetName = "NoviceDungeonPanel"
    self.events = {}
    self.mType = 0
    self.isOver = false
    self.isFirst = true
    self.schedules = {}
end

function NoviceDungeonPanel:dctor()
    self.model = nil;
    if self.monster then
        self.monster:destroy()
    end
    GlobalEvent:RemoveTabListener(self.events);
    self:StopAllSchedules()
    if self.showSchedule then
        GlobalSchedule:Stop(self.showSchedule)
        self.showSchedule = nil
    end

    if self.showSchedule2 then
        GlobalSchedule:Stop(self.showSchedule2)
        self.showSchedule2 = nil
    end

    if self.boom_exit_schedule then
        GlobalSchedule.StopFun(self.boom_exit_schedule);
    end

    if self.boom_Action then
        cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.boom_exit)
        self.boom_Action = nil
    end
    if self.effect  then
        self.effect:destroy()
    end
end

function NoviceDungeonPanel:Open(data)
    --dump(data)
    --print2(data)
    WindowPanel.Open(self)
    self.data = data;
    dump(self.data)
end

function NoviceDungeonPanel:LoadCallBack()
    self.nodes =
    {
        "endTime/endTitleTxt", "endTime", "hardshow","hardshow/head/round","hardshow/des","hardshow/head/bosshead","hardshow/dun_name",
        "startTime", "startTime/time","hardshow/head","hardshow/waveObj","hardshow/waveObj/current","warObj","modelObj","modelObj/modelCon",
        "modelObj/modelDi","modelObj/modelDiText","bossImg","boom_exit",
    }
    self:GetChildren(self.nodes);
    SetLocalPosition(self.transform, 0, 0, 0)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.round = GetText(self.round)
    self.des = GetText(self.des)
    self.time = GetText(self.time)
    self.current = GetText(self.current)
    self.bosshead = GetImage(self.bosshead)
    self.dun_name = GetText(self.dun_name)
   -- self.endTime.gameObject:SetActive(false);
    self.startTime.gameObject:SetActive(false);
    SetVisible(self.warObj,false)
    SetVisible(self.modelObj,false)
    SetVisible(self.bossImg,false)
    self.boom_exit = GetImage(self.boom_exit)
    SetGameObjectActive(self.boom_exit.gameObject, false);
    self:InitUI();
    self:AddEvent();
    --Config.db_activity
    self:InitScene()
    SceneManager:GetInstance():SetMainRoleRotateY(45);
    SetAlignType(self.hardshow.transform, bit.bor(AlignType.Left, AlignType.Top))
    SetAlignType(self.modelObj.transform, bit.bor(AlignType.Right, AlignType.Null))
    self:RequseInfo();
    
    self:checkAdaptUI()
end

function NoviceDungeonPanel:checkAdaptUI()
    UIAdaptManager:GetInstance():AdaptUIForBangScreenLeft(self.hardshow.transform)
    UIAdaptManager:GetInstance():AdaptUIForBangScreenRight(self.modelObj.transform)
end

function NoviceDungeonPanel:InitScene()
    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP);
    if createdMonTab then
        for k, monster in pairs(createdMonTab) do
            self:HandleNewCreate(monster);
        end
    end
end

function NoviceDungeonPanel:InitUI()
   -- self.endTime.gameObject:SetActive(false);
end
function NoviceDungeonPanel:AddEvent()
    --结束副本时间
    self.equipschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
   self:HandleData()


    local function callBack(data)
        if self.equipschedules then
            GlobalSchedule:Stop(self.equipschedules);
        end
        self.isOver = true
        self.dungeonExit:ShowArrow(true)
        SetVisible(self.endTime,false)
        self.round.text = string.format("<color=#5BD022>%s</color>：1/1",self.bossName )
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_AUTO_EXIT, callBack)


    local call_back = function()
        if self.isOver == true then
            return
        end
        SetGameObjectActive(self.endTime.gameObject , false);
        if self.dungeonType == "wave"  then
            SetGameObjectActive(self.modelObj.gameObject , false);
        end
        self.hideByIcon = true;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        if self.isOver == true then
            return
        end
        SetGameObjectActive(self.endTime.gameObject , true);
        if self.dungeonType == "wave"  then
            SetGameObjectActive(self.modelObj.gameObject , true);
        end
        self.hideByIcon = false;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);


    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self, self.HandleDungeonInfo))
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.GlobalEnterDungeInfo, handler(self, self.HandleData))
    --self:HandleData()
    self:HandleDungeonInfo()
end

function NoviceDungeonPanel:HandleNewCreate(monster)
   -- dump(monster)
    if monster  and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_CREEP  then
        if monster:IsBoss()  or monster.creep_kind == enum.CREEP_KIND.CREEP_KIND_TOMB   then
            if  not string.isNilOrEmpty(monster.config.talk) then
                monster.name_container:SetTalkContent(monster.config.talk)
                monster.name_container:ShowTalk(true,5)
            end
        --    local call_back1 = function(hp)
        --        local value = hp / monster.object_info.hpmax
        --        if tonumber(value) <= 0.5 then
        --            -- monster.name_container:SetTalkContent("有勇无谋的勇士，看我灭了你！")
        --            monster.name_container:ShowTalk(true,5)
        --        end
        --        -- self.enemyHp.fillAmount = value
        --        if monster and monster.object_info and monster.object_info.hp <= 0 then
        --            --call_back();
        --            monster.object_info:RemoveListener(self.update_blood);
        --        end
        --    end
        --    self.update_blood = monster.object_info:BindData("hp", call_back1);
        end
        if monster.object_info and monster.object_info["ext"] and monster.object_info["ext"]["disappear"] then
            if self.isFirst then
                self.isFirst = false
                SetGameObjectActive(self.boom_exit.gameObject, true);

               -- local time_id
                local call_back = function()
                    self.isFirst = true
                    if self.boom_exit_schedule then
                        GlobalSchedule.StopFun(self.boom_exit_schedule);
                    end
                    SetGameObjectActive(self.boom_exit.gameObject, false);
                    SetColor(self.boom_exit, 255, 255, 255, 255);

                end
                if self.boom_exit_schedule then
                    GlobalSchedule.StopFun(self.boom_exit_schedule);
                end

                cc.ActionManager:GetInstance():removeAllActionsFromTarget(self.boom_exit)
                local value_action = cc.FadeTo(4, 0.5, self.boom_exit);
                local delay = cc.DelayTime(3);
                local action = cc.Sequence(delay, value_action)
                cc.ActionManager:GetInstance():addAction(action, self.boom_exit)
                self.boom_Action = action
                self.boom_exit_schedule = GlobalSchedule.StartFunOnce(call_back, 8);
              --  time_id = self.boom_exit_schedule

                local call_back1 = function()
                    if monster and monster.object_info and monster.object_info.hp <= 0 then
                        --call_back();
                        monster.object_info:RemoveListener(self.update_blood);
                    end
                end

                self.update_blood = monster.object_info:BindData("hp", call_back1);
            end
        end

    end
end
--副本信息的返回
function NoviceDungeonPanel:HandleDungeonInfo()
    local data = self.model.dungeonInfo
    if  not data then
        return
    end
    if data.stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_NEWBIE then
        return
    end
    if self.dungeonType == "wave" then
        if data.cur_wave and data.max_wave then
            self.current.text  = string.format("Current Wave：<color=#5BD022>%s/%s</color>",data.cur_wave,data.max_wave)
            if data.cur_wave == data.max_wave then
                SetVisible(self.bossImg,true)
                local time = 3
                local function call_back()
                    time = time - 1
                    if time <= 0 then
                        SetVisible(self.bossImg,false)
                        if self.showSchedule2 then
                            GlobalSchedule:Stop(self.showSchedule2)
                            self.showSchedule2 = nil
                        end
                    end
                end
                self.showSchedule2 = GlobalSchedule.StartFun(call_back, 1, -1)
            end
        end
    end


end


function NoviceDungeonPanel:HandleData(data)
    local id = DungeonModel:GetInstance().curDungeonID
    local dungeonCfg = Config.db_dunge[id]
    if not dungeonCfg then
        return
    end
    local stype = dungeonCfg.stype
    if stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_NEWBIE and stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_NEWBIE_SUMMON and stype ~= enum.SCENE_STYPE.SCENE_STYPE_DUNGE_NEWBIE_ANGER then
        return
    end
    self.dun_name.text = dungeonCfg.name
    self.des.text = dungeonCfg.des
    local complete = String2Table(dungeonCfg.complete)
    local dtype = complete[1][1]
    local num = complete[1][2]
    self.dungeonType = dtype
    --print2(complete[1][1])
    --dump(complete)
    if dtype == "split" then -- 分裂副本
        SetVisible(self.head,false)
        SetVisible(self.waveObj,false)
        SetLocalPosition(self.des.transform,-495,44,0)
    elseif dtype == "creep" then --Boss
        local key = id.."@"..1
        local dungeonWaveCfg = Config.db_dunge_wave[tostring(key)]
        if not dungeonWaveCfg then
            return
        end
        local creepsTab = String2Table(dungeonWaveCfg.creeps)
        local creepID = creepsTab[1]
        local id
        if type(creepID) == "table" then
            id = creepID[1]
        else
            id = creepID
        end
        local creepCfg = Config.db_creep[id]
        if not creepCfg then
            return
        end
        self.bossName = creepCfg.name
        self.round.text = string.format("<color=#5BD022>%s</color>：0/1",self.bossName )
        self:SetBossHead(creepCfg.avatar);
        SetVisible(self.waveObj,false)
    elseif dtype == "wave" then
        self.current.text =string.format("Current Wave：<color=#5BD022>%s/%s</color>",0,num)
        LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelCon,nil,true,nil,nil,4)
        LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelDiText.transform,nil,true,nil,nil,5)
       -- LayerManager:GetInstance():AddOrderIndexByCls(self,self.modelDi.transform,nil,true,nil,nil,3)
        SetVisible(self.head,false)
        SetVisible(self.waveObj,true)
        SetVisible(self.modelObj,true)
        SetVisible(self.warObj,true)
        local time = 3
        local function call_back()
            time = time - 1
            if time <= 0 then
                SetVisible(self.warObj,false)
                if self.showSchedule then
                    GlobalSchedule:Stop(self.showSchedule)
                    self.showSchedule = nil
                end
            end
        end
        self.showSchedule = GlobalSchedule.StartFun(call_back, 1, -1)


        local function cb()
          --  LayerManager.GetInstance():AddOrderIndexByCls(self, self.texture_cpn, nil, true, nil, 1, 3)
        end
        self.effect = UIEffect(self.modelDi, 10313, false, "Bottom", cb)
        self.effect:SetOrderIndex(101)

        self:InitModel()
    end
    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events)

    --logError(DungeonModel.GetInstance().DungeEnter[id].ptime, DungeonModel.GetInstance().DungeEnter[id].etime,os.time())
  --  dump(TimeManager:GetLastTimeData(os.time(), self.start_dungeon_time))
    if DungeonModel.GetInstance().DungeEnter[id].ptime then
        self.prep_time = DungeonModel.GetInstance().DungeEnter[id].ptime
    end
    if DungeonModel.GetInstance().DungeEnter[id].etime then
        self.end_time = DungeonModel.GetInstance().DungeEnter[id].etime
    end


    --if self.prep_time and not self.start_dungeon_time then
    --    if self.prep_time < os.time() then
    --        self.start_dungeon_time = 0;
    --        self.time.text = tostring(self.start_dungeon_time);
    --        self:StartDungeon();
    --    else
    --        local preptime = self.prep_time;
    --        local ostime = math.round(os.time());
    --        self.start_dungeon_time = preptime - ostime - 1;
    --        self.time.text = tostring(self.start_dungeon_time);
    --        self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
    --    end
    --end

    if self.prep_time and not self.start_dungeon_time then
        if self.prep_time < os.time() then
            self.start_dungeon_time = 0;
            self.time.text = tostring(self.start_dungeon_time);
            self:StartDungeon();
        else
            local preptime = self.prep_time;
            local ostime = math.round(os.time());
            self.start_dungeon_time = preptime;
            self.time.text = tostring(self.start_dungeon_time - ostime);
            self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 1, -1);
        end
    end
   -- print2(self.ptime,self.end_time)
end

function NoviceDungeonPanel:SetBossHead(avatarId)
    local headId = avatarId or 50101
  --  lua_resMgr:SetImageTexture(self, self.bosshead, "iconasset/icon_boss_head", bossid, false);
    lua_resMgr:SetImageTexture(self, self.bosshead, "iconasset/icon_boss_head", headId, true);
end


--请求副本信息
function NoviceDungeonPanel:RequseInfo()
    DungeonCtrl:GetInstance():RequeseExpDungeonInfo()
end

function NoviceDungeonPanel:StartDungeon()

    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
    --停止自动寻路
    OperationManager:GetInstance():StopAStarMove();
    local timeTab = TimeManager:GetLastTimeData(os.time(), self.start_dungeon_time);
    local timestr = "";
    local formatTime = "%02d";
    if table.isempty(timeTab) then
        --if self.dungeonType == "wave" then
        --    SetVisible(self.warObj,false)
        --end
        self.startTime.gameObject:SetActive(false);
        if self.schedules[1] then
            GlobalSchedule:Stop(self.schedules[1]);
        end
        self.schedules[1] = nil;
    else
        timeTab.min = timeTab.min or 0;
        timeTab.hour = timeTab.hour or 0;
        if timeTab.hour then
            timestr = timestr .. string.format("%02d", timeTab.hour) .. ":";
        end
        if timeTab.min then
            timestr = timestr .. string.format("%02d", timeTab.min) .. ":";
        end
        if timeTab.sec then
            timestr = timestr .. string.format("%02d", timeTab.sec);
        end
        self.time.text = timestr;--"副本倒计时: " ..
    end

    --if self.start_dungeon_time <= 0 then
    --    if self.dungeonType == "wave" then
    --        SetVisible(self.warObj,true)
    --    end
    --    self.startTime.gameObject:SetActive(false);
    --    if self.schedules[1] then
    --        GlobalSchedule:Stop(self.schedules[1]);
    --    end
    --    self.schedules[1] = nil;
    --    --防止自动战斗不打
    --    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
    --    --停止自动寻路
    --    OperationManager:GetInstance():StopAStarMove();
    --else
    --    self.startTime.gameObject:SetActive(true);
    --    self.start_dungeon_time = self.start_dungeon_time - 1;
    --    self.time.text = tostring(self.start_dungeon_time);
    --end
end

--结束倒计时
function NoviceDungeonPanel:EndDungeon()

    if self.end_time and self.start_dungeon_time <= 0 then
        self.endTime.gameObject:SetActive(true);
    end
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        SetGameObjectActive(self.endTime.gameObject, true);
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
    NoviceDungeonPanel.super.EndDungeon(self);
end
function NoviceDungeonPanel:StopAllSchedules()
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



function NoviceDungeonPanel:InitModel()
    -- self.curResName

    if self.monster then
        self.monster:destroy()
    end
    local config = {};
    config.rotate = { x = 0, y = 220, z = 0 };
    config.pos = {x = 2005, y = -63, z = 200}
    config.scale = {x = 140,y=140,z=140}
    config.carmera_size = 3.5
    self.monster = UIMountCamera(self.modelCon, nil, "model_pet_10001", enum.ITEM_STYPE.ITEM_STYPE_MOUNT_MORPH,nil,false);
    self.monster:SetConfig(config)
end