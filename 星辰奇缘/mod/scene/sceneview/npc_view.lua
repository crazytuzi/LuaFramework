NpcView = NpcView or BaseClass(UnitView)

local GameObject = UnityEngine.GameObject
local Vector3 = UnityEngine.Vector3

function NpcView:__init(data)
    self.baseData = nil

    -- 开始加载单位，计数加1
    SceneManager.Instance.sceneElementsModel:AddCreateCount()
end

function NpcView:__delete()
    -- print(string.format("npc被删除了 %s", self.data.uniqueid))
    self:objPool_push()

    local baseData = DataUnit.data_unit[self.data.baseid]
    local data = self.data
    if data.unittype == SceneConstData.unittype_teleporter or data.unittype == SceneConstData.unittype_fun_teleporter then
    elseif data.unittype == SceneConstData.unittype_exquisite_shelf then
    elseif data.unittype == SceneConstData.unittype_sceneeffect or data.unittype == SceneConstData.unittype_trialeffect then
    elseif data.unittype == SceneConstData.unittype_pet then
    elseif data.unittype == SceneConstData.unittype_taskcollection_effect then
    else
        local self_view = SceneManager.Instance.sceneElementsModel.self_view
        if self_view ~= nil and self_view.controller ~= nil and self_view.controller.TriggerUnit == self.gameObject then
            self_view.controller.TriggerUnit = nil
        end

        if self.data.classes == nil or self.data.sex == nil or self.data.classes == 0 then
            -- CombatManager.Instance.objPool:PushUnit(self.gameObject, "npc_obj")
            if self.data.noShadow and self.shadow ~= nil then
                self.shadow:SetActive(true)
                self.shadow = nil
            end
            self:SetGuildNameColor(ColorHelper.colorObjectScene[12])
            GoPoolManager.Instance:Return(self.gameObject, "npc_obj", GoPoolType.BoundNpc)
            self.gameObject = nil
        end
    end
end

function NpcView:Create()
    local baseData = BaseUtils.copytab(DataUnit.data_unit[self.data.baseid])
    local data = self.data
    self.baseData = baseData
    if data.extData ~= nil then
        for k,v in pairs(data.extData) do
            -- print("--------------------------------------")
            -- print(k)
            self.baseData[k] = v
        end
    end

    -- print(string.format("get_unique_npcid %s %s", self.data.id, self.data.battleid))

    if data.unittype == SceneConstData.unittype_teleporter or data.unittype == SceneConstData.unittype_fun_teleporter then
        if self.baseData == nil then return end

        self:build_teleporter()
        local effectId = baseData.res
        self.build_teleporter_effect_closure = function()
            self:build_teleporter_effect()
        end

        local resList = {
            {file = string.format("prefabs/effect/%s.unity3d", effectId), type = AssetType.Main}
        }
        self:LoadAssetBundleBatch(resList, self.build_teleporter_effect_closure)
    elseif data.unittype == SceneConstData.unittype_exquisite_shelf then
        if self.baseData == nil then return end

        self:build_teleporter()
        local effectId = baseData.res
        self.build_teleporter_effect_closure = function()
            self:build_teleporter_effect()
        end

        local resList = {
            {file = string.format("prefabs/effect/%s.unity3d", effectId), type = AssetType.Main}
        }
        self:LoadAssetBundleBatch(resList, self.build_teleporter_effect_closure)
    elseif data.unittype == SceneConstData.unittype_sceneeffect or data.unittype == SceneConstData.unittype_trialeffect then
        if self.baseData == nil then return end

        local effectId = baseData.res

        self.build_effect_closure = function()
            self:build_effect()
        end

        self.build_effect_path = string.format("prefabs/effect/%s.unity3d", effectId)
        local resList = {
            {file = self.build_effect_path, type = AssetType.Main}
        }
        self:LoadAssetBundleBatch(resList, self.build_effect_closure)
    elseif data.unittype == SceneConstData.unittype_pet then
        self:build_Pet()
    elseif data.unittype == SceneConstData.unittype_taskcollection_effect then
        self:build_EffectNpc() -- 没有模型，只有特效的npc
    else
        if self.baseData == nil then return end

        self:build_Npc()
    end
