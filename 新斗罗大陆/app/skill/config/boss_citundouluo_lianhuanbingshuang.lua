local boss_citundouluo_lianhuanbingshuang = 
{
    CLASS = "composite.QSBParallel",
    ARGS = 
    {
        {
            CLASS = "action.QSBPlayEffect",
            OPTIONS = {is_hit_effect = false},
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = 
            {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = 
                    {
                        {
                            CLASS = "action.QSBPlaySound",
                        },
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12"},
                        },
                        {
							CLASS = "action.QSBApplyBuff",
							OPTIONS = {buff_id = "haima_bingshuanghongkuang_buff", is_target = false},
						},
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = 
                            {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 3},
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
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 65 / 24 },
                                },
                                {   
                                    CLASS = "action.QSBArgsPosition",
                                    OPTIONS = {is_attacker = true},
                                },
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1, pass_key = {"pos"}},
                                },
                                {
                                    CLASS = "action.QSBMultipleTrap", --连续放置多个陷阱
                                    OPTIONS = {interval_time = 1.5, attacker_face = false,attacker_underfoot = true,count = 6, distance = 150, trapId = "citun_lianxubingshuang"},
                                },
                            },
                        },
                    },
                },
            },
        },
    },
}

return boss_citundouluo_lianhuanbingshuang