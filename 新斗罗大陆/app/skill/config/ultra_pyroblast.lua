
local ultra_pyroblast = {
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
                    CLASS = "action.QSBAttackFinish"
                },
	        },
	    },
	    {
	    	CLASS = "composite.QSBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.067},
	            },
	            {
	                CLASS = "action.QSBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pyroblast_1"},
	            },
        	},
	    },
		{
	    	CLASS = "composite.QSBSequence",
	    	ARGS = {
	    		{
	                CLASS = "action.QSBDelayTime",
	                OPTIONS = {delay_time = 1.067},
	            },
	            {
	                CLASS = "action.QSBBullet",
	        		OPTIONS = {effect_id = "pyroblast_2", speed = 2360, hit_effect_id = "pyroblast_3", shake = {amplitude = 12, duration = 0.3, count = 1}},
	            },
	    	},
		},
	 --    {
	 --    	CLASS = "composite.QSBSequence",
	 --    	ARGS = {
	 --    		{
	 --    			CLASS = "action.QSBShowActor",
	 --                OPTIONS = {is_attacker = true, turn_on = true, time = 0.1, revertable = true},
	 --    		},
	 --    		{
  --       			CLASS = "action.QSBBulletTime",
  --       			OPTIONS = {turn_on = true, revertable = true},
  --       		},
	 --    		{
	 --    			CLASS = "action.QSBDelayTime",
	 --    			OPTIONS = {delay_time = 0.8},
	 --    		},
	 --    		{
  --       			CLASS = "action.QSBBulletTime",
  --       			OPTIONS = {turn_on = false},
  --       		},
	 --    		{
	 --    			CLASS = "action.QSBShowActor",
	 --                OPTIONS = {is_attacker = true, turn_on = false, time = 0.1},
	 --    		},
	 --    	},
		-- },
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
                        -- {
                        --     CLASS = "action.QSBDelayByAttack",
                        -- },
                        {
                            CLASS = "action.QSBActorScale",
                            OPTIONS = {is_attacker = true, scale_to = 1.4, duration = 0},
                        },
                    },
                },
                {
                    CLASS = "action.QSBDelayTime",
                    OPTIONS = {delay_time = 0.91},
                },
                {
                    CLASS = "action.QSBActorScale",
                    OPTIONS = {is_attacker = true, scale_to = 1.0, duration = 0},
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
	},
} 

return ultra_pyroblast