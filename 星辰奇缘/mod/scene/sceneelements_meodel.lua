SceneElementsModel = SceneElementsModel or BaseClass(BaseModel)

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

function SceneElementsModel:__init()
    self.scene_elements = nil

    self.scenePathModel = ScenePathModel.New()

    ------------ 场景设置 ------------
    self.ShowRoleNum = tonumber(DataSystem.data_setting[1]) or 14 -- 最大人数限制
    self.NowRoleNum = 0 -- 当前人数
    self.LimitRoleNum = false
    self.createCount_Max = tonumber(DataSystem.data_setting[2]) or 1 -- 同时创建人物最大个数
    self.createCount = 0 -- 当前创建人物个数
    self.createTick = tonumber(DataSystem.data_setting[3]) or 1 -- 创建人物的时间间隔
    self.createTposeCount_Max = tonumber(DataSystem.data_setting[4]) or 1 -- 同时创建模型最大个数
    self.createTposeCount = 0 -- 当前创建模型个数
    self.createTposeTick = tonumber(DataSystem.data_setting[5]) or 3 -- 创建模型的时间间隔
    self.tickCount = 0
    self.removeOutView = true

    ------------ Prefabs ------------
    self.instantiate_object = nil -- 创建模板 人物、npc、传送点
    self.selected_effect = nil -- 选中单位特效
    self.selected_effect_special_mark = false -- 特殊选中框标记，下次选中时恢复默认设置
    self.instantiate_selected_effect = nil -- 选中单位特效
    self.TargetPointEffect = nil -- 移动目标点特效
    self.TargetPointEffect2 = nil -- 移动目标点特效
    self.TargetPointEffect3 = nil -- 移动目标点特效
    self.LastTargetPointEffect = nil -- 上次使用的移动目标点特效

    self.TargetFootEffect = {}  --移动足迹总表
    self.LastTargetFootEffect = {}
    self.footDesTimer = {}
    self.lastFootId = {}

    ------------ 列表 ------------
    self.RoleView_List = {}
    self.NpcView_List = {}
    self.curSceneUnitDataList = {}
    self.passengerVirtualData = {}

    self.WaitForCreateUnitData_List = {}
    self.VirtualUnitData_List = {}

    ------------ 跟随 ------------
    self.FollowUnit_List = {}
    self.FollowDistance = {1, 0.5, 0.4, 0.4}

    self.FollowData = nil

    ------------ 自己 ------------
    self.self_unique = ""
    self.self_view = nil
    self.self_data = nil
    self.self_fly = 1

    self.self_pet_unique = ""
    self.self_pet_view = nil

    self.follow_npc_unique = ""
    self.follow_npc_view = nil

    self.target_uniqueid = nil
    self.isovercontroll = true -- 能否控制行走

    ------------ 各种隐藏标记Mark ------------
    self.Show_Self_Mark = true
    self.Show_Self_Weapon_Mark = true
    self.Show_Self_Pet_Mark = true
    self.Show_OtherRole_Mark = true
    self.Show_Npc_Mark = true
    self.Show_Role_Wing_Mark = true
    self.Show_OtherRole_Ride_Mark = true
    self.Show_Transform_Mark = true

    ------------ 发送移动包 ------------
    self.SendMoveCount = 0
    self.LastSendPosition_X = 0
    self.LastSendPosition_Y = 0

    self.mapid = 0

    self.onArena = false

    self.isContinuousTouch = false -- 开启检测连续移动
    self.touchCount = 0  -- 连续移动倒计时
    self.touchCount_Max = 25 -- 连续移动倒计时 最大值
    if BaseUtils.IsIPhonePlayer() then --ios特殊处理
        self.touchCount_Max = 30 -- 连续移动倒计时 最大值
    end

    self.click_CoolDowm = 0 -- 点击地图的冷却时间

    self.miss_teamleader = false -- 丢失队长标记，连续检查到两个则离队再归队

    --- 采集条，公用2
    self.collection = CollectPanel.New()

    self.isOursTeam = false
end

function SceneElementsModel:__delete()

end

function SceneElementsModel:SetSceneActive(active)
    if active then
        for k,v in pairs(self.RoleView_List) do
            v:SetActive(v.active, true)
        end
        for k,v in pairs(self.NpcView_List) do
            v:SetActive(v.active, true)
        end

        self.TargetPointEffect:SetActive(false)
        self.TargetPointEffect2:SetActive(false)
        self.TargetPointEffect3:SetActive(false)

        for _,dat in pairs(self.TargetFootEffect) do
            if dat ~= nil then
                for i,v in pairs(dat) do
                    if v.effectView ~= nil then
                        v.effectView:SetActive(false)
                    end
                end
            end
        end
    end
end

-- 地图、场景元素加载完成
function SceneElementsModel:OnLoadSceneElements()
    local scene_elements = SceneManager.Instance.sceneModel.scene_elements

    -- 场景
    self.scene_elements = scene_elements
    -- 人物、npc、传送点  Prefabs
    self.instantiate_object = scene_elements.transform:FindChild("InstantiateObject")
    self.instantiate_object_role = self.instantiate_object:FindChild("Role").gameObject
    self.instantiate_object_npc = self.instantiate_object:FindChild("NPC").gameObject
    self.instantiate_object_teleporter = self.instantiate_object:FindChild("Teleporter").gameObject
    self.instantiate_object_home = self.instantiate_object:FindChild("Home").gameObject

    -- 选中单位特效
    self.instantiate_selected_effect = self.instantiate_object:FindChild("SelectedEffect").gameObject
    -- 移动目标点特效
    self.TargetPointEffect = scene_elements.transform:FindChild("TargetPointEffect").gameObject
    self.TargetPointEffect2 = scene_elements.transform:FindChild("TargetPointEffect2").gameObject
    self.TargetPointEffect3 = scene_elements.transform:FindChild("TargetPointEffect3").gameObject
    self.timerTable = {};
    self.timerTable[self.TargetPointEffect] = 0
    self.timerTable[self.TargetPointEffect2] = 0
    self.timerTable[self.TargetPointEffect3] = 0

end

-- 地图、场景元素加载完成
function SceneElementsModel:AddListener()
    EventMgr.Instance:AddListener(event_name.scene_load, function() self:OnSceneLoad() end)
    EventMgr.Instance:AddListener(event_name.team_create, function() self:setfollow() end)
    EventMgr.Instance:AddListener(event_name.team_leave, function() self:setfollow() end)
    EventMgr.Instance:AddListener(event_name.team_update, function() self:setfollow() end)
    -- EventMgr.Instance:AddListener(event_name.team_info_update, function() self:setfollow() end)
    EventMgr.Instance:AddListener(event_name.battlepet_update, function(change_list) self:battlepet_update(change_list) end)

    EventMgr.Instance:AddListener(event_name.begin_fight, function(combat_type, fightResult) self:Self_CancelAutoPath() self:Self_StopMove() end)
end

-- FixedUpdate 驱动所有场景单位、玩家
function SceneElementsModel:FixedUpdate()
    if not SceneManager.Instance.sceneModel.map_loaded then
        return
    end

    for k,v in pairs(self.RoleView_List) do
        v:FixedUpdate()
    end
    for k,v in pairs(self.NpcView_List) do
        v:FixedUpdate()
    end
    self:UpdateRoleFootStatus()
    self:SendMove()
    self:ContinuousTouch()
end

-- OnTick 每0.2秒执行一次
function SceneElementsModel:OnTick()
    self.tickCount = self.tickCount + 1
    if self.tickCount % self.createTick == 0 then
        self:CreateSceneUnits()
    end
    if self.tickCount % self.createTposeTick == 0 then
        self:CreateTpose()
    end
    if self.tickCount % 5 == 0 then
        self:UpdateWaitForCreateUnitData()
        self:RemoveOutViewUnits()
        self:RemoveShowRoleNum()
        self:CheckOnArena()

        if RoleManager.Instance.RoleData.event == RoleEumn.Event.None then
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.NewQuestionMatch then
            NewExamManager.Instance:CheckOnArena()
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.CanYon then
            CanYonManager.Instance:CheckOnArena()
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragon
            or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonFight
            or RoleManager.Instance.RoleData.event == RoleEumn.Event.GuildDragonRod
            then
            GuildDragonManager.Instance:CheckOnArena()
        end
    end
    if self.tickCount % 11 == 0 then
        self:SubCreateCount()
        self:SubCreateTposeCount()
    end
    if self.tickCount % 26 == 0 then
        self:check_teamfollow()
    end
    self:Follow()
end

-- OnTick 每0.2秒执行一次
function SceneElementsModel:Reconnet()
    self.VirtualUnitData_List = {}
end

-- 开始加载单位，计数加1
function SceneElementsModel:AddCreateCount()
    self.createCount = self.createCount + 1
end

-- 加载单位完成，计数减1
function SceneElementsModel:SubCreateCount()
    LuaTimer.Add(50, function()
            if self.createCount > 0 then self.createCount = self.createCount - 1 end
        end)
end

-- 开始加载模型，计数加1
function SceneElementsModel:AddCreateTposeCount()
    self.createTposeCount = self.createTposeCount + 1
end

-- 加载单位模型，计数减1
function SceneElementsModel:SubCreateTposeCount()
    LuaTimer.Add(50, function()
            if self.createTposeCount > 0 then self.createTposeCount = self.createTposeCount - 1 end
        end)
end

-- 检查自己是否在擂台上
function SceneElementsModel:CheckOnArena()
    if RoleManager.Instance.RoleData.lev > 39 and self.self_view ~= nil then
        local onArena = self:IsOnArena(self.self_view)
        if not self.onArena and onArena then
            self.onArena = true
            NoticeManager.Instance:FloatTipsByString(TI18N("你已进入<color='#ffff00'>擂台区域</color>，<color='#ffff00'>擂台区域</color>内不需要申请即可进行切磋"))
        elseif self.onArena and not onArena then
            self.onArena = false
            NoticeManager.Instance:FloatTipsByString(TI18N("你已离开<color='#ffff00'>擂台区域</color>，不会自动进入切磋战斗"))
        end
    end
end

-- 创建缓存的单位
function SceneElementsModel:CreateSceneUnits()
    MarryManager.Instance.model:update_virtual() -- 修改结缘伴侣双方为虚拟单位，则可以立刻创建出来

    for k,v in pairs(self.WaitForCreateUnitData_List) do -- 优先加载npc
        if v.unittype ~= SceneConstData.unittype_role then
            self:CreateSceneUnit(k, v)
        end
    end
    for k,v in pairs(self.WaitForCreateUnitData_List) do -- 然后加载玩家
        if v.unittype == SceneConstData.unittype_role then
            self:CreateSceneUnit(k, v)
        end
    end
end

-- 创建带创建的模型
function SceneElementsModel:CreateTpose()
    -- for k,v in pairs(self.NpcView_List) do
    --     if v.CreateTpose_Mark then
    --         v:ChangeLook()
    --     end
    -- end
    for k,v in pairs(self.RoleView_List) do
        if v.CreateTpose_Mark then
            v:ChangeLook()
        end
    end
end

-- 检查并删除超出九宫格的人物
function SceneElementsModel:Check9Gird()
    if self.self_view ~= nil then
        local roleData = RoleManager.Instance.RoleData
        if roleData.event == RoleEumn.Event.GuildFight or roleData.event == RoleEumn.Event.SkyLantern or roleData.event == RoleEumn.Event.CanYon or roleData.event == RoleEumn.Event.Halloween or roleData.event == RoleEumn.Event.StarChallenge then
            for k,v in pairs(self.WaitForCreateUnitData_List) do
                if v.unittype == SceneConstData.unittype_role then
                    if math.abs(self.self_view.data.gx - v.gx) > 1 or math.abs(self.self_view.data.gy - v.gy) > 1 then
                        if v.out9Gird then -- 如果上次检查是超出九宫格，则删除该数据
                            self.WaitForCreateUnitData_List[k] = nil
                        else -- 如果上次检查未超出九宫格，则写入标记
                            v.out9Gird = true
                        end
                    else
                        v.out9Gird = false
                    end
                end
            end
        end
    end
end

-- 移除视野外的单位
function SceneElementsModel:RemoveOutViewUnits()
    if not self.removeOutView then return end

    local removeList = {}
    for k,v in pairs(self.RoleView_List) do
        if k ~= self.self_unique and not BaseUtils.is_null(v.gameObject) then
            local p = v:GetCachedTransform().position
            if not TeamManager.Instance:IsInMyTeam(k) and not v.data.is_virtual and not v.data.exclude_outofview and SceneManager.Instance.MainCamera:OutView(p.x, p.y)  then
                removeList[k] = v
            end
        end
    end
    for k,v in pairs(self.NpcView_List) do
        if not BaseUtils.is_null(v.gameObject) then
            local p = v:GetCachedTransform().position
            if not v.data.is_virtual and not v.data.exclude_outofview and SceneManager.Instance.MainCamera:OutView(p.x, p.y) then
                removeList[k] = v
            end
        end
    end
    for k,v in pairs(removeList) do
        if v.data.unittype == SceneConstData.unittype_role then
            self:RemoveRole(k)
        else
            self:RemoveNpc(k)
        end
        self.WaitForCreateUnitData_List[k] = v.data
    end
end

-- 超出同屏显示限制的时候，移除不优先显示的玩家单位
function SceneElementsModel:RemoveShowRoleNum()
    if self.LimitRoleNum and self.ShowRoleNum >= self.NowRoleNum then

        -- 删除当队员的人，创建当队长的人 step1 原始方案，后来增加需求 step2 step3
        local canRemoveList = {} -- 可移除不优先显示的玩家单位
        for k,v in pairs(self.RoleView_List) do
            if v.data.team_status == 2 and not TeamManager.Instance:IsInMyTeam(k) and k ~= self.self_unique and not v.data.is_virtual then
                table.insert(canRemoveList, v)
            end
        end
        if #canRemoveList > 0 then
            local canCreateList = {} -- 可优先显示的玩家单位
            for k,v in pairs(self.WaitForCreateUnitData_List) do
                if v.unittype == SceneConstData.unittype_role then
                    if v.team_status == 1 then
                        if self:RoleCanCreate(k, v) then
                            table.insert(canCreateList, v)
                        end
                    end
                end
            end

            for i=1, #canRemoveList do
                if #canCreateList > 0 then
                    local canRemoveData = canRemoveList[1].data
                    self:RemoveRole(canRemoveData.uniqueid)
                    self.WaitForCreateUnitData_List[canRemoveData.uniqueid] = canRemoveData
                    local canCreateData = table.remove(canCreateList)
                    self:CreateSceneUnit(canCreateData.uniqueid, canCreateData)
                    return
                end
            end
        end

        -- 删除无队伍的人，创建当队长的人 step2
        for k,v in pairs(self.RoleView_List) do
            if v.data.team_status == 0 and not TeamManager.Instance:IsInMyTeam(k) and k ~= self.self_unique and not v.data.is_virtual then
                table.insert(canRemoveList, v)
            end
        end
        if #canRemoveList > 0 then
            local canCreateList = {} -- 可优先显示的玩家单位
            for k,v in pairs(self.WaitForCreateUnitData_List) do
                if v.unittype == SceneConstData.unittype_role then
                    if v.team_status == 1 then
                        if self:RoleCanCreate(k, v) then
                            table.insert(canCreateList, v)
                        end
                    end
                end
            end

            for i=1, #canRemoveList do
                if #canCreateList > 0 then
                    local canRemoveData = canRemoveList[1].data
                    self:RemoveRole(canRemoveData.uniqueid)
                    self.WaitForCreateUnitData_List[canRemoveData.uniqueid] = canRemoveData
                    local canCreateData = table.remove(canCreateList)
                    self:CreateSceneUnit(canCreateData.uniqueid, canCreateData)
                    return
                end
            end
        end

        -- 删除当队员的人，创建无队伍的人 step2
        for k,v in pairs(self.RoleView_List) do
            if v.data.team_status == 0 and not TeamManager.Instance:IsInMyTeam(k) and k ~= self.self_unique and not v.data.is_virtual then
                table.insert(canRemoveList, v)
            end
        end
        if #canRemoveList > 0 then
            local canCreateList = {} -- 可优先显示的玩家单位
            for k,v in pairs(self.WaitForCreateUnitData_List) do
                if v.unittype == SceneConstData.unittype_role then
                    if v.team_status == 1 then
                        if self:RoleCanCreate(k, v) then
                            table.insert(canCreateList, v)
                        end
                    end
                end
            end

            for i=1, #canRemoveList do
                if #canCreateList > 0 then
                    local canRemoveData = canRemoveList[1].data
                    self:RemoveRole(canRemoveData.uniqueid)
                    self.WaitForCreateUnitData_List[canRemoveData.uniqueid] = canRemoveData
                    local canCreateData = table.remove(canCreateList)
                    self:CreateSceneUnit(canCreateData.uniqueid, canCreateData)
                    return
                end
            end
        end
    end
