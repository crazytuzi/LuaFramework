--[[
    filename: ComBattle.Adapter.ConfigAdapter
    description: 配置适配器
    date: 2016.10.26

    author: 杨科
    email:  h3rvgo@gmail.com
-- ]]

local configAdapter = {
    font = {
        DEFAULT = Enums.Font.eDefault,
    },
    fontSize = {
        DEFAULT = Enums.Fontsize.eDefault,
    },

    atomType = {
        eATTACK = ld.FightAtomType.eATTACK, -- 人物攻击
        eSTATE  = ld.FightAtomType.eSTATE,  -- 状态变化
        eVALUE  = ld.FightAtomType.eVALUE,  -- 数值变化
    },

    atomBuffType = {
        eADD  = ld.BuffDisplayState.eAttach,
        eEXEC = ld.BuffDisplayState.eTrigger,
        eDEL  = ld.BuffDisplayState.eDisappear,
    },

    -- 伤害类型
    damageType = {
        --闪避>暴击>格挡>正常伤害
        eDODGE        = ld.LogicEffectType.eDodge, -- 闪避
        eCRITICAL     = ld.LogicEffectType.eCrit, -- 暴击
        eBLOCK        = ld.LogicEffectType.eBlock, -- 格挡
        eNORMAL       = ld.LogicEffectType.eNormalAttack, -- 正常伤害(普通攻击)
        eHEAL         = ld.LogicEffectType.eTreatment, -- 治疗
        eCRITICALHEAL = ld.LogicEffectType.eCritTreatment, -- 暴击治疗
    },

    buffType = {
        eNULL     = ld.BuffState.eNULL,     -- 无
        eBanAct   = ld.BuffState.eBanAct,   -- 眩晕*
        eFreeze   = ld.BuffState.eFreeze,   -- 冰冻*
        eBanRA    = ld.BuffState.eBanRA,    -- 沉默*
        eBanNA    = ld.BuffState.eBanNA,    -- 麻痹*
        eBanRP    = ld.BuffState.eBanRP,    -- 封怒*
        eBanHP    = ld.BuffState.eBanHP,    -- 封血*
        eShield   = ld.BuffState.eShield,   -- 护盾*
        eHPDOT    = ld.BuffState.eHPDOT,    -- 中毒*
        eHPHOT    = ld.BuffState.eHPHOT,    -- 持续恢复*
        eReAttack = ld.BuffState.eReAttack, -- 再次攻击*
        eReNA     = ld.BuffState.eReNA,     -- 再次普攻*
        eBeatBack = ld.BuffState.eBeatBack, -- 反击*
        eRefresh  = ld.BuffState.eRefresh,  -- 清除负面效果*(只处理了在技能直接产生的buff)
        eRebirth  = ld.BuffState.eRebirth,  -- 复活
        eUnDead   = ld.BuffState.eUnDead,   -- 强制不死*
        eUnHurt   = ld.BuffState.eUnHurt,   -- 免疫伤害*
        eLastHurt = ld.BuffState.eLastHurt, -- 抵挡致命伤害*
    },
}

return configAdapter
