-- 定义点特效
StaticEffect = StaticEffect or BaseClass(CombatBaseAction)

-- attacker = GameObject
-- target = GameObject
function StaticEffect:__init(brocastCtx, minotaction, actionData, attacker, target, sEffectData, effectObject)
    self.minor = minotaction
    self.sEffectData = sEffectData
    self.actionData = actionData
    self.effectList = {}
    self.attacker = attacker
    self.target = target
    self.baseEffectObject = effectObject
    self.res_id = effectObject.res_id
    -- self.effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
    self.effectPath = CombatUtil.GetSubpackEffect(effectObject.res_id, self.minor.subpkgEffectDict)
    self.shaker = {transform = nil}
    self.endTime = 800
    self.pointInfo = self:GetSkillEffectInfo(actionData, self.baseEffectObject.id)
    if self.pointInfo ~= nil then
        self.endTime = self.pointInfo.end_time
    else
        -- local motionId = self.brocastCtx.majorCtx:GetMotionId(actionData)
        -- Log.Error("[战斗]缺少技能特效信息(skill_effect_data)或者该技能没有攻击特效但有普通特效：skillId:" .. actionData.skill_id .. " motionId:" .. motionId)
    end

    self.triggerHit = SyncSupporter.New(brocastCtx)
end

function StaticEffect:Play()
    self:InvokeAndClear(CombatEventType.Start)
    local attacker = self.attacker
    local target = self.target
    if BaseUtils.is_null(attacker) or BaseUtils.is_null(target) then
        return
    end
    local attackTransform = attacker.transform:FindChild("tpose") == nil and attacker.transform or attacker.transform:FindChild("tpose")
    local targetTransform = target.transform:FindChild("tpose") == nil and target.transform or target.transform:FindChild("tpose")

    -- local effectObject = CombatManager.Instance.objPool:Pop(self.res_id)
    local effectObject = GoPoolManager.Instance:Borrow(self.effectPath, GoPoolType.Effect)
    if effectObject == nil then
        local effectPrefab = self.minor.assetwrapper:GetMainAsset(self.effectPath)
        if effectPrefab == nil then
            Log.Error("StaticEffect读不到特效资源:" .. self.effectPath)
        else
            effectObject = GameObject.Instantiate(effectPrefab)
        end
    end



    if not BaseUtils.isnull(effectObject) then
        table.insert(self.effectList, {go = effectObject, path = self.res_id})

        local targetFighterId = 0
        if self.sEffectData.target == EffectTarget.Attacker then
            targetFighterId = self.actionData.self_id
            if self.sEffectData.target_point == EffectTargetPoint.Weapon then
                local attackCtrl = self:FindFighter(self.actionData.self_id)
                self:BindWeapon(attacker, attackCtrl, effectObject)
            elseif self.sEffectData.target_point == EffectTargetPoint.LHand then
                CombatUtil.BindMounter(attackTransform, effectObject, "Bip_L_Hand")
            elseif self.sEffectData.target_point == EffectTargetPoint.RHand then
                CombatUtil.BindMounter(attackTransform, effectObject, "Bip_R_Hand")
            elseif self.sEffectData.target_point == EffectTargetPoint.LFoot then
                CombatUtil.BindMounter(attackTransform, effectObject, "Bip_L_Foot")
            elseif self.sEffectData.target_point == EffectTargetPoint.RFoot then
                CombatUtil.BindMounter(attackTransform, effectObject, "Bip_R_Foot")
            elseif self.sEffectData.target_point == EffectTargetPoint.Custom then
                CombatUtil.BindMounter(attackTransform, effectObject, self.sEffectData.custom_mounter)
            else
                effectObject.transform:SetParent(attackTransform)
            end
        else
            targetFighterId = self.actionData.target_id
            if self.sEffectData.target_point == EffectTargetPoint.Weapon then
                local attackCtrl = self:FindFighter(self.actionData.target_id)
                self:BindWeapon(target, attackCtrl, effectObject)
            elseif self.sEffectData.target_point == EffectTargetPoint.LHand then
                CombatUtil.BindMounter(targetTransform, effectObject, "Bip_L_Hand")
            elseif self.sEffectData.target_point == EffectTargetPoint.RHand then
                CombatUtil.BindMounter(targetTransform, effectObject, "Bip_R_Hand")
            elseif self.sEffectData.target_point == EffectTargetPoint.LFoot then
                CombatUtil.BindMounter(targetTransform, effectObject, "Bip_L_Foot")
            elseif self.sEffectData.target_point == EffectTargetPoint.RFoot then
                CombatUtil.BindMounter(targetTransform, effectObject, "Bip_R_Foot")
            elseif self.sEffectData.target_point == EffectTargetPoint.Custom then
                CombatUtil.BindMounter(targetTransform, effectObject, self.sEffectData.custom_mounter)
            else
                effectObject.transform:SetParent(targetTransform)
            end
        end
        effectObject.transform.localScale = Vector3(1, 1, 1)
        effectObject.transform.localPosition = Vector3(0, 0, 0)
        effectObject.transform.localRotation = Quaternion.identity
        if self.baseEffectObject.overlay ~= 1 then
            Utils.ChangeLayersRecursively(effectObject.transform, "CombatModel")
        else
            Utils.ChangeLayersRecursively(effectObject.transform, "Ignore Raycast")
        end
        effectObject:SetActive(false)
        if self.sEffectData.effect_type == EffectType.HitFlyEffect then
            local transform = effectObject.transform:FindChild("FatherShaker/Shaker")
            if transform ~= nil then
                self.shaker.transform = transform
            else
                Log.Error("[战斗]击飞特效缺少FatherShaker/Shaker挂点[effectId:" .. self.baseEffectObject.id .. "]")
            end
        end
    end

    -- 是否透明
    -- if self.baseEffectObject.id == 120311 and targetFighterId ~= 0 then
    if self.baseEffectObject.id == nil and targetFighterId ~= 0 then
        local setalpha1 = SetAlphaAction.New(self.brocastCtx, targetFighterId, 0)
        local setalpha2 = SetAlphaAction.New(self.brocastCtx, targetFighterId, 1)
        local delay = DelayAction.New(self.brocastCtx, 800)
        setalpha1:AddEvent(CombatEventType.End, delay)
        delay:AddEvent(CombatEventType.End, setalpha2)
        self.triggerHit:AddAction(setalpha1)
    end
    self:DoPlay()