end

-- 更新未创建的单位数据
function SceneElementsModel:UpdateWaitForCreateUnitData()
    for k,v in pairs(self.WaitForCreateUnitData_List) do
        if v.targetPosition ~= nil then
            local positionX = v.x
            local positionY = v.y
            local targetX = v.targetPosition.x
            local targetY = v.targetPosition.y
            if positionX ~= targetX or positionY ~= targetY then
                local p = Vector2.MoveTowards(Vector2(positionX, positionY), Vector2(targetX, targetY), v.speed)
                v.x = p.x
                v.y = p.y
            else
                v.targetPosition = nil
            end
        end
    end
end

function SceneElementsModel:SetDoubleRideData(data_list)
    for _,v in pairs(data_list) do
        for _,data in pairs(v.looks) do
            if data.looks_type == SceneConstData.looks_type_double_ride_driver then   --  81  司机数据
                local str = data.looks_str
                local driver_Data = StringHelper.Split(str, ",")
                v.driver_id = driver_Data[1]
                v.driver_platform = driver_Data[2]
                v.driver_zone_id = driver_Data[3]               
                v.passengers = {}
            elseif data.looks_type == SceneConstData.looks_type_double_ride_passenger then   --80  乘客数据
                local str = data.looks_str
                v.driver_id = 0
                v.driver_platform = ""
                v.driver_zone_id = 0   
                if str ~= "" then
                    local passenger_Data = StringHelper.Split(str, ",")       
                    v.passengers = {}
                    v.passengers[1] = {
                        rid = passenger_Data[1],
                        platform = passenger_Data[2],
                        zone_id = passenger_Data[3]
                    }
                else
                    v.passengers = {}
                end
            end
        end
    end
    return data_list
end


function SceneElementsModel:UpdateRoleList(data_list, noCreate)
    --print(debug.traceback())
    --BaseUtils.dump(data_list,"收到的数据：")

    ------  双人坐骑处理 --------
    local data_list = self:SetDoubleRideData(data_list)
    --BaseUtils.dump(data_list,"收到的数据2：")
    --local self_looks_change_Mark = false
    -- 当我是乘客的时候，先处理好event，以供下面使用
    local canShowRide = RideManager.Instance:CanShowRide(RoleManager.Instance.RoleData.event)
    for key, value in pairs(data_list) do
        local uniqueid = BaseUtils.get_unique_roleid(value.rid, value.zone_id, value.platform)
        if uniqueid == self.self_unique and value.driver_id ~= nil and value.driver_id ~= 0 then
            canShowRide = RideManager.Instance:CanShowRide(value.event)
        end
    end
    local curDataList = {}  --单次刷新的列表
    local needReflashDriverList = {}
    for key, value in pairs(data_list) do
        local uniqueid = BaseUtils.get_unique_roleid(value.rid, value.zone_id, value.platform)
        value.isDriver = 2  -- 0 乘客 1 司机  2 普通
        if canShowRide then
            if value.driver_id ~= nil and value.driver_id ~= 0 then
                --它是乘客
                value.isDriver = 0
                --这里不给最新value
                local passengerData = nil
                if self.WaitForCreateUnitData_List[uniqueid] ~= nil then
                    passengerData = self.WaitForCreateUnitData_List[uniqueid]
                    
                elseif self.RoleView_List[uniqueid] ~= nil then
                    passengerData = self.RoleView_List[uniqueid].data
                end
                if self.passengerVirtualData[uniqueid] ~= nil then
                    -- passengerData = RoleData.New()
                    -- passengerData:update_data(self.passengerVirtualData[uniqueid])
                    passengerData = self.passengerVirtualData[uniqueid]
                end
                if passengerData == nil then
                    --第一次加载就是乘客状态，刚好第一次不需要去再次刷新司机
                    passengerData = RoleData.New()
                    passengerData:update_data(value)
                end
                self:RemoveRole(uniqueid)   --先移除之前场景的准乘客
                if passengerData then
                    self.passengerVirtualData[uniqueid] = passengerData
                end
                value.noCreate = true
            elseif value.passengers ~= nil and #value.passengers > 0 then
                value.isDriver = 1
            end
        end
        if self.curSceneUnitDataList[uniqueid] ~= nil then
            --上一次数据存在
            if self.curSceneUnitDataList[uniqueid].isDriver == 0 and value.isDriver ~= 0 then
                --print("开始是乘客 后面不是，让他重新被创建")
                local pass = nil
                if self.passengerVirtualData[uniqueid] ~= nil then
                    pass = self.passengerVirtualData[uniqueid]
                end
                -- if pass ~= nil then
                --     value.gx = pass.gx
                --     value.gy = pass.gy
                --     value.x = pass.x
                --     value.y = pass.y
                -- end
                local tempValue = BaseUtils.copytab(value)
                value = RoleData.New()
                if pass ~= nil then
                   value:update_data(pass)
                end
                value:update_data(tempValue)

                value.noCreate = false
                value.beCreate = true
                self.passengerVirtualData[uniqueid] = nil
            end
            if value.isDriver == 0 then
                value.noCreate = true
            end
        end
        self.curSceneUnitDataList[uniqueid] = value
        curDataList[uniqueid] = self.curSceneUnitDataList[uniqueid]

        value.passengersData = {}
        if value.isDriver == 1 then
            for k,v in pairs(value.passengers) do
                local uniqueidPassenger = BaseUtils.get_unique_roleid(v.rid, v.zone_id, v.platform)
                local passengerData = curDataList[uniqueidPassenger]
                if passengerData == nil then
                    passengerData = self.curSceneUnitDataList[uniqueidPassenger]
                end
                if passengerData ~= nil then
                    passengerData.driver_id = value.rid
                    passengerData.isDriver = 0
                    value.passengersData[uniqueidPassenger] = passengerData
                end
            end
        end
    end
    ------   end  ---------

    for k, v in pairs(curDataList) do
        local platform = v.platform
        local rid = v.rid
        local zone_id = v.zone_id
        local uniqueroleid = BaseUtils.get_unique_roleid(rid, zone_id, platform)
        local role
        role = self.WaitForCreateUnitData_List[uniqueroleid]
        if role == nil then
            local rv = self.RoleView_List[uniqueroleid]
            if rv ~= nil then
                role = rv.data
            end
        end
        --再取乘客数据
        if role == nil then
            role = self.passengerVirtualData[uniqueroleid]
        end

        if role ~= nil and v.event ~= 4 then
            local old_role = BaseUtils.copytab(role)
            local looks_Mark = false
            local ride_Mark = false
            local name_Mark = false
            local guild_Mark = false
            local team_leader_Mark = false
            local status_Mark = false
            local speed_Mark = false
            local event_Mark = false
            local action_Mark = false
            local classes_Mark = false
            local sex_Mark = false
            local foot_mark_Mark = false
            local looks = {}
            for k2, v2 in pairs(v.looks) do
                table.insert(looks, {  looks_type = v2.looks_type
                                            ,looks_mode = v2.looks_mode
                                            ,looks_val = v2.looks_val
                                            ,looks_str = v2.looks_str})
            end
            
            if not BaseUtils.sametab(role.looks, looks) then looks_Mark = true end
            if v.isLooksChange == 1 then looks_Mark = true end  --用于刷新司机looks
            -- isNameChange  isEventChange  暂时未用到，方便后续拓展
            role.looks = looks
            if role.ride ~= v.ride then ride_Mark = true end
            if role.team_status ~= v.team_status then team_leader_Mark = true end
            if role.team_mark ~= v.team_mark then team_leader_Mark = true end
            if role.foot_mark ~= v.foot_mark then
                foot_mark_Mark = true
            end
            if role.status ~= v.status then status_Mark = true end
            if role.name ~= v.name then name_Mark = true end
            if role.guild ~= v.guild or role.guild_signature ~= v.guild_signature
                or role.guild ~= v.guild then guild_Mark = true end
            if role.speed ~= v.speed then speed_Mark = true end
            if role.classes ~= v.classes then classes_Mark = true end
            if role.sex ~= v.sex then sex_Mark = true end

            if role.event ~= v.event then event_Mark = true end
            role.event = v.event

            if role.action ~= v.action then action_Mark = true end
            role.action = v.action
            role:update_data(v)
            role.targetPosition = nil

            local rv = self.RoleView_List[uniqueroleid]
            if rv ~= nil and not rv.isdelete then
                if ride_Mark then
                    -- print(string.format("玩家骑乘状态改变 %s", role.ride))
                    rv:change_ride()
                end
                if name_Mark or guild_Mark then
                    rv:change_name()
                    rv:change_guild_name()
                end
                if team_leader_Mark then
                    -- print(string.format("玩家队长状态改变 %s", role.team_status))
                    rv:change_team_leader_mark()
                end
                if foot_mark_Mark then
                    --足迹改变啦
                    rv:change_foot_mark()
                end
                if speed_Mark then
                    rv.Speed = role.speed * SceneManager.Instance.sceneModel.mapsizeconvertvalue
                end
                if status_Mark then
                    rv:change_status_effect()
                end
                if action_Mark then
                    if role.action == 5 and uniqueroleid ~= self.self_unique then -- 如果是死亡状态且非自己，则移除RoleView，并存入WaitForCreateUnitData_List里面
                        self:RemoveRoleAndCache(uniqueroleid)
                    end
                    rv:change_status_effect()
                end
                if looks_Mark then
                    -- BaseUtils.dump(role, "ChangeLook"..role.name)
                    -- Log.Error(debug.traceback())
                    rv:ChangeLook()
                    rv:change_honor()
                end
                if not looks_Mark then
                    if classes_Mark or sex_Mark then
                        rv:ChangeLook()
                    elseif ride_Mark then
                        for k, v in pairs(role.looks) do
                            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                                -- print("SceneConstData.looktype_ride")
                                rv:ChangeRideEffect()
                                rv:ChangeLook()
                                rv:update_top_object()
                                break
                            end
                        end
                    end
                end
                if event_Mark then
                    rv:ChangeEvent(role.event, old_role.event)
                end
            elseif self.passengerVirtualData[uniqueroleid] ~= nil then
                --当前这个人是乘客，让他去刷新他的司机
                local uniqueidDriver = BaseUtils.get_unique_roleid(v.driver_id, v.driver_zone_id, v.driver_platform)
                local driverData = BaseUtils.copytab(self.curSceneUnitDataList[uniqueidDriver])
                local isNeedRefresh = false
                if driverData ~= nil then 
                    if name_Mark then
                        driverData.isNameChange = 1
                        isNeedRefresh = true
                    end
                    if looks_Mark then
                        driverData.isLooksChange = 1
                        isNeedRefresh = true
                    end
                    --为了解决家园出来的事件改变的bug，暂时屏蔽
                    -- if event_Mark then
                    --     driverData.isEventChange = 1
                    --     isNeedRefresh = true
                    -- end
                end
                if isNeedRefresh then
                    table.insert(needReflashDriverList, driverData)
                    self.passengerVirtualData[uniqueroleid]:update_data(v)
                end
            end

            -- 如果是自己，则抛looks改变事件
            -- 如果是自己，则更新飞行图标
            if uniqueroleid == self.self_unique then
                local roleData = RoleManager.Instance.RoleData
                roleData.status = role.status
                roleData.event = role.event
                roleData.ride = role.ride
                roleData.looks = role.looks
                roleData.speed = role.speed
                if status_Mark then EventMgr.Instance:Fire(event_name.role_status_change, role.status, old_role.status) end
                if event_Mark then EventMgr.Instance:Fire(event_name.role_event_change, role.event, old_role.event) end
                if ride_Mark then EventMgr.Instance:Fire(event_name.role_ride_change, role.ride, old_role.ride) end
                if looks_Mark then EventMgr.Instance:Fire(event_name.role_looks_change, role.looks, old_role.looks) end
                -- ui_chat_mini.update_flybtn()
            end

        elseif ((not noCreate and not v.noCreate) or v.beCreate) and v.event ~= 4 then
            --乘客 v.noCreate 为 True
            --BaseUtils.dump(v,"v")
            --print("创建角色："..v.name)
            role = RoleData.New()
            role:update_data(v)
            self.WaitForCreateUnitData_List[uniqueroleid] = role
            self:CreateSceneUnit(uniqueroleid, role)
        end
    end

    if #needReflashDriverList > 0 then
      self:UpdateRoleList(needReflashDriverList)
    end
end


-- 更新场景npc
function SceneElementsModel:UpdateNpcList(data_list, noCreate)
    for k, v in pairs(data_list) do
        local id = v.id
        local battleid = v.battle_id
        local uniquenpcid = BaseUtils.get_unique_npcid(id, battleid)
        local npc
        npc = self.WaitForCreateUnitData_List[uniquenpcid]
        if npc == nil then
            local nv = self.NpcView_List[uniquenpcid]
            if nv ~= nil then
                npc = nv.data
            end
        end
        -- if npc == nil then npc = self.WaitForCreateUnitData_List[uniquenpcid] end
        -- print(string.format("%s npc", uniquenpcid))
        -- print(DataUnit.data_unit[v.base_id].name)
        -- print(string.format("%s npc，坐标：%s ,%s", uniquenpcid, v.x, v.y))
        -- print(v.status)
        -- BaseUtils.dump(v, "<color=#FF0000>==========="..v.name.."</color>")
        if npc ~= nil then
            local update_scene_mark = false
            local update_looks_mark = false
            local update_name_mark = false
            local update_status_mark = false
            if v.x ~= nil and v.y ~= nil and (npc.x ~= v.x or npc.y ~= v.y) then update_scene_mark = true end
            if npc.sex ~= v.sex or npc.classes ~= v.classes then update_looks_mark = true end
            if update_looks_mark then
                local looks = {}
                for k2, v2 in pairs(v.looks) do
                    table.insert(looks, {  looks_type = v2.looks_type
                                                ,looks_mode = v2.looks_mode
                                                ,looks_val = v2.looks_val
                                                ,looks_str = v2.looks_str})
                end
                if not BaseUtils.sametab(npc.looks, looks) then update_looks_mark = true end
            end
            if npc.name ~= v.name then update_name_mark = true end
            if npc.status ~= v.status then update_status_mark = true end
            if battleid ~= 5 then -- 非吃货游行npc才更新
                npc:update_data(v)
                npc.targetPosition = nil
                local nv = self.NpcView_List[uniquenpcid]
                    if nv ~= nil then
                    if update_scene_mark then
                        local path = { SceneManager.Instance.sceneModel:transport_small_pos(npc.x, SceneManager.Instance.sceneModel:get_py_big(npc.y)) }
                        nv.TargetPositionList = path
                    end
                    if update_name_mark then
                        nv:change_name()
                    end
                    if update_looks_mark then
                        if npc.unittype ~= SceneConstData.unittype_teleporter and npc.unittype ~= SceneConstData.unittype_fun_teleporter
                            and npc.unittype ~= SceneConstData.unittype_sceneeffect and npc.unittype ~= SceneConstData.unittype_trialeffect
                            and npc.unittype ~= SceneConstData.unittype_pet and npc.unittype ~= SceneConstData.unittype_taskcollection_effect then
                            nv:ChangeLook()
                        end
                    end
                    if update_status_mark then
                        nv:change_status_effect()
                    end
                end
            end

        elseif not noCreate then
            npc = NpcData.New()
            npc:update_data(v)
            self.WaitForCreateUnitData_List[uniquenpcid] = npc

            self:CreateSceneUnit(uniquenpcid, npc)
        end
    end
    if SceneManager.Instance.sceneModel.map_loaded then
        self.npc_list_update_event_cache = false
        EventMgr.Instance:Fire(event_name.npc_list_update)
        -- Log.Debug(string.format("系统时间： %s", os.time()))
        self:AutoPath()
    else
        self.npc_list_update_event_cache = true
    end