end

function NpcView:build_teleporter()
    self.gameObject = GameObject.Instantiate(SceneManager.Instance.sceneElementsModel.instantiate_object_teleporter)
    self.gameObject.transform:SetParent(SceneManager.Instance.sceneModel.sceneView.gameObject.transform)
    self.gameObject.name = self.data.uniqueid
    self.controller = self.gameObject:AddComponent(UnitController)

    self.rolename_object = self.gameObject.transform:FindChild("RoleName")
    self.rolenameshadow_object = self.gameObject.transform:FindChild("RoleNameShadow")

    -- self:facetoindex(data_unit.data_unit[self.data.baseid].forward)
    self:JumpTo_by_big_pos(self.data.x, self.data.y)
    Utils.ChangeLayersRecursively(self.gameObject.transform, "Model")
    self:change_name()
end

function NpcView:build_teleporter_effect()
    if self.gameObject == nil then return end

    local effectId = self.baseData.res
    local prefab = self:GetPrefab(string.format("prefabs/effect/%s.unity3d", effectId))
    if prefab == nil then
        Log.Debug(string.format("id为%s的传送门创建失败", effectId))
        return
    end
    local effect = GameObject.Instantiate(prefab)
    effect.transform:SetParent(self.gameObject.transform:FindChild("Effect"))

    effect.transform.localPosition = Vector3.zero
    effect.transform.localRotation = Quaternion.identity

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateCount()
end

function NpcView:build_effect()
    local effect_data = self.baseData
    local prefab = self:GetPrefab(self.build_effect_path)
    if BaseUtils.isnull(prefab) then
        Log.Debug(string.format("id为%s的特效单位创建失败", self.build_effect_path))
        return
    end
    self.gameObject = GameObject.Instantiate(prefab)
    self.gameObject.transform:SetParent(SceneManager.Instance.sceneElementsModel.scene_elements.transform)
    self.gameObject.name = self.data.uniqueid

    self:JumpTo_by_big_pos(self.data.x, self.data.y)

    self.gameObject.transform.localRotation = Quaternion.identity
    -- self.gameObject.transform:Rotate(Vector(-20, 0, 0))
    self.gameObject.transform:Rotate(Vector3(0, SceneConstData.UnitFaceToIndex[effect_data.forward + 1], 0))
    Utils.ChangeLayersRecursively(self.gameObject.transform, "SceneEffect")

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateCount()
end

