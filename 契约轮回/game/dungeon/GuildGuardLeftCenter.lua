GuildGuardLeftCenter = GuildGuardLeftCenter or class("GuildGuardLeftCenter", DungeonMainBasePanel);
local this = GuildGuardLeftCenter
local ConfigLanguage = require('game.config.language.CnLanguage')

GuildGuardLeftCenter.SwitchType = {
    Task = 1,
    Team = 2,
}

function GuildGuardLeftCenter:ctor(parent_node, bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "GuildGuardLeftCenter"
    self.layer = "Bottom"
    self.bossid = bossid;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};

    self.items = {};
    self.show = true
    --GuildGuardLeftCenter.super.Load(self)
end

function GuildGuardLeftCenter:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end

    destroyTab(self.items);
    self.items = nil;

    if self.kick_countdown then
        self.kick_countdown:destroy();
    end
    self.kick_countdown = nil;

    if self.ggschedules then
        GlobalSchedule:Stop(self.ggschedules);
    end
    self.ggschedules = nil;

    if self.startSchedule then
        GlobalSchedule.StopFun(self.startSchedule);
    end
    self.startSchedule = nil;
    if self.requestschedule then
        GlobalSchedule.StopFun(self.requestschedule);
    end
    self.requestschedule = nil;

    destroyTab(self.crystals);
    self.crystals = nil;

end

function GuildGuardLeftCenter:Open(data)
    WindowPanel.Open(self)
    self.data = data;
end


--玩法说明:<color=#ffffff>击杀入侵的怪物,共8波,守卫八天镇火不被破坏,击杀数量超多,获得经验不多</color>
function GuildGuardLeftCenter:LoadCallBack()
    self.nodes = {
        "ranks", "ranks/list_item_1", "ranks/list_item_3", "ranks/list_item_2", "ranks/list_item_4",

        "endTime/endTitleTxt", "endTime", "startTime/time", "startTime",

        "contents", "contents/wave_label", "contents/exp_label", "contents/killmon_label", "contents/play_title", "contents/wave", "contents/killmon", "contents/exp",

        "con", "con/text_task", "con/img_team_bg", "con/btn_team", "con/btn_task", "con/img_task_show", "btn_switch_2", "con/text_team", "con/img_team_show", "con/btn_switch_1",
        "con/des_title", "con/des",

        "crystal", "crystal/crystal_item_2", "crystal/crystal_item_1", "crystal/crystal_item_3",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0);

    SetAlignType(self.contents, bit.bor(AlignType.Left, AlignType.Null));
    SetAlignType(self.con, bit.bor(AlignType.Left, AlignType.Null));
    SetAlignType(self.ranks, bit.bor(AlignType.Left, AlignType.Null));
    SetAlignType(self.crystal, bit.bor(AlignType.Right, AlignType.Null));

    self.ggIDTab = Config.db_creep_born[DungeonModel.GuildGuardSceneID];
    self.idTab = {};
    self.cid1 = 30381001;
    self.cid2 = 30381002;
    self.cid3 = 30381003;
    local creeps = nil;
    if self.ggIDTab then
        creeps = String2Table(self.ggIDTab["creeps"]);
        for k, v in pairs(creeps) do
            if k == 1 then
                self.cid1 = v[1];
            elseif k == 2 then
                self.cid2 = v[1];
            elseif k == 3 then
                self.cid3 = v[1];
            end
        end
    end
    self.idTab[self.cid1] = true;
    self.idTab[self.cid2] = true;
    self.idTab[self.cid3] = true;

    self:InitUI();

    local enterData = DungeonModel:GetInstance():GetCurrentEnter();
    if enterData then
        self.end_time = enterData.etime;
    end

    for i = 1, 3 do
        local n = "cid" ..i;
        if self[n] then
            self.crystals[i] = GuildGuardNpcItem(self["crystal_item_" .. i], nil, i);
            if creeps and creeps[i] then
                self.crystals[i]:SetExpAdd(string.format("EXP+%s%%", (tonumber(creeps[i][4]) / 100)));
            end
            self.crystals[i]:InitWithID(self[n]);
        end
    end

    self:AddEvents();

    if not self.show then
        SetVisible(self.gameObject, false)
    end

    self:StartDungeonCD();

    if not AutoFightManager:GetInstance():GetAutoFightState() then
        GlobalEvent:Brocast(FightEvent.AutoFight)
    end
    SceneManager:GetInstance():SetMainRoleRotateY(45);

    self:SwitchTaskTeam(GuildGuardLeftCenter.SwitchType.Task);

    self:InitScene();


end

