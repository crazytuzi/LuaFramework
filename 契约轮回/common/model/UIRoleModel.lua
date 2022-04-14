-- 
-- @Author: LaoY
-- @Date:   2018-07-17 19:41:56
-- 

function GetRoleModelData(role_data, res_id)
    role_data = role_data or RoleInfoModel:GetInstance():GetMainRoleData()

    local body_res_id = res_id or role_data.res_id ---此处仅为保持老代码兼容
            or (role_data.figure and role_data.figure["fashion_clothes"] and role_data.figure["fashion_clothes"].show and role_data.figure["fashion_clothes"].model)
            or (role_data.gender and role_data.gender == 2 and 12001 or 11001)

    local weapon_res_id = (role_data.figure and role_data.figure.weapon and role_data.figure.weapon.show and role_data.figure.weapon.model)
            or role_data.weapon_res_id or body_res_id

    local wing_res_id = role_data.figure and role_data.figure.wing and role_data.figure.wing.model or 0
    local offhand_res_id = role_data.figure and role_data.figure.offhand and role_data.figure.offhand.model or body_res_id
    local hear_id = (role_data.figure and role_data.figure.fashion_head and role_data.figure.fashion_head.show and role_data.figure.fashion_head.model) or body_res_id

    local talisman_res_id = role_data.figure and role_data.figure.talis and role_data.figure.talis.model
    local magic_res_id = nil

    return {
        role_data = role_data,
        res_id = body_res_id,
        weapon_res_id = weapon_res_id,
        wing_res_id = wing_res_id,
        offhand_res_id = offhand_res_id,
        hear_id = hear_id,
        talisman_res_id = talisman_res_id,
        magic_res_id = magic_res_id,

        is_show_all = true,
        is_show_wing = wing_res_id and wing_res_id ~= 0,
        is_show_leftHand = true,
        is_show_weapon = true,
        is_show_head = true,
        is_show_talisman = false,
        is_show_magic = false,
    }
end

UIRoleModel = UIRoleModel or class("UIRoleModel", UIModel)
local UIRoleModel = UIRoleModel

function UIRoleModel:ctor(parent, load_call_back, data, config)
    self.parent = parent

    self.data = GetRoleModelData(data, config and config.res_id or nil)

    if (config) then
        self:ApplyConfig(config)
    end

    self.load_call_back = load_call_back;
    self.is_recursion_show = true

    self.boneRes_list = {}
    self.boneNode_list = {}
    self.boneObject_list = {}

    self.effect_list = {}
    self.animationEffect = {}

    if self.data then
        self:InitData()
    end
end

function UIRoleModel:dctor()
    self:ClearBoneNode()
    AnimationManager:GetInstance():RemoveAnimation(self)
    if self.gameObject then
        LayerManager.RecycleUnUseUIModelLayer(self.gameObject.layer)
    end
    self.parentLayer = nil;

    self:ClearBoneEffect()
end

function UIRoleModel:ApplyConfig(config)
    if config.is_show_wing ~= nil then
        self.data.is_show_wing = config.is_show_wing
    end
    if config.is_show_leftHand ~= nil then
        self.data.is_show_leftHand = config.is_show_leftHand
    end
    if config.is_show_weapon ~= nil then
        self.data.is_show_weapon = config.is_show_weapon
    end
    if config.is_show_head ~= nil then
        self.data.is_show_head = config.is_show_head
    end
    if config.is_show_effect ~= nil then
        self.data.is_show_effect = config.is_show_effect
    end
    if config.index ~= nil then
        self.configIndex = config.index
    end
    if config.is_show_before_unloaded ~= nil then
        self.is_show_before_unloaded = config.is_show_before_unloaded
    end
    self.data.config = config.config
end

function UIRoleModel:ReLoadData(data, call_back, config)
    self.data = GetRoleModelData(data, config and config.res_id or nil)

    if (config) then
        self:ApplyConfig(config)
    end

    self.load_call_back = call_back

    if not self.is_loading then
        self:InitData()
    end
end

function UIRoleModel:InitData()

    local res_id = self.data and self.data.res_id or 12001
    --if self.res_id == res_id then
    --    return
    --end

    local abName = "model_clothe_" .. res_id
    local assetName = "model_clothe_" .. res_id

    self.layer_name = layer_name or "UI"
    self.is_loading = true
    self.res_id = res_id
    local function call_back(objs, is_cache)
        self.is_loading = false
        if self.res_id ~= self.data.res_id then
            self:InitData()
            return
        end

        self:CreateModel(objs, is_cache, abName, assetName, self.data.res_scale, self.data.pos)
        -- self:LoadCallBack(objs)
    end
    lua_resMgr:LoadPrefab(self, abName, assetName, call_back, nil, nil, true)
