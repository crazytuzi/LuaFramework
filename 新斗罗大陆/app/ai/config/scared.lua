
local scared = {
    CLASS = "composite.QAISelector",
    ARGS = 
    {
    	{
    		CLASS = "composite.QAISequence",
    		ARGS = 
    		{
		    	{
		    		CLASS = "action.QAIReturnToAI",
					OPTIONS = {hp_above_for_melee = 0.0, wait_time_for_melee = 0.0},
		    	},
		    	{
		    		CLASS = "action.QAIStopMoving",
		    	},
		    	{
		    		CLASS = "action.QAIResult",
					OPTIONS = {result = false},
		    	},
    		},
    	},
    	{
    		CLASS = "composite.QAISelector",
    		ARGS = 
    		{
    			{
    				CLASS = "composite.QAISequence",
    				ARGS = 
    				{
	    				{
	    					CLASS = "action.QAITimeSpan",
	    					OPTIONS = {from = 0, to = 2.5, relative = true},
	    				},
	    				{
	    					CLASS = "action.QAIMoveAwayFromTarget",
	    					OPTIONS = {distance = 10},
	    				},
	    				{
	    					CLASS = "action.QAISelector",
	    					ARGS = 
	    					{
						    	{
						    		CLASS = "composite.QAISequence",
									ARGS = 
									{
										{
											CLASS = "action.QAITimer",
											OPTIONS = {interval = 999999, first_interval = 0},
										},
								    	{
								    		CLASS = "action.QAIStopMoving",
								    	},
									},
						    	},
						    	{
						    		CLASS = "action.QAIResult",
						    		OPTIONS = {result = true},
						    	},
	    					},
	    				},
    				},
    			},
		    	{
		    		CLASS = "composite.QAISelector",
		    		OPTIONS = {alternatively = true},
		    		ARGS = 
		    		{
				    	{
					    	CLASS = "composite.QAISequence",
					    	ARGS = 
					    	{
				            	{
					            	CLASS = "action.QAITimeSpan",
					            	OPTIONS = {from = 0, to = {0.9, 1.1}, relative = true},
				            	},
				            	{
				            		CLASS = "action.QAIMoveLineStrip",
				      				OPTIONS = {target_list = {{x = -3, y = 0}}, relative = true},
				            	},
					    	},
				    	},
				    	{
					    	CLASS = "composite.QAISequence",
					    	ARGS = 
					    	{
				            	{
					            	CLASS = "action.QAITimeSpan",
					            	OPTIONS = {from = 0, to = {0.9, 1.1}, relative = true},
				            	},
				            	{
				            		CLASS = "action.QAIMoveLineStrip",
				      				OPTIONS = {target_list = {{x = 3, y = 0}}, relative = true},
				            	},
					    	},
				    	},
		    		},
		    	},
    		},
    	},
    },
}

return scared