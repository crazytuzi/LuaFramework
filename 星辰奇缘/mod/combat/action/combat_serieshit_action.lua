-- 连击特效 幻影疾风
SeriesHitAction = SeriesHitAction or BaseClass(CombatBaseAction)

function SeriesHitAction:__init(brocastCtx, majorCtx, minorAction, actionData, skillEffect)
    self.majorCtx = majorCtx
    self.minorAction = minorAction
    self.actionData = actionData
    self.skillEffect = skillEffect
    self.effectObject = brocastCtx.combatMgr:GetEffectObject(skillEffect.effect_id)
    self.protectData = minorAction.protectData

    self.effect = nil
    self.isSelfEffect = true

    -- 处理音效
    local motionId = self.majorCtx:GetMotionId(actionData)
    local soundDataList = self.brocastCtx.combatMgr:GetSoundData(self.actionData.skill_id, motionId)
    self.soundData = nil
    if soundDataList ~= nil then
        for _, sdata in ipairs(soundDataList) do
            if sdata.moment == 2 or sdata.moment == 3 then
                self.soundData = sdata
            end
        end
    end

    self.endSupporter = TaperSupporter.New(brocastCtx)
    self.endSupporter:AddEvent(CombatEventType.End, self.OnActionEnd, self)
end

function SeriesHitAction:Parse()
    if self.effect == nil then
        local attacker = self:FindFighter(self.actionData.self_id).transform.gameObject
        local defense = self:GetEffectTarget(self.actionData, self.skillEffect)
        self.effect = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.actionData, attacker, defense, self.skillEffect, self.effectObject)
    end
    local hurtList = self.skillEffect.hurt_ratio
    if #hurtList > 1 then
        local total = 0
        for _, val in ipairs(hurtList) do
            total = total + val[2]
        end
        total = (total == 0 and 1 or total)
        if self.skillEffect.effect_type == EffectType.HitFlyEffect then
            if self.actionData.is_hit == 1 then
                -- BaseUtils.dump(self.effect)
                self:ParseHitFlyEffect(hurtList, total)
            else
                local evasion = EvasionAction.New(self.brocastCtx, self.actionData)
                evasion:AddEvent(CombatEventType.End, self.endSupporter)
                self.effect:AddEvent(CombatEventType.Hit, evasion)
            end
        else
            if self.actionData.is_hit == 1 then
                self:ParseSeriesHitEffect(hurtList, total)
            else
                local delay = nil
                local ratio = nil
                local lastNode = nil
                for _, val in ipairs(hurtList) do
                    ratio = val
                    delay = DelayAction.New(self.brocastCtx, ratio[1])
                    if lastNode == nil then
                        self.effect:AddEvent(CombatEventType.Hit, delay)
                        lastNode = delay
                    else
                        lastNode:AddEvent(CombatEventType.End, delay)
                        lastNode = delay
                    end
                    local evasion = EvasionAction.New(self.brocastCtx, self.actionData)
                    evasion:AddEvent(CombatEventType.End, self.endSupporter)
                    delay:AddEvent(CombatEventType.End, evasion)
                end
            end
        end
    else
        if self.actionData.is_hit == 1 then
            local targetAttrChangeEffect = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, 1, true)
            local hit = HitAction.New(self.brocastCtx, self.actionData)
            hit:AddEvent(CombatEventType.End, self.endSupporter)
            self.effect:AddEvent(CombatEventType.Hit, hit)
            self.effect:AddEvent(CombatEventType.Hit, targetAttrChangeEffect)
            self.effect:AddEvent(CombatEventType.End, self.endSupporter)

            if self.skillEffect.shake == 1 or self.actionData.is_crit == 1 then
                self.effect:AddEvent(CombatEventType.End, ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            else
                -- self.effect:AddEvent(CombatEventType.End, ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
            end

            if self.soundData ~= nil then
                self.effect:AddEvent(CombatEventType.Hit, SoundAction.New(self.brocastCtx, self.soundData))
            end
        else
            local evasion = EvasionAction.New(self.brocastCtx, self.actionData)
            local targetAttrChangeEffect = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, 1, true)
            evasion:AddEvent(CombatEventType.End, targetAttrChangeEffect)
            evasion:AddEvent(CombatEventType.End, self.endSupporter)
            effect:AddEvent(CombatEventType.Hit, evasion)
        end
    end
end

function SeriesHitAction:Play()
    self:InvokeAndClear(CombatEventType.Start)
    if self.isSelfEffect then
        self.effect:Play()
    end
end

function SeriesHitAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function SeriesHitAction:ParseSeriesHitEffect(hurtList, total)
    local syncHitAction = SyncSupporter.New(self.brocastCtx)
    local beforeSync = SyncSupporter.New(self.brocastCtx)
    local hit = nil
    local lastNode = nil
    local ratio = hurtList[1]

    local lastProtect = nil
    local protectMove = nil

    local targetAttrChangeEffect = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, ratio[2] / total, true)
    syncHitAction:AddAction(targetAttrChangeEffect)
    self.effect:AddEvent(CombatEventType.Hit, syncHitAction)
    self.effect:AddEvent(CombatEventType.Start, beforeSync)
    -- 震屏
    if self.skillEffect.shake == 1 or self.actionData.is_crit == 1 then
        syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
    else
        -- syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
    end
    if self.actionData.is_defence == 1 then
        syncHitAction:AddAction(DefenseAction.New(self.brocastCtx, self.actionData))
    else
        hit = HitAction.New(self.brocastCtx, self.actionData, false)
        hit.isFianl = false
        syncHitAction:AddAction(hit)

        if self.soundData ~= nil then
            syncHitAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
        end
    end
    -- 保护
    if self.protectData ~= nil then
        for i,pData in ipairs(self.protectData) do
            if pData.target_id == self.actionData.target_id then
                lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncHitAction, pData, false)
                protectMove = true
                ProtectAction.MoveBack(self.brocastCtx, pData, lastProtect)
            end
        end
        -- lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncHitAction, self.protectData, false)
        -- protectMove = true
    end
    for i = 2, #hurtList do
        ratio = hurtList[i]
        local syncHitAction = SyncSupporter.New(self.brocastCtx)
        local delay = DelayAction.New(self.brocastCtx, ratio[1])
        if self.actionData.is_defence == 1 then
            syncHitAction:AddAction(DefenseAction.New(self.brocastCtx, self.actionData))
        else
            hit = HitAction.New(self.brocastCtx, self.actionData, i==#hurtList)
            hit.isFianl = false
            syncHitAction:AddAction(hit)

            if self.soundData ~= nil then
                syncHitAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
            end
        end
        -- 保护
        -- if self.protectData ~= nil and self.protectData.target_id == self.actionData.target_id then
        --     lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncHitAction, self.protectData, true)
        -- end

        if lastNode == nil then
            self.effect:AddEvent(CombatEventType.Hit, delay)
            lastNode = delay
        else
            lastNode:AddEvent(CombatEventType.End, delay)
            lastNode = delay
        end
        local attrEffect = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, ratio[2] / total, true)
        syncHitAction:AddAction(attrEffect)

        if self.skillEffect.shake == 1 or self.actionData.is_crit == 1 then
            syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
        else
            -- syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
        end

        delay:AddEvent(CombatEventType.End, syncHitAction)

        -- 总伤害
        if i == #hurtList then
            local totalHurtAction = CombatTotalHurtAction.New(self.brocastCtx, self.actionData)
            local delayTotal = DelayAction.New(self.brocastCtx, 500)
            delayTotal:AddEvent(CombatEventType.End, totalHurtAction)
            syncHitAction:AddAction(delayTotal)
        end
    end
    -- if protectMove and lastProtect ~= nil then

    --     ProtectAction.MoveBack(self.brocastCtx, self.protectData, lastProtect)
    -- end
    -- 漂字
    if hit ~= nil then
        hit.isFianl = true
        local targetCtrl = self:FindFighter(self.actionData.target_id)
        local gotoAction = GoToAction.New(self.brocastCtx, targetCtrl, targetCtrl.originPos)
        hit:AddEvent(CombatEventType.End, gotoAction)
    end
    lastNode:AddEvent(CombatEventType.End, self.endSupporter)
    self.effect:AddEvent(CombatEventType.End, self.endSupporter)
