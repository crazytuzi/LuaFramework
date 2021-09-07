RoleView = RoleView or BaseClass(UnitView)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function RoleView:__init(data)
    self.wing = nil
    self.wingAnimationData = nil

    self.weapon = nil
    self.weapon2 = nil

    self.transform_id = 0 -- 变身id
    self.camp = 0 -- 阵营值

    self.tweenTposeId = nil
    self.last_ridefly = nil -- 上次的模型是坐骑飞行

    self.noSendMove = false -- 不同步位置标记，特殊状态时设置，如：跳跃中

    self.ChangeLook_Mark_Timer = nil
    self._CancelChangeLookMark = function()
        self:CancelChangeLookMark()
    end
end

function RoleView:__delete()
    -- print(string.format("玩家被删除了 %s", self.data.uniqueid))
    self:ClearCollectStatusEffect()
    self:objPool_push()



    if self.tweenTposeId ~= nil then
        Tween.Instance:Cancel(self.tweenTposeId)
        self.tweenTposeId = nil
    end

    if self.gameObject.name ~= SceneManager.Instance.sceneElementsModel.self_unique then
        -- CombatManager.Instance.objPool:PushUnit(self.gameObject, "role_obj")
        self:SetNameColor(ColorHelper.colorObjectScene[9])
        self:SetGuildNameColor(ColorHelper.colorObjectScene[12])
        GoPoolManager.Instance:Return(self.gameObject, "role_obj", GoPoolType.BoundRole)
        self.gameObject = nil
    end
end

function RoleView:StopMoveTo()
    self.TargetPositionList = {}
    -- 站立动作
    self:PlayStandAction()

    if self.moveEnd_CallBack ~= nil then
        local callback = self.moveEnd_CallBack
        self.moveEnd_CallBack = nil
        callback()
    end

    if self.gameObject ~= nil and self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
        SceneManager.Instance.sceneElementsModel:Self_Change_Top_Effect(2)
    end
end

function RoleView:Create()
	-- print(string.format("get_unique_roleid %s %s %s", self.data.roleid, self.data.zoneid, self.data.platform))
    -- self.gameObject = CombatManager.Instance.objPool:PopUnit("role_obj")
    self.gameObject = GoPoolManager.Instance:Borrow("role_obj", GoPoolType.BoundRole)

    if self.gameObject ~= nil then
        local oldTpose = self.gameObject.transform:FindChild("tpose")
        if oldTpose ~= nil then
            GameObject.Destroy(oldTpose.gameObject)
        end

        local controller = self.gameObject:GetComponent(RoleController)
        if controller ~= nil then
            GameObject.Destroy(controller)
        end
    else
    	self.gameObject = GameObject.Instantiate(SceneManager.Instance.sceneElementsModel.instantiate_object_role)
    end

	local gameObject = self.gameObject
    Utils.ChangeLayersRecursively(gameObject.transform, "Model")
    gameObject.transform:SetParent(SceneManager.Instance.sceneElementsModel.scene_elements.transform)
    gameObject.name = self.data.uniqueid

    -- self.shadow = gameObject.transform:FindChild("Shadow").gameObject
    -- self.shadow:SetActive(false)

    self.rolename_object = gameObject.transform:FindChild("RoleName")
    self.rolenameshadow_object = gameObject.transform:FindChild("RoleNameShadow")
    self.guildname_object = gameObject.transform:FindChild("GuildName")
    self.guildnameshadow_object = gameObject.transform:FindChild("GuildNameShadow")

    self.transform_id = 0
    self.honor_object = gameObject.transform:FindChild("Honor")

    self.controller = gameObject:AddComponent(RoleController)
    self.Speed = self.data.speed * SceneManager.Instance.sceneModel.mapsizeconvertvalue
    -- self.role_controller:FaceTo_LuaNow(scene_data.UnitFaceToIndex[self.data.dir+1])

    self:SetNameColor(ColorHelper.colorObjectScene[9])
    -- self:SetGuildNameColor(ColorHelper.colorObjectScene[9])

    self:JumpTo_by_big_pos(self.data.x, self.data.y)
    -- self:change_unitstate(self.data.state)
    self:change_ride()

    self:change_name()
    self:change_guild_name()
    -- self:change_honor()
    self:ChangeLook()
    self:change_team_leader_mark()
    self:change_foot_mark()
    self:change_status_effect()

    if SceneManager.Instance.sceneElementsModel.self_unique ~= nil and SceneManager.Instance.sceneElementsModel.self_unique ~= "" then
        if gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
            SceneManager.Instance.sceneElementsModel.self_view = self
            SceneManager.Instance.sceneElementsModel.self_data = self.data
            SceneManager.Instance.MainCamera:SetFolloewObject(self.gameObject)
            SceneManager.Instance.sceneElementsModel:setfollow()

            self._subpackageCompleted = function() self:subpackageCompleted() end
            SubpackageManager.Instance.OnCompletedEvent:Add(self._subpackageCompleted)
            -- if not mod_scene_manager.show_me_mark then -- 处理隐藏自己
            --     gameObject:SetActive(false)
            -- end
        elseif self.data.passengersData ~= nil and self.data.passengersData[SceneManager.Instance.sceneElementsModel.self_unique] ~= nil then
            SceneManager.Instance.MainCamera:SetFolloewObject(self.gameObject)
            SceneManager.Instance.sceneElementsModel:setfollow()
            self._subpackageCompleted = function() self:subpackageCompleted() end
            SubpackageManager.Instance.OnCompletedEvent:Add(self._subpackageCompleted)
        else
            -- if not mod_scene_manager.show_otherrole_mark then -- 处理隐藏玩家单位
                -- if not table.containValue(mod_scene_manager.show_otherrole_excludelist, gameObject.name) then
                --     gameObject:SetActive(false)
                -- end
            -- end
        end
    else
        SceneManager.Instance.resetSelfView = true
    end

    self:ChangeZIndex(self.rolename_object)
    self:ChangeZIndex(self.rolenameshadow_object)
    self:ChangeZIndex(self.guildname_object)
    self:ChangeZIndex(self.guildnameshadow_object)
    self:ChangeZIndex(gameObject.transform:FindChild("Shadow"), 21)
end

