WingTposeLoader = WingTposeLoader or BaseClass()

function WingTposeLoader:__init(looks, callback, layer, isEffect)
	self.looks = looks
    self.callback = callback
    self.layer = layer
    self.isEffect = isEffect

    if self.layer == nil then self.layer = "Model" end

    self.animator = nil

    self.resData = {
        wingData = nil
        ,animationData = nil
        ,skinPath = ""
        ,modelPath = ""
        ,ctrlPath = ""
    }

    for k, v in pairs(looks) do
		if v.looks_type == SceneConstData.looktype_wing then -- 翅膀
            self.resData.wingData = DataWing.data_base[v.looks_val]
        end
    end

	if self.resData.wingData == nil then
		self.callback()
	end

	self.resData.animationData = DataAnimation.data_wing_data[self.resData.wingData.act_id]

    if self.resData.animationData == nil then
        Log.Error(string.format("找不到id为%s的翅膀动作", self.resData.wingData.act_id))
        return
    end

    self.resData.skinPath = string.format("prefabs/wing/skin/%s.unity3d", self.resData.wingData.map_id)
    self.resData.modelPath = string.format("prefabs/wing/model/%s.unity3d", self.resData.wingData.model_id)
    self.resData.ctrlPath = string.format("prefabs/wing/animation/%s.unity3d", self.resData.animationData.controller_id)

    self.loadCompleted = function()
        self:BuildWing()
    end

    local subResources = SubpackageManager.Instance:WingResources(self.resData)

    -- local resources = {
    --     {file = self.resData.skinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    --     , {file = self.resData.ctrlPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    -- }

    -- self.wing = CombatManager.Instance.objPool:PopUnit(string.format("%s%s",self.resData.modelPath, self.resData.wingData.wing_id))
    self.wing = GoPoolManager.Instance:Borrow(self.resData.modelPath, GoPoolType.Wing)
    if self.wing ~= nil then
        -- table.insert(resources, {file = self.resData.modelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        SubpackageManager.Instance:RemoveByFile(subResources, self.resData.modelPath)
    end

    self.effectCache = {}

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(subResources, self.loadCompleted)
end

function WingTposeLoader:__delete()
    -- if self.wing ~= nil then
    self.wingtpose = nil
    if not BaseUtils.is_null(self.wing) then
        -- GameObject.Destroy(self.wing)
        GoPoolManager.Instance:Return(self.wing, self.resData.modelPath, GoPoolType.Wing)
        self.wing = nil
    end

    for key, data in pairs(self.effectCache) do
        GoPoolManager.Instance:Return(data.effect, data.path, GoPoolType.Effect)
    end
    self.effectCache = {}

    -- if self.wingtpose ~= nil then
    -- if not BaseUtils.is_null(self.wingtpose) then
    --     GameObject.Destroy(self.wingtpose)
    --     self.wingtpose = nil
    -- end

    if self.assetWrapper ~= nil then
    	self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.wing = nil
    self.wingtpose = nil

    self.animator = nil
    self.resData.animationData = nil
    self.callback = nil
end

function WingTposeLoader:BuildWing()
    if self.assetWrapper == nil then return end

    -- local loadWingEffect = false
    local loadWingEffect = true -- 都下载
    if BaseUtils.isnull(self.wing) then
	   self.wing = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.modelPath))
       loadWingEffect = true
    end
	self.wing.name = "wing_node"
    self.wingtpose = self.wing.transform:FindChild("wing_tpose").gameObject
    local skin = self.assetWrapper:GetMainAsset(self.resData.skinPath)
    local ctrl = self.assetWrapper:GetMainAsset(self.resData.ctrlPath)
    self.wingtpose:GetComponent(Animator).runtimeAnimatorController = ctrl
    local meshNode = self.wingtpose.transform:FindChild(string.format("Mesh_%s", self.resData.wingData.model_id))
    if meshNode == nil then
        Log.Error("meshNode is nil:model_id:" .. tostring(self.resData.wingData.model_id) .. " path:" .. self.resData.modelPath)
    end
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    meshNode.renderer.material.mainTexture = skin
    self.wingtpose:GetComponent(Animator).applyRootMotion = false

    local animator = self.wingtpose:GetComponent(Animator)
    animator:Play("Fan" .. self.resData.animationData.fan_id)

    self.callback(self.wing, self.resData.animationData, { modelPath = self.resData.modelPath})

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    else
        return
    end
    if self.isEffect == nil then
        self.isEffect = true
    end
    if loadWingEffect and self.isEffect then
        self.build_effect = function()
            if self.wingtpose ~= nil and self.wingtpose:Equals(NULL) == false then
                self:BuildWingEffect()
            end
        end

    	local resources = {}
        for i=1,#self.resData.wingData.mounter do
            local ed = self.resData.wingData.mounter[i]
            local effectData = DataEffect.data_effect[ed.mounter_val]
            if effectData == nil then
                Log.Error(string.format("翅膀的特效id在特效表中找不到:%s", ed.mounter_val))
                return
            end
            local path = string.format("prefabs/effect/%s.unity3d", effectData.res_id)
            local effectCache = GoPoolManager.Instance:Borrow(path, GoPoolType.Wing)
            if effectCache == nil then
                local fileData = {file = path, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
                table.insert(resources, fileData)
            else
                self.effectCache[ed.mounter_val] = { effect = effectCache, path = path }
            end
        end

        self.assetWrapper = AssetBatchWrapper.New()
        self.assetWrapper:LoadAssetBundle(resources, self.build_effect)
    end
end

function WingTposeLoader:BuildWingEffect()
    if self.assetWrapper == nil then
        return
    end
	for i=1,#self.resData.wingData.mounter do
        local ed = self.resData.wingData.mounter[i]
        local weaponPoint = nil
        local effectData = DataEffect.data_effect[ed.mounter_val]
        local path = string.format("prefabs/effect/%s.unity3d", effectData.res_id)
        local effectCache = self.effectCache[ed.mounter_val]
        local effect = nil
        if effectCache == nil then
            effect = GameObject.Instantiate(self.assetWrapper:GetMainAsset(path))
            self.effectCache[ed.mounter_val] = { effect = effect, path = path }
        else
            effect = effectCache.effect
        end
        local tp_transform = self.wingtpose.transform

        if ed.mounter_type == EffectDataMounter.WingL1 then  --左翅膀1
             weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_l_wing1")
        elseif ed.mounter_type == EffectDataMounter.WingL2 then --左翅膀2
            weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_l_wing2")
        elseif ed.mounter_type == EffectDataMounter.WingL3 then --左翅膀3
            weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_l_wing3")
        elseif ed.mounter_type == EffectDataMounter.WingR1 then --右翅膀1
            weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_r_wing1")
        elseif ed.mounter_type == EffectDataMounter.WingR2 then --右翅膀2
            weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_r_wing2")
        elseif ed.mounter_type == EffectDataMounter.WingR3 then --右翅膀3
            weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_r_wing3")
        elseif ed.mounter_type == EffectDataMounter.Origin then --源点
            weaponPoint = BaseUtils.GetChildPath(tp_transform,"bp_wing")
        elseif ed.mounter_type == EffectDataMounter.Custom then --自定义
            weaponPoint = BaseUtils.GetChildPath(tp_transform,effectData.mounter_str)
        end
        effect.transform:SetParent(tp_transform:Find(weaponPoint))
        effect.transform.localPosition = Vector3(0, 0, 0)
        effect.transform.localRotation = Quaternion.identity
        effect.transform:Rotate(Vector3(0, 0, 0))
        effect.transform.localScale = Vector3(0.8, 0.8, 0.8)
        if self.layer ~= nil then Utils.ChangeLayersRecursively(effect.transform, self.layer) end
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

-- -- 特效挂点
-- EffectDataMounter = {
--     Origin = 0
--     ,Weapon = 1
--     ,WingL1 = 2
--     ,WingL2 = 3
--     ,WingL3 = 4
--     ,WingR1 = 5
--     ,WingR2 = 6
--     ,WingR3 = 7
--     ,Wing = 8
--     ,Custom = 9
--     ,TopOrigin = 10
-- }
