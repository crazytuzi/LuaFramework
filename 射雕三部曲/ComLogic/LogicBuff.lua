local LogicBuff = class("LogicBuff" , function(battaData)
    return {
        data = battaData,
    }
end)

--buff计算
--[[
    params:
        posId    buff的依附者
        point    buff的触发时刻
        special
        extend   扩展数据
    return:
        NULL
]]
function LogicBuff:calc(params)
    local buffIdList = self.data:getBuff({
        point = params.point,
        posId = params.posId,
    })
    local active = (params.extend.obj_attacker == params.posId)
    if buffIdList then
        for buffId , buffList in ld.pairsByKeys(buffIdList) do
            for uniqueId , buff in ld.pairsByKeys(buffList) do
                --判断buff是否能在这个时刻执行
                if (not params.special) or (params.special == buff.stateEnum) then
                    if self:checkBuffPoint({buff = buff , attackType = params.extend.attackType , e_type = params.extend.e_type , point = params.point , active = active , damage = params.extend.damage}) then
                        local hasExcute = self:calcBuff({posId = params.posId , buff = buff , extend = params.extend})
                        if hasExcute and self:calcLifeTime(buff) then
                            --从列表中删除
                            self.data:deleteBuff({
                                point = params.point,
                                posId = params.posId,
                                buffId = buffId,
                                uniqueId = uniqueId,
                            })
                        end
                    end
                end
            end
        end
    end
end

--[[
    params:
        posId
        buff
        extend
    return:
        bool
]]
function LogicBuff:calcBuff(params)
    local otarget = nil
    if (type(params.extend.obj_target) ~= "table") or (not params.extend.obj_target.isHero) then
        otarget = params.extend.obj_target
    else
        if not params.extend.obj_target.isPet then
            otarget = params.extend.obj_target.idx
        end
    end
    --获取打击目标
    local targetFunc = require("ComLogic.LogicTarget").new({data = self.data})
    local target = targetFunc:getTarget({
        posId = params.posId ,
        extend = params.buff.targetNum ,
        type1 = params.buff.targetCampEnum,
        type2 = params.buff.targetEnum,
        target = otarget,
        viewBuff = params.buff.ID,
    })
    local hasExcute = false
    for m , n in ipairs(target) do
        --判断buff条件
        if self:checkCondition({buff = params.buff , extend = params.extend , target = n}) then
            hasExcute = true
            --执行
            self:calcEffect({buff = params.buff , extend = params.extend , target = n})
            --执行特殊buff
            self:calcSpecial({buff = params.buff , extend = params.extend , target = n})
        end
    end
    return hasExcute
end

local function check_type_active(point , active)
    if active then
        if point == ld.TriggerPoint1.eNormalAttack or
            point == ld.TriggerPoint1.eAttack or
            point == ld.TriggerPoint1.eSkillAttack then
            return true
        end
    else
        if point == ld.TriggerPoint1.eNormalAttacked or
            point == ld.TriggerPoint1.eSkillAttacked or
            point == ld.TriggerPoint1.eAttacked then
            return true
        end
    end
    return false
end

local function check_type_attactype(point , etype)
    if etype == ld.AttackType.eNormal then
        if point == ld.TriggerPoint1.eNormalAttack or
            point == ld.TriggerPoint1.eNormalAttacked or
            point == ld.TriggerPoint1.eAttack or
            point == ld.TriggerPoint1.eAttacked then
            --普攻、被普攻、攻击、被攻击
            return true
        end
    elseif etype == ld.AttackType.eSkill then
        if point == ld.TriggerPoint1.eSkillAttack or
            point == ld.TriggerPoint1.eSkillAttacked or
            point == ld.TriggerPoint1.eAttack or
            point == ld.TriggerPoint1.eAttacked then
            --技攻、被技攻、攻击、被攻击
            return true
        end
    end
    return false
end

local function check_type_effect(point , effect)
    if point == ld.TriggerPoint3.eNULl then
        --全部通过
        return true
    elseif point == ld.TriggerPoint3.eAfterCrit then
        if effect == ld.LogicEffectType.eCrit then
            --暴击后
            return true
        end
    elseif point == ld.TriggerPoint3.eAfterDodge then
        if effect == ld.LogicEffectType.eDodge then
            --闪避后
            return true
        end
    elseif point == ld.TriggerPoint3.eAfterBlock then
        if effect == ld.LogicEffectType.eBlock then
            --格挡后
            return true
        end
    elseif point == ld.TriggerPoint3.eAfterNoDodge then
        if effect ~= ld.LogicEffectType.eDodge then
            --未闪避后
            return true
        end
    end
    return false
end