end

function UIRoleModel:CreateModel(objs, is_cache, abName, assetName, scale, pos)
    self:ClearBoneNode()
    UIRoleModel.super.CreateModel(self, objs, is_cache, abName, assetName, scale, pos)
    self.abName = abName
    self.assetName = assetName
end

function UIRoleModel:LoadCallBack()
    self:ClearBoneNode()

    if not self.is_show_before_unloaded then
        self:SetVisible(false)
    end
    -- 一定要再加载前先执行
    if self.data.is_show_effect then
        self:SetEffectInfo("body", self.transform, self.data.config.bodyEffect)
        self:SetAnimationEffect()
    end
    if self.data.is_show_all and self.data.is_show_head then
        self:LoadHead(self.data.hear_id)
    end
    if self.data.is_show_all and self.data.is_show_leftHand then
        self:LoadLHand(self.data.offhand_res_id)
    end
    if self.data.is_show_all and self.data.is_show_weapon then
        self:LoadWeapon(self.data.weapon_res_id)
    end
    if self.data.is_show_all and self.data.is_show_wing then
        self:LoadWing(self.data.wing_res_id)
    end

    if (self.data.animation) then
        local ani = self.data.animation
        self:AddAnimation(ani.animations, ani.isLoop, ani.default, ani.delay)
    else
        self:AddAnimation({ "idle" }, false, "idle", 0)
    end

    if self.load_call_back then
        self.load_call_back(self.data.role_data.index or self.configIndex);
    end
    self.load_call_back = nil;
    self:SetOrderByParentAuto()
end

function UIRoleModel:LoadHead(hear_id)
    local res_id = hear_id or self.res_id
    local abName = "model_head_" .. res_id
    local assetName = "model_head_" .. res_id
    local boneName = SceneConstant.BoneNode.Head

    local function load_callback()
        -- if not self.data.isHeadAnimation then
        --     return
        -- end

        if not self.boneObject_list[boneName] then
            return
        end

        local info = self.boneObject_list[boneName]
        info.animator = info.gameObject:GetComponent('Animator')
        if not self.is_show_before_unloaded then
            self:SetVisible(true)
        end
    end
    self:SetBoneResource(boneName, abName, assetName, load_callback, nil)
end

function UIRoleModel:LoadLHand(hand_id)
    local res_id = hand_id or self.res_id
    local abName = "model_hand_" .. res_id
    local assetName = "model_hand_" .. res_id
    local boneName = SceneConstant.BoneNode.LHand

    local function load_func()
        if not self.boneObject_list[boneName] then
            return
        end
        local info = self.boneObject_list[boneName]
        info.animator = info.gameObject:GetComponent('Animator')
    end

    self:RemoveBoneResource(boneName);
    self:SetBoneResource(boneName, abName, assetName, load_func, nil)
end

function UIRoleModel:SetWingVisible(flag)
    local isShow = toBool(flag)
    self:RemoveBoneResource(SceneConstant.BoneNode.Wing)

    if (isShow) then
        self.data.is_show_wing = true
        self:LoadWing(self.data.wing_res_id)
    else
        self.data.is_show_wing = false
    end
end

function UIRoleModel:LoadWing(wing_res_id)

    local boneName = SceneConstant.BoneNode.Wing

    if (not self.data.is_show_wing) then
        self:RemoveBoneResource(boneName)
        return
    end

    local res_id = wing_res_id or 0

    if res_id == 0 then
        self:RemoveBoneResource(boneName)
        return
    else
        local abName = "model_wing_" .. res_id
        local assetName = "model_wing_" .. res_id

        local function load_callback()

            if not self.data.isWingAnimation then
                return
            end

            if not self.boneObject_list[boneName] then
                return
            end

            local info = self.boneObject_list[boneName]
            info.animator = info.gameObject:GetComponent('Animator')
        end
        self:SetBoneResource(boneName, abName, assetName, load_callback, nil)
    end
end

