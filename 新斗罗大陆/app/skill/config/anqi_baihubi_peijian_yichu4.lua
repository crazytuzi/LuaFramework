	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBSequence",
	    ARGS = {
	        -- {
         --        CLASS = "action.QSBRemoveBuff",
         --     	OPTIONS = {buff_id = "anqi_baihubi_buff1_1",remove_all_same_buff_id = true},
         -- 	},
	        {
                CLASS = "action.QSBRemoveBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_xixue_1_4",remove_all_same_buff_id = true, is_target = false},
         	},
	        {
                CLASS = "action.QSBRemoveBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_xixue_2_4",remove_all_same_buff_id = true, is_target = false},
         	},	
         	-- {
          --       CLASS = "action.QSBHitTarget",
          --   },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xiehuoshuanglian_trigger_1