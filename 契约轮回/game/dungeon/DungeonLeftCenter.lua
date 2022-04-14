DungeonLeftCenter = DungeonLeftCenter or class("DungeonLeftCenter", BaseItem);
local this = DungeonLeftCenter

--21D760绿色D6302F红色

function DungeonLeftCenter:ctor(parent_node, bossid)
    self.abName = "dungeon";
    self.image_ab = "dungeon_image";
    self.assetName = "DungeonLeftCenter"
    self.layer = "Bottom"
    self.bossid = bossid;
    self.model = DungeonModel.GetInstance()
    self.events = {};
    self.schedules = {};

    self.items = {};
    self.show = true
    DungeonLeftCenter.super.Load(self)
end

function DungeonLeftCenter:dctor()
    self:StopTime()
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
end

function DungeonLeftCenter:LoadCallBack()
    self.nodes = {
        "contents/ScrollView/Viewport/Content", "contents/list_item_0", "contents", "contents/refresh_btn",
        "contents/ScrollView", "contents/angry/angryblood", "contents/angry", "contents/angry/angry_text", "contents/angry/countdown_bg", "contents/angry/countdown_bg/countdown_label", "contents/angry/countdown_bg/countdown_text",

        "togs/boss", "togs/team", "togs/tog_bg", "min_btn", --"contents/togs/team","contents/togs/boss",
        "contents/vigor","contents/vigor/vigorblood","contents/vigor/vigor_text",
        "contents/tips","contents/tipsbg","contents/potionIcon","contents/refreshIcon",
    }
    self:GetChildren(self.nodes)

    SetLocalPosition(self.transform, 0, 0, 0);
    SetVisible(self.potionIcon,false)
    SetVisible(self.refreshIcon,false)
    SetAlignType(self.potionIcon, bit.bor(AlignType.Right, AlignType.Top))
    --SetAlignType(self.transform, bit.bor(AlignType.Left, AlignType.Top))
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

    local sceneid = SceneManager:GetInstance():GetSceneId();
    local sceneConfig = Config.db_scene[sceneid];
    if sceneConfig then
        if sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD 
            or sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_NOTIRED then
            DungeonCtrl.GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_WORLD)
        elseif sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME then
            DungeonCtrl.GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_HOME)
        elseif sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WILD then
            DungeonCtrl.GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_WILD)
        elseif sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
            DungeonCtrl.GetInstance():RequestBossList(enum.BOSS_TYPE.BOSS_TYPE_SPATIOTEMPORAL)
        end
    end
end

function DungeonLeftCenter:CheckMove()

    local call_back = function()
        if not AutoFightManager:GetInstance():GetAutoFightState() then
            GlobalEvent:Brocast(FightEvent.AutoFight)
        end
    end

    local function Func()
        if self.items then
            if DungeonModel:GetInstance().SelectedDungeonID then
                local id = DungeonModel:GetInstance().SelectedDungeonID
                --for k, v in pairs(self.items) do
                local data = Config.db_boss[DungeonModel:GetInstance().SelectedDungeonID];
                --if v.data.id == dsddDungeonModel:GetInstance().SelectedDungeonID then
                if data then
                    local tab = data;
                    local coord = String2Table(tab.coord);

                    if DungeonModel.GetInstance():IsSpacetimeCrackBoss(tab.type) then
                        coord = DungeonModel.GetInstance():GetSpacetimeCrackBossCoord(tab)
                    end

                    local main_role = SceneManager:GetInstance():GetMainRole()
                    --local main_pos = main_role:GetPosition();
                    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高

                    -- local range = AutoFightManager:GetInstance().def_range
                    if coord then
                        OperationManager:GetInstance():TryMoveToPosition(nil, nil, { x = coord[1], y = coord[2] }, handler(self, self.MoveCallBack, DungeonModel:GetInstance().SelectedDungeonID), self:GetRange());
                    end
                    -- AutoFightManager:GetInstancde():SetAutoPosition({ x = coord[1], y = coord[2] })
                    DungeonModel:GetInstance().SelectedDungeonID = nil;
                    return ;
                end

                --end
                --end
            elseif DungeonModel:GetInstance().targetPos then
                local targetX = DungeonModel:GetInstance().targetPos.x
                local targetY = DungeonModel:GetInstance().targetPos.y
                OperationManager.GetInstance():TryMoveToPosition(nil, nil, {x=targetX, y=targetY})
                DungeonModel:GetInstance().targetPos = nil
            end
        end
    end
    self:StopTime()
    GlobalSchedule:StartOnce(Func, 0.1)
