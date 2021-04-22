local hl_qingyufenghuang_dazhao_buff_trigger3 = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 3},
                },
                {
                    CLASS = "action.QSBDecreaseHpByCostHp",
                    OPTIONS = {mode = "max_hp_percent", value = 0.03, multiply_cofficient = 2, ignore_absorb = true},
                },
            },
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "hl_qingyufenghuang_attack01_3",is_hit_effect = true},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return hl_qingyufenghuang_dazhao_buff_trigger3