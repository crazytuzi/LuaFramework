local xiaowu_shunjianshanyi ={
    CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "xiaowu_tongyongchongfeng_buff"},
        },
        {
            CLASS = "action.QSBMoveToTarget",
            OPTIONS = {is_position = true, effect_id = "xiaowu_shanxian_1", effect_interval = 50, scale_actor_face = 1},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "xiaowu_tongyongchongfeng_buff"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = { 
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12"},       
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                             CLASS = "action.QSBHitTarget",
                        },
                        {
                            CLASS = "action.QSBApplyBuff",
                            OPTIONS = {is_target = true, buff_id = "chongfeng_tongyong_xuanyun"},
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = false},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {exit = true},
        },
    },
}

return xiaowu_shunjianshanyi