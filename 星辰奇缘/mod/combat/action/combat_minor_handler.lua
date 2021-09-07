-- 子播报内容处理

-- 技能特效
MinorEffectHandler = MinorEffectHandler or BaseClass(MinorBaseHandler)

function MinorEffectHandler:__init(brocastCtx, minorAction, skillMotion)
    self.brocastCtx = brocastCtx
    self.minorAction = minorAction
    self.skillMotion = skillMotion

    self.firstAction = minorAction.firstAction
    self.actionList = minorAction.actionList
    self.combatSkill = self.brocastCtx.combatMgr:GetCombatSkillObject(self.firstAction.skill_id, self.firstAction.skill_lev)

    -- self.firstAttacker = self.minorAction:FindFighter(self.firstAction.self_id)
    self.firstAttacker = self.minorAction.firstAttacker
    self.firstDefence = self.minorAction:FindFighter(self.firstAction.target_id)

    self.combatMgr = CombatManager.Instance
    self.majorCtx = minorAction.majorCtx
    self.motionId = self.majorCtx:GetMotionId(self.firstAction)
    self.multiAttackList = {}   -- 多段攻击
    self.attackList = {}        -- 攻击特效
    self.multiHitList = {}      -- 连击特效
    self.normalList = {}        -- 普通特效
    self.thunderList = {}       -- 雷击特效
    self.boomList = {}          -- 爆击特效
    self.muiltthunderList = {}          -- 群体雷击特效
    self.bubbleList = {}          -- 泡泡分裂弹射特效
    self.geocentricList = {}    -- 地心烈炎分段特效
    self.pokerList = {}    -- 魔幻卡牌特效
    self.skillEffectList = CombatManager.Instance:GetSkillEffectList(self.firstAction.skill_id, self.motionId)
    if self.skillEffectList == nil then
        self.skillEffectList = {}
    end
    self.isYinYang = self.firstAction.action_type == 12
    self.isThunder = false
    self.isBoom = false
    self.isMuiltThunder = false
    self.isBubble = false
    self.isGeocentric = false
    self.isPoker = false
end

