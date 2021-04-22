	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBParallel",
	    ARGS = {
	        -- {
         --        CLASS = "action.QSBRemoveBuff",
         --     	OPTIONS = {buff_id = "anqi_baihubi_buff1_1",remove_all_same_buff_id = true},
         -- 	},
	        {
                CLASS = "action.QSBRemoveBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_buff1_chufa2",remove_all_same_buff_id = true, enemies_except_target = true},
         	},
	        {
                CLASS = "action.QSBRemoveBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_buff1_chufa1_2",remove_all_same_buff_id = true, enemies_except_target = true},
         	},	        
         	{
                CLASS = "action.QSBApplyBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_buff1_chufa2",is_target = true},
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