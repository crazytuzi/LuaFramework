
local feiti1 = {
    CLASS = "composite.QSBSequence",
    OPTIONS = {forward_mode = true,},
    ARGS = {
        {
            CLASS = "action.QSBLockTarget",
            OPTIONS = {is_lock_target = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {buff_id = "feiti_jiasu"},
        }, 
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {effect_id = "kick_1_4", is_rotate_to_target = true},
        },
        {
            CLASS = "action.QSBManualMode",
            OPTIONS = {enter = true, revertable = true},
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = true, buff_id = "stun_charge"},
        }, 
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attacke15", is_loop = true},
        },       
        {
            CLASS = "action.QSBMoveToTarget",
            OPTIONS = {is_position = true},
        },
        {
            CLASS = "action.QSBRemoveBuff",
            OPTIONS = {buff_id = "feiti_jiasu"},
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
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",

                            OPTIONS = {is_hit_effect = true},
                        },
                        {
                             CLASS = "action.QSBHitTarget",
                        }
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            
                            OPTIONS = {is_hit_effect = false, effect_id = "charge_2"},
                        },
                        {
                             CLASS = "action.QSBHitTarget",
                        }
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

return feiti1