function NpcView:build_Npc()
    -- self.gameObject = CombatManager.Instance.objPool:PopUnit("npc_obj")
    self.gameObject = GoPoolManager.Instance:Borrow("npc_obj", GoPoolType.BoundNpc)
    if self.gameObject ~= nil then
        local oldTpose = self.gameObject.transform:FindChild("tpose")
        if oldTpose ~= nil then
            GameObject.Destroy(oldTpose.gameObject)
        end

        local controller = self.gameObject:GetComponent(UnitController)
        if controller ~= nil then
            GameObject.Destroy(controller)
        end
    else
        self.gameObject = GameObject.Instantiate(SceneManager.Instance.sceneElementsModel.instantiate_object_npc)
    end

    local gameObject = self.gameObject
    Utils.ChangeLayersRecursively(gameObject.transform, "Model")
    gameObject.transform:SetParent(SceneManager.Instance.sceneElementsModel.scene_elements.transform)
    gameObject.name = self.data.uniqueid

    self.shadow = gameObject.transform:FindChild("Shadow").gameObject
    if self.data.noShadow then self.shadow:SetActive(false) end

    self.rolename_object = gameObject.transform:FindChild("RoleName")
    self.rolenameshadow_object = gameObject.transform:FindChild("RoleNameShadow")
    self.guildname_object = gameObject.transform:FindChild("GuildName")
    self.guildnameshadow_object = gameObject.transform:FindChild("GuildNameShadow")

    self.honor_object = gameObject.transform:FindChild("Honor")
    self.state_object = gameObject.transform:FindChild("State")

    self.controller = gameObject:AddComponent(UnitController)
    self.Speed = self.data.speed * SceneManager.Instance.sceneModel.mapsizeconvertvalue
    -- self.role_controller:FaceTo_LuaNow(SceneConstData.UnitFaceToIndex[self.data.dir+1])

    -- local p = SceneManager.Instance.sceneModel:transport_small_pos(self.data.x, SceneManager.Instance.sceneModel:get_py_big(self.data.y))
    self:JumpTo_by_big_pos(self.data.x, self.data.y)
    -- self:change_unitstate(self.data.state)

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateCount()

    self:change_name()
    self:change_guild_name()
    self:change_honor()
    self:ChangeLook()
    self:change_status_effect()
    -- self:change_team_leader_mark(self.data.team_leader)

    if self.data.canIdle == nil then -- npc没有填写canIdle数据的统一配置为true
        if self.data.unittype ~= SceneConstData.unittype_taskcollection and self.data.unittype ~= SceneConstData.unittype_collection and self.data.unittype ~= SceneConstData.unittype_pick and self.data.unittype ~= SceneConstData.unittype_taskcollection_effect then
            self.data.canIdle = true
        end
    end

    self:ChangeZIndex(self.rolename_object)
    self:ChangeZIndex(self.rolenameshadow_object)
    self:ChangeZIndex(self.guildname_object)
    self:ChangeZIndex(self.guildnameshadow_object)
    self:ChangeZIndex(gameObject.transform:FindChild("Shadow"), 21)
    self:ChangeZIndex(self.honor_object, -8)
end

function NpcView:build_Pet()
    self.gameObject = GameObject.Instantiate(SceneManager.Instance.sceneElementsModel.instantiate_object_npc)

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

    self.honor_object = gameObject.transform:FindChild("Honor")
    self.state_object = gameObject.transform:FindChild("State")

    self.controller = gameObject:AddComponent(UnitController)
    self.Speed = self.data.speed * SceneManager.Instance.sceneModel.mapsizeconvertvalue

    self:JumpTo_by_big_pos(self.data.x, self.data.y)
    -- self:change_unitstate(self.data.state)

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateCount()

    self.baseData = BaseUtils.copytab(self.data)

    local petdata = self.data
    self.baseData.skin = petdata.base.skin_id_0
    self.baseData.res = petdata.base.model_id
    if petdata.genre ~= 1 then
        if petdata.grade == 0 then
            self.baseData.res = petdata.base.model_id
            self.baseData.skin = petdata.base.skin_id_0
        elseif petdata.grade == 1 then
            self.baseData.res = petdata.base.model_id1
            self.baseData.skin = petdata.base.skin_id_1
        elseif petdata.grade == 2 then
            self.baseData.res = petdata.base.model_id2
            self.baseData.skin = petdata.base.skin_id_2
        elseif petdata.grade == 3 then
            self.baseData.res = petdata.base.model_id3
            self.baseData.skin = petdata.base.skin_id_3
        end
    else
        if petdata.grade == 0 then
            self.baseData.res = petdata.base.model_id
            self.baseData.skin = petdata.base.skin_id_s0
        elseif petdata.grade == 1 then
            self.baseData.res = petdata.base.model_id1
            self.baseData.skin = petdata.base.skin_id_s1
        elseif petdata.grade == 2 then
            self.baseData.res = petdata.base.model_id2
            self.baseData.skin = petdata.base.skin_id_s2
        elseif petdata.grade == 3 then
            self.baseData.res = petdata.base.model_id3
            self.baseData.skin = petdata.base.skin_id_s3
        end
    end
    
    if petdata.use_skin ~= 0 then
        self.baseData.skin = petdata.use_skin

        for key, value in pairs(DataPet.data_pet_skin) do
            if petdata.base.id == value.id and petdata.use_skin == value.skin_id then
                self.baseData.res = value.model_id
                self.baseData.effects = value.effects
            end
        end
    end

    -- self.baseData.res = petdata.base.model_id
    self.baseData.animation_id = petdata.base.animation_id
    self.baseData.scale = petdata.base.scale
    --处理宠物幻化 jia
    local transList = petdata.unreal;
    local isOpen = false;
    if transList ~= nil and #transList > 0 and DataPet.data_pet_trans_black[petdata.base_id] == nil then
        isOpen = true
    end
    if isOpen and petdata.unreal_looks_flag == 0 then
        local taransData = transList[1];
        local itemID = taransData.item_id
        local endTime = taransData.timeout
        if endTime > BaseUtils.BASE_TIME then
            local transTmp = DataPet.data_pet_trans[itemID];
            if transTmp ~= nil then
                local transFTmp = DataTransform.data_transform[transTmp.skin_id];
                if transFTmp ~= nil then
                    self.baseData.res = transFTmp.res
                    self.baseData.skin = transFTmp.skin
                    self.baseData.animation_id = transFTmp.animation_id
                    self.baseData.effects = transFTmp.effects
                    self.baseData.scale = transFTmp.scale 
                end
            end
        end
    end
    self.baseData.name = petdata.name
    self.baseData.honor_text = ""
    self.baseData.collider = { {val = 0}, {val = 0}, {val = 0}, {val = 0}, {val = 0}, {val = 0} }

    self:change_name()
    self:change_guild_name()
    self:ChangeLook()

    local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    sceneElementsModel.self_pet_view = self
    sceneElementsModel.FollowUnit_List = {self}
    self.gameObject:SetActive(sceneElementsModel.Show_Self_Pet_Mark)

    self:ChangeZIndex(self.rolename_object)
    self:ChangeZIndex(self.rolenameshadow_object)
    self:ChangeZIndex(self.guildname_object)
    self:ChangeZIndex(self.guildnameshadow_object)
    self:ChangeZIndex(gameObject.transform:FindChild("Shadow"), 21)

    self:ChangeZIndex(self.honor_object, -8)
