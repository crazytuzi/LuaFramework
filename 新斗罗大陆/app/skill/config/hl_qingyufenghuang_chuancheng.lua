local hl_qingyufenghuang_chuancheng = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    { 
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack12"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_qingyufenghuang_attack12_1_1"},
                },   
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "hl_qingyufenghuang_attack12_1_2"},
                },             
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 72},
                },
                {
                    CLASS = "action.QSBBullet",
                    OPTIONS = {start_pos = {x = 130,y = 120},},
                },
            },
        },
    },
}

return hl_qingyufenghuang_chuancheng