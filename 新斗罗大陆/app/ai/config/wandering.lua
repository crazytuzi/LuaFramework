
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
    		CLASS = "action.QAIWandering",
    		OPTIONS = {animations = {"stand"}} -- sample: animations = {"attack01", "victory"}
    	},
    },
}

return scared