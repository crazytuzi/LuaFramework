--成年小舞 大招
--创建人：庞圣峰
--创建时间：2018-3-13


local xiaowu_rgt_dazhao = {
     CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayAnimation",
            OPTIONS = {animation = "attack11_1", revertable = true, reload_on_cancel = true, no_stand = true},
        },
        {
            CLASS = "action.QSBPlaySound",
            OPTIONS = {sound_id ="chengnianxiaowu_skill"},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 24 / 24 * 30},
                },
                {
                    CLASS = "action.QSBImmuneCharge",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 6 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 12 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 18 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 24 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 30 / 24 * 30},
                                },
                                {
                                    CLASS = "action.QSBKillingSpree",
                                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true, in_range = true, original_target = true}
                                },
                                {
                                    CLASS = "action.QSBPlaySound",
                                },
                            },
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 30 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 36 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 42 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 48 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 54 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 60 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 66 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 72 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                        --         },
                        --     },
                        -- },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = 
                        --     {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_frame = 78 / 24 * 30},
                        --         },
                        --         {
                        --             CLASS = "action.QSBKillingSpree",
                        --             OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true, in_range = true, original_target = true}
                        --         },
                        --     },
                        -- },
                    },
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBActorStand",
                            OPTIONS = {reload = true,}
                        },
                        {
                            CLASS = "action.QSBImmuneCharge",
                            OPTIONS = {enter = false},
                        },
                        {
                            CLASS = "action.QSBActorFadeIn",
                            OPTIONS = {duration = 0.25, revertable = true},
                        },
                    },
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
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.4},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
            },
        },
        {                   -- 竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.4},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
            },
        },
    },
}

return xiaowu_rgt_dazhao