function GuildGuardLeftCenter:StartDungeonCD()
    SetGameObjectActive(self.startTime, true);
    SetGameObjectActive(self.endTime.gameObject, false);
    local dungeConfig = Config.db_dunge[DungeonModel:GetInstance().curDungeonID];
    if dungeConfig then
        local prep = dungeConfig.prep;
        self.startDungeonTime = os.time() + prep;

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
        self.startSchedule = GlobalSchedule.StartFun(handler(self, self.HandleDungeonStartCountDown), 0.2, -1);
    end
end

function GuildGuardLeftCenter:InitUI()
    self.crystals = {};
    self.wave = GetText(self.wave);
    self.wave_label = GetText(self.wave_label);
    self.exp_label = GetText(self.exp_label);
    self.exp = GetText(self.exp);
    self.killmon_label = GetText(self.killmon_label);
    self.killmon = GetText(self.killmon);
    self.des = GetText(self.des);
    self.des_title = GetText(self.des_title);

    self.play_title = GetText(self.play_title);
    --self.play_title.text = "";

    self.endTitleTxt = GetText(self.endTitleTxt);
    self.time = GetText(self.time);

    self:InitTogs();

    self.text_task_component = self.text_task:GetComponent('Text');
    self.text_team_component = self.text_team:GetComponent('Text');
    self.text_task_component.text = ConfigLanguage.Custom.GUILD_GIARD_RANK;
    self.text_team_component.text = ConfigLanguage.Custom.GUILD_GIARD;

    SetGameObjectActive(self.btn_switch_2, false);
end

function GuildGuardLeftCenter:SwitchTaskTeam(switch_type)
    if self.switch_type == switch_type then
        return
    end
    local x, y = self:GetPosition()

    self.switch_type = switch_type
    local task_color
    local task_img
    local team_color
    if self.switch_type == GuildGuardLeftCenter.SwitchType.Task then
        task_color = Color(252, 245, 224, 255)
        team_color = Color(162, 162, 162, 255)
        SetGameObjectActive(self.img_task_show, true);
        SetGameObjectActive(self.img_team_show, false);
        SetGameObjectActive(self.contents, true);
        SetGameObjectActive(self.ranks, false);
    else
        task_color = Color(162, 162, 162, 255)
        team_color = Color(252, 245, 224, 255)
        SetGameObjectActive(self.img_task_show, false);
        SetGameObjectActive(self.img_team_show, true);
        SetGameObjectActive(self.contents, false);
        SetGameObjectActive(self.ranks, true);
    end

    SetColor(self.text_task_component, task_color.r, task_color.g, task_color.b, task_color.a)
    SetColor(self.text_team_component, team_color.r, team_color.g, team_color.b, team_color.a)
end

function GuildGuardLeftCenter:InitTogs()
    destroyTab(self.items);
    self.items = {};

    for i = 1, 4, 1 do
        local item = GuildGuardItem(self["list_item_" .. i]);
        item.gameObject.name = "guild_guard_" .. i;
        self.items[i] = item;
        SetLocalScale(item.transform, 1, 1, 1);
        --SetLocalPosition(item.transform, 0, 0, 0);
    end

end

function GuildGuardLeftCenter:AddEvents()
    local call_back1 = function()

    end

    AddEventListenerInTab(DungeonEvent.DUNGEON_AUTO_EXIT, call_back1, self.events);

    local function call_back(target, x, y)
        self:SwitchTaskTeam(GuildGuardLeftCenter.SwitchType.Task)
    end
    AddClickEvent(self.btn_task.gameObject, call_back)

    local function call_back(target, x, y)
        self:SwitchTaskTeam(GuildGuardLeftCenter.SwitchType.Team)
    end
    AddClickEvent(self.btn_team.gameObject, call_back)

    --结束副本时间
    self.ggschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);

    self:RequestInfo();
    self.requestschedule = GlobalSchedule:Start(handler(self, self.RequestInfo), 2, -1);

    GlobalEvent.AddEventListenerInTab(MainEvent.MAIN_MIDDLE_LEFT_LOADED, handler(self, self.HandleMainMiddleLeftLoaded), self.events);

    GlobalEvent.AddEventListenerInTab(DungeonEvent.DUNGEON_SAVAGE_ANGRY_DATA, handler(self, self.hanelSavageData), self.events);

    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events);

    local function call_back()
        local sceneid = SceneManager:GetInstance():GetSceneId();
        local sceneConfig = Config.db_scene[sceneid];
        if sceneConfig and sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_GUILDGUARD then
            self:InitTogs();
        end
    end
    GlobalEvent.AddEventListenerInTab(EventName.ChangeSceneEnd, call_back, self.events);

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, handler(self, self.HandleData));

    local call_back = function()
        SetGameObjectActive(self.crystal.gameObject, false);
        SetGameObjectActive(self.endTime.gameObject, false);
        self.hideByIcon = true;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        SetGameObjectActive(self.crystal.gameObject, true);
        SetGameObjectActive(self.endTime.gameObject, true);
        self.hideByIcon = nil;
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);

    GlobalEvent.AddEventListenerInTab(EventName.NewSceneObject, handler(self, self.HandleNewCreate), self.events);

    AddEventListenerInTab(SceneEvent.UPDATE_ACTOR_HP, handler(self, self.HandleActorHp), self.events);

    AddEventListenerInTab(RankEvent.RankReturnList, handler(self, self.HandleRank), self.events);