function MinorEffectHandler:Process()
    local isThunder = false
    local isBoom = false
    local isMuiltThunder = false
    for _, skillEffect in ipairs(self.skillEffectList) do
        -- BaseUtils.dump(skillEffect, "skillEffect")
        if skillEffect.attack_type == EffectAttackType.Thunder then
            isThunder = true
            self.isThunder = true
            break
        elseif skillEffect.attack_type == EffectAttackType.Boom then
            self.isBoom = true
            isBoom = true
            break
        elseif skillEffect.attack_type == EffectAttackType.MuiltThunder then
            self.isMuiltThunder = true
            isMuiltThunder = true
            break
        elseif skillEffect.attack_type == EffectAttackType.Bubble1 or skillEffect.attack_type == EffectAttackType.Bubble2 then
            self.isBubble = true
            break
        elseif skillEffect.attack_type == EffectAttackType.Geocentric1 or skillEffect.attack_type == EffectAttackType.Geocentric2 then
            self.isGeocentric = true
            break
        elseif skillEffect.attack_type == EffectAttackType.Poker1 or skillEffect.attack_type == EffectAttackType.Poker2 then
            self.isPoker = true
            break
        end
    end
    for _, skillEffect in ipairs(self.skillEffectList) do
        if isThunder then
            if skillEffect.trigger == EffectTrigger.Hit or skillEffect.trigger == EffectTrigger.MoveEnd then
                if skillEffect.attack_type == EffectAttackType.Thunder then
                    table.insert(self.thunderList, skillEffect)
                else
                    if skillEffect.target == EffectTarget.Defence then
                        table.insert(self.thunderList, skillEffect)
                    else
                        table.insert(self.normalList, skillEffect)
                    end
                end
            else
                table.insert(self.normalList, skillEffect)
            end
        elseif isBoom then
            if skillEffect.attack_type == EffectAttackType.Boom then
                table.insert(self.boomList, skillEffect)
            else
                if skillEffect.target == EffectTarget.Defence then
                    table.insert(self.boomList, skillEffect)
                else
                    table.insert(self.normalList, skillEffect)
                end
            end
        elseif isMuiltThunder then
            if skillEffect.attack_type == EffectAttackType.MuiltThunder then
                table.insert(self.muiltthunderList, skillEffect)
            else
                if skillEffect.target == EffectTarget.Defence then
                    table.insert(self.muiltthunderList, skillEffect)
                else
                    table.insert(self.normalList, skillEffect)
                end
            end
        elseif self.isBubble then
            if skillEffect.attack_type == EffectAttackType.Bubble1 or skillEffect.attack_type == EffectAttackType.Bubble2 then
                table.insert(self.bubbleList, skillEffect)
            else
                if skillEffect.target == EffectTarget.Defence then
                    table.insert(self.bubbleList, skillEffect)
                else
                    table.insert(self.normalList, skillEffect)
                end
            end
        elseif self.isGeocentric then
            if skillEffect.attack_type == EffectAttackType.Geocentric1 or skillEffect.attack_type == EffectAttackType.Geocentric2 then
                table.insert(self.geocentricList, skillEffect)
            else
                if skillEffect.target == EffectTarget.Defence then
                    table.insert(self.geocentricList, skillEffect)
                else
                    table.insert(self.normalList, skillEffect)
                end
            end
        elseif self.isPoker then
            if skillEffect.attack_type == EffectAttackType.Poker1 or skillEffect.attack_type == EffectAttackType.Poker2 then
                table.insert(self.pokerList, skillEffect)
            else
                -- 这里施法动作也由PokerAction管理
                -- if skillEffect.target == EffectTarget.Defence then
                    table.insert(self.pokerList, skillEffect)
                -- else
                    -- table.insert(self.normalList, skillEffect)
                -- end
            end
        elseif skillEffect.is_multi_attack == 1 then
            table.insert(self.multiAttackList, skillEffect)
        elseif skillEffect.attack_type == EffectAttackType.Attack then
            table.insert(self.attackList, skillEffect)
        elseif skillEffect.attack_type == EffectAttackType.MultiHit then
            table.insert(self.multiHitList, skillEffect)
        elseif skillEffect.attack_type == EffectAttackType.Thunder then
            table.insert(self.thunderList, skillEffect)
        elseif skillEffect.attack_type == EffectAttackType.Boom then
            table.insert(self.boomList, skillEffect)
        else
            table.insert(self.normalList, skillEffect)
        end
    end
    -- 普通特效
    if #self.normalList > 0 then
        self:ParseNormalEffect(self.normalList)
    end

    -- 多段特效
    if #self.multiAttackList > 0 then
        self:ParseMultiAttackEffect(self.multiAttackList)
    end

    -- 连击特效
    if #self.multiHitList > 0 then
        self:ParseMultiHitEffect(self.multiHitList)
    end

    -- 攻击特效
    if #self.attackList > 0 and not self.isYinYang then
        self:ParseAttackEffect(self.attackList)
    end

    -- 雷击特效
    if #self.thunderList > 0 then
        self:ParseThunderEffect(self.thunderList)
    end

    if #self.boomList > 0 then
        self:ParseBoomEffect(self.boomList)
    end

    if #self.muiltthunderList > 0 then
        self:ParseMuiltThunderEffect(self.muiltthunderList)
    end

    if #self.bubbleList > 0 then
        self:ParseBubbleEffect(self.bubbleList)
    end

    if #self.geocentricList > 0 then
        self:ParseGeocentricEffect(self.geocentricList)
    end

    if #self.pokerList > 0 then
        self:ParsePokerEffect(self.pokerList)
    end

    if #self.multiAttackList == 0 and #self.multiHitList == 0 and #self.attackList == 0 and #self.thunderList == 0  and #self.boomList == 0 and #self.muiltthunderList == 0 and #self.bubbleList == 0 and #self.geocentricList == 0 and #self.pokerList == 0 then
        if self.combatSkill.type == 0 and self.combatSkill.sub_type == 0 then
            for _, actionData in ipairs(self.actionList) do
                if actionData.is_hit == 1 then
                    local beforeSync = SyncSupporter.New(self.brocastCtx)
                    local syncHitAction = SyncSupporter.New(self.brocastCtx)
                    syncHitAction:AddAction(EffectFactory.AttrChangeEffectByAction(self.brocastCtx, actionData, 1))
                    if actionData.is_crit == 1 then
                        syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Normal))
                    else
                        -- syncHitAction:AddAction(ShakeCameraAction.New(self.brocastCtx, CombatShakeType.Small))
                    end
                    if actionData.is_defence == 1 then
                        local effectPath = "prefabs/effect/16048.unity3d"
                        local effectObject = self.combatMgr:GetEffectObject(160481)
                        self.resourceLoader:AddResPath({effectPath})
                        syncHitAction:AddAction(SimpleEffect.New(self.brocastCtx, actionData, effectObject, self.minorAction))
                        syncHitAction:AddAction(DefenseAction.New(self.brocastCtx, actionData))
                    else
                        if self.minorAction:NeedHit(actionData) then
                            local effectPath = "prefabs/effect/" .. 16048 .. ".unity3d"
                            local effectObject = self.combatMgr:GetEffectObject(160481)
                            self.resourceLoader:AddResPath({effectPath})
                            syncHitAction:AddAction(HitAction.New(self.brocastCtx, actionData))
                            syncHitAction:AddAction(SimpleEffect.New(self.brocastCtx, actionData, effectObject, self.minorAction))
                        end
                    end
                    if self.minorAction.protectData ~= nil then
                        for i,pData in ipairs(self.minorAction.protectData) do
                            if pData.target_id == actionData.target_id then
                                local lastProtect = ProtectAction.AddProtectAction(self.brocastCtx, beforeSync, syncHitAction, pData, false)
                                ProtectAction.MoveBack(self.brocastCtx, pData, lastProtect)
                            end
                        end
                    end
                    self.skillMotion:AddEvent(CombatEventType.Start, beforeSync)
                    self.skillMotion:AddEvent(CombatEventType.Hit, syncHitAction)
                    syncHitAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
                else
                    local evasion = EvasionAction.New(self.brocastCtx, actionData)
                    evasion:AddEvent(CombatEventType.End, self.endTaperSupporter)
                    self.skillMotion:AddEvent(CombatEventType.Hit, evasion)
                end
            end
        end
    end
