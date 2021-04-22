local xiaowu_sanliantitui =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 0},
                -- },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "xiaowu_attack13_1_1", is_hit_effect = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 19},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "xiaowu_attack13_3", is_hit_effect = true},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 0},
                -- },
                {
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack13"},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 8},
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
                -- {
                --     CLASS = "action.QSBApplyBuff",
                --     OPTIONS = {is_target = true, buff_id = "sanliantitui_debuff"},
                -- },
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
                        -- {
                        --     CLASS = "action.QSBPlayAnimation",
                        --     OPTIONS = {animation = "attack13_3"},
                        -- },
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
        },       
    },
}

return xiaowu_sanliantitui