end

local temptab = {
    ["wave_etime"] = 0,
    ["end_time"] = 1565492619,
    ["stype"] = 311,
    ["id"] = 30381,
    ["cur_wave"] = 0,
    ["max_wave"] = 8,
    ["count"] = {

    },
    ["dunge"] = 30381
}

function GuildGuardLeftCenter:HandleData(data)
    if data.stype ~= enum.SCENE_STYPE.SCENE_STYPE_GUILDGUARD then
        return ;
    end
    print2(Table2String(data));
    local prep_time = data.prep_time;
    self.level = data.level;
    self.cur_wave = data.cur_wave;
    self.max_wave = data.max_wave;
    self.end_time = data.end_time;
    self.wave_etime = data.wave_etime;
    self.curDungeonID = data.dunge;
    local dungeConfig = Config.db_dunge[DungeonModel:GetInstance().curDungeonID];
    self.startDungeonTime = data.start_time + dungeConfig.prep
    if data.exp then
        self.exp.text = GetShowNumber(data.exp);
    end
    if data.assault and data.assault ~= 0 then
        self.assault = data.assault;
        --self.des.text = string.format("%s<color=#ffffff>秒后怪物将会发起突袭攻击</color>", tonumber(self.assault));--self.des.text = "90<color=#ffffff>秒后怪物将会发起突袭攻击</color>";
    else
        SetGameObjectActive(self.des, false);
    end

    local killnum = 0;
    if data["count"] then
        for k, v in pairs(data["count"]) do
            killnum = killnum + v;
        end
    end
    self.killmon.text = killnum .. "X";
    self.wave.text = string.format("<color=#5BD022>%s/%s(Wave)</color>", self.cur_wave, self.max_wave);--"<color=#5BD022>" .. self.cur_wave .. "/" .. self.max_wave .. "</color>";
end

function GuildGuardLeftCenter:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    --if self.end_time then
    --    local aaa = not self.startSchedule;
    --    local bbb = not self.hideByIcon;
    --    if not self.startSchedule and not self.hideByIcon then
    --        SetGameObjectActive(self.endTime.gameObject, true);
    --    else
    --        SetGameObjectActive(self.endTime.gameObject, false);
    --    end
    --
    --    timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
    --    if table.isempty(timeTab) then
    --        Notify.ShowText("副本结束了,需要做清理了");
    --        GlobalSchedule.StopFun(self.bossschedules);
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

    if self.wave_etime then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.wave_etime);
        if table.isempty(timeTab) then
            SetGameObjectActive(self.endTime.gameObject, false);
        else
            SetGameObjectActive(self.endTime.gameObject, true);
            timeTab.min = timeTab.min or 0;
            if timeTab.min then
                timestr = timestr .. string.format(formatTime, timeTab.min) .. "：";
            end
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.endTitleTxt.text = timestr .. "sec";
        end
    end

    if self.assault then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.assault);
        if timeTab and not table.isempty(timeTab) then
            SetGameObjectActive(self.des, true);
            timeTab.min = timeTab.min or 0;
            timeTab.sec = timeTab.sec or 0;
            timeTab.sec = timeTab.min * 60 + timeTab.sec;
            self.des.text = string.format("%s<color=#ffffff>sec later.Monsters will assault</color>", tonumber(timeTab.sec));
        else
            SetGameObjectActive(self.des);
        end
    else
        SetGameObjectActive(self.des);
    end

    if not self.startSchedule and not self.hideByIcon then

    else
        SetGameObjectActive(self.endTime.gameObject, false);
    end
end

function GuildGuardLeftCenter:HandleMainMiddleLeftLoaded()

end

function GuildGuardLeftCenter:RequestInfo()
    DungeonCtrl:GetInstance():RequeseExpDungeonInfo();
    RankController:GetInstance():RequestRankListInfo(DungeonModel.GuildGuardRankId, 1)
end
function GuildGuardLeftCenter:InitScene()
    local createdMonTab = SceneManager:GetInstance():GetObjectListByType(enum.ACTOR_TYPE.ACTOR_TYPE_CREEP);
    if createdMonTab then
        for k, monster in pairs(createdMonTab) do
            self:HandleNewCreate(monster);
        end
    end
