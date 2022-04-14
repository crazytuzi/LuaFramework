BeastIslandLeftCenter = BeastIslandLeftCenter or class("BeastIslandLeftCenter", BaseItem);
local this = BeastIslandLeftCenter

--21D760绿色D6302F红色

function BeastIslandLeftCenter:ctor(parent_node, bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "BeastIslandLeftCenter"
    self.layer = "Bottom"
    self.bossid = bossid;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};

    self.items = {};
    self.show = true
    BeastIslandLeftCenter.super.Load(self)
end

function BeastIslandLeftCenter:dctor()
    GlobalEvent:RemoveTabListener(self.events);
    self.events = nil;
    if self.schedule then
        GlobalSchedule:Stop(self.schedule);
    end

    destroyTab(self.items);
    self.items = {};

    if self.kick_countdown then
        self.kick_countdown:destroy();
    end
    self.kick_countdown = nil;

    local panel = lua_panelMgr:GetPanel(DungeonExpelPanel);
    if panel then
        panel:Close();
    end

    if self.role_buff_event_id then
        RoleInfoModel:GetInstance():GetMainRoleData():RemoveListener(self.role_buff_event_id);
    end
    self.role_buff_event_id = nil;
    destroyTab(self.misAwards);
    self.misAwards = nil;

    if self.award then
        self.award:destroy();
    end
    self.award = nil;
end

function BeastIslandLeftCenter:LoadCallBack()
    self.nodes = {
        "contents/ScrollView/Viewport/Content", "contents/list_item_0", "contents", "contents/refresh_btn",
        "contents/ScrollView",
        "contents/static_con",


        "btns", "btns/list_btn", "btns/mis_btn", "btns/warbtn",

        "miss", "miss/mis_desc", "miss/mis_award", "miss/mis_content", "miss/mis_name",
        "miss/mis_jixu", "miss/mis_jixu/jixu_text","contents/potionIcon",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0);
    SetAlignType(self.potionIcon, bit.bor(AlignType.Right, AlignType.Top))
    --SetAlignType(self.contents, bit.bor(AlignType.Left, AlignType.Null));
    --SetAlignType(self.btns, bit.bor(AlignType.Left, AlignType.Null));
    --self.exit_btn = GetButton(self.exit_btn);
    --SetAlignType(self.exit_btn.transform, bit.bor(AlignType.Right, AlignType.Top))
    --SetLocalPosition(self.exit_btn.transform, 383, 300, 0);
    --Notify.ShowText(GetSizeDeltaX(self.bg.transform))
    self:InitUI();

    self:AddEvents();

    self:CheckMove();

    self:CheckBeastMission();

    if not self.show then
        SetVisible(self.gameObject, false)
    end
end

function BeastIslandLeftCenter:InitUI()
    self.list_btn = GetToggle(self.list_btn);
    self.mis_btn = GetToggle(self.mis_btn);
    self.mis_btn.isOn = false;
    self.warbtn = GetButton(self.warbtn);
    SetGameObjectActive(self.warbtn);

    self.mis_name = GetText(self.mis_name);
    self.mis_content = GetText(self.mis_content);
    self.mis_desc = GetText(self.mis_desc);
    --SetGameObjectActive(self.mis_content)
    self.mis_content.text = "Finishing quests will grant you:";
    self.mis_jixu = GetButton(self.mis_jixu);
    self.jixu_text = GetText(self.jixu_text);

    local sceneMosterTab = self.model.localBossTab[tostring(SceneManager:GetInstance():GetSceneId())];--SceneManager:GetInstance():GetSceneId()
    if not sceneMosterTab then
        self.refresh_btn.gameObject:SetActive(false);
    end

    self:InitTogs(1);
    self:HandleTogBtn(nil, nil, nil, self.list_btn);
    self:InitMission();
end

