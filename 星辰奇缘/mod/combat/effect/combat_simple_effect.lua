-- 简单特效

SimpleEffect = SimpleEffect or BaseClass(CombatBaseAction)

function SimpleEffect:__init(brocastCtx, actionData, effectObject, minorAction)
    self.brocastCtx = brocastCtx
    self.actionData = actionData
    self.targetCtrl = self:FindFighter(actionData.target_id)
    self.assetwrapper = minorAction.assetwrapper
    if self.targetCtrl ~= nil then
        self.target = self.targetCtrl.transform:FindChild("tpose").gameObject
    end
    self.effectObject = effectObject
    self.res_id = effectObject.res_id
    -- self.effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
    self.effectPath = CombatUtil.GetSubpackEffect(effectObject.res_id, minorAction.subpkgEffectDict)
    self.effectObject = nil
end

function SimpleEffect:Play()
    if self.targetCtrl == nil or BaseUtils.isnull(self.targetCtrl.transform) or BaseUtils.isnull(self.targetCtrl.transform:FindChild("tpose")) then
        self:InvokeDelay(self.OnActionEnd, 200 / 1000, self)
        Log.Info("特效找不到依附对象")
        return
    end
    self:InvokeDelay(self.OnActionEnd, 200 / 1000, self)

    -- self.effectObject = CombatManager.Instance.objPool:Pop(self.res_id)
    self.effectObject = GoPoolManager.Instance:Borrow(self.effectPath, GoPoolType.Effect)
    if self.effectObject == nil then
        local effectPrefab = self.assetwrapper:GetMainAsset(self.effectPath)
        self.effectObject = GameObject.Instantiate(effectPrefab)
    end
    self.targetCtrl = self:FindFighter(self.actionData.target_id)
    if self.targetCtrl ~= nil then
        self.target = self.targetCtrl.transform:FindChild("tpose").gameObject
    end
    self.effectObject.transform:SetParent(self.target.transform)
    self.effectObject.transform.localScale = Vector3(1, 1, 1)
    self.effectObject.transform.localPosition = Vector3(0, 0, 0)
    self.effectObject.transform.localRotation = Quaternion.identity
    Utils.ChangeLayersRecursively(self.effectObject.transform, "CombatModel")
    self.effectObject:SetActive(true)
end

function SimpleEffect:OnActionEnd()
    -- self:InvokeDelay(function() if self.effectObject ~= nil then GameObject.DestroyImmediate(self.effectObject) end end, 300 / 1000)
    self:InvokeDelay(function()
        if self.effectObject ~= nil then
            -- CombatManager.Instance.objPool:Push(self.effectObject, self.res_id)
            GoPoolManager.Instance:Return(self.effectObject, self.effectPath, GoPoolType.Effect)
        end
    end,
    300 / 1000)
    self:InvokeAndClear(CombatEventType.End)
end