end
--更新水晶血量的协议
function GuildGuardLeftCenter:HandleActorHp(data)
    local uid = data.uid;--uid
    local hp = data.hp;--当前血量
    local hpmax = data.hpmax;--最大血量

    for i = 1, #self.crystals do
        if self.crystals[i] and self.crystals[i].data and self.crystals[i].data.uid == uid then
            self.crystals[i]:UpdateHP(hp, hpmax);
        end
    end
end

--8010001
--8010002
--8010003
function GuildGuardLeftCenter:HandleNewCreate(monster)
    local creeps = nil;
    if self.idTab then
        creeps = String2Table(self.ggIDTab["creeps"]);
    end
    --if monster and monster.object_info then
    --    print2("怪物ID : " .. monster.object_info.id);
    --end
    if monster and monster.object_info and self.idTab[monster.object_info.id] then
        local object_info = monster.object_info;
        --print2("目标ID : " .. monster.object_info.id);
        local config = Config.db_creep[object_info.id];
        if object_info.id == self.cid1 then
            if self.crystals[1] then
                self.crystals[1]:UpdateData(object_info);
            --else
            --    self.crystals[1] = GuildGuardNpcItem(self.crystal_item_1, object_info, 1);
            --    if creeps and creeps[1] then
            --        self.crystals[1]:SetExpAdd(string.format("经验+%s%%", (tonumber(creeps[1][4]) / 100)));
            --    end
            end
        elseif object_info.id == self.cid2 then
            if self.crystals[2] then
                self.crystals[2]:UpdateData(object_info);
            --else
            --    self.crystals[2] = GuildGuardNpcItem(self.crystal_item_2, object_info, 2);
            --    if creeps and creeps[2] then
            --        self.crystals[2]:SetExpAdd(string.format("经验+%s%%", (tonumber(creeps[2][4]) / 100)));
            --    end
            end
        elseif object_info.id == self.cid3 then
            if self.crystals[3] then
                self.crystals[3]:UpdateData(object_info);
            --else
            --    self.crystals[3] = GuildGuardNpcItem(self.crystal_item_3, object_info, 3);
            --    if creeps and creeps[3] then
            --        self.crystals[3]:SetExpAdd(string.format("经验+%s%%", (tonumber(creeps[3][4]) / 100)));
            --    end
            end
        elseif monster.creep_kind == enum.CREEP_KIND.CREEP_KIND_COLLECT and self.cur_wave and tonumber(self.cur_wave) <= 3 then
            monster.advance_container = AdvanceDungeonItem();
            monster.advance_container:ShowDes(true, "Tap to collect");
            monster.advance_container:UpdateLockPos(-monster:GetBodyHeight() / 2);
            monster:SetAdvanceItemPos();
        end

        local config = Config.db_creep[object_info.id];
        local dungeonConfig = Config.db_dunge[monster.config.scene_id];
        --这段是boss出现,改成配置
        --if config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS2 or config.rarity == enum.CREEP_RARITY.CREEP_RARITY_BOSS3 then
        --    self.isBoss = true;
        --    lua_resMgr:SetImageTexture(self, self.kill_tip, self.imageAb, "pet_dungeon_boss_tip", false, nil, false);
        --    SetGameObjectActive(self.kill_tip_num, false);
        --    self:KillSchedules();
        --    --self:RemoveActions();
        --
        --    self:StartActions();
        --end
        if monster.object_info and monster.object_info["ext"] and monster.object_info["ext"]["disappear"] then
            local time = monster.object_info["ext"]["disappear"];
            SetGameObjectActive(self.boom_exit.gameObject, true);

            local call_back = function()
                SetGameObjectActive(self.boom_exit.gameObject, false);
            end
            if self.boom_exit_schedule then
                GlobalSchedule.StopFun(self.boom_exit_schedule);
            end
            self.boom_exit_schedule = GlobalSchedule.StartFunOnce(call_back, 15);

            local call_back1 = function()
                if monster and monster.object_info and monster.object_info.hp <= 0 then
                    call_back();
                    monster.object_info:RemoveListener(self.update_blood);
                end
            end

            self.update_blood = monster.object_info:BindData("hp", call_back1);
        end
    end
end

function GuildGuardLeftCenter:HandleRank(data)
    if data.id == DungeonModel.GuildGuardRankId and self.items then
        local mine = data.mine;

        if self.items[4] then
            self.items[4]:SetData(mine, RoleInfoModel:GetInstance():GetRoleValue("name"));
        end
        local ranks = data.list or {};
        for i = 1, 3 do
            if i == mine.rank then
                self.items[i]:SetData(mine, RoleInfoModel:GetInstance():GetRoleValue("name"));
                SetGameObjectActive(self.items.gameObject, true);
            else
                if ranks[i] then
                    SetGameObjectActive(self.items.gameObject, true);
                    self.items[i]:SetData(ranks[i]);
                else
                    SetGameObjectActive(self.items.gameObject);
                end
            end

        end
    end
end