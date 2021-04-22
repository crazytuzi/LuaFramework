
local ui_ultra_pyroblast = {
	CLASS = "composite.QUIDBParallel",
	ARGS = {
		{
	        CLASS = "composite.QUIDBSequence",
	        ARGS = {
	            {
	                CLASS = "action.QUIDBPlayAnimation",
	                OPTIONS = {animation = "attack11"},
	            },
	        },
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_time = 1.067},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pyroblast_1"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_time = 1.13},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pyroblast_3_1"},
	            },
        	},
	    },
	    {
	    	CLASS = "composite.QUIDBSequence",
	        ARGS = {
	    		{
	                CLASS = "action.QUIDBDelayTime",
	                OPTIONS = {delay_time = 1.1},
	            },
	            {
	                CLASS = "action.QUIDBPlayEffect",
	                OPTIONS = {is_hit_effect = false, effect_id = "pyroblast_2_1"},
	            },
        	},
	    },
		-- {
	 --    	CLASS = "composite.QSBSequence",
	 --    	ARGS = {
	 --    		{
	 --                CLASS = "action.QSBDelayTime",
	 --                OPTIONS = {delay_time = 1.067},
	 --            },
	 --            {
	 --                CLASS = "action.QSBBullet",
	 --        		OPTIONS = {effect_id = "pyroblast_2", speed = 2360, hit_effect_id = "pyroblast_3"},
	 --            },
	 --    	},
		-- },
	 --    {
	 --    	CLASS = "composite.QSBSequence",
	 --    	ARGS = {
	 --    		{
	 --    			CLASS = "action.QSBShowActor",
	 --                OPTIONS = {is_attacker = true, turn_on = true, time = 0.3},
	 --    		},
	 --    		{
  --       			CLASS = "action.QSBBulletTime",
  --       			OPTIONS = {turn_on = true},
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
	 --                OPTIONS = {is_attacker = true, turn_on = false, time = 0.2},
	 --    		},
	 --    	},
		-- },
	},
} 

return ui_ultra_pyroblast