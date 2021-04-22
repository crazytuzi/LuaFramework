
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
                    OPTIONS = {delay_frame = 37},
                },                                          
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "wyw_attack01_1", is_hit_effect = false},--攻击特效
                },
            },
        },

        {
            CLASS = "composite.QSBSequence",
            OPTIONS = {forward_mode = true},
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 40},
                },

                {
                    CLASS = "action.QSBArgsConditionSelector",
                    OPTIONS = 
                    {
                        failed_select = 2,
                        {expression = "target:has_buff:boss_wyw_tank_enhance", select = 1},

                    }
                },

                {
                    CLASS = "composite.QSBSelector",
                    ARGS = 
                    {
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS ={

                                                {
                                                    CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                                    OPTIONS = {coefficient = 0.003, set_black_board = {asd = "damage"}},
                                                },
 
                                                {
                                                    CLASS = "action.QSBExpression",
                                                    OPTIONS = {expStr = "isBlockDamageSign = {target:block_f > random}"},
                                                },
                                                {
                                                    CLASS = "action.QSBExpression",
                                                    OPTIONS = {expStr = "value = {0.15* (1 - 0.5 * isBlock)}, isBlockDamageSign = {isBlock}", get_black_board = {isBlock = "isBlockDamageSign"}}

                                                },
                                                {
                                                    CLASS = "action.QSBDecreaseHpWtihoutLog",
                                                    OPTIONS = {mode = "max_hp_percent", ignore_absorb = true,target = true, showDamage = true},
                                                },

                                				{
                                					CLASS = "action.QSBPlayEffect",
                                					OPTIONS = {is_hit_effect = true},
                                				},
                                                 {
                                                    CLASS = "action.QSBDecreaseAbsorbByProp",
                                                    OPTIONS = { current_absorb_percent = 1},
                                                },  
                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.6}
                                                },

                                    },

                            },


                            {
                                CLASS = "composite.QSBSequence",
                                ARGS ={

                                                {
                                                    CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                                    OPTIONS = {coefficient = 0.08, set_black_board = {asd = "damage"}},
                                                },
                                                {
                                                    CLASS = "action.QSBDecreaseAbsorbByProp",
                                                    OPTIONS = { current_absorb_percent = 1},
                                                }, 

 


                                                {
                                                    CLASS = "action.QSBPlayEffect",
                                                    OPTIONS = {is_hit_effect = true},
                                                },

                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 1}
                                                },
                                                    
                                    },

                            },

                    },
                },


            },
        },	
    },
}

return jinzhan_tongyong