end

function DungeonLeftCenter:StopTime()
    if self.time_id then
        GlobalSchedule:Stop(self.time_id)
        self.time_id = nil
    end
end

function DungeonLeftCenter:GetRange()
    if not AutoFightManager:GetInstance().def_range then
        return nil
    end
    -- return AutoFightManager:GetInstance().def_range * 0.9
    return 500
end

function DungeonLeftCenter:MoveCallBack(boss_type_id)
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
        if  DungeonModel.GetInstance():IsSpacetimeCrackBoss(tab.type) then
            coord = DungeonModel.GetInstance():GetSpacetimeCrackBossCoord(tab)
        end
        if coord then
            AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
        end
       
    end
end

function DungeonLeftCenter:InitUI()
    self.min_btn = GetButton(self.min_btn);
    self.team = GetToggle(self.team);
    self.boss = GetToggle(self.boss);
    self.vigor_text = GetText(self.vigor_text)

    SetLocalScale(self.min_btn.transform, 1, 1, 1);

    --print2("当前场景ID : " .. SceneManager:GetInstance():GetSceneId());
    local sceneMosterTab = self.model.localBossTab[tostring(SceneManager:GetInstance():GetSceneId())];--SceneManager:GetInstance():GetSceneId()
    if not sceneMosterTab then
        self.refresh_btn.gameObject:SetActive(false);
    end

    self:InitTogs(1);

    self.angry_text = GetText(self.angry_text);

    self.angryblood = BossBloodItem(self.angryblood, 3);
    self.angryblood:UpdateCurrentBloodImmi(0, 100);
    self.angry.gameObject:SetActive(false);

    self.vigorblood = BossBloodItem(self.vigorblood, 3)
    self.vigorblood:UpdateCurrentBloodImmi(0, 100);
    self.vigor.gameObject:SetActive(false);

    self:hanelSavageData(DungeonModel:GetInstance().angryData);
    self:UpdateVigor()

    self.countdown_text = GetText(self.countdown_text);

    SetGameObjectActive(self.countdown_bg, false);
    if self.tips then
        local scene_id = SceneManager:GetInstance():GetSceneId()
        if scene_id == 20000 then
            SetVisible(self.tips, true)
            SetVisible(self.tipsbg, true)
        else
            SetVisible(self.tips, false)
            SetVisible(self.tipsbg, false)
        end
    end
    if self.potionIcon and self.refreshIcon then
        local sceneId = SceneManager:GetInstance():GetSceneId()
        local config = Config.db_scene[sceneId]
        if not config then
            return
        end
        if config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then --世界首领 --幻之岛
            SetVisible(self.potionIcon,true)
        else
            SetVisible(self.potionIcon,false)
        end
    end


end