end

function NpcView:build_EffectNpc()
    self.gameObject = GameObject.Instantiate(SceneManager.Instance.sceneElementsModel.instantiate_object_npc)

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

    self.honor_object = gameObject.transform:FindChild("Honor")
    self.state_object = gameObject.transform:FindChild("State")

    self.controller = gameObject:AddComponent(UnitController)
    self.Speed = self.data.speed * SceneManager.Instance.sceneModel.mapsizeconvertvalue

    self:JumpTo_by_big_pos(self.data.x, self.data.y)

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateCount()

    self:change_name()
    self:change_guild_name()
    self:change_honor()

    self.data.canIdle = false -- 这玩意没有模型，强制改为 canIdle = false

    local effectId = self.baseData.res
    local fun = function()
        local instantiateObject = self:GetPrefab(string.format("prefabs/effect/%s.unity3d", effectId))
        if BaseUtils.is_null(instantiateObject) then return end
        self.effectObject = GameObject.Instantiate(instantiateObject)
        self.effectObject.transform:SetParent(self.gameObject.transform)
        self.effectObject.transform.localPosition = Vector3(0, 0, 0)

        self.effectObject.transform.localRotation = Quaternion.identity
        self.effectObject.transform:Rotate(Vector3(-20, 0, 0))
        self.effectObject.transform:Rotate(Vector3(0, SceneConstData.UnitFaceToIndex[self.baseData.forward + 1], 0))
        Utils.ChangeLayersRecursively(self.gameObject.transform, "Model")
    end

    local resList = {
        {file = string.format("prefabs/effect/%s.unity3d", effectId), type = AssetType.Main}
    }
    self:LoadAssetBundleBatch(resList, fun)

    self:ChangeZIndex(self.rolename_object)
    self:ChangeZIndex(self.rolenameshadow_object)
    self:ChangeZIndex(self.guildname_object)
    self:ChangeZIndex(self.guildnameshadow_object)
    self:ChangeZIndex(gameObject.transform:FindChild("Shadow"), 21)
    self:ChangeZIndex(self.honor_object, -8)
end

