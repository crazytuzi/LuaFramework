local ssmahongjun_dazhao =
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBAttackFinish",
        },
        {
            CLASS = "composite.QSBSequence",                            
            ARGS = 
            {
                {
                    CLASS = "action.QSBArgsPosition",
                    OPTIONS = {is_attacker = true},
                },
                {
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "ssptangchen_zj1", front_layer = false},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.5},
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
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "ssptangchen_zj2_1", front_layer = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",                            
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "ssptangchen_zj2_2", front_layer = false},
                                },
                            },
                        }, 
                        {
                            CLASS = "composite.QSBSequence",                            
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "ssptangchen_zj2_3", front_layer = false},
                                },
                            },
                        }, 
                        {
                            CLASS = "composite.QSBSequence",                            
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "ssptangchen_zj2_4", front_layer = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",                            
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "ssptangchen_zj2_5", front_layer = false},
                                },
                            },
                        },
                        {
                            CLASS = "composite.QSBSequence",                            
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBPlaySceneEffect",
                                    OPTIONS = {effect_id = "ssptangchen_zj2_6", front_layer = false},
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
                    OPTIONS = {delay_time = 1.75},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1,check_target_by_skill = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1,check_target_by_skill = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1,check_target_by_skill = true},
                },
                {
                    CLASS = "action.QSBHitTarget",
                    OPTIONS = {damage_scale = 1,check_target_by_skill = true},
                },
                -- {
                --     CLASS = "action.QSBBullet",
                --     OPTIONS = 
                --     {
                --         start_pos = {x = 0,y = 0},
                --         effect_id = "tmzd_2", 
                --         speed = 3000, 
                --         random_enemy_in_skill_range = false,                                
                --     },
                -- },
                -- {
                --     CLASS = "action.QSBBullet",
                --     OPTIONS = 
                --     {
                --         start_pos = {x = 0,y = 0},
                --         effect_id = "tmzd_2", 
                --         speed = 3000, 
                --         random_enemy_in_skill_range = false,                                
                --     },
                -- },                        
                -- {
                --     CLASS = "action.QSBBullet",
                --     OPTIONS = 
                --     {
                --         start_pos = {x = 0,y = 0},
                --         effect_id = "tmzd_2", 
                --         speed = 3000, 
                --         random_enemy_in_skill_range = false,                                
                --     },
                -- },
                -- {
                --     CLASS = "action.QSBBullet",
                --     OPTIONS = 
                --     {
                --         start_pos = {x = 0,y = 0},
                --         effect_id = "tmzd_2", 
                --         speed = 3000, 
                --         random_enemy_in_skill_range = false,                                
                --     },
                -- },
            },
        },                         
    },
}

return ssmahongjun_dazhao