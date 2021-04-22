
local shadow_arrow_rain = {
    CLASS = "composite.QSBParallel",
    ARGS = {
    	--[[ 
    		assembly line 1: 
    		1. play prepare animation while wait 0.367 (11 frame) and play thunder effect
    		2. play skill animation
    		3. wait and play attack effect
    	--]]
        {
            CLASS = "composite.QSBSequence",
            ARGS = {
                {
                    CLASS = "composite.QSBParallel",
                    ARGS = {
                        {
                            CLASS = "action.QSBPlayAnimation",
                            OPTIONS = {animation = "attack12"},
                        },
                        {
                            CLASS = "composite.QSBSequence",
                            ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_frame = 34},
                                },
                                -- {
                                --     CLASS = "composite.QSBParallel",
                                --     ARGS = {
                                --         {
                                --             CLASS = "action.QSBPlayEffect",
                                --             OPTIONS = {is_hit_effect = false, effect_id = "blizzard_1"},
                                --         },
                                --         {
                                --             CLASS = "action.QSBPlayEffect",
                                --             OPTIONS = {is_hit_effect = false, effect_id = "blizzard_4"},
                                --         },
                                --     },
                                -- },
                            },
                        },
                    },
                },
                {
                    CLASS = "action.QSBAttackFinish",
                },
            },
        },
        --[[
        	assembly line 2:
        	1. fade in black area (8 frame) and display attacker
            2. wait 78 frame
        	2. fade out (12 frame)
        --]]
     --    {
     --    	CLASS = "composite.QSBSequence",
     --    	ARGS = {
     --    		{
     --    			CLASS = "action.QSBShowActor",
     --                OPTIONS = {is_attacker = true, turn_on = true, time = 0.3, revertable = true},
     --    		},
     --            {
     --                CLASS = "action.QSBBulletTime",
     --                OPTIONS = {turn_on = true, revertable = true},
     --            },
     --    		{
     --    			CLASS = "action.QSBDelayTime",
     --    			OPTIONS = {delay_time = 1.1},
     --    		},
     --            {
     --                CLASS = "action.QSBBulletTime",
     --                OPTIONS = {turn_on = false},
     --            },
     --    		{
     --    			CLASS = "action.QSBShowActor",
     --                OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
     --    		},
     --    	},
    	-- },
        --[[
            assembly line 3:
            1. wait 3.1 (93 frame)
            2. play hit effect for three times
        --]]
    	-- {
            -- CLASS = "composite.QSBParallel",
            -- ARGS = {
               
                -- {
                --     CLASS = "action.QSBDelayTime",
                --     OPTIONS = {delay_time = 1},
                -- },
    	{
			CLASS = "composite.QSBParallel",
			ARGS = {
       		 	{
		            CLASS = "action.QSBPlayWarningZone",
		            OPTIONS = {duration = 4, effect_id = "The_flame_tip_ring_2",is_hit_effect = false,is_range_effect = true},
		        },
		        {
		            CLASS = "composite.QSBParallel",
		            ARGS = {
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = {
                                {
                                    CLASS = "action.QSBDelayTime",
                                    OPTIONS = {delay_time = 2.63},
                                },
                                {
                                    CLASS = "action.QSBUncancellable",
                                },
		                        {
		                            CLASS = "action.QSBPlayEffect",
		                            OPTIONS = {is_hit_effect = true, effect_id = "shadow_arrow_rain_3",is_range_effect = true},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1},
		                        },
		                        {
		                            CLASS = "action.QSBPlayEffect",
		                            OPTIONS = {is_hit_effect = true, effect_id = "shadow_arrow_rain_3",is_range_effect = true},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1},
		                        },
		                        {
		                            CLASS = "action.QSBPlayEffect",
		                            OPTIONS = {is_hit_effect = true, effect_id = "shadow_arrow_rain_3",is_range_effect = true},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1},
		                        },
		                        {
		                            CLASS = "action.QSBPlayEffect",
		                            OPTIONS = {is_hit_effect = true, effect_id = "shadow_arrow_rain_3",is_range_effect = true},
		                        },
		                    },
		                },
		                {
		                    CLASS = "composite.QSBSequence",
		                    ARGS = {
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 3},
		                        },
		                        {
		                            CLASS = "action.QSBHitTarget",
		                            OPTIONS = {is_range_hit = true},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.1},
		                        },
		                        {
		                            CLASS = "action.QSBHitTarget",
		                            OPTIONS = {is_range_hit = true},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.1},
		                        },
		                        {
		                            CLASS = "action.QSBHitTarget",
		                            OPTIONS = {is_range_hit = true},
		                        },
		                        {
		                            CLASS = "action.QSBDelayTime",
		                            OPTIONS = {delay_time = 1.1},
		                        },
		                        {
		                            CLASS = "action.QSBHitTarget",
		                            OPTIONS = {is_range_hit = true},
		                        },
		                    },
	                    },
                    },
                },
            },
        },
    },
}

return shadow_arrow_rain