end

function SeriesHitAction:ParseHitFlyEffect(hurtList, total)
    local beforeSync = SyncSupporter.New(self.brocastCtx) --保护或者其它动作提前
    local syncHitAction = SyncSupporter.New(self.brocastCtx)
    local hitFly = HitFlyAction.New(self.brocastCtx, self.actionData)
    hitFly.shaker = self.effect:GetShaker()
    self.effect:AddEvent(CombatEventType.End, hitFly.OnActionEnd, hitFly)
    local firstRatio = hurtList[1]

    local protectMove = false
    local lastProtect = nil

    local targetAttrChangeEffect = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, firstRatio[2] / total, true)

    self.effect:AddEvent(CombatEventType.Hit, syncHitAction)
    self.effect:AddEvent(CombatEventType.Start, beforeSync)
    syncHitAction:AddAction(hitFly)
    syncHitAction:AddAction(targetAttrChangeEffect)

    -- 震屏
    if self.skillEffect.shake == 1 or self.actionData.is_crit == 1 then
        syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
    else
        -- syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
    end

    if self.soundData ~= nil then
        syncHitAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
    end

    -- 防御特效
    -- 保护
    if self.protectData ~= nil and self.protectData.target_id == self.actionData.target_id then
        lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncHitAction, self.protectData, false)
        protectMove = true
    end

    local delay = nil
    local lastNode = nil
    for i = 2, #hurtList do
        local hitRatio = hurtList[i]
        delay = DelayAction.New(self.brocastCtx, hitRatio[1])
        if lastNode == nil then
            self.effect:AddEvent(CombatEventType.Hit, delay)
            lastNode = delay
        else
            lastNode:AddEvent(CombatEventType.End, delay)
            lastNode = delay
        end
        targetAttrChangeEffect = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, hitRatio[2] / total, true)
        delay:AddEvent(CombatEventType.End, targetAttrChangeEffect)

        -- 震屏
        if self.skillEffect.shake == 1 or self.actionData.is_crit == 1 then
            delay:AddEvent(CombatEventType.End, ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
        else
            -- delay:AddEvent(CombatEventType.End, ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
        end

        -- 总伤害
        if i == #hurtList then
            local totalHurtAction = CombatTotalHurtAction.New(self.brocastCtx, self.actionData)
            local delayTotal = DelayAction.New(self.brocastCtx, 500)
            delayTotal:AddEvent(CombatEventType.End, totalHurtAction)
            delay:AddEvent(CombatEventType.End, delayTotal)
        end
    end
    -- 保护
    if protectMove and lastProtect ~= nil then
        ProtectAction.MoveBack(self.brocastCtx, self.protectData, lastProtect)
    end
    lastNode:AddEvent(CombatEventType.End, self.endSupporter)
    hitFly:AddEvent(CombatEventType.End, self.endSupporter)
    self.effect:AddEvent(CombatEventType.End, self.endSupporter)
end













