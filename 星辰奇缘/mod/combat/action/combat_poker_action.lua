-- 扑克攻击
PokerAction = PokerAction or BaseClass(CombatBaseAction)

-- function PokerAction:__init(brocastCtx, minorAction, pokerShowEffectRedRed, pokerShowEffectBlack, pokerAttckEffectRed, pokerAttckEffectBlack, otherEffectList)
function PokerAction:__init(brocastCtx, minorAction, pokerAttckEffectRed, pokerAttckEffectBlack, otherEffectList)
    self.minorAction = minorAction
    self.actionList = minorAction.actionList

    -- self.pokerShowEffectRed = pokerShowEffectRed
    -- self.pokerShowEffectRedObject = self.brocastCtx.combatMgr:GetEffectObject(self.pokerShowEffectRed.effect_id)

    -- self.pokerShowEffectBlack = pokerShowEffectBlack
    -- self.pokerShowEffectBlackObject = self.brocastCtx.combatMgr:GetEffectObject(self.pokerShowEffectBlack.effect_id)

    self.pokerAttckEffectRed = pokerAttckEffectRed
    self.pokerAttckEffectRedObject = self.brocastCtx.combatMgr:GetEffectObject(self.pokerAttckEffectRed.effect_id)

    self.pokerAttckEffectBlack = pokerAttckEffectBlack
    self.pokerAttckEffectBlackObject = self.brocastCtx.combatMgr:GetEffectObject(self.pokerAttckEffectBlack.effect_id)
    
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

    -- 施法特效为以下这些的话，就特殊处理成展示3张卡牌
    self.pokerShowEffectList = { 108120, 108121, 108122, 108130, 108131, 108132 }
    -- -- 对应每个位置的红牌特效
    -- self.pokerShowEffectRed = { 108120, 108121, 108122 }
    -- -- 对应每个位置的红牌特效
    -- self.pokerShowEffectBlack = { 108130, 108131, 108132 }

    -- 每个技能对应的所有展示卡牌组合
    self.pokerShowEffect = {
        [60550] = { {108120, 108121, 108122} }, -- 全红
        [60551] = { {108130, 108121, 108122}, {108120, 108131, 108122}, {108120, 108121, 108132} }, -- 半红
        [60552] = { {108130, 108131, 108132} }, -- 全黑
        [60553] = { {108120, 108131, 108132}, {108130, 108121, 108132}, {108130, 108131, 108122} }, -- 半红
    }
end

function PokerAction:Parse()
    self:ParseFlyEffect()
end

function PokerAction:Play()
    if self.firstAction ~= nil then
        self.firstAction:Play()
    end
end

function PokerAction:OnActionEnd()
    self:InvokeAndClear(CombatEventType.End)
end

function PokerAction:ParseFlyEffect()
    local lastActionData = nil
    local effectAction = nil
    local sortData = self:SortActionList(self.actionList)
    for order,actionData in ipairs(sortData) do
        local nodeAction = SyncSupporter.New(self.brocastCtx)
        local delay = DelayAction.New(self.brocastCtx, 1000)
        nodeAction:AddAction(delay)
        local attacker = self:FindFighter(actionData.self_id).transform.gameObject
        local target = self:FindFighter(actionData.target_id).transform.gameObject
        local poker, pokerObj = self:GetPokerEffect(actionData)
        effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, actionData, attacker, target, poker, pokerObj)
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
        attrchangedelay  = DelayAction.New(self.brocastCtx, poker.fly_time)
        if self:NeedHit(actionData) then
            synchit:AddAction(HitAction.New(self.brocastCtx, actionData))
        end
        if poker.shake == 1 or actionData.is_crit == 1 then
            synchit:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
        end
        -- 音效
        if self.soundData ~= nil then
            synchit:AddAction(SoundAction.New(self.brocastCtx, self.soundData))
        end
        synchit:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1))
        attrchangedelay:AddEvent(CombatEventType.End, synchit)
        nodeAction:AddAction(attrchangedelay)
        
        self:CreateOtherHitEffect(actionData, synchit)

        -- self.firstAction:AddAction(nodeAction)
        delay:AddEvent(CombatEventType.End, nodeAction)
        self.firstAction:AddAction(delay)

        lastActionData = actionData
    end

    self:CreateOtherFollowEffect(lastActionData, self.firstAction)
end

function PokerAction:CreateOtherFollowEffect(actionData, syncAction)
    local effectAction = nil
    for _, skillEffect in ipairs(self.otherEffectList) do
        if skillEffect.trigger == EffectTrigger.Follow then
            if self:IsPokerShowEffect(skillEffect) then
                self:MakePokerShowEffect(skillEffect, actionData, syncAction)
            else
                local effectObject = self.brocastCtx.combatMgr:GetEffectObject(skillEffect.effect_id)
                local attacker = self:FindFighter(actionData.self_id).transform.gameObject
                local target = self:FindFighter(actionData.target_id).transform.gameObject
                effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.minorAction.firstAction, attacker, target, skillEffect, effectObject)
                syncAction:AddAction(effectAction)
            end
        end
    end
end

function PokerAction:CreateOtherHitEffect(actionData, syncAction)
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

function PokerAction:GetAttackEffect()
    for k,v in pairs(self.otherEffectList) do
        if v.attack_type == EffectAttackType.Attack then
            return v
        end
    end
end

function PokerAction:SortActionList(Alist)
    -- local temp = {[1] = {}, [2] = {}}
    -- for _,action in ipairs(Alist) do
    --     local temp_action = BaseUtils.copytab(action)
    --     local first = false
    --     for k,v in pairs(temp_action.self_changes) do
    --         if v.change_type == 7 and v.change_val == 1 then
    --             table.insert(temp[1], temp_action)
    --             first = true
    --         end
    --     end
    --     if not first then
    --         table.insert(temp[2], temp_action)
    --     end
    -- end
    -- if temp[1][1] ~= nil then
    --     for k,v in pairs(temp[2]) do
    --         v.self_id = temp[1][1].target_id
    --     end
    -- end
    -- return temp

    return Alist
end

function PokerAction:GetPokerEffect(actionData)
    local pokerType = 0
    for _, change in ipairs(actionData.self_changes) do
        if change.change_type == 17 then
            pokerType = change.change_val % 2
            break
        end
    end

    if pokerType == 0 then
        return self.pokerAttckEffectRed, self.pokerAttckEffectRedObject
    else
        return self.pokerAttckEffectBlack, self.pokerAttckEffectBlackObject
    end
end

function PokerAction:IsPokerShowEffect(skillEffect)
    for _, effectId in ipairs(self.pokerShowEffectList) do
        if skillEffect.effect_id == effectId then
            return true
        end    
    end    

    return false
end

function PokerAction:MakePokerShowEffect(skillEffect, actionData, syncAction)
    local list = self.pokerShowEffect[skillEffect.skill_id]
    local showEffectList = list[math.random(1, #list)]

    local effectAction = nil
    for i=1, 3 do
        local effect_id = showEffectList[i]
        local effectObject = self.brocastCtx.combatMgr:GetEffectObject(effect_id)
        local tempSkillEffect = BaseUtils.copytab(skillEffect)
        tempSkillEffect.custom_mounter = effectObject.mounter_str
        local attacker = self:FindFighter(actionData.self_id).transform.gameObject
        local target = self:FindFighter(actionData.target_id).transform.gameObject
        effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.minorAction.firstAction, attacker, target, tempSkillEffect, effectObject)
        syncAction:AddAction(effectAction)
    end
end