
local jinzhan_tongyong = {
     CLASS = "composite.QSBParallel",
     ARGS = {
        -- {
        --     CLASS = "action.QSBPlaySound"
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
					CLASS = "action.QSBPlayAnimation",
				},
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 5},
                }, 
				{
					CLASS = "action.QSBAttackFinish"
				},
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {          
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 62},
                }, 
                -- {
                --     CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                --     OPTIONS = {coefficient = 0.05, set_black_board = {asd = "damage"}},
                -- },
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 6, duration = 0.2, count = 2, level = 5},
                }, 

                        --R点选取突刺方案
                        {
                        CLASS = "action.QSBArgsConditionSelector",
                        OPTIONS = {
                            failed_select = 3,
                            {expression = "self:random*100<40", select = 1},
                            {expression = "self:random*100>80", select = 2},
                            -- {expression = "self:random*100<100", select = 3},
                            }
                        },
                        {
                            CLASS = "composite.QSBSelector",
                            ARGS = {

                                     {--1
                                        CLASS ="composite.QSBParallel",
                                        ARGS = 
                                        {
                                            {
                                                CLASS = "action.QSBPlayEffect",
                                                OPTIONS = {effect_id = "wyw_attack13_3", is_hit_effect = true},
                                            },
                                             {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "wyw_zhongji_xj1",
                                                        args = 
                                                        {
                                                            {delay_time = 0.1 , relative_pos = { x = -900, y = 200}} ,
                                                            {delay_time = 0.1 , relative_pos = { x = -400, y = 190}} ,

                                                        },
                                                    },
                                                }, 
                                                {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "wyw_zhongji_xj2",
                                                        args = 
                                                        {
                                                            {delay_time = 0.1 , relative_pos = { x = -1000, y = -30}} ,
                                                            {delay_time = 0.1 , relative_pos = { x = -500, y = -90}} ,

                                                        },
                                                    },
                                                },
                                                 {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "wyw_zhongji_xj3",
                                                        args = 
                                                        {
                                                            {delay_time = 0.1 , relative_pos = { x = -690, y = 70}} ,
                                                            -- {delay_time = 0 , relative_pos = { x = -530, y = 170}} ,

                                                        },
                                                    },
                                                },
                                                {

                                                    CLASS = "composite.QSBSequence",
                                                    ARGS ={
                                                            {
                                                                CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                                                OPTIONS = {coefficient = 0.025, set_black_board = {asd = "damage"}},
                                                            },

                                                            {
                                                                CLASS = "action.QSBHitTarget",
                                                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.8}
                                                            },
                                                             {
                                                                CLASS = "action.QSBDecreaseAbsorbByProp",
                                                                OPTIONS = { current_absorb_percent = 1},
                                                            }, 



                                                    },

                                                },
                     
                                                -- {
                                                --     CLASS = "action.QSBHitTarget",
                                                --     OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.7}
                                                -- },

                                        },
                                    },--1
                                    
                                    {--2
                                            CLASS ="composite.QSBParallel",
                                            ARGS = 
                                            {
                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {effect_id = "wyw_attack13_3", is_hit_effect = true},
                                                },
                                                 {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "wyw_zhongji_xj1",
                                                        args = 
                                                        {
                                                            {delay_time = 0.1 , relative_pos = { x = -730, y =120}} ,
                                                            {delay_time = 0.1 , relative_pos = { x = -920, y = -90}} ,

                                                        },
                                                    },
                                                }, 
                                                {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "wyw_zhongji_xj2",
                                                        args = 
                                                        {
                                                            {delay_time = 0.1 , relative_pos = { x = -500, y = 220}} ,
                                                            {delay_time = 0.1 , relative_pos = { x = -370, y = 140}} ,

                                                        },
                                                    },
                                                },
                                                 {
                                                    CLASS = "action.QSBTrap", 
                                                    OPTIONS = 
                                                    { 
                                                        trapId = "wyw_zhongji_xj3",
                                                        args = 
                                                        {
                                                            {delay_time = 0.1 , relative_pos = { x = -1000, y = 190}} ,
                                                            {delay_time = 0.1 , relative_pos = { x = -610, y = -20}} ,

                                                        },
                                                    },
                                                },
                        
                                                 {

                                                    CLASS = "composite.QSBSequence",
                                                    ARGS ={

                                                            {
                                                                CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                                                OPTIONS = {coefficient = 0.025, set_black_board = {asd = "damage"}},
                                                            },

                                                            {
                                                                CLASS = "action.QSBHitTarget",
                                                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.8}
                                                            },
                                                             {
                                                                CLASS = "action.QSBDecreaseAbsorbByProp",
                                                                OPTIONS = { current_absorb_percent = 1},
                                                            }, 



                                                    },

                                                },

                                            },
                                        },--2
                                        {--3
                                                CLASS ="composite.QSBParallel",
                                                ARGS = 
                                                {
                                                    {
                                                        CLASS = "action.QSBPlayEffect",
                                                        OPTIONS = {effect_id = "wyw_attack13_3", is_hit_effect = true},
                                                    },
                        
                                                 {

                                                    CLASS = "composite.QSBSequence",
                                                    ARGS ={
                                                            {
                                                                CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                                                OPTIONS = {coefficient = 0.025, set_black_board = {asd = "damage"}},
                                                            },

                                                            {
                                                                CLASS = "action.QSBHitTarget",
                                                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.8}
                                                            },
                                                             {
                                                                CLASS = "action.QSBDecreaseAbsorbByProp",
                                                                OPTIONS = { current_absorb_percent = 1},
                                                            }, 



                                                    },

                                                },

                                                },
                                            },--3

                            },
                        },
                                                       

            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
                -- {
                --     CLASS = "action.QSBShakeScreen",
                --     OPTIONS = {amplitude = 6, duration = 0.2, count = 2},
                -- }, 
				{
					CLASS = "composite.QSBParallel",
					ARGS = { 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "wyw_attack13_1", is_hit_effect = false},
                                }, 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {effect_id = "wyw_attack13_2", is_hit_effect = false},
                                }, 

					},
				},
            },
        },	
    },
}

return jinzhan_tongyong