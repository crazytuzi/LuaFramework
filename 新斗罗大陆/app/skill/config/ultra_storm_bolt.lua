
local ultra_pyroblast = {
	CLASS = "composite.QSBParallel",
	ARGS = {
        {
            CLASS = "action.QSBSelectTarget",
            OPTIONS = {cancel_if_not_found = true, range = {min = 0, max = 21}, always = false},
        },
		{
	        CLASS = "composite.QSBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QSBPlayAnimation",
	                OPTIONS = {animation = "attack11", reload_on_cancel = true},
	            },
	            {
                    CLASS = "action.QSBAttackFinish",
                },
	        },
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.17},
	            },
	            {
		            CLASS = "composite.QSBParallel",
					ARGS = 	
					{
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
			                		CLASS = "action.QSBPlayLoopEffect",
			                		OPTIONS = {effect_id = "storm_bolt_1_1"},
			            		},
			            		{
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 0.56},
					            },
			            		{
			               			 CLASS = "action.QSBStopLoopEffect",
			                		OPTIONS = {effect_id = "storm_bolt_1_1"},
			            		},
							},
						},
						{
							CLASS = "composite.QSBSequence",
							ARGS = 
							{
								{
			                		CLASS = "action.QSBPlayLoopEffect",
			                		OPTIONS = {effect_id = "storm_bolt_1_3"},
			            		},
			            		{
					                CLASS = "action.QSBDelayTime",
					                OPTIONS = {delay_time = 0.56},
					            },
			            		{
			               			 CLASS = "action.QSBStopLoopEffect",
			                		OPTIONS = {effect_id = "storm_bolt_1_3"},
			            		},
							},
						},
			            {
			                CLASS = "action.QSBPlayEffect",
			                OPTIONS = {is_hit_effect = false, effect_id = "storm_bolt_1_2"},
			            },
		            },
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
                            OPTIONS = {is_attacker = true, scale_to = 1.4, duration = 0.3},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 1.4},
                },
                {
                    CLASS = "action.QSBActorScale",
                    OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0.3},
                },
                {
                    CLASS = "action.QSBBulletTime",
                    OPTIONS = {turn_on = false},
                },
                {
                    CLASS = "action.QSBShowActor",
                    OPTIONS = {is_attacker = true, turn_on = false},
                },
            },
        },
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.83},
	            },
	            {
	                CLASS = "action.QSBBullet",
	        		OPTIONS = {effect_id = "storm_bolt_2", speed = 2000, hit_effect_id = "storm_bolt_3"},
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
	    			OPTIONS = {delay_time = 1.75},
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
		{					-- 竞技场黑屏
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
	    			OPTIONS = {delay_time = 1.75},
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

return ultra_pyroblast