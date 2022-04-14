---
--- Created by R2D2.
--- DateTime: 2019/5/17 11:06
--- 创角时角色显示专用

CreateRoleModel = CreateRoleModel or class("CreateRoleModel", UIModel)
local CreateRoleModel = CreateRoleModel

function CreateRoleModel:ctor(parent, load_call_back, data)
    self.parent = parent
    self.data = data
    self.load_call_back = load_call_back;

    self.otherAnimator_list = {}
    self.effect_list = {}
    self.boneNode_list = {}
    self.animationEffect = {}

    if self.data then
        self:InitData()
    end
end

function CreateRoleModel:dctor()
    self:ClearBoneNode()
    AnimationManager:GetInstance():RemoveAnimation(self)
end

function CreateRoleModel:ReLoadData(data, call_back)
    self.data = data
    self.load_call_back = call_back

    if not self.is_loading then
        self:InitData()
    end
end

function CreateRoleModel:InitData()

    local res_id = self.data and self.data.res_id or 12001
    if self.res_id == res_id then
        return
    end

    ---默认动作，用作分部动作默认值用
    self.defaultAction = "idle"
    if self.data.animation then
        if type(self.data.animation) == "table" then
            self.defaultAction = self.data.animation.animations[1]
        else
            self.defaultAction = self.data.animation.animations
        end
    end

    local abName = "model_clothe_" .. res_id
    local assetName = "model_clothe_" .. res_id

    self.layer_name = self.data.layer_name or "UI"
    self.is_loading = true
    self.res_id = res_id

    local function call_back(objs, is_cache)
        self.is_loading = false
        if self.res_id ~= self.data.res_id then
            self:InitData()
            return
        end

        self:CreateModel(objs, is_cache, abName, assetName, self.data.res_scale, self.data.pos)
    end

    lua_resMgr:LoadPrefab(self, abName, assetName, call_back, nil, nil, true)
end

function CreateRoleModel:CreateModel(objs, is_cache, abName, assetName, scale, pos)
    self:ClearBoneNode()
    CreateRoleModel.super.CreateModel(self, objs, is_cache, abName, assetName, scale, pos)
    self.abName = abName
    self.assetName = assetName
end

function CreateRoleModel:LoadCallBack()

    self:SetEffectInfo("body", self.transform, self.data.config.bodyEffect)

    -- 一定要再加载前先执行
    self:LoadHead()
    self:LoadWeapon()
    self:LoadWing()

    self:SetAnimationEffect()

    if (self.data.animation) then
        local ani = self.data.animation
        self:AddAnimation(ani.animations, ani.isLoop, ani.default, ani.delay)
    else
        self:AddAnimation({ "idle" }, false, "idle", 0)
    end

    if self.load_call_back then
        self.load_call_back(self.data.index);
    end
    self.load_call_back = nil;
end

function CreateRoleModel:LoadHead(hear_res_id)

    local res_id = hear_res_id or self.res_id
    local boneName = SceneConstant.BoneNode.Head
    local resName = "model_head_" .. res_id

    self:SetBoneInfo(boneName, resName, nil, true)
end

function CreateRoleModel:LoadWing(wing_res_id)

    local res_id = wing_res_id or self.res_id
    local boneName = SceneConstant.BoneNode.Wing
    local resName = "model_wing_" .. res_id

    self:SetBoneInfo(boneName, resName, self.data.config.wingEffect, true)
end

function CreateRoleModel:LoadWeapon(weapon_res_id)

    local res_id = weapon_res_id or self.res_id
    local boneName = SceneConstant.BoneNode.RHand
    local resName = "model_weapon_r_" .. res_id

    self:SetBoneInfo(boneName, resName, nil, false)
end

function CreateRoleModel:SetBoneInfo(boneName, resName, effectTab, needAnimator)
    if not self.is_loaded then
        return
    end

    local bone = self:GetBoneNode(boneName)

    local resTransform = GetComponentChildByName(bone, resName)
    if (resTransform) then
        local resGameObject = resTransform.gameObject
        local animator = resGameObject:GetComponent('Animator')

        if (animator and needAnimator) then
            self.otherAnimator_list[boneName] = { animator = animator, gameObject = resGameObject, transform = resTransform }
            animator:CrossFade(self.defaultAction, 0)
        end

        if (effectTab == nil or #effectTab == 0) then
            return
        end

        self:SetEffectInfo(boneName, resTransform, effectTab)
    end
end

function CreateRoleModel:SetAnimationEffect()
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

function CreateRoleModel:SetEffectInfo(boneName, resTransform, effectTab)
    self.effect_list[boneName] = {}
    for _, v in ipairs(effectTab) do
        local t = resTransform:Find(v)
        if (t) then
            SetVisible(t, false)
            table.insert(self.effect_list[boneName], t)
        end
    end
end

function CreateRoleModel:ShowAllEffect()
    for _, v in pairs(self.effect_list) do
        for _, e in ipairs(v) do
            SetVisible(e, false)
            SetVisible(e, true)
        end
    end
end

function CreateRoleModel:HideAllEffect()
    for _, v in pairs(self.effect_list) do
        for _, e in ipairs(v) do
            SetVisible(e, false)
        end
    end

    self:HideAnimationEffect()
end

function CreateRoleModel:HideAnimationEffect()
    for _, v in pairs(self.animationEffect) do
        for _, w in ipairs(v) do
            SetVisible(w, false)
        end
    end
end

function CreateRoleModel:PlayAnimation(actionName, isLoop, defaultAction)
    isLoop = toBool(isLoop)
    defaultAction = defaultAction or "idle"
    if(self and self.animator) then
        AnimationManager:GetInstance():AddAnimation(self, self.animator, actionName, isLoop, defaultAction, 0)
    end
end

function CreateRoleModel:PlayAnimationList(actionList, defalutAction, delayTime)
    local action_list = actionList or { "idle" }
    local default_action = defalutAction or "idle"
    local delay_Time = delayTime or 0

    if(self and self.animator) then
        AnimationManager:GetInstance():AddAnimation(self, self.animator, action_list, false, default_action, delay_Time)
    end
end

function CreateRoleModel:CheckAnimatorState(stateName)
    return self.animator:GetCurrentAnimatorStateInfo(0):IsName(stateName)
end

function CreateRoleModel:PlayCallBack(animation_name)
    --logError("animation_name: " .. animation_name)

    for _, v in pairs(self.otherAnimator_list) do
        if (v.animator) then
            v.animator:CrossFade(animation_name, 0)
        end
    end

    self:PlayAnimationEffect(animation_name)
end

function CreateRoleModel:PlayAnimationEffect(animation_name)
    if self.animationEffect[animation_name] then
        local tab = self.animationEffect[animation_name]

        for _, v in ipairs(tab) do
            SetVisible(v, false)
            SetVisible(v, true)
        end
    end
end

--[[
	@author LaoY
	@des	获取骨骼节点 放在C#获取，效率快4倍左右 再做个缓存
	@param1 boneName string
	@return Component
--]]
function CreateRoleModel:GetBoneNode(boneName)
    if not self.boneNode_list[boneName] then
        self.boneNode_list[boneName] = GetComponentChildByName(self.transform, boneName)
    end
    return self.boneNode_list[boneName]
end

function CreateRoleModel:ClearBoneNode()
    self.boneNode_list = {}
    self.effect_list = {}
end