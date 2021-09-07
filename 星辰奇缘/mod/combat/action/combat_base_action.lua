-- 战斗基础行动类

CombatBaseAction = CombatBaseAction or BaseClass()

function CombatBaseAction:__init(brocastCtx)
    if brocastCtx == nil then
        Log.Error("[战斗]CombatBaseAction接受到空的上下文")
        print(debug.traceback())
    end
    MemoryCheckTable[self] = Time.time
    self.__ActionName = "<Unknown Event>"
    self.brocastCtx = brocastCtx
    self.StartEvent = {}
    self.EndEvent = {}
    self.HitEvent = {}
    self.MultiHitEvent = {}
    self.MoveEndEvent = {}
    -- setmetatable(self.StartEvent, {__mode = "kv"})
    -- setmetatable(self.EndEvent, {__mode = "kv"})
    -- setmetatable(self.HitEvent, {__mode = "kv"})
    -- setmetatable(self.MultiHitEvent, {__mode = "kv"})
    -- setmetatable(self.MoveEndEvent, {__mode = "kv"})
end

function CombatBaseAction:__delete()
    self.BrocastCtx = nil
    self.StartEvent = nil
    self.EndEvent = nil
    self.HitEvent = nil
    self.MultiHitEvent = nil
    self.MoveEndEvent = nil
end

-- action 为TaperSupporter
function CombatBaseAction:AddTaperEvent(eventType, action, ...)
    self:AddEvent(eventType, action, ...)
end

-- action 为Action时，不用第三个参数
-- action 为function时, 第三个参数为function的owner
function CombatBaseAction:AddEvent(eventType, action, ...)
    local funcInfo = nil
    if type(action) == "function" then
        funcInfo = {func = action, param = {...}}
    elseif type(action) == "table" then
        if action["__ActionName"] ~= nil then
            if action["__ActionName"] == "TaperSupporter" then
                action:Enqueue(eventType)
            end
        end
        if action["Play"] ~= nil then
            funcInfo = {func = action["Play"], param = {action, ...}}
        else
            Log.Error("[战斗]非法Action")
        end
    end

    if funcInfo == nil then
        Log.Error("[战斗]添加事件出错,funcInfo为空\r\n" .. debug.traceback())
    end
    if eventType == CombatEventType.Start then
        table.insert(self.StartEvent, funcInfo)
    elseif eventType == CombatEventType.Hit then
        table.insert(self.HitEvent, funcInfo)
    elseif eventType == CombatEventType.MultiHit then
        table.insert(self.MultiHitEvent, funcInfo)
    elseif eventType == CombatEventType.End then
        table.insert(self.EndEvent, funcInfo)
    elseif eventType == CombatEventType.MoveEnd then
        table.insert(self.MoveEndEvent, funcInfo)
    else
        Log.Error("[战斗]增加不明事件类型:" .. (eventType or "nil" ))
        -- print(debug.traceback())
    end
end

function CombatBaseAction:InvokeAndClear(eventType)
    local event = nil
    if eventType == CombatEventType.Start then
        event = self.StartEvent
        self.StartEvent = {}
    elseif eventType == CombatEventType.Hit then
        event = self.HitEvent
        self.HitEvent = {}
    elseif eventType == CombatEventType.MultiHit then
        event = self.MultiHitEvent
        self.MultiHitEvent = {}
    elseif eventType == CombatEventType.End then
        event = self.EndEvent
        self.EndEvent = {}
    elseif eventType == CombatEventType.MoveEnd then
        event = self.MoveEndEvent
        self.MoveEndEvent = {}
    else
        Log.Error("[战斗]触发不明事件类型:" .. (eventType or "nil" )) -- 可能系:和.的问题
        print(debug.traceback())
    end
    for k, v in ipairs(event) do
        if #v.param == 1 then
            v.func(v.param[1])
        elseif #v.param == 2 then
            v.func(v.param[1],v.param[2])
        elseif #v.param == 3 then
            v.func(v.param[1], v.param[2], v.param[3])
        else
            v.func()
        end
    end
    event = nil