function BeastIslandLeftCenter:CheckMove()

    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    if self.items then
        if DungeonModel:GetInstance().SelectedDungeonID then
            local data = Config.db_boss[DungeonModel:GetInstance().SelectedDungeonID];
            if data then
                local tab = data;
                local coord = String2Table(tab.coord);
                local main_role = SceneManager:GetInstance():GetMainRole()
                local main_pos = main_role:GetPosition();
                TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高

                -- local range = AutoFightManager:GetInstance().def_range
                OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, handler(self, self.MoveCallBack, DungeonModel:GetInstance().SelectedDungeonID), self:GetRange());
                -- AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
                DungeonModel:GetInstance().SelectedDungeonID = nil;
                return ;
            end
        elseif DungeonModel:GetInstance().targetPos then
            local targetX = DungeonModel:GetInstance().targetPos.x
            local targetY = DungeonModel:GetInstance().targetPos.y
            OperationManager.GetInstance():TryMoveToPosition(nil, nil, {x=targetX, y=targetY})
            DungeonModel:GetInstance().targetPos = nil
        end


    end
end

function BeastIslandLeftCenter:GetRange()
    if not AutoFightManager:GetInstance().def_range then
        return nil
    end
    -- return AutoFightManager:GetInstance().def_range * 0.9
    return 500
end

function BeastIslandLeftCenter:MoveCallBack(boss_type_id)
    -- if not AutoFightManager:GetInstance():GetAutoFightState() then
    -- 	GlobalEvent:Brocast(FightEvent.AutoFight)
    -- end

    AutoFightManager:GetInstance():Start(true)

    local object = SceneManager:GetInstance():GetCreepByTypeId(boss_type_id)
    if object then
        object:OnClick()
    end
    local data = Config.db_boss[boss_type_id];
    if data then
        local tab = data;
        local coord = String2Table(tab.coord);
        AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
    end
end