function NpcView:ChangeLook()
    if self.ChangeLook_Mark then
        self.ChangeLook_Cache = true
        return
    end

    SceneManager.Instance.sceneElementsModel:AddCreateCount()
    -- local sceneElementsModel = SceneManager.Instance.sceneElementsModel
    -- -- 开始加载模型，计数加1
    -- if sceneElementsModel.createTposeCount < sceneElementsModel.createTposeCount_Max or self.data.unittype == SceneConstData.unittype_pet then
    --     sceneElementsModel:AddCreateTposeCount()
    --     self.CreateTpose_Mark = false
    -- else
    --     self.CreateTpose_Mark = true
    --     return
    -- end

    if self.data.classes == nil or self.data.sex == nil or self.data.classes == 0 then
        local callback = function(tpose, animationData, poolData) self:TposeComplete(tpose, animationData, nil, nil, poolData) end
        NpcTposeLoader.New(self.baseData.skin, self.baseData.res, self.baseData.animation_id, self.baseData.scale / 100, callback)
    else
        self.scale = self.baseData.scale / 100

        local rideMark = false
        for _,value in ipairs(self.data.looks) do
            if value.looks_type == SceneConstData.looktype_ride then -- 坐骑
                rideMark = true
            end
        end
        if rideMark then
            local callback = function(tpose, animationData, headTpose, headAnimationData, bodyTopse, bodyAnimationData) self:TposeComplete(tpose, animationData, headTpose, headAnimationData, nil, bodyTopse, bodyAnimationData) end
            MixRoleRideLoader.New(self.data.classes, self.data.sex, self.data.looks, callback, false, "Model")
        else
            local callback = function(tpose, animationData, headTpose, headAnimationData) self:TposeComplete(tpose, animationData, headTpose, headAnimationData) end
            MixRoleWingLoader.New(self.data.classes, self.data.sex, self.data.looks, callback, false, "Model")
        end
    end
end

function NpcView:TposeComplete(tpose, animationData, headTpose, headAnimationData, poolData, bodyTopse, bodyAnimationData)
    if self.gameObject == nil then
        if tpose ~= nil then GameObject.Destroy(tpose) end
        if headTpose ~= nil then GameObject.Destroy(headTpose) end
        return
    end

    self.animationData = animationData
    self.headTpose = headTpose
    self.headAnimationData = headAnimationData
    if headTpose ~= nil then
        self.animator_head = headTpose:GetComponent(Animator)
    else
        self.animator_head = nil
    end

    self.bodyTopse = bodyTopse
    self.bodyAnimationData = bodyAnimationData
    if self.bodyTopse ~= nil then
        self.animator_body = bodyTopse:GetComponent(Animator)
    else
        self.animator_body = nil
    end

    if self.tpose == nil then
        self.tpose = tpose
        local dir = self.data.dir
        -- print(string.format("%s %s", self.data.name, self.data.dir))
        if dir == nil then
            dir = SceneConstData.UnitFaceToIndex[self.baseData.forward+1]
        end
        -- print(dir)
        self:FaceTo_Now(dir)
    else
        self:objPool_push()

        if self.tpose ~= nil then
            self.tpose:SetActive(false)
            self.tpose.name = "Destroy_Tpose"
            GameObject.Destroy(self.tpose)
        end

        self.tpose = tpose
        self:FaceTo_Now(self.orienation)
    end

    -- 存储用于对象池的使用的数据
    self.poolData = poolData

    self.tpose.name = "tpose"
    Utils.ChangeLayersRecursively(self.tpose.transform, "Model")
    self.tpose.transform:SetParent(self.gameObject.transform)
    self.tpose.transform.localPosition = Vector3.zero
    -- self.shadow:SetActive(true)

    self.animator = tpose:GetComponent(Animator)
    if self.animator_body ~= nil and self.bodyAnimationData ~= nil then
        local look_ride
        for k, v in pairs(self.data.looks) do
            if v.looks_type == SceneConstData.looktype_ride then
                look_ride = v.looks_val
            end
        end
        local looksData = DataMount.data_ride_data[look_ride]
        if looksData then
            local action_type = looksData.action_type_male
            if self.data.sex == 0 then
                action_type = looksData.action_type_female
            end
            if action_type == 2 or action_type == 3 then
                self.animator_body:Play(SceneConstData.genanimationname("Sit", self.bodyAnimationData.ridestand_id2))
            elseif action_type == 4 then
                self.animator_body:Play(SceneConstData.genanimationname("Sit", self.bodyAnimationData.ridestand_id3))
            elseif action_type == 5 then
                if self.data.sex == 0 then
                    self.animator_body:Play(SceneConstData.genanimationname("Stand", 6))
                else
                    self.animator_body:Play(SceneConstData.genanimationname("Stand", 1))
                end
            elseif action_type == 6 then
                self.animator_body:Play(SceneConstData.genanimationname("Sit", 5))
            else
                self.animator_body:Play(SceneConstData.genanimationname("Sit", self.bodyAnimationData.ridestand_id))
            end
        end
    end
    self:UpdateAlpha(true)
    self:SetBoxCollider(self.baseData.collider)
    self:SetScale(self.scale)
    self:CreateDefaultEffect()

    -- 加载单位完成，计数减1
    SceneManager.Instance.sceneElementsModel:SubCreateCount()
    
    -- SceneManager.Instance.sceneElementsModel:SubCreateTposeCount()

    self.ChangeLook_Mark = false
    if self.ChangeLook_Cache then
        self.ChangeLook_Cache = false
        self:ChangeLook()
        return
    end

    if self.action_cacheData == nil then
        if self:Get_IsMoving() then
            local targetPosition = self.TargetPositionList[1]
            self:FaceToPoint(targetPosition)
            self:PlayAction(SceneConstData.UnitAction.Move)
        else
            self:PlayAction(SceneConstData.UnitAction.Stand)
        end
    else
        if self.action_cacheData.act_name ~= nil then
            self:PlayActionName(self.action_cacheData.act_name, self.action_cacheData.nostand)
        else
            self:PlayAction(self.action_cacheData.action, self.action_cacheData.nostand)
        end
        self.action_cacheData = nil
    end

    if self.data.tposecallback ~= nil then
        self.data.tposecallback(self)
        self.data.tposecallback = nil
    end
