
local ultra_circle_of_healing = {		--治疗之环
	CLASS = "composite.QSBParallel",
	ARGS = {
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
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
                    CLASS = "action.QSBPlayEffect",
                    OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_3"},
             	},
            },
	    },           
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 0},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_2"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 0},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "take_pity_y"},
	            },
        	},
	    },
	    -- {
	    -- 	CLASS = "composite.QSBSequence",
	    --     ARGS = {
	    -- 		{
	    --             CLASS = "action.QSBDelayTime",
	    --             OPTIONS = {delay_frame = 0},
	    --         },
	    --         {
	    --             CLASS = "action.QSBPlayEffect",
	    --             OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_5"},
	    --         },
     --    	},
	    -- },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 0},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_1"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 18},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_1"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 36},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_1"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 54},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_1"},
	            },
        	},
	    },
	    -- {
	    -- 	CLASS = "composite.QSBSequence",
	    --     ARGS = {
	    -- 		{
	    --             CLASS = "action.QSBDelayTime",
	    --             OPTIONS = {delay_frame = 72},
	    --         },
	    --         {
	    --             CLASS = "action.QSBPlayEffect",
	    --             OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_1"},
	    --         },
     --    	},
	    -- },
	    -- {
	    -- 	CLASS = "composite.QSBSequence",
	    --     ARGS = {
	    -- 		{
	    --             CLASS = "action.QSBDelayTime",
	    --             OPTIONS = {delay_frame = 90},
	    --         },
	    --         {
	    --             CLASS = "action.QSBPlayEffect",
	    --             OPTIONS = {is_hit_effect = false, effect_id = "take_pity_1_1"},
	    --         },
     --    	},
	    -- },
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "take_pity_1_4", pos  = {x = 640 , y = 240}},
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
                    CLASS = "action.QSBPlaySceneEffect",
                    OPTIONS = {effect_id = "take_pity_1_4_2", pos  = {x = 640 , y = 390}},
                },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 16},
                },
	    		{
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 34},	
                },
	    		{
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 52},
                },
	    		{
                    CLASS = "action.QSBHitTarget",
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_frame = 70},
                },
	    		{
                    CLASS = "action.QSBHitTarget",
                },
       --          {
       --              CLASS = "action.QSBDelayTime",
       --              OPTIONS = {delay_frame = 18},
       --          },
	    		-- {
       --              CLASS = "action.QSBHitTarget",
       --          },
       --          {
       --              CLASS = "action.QSBDelayTime",
       --              OPTIONS = {delay_frame = 18},
       --          },
	    		-- {
       --              CLASS = "action.QSBHitTarget",
       --          },
	    	},
		},
		{
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 16},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "take_pity_3"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 34	},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "take_pity_3"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 52},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "take_pity_3"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_frame = 70},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = true, effect_id = "take_pity_3"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	    			CLASS = "action.QSBShowActor",
	                OPTIONS = {is_attacker = true, turn_on = true, time = 0.8, revertable = true},
	    		},
	    		{
        			CLASS = "action.QSBBulletTime",
        			OPTIONS = {turn_on = true, revertable = true},
        		},
	    		{
	    			CLASS = "action.QSBDelayTime",
	    			OPTIONS = {delay_time = 0.885},
	    		},
	    		{
        			CLASS = "action.QSBBulletTime",
        			OPTIONS = {turn_on = false},
        		},
	    		{
	    			CLASS = "action.QSBShowActor",
	                OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
	    		},
	    	},
		},
		{						-- 竞技场黑屏
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	    			CLASS = "action.QSBShowActorArena",
	                OPTIONS = {is_attacker = true, turn_on = true, time = 0.8, revertable = true},
	    		},
	    		{
        			CLASS = "action.QSBBulletTimeArena",
        			OPTIONS = {turn_on = true, revertable = true},
        		},
	    		{
	    			CLASS = "action.QSBDelayTime",
	    			OPTIONS = {delay_time = 0.885},
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
	},
} 

return ultra_circle_of_healing