end

function MinorEffectHandler:ParseNormalEffect(normalList)
    for _, skillEffect in ipairs(normalList) do
        local effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        if effectObject == nil then
            Log.Error("[effect_data]缺少特效基础信息:" .. skillEffect.effect_id)
        end
        -- local effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        local effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        local targetPoint = nil
        local loaderAction = nil
        local effectAction = nil
        -- loaderAction = ResloaderAction.New(self.brocastCtx, {effectPath})
        self.resourceLoader:AddResPath({effectPath})
        if skillEffect.target == EffectTarget.Attacker then
            targetPoint = self.minorAction:GetEffectTarget(self.firstAction, skillEffect)
            effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.firstAction, self.firstAttacker.transform.gameObject, targetPoint, skillEffect, effectObject)
            if effectAction ~= nil then
                self:RegEffect(effectAction, skillEffect.trigger)
            end
        else
            if skillEffect.range == EffectRange.Single then
                local first = true
                for _, actionData in ipairs(self.actionList) do
                    if self.isThunder and first == false then   -- 远程闪电链只处理第一个起手攻击特效
                        break
                    end
                    targetPoint = self.minorAction:GetEffectTarget(actionData, skillEffect)
                    effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, actionData, self.firstAttacker.transform.gameObject, targetPoint, skillEffect, effectObject)
                    if effectAction ~= nil then
                        self:RegEffect(effectAction, skillEffect.trigger)
                    end
                    first = false
                end
            else
                targetPoint = self.minorAction:GetEffectTarget(self.firstAction, skillEffect)
                effectAction = EffectFactory.CreateGeneral(self.brocastCtx, self.minorAction, self.firstAction, self.firstAttacker.transform.gameObject, targetPoint, skillEffect, effectObject)
                if effectAction ~= nil then
                    self:RegEffect(effectAction, skillEffect.trigger)
                end
            end
        end
    end
end

