DungeonBossLeftCenter = DungeonBossLeftCenter or class("DungeonBossLeftCenter", BaseItem);
local this = DungeonBossLeftCenter

--21D760绿色D6302F红色

function DungeonBossLeftCenter:ctor(parent_node, bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonBossLeftCenter"
    self.layer = "Bottom"
    self.bossid = bossid;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};

    self.items = {};
    self.show = true
    DungeonBossLeftCenter.super.Load(self)
end

function DungeonBossLeftCenter:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end

    destroyTab(self.items);
    self.items = {};

    if self.kick_countdown then
        self.kick_countdown:destroy();
    end
    self.kick_countdown = nil;

    if self.bossschedules then
        GlobalSchedule:Stop(self.bossschedules);
    end
    self.bossschedules = nil;

    if self.startSchedule then
        GlobalSchedule.StopFun(self.startSchedule);
    end
    self.startSchedule = nil;
end

function DungeonBossLeftCenter:LoadCallBack()
    self.nodes = {
        "contents/ScrollView/Viewport/Content", "contents/list_item_0", "contents", "contents/refresh_btn",
        "contents/ScrollView", "contents/angry/angryblood", "contents/angry", "contents/angry/angry_text", "contents/angry/countdown_bg", "contents/angry/countdown_bg/countdown_label", "contents/angry/countdown_bg/countdown_text",

        "togs/boss", "togs/team", "togs/tog_bg", "min_btn",

        "endTime/endTitleTxt", "endTime", "startTime/time", "startTime",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0);

    self:InitUI();

    local enterData = DungeonModel:GetInstance():GetCurrentEnter();
    if enterData then
        self.end_time = enterData.etime;
    end

    self:AddEvents();

    if not self.show then
        SetVisible(self.gameObject, false)
    end

    --self:StartDungeonCD();
    SetGameObjectActive(self.startTime , false);

    if not AutoFightManager:GetInstance():GetAutoFightState() then
        GlobalEvent:Brocast(FightEvent.AutoFight)
    end
    SceneManager:GetInstance():SetMainRoleRotateY(45);
end

function DungeonBossLeftCenter:StartDungeonCD()
    SetGameObjectActive(self.startTime, true);
    SetGameObjectActive(self.endTime.gameObject, false);
    --local sceneInfo = SceneManager:GetInstance():GetSceneInfo();
    --if sceneInfo then
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
    --end
end

function DungeonBossLeftCenter:InitUI()
    self.min_btn = GetButton(self.min_btn);
    self.team = GetToggle(self.team);
    self.boss = GetToggle(self.boss);

    self.endTitleTxt = GetText(self.endTitleTxt);
    self.time = GetText(self.time);

    SetLocalScale(self.min_btn.transform, 1, 1, 1);

    self:InitTogs(1);

    self.angry_text = GetText(self.angry_text);

    SetGameObjectActive(self.refresh_btn, false);

    self.angryblood = BossBloodItem(self.angryblood, 3);
    self.angryblood:UpdateCurrentBloodImmi(0, 100);
    self.angry.gameObject:SetActive(false);

    self:hanelSavageData(DungeonModel:GetInstance().angryData);

    self.countdown_text = GetText(self.countdown_text);

    SetGameObjectActive(self.countdown_bg, false);
end

