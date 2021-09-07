-- 普通攻击特效
NormalAttackAction = NormalAttackAction or BaseClass(CombatBaseAction)

function NormalAttackAction:__init(brocastCtx, majorCtx, minorAction, actionData, skillEffect)
    self.majorCtx = majorCtx
    self.minorAction = minorAction
    self.actionData = actionData
    self.skillEffect = skillEffect
    self.resourceLoader = minorAction.resourceLoader
    self.effect = nil
    self.isSelfEffect = true


    -- 保护
    self.protectData = minorAction.protectData

    self.endTaperSupporter = TaperSupporter.New(brocastCtx)
    self.endTaperSupporter:AddEvent(CombatEventType.End, self.OnActionEnd, self)

    -- 处理音效
    local motionId = majorCtx:GetMotionId(actionData)
    self.soundDataList = self.brocastCtx.combatMgr:GetSoundData(self.actionData.skill_id, motionId)
end

function NormalAttackAction:SetEffect(effect)
    self.effect = effect
    self.isSelfEffect = false
end

function NormalAttackAction:Parse()
    if self.effect == nil then
        local effectObject = self.brocastCtx.combatMgr:GetEffectObject(self.skillEffect.effect_id)
        local targetPoint = self:GetEffectTarget(self.actionData, self.skillEffect)
        local attacker = nil
        if self.actionData.self_id == 0 or self.actionData.self_id == nil then
            attacker = self.brocastCtx.controller.MiddleEastPoint.gameObject
        else
            -- attacker = self:FindFighter(self.actionData.self_id).transform.gameObject
            local status, err = xpcall(
                function()
                    attacker = self:FindFighter(self.actionData.self_id).transform.gameObject
                end
                ,function(err) Log.Error("NormalAttackAction:Parse() 出错了:" .. tostring(err) .. ", isFighting = " .. tostring(CombatManager.Instance.isFighting)); Log.Error(debug.traceback()) end)
        end
        self.effect = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.actionData, attacker, targetPoint, self.skillEffect, effectObject)
    end
    local beforeSync = SyncSupporter.New(self.brocastCtx) --保护或者其它动作提前
    local syncAction = SyncSupporter.New(self.brocastCtx)
    -- beforeSync:AddEvent(CombatEventType.End, syncAction)
    if self.actionData.is_hit == 1 then
        if self.skillEffect.effect_type == EffectType.HitFlyEffect then
            -- 击飞
            local hitFly = HitFlyAction.New(self.brocastCtx, self.actionData)
            hitFly.shaker = self.effect:GetShaker()
            self.effect:AddEvent(CombatEventType.End, hitFly.OnActionEnd, hitFly)
            hitFly:AddEvent(CombatEventType.End, self.endTaperSupporter)
            syncAction:AddAction(hitFly)
        else
            if self.actionData.is_defence == 1 then
                syncAction:AddAction(DefenseAction.New(self.brocastCtx, self.actionData))
                -- 还有特效
            else
                if self:NeedHit(self.actionData) then
                    syncAction:AddAction(HitAction.New(self.brocastCtx, self.actionData))
                end
            end
            -- 保护
            if self.protectData ~= nil then
                for i,pData in ipairs(self.protectData) do
                    if pData.target_id == self.actionData.target_id then
                        -- local lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncAction, pData, false)
                        -- ProtectAction.MoveBack(self.brocastCtx, pData, lastProtect)
                        local lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncAction, pData, false)
                        ProtectAction.MoveBack(self.brocastCtx, pData, lastProtect)
                    end
                end
            end
        end
        syncAction:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, self.actionData, 1))

        -- 震屏
        if self.skillEffect.shake == 1 or self.actionData.is_crit == 1 then
            syncAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
        else
            -- syncAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
        end
        -- 音效
        if self.soundDataList ~= nil then
            for _, soundData in ipairs(self.soundDataList) do
                if soundData.moment == 2 then -- 攻击点
                    syncAction:AddAction(SoundAction.New(self.brocastCtx, soundData))
                end
            end
        end
    else
        syncAction:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, self.actionData, 1))
        syncAction:AddAction(EvasionAction.New(self.brocastCtx, self.actionData))
    end

    if self.skillEffect.effect_type == EffectType.FlyEffect then
        self.effect:AddEvent(CombatEventType.MoveEnd, self.OnHit, self)
        self.effect:AddEvent(CombatEventType.Start, self.OnStar, self)
    else
        self.effect:AddEvent(CombatEventType.Hit, self.OnHit, self)
        self.effect:AddEvent(CombatEventType.Start, self.OnStar, self)
    end
    syncAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
    self:AddEvent(CombatEventType.Start, beforeSync)
    self:AddEvent(CombatEventType.Hit, syncAction)
    self.effect:AddEvent(CombatEventType.End, self.endTaperSupporter)
end

function NormalAttackAction:Play()
    self:InvokeAndClear(CombatEventType.Start)
    if self.isSelfEffect then
        self.effect:Play()
    end
end

function NormalAttackAction:OnStar()
    self:InvokeAndClear(CombatEventType.Start)
end

function NormalAttackAction:OnHit()
    self:InvokeAndClear(CombatEventType.Hit)
end

function NormalAttackAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end