function RoleView:ChangeLook()
    -- print("ChangeLook"..debug.traceback())
    --BaseUtils.dump(self.data,"self.data__")
    -- print(string.format("ChangeLook %s %s", self.data.name, Time.time))
    -- BaseUtils.dump(self.data.looks, self.data.name)
    if self.gameObject == nil then
        return
    end

    if self.ChangeLook_Mark then
        self.ChangeLook_Cache = true
        return
    end

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    -- 开始加载模型，计数加1
    if sceneElementsModel.createTposeCount < sceneElementsModel.createTposeCount_Max or self.gameObject.name == sceneElementsModel.self_unique then
        sceneElementsModel:AddCreateTposeCount()
        self.CreateTpose_Mark = false
    else
        self.CreateTpose_Mark = true
        return
    end

    self.transform_id = 0
    local hasScale = false

    self.tposeAnimator2 = nil
    self.roleAnimationData2 = nil

    if BaseUtils.IsVerify then
        -- 现在人物不用变身了，直接给他一个时装
        -- local isHasTrans = false
        -- for k,v in pairs(self.data.looks) do
        --     if v.looks_type == SceneConstData.looktype_transform then -- 普通变身
        --         v.looks_val = KvData.GetRoleTransformId()
        --         isHasTrans = true
        --         break
        --     end
        -- end
        -- if isHasTrans == false then
        --     local transformData = {
        --         looks_type =  SceneConstData.looktype_transform,
        --         looks_mode = 0,
        --         looks_val = KvData.GetRoleTransformId(),
        --         looks_str = "",
        --     }
        --     table.insert(self.data.looks, transformData)
        -- end

        local dressLook, hairLook = KvData.RandomRoleLook(self.gameObject.name == sceneElementsModel.self_unique)
        local isHasDress = false
        local isHasHair = false
        for k,v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_dress then -- 身上时装
                self.data.looks[k] = dressLook
                isHasDress = true
            elseif v.looks_type == SceneConstData.looktype_hair then -- 头上时装
                self.data.looks[k] = hairLook
                isHasHair = true
            end
        end
        if not isHasDress then
            table.insert(self.data.looks, dressLook)
        end
        if not isHasHair then
            table.insert(self.data.looks, hairLook)
        end
    end

    for k,v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_transform then -- 变身
            -- if SceneManager.Instance.sceneElementsModel.Show_Transform_Mark then
            --     self.transform_id = v.looks_val
            -- else
            --     local transform_data = DataTransform.data_transform[v.looks_val]
            --     if transform_data ~= nil and transform_data.hard_show == 1 then
            --         self.transform_id = v.looks_val
            --     end
            -- end
            self.transform_id = v.looks_val
        elseif v.looks_type == SceneConstData.looktype_scale then -- 变身
            hasScale = true
            self:SetScale(v.looks_val/100)
        elseif v.looks_type == SceneConstData.looktype_lev_break then -- 等级突破
            if v.looks_val == 1 then
                self:SetNameColor(ColorHelper.colorObjectScene[10])
            elseif v.looks_val == 2 then
                self:SetNameColor(ColorHelper.colorObjectScene[11])
            end
        elseif v.looks_type == SceneConstData.looktype_camp then -- 活动的阵营
            self.camp = v.looks_val
        elseif v.looks_type == SceneConstData.looktype_hero_camp then

        elseif v.looks_type == SceneConstData.looktype_camp_cake then -- 护送蛋糕特效
            if v.looks_val == 1 and self.top_effect_state ~= 7 then -- 只要是护送蛋糕
                self:change_top_effect(7)
            elseif v.looks_val == 2 and self.top_effect_state ~= 9 then -- 只要是护送蛋糕 特殊
                self:change_top_effect(9)
            elseif v.looks_val == 0 then
                if self.top_effect_id == 20188 then -- 仅当护送蛋糕时才处理
                    self:change_top_effect(8)
                elseif self.top_effect_id == 20189 then -- 仅当护送蛋糕时才处理
                    self:change_top_effect(10)
                end
            end
        elseif v.looks_type == SceneConstData.looktype_league_king then
            self.guildname_object:GetComponent(TextMesh).text = self.data.guild..TI18N("王牌")
            self.guildname_object.gameObject:SetActive(true)
            self.guildnameshadow_object:GetComponent(TextMesh).text = self.data.guild..TI18N("王牌")
            self.guildnameshadow_object.gameObject:SetActive(true)
        elseif v.looks_type == SceneConstData.looktype_name_color then -- 名字颜色、改名字
            self:SetNameColor(ColorHelper.colorObjectScene[v.looks_val])
            if v.looks_str ~= nil then
                if v.looks_str ~= "" then self.data.name = v.looks_str end
                self:change_name()
            end
        elseif v.looks_type == SceneConstData.looktype_guild_name_color then -- 公会名字颜色
            self:SetGuildNameColor(ColorHelper.colorObjectScene[v.looks_val])
        elseif v.looks_type == SceneConstData.looktype_camp_name then
            local roleData = RoleManager.Instance.RoleData
            if self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
                roleData.camp = v.looks_val
                SceneManager.Instance.sceneElementsModel:SetAllRoleNameColor()
            else
                if roleData.camp ~= 0 and v.looks_val ~= 0 then
                    if roleData.camp == v.looks_val then
                        self:SetNameColor(ColorHelper.colorObjectScene[9])
                    else
                        self:SetNameColor(ColorHelper.colorObjectScene[6])
                    end
                end
            end
        end
    end

    if self.data.event == RoleEumn.Event.Halloween or self.data.event == RoleEumn.Event.Halloween_sub then -- 万圣节南瓜精活动特殊处理
        self:ChangeEvent(self.data.event)

        self.transform_id = 76880
        hasScale = true
        self:SetScale(1.2)
        self:change_name()

        if RoleManager.Instance.RoleData.camp == self.camp then
            self:SetNameColor(ColorHelper.colorObjectScene[1])
        else
            self:SetNameColor(ColorHelper.colorObjectScene[6])
        end
    end

    if hasScale == false then
        self:SetScale(1)
    end

    local changeLookKey = math.random()
    self.changeLookKey = changeLookKey
    if self.transform_id ~= 0 then
        local transform_data = DataTransform.data_transform[self.transform_id]
        if transform_data == nil then
            print(string.format("不存在的变身id %s", self.transform_id))
            SceneManager.Instance.sceneElementsModel:SubCreateCount()
            return
        end

        local skinId = transform_data.skin
        local modelId = transform_data.res
        local animationId = transform_data.animation_id
        local scale = 1

        if BaseUtils.IsVerify then
            local scaleList = {0.8, 0.9, 1, 1.1, 1.2, 1.3, 1.4, 1.5}
            math.randomseed(os.time())
            scale = scaleList[math.random(1, #scaleList)]
        end

        self.data.canIdle = true
        self.ChangeLook_Mark = true
        self:StartChangeLookMarkTimer()
        local callback = function(tpose, animationData, poolData) self:TposeComplete(changeLookKey, animationData, tpose, nil, nil, poolData) end
        NpcTposeLoader.New(skinId, modelId, animationId, scale, callback)
    elseif self.data.ride == SceneConstData.unitstate_ride then
        if self:GetShowRide() and RideManager.Instance:CanShowRide(self.data.event) then -- 是可以显示坐骑的event
            self.data.canIdle = false
            self.ChangeLook_Mark = true
            self:StartChangeLookMarkTimer()
            local callback = function(ride, rideAnimationData, ridePoolData,nowBaseId) self:RideTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData,nowBaseId) end
            RideTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)
        else  -- 是不可以显示坐骑的event
            self.data.canIdle = true
            self.ChangeLook_Mark = true
            self:StartChangeLookMarkTimer()
            local callback = function(animationData, tpose, headAnimationData, headTpose, poolData) self:TposeComplete(changeLookKey, animationData, tpose, headAnimationData, headTpose, poolData) end
            RoleTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)
        end
    elseif self.data.ride == SceneConstData.unitstate_fly then
        local looks_ride = 0
        local looks_ride_jewelry2 = 0
        for k, v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                looks_ride = v.looks_val
            end
            if v.looks_type == SceneConstData.looktype_ride_jewelry2 then -- 坐骑饰品2
                looks_ride_jewelry2 = v.looks_val
            end
        end
        if looks_ride == 0 or looks_ride_jewelry2 == 0 or not RideManager.Instance:CanShowRide(self.data.event)
            or not self:GetShowRide() then -- 普通飞信
            self.ride_fly = false
            self.data.canIdle = true
            self.ChangeLook_Mark = true
            self:StartChangeLookMarkTimer()
            local callback = function(animationData, tpose, headAnimationData, headTpose, poolData) self:TposeComplete(changeLookKey, animationData, tpose, headAnimationData, headTpose, poolData) end
            RoleTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)
        else -- 坐骑飞行
            self.ride_fly = true
            self.data.canIdle = false
            self.ChangeLook_Mark = true
            self:StartChangeLookMarkTimer()
            local callback = function(ride, rideAnimationData, ridePoolData,nowBaseId) self:RideTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData,nowBaseId) end
            RideTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)

            if self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
                SceneManager.Instance.sceneElementsModel:setfollow()
            end
        end
    else
        self.data.canIdle = true
        self.ChangeLook_Mark = true
        self:StartChangeLookMarkTimer()
        local callback = function(animationData, tpose, headAnimationData, headTpose, poolData) self:TposeComplete(changeLookKey, animationData, tpose, headAnimationData, headTpose, poolData) end
        RoleTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)
    end
end

function RoleView:ChangeLook_AfterBuildTpose()
    self:CleanAllEffect()
    self:ClearHalo()
    for k,v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_effect then
            self:CreateEffect(v.looks_val)
        elseif v.looks_type == SceneConstData.looktype_buff then
            local effect_id = DataBuff.data_list[v.looks_val].effect_id
            if effect_id ~= 0 then self:CreateEffect(effect_id) end
        elseif v.looks_type == SceneConstData.looktype_tpose_alpha then -- 透明
            if v.looks_val == 1 then
                self.can_alpha = false
                self:SetAlpha(0.3)
            else
                self.can_alpha = true
                self:UpdateAlpha(true)
            end
        elseif v.looks_type == SceneConstData.lookstype_halo then
            -- self:CreateEffect(v.looks_val)
            self:LoadHalo(v.looks_val)
        end
    end
end

function RoleView:RideTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData,nowBaseId)
    if self.changeLookKey ~= changeLookKey then
        if ride ~= nil then GameObject.Destroy(ride) end
        return
    end

    if self.gameObject == nil then
        if ride ~= nil then GameObject.Destroy(ride) end
        return
    end
    self.nowBaseId = nowBaseId
    local callback = function(animationData, tpose, headAnimationData, headTpose, poolData)
        self:RideAndRoleTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData, animationData, tpose, headAnimationData, headTpose, poolData)
    end
    RoleTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)
end

function RoleView:RideAndRoleTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData, animationData, tpose, headAnimationData, headTpose, poolData)
    if self.changeLookKey ~= changeLookKey then
        if ride ~= nil then GameObject.Destroy(ride) end
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        return
    end

    if self.gameObject == nil then
        if ride ~= nil then GameObject.Destroy(ride) end
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        return
    end

    if BaseUtils.isnull(ride) then
        LuaTimer.Add(1000, function() self:ChangeLook() end)
        return
    end

    self.animationData = rideAnimationData
    self.roleAnimationData = animationData
    self.headAnimationData = headAnimationData
    self.rideEffect = ridePoolData.rideEffect

    self:IsShowEffect()
    ride.name = "tpose"
    Utils.ChangeLayersRecursively(ride.transform, "Model")
    ride.transform:SetParent(self.gameObject.transform)

    -- self.shadow:SetActive(true)

    self.animator = ride:GetComponent(Animator)
    self.tposeAnimator = tpose:GetComponent(Animator)
    if headTpose ~= nil then
        self.animator_head = headTpose:GetComponent(Animator)
    else
        self.animator_head = nil
    end

    --local path = BaseUtils.GetChildPath(ride.transform, "bp_body")
    local path = self:GetRidePath(ride, 1)
    -- print("bp_body_RideAndRole"..debug.traceback())
    local bind = ride.transform:Find(path)
    if bind ~= nil then
        local t = tpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        -- t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")

        local looks_ride
        for k, v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                looks_ride = v.looks_val
            end
        end
        --print("bp_body_RideAndRole222"..debug.traceback())
        local looksData = DataMount.data_ride_data[looks_ride]
        if looksData then
            local action_type = looksData.action_type_male
            if self.data.sex == 0 then
                action_type = looksData.action_type_female
            end
            --print(action_type.."action_type")
            --BaseUtils.dump(self.roleAnimationData,"self.roleAnimationData")
            if action_type == 2 or action_type == 3 then
                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id2))
            elseif action_type == 4 then
                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id3))
            elseif action_type == 5 then
                if RoleManager.Instance.RoleData.sex == 0 then
                    self.tposeAnimator:Play(SceneConstData.genanimationname("Stand", 6))
                else
                    self.tposeAnimator:Play(SceneConstData.genanimationname("Stand", 1))
                end
            elseif action_type == 6 then
                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", 5))
            elseif action_type == 7 then  --双侧坐乘骑
                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id5))
            else
                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id))
            end
        else
            Log.Debug(string.format("<color='#00ff00'>mount_data 这个坐骑数据没有啊 %s</color>", looks_ride))
        end
        -- self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", 3))
    end

    self.cachedTposeTransform = nil

    if self.tpose == nil then
        self.tpose = ride
        self.roleTpose = tpose
        self.headTpose = headTpose
        local dir = self.data.dir
        if dir ~= nil and SceneConstData.UnitFaceToIndex[dir+1] ~= nil then self:FaceTo_Now(SceneConstData.UnitFaceToIndex[dir+1]) end
        self:CreatTposeComplete()
    else
        -- self.tpose:SetActive(false)
        -- self.tpose.name = "Destroy_Tpose"
        -- local destroy_tpose = self.tpose

        self:objPool_push()

        self.tpose = ride
        self.roleTpose = tpose
        self.headTpose = headTpose
        self:FaceTo_Now(self.orienation)

        -- GameObject.Destroy(destroy_tpose)
    end


    self.ride = true

    -- 存储用于对象池的使用的数据
    self.ridePoolData = ridePoolData
    self.poolData = poolData

    self:change_ride()
    self:SetScale(self.scale)

    self.ChangeLook_Mark = false
    self:ClearChangeLookMarkTimer()
    if self.ChangeLook_Cache then
        self.ChangeLook_Cache = false
        self:ChangeLook()
        return
    end

    -- 暂时只考虑双人坐骑
    if self.data.isDriver == 1 then
        
        local callback = function(animationData, tpose, headAnimationData, headTpose, poolData)
            self:RideAndTwoRoleTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData, animationData, tpose, headAnimationData, headTpose, poolData, self.roleTpose, self.headTpose)
        end
        local passengerUniqueid = BaseUtils.get_unique_roleid(self.data.passengers[1].rid, self.data.passengers[1].zone_id, self.data.passengers[1].platform)
        -- BaseUtils.dump(self.data, "-----------")
        local passengerData = self.data.passengersData[passengerUniqueid]
        if passengerData ~= nil then
            if passengerUniqueid == SceneManager.Instance.sceneElementsModel.self_unique then
                SceneManager.Instance.sceneElementsModel.self_data = RoleData.New()
                SceneManager.Instance.sceneElementsModel.self_data:update_data(passengerData)
            end
            --BaseUtils.dump(passengerData,"乘客数据look")
            RoleTposeLoader.New(passengerData.classes, passengerData.sex, passengerData.looks, callback)
        else
            -- 加载单位完成，计数减1
            SceneManager.Instance.sceneElementsModel:SubCreateTposeCount()
        end
    else
        -- 加载单位完成，计数减1
        SceneManager.Instance.sceneElementsModel:SubCreateTposeCount()
    end

    -- 加载单位完成，计数减1
    --SceneManager.Instance.sceneElementsModel:SubCreateTposeCount()

    if self.action_cacheData == nil then
        if self:Get_IsMoving() then
            local targetPosition = self.TargetPositionList[1]
            self:FaceToPoint(targetPosition)
            self:PlayMoveAction()
        else
            self:PlayStandAction()
        end
    else
        if self.action_cacheData.act_name ~= nil then
            self:PlayActionName(self.action_cacheData.act_name, self.action_cacheData.nostand)
        else
            self:PlayAction(self.action_cacheData.action, self.action_cacheData.nostand)
        end
        self.action_cacheData = nil
    end

    if self.transform_id == 0 and self.data.event ~= RoleEumn.Event.Marry_cere then
        local noWing = false
        local looks_ride
        for k, v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                looks_ride = v.looks_val
            end
        end

        local looksData = DataMount.data_ride_data[looks_ride]
        if looksData then
            if looksData.action_type == 2 or looksData.action_type == 3 then
                noWing = true
            end
        end

        self.weaponPoolData = nil
        self:LoadOthers(changeLookKey, {noWing = noWing})
    end

    if self.tweenTposeId ~= nil then
        Tween.Instance:Cancel(self.tweenTposeId)
        self.tweenTposeId = nil
    end

    local rideFlyHight = self:GetRideFlyHight()
    if self.data.ride == SceneConstData.unitstate_fly and self.ride_fly then
        if self.last_ridefly == nil or self.last_ridefly or self.tpose == nil then
            ride.transform.localPosition = Vector3(0, rideFlyHight, 0)
        else
            ride.transform.localPosition = Vector3.zero
            self:PlayMoveAction()
            self.tweenTposeId = Tween.Instance:MoveLocalY(ride.gameObject, rideFlyHight, 0.5, function() self:RideFlyTweenEnd(ride) end).id
        end
        -- self.shadow.transform.localScale = Vector3.one
        self.last_ridefly = true
        self:update_top_object()
    else
        if not self.last_ridefly or self.tpose == nil then
            ride.transform.localPosition = Vector3.zero
        else
            ride.transform.localPosition = Vector3(0, rideFlyHight, 0)
            self:PlayMoveAction()
            self.tweenTposeId = Tween.Instance:MoveLocalY(ride.gameObject, 0, 0.5, function() self:RideFlyTweenEnd(ride) end).id
        end
        -- self.shadow.transform.localScale = Vector3(1.5, 1.5, 1.5)
        self.last_ridefly = false
    end

    self:ChangeLook_AfterBuildTpose()