end

-- 创建单位
function SceneElementsModel:CreateSceneUnit(uniqueid, data, tposecallback)
    if SceneManager.Instance.sceneModel.map_loaded then
        if data.unittype == SceneConstData.unittype_role then
            return self:CreateRole(uniqueid, data, tposecallback)
        else
            return self:CreateNpc(uniqueid, data, tposecallback)
        end
    else
        if tposecallback ~= nil then data.tposecallback = tposecallback end
        self.WaitForCreateUnitData_List[uniqueid] = data
        return false
    end
end

function SceneElementsModel:RoleCanCreate(uniqueroleid, role)
    if (self.createCount_Max > self.createCount -- 同时创建单位数量限制
            and ( role.action ~= 5 or uniqueroleid == self.self_unique ) -- status == 1时, 是死亡状态不创建玩家
            and ( (not self.LimitRoleNum) or (self.LimitRoleNum and self.ShowRoleNum > self.NowRoleNum) ) -- 限制玩家单位数量
            and (role.exclude_outofview or SceneManager.Instance.MainCamera:InView_big(role.x, role.y)) -- 视野限制
            and (uniqueroleid ~= self.self_unique and self.Show_OtherRole_Mark)
            or role.is_virtual
            or (uniqueroleid == self.self_unique and self.Show_Self_Mark) or role.no_hide
            or TeamManager.Instance:IsInMyTeam(uniqueroleid)
            ) and SceneManager.Instance.sceneModel.map_loaded then
        return true
    end
    return false
end

-- 创建玩家
function SceneElementsModel:CreateRole(uniqueroleid, role, tposecallback)
    if self.RoleView_List[uniqueroleid] == nil then
        -- if self.createCount_Max > self.createCount -- 同时创建单位数量限制
        -- print(string.format("尝试创建玩家 %s %s", uniqueroleid, role.action))
        if (self.createCount_Max > self.createCount -- 同时创建单位数量限制
            and ( role.action ~= 5 or uniqueroleid == self.self_unique ) -- status == 1时, 是死亡状态不创建玩家
            and ( (not self.LimitRoleNum) or (self.LimitRoleNum and self.ShowRoleNum > self.NowRoleNum) ) -- 限制玩家单位数量
            and (role.exclude_outofview or SceneManager.Instance.MainCamera:InView_big(role.x, role.y)) -- 视野限制
            and (uniqueroleid ~= self.self_unique and self.Show_OtherRole_Mark)
            or role.is_virtual
            or (uniqueroleid == self.self_unique and self.Show_Self_Mark) or role.no_hide
            or TeamManager.Instance:IsInMyTeam(uniqueroleid)
            ) and SceneManager.Instance.sceneModel.map_loaded

            then
            -- 开始创建
            -- print(string.format("创建玩家 %s %s %s", uniqueroleid, role.x, role.y))
            -- print(string.format("time %s, createCount %s", Time.time, self.createCount))
            if tposecallback ~= nil then role.tposecallback = tposecallback end
            local rv = RoleView.New(role)
            self.RoleView_List[uniqueroleid] = rv
            self.WaitForCreateUnitData_List[uniqueroleid] = nil
            rv:Create()

            self.NowRoleNum = self.NowRoleNum + 1

            -- if tposecallback ~= nil then
            --     rc:add_tpose_complete_callback(tposecallback)
            -- end

            if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
                self:setfollow()
            end

            -- if role.goto_x ~= nil and role.goto_y ~= nil then
            --     mod_scene_elements_manager.role_move(uniqueroleid, role.goto_x, mod_scene_manager.get_py(role.goto_y), role.movetoend_callback)
            --     role.goto_x = nil
            --     role.goto_y = nil
            -- end

            -- mod_scene_elements_manager.cancreatedestory = false
            -- if role.exclude_outofview ~= true then -- 不受视野控制单位不加入计数
            --     mod_scene_elements_manager.role_num = mod_scene_elements_manager.role_num + 1
            -- end
            return true
        else
            if tposecallback ~= nil then role.tposecallback = tposecallback end
            self.WaitForCreateUnitData_List[uniqueroleid] = role
            return false
        end
    else
        print(string.format("玩家已存在 %s", uniqueroleid))
        self.WaitForCreateUnitData_List[uniqueroleid] = nil
        return false
    end
end

-- 创建Npc
function SceneElementsModel:CreateNpc(uniquenpcid, npc, tposecallback)
    --print(debug.traceback())
    if self.NpcView_List[uniquenpcid] == nil and npc ~= nil then
        -- if uniquenpcid == "24_1" then
        --     local mainCamera = SceneManager.Instance.MainCamera
        --     print(string.format("ViewWidth %s, ViewHeight %s", mainCamera.ViewWidth, mainCamera.ViewHeight))
        --     print(string.format("x %s, y %s", mainCamera.x, mainCamera.y))
        --     local p = SceneManager.Instance.sceneModel:transport_small_pos(npc.x, npc.y)
        --     print(string.format("npc %s, npc %s", p.x, p.y))

        --     print(string.format("mainCamera %s, mainCamera %s", math.abs(mainCamera.x - p.x), math.abs(mainCamera.y - p.y)))

        --     print(string.format("CameraOffsetX %s, CameraOffsetY %s", SceneManager.Instance.MainCamera.CameraOffsetX, SceneManager.Instance.MainCamera.CameraOffsetY))

        --     print(SceneManager.Instance.Mapsizeconvertvalue)
        --     print(SceneManager.Instance.MainCamera:InView_big(npc.x, npc.y))
        -- end
        --特殊npc不隐藏处理
        if (npc.battleid == 35 and npc.id <= 5) or (SceneManager.Instance:CurrentMapId() == 52001 and npc.id <= 9) then
            npc.no_hide = true
            npc.exclude_outofview = true
            npc.no_facetopoint = true
        end
        if self.createCount_Max > self.createCount -- 同时创建单位数量限制
            and (npc.is_virtual or npc.exclude_outofview or SceneManager.Instance.MainCamera:InView_big(npc.x, npc.y)) -- 视野限制
            and (self.Show_Npc_Mark or npc.no_hide)
            and SceneManager.Instance.sceneModel.map_loaded
            or npc.battleid == 5 -- 吃货游行NPC不限制
            -- or npc.battleid == 35 -- 中秋NPC不限制
            then
            -- 开始创建
            if tposecallback ~= nil then npc.tposecallback = tposecallback end
            local nv = NpcView.New(npc)
            self.NpcView_List[uniquenpcid] = nv
            self.WaitForCreateUnitData_List[uniquenpcid] = nil
            nv:Create()

            -- 创建的npc是寻路目标，寻路至该npc
            if uniquenpcid == self.target_uniqueid or ( self.autopath_data ~= nil and uniquenpcid == self.autopath_data.targetid ) then
                print("Self_MoveToTarget 564654564")
                self:Self_MoveToTarget(uniquenpcid)
            end

            -- if npc.goto_x ~= nil and npc.goto_y ~= nil then
            --     mod_scene_elements_manager.unit_move(uniquenpcid, npc.goto_x, mod_scene_manager.get_py(npc.goto_y), npc.movetoend_callback)
            --     npc.goto_x = nil
            --     npc.goto_y = nil
            -- end

            -- --处理头上的任务状态标志
            -- local state = mod_task.npcStateTab[uniquenpcid]
            -- if state ~= nil then
            --     mod_scene_elements_manager.show_task_state(npc.id, npc.battleid, state)
            -- end

            -- mod_scene_elements_manager.cancreatedestory = false
            return true
        else
            if tposecallback ~= nil then npc.tposecallback = tposecallback end
            self.WaitForCreateUnitData_List[uniquenpcid] = npc
            return false
        end
    else
        if self.NpcView_List[uniquenpcid] == nil then
            print(string.format("NPC已存在 %s", uniquenpcid))
            self.WaitForCreateUnitData_List[uniquenpcid] = nil
            return false
        end
        return false
    end
end

-- 删除场景上所有单位
function SceneElementsModel:CleanElements()
    for k,v in pairs(self.RoleView_List) do
        if k ~= self.self_unique then
            self:RemoveRole(k)
        end
    end
    for k,v in pairs(self.NpcView_List) do
        if k ~= self.self_pet_unique and k ~= self.follow_npc_unique then
            self:RemoveNpc(k)
        end
    end
    self.WaitForCreateUnitData_List = {}
    self.passengerVirtualData = {}

    self:RemoveAllVirtual_Unit() -- 清空所有虚拟单位

    self.NowRoleNum = 0
end

-- 删除玩家
function SceneElementsModel:RemoveRole(uniqueroleid)
    local rv = self.RoleView_List[uniqueroleid]
    if rv ~= nil then -- 已创建的玩家
        -- print(string.format("删除的角色名字 %s ", rv.data.name))
        rv:DeleteMe()
        self.RoleView_List[uniqueroleid] = nil
        self.WaitForCreateUnitData_List[uniqueroleid] = nil
        self.passengerVirtualData[uniqueroleid] = nil
        if TeamManager.Instance:IsInMyTeam(uniqueroleid) then
            self:setfollow()
        end

        self.NowRoleNum = self.NowRoleNum - 1
    else -- 未创建的玩家
        self.WaitForCreateUnitData_List[uniqueroleid] = nil
    end
end

-- 删除Npc
function SceneElementsModel:RemoveNpc(uniquenpcid)
    local nv = self.NpcView_List[uniquenpcid]
    if nv ~= nil then -- 已创建的Npc
        nv:DeleteMe()
        self.NpcView_List[uniquenpcid] = nil
        self.WaitForCreateUnitData_List[uniquenpcid] = nil
    else -- 未创建的Npc
        self.WaitForCreateUnitData_List[uniquenpcid] = nil
    end
end

function SceneElementsModel:UpdateRoleStatus(data)
    local platform = data.platform
    local rid = data.rid
    local zone_id = data.zone_id
    local uniqueroleid = BaseUtils.get_unique_roleid(rid, zone_id, platform)
    local role
    local rv
    role = self.WaitForCreateUnitData_List[uniqueroleid]
    if role == nil then
        rv = self.RoleView_List[uniqueroleid]
        if rv ~= nil then
            role = rv.data
        end
    end
    -- print("UpdateRoleStatus")
    if role ~= nil then
        local status_Mark = false
        local old_status = role.status
        local event_Mark = false
        local old_event = role.event
        if role.status ~= data.status then status_Mark = true end
        if role.event ~= data.event then event_Mark = true end
        role:update_data(data)
        -- print(string.format("UpdateRoleStatus %s", data.status))
        if BaseUtils.get_self_id() == uniqueroleid then
            local roleData = RoleManager.Instance.RoleData
            roleData.status = role.status
            roleData.event = role.event
        end

        if status_Mark then
            if rv ~= nil then
                rv:change_status_effect()
            end
            if BaseUtils.get_self_id() == uniqueroleid then
                EventMgr.Instance:Fire(event_name.role_status_change, role.status, old_status)
            end
        end
        if event_Mark then
            if BaseUtils.get_self_id() == uniqueroleid then
                EventMgr.Instance:Fire(event_name.role_event_change, role.event, old_event)
            end
        end
    end
end

function SceneElementsModel:GetRoleDir()
    if SceneManager.Instance:CurrentMapId() == 30002 then
        SceneManager.Instance:Send10169()
    end
end

function SceneElementsModel:UpdateRoleDir(data)
    local platform = data.platform
    local rid = data.rid
    local zone_id = data.zone_id
    local uniqueroleid = BaseUtils.get_unique_roleid(rid, zone_id, platform)
    local role
    local rv
    role = self.WaitForCreateUnitData_List[uniqueroleid]
    if role == nil then
        rv = self.RoleView_List[uniqueroleid]
        if rv ~= nil then
            role = rv.data
        end
    end
    if role ~= nil and role.event ~= 4 then
        role.targetPosition = nil
        role.dir = data.dir
        local rv = self.RoleView_List[uniqueroleid]
        if rv ~= nil and SceneConstData.UnitFaceToIndex[data.dir+1] ~= nil then
            rv:FaceTo_Now(SceneConstData.UnitFaceToIndex[data.dir+1])
        end
    end
end