function UIRoleModel:LoadWeapon(weapon_id)
    local res_id = weapon_id or self.res_id
    local abName = "model_weapon_" .. res_id
    local assetName = "model_weapon_r_" .. res_id
    local boneName = SceneConstant.BoneNode.RHand
    local function load_func()
        local info = self.boneObject_list[boneName]
        if info.transform then
            info.animator = info.transform:GetComponent("Animator")
            info.animator:CrossFade("idle",0)
        end
    end
    self:SetBoneResource(boneName, abName, assetName, load_func, nil)
end

function UIRoleModel:SetBoneResource(boneName, abName, assetName, load_func, remove_cache_func)
    if not self.is_loaded then
        logWarn("The time is wrong to call SetBoneResource , the res is " .. abName)
        return
    end
    local last_res = self.boneRes_list[boneName]
    local function load_callback(objs, is_cache)
        if self.is_dctored or not objs or not objs[0] then
            logWarn("load", boneName, "is failed", "the res is", abName)
            return
        end
        local function new_call_back(obj)
            if self.is_dctored then
                if not poolMgr:AddGameObject(abName, assetName, obj) then
                    destroy(obj)
                end
                return
            end
            local bone = self:GetBoneNode(boneName)
            if not bone then
                logWarn("can not find the bone , the name is " .. boneName)
                return
            end
            local new_gameObject = obj
            local bone_object = self.boneObject_list[boneName]
            if bone_object and bone_object.gameObject then
                local res = self.boneRes_list[boneName]
                if abName == res.abName and assetName == res.assetName then
                    if not last_res or not poolMgr:AddGameObject(last_res.abName, last_res.assetName, bone_object.gameObject) then
                        destroy(bone_object.gameObject)
                    end
                    -- 不要置为nil
                    self.boneObject_list[boneName].gameObject = false
                    self.boneObject_list[boneName].transform = false
                    if remove_cache_func then
                        remove_cache_func()
                    end
                else
                    if not poolMgr:AddGameObject(abName, assetName, new_gameObject) then
                        destroy(new_gameObject)
                    end
                    return
                end
            end

            -- 保存gameObject和transform，不要频繁和C#交互
            local transform = new_gameObject.transform
            self.boneObject_list[boneName] = { gameObject = new_gameObject, transform = transform }
            transform:SetParent(bone)

            if boneName == SceneConstant.BoneNode.Head then
                self.boneObject_list[boneName].animator = new_gameObject:GetComponent('Animator')
            end
            SetChildLayer(transform, self.data.layer or self.parentLayer or LayerManager.BuiltinLayer.UI)
            SetLocalPosition(transform)
            SetLocalRotation(transform)
            SetLocalScale(transform)

            if load_func then
                load_func()
            end

            self:ClearBoneEffect(boneName)
            self:LoadBoneNodeEffect(transform,boneName,assetName)
        end

        if is_cache then
            new_call_back(objs[0])
        else
            lua_resMgr:GetPrefab("", "", objs[0], new_call_back);
        end
    end
    self.boneRes_list[boneName] = { abName = abName, assetName = assetName }
    lua_resMgr:LoadPrefab(self, abName, assetName, load_callback, nil, Constant.LoadResLevel.High, true)
end

function UIRoleModel:ClearBoneEffect(boneName)
    if not self.model_bone_effect_list then
        return
    end
    if boneName then
        if self.model_bone_effect_list[boneName] then
            for k,v in pairs(self.model_bone_effect_list[boneName]) do
                v:destroy()
            end
            self.model_bone_effect_list[boneName] = {}
        end
    else
        for _boneName,boneList in pairs(self.model_bone_effect_list) do
            for k,v in pairs(boneList) do
                v:destroy()
            end
        end
        self.model_bone_effect_list = nil
    end
end