end

function RoleView:RideAndTwoRoleTposeComplete(changeLookKey, ride, rideAnimationData, ridePoolData, animationData, tpose, headAnimationData, headTpose, poolData, firstRoleTpose, firstRoleHeadTpose)
    if self.changeLookKey ~= changeLookKey then
        if ride ~= nil then GameObject.Destroy(ride) end
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        if firstRoleTpose ~= nil then GameObject.Destroy(firstRoleTpose) end
        if firstRoleHeadTpose ~= nil then GameObject.Destroy(firstRoleHeadTpose) end
        return
    end

    if self.gameObject == nil then
        if ride ~= nil then GameObject.Destroy(ride) end
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        if firstRoleTpose ~= nil then GameObject.Destroy(firstRoleTpose) end
        if firstRoleHeadTpose ~= nil then GameObject.Destroy(firstRoleHeadTpose) end
        return
    end

    if BaseUtils.isnull(ride) then
        LuaTimer.Add(1000, function() self:ChangeLook() end)
        return
    end

    self.animationData2 = rideAnimationData
    self.roleAnimationData2 = animationData
    self.headAnimationData2 = headAnimationData

    self.tposeAnimator2 = tpose:GetComponent(Animator)
    if headTpose ~= nil then
        self.animator_head2 = headTpose:GetComponent(Animator)
    else
        self.animator_head2 = nil
    end
    --local path = BaseUtils.GetChildPath(ride.transform, "bp_body2")
    local path = self:GetRidePath(ride, 2)
    
    local bind = ride.transform:Find(path)
    if bind ~= nil then
        local t = tpose:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        -- t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")

        local looks_ride
        for k, v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                looks_ride = v.looks_val
            end
        end

        local looksData = DataMount.data_ride_data[looks_ride]
        if looksData then
            local action_type = looksData.action_type_male
            if self.data.sex == 0 then
                action_type = looksData.action_type_female
            end
            --print(action_type.."action_type")
            --BaseUtils.dump(self.roleAnimationData,"self.roleAnimationData")
            if action_type == 2 or action_type == 3 then
                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id2))
            elseif action_type == 4 then
                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id3))
            elseif action_type == 5 then
                if RoleManager.Instance.RoleData.sex == 0 then
                    self.tposeAnimator2:Play(SceneConstData.genanimationname("Stand", 6))
                else
                    self.tposeAnimator2:Play(SceneConstData.genanimationname("Stand", 1))
                end
            elseif action_type == 6 then --跪坐
                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", 5))
            elseif action_type == 7 then  --双侧坐乘骑
                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id6))
            else
                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id))
            end
            --self.animation_cls_passenger = self.tposeAnimator2
            --self.animationData_passenger = self.roleAnimationData2
        else
            Log.Debug(string.format("<color='#00ff00'>mount_data 这个坐骑数据没有啊 %s</color>", looks_ride))
        end
        -- self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", 3))
    end

    self.poolData2 = poolData
    self.roleTpose2 = tpose
    self.headTpose2 = headTpose

    --加载乘客头饰
    local loadHeadSurbase = false
    local passengerUniqueid = BaseUtils.get_unique_roleid(self.data.passengers[1].rid, self.data.passengers[1].zone_id, self.data.passengers[1].platform)
    local passengerData = self.data.passengersData[passengerUniqueid]
    if passengerData ~= nil then
        for k, v in pairs(passengerData.looks) do
            if v.looks_type == SceneConstData.lookstype_headsurbase then -- 头饰
                loadHeadSurbase = true
                break
            end
        end
        if loadHeadSurbase then
            print("加载头饰")
            local callback_passenger = function(headsurbase, headsurbaseData, headsurbasePoolData) self:HeadSurbaseComplete_passenger(changeLookKey, headsurbase, headsurbaseData, headsurbasePoolData, tpose) end
            HeadSurbaseTposeLoader.New(passengerData.looks, callback_passenger)
        end
    end
end

function RoleView:GetRidePath(ride, type)
    local path = nil
    local data = self.data
    if self.data.isDriver == 1 then
        local passengerUniqueid = BaseUtils.get_unique_roleid(self.data.passengers[1].rid, self.data.passengers[1].zone_id, self.data.passengers[1].platform)
        local passengerdata = self.data.passengersData[passengerUniqueid]
        if self:IsSheepRide() then
            --冲阵羊系列 区分男女
            if passengerdata ~= nil then
                if self.data.sex == 0 or (self.data.sex == 1 and passengerdata.sex == 1) then
                    if type == 1 then  --第一个位置
                        path = BaseUtils.GetChildPath(ride.transform, "bp_body")
                    elseif type == 2 then  --第二个位置
                        path = BaseUtils.GetChildPath(ride.transform, "bp_body2")
                    end
                elseif self.data.sex == 1 and passengerdata.sex == 0 then
                    if type == 1 then  --第一个位置
                        path = BaseUtils.GetChildPath(ride.transform, "bp_body2")
                    elseif type == 2 then  --第二个位置
                        path = BaseUtils.GetChildPath(ride.transform, "bp_body")
                    end
                end
            end
        else
            --默认双人坐骑，队长位置挂点1 乘客位置挂点2
            if type == 1 then  --第一个位置
                path = BaseUtils.GetChildPath(ride.transform, "bp_body")
            elseif type == 2 then  --第二个位置
                path = BaseUtils.GetChildPath(ride.transform, "bp_body2")
            end
        end
    else
        path = BaseUtils.GetChildPath(ride.transform, "bp_body")
    end
    return path
end

function RoleView:IsSheepRide()
    if self.nowBaseId == 2057 or self.nowBaseId == 2058 or self.nowBaseId == 2059 or self.nowBaseId == 2060 or self.nowBaseId == 2061 or self.nowBaseId == 2062 then
        return true
    end
    return false
end

-- function RoleView:IsDoubleDogandPigRide()
--     if self.nowBaseId == 2063 or self.nowBaseId == 2064 or self.nowBaseId == 2065 or self.nowBaseId == 2066 or self.nowBaseId == 2067 or self.nowBaseId == 2068 then
--         return true
--     end
--     return false
-- end



function RoleView:GetRideFlyHight()
    local looks_ride
    for k, v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
            looks_ride = v.looks_val
        end
    end

    if looks_ride == 2023 or looks_ride == 2024 or looks_ride == 2025 or looks_ride == 2026 or looks_ride == 2027 or looks_ride == 2028 or looks_ride == 2029 or looks_ride == 2030 then
        return 0.2
    else
        return 0.4
    end
end

