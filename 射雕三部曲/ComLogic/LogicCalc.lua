local LogicCalc = class("LogicCalc" , function(data)
    return {data = data}
end)

function LogicCalc:getEffectType_attack(hero_from , hero_to)
    --[[
        a=1;
        b=10;
        q=0.9888;
        闪避X值=Max( ( 守方闪避–(攻方命中-100) ) ,0);
        暴击X值=Max( ( 攻方暴击 - 守方韧性) , 0);
        格挡X值=Max( ( 守方格挡 - 攻方破击 ) , 0 ) ;
        权值= 向下取整( IF(x<=b, x, a*( 1 - q^(x-b) ) / ( 1 - q ) + b ) * 100 );
        闪避权值 = 权值 ( 闪避X值 ) + 守方额外闪避率DODR * 100;
        暴击权值 = 权值 ( 暴击X值 ) + 攻方额外暴击率CRIR * 100;
        格挡权值 = 权值 ( 格挡X值 ) + 守方额外格挡率BLOR * 100;

        闪避区间: [ 0 , 闪避权值 ) ;
        格挡区间: [ 闪避权值, 闪避权值 + 格挡权值) ;
        暴击区间: [ 闪避权值 + 暴击权值, 闪避权值 + 格挡权值 + 暴击权值) ;
        正常伤害区间: [ 闪避权值 + 暴击权值 + 格挡权值, 10000 );
    ]]
    local function valueFix(x)
        local a = 1
        local b = 10
        local q = 0.9888
        local ret = 0
        if (x <= b) then
            ret = x
        else
            ret = a * (1 - math.pow(q , x - b)) / (1 - q) + b
        end
        return math.floor(ret * 100)
    end
    local rand = self.data.rand:random(0 , 9999)
    local value = math.max(valueFix(math.max(hero_to.DOD - (hero_from.HIT - 100) , 0)) + hero_to.DODR * 100 - hero_from.HITR * 100 , 0)
    if (value >= 10000) or (value > rand) then
        return ld.LogicEffectType.eDodge   --闪避
    end
    value = value + math.max(valueFix(math.max(hero_to.BLO - hero_from.BOG , 0)) + hero_to.BLOR * 100 - hero_from.BOGR * 100 , 0)
    if (value >= 10000) or (value > rand) then
        return ld.LogicEffectType.eBlock    --格挡
    end
    value = value + math.max(valueFix(math.max(hero_from.CRI - hero_to.TEN , 0)) + hero_from.CRIR * 100 - hero_to.TENR * 100 , 0)
    if (value >= 10000) or (value > rand) then
        return ld.LogicEffectType.eCrit    --暴击
    end
    return ld.LogicEffectType.eNormalAttack    --正常伤害
end

function LogicCalc:getEffectType_heal(hero)
    --[[
        暴击值=攻方暴击;
        暴击区间: [ 0, 暴击值 ) ;
        正常治疗区间: [ 暴击值, 100 ) ;
    ]]
    local function valueFix(x)
        local a = 0.7
        local b = 10
        local q = 0.988
        local ret = 0
        if (x <= b) then
            ret = x
        else
            ret = a * (1 - math.pow(q , x - b)) / (1 - q) + b
        end
        return math.floor(ret * 100)
    end
    local rand = self.data.rand:random(0 , 9999)
    local value = math.max(valueFix(hero.CRI) + hero.CRIR * 100 , 0)
    if (value >= 10000) or (value > rand) then
        return ld.LogicEffectType.eCritTreatment   --暴击治疗
    end
    return ld.LogicEffectType.eTreatment   --治疗
end

--计算伤害强度
function LogicCalc:getDamageStrength(hero_from , hero_to)
    --[[
        攻击 = AP * (APR/10000+1);
        防御 = DEF * (DEFR/10000+1);

        伤害强度= Max（攻方攻击-防方防御,攻方攻击*0.1）
    ]]
    --攻方攻击
    local ap_from = hero_from.AP * (hero_from.APR / 10000 + 1)
    --守方防御
    local def_to = hero_to.DEF * (hero_to.DEFR / 10000 + 1)
    --伤害强度
    return math.max(ap_from - def_to , ap_from * 0.1)
end

