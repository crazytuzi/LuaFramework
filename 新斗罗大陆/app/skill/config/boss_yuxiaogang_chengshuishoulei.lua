local shifa_tongyong = {
     CLASS = "composite.QSBSequence",
     ARGS = {
        {
            CLASS = "action.QSBPlaySound"
        },
        
        {
            CLASS = "composite.QSBParallel",
            ARGS = {

                
                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 5},
                            },
                            {
                                CLASS = "action.QSBPlayAnimation",
                            -- ARGS = 
                            -- {
                            --     {
                            --         CLASS = "action.QSBBullet",
                            --         OPTIONS = {flip_follow_y = true},
                            --     },
                            -- },
                            },
                        },
                },

                {
                    CLASS = "composite.QSBSequence",
                    ARGS = 
                         {
                            {
                                CLASS = "action.QSBDelayTime",
                                OPTIONS = {delay_frame = 26},
                            },
                            {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "boss_yuxiaogang_atk14_1"},
                            }, 
                        },
                },
                -- {
                --      CLASS = "composite.QSBSequence",
                --      ARGS = 
                --      {
                --         {
                --             CLASS = "action.QSBDelayTime",
                --             OPTIONS = {delay_frame = 27},
                --         },
                --         {
                            -- CLASS = "action.QSBBullet",
                            -- OPTIONS = {
                            --     start_pos = {x = 40,y = 60},effect_id = "yuxiaogang_atk14_2"
                            -- },
                --         },
                --     },
                -- },
                {
                     CLASS = "composite.QSBSequence",
                     ARGS = 
                     {
                        {
                            CLASS = "action.QSBDelayTime",
                            OPTIONS = {delay_frame = 30},
                        },
                     
                        {
                            CLASS = "action.QSBBullet",
                            OPTIONS = {is_throw = true, from_target = false,hit_duration = -2, 
                            speed_power = 1,--[[影响飞行速度变化]]throw_speed = 1225,--[[影响飞行总时间]] throw_angel = 85, --[[影响抛物线弧度]]
                            start_pos = {x = 30,y = 145},
                            at_position={x = 10, y = 10}},--[[影响抛物线落点偏移]]

                        },
                        
                    },
                },

                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --          {
                --             {
                --                 CLASS = "action.QSBDelayTime",
                --                 OPTIONS = {delay_frame = 47},
                --             },
                --             {
                --             CLASS = "action.QSBPlayEffect",
                --             OPTIONS = {is_hit_effect = true, effect_id = "yuxiaogang_atk14_4"},
                --             }, 
                --         },
                -- },

                -- {
                --     CLASS = "composite.QSBSequence",
                --     ARGS = 
                --          {
                --             {
                --                 CLASS = "action.QSBDelayTime",
                --                 OPTIONS = {delay_frame = 65},
                --             },
                --             {
                --                 CLASS = "action.QSBHitTarget",
                --             },
                --         },
                -- },
                
            },
        },
        {
            CLASS = "action.QSBAttackFinish"
        },
    },
}

return shifa_tongyong