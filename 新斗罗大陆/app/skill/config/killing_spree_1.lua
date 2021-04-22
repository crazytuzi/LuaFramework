local killing_spree = {
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
           	CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {buff_id = "heti_killing_spree_debuff"},
                                },
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack11", revertable = true, reload_on_cancel = true, no_stand = true},
                                },
                                -- {
                                --     CLASS = "action.QSBDelayTime",
                                --     OPTIONS = {delay_time = 0.40},
                                -- },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.4},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "haunt_3"},
                                },
                                {
                                    CLASS = "action.QSBImmuneCharge",
                                    OPTIONS = {enter = true, revertable = true},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.4},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "stress_roar_1_ground"},
                                }
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBManualMode",
                    OPTIONS = {enter = true, revertable = true},
                },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false}
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true}
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true}
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true}
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true}
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true}
                },
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_frame = 1},
                -- },
                {
                    CLASS = "action.QSBKillingSpree",
                    OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 20}, always = true, in_range = true, original_target = true}
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
                    CLASS = "action.QSBRemoveBuff",
                    OPTIONS = {buff_id = "heti_killing_spree_debuff"},
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 27},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "killing_spree_y"},
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
        {                   --竞技场黑屏
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

return killing_spree