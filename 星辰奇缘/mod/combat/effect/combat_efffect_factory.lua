EffectFactory = EffectFactory or {}

-- attacker = GameObject
-- target = GameObject
function EffectFactory.CreateGeneral(brocastCtx, minoraction, actionData, attacker, target, sEffectObject, effectObject)
    if sEffectObject.effect_type == EffectType.FlyEffect then
        return FlyEffect.New(brocastCtx, minoraction, actionData, attacker, target, sEffectObject, effectObject)
    elseif sEffectObject.effect_type == EffectType.StaticEffect then
        return StaticEffect.New(brocastCtx, minoraction, actionData, attacker, target, sEffectObject, effectObject)
    elseif sEffectObject.effect_type == EffectType.HitFlyEffect then
        return StaticEffect.New(brocastCtx, minoraction, actionData, attacker, target, sEffectObject, effectObject)
    end
end

-- 创建漂血
function EffectFactory.AttrChangeEffectByAction(brocastCtx, actionData, ratio)
    return EffectFactory.AttrChangeEffectByActionStep(brocastCtx, actionData, ratio, false)
end
function EffectFactory.AttrChangeEffectByActionStep(brocastCtx, actionData, ratio, IsStep)
    local targetChange = EffectFactory.AttrChangeEffect(brocastCtx, actionData.target_changes, actionData.target_id, actionData.is_crit, ratio, IsStep)
    local syncSupporter = SyncSupporter.New(brocastCtx)
    syncSupporter:AddAction(targetChange)
    local selfChangeList = {}
    for _, data in ipairs(actionData.self_changes) do
        if data.change_type == 0 and data.change_val > 0 then
            table.insert(selfChangeList, data)
        end
    end
    if #selfChangeList > 0 then
        local selfChange = EffectFactory.AttrChangeEffect(brocastCtx, selfChangeList, actionData.self_id, 0, ratio, IsStep)
        syncSupporter:AddAction(selfChange)
    end
    return syncSupporter
end

function EffectFactory.AttrChangeEffect(brocastCtx, changeList, fighterId, isCrit, ratio, IsStep)
    if IsStep == nil then
        IsStep = false
    end
    return AttrChangeEffect.New(brocastCtx, changeList, fighterId, isCrit, ratio, IsStep)
end