local function check_type_effects(point , effectList)
    if point == ld.TriggerPoint3.eNULl then
        --全部通过
        return true
    elseif point == ld.TriggerPoint3.eAfterCrit then
        if effectList[ld.LogicEffectType.eCrit] then
            --暴击后
            return true
        end
    elseif point == ld.TriggerPoint3.eAfterDodge then
        if effectList[ld.LogicEffectType.eDodge] then
            --闪避后
            return true
        end
    elseif point == ld.TriggerPoint3.eAfterBlock then
        if effectList[ld.LogicEffectType.eBlock] then
            --格挡后
            return true
        end
    elseif point == ld.TriggerPoint3.eAfterNoDodge then
        for i , v in ld.pairsByKeys(effectList) do
            if (i ~= ld.LogicEffectType.eDodge) and (v == true) then
                --未闪避后
                return true
            end
        end
    end
    return false
end

--[[
    params:
        buff            buff对象
        attackType      攻击类型
        e_type          伤害类型
        point           buff的触发时刻
        active          是否主动方（攻击者）
        damage          伤害值
    return:
        bool
]]
function LogicBuff:checkBuffPoint(params)
    if params.point == ld.BuffCalcPoint.eAttackOver or
        params.point == ld.BuffCalcPoint.eRoundOver or
        params.point == ld.BuffCalcPoint.eBattleStart or
        params.point == ld.BuffCalcPoint.eDeadTime or
        params.point == ld.BuffCalcPoint.eHealed or
        params.point == ld.BuffCalcPoint.eRightNow or
        params.point == ld.BuffCalcPoint.eHurt then
        --攻击结束、回合结束、开场触发、死亡时触发
        return true
    elseif params.point == ld.BuffCalcPoint.eBefore_all or
        params.point == ld.BuffCalcPoint.eBefore_one then
        --伤害计算前
        if check_type_active(params.buff.point1 , params.active) then
            return check_type_attactype(params.buff.point1 , params.attackType)
        end
    elseif params.point == ld.BuffCalcPoint.eAfter_one then
        --伤害计算后 被攻击者
        if check_type_active(params.buff.point1 , params.active) then
            if params.buff.point1 == ld.TriggerPoint1.eAttacked or
                params.buff.point1 == ld.TriggerPoint1.eSkillAttacked or
                params.buff.point1 == ld.TriggerPoint1.eNormalAttacked then
                --被攻击、被普攻、被技攻
                if params.damage > 0 then
                    --治疗不算被攻击
                    return false
                end
            end
            if check_type_attactype(params.buff.point1 , params.attackType) then
                return check_type_effect(params.buff.point3 , params.e_type)
            end
        end
    elseif params.point == ld.BuffCalcPoint.eAfter_all then
        --满足其一，便算触发
        if check_type_active(params.buff.point1 , params.active) then
            if params.buff.point1 == ld.TriggerPoint1.eAttacked or
                params.buff.point1 == ld.TriggerPoint1.eSkillAttacked or
                params.buff.point1 == ld.TriggerPoint1.eNormalAttacked then
                --被攻击、被普攻、被技攻
                return false
            elseif params.buff.point1 == ld.TriggerPoint1.eAttack or
                params.buff.point1 == ld.TriggerPoint1.eSkillAttack or
                params.buff.point1 == ld.TriggerPoint1.eNormalAttack then
                if check_type_attactype(params.buff.point1 , params.attackType) then
                    if type(params.e_type) == "number" then
                        return check_type_effect(params.buff.point3 , params.e_type)
                    elseif type(params.e_type) == "table" then
                        return check_type_effects(params.buff.point3 , params.e_type)
                    end
                end
            end
        end
    end

    return false
end

--[[
    params:
        buff        buff对象
        target      buff目标
        extend      扩展参数
    return:
        BOOL
]]
function LogicBuff:checkCondition(params)
    local parse = require("ComLogic.LogicParse").new({
        owner = params.buff.fromPos,
        target = params.target,
        self = params.extend.obj_self,
        attacker = params.extend.obj_attacker,
        defender = params.extend.obj_defender,
        damage = params.extend.damage,
        data = self.data,
        logicbuff = self,
        buff = params.buff,
    })
    return parse:parseCondition(params.buff.condition)
end

--[[
    params:
        buff        buff对象
        target      buff目标
        extend      扩展参数
    return:
        NULL
]]
function LogicBuff:calcEffect(params)
    local atom = require("ComLogic.LogicRet").new()
    self.data:pushRecord(atom)

    local parse = require("ComLogic.LogicParse").new({
        owner = params.buff.fromPos,
        target = params.target,
        self = params.extend.obj_self,
        attacker = params.extend.obj_attacker,
        defender = params.extend.obj_defender,
        damage = params.extend.damage,
        data = self.data,
        buff = params.buff,
        logicbuff = self,
    })
    parse:parseCalc(params.buff.effectExp)
    self.data:popRecord()

    local c_atom = self.data:getRecord():addAtom()
    c_atom:addBuff({
        buffId = params.buff.ID,
        uniqueId = params.uniqueId,
        toPos = params.target,
        fromPos = params.buff.fromPos,
        type = ld.BuffDisplayState.eTrigger,
        extend = params.buff.extend,
    })
    c_atom:set("exec" , atom:getResult())
