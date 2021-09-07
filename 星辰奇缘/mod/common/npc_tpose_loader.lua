NpcTposeLoader = NpcTposeLoader or BaseClass()

function NpcTposeLoader:__init(skinId, modelId, animationId, scale, callback)
    self.resData = {
        skinId = skinId
        ,modelId = modelId
        ,animationId = animationId
        ,animationData = nil

        ,skinPath = ""
        ,modelPath = ""
        ,ctrlPath = ""

    }

    self.scale = scale
    self.callback = callback

    self.resData.animationData = DataAnimation.data_npc_data[self.resData.animationId]
    if self.resData.animationData == nil then
        Log.Error("缺少AnimationData信息(animation_data表)[animationId:" .. self.resData.animationId .. ", skinId:" .. self.resData.skinId .. " , modelId:" .. self.resData.modelId .. "]")
        return
    end
    self.resData.skinPath = string.format("prefabs/npc/skin/%s.unity3d", self.resData.skinId)
    self.resData.modelPath = string.format("prefabs/npc/model/%s.unity3d", self.resData.modelId)
    self.resData.ctrlPath = string.format("prefabs/npc/animation/%s.unity3d", self.resData.animationData.controller_id)
    -- 如果是守护(controller_id == 99999),则使用人物动作
    if self.resData.animationData.controller_id == 99999 then
        self.resData.ctrlPath = SceneConstData.looksdefiner_playerctrlpath
    end

    local loadCompleted = function()
        self:BuildTpose()
    end

    local subResources = SubpackageManager.Instance:NpcResources(self.resData)
    -- local resources = {
    --     {file = self.resData.skinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    --     ,{file = self.resData.ctrlPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    -- }

    -- self.newTpose = CombatManager.Instance.objPool:PopUnit(self.resData.modelPath)
    self.newTpose = GoPoolManager.Instance:Borrow(self.resData.modelPath, GoPoolType.Npc)
    if self.newTpose ~= nil then
        -- table.insert(resources, {file = self.resData.modelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
        SubpackageManager.Instance:RemoveByFile(subResources, self.resData.modelPath)
    end

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(subResources, loadCompleted)
end

function NpcTposeLoader:__delete()
    -- if self.tpose ~= nil then
    --     GameObject.Destroy(self.tpose)
    --     self.tpose = nil
    -- end
    self.meshNode = nil
    self.animator = nil
    if not BaseUtils.is_null(self.tpose) then
        GoPoolManager.Instance:Return(self.tpose, self.resData.modelPath, GoPoolType.Npc)
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end


    self.callback = nil
    self.resData.animationData = nil
end

function NpcTposeLoader:BuildTpose()
    if self.assetWrapper == nil then return end

    local newTpose = self.newTpose
    if newTpose == nil then
        newTpose = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.modelPath).transform:FindChild("tpose").gameObject)
    end
    if newTpose == nil then
        Log.Error(string.format("取不到模型tpose,此模型id为%s",self.resData.modelId))
    end
    self.tpose = newTpose
    local skin = self.assetWrapper:GetMainAsset(self.resData.skinPath)
    local ctrl = self.assetWrapper:GetMainAsset(self.resData.ctrlPath)
    newTpose:GetComponent(Animator).runtimeAnimatorController = ctrl
    local meshNode = newTpose.transform:FindChild(string.format("Mesh_%s", self.resData.modelId))
    meshNode.renderer.material.mainTexture = skin;
    newTpose:GetComponent(Animator).applyRootMotion = false;
    local animator = newTpose:GetComponent(Animator);
    animator:Play("Stand" .. self.resData.animationData.stand_id);
    newTpose.transform.localScale = Vector3(self.scale, self.scale, self.scale)
    if self.callback ~= nil then
        self.callback(newTpose, self.resData.animationData, { modelPath = self.resData.modelPath, meshNode = meshNode })
    end

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end
