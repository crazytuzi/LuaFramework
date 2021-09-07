-- 雷爆
BoomAction = BoomAction or BaseClass(CombatBaseAction)

function BoomAction:__init(brocastCtx, minorAction, boomEffect, otherEffectList)
    self.minorAction = minorAction
    self.actionList = minorAction.actionList
    self.boomEffect = boomEffect
    self.boomEffectObject = self.brocastCtx.combatMgr:GetEffectObject(self.boomEffect.effect_id)
    self.otherEffectList = otherEffectList
    self.attacker = self:FindFighter(self.minorAction.firstAction.self_id)
    self.protectData = minorAction.protectData

    self.firstAction = SyncSupporter.New(self.brocastCtx)

    self.endTaperSupporter = TaperSupporter.New(brocastCtx)
    self.endTaperSupporter:AddEvent(CombatEventType.End, self.OnActionEnd, self)

    -- 处理音效
    local motionId = self.minorAction.majorCtx:GetMotionId(self.minorAction.firstAction)
    local soundDataList = self.brocastCtx.combatMgr:GetSoundData(self.minorAction.firstAction.skill_id, motionId)
    self.soundData = nil
    if soundDataList ~= nil then
        for _, sdata in ipairs(soundDataList) do
            if sdata.moment == 2 or sdata.moment == 3 then
                self.soundData = sdata
            end
        end
    end
end

function BoomAction:Parse()
    -- 只考虑近战
    self:ParseHitEffect()
end

function BoomAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    end
end

function BoomAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function BoomAction:ParseHitEffect()
    local hitSyncAction = nil
    local isFirst = true
    for _, actionData in ipairs(self.actionList) do
        local nodeAction = SyncSupporter.New(self.brocastCtx)
        local attacker = self:FindFighter(actionData.self_id).transform.gameObject
        local target = self:FindFighter(actionData.target_id).transform.gameObject
        local playAction = nil
        local effectAction = nil
        if hitSyncAction == nil then
            local firstHitAction = SyncSupporter.New(self.brocastCtx)
            hitSyncAction = SyncSupporter.New(self.brocastCtx)
            effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, actionData, attacker, target, self.boomEffect, self.boomEffectObject)
            effectAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
            self:CreateOtherHitEffect(actionData, firstHitAction)
            nodeAction:AddAction(effectAction)
            local delay = DelayAction.New(self.brocastCtx, self.boomEffect.delay_time)
            delay:AddEvent(CombatEventType.End, hitSyncAction)
            delay:AddEvent(CombatEventType.End, self.endTaperSupporter)
            if self.boomEffect.trigger == EffectTrigger.Hit then
                nodeAction:AddAction(firstHitAction)
                nodeAction:AddAction(delay)
                playAction = nodeAction
            elseif self.boomEffect.trigger == EffectTrigger.ActionStart then
                effectAction:AddEvent(CombatEventType.Hit, firstHitAction)
                effectAction:AddEvent(CombatEventType.Hit, delay)
                playAction = firstHitAction
            end
            -- 震屏
            if self.boomEffect.shake == 1 or actionData.is_crit == 1 then
                nodeAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
                hitSyncAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            end
            if self.protectData ~= nil then
                for i,pData in ipairs(self.protectData) do
                    if pData.target_id == actionData.target_id then
                        local lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, nodeAction, nodeAction, pData, false)
                        local protectMove = true
                        ProtectAction.MoveBack(self.brocastCtx, pData, lastProtect)
                    end
                end
            end
            -- 音效
            if self.soundData ~= nil then
                nodeAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
                hitSyncAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
            end
            self.firstAction:AddAction(nodeAction)
        else
            self:CreateOtherHitEffect(actionData, hitSyncAction)
            playAction = hitSyncAction
        end
        -- 受击
        if self:NeedHit(actionData) then
            if isFirst and self.boomEffect.effect_type == EffectType.HitFlyEffect then
                local hitFly = HitFlyAction.New(self.brocastCtx, actionData)
                hitFly.shaker = effectAction:GetShaker()
                effectAction:AddEvent(CombatEventType.End, hitFly.OnActionEnd, hitFly)
                hitFly:AddEvent(CombatEventType.End, self.endTaperSupporter)
                playAction:AddAction(hitFly)
            else
                playAction:AddAction(HitAction.New(self.brocastCtx, actionData))
            end
        end
        isFirst = false
        -- 飘血
        playAction:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1))
    end
end

function BoomAction:CreateOtherHitEffect(actionData, syncAction)
    local effectAction = nil
    for _, skillEffect in ipairs(self.otherEffectList) do
        if skillEffect.trigger == EffectTrigger.Hit then
            local effectObject = self.brocastCtx.combatMgr:GetEffectObject(skillEffect.effect_id)
            local attacker = self:FindFighter(actionData.self_id).transform.gameObject
            local target = self:FindFighter(actionData.target_id).transform.gameObject
            effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.minorAction.firstAction, attacker, target, skillEffect, effectObject)
            syncAction:AddAction(effectAction)
        end
    end
end