BeastIslandLeftCenter.currentType = 1;
function BeastIslandLeftCenter:InitTogs(type)
    destroyTab(self.items);
    if not self.is_loaded then
        return
    end
    self.items = {};
    self.currentType = type;
    if type == 1 then
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
            if bossTab.seq <= 2 then
                SetParent(item.transform, self.static_con);
                --item.transform:SetParent(self.Content.transform);
                SetLocalScale(item.transform, 1, 1, 1);
                SetLocalPosition(item.transform, 0, 0, 0);
            else
                item.transform:SetParent(self.Content.transform);
                SetLocalScale(item.transform, 1, 1, 1);
                SetLocalPosition(item.transform, 0, 0, 0);
            end
            self:RefreshDungeonScrollItem(item);
        end
        --self.items[1]:SetSelected(true);
        local rt = self.Content:GetComponent("RectTransform");
        rt.sizeDelta = Vector2(rt.sizeDelta.x, (#tab - 2) * 46);

        self.list_item_0.gameObject:SetActive(false);
    else
        self.list_item_0.gameObject:SetActive(true);
        local sceneid = tostring(SceneManager:GetInstance():GetSceneId());
        local sceneMosterTab = self.model.localBossTab[sceneid];--SceneManager:GetInstance():GetSceneId()
        if sceneMosterTab then
            self.refresh_btn.gameObject:SetActive(true);
            table.sort(sceneMosterTab, SeqCompareFun);

            for i = 1, #sceneMosterTab, 1 do
                local monsterTab = sceneMosterTab[i];
                local item = DungeonLeftCenterItem(newObject(self.list_item_0), monsterTab);
                item.gameObject.name = "world_moster_" .. i;
                self.items[i] = item;
                --item:SetJie();
                item.transform:SetParent(self.Content.transform);
                SetLocalScale(item.transform, 1, 1, 1);
                SetLocalPosition(item.transform, 0, 0, 0);
                --self:RefreshDungeonScrollItem(item);
            end
            --self.items[1]:SetSelected(true);

            local rt = self.Content:GetComponent("RectTransform");
            rt.sizeDelta = Vector2(rt.sizeDelta.x, #sceneMosterTab * 40);
        end

        self.list_item_0.gameObject:SetActive(false);
    end
    SetLocalPosition(self.Content.transform, 0, 0, 0)
    self:AddTogEvents();
end

function BeastIslandLeftCenter:AddEvents()
    --刷新事件
    AddClickEvent(self.refresh_btn.gameObject, handler(self, self.HandleRefresh));

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(DungeonEvent.WORLD_BOSS_LIST, handler(self, self.HaneleBossList));

    GlobalEvent.AddEventListenerInTab(MainEvent.MAIN_MIDDLE_LEFT_LOADED, handler(self, self.HandleMainMiddleLeftLoaded), self.events);

    GlobalEvent.AddEventListenerInTab(DungeonEvent.WORLD_BOSS_INFO, handler(self, self.HandleBossInfo), self.events);

    GlobalEvent.AddEventListenerInTab(EventName.GameReset, function()
        self:destroy()
    end, self.events);

    local function call_back2()
        local sceneid = SceneManager:GetInstance():GetSceneId();
        local sceneConfig = Config.db_scene[sceneid];
        if sceneConfig and (sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD or sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME) then
            self:InitTogs(1);
            self:CheckMove();
        elseif sceneConfig and sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WILD then
            self:InitTogs(1);
            self:CheckMove();
        end
    end
    GlobalEvent.AddEventListenerInTab(EventName.ChangeSceneEnd, call_back2, self.events);

    local function call_back()
        self:UpdateBuff()
    end
    self.role_buff_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("buffs", call_back);

    AddClickEvent(self.list_btn.gameObject, handler(self, self.HandleTogBtn, self.list_btn));
    AddClickEvent(self.mis_btn.gameObject, handler(self, self.HandleTogBtn, self.mis_btn));

    AddEventListenerInTab(TaskEvent.FinishTask, handler(self, self.FinishTask), self.events);
    local update_task_call_back = function()
        self:InitMission(true);
        --print2("update_task_call_back");
    end
    AddEventListenerInTab(TaskEvent.GlobalUpdateTask, update_task_call_back, self.events);
    AddClickEvent(self.mis_name.gameObject, handler(self, self.HandleDoTask));
    AddClickEvent(self.mis_desc.gameObject, handler(self, self.HandleDoTask));
    AddClickEvent(self.mis_jixu.gameObject, handler(self, self.HandleDoTask));


    local function call_back()
        --11101  世界首领疲劳药水
        --11102  幻之岛疲劳药水
        --11103  可选疲劳药水（幻之岛/世界首领
        -- local num =  BagModel:GetInstance():GetItemNumByItemID(self.costId)
        local itemId = 0
        local sceneId = SceneManager:GetInstance():GetSceneId()
        local config = Config.db_scene[sceneId]
        if not config then
            return
        end
        if config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD  then --世界首领
            itemId = 11101
        elseif config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST  then--幻之岛
            itemId = 11102
        end

        local num =  BagModel:GetInstance():GetItemNumByItemID(itemId)
        if num <= 0 then
            local  num1 = BagModel:GetInstance():GetItemNumByItemID(11103)
            if num1 <= 0 then
                Notify.ShowText("No available items for now, please attend this event more")
            else -- 使用礼包
                local uid = BagModel:GetInstance():GetUidByItemID(11103)
                GoodsController:GetInstance():RequestUseItem(uid,1)
            end
        else
            lua_panelMgr:GetPanelOrCreate(DungeonTimesPanel):Open(itemId)
        end

    end
    AddButtonEvent(self.potionIcon.gameObject,call_back)



    local call_back = function()
        if self.potionIcon then
            SetGameObjectActive(self.potionIcon.gameObject , false);
        end
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        if self.potionIcon then
            SetGameObjectActive(self.potionIcon.gameObject , true);
        end

    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);
end

function BeastIslandLeftCenter:HandleTogBtn(go, x, y, btn)
    self.list_btn.isOn = false;
    self.mis_btn.isOn = false;
    btn.isOn = true;

    SetGameObjectActive(self.contents, self.list_btn.isOn);
    SetGameObjectActive(self.miss, self.mis_btn.isOn);
end

function BeastIslandLeftCenter:AddTogEvents()
    for i = 1, #self.items, 1 do
        local item = self.items[i];
        AddClickEvent(item.gameObject, handler(self, self.HandleMoveTo));
    end
end

function BeastIslandLeftCenter:HandleMoveTo(target, x, y)
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
            if #coord == 2 then
                local function ok_func()
                    local main_role = SceneManager:GetInstance():GetMainRole()
                    local main_pos = main_role:GetPosition();
                    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                    OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, handler(self, self.MoveCallBack, v.data.id), self:GetRange());
                end

                local boss_drop_limit = String2Table(Config.db_game["boss_drop_limit"].val)[1]
                if table.containValue(boss_drop_limit, boss_type) then
                    local level = RoleInfoModel:GetInstance():GetRoleValue("level")
                    local creep = Config.db_creep[tab.id]
                    --local buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(buff_id)
                    --if buff then
                    --    DungeonModel:GetInstance().tired = buff.value;
                    --    DungeonModel:GetInstance():UpdateReddot();
                    --end
                    local sceneId = SceneManager:GetInstance():GetSceneId()
                    local config = Config.db_scene[sceneId]
                    if not config then
                        return
                    end
                    local str = "\nYour level is X higher than the boss and no loot will be available after defeating it.\nProceed?"
                    local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
                    if config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD  then --世界首领
                        local buffer = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_WORLD_BOSS_KILL_TIRED)
                        --if buffer then
                        local value = (buffer and buffer.value or 0)
                        local tired = 10;
                        if Config.db_game["boss_tired"] then
                            local val = String2Table(Config.db_game["boss_tired"].val);
                            tired = tonumber(val[1]);
                        end
                        local curTired = SafetoNumber(tired) - SafetoNumber(value)
                        str = "\nYour level is X higher than the boss and no loot will be available after defeating it.\nProceed?\nDaily fatigue left:"..curTired
                        --end
                    elseif config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST  then --幻之岛
                        local buffer = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_BEAST_BOSS_KILL_TIRED)
                        --if buffer then
                        local value = (buffer and buffer.value or 0)
                        local tired = 10;
                        if Config.db_game["boss_tired"] then
                            local val = String2Table(Config.db_game["boss_tired"].val);
                            tired = tonumber(val[1]);
                        end
                        local curTired = SafetoNumber(tired) - SafetoNumber(value)
                        str = "\nYour level is X higher than the boss and no loot will be available after defeating it.\nProceed?\nDaily fatigue left:"..curTired
                        -- end
                    end
                    if level-creep.level >= tab.drop_lv then
                        Dialog.ShowTwo("Tip",str,"Confirm",ok_func,nil,"Cancel",nil,nil,"Don't notice me again today",false,nil,-20010)
                        return
                    end
                end
                local power = RoleInfoModel:GetInstance():GetMainRoleData().power
                if power < tab.power  then
                    local str = string.format("\n\nThat boss has higher CP<color=#eb0000>(%s)</color> and challenging it might be difficult.Proceed anyway?\n   My CP：%s",tab.power,power)
                    Dialog.ShowTwo("Tip",str,"Confirm",ok_func,nil,"Cancel",nil,nil,"Don't notice me again today",false,nil,-20011)
                    return
                end

                ok_func()
                --local main_role = SceneManager:GetInstance():GetMainRole()
                --local main_pos = main_role:GetPosition();
                --TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                --OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, handler(self, self.MoveCallBack, v.data.id), self:GetRange());
            else
                if DungeonModel:GetInstance():IsBeastIsland(v) then
                    Notify.ShowText("It needs to be explored by yourself");
                end
            end

            -- AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
        end
    end

