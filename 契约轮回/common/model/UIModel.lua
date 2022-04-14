--
-- @Author: LaoY
-- @Date:   2018-09-19 20:19:25
--

UIModel = UIModel or class("UIModel", Node)
local this = UIModel

function UIModel:ctor(parent)
    self.is_replay_in_show = true   -- 重新显示是否重复播放动作
    self.parent = parent
end

function UIModel:dctor()
    AnimationManager:GetInstance():RemoveAnimation(self);
    if self.gameObject then
        LayerManager.RecycleUnUseUIModelLayer(self.gameObject.layer)
    end
    self:ClearNodeEffect()
end

function UIModel:Load()
    lua_resMgr:LoadPrefab(self, self.abName, self.assetName, handler(self, self.CreateModel), nil, Constant.LoadResLevel.High, true)
end

function UIModel:DestyoyGameObject(abName, assetName)
    if self.gameObject then
        if not poolMgr:AddGameObject(abName or self.abName, assetName or self.assetName, self.gameObject) then
            destroy(self.gameObject)
        end
        self.gameObject = nil
    end
end

function UIModel:CreateModel(objs, is_cache, abName, assetName, scale, pos)
    if self.is_dctored or not objs or not objs[0] then
        return
    end

    local last_abName, last_assetName = self.abName, self.assetName
    local function new_call_back(obj)
        if self.is_dctored then
            if not poolMgr:AddGameObject(self.abName, self.assetName, obj) then
                destroy(obj)
            end
            return
        end
        self.is_loaded = true

        if self.gameObject then
            AnimationManager:GetInstance():RemoveAnimation(self)
        end

        self:DestyoyGameObject(last_abName, last_assetName)

        self.gameObject = obj
        self.transform = self.gameObject.transform
        self.animator = self.gameObject:GetComponent('Animator')
        self.transform:SetParent(self.parent)

        SetChildLayer(self.transform, self.data and self.data.layer or LayerManager.BuiltinLayer.UI)
        if self.isVisible ~= nil then
            self:SetVisible(self.isVisible)
        end

        if is_cache then
            self.animator.speed = 1
        end
        self.animator.cullingMode = UnityEngine.AnimatorCullingMode.AlwaysAnimate

        SetRotate(self.transform, 0, 0, 0)
        if pos then
            SetLocalPosition(self.transform, pos.x, pos.y, pos.z)
        else
            SetLocalPosition(self.transform, 0, 0,  -100)
        end

        local l_scale = 100
        if scale then
            l_scale = l_scale * scale
        end
        if self.scale ~= nil then
            self:SetScale(self.scale)
        else
            self:SetScale(l_scale)
        end

        --SetChildLayer(self.transform, LayerManager.GetUnUseUIModelLayer());
        self.parentLayer = self.gameObject.layer;
        --if self.transform.parent then
        --    local cameraObj = GetChild(self.transform.parent, "Camera");
        --    --if cameraObj then
        --    --    local camera = GetCamera(cameraObj);
        --    --    camera.cullingMask = BitState.State[self.gameObject.layer + 1];
        --    --end
        --end

        SetGameObjectActive(self.gameObject, false);
        SetGameObjectActive(self.gameObject, true);
        self:LoadCallBack()

        self:ClearNodeEffect()
        self:LoadNodeEffect()
    end

    if is_cache then
        local function step()
            if self.is_dctored then
                return
            end
            new_call_back(objs[0])
        end
        GlobalSchedule:StartOnce(step, 0)
        if objs[0] then
            SetVisible(objs[0],false)
        end
    else
        lua_resMgr:GetPrefab("", "", objs[0], new_call_back);
    end
end

function UIModel:ClearNodeEffect()
    if not self.model_effect_list then
        return
    end
    for k,v in pairs(self.model_effect_list) do
        v:destroy()
    end
    self.model_effect_list = {}
end

function UIModel:LoadNodeEffect()
    self.model_effect_list = self.model_effect_list or {}
    local effect_list_cf = ModelEffectConfig[self.assetName]
    if not effect_list_cf then
        return
    end
    for node_name,effect_list in pairs(effect_list_cf) do
        for k,cf in pairs(effect_list) do
            local node = GetComponentChildByName(self.transform,node_name)
            if node then
                local effect = ModelEffect(node,cf.name,cf,self,true)
                self.model_effect_list[#self.model_effect_list+1] = effect
            end
        end
    end
end

function UIModel:AddEvent()
end

function UIModel:SetCameraLayer()
    if self.gameObject and self.transform then
        SetChildLayer(self.transform, LayerManager.GetUnUseUIModelLayer());
        if self.transform.parent then
            local cameraObj = GetChild(self.transform.parent, "Camera");
            if cameraObj then
                local camera = GetCamera(cameraObj);
                camera.cullingMask = BitState.State[self.gameObject.layer + 1];
            end
        end
    end
end

--[[
	@author LaoY
	@des	
	@param1 动作列表
	@param2 是否循环（列表）
	@param3 默认动作
	@param4 每个动作之间的延迟
--]]
function UIModel:AddAnimation(animation_name_list, is_loop, default_action_name, delay_time)
    if self.animator then
        is_loop = is_loop == nil and true or is_loop
        -- default_action_name = default_action_name == nil and "idle" or default_action_name
        delay_time = delay_time == nil and 0.1 or delay_time
        AnimationManager:GetInstance():AddAnimation(self, self.animator, animation_name_list, is_loop, default_action_name, delay_time)
    end
end

function UIModel:SetReplayMode(flag)
    self.is_replay_in_show = flag
end

function UIModel:PlayCallBack(animation_name)
    
end

--over write
function UIModel:LoadCallBack()
end