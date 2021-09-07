HomeTposeLoader = HomeTposeLoader or BaseClass()

function HomeTposeLoader:__init(skinId, modelId, animationId, scale, callback)
    self.resData = {
        skinId = skinId
        ,modelId = modelId
        ,animationId = animationId
        ,animationData = nil

        ,skinPath = ""
        ,modelPath = ""
        
    }

    self.scale = scale
    self.callback = callback

    self.resData.animationData = DataAnimation.data_npc_data[self.resData.animationId]
    if self.resData.animationData ~= nil then
        self.resData.ctrlPath = string.format("prefabs/npc/animation/%s.unity3d", self.resData.animationData.controller_id)
    end
    self.resData.skinPath = string.format("prefabs/npc/skin/%s.unity3d", self.resData.skinId)
    self.resData.modelPath = string.format("prefabs/npc/model/%s.unity3d", self.resData.modelId)

    local loadCompleted = function()
        self:BuildTpose()
    end

    local subResources = SubpackageManager.Instance:HomeResources(self.resData)

    -- self.newTpose = CombatManager.Instance.objPool:PopUnit(self.resData.modelPath)
    -- if self.newTpose ~= nil then
    --     SubpackageManager.Instance:RemoveByFile(subResources, self.resData.modelPath)
    -- end
    
    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(subResources, loadCompleted)
end

function HomeTposeLoader:__delete()
    if self.tpose ~= nil then
        GameObject.Destroy(self.tpose)
        self.tpose = nil
    end
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    self.callback = nil
    self.resData = nil
end

function HomeTposeLoader:BuildTpose()
    if self.assetWrapper == nil then return end

    local newTpose = self.newTpose
    if newTpose == nil then
        newTpose = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.modelPath).transform:FindChild("tpose").gameObject)
    end
    self.tpose = newTpose
    local skin = self.assetWrapper:GetMainAsset(self.resData.skinPath)

    local meshNode = newTpose.transform:FindChild(string.format("Mesh_%s", self.resData.modelId))
    meshNode.renderer.material.mainTexture = skin;
    if self.resData.animationData ~= nil then
        local ctrl = self.assetWrapper:GetMainAsset(self.resData.ctrlPath)
        newTpose:GetComponent(Animator).runtimeAnimatorController = ctrl
        newTpose:GetComponent(Animator).applyRootMotion = false;
        local animator = newTpose:GetComponent(Animator);
        animator:Play("Stand" .. self.resData.animationData.stand_id);
    end

    newTpose.transform.localScale = Vector3(self.scale, self.scale, self.scale)
    if self.callback ~= nil then
        self.callback(newTpose, self.resData.animationData, { modelPath = self.resData.modelPath, modelId = self.resData.modelId})
    end
    
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end