end

function NpcView:CreateDefaultEffect()
    if self.data.unittype == SceneConstData.unittype_pet then
        local petdata = self.data
        local effects = petdata.base.effects_0
        if petdata.genre ~= 1 then
            if petdata.grade == 0 then
                effects = petdata.base.effects_0
            elseif petdata.grade == 1 then
                effects = petdata.base.effects_1
            elseif petdata.grade == 2 then
                effects = petdata.base.effects_2
            end
        else
            if petdata.grade == 0 then
                effects = petdata.base.effects_s0
            elseif petdata.grade == 1 then
                effects = petdata.base.effects_s1
            elseif petdata.grade == 2 then
                effects = petdata.base.effects_s2
            end
        end

        if petdata.use_skin ~= 0 then
            self.baseData.skin = petdata.use_skin

            for key, value in pairs(DataPet.data_pet_skin) do
                if petdata.base.id == value.id and petdata.use_skin == value.skin_id then
                    effects = value.effects
                end
            end
        end
        --处理宠物幻化 jia
        local transList = petdata.unreal;
        local isOpen = false;
        if transList ~= nil and #transList > 0 and DataPet.data_pet_trans_black[petdata.base_id] == nil then
            isOpen = true
        end
        if isOpen and petdata.unreal_looks_flag == 0 then
            local taransData = transList[1];
            local itemID = taransData.item_id
            local endTime = taransData.timeout
            if endTime > BaseUtils.BASE_TIME then
                local transTmp = DataPet.data_pet_trans[itemID];
                if transTmp ~= nil then
                    local transFTmp = DataTransform.data_transform[transTmp.skin_id];
                    if transFTmp ~= nil then
                        effects = transFTmp.effects
                    end
                end
            end
        end
        for i=1,#effects do
            self:CreateEffect(effects[i].effect_id)
        end
    else
        local data = DataUnit.data_unit[self.data.baseid]
        for i=1,#data.effects do
            self:CreateEffect(data.effects[i].effect_id)
        end
    end
