
local ultra_deep_freeze_human = {
    CLASS = "composite.QSBParallel",
    ARGS = {
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                         {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack11"},
                        },
                        -- {
                        --     CLASS = "composite.QSBSequence",
                        --     ARGS = {
                        --         {
                        --             CLASS = "action.QSBDelayTime",
                        --             OPTIONS = {delay_time = 1.067},
                        --         },
                        --         {
                        --             CLASS = "action.QSBHitTarget",
                        --         },
                        --     },
                        -- },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish"
                },
            },
        },
        {
        	CLASS = "composite.QSBSequence",
        	ARGS = {
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
        		},
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = true, revertable = true},
                },
        		{
        			CLASS = "action.QSBDelayTime",
        			OPTIONS = {delay_time = 0.6},
        		},
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
        		{
        			CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
        		},
        	},
    	},
        {                       -- 竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.4, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.6},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.3},
                },
            },
        },
    	{
    		CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 2},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "deep_freeze_1_1"},
                }, 
        	},
    	},
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "deep_freeze_1_2"},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 14},
                },
                {
                    CLASS = "action.QSBLaser",          --特殊子弹，激光形式的子弹
                    OPTIONS = {effect_id = "deep_freeze_2_1", effect_width = 520},
                }, 
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 15},
                },
                {
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = true, effect_id = "deep_freeze_3_1"},
                }, 
            },
        },
    },
}

return ultra_deep_freeze_human
