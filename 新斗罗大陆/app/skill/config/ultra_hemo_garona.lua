local ultra_hemo_garona = {
    CLASS = "composite.QSBParallel",
    ARGS = { 
        {       --攻击动作以及技能效果的时间点
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayAnimation",
                                    OPTIONS = {animation = "attack13"},
                                },
                                {
                                    CLASS = "action.QSBReloadAnimation",
                                },
                                
                                {
                                    CLASS = "action.QSBAttackFinish",
                                },
                            },
                        },

                    },
                },
                
            },
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = {
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "wll_yingxi_1"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 34},
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 28},
        --         },
        --         {
        --             CLASS = "action.QSBShuttle",
        --             OPTIONS = {rotation = 0, effect_id = nil, cancel_if_not_found = false, original_target = true, 
        --                     in_range = true, is_flip_x = true, revertable = true, switch_direction = false, shuttle_shade_count = 0, shuttle_shade_interval_frame = 0},
        --         },

        --     },
        -- },

        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 34},
        --         },
        --         {
        --             CLASS = "composite.QSBParallel",
        --             ARGS = 
        --             {
        --                 -- {
        --                 --     CLASS = "action.QSBActorStand",
        --                 --     OPTIONS = {reload = true,}
        --                 -- },
        --                 -- {
        --                 --     CLASS = "action.QSBImmuneCharge",
        --                 --     OPTIONS = {enter = false},
        --                 -- },
        --                 -- {
        --                 --     CLASS = "action.QSBActorFadeIn",
        --                 --     OPTIONS = {duration = 0.25, revertable = true},
        --                 -- },
        --                 {
        --                     CLASS = "action.QSBAttackFinish",
        --                 },
        --             },
        --         },
        --     },
        -- },
    },
}

return ultra_hemo_garona