--计算阵营加成
function LogicCalc:getDamageFormation(hero_from , hero_to)
    --[[
        阵营伤害% =
        攻方A阵营,防方B阵营,则=攻方B阵营伤害加成%RBDAMADDR  - 防方A阵营伤害减免%RADAMCUTR;
        攻方B阵营,防方A阵营,则=攻方A阵营伤害加成%RADAMADDR  - 防方B阵营伤害减免%RBDAMCUTR;
        攻方A阵营,防方C阵营,则=攻方C阵营伤害加成%RCDAMADDR  - 防方A阵营伤害减免%RADAMCUTR;
        攻方C阵营,防方A阵营,则=攻方A阵营伤害加成%RADAMADDR  - 防方C阵营伤害减免%RCDAMCUTR;
        攻方B阵营,防方C阵营,则=攻方C阵营伤害加成%RCDAMADDR  - 防方B阵营伤害减免%RBDAMCUTR;
        攻方C阵营,防方B阵营,则=攻方B阵营伤害加成%RBDAMADDR  - 防方C阵营伤害减免%RCDAMCUTR;
        攻方A阵营,防方A阵营,则=攻方A阵营伤害加成%RADAMADDR  - 防方A阵营伤害减免%RCDAMCUTR;
        攻方B阵营,防方B阵营,则=攻方B阵营伤害加成%RCDAMADDR  - 防方B阵营伤害减免%RBDAMCUTR;
        攻方C阵营,防方C阵营,则=攻方C阵营伤害加成%RBDAMADDR  - 防方C阵营伤害减免%RCDAMCUTR;
    ]]
    -- if hero_from.RACE and hero_to.RACE then
    --     local v1 = hero_from.RACE.ADDR[hero_to.RACE.ID]
    --     local v2 = hero_to.RACE.CUTR[hero_from.RACE.ID]
    --     return v1 - v2
    -- end

    if hero_from.RaceId and hero_to.RaceId then
        local v1 , v2 = 0 , 0
        if hero_to.RaceId == 1 then
            v1 = hero_from.RADAMADDR
        elseif hero_to.RaceId == 2 then
            v1 = hero_from.RBDAMADDR
        elseif hero_to.RaceId == 3 then
            v1 = hero_from.RCDAMADDR
        end
        if hero_from.RaceId == 1 then
            v2 = hero_to.RADAMCUTR
        elseif hero_from.RaceId == 2 then
            v2 = hero_to.RBDAMCUTR
        elseif hero_from.RaceId == 3 then
            v2 = hero_to.RCDAMCUTR
        end
        return v1 - v2
    end
    return 0
end

function LogicCalc:calcRP_from(hero_from)
    --攻击者增加固定值
    local rp = 25
    return math.min(ld.MaxRP - hero_from.RP , rp)
end

function LogicCalc:calcRP_to(hero_to , damage)
    if hero_to.IsBoss or hero_to.isBoss then
        return 0
    end
    --怒气值= (( 受到伤害值 / 自身生命上限 ) * 系数b)向下取整；
    local rp = 100
    local r_damage = math.min(damage , hero_to.HP)
    return math.min(math.floor((r_damage / hero_to.MHP) * rp) , ld.MaxRP - hero_to.RP)
end

function LogicCalc:calcRP_useSkill(hero)
    return -hero.RP
end

function LogicCalc:calcRP_kill(hero)
    if hero.IsBoss or hero.isBoss then
        return 0
    end
    local rp = 25
    return math.min(rp , ld.MaxRP - hero.RP)
end

function LogicCalc:getFirstPriorityFix(hero_from , hero_to)
--[[
    一级属性系数=攻方INTE>攻方STR?(攻方INTE - 防方INTE)/100 : (攻方STR – 防方STR)/100 ;
]]
    if hero_from.INTE > hero_from.STR then
        return (hero_from.INTE - hero_to.INTE)/100
    else
        return (hero_from.STR - hero_to.STR)/100
    end
end

