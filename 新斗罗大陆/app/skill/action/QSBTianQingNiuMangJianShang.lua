--[[
    Class name QSBTianQingNiuMangJianShang
    Create by wanghai 
    @param buff_id:buffid，需要能够存储伤害并且免疫死亡
    @param start_percent, 累计受到百分比的伤害后开始减伤
    @param reduction_percent, 减伤的百分比，0.4就是减伤60%，只收到40%的伤害
    @param end_percent， 减伤的上限，0.6就是累计减伤最大生命值的60%buff失效
--]]
local QSBAction = import(".QSBAction")
local QSBTianQingNiuMangJianShang = class("QSBTianQingNiuMangJianShang", QSBAction)

local QActor = import("...models.QActor")
local QSkill = import("...models.QSkill")

function QSBTianQingNiuMangJianShang:_execute(dt)
    local actor = self._attacker
    local hasBuff, buff = actor:hasSameIDBuff(self._options.buff_id)
    if not hasBuff then
        self:finished()
        return
    end

    local p = app.battle:getFromMap(actor, "QSBTianQingNiuMangJianShang")
    if not p then
        app.battle:setFromMap(actor, "QSBTianQingNiuMangJianShang", 0)
    end

    local this = self
    -- local decreaseHpCallBack = {}
    -- decreaseHpCallBack.name = "decreaseHp"

    -- decreaseHpCallBack.functionBefore = function(params)
    --     local actor, hp, attacker, skill, no_render, isAOE, ignoreAbsorb, not_add_to_log, isExecute = table.unpack(params, 1, params.n)
    --     local hasBuff, buff = actor:hasSameIDBuff(this._options.buff_id)
    --     if not hasBuff then
    --         actor:removeFunctionCallBack(decreaseHpCallBack)
    --     end

    --     local reductionValue = 0
    --     if hasBuff then
    --         reductionValue = app.battle:getFromMap(actor, "QSBTianQingNiuMangJianShang")
    --         if buff:getSavedDamage() > this._options.start_percent * actor:getMaxHp() then
    --             local preHp = hp
    --             hp = hp * this._options.reduction_percent
    --             reductionValue = reductionValue + (preHp - hp)
    --             app.battle:setFromMap(actor, "QSBTianQingNiuMangJianShang", reductionValue)
    --         end
    --     end
    -- end

    -- decreaseHpCallBack.functionEnd = function(params, result)
    --     local resultActor, damage, absorbTotal, overKill = table.unpack(result, 1, result.n)
    --     if buff then
    --         buff:saveDamage(damage)
    --     end

    --     local reductionValue = app.battle:getFromMap(actor, "QSBTianQingNiuMangJianShang")
    --     if reductionValue > this._options.end_percent * actor:getMaxHp() then
    --         if hasBuff then
    --             buff.effects.immune_death = false
    --         end
    --         actor:removeFunctionCallBack(decreaseHpCallBack)
    --     end
    -- end

    -- actor:addFunctionCallBack(decreaseHpCallBack)

    local _decreaseHp = actor.decreaseHp
    function actor:decreaseHp(hp, ...)
        local hasBuff, buff = actor:hasSameIDBuff(this._options.buff_id)
        if not hasBuff then
            actor.decreaseHp = _decreaseHp
        end

        local reductionValue = 0
        if hasBuff then
            reductionValue = app.battle:getFromMap(actor, "QSBTianQingNiuMangJianShang")
            if buff:getSavedDamage() > this._options.start_percent * actor:getMaxHp() then
                local preHp = hp
                hp = hp * this._options.reduction_percent
                reductionValue = reductionValue + (preHp - hp)
                app.battle:setFromMap(actor, "QSBTianQingNiuMangJianShang", reductionValue)
            end
        end

        local damage, absorbTotal, overKill
        self, damage, absorbTotal, overKill = _decreaseHp(actor, hp, ...)

        if buff then
            buff:saveDamage(damage)
        end

        if reductionValue > this._options.end_percent * actor:getMaxHp() then
            if hasBuff then
                buff.effects.immune_death = false
            end
            actor.decreaseHp = _decreaseHp
        end

        return self, damage, absorbTotal, overKill
    end

    self:finished()
end

return QSBTianQingNiuMangJianShang