end

function NpcView:change_name()
    if self.gameObject == nil then return end
    local name = self.data.name
    if name == nil or name == "" then name = self.baseData.name end
    self.rolename_object:GetComponent(TextMesh).text = name
    self.rolenameshadow_object:GetComponent(TextMesh).text = name

    if self.baseData.id == 76880 then
        self:SetNameColor(ColorHelper.colorObjectScene[6])
    else
        self:SetNameColor(ColorHelper.colorObjectScene[5])
    end
end

function NpcView:change_guild_name()
    if self.gameObject == nil then return end

    local honorStr = ""
    local honorshadowStr = ""

    local data = self.baseData
    honorStr = data.honor_text
    honorshadowStr = data.honor_text

    if honorStr ~= "" then
        self.guildname_object:GetComponent(TextMesh).text = honorStr
        self.guildname_object.gameObject:SetActive(true)
        self.guildnameshadow_object:GetComponent(TextMesh).text = honorshadowStr
        self.guildnameshadow_object.gameObject:SetActive(true)

        self:SetGuildNameColor(ColorHelper.colorObjectScene[data.honor_color])
    else
        self.guildname_object.gameObject:SetActive(false)
        self.guildnameshadow_object.gameObject:SetActive(false)
    end

    if honorStr == "" then
        self.rolename_object.transform.localPosition = self.guildname_object.transform.localPosition
        self.rolenameshadow_object.transform.localPosition = self.guildnameshadow_object.transform.localPosition
    else
        self.rolename_object.transform.localPosition = Vector3(self.guildname_object.transform.localPosition.x, self.guildname_object.transform.localPosition.y - 0.15, 0)
        self.rolenameshadow_object.transform.localPosition = Vector3(self.guildnameshadow_object.transform.localPosition.x, self.guildnameshadow_object.transform.localPosition.y - 0.15, 0)
    end

    self:ChangeZIndex(self.rolename_object)
    self:ChangeZIndex(self.rolenameshadow_object)
end

-- type 0.显示原有称号 1.显示任务可接 2.显示任务完成
function NpcView:change_honor()
    local honorType = self.data.honorType
    -- print(string.format("%s %s", self.data.name, honorType))
    local data = self.baseData -- DataUnit.data_unit[self.data.baseid]
    self.honorid = data.honorid
    if self.honorid ~= 0 or honorType == 1 or honorType == 2 then
        self:show_honor(true, honorType)
        local honor_data = DataHonor.data_get_honor_list[self.honorid]
        if self.gameObject == nil then return end
        local spriterenderer = self.honor_object:GetComponent(SpriteRenderer)
        if honorType == nil or honorType == 0 then
            spriterenderer.sprite = PreloadManager.Instance:GetSprite(AssetConfig.honor_img, tostring(honor_data.res_id))
        elseif honorType == 1 then
            spriterenderer.sprite = PreloadManager.Instance:GetSprite(AssetConfig.honor_img, "HasTaskState")
        elseif honorType == 2 then
            spriterenderer.sprite = PreloadManager.Instance:GetSprite(AssetConfig.honor_img, "FinishTaskState")
        end
    else
        self:show_honor(false)
    end

    self:update_top_object()
end

-- type 0.显示原有称号 1.显示任务可接 2.显示任务完成
function NpcView:show_honor(bool, honorType)
    if self.honor_object ~= nil and self.honor_object:Equals(NULL) == false then
        if bool then
            local data = DataUnit.data_unit[self.data.baseid]
            self.honorid = data.honorid
            if self.honorid ~= 0 or honorType == 1 or honorType == 2 then
                self.honor_object.gameObject:SetActive(bool)
            end
        else
            self.honor_object.gameObject:SetActive(bool)
        end
    end
end

function NpcView:change_status_effect()
    if self.data.status == 2 and not BaseUtils.is_null(self.gameObject) then
        self.status = self.data.status

        local mark = true
        if self.status == 2 then
            if self.status_effect_id == 10096 and self.status_effect ~= nil then
                mark = false
            else
                self.status_effect_id = 10096
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
end

