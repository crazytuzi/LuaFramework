-- 张南：这是三连击的特效的配置
        -- "triple_chop_3": {
        --     "id": "triple_chop_3",
        --     "cehua": "三连击-溅血",
        --     "file": "triple_chop_3",
        --     "scale": 1.0,
        --     "play_speed": 1,
        --     "offset_x": 0,
        --     "offset_y": 0,
        --     "rotation": 0
        -- },
        -- "triple_chop_1_1": {
        --     "id": "triple_chop_1_1",
        --     "cehua": "三连击-残影",
        --     "file": "triple_chop_1_1",
        --     "scale": 1.0,
        --     "play_speed": 1,
        --     "offset_x": 0,
        --     "offset_y": 0,
        --     "rotation": 0,
        --     "dummy": "dummy_bottom"
        -- },
        -- "triple_chop_1_2": {
        --     "id": "triple_chop_1_2",
        --     "cehua": "三连击-刀光",
        --     "file": "triple_chop_1_2",
        --     "scale": 1.0,
        --     "play_speed": 1,
        --     "offset_x": 0,
        --     "offset_y": 0,
        --     "rotation": 0
        -- }

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
                    OPTIONS = {rotation = 0, effect_id = "triple_chop_1_1", cancel_if_not_found = true, original_target = true, in_range = true, is_flip_x = true, revertable = true},
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
                                    OPTIONS = {rotation = 0, effect_id = "triple_chop_1_2", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {rotation = 0, effect_id = "triple_chop_3", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
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
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 1},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBShuttle",
                    OPTIONS = {rotation = 30, effect_id = "triple_chop_1_1", cancel_if_not_found = true, original_target = true, in_range = true, is_flip_x = true, revertable = true},
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
                                    OPTIONS = {rotation = 30, effect_id = "triple_chop_1_2", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {rotation = 30, effect_id = "triple_chop_3", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
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
        {
            CLASS = "action.QSBDelayTime",
            OPTIONS = {delay_frame = 1},
        },
        {
            CLASS = "composite.QSBParallel",
            ARGS = 
            {
                {
                    CLASS = "action.QSBShuttle",
                    OPTIONS = {rotation = -30, effect_id = "triple_chop_1_1", cancel_if_not_found = true, original_target = true, in_range = true, is_flip_x = true, revertable = true},
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
                                    OPTIONS = {rotation = -30, effect_id = "triple_chop_1_2", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
                                },
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {rotation = -30, effect_id = "triple_chop_3", is_hit_effect = true, is_current_target = true, front_layer = true, scale_actor_face = -1},
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