function UIRoleModel:LoadBoneNodeEffect(transform,boneName,assetName)
    self.model_bone_effect_list = self.model_bone_effect_list or {}
    self.model_bone_effect_list[boneName] = self.model_bone_effect_list[boneName] or {}

    local effect_list_cf = ModelEffectConfig[assetName]
    if not effect_list_cf then
        return
    end
    for node_name,effect_list in pairs(effect_list_cf) do
        for k,cf in pairs(effect_list) do
            local node = GetComponentChildByName(transform,node_name)
            if node then
                local effect = ModelEffect(node,cf.name,cf,self,true)
                self.model_bone_effect_list[boneName][#self.model_bone_effect_list[boneName]+1] = effect
            end
        end
    end
end

function UIRoleModel:GetAnimatorByBone(boneName)
    if (self.boneObject_list[boneName] and self.boneObject_list[boneName].animator) then
        return self.boneObject_list[boneName].animator
    else
        return nil
    end
end

function UIRoleModel:PlayAnimation(actionName)
    AnimationManager:GetInstance():AddAnimation(self, self.animator, actionName, true, "idle", 0.1)
end

function UIRoleModel:PlayAnimationList(actionList, defalutAction, delayTime)
    local action_list = actionList or { "idle" }
    local default_action = defalutAction or "idle"
    local delay_Time = delayTime or 0.02
    AnimationManager:GetInstance():AddAnimation(self, self.animator, action_list, false, default_action, delay_Time)
end

function UIRoleModel:PlayCallBack(animation_name)
    --if (self.data.isHeadAnimation) then
    local headAnimator = self:GetAnimatorByBone(SceneConstant.BoneNode.Head)
    if (headAnimator) then
        headAnimator:CrossFade(animation_name, 0)
    end
    --end

    if (self.data.isWingAnimation) then
        local wingAnimator = self:GetAnimatorByBone(SceneConstant.BoneNode.Wing)
        if (wingAnimator) then
            wingAnimator:CrossFade(animation_name, 0)
        end
    end
end

--[[
	@author LaoY
	@des	获取骨骼节点 放在C#获取，效率快4倍左右 再做个缓存
	@param1 boneName string
	@return Component
--]]
function UIRoleModel:GetBoneNode(boneName)
    if not self.boneNode_list[boneName] then
        self.boneNode_list[boneName] = GetComponentChildByName(self.transform, boneName)
    end
    return self.boneNode_list[boneName]
end

function UIRoleModel:ClearBoneNode()
    for boneName, info in pairs(self.boneObject_list) do
        local res = self.boneRes_list[boneName]
        -- 添加到缓存
        if not info.gameObject then
            return
        end
        if res then
            if not poolMgr:AddGameObject(res.abName, res.assetName, info.gameObject) then
                destroy(info.gameObject)
            end
        end
    end
    self.boneObject_list = {}
    self.boneRes_list = {}
    ---Parent Transform 要清除，以免将模型挂到上个模型上
    self.boneNode_list = {}

    self.effect_list = {}
end

function UIRoleModel:RemoveBoneResource(boneName)
    local bone_object = self.boneObject_list[boneName]
    if bone_object then
        local res = self.boneRes_list[boneName]
        if not poolMgr:AddGameObject(res.abName, res.assetName, bone_object.gameObject) then
            destroy(bone_object.gameObject)
        end
    end
    self.boneObject_list[boneName] = nil
    self.boneRes_list[boneName] = nil
end

function UIRoleModel:SetEffectInfo(boneName, resTransform, effectTab)
    self.effect_list[boneName] = {}
    for _, v in ipairs(effectTab) do
        local t = resTransform:Find(v)
        if (t) then
            SetVisible(t, false)
            table.insert(self.effect_list[boneName], t)
        end
    end
end

function UIRoleModel:ShowAllEffect()
    for _, v in pairs(self.effect_list) do
        for _, e in ipairs(v) do
            SetVisible(e, false)
            SetVisible(e, true)
        end
    end
end

function UIRoleModel:HideAllEffect()
    for _, v in pairs(self.effect_list) do
        for _, e in ipairs(v) do
            SetVisible(e, false)
        end
    end

    self:HideAnimationEffect()
end

function UIRoleModel:HideAnimationEffect()
    for _, v in pairs(self.animationEffect) do
        for _, w in ipairs(v) do
            SetVisible(w, false)
        end
    end
end

function UIRoleModel:CheckAnimatorState(stateName)
    return self.animator:GetCurrentAnimatorStateInfo(0):IsName(stateName)
end

function UIRoleModel:SetAnimationEffect()
    if self.data.config then
        local effectArray = self.data.config.actionArray
        for k, v in pairs(effectArray) do
            self.animationEffect[k] = {}

            for _, w in ipairs(v) do
                local t = self.transform:Find(w)
                if (t) then
                    SetVisible(t, false)
                    table.insert(self.animationEffect[k], t)
                end
            end
        end
    end
end

function UIRoleModel:PlayAnimationEffect(animation_name)
    if self.animationEffect[animation_name] then
        local tab = self.animationEffect[animation_name]

        for _, v in ipairs(tab) do
            SetVisible(v, false)
            SetVisible(v, true)
        end
    end
end