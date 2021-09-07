-- 飞行特效
FlyEffect = FlyEffect or BaseClass(CombatBaseAction)

-- attacker = GameObject
-- target = GameObject
function FlyEffect:__init(brocastCtx, minoraction,actionData, attacker, target, sEffectData, effectObject)
    self.minor = minoraction
    -- self.actionData = actionData
    self.attacker = attacker
    self.target = target
    self.sEffectData = sEffectData
    self.effectObject = effectObject
    self.res_id = effectObject.res_id
    -- self.effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
    self.effectPath = CombatUtil.GetSubpackEffect(effectObject.res_id, minoraction.subpkgEffectDict)

    self.attackPos = attacker.transform.position
    self.targetPos = target.transform.position

    self.flyer = nil
    self.isFlyEffect = true
end

function FlyEffect:Play()
    self:InvokeAndClear(CombatEventType.Start)
    -- self.flyer = CombatManager.Instance.objPool:Pop(self.res_id)
    self.flyer = GoPoolManager.Instance:Borrow(self.effectPath, GoPoolType.Effect)
    if self.flyer == nil then
        local effectPrefab = self.minor.assetwrapper:GetMainAsset(self.effectPath)
        if effectPrefab == nil then
            Log.Error("缺少特效资源res_id:" .. self.effectObject.res_id)
        end
        self.flyer = GameObject.Instantiate(effectPrefab)
    else
        local fctrl = self.flyer:GetComponent(LuaBehaviourDownUpBase)
        GameObject.Destroy(fctrl)
    end
    if BaseUtils.isnull(self.flyer) or BaseUtils.isnull(self.attacker) or BaseUtils.isnull(self.attacker.transform) or BaseUtils.isnull(self.attacker.transform:FindChild("tpose")) then
        self:OnActionEnd()
        return
    end
    if self.sEffectData.attack_type == EffectAttackType.Thunder or self.sEffectData.attack_type == EffectAttackType.MuiltThunder or self.sEffectData.attack_type == EffectAttackType.Bubble1 or self.sEffectData.attack_type == EffectAttackType.Bubble2 then
        self.flyer.transform.position = self.attacker.transform.position
        self.flyer.transform.localScale = Vector3(1, 1, 1)
    else
        self.flyer.transform:SetParent(self.attacker.transform:FindChild("tpose").transform)
        self.flyer.transform.localScale = Vector3(1, 1, 1)
        self.flyer.transform.localPosition = Vector3(0, 0, 0)
        self.flyer.transform.localRotation = Quaternion.identity
    end
    if self.effectObject.overlay ~= 1 then
        Utils.ChangeLayersRecursively(self.flyer.transform, "CombatModel")
    else
        Utils.ChangeLayersRecursively(self.flyer.transform, "Ignore Raycast")
    end
    -- local fctrl = self.flyer:AddComponent(LuaBehaviourDownUpBase)
    -- local flyController = fctrl:SetClass("FlyController")
    local flyController = FlyController.New()
    flyController:AfterInit(self.flyer.transform)
    -- flyController:Setting(self.attackPos, self.targetPos, self.sEffectData.fly_time)
    flyController:Setting(self.attackPos, self.target, self.sEffectData.fly_time, self.sEffectData.attack_type == EffectAttackType.Thunder) -- 飞行特效目标点改为传递gameObject
    flyController:Start()
    flyController:AddMoveEndListener(function() self:OnMoveEnd() end)
    self.flyer:SetActive(true)
end

function FlyEffect:HideEffect()
    if self.flyer then
        self.flyer:SetActive(false)
    end
end

function FlyEffect:OnMoveEnd()
    if BaseUtils.isnull(self.target) then
        return self:OnActionEnd()
    end
    local dis = Vector3.Distance(self.attackPos, self.target.transform.position)
    if dis < 2 then
        self.fast = true
    end
    if self.sEffectData.hit_delay > 0 and dis > 2 then
        self:InvokeDelay(function() self:InvokeAndClear(CombatEventType.Hit) end, self.sEffectData.hit_delay / 1000)
    else
        self:InvokeAndClear(CombatEventType.Hit)
    end
    self:InvokeAndClear(CombatEventType.MoveEnd)

    if self.sEffectData.delay_time == 0 or dis < 2 then
        self:OnActionEnd()
    else
        self:InvokeDelay(self.OnActionEnd, self.sEffectData.delay_time / 1000, self)
    end
end

function FlyEffect:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
    self:InvokeDelay(function()
            if self.flyer ~= nil then
                -- CombatManager.Instance.objPool:Push(self.flyer, self.res_id)
                GoPoolManager.Instance:Return(self.flyer, self.effectPath, GoPoolType.Effect)
            end
        end
        ,0.8
    )
end
