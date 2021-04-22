local tank_chongfeng = 
{
    CLASS = "composite.QSBParallel",
    -- OPTIONS = {forward_mode = true},
    ARGS = 
    {
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = false, buff_id = "mianyi_suoyou_zhuangtai"},
        },
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack21"},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "boss_niugao_attack21_1", is_hit_effect = false},
        },
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "boss_niugao_attack21_1_1", is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 70 },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },                        
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 6/24 },
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 12, duration = 0.35, count = 1,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 6/24 },
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 21/24 },
                },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 8, duration = 0.35, count = 1,},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 3/24 },
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "niugao_ruchang_dici", is_hit_effect = false},
                },
            },
        },
    },
}

return tank_chongfeng