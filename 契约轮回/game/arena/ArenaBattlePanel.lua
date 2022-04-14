---
--- Created by  Administrator
--- DateTime: 2019/5/7 11:08
---
ArenaBattlePanel = ArenaBattlePanel or class("ArenaBattlePanel", BasePanel)
local this = ArenaBattlePanel

function ArenaBattlePanel:ctor()
    self.abName = "arena"
    self.assetName = "ArenaBattlePanel"
    
    self.is_hide_model_effect = false

    self.model = ArenaModel:GetInstance()
    self.events = {};
    self.modelEvents = {}
    self.schedules = {};

    self.role_data = RoleInfoModel:GetInstance():GetMainRoleData()
end

function ArenaBattlePanel:dctor()
    GlobalEvent:RemoveTabListener(self.events)
    self.model:RemoveTabListener(self.modelEvents)
    self.model.isOpenBattlePanle = false
    self:StopAllSchedules()

    if self.role_update_list and self.role_data then
        for k, event_id in pairs(self.role_update_list) do
            self.role_data:RemoveListener(event_id)
        end
        self.role_update_list = nil
    end
end

function ArenaBattlePanel:LoadCallBack()
    self.nodes = {
        "enemyObj/enemyPower", "myObj/levelBg", "myObj/myHp", "enemyObj/enemy_levelBg", "enemyObj/enemy_levelBg/enemyLevel", "myObj/headBG/my_mask/myHead", "enemyObj/headBG/ene_mask/enemyHead", "skipBtn", "enemyObj/enemyHp",
        "myObj/levelBg/myLevel", "myObj/myPower", "startTime/time", "endTime/endText", "startTime", "endTime",
    }
    self:GetChildren(self.nodes)
    self.myLevel = GetText(self.myLevel)
    self.myPower = GetText(self.myPower)
    self.myHead = GetImage(self.myHead)
    self.myHp = GetImage(self.myHp)
    self.enemyHead = GetImage(self.enemyHead)
    self.enemyHp = GetImage(self.enemyHp)
    self.enemyLevel = GetText(self.enemyLevel)
    self.enemyPower = GetText(self.enemyPower)
    self.time = GetText(self.time)
    self.endText = GetText(self.endText)
    self.my_lv_img = GetImage(self.levelBg)
    self.enemy_lv_img = GetImage(self.enemy_levelBg)

    self.endTime.gameObject:SetActive(false);
    self:InitUI()
    self:AddEvent()
    self:InitScene()
    ArenaController:GetInstance():RequstBattleInfo()
    LayerManager:GetInstance():SetLayerVisible(LayerManager.LayerNameList.Bottom,false)
    -- SceneControler:GetInstance():RequestSceneRush(1300,650)

    --if not AutoFightManager:GetInstance():GetAutoFightState() then  --自动战斗 之后会改
    --    GlobalEvent:Brocast(FightEvent.AutoFight)
    --end

end

function ArenaBattlePanel:InitScene()
    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT);
    if createdMonTab then
        for k, monster in pairs(createdMonTab) do
            self:HandleNewCreate(monster);
        end
    end
end

function ArenaBattlePanel:InitUI()
    self.scene_data = SceneManager:GetInstance():GetSceneInfo()
    self:SetMyInfo()
    -- self:SetEnemyInfo()
end

function ArenaBattlePanel:SetMyInfo()
    SetTopLevelImg(self.role_data.level, self.my_lv_img, self, self.myLevel)
    --self.myLevel.text = self.role_data.level
    self.myPower.text = self.role_data.power
    if self.role_data.gender == 1 then
        --男
        lua_resMgr:SetImageTexture(self, self.myHead, "main_image", "img_role_head_1", true, nil, false)
    else
        lua_resMgr:SetImageTexture(self, self.myHead, "main_image", "img_role_head_2", true, nil, false)
    end
end
function ArenaBattlePanel:SetEnemyInfo(role)
    self.enemyPower.text = role.power
    SetTopLevelImg(250, self.enemy_lv_img, self, self.enemyLevel)
    --self.enemyLevel.text = 250 --写死
    if role.gender == 1 then
        --男
        lua_resMgr:SetImageTexture(self, self.enemyHead, "main_image", "img_role_head_1", true, nil, false)
    else
        lua_resMgr:SetImageTexture(self, self.enemyHead, "main_image", "img_role_head_2", true, nil, false)
    end
end

