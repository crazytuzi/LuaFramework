-- 泡泡弹射
GeocentricAction = GeocentricAction or BaseClass(CombatBaseAction)

function GeocentricAction:__init(brocastCtx, minorAction, bubble1Effect, bubble2Effect, otherEffectList)
    self.minorAction = minorAction
    self.actionList = minorAction.actionList
    self.bubble1Effect = bubble1Effect
    self.bubble2Effect = bubble2Effect
    self.bubble1EffectObject = self.brocastCtx.combatMgr:GetEffectObject(self.bubble1Effect.effect_id)
    self.bubble2EffectObject = self.brocastCtx.combatMgr:GetEffectObject(self.bubble2Effect.effect_id)
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

function GeocentricAction:Parse()
    self:ParseFlyEffect()
end

function GeocentricAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    end
end

function GeocentricAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function GeocentricAction:ParseFlyEffect()
    local lastAction = nil
    local lastNode = nil
    local effectAction = nil
    local lastActionData = nil
    local first = true
    local sortData = self:SortActionList(self.actionList)

    local delayTime = 1000
    if self.bubble1Effect ~= nil and self.bubble1Effect.delay_time ~= nil then
        delayTime = self.bubble1Effect.delay_time
    end

    for order,actionGroup in ipairs(sortData) do
        local nodeAction = SyncSupporter.New(self.brocastCtx)
        local delay = DelayAction.New(self.brocastCtx, delayTime)
        nodeAction:AddAction(delay)
        for _,actionData in pairs(actionGroup) do
            local attacker = self:FindFighter(actionData.self_id).transform.gameObject
            local target = self:FindFighter(actionData.target_id).transform.gameObject
            local bubble = order == 1 and self.bubble1Effect or self.bubble2Effect
            local bubbleObj = order == 1 and self.bubble1EffectObject or self.bubble2EffectObject
            effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, actionData, attacker, target, bubble, bubbleObj)
            effectAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
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
            -- 受击
            -- 飘血
            local synchit = SyncSupporter.New(self.brocastCtx)
            local attrchangedelay
            if order == 1 then
                attrchangedelay  = DelayAction.New(self.brocastCtx, self.bubble1Effect.hit_delay)
            else
                attrchangedelay  = DelayAction.New(self.brocastCtx, self.bubble2Effect.hit_delay)
            end
            if self:NeedHit(actionData) then
                synchit:AddAction(HitAction.New(self.brocastCtx, actionData))
            end
            if self.bubble1Effect.shake == 1 or actionData.is_crit == 1 then
                synchit:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
            end
            -- 音效
            if self.soundData ~= nil then
                synchit:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
            end
            synchit:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1))
            attrchangedelay:AddEvent(CombatEventType.End, synchit)
            nodeAction:AddAction(attrchangedelay)
            self:CreateOtherHitEffect(actionData, synchit, order == 1)
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


function GeocentricAction:CreateOtherHitEffect(actionData, syncAction, first)
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

function GeocentricAction:GetAttackEffect()
    for k,v in pairs(self.otherEffectList) do
        if v.attack_type == EffectAttackType.Attack then
            return v
        end
    end
end

function GeocentricAction:SortActionList(Alist)
    local temp = {[1] = {}, [2] = {}}
    for _,action in ipairs(Alist) do
        local temp_action = BaseUtils.copytab(action)
        local first = false
        for k,v in pairs(temp_action.self_changes) do
            if v.change_type == 7 and v.change_val == 1 then
                table.insert(temp[1], temp_action)
                first = true
            end
        end
        if not first then
            table.insert(temp[2], temp_action)
        end
    end
   
    if temp[1][1] ~= nil then
        for k,v in pairs(temp[2]) do
            v.self_id = temp[1][1].target_id
        end
    else
        -- Log.Error("[战斗]GeocentricAction：ActionList里面没有change_type == 7 and change_val == 1的对象")
        local errorString = ""
        local skill_id = 0
        -- 对于战斗数据异常的特殊处理
        temp = {[1] = {}, [2] = {}}
        for _,action in ipairs(Alist) do
            local temp_action = BaseUtils.copytab(action)
            if temp[1][1] == nil then
                table.insert(temp[1], temp_action)
            else
                table.insert(temp[2], temp_action)
            end

            skill_id = temp_action.skill_id
            -- errorString = string.format("%s, target_id = %s, ", errorString, temp_action.target_id)
            -- for k,v in pairs(temp_action.self_changes) do
            --     errorString = string.format("%s, change_type = %s, change_val = %s,", errorString, v.change_type, v.change_val)
            -- end
        end
        -- Log.Error(string.format("[战斗]GeocentricAction数据错误的调试信息，skill_id = %s, %s", skill_id, errorString))
    end
    return temp
end