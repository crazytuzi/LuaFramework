RoleTposeLoader = RoleTposeLoader or BaseClass()

function RoleTposeLoader:__init(classes, sex, looks, callback)
    if looks == nil then
        Log.Error("[RoleTposeLoader]: looks为nil")
        Log.Error(debug.traceback())
        return
    end
    self.classes = classes
    self.sexNum = sex
    self.sex = (sex == 1 and "male" or "female")
    self.looks = looks
    self.callback = callback

    self.tpose = nil
    self.animator = nil

    self.headTpose = nil
    -- self.headAnimator = nil
    -- self.headCtrl = ""

    -- 分包逻辑需要使用的内容
    self.resData = {
        classes = classes
        ,sex = sex
        ,bodyModelId = nil
        ,headModelId = nil

        ,bodyModelPath = ""
        ,bodySkinPath = ""
        ,headModelPath = ""
        ,headSkinPath = ""

        ,headAnimationData = nil
    }

    for k, v in pairs(looks) do
        if v.looks_type == SceneConstData.looktype_hair then -- 头部
            if v.looks_val then
                local headData = DataFashion.data_base[BaseUtils.ConvertInvalidHeadModel(self.classes, self.sexNum, v.looks_val)]
                -- 不要头部动作了，只分男女
                -- self.resData.headAnimationData = DataAnimation.data_role_head_data[headData.animation_id]
                self.resData.headAnimationData = DataAnimation.data_role_head_data[self.sexNum]
                self.resData.headModelPath = string.format(SceneConstData.looksdefiner_playerheadpath, headData.model_id)
                self.resData.headModelId = BaseUtils.ConvertInvalidHeadModel(self.classes, self.sexNum, v.looks_val)
            end
            if v.looks_mode ~= 0 then
                self.resData.headSkinPath = string.format(SceneConstData.looksdefiner_playerhead_skinpath, BaseUtils.ConvertInvalidHeadSkin(self.classes, self.sexNum, v.looks_mode))
            else
                self.resData.headModelPath = ""
                self.resData.headModelId = nil
            end
        elseif v.looks_type == SceneConstData.looktype_dress then -- 衣服
            if v.looks_val then
                self.resData.bodyModelPath = string.format(SceneConstData.looksdefiner_playerbodypath, BaseUtils.ConvertInvalidDressModel(self.classes, self.sexNum, v.looks_val))
                self.resData.bodyModelId = BaseUtils.ConvertInvalidDressModel(self.classes, self.sexNum, v.looks_val)
            end

            if v.looks_mode ~= 0 then
                self.resData.bodySkinPath = string.format(SceneConstData.looksdefiner_playerbody_skinpath, BaseUtils.ConvertInvalidDressSkin(self.classes, self.sexNum, v.looks_mode))
            else
                self.resData.bodyModelPath = ""
                self.resData.bodyModelId = nil
            end
        end
    end
    self.animationData = DataAnimation.data_role_data[BaseUtils.Key(self.classes, self.sexNum)]

    self.ctrlPath = SceneConstData.looksdefiner_playerctrlpath
    -- self.headCtrl = string.format(SceneConstData.looksdefiner_headctrlpath, self.sex)

    if self.resData.headModelPath == "" then
        local looksVal = BaseUtils.default_head(self.classes, self.sexNum)
        local headData = DataFashion.data_base[looksVal]
        self.resData.headModelPath = string.format(SceneConstData.looksdefiner_playerheadpath, headData.model_id)
        -- 不要头部动作了，只分男女
        -- self.resData.headAnimationData = DataAnimation.data_role_head_data[headData.animation_id]
        self.resData.headAnimationData = DataAnimation.data_role_head_data[self.sexNum]
        self.resData.headModelId = looksVal
    end
    if self.resData.bodyModelPath == "" then
        local looksVal = BaseUtils.default_dress(self.classes, self.sexNum)
        self.resData.bodyModelPath = string.format(SceneConstData.looksdefiner_playerbodypath, looksVal)
        self.resData.bodyModelId = looksVal
    end

    if self.resData.headSkinPath == "" then
        local looksVal = BaseUtils.default_head_skin(self.classes, self.sexNum)
        self.resData.headSkinPath = string.format(SceneConstData.looksdefiner_playerhead_skinpath, looksVal)
    end
    if self.resData.bodySkinPath == "" then
        local looksVal = BaseUtils.default_dress_skin(self.classes, self.sexNum)
        self.resData.bodySkinPath = string.format(SceneConstData.looksdefiner_playerbody_skinpath, looksVal)
    end

    self.loadCompleted = function()
        self:BuildTpose()
    end

    local subResources = SubpackageManager.Instance:RoleResources(self.resData)

    -- local resources = {
    --     {file = self.resData.bodySkinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    --     ,{file = self.resData.headSkinPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()}
    -- }
    -- self.newTpose = CombatManager.Instance.objPool:PopUnit(self.resData.bodyModelPath)
    self.newTpose = GoPoolManager.Instance:Borrow(self.resData.bodyModelPath, GoPoolType.Role)
    if self.newTpose ~= nil then
        SubpackageManager.Instance:RemoveByFile(subResources, self.resData.bodyModelPath)
        -- table.insert(resources, {file = self.resData.bodyModelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
    end
    -- self.newHeadTpose = CombatManager.Instance.objPool:PopUnit(self.resData.headModelPath)
    self.newHeadTpose = GoPoolManager.Instance:Borrow(self.resData.headModelPath, GoPoolType.Head)
    if self.newHeadTpose ~= nil then
        SubpackageManager.Instance:RemoveByFile(subResources, self.resData.headModelPath)
        -- table.insert(resources, {file = self.resData.headModelPath, type = AssetType.Main, holdTime = BaseUtils.DefaultHoldTime()})
    end

    self.assetWrapper = AssetBatchWrapper.New()
    self.assetWrapper:LoadAssetBundle(subResources, self.loadCompleted)
    -- self.assetWrapper:LoadAssetBundle(resources, self.loadCompleted)
end

function RoleTposeLoader:__delete()
    if not BaseUtils.isnull(self.tpose) then
        -- GameObject.Destroy(self.tpose)
        GoPoolManager.Instance:Return(self.tpose, self.resData.bodyModelPath, GoPoolType.Role)
    end
    self.tpose = nil

    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end

    if not BaseUtils.isnull(self.headTpose) then
        -- GameObject.Destroy(self.headTpose)
        GoPoolManager.Instance:Return(self.headTpose, self.resData.headModelPath, GoPoolType.Head)
    end
    self.headTpose = nil

    self.tpose = nil
    self.animator = nil

    self.headTpose = nil
    self.headAnimator = nil
    if self.resData ~= nil then
        self.resData.headAnimationData = nil
        self.resData = nil
    end
    self.callback = nil
end

function RoleTposeLoader:BuildTpose()
    if self.assetWrapper == nil then return end

    local newTpose = self.newTpose
    if newTpose == nil then
        newTpose = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.bodyModelPath).transform:FindChild("tpose").gameObject)
        newTpose.transform.localPosition = Vector3(5, -5, 0)
    end
    local skin = self.assetWrapper:GetMainAsset(self.resData.bodySkinPath)
    local meshNode = newTpose.transform:FindChild(string.format("Mesh_%s", self.resData.bodyModelId))
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    meshNode.renderer.material.mainTexture = skin
    local ctrl = PreloadManager.Instance:GetMainAsset(self.ctrlPath)
    local animator = newTpose:GetComponent(Animator)
    animator.runtimeAnimatorController = ctrl
    animator.applyRootMotion = false
    self.animator = animator
    self.tpose = newTpose
    if self.animationData ~= nil then
        self.animator:Play("Stand" .. self.animationData.stand_id)
    end

    newTpose = self.newHeadTpose
    if newTpose == nil then
        newTpose = GameObject.Instantiate(self.assetWrapper:GetMainAsset(self.resData.headModelPath).transform:FindChild("tpose").gameObject)
    end
    skin = self.assetWrapper:GetMainAsset(self.resData.headSkinPath)
    meshNode = newTpose.transform:FindChild(string.format("Mesh_%s", self.resData.headModelId))
    BaseUtils.ChangeShaderForOldVersion(meshNode.renderer.material)
    meshNode.renderer.material.mainTexture = skin
    -- ctrl = PreloadManager.Instance:GetMainAsset(self.headCtrl)
    animator = newTpose:GetComponent(Animator)
    -- animator.runtimeAnimatorController = ctrl
    animator.applyRootMotion = false
    -- self.headAnimator = animator
    self.headTpose = newTpose
    -- if self.resData.headAnimationData ~= nil then
    --     self.headAnimator:Play(self.resData.headAnimationData.stand_id)
    -- end
    self:bindHead()

    self.callback(self.animationData, self.tpose, self.resData.headAnimationData, self.headTpose, { modelPath = self.resData.bodyModelPath, headPath = self.resData.headModelPath})

    if not BaseUtils.isnull(self.headTpose) then
        self.headTpose:SetActive(false)
        LuaTimer.Add(30, function()
            if not BaseUtils.isnull(self.headTpose) then
                self.headTpose:SetActive(true)
            end
        end)
    end
    
    if self.assetWrapper ~= nil then
        self.assetWrapper:DeleteMe()
        self.assetWrapper = nil
    end
end

function RoleTposeLoader:bindHead()
    local path = BaseUtils.GetChildPath(self.tpose.transform, "Bip_Head")
    local mounter = self.tpose.transform:Find(path)
    local headTran = self.headTpose.transform
    headTran:SetParent(mounter)
    headTran.localPosition = Vector3(0, 0, 0)
    headTran.localScale = Vector3(1, 1, 1)
    headTran.localRotation = Quaternion.identity
    headTran:Rotate(Vector3(90, 0, 0))
end


