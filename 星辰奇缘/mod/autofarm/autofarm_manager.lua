AutoFarmManager = AutoFarmManager or BaseClass(BaseManager)

function AutoFarmManager:__init()
    if AutoFarmManager.Instance then
        Log.Error("不可以对单例对象重复实例化")
        return
    end
    AutoFarmManager.Instance = self
    self.model = AutoFarmModel.New()
    self.index = 1
    self:InitHandler()
    self.movindex = 1
    self.Farming = false
    self.FarmingAncientDemons = false
    self.pointlist = {}
    self.beginFcallback = function()
        self:beginfight()
    end

    self.endFcallback = function()
        if RoleManager.Instance.RoleData.satiety == 0 then
            self:stopFarm()
            return
        end
        self:endfight()
    end

    self.stopFarmcallback = function()
        NoticeManager.Instance:FloatTipsByString(TI18N("野外挂机已结束"))
        self:stopFarm()
    end

    self.autofarmcallback = function()
        self:AutoFarm()
    end

    self.startautoFarmcallback = function()
        self:startautoFarm()
    end

    self._StarAncientDemons = function()
        self:StarAncientDemons()
    end

    self._StopAncientDemons = function()
        self:StopAncientDemons()
    end

    self.OnUpdate = EventLib.New()
end

function AutoFarmManager:InitHandler()
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:CheckMap() end)
    EventMgr.Instance:AddListener(event_name.team_update, function() self:teamFollow() end)
end

--------------通用任意地图两点巡逻-------------

function AutoFarmManager:startautoFarm(  )
    -- StartButtontxt = "停止挂机"
    -- ctx:InvokeDelay(function ()
    --     windows.close_window(windows.panel.autofarmwin)
    -- end, 0.5)
    self:StopAncientDemons()

    self:stopFarm()
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(3)
    self.pointlist = {}
    self.Farming = true
    local currmapid = SceneManager.Instance:CurrentMapId()
    for _,v in pairs(DataHangup.data_list) do
        if currmapid == v.map_id then
            local length = #v.path
            local index = Random.Range(1,length)
            index = math.ceil(index)
            local pathdata = v.path

            for i=1,#pathdata/2 do
                local posi = SceneManager.Instance.sceneModel:transport_small_pos(pathdata[2*i-1],  pathdata[2*i])
                table.insert( self.pointlist, {x = posi.x, y = posi.y} )
            end
        end
     end
     if #self.pointlist < 1 then
        -- Log.Error("挂机巡逻点配置长度为0")
        return self:stopFarm()
     end
    -- event_name.map_click
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
    EventMgr.Instance:AddListener(event_name.begin_fight, self.beginFcallback)

    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFcallback)
    EventMgr.Instance:AddListener(event_name.end_fight, self.endFcallback)

    EventMgr.Instance:RemoveListener(event_name.scene_load, self.stopFarmcallback)
    EventMgr.Instance:AddListener(event_name.scene_load, self.stopFarmcallback)

    EventMgr.Instance:RemoveListener(event_name.scene_load, self.startautoFarmcallback)

    EventMgr.Instance:RemoveListener(event_name.map_click, self.stopFarmcallback)
    EventMgr.Instance:AddListener(event_name.map_click, self.stopFarmcallback)
    -- EventMgr.Instance:AddListener(event_name.map_click, self.stopFarmcallback)
    self.autofarmcallback()

    self.OnUpdate:Fire()
end


function AutoFarmManager:AutoFarm()
    if CombatManager.Instance.isFighting == true then
        return
    end
    if not BaseUtils.isnull(SceneManager.Instance.sceneElementsModel.self_view) then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = function() self:AutoFarm() end
    end
    self.movindex = self.movindex%2+1
    local length = #self.pointlist
    local index = Random.Range(1,length)
    index = math.ceil(index)
    if self.index == index then
        if index == 1 then
            index = length
        else
            index = 1
        end
    end
    self.index = index
    local pos = self.pointlist[self.index]
    if pos == nil then
        return self:stopFarm()
    elseif not BaseUtils.isnull(SceneManager.Instance.sceneElementsModel) then
        SceneManager.Instance.sceneElementsModel:Self_MoveToPoint(pos.x, pos.y)
    end
end

