local killing_spree = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        -- 人物消失
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack13"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBImmuneCharge",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBActorFadeOut",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
            },
        },
        {
            CLASS = "action.QSBApplyBuff",
            OPTIONS = {is_target = true, buff_id = "sanliantitui_debuff"},
        },
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 0.5},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 1},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 1},
        },
        {
            CLASS = "action.QSBHitTarget",
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBActorFadeIn",
                    OPTIONS = {duration = 0.15, revertable = true},
                },
                {
                    CLASS = "action.QSBImmuneCharge",
                    OPTIONS = {enter = false},
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {exit = true},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
    },
}

return killing_spree