DungeonLeftCenter.currentType = 1;
function DungeonLeftCenter:InitTogs(type)
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

            local item = self:GetDungeLeftCenterItem()(newObject(self.list_item_0), bossTab);

            item.gameObject.name = "world_boss_" .. i;
            self.items[i] = item;
            --item:SetJie();
            item.transform:SetParent(self.Content.transform);
            SetLocalScale(item.transform, 1, 1, 1);
            SetLocalPosition(item.transform, 0, 0, 0);
            self:RefreshDungeonScrollItem(item);
        end
        --self.items[1]:SetSelected(true);
        local rt = self.Content:GetComponent("RectTransform");
        rt.sizeDelta = Vector2(rt.sizeDelta.x, #tab * 46);

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
                local item = self:GetDungeLeftCenterItem()(newObject(self.list_item_0), monsterTab);
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

function DungeonLeftCenter:AddEvents()
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

    local function call_back2()
        local sceneid = SceneManager:GetInstance():GetSceneId();
        local sceneConfig = Config.db_scene[sceneid];
        if sceneConfig and (sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD or sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME) then
            self:InitTogs(1);
            self:CheckMove();
            SetGameObjectActive(self.angry, false);
        elseif sceneConfig and sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WILD then
            self:InitTogs(1);
            self:CheckMove();
        elseif sceneConfig and sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
            self:InitTogs(1);
            self:CheckMove();
        end
        
    end
    GlobalEvent.AddEventListenerInTab(EventName.ChangeSceneEnd, call_back2, self.events);

    local function call_back()
        self:UpdateBuff()
        self:UpdateVigor()
    end
    self.role_buff_event_id = RoleInfoModel:GetInstance():GetMainRoleData():BindData("buffs", call_back)


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
        local sceneId = SceneManager:GetInstance():GetSceneId()
        local config = Config.db_scene[sceneId]
        if not config then
            return
        end
        if config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then
            if self.potionIcon then
                SetGameObjectActive(self.potionIcon.gameObject , false);
            end
        end
    end

    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.ShowTopRightIcon, call_back);

    local call_back1 = function()
        local sceneId = SceneManager:GetInstance():GetSceneId()
        local config = Config.db_scene[sceneId]
        if not config then
            return
        end
        if config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_WORLD or config.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_BEAST then
            if self.potionIcon then
                SetGameObjectActive(self.potionIcon.gameObject , true);
            end
        end

    end
    self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.HideTopRightIcon, call_back1);


    --self.events[#self.events + 1] = GlobalEvent.AddEventListener(MainEvent.MAIN_MIDDLE_LEFT_LOADED , handler(self , self.HandleMainMiddleLeftLoaded))
end

function DungeonLeftCenter:AddTogEvents()
    for i = 1, #self.items, 1 do
        local item = self.items[i];
        AddClickEvent(item.gameObject, handler(self, self.HandleMoveTo));
    end
end

function DungeonLeftCenter:HandleMoveTo(target, x, y)
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
            local boss_type = tab.type
            local function ok_func()
                local coord = String2Table(tab.coord);
                if  DungeonModel.GetInstance():IsSpacetimeCrackBoss(tab.type) then
                    coord = DungeonModel.GetInstance():GetSpacetimeCrackBossCoord(tab)
                end
                if coord and #coord == 2 then
                    local main_role = SceneManager:GetInstance():GetMainRole()
                    local main_pos = main_role:GetPosition();
                    TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                    OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, handler(self, self.MoveCallBack, v.data.id), self:GetRange());
                else
                    if DungeonModel:GetInstance():IsBeastIsland(v) or  DungeonModel.GetInstance():IsSpacetimeCrackBoss(tab.type) then
                        Notify.ShowText("It needs to be explored by yourself");
                    end
                end
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
                    Dialog.ShowTwo("Tip",str,"Confirm",ok_func,nil,"Cancel",nil,nil,"Don't notice me again today",false,nil,-10010)
                    return
                end
            end
            local power = RoleInfoModel:GetInstance():GetMainRoleData().power
            if power < tab.power  then
                local str = string.format("\n\nThat boss has higher CP<color=#eb0000>(%s)</color> and challenging it might be difficult.Proceed anyway?\n   My CP：%s",tab.power,power)
                Dialog.ShowTwo("Tip",str,"Confirm",ok_func,nil,"Cancel",nil,nil,"Don't notice me again today",false,nil,-10011)
                return
            end

            local coord = String2Table(tab.coord);
            if  DungeonModel.GetInstance():IsSpacetimeCrackBoss(tab.type) then
                coord = DungeonModel.GetInstance():GetSpacetimeCrackBossCoord(tab)
            end
            if coord and #coord == 2 then
                local main_role = SceneManager:GetInstance():GetMainRole()
                local main_pos = main_role:GetPosition();
                TaskModel:GetInstance():StopTask();--先停掉任务,因为任务优先级高
                OperationManager:GetInstance():TryMoveToPosition(nil, main_pos, { x = coord[1], y = coord[2] }, handler(self, self.MoveCallBack, v.data.id), self:GetRange());
            else
                if DungeonModel:GetInstance():IsBeastIsland(v) or  DungeonModel.GetInstance():IsSpacetimeCrackBoss(tab.type) then
                    Notify.ShowText("It needs to be explored by yourself");
                end
            end

            -- AutoFightManager:GetInstance():SetAutoPosition({ x = coord[1], y = coord[2] })
        end
    end

end

