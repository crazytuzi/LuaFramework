
local ultra_shoot = {
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
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayByAttack",
                },
                {
                    CLASS = "action.QSBBullet",
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
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayByAttack",
                        },
                        {
                            CLASS = "action.QSBActorScale",
                            OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0.1},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 20},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBActorScale",
                    OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0.1},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.4},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false},
                },
            },
        },
    },
}

return ultra_shoot