--坐骑自带特效 （不是飞行特效）
function RoleView:IsShowEffect()
    local myEffectLoader = false
    if self.rideEffect ~= nil and not BaseUtils.isnull(self.rideEffect.gameObject) then
        --   BaseUtils.dump(self.data,"当前坐骑数据000==================================")
        -- BaseUtils.dump(RideManager.Instance.model.ridelist,"所有坐骑数据000===================================")
        -- for k,v in pairs(RideManager.Instance.model.ridelist) do
        --     if self.nowBaseId == v.base.base_id then
        --         print(self.nowBaseId)
        --         BaseUtils.dump(v,"??????????????????????????????????????")
        --         if v.decorate_list ~= nil then
            if  RideManager.Instance.model.cur_ridedata ~= nil and RideManager.Instance.model.cur_ridedata.decorate_list ~= nil then
                    --BaseUtils.dump(RideManager.Instance.model.cur_ridedata.decorate_list,"decorate_list")
                    for k2,v2 in pairs(RideManager.Instance.model.cur_ridedata.decorate_list) do
                        if v2.decorate_index == 1 then
                            myEffectLoader = true

                        end
                    end
            end
                -- end
            -- end
        local mountData = DataMount.data_ride_data[self.nowBaseId]
        if mountData.isalwaysshow == 1 then
            self.rideEffect.gameObject:SetActive(true)
        else
            if myEffectLoader == true then
                self.rideEffect.gameObject:SetActive(true)
            else
                self.rideEffect.gameObject:SetActive(false)
            end
        end
    end
end


function RoleView:RideFlyTweenEnd(ride)
    if not BaseUtils.isnull(ride) then
        if self:Get_IsMoving() then
            self:PlayMoveAction()
        else
            self:PlayStandAction()
        end
    end
end

function RoleView:TposeComplete(changeLookKey, animationData, tpose, headAnimationData, headTpose, poolData)
    -- print(string.format("TposeComplete %s %s %s", self.data.name, tpose, Time.time))
    if self.changeLookKey ~= changeLookKey then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        return
    end

    if self.gameObject == nil then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        return
    end

    self.animationData = animationData
    self.headAnimationData = headAnimationData
    tpose.name = "tpose"
    Utils.ChangeLayersRecursively(tpose.transform, "Model")
    tpose.transform:SetParent(self.gameObject.transform)
    tpose.transform.localPosition = Vector3.zero
    -- self.shadow:SetActive(true)
    -- self.shadow.transform.localScale = Vector3(0.7, 0.7, 0.7)

    self.animator = tpose:GetComponent(Animator)
    if headTpose ~= nil then
        self.animator_head = headTpose:GetComponent(Animator)
    else
        self.animator_head = nil
    end

    self.cachedTposeTransform = nil

    if self.tpose == nil then
        self.tpose = tpose
        self.headTpose = headTpose
        local dir = self.data.dir
        if dir ~= nil and SceneConstData.UnitFaceToIndex[dir+1] ~= nil then self:FaceTo_Now(SceneConstData.UnitFaceToIndex[dir+1]) end
        self:CreatTposeComplete()
    else
        -- self.tpose:SetActive(false)
        -- self.tpose.name = "Destroy_Tpose"
        -- local destroy_tpose = self.tpose

        self:objPool_push()

        self.tpose = tpose
        self.headTpose = headTpose
        self:FaceTo_Now(self.orienation)

        -- GameObject.Destroy(destroy_tpose)
    end

    self.last_ridefly = false

    self.ride = false

    self.roleTpose = nil
    self.roleAnimationData = nil
    self.ridePoolData = nil

    -- 存储用于对象池的使用的数据
    self.poolData = poolData

    self:change_ride()
    self:SetScale(self.scale)

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateTposeCount()

    self.ChangeLook_Mark = false
    self:ClearChangeLookMarkTimer()
    if self.ChangeLook_Cache then
        self.ChangeLook_Cache = false
        self:ChangeLook()
        return
    end

    if self.action_cacheData == nil then
        if self:Get_IsMoving() then
            local targetPosition = self.TargetPositionList[1]
            self:FaceToPoint(targetPosition)
            self:PlayMoveAction()
        else
            self:PlayStandAction()
        end
    else
        if self.action_cacheData.act_name ~= nil then
            self:PlayActionName(self.action_cacheData.act_name, self.action_cacheData.nostand)
        else
            self:PlayAction(self.action_cacheData.action, self.action_cacheData.nostand)
        end
        self.action_cacheData = nil
    end

    if self.transform_id == 0 and self.data.event ~= RoleEumn.Event.Marry_cere then
        local callback = function(weapon, weapon2, weaponPoolData,isOtherWeapon) self:WeaponComplete(changeLookKey, weapon, weapon2, weaponPoolData,isOthenWeapon) end
        WeaponTposeLoader.New(self.data.classes, self.data.sex, self.data.looks, callback)
    end

    self:ChangeLook_AfterBuildTpose()

    if self.data.tposecallback ~= nil then
        self.data.tposecallback(self)
        self.data.tposecallback = nil
    end
    if (self.collectstatus ~= nil and self.collectstatus == 1) or CanYonManager.Instance:IsCollecting(self.gameObject.name) then
        if self.collectstatus ~= 1 then
            self:ShowCollectStatusEffect()
        else
            self:ShowCollectStatusEffect(true)
        end
    end

    LuaTimer.Add(200, function() if self.data ~= nil then self:ChangeEvent(self.data.event) end end)
end

function RoleView:WeaponComplete(changeLookKey, weapon, weapon2, weaponPoolData,isOtherWeapon)
    self.isOtherWeapon = isOtherWeapon or false
    if self.changeLookKey ~= changeLookKey then
        if weapon ~= nil then GameObject.Destroy(weapon) end
        if weapon2 ~= nil then GameObject.Destroy(weapon2) end
        return
    end

    if self.gameObject == nil then
        if weapon ~= nil then GameObject.Destroy(weapon) end
        if weapon2 ~= nil then GameObject.Destroy(weapon2) end
        return
    end
    if self.transform_id ~= 0 then
        if weapon ~= nil then GameObject.Destroy(weapon) end
        if weapon2 ~= nil then GameObject.Destroy(weapon2) end
        return
    end

    local point = nil
    if self.data.classes == SceneConstData.classes_ranger or self.data.classes == SceneConstData.classes_devine then
        point = BaseUtils.GetChildPath(self.tpose.transform, "Bip_L_Weapon")
    else
        point = BaseUtils.GetChildPath(self.tpose.transform, "Bip_R_Weapon")
    end

    local t = weapon:GetComponent(Transform)
    weapon.name = "Mesh_Weapon"
    Utils.ChangeLayersRecursively(t, "Model")
    t:SetParent(self.tpose.transform:Find(point))
    t.localPosition = Vector3.zero
    t.localRotation = Quaternion.identity
    t.localScale = Vector3.one

    if weapon2 ~= nil then
        local point = BaseUtils.GetChildPath(self.tpose.transform, "Bip_L_Weapon")
        local t2 = weapon2:GetComponent(Transform)
        weapon2.name = "Mesh_Weapon"
        Utils.ChangeLayersRecursively(t2, "Model")
        t2:SetParent(self.tpose.transform:Find(point))
        t2.localPosition = Vector3.zero
        t2.localRotation = Quaternion.identity
        t2.localScale = Vector3.one
    end
    self.weaponPoolData = weaponPoolData
    self.weapon = weapon
    self.weapon2 = weapon2

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    if self.gameObject.name == sceneElementsModel.self_unique then
        if not sceneElementsModel.Show_Self_Weapon_Mark then
            if self.weapon ~= nil then
                self.weapon:SetActive(false)
            end
            if self.weapon2 ~= nil then
                self.weapon2:SetActive(false)
            end
        end
    end

    self:LoadOthers(changeLookKey)
end

function RoleView:WingComplete(changeLookKey, wing, animationData, wingPoolData)
    if self.changeLookKey ~= changeLookKey then
        if wing ~= nil then GameObject.Destroy(wing) end
        return
    end

    if self.gameObject == nil then
        if wing ~= nil then GameObject.Destroy(wing) end
        return
    end
    if self.transform_id ~= 0 then
        if wing ~= nil then GameObject.Destroy(wing) end
        return
    end

    local path = BaseUtils.GetChildPath(self.tpose.transform, "bp_wing")
    local bind = self.tpose.transform:Find(path)
    if bind ~= nil then
        local t = wing:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")
        self.wingPoolData = wingPoolData
        self.wing = wing
        self.wingAnimationData = animationData
    end
    self:UpdateAlpha(true)

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    if not sceneElementsModel.Show_Role_Wing_Mark then
        if self.wing ~= nil then
            self.wing:SetActive(false)
        end
    end
end

function RoleView:BeltComplete(changeLookKey, belt, beltData, beltPoolData)
    if self.changeLookKey ~= changeLookKey then
        if belt ~= nil then GameObject.Destroy(belt) end
        return
    end

    if self.gameObject == nil then
        if belt ~= nil then GameObject.Destroy(belt) end
        return
    end
    if self.transform_id ~= 0 then
        if belt ~= nil then GameObject.Destroy(belt) end
        return
    end

    local path = BaseUtils.GetChildPath(self.tpose.transform, "bp_wing")
    local bind = self.tpose.transform:Find(path)
    if bind ~= nil then
        local t = belt:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 270, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")
        self.beltPoolData = beltPoolData
        self.belt = belt
    end
    self:UpdateAlpha(true)
end

function RoleView:HeadSurbaseComplete(changeLookKey, headsurbase, headsurbaseData, headsurbasePoolData)
    if self.changeLookKey ~= changeLookKey then
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return
    end
    if self.gameObject == nil then
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return
    end
    if self.transform_id ~= 0 then
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return
    end
    local path = BaseUtils.GetChildPath(self.tpose.transform, "Bip_Head")
    local bind = self.tpose.transform:Find(path)

    if (self.data.ride == SceneConstData.unitstate_ride or (self.data.ride == SceneConstData.unitstate_fly and self.ride_fly)) and not BaseUtils.is_null(self.roleTpose) then
        path = BaseUtils.GetChildPath(self.roleTpose.transform, "Bip_Head")
        bind = self.roleTpose.transform:Find(path)
    end
    
    
    if bind ~= nil then
        local t = headsurbase:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 0, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")
        self.headsurbasePoolData = headsurbasePoolData
        self.headsurbase = headsurbase
    end
    self:UpdateAlpha(true)
end

function RoleView:HeadSurbaseComplete_passenger(changeLookKey, headsurbase, headsurbaseData, headsurbasePoolData, tpose)
    if self.changeLookKey ~= changeLookKey then
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return
    end
    if self.gameObject == nil then
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return
    end
    if self.transform_id ~= 0 then
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return
    end
    if tpose == nil then  
        if headsurbase ~= nil then GameObject.Destroy(headsurbase) end
        return 
    end

    local path = BaseUtils.GetChildPath(tpose.transform, "Bip_Head")
    local bind = tpose.transform:Find(path)
    if bind ~= nil then
        local t = headsurbase:GetComponent(Transform)
        t:SetParent(bind)
        t.localPosition = Vector3(0, 0, 0)
        t.localRotation = Quaternion.identity
        t:Rotate(Vector3(90, 0, 0))
        t.localScale = Vector3(1, 1, 1)
        Utils.ChangeLayersRecursively(t, "Model")
        self.headsurbasePoolData2 = headsurbasePoolData
        self.headsurbase2 = headsurbase
    end
    self:UpdateAlpha(true)
