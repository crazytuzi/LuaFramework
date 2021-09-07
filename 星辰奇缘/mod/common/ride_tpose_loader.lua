RideTposeLoader = RideTposeLoader or BaseClass()

function RideTposeLoader:__init(classes, sex, looks, callback)
	self.classes = classes
	self.sexNum = sex
    self.sex = sex
    self.looks = looks
    self.callback = callback

    self.resData = {
        modelId = nil
        ,rideAnimationData = nil
        ,skinPath = ""
        ,ridePath = ""
        ,ctrlPath = ""
        ,rideEffectPath = nil
        ,effectData = nil
        ,effect_id = nil
    }

    self.looks_ride = 0
    self.looks_ride_jewelry1 = 0
    self.looks_ride_jewelry2 = 0
    for k, v in pairs(looks) do
        if v.looks_type == SceneConstData.looktype_ride then -- 坐骑
            -- v.looks_val = 2022
            self.looks_ride = v.looks_val
        elseif v.looks_type == SceneConstData.looktype_ride_jewelry1 then -- 坐骑饰品1
            self.looks_ride_jewelry1 = v.looks_val
        elseif v.looks_type == SceneConstData.looktype_ride_jewelry2 then -- 坐骑饰品2
            self.looks_ride_jewelry2 = v.looks_val
        end
    end

    local looksData = DataMount.data_ride_data[self.looks_ride]
    if looksData then
        self.resData.ridePath = string.format(SceneConstData.looksdefiner_ridepath, looksData.model_id)
        self.resData.skinPath = string.format(SceneConstData.looksdefiner_rideSkinpath, looksData.skin_id)
        self.resData.ctrlPath = string.format(SceneConstData.looksdefiner_rideCtrpath, looksData.animation_id)
        self.resData.rideAnimationData = DataAnimation.data_ride_data[looksData.animation_id]
        self.resData.modelId = looksData.model_id
        if looksData.effect_id ~= nil and next(looksData.effect_id) ~= nil then
                --暂时考虑单个特效
                self.resData.effect_id = looksData.effect_id[1].effect_d
                local res_id = DataEffect.data_effect[looksData.effect_id[1].effect_d].res_id
                self.resData.rideEffectPath = string.format(AssetConfig.effect, res_id)

        end

        -- if self.looks_ride_jewelry1 ~= 0 then
        --     local ride_jewelry = DataMount.data_ride_jewelry[self.looks_ride_jewelry1]
        --     if ride_jewelry.model_id ~= 0 and ride_jewelry.skin_id ~= 0 then
        --         self.resData.ridePath = string.format(SceneConstData.looksdefiner_ridepath, ride_jewelry.model_id)
        --         self.resData.skinPath = string.format(SceneConstData.looksdefiner_rideSkinpath, ride_jewelry.skin_id)
        --         self.resData.modelId = ride_jewelry.model_id
        --     else
        --         Log.Debug(string.format("<color='#00ff00'>mount_data 这个坐骑饰品的数据有问题，id  %s model_id %s skin_id%s</color>", self.looks_ride_jewelry1, ride_jewelry.model_id, ride_jewelry.skin_id))
        --     end
        -- end
    else
        Log.Debug(string.format("<color='#00ff00'>mount_data 这个坐骑looks数据没有啊 %s %s %s</color>", self.looks_ride, self.looks_ride_jewelry1, self.looks_ride_jewelry2))
        return
    end

    self.loadCompleted = function()
        self:BuildRide()
    end

    local subResources = SubpackageManager.Instance:RideResources(self.resData)

    -- self.ride = CombatManager.Instance.objPool:PopUnit(self.ridePath)
    self.ride = GoPoolManager.Instance:Borrow(self.resData.ridePath, GoPoolType.Ride)
    if self.ride ~= nil then
        SubpackageManager.Instance:RemoveByFile(subResources, self.resData.ridePath)
    end

    if self.resData.rideEffectPath ~= nil then
        -- self.rideEffect = CombatManager.Instance.objPool:PopUnit(self.rideEffectPath)
        self.rideEffect = GoPoolManager.Instance:Borrow(self.resData.rideEffectPath, GoPoolType.Effect)

        if self.rideEffect ~= nil then
            SubpackageManager.Instance:RemoveByFile(subResources, self.resData.rideEffectPath)
        end
    end

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(subResources, self.loadCompleted)
end

function RideTposeLoader:__delete()
    --print("RideTposeLoader:__delete"..debug.traceback())
    if not BaseUtils.isnull(self.ride) then
        -- GameObject.Destroy(self.ride)
        GoPoolManager.Instance:Return(self.ride, self.resData.ridePath, GoPoolType.Ride)
    end
    if self.assetWrapper ~= nil then
    	self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if not BaseUtils.is_null(self.rideEffect) then
        -- GameObject.Destroy(self.rideEffect)
        GoPoolManager.Instance:Return(self.rideEffect, self.resData.rideEffect, GoPoolType.Effect)
    end

    self.ride = nil
    self.rideEffect = nil
    self.rideAnimationData = nil
    self.resData = nil
    self.callback = nil
end

function RideTposeLoader:BuildRide()
    if self.assetWrapper == nil then return end

    if self.ride == nil then
    	self.ride = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.ridePath).transform:FindChild("ride_tpose").gameObject)
    end

    self:BuildRideEffect()

    -- local meshNode = self.ride.transform
    local meshNode = self.ride.transform:FindChild(string.format("Mesh_%s", self.resData.modelId))
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    local skin = self.assetWrapper:GetMainAsset(self.resData.skinPath)
    meshNode.renderer.material.mainTexture = skin

    local ctrl = self.assetWrapper:GetMainAsset(self.resData.ctrlPath)
    local animator = self.ride:GetComponent(Animator)
    animator.runtimeAnimatorController = ctrl
    animator.applyRootMotion = false
    self.animator = animator
    if self.animationData ~= nil then
        self.animator:Play("Stand" .. self.animationData.stand_id)
    end
    
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.callback(self.ride, self.resData.rideAnimationData, { ridePath = self.resData.ridePath, rideAnimationData = self.resData.rideAnimationData, rideEffect = self.rideEffect, rideEffectPath = self.rideEffectPath },self.looks_ride)
end

function RideTposeLoader:BuildRideEffect()
    if self.resData.rideEffectPath ~= nil then
        if self.rideEffect == nil then
            self.rideEffect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.rideEffectPath))
        end
        local effectId = self.resData.effect_id
        local effectData = DataEffect.data_effect[effectId]
        if effectData == nil then
            return
        end
        local mountNode = effectData.mounter_str
        local effectParent = self.ride.transform
        if mountNode ~= "" then
            local path = BaseUtils.GetChildPath(self.ride.transform, tostring(mountNode))
            effectParent = self.ride.transform:Find(path)
        end
        
        self.rideEffect.transform:SetParent(effectParent)
        self.rideEffect.transform.localPosition = Vector3(0, 0, 0)
        self.rideEffect.transform.localRotation = Quaternion.identity
    end
end