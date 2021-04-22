
local rotation = 200

local killing_spree = {
    CLASS = "composite.QSBSequence",
    ARGS = 
    {
        -- 人物消失
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
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBShuttle",
                    OPTIONS = {rotation = -20, effect_id = "garrote_1", cancel_if_not_found = true, original_target = true, 
                            in_range = true, is_flip_x = true, revertable = true, front_to_back = true},
                },
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 3},
                        },
                        {
                            CLASS = "composite.QSBParallel",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {rotation = -200, effect_id = "garrote_3", is_hit_effect = true, is_current_target = true, front_layer = true, is_flip_x = true},
                                },
                                {
                                    CLASS = "action.QSBHitTarget",
                                    OPTIONS = {is_current_target = true},
                                },
                            },
                        },        
                    },
                },
            },
        },
        -- {
        --     CLASS = "action.QSBDelayTime",
        --     OPTIONS = {delay_frame = 1},
        -- },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBShuttle",
        --             OPTIONS = {rotation = rotation, effect_id = "triple_chop_1_1", cancel_if_not_found = true, original_target = true, 
        --                     in_range = true, is_flip_x = true, revertable = true, switch_direction = false},
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_frame = 3},
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {rotation = rotation, effect_id = "triple_chop_1_2", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
        --                         },
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {rotation = rotation, effect_id = "triple_chop_3", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
        --                         },
        --                         {
        --                             CLASS = "action.QSBHitTarget",
        --                             OPTIONS = {is_current_target = true},
        --                         },
        --                     },
        --                 },        
        --             },
        --         },
        --     },
        -- },
        -- {
        --     CLASS = "action.QSBDelayTime",
        --     OPTIONS = {delay_frame = 1},
        -- },
        -- {
        --     CLASS = "composite.QSBParallel",
        --     ARGS = 
        --     {
        --         {
        --             CLASS = "action.QSBShuttle",
        --             OPTIONS = {rotation = 0, effect_id = "triple_chop_1_1", cancel_if_not_found = true, original_target = true, 
        --                     in_range = true, is_flip_x = true, revertable = true, switch_direction = false, last_one = false},
        --         },
        --         {
        --             CLASS = "composite.QSBSequence",
        --             ARGS = 
        --             {
        --                 {
        --                     CLASS = "action.QSBDelayTime",
        --                     OPTIONS = {delay_frame = 3},
        --                 },
        --                 {
        --                     CLASS = "composite.QSBParallel",
        --                     ARGS = 
        --                     {
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {rotation = 0, effect_id = "triple_chop_1_2", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
        --                         },
        --                         {
        --                             CLASS = "action.QSBPlayEffect",
        --                             OPTIONS = {rotation = 0, effect_id = "triple_chop_3", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
        --                         },
        --                         {
        --                             CLASS = "action.QSBHitTarget",
        --                             OPTIONS = {is_current_target = true},
        --                         },
        --                     },
        --                 },        
        --             },
        --         },
        --     },
        -- },
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
            },
        },
        {
            CLASS = "action.QSBAttackFinish",
        },
    },
}

return killing_spree