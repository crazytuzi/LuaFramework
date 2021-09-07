-- 雷击
MuiltThunderAction = MuiltThunderAction or BaseClass(CombatBaseAction)

function MuiltThunderAction:__init(brocastCtx, minorAction, thunderEffect, otherEffectList)
    self.minorAction = minorAction
    self.actionList = minorAction.actionList
    self.thunderEffect = thunderEffect
    self.thunderEffectObject = self.brocastCtx.combatMgr:GetEffectObject(self.thunderEffect.effect_id)
    self.otherEffectList = otherEffectList
    self.attacker = self:FindFighter(self.minorAction.firstAction.self_id)
    self.attackEffect = self:GetAttackEffect()
    self.firstAction = SyncSupporter.New(self.brocastCtx)
    self.protectData = minorAction.protectData

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

function MuiltThunderAction:Parse()
    if self.thunderEffect.effect_type == EffectType.FlyEffect then
        self:ParseFlyEffect()
    else
        self:ParseHitEffect()
    end
end

function MuiltThunderAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    end
end

function MuiltThunderAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function MuiltThunderAction:ParseFlyEffect()
    local lastAction = nil
    local lastNode = nil
    local effectAction = nil
    local lastActionData = nil
    local first = true
    local sortData = self:SortActionList(self.actionList)
    for _,actionGroup in ipairs(sortData) do
        local nodeAction = SyncSupporter.New(self.brocastCtx)
        -- local delay = DelayAction.New(self.brocastCtx, self.thunderEffect.fly_time)
        local delay = DelayAction.New(self.brocastCtx, 600)
        nodeAction:AddAction(delay)
        for _,actionData in pairs(actionGroup) do
            self:CreateOtherHitEffect(actionData, nodeAction, first)
            local attacker = self:FindFighter(actionData.self_id).transform.gameObject
            local target = self:FindFighter(actionData.target_id).transform.gameObject
            effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, action, attacker, target, self.thunderEffect, self.thunderEffectObject)
            effectAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
            -- if lastNode == nil then
            --     self.firstAction:AddAction(effectAction)
            -- else
            --     lastNode:AddAction(effectAction)
            -- end
            nodeAction:AddAction(effectAction)
            if self.protectData ~= nil then
                for i,pData in ipairs(self.protectData) do
                    if pData.target_id == actionData.target_id then
                        local lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, nodeAction, nodeAction, pData, false)
                        ProtectAction.MoveBack(self.brocastCtx, pData, lastProtect)
                    end
                end
            end
            -- 震屏
            if self.thunderEffect.shake == 1 or actionData.is_crit == 1 then
                nodeAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            end
            -- 音效
            if self.soundData ~= nil then
                nodeAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
            end
            -- 受击
            if self:NeedHit(actionData) then
                nodeAction:AddAction(HitAction.New(self.brocastCtx, actionData))
            end
            -- 飘血
            nodeAction:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1))
        end
        if lastAction == nil then
            self.firstAction:AddAction(nodeAction)
        else
            lastAction:AddEvent(CombatEventType.End, nodeAction)


            lastNode = nodeAction
        end
        first = false
        lastAction = delay
        lastActionData = actionData
    end
end

function MuiltThunderAction:ParseHitEffect()
    local lastAction = nil
    local effectAction = nil
    local first = true
    for _, actionData in ipairs(self.actionList) do
        local attacker = self:FindFighter(actionData.self_id).transform.gameObject
        local target = self:FindFighter(actionData.target_id).transform.gameObject
        effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.minorAction.firstAction, attacker, target, self.thunderEffect, self.thunderEffectObject)
        effectAction:AddEvent(CombatEventType.End, self.endTaperSupporter)

        local nodeAction = SyncSupporter.New(self.brocastCtx)
        local delay = DelayAction.New(self.brocastCtx, 500)
        nodeAction:AddAction(effectAction)
        nodeAction:AddAction(delay)
        self:CreateOtherHitEffect(actionData, nodeAction, first)
        first = false
        if lastAction == nil then
            self.firstAction:AddAction(nodeAction)

            -- 震屏
            if self.thunderEffect.shake == 1 or actionData.is_crit == 1 then
                nodeAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            end
            -- 音效
            if self.soundData ~= nil then
                nodeAction:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
            end
        else
            lastAction:AddEvent(CombatEventType.End, nodeAction)
        end
        -- 受击
        if self:NeedHit(actionData) then
            nodeAction:AddAction(HitAction.New(self.brocastCtx, actionData))
        end
        -- 飘血
        nodeAction:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1))
        lastAction = delay
    end
end

function MuiltThunderAction:CreateOtherHitEffect(actionData, syncAction, first)
    local effectAction = nil
    for _, skillEffect in ipairs(self.otherEffectList) do
        if skillEffect.trigger == EffectTrigger.Hit and (first or skillEffect.effect_type ~= 0) then
            local effectObject = self.brocastCtx.combatMgr:GetEffectObject(skillEffect.effect_id)
            local attacker = self:FindFighter(actionData.self_id).transform.gameObject
            local target = self:FindFighter(actionData.target_id).transform.gameObject
            effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.minorAction.firstAction, attacker, target, skillEffect, effectObject)
            syncAction:AddAction(effectAction)
        end
    end
end

function MuiltThunderAction:GetAttackEffect()
    for k,v in pairs(self.otherEffectList) do
        if v.attack_type == EffectAttackType.Attack then
            return v
        end
    end
end

function MuiltThunderAction:SortActionList(Alist)
    local temp = {}
    for _,action in ipairs(Alist) do
        local temp_action = BaseUtils.copytab(action)
        for _, data in ipairs(action.target_changes) do
            if data.change_type == 12 then
                temp_action.self_id = data.change_val
            end
        end
        for _, data in ipairs(action.self_changes) do
            if data.change_type == 7 then
                temp_action.sort = data.change_val
            end
        end
        if temp_action.sort ~= nil then
            if temp[temp_action.sort] == nil then
                temp[temp_action.sort] = {}
            end
            table.insert(temp[temp_action.sort], temp_action)
        else
            BaseUtils.dump(temp_action,"没有序号")
        end
    end
    return temp
end