DungeonBossLeftCenter.currentType = 1;
function DungeonBossLeftCenter:InitTogs(type)

    destroyTab(self.items);
    self.items = {};
    self.currentType = type;
    --if type == 1 then
    self:InitBossData()
    self.list_item_0.gameObject:SetActive(true);
    local tab = self.bossData;

    table.sort(tab, SeqCompareFun);
    for i = 1, #tab, 1 do
        local bossTab = tab[i];
        local item = DungeonLeftCenterItem(newObject(self.list_item_0), bossTab);
        item.gameObject.name = "world_boss_" .. i;
        self.items[i] = item;
        --item:SetJie();
        item.transform:SetParent(self.Content.transform);
        SetLocalScale(item.transform, 1, 1, 1);
        SetLocalPosition(item.transform, 0, 0, 0);
        if i ~= 1 then
            self:RefreshDungeonScrollItem(item);
        end

    end
    --self.items[1]:SetSelected(true);
    local rt = self.Content:GetComponent("RectTransform");
    rt.sizeDelta = Vector2(rt.sizeDelta.x, #tab * 46);

    self.list_item_0.gameObject:SetActive(false);
    --else
    --    self.list_item_0.gameObject:SetActive(true);
    --    local sceneid = tostring(SceneManager:GetInstance():GetSceneId());
    --    local sceneMosterTab = self.model.localBossTab[sceneid];--SceneManager:GetInstance():GetSceneId()
    --    if sceneMosterTab then
    --        self.refresh_btn.gameObject:SetActive(true);
    --        table.sort(sceneMosterTab, SeqCompareFun);
    --
    --        for i = 1, #sceneMosterTab, 1 do
    --            local monsterTab = sceneMosterTab[i];
    --            local item = DungeonBossLeftCenterItem(newObject(self.list_item_0), monsterTab);
    --            item.gameObject.name = "world_moster_" .. i;
    --            self.items[i] = item;
    --            --item:SetJie();
    --            item.transform:SetParent(self.Content.transform);
    --            SetLocalScale(item.transform, 1, 1, 1);
    --            SetLocalPosition(item.transform, 0, 0, 0);
    --            --self:RefreshDungeonScrollItem(item);
    --        end
    --        --self.items[1]:SetSelected(true);
    --
    --        local rt = self.Content:GetComponent("RectTransform");
    --        rt.sizeDelta = Vector2(rt.sizeDelta.x, #sceneMosterTab * 40);
    --    end
    --
    --    self.list_item_0.gameObject:SetActive(false);
    --end
    SetLocalPosition(self.Content.transform, 0, 0, 0)
    self:AddTogEvents();
end

function DungeonBossLeftCenter:AddEvents()

    local call_back1 = function()
        if self.items and self.items[1] then
            self:RefreshDungeonScrollItem(self.items[1]);
        end
    end

    AddEventListenerInTab(DungeonEvent.DUNGEON_AUTO_EXIT, call_back1, self.events);
    ----退出按钮事件
    --AddClickEvent(self.exit_btn.gameObject, handler(self, self.HandleExit));
    --最小化按钮
    AddClickEvent(self.min_btn.gameObject, handler(self, self.HandleMin));
    --刷新事件
    AddClickEvent(self.refresh_btn.gameObject, handler(self, self.HandleRefresh));
    --tog点击
    AddValueChange(self.boss.gameObject, handler(self, self.HandleTog));

    --self:AddTogEvents();

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.WORLD_BOSS_LIST, handler(self, self.HaneleBossList));

    GlobalEvent.AddEventListenerInTab(MainEvent.MAIN_MIDDLE_LEFT_LOADED, handler(self, self.HandleMainMiddleLeftLoaded), self.events);

    GlobalEvent.AddEventListenerInTab(DungeonEvent.WORLD_BOSS_INFO, handler(self, self.HandleBossInfo), self.events);

    GlobalEvent.AddEventListenerInTab(DungeonEvent.DUNGEON_SAVAGE_ANGRY_DATA, handler(self, self.hanelSavageData), self.events);

    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events);

    local function call_back()
        local sceneid = SceneManager:GetInstance():GetSceneId();
        local sceneConfig = Config.db_scene[sceneid];
        if sceneConfig and sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD then
            self:InitTogs(1);
        end
    end
    GlobalEvent.AddEventListenerInTab(EventName.ChangeSceneEnd, call_back, self.events);


    --结束副本时间
    --self.bossschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
    SetGameObjectActive(self.endTime , false);
end

function DungeonBossLeftCenter:AddTogEvents()
    for i = 1, #self.items, 1 do
        local item = self.items[i];
        --AddClickEvent(item.gameObject, handler(self, self.HandleMoveTo));
    end
end

function DungeonBossLeftCenter:HandleMoveTo(target, x, y)
    for k, v in pairs(self.items) do
        v:SetSelected(false);
    end

    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    for k, v in pairs(self.items) do
        if v.gameObject == target then
            v:SetSelected(true);
            local tab = v.data;
            local coord = String2Table(tab.coord);
            local main_role = SceneManager:GetInstance():GetMainRole()
            local main_pos = main_role:GetPosition();
            TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
            OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, call_back);
            AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
        end
    end

end

function DungeonBossLeftCenter:HandleTog(target, bool)
    if bool then
        self.ScrollView.gameObject:SetActive(true);
    else
        self.ScrollView.gameObject:SetActive(false);
    end
end

function DungeonBossLeftCenter:EndDungeon()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%02d";
    --整个副本的结束时间
    if self.end_time then
        local aaa = not self.startSchedule;
        local bbb = not self.hideByIcon;
        if not self.startSchedule and not self.hideByIcon then
            SetGameObjectActive(self.endTime.gameObject, true);
        else
            SetGameObjectActive(self.endTime.gameObject, false);
        end

        timeTab = TimeManager:GetLastTimeData(os.time(), self.end_time);
        if table.isempty(timeTab) then
            Notify.ShowText("The dungeon is over. It's time to clean up");
            GlobalSchedule.StopFun(self.bossschedules);
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
    if self.dungeon_is_exit then
        SetGameObjectActive(self.endTime.gameObject, false);
    end
end

