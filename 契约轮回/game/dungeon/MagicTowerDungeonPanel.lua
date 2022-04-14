--
-- @Author: LaoY
-- @Date:   2018-12-12 10:57:24
--
MagicTowerDungeonPanel = MagicTowerDungeonPanel or class("MagicTowerDungeonPanel", DungeonMainBasePanel)
local this = MagicTowerDungeonPanel

function MagicTowerDungeonPanel:ctor()
    self.abName = "dungeon"
    self.assetName = "MagicTowerDungeonPanel"
    self.events = {}
    self.dungeon_type = enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER
    self.use_background = false
    self.change_scene_close = true
end

function MagicTowerDungeonPanel:dctor()
    if self.event_id_1 then
        self.model:RemoveListener(self.event_id_1)
        self.event_id_1 = nil
    end

    GlobalEvent:RemoveTabListener(self.events);

    if self.timeschedules then
        GlobalSchedule:Stop(self.timeschedules);
    end
    if self.tuantable_reddot then
        self.tuantable_reddot:destroy()
        self.tuantable_reddot = nil
    end
    if self.startSchedule then
        GlobalSchedule.StopFun(self.startSchedule);
    end
    self.startSchedule = nil;
end

function MagicTowerDungeonPanel:Open()
    MagicTowerDungeonPanel.super.Open(self)
end

function MagicTowerDungeonPanel:LoadCallBack()
    self.nodes = {
        "btn_turn_table", "endTime/endTitleTxt", "endTime", "hardshow/floorTex", "hardshow",
        "startTime", "startTime/time",
    }
    self:GetChildren(self.nodes)
    self.endTitleTxt = GetText(self.endTitleTxt)
    self.floorTex = GetText(self.floorTex);
    self.time = GetText(self.time);
    self:AddEvent()

    self.tuantable_reddot = RedDot(self.btn_turn_table.transform, nil, RedDot.RedDotType.Nor)
    self.tuantable_reddot:SetPosition(30, 25)
    --self.tuantable_reddot:SetRedDotParam(true)
    self:UpdateReddot();

    SetAlignType(self.hardshow.transform, bit.bor(AlignType.Left, AlignType.Null))

    self:StartDungeonCD();
end

function MagicTowerDungeonPanel:StartDungeonCD()
    SetGameObjectActive(self.startTime, true);
    SetGameObjectActive(self.endTime.gameObject, false);
    local dungeConfig = Config.db_dunge[self.model.curDungeonID];
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

function MagicTowerDungeonPanel:AddEvent()
    local function call_back(target, x, y)

        lua_panelMgr:OpenPanel(MagicTowerTurnTablePanel, self.dungeon_type)
    end
    AddClickEvent(self.btn_turn_table.gameObject, call_back)

    local function callBack()
        SetGameObjectActive(self.endTime.gameObject, true);
        self.hideByIcon = false;
        SetVisible(self.btn_turn_table, true)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.HideTopRightIcon, callBack)

    AddEventListenerInTab(DungeonEvent.UpdateReddot, handler(self, self.UpdateReddot), self.events);

    local function callBack()
        SetGameObjectActive(self.endTime.gameObject, false);
        self.hideByIcon = true;
        SetVisible(self.btn_turn_table, false)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(MainEvent.ShowTopRightIcon, callBack)
    local function callBack(data)
        if self.timeschedules then
            GlobalSchedule:Stop(self.timeschedules);
        end
        SetVisible(self.endTime, false)
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_AUTO_EXIT, callBack)

    local function callBack1(data)
        self.end_time = data.end_time
        if self.timeschedules then
            GlobalSchedule:Stop(self.timeschedules);
        end
        self.timeschedules = GlobalSchedule:Start(handler(self, self.EndDungeon), 0.2, -1);
    end

    self.events[#self.events + 1] = GlobalEvent:AddListener(DungeonEvent.DUNGEON_EXP_GOLD_INFO, callBack1)

    local function call_back()
        local main_role = SceneManager:GetInstance():GetMainRole()
        if main_role then
            main_role:SetRotateY(45)
        end
    end
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSceneEnd, call_back)
    self.events[#self.events + 1] = GlobalEvent:AddListener(EventName.ChangeSameScene, call_back)
    call_back()

    local function call_back()
        OperationManager:GetInstance():StopAStarMove();
        AutoFightManager:GetInstance():StartAutoFight()
        local id = DungeonModel:GetInstance().curDungeonID
        if DungeonModel.GetInstance().DungeEnter[id] then
            self.floorTex.text = string.format("m%sc", DungeonModel.GetInstance().DungeEnter[id].floor)
        else
            self.floorTex.text = "";
        end

        DungeonCtrl:GetInstance():RequeseExpDungeonInfo();
        self:StartDungeonCD();
    end
    self.event_id_1 = self.model:AddListener(DungeonEvent.ResEnterDungeonInfo, call_back)
    call_back()
end

function MagicTowerDungeonPanel:EndDungeon()
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

    MagicTowerDungeonPanel.super.EndDungeon(self);
end

function MagicTowerDungeonPanel:OpenCallBack()
    self:UpdateView()
end

function MagicTowerDungeonPanel:UpdateView()

end

function MagicTowerDungeonPanel:CloseCallBack()

end

function MagicTowerDungeonPanel:UpdateReddot()
    local data = self.model.dungeon_info_list[enum.SCENE_STYPE.SCENE_STYPE_DUNGE_MAGICTOWER];
    if data then
        local info = data.info;
        if info and info.loto_times > 0 then
            self.tuantable_reddot:SetRedDotParam(true);
        else
            self.tuantable_reddot:SetRedDotParam(false);
        end
    end
end