end


function RoleView:loadRideEffect()
    -- BaseUtils.dump(self.data,"self.data_loadRideEffect")
    if self.data.ride == SceneConstData.unitstate_fly then
        local looks_ride = 0
        local looks_ride_jewelry1 = 0
        local looks_ride_jewelry2 = 0
        for k, v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                looks_ride = v.looks_val
            elseif v.looks_type == SceneConstData.looktype_ride_jewelry1 then -- 坐骑饰品1
                looks_ride_jewelry1 = v.looks_val
            elseif v.looks_type == SceneConstData.looktype_ride_jewelry2 then -- 坐骑饰品2
                looks_ride_jewelry2 = v.looks_val
            end
        end
        if looks_ride ~= 0 and looks_ride_jewelry2 ~= 0 and self:GetShowRide() then
            if self.rideEffectLook ~= looks_ride then
                GameObject.Destroy(self.rideEffectObject)
                self.rideEffectObject = nil
                self:IsShowEffect()

            end

            if not BaseUtils.is_null(self.rideEffectObject) then
                self.rideEffectObject:SetActive(true)
                 if not BaseUtils.is_null(self.rideEffect) and not BaseUtils.is_null(self.rideEffect.gameObject) then
                    self.rideEffect.gameObject:SetActive(false)
                end

            else
                self.rideEffectLook = looks_ride
                local looksData = DataMount.data_ride_data[looks_ride]
                if looksData then
                    local callback = function(gameObject)
                        self.rideEffectObject = gameObject
                        if not BaseUtils.is_null(self.rideEffect) and not BaseUtils.is_null(self.rideEffect.gameObject) then
                            -- self.rideEffect.gameObject:SetActive(false)
                        end
                     end
                    TposeEffectLoader.New(self.gameObject, self.tpose, {{effect_id = looksData.s_effect_id}}, callback)
                else
                    Log.Debug(string.format("<color='#00ff00'>mount_data 这个坐骑数据没有啊 %s</color>", looks_ride))
                end
            end
        elseif not BaseUtils.is_null(self.rideEffectObject) then
            self:IsShowEffect()
        end
    elseif not BaseUtils.is_null(self.rideEffectObject) then
        self.rideEffectObject:SetActive(false)
        self:IsShowEffect()
    end

end

function RoleView:LoadOthers(changeLookKey, extra)

    local updateAlphaMark = false

    local loadWing = false
    local loadHeadSurbase = false
    local loadBelt = false
    local isDobuldRoleRide = false
    local isRideJewelry2 = false
    for k, v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_wing then -- 翅膀
            loadWing = true
        elseif v.looks_type == SceneConstData.lookstype_belt then -- 腰饰
            loadBelt = true
        elseif v.looks_type == SceneConstData.lookstype_headsurbase then -- 头饰
            loadHeadSurbase = true
        elseif v.looks_type == SceneConstData.looktype_ride then -- 双人坐骑
            if v.looks_val > 0 then
                local rideData = DataMount.data_ride_data[v.looks_val]
                if rideData ~= nil then
                    if rideData.multiplayer > 0 then
                        isDobuldRoleRide = true
                    end
                end
            end
        elseif v.looks_type == SceneConstData.looktype_ride_jewelry2 then -- 坐骑饰品2
            isRideJewelry2 = (v.looks_val ~= 0)
        end
    end
    if isDobuldRoleRide == true then
        loadWing = false
        loadBelt = false
        if self.data.ride == SceneConstData.unitstate_fly and not isRideJewelry2 then
            loadWing = true
            loadBelt = true
        end
    end

    if extra ~= nil then
        if extra.noWing then
            loadWing = false
        end
        if extra.noBelt then
            loadBelt = false
        end
        if extra.noHeadSurbase then
            loadHeadSurbase = false
        end
    end

    if loadWing then
        local callback = function(wing, animationData, wingPoolData) self:WingComplete(changeLookKey,wing, animationData, wingPoolData) end
        WingTposeLoader.New(self.data.looks, callback, "Model")
    else
        updateAlphaMark = true
    end

    if loadBelt then
        local callback = function(belt, beltData, beltPoolData) self:BeltComplete(changeLookKey, belt, beltData, beltPoolData) end
        BeltTposeLoader.New(self.data.looks, callback, "Model")
    else
        updateAlphaMark = true
    end

    if loadHeadSurbase then
        local callback = function(headsurbase, headsurbaseData, headsurbasePoolData) self:HeadSurbaseComplete(changeLookKey, headsurbase, headsurbaseData, headsurbasePoolData) end
        HeadSurbaseTposeLoader.New(self.data.looks, callback, "Model")
    else
        updateAlphaMark = true
    end

    if updateAlphaMark then
        self:UpdateAlpha(true)
    end

    self:loadRideEffect()
end

function RoleView:ChangeRideEffect()
    if not BaseUtils.is_null(self.gameObject) and self.gameObject.name ~= SceneManager.Instance.sceneElementsModel.self_unique then return end

    if self.change_ride_effect == nil then
        local callback = function(effect)
            if BaseUtils.is_null(self.gameObject) then
                GameObject.Destroy(effect.gameObject)
                return
            end

            effect.gameObject.transform:SetParent(self.gameObject.transform)
            effect.gameObject.transform.localPosition = Vector3 (0, 0, -20)
            effect.gameObject.transform.localRotation = Quaternion.identity
            effect.gameObject.transform.localScale = Vector3 (1, 1, 1)
            Utils.ChangeLayersRecursively(effect.gameObject.transform, "Model")

            self.change_ride_effect = effect

            local fun = function()
                if not BaseUtils.is_null(self.change_ride_effect) then
                    self.change_ride_effect:SetActive(false)
                end
            end
            LuaTimer.Add(1500, fun)
        end

        if self.change_ride_effect ~= nil then
            self.change_ride_effect:DeleteMe()
            self.change_ride_effect = nil
        end

        self.change_ride_effect = BaseEffectView.New({ effectId = 16134, callback = callback })
    else
        self.change_ride_effect:SetActive(false)
        self.change_ride_effect:SetActive(true)

        local fun = function()
            if not BaseUtils.is_null(self.change_ride_effect) then
                self.change_ride_effect:SetActive(false)
            end
        end
        LuaTimer.Add(1500, fun)
    end
end

function RoleView:CreatTposeComplete()
    if self.gameObject == nil then return end

    self.CreateComplete = true

    self:PlayStandAction()
    -- self:ChangeUnitState(self.data.state)
    -- self:faceto(scene_data.UnitFaceTo.Forward)

    if self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
        local rigidbody = self.gameObject:AddComponent(Rigidbody)
        rigidbody.useGravity = false
        rigidbody.isKinematic = true
        self.IsOverControl = true
        -- player:SetFollower(self.role_controller)
        print(string.format("<color='#00ff00'>自己位置 %s %s</color>", self.gameObject.transform.position.x, self.gameObject.transform.position.y))

        self:SetCapsuleCollider(0.5, 1.5, 0.7)
        -- mod_scene_elements_manager.setfollow()
        LuaTimer.Add(100, function() EventMgr.Instance:Fire(event_name.self_loaded) end)
        -- EventMgr.Instance:Fire(event_name.self_loaded)
    else
        -- local rigidbody = self.gameObject:GetComponent("Rigidbody")
        -- GameObject.Destroy(rigidbody)
    end
end

function RoleView:change_name()
    if self.gameObject == nil then return end
    local name = self.data.name
    if self.data.event == RoleEumn.Event.Halloween or self.data.event == RoleEumn.Event.Halloween_sub then -- 万圣节南瓜精活动特殊处理
        name = "南瓜精"
    end

    local namePrefix = self.namePrefix
    local nameStr = string.format("%s%s", namePrefix, name)
    local nameshadowStr = string.format("%s%s", namePrefix, name)
    if self.data.guild_signature ~= nil and string.len(self.data.guild_signature) > 0 then
        nameStr = string.format("%s%s(%s)", namePrefix, nameStr, self.data.guild_signature)
        nameshadowStr = string.format("%s%s(%s)", namePrefix, nameshadowStr, self.data.guild_signature)
    end

    self.rolename_object:GetComponent(TextMesh).text = nameStr
    self.rolenameshadow_object:GetComponent(TextMesh).text = nameshadowStr
end