end

function BeastIslandLeftCenter:HandleMin(target, x, y)
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

function BeastIslandLeftCenter:HandleRefresh(target, x, y)
    if self.currentType == 1 then
        self:InitTogs(2);
    else
        self:InitTogs(1);
    end

end

function BeastIslandLeftCenter:HaneleBossList(data)
    if self.items and self.currentType == 1 then
        for i = 1, #self.items, 1 do
            self:RefreshDungeonScrollItem(self.items[i]);
        end
    end
end

function BeastIslandLeftCenter:HandleMainMiddleLeftLoaded()

end

function BeastIslandLeftCenter:HandleBossInfo(data)
    for i = 1, #self.items, 1 do
        self:RefreshDungeonScrollItem(self.items[i]);
    end
end

function BeastIslandLeftCenter:RefreshDungeonScrollItem(item)
    local bossTab = item.data;

    local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(bossTab.type, bossTab.id);
    if bossinfo then
        local time = bossinfo.born;--1541494877
        item:StartSechudle(time);
    end
end

function BeastIslandLeftCenter:SetShow(flag)
    self.show = flag
end

function BeastIslandLeftCenter:InitBossData()
    self.bossData = {};
    local tab = self.model:GetBossesByType();
    for k, v in pairs(tab) do
        if v.scene == SceneManager:GetInstance():GetSceneId() then
            if v.seq ~= 0 then
                table.insert(self.bossData, v);
            end
        end
    end
end

