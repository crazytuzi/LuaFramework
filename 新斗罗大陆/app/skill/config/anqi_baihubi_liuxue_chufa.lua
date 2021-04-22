	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBSequence",

	    OPTIONS = {forward_mode = true},
	    ARGS = {
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 1,
                    {expression = "target:has_buff:anqi_baihubi_buff3_1", select = -1},
                }
            },
	        {
	            CLASS = "composite.QSBSelector",
	            ARGS = {
            
                    {
                        CLASS = "action.QSBApplyBuff",
                        OPTIONS = {buff_id = "anqi_baihubi_buff3_1",is_target = true },
                    },

	            },
	        },
            {
		        CLASS = "action.QSBRemoveBuff",
		        OPTIONS = {buff_id = "anqi_baihubi_buff3_1",remove_all_same_buff_id = true, enemies_except_target = true },
		    },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xiehuoshuanglian_trigger_1