function RoleView:change_guild_name()
    if self.gameObject == nil then return end

    local guildStr = ""
    local guildshadowStr = ""
    local guild_post = nil
    local pre_guild_post = nil
    local honor_data = nil
    local pre_honor_data = nil
    for k,v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_hero_camp then
            if self.data.event == RoleEumn.Event.CanYon then 
                guild_post = CanYonEumn.CampNames[v.looks_val]..TI18N("代表队")
            else
                guild_post = HeroManager.Instance.campNames[v.looks_val]..TI18N("代表队")
            end
            break
        elseif v.looks_type == SceneConstData.looktype_honor then
            if v.looks_mode == 2 then
                honor_data = DataHonor.data_get_honor_list[v.looks_val]
                if honor_data ~= nil then
                    if honor_data.type == 6 then
                        -- guild_post = string.format("%s的%s", self.data.lover_name, honor_data.name)
                        guild_post = string.format(TI18N("%s的%s"), v.looks_str, honor_data.name)
                    elseif honor_data.type == 7 then -- 师徒
                        guild_post = string.format("%s%s", v.looks_str, honor_data.name)
                    elseif v.looks_str ~= nil and string.len(v.looks_str) > 0 then
                        guild_post = v.looks_str
                    else
                        guild_post = honor_data.name
                    end
                end
            end
        elseif v.looks_type == SceneConstData.looktype_pre_honor then
            pre_honor_data = DataHonor.data_get_pre_honor_list[v.looks_val]
            if pre_honor_data ~= nil then
                pre_guild_post = pre_honor_data.pre_name
            end
        end
    end
    if pre_guild_post ~= nil and guild_post ~= nil then
        local myStr = pre_guild_post .."·" .. guild_post
        guild_post = myStr
    end

    if guild_post ~= nil and string.len(guild_post) > 0 then
        if honor_data ~= nil and honor_data.type == 3
            and self.data.guild ~= nil and string.len(self.data.guild) > 0 then
            guildStr = string.format("%s%s", guildStr, self.data.guild)
            guildshadowStr = string.format("%s%s", guildshadowStr, self.data.guild)
        end

        guildStr = string.format("%s%s", guildStr, guild_post)
        guildshadowStr = string.format("%s%s", guildshadowStr, guild_post)
    end

    if guildStr ~= "" then
        self.guildname_object:GetComponent(TextMesh).text = guildStr
        self.guildname_object.gameObject:SetActive(true)
        self.guildnameshadow_object:GetComponent(TextMesh).text = guildshadowStr
        self.guildnameshadow_object.gameObject:SetActive(true)
    else
        self.guildname_object.gameObject:SetActive(false)
        self.guildnameshadow_object.gameObject:SetActive(false)
    end

    for k,v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_league_king then
            self.guildname_object:GetComponent(TextMesh).text = self.data.guild..TI18N("王牌")
            self.guildname_object.gameObject:SetActive(true)
            self.guildnameshadow_object:GetComponent(TextMesh).text = self.data.guild..TI18N("王牌")
            self.guildnameshadow_object.gameObject:SetActive(true)
        end
    end
    if guildStr == "" then
        self.rolename_object.transform.localPosition = self.guildname_object.transform.localPosition
        self.rolenameshadow_object.transform.localPosition = self.guildnameshadow_object.transform.localPosition
    else
        self.rolename_object.transform.localPosition = Vector3(self.guildname_object.transform.localPosition.x, self.guildname_object.transform.localPosition.y - 0.15, 0)
        self.rolenameshadow_object.transform.localPosition = Vector3(self.guildnameshadow_object.transform.localPosition.x, self.guildnameshadow_object.transform.localPosition.y - 0.15, 0)
    end
    self:ChangeZIndex(self.rolename_object)
    self:ChangeZIndex(self.rolenameshadow_object)
end

function RoleView:change_honor()
    if BaseUtils.isnull(self.honor_object) then
        return
    end

    self.honorid = nil
    local looks = self.data.looks
    for k,v in pairs(looks) do
        if v.looks_type == SceneConstData.looktype_honor then
            if v.looks_mode == 1 then
                self.honorid = v.looks_val
            end
        end
    end

    if self.honorid then
        self.honor_object.gameObject:SetActive(true)
        local spriterenderer = self.honor_object:GetComponent(SpriteRenderer)
        local honor_data = DataHonor.data_get_honor_list[self.honorid]
        spriterenderer.sprite = PreloadManager.Instance:GetSprite(AssetConfig.honor_img, tostring(honor_data.res_id))
    else
        self.honor_object.gameObject:SetActive(false)
    end

    self:update_top_object()

    self:change_guild_name()
end

function RoleView:change_ride()
    if self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
        if self.data.ride == SceneConstData.unitstate_walk then
            SceneManager.Instance.MainCamera:SetFly(false)
        elseif self.data.ride == SceneConstData.unitstate_fly then
            SceneManager.Instance.MainCamera:SetFly(true)
        elseif self.data.ride == SceneConstData.unitstate_ride then
            SceneManager.Instance.MainCamera:SetFly(false)
        end
    end

    if self.data.ride == SceneConstData.unitstate_walk then
        if self.lastAction == SceneConstData.UnitAction.FlyMove then
            self:PlayAction(SceneConstData.UnitAction.Move)
        else
            self:PlayAction(SceneConstData.UnitAction.Stand)
        end
    elseif self.data.ride == SceneConstData.unitstate_fly then
        if self.ride then return end -- looks 还保留在骑乘状态，没有飞行动作
        self.ride_fly = false
        if self.lastAction == SceneConstData.UnitAction.Move then
            self:PlayAction(SceneConstData.UnitAction.FlyMove)
        else
            self:PlayAction(SceneConstData.UnitAction.FlyStand)
        end
    elseif self.data.ride == SceneConstData.unitstate_ride then
        if self.lastAction == SceneConstData.UnitAction.Move then
            self:PlayAction(SceneConstData.UnitAction.Move)
        else
            self:PlayAction(SceneConstData.UnitAction.Stand)
        end
    end


    self:update_top_object()

    if self.transform_id ~= 0 and self.tpose ~= nil then
        if self.data.ride == SceneConstData.unitstate_walk then
            self.tpose.transform.localPosition = Vector3.zero
        elseif self.data.ride == SceneConstData.unitstate_fly then
            self.tpose.transform.localPosition = Vector3(0, 0.35, 0)
        elseif self.data.ride == SceneConstData.unitstate_ride then
            self.tpose.transform.localPosition = Vector3.zero
        end
    end

    if self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
        SceneManager.Instance.sceneElementsModel:setfollow()
    end
end

function RoleView:change_foot_mark()
    --暂时只显示自己的足迹
    if SceneManager.Instance.sceneElementsModel.self_unique == self.gameObject.name then
        RoleManager.Instance.foot_mark_id = self.data.foot_mark
        --local sourceid = AchievementManager.Instance.model:getFootSourceId(self.data.foot_mark)
        --SceneManager.Instance.sceneElementsModel:CreateFootMarks(self.gameObject.name, sourceid)
    end
end

function RoleView:change_team_leader_mark()
    if self.data.team_status == 1 then
        local mark = true
        if self.team_leader_effect_id == AchievementManager.Instance.model:getSourceId(self.data.team_mark) and self.team_leader_effect ~= nil then
            mark = false
        else
            self.team_leader_effect_id = AchievementManager.Instance.model:getSourceId(self.data.team_mark)
        end

        if mark then
            local callback = function(effect)
                if BaseUtils.is_null(self.gameObject) then
                    GameObject.Destroy(effect.gameObject)
                    return
                end

                effect.gameObject.transform:SetParent(self.gameObject.transform)
                effect.gameObject.transform.localRotation = Quaternion.identity
                effect.gameObject.transform:Rotate(Vector3(340, 0, 0))
                effect.gameObject.transform.localScale = Vector3 (1, 1, 1)
                Utils.ChangeLayersRecursively(effect.gameObject.transform, "Model")
                self.team_leader_effect = effect
                self:update_top_object()
            end

            if self.team_leader_effect ~= nil then
                self.team_leader_effect:DeleteMe()
                self.team_leader_effect = nil
            end

            self.team_leader_effect = BaseEffectView.New({ effectId = self.team_leader_effect_id, callback = callback })
        else
            self.team_leader_effect:SetActive(true)
        end
    elseif self.team_leader_effect ~= nil then
        self.team_leader_effect:SetActive(false)
    end
end

--显示头顶特效 1.自动寻路 特效20020 2.清除自动寻路 3.巡逻中 特效20099 4.清除逻中 5.护送中特效 20098 6.清除护送中特效 7.护送蛋糕特效 20188 8.清除护送蛋糕特效 9.特殊护送蛋糕特效 20189 10.清除特殊护送蛋糕特效
function RoleView:change_top_effect(top_effect_state)
    if (top_effect_state == 1 or top_effect_state == 3 or top_effect_state == 5 or top_effect_state == 7 or top_effect_state == 9) and self.gameObject ~= nil then
        if (self.top_effect_id == 20188 or self.top_effect_id == 20189) and top_effect_state ~= 7 and top_effect_state ~= 9 then -- 护送蛋糕特效等级高于其他特效，其他特效不可覆盖护送蛋糕
            return
        end

        self.top_effect_state = top_effect_state

        local mark = true
        if self.top_effect_state == 1 then
            if self.top_effect_id == 20020 and self.top_effect ~= nil then
                mark = false
            else
                self.top_effect_id = 20020
                if self.top_effect ~= nil and self.top_effect.gameObject ~= nil then GameObject.Destroy(self.top_effect.gameObject) end
            end
            -- self:set_movetoend_callback(true)
        elseif self.top_effect_state == 3 then
            if self.top_effect_id == 20099 and self.top_effect ~= nil then
                mark = false
            else
                self.top_effect_id = 20099
                if self.top_effect ~= nil and self.top_effect.gameObject ~= nil then GameObject.Destroy(self.top_effect.gameObject) end
            end
        elseif self.top_effect_state == 5 then
            if self.top_effect_id == 20098 and self.top_effect ~= nil then
                mark = false
            else
                self.top_effect_id = 20098
                if self.top_effect ~= nil and self.top_effect.gameObject ~= nil then GameObject.Destroy(self.top_effect.gameObject) end
            end
        elseif self.top_effect_state == 7 then
            if self.top_effect_id == 20188 and self.top_effect ~= nil then
                mark = false
            else
                self.top_effect_id = 20188
                if self.top_effect ~= nil and self.top_effect.gameObject ~= nil then GameObject.Destroy(self.top_effect.gameObject) end
            end
        elseif self.top_effect_state == 9 then
            if self.top_effect_id == 20189 and self.top_effect ~= nil then
                mark = false
            else
                self.top_effect_id = 20189
                if self.top_effect ~= nil and self.top_effect.gameObject ~= nil then GameObject.Destroy(self.top_effect.gameObject) end
            end
        end
        if mark then
            local callback = function(effect)
                if BaseUtils.is_null(self.gameObject) then
                    GameObject.Destroy(effect.gameObject)
                    return
                end
                effect.gameObject.transform:SetParent(self.gameObject.transform)
                effect.gameObject.transform.localRotation = Quaternion.identity
                effect.gameObject.transform.localScale = Vector3 (1, 1, 1)
                Utils.ChangeLayersRecursively(effect.gameObject.transform, "Model")

                if top_effect_state == 5 then
                    self.top_effect.transform.localScale = Vector3.one*1.5
                end

                self.top_effect = effect
                self:update_top_object()
            end

            if self.top_effect ~= nil then
                self.top_effect:DeleteMe()
                self.top_effect = nil
            end
            self.top_effect = BaseEffectView.New({ effectId = self.top_effect_id, callback = callback })
        else
            self.top_effect:SetActive(true)
        end
        self.top_effect_state = top_effect_state
    elseif self.top_effect ~= nil then
        if (self.top_effect_id == 20020 and top_effect_state == 2)
            or (self.top_effect_id == 20099 and top_effect_state == 4)
            or (self.top_effect_id == 20098 and top_effect_state == 6)
            or (self.top_effect_id == 20188 and top_effect_state == 8)
            or (self.top_effect_id == 20189 and top_effect_state == 10) then
            self.top_effect:SetActive(false)
            self:update_top_object()
        end
        self.top_effect_state = top_effect_state
    else
        self.top_effect_state = top_effect_state
    end