function BeastIslandLeftCenter:UpdateBuff()
    local buff_effect_type
    local sceneId = SceneManager:GetInstance():GetSceneId()
    local config = Config.db_scene[sceneId]
    if not config then
        return
    end
    if config.type ~= enum.SCENE_TYPE.SCENE_TYPE_BOSS then
        return
    end
    local max_tired = 1
    if config.stype == enum.SCENE_STYPE.SCENE_STYPE_DUNGE_WORLD_BOSS
            or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD
            or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME
            or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WILD
    then
        buff_effect_type = enum.BUFF_EFFECT.BUFF_EFFECT_BOSSTIRED
        max_tired = String2Table(Config.db_game.boss_tired.val)[1]
    elseif config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then
        buff_effect_type = enum.BUFF_EFFECT.BUFF_EFFECT_BEASTBOSSTIRED
        max_tired = String2Table(Config.db_game.boss_tired.val)[1]
    else
        return
    end
    local buff_id = RoleInfoModel:GetInstance():GetMainRoleData():IsHaveBuffEffectType(buff_effect_type)
    local bo = false
    if buff_id then
        local buff = RoleInfoModel:GetInstance():GetMainRoleData():GetBuffByID(buff_id)
        if buff then
            DungeonModel:GetInstance().tired = buff.value;
            DungeonModel:GetInstance():UpdateReddot();
        end
    end
end

function BeastIslandLeftCenter:CheckBeastMission()
    if self.model:IsBeastScene() or self.model:IsCrossBeastScene() then
        TaskModel:GetInstance():DoTaskByType(enum.TASK_TYPE.TASK_TYPE_BEAST);
    end
end

function BeastIslandLeftCenter:InitMission(isfinish)
    local task_type = nil;
    local task_type2 = nil;

    if self.model:IsCrossBeastScene() then
        task_type = enum.TASK_TYPE.TASK_TYPE_PREV4;
        task_type2 = enum.TASK_TYPE.TASK_TYPE_LOOP4;
    else
        task_type = enum.TASK_TYPE.TASK_TYPE_PREV3;
        task_type2 = enum.TASK_TYPE.TASK_TYPE_LOOP3;
    end
    local taskID = TaskModel:GetInstance():GetTaskIdByType(task_type);
    local taskID2 = TaskModel:GetInstance():GetTaskIdByType(task_type2);
    local taskConfig;
    local info;
    local realTaskID = nil;
    local realTaskConfig;
    if taskID then
        realTaskID = TaskModel:GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_BEAST);
        taskConfig = Config.db_task[taskID];
        realTaskConfig = Config.db_task[realTaskID];
        info = TaskModel:GetInstance():GetTask(taskID);
        if taskConfig then
            if enum.TASK_TYPE[taskConfig.type] then
                self.mis_name.text = string.format("[%s]%s<color=#27EF6B>(%s/%s)</color>", enum.TASK_TYPE[taskConfig.type], taskConfig.name, 0, 10);
            else
                self.mis_name.text = string.format("%s<color=#27EF6B>(%s/%s)</color>", taskConfig.name, 0, 10);
            end

            self.mis_desc.text = "You didn't accept the quest yet";

            self:InitMisAward(realTaskConfig);
        end
        SetGameObjectActive(self.mis_content, true);
        SetGameObjectActive(self.mis_jixu, true);
        SetGameObjectActive(self.mis_award, true);
    elseif taskID2 then
        SetGameObjectActive(self.mis_content, true);
        SetGameObjectActive(self.mis_jixu, true);
        SetGameObjectActive(self.mis_award, true);
        realTaskID = TaskModel:GetInstance():GetTaskIdByType(enum.TASK_TYPE.TASK_TYPE_BEAST);
        taskConfig = Config.db_task[taskID2];
        realTaskConfig = Config.db_task[realTaskID];
        local goals = String2Table(taskConfig.goals)
        local maxNum = tonumber(goals[1][3]);
        info = TaskModel:GetInstance():GetTask(taskID2);
        local realInfo = TaskModel:GetInstance():GetTask(realTaskID);
        local current = info.count or 0;
        --是否完成了最后一个
        local isFinLast = isfinish and (info.count + 1) == maxNum;
        if taskConfig and realTaskConfig then
            if enumName.TASK_TYPE[taskConfig.type] then
                self.mis_name.text = string.format("[%s]%s<color=#27EF6B>(%s/%s)</color>", enumName.TASK_TYPE[taskConfig.type], realTaskConfig.name, current, maxNum);
            else
                self.mis_name.text = string.format("%s<color=#27EF6B>(%s/%s)</color>", realTaskConfig.name, current, maxNum);
            end
            --self.mis_name.text = string.format("[%s]%s<color=#27EF6B>(%s/%s)</color>", enum.TASK_TYPE[taskConfig.type], taskConfig.name, current, maxNum);
            if realInfo then
                local realgoals = realInfo.goals;
                local goal_type = realgoals[1][1];
                if goal_type ~= enum.EVENT.EVENT_TALK then
                    local maxcount = tonumber(realgoals[1][3]);
                    local color = "e63232"
                    if realInfo.count >= maxcount then
                        color = "53f057"
                    end
                    self.mis_desc.text = string.format(realTaskConfig.desc .. "<color=#%s>(%s/%s)</color>", color, realInfo.count, maxcount);
                else
                    self.mis_desc.text = realTaskConfig.desc;
                end
            else
                self.mis_desc.text = realTaskConfig.desc;
            end

            self:InitMisAward(realTaskConfig);
        else
            self.mis_name.text = string.format("[%s]%s<color=#27EF6B>(%s/%s)</color>", enumName.TASK_TYPE[taskConfig.type], "Mirage Island Quest", 10, 10);
            self.mis_desc.text = "All quests are finished";
            SetGameObjectActive(self.mis_content);
            SetGameObjectActive(self.mis_jixu);
            SetGameObjectActive(self.mis_award);
        end
    end
