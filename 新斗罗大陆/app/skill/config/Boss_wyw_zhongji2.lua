
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
                    OPTIONS = {delay_frame = 62},
                }, 
                {
                    CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 6, duration = 0.2, count = 2, level = 5},
                },

                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {effect_id = "wyw_attack13_3", is_hit_effect = true},
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
                                                    OPTIONS = {coefficient = 0.025, set_black_board = {asd = "damage"}},
                                                },
                                                {
                                                    CLASS = "action.QSBDecreaseAbsorbByProp",
                                                    OPTIONS = { current_absorb_percent = 1},
                                                }, 

                                                {
                                                    CLASS = "action.QSBHitTarget",
                                                    OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 0.8}
                                                },




                                        },

                                },

                              {

                                    CLASS = "composite.QSBSequence",
                                    ARGS ={

                                            {
                                                CLASS = "action.QSBArgsGetHeroDamagePerSecond",
                                                OPTIONS = {coefficient = 1, set_black_board = {asd = "damage"}},
                                            },
                                            {
                                                CLASS = "action.QSBDecreaseAbsorbByProp",
                                                OPTIONS = { current_absorb_percent = 1},
                                            }, 

                                            {
                                                CLASS = "action.QSBHitTarget",
                                                OPTIONS = {get_black_board = {damage_addition = "asd"},ignore_absorb_percent = 1}
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
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
				{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 55},
                },
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