function AutoFarmManager:beginfight(  )
    -- CombatManager.Instance.isFighting=true
    if not BaseUtils.isnull(SceneManager.Instance.sceneElementsModel.self_view) then
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
    end
end

function AutoFarmManager:endfight(  )
    -- CombatManager.Instance.isFighting=false
    self:AutoFarm()
end

function AutoFarmManager:stopFarm(  )
    -- StartButtontxt = TI18N("原地挂机")
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    if SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view.moveEnd_CallBack = nil
    end
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.startautoFarmcallback)
    EventMgr.Instance:RemoveListener(event_name.begin_fight, self.beginFcallback)
    EventMgr.Instance:RemoveListener(event_name.end_fight, self.endFcallback)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self.stopFarmcallback)
    EventMgr.Instance:RemoveListener(event_name.map_click, self.stopFarmcallback)
    if self.Farming and SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
    end
    self.Farming = false

    self.OnUpdate:Fire()
end


function AutoFarmManager:setPoint(  )
    self.model:SetPoint()
end

function AutoFarmManager:tofarm(map_id)
    self.model:CloseMain()
    SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
    -- SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(1)
    if CombatManager.Instance.isFighting == true then
        --战斗中不执行
        NoticeManager.Instance:FloatTipsByString(TI18N("当前在战斗中，不能进行该操作"))
    end
    local ok = false
    for _,v in pairs(DataHangup.data_list) do
        if map_id == v.map_id then
            ok = true
        end
    end
    if not ok then
        NoticeManager.Instance:FloatTipsByString(TI18N("当前地图不可挂机"))
        return
    end
    if map_id == SceneManager.Instance:CurrentMapId() then
        self.startautoFarmcallback()
        return
    end
    SceneManager.Instance.sceneElementsModel:Self_Transport(map_id, 0, 0)

    EventMgr.Instance:AddListener(event_name.scene_load, self.startautoFarmcallback)

    NoticeManager.Instance:FloatTipsByString(TI18N("开始野外挂机"))
    self:StopAncientDemons()
end

function AutoFarmManager:CheckMap()
    local currmapid = SceneManager.Instance:CurrentMapId()

    if currmapid == 10007 then -- 10007地图特殊处理
        self.model:ShowButtonArea(true)
    else
        local ok = false
        for _,v in pairs(DataHangup.data_list) do
            if currmapid == v.map_id then
                ok = true
            end
        end

        if ok then
            self.model:ShowButtonArea()
        else
            self.model:CloseButtonArea()
        end
    end
end

function AutoFarmManager:teamFollow()
    if RoleEumn.TeamStatus.Follow == TeamManager.Instance:MyStatus() then
        self:stopFarm()
        self:StopAncientDemons()    
    end
end

