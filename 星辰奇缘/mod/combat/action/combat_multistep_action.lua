-- 多段攻击特效
MultiStepAction = MultiStepAction or BaseClass(CombatBaseAction)

function MultiStepAction:__init(brocastCtx, minorAction, actionData, skillEffectList)
    self.minorAction = minorAction
    self.actionData = actionData
    self.skillEffectList = skillEffectList
    self.attacker = self:FindFighter(actionData.self_id)
    self.defense = self:FindFighter(actionData.target_id)
    self.multiNodeList = {}
    self.totalHurtAction = nil

    self.isFirst = true
    self.finalHit = nil

    self.protectData = minorAction.protectData
    self.protectMove = false
    self.lastProtect = nil

    local soundDataList = self.brocastCtx.combatMgr:GetSoundData(self.actionData.skill_id, 0)
    self.soundData = nil
    if soundDataList ~= nil then
        for _, sdata in ipairs(soundDataList) do
            if sdata.moment == 2 or sdata.moment == 3 then
                self.soundData = sdata
                break
            end
        end
    end
    self.endTaper = TaperSupporter.New(self.brocastCtx)
    self.endTaper:AddEvent(CombatEventType.End, self.OnActionEnd, self)
end

function MultiStepAction:Parse()
    local total = 0
    for _, skillEffect in ipairs(self.skillEffectList) do
        if skillEffect.attack_type == EffectAttackType.Attack then
            if #skillEffect.hurt_ratio > 0 then
                total = total + skillEffect.hurt_ratio[1]
            end
        end
    end

    local attackCount = 0
    for _, skillEffect in ipairs(self.skillEffectList) do
        if skillEffect.target == EffectTarget.Defence or self.isFirst then
            self:CreateAction(skillEffect, total)
            if skillEffect.attack_type == EffectAttackType.Attack then
                attackCount = attackCount + 1
            end
        end
    end

    if attackCount > 1 then
        self.totalHurtAction = CombatTotalHurtAction.New(self.brocastCtx, self.actionData)
    end

    if self.protectMove and self.lastProtect ~= nil then
        for i,pData in ipairs(self.protectData) do
            if pData.target_id == self.actionData.target_id then
                ProtectAction.MoveBack(self.brocastCtx, pData, self.lastProtect)
            end
        end
        -- ProtectAction.MoveBack(self.brocastCtx, self.protectData, self.lastProtect)
    end

    if self.finalHit ~= nil then
        self.finalHit.isFianl = true
    end
end

function MultiStepAction:Play()
    self:InvokeAndClear(CombatEventType.Start)
    local total = 0
    local angle = 0
    local length = #self.multiNodeList
    if #self.multiNodeList > 0 then
        for index, node in ipairs(self.multiNodeList) do
            if index == 1 then
                node.action:Play()
                angle = node.seffect.multi_attack_time
                total = total + angle
            else
                self:InvokeDelay(node.action.Play, total / 1000, node.action)
                if self.actionData.skill_id == 60555 and not self.isFirst then -- 精灵兽兔子的技能，是溅射连击，不显示攻击特效，这里特殊处理下
                    if node.action.isFlyEffect then
                        self:InvokeDelay(node.action.HideEffect, total / 1000, node.action)
                    end
                end
                angle = node.seffect.multi_attack_time
                if angle > 0 then
                    total = total + angle
                end
                if index == length and self.totalHurtAction ~= nil then
                    -- node.action:AddEvent(CombatEventType.End, self.totalHurtAction)
                    -- self:InvokeDelay(self.totalHurtAction.Play, total / 1000, self.totalHurtAction)
                    local delay = DelayAction.New(self.brocastCtx, 500)
                    delay:AddEvent(CombatEventType.End, self.totalHurtAction)
                    if node.seffect.effect_type == EffectType.FlyEffect then
                        node.action:AddEvent(CombatEventType.MoveEnd, delay)
                    else
                        node.action:AddEvent(CombatEventType.Hit, delay)
                    end
                end
            end
        end
    else
        self:OnActionEnd()
    end
    self.endTaper:EmptyCheck()
end

function MultiStepAction:CreateAction(skillEffect, total)
    local effectObject = self.brocastCtx.combatMgr:GetEffectObject(skillEffect.effect_id)
    local targetPoint = self:GetEffectTarget(self.actionData, skillEffect)
    local effect = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.actionData, self.attacker.transform.gameObject, targetPoint, skillEffect, effectObject)
    table.insert(self.multiNodeList, {action = effect, seffect = skillEffect})

    if skillEffect.attack_type == EffectAttackType.Attack then
        if self.actionData.is_hit == 1 then
            local beforeSync = SyncSupporter.New(self.brocastCtx) --保护或者其它动作提前
            local syncEffect = SyncSupporter.New(self.brocastCtx)
            -- beforeSync:AddEvent(CombatEventType.End, syncEffect)
            local ratio = 1
            if total ~= 0 and #skillEffect.hurt_ratio > 0 then
                ratio = skillEffect.hurt_ratio[1] / total
            end
            local attrChgAction = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, ratio, true)
            syncEffect:AddAction(attrChgAction)

            if skillEffect.shake == 1 or self.actionData.is_crit == 1 then
                -- 暂时屏蔽震动效果
                -- syncEffect:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            else
                -- syncEffect:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
            end

            if self.actionData.is_defence == 1 then
                syncEffect:AddAction(DefenseAction.New(self.brocastCtx, self.actionData))
            else
                local hit = HitAction.New(self.brocastCtx, self.actionData)
                hit.isFianl = false
                self.finalHit = hit
                syncEffect:AddAction(hit)
            end
            -- 音效
            if self.soundData ~= nil then
                syncEffect:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
            end
            -- 保护
            if self.protectData ~= nil then
                for i,pData in ipairs(self.protectData) do
                    if pData.target_id == self.actionData.target_id then
                        self.lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncEffect, pData, self.protectMove)
                        self.protectMove = true
                    end
                end
            end
            if skillEffect.effect_type == EffectType.FlyEffect then
                effect:AddEvent(CombatEventType.MoveEnd, syncEffect)
                effect:AddEvent(CombatEventType.Start, beforeSync)
            else
                effect:AddEvent(CombatEventType.Hit, syncEffect)
                effect:AddEvent(CombatEventType.Start, beforeSync)
            end
        else
            local evasion = EvasionAction.New(self.brocastCtx, self.actionData)
            local ratio = 1
            if total ~= 0 and #skillEffect.hurt_ratio > 0 then
                ratio = skillEffect.hurt_ratio[1] / total
            end
            local attrChgAction = EffectFactory.AttrChangeEffectByActionStep(self.brocastCtx, self.actionData, ratio, true)
            evasion:AddEvent(CombatEventType.MoveEnd, attrChgAction)
            if skillEffect.effect_type == EffectType.FlyEffect then
                effect:AddEvent(CombatEventType.MoveEnd, evasion)
            else
                effect:AddEvent(CombatEventType.Hit, evasion)
            end
        end
        effect:AddEvent(CombatEventType.End, self.endTaper)
    else
        effect:AddEvent(CombatEventType.End, self.endTaper)
    end
end

function MultiStepAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