function DungeonBossLeftCenter:HandleMin(target, x, y)
    RemoveClickEvent(self.min_btn.gameObject);
    local scale = self.min_btn.transform.localScale;
    local localPos = self.contents.transform.localPosition;

    local end_call_back = function()
        SetLocalScale(self.min_btn.transform, -scale.x, 1, 1);
        if scale.x == 1 then
            --self.contents.gameObject:SetActive(false);
        end
        AddClickEvent(self.min_btn.gameObject, handler(self, self.HandleMin))
    end

    local moveAction;
    local finishAction;
    local action;

    if scale.x == -1 then
        moveAction = cc.MoveTo(0.3, 0, 0, 0);
        finishAction = cc.CallFunc(end_call_back)
        action = cc.Sequence(moveAction, finishAction);
        cc.ActionManager:GetInstance():addAction(action, self.contents.transform);
        --self.contents.gameObject:SetActive(true);
    else
        moveAction = cc.MoveTo(0.3, -300, localPos.y, localPos.z)
        finishAction = cc.CallFunc(end_call_back)
        action = cc.Sequence(moveAction, finishAction);
        cc.ActionManager:GetInstance():addAction(action, self.contents.transform);
    end
end

function DungeonBossLeftCenter:HandleRefresh(target, x, y)
    if self.currentType == 1 then
        self:InitTogs(2);
    else
        self:InitTogs(1);
    end

end

function DungeonBossLeftCenter:HaneleBossList(data)
    if self.items and self.currentType == 1 then
        for i = 1, #self.items, 1 do
            self:RefreshDungeonScrollItem(self.items[i]);
        end
    end
end

function DungeonBossLeftCenter:HandleMainMiddleLeftLoaded()

end

function DungeonBossLeftCenter:HandleBossInfo(data)
    for i = 1, #self.items, 1 do
        self:RefreshDungeonScrollItem(self.items[i]);
    end
end

function DungeonBossLeftCenter:hanelSavageData()
    local data = DungeonModel:GetInstance().angryData;
    if data.anger and data.kickcd then
        local anger = data.anger;--增加后的愤怒值
        local kickcd = data.kickcd;--愤怒值满后被踢出副本的倒计时(时间戳)
        if self.angry then
            self.angry.gameObject:SetActive(true);
        end
        if anger > 100 then
            anger = 100;
        end
        self.angryblood:UpdateCurrentBlood(100 - anger, 100);
        self.angry_text.text = tostring(100 - anger);
        if kickcd ~= 0 and not self.kick_countdown then
            SetGameObjectActive(self.countdown_bg, true);
            self.kick_countdown = CountDownText(self.countdown_bg, { formatTime = "%d", isShowMin = false, duration = 0.2, nodes = { "countdown_text" } });
            self.kick_countdown:StartSechudle(kickcd, handler(self, self.HandleCountDown), handler(self, self.HandleCDUpdate));
        end
    end
end

function DungeonBossLeftCenter:HandleCountDown()
    if self.countdown_bg then
        SetGameObjectActive(self.countdown_bg, false);
    end
    print2("结束了" .. tostring(os.time()) .. "__" .. tostring(DungeonModel:GetInstance().angryData.kickcd))
end

function DungeonBossLeftCenter:HandleCDUpdate()
    local data = DungeonModel:GetInstance().angryData;
    if data.kickcd then
        if data.kickcd - os.time() < 11 then
            local panel = lua_panelMgr:GetPanel(DungeonExpelPanel);
            if not panel then
                lua_panelMgr:GetPanelOrCreate(DungeonExpelPanel):Open();
            end
        end
    end
end

function DungeonBossLeftCenter:RefreshDungeonScrollItem(item)
    local enterData = DungeonModel:GetInstance():GetCurrentEnter();
    if enterData then
        item:StartSechudle(enterData.etime);
    end

end

function DungeonBossLeftCenter:SetShow(flag)
    self.show = flag
end

function DungeonBossLeftCenter:InitBossData()
    self.bossData = {};
    for k, v in pairs(Config.db_boss) do
        if v.type == 1 then
            table.insert(self.bossData, v);
        end
    end
end

function DungeonBossLeftCenter:HandleDungeonStartCountDown()
    local timeTab = nil;
    local timestr = "";
    local formatTime = "%d";--"%02d";
    if self.startDungeonTime then
        timeTab = TimeManager:GetLastTimeData(os.time(), self.startDungeonTime);

        if table.isempty(timeTab) then
            GlobalSchedule.StopFun(self.startSchedule);
            if self.startTime and self.startTime.gameObject then
                SetGameObjectActive(self.startTime.gameObject, false);
            end
            if self.endDungeonStartCountDownFun then
                self.endDungeonStartCountDownFun();
            end
            self.startSchedule = nil;
        else
            if timeTab.sec then
                timestr = timestr .. string.format(formatTime, timeTab.sec);
            end
            self.time.text = timestr;
        end
    end
end