function NpcView:update_top_object()
    if BaseUtils.is_null(self.gameObject) then
        return
    end

    local h = 1
    if self.data.classes == nil or self.data.sex == nil or self.data.classes == 0 then
        h = 1 * self.scale
    else
        local rideMark = false
        for _,value in ipairs(self.data.looks) do
            if value.looks_type == SceneConstData.looktype_ride then -- 坐骑
                rideMark = true
            end
        end

        if rideMark then
            h = 1.15 * self.scale
        else
            h = 1 * self.scale
        end
    end

    if self.honorid ~= 0 or self.data.honorType == 1 or self.data.honorType == 2 then
        self.honor_object.transform.localPosition = Vector3 (0, h, 0)
        h = h + 0.2 * self.scale
    end
    if self.status_effect ~= nil and self.status_effect.gameObject ~= nil then
        self.status_effect.gameObject.transform.localPosition = Vector3 (0, h, 0)
        h = h + 0.2 * self.scale
    end
    self:ChangeZIndex(self.honor_object, -8)
end

function NpcView:objPool_push()
    local baseData = DataUnit.data_unit[self.data.baseid]
    local data = self.data
    if data.unittype == SceneConstData.unittype_teleporter or data.unittype == SceneConstData.unittype_fun_teleporter then
    elseif data.unittype == SceneConstData.unittype_sceneeffect or data.unittype == SceneConstData.unittype_trialeffect then
    elseif data.unittype == SceneConstData.unittype_pet then
    elseif data.unittype == SceneConstData.unittype_taskcollection_effect then
    else
        if self.controller ~= nil and not BaseUtils.is_null(self.tpose) then
            self.controller:SetAlphaChlid(self.tpose.transform, 1)
        end

        if self.data.classes == nil or self.data.sex == nil or self.data.classes == 0 then
            if self.poolData ~= nil then
                if self.poolData.modelPath ~= nil then
                    -- CombatManager.Instance.objPool:PushUnit(self.tpose, self.poolData.modelPath)
                    GoPoolManager.Instance:Return(self.tpose, self.poolData.modelPath, GoPoolType.Npc)
                    self.tpose = nil
                end
            end

            self.poolData = nil
        end

        self:CleanAllEffect()
    end
end

function NpcView:ChangeZIndex(textRect, zindex)
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

function NpcView:SetActive(active, hard)
    if self.active ~= active or hard then
        self.active = active
        if not BaseUtils.is_null(self.gameObject) then
            self.gameObject:SetActive(self.active)
        end

        if self.active then
            self:PlayAction(self.lastAction)

            if self.animator_body ~= nil and self.bodyAnimationData ~= nil then
                local look_ride
                for k, v in pairs(self.data.looks) do
                    if v.looks_type == SceneConstData.looktype_ride then
                        look_ride = v.looks_val
                    end
                end
                local looksData = DataMount.data_ride_data[look_ride]
                if looksData then
                    local action_type = looksData.action_type_male
                    if self.data.sex == 0 then
                        action_type = looksData.action_type_female
                    end
                    if action_type == 2 or action_type == 3 then
                        self.animator_body:Play(SceneConstData.genanimationname("Sit", self.bodyAnimationData.ridestand_id2))
                    elseif action_type == 4 then
                        self.animator_body:Play(SceneConstData.genanimationname("Sit", self.bodyAnimationData.ridestand_id3))
                    elseif action_type == 5 then
                        if self.data.sex == 0 then
                            self.animator_body:Play(SceneConstData.genanimationname("Stand", 6))
                        else
                            self.animator_body:Play(SceneConstData.genanimationname("Stand", 1))
                        end
                    elseif action_type == 6 then
                        self.animator_body:Play(SceneConstData.genanimationname("Sit", 5))
                    else
                        self.animator_body:Play(SceneConstData.genanimationname("Sit", self.bodyAnimationData.ridestand_id))
                    end
                end
            end
        else

        end
    end
end