end

function RoleView:change_status_effect()
    if self.data.uniqueid == SceneManager.Instance.sceneElementsModel.self_unique then return end

    if (self.data.status == 2
        or self.data.event == RoleEumn.Event.AnimalChess
        or self.data.event == RoleEumn.Event.RushTopPlay
        or self.data.event == RoleEumn.Event.DragonChess
        )
        and not BaseUtils.is_null(self.gameObject) then
        self.status = self.data.status

        local mark = true
        if self.status == 2 then
            if self.status_effect_id == 10096 and self.status_effect ~= nil then
                mark = false
            else
                self.status_effect_id = 10096
            end
        elseif self.data.event == RoleEumn.Event.AnimalChess or self.data.event == RoleEumn.Event.DragonChess then        -- 小游戏
            if self.status_effect_id == 10195 and self.status_effect ~= nil then
                mark = false
            else
                self.status_effect_id = 10195
            end
        elseif self.data.event == RoleEumn.Event.RushTopPlay then        -- 冲顶大会答题
            if self.status_effect_id == 10257 and self.status_effect ~= nil then
                mark = false
            else
                self.status_effect_id = 10257
            end
        end

        if mark then
            local callback = function(effect)
                if BaseUtils.is_null(self.gameObject) then
                    GameObject.Destroy(effect.gameObject)
                    return
                end

                effect.gameObject.transform:SetParent(self.gameObject.transform)
                effect.gameObject.transform.localRotation = Quaternion.identity
                effect.gameObject.transform.localScale = Vector3 (1, 1, 1)
                Utils.ChangeLayersRecursively(effect.gameObject.transform, "Model")

                self.status_effect = effect
                self:update_top_object()
            end

            if self.status_effect ~= nil then
                self.status_effect:DeleteMe()
                self.status_effect = nil
            end

            self.status_effect = BaseEffectView.New({ effectId = self.status_effect_id, callback = callback })
        else
            self.status_effect:SetActive(true)
        end
    elseif self.status_effect ~= nil then
        self.status_effect:SetActive(false)
        self.status = self.data.status
    else
        self.status = self.data.status
    end
    self:loadRideEffect()
end

function RoleView:update_top_object()
    if BaseUtils.is_null(self.gameObject) then
        return
    end

    --坐骑模型太高
    local _h = 0
    for k, v in pairs(self.data.looks) do
        if v.looks_type == SceneConstData.looktype_ride then 
            local ride_base_id = v.looks_val
            if DataMount.data_ride_data[ride_base_id] ~= nil then 
                _h = DataMount.data_ride_data[ride_base_id].scale / 100
            end
            break
        end
    end

    local h = 0
    if self.data.ride == SceneConstData.unitstate_walk then
        h = 0.9 * self.scale
    elseif self.data.ride == SceneConstData.unitstate_fly then
        if self.ride_fly then
            h = (1.55 / _h) * self.scale
        else    
            h = 1.15 * self.scale 
        end
    elseif self.data.ride == SceneConstData.unitstate_ride then
        h = (1.15 / _h) * self.scale
    end

    if self.honorid then
        self.honor_object.transform.localPosition = Vector3 (0, h, 0)
        h = h + 0.2 * self.scale
    end
    if self.team_leader_effect ~= nil and self.team_leader_effect.gameObject ~= nil then
        self.team_leader_effect.gameObject.transform.localPosition = Vector3 (0, h, -2)
        h = h + 0.2 * self.scale
    end
    if self.status_effect ~= nil and self.status_effect.gameObject ~= nil then
        self.status_effect.gameObject.transform.localPosition = Vector3 (0, h, 0)
        h = h + 0.2 * self.scale
    end
    if self.top_effect ~= nil and self.top_effect.gameObject ~= nil then
        self.top_effect.gameObject.transform.localPosition = Vector3 (0, h, 0)
        h = h + 0.2 * self.scale
    end
end

function RoleView:ChangeEvent(event, oldEvent)
    if BaseUtils.is_null(self.gameObject) then
        return
    end
    if oldEvent ~= RoleEumn.Event.Halloween_sub and event == RoleEumn.Event.Halloween_sub then
        self.canMove = false
        self:play_action(SceneConstData.UnitAction.Dead, nil, true)
        -- self.animator:Play(SceneConstData.genanimationname("Dead", self.animationData.dead_id))

        if self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique then
            EventMgr.Instance:Fire(event_name.halloween_self_dead_tips)
        end

        if self.die_effect == nil then
            local callback = function(effect)
                if BaseUtils.is_null(self.gameObject) then
                    GameObject.Destroy(effect.gameObject)
                    return
                end

                effect.gameObject.transform:SetParent(self.gameObject.transform)
                effect.gameObject.transform.localPosition = Vector3 (0, 0, -20)
                effect.gameObject.transform.localRotation = Quaternion.identity
                effect.gameObject.transform.localScale = Vector3 (1, 1, 1)
                Utils.ChangeLayersRecursively(effect.gameObject.transform, "Model")

                self.die_effect = effect

                local fun = function()
                    if not BaseUtils.is_null(self.die_effect) then
                        self.die_effect:SetActive(false)
                    end
                end
                LuaTimer.Add(1500, fun)
            end

            if self.die_effect ~= nil then
                self.die_effect:DeleteMe()
                self.die_effect = nil
            end

            self.die_effect = BaseEffectView.New({ effectId = 16236, callback = callback })
        else
            self.die_effect:SetActive(false)
            self.die_effect:SetActive(true)

            local fun = function()
                if not BaseUtils.is_null(self.die_effect) then
                    self.die_effect:SetActive(false)
                end
            end
            LuaTimer.Add(1500, fun)
        end

        -- SceneTalk.Instance:ShowTalk_Player(self.data.roleid, self.data.zoneid, self.data.platform, "{face_1, 11}", 3)
    else
        self.canMove = true
        if oldEvent == RoleEumn.Event.Halloween_sub or oldEvent == RoleEumn.Event.Halloween then
            self:change_name()
        end
    end
end

function RoleView:subpackageCompleted()
    SubpackageManager.Instance.OnCompletedEvent:Remove(self._subpackageCompleted)
    self:ChangeLook()
end

function RoleView:objPool_push()
    if self.controller ~= nil and not BaseUtils.is_null(self.tpose) then
        self.controller:SetAlphaChlid(self.tpose.transform, 1)
    end
    if self.ride then
        if self.ridePoolData ~= nil then
            if self.ridePoolData.ridePath ~= nil then
                GoPoolManager.Instance:Return(self.tpose, self.ridePoolData.ridePath, GoPoolType.Ride)
                self.tpose = nil

                if not BaseUtils.is_null(self.rideEffectObject) then
                    GameObject.Destroy(self.rideEffectObject)
                    self.rideEffectObject = nil
                    self:IsShowEffect()
                end
            end
        end
        if self.poolData ~= nil then
            if self.poolData.modelPath ~= nil then
                if not BaseUtils.is_null(self.tpose) then
                    self.tpose.transform.localScale = Vector3.one
                end
                GoPoolManager.Instance:Return(self.roleTpose, self.poolData.modelPath, GoPoolType.Role)
                self.tpose = nil
            end
            if self.poolData.headPath ~= nil then
                if not BaseUtils.is_null(self.headTpose) then
                    self.headTpose.transform.localScale = Vector3.one
                end
                GoPoolManager.Instance:Return(self.headTpose, self.poolData.headPath, GoPoolType.Head)
                self.headTpose = nil
            end
        end

        if self.poolData2 ~= nil then
            if self.poolData2.modelPath ~= nil then
                if not BaseUtils.is_null(self.roleTpose2) then
                    self.roleTpose2.transform.localScale = Vector3.one
                end
                GoPoolManager.Instance:Return(self.roleTpose2, self.poolData2.modelPath, GoPoolType.Role)
                self.roleTpose2 = nil
            end
            if self.poolData2.headPath ~= nil then
                if not BaseUtils.is_null(self.headTpose2) then
                    self.headTpose2.transform.localScale = Vector3.one
                end
                GoPoolManager.Instance:Return(self.headTpose2, self.poolData2.headPath, GoPoolType.Head)
                self.headTpose2 = nil
            end
        end
    else
        if self.poolData ~= nil then
            if self.poolData.modelPath ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.tpose, self.poolData.modelPath)
                if not BaseUtils.isnull(self.tpose) then
                    self.tpose.transform.localScale = Vector3.one
                end
                GoPoolManager.Instance:Return(self.tpose, self.poolData.modelPath, GoPoolType.Role)
                self.tpose = nil
            end
            if self.poolData.headPath ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.headTpose, self.poolData.headPath)
                if not BaseUtils.isnull(self.headTpose) then
                    self.headTpose.transform.localScale = Vector3.one
                end
                GoPoolManager.Instance:Return(self.headTpose, self.poolData.headPath, GoPoolType.Head)
                self.headTpose = nil
            end
        end
    end

    if self.weaponPoolData ~= nil then
        if self.weaponPoolData.weaponPath ~= nil then
            if self.weapon ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.weapon, self.weaponPoolData.weaponPath)
                GoPoolManager.Instance:Return(self.weapon, self.weaponPoolData.weaponPath, GoPoolType.Weapon)
            end
            if self.weapon2 ~= nil then
                if self.isOtherWeapon == true then
                    GoPoolManager.Instance:Return(self.weapon2, self.weaponPoolData.weaponPath2, GoPoolType.Weapon)
                else
                    GameObject.Destroy(self.weapon2)
                end
                -- CombatManager.Instance.objPool:PushUnit(self.weapon2, self.weaponPoolData.weaponPath)
                -- GoPoolManager.Instance:Return(self.weapon2, self.weaponPoolData.weaponPath, GoPoolType.Weapon)

            end
            if self.weaponPoolData.weaponEffectPath ~= nil then
                if self.weaponPoolData.weaponEffect ~= nil then
                    -- CombatManager.Instance.objPool:PushUnit(self.weaponPoolData.weaponEffect, self.weaponPoolData.weaponEffectPath)
                    GoPoolManager.Instance:Return(self.weaponPoolData.weaponEffect, self.weaponPoolData.weaponEffectPath, GoPoolType.Effect)
                end
                if self.weaponPoolData.weaponEffect2 ~= nil then
                    if self.weaponPoolData.weaponEffectPath2 == nil then
                        GoPoolManager.Instance:Return(self.weaponPoolData.weaponEffect2, self.weaponPoolData.weaponEffectPath, GoPoolType.Effect)
                    else
                        GoPoolManager.Instance:Return(self.weaponPoolData.weaponEffect2, self.weaponPoolData.weaponEffectPath2, GoPoolType.Effect)
                    end
                end
            end
        end
    end

    if self.wingPoolData ~= nil then
        if self.wingPoolData.modelPath ~= nil then
            if self.wing ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.wing, self.wingPoolData.modelPath)
                GoPoolManager.Instance:Return(self.wing, self.wingPoolData.modelPath, GoPoolType.Wing)
                self.wing = nil
            end
        end
    elseif self.wing ~= nil then
        GameObject.Destroy(self.wing)
        self.wing = nil
    end

    if self.beltPoolData ~= nil then
        if self.beltPoolData.modelPath ~= nil then
            if self.belt ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.belt, self.beltPoolData.modelPath)
                GoPoolManager.Instance:Return(self.belt, self.beltPoolData.modelPath, GoPoolType.Surbase)
                self.belt = nil
                if self.beltPoolData.effectPath ~= nil then
                    -- CombatManager.Instance.objPool:PushUnit(self.beltPoolData.effect, self.beltPoolData.effectPath)
                    GoPoolManager.Instance:Return(self.beltPoolData.effect, self.beltPoolData.effectPath, GoPoolType.Effect)
                end
            end
        end
    elseif self.belt ~= nil then
        GameObject.Destroy(self.belt)
        self.belt = nil
    end

    if self.headsurbasePoolData ~= nil then
        if self.headsurbasePoolData.modelPath ~= nil then
            if self.headsurbase ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.headsurbase, self.headsurbasePoolData.modelPath)
                GoPoolManager.Instance:Return(self.headsurbase, self.headsurbasePoolData.modelPath, GoPoolType.Surbase)
                self.headsurbase = nil
                if self.headsurbasePoolData.effectPath ~= nil then
                    -- CombatManager.Instance.objPool:PushUnit(self.headsurbasePoolData.effect, self.headsurbasePoolData.effectPath)
                    GoPoolManager.Instance:Return(self.headsurbasePoolData.effect, self.headsurbasePoolData.effectPath, GoPoolType.Effect)
                end
            end
        end
    elseif self.headsurbase ~= nil then
        GameObject.Destroy(self.headsurbase)
        self.headsurbase = nil
    end

    if self.headsurbasePoolData2 ~= nil then
        if self.headsurbasePoolData2.modelPath ~= nil then
            if self.headsurbase2 ~= nil then
                -- CombatManager.Instance.objPool:PushUnit(self.headsurbase, self.headsurbasePoolData.modelPath)
                GoPoolManager.Instance:Return(self.headsurbase2, self.headsurbasePoolData2.modelPath, GoPoolType.Surbase)
                self.headsurbase2 = nil
                if self.headsurbasePoolData2.effectPath ~= nil then
                    -- CombatManager.Instance.objPool:PushUnit(self.headsurbasePoolData.effect, self.headsurbasePoolData.effectPath)
                    GoPoolManager.Instance:Return(self.headsurbasePoolData2.effect, self.headsurbasePoolData2.effectPath, GoPoolType.Effect)
                end
            end
        end
    elseif self.headsurbase2 ~= nil then
        GameObject.Destroy(self.headsurbase2)
        self.headsurbase2 = nil
    end

    self.poolData = nil
    self.weaponPoolData = nil
    self.wingPoolData = nil
    self.beltPoolData = nil
    self.headsurbasePoolData = nil

    if self.tweenTposeId ~= nil then
        Tween.Instance:Cancel(self.tweenTposeId)
        self.tweenTposeId = nil
    end