function ArenaBattlePanel:AddEvent()

    self.equipschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
    local function call_back()
        ArenaController:GetInstance():RequstSkip()
    end
    AddClickEvent(self.skipBtn.gameObject, call_back)

    self.role_update_list = {}

    local function call_back()
        self:UpdateMainHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hp", call_back)
    local function call_back()
        self:UpdateMainHp()
    end
    self.role_update_list[#self.role_update_list + 1] = self.role_data:BindData("hpmax", call_back)

    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events);
    self.modelEvents[#self.modelEvents + 1] = self.model:AddListener(ArenaEvent.ArenaBattleInfo, handler(self, self.ArenaBattleInfo))
end

function ArenaBattlePanel:Open()
    self.model.isOpenBattlePanle = true
    WindowPanel.Open(self);
end

function ArenaBattlePanel:ArenaBattleInfo(data)

    -- if not AutoFightManager:GetInstance():GetAutoFightState() then
    --     GlobalEvent:Brocast(FightEvent.AutoFight)
    -- end

    local main_role = SceneManager:GetInstance():GetMainRole()
    if main_role then
        main_role:SetRotateY(90)
    end

    self.prep_time = data.ptime
    self.end_time = data.etime
    if self.prep_time and not self.start_dungeon_time then
        self.start_dungeon_time = self.prep_time
        if self.schedules[1] then
            GlobalSchedule.StopFun(self.schedules[1])
        end
        self.endDungeonStartCountDownFun = function()
            if self.schedules[1] then
                GlobalSchedule.StopFun(self.schedules[1])
            end
            self.schedules[1] = nil
            SetGameObjectActive(self.endTime.gameObject, true)
        end
        self.schedules[1] = GlobalSchedule:Start(handler(self, self.StartDungeon), 0.2, -1);
    end
end
function ArenaBattlePanel:StartDungeon()
    --self.start_dungeon_time = self.start_dungeon_time - 1;
    --self.time.text = tostring(self.start_dungeon_time);
    --if self.start_dungeon_time == 1 then
    --    local arenaCfg = Config.db_arena["rush"]
    --    local rushTab = String2Table(arenaCfg.val)
    --    dump(rushTab)
    --    local roleData =   SceneManager:GetInstance():GetMainRole()
    --    local  rush_pos = {x = rushTab[1][1],y=rushTab[1][2]}
    --    roleData:PlayRush(rush_pos)
    --end
    --if self.start_dungeon_time <= 0 then
    --    self.startTime.gameObject:SetActive(false);
    --
    --    if self.schedules[1] then
    --        GlobalSchedule:Stop(self.schedules[1]);
    --    end
    --    self.schedules[1] = nil;
    --
    --    --防止自动战斗不打
    --    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
    --    --停止自动寻路
    --    OperationManager:GetInstance():StopAStarMove();
    --
    --
    --    if not AutoFightManager:GetInstance():GetAutoFightState() then
    --        GlobalEvent:Brocast(FightEvent.AutoFight)
    --    end
    --end
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";--"%02d";
    if self.start_dungeon_time then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.start_dungeon_time);
        if table.isempty(timeTab) then
            GlobalSchedule.StopFun(self.schedules[1]);
            if self.startTime and self.startTime.gameObject then
                SetGameObjectActive(self.startTime.gameObject, false);
            end
            if self.endDungeonStartCountDownFun then
                self.endDungeonStartCountDownFun();
            end
            self.schedules[1] = nil;

            --防止自动战斗不打
            TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
            --停止自动寻路
            OperationManager:GetInstance():StopAStarMove();

            --
            --if not AutoFightManager:GetInstance():GetAutoFightState() then
            --    GlobalEvent:Brocast(FightEvent.AutoFight)
            --end

            --local arenaCfg = Config.db_arena["rush"]
            --local rushTab = String2Table(arenaCfg.val)

            --local roleData =   SceneManager:GetInstance():GetMainRole()
            --local  rush_pos = {x = rushTab[1][1],y=rushTab[1][2]}
            --roleData:PlayRush(rush_pos)
        else
            --timeTab.min = timeTab.min or 0;
            --if timeTab.min then
            --    timestr = timestr .. string.format(formatTime, timeTab.min) .. ":";
            --end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.time.text = timestr;
        end
    end


end

--结束倒计时
function ArenaBattlePanel:EndDungeon()
    --if self.end_time and self.start_dungeon_time <= 0 then
    --    self.endTime.gameObject:SetActive(true);
    --end
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
                timestr = timestr .. string.format(formatTime, timeTab.min) .. "：";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endText.text = "Battle ends in: " .. timestr;
        end
    end
end

function ArenaBattlePanel:HandleNewCreate(monster)
    if monster and monster.object_type == enum.ACTOR_TYPE.ACTOR_TYPE_ROBOT then

        local call_back1 = function(hp)
            local value = hp / monster.object_info.hpmax
            logError(hp,monster.object_info.hpmax)
            self.enemyHp.fillAmount = value
            if monster and monster.object_info and monster.object_info.hp <= 0 then
                --call_back();
                monster.object_info:RemoveListener(self.update_blood);
            end
        end
        self.update_blood = monster.object_info:BindData("hp", call_back1);
        monster:SetRotateY(255)
        self:SetEnemyInfo(monster.object_info)
    end
end

function ArenaBattlePanel:UpdateMainHp()
    if not self.role_data or not self.role_data.attr or not self.role_data.hp or not self.role_data.hpmax or not self.is_loaded then
        return
    end
    local value = self.role_data.hp / self.role_data.hpmax
    self.myHp.fillAmount = value
end

function ArenaBattlePanel:StopAllSchedules()
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