function MinorEffectHandler:ParseAttackEffect(attackList)
    if #attackList > 1 then
        Log.Error("攻击特效超过一个"..tostring(self.firstAction.skill_id))
    end
    local skillEffect = attackList[1]
    local effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
    if effectObject == nil then
        Log.Error("[effect_data]缺少特效基础信息:" .. skillEffect.effect_id)
    end
    -- local effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
    local effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
    self.resourceLoader:AddResPath({effectPath})

    local normalAction = nil
    if skillEffect.target == EffectTarget.Attacker then
        local firstEffectAtk = nil
        for _, actionData in ipairs(self.actionList) do
            normalAction = NormalAttackAction.New(self.brocastCtx, self.majorCtx, self.minorAction, actionData, skillEffect)
            if firstEffectAtk ~= nil then
                normalAction:SetEffect(firstEffectAtk)
            end
            normalAction:Parse()
            normalAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
            self:RegEffect(normalAction, skillEffect.trigger)
            if firstEffectAtk == nil then
                firstEffectAtk = normalAction.effect
            end
        end
    else -- EffectTarget.Defense
        if skillEffect.range == EffectRange.Single then
            for _, actionData in ipairs(self.actionList) do
                normalAction = NormalAttackAction.New(self.brocastCtx, self.majorCtx, self.minorAction, actionData, skillEffect)
                normalAction:Parse()
                normalAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
                self:RegEffect(normalAction, skillEffect.trigger)
            end
        else
            normalAction = NormalAttackAction.New(self.brocastCtx, self.majorCtx, self.minorAction, self.firstAction, skillEffect)
            normalAction:Parse()
            normalAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
            self:RegEffect(normalAction, skillEffect.trigger)
            local firstEffect = normalAction.effect
            if #self.actionList > 1 then
                for i = 2, #self.actionList do
                    local actionData = self.actionList[i]
                    normalAction = NormalAttackAction.New(self.brocastCtx, self.majorCtx, self.minorAction, actionData, skillEffect)
                    normalAction:SetEffect(firstEffect)
                    normalAction:Parse()
                    normalAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
                end
            end
        end
    end
end

function MinorEffectHandler:ParseMultiAttackEffect(multiAttackList)
    local isFirst = true
    local resources = {}
    local effectObject = nil
    local effectPath = nil
    for _, skillEffect in ipairs(multiAttackList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)
    end
    -- local loaderAction = ResloaderAction.New(self.brocastCtx, resources)
    self.resourceLoader:AddResPath(resources)
    for _, actionData in ipairs(self.actionList) do
        local multiAttackAction = MultiStepAction.New(self.brocastCtx, self.minorAction, actionData, multiAttackList)
        multiAttackAction.isFirst = isFirst
        multiAttackAction:Parse()
        isFirst = false
        multiAttackAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
        self:RegEffect(multiAttackAction, EffectTrigger.MultiHit)
    end
end

