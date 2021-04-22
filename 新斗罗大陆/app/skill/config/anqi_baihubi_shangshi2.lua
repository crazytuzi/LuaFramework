
	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBSequence",
	    OPTIONS = {forward_mode = true},
	    ARGS = {
	        {
	            CLASS = "action.QSBArgsConditionSelector",
	            OPTIONS = {
	                failed_select = -1,
              		{expression = "self:is_ranged=false", select = 1},
	                {expression = "self:is_ranged=true", select = 2},
	            }	
	        },
	        {
	            CLASS = "composite.QSBSelector",
	            ARGS = {
					{
                        CLASS = "action.QSBChangeRecoverHpLimit",
                        OPTIONS = {percent = 0.20,is_inherit_damage_percent = true},
                    }, 
					{
                        CLASS = "action.QSBChangeRecoverHpLimit",
                        OPTIONS = {percent = 0.10,is_inherit_damage_percent = true},
                    }, 
	            },
	        },
            -- {
            --     CLASS = "action.QSBHitTarget",
            -- },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xiehuoshuanglian_trigger_1