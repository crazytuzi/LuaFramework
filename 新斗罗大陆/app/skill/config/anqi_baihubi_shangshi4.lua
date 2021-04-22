
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
                        OPTIONS = {percent = 0.32,is_inherit_damage_percent = true},
                    }, 
					{
                        CLASS = "action.QSBChangeRecoverHpLimit",
                        OPTIONS = {percent = 0.16,is_inherit_damage_percent = true},
                    }, 
	            },
	        },
	        {
		        CLASS = "action.QSBRemoveBuff",
		     	OPTIONS = {buff_id = "anqi_baihubi_buff5_2",remove_all_same_buff_id = true, enemies_except_target = true},
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