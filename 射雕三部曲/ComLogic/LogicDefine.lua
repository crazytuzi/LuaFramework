require("Config.AttackModel")
require("Config.BuffModel")

if not dump then
    dump = function( ... )end
end

ld = {
    AttackType = {
        eNormal = 1,    --普攻
        eSkill = 2,    --技攻
        eSpecial = 3,   --两者皆不是（反击）
    },
    HeroStandType = {
        eEnemy = 1,     --敌人
        eTeammate = 2,  --队友
    },
    FightAtomType = {
        eATTACK = 1 ,   --人物攻击
        eSTATE = 2,     --状态变化
        eVALUE = 3,     --数值变化
    },
    -- 攻击效果类型
    LogicEffectType = {
        --闪避>暴击>格挡>正常伤害
        eDodge = 1, --闪避
        eCrit = 2, --暴击
        eBlock = 3, --格挡
        eNormalAttack = 4, --正常伤害(普通攻击)
        eTreatment = 5, --治疗
        eCritTreatment = 6, --暴击治疗
    },
    --最大怒气值
    MaxRP = 200,
    --buff显示阶段
    BuffDisplayState = {
        eAttach = 1,    --附加
        eTrigger = 2,   --触发
        eDisappear = 3, --结束
    },
    --buff执行时刻
    BuffCalcPoint = {
        eNULL = 0,
        eBefore_all = 1,            --伤害计算前（多人）
        eBefore_one = 2,            --伤害计算前（单人）
        eAfter_one = 3,             --伤害计算后 (单人)
        eAfter_all = 4,             --伤害计算后（多人）
        eAttackOver = 5,            --攻击结束
        eRoundOver = 6,             --回合结束
        eBattleStart = 7,           --开场触发
        eDeadTime = 8,              --死亡时触发
        eHealed = 9,                --被治疗
        eRightNow = 10,             --附加时执行
        eHurt = 11,                 --受到伤害时
    },
    --触发条件枚举1
    TriggerPoint1 = {
        eNone = 0, --无
        eAttack = 1, --攻击
        eNormalAttack = 2, --普攻
        eSkillAttack = 3, --技攻
        eAttacked = 4, --被攻击
        eNormalAttacked = 5, --被普攻
        eSkillAttacked = 6, --被技攻
        eStartFighting = 7, --开场触发
        eRoundOver = 8,     --回合结束
        eAttackOver = 9,    --攻击结束
        eDeadTime = 10,     --死亡时触发
        eHealed = 11,       --被治疗
        eRightNow = 12,     --附加时执行
        eHurt = 13,         --受到伤害时
    },

    --触发条件枚举2
    TriggerPoint2 = {
        eNone = 0, --无
        eBeforeCalculation_all = 1, --计算前（多人）
        eBeforeCalculation = 2, --计算前（单人）
        eAfterCalculation = 3, --计算后（单人）
        eAfterCalculation_all = 4, --计算后（多人）
    },

    --触发条件枚举3
    TriggerPoint3 = {
        eNULl = 0,      --无
        eAfterCrit = 1, --暴击后
        eAfterDodge = 2, --闪避后
        eAfterBlock = 3, --格挡后
        eAfterNoDodge = 4, --未闪避后
    },

    --buff所对应的持续状态
    BuffState = {
        eNULL = 0,    --无
        eBanAct = 1,  --眩晕*
        eBanRA = 2,   --沉默*
        eBanNA = 3,   --麻痹*
        eBanRP = 4,   --封怒*
        eBanHP = 5,   --封血*
        eShield = 6,  --护盾*
        eHPDOT = 7,   --中毒*
        eHPHOT = 8,   --持续恢复*
        eReAttack = 9,--再次攻击*
        eReNA = 10,   --再次普攻*
        eBeatBack = 11, --反击*
        eRefresh = 12,--清除负面效果*(只处理了在技能直接产生的buff)
        eRebirth = 13,  --复活
        eUnDead = 14,   --强制不死*
        eUnHurt = 15,   --免疫伤害*
        eLastHurt = 16, --抵挡致命伤害*
        eUnThorn = 17,  --免疫反伤
        eUnCUTRP = 18,  --免疫降怒
        eUnDebuff = 19, --免疫负面效果
        eHPHole = 20,   --治疗黑洞
        eFreeze = 21,   --冰冻
        eReAttack2 = 22,-- 再次怒技(不扣怒，不加怒)
        eUnControl = 23 ,--免疫控制
        eCleanBuff = 24,--清除无敌  不死   护盾   回合状态免疫
    }
}

--位置与阵型的关系
ld.getStandType = function(posId)
    if posId > 6 then
        return ld.HeroStandType.eEnemy
    end
    return ld.HeroStandType.eTeammate
end

-- 珍兽的站位与阵型关系
ld.getPetStandType = function(posId)
    if posId > 1 then
        return ld.HeroStandType.eEnemy
    end
    return ld.HeroStandType.eTeammate
end

--通过skillId获取对应的技能
ld.getSkill = function(skillId)
    return AttackModel.items[skillId]
end

--通过buffId获取对应的buff
ld.getBuff = function(buffId)
    return BuffModel.items[buffId]
end

--去除前后的空格
ld.trim = function(str)
    return (str:gsub("^%s*(.-)%s*$", "%1"))
end

--分割字符串，不返回空的部分
ld.split = function(str, delimiter)
    if str==nil or str=='' or delimiter==nil then
        return nil
    end

    local result = {}
    local tmp1 = (delimiter == '.' and '%.' or delimiter)
    for match in (str..delimiter):gmatch("(.-)"..tmp1) do
        if match ~= "" then
            table.insert(result, ld.trim(match))
        end
    end
    return result
end

ld.pairsByKeys = function(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0                 -- iterator variable
    local function iter()    -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            if t[a[i]] == nil then
                return iter()
            else
                return a[i], t[a[i]]
            end
        end
    end
    return iter
end

--判断是否是合体技
ld.checkComboSkill = function( skillId )
    -- if math.floor(skillId / 1000) % 1000 == 3 then
    --     return true
    -- end
    require("Config.HeroJointModel")
    for _, comboSkillInfo in pairs(HeroJointModel.items) do
        if comboSkillInfo.jointSkillID == skillId then
            return true
        end
    end

    return false
end

return ld