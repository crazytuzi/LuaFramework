	local anqi_xiehuoshuanglian_trigger_1 ={
	    CLASS = "composite.QSBSequence",
        OPTIONS = {forward_mode = true},
	    ARGS = {
            {
                CLASS = "action.QSBArgsConditionSelector",
                OPTIONS = {
                    failed_select = 1,
                    {expression = "self:has_buff:anqi_baihubi_biaojibuff", select = 2},
                }
            },
             {
                CLASS = "composite.QSBSelector",
                ARGS = {
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                	        {
                	            CLASS = "action.QSBArgsConditionSelector",
                	            OPTIONS = {
                	                failed_select = 4,
                	                {expression = "target:hp<target:max_hp*0.3", select = 1},
                	                {expression = "target:hp<target:max_hp*0.7", select = 2},
                	                {expression = "target:hp<target:max_hp*1.1", select = 3},
                	            }
                	        },
                	        {
                	            CLASS = "composite.QSBSelector",
                	            ARGS = {

                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 1,check_target_by_skill = true},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 2,check_target_by_skill = true},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {damage_scale = 3,check_target_by_skill = true},
                                    },
                                    {
                                        CLASS = "action.QSBHitTarget",
                                        OPTIONS = {check_target_by_skill = true},
                                    },
                	            },
                	        },
                        },
                    },
                    {
                        CLASS = "composite.QSBSequence",
                        ARGS = {
                            {
                                CLASS = "action.QSBArgsConditionSelector",
                                OPTIONS = {
                                    failed_select = 1,
                                    {expression = "target:has_buff:pve_zuojia_shanghaibeishu", select = 2},
                                }
                            },
                            {
                                CLASS = "composite.QSBSelector",
                                ARGS = {
                                    {
                                        CLASS = "composite.QSBSequence",
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBArgsConditionSelector",
                                                OPTIONS = {
                                                    failed_select = 4,
                                                    {expression = "target:hp<target:max_hp*0.3", select = 1},
                                                    {expression = "target:hp<target:max_hp*0.7", select = 2},
                                                    {expression = "target:hp<target:max_hp*1.1", select = 3},
                                                }
                                            },
                                            {
                                                CLASS = "composite.QSBSelector",
                                                ARGS = {

                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {damage_scale = 1,check_target_by_skill = true},
                                                    },
                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {damage_scale = 2,check_target_by_skill = true},
                                                    },
                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {damage_scale = 3,check_target_by_skill = true},
                                                    },
                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {check_target_by_skill = true},
                                                    },
                                                },
                                            },
                                        },
                                    },
                                    {
                                         CLASS = "composite.QSBSequence",
                                        ARGS = {
                                            {
                                                CLASS = "action.QSBArgsConditionSelector",
                                                OPTIONS = {
                                                    failed_select = 4,
                                                    {expression = "target:hp<target:max_hp*0.3", select = 1},
                                                    {expression = "target:hp<target:max_hp*0.7", select = 2},
                                                    {expression = "target:hp<target:max_hp*1.1", select = 3},
                                                }
                                            },
                                            {
                                                CLASS = "composite.QSBSelector",
                                                ARGS = {

                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {damage_scale = 11,check_target_by_skill = true},
                                                    },
                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {damage_scale = 12,check_target_by_skill = true},
                                                    },
                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {damage_scale = 13,check_target_by_skill = true},
                                                    },
                                                    {
                                                        CLASS = "action.QSBHitTarget",
                                                        OPTIONS = {check_target_by_skill = true},
                                                    },
                                                },
                                            },

                                        },
                                    },
                                },
                            },
                        },
                    },
                },
            },

        	{
                CLASS = "action.QSBRemoveBuff",
             	OPTIONS = {buff_id = "anqi_baihubi_buff1_chufa1_1",remove_all_same_buff_id = true, is_target = false},
         	},	 
            -- {
            --     CLASS = "action.QSBHitTarget",
            --     OPTIONS = {check_target_by_skill = true},
            -- },
            {
                CLASS = "action.QSBPlayMountSkillAnimation",
            },
	    	{
	            CLASS = "action.QSBAttackFinish"
	        },
	    },
	}

return anqi_xiehuoshuanglian_trigger_1