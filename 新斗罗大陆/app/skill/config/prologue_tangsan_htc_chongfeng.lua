
local tangsan_htc_chongfeng = {
   CLASS = "composite.QSBSequence",
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
        }, 
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = true, buff_id = "xuzhang_chongfeng_xuanyun"},
        },      
        {
            CLASS = "action.QSBMoveToTarget",
            OPTIONS = {is_position = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "tongyongchongfeng_buff1"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                        },
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                    },
                },
                -- {
                --      CLASS = "composite.QSBSequence",
                --      ARGS = {
                --         {
                --             CLASS = "action.QSBPlaySound",
                --             OPTIONS = {is_loop = true},
                --         },
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_time = 2},
                --         }, 
                --         {
                --             CLASS = "action.QSBStopSound",
                --             OPTIONS = {sound_id ="chengniantangsan_dz1"},
                --         }, 
                --     },
                -- },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                        -- {
                        --     CLASS = "action.QSBPlayEffect",
                        --     OPTIONS = {is_hit_effect = false, effect_id = "charge_2"},
                        -- },
                        {
                             CLASS = "action.QSBHitTarget",
                        },
                        -- {
                        --     CLASS = "action.QSBApplyBuff",
                        --     OPTIONS = {is_target = true, buff_id = "chongfeng_tongyong_xuanyun"},
                        -- },
                    },
                },
                -- {
                --     CLASS = "composite.QSBParallel",
                --     ARGS = {
                --         {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {is_hit_effect = false, effect_id = "charge_2"},
                --         },
                --         {
                --              CLASS = "action.QSBHitTarget",
                --         }
                --     },
                -- },
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

return tangsan_htc_chongfeng