end

function StaticEffect:DoPlay()
    for _, effect in ipairs(self.effectList) do
        if not BaseUtils.isnull(effect.go) then
            effect.go:SetActive(true)
        end
    end
    if self.sEffectData.hit_delay > 0 then
        self:InvokeDelay(self.OnHit, self.sEffectData.hit_delay / 1000, self)
    else
        self:InvokeAndClear(CombatEventType.Hit)
    end
    if self.sEffectData.delay_time > 0 then
        self:InvokeDelay(self.OnActionEnd, self.sEffectData.delay_time / 1000, self)
    else
        self:OnActionEnd()
    end
end

function StaticEffect:OnHit()
    self.triggerHit:Play()
    self:InvokeAndClear(CombatEventType.Hit)
end

function StaticEffect:OnActionEnd()
    for _, effect  in ipairs(self.effectList) do
        self:InvokeDelay(function()                 --[[print("销毁特效:"..effect.name.."||"..tostring(self.endTime)) ]]
                -- GameObject.DestroyImmediate(effect.go)
                if not BaseUtils.isnull(effect.go) then
                    -- CombatManager.Instance.objPool:Push(effect.go, self.res_id)
                    GoPoolManager.Instance:Return(effect.go, self.effectPath, GoPoolType.Effect)
                end
            end
        , self.endTime / 1000)
    end
    self:InvokeAndClear(CombatEventType.End)
end

function StaticEffect:GetShaker()
    return self.shaker
end

function StaticEffect:BindWeapon(bind, bindCtrl, effect)
    if bindCtrl == nil or BaseUtils.isnull(bind) then
        return
    end
    local fighterData = bindCtrl.fighterData
    local attackTransform = bind.transform:FindChild("tpose") == nil and bind.transform or bind.transform:FindChild("tpose")
    local weaponPoint = ""
    if fighterData.classes == CombatClasses.Gladiator then
        local leffect = self:CreateEffect(effect, attackTransform, "Bip_L_Weapon")
        table.insert(self.effectList, {go = leffect,  path = self.effectPath})
        local rpath = BaseUtils.GetChildPath(attackTransform.transform, "Bip_R_Weapon")
        local rweapon = attackTransform:Find(rpath)
        if rweapon ~= nil then
            effect.transform:SetParent(rweapon)
        else
            effect.transform:SetParent(attackTransform)
        end
    elseif fighterData.classes == CombatClasses.Ranger or fighterData.classes == CombatClasses.Devine then
        weaponPoint = BaseUtils.GetChildPath(attackTransform, "Bip_L_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    else
        weaponPoint = BaseUtils.GetChildPath(attackTransform, "Bip_R_Weapon")
        effect.transform:SetParent(attackTransform:Find(weaponPoint))
    end
end

function StaticEffect:CreateEffect(base, tpose, mountPoint)
    local mountPath = BaseUtils.GetChildPath(tpose, mountPoint)
    local effect = GoPoolManager.Instance:Borrow(self.effectPath, GoPoolType.Effect)
    if effect == nil then
        effect= GameObject.Instantiate(base)
    end
    Utils.ChangeLayersRecursively(effect.transform, "CombatModel")
    local wt = effect.transform
    local weapon = tpose.transform:Find(mountPath)
    if weapon ~= nil then
        wt:SetParent(weapon)
    else
        wt:SetParent(tpose.transform)
    end
    wt.localPosition = Vector3.zero
    wt.localRotation = Quaternion.identity
    wt.localScale = Vector3(1, 1, 1)
    wt.localPosition = Vector3(0, 0, 0)
    effect:SetActive(false)
    return effect
end

function StaticEffect:BindMounter()
end