--[[
    params:
        hero_from
        hero_to
        skillId
        newfactor
        multi
    return
        hp
]]
function LogicCalc:calcHP(params)
    local multi_addition = 1.1
    local type_factor = 1
    local e_type = (ld.getSkill(params.skillId).type == 0) and self:getEffectType_attack(params.hero_from , params.hero_to) or self:getEffectType_heal(params.hero_from)
    if e_type == ld.LogicEffectType.eDodge then
        --闪避
        return e_type
    elseif e_type == ld.LogicEffectType.eCrit then
        --暴击
        --暴击伤害率=Max(1.5 + ( 攻方必杀 - 守方守护 ) / 100,1) ;
        type_factor = math.max(1.5 + (params.hero_from.CRID - params.hero_to.TEND)/100 , 1)
    elseif e_type == ld.LogicEffectType.eBlock then
        --格挡伤害值= 正常伤害 * 0.5 ;
        type_factor = 0.5
    elseif e_type == ld.LogicEffectType.eNormalAttack then
        type_factor = 1
    elseif e_type == ld.LogicEffectType.eTreatment then
        type_factor = 1
    elseif e_type == ld.LogicEffectType.eCritTreatment then
        type_factor = 1.25
    end

    local factor = (params.newfactor or ld.getSkill(params.skillId).factor) / 10000
    if ld.getSkill(params.skillId).type == 0 then
        --[[
            原始伤害值1=普攻=伤害强度*普攻系数值Factor  * (1+一级属性系数) ;
            原始伤害值2=技攻=伤害强度*技能系数值Factor  * (1+一级属性系数) *（1+（（怒气-100）/200）
        ]]
        local damageStr = self:getDamageStrength(params.hero_from , params.hero_to)
        local damageBase = damageStr * factor * (1 + self:getFirstPriorityFix(params.hero_from , params.hero_to))
        if params.hero_from.NAId == params.skillId then
            damageBase = damageBase
        --elseif params.hero_from.RAId == params.skillId then
        else--合体技伤害
            damageBase = damageBase * (1 + (params.hero_from.RP - ld.MaxRP/2)/ld.MaxRP)
        end
        if params.multi then
            damageBase = damageBase * multi_addition
        end
        --[[
            正常伤害值=原始伤害值 * Max((1 + 攻方伤害加成%DAMADDR/10000 - 防方伤害减免%DAMCUTR/10000 +阵营伤害%/10000) * (1 + 攻方独立A伤害加成%ADAMADDR/10000 - 防方独立A伤害减免%ADAMCUTR/10000) ,0.01);
        ]]
        local damageNormal = damageBase * math.max((1 + params.hero_from.DAMADDR/10000 - params.hero_to.DAMCUTR/10000 + self:getDamageFormation(params.hero_from , params.hero_to)/10000) * (1 + params.hero_from.ADAMADDR/10000 - params.hero_to.ADAMCUTR/10000) , 0.01)
        --最终伤害 =Max([ 暴击伤害值 or 格挡伤害值 or正常伤害值 ] + (攻方伤害加成 - 防方伤害减免), 1);
        local lastDamage = -math.floor(math.max(type_factor * damageNormal + params.hero_from.DAMADD - params.hero_to.DAMCUT , 1))

        -- 统计侠客的伤害和承伤
        require("ComLogic.StatisticsManager")
        StatisticsManager.damageStatistics(params.hero_from, math.abs(lastDamage))
        StatisticsManager.behitStatistics(params.hero_to, math.abs(lastDamage))

        return e_type , lastDamage
    else
        --[[
            原始治疗值 = 施放者攻击 * 技能系数值Factor;
            正常治疗值 = Max((原始治疗值 + 施放者CP + 承受者BCP  ) * ( 1 +施放者CPR/10000 + 承受者BCPR/10000 ), 0 );

            暴击治疗值 =正常治疗值 * 1.25 ;
        ]]
        local heal_org = params.hero_from.AP * (params.hero_from.APR / 10000 + 1)  * factor
        local heal = math.max((heal_org + params.hero_from.CP + params.hero_to.BCP) * (1 + params.hero_from.CPR/10000 + params.hero_to.BCPR/10000) , 0)
        if params.multi then
            heal = heal * multi_addition
        end
        local lastHeal = math.floor(heal * type_factor--[[暴击加成值]])

        -- 统计侠客的治疗
        require("ComLogic.StatisticsManager")
        StatisticsManager.healStatistics(params.hero_from, lastHeal)

        return e_type , lastHeal
    end
end

return LogicCalc