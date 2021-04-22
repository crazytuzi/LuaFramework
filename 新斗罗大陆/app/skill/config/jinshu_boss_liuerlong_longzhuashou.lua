
local boss_liuerlong_longzhuashou = 
{
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="liuerlong_cheer"},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBPlayAnimation",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                -- {
                                --     CLASS = "action.QSBPlayEffect",
                                --     OPTIONS = {is_hit_effect = true},
                                -- },
                                {
                                    CLASS = "action.QSBHitTarget",
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    OPTIONS = {forward_mode = true},
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBArgsIsDirectionLeft",
                            OPTIONS = {is_attacker = true},
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = 
                            {   
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 8 / 24},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "boss_liuerlong_attack14_1_3" ,is_hit_effect = true},
                                        },
                                    },
                                },
                                {
                                    CLASS = "composite.QSBSequence",
                                    ARGS = 
                                    {
                                        {
                                            CLASS = "action.QSBDelayTime",
                                            OPTIONS = {delay_time = 8 / 24},
                                        },
                                        {
                                            CLASS = "action.QSBPlayEffect",
                                            OPTIONS = {effect_id = "boss_liuerlong_attack14_1_4" ,is_hit_effect = true},
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_time = 15 / 24},
                        },
                        {
                            CLASS = "action.QSBDragActor",
                            OPTIONS = {pos_type = "self" , pos = {x = 250,y = 0} , duration = 0.4, flip_with_actor = true },
                        },
                    },
                },
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return boss_liuerlong_longzhuashou