end

function RoleView:ChangeZIndex(textRect, zindex)
    if textRect == nil then
        return
    end
    local pos = textRect.localPosition
    if zindex == nil then
        textRect.localPosition = Vector3(pos.x, pos.y, 10)
    else
        textRect.localPosition = Vector3(pos.x, pos.y, zindex)
    end
end

function RoleView:SetActive(active, hard)
    if self.active ~= active or hard then
        self.active = active
        if not BaseUtils.is_null(self.gameObject) then
            self.gameObject:SetActive(self.active)
            if self.active then
                self:PlayAction(self.lastAction)
                if self.data.ride == SceneConstData.unitstate_ride or (self.data.ride == SceneConstData.unitstate_fly and self.ride_fly) then
                    local looks_ride
                    for k, v in pairs(self.data.looks) do
                        if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
                            looks_ride = v.looks_val
                        end
                    end
                    local looksData = DataMount.data_ride_data[looks_ride]
                    if self.tposeAnimator ~= nil and self.roleAnimationData ~= nil then
                        if looksData then
                            local action_type = looksData.action_type_male
                            if self.data.sex == 0 then
                                action_type = looksData.action_type_female
                            end
                            if action_type == 2 or action_type == 3 then
                                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id2))
                            elseif action_type == 4 then
                                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id3))
                            elseif action_type == 5 then
                                if RoleManager.Instance.RoleData.sex == 0 then
                                    self.tposeAnimator:Play(SceneConstData.genanimationname("Stand", 6))
                                else
                                    self.tposeAnimator:Play(SceneConstData.genanimationname("Stand", 1))
                                end
                            elseif action_type == 6 then
                                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", 5))
                            elseif action_type == 7 then
                                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id5))
                            else
                                self.tposeAnimator:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData.ridestand_id))
                            end
                        else
                            Log.Debug(string.format("<color='#00ff00'>mount_data 这个坐骑数据没有啊 %s</color>", looks_ride))
                        end
                    end
                    if self.tposeAnimator2 ~= nil and self.roleAnimationData2 ~= nil then
                        if looksData then
                            local action_type = looksData.action_type_male
                            if self.data.sex == 0 then
                                action_type = looksData.action_type_female
                            end
                            if action_type == 2 or action_type == 3 then
                                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id2))
                            elseif action_type == 4 then
                                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id3))
                            elseif action_type == 5 then
                                if RoleManager.Instance.RoleData.sex == 0 then
                                    self.tposeAnimator2:Play(SceneConstData.genanimationname("Stand", 6))
                                else
                                    self.tposeAnimator2:Play(SceneConstData.genanimationname("Stand", 1))
                                end
                            elseif action_type == 6 then
                                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", 5))
                            elseif action_type == 7 then
                                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id6))
                            else
                                self.tposeAnimator2:Play(SceneConstData.genanimationname("Sit", self.roleAnimationData2.ridestand_id))
                            end
                        end
                    end
                end
            end
        end
    end
end

function RoleView:GetShowRide()
    return self.gameObject.name == SceneManager.Instance.sceneElementsModel.self_unique
        or (self.gameObject.name ~= SceneManager.Instance.sceneElementsModel.self_unique and (SceneManager.Instance.sceneElementsModel.Show_OtherRole_Ride_Mark or TeamManager.Instance:IsInMyTeam(self.gameObject.name)))
end

function RoleView:ShowCollectStatusEffect(old)
    self.collectstatus = 1
    if self.gameObject ~= nil then
        local callback = function(ev)
            if BaseUtils.isnull(self.gameObject) then
                return
            end
            self:PlayAction(SceneConstData.UnitAction.Pick)
            ev.transform:SetParent(self.gameObject.transform)
            ev.transform.localScale = Vector3.one
            ev.transform.localPosition = Vector3(0, 0.8, -2.5)
            ev.transform.localRotation = Quaternion.identity
            -- ev.transform:Rotate(Vector3(0, 270, 0))
            Utils.ChangeLayersRecursively(ev.transform, "Model")
            if self.clearTimer ~= nil and old ~= true then
                LuaTimer.Delete(self.clearTimer)
                self.clearTimer = nil
            end
            self.clearTimer = LuaTimer.Add(20000,function()
                self:ClearCollectStatusEffect()
            end)
        end
        local pos = self.gameObject.transform.position
        if RoleManager.Instance.RoleData.event == 32 and Vector2.Distance(Vector2(pos.x, pos.y), GuildLeagueManager.Instance.CannonPosition) <= 2 then
            self.collectstatusEffect = BaseEffectView.New({ effectId = 10139, callback = callback })
        else
            self.collectstatusEffect = BaseEffectView.New({ effectId = 10138, callback = callback })
        end
    end
end
-- 清除采集状态特效
function RoleView:ClearCollectStatusEffect()
    if self.clearTimer ~= nil then
        LuaTimer.Delete(self.clearTimer)
        self.clearTimer = nil
    end
    self:PlayAction(SceneConstData.UnitAction.Idle)
    self.collectstatus = 0
    if self.collectstatusEffect ~= nil then
        self.collectstatusEffect:DeleteMe()
        self.collectstatusEffect = nil
    end
end

-- changelook 开始计时，10秒后清除changelook锁
function RoleView:StartChangeLookMarkTimer()
    self:ClearChangeLookMarkTimer()
    self.ChangeLook_Mark_Timer = LuaTimer.Add(10000, self._CancelChangeLookMark)
end

-- 10秒计时到了，解开changelook锁
function RoleView:CancelChangeLookMark()
    self.ChangeLook_Mark = false
    self:ClearChangeLookMarkTimer()
    if self.ChangeLook_Cache then
        self.ChangeLook_Cache = false
        self:ChangeLook()
        return
    end
end

-- changelook 取消计时
function RoleView:ClearChangeLookMarkTimer()
    if self.ChangeLook_Mark_Timer ~= nil then
        LuaTimer.Delete(self.ChangeLook_Mark_Timer)
        self.ChangeLook_Mark_Timer = nil
    end
end

function RoleView:LoadHalo(effectId)
    if self.halo ~= nil then
        return
    end

    local effectData = DataEffect.data_effect[effectId]
    if effectData == nil then
        print(string.format("effect_data 这个特效id数据没有啊 %s", effectId))
        return
    end

    local callback = function(effect)
        if not BaseUtils.is_null(self.gameObject) then
            effect.transform:SetParent(self.gameObject.transform)
            effect.transform.localScale = Vector3.one
            effect.transform.localPosition = Vector3.zero
            effect.transform.localRotation = Quaternion.identity
            effect.transform:Rotate(Vector3(-20, 0, 0))
            Utils.ChangeLayersRecursively(effect.transform, "Model")
            effect:SetActive(true)
        else
            GameObject.DestroyImmediate(effect.gameObject)
            effect.gameObject = nil
        end
    end
    self.halo = BaseEffectView.New({effectId = effectData.res_id, callback = callback})
end

function RoleView:ClearHalo()
    if self.halo ~= nil then
        self.halo:DeleteMe()
        self.halo = nil
    end
end