end

function CombatBaseAction:InvokeDelay(func, sec, owner)
    -- local traceback = debug.traceback()
    local dealFunc = function(owner)
        local status, err = xpcall(
            function()
                if self.brocastCtx == nil or self.brocastCtx.controller == nil or self.brocastCtx.controller.combatMgr.isFighting == false then
                    return
                end
                func(owner)
            end
            ,function(err) Log.Error("InvokeDelay出错了:" .. tostring(err) .. ", isFighting = " .. tostring(CombatManager.Instance.isFighting)); Log.Error(debug.traceback()) end)
        if not status then
            Log.Error("CombatBaseAction:InvokeDelay出错了")
        end
    end

    LuaTimer.Add(sec*1000, function () dealFunc(owner)   end)
end

function CombatBaseAction:FindFighter(fighterId)
    return self.brocastCtx:FindFighter(fighterId)
end

function CombatBaseAction:Play()
end

function CombatBaseAction:Parse()
end

-- return GameObject
function CombatBaseAction:GetEffectTarget(actionData, skillEffect)
    local targetPoint = nil
    if skillEffect.target == EffectTarget.Attacker then
        local targetPointCtrl = self:FindFighter(actionData.self_id)
        if targetPointCtrl == nil or BaseUtils.isnull(targetPointCtrl.transform) then
            return self.brocastCtx.controller.MiddleWestPoint
        end
        targetPoint = targetPointCtrl.transform.gameObject
        if skillEffect.range == EffectRange.Group then
            targetPoint = targetPointCtrl.regionalPoint
        end
    else
        local targetPointCtrl = self:FindFighter(actionData.target_id)
        if targetPointCtrl == nil or BaseUtils.isnull(targetPointCtrl.transform) then
            return self.brocastCtx.controller.MiddleWestPoint
        end
        targetPoint = targetPointCtrl.transform.gameObject
        if skillEffect.range == EffectRange.Group then
            targetPoint = targetPointCtrl.regionalPoint
        end
    end
    return targetPoint
end

function CombatBaseAction:DestroyImmediate(gameObject)
    if gameObject ~= nil then
        GameObject.DestroyImmediate(gameObject)
    end
end

function CombatBaseAction:NeedHit(actionData)
    local tcList = actionData.target_changes
    local find = false
    for _, tData in ipairs(tcList) do
        if tData.change_type == 0 and tData.change_val < 0 then
            find = true
            break
        end
    end
    return find
end

function CombatBaseAction:GetAttackSKillEffect(actionData, id)
    local majorCtx = self.brocastCtx.majorCtx
    local combatSkillObj = CombatManager.Instance:GetCombatSkillObject(actionData.skill_id, actionData.skill_lev)
    local motionId = majorCtx:GetMotionId(actionData)
    local skillEffectList = CombatManager.Instance:GetSkillEffectList(actionData.skill_id, motionId)
    if skillEffectList == nil then
        -- Log.Error("[战斗]缺少技能特效信息2：skillId:" .. actionData.skill_id .. " motionId:" .. motionId)
        return nil
    end
    for _, data in ipairs(skillEffectList) do
        if data.attack_type == EffectAttackType.MultiHit
            or data.attack_type == EffectAttackType.Attack
            or data.attack_type == EffectAttackType.Thunder
            or data.attack_type == EffectAttackType.Boom
            or data.attack_type == EffectAttackType.MuiltThunder
            or data.attack_type == EffectAttackType.Bubble1
            or data.attack_type == EffectAttackType.Geocentric1
            or data.attack_type == EffectAttackType.Poker1
            or data.attack_type == EffectAttackType.Poker2
            then
            return data
        end
    end

    local list = DataSkillEffect.data_skill_effect
    for _, data in ipairs(list) do
        if data.skill_id == actionData.skill_id and (data.attack_type == EffectAttackType.MultiHit or data.attack_type == EffectAttackType.Attack or data.attack_type == EffectAttackType.Boom or data.Thunder) then
            if data.hit_distance == 0 then
                data.hit_distance = 500
            end
            if data.hit_time == 0 then
                data.hit_time = 0
            end
            if data.end_time == 0 then
                data.end_time = 300
            end
            return data
        end
    end
    if combatSkillObj.sub_type ~= nil and combatSkillObj.sub_type ~= 2 and combatSkillObj.sub_type ~= 1 then
        BaseUtils.dump(combatSkillObj,"技能数据")
        Log.Error(string.format("GetAttackSKillEffect出错了:skillId:%s, skillLev:%s,无攻击特效", actionData.skill_id, actionData.skill_lev))
    end