function SceneElementsModel:OnRoleTransport(data)
    local uniqueroleid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)
    -- Log.Debug(string.format("on10118 收到角色传送事件 %s", uniqueroleid))

    local model = data.mode
    local speed = data.speed
    local dir = data.dir
    local sx = data.x
    local sy = data.y
    local gx = data.gx
    local gy = data.gy
    local dest = {}
    for k, v in pairs(data.dest) do
        table.insert(dest, { dx = v.dx, dy = v.dy } )
    end

    -- BaseUtils.dump(data)
    if #dest > 0 then
        local rv = self.RoleView_List[uniqueroleid]
        if rv ~= nil then
            rv.data.gx = gx
            rv.data.gy = gy
            if model == SceneConstData.translatestyle_now then
                -- print("111")
                -- print(string.format("%s, %s", dest[#dest].dx, dest[#dest].dy))

                -- BaseUtils.dump(SceneManager.Instance.sceneModel:transport_small_pos(dest[#dest].dx, dest[#dest].dy))

                rv:JumpTo_by_big_pos(dest[#dest].dx, dest[#dest].dy)
                rv.data.x = dest[#dest].dx
                rv.data.y = dest[#dest].dy
                if uniqueroleid == self.self_unique then
                    EventMgr.Instance:Fire(event_name.current_trasport_succ)
                end
            elseif model == SceneConstData.translatestyle_jump then
                rv:StopMoveTo()
                local roleJump = SceneJump.New()
                roleJump.callback = function()
                    roleJump:DeleteMe()
                end

                local targetPoint = rv:GetCachedTransform().localPosition
                targetPoint = SceneManager.Instance.sceneModel:transport_big_pos(targetPoint.x, targetPoint.y)
                local jumpToPoint = { x = dest[#dest].dx, y = dest[#dest].dy }
                roleJump:Show({ val = { targetPoint, jumpToPoint } })
            end
        else
            -- print("222")
            local role = self.WaitForCreateUnitData_List[uniqueroleid]
            if role then
                -- print("2223333")
                role.gx = gx
                role.gy = gy
                role.x = dest[#dest].dx
                role.y = dest[#dest].dy
            end
        end
    end
end

function SceneElementsModel:SendMove()
    if self.SendMoveCount % 60 == 0 and self.self_view ~= nil and not BaseUtils.is_null(self.self_view.gameObject) then
        self.SendMoveCount = 1
        local p = self.self_view:GetCachedTransform().position

        -- local sendPosition = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
        -- print("SendMove")
        -- print(sendPosition.x)
        -- print(sendPosition.y)
        -- 如果在典礼仪式中则不发移动包
        if RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_cere or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest_cere or ParadeManager.Instance.selfstatus == 1 then

        else -- 其他状态则发移动包
            if p.x ~= self.LastSendPosition_X or p.y ~= self.LastSendPosition_Y then
                local sceneModel = SceneManager.Instance.sceneModel
                local teamManager = TeamManager.Instance
                local dir = math.floor((self.self_view.orienation+360+22.5) / 45) % 8
                if teamManager:HasTeam() and teamManager:MyStatus() == RoleEumn.TeamStatus.Leader then
                    -- print("<color='#ffff00'>我走</color>")
                    local members = {}
                    if teamManager.memberTab then
                        for k,v in pairs(teamManager.memberTab) do
                            local unique_roleid = v.uniqueid
                            local role_view = self.RoleView_List[unique_roleid]
                            if role_view ~= nil then
                                local role_data = role_view.data
                                local role_position = role_view:GetCachedTransform().position
                                local sendPosition = sceneModel:transport_big_pos(role_position.x, role_position.y)
                                table.insert(members, {
                                    rid = role_data.roleid,
                                    platform = role_data.platform,
                                    zone_id = role_data.zoneid,
                                    x = sendPosition.x,
                                    y = sendPosition.y,
                                    dir = dir
                                    })
                                
                                if role_data.passengers ~= nil then
                                    for i, v in ipairs(role_data.passengers) do
                                        table.insert(members, {
                                            rid = tonumber(v.rid),
                                            platform = v.platform,
                                            zone_id = tonumber(v.zone_id),
                                            x = sendPosition.x,
                                            y = sendPosition.y,
                                            dir = dir
                                            })
                                    end
                                end
                            end
                        end
                    end
                    SceneManager.Instance:Send10167(self.mapid, members)
                    self.LastSendPosition_X = p.x
                    self.LastSendPosition_Y = p.y
                elseif teamManager:MyStatus() ~= RoleEumn.TeamStatus.Follow and not self.self_view.noSendMove then
                    local sendPosition = sceneModel:transport_big_pos(p.x, p.y)
                    SceneManager.Instance:Send10115(self.mapid, sendPosition.x, sendPosition.y, dir)
                    self.LastSendPosition_X = p.x
                    self.LastSendPosition_Y = p.y
                end
            end
        end
    else
        self.SendMoveCount = self.SendMoveCount + 1
    end
end

function SceneElementsModel:RoleMove(data)
    local uniqueroleid = BaseUtils.get_unique_roleid(data.rid, data.zone_id, data.platform)

    local rv = self.RoleView_List[uniqueroleid]
    if rv ~= nil then
        rv.data.gx = data.gx
        rv.data.gy = data.gy

        rv.data.x = data.x
        rv.data.y = data.y
    else
        local role = self.WaitForCreateUnitData_List[uniqueroleid]
        if role ~= nil then
            role.gx = data.gx
            role.gy = data.gy
        end
        local passenger = self.passengerVirtualData[uniqueroleid]
        if passenger ~= nil then
            passenger.gx = data.gx
            passenger.gy = data.gy

            passenger.x = data.x
            passenger.y = data.y

            passenger.dir = data.dir
        end
    end

    -- 如果是自己则计算九宫格
    if uniqueroleid == self.self_unique then
        self:Check9Gird()
    end

    local teamManager = TeamManager.Instance
    if teamManager:IsInMyTeam(uniqueroleid) and teamManager.captinId ~= uniqueroleid and teamManager:SomeOneStatus(uniqueroleid) == RoleEumn.TeamStatus.Follow then
        return
    end

    -- 如果是自己则不移动
    if uniqueroleid ~= self.self_unique then
        local rv = self.RoleView_List[uniqueroleid]
        if rv ~= nil then
            local jumpMarkNewExam = NewExamManager.Instance:CheckInOtherZone(rv, data.dx, data.dy)
            local jumpMarkGuildDragon = GuildDragonManager.Instance:CheckInOtherZone(rv, data.dx, data.dy)
            if not jumpMarkNewExam and not jumpMarkGuildDragon then
                local p = SceneManager.Instance.sceneModel:transport_small_pos(data.dx, data.dy)
                rv:MoveTo_NoPaths(p.x, p.y)
            end
        else
            local role = self.WaitForCreateUnitData_List[uniqueroleid]
            if role ~= nil then
                -- role:update_data(data)
                role.targetPosition = Vector2(data.dx, data.dy)
            end
        end
    end

    -- 如果是自己且在典礼仪式中则移动
    if uniqueroleid == self.self_unique and (RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_cere or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest_cere) then
        local rv = self.RoleView_List[uniqueroleid]
        if rv ~= nil then
            local p = SceneManager.Instance.sceneModel:transport_small_pos(data.dx, data.dy)
            rv:MoveTo_NoPaths(p.x, p.y)
        else
            local role = self.WaitForCreateUnitData_List[uniqueroleid]
            if role ~= nil then
                -- role:update_data(data)
                role.targetPosition = Vector2(data.dx, data.dy)
            end
        end
    end
end

function SceneElementsModel:NpcMove(data)
    local data_list = {data}
    for k, v in pairs(data_list) do
        local id = v.id
        local battleid = v.battle_id
        local uniquenpcid = BaseUtils.get_unique_npcid(id, battleid)
        local npc
        npc = self.WaitForCreateUnitData_List[uniquenpcid]
        if npc == nil then
            local nv = self.NpcView_List[uniquenpcid]
            if nv ~= nil then
                npc = nv.data
            end
        end
        -- if npc == nil then npc = self.WaitForCreateUnitData_List[uniquenpcid] end
        -- print(string.format("%s npc", uniquenpcid))
        -- print(string.format("%s npc，坐标：%s ,%s", uniquenpcid, v.x, v.y))
        -- print(v.status)
        -- BaseUtils.dump(v, "<color=#FF0000>==========="..v.name.."</color>")

        v.x = v.dx
        v.y = v.dy
        if npc ~= nil then
            local update_scene_mark = false
            local update_looks_mark = false
            local update_name_mark = false
            local update_status_mark = false
            if v.x ~= nil and v.y ~= nil and (npc.x ~= v.x or npc.y ~= v.y) then update_scene_mark = true end
            if battleid ~= 5 then -- 非吃货游行npc才更新
                npc:update_data(v)
                npc.targetPosition = nil
                local nv = self.NpcView_List[uniquenpcid]
                    if nv ~= nil then
                    if update_scene_mark then
                        local path = { SceneManager.Instance.sceneModel:transport_small_pos(npc.x, SceneManager.Instance.sceneModel:get_py_big(npc.y)) }
                        nv.TargetPositionList = path
                        local pos = SceneManager.Instance.sceneModel:transport_small_pos(npc.x, npc.y)
                        nv:MoveTo_NoPaths(pos.x, pos.y)
                    end
                end
            end

        -- elseif not noCreate then
        --     npc = NpcData.New()
        --     npc:update_data(v)
        --     self.WaitForCreateUnitData_List[uniquenpcid] = npc

        --     self:CreateSceneUnit(uniquenpcid, npc)
        end
    end
    if SceneManager.Instance.sceneModel.map_loaded then
        self.npc_list_update_event_cache = false
        EventMgr.Instance:Fire(event_name.npc_list_update)
        -- Log.Debug(string.format("系统时间： %s", os.time()))
        self:AutoPath()
    else
        self.npc_list_update_event_cache = true
    end
end
--******************************--
--******************************--
------------ Mark 特殊方法 ------------
--******************************--
--******************************--

-- 创建虚拟单位
function SceneElementsModel:CreateVirtual_Unit(uniqueid, data, tposecallback)
    data.is_virtual = true
    self:CreateSceneUnit(uniqueid, data, tposecallback)

    self.VirtualUnitData_List[uniqueid] = data
end

-- 删除虚拟单位
function SceneElementsModel:RemoveVirtual_Unit(uniqueid)
    local rv = self.RoleView_List[uniqueid]
    if rv ~= nil then -- 已创建的玩家
        rv:DeleteMe()
        self.RoleView_List[uniqueid] = nil
        self.WaitForCreateUnitData_List[uniqueid] = nil
    else -- 未创建的玩家
        self.WaitForCreateUnitData_List[uniqueid] = nil
    end

    local nv = self.NpcView_List[uniqueid]
    if nv ~= nil then -- 已创建的Npc
        nv:DeleteMe()
        self.NpcView_List[uniqueid] = nil
        self.WaitForCreateUnitData_List[uniqueid] = nil
    else -- 未创建的Npc
        self.WaitForCreateUnitData_List[uniqueid] = nil
    end

    self.VirtualUnitData_List[uniqueid] = nil
end

function SceneElementsModel:RemoveAllVirtual_Unit()
    for k,v in pairs(self.VirtualUnitData_List) do
        self:RemoveVirtual_Unit(k)
    end
end

function SceneElementsModel:Follow()
    local folloewObject = SceneManager.Instance.MainCamera.folloewObject
    if BaseUtils.isnull(folloewObject) then return end

    local folloewTransform = SceneManager.Instance.MainCamera.folloewTransform
    if SceneManager.Instance.MainCamera.onlyFolloewView then return end
    local followIndex = 0
    for k,v in pairs(self.FollowUnit_List) do
        local followUnit = v
        if not BaseUtils.is_null(followUnit.gameObject) and folloewObject ~= followUnit.gameObject then
            local distance = BaseUtils.distance_bypoint(folloewTransform.localPosition, followUnit:GetCachedTransform().localPosition)
            if (distance > self.FollowDistance[1] + followIndex * self.FollowDistance[4]) then
                -- if self.self_view ~= followUnit then
                    local p = BaseUtils.distanceto_bypoint(followUnit:GetCachedTransform().localPosition
                    , folloewTransform.localPosition, self.FollowDistance[3] + followIndex * self.FollowDistance[4])
                    followUnit:JumpTo(p.x, p.y)
                -- end
            elseif (distance > self.FollowDistance[2] + followIndex * self.FollowDistance[4]) then
                local toPoint = BaseUtils.distanceto_bypoint(followUnit:GetCachedTransform().localPosition
                    , folloewTransform.localPosition, self.FollowDistance[3] + followIndex * self.FollowDistance[4])
                followUnit:MoveTo_NoPaths(toPoint.x, toPoint.y)
                followUnit.TargetOrienation = nil
            elseif ((self.self_view ~= nil and #self.self_view.TargetPositionList == 0 or self.self_view == nil) and distance <= self.FollowDistance[2] + followIndex * self.FollowDistance[4]) then
                if #followUnit.TargetPositionList > 0 or followUnit:Get_IsMovingAction() then
                    followUnit:StopMoveTo()
                end
            end
            -- print(string.format("%s %s", folloewObject.transform.localPosition.x, folloewObject.transform.localPosition.y))
            followUnit:FaceToPoint(folloewTransform.localPosition)

            followIndex = followIndex + 1
        end
    end
end

function SceneElementsModel:setfollow()
    -- print("setfollow")
    -- print(debug.traceback())
    if TeamManager.Instance:HasTeam() then
        self:petfollow()
        self:followNpcfollow()
        self:teamfollow()
    else
        self:teamfollow()
        self:petfollow()
        self:followNpcfollow()
    end

    self:Show_OtherRole_Ride(self.Show_OtherRole_Ride_Mark)
end

function SceneElementsModel:teamfollow()
    if RoleManager.Instance.RoleData.event == RoleEumn.Event.Parade then return end
    -- print("teamfollow")
    

    self.FollowUnit_List = {}
    local teamManager = TeamManager.Instance
    if teamManager:HasTeam() and (teamManager:MyStatus() == RoleEumn.TeamStatus.Leader or teamManager:MyStatus() == RoleEumn.TeamStatus.Follow)
        and self.RoleView_List[teamManager.captinId] ~= nil then
        -- print(string.format("队长 %s %s", teamManager.captinId, self.self_unique))
        if teamManager.captinId == self.self_unique then
            self:Set_isovercontroll(true)
            
            if self.self_view ~= nil and self.self_view.gameObject ~= nil then 
                SceneManager.Instance.MainCamera:SetFolloewObject(self.self_view.gameObject)
            end

            -- 队伍的跟随设置
            self.FollowDistance = {1.5, 0.4, 0.3, 0.4}

            -- print("我是队长")
        else
            self:Set_isovercontroll(false)
            SceneManager.Instance.MainCamera:SetFolloewObject(self.RoleView_List[teamManager.captinId].gameObject)
            -- 队伍的跟随设置
            self.FollowDistance = {1.5, 0.4, 0.3, 0.4}

            -- print("我是队员")
        end
        for k,v in pairs(teamManager.memberTab) do
            -- print(string.format("status %s", RoleEumn.TeamStatus.Follow))
            if v.status == RoleEumn.TeamStatus.Follow then
                local unique_roleid = v.uniqueid
                local role_view = self.RoleView_List[unique_roleid]
                -- print(string.format("role_view %s", role_view))
                if role_view ~= nil then
                    table.insert(self.FollowUnit_List, role_view)
                end
            end
        end
        -- print(string.format("队伍成员 %s", #self.FollowUnit_List))
    else
        if ParadeManager.Instance.selfstatus == 1 then --判断是不是在吃货状态
            self:Set_isovercontroll(false)
        else
            self:Set_isovercontroll(true)
        end

        if self.self_view ~= nil and self.self_view.gameObject ~= nil then 
            SceneManager.Instance.MainCamera:SetFolloewObject(self.self_view.gameObject)

            if ctx.sceneManager.Map:Walkable(self.self_view:GetCachedTransform().position.x
                , self.self_view:GetCachedTransform().position.y) == false then
                if self.self_view.data.ride == SceneConstData.unitstate_walk then
                    self.self_view:MoveToRoadPoint()
                end
            end
        end
    end
end

function SceneElementsModel:petfollow()
    if self.self_view == nil or self.self_view.gameObject == nil then return end
    -- print("petfollow")

    if self.FollowData == nil -- 没有设置npc跟随
        and PetManager.Instance:Get_BattlePet() ~= nil
        and not TeamManager.Instance:HasTeam()
        and (self.self_view.data.ride == SceneConstData.unitstate_walk or self.self_view.data.ride == SceneConstData.unitstate_ride) then
        local pet_data_x = nil
        local pet_data_y = nil
        if self.self_pet_view ~= nil and not BaseUtils.is_null(self.self_pet_view.gameObject) then
            local p = SceneManager.Instance.sceneModel:transport_big_pos(self.self_pet_view:GetCachedTransform().position.x, self.self_pet_view:GetCachedTransform().position.y)
            pet_data_x = p.x
            pet_data_y = p.y
        end
        self:remove_pet()
        self.self_pet_unique = BaseUtils.get_unique_npcid(PetManager.Instance:Get_BattlePet().id, 999)
        self:creat_pet(pet_data_x, pet_data_y)
    elseif self.self_pet_view ~= nil or self.WaitForCreateUnitData_List[self.self_pet_unique] ~= nil then
        self:remove_pet()
        self.self_pet_view = nil
        self.self_pet_unique = ""
        self.FollowUnit_List = {}
    end
end

function SceneElementsModel:remove_pet()
    -- print("remove_pet")
    if self.WaitForCreateUnitData_List[self.self_pet_unique] ~= nil then
        self.WaitForCreateUnitData_List[self.self_pet_unique] = nil
    end

    local nv = self.NpcView_List[self.self_pet_unique]
    if nv ~= nil then
        nv:DeleteMe()
        self.NpcView_List[self.self_pet_unique] = nil
        self.WaitForCreateUnitData_List[self.self_pet_unique] = nil
    end

    self.self_pet_view = nil
    self.self_pet_unique = ""
end

function SceneElementsModel:creat_pet(pet_data_x, pet_data_y)
    -- print("creat_pet")
    local pet_data = BaseUtils.copytab(PetManager.Instance:Get_BattlePet())

    pet_data.uniqueid = self.self_pet_unique
    pet_data.battle_id = 999
    pet_data.baseid = pet_data.base.id
    pet_data.unittype = SceneConstData.unittype_pet
    pet_data.speed = RoleManager.Instance.RoleData.speed
    pet_data.dir = 270
    pet_data.canIdle = true
    pet_data.exclude_outofview = true

    if pet_data_x == nil or pet_data_y == nil then
        local p = SceneManager.Instance.sceneModel:transport_big_pos(self.self_view:GetCachedTransform().position.x - 0.6, self.self_view:GetCachedTransform().position.y)
        pet_data.x = p.x
        pet_data.y = p.y
    else
        pet_data.x = pet_data_x
        pet_data.y = pet_data_y
    end

    self:CreateNpc(self.self_pet_unique, pet_data, nil)

    self.FollowDistance = {3, 0.8, 0.6, 0.6}
end

function SceneElementsModel:battlepet_update(change_list)
    if change_list == nil
        or table.containValue(change_list, "id")
        or table.containValue(change_list, "name")
        or table.containValue(change_list, "base_id")
        or table.containValue(change_list, "genre")
        or table.containValue(change_list, "grade")
        or table.containValue(change_list, "use_skin")
        or table.containValue(change_list, "unreal") then
        self:setfollow()
    end
end

function SceneElementsModel:setFollowNpcData(data)
    if self.FollowData == nil then
        if data ~= nil then
            self.FollowData = data
            self:setfollow()
        end
    else
        if data ~= nil then
            self.FollowData = data
            local follow_data_x = nil
            local follow_data_y = nil
            if self.follow_npc_view ~= nil then
                if not BaseUtils.is_null(self.follow_npc_view.gameObject) then
                    local p = SceneManager.Instance.sceneModel:transport_big_pos(self.follow_npc_view:GetCachedTransform().position.x, self.follow_npc_view:GetCachedTransform().position.y)
                    follow_data_x = p.x
                    follow_data_y = p.y
                end
                self:remove_followNpc()
                self.follow_npc_unique = BaseUtils.get_unique_npcid(self.FollowData.id, 999)
                self:creat_followNpc(follow_data_x, follow_data_y)
            end
        else
            self.FollowData = data
            self:setfollow()
        end
    end
end

function SceneElementsModel:followNpcfollow()
    if self.self_view == nil or self.self_view.gameObject == nil then return end
    -- print("followNpcfollow")

    if self.FollowData ~= nil -- 有跟随npc数据
        and not TeamManager.Instance:HasTeam()
        and (self.self_view.data.ride == SceneConstData.unitstate_walk or self.self_view.data.ride == SceneConstData.unitstate_ride) then
        local follow_data_x = nil
        local follow_data_y = nil
        if self.follow_npc_view ~= nil and not BaseUtils.is_null(self.follow_npc_view.gameObject) then
            local p = SceneManager.Instance.sceneModel:transport_big_pos(self.follow_npc_view:GetCachedTransform().position.x, self.follow_npc_view:GetCachedTransform().position.y)
            follow_data_x = p.x
            follow_data_y = p.y
        end
            self:remove_followNpc()
            self.follow_npc_unique = BaseUtils.get_unique_npcid(self.FollowData.id, 999)
            self:creat_followNpc(follow_data_x, follow_data_y)
    elseif self.follow_npc_view ~= nil or self.WaitForCreateUnitData_List[self.follow_npc_unique] ~= nil then
        self:remove_followNpc()
        self.follow_npc_view = nil
        self.follow_npc_unique = ""
        self.FollowUnit_List = {}
    end
end

function SceneElementsModel:remove_followNpc()
    if self.WaitForCreateUnitData_List[self.follow_npc_unique] ~= nil then
        self.WaitForCreateUnitData_List[self.follow_npc_unique] = nil
    end

    local nv = self.NpcView_List[self.follow_npc_unique]
    if nv ~= nil then
        nv:DeleteMe()
        self.NpcView_List[self.follow_npc_unique] = nil
        self.WaitForCreateUnitData_List[self.follow_npc_unique] = nil
    end

    self.follow_npc_view = nil
    self.follow_npc_unique = ""
end

function SceneElementsModel:creat_followNpc(followUnit_x, followUnit_y)
    -- print("creat_followNpc")
    local follow_data = BaseUtils.copytab(self.FollowData)

    follow_data.uniqueid = self.follow_npc_unique
    follow_data.battle_id = 999
    follow_data.unittype = SceneConstData.unittype_npc
    follow_data.speed = RoleManager.Instance.RoleData.speed
    follow_data.dir = 270
    follow_data.canIdle = true
    follow_data.exclude_outofview = true

    if followUnit_x == nil or followUnit_y == nil then
        local p = SceneManager.Instance.sceneModel:transport_big_pos(self.self_view:GetCachedTransform().position.x - 0.6, self.self_view:GetCachedTransform().position.y)
        follow_data.x = p.x
        follow_data.y = p.y
    else
        follow_data.x = followUnit_x
        follow_data.y = followUnit_y
    end

    self:CreateNpc(self.follow_npc_unique, follow_data, function(npc_view) self:creat_followNpc_callback(npc_view) end)

    self.FollowDistance = {3, 0.8, 0.6, 0.6}
end

function SceneElementsModel:creat_followNpc_callback(npc_view)
    if npc_view ~= nil and not BaseUtils.is_null(npc_view.gameObject) then
        self.follow_npc_view = npc_view
        self.FollowUnit_List = {npc_view}
        -- npc_view.gameObject:SetActive(self.Show_Self_Pet_Mark)
    end
end

-- 检查队伍，如果自己正在跟随且队长未创建, 则离队再归队
function SceneElementsModel:check_teamfollow()
    if self.self_view == nil or self.self_view.gameObject == nil or ParadeManager.Instance.selfstatus == 1 then return end

    local teamManager = TeamManager.Instance
    if teamManager:HasTeam() and (teamManager:MyStatus() == RoleEumn.TeamStatus.Follow) and not CombatManager.Instance.isFighting then
        if self.RoleView_List[teamManager.captinId] == nil then
            if self.miss_teamleader then
                self.miss_teamleader = false
                TeamManager.Instance:Send11739()
                LuaTimer.Add(1000, function() SceneManager.Instance:Send10122() end)
            else
                self.miss_teamleader = true
            end
        else
            self.miss_teamleader = false
        end
    end
end

--******************************--
--******************************--
------------ Mark 控制自己 ------------
--******************************--
--******************************--
function SceneElementsModel:Self_Transport_After_Clean(mapid, x, y)
    self:Self_CancelAutoPath()
    self:Self_Transport(mapid, x, y)
end

function SceneElementsModel:Self_Transport(mapid, x, y)
    if not self.isovercontroll then return end

    NoticeManager.Instance:HideGuildPublicity()
    -- 传送要取消当前采集
    EventMgr.Instance:Fire(event_name.cancel_colletion)

    if mapid == 30001 then
        Connection.Instance:send(11128, {})
    else
        SceneManager.Instance:Send10119(mapid, x, y)
    end
end

function SceneElementsModel:Self_Transport_small_pos(mapid, x, y)
    local p = SceneManager.Instance.sceneModel:transport_big_pos(x, y)
    self:Self_Transport(mapid, p.x, p.y)
end

-- 访问单位(不管单位是否创建)
function SceneElementsModel:Self_PathToTarget(uniqueid, direct)
    if not self.isovercontroll then return end
    local path = DataWorldNpc.data_world_npc[uniqueid]
    local mapid = SceneManager.Instance.sceneModel.sceneView.mapid
    --print(debug.traceback())
    --BaseUtils.dump(uniqueid, "1212121ba211")
    if path ~= nil then
        if mapid == path.mapbaseid then
            if direct then
                -- self:Self_AutoPath(path.mapbaseid, uniqueid, path.posx, path.posy)
                -- self:Self_Transport(path.mapbaseid, path.posx, path.posy)
            else
                self:Self_MoveToTarget(uniqueid)
            end
        else
            if direct then
                self:Self_AutoPath(path.mapbaseid, uniqueid, path.posx, path.posy)
            else
                self:Self_AutoPath(path.mapbaseid, uniqueid, nil, nil, true)
            end
        end
    end
end

-- 自动寻路(默认有路径的寻路)
-- target_mapid 目标地图
-- targetid 目标id (targetid 与 x, y传入其中一组即可)
-- x, y 目标坐标(小坐标) (targetid 与 x, y传入其中一组即可)
-- direct 直接传送到目标地图，然后再寻路
function SceneElementsModel:Self_AutoPath(target_mapid, targetid, x, y, direct, moveend_callback)
    if not self.isovercontroll then return end
    self.autopath_data = { target_mapid = target_mapid, targetid = targetid, x = x , y = y, direct = direct, moveend_callback = moveend_callback}
    --print(debug.traceback())
    --BaseUtils.dump(self.autopath_data, "asdasdasdasd")
    AutoFarmManager.Instance:stopFarm()
    AutoFarmManager.Instance:StopAncientDemons()
    HomeManager.Instance:CancelFindTree()

    self:AutoPath()
end

function SceneElementsModel:Self_CancelAutoPath()
    self.autopath_data = nil
    self.target_uniqueid = nil
end

function SceneElementsModel:Self_CancelAutoPath_AndTopEffect()
    self:Self_CancelAutoPath()
    self:Self_Change_Top_Effect(2)
    self:Self_Change_Top_Effect(4)
    self:Self_Change_Top_Effect(6)
end

-- 场景加载完成
function SceneElementsModel:OnSceneLoad()
    if self.npc_list_update_event_cache then
        self.npc_list_update_event_cache = false
        EventMgr.Instance:Fire(event_name.npc_list_update)
        self:AutoPath()
    else
        self.npc_list_update_event_cache = false
    end
end

-- 根据自动寻路数据，继续寻路
function SceneElementsModel:AutoPath()
    if SceneManager.Instance.MainCamera.sceneTexture_tweenId then
        if self.autoPathTimerId == nil then
            self.autoPathTimerId = LuaTimer.Add(200, function() self.autoPathTimerId = nil self:AutoPath() end)
        end
        return
    end

    if self.autopath_data ~= nil then
        local mapid = SceneManager.Instance.sceneModel.sceneView.mapid
        if self.autopath_data.target_mapid == mapid then
            if self.autopath_data.x ~= nil and self.autopath_data.y ~= nil then
                local p = SceneManager.Instance.sceneModel:transport_small_pos(self.autopath_data.x, self.autopath_data.y)
                if self.self_view ~= nil then
                    self.self_view.moveEnd_CallBack = function()
                        if self.autopath_data ~= nil then
                            local callback = self.autopath_data.moveend_callback
                            self.autopath_data.moveend_callback = nil
                            if callback ~= nil then
                                callback()
                            end
                        end
                    end
                end
                self:Self_MoveToPoint(p.x, p.y)
            elseif self.autopath_data.targetid ~= nil then
                self:Self_MoveToTarget(self.autopath_data.targetid)
            else
                self.autopath_data = nil
            end
        elseif self.autopath_data.target_mapid ~= nil then
            if self.autopath_data.direct then -- 直接传送到目标地图
                self:Self_Transport(self.autopath_data.target_mapid, 0, 0)
            else
                local path = self.scenePathModel:get_path(mapid, self.autopath_data.target_mapid)
                if path ~= nil and #path > 0 then
                    local teleporterid = path[1]
                    self:Self_MoveToTarget(string.format("%s_1", teleporterid))
                end
            end
        end
    elseif self.target_uniqueid ~= nil then
        self:Self_MoveToTarget(self.target_uniqueid)
    end
end

-- 访问单位
function SceneElementsModel:Self_MoveToTarget(uniqueid)
    if self.self_view == nil then return end
    if not self.isovercontroll then return end
    -- print(debug.traceback())
    -- print("Self_MoveToTarget")
    local npcView = self.NpcView_List[uniqueid]
    if npcView ~= nil then -- 移动到场景单位的处理
        self.target_uniqueid = nil
        if self.touchNpcView ~= nil and self.touchNpcView.data ~= nil and self.touchNpcView ~= self.self_pet_view then
            if not self.touchNpcView.data.no_facetopoint then
                local dir = self.touchNpcView.data.dir
                if dir == nil then
                    dir = SceneConstData.UnitFaceToIndex[self.touchNpcView.baseData.forward+1]
                end
                self.touchNpcView:FaceTo(dir)
            end
        end
        self.CurrentClickObject = npcView.gameObject
        ctx.sceneManager.CurrentClickObject = npcView.gameObject

        self:Set_Selected_Effect(npcView.gameObject.transform, true)
        self.Selected_Effect_Parent = npcView

        GuildManager.Instance.model:TposeSpecail(npcView, self.selected_effect.transform)

        if self.self_view.controller.TriggerUnit == npcView.gameObject then
            self:TouchSceneUnit(uniqueid)
        else
            local point = npcView:GetCachedTransform().position
            self:Self_MoveToPoint(point.x, point.y)
        end
    else
        local npc = self.WaitForCreateUnitData_List[uniqueid]
        self.target_uniqueid = uniqueid
        if npc ~= nil then
            local p = SceneManager.Instance.sceneModel:transport_small_pos(npc.x + 1, npc.y)
            self:Self_MoveToPoint(p.x, p.y)
        end
    end

    -- Mark 没有移动到玩家所在位置的需求，暂时屏蔽
    -- local touchRoleView = self.RoleView_List[uniqueid]
    -- if touchRoleView ~= nil then -- 移动到玩家单位的处理
    --     local point = touchNpcView:GetCachedTransform().position
    --     self:MoveToPoint(point.x, point.y)
    -- end
end

function SceneElementsModel:Self_MoveToPoint(x, y)
    if not self.isovercontroll then return end
    if self.self_view ~= nil then
        self.self_view:MoveTo(x, y)

        if self.LastTargetPointEffect == nil then
            self.LastTargetPointEffect = self.TargetPointEffect
        else
            if self.LastTargetPointEffect == self.TargetPointEffect then
                self.LastTargetPointEffect = self.TargetPointEffect2
            elseif self.LastTargetPointEffect == self.TargetPointEffect2 then
                self.LastTargetPointEffect = self.TargetPointEffect3
            else
                self.LastTargetPointEffect = self.TargetPointEffect
            end
        end

        if self.LastTargetPointEffect ~= nil then
            LuaTimer.Delete(self.timerTable[self.LastTargetPointEffect])
            self.LastTargetPointEffect:SetActive(false)
            self.LastTargetPointEffect:SetActive(true)
            self.LastTargetPointEffect.transform.position = Vector3(x, y, 48)
            local current = self.LastTargetPointEffect
            self.timerTable[self.LastTargetPointEffect] = LuaTimer.Add(1500, function () current:SetActive(false) end)
        end
    end
end

function SceneElementsModel:Self_HideTargetPointEffect()
    if self.LastTargetPointEffect ~= nil then
        self.LastTargetPointEffect:SetActive(false)
    end
end

function SceneElementsModel:Self_StopMove()
    if self.self_view ~= nil then
        self.self_view:StopMoveTo()
    end
end

function SceneElementsModel:Set_Selected_Effect(transform, show)
    if BaseUtils.is_null(self.selected_effect) then
        self.selected_effect = GameObject.Instantiate(self.instantiate_selected_effect)
        -- self.selected_effect.transform:SetParent(self.scene_elements.transform)
    end

    if show then
        self.selected_effect:SetActive(false)
        self.selected_effect:SetActive(true)
    else
        self.selected_effect:SetActive(false)
    end

    if transform == nil then
        self.selected_effect.transform:SetParent(self.scene_elements.transform)
        self.selected_effect.transform.localPosition = Vector3(-5, -5, 0)
        self.selected_effect.transform:SetAsFirstSibling()
        self.Selected_Effect_Parent = nil
    else
        self.selected_effect.transform:SetParent(transform)
        self.selected_effect.transform.localPosition = Vector3.zero
        self.selected_effect.transform:SetAsFirstSibling()
    end

    if self.selected_effect_special_mark then
        self.selected_effect.transform.localScale = Vector3.one
        self.selected_effect_special_mark = false
    end
end

function SceneElementsModel:Self_RideChange()
    if self.self_view ~= nil then
        if self.self_view.data.ride == SceneConstData.unitstate_walk then
            SceneManager.Instance:Send10010(1)
        elseif self.self_view.data.ride == SceneConstData.unitstate_fly then
            SceneManager.Instance:Send10010(2)
        elseif self.self_view.data.ride == SceneConstData.unitstate_ride then
            SceneManager.Instance:Send10010(1)
        end
    end
end

function SceneElementsModel:Self_Change_Top_Effect(top_effect_state)
    if self.self_view ~= nil then
        self.self_view:change_top_effect(top_effect_state)
    end
end

--******************************--
--******************************--
------------ Mark 各种隐藏 ------------
--******************************--
--******************************--
function SceneElementsModel:Show_Self(show)
    self.Show_Self_Mark = show
    if self.self_view ~= nil and not BaseUtils.is_null(self.self_view.gameObject) and not self.self_view.data.no_hide then
        self.self_view:SetActive(show)
    end
end

function SceneElementsModel:Show_Self_Weapon(show)
    self.Show_Self_Weapon_Mark = show
    if self.self_view ~= nil then
        if not BaseUtils.is_null(self.self_view.weapon) then
            self.self_view.weapon:SetActive(show)
        end
        if not BaseUtils.is_null(self.self_view.weapon2)  then
            self.self_view.weapon2:SetActive(show)
        end
    end
end

function SceneElementsModel:Show_Self_Pet(show)
    self.Show_Self_Pet_Mark = show
    if self.self_pet_view ~= nil and not BaseUtils.is_null(self.self_pet_view.gameObject) and not self.self_pet_view.data.no_hide then
        self.self_pet_view:SetActive(show)
    end
end

function SceneElementsModel:Show_OtherRole(show)
    self.Show_OtherRole_Mark = show
    for k,v in pairs(self.RoleView_List) do
        if not BaseUtils.is_null(v.gameObject) and not v.data.no_hide and v.data.uniqueid ~= self.self_unique then
            v:SetActive(show)
        end
    end
end

function SceneElementsModel:Show_Npc(show)
    self.Show_Npc_Mark = show
    for k,v in pairs(self.NpcView_List) do
        if not BaseUtils.is_null(v.gameObject) and not v.data.no_hide then
            v:SetActive(show)
        end
    end
end

function SceneElementsModel:Show_Role_Wing(show)
    self.Show_Role_Wing_Mark = show
    for k,v in pairs(self.RoleView_List) do
        if not BaseUtils.is_null(v.gameObject) and not BaseUtils.is_null(v.wing) then
            v.wing:SetActive(show)
        end
    end
end

function SceneElementsModel:Show_OtherRole_Ride(show)
    self.Show_OtherRole_Ride_Mark = show
    for k,v in pairs(self.RoleView_List) do
        if not BaseUtils.is_null(v.gameObject) and v.data.uniqueid ~= self.self_unique
            and (v.data.ride == SceneConstData.unitstate_ride or v.data.ride == SceneConstData.unitstate_fly) then
                v:ChangeLook()
        end
    end
end

function SceneElementsModel:Show_Transform(show)
    self.Show_Transform_Mark = show
    for k,v in pairs(self.RoleView_List) do
        if not BaseUtils.is_null(v.gameObject) and v.data.uniqueid ~= self.self_unique then
            v:ChangeLook()
        end
    end
end

function SceneElementsModel:ContinuousTouch()
    if self.isContinuousTouch then
        if self.touchCount > 0 then
            self.touchCount = self.touchCount - 1
        else
            if Application.platform == RuntimePlatform.WindowsPlayer or Application.platform == RuntimePlatform.WindowsEditor
                or Application.platform == RuntimePlatform.OSXEditor or Application.platform == RuntimePlatform.OSXPlayer then
                if Input.anyKey then
                    self.touchCount = self.touchCount_Max
                    local uiPos = Input.mousePosition
                    local position = uiPos
                    SceneManager.Instance.sceneModel.mapclicker:Click(position)
                    self.click_CoolDowm = math.floor(self.touchCount_Max / 2)
                else
                    self.isContinuousTouch = false
                end
            else
                if Input.touchCount == 1 then
                    self.touchCount = self.touchCount_Max
                    local uiPos = Input.GetTouch(0).position
                    local position = uiPos
                    SceneManager.Instance.sceneModel.mapclicker:Click(position)
                    self.click_CoolDowm = math.floor(self.touchCount_Max / 2)
                else
                    self.isContinuousTouch = false
                end
            end
        end
    end
    if self.click_CoolDowm > 0 then
        self.click_CoolDowm = self.click_CoolDowm - 1
    end
end

function SceneElementsModel:onMapPointerDown()
    self.isContinuousTouch = true -- 开启检测连续移动
    self.touchCount = math.floor(self.touchCount_Max / 4)
end

function SceneElementsModel:onMapPointerUp()
    self.isContinuousTouch = false -- 关闭检测连续移动
end

--******************************--
--******************************--
------------ Mark 操作反馈 ------------
--******************************--
--******************************--
function SceneElementsModel:MapClick(x, y)
    -- print(string.format("点击地图 x %s, y %s", x, y))
    if self.click_CoolDowm > 0 then
        return
    end

    if GuildDragonManager.Instance:IsActive() and not GuildDragonManager.Instance:IsLegal(self.self_view, x, y) then
        return
    end
    if IngotCrashManager.Instance:IsActive() and not IngotCrashManager.Instance:IsLegal(self.self_view, x, y) then
        return
    end
    if not self.isovercontroll then
        MainUIManager.Instance:HideSelectIcon()
        MainUIManager.Instance:HideClicknpcData()
        local teamManager = TeamManager.Instance
        if teamManager:HasTeam() and teamManager:MyStatus() == RoleEumn.TeamStatus.Follow then
            NoticeManager.Instance:FloatTipsByString(TI18N("正在跟随队长（可在队伍面板<color='#ffff00'>暂离或退出</color>队伍）"))
        elseif RoleManager.Instance.RoleData.event == RoleEumn.Event.ExquisiteShelf then
            NoticeManager.Instance:FloatTipsByString(TI18N("请等待守门人出现，才能继续移动"))
        end
        return
    end

    if self.self_view ~= nil then
        local isExamOtherZone = NewExamManager.Instance:IsOtherZone(self.self_view, x, y)
        if isExamOtherZone then
            return
        end
    end

    -- print(string.format("self.isovercontroll %s", self.isovercontroll))
    if self.touchNpcView ~= nil and self.touchNpcView.data ~= nil and self.touchNpcView ~= self.self_pet_view then
        if not self.touchNpcView.data.no_facetopoint then
            local dir = self.touchNpcView.data.dir
            if dir == nil then
                dir = SceneConstData.UnitFaceToIndex[self.touchNpcView.baseData.forward+1]
            end
            self.touchNpcView:FaceTo(dir)
        end
    end
    self.target_uniqueid = nil
    self.autopath_data = nil
    self.CurrentClickObject = nil
    ctx.sceneManager.CurrentClickObject = nil

    if self.Selected_Effect_Parent ~= nil then
        self:Set_Selected_Effect()
    end
    self:Self_MoveToPoint(x, y)
    MainUIManager.Instance:HideSelectIcon()
    MainUIManager.Instance:HideClicknpcData()
    EventMgr.Instance:Fire(event_name.map_click)
    self:Self_Change_Top_Effect(2)

    if AutoQuestManager.Instance.model.isOpen then
        print("点击地图导致自动停止")
        AutoQuestManager.Instance.disabledAutoQuest:Fire()
    end
end

function SceneElementsModel:ClickUnitObject(objectName)
    -- print(string.format("ClickUnitObject %s", objectName))
    local objectName_List = {}
    local ray = ctx.MainCamera:ScreenPointToRay(Input.mousePosition) --从摄像机发出到点击坐标的射线
    local raycastHits = Physics.RaycastAll(ray, Mathf.Infinity, (2 ^ LayerMask.NameToLayer("Model")))
    local hitObjects = BaseUtils.RaycastHitToGameObject(raycastHits)
    for i = #hitObjects, 1, -1 do
        local gameObj = hitObjects[i]
        if not BaseUtils.is_null(gameObj) then
            local nv = self.NpcView_List[gameObj.name]
            if nv ~= nil and nv.controller.DontSelect ~= true then --当射线碰撞目标是npc，传递点击给他
                table.insert(objectName_List, { npcuniqueid = nv.controller.name, name = nv.data.name })
            end
        end
    end

    if HalloweenManager.Instance.model:ClickNpc(objectName) then  -- 万圣节特殊处理
        return
    end

    if #objectName_List > 1 then
        MainUIManager.Instance:SetClicknpcData(objectName_List)
    else
        MainUIManager.Instance:HideClicknpcData()
        self:ClickUnitObject_DoAction(objectName)
    end
end

function SceneElementsModel:ClickUnitObject_DoAction(objectName)
    if not self.isovercontroll then
        local no_controll = true
        local touchNpcView = self.NpcView_List[objectName]
        if touchNpcView ~= nil then
            local data = touchNpcView.data
            local baseData = touchNpcView.baseData
            if data.unittype == SceneConstData.unittype_taskcollection or data.unittype == SceneConstData.unittype_collection or data.unittype == SceneConstData.unittype_pick or data.unittype == SceneConstData.unittype_taskcollection_effect then
                local base = baseData
                if base ~= nil and (base.fun_type == SceneConstData.fun_type_skill_prac_box or base.fun_type == fun_type_notname_treasure) then -- 如果功能类型为冒险保箱类型，则打开冒险保箱界面
                    no_controll = false
                end
            end
        end
        if no_controll then return end
    end

    local touchNpcView = self.NpcView_List[objectName]
    if touchNpcView ~= nil then -- 点击到场景单位的处理
        local data = touchNpcView.data
        local baseData = touchNpcView.baseData
        if data.no_click then return end

        if baseData.type == SceneConstData.unittype_pick and baseData.fun_type == SceneConstData.fun_type_fairyland_box then
            self:Self_MoveToTarget(objectName)
        elseif baseData.fun_type == SceneConstData.fun_type_ship_box and baseData.type == SceneConstData.unittype_npc then
            local confirmData = NoticeConfirmData.New()
                        confirmData.type = ConfirmData.Style.Normal
                        confirmData.content = TI18N("开启冒险宝箱需要消耗<color='#00ff00'>15000</color>{assets_2, 90000}，是否继续？")
                        confirmData.sureLabel = TI18N("确认")
                        confirmData.cancelLabel = TI18N("取消")
                        confirmData.sureCallback = function()
                            if RoleManager.Instance.RoleData.coin >= 15000 then
                                ShippingManager.Instance.model:OpenBoxWindow({battle_id = data.battleid, uid = data.id})
                            else
                                NoticeManager.Instance:FloatTipsByString(TI18N("{assets_2, 90000}不足，无法开启宝箱"))
                            end
                        end
                        NoticeManager.Instance:ConfirmTips(confirmData)
        elseif baseData.fun_type == SceneConstData.unittype_pet then
        elseif data.unittype == SceneConstData.unittype_taskcollection or data.unittype == SceneConstData.unittype_collection or data.unittype == SceneConstData.unittype_pick or data.unittype == SceneConstData.unittype_taskcollection_effect then
            local base = baseData
            if base ~= nil and base.fun_type == SceneConstData.fun_type_skill_prac_box then -- 如果功能类型为冒险保箱类型，则打开冒险保箱界面
                if RoleManager.Instance.RoleData.lev < 30 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("你的等级不足30级，还不能打开冒险宝箱~"))
                else
                    if not SkillManager.Instance.model:check_prac_skill_fullexp() then
                        local confirmData = NoticeConfirmData.New()
                        confirmData.type = ConfirmData.Style.Normal
                        confirmData.content = TI18N("开启冒险宝箱需要消耗<color='#00ff00'>30000银币</color>，是否继续？")
                        confirmData.sureLabel = TI18N("确认")
                        confirmData.cancelLabel = TI18N("取消")
                        confirmData.sureCallback = function()
                            if RoleManager.Instance.RoleData.coin >= 30000 then
                                SkillManager.Instance:Send10812(data.id, data.battleid)
                            else
                                NoticeManager.Instance:FloatTipsByString(TI18N("{assets_2, 90000}不足，无法开启宝箱"))
                            end
                        end
                        NoticeManager.Instance:ConfirmTips(confirmData)

                        self:Set_Selected_Effect(touchNpcView.gameObject.transform, true)
                        self.Selected_Effect_Parent = touchNpcView
                    else
                        NoticeManager.Instance:FloatTipsByString(TI18N("冒险技能经验已满，无法开启宝箱"))
                    end
                end
            -- elseif base ~= nil and base.fun_type == SceneConstData.fun_type_notname_treasure then
            --     NotNamedTreasureManager.Instance.model:OpenTreasure(base.id, data.id)
            else
                self:Self_MoveToTarget(objectName)
            end
        else
            self:Self_MoveToTarget(objectName)
        end
    end
end

function SceneElementsModel:ClickRoleObject(eventData, eventObject)
    -- print(string.format("ClickRoleObject %s", eventObject))
    if eventObject == nil or self.self_view == nil or BaseUtils.is_null(self.self_view.gameObject) then return end
    
    if eventObject == self.self_view.gameObject then
        -- print("点击自己")
        local ray = ctx.MainCamera:ScreenPointToRay(Input.mousePosition) --从摄像机发出到点击坐标的射线
        local raycastHits = Physics.RaycastAll(ray, Mathf.Infinity, (2 ^ LayerMask.NameToLayer("Model")))
        local hitObjects = BaseUtils.RaycastHitToGameObject(raycastHits)
        for i = #hitObjects, 1, -1 do
            local gameObj = hitObjects[i]
            if not BaseUtils.is_null(gameObj) then
                local nv = self.NpcView_List[gameObj.name]
                if nv ~= nil and nv.controller.DontSelect ~= true then --当射线碰撞目标是npc，传递点击给他
                    eventData.pointerEnter = gameObj
                    nv.controller:OnPointerClick(eventData)
                    return
                end

                local rv = self.RoleView_List[gameObj.name]
                if rv ~= nil and rv.controller.DontSelect ~= true and rv ~= self.self_view then --当射线碰撞目标是role，传递点击给他
                    eventData.pointerEnter = gameObj
                    rv.controller:OnPointerClick(eventData)
                    return
                end
            end
        end

        SceneManager.Instance.sceneModel.mapclicker:Click(eventData.position)
    else
        local touchRoleView = self.RoleView_List[eventObject.name]
        -- BaseUtils.dump(touchRoleView,"SceneElementsModel:ClickRoleObject")
        -- BaseUtils.dump(self.self_view,"self.self_view")
        if touchRoleView ~= nil then -- 点击到玩家单位的处理
            local ray = ctx.MainCamera:ScreenPointToRay(Input.mousePosition) --从摄像机发出到点击坐标的射线
            local raycastHits = Physics.RaycastAll(ray, Mathf.Infinity, (2 ^ LayerMask.NameToLayer("Model")))
            local hitObjects = BaseUtils.RaycastHitToGameObject(raycastHits)
            for i = #hitObjects, 1, -1 do
                local gameObj = hitObjects[i]
                if not BaseUtils.is_null(gameObj) then
                    local nv = self.NpcView_List[gameObj.name]
                    if nv ~= nil and nv.controller.DontSelect ~= true then --当射线碰撞目标是role，传递点击给他
                        eventData.pointerEnter = gameObj
                        nv.controller:OnPointerClick(eventData)
                        return
                    end
                end
            end

            if not BaseUtils.is_null(touchRoleView.gameObject) then
                self:Set_Selected_Effect(touchRoleView:GetCachedTransform(), true)
                self.Selected_Effect_Parent = touchRoleView
            end

            if HalloweenManager.Instance.model:ClickRole(touchRoleView.data) then
                return
            end

            if touchRoleView.data ~= nil then
                if touchRoleView.data.status ~= 2 then
                    SceneManager.Instance.sceneModel.mapclicker:Click(eventData.position)
                end

                if self:IsOnArena(self.self_view) and self:IsOnArena(touchRoleView) then
                    CombatManager.Instance:Send10760(touchRoleView.data.roleid, touchRoleView.data.platform, touchRoleView.data.zoneid)
                elseif self:CheckCanFight(touchRoleView) then
                    --公会战，发起战斗
                    if self.self_view.data.event == 17 then
                        GuildfightManager.Instance:send15504(touchRoleView.data.roleid, touchRoleView.data.platform, touchRoleView.data.zoneid)
                    elseif self.self_view.data.event == RoleEumn.Event.CanYon then
                        CanYonManager.Instance:Send21104(touchRoleView.data.roleid, touchRoleView.data.platform, touchRoleView.data.zoneid)
                    end
                end
            end
            MainUIManager.Instance:SetPlayerData(touchRoleView.data)


            -- 元宝争霸
            if RoleManager.Instance.RoleData.event == RoleEumn.Event.IngotCrashPVP then
                -- 单人PK准备地图，点击对方玩家发起战斗
                if IngotCrashManager.Instance.lastClickStemp ~= nil and BaseUtils.BASE_TIME - IngotCrashManager.Instance.lastClickStemp > 5 then
                    NoticeManager.Instance:FloatTipsByString(TI18N("不能频繁发起战斗噢~"))
                else
                    IngotCrashManager.Instance:send20003()
                end
            end
        end
    end
end
--判断是否可以进入公会战 战斗场景
function SceneElementsModel:CheckCanFight(touchRoleView)
    local looks_type = nil
    if (self.self_view.data.event == 17 and touchRoleView.data.event == 17) then
        looks_type = 64
    elseif self.self_view.data.event == RoleEumn.Event.CanYon and touchRoleView.data.event == RoleEumn.Event.CanYon then
        looks_type = SceneConstData.looktype_hero_camp
    end

    if looks_type ~= nil then
        local looksMine = nil
        local looksOther = nil
        for i,v in ipairs(self.self_view.data.looks) do
            if v.looks_type == looks_type then
                looksMine = v
                break
            end
        end
        for i,v in ipairs(touchRoleView.data.looks) do
            if v.looks_type == looks_type then
                looksOther = v
                break
            end
        end
        if looksMine ~= nil and looksOther ~= nil and  looksMine.looks_val ~= looksOther.looks_val then
            return true
        else
            return false
        end
    else
        return false
    end
end

function SceneElementsModel:TouchSceneUnit(objectName)
    --print(debug.traceback())
    --print(objectName.."objectName")
    if self.self_view == nil or BaseUtils.is_null(self.self_view.gameObject) then return end
    -- 寻路目标
    if self.target_uniqueid == objectName then self.target_uniqueid = nil end
    --BaseUtils.dump(self.NpcView_List,"self.NpcView_List")
    local touchNpcView = self.NpcView_List[objectName]
    self.touchNpcView = touchNpcView
    if touchNpcView ~= nil and not BaseUtils.is_null(touchNpcView.gameObject) then -- 碰撞到场景单位的处理
        local touchNpcData = touchNpcView.data

        if touchNpcView.gameObject == self.CurrentClickObject then -- 碰撞到的是点击选中的目标
			if DataUnit.data_unit[touchNpcData.baseid].sounds_id > 0 then
                if not SoundManager.Instance.playerList[AudioSourceType.NPC]:IsPlaying() then
                    SoundManager.Instance:Play(DataUnit.data_unit[touchNpcData.baseid].sounds_id)
                end
			end
            if self.autopath_data ~= nil and self.autopath_data.targetid == objectName then
                self:Self_CancelAutoPath()
            end
            ctx.sceneManager.CurrentClickObject = nil
            self.CurrentClickObject = nil
            self.self_view:StopMoveTo()
            self.self_view.controller.TriggerUnit = touchNpcView.gameObject
            if touchNpcData.unittype == SceneConstData.unittype_npc then
                --普通npc
                if not touchNpcView.data.no_facetopoint then
                    touchNpcView:FaceToPoint(self.self_view:GetCachedTransform().localPosition)
                end
                -- if touchNpcView.baseData.fun_type == SceneConstData.send_word_latern then
                --      --寄语灯笼
                --     if AnniversaryTyManager.Instance.model.IsFirstLantern == true then
                --         AnniversaryTyManager.Instance:Send11894()  --请求寄语列表
                --         AnniversaryTyManager.Instance.model.IsFirstLantern = false
                --     end
                -- end
                MainUIManager.Instance:OpenDialog(touchNpcData)
            elseif touchNpcData.unittype == SceneConstData.unittype_dramaunit or touchNpcData.unittype == SceneConstData.unittype_monster then
                -- 剧情单位/.普通怪物的，如果有配按钮，就弹npc框没就直接操作
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                local base = DataUnit.data_unit[touchNpcData.baseid]
                local isDungeon = false
                for k1,v1 in pairs(DataDungeon.data_get) do
                    for k2,v2 in pairs(v1.unit_list) do
                        if v2.unit_base_id[1] == touchNpcData.baseid then
                            isDungeon = true
                            break
                        end
                    end
                end
                --print(DungeonManager.Instance.currdungeonID.."currdungeonID")

                if DungeonManager.Instance.currdungeonID ~= nil and DataDungeon.data_get[DungeonManager.Instance.currdungeonID] ~= nil and isDungeon == true and (TeamManager.Instance:MyStatus()  == RoleEumn.TeamStatus.None or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader) and TeamManager.Instance.teamNumber < 4 then
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
                    local btn1 = {button_id = DialogEumn.ActionType.action6, button_args = {}, button_desc = TI18N("继续挑战"), button_show = "[]"}
                    local btn2 = {button_id = DialogEumn.ActionType.action998, button_args = {1}, button_desc = string.format(TI18N("只是路过"), TrialManager.Instance.model.can_ask), button_show = "[]"}
                    extra.base.buttons = { btn1, btn2 }
                    extra.base.plot_talk = TI18N("副本战斗非常凶险，你的队伍人数不足4人，凭什么打败我？")
                    MainUIManager.Instance.dialogModel:Open(touchNpcData, extra, true)

                else
                    if base ~= nil and #base.buttons > 0 then
                        touchNpcView:FaceToPoint(self.self_view:GetCachedTransform().localPosition)
                        if base.fun_type == SceneConstData.fun_type_godswar_boss then
                            --如果功能类型为诸神boss类型，则先请求战斗id
                            GodsWarWorShipManager.Instance:Send17957()
                        end
                        if touchNpcData.battleid == 21 then
                            --宠物情愿宠物对话框
                            PetLoveManager.Instance.model:InitTalkUI(touchNpcData)
                        else
                            --print("####################")
                            MainUIManager.Instance:OpenDialog(touchNpcData)
                        end
                    elseif base ~= nil and base.fun_type == SceneConstData.fun_type_trial_unit then -- 如果功能类型为试炼类型，则打开试炼对话框
                        touchNpcView:FaceToPoint(self.self_view:GetCachedTransform().localPosition)
                        TrialManager.Instance.model:open_dialog(touchNpcData)
                    elseif base ~= nil and base.fun_type == SceneConstData.fun_type_trial_box then -- 如果功能类型为试炼保箱类型，则播放死亡动作后再触发
                        TrialManager.Instance.model:click_trial_box(touchNpcView, touchNpcData)
                    else
                        touchNpcView:FaceToPoint(self.self_view:GetCachedTransform().localPosition)

                        -- 客户端拦截处理
                        if touchNpcData.id == 20012 then
                            DramaManagerCli.Instance:TouchYifu()
                            return
                        end
                        SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id)
                    end
                end
            elseif touchNpcData.unittype == SceneConstData.unittype_teleporter then
                -- print(string.format("碰撞到目标传送点了 %s", objectName))
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id)
            elseif touchNpcData.unittype == SceneConstData.unittype_fun_teleporter then -- 功能传送点
                -- print(string.format("功能传送点 %s", objectName))
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                local base = DataUnit.data_unit[touchNpcData.baseid]
                -- print(touchNpcData.baseid)
                if base ~= nil then
                    -- print(base.fun_type)
                    -- print(SceneConstData.fun_type_exit_home)
                    if base.fun_type == SceneConstData.fun_type_exit_home then
                        HomeManager.Instance:ExitHome()
                    end
                end
            elseif touchNpcData.unittype == SceneConstData.unittype_exquisite_shelf then
                -- print(string.format("碰撞到目标传送点了 %s", objectName))
                SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                ExquisiteShelfManager.Instance:send20307()

            elseif touchNpcData.unittype == SceneConstData.unittype_taskcollection or touchNpcData.unittype == SceneConstData.unittype_collection or touchNpcData.unittype == SceneConstData.unittype_pick or touchNpcData.unittype == SceneConstData.unittype_taskcollection_effect then
                local base = DataUnit.data_unit[touchNpcData.baseid]
                if base ~= nil and base.id == 62321 then -- 特殊id，红包雨
                    local txt = TI18N("采集中......")
                    local time = 2000
                    local func = function()
                        RedBagManager.Instance:Send18504(touchNpcData.id)
                    end
                    self.collection.callback = func
                    self.collection:Show({msg = txt, time = time})
                elseif base ~= nil and base.fun_type == SceneConstData.fun_type_guild_plant_flower then
                    --公会种花
                    -- GuildManager.Instance.isNeedShowPlantFlowerPanel = true
                    --发协议，要打开种花界面
                    -- Log.Debug("点击公会种花单位，要打开种花界面")
                    -- Log.Error(touchNpcData.id)
                    GuildManager.Instance:request11166(touchNpcData.battleid,touchNpcData.id)
                elseif base ~= nil and base.fun_type == SceneConstData.fun_type_top_compete then
                    --巅峰宝箱
                    local key_num = BackpackManager.Instance:GetItemCount(29005)
                    if key_num == 0 then
                        local data = NoticeConfirmData.New()
                        data.type = ConfirmData.Style.Normal
                        data.content = TI18N("您的钥匙已经用完，是否传送出去")
                        data.sureLabel = TI18N("确认")
                        data.sureSecond = 10
                        data.cancelLabel = TI18N("取消")
                        data.sureCallback = function()
                            TopCompeteManager.Instance:request15102()
                        end
                        NoticeManager.Instance:ConfirmTips(data)
                    else
                        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                        local txt = TI18N("采集中......")
                        local time = 2000
                        local func = function()
                            SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id, 0)
                        end
                        self.collection.callback = func
                        self.collection:Show({msg = txt, time = time})
                    end
                elseif base ~= nil and base.fun_type == SceneConstData.fun_type_fairyland_box then --
                    --点中幻境宝箱
                    local cfg_data = FairyLandManager.Instance.model:get_cfg_data(base.id)

                    local confirm_back = function()
                        local key_num = FairyLandManager.Instance.model:get_can_open_key_num(cfg_data.key_type)
                        if key_num == 0 then
                            NoticeManager.Instance:FloatTipsByString(TI18N("当前没有可以开启该宝箱的钥匙，无法开启宝箱"))
                            return
                        end
                        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
                        local txt = TI18N("采集中......")
                        local time = DataFairy.data_time[cfg_data.box_id].timeout*1000
                        local func = function()
                            SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id, 0)
                        end
                        self.collection.callback = func
                        self.collection:Show({msg = txt, time = time})
                    end
                    local key_name = FairyLandManager.Instance.model:get_key_name(cfg_data.key_type)
                    local tong_box_name = FairyLandManager.Instance.model.fairy_box_names[cfg_data.key_type]
                    if cfg_data.box_id == 79643 then
                        tong_box_name = TI18N("神秘宝箱")
                    end
                    local str = string.format("%s1%s%s%s%s%s", TI18N("是否消耗"), TI18N("把"), key_name, TI18N("打开"), tong_box_name, TI18N("宝箱"))
                    local confirm_data = NoticeConfirmData.New()
                    confirm_data.type = ConfirmData.Style.Normal
                    confirm_data.content = str
                    confirm_data.sureLabel = TI18N("开启")
                    confirm_data.cancelLabel = TI18N("取消")
                    confirm_data.sureCallback = function() confirm_back()  end
                    NoticeManager.Instance:ConfirmTips(confirm_data)
                elseif base ~= nil and base.fun_type == SceneConstData.fun_type_notname_treasure then
                    NotNamedTreasureManager.Instance.model:OpenTreasure(base.id, touchNpcData.id)
                elseif base ~= nil and base.fun_type == SceneConstData.fun_type_home_flower then -- 家园魔法豌豆
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.magicbeenpanel)
                elseif base ~= nil and base.fun_type == SceneConstData.fun_type_child_water then -- 子女采集泉水
                    WindowManager.Instance:OpenWindowById(WindowConfig.WinID.child_whater_win)
                elseif touchNpcData.battleid == SceneConstData.battle_id_home_box then
                    local txt = TI18N("采集中......")
                    local time = 2000
                    local func = function()
                        SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id)
                        HomeManager.Instance:Send11229(touchNpcData.id)
                    end
                    self.collection.callback = func
                    self.collection:Show({msg = txt, time = time})
                else
                    SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)

                    if touchNpcData.battleid == 0 and QuestManager.Instance.plantData ~= nil and touchNpcData.id == QuestManager.Instance.plantData.unit_id and QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.plant) == nil then
                        -- 种树任务倒计时
                        MainUIManager.Instance:OpenDialog(touchNpcData, nil, false, false, true)
                        return
                    end

                    if touchNpcData.baseid == 76203 then
                        if touchNpcData.id == QuestManager.Instance.plantData.unit_id and QuestManager.Instance:GetQuestByType(QuestEumn.TaskType.plant) ~= nil and QuestManager.Instance.round_plant == 6 then
                            if TeamManager.Instance:MemberCount() < 2 then
                                ---确认框
                                local data = NoticeConfirmData.New()
                                data.type = ConfirmData.Style.Normal
                                data.content = TI18N("当且仅当<color='#00ff00'>两人</color>组队收获时，可获得经验加成。您现在只有<color='#00ff00'>一人</color>，是否确定收获？")
                                data.sureLabel = TI18N("确定")
                                data.cancelLabel = TI18N("取消")
                                data.sureCallback = function()
                                    self.collection.callback = function() SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id) end
                                    self.collection:Show({msg = TI18N("收获中..."), time = 2000})
                                end
                                NoticeManager.Instance:ConfirmTips(data)
                            else
                                self.collection.callback = function() SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id) end
                                self.collection:Show({msg = TI18N("收获中..."), time = 2000})
                            end
                        else
                            base = BaseUtils.copytab(DataUnit.data_unit[76203])
                            base.buttons = {}
                            base.plot_talk = QuestEumn.PlantDesc[math.random(1,#QuestEumn.PlantDesc)]
                            MainUIManager.Instance:OpenDialog({id = QuestManager.Instance.plantData.unit_id, baseid = baseId}, {base = base}, true, true)
                        end
                        return
                    end

                    local txt = TI18N("采集中......")
                    local time = 2000
                    local effectType = 0
                    local effectId = 0
                    local sound = 0
                    if DataElf.data_collect[touchNpcData.baseid] ~= nil then
                        time = DataElf.data_collect[touchNpcData.baseid].time * 1000
                    elseif touchNpcView.baseData ~= nil and touchNpcView.baseData ~= "" then
                        local a = StringHelper.MatchBetweenSymbols(touchNpcView.baseData.data_cli, "{", "}")
                        if a[1] ~= nil then
                            local ss = StringHelper.Split(a[1], ",")
                            time = tonumber(ss[2])
                            txt = ss[3]
                            effectType = tonumber(ss[4])
                            effectId = tonumber(ss[5])
                            sound = tonumber(ss[6])
                        end
                    end

                    local func = nil
                    if SceneManager.Instance:CurrentMapId() == 51001 then
                        if WarriorManager.Instance:IsDead() ~= true then
                            func = function() WarriorManager.Instance:PickUnit(touchNpcData.battleid, touchNpcData.id, touchNpcData.baseid) end
                            if DataWarrior.data_artifact[touchNpcData.baseid] ~= nil then
                                time = 8000
                            end
                        else
                            NoticeManager.Instance:FloatTipsByString(TI18N("你已经死亡，不能进行采集"))
                            return
                        end
                    else
                        func = function() SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id) end
                    end
                    self.collection.callback = func
                    self.collection:Show({msg = txt, time = time, type = effectType, id = effectId, sound = sound, map = SceneManager.Instance:CurrentMapId(), x = touchNpcData.x, y = touchNpcData.y})
                end
            elseif touchNpcData.unittype == SceneConstData.unittype_worldboss then
                touchNpcView:FaceToPoint(self.self_view:GetCachedTransform().localPosition)
                MainUIManager.Instance:OpenDialog(touchNpcData)
            elseif touchNpcData.unittype == 12 then --游行npc类型
                MainUIManager.Instance:OpenDialog(touchNpcData)
            elseif touchNpcData.fun_type == 35 and touchNpcData.type == 1 then
                MainUIManager.Instance:OpenDialog(touchNpcData)
            elseif touchNpcData.unittype == SceneConstData.unittype_guild_dragon then
                GuildDragonManager.Instance:BeginFight()
            else
                local base = DataUnit.data_unit[touchNpcData.baseid]
                local isDungeon = false
                for k1,v1 in pairs(DataDungeon.data_get) do
                    for k2,v2 in pairs(v1.unit_list) do
                        if v2.unit_base_id[1] == touchNpcData.baseid then
                            isDungeon = true
                            break
                        end
                    end
                end

                if DungeonManager.Instance.currdungeonID ~= nil and DataDungeon.data_get[DungeonManager.Instance.currdungeonID] ~= nil and isDungeon == true and (TeamManager.Instance:MyStatus()  == RoleEumn.TeamStatus.None or TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Leader) and TeamManager.Instance.teamNumber < 4 then
                    local extra = {}
                    extra.base = BaseUtils.copytab(DataUnit.data_unit[touchNpcData.baseid])
                    local btn1 = {button_id = DialogEumn.ActionType.action6, button_args = {}, button_desc = TI18N("继续挑战"), button_show = "[]"}
                    local btn2 = {button_id = DialogEumn.ActionType.action998, button_args = {1}, button_desc = string.format(TI18N("只是路过"), TrialManager.Instance.model.can_ask), button_show = "[]"}
                    extra.base.buttons = { btn1, btn2 }
                    extra.base.plot_talk = TI18N("副本战斗非常凶险，你的队伍人数不足4人，凭什么打败我？")
                    MainUIManager.Instance.dialogModel:Open(touchNpcData, extra, true)
                else

                    touchNpcView:FaceToPoint(self.self_view:GetCachedTransform().localPosition)
                    if #DataUnit.data_unit[touchNpcData.baseid].buttons == 0 then
                        SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id)
                    elseif touchNpcData.unittype == 3 and DungeonManager.Instance.activeType == 5 then      -- 夺宝奇兵
                        MainUIManager.Instance:OpenDialog(touchNpcData)
                    else
                        SceneManager.Instance:Send10100(touchNpcData.battleid, touchNpcData.id)
                    end
                end
            end
        end
    end

    -- Mark 没有碰撞玩家的需求，暂时屏蔽
    -- local touchRoleView = self.RoleView_List[objectName]
    -- if touchRoleView ~= nil then -- 碰撞到玩家单位的处理
    --     local touchRoleData = touchRoleView.data
    -- end
end

-- 是否在主城擂台上
function SceneElementsModel:IsOnArena(target)
    if target == nil or target.gameObject == nil then return false end
    if SceneManager.Instance:CurrentMapId() ~= 10001 then return false end

    local p = target:GetCachedTransform().localPosition
    p = SceneManager.Instance.sceneModel:transport_big_pos(p.x, p.y)
    if p.x > 3180 and p.x < 4205 and p.y > 3100 and p.y < 3608 then
        return true
    else
        return false
    end
end

-- 设置是否限制玩家单位数量
function SceneElementsModel:Set_LimitRoleNum(limit)
    -- Log.Debug("SceneElementsModel:Set_LimitRoleNum(limit)--debug info ="..debug.traceback())
    -- print(limit)
    self.LimitRoleNum = limit
    if self.LimitRoleNum then
        self.NowRoleNum = 0
        for key,value in pairs(self.RoleView_List) do
            self.NowRoleNum = self.NowRoleNum + 1
        end

        -- Log.Debug("Set_LimitRoleNum %s"..self.NowRoleNum)

        -- while self.ShowRoleNum < self.NowRoleNum do -- 限制玩家单位数量
        -- 暂时处理崩溃，具体逻辑得吃货和场景商量两边协调处理好,这样处理会导致在吃货中场景的省流量设置无效
        while self.ShowRoleNum < self.NowRoleNum do -- 限制玩家单位数量
            local uniqueroleid = nil
            for k, v in pairs(self.RoleView_List) do
                if k ~= self.self_unique and not TeamManager.Instance:IsInMyTeam(k) then
                    if RoleEumn.Event.Parade ~= v.data.event and not v.data.is_virtual then -- 不是吃货游行活动，且不是虚拟单位，可尝试移除
                        uniqueroleid = k
                        break
                    elseif RoleEumn.Event.Parade == v.data.event then -- 是吃货游行活动，不管是不是虚拟单位，都可尝试移除
                        uniqueroleid = k
                        break
                    end
                end
            end

            if uniqueroleid == nil then return end

            self:RemoveRoleAndCache(uniqueroleid)
        end
    end
end

function SceneElementsModel:RemoveRoleAndCache(uniqueroleid)
    local rv = self.RoleView_List[uniqueroleid]
    if rv ~= nil then -- 已创建的玩家
        if not rv.data.is_virtual then
            self.WaitForCreateUnitData_List[uniqueroleid] = rv.data
            rv:DeleteMe()
            self.RoleView_List[uniqueroleid] = nil
            self.NowRoleNum = self.NowRoleNum - 1
        else
            -- print(string.format("%s是虚拟单位", rv.data.name))
            self.NowRoleNum = self.NowRoleNum - 1
        end
    end
end

function SceneElementsModel:Set_isovercontroll(value)
    self.isovercontroll = value
    if TeamManager.Instance:MyStatus() == RoleEumn.TeamStatus.Follow or RoleManager.Instance.RoleData.Event == RoleEumn.Event.Parade
        or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_cere or RoleManager.Instance.RoleData.event == RoleEumn.Event.Marry_guest_cere then
        self.isovercontroll = false
    end
end

function SceneElementsModel:SetAllRoleNameColor()
    local roleData = RoleManager.Instance.RoleData
    for _, roleView in pairs(self.RoleView_List) do
        for __,lookData in pairs(roleView.data.looks) do
            if lookData.looks_type == SceneConstData.looktype_camp_name then
                if roleData.camp ~= 0 and lookData.looks_val ~= 0 then
                    if roleView.data.event == RoleEumn.Event.Halloween or roleView.data.event == RoleEumn.Event.Halloween_sub then
                        if roleData.camp == lookData.looks_val then
                            roleView:SetNameColor(ColorHelper.colorObjectScene[1])
                        else
                            roleView:SetNameColor(ColorHelper.colorObjectScene[6])
                        end
                    else
                        if roleData.camp == lookData.looks_val then
                            roleView:SetNameColor(ColorHelper.colorObjectScene[9])
                        else
                            roleView:SetNameColor(ColorHelper.colorObjectScene[6])
                        end
                    end
                end
            end
        end
    end
end

function SceneElementsModel:Get_Self_Loaded()
    if self.self_view and self.self_view.data.uniqueid == self.self_unique and self.self_view.tpose  then
        return true
    end
    return false
end

function SceneElementsModel:GetSceneData_Npc()
    local datalist = {}
    for k, v in pairs(self.NpcView_List) do
        table.insert(datalist, v.data)
    end
    for k, v in pairs(self.WaitForCreateUnitData_List) do
        if v.unittype ~= SceneConstData.unittype_role then
            table.insert(datalist, v)
        end
    end
    return datalist
end


function SceneElementsModel:GetSceneData_Role()
    local datalist = {}
    for k, v in pairs(self.RoleView_List) do
        table.insert(datalist, v.data)
    end
    for k, v in pairs(self.WaitForCreateUnitData_List) do
        if v.unittype == SceneConstData.unittype_role then
            table.insert(datalist, v)
        end
    end
    return datalist
end

-- 获取某个角色数据
function SceneElementsModel:GetSceneData_OneRole(uniqueid)
    local data = nil
    local roleView = self.RoleView_List[uniqueid]
    if roleView == nil then
        data = self.WaitForCreateUnitData_List[uniqueid]
    else
        data = roleView.data
    end
    return data
end

-- 获取某个角色数据
function SceneElementsModel:GetSceneData_OneNpc(uniqueid)
    local data = nil
    local npcView = self.NpcView_List[uniqueid]
    if npcView == nil then
        data = self.WaitForCreateUnitData_List[uniqueid]
    else
        data = npcView.data
    end
    return data
end

--创建并显示足迹
function SceneElementsModel:CreateFootMarks(pos, uniqueid, effectid)
    local isCreate = true
    if isCreate and self.scene_elements ~= nil then
        local footData = DataSystem.data_foot_mark[effectid]
        if self.TargetFootEffect[effectid] == nil then
            self.TargetFootEffect[effectid] = {}
        end
        local fun = function(effectView)
            local effectObject = effectView.gameObject
            effectObject.name = "TargetFootEffect".."_"..effectid.."_"..uniqueid
            effectObject.transform:SetParent(self.scene_elements.transform)
            effectObject.transform.localScale = Vector3.one
            effectObject.transform.localRotation = Quaternion.Euler(330,0,0)
            effectObject.transform.localPosition = Vector3(pos.x, pos.y, footData.z_value)
        end
        local footRes = BaseEffectView.New({effectId = effectid, time = nil, callback = fun})
        local singleFoot = { effectView = footRes, unique_id = uniqueid, clean_count = footData.clean_count, hide_count = footData.hide_count}
        table.insert(self.TargetFootEffect[effectid], singleFoot)
    end
end


--展示某人的足迹
function SceneElementsModel:ShowFootMarks(pos, uniqueid, effectid)
    local footEffectList = self.TargetFootEffect[effectid]
    local isCreateFoot = true    --需要创建New
    local targetFoot = nil
    if footEffectList ~= nil then
        for i,v in pairs(footEffectList) do
            if v.hide_count == -1 then
                targetFoot = v
                isCreateFoot = false
            end
        end
    end

    if not isCreateFoot and targetFoot ~= nil then
        local footData = DataSystem.data_foot_mark[effectid]
        targetFoot.hide_count = footData.hide_count
        targetFoot.clean_count = footData.clean_count
        targetFoot.unique_id = uniqueid
        targetFoot.effectView:SetActive(false)
        targetFoot.effectView.transform.position = Vector3(pos.x, pos.y, footData.z_value)
        targetFoot.effectView:SetActive(true)
    else
        local num = self:GetRoleFootCount(uniqueid, effectid)
        -- print("&&&&&&&&&&&&&&&&&&&&&&____"..num)
        if num < 3 then
            self:CreateFootMarks(pos, uniqueid, effectid)
        else
            self:GetRoleMinCountFoot(pos, uniqueid, effectid)
        end
        
    end
end
--fixed 刷新
function SceneElementsModel:UpdateRoleFootStatus()
    for _, v in pairs(self.TargetFootEffect) do
        for i, data in pairs(v) do
            if data.hide_count == 0 then
                data.hide_count = -1
                data.effectView:SetActive(false)
            elseif data.hide_count > 0 then
                data.hide_count = data.hide_count - 1
            end
            if data.clean_count == 0 then
                data.clean_count = -1
                if data.effectView ~= nil then
                    data.effectView:DeleteMe()
                    data.effectView = nil
                end
                v[i] = nil
            elseif data.clean_count > 0 then
                data.clean_count = data.clean_count - 1
            end
        end
    end
end


--找到自己hide_count最小的足迹
function SceneElementsModel:GetRoleMinCountFoot(pos, uniqueid, effectid)
    local minNum = nil
    local minIndex = nil
    for i, v in pairs(self.TargetFootEffect) do
        if i == uniqueid then
            for k, data in pairs(v) do
                if minNum == nil then
                    minNum = data.hide_count
                    minIndex = k
                else
                    if data.hide_count < minNum then
                        minNum = data.hide_count
                        minIndex = k
                    end
                end
            end
        end
        if minIndex ~= nil then
            local footData = DataSystem.data_foot_mark[effectid]
            v[minIndex].hide_count = footData.hide_count
            v[minIndex].clean_count = footData.clean_count
            v[minIndex].unique_id = uniqueid
            v[minIndex].effectView:SetActive(false)
            v[minIndex].effectView.transform.position = Vector3(pos.x, pos.y, footData.z_value)
            v[minIndex].effectView:SetActive(true)
        end
    end
end

--当前角色足迹个数
function SceneElementsModel:GetRoleFootCount(uniqueid, effectid)
    local num = 0 
    if self.TargetFootEffect[effectid] ~= nil then
        for i,v in pairs(self.TargetFootEffect[effectid]) do
            if v.unique_id == uniqueid then
                num = num + 1
            end
        end
    end
    return num
end