function MinorEffectHandler:ParseMultiHitEffect(multiHitList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil
    for _, skillEffect in ipairs(multiHitList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)
    end
    -- local loaderAction = ResloaderAction.New(self.brocastCtx, resources)
    self.resourceLoader:AddResPath(resources)

    local seriesAction = nil
    for _, skillEffect in ipairs(multiHitList) do
        if skillEffect.target == EffectTarget.Attacker then
            seriesAction = SeriesHitAction.New(self.brocastCtx, self.majorCtx, self.minorAction, self.firstAction, skillEffect)
            seriesAction:Parse()
            seriesAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
            self:RegEffect(seriesAction, skillEffect.trigger)
        else
            if skillEffect.range == EffectRange.Single then
                for _, actionData in ipairs(self.actionList) do
                    seriesAction = SeriesHitAction.New(self.brocastCtx, self.majorCtx, self.minorAction, actionData, skillEffect)
                    seriesAction:Parse()
                    seriesAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
                    self:RegEffect(seriesAction, skillEffect.trigger)
                end
            else
                seriesAction = SeriesHitAction.New(self.brocastCtx, self.majorCtx, self.minorAction, self.firstAction, skillEffect)
                seriesAction:Parse()
                seriesAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
                self:RegEffect(seriesAction, skillEffect.trigger)
                local firstEffect = seriesAction.effect
                if #self.actionList > 1 then
                    local count = #self.actionList
                    for i = 2, count do
                        local actionData = self.actionList[i]
                        seriesAction = SeriesHitAction.New(self.brocastCtx, self.majorCtx, self.minorAction, actionData, skillEffect)
                        seriesAction.effect = firstEffect
                        seriesAction:Parse()
                        seriesAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
                    end
                end
            end
        end
    end
end

function MinorEffectHandler:ParseThunderEffect(thunderList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil

    local thunderEffect = nil
    local otherEffectList = {}

    for _, skillEffect in ipairs(thunderList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)

        if skillEffect.attack_type == EffectAttackType.Thunder then
            if thunderEffect == nil then
                thunderEffect = skillEffect
            else
                thunderEffect = skillEffect
                Log.Error("存在多个电击特效:" .. skillEffect.effect_id)
            end
        else
            table.insert(otherEffectList, skillEffect)
        end
    end
    self.resourceLoader:AddResPath(resources)
    local thunderAction = ThunderAction.New(self.brocastCtx, self.minorAction, thunderEffect, otherEffectList)
    thunderAction:Parse()
    self:RegEffect(thunderAction, thunderEffect.trigger)
    thunderAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
end

-- 雷爆
function MinorEffectHandler:ParseBoomEffect(boomList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil

    local boomEffect = nil
    local otherEffectList = {}

    for _, skillEffect in ipairs(boomList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)

        if skillEffect.attack_type == EffectAttackType.Boom then
            if boomEffect == nil then
                boomEffect = skillEffect
            else
                boomEffect = skillEffect
                Log.Error("存在多个雷爆特效:" .. skillEffect.effect_id)
            end
        else
            table.insert(otherEffectList, skillEffect)
        end
    end
    self.resourceLoader:AddResPath(resources)
    local boomAction = BoomAction.New(self.brocastCtx, self.minorAction, boomEffect, otherEffectList)
    boomAction:Parse()
    self:RegEffect(boomAction, boomEffect.trigger)
    boomAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
end


function MinorEffectHandler:ParseMuiltThunderEffect(muiltthunderList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil

    local thunderEffect = nil
    local otherEffectList = {}

    for _, skillEffect in ipairs(muiltthunderList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)

        if skillEffect.attack_type == EffectAttackType.MuiltThunder then
            if thunderEffect == nil then
                thunderEffect = skillEffect
            else
                thunderEffect = skillEffect
                Log.Error("存在多个群体电击特效:" .. skillEffect.effect_id)
            end
        else
            table.insert(otherEffectList, skillEffect)
        end
    end
    self.resourceLoader:AddResPath(resources)
    local thunderAction = MuiltThunderAction.New(self.brocastCtx, self.minorAction, thunderEffect, otherEffectList)
    thunderAction:Parse()
    -- self:RegEffect(thunderAction, thunderEffect.trigger)
    self:RegEffect(thunderAction, EffectTrigger.MultiHit)
    thunderAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
end


function MinorEffectHandler:ParseBubbleEffect(bubbleList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil

    local bubble1Effect = nil
    local bubble2Effect = nil
    local otherEffectList = {}

    for _, skillEffect in ipairs(bubbleList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)

        if skillEffect.attack_type == EffectAttackType.Bubble1 then
            if bubble1Effect == nil then
                bubble1Effect = skillEffect
            else
                bubble1Effect = skillEffect
                Log.Error("存在多个一段泡泡特效:" .. skillEffect.effect_id)
            end
        elseif skillEffect.attack_type == EffectAttackType.Bubble2 then
            if bubble2Effect == nil then
                bubble2Effect = skillEffect
            else
                bubble2Effect = skillEffect
                Log.Error("存在多个二段泡泡特效:" .. skillEffect.effect_id)
            end
        else
            table.insert(otherEffectList, skillEffect)
        end
    end

    self.resourceLoader:AddResPath(resources)
    local bubbleAction = BubbleAction.New(self.brocastCtx, self.minorAction, bubble1Effect, bubble2Effect, otherEffectList)
    bubbleAction:Parse()
    -- self:RegEffect(bubbleAction, thunderEffect.trigger)
    -- local delay = DelayAction.New(self.brocastCtx, bubble1Effect.fly_time)
    -- delay:AddEvent(CombatEventType.End, bubbleAction)
    -- self:RegEffect(delay, EffectTrigger.MultiHit)
    self:RegEffect(bubbleAction, EffectTrigger.MultiHit)
    bubbleAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
end

function MinorEffectHandler:ParseGeocentricEffect(bubbleList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil

    local geocentric1Effect = nil
    local geocentric2Effect = nil
    local otherEffectList = {}

    for _, skillEffect in ipairs(bubbleList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)

        if skillEffect.attack_type == EffectAttackType.Geocentric1 then
            if geocentric1Effect == nil then
                geocentric1Effect = skillEffect
            else
                geocentric1Effect = skillEffect
                Log.Error("存在多个一段地心烈炎特效:" .. skillEffect.effect_id)
            end
        elseif skillEffect.attack_type == EffectAttackType.Geocentric2 then
            if geocentric2Effect == nil then
                geocentric2Effect = skillEffect
            else
                geocentric2Effect = skillEffect
                Log.Error("存在多个二段地心烈炎特效:" .. skillEffect.effect_id)
            end
        else
            table.insert(otherEffectList, skillEffect)
        end
    end

    self.resourceLoader:AddResPath(resources)
    local geocentricAction = GeocentricAction.New(self.brocastCtx, self.minorAction, geocentric1Effect, geocentric2Effect, otherEffectList)
    geocentricAction:Parse()
    -- self:RegEffect(bubbleAction, thunderEffect.trigger)
    -- local delay = DelayAction.New(self.brocastCtx, bubble1Effect.fly_time)
    -- delay:AddEvent(CombatEventType.End, bubbleAction)
    -- self:RegEffect(delay, EffectTrigger.MultiHit)
    self:RegEffect(geocentricAction, EffectTrigger.Follow)
    geocentricAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
end

function  MinorEffectHandler:ParsePokerEffect(pokerList)
    local resources = {}
    local effectObject = nil
    local effectPath = nil

    local poker1Effect = nil
    local poker2Effect = nil
    local otherEffectList = {}

    for _, skillEffect in ipairs(pokerList) do
        effectObject = self.combatMgr:GetEffectObject(skillEffect.effect_id)
        -- effectPath = "prefabs/effect/" .. effectObject.res_id .. ".unity3d"
        effectPath = CombatUtil.CheckSubpackEffect(effectObject.res_id, self.minorAction.subpkgEffectDict)
        table.insert(resources, effectPath)

        if skillEffect.attack_type == EffectAttackType.Poker1 then
            if poker1Effect == nil then
                poker1Effect = skillEffect
            else
                poker1Effect = skillEffect
                Log.Error("存在多个红牌特效:" .. skillEffect.effect_id)
            end
        elseif skillEffect.attack_type == EffectAttackType.Poker2 then
            if poker2Effect == nil then
                poker2Effect = skillEffect
            else
                poker2Effect = skillEffect
                Log.Error("存在多个黑牌特效:" .. skillEffect.effect_id)
            end
        else
            table.insert(otherEffectList, skillEffect)
        end
    end

    -- 特殊地把红牌和黑牌特效加载进来，后续会随机使用
    effectPath = CombatUtil.CheckSubpackEffect(10812, self.minorAction.subpkgEffectDict)
    table.insert(resources, effectPath)
    effectPath = CombatUtil.CheckSubpackEffect(10813, self.minorAction.subpkgEffectDict)
    table.insert(resources, effectPath)

    self.resourceLoader:AddResPath(resources)
    local pokerAction = PokerAction.New(self.brocastCtx, self.minorAction, poker1Effect, poker2Effect, otherEffectList)
    pokerAction:Parse()
    -- self:RegEffect(bubbleAction, thunderEffect.trigger)
    -- local delay = DelayAction.New(self.brocastCtx, bubble1Effect.fly_time)
    -- delay:AddEvent(CombatEventType.End, bubbleAction)
    -- self:RegEffect(delay, EffectTrigger.MultiHit)
    self:RegEffect(pokerAction, EffectTrigger.Follow)
    pokerAction:AddEvent(CombatEventType.End, self.endTaperSupporter)
end

function MinorEffectHandler:GetAttackEffect(actionData)
    local motionId = self.majorCtx:GetMotionId(actionData)
    local skillEffectList = CombatManager.Instance:GetSkillEffectList(actionData.skill_id, motionId)
    for i,skillEffect in ipairs(skillEffectList) do
        if skillEffect.attack_type == EffectAttackType.Attack then
            return skillEffect
        end
    end
end