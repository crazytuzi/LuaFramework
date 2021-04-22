
local ultra_taunt = {
    CLASS = "composite.QSBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation
    		2. play skill animation
    		3. hit target, play hit effect and finish attack
    	--]]
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 8},
                },
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
                    },
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.25},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 15, duration = 0.2, count = 1,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.17},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 12, duration = 0.15, count = 1,},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.12},
                },
                {
                 CLASS = "action.QSBShakeScreen",
                    OPTIONS = {amplitude = 8, duration = 0.1, count = 1,},
                },
            },
        },
        --[[
        	assembly line 2:
        	1. fade in black area and display attacker
        	2. fade out 
        --]]
     --    {
     --    	CLASS = "composite.QSBSequence",
     --    	ARGS = {
     --    		{
     --    			CLASS = "action.QSBShowActor",
     --                OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
     --    		},
     --            {
     --                CLASS = "action.QSBBulletTime",
     --                OPTIONS = {turn_on = true},
     --            },
     --    		{
     --    			CLASS = "action.QSBDelayTime",
     --    			OPTIONS = {delay_time = 0.9},
     --    		},
     --            {
     --                CLASS = "action.QSBBulletTime",
     --                OPTIONS = {turn_on = false, revertable = true},
     --            },
     --    		{
     --    			CLASS = "action.QSBShowActor",
     --                OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
     --    		},
     --    	},
    	-- },
        {                   -- 竞技场黑屏
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = true, revertable = true},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.9},
                },
                {
                    CLASS = "action.QSBBulletTimeArena",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActorArena",
                    OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
                },
            },
        },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBShowActor",
                            OPTIONS = {is_attacker = true, turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBBulletTime",
                            OPTIONS = {turn_on = true, revertable = true},
                        },
                        {
                            CLASS = "action.QSBDelayByAttack",
                        },
                        {
                            CLASS = "action.QSBActorScale",
                            OPTIONS = {is_attacker = true, scale_to = 1.4, duration = 0},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.79},
                },
                
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false},
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.37},
                },
                {
                    CLASS = "action.QSBActorScale",
                    OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0},
                },
            },
        },
        --[[
            assembly line 3:
            1. wait 0.1 (3 frame)
            2. play thunder effect
            3. wait 0.467 (14 frame)
            4. play attack effect
        --]]
    	{
    		CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 26},
                },
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "taunt_2"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "taunt_3"},
                        },
                        {
                            CLASS = "action.QSBPlayEffect",
                            OPTIONS = {is_hit_effect = false, effect_id = "taunt_1"},
                        },
                    },
                },
        	},
    	},
        -- {
        --     CLASS = "composite.QSBSequence",
        --     ARGS = {
        --         {
        --             CLASS = "action.QSBDelayTime",
        --             OPTIONS = {delay_frame = 0},
        --         },
        --         {
        --             CLASS = "action.QSBPlayEffect",
        --             OPTIONS = {is_hit_effect = false, effect_id = "taunt_y"},
        --         },
        --     },
        -- },
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 35}
                },
                {
                    CLASS = "action.QSBHitTarget",
                },
            },
        },
    },
}

return ultra_taunt