end

--[[
    执行特殊buff
    params:
        buff        buff对象
        target      buff目标
        extend      扩展参数
    return:
        NULL
]]
function LogicBuff:calcSpecial(params)
    if params.buff.stateEnum == ld.BuffState.eRefresh then
        --清除负面效果
        for point , posList in ld.pairsByKeys(self.data.BuffCache) do
            if posList[params.target] then
                for buffid , buffList in ld.pairsByKeys(posList[params.target]) do
                    for i , buff in ld.pairsByKeys(buffList) do
                        if buff.isDebuff == 0 then
                            self.data:deleteBuff({
                                point = ld.BuffCalcPoint.eRoundOver,
                                posId = params.target,
                                buffId = buffid,
                                uniqueId = i,
                            })
                        end
                    end
                end
            end
        end
    end
    if params.buff.stateEnum == ld.BuffState.eCleanBuff then
        --清除无敌  不死   护盾   回合状态免疫
        for point , posList in ld.pairsByKeys(self.data.BuffCache) do
            if posList[params.target] then
                for buffid , buffList in ld.pairsByKeys(posList[params.target]) do
                    for i , buff in ld.pairsByKeys(buffList) do
                        if (buff.stateEnum == ld.BuffState.eUnDead) or (buff.stateEnum == ld.BuffState.eShield)
                            or (buff.stateEnum == ld.BuffState.eUnHurt) or (buff.stateEnum == ld.BuffState.eUnHurt)
                            or (buff.stateEnum == ld.BuffState.eUnThorn) or (buff.stateEnum == ld.BuffState.eUnCUTRP)
                            or (buff.stateEnum == ld.BuffState.eUnDebuff) or (buff.stateEnum == ld.BuffState.eUnControl) then
                            self.data:deleteBuff({
                                point = ld.BuffCalcPoint.eRoundOver,
                                posId = params.target,
                                buffId = buffid,
                                uniqueId = i,
                            })
                            return
                        end
                    end
                end
            end
        end
    end
end

--[[
    结算执行次数
    buff        buff对象
    return bool 是否释放buff
]]
function LogicBuff:calcLifeTime(buff)
    --小与0表示不限次数
    if buff.lifeTime <= 0 then
        return false
    end
    buff.lifeTime = buff.lifeTime - 1
    if buff.lifeTime <= 0 then
        return true
    end
    return false
end

--[[
    结算回合结束,分两类。
]]
function LogicBuff:calcLifeRound()
    for point , posList in ld.pairsByKeys(self.data.BuffCache) do
        for pos , buffIdList in ld.pairsByKeys(posList) do
            for buffid , buffList in ld.pairsByKeys(buffIdList) do
                for i , buff in ld.pairsByKeys(buffList) do
                    --这里只处理正常的buff,特殊buff有下面的函数calcLifeSpecial
                    if buff.stateEnum == ld.BuffState.eNULL or
                        --回合技能、宠物技能在这里结算
                        buff.extend.lifeRound or buff.extend.lifeRound_pet then
                        --只结算普通buff类
                        if buff.lifeRound <= 0 then
                            --小与0表示不限次数
                        else
                            buff.lifeRound = buff.lifeRound - 1
                            if buff.lifeRound <= 0 then
                                self.data:deleteBuff({
                                    point = ld.BuffCalcPoint.eRoundOver,
                                    posId = pos,
                                    buffId = buffid,
                                    uniqueId = i,
                                })
                            end
                        end
                    end
                end
            end
        end
    end
end

--结算特殊类buff的回合
function LogicBuff:calcLifeSpecial(posId)
    if self.data.BuffLinked[posId] then
        for i , v in ld.pairsByKeys(self.data.BuffLinked[posId]) do
            local buff = self.data:getBuff({
                point = v.point,
                posId = v.tpos,
                buffId = v.buffId,
                uniqueId = v.uniqueId,
            })
            if buff then
                if (not buff.extend.lifeRound) and (not buff.extend.lifeRound_pet) then
                    if buff.lifeRound <= 0 then
                        --小与0表示不限次数
                    else
                        buff.lifeRound = buff.lifeRound - 1
                        if buff.lifeRound <= 0 then
                            --删除
                            self.data:deleteBuff({
                                point = ld.BuffCalcPoint.eAttackOver,
                                posId = v.tpos,
                                buffId = v.buffId,
                                uniqueId = v.uniqueId,
                            })
                        end
                    end
                end
            else
                error(TR("buff和linked不对应！"))
            end
        end
    end
end

return LogicBuff