end

function CombatBaseAction:GetSkillEffectInfo(actionData,resId)
    if actionData.skill_id == 2000 then
        return
    end
    local majorCtx = self.brocastCtx.majorCtx
    local combatSkillObj = CombatManager.Instance:GetCombatSkillObject(actionData.skill_id, actionData.skill_lev)
    local passive_skillid = nil
    if actionData.show_passive_skills ~= nil and actionData.show_passive_skills[1] ~= nil then
        passive_skillid = actionData.show_passive_skills[1].skill_id
        -- combatSkillObj = CombatManager.Instance:GetCombatSkillObject(actionData.show_passive_skills[1].skill_id, 1)
    end
    local motionId = majorCtx:GetMotionId(actionData)
    local skillEffectList = CombatManager.Instance:GetSkillEffectList(actionData.skill_id, motionId)
    local passiveskillEffectList = CombatManager.Instance:GetSkillEffectList(passive_skillid, motionId)
    if skillEffectList == nil and passiveskillEffectList == nil then
        if combatSkillObj.sub_type ~= nil and combatSkillObj.sub_type ~= 2 and combatSkillObj.sub_type ~= 1 then
            Log.Error("[战斗]缺少技能特效信息2：skillId:" .. actionData.skill_id .. " motionId:" .. motionId.."被动："..tostring(passive_skillid))
        end
        return nil
    end


    local list = DataSkillEffect.data_skill_effect
    for _, data in ipairs(skillEffectList) do
        
        if (data.skill_id == actionData.skill_id or data.skill_id == passive_skillid) and (resId == nil or resId == data.effect_id) then
            return data
        end
    end

    local data = self:GetSpecialSkillEffectInfo(actionData,resId)
    if data then
        return data
    end

    if passiveskillEffectList == nil then
        Log.Error("[战斗]缺少技能特效信息3：skillId:" .. actionData.skill_id .. " motionId:" .. motionId.."被动："..tostring(passive_skillid))
        return nil
    end
    for _, data in ipairs(passiveskillEffectList) do
        if (data.skill_id == actionData.skill_id or data.skill_id == passive_skillid) and (resId == nil or resId == data.effect_id) then
            return data
        end
    end
    if combatSkillObj.sub_type ~= nil and combatSkillObj.sub_type ~= 2 and combatSkillObj.sub_type ~= 1 then
        Log.Error(string.format("获取特效配置信息出错了:skillId:%s, effectId:%s", actionData.skill_id, resId))
    end
end

function CombatBaseAction:GetSpecialSkillEffectInfo(actionData,resId)
    -- 判断爱丽丝的纸牌特效
    if (actionData.skill_id == 60550 or actionData.skill_id == 60551 or actionData.skill_id == 60552 or actionData.skill_id == 60553)
        and (resId == 108120 or resId == 108121 or resId == 108122 or resId == 108130 or resId == 108131 or resId == 108132) then
            local skillEffectList = DataSkillEffect.data_skill_effect["60550_0"]
            for _, data in ipairs(skillEffectList) do
                if data.effect_id == 108120 then
                    return data
                end
            end
    end
end