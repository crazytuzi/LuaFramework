
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
	                OPTIONS = {delay_time = 0.75},
	            },
	            {
		            CLASS = "composite.QUIDBParallel",
					ARGS = 	
					{
						{
							CLASS = "action.QUIDBPlayLoopEffect",
	                		OPTIONS = {effect_id = "storm_bolt_1_1",duration = 0.95},
						},
						{
							CLASS = "action.QUIDBPlayLoopEffect",
	                		OPTIONS = {effect_id = "storm_bolt_1_3",duration = 0.95},
						},
			            {
			                CLASS = "action.QUIDBPlayEffect",
			                OPTIONS = {effect_id = "storm_bolt_1_2"},
			            },
		            },
	            },
        	},
	    },
	},
} 

return ui_ultra_pyroblast