function AutoFarmManager:StarAncientDemons(teamUp)
    self:stopFarm()

    self.FarmingAncientDemons = true

    EventMgr.Instance:RemoveListener(event_name.end_fight, self._StarAncientDemons)
    EventMgr.Instance:AddListener(event_name.end_fight, self._StarAncientDemons)

    EventMgr.Instance:RemoveListener(event_name.scene_load, self._StarAncientDemons)
    EventMgr.Instance:AddListener(event_name.scene_load, self._StarAncientDemons)

    EventMgr.Instance:RemoveListener(event_name.map_click, self._StopAncientDemons)
    EventMgr.Instance:AddListener(event_name.map_click, self._StopAncientDemons)

    local currmapid = SceneManager.Instance:CurrentMapId()

    local data_map = nil
    for k,v in ipairs(DataTreasure.data_map) do
        if currmapid == v.map_base_id then
            data_map = v
        end
    end

    if data_map == nil then
        local map_id = -1
        for k,v in ipairs(DataTreasure.data_map) do
            if map_id == -1 and RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData.lev <= v.max_lev then
                map_id = v.map_base_id
            end
        end
        if map_id ~= -1 then
            SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
            SceneManager.Instance.sceneElementsModel:Self_Transport(map_id, 0, 0)
        end
    else
        if data_map.min_lev > RoleManager.Instance.RoleData.lev then
            local map_id = -1
            for k,v in ipairs(DataTreasure.data_map) do
                if map_id == -1 and RoleManager.Instance.RoleData.lev >= v.min_lev and RoleManager.Instance.RoleData.lev <= v.max_lev then
                    map_id = v.map_base_id
                end
            end
            if map_id ~= -1 then
                SceneManager.Instance.sceneElementsModel:Self_CancelAutoPath()
                SceneManager.Instance.sceneElementsModel:Self_Transport(map_id, 0, 0)
            end
        else
            local option = 31
            if data_map.min_lev >100 then
                option = 39
            elseif data_map.min_lev >94 then
                option = 38
            elseif data_map.min_lev >84 then
                option = 37
            elseif data_map.min_lev > 74 then
                option = 36
            elseif data_map.min_lev > 64 then
                option = 35
            elseif data_map.min_lev > 54 then
                option = 34
            elseif data_map.min_lev > 44 then
                option = 33
            elseif data_map.min_lev > 34 then
                option = 32
            elseif data_map.min_lev > 24 then
                option = 31
            end
            local first = DataTeam.data_match[option].tab_id
            local second = DataTeam.data_match[option].id

            local leader = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[first] = second
                TeamManager.Instance.LevelOption = 1
                TeamManager.Instance:Send11701()
                LuaTimer.Add(200, function() WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1}) end)
            end
            local member = function()
                TeamManager.Instance.TypeOptions = {}
                TeamManager.Instance.TypeOptions[first] = second
                TeamManager.Instance.LevelOption = 1
                WindowManager.Instance:OpenWindowById(WindowConfig.WinID.team, {1})
            end
            if not TeamManager.Instance:HasTeam() then
                if teamUp and TeamManager.Instance:MyMatchStatus() ~= TeamEumn.MatchStatus.Recruiting and TeamManager.Instance:MyMatchStatus() ~= TeamEumn.MatchStatus.Matching then
                    local info = {
                        Desc = TI18N("上古妖魔在场景中<color='#ffff00'>随机出现</color>，可在四周找找看{face_1,16}"),
                        Ltxt = TI18N("我要当队长"),
                        Mtxt = "",
                        Rtxt = TI18N("我要当队员"),
                        LGreen = true,
                        MGreen = false,
                        RGreen = false,
                        LCallback = leader,
                        MCallback = nil,
                        RCallback = member,
                    }
                    LuaTimer.Add(800, function()
                        TipsManager.Instance:ShowTeamUp(info)
                    end)
                end
            elseif RoleEumn.TeamStatus.Follow == TeamManager.Instance:MyStatus() then
                NoticeManager.Instance:FloatTipsByString(TI18N("您当前处于归队状态，无法开始搜寻上古妖魔"))
                return
            elseif RoleEumn.TeamStatus.Away == TeamManager.Instance:MyStatus() then
                NoticeManager.Instance:FloatTipsByString(TI18N("开始搜寻非战斗状态上古妖魔"))
            elseif RoleEumn.TeamStatus.Leader == TeamManager.Instance:MyStatus() then
                NoticeManager.Instance:FloatTipsByString(TI18N("开始搜寻非战斗状态上古妖魔"))
                if teamUp and TeamManager.Instance.teamNumber < 5 then
                    -- member()
                    TeamManager.Instance:Send11711(second, 1)
                end
            end

            local units = SceneManager.Instance.sceneElementsModel:GetSceneData_Npc()
            for k,v in pairs(units) do
                if v.unittype == SceneConstData.unittype_monster then
                    local baseData = DataUnit.data_unit[v.baseid]
                    if baseData.fun_type == SceneConstData.fun_type_treasure_ghost and v.status == 0 then
                        SceneManager.Instance.sceneElementsModel:Self_MoveToTarget(v.uniqueid)
                        return
                    end
                end
            end

            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有非战斗状态上古妖魔"))
        end
    end

    self.OnUpdate:Fire()
end

function AutoFarmManager:StopAncientDemons(  )
    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(4)
    
    EventMgr.Instance:RemoveListener(event_name.end_fight, self._StarAncientDemons)
    EventMgr.Instance:RemoveListener(event_name.scene_load, self._StarAncientDemons)
    EventMgr.Instance:RemoveListener(event_name.map_click, self._StopAncientDemons)

    if self.Farming and SceneManager.Instance.sceneElementsModel.self_view ~= nil then
        SceneManager.Instance.sceneElementsModel.self_view:StopMoveTo()
    end
    self.FarmingAncientDemons = false

    self.OnUpdate:Fire()
end