function DungeonLeftCenter:HandleTog(target, bool)
    if bool then
        self.ScrollView.gameObject:SetActive(true);
    else
        self.ScrollView.gameObject:SetActive(false);
    end
end

--function DungeonLeftCenter:HandleExit(target, x, y)
--    SceneControler:GetInstance():RequestSceneLeave();
--end

function DungeonLeftCenter:HandleMin(target, x, y)
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

function DungeonLeftCenter:HandleRefresh(target, x, y)
    if self.currentType == 1 then
        self:InitTogs(2);
    else
        self:InitTogs(1);
    end

end

function DungeonLeftCenter:HaneleBossList(data)
    --logError("DungeonLeftCenter:HaneleBossList")
    if self.items and self.currentType == 1 then
        for i = 1, #self.items, 1 do
            self:RefreshDungeonScrollItem(self.items[i]);
        end
    end
end

function DungeonLeftCenter:HandleMainMiddleLeftLoaded()

end

function DungeonLeftCenter:HandleBossInfo(data)
    --logError("DungeonLeftCenter:HandleBossInfo")
    for i = 1, #self.items, 1 do
        self:RefreshDungeonScrollItem(self.items[i]);
    end
end

function DungeonLeftCenter:hanelSavageData()
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

function DungeonLeftCenter:UpdateVigor()
    local scene_id = SceneManager:GetInstance():GetSceneId()
    if scene_id >= 20100 and scene_id <= 20102 then
        local scenecfg = Config.db_scene[scene_id]
        if scenecfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_HOME then
            SetVisible(self.vigor, true)
            local main_role_data = RoleInfoModel:GetInstance():GetMainRoleData()
            if main_role_data then
                local buffer = main_role_data:GetBuffByID(enum.BUFF_ID.BUFF_ID_HOME_BOSS_VIGOR)
                local vigor_value = (buffer and buffer.value or 0)
                vigor_value = (vigor_value > 100 and 100 or vigor_value)
                self.vigorblood:UpdateCurrentBlood(100-vigor_value, 100)
                self.vigor_text.text = 100-vigor_value
            end
        end
    else
        SetVisible(self.vigor, false)
    end
end

function DungeonLeftCenter:HandleCountDown()
    if self.countdown_bg then
        SetGameObjectActive(self.countdown_bg, false);
    end
    print2("结束了" .. tostring(os.time()) .. "__" .. tostring(DungeonModel:GetInstance().angryData.kickcd))
end

function DungeonLeftCenter:HandleCDUpdate()
    local data = DungeonModel:GetInstance().angryData;
    if data.kickcd then
        if data.kickcd - os.time() < 11 then
            local panel = lua_panelMgr:GetPanel(DungeonExpelPanel);
            if not panel then
                panel = lua_panelMgr:GetPanelOrCreate(DungeonExpelPanel)
                panel:Open()
            end

            local sceneid = SceneManager:GetInstance():GetSceneId();
            local sceneConfig = Config.db_scene[sceneid];
            if sceneConfig.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
                if panel then
                    panel:SetText(SpacetimeCrackDungePanel.ExpelTip)
                end
            end
        end
    end
end

function DungeonLeftCenter:RefreshDungeonScrollItem(item)
    local bossTab = item.data;

    local bossinfo = DungeonModel:GetInstance():GetDungeonBossInfo(bossTab.type, bossTab.id);
    if bossinfo then
        local time = bossinfo.born;--1541494877
        item:StartSechudle(time);
    end
end

function DungeonLeftCenter:SetShow(flag)
    self.show = flag
end

function DungeonLeftCenter:InitBossData()
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

function DungeonLeftCenter:UpdateBuff()
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

function DungeonLeftCenter:CheckBeastMission()
    if self.model:IsBeastScene() or self.model:IsCrossBeastScene() then
        TaskModel:GetInstance():DoTaskByType(enum.TASK_TYPE.TASK_TYPE_BEAST);
    end
end

function DungeonLeftCenter:GetDungeLeftCenterItem(  )
    local scene_id = SceneManager.GetInstance():GetSceneId()
    local scene_cfg = Config.db_scene[scene_id]
    if scene_cfg.stype == enum.SCENE_STYPE.SCENE_STYPE_BOSS_FISSURE then
        return SpacetimeCrackDungeonLeftCenterItem
    end

    return DungeonLeftCenterItem
end