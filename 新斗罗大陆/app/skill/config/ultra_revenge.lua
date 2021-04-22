
local ultra_revenge = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBApplyBuff",
                    OPTIONS = {buff_id = "revenge_buff"},
                },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "revenge_buff"},
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShowActor",
                                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.55, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBBulletTime",
                                    OPTIONS = {turn_on = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.56},
                                },
                                {
                                    CLASS = "action.QSBBulletTime",
                                    OPTIONS = {turn_on = false},
                                },
                                {
                                    CLASS = "action.QSBShowActor",
                                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                                },
                                
                            },
                        },
                        {                       --竞技场黑屏
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBShowActorArena",
                                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.55, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBBulletTimeArena",
                                    OPTIONS = {turn_on = true, revertable = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.56},
                                },
                                {
                                    CLASS = "action.QSBBulletTimeArena",
                                    OPTIONS = {turn_on = false},
                                },
                                {
                                    CLASS = "action.QSBShowActorArena",
                                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                                },
                                
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {is_range_hit = true},
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },                    
    },
}

return ultra_revenge