local shifa_tongyong = 
{
    CLASS = "composite.QSBSequence",
    ARGS = {

        -- 不可打断
        {
            CLASS = "action.QSBUncancellable"
        },

        -- 无法锁定
        {
            CLASS = "action.QSBSetCannotBeLocked",
            OPTIONS = { isCan = false, isImmuneAoE = true, isImmuneTrap = true },
        },

        -- 清除仇恨
        {
            CLASS = "action.QSBClearHatred",
        },

        -- 播动作特效啥的
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = { animation = "attack11" },
        },

        -- 应用变身buff
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "sspbbd_bianshen1", is_target = false},
        },

        {
            CLASS = "action.QSBAttackFinish",
        },
    }, 
}

return shifa_tongyong