end

function BeastIslandLeftCenter:InitMisAward(taskConfig)
    destroyTab(self.misAwards);
    self.misAwards = {};
    if not taskConfig then
        return ;
    end
    if self.award then
        self.award:destroy();
    end

    local tab = LString2Table(taskConfig.gain);
    if tab and #tab > 0 then
        local awardTab = tab[1];
        self.award = GoodsIconSettorTwo(self.mis_award.transform)
        local param = {}
        --param["model"] = self.model;
        param["item_id"] = awardTab[1];
        param["num"] = awardTab[2];
        param["can_click"] = true;
        param["bind"] = awardTab[3] == 1;
        param["size"] = { x = 80, y = 80 }
        self.award:SetIcon(param);
    end


end

function BeastIslandLeftCenter:FinishTask(taskID)
    local beastTaskType = {
        [enum.TASK_TYPE.TASK_TYPE_PREV3] = true;
        [enum.TASK_TYPE.TASK_TYPE_LOOP3] = true;
        [enum.TASK_TYPE.TASK_TYPE_PREV4] = true;
        [enum.TASK_TYPE.TASK_TYPE_LOOP4] = true;
        [enum.TASK_TYPE.TASK_TYPE_BEAST] = true;
    }
    if taskID then
        local taskConfig = Config.db_task[taskID];
        if taskConfig and (taskConfig.type == enum.TASK_TYPE.TASK_TYPE_BEAST or beastTaskType[taskConfig.type]) then
            self:InitMission(true);
        end
        --self:UpdateTaskInfo()

    end
end

function BeastIslandLeftCenter:HandleDoTask(go, x, y)
    local task_type = nil;
    local task_type2 = nil;

    if self.model:IsCrossBeastScene() then
        task_type = enum.TASK_TYPE.TASK_TYPE_PREV4;
        task_type2 = enum.TASK_TYPE.TASK_TYPE_LOOP4;
    else
        task_type = enum.TASK_TYPE.TASK_TYPE_PREV3;
        task_type2 = enum.TASK_TYPE.TASK_TYPE_LOOP3;
    end
    local taskID = TaskModel:GetInstance():GetTaskIdByType(task_type);
    local taskID2 = TaskModel:GetInstance():GetTaskIdByType(task_type2);

    local fun = function()
        Notify.ShowText("You need to seek for targets manually");
    end

    if taskID then
        TaskModel:GetInstance():DoTaskByType(task_type, nil, fun)
    else
        TaskModel:GetInstance():DoTaskByType(enum.TASK_TYPE.TASK_TYPE_BEAST, nil, fun)
    end
end