
local ultra_devouring_plague = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                -- {
                --     CLASS = "action.QSBDelayByAttack",
                --     OPTIONS = {animation = "attack13"},
                -- },
				{
                    CLASS = "action.QSBPlayAnimation",
                    OPTIONS = {animation = "attack11"},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBAttackFinish"
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true},
                        },
                    },
                },
            },
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
        		},
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
        		{
        			CLASS = "action.QSBDelayTime",
        			OPTIONS = {delay_time = 0.5},
        		},
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.167},
        		},
        	},
    	},
        {                   -- 竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.5},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.167},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 17},
                }, 
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_3"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = true, effect_id = "devouring_plague_3"},
                        }, 
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 0.033},
                                }, 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1"},
                                },
                                {
                                    CLASS = "action.QSBApplyBuff",
                                    OPTIONS = {is_hit_effect = false, buff_id = "devouring_plague_4;y"},
                                }, 
                            },
                        } ,
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 5},
                                }, 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_2"},
                                },
                            },
                        } ,
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 1},
                                }, 
                                {
                                    CLASS = "action.QSBPlayEffect",
                                    OPTIONS = {is_hit_effect = false, effect_id = "devouring_plague_1_4"},
                                },
                            },
                        } ,
                    },
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